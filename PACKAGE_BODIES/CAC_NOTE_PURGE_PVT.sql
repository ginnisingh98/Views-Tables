--------------------------------------------------------
--  DDL for Package Body CAC_NOTE_PURGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CAC_NOTE_PURGE_PVT" AS
/* $Header: cacntpvb.pls 120.5 2006/01/02 21:16:34 mpadhiar noship $ */
/*=======================================================================+
 |  Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 | FILENAME                                                              |
 |   cacntpvb.pls                                                        |
 |                                                                       |
 | DESCRIPTION                                                           |
 |   - This package is implemented for Notes purge program that would be |
 |     called from TASK or SR.                                           |
 |     This is private API and should not be called by other team.       |
 |     It will be called by CAC_NOTE_PURGE_PUB.PURGE_NOTES program only. |
 |                                                                       |
 | NOTES                                                                 |
 |                                                                       |
 | Date         Developer             Change                             |
 | ----------   ---------------       -----------------------------------|
 | 08-08-2005   Abhinav Raina         Created                            |
 | 12-19-2005   Manas Padhiary	      Changed for Bug no 4612646         |
 +======================================================================*/

 Procedure purge_notes(
      p_api_version           IN   NUMBER,
      p_init_msg_list         IN   VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                IN   VARCHAR2 DEFAULT fnd_api.g_false,
      x_return_status         OUT  NOCOPY VARCHAR2,
      x_msg_data              OUT  NOCOPY VARCHAR2,
      x_msg_count             OUT  NOCOPY NUMBER,
      p_processing_set_id     IN   NUMBER,
      p_object_type           IN   VARCHAR2 )

  IS

      l_api_version   CONSTANT NUMBER := 1.0;
      l_api_name      CONSTANT VARCHAR2(30) := 'PURGE_NOTES';

	  -- Modified by Manas For bug no 4612646 (for Implementing code Review )

	  cursor c_fetch_note_ids is
      select jtf_note_id
        from jtf_notes_b
       where source_object_code = p_object_type
         and source_object_id in ( select object_id
	                             from jtf_object_purge_param_tmp
				    where processing_set_id = p_processing_set_id
				      and ( purge_status is null or purge_status <> 'E'));

      cursor c_fetch_note_contx_ids is
      select jtf_note_id
        from jtf_note_contexts
       where note_context_type = p_object_type
         and note_context_type_id in ( select object_id
	                                 from jtf_object_purge_param_tmp
				        where processing_set_id = p_processing_set_id
				          and ( purge_status is null or purge_status <> 'E'));

      TYPE t_tab_num       Is Table Of NUMBER;
      l_tab_note_id        t_tab_num:=t_tab_num();
      l_tab_note_contx_id  t_tab_num:=t_tab_num();
      l_entity_name        VARCHAR2(30) := 'JTF_NOTES_B';

 BEGIN

      SAVEPOINT purge_notes;
      x_return_status := fnd_api.g_ret_sts_success;

      IF NOT fnd_api.compatible_api_call (
			    l_api_version,
			    p_api_version,
			    l_api_name,
			    g_pkg_name
	     		    )
      THEN
	   RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
	   fnd_msg_pub.initialize;
      END IF;

       Open c_fetch_note_ids;
      Fetch c_fetch_note_ids Bulk Collect Into l_tab_note_id;
      Close c_fetch_note_ids;

      IF l_tab_note_id.COUNT > 0
      THEN
          --Delete data from JTF_NOTES_B table
          Forall j In l_tab_note_id.FIRST.. l_tab_note_id.LAST
                   Delete JTF_NOTES_B
	            Where jtf_note_id = l_tab_note_id(j);

          --Delete data from JTF_NOTES_TL table
          Forall j In l_tab_note_id.FIRST.. l_tab_note_id.LAST
                   Delete JTF_NOTES_TL
	            Where jtf_note_id = l_tab_note_id(j);

          --Delete data from JTF_NOTE_CONTEXTS table
          Forall j In l_tab_note_id.FIRST.. l_tab_note_id.LAST
                   Delete JTF_NOTE_CONTEXTS
	            Where jtf_note_id = l_tab_note_id(j);

	  -- Calling delete attachment API

	  -- Modified by Manas For bug no 4612646
	  -- Instead of directly deleting data from tables, Calling the procedure
	  -- fnd_attached_documents2_pkg.delete_attachments


	   	   For j In 1.. l_tab_note_id.LAST loop
		   	  fnd_attached_documents2_pkg.delete_attachments(X_entity_name=>l_entity_name,
			   	X_pk1_value =>to_char(l_tab_note_id(j)),
 				X_pk2_value => NULL,
				X_pk3_value => NULL,
				X_pk4_value => NULL,
 				X_pk5_value => NULL,
				X_delete_document_flag =>'Y',
				X_automatically_added_flag => NULL) ;
		  end loop;



      END IF;

       Open c_fetch_note_contx_ids;
      Fetch c_fetch_note_contx_ids Bulk Collect Into l_tab_note_contx_id;
      Close c_fetch_note_contx_ids;

      IF l_tab_note_contx_id.COUNT > 0
      THEN
          --Delete data from JTF_NOTES_B table
          Forall j In l_tab_note_contx_id.FIRST.. l_tab_note_contx_id.LAST
                   Delete JTF_NOTE_CONTEXTS
	            Where jtf_note_id = l_tab_note_contx_id(j);
      END IF;

      IF fnd_api.to_boolean(p_commit)
      THEN
	   COMMIT WORK;
      END IF;

 EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
	   ROLLBACK TO purge_notes;
	   x_return_status := fnd_api.g_ret_sts_unexp_error;
	   fnd_msg_pub.count_and_get (
  				    p_count => x_msg_count,
	                            p_data => x_msg_data
	                             );

      WHEN OTHERS
      THEN
	   ROLLBACK TO purge_notes;
	   fnd_message.set_name ('JTF', 'CAC_NOTE_UNKNOWN_ERROR');
	   fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
	   fnd_msg_pub.add;

	   x_return_status := fnd_api.g_ret_sts_unexp_error;
	   fnd_msg_pub.count_and_get (
	                            p_count => x_msg_count,
	                            p_data => x_msg_data
	                             );
 END purge_notes ;

END;

/
