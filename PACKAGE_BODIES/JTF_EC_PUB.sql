--------------------------------------------------------
--  DDL for Package Body JTF_EC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_EC_PUB" as
/* $Header: jtfpecb.pls 115.11 2003/01/13 13:46:15 siyappan ship $ */
--/**==================================================================*
--|   Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA   |
--|                        All rights reserved.                        |
--+====================================================================+
-- Start of comments
--	API name 	: JTF_EC_PUB package body
--	Type		: Public.
--	Function	: Creates/Updates/Deletes an escalation document and related reference documents,
--			  contacts and contact details (contact points).
--	Pre-reqs	: None.
--      File		: jtfpecb.pls
--
--	History		: 11-SEP-00  tivanov	Created
--
--	Standard parameters: Please review the package specification
--			for the list with parameters.
--
--	Version		: 1.0
--
--------------------------------------------------------------------------------------------
--
-- End of comments

--==========================================================================================
-- Private Procedures
--==========================================================================================
PROCEDURE Create_Esc_Note(p_notes_rec		IN	Notes_Rec_Type,
			  p_source_object_id	IN 	NUMBER,
			  p_source_object_code	IN	VARCHAR2,
			  p_user_id		IN	NUMBER,
			  p_login_id		IN      NUMBER,
			  x_msg_count           OUT NOCOPY     NUMBER,
			  x_msg_data            OUT NOCOPY     VARCHAR2,
			  x_note_id		OUT NOCOPY	NUMBER,
			  x_return_status       OUT NOCOPY     VARCHAR2) Is

l_api_name		VARCHAR2(30) := 'Create_Esc_Note';
l_api_version		NUMBER := 1.0;
l_notes_rec		Notes_Rec_Type := p_notes_rec;
l_user_id 		NUMBER := p_user_id;
l_login_id 		NUMBER := p_login_id;
l_return_status		VARCHAR2(1) := 'x';
l_note_id 		jtf_notes_b.jtf_note_id%TYPE;
l_note_context_id 	NUMBER;

BEGIN

SAVEPOINT	Create_Esc_Note;

	--  Initialize API return status to success

x_return_status := FND_API.G_RET_STS_SUCCESS;

-------------------------------------------------------------------------------------------
-- Convert the missing fields to NULLs
-------------------------------------------------------------------------------------------
	jtf_ec_util.Conv_Miss_Char(l_notes_rec.note);
	jtf_ec_util.Conv_Miss_Char(l_notes_rec.note_detail);
	jtf_ec_util.Conv_Miss_Char(l_notes_rec.note_type);
	jtf_ec_util.Conv_Miss_Char(l_notes_rec.note_context_type_01);
	jtf_ec_util.Conv_Miss_Num(l_notes_rec.note_context_type_id_01);
	jtf_ec_util.Conv_Miss_Char(l_notes_rec.note_context_type_02);
	jtf_ec_util.Conv_Miss_Num(l_notes_rec.note_context_type_id_02);
	jtf_ec_util.Conv_Miss_Char(l_notes_rec.note_context_type_03);
	jtf_ec_util.Conv_Miss_Num(l_notes_rec.note_context_type_id_03);

   if l_notes_rec.note_status = fnd_api.g_miss_char then
	l_notes_rec.note_status := 'I';
   end if;

   if (l_notes_rec.note IS NOT NULL)  then

     jtf_notes_pub.create_note(
      p_api_version    => l_api_version,
      p_init_msg_list  => fnd_api.g_false,
      p_commit         => fnd_api.g_false,
      x_return_status  => l_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_source_object_id => p_source_object_id,
      p_source_object_code => p_source_object_code,
      p_notes              => l_notes_rec.note,
      p_notes_detail       => l_notes_rec.note_detail,
      p_note_type          => l_notes_rec.note_type,
      p_note_status        => l_notes_rec.note_status,
      p_entered_by         => l_user_id,
      p_entered_date       => SYSDATE,
      p_created_by         => l_user_id,
      p_creation_date      => SYSDATE,
      p_last_updated_by    => l_user_id,
      p_last_update_date   => SYSDATE,
      p_last_update_login  => l_login_id,
      x_jtf_note_id        => l_note_id
    );

     x_note_id := l_note_id;

     if (l_return_status = fnd_api.g_ret_sts_error) then
    	raise fnd_api.g_exc_error;
     elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
    	raise fnd_api.g_exc_unexpected_error;
     end if;

   end if;

   if (l_notes_rec.note_context_type_01 is NOT NULL)
      AND
      (l_notes_rec.note_context_type_id_01 is NOT NULL)
   then

      jtf_notes_pub.create_note_context(
        x_return_status        => l_return_status,
        p_creation_date        => SYSDATE,
        p_last_updated_by      => l_user_id,
        p_last_update_date     => SYSDATE,
        p_jtf_note_id          => l_note_id,
        p_note_context_type    => l_notes_rec.note_context_type_01,
        p_note_context_type_id => l_notes_rec.note_context_type_id_01,
        p_last_update_login  => l_login_id,
        x_note_context_id      => l_note_context_id
      );

     if (l_return_status = fnd_api.g_ret_sts_error) then
    	raise fnd_api.g_exc_error;
     elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
    	raise fnd_api.g_exc_unexpected_error;
     end if;

    end if;

    if (l_notes_rec.note_context_type_02 is NOT NULL)
	AND
       (l_notes_rec.note_context_type_id_02 is NOT NULL)
    then

       jtf_notes_pub.create_note_context(
        x_return_status        => l_return_status,
        p_creation_date        => SYSDATE,
        p_last_updated_by      => l_user_id,
        p_last_update_date     => SYSDATE,
        p_jtf_note_id          => l_note_id,
        p_note_context_type    => l_notes_rec.note_context_type_02,
        p_note_context_type_id => l_notes_rec.note_context_type_id_02,
        p_last_update_login  => l_login_id,
        x_note_context_id      => l_note_context_id
      );

     if (l_return_status = fnd_api.g_ret_sts_error) then
    	raise fnd_api.g_exc_error;
     elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
    	raise fnd_api.g_exc_unexpected_error;
     end if;

    end if;

    if  (l_notes_rec.note_context_type_03 IS NOT NULL)
	AND
        (l_notes_rec.note_context_type_id_03 IS NOT NULL)
    then

      jtf_notes_pub.create_note_context(
        x_return_status        => l_return_status,
        p_creation_date        => SYSDATE,
        p_last_updated_by      => l_user_id,
        p_last_update_date     => SYSDATE,
        p_jtf_note_id          => l_note_id,
        p_note_context_type    => l_notes_rec.note_context_type_03,
        p_note_context_type_id => l_notes_rec.note_context_type_id_03,
	p_last_update_login    => l_login_id,
        x_note_context_id      => l_note_context_id
      );

     if (l_return_status = fnd_api.g_ret_sts_error) then
    	raise fnd_api.g_exc_error;
     elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
    	raise fnd_api.g_exc_unexpected_error;
     end if;

    end if;

EXCEPTION

WHEN 	fnd_api.g_exc_error
THEN
	ROLLBACK TO Create_Esc_Note;
        x_return_status := fnd_api.g_ret_sts_error;
        fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
            );

WHEN 	fnd_api.g_exc_unexpected_error
THEN

        ROLLBACK TO Create_Esc_Note;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
            );

WHEN OTHERS
THEN
        ROLLBACK TO Create_Esc_Note;
	x_return_status := fnd_api.g_ret_sts_unexp_error;

	if 	FND_MSG_PUB.Check_Msg_Level
		(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	then
    	   	FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
	end if;

        fnd_msg_pub.count_and_get ( p_count => x_msg_count,
				   p_data => x_msg_data);

END Create_Esc_Note;

PROCEDURE Create_Esc_Contacts(	p_esc_contacts_rec 	IN	Esc_Contacts_Rec_Type,
--				p_cont_points		IN	Esc_Cont_Points_Tbl_Type,
			       	p_esc_id		IN	NUMBER,
				p_esc_number		IN	VARCHAR2,
				x_msg_count           	OUT NOCOPY     NUMBER,
				x_msg_data            	OUT NOCOPY     VARCHAR2,
				x_esc_contact_id	OUT NOCOPY	NUMBER,
			       	x_return_status       	OUT NOCOPY     VARCHAR2) Is

l_api_version		NUMBER := 1.0;
l_esc_contacts		Esc_Contacts_Rec_Type	:= p_esc_contacts_rec;
-- l_cont_points		Esc_Cont_Points_Tbl_Type	:= p_cont_points;
l_escalation_id		jtf_tasks_b.task_id%TYPE	:= p_esc_id;
l_escalation_number	jtf_tasks_b.task_number%TYPE	:= p_esc_number;
l_return_status		varchar2(1) 	:= 'x';
l_api_name 		varchar2(30) 	:= 'Create_Esc_Contacts';
l_task_phone_id		jtf_task_phones.task_phone_id%TYPE := NULL;
l_escalation_contact_id jtf_task_references_b.task_reference_id%TYPE;

BEGIN

SAVEPOINT	Create_Esc_Contacts;

	--  Initialize API return status to success

x_return_status := FND_API.G_RET_STS_SUCCESS;

-------------------------------------------------------------------------------------------
-- Convert the missing fields to NULLs
-------------------------------------------------------------------------------------------
	jtf_ec_util.Conv_Miss_Num(l_esc_contacts.contact_id);
--	jtf_ec_util.Conv_Miss_Num(l_esc_contacts.task_contact_id);
--	jtf_ec_util.Conv_Miss_Num(l_esc_contacts.object_version_number);
	jtf_ec_util.Conv_Miss_Char(l_esc_contacts.contact_type_code);
	jtf_ec_util.Conv_Miss_Char(l_esc_contacts.escalation_requester_flag);
	jtf_ec_util.Conv_Miss_Char(l_esc_contacts.escalation_notify_flag);
	jtf_ec_util.Conv_Miss_Char(l_esc_contacts.attribute1);
	jtf_ec_util.Conv_Miss_Char(l_esc_contacts.attribute2);
	jtf_ec_util.Conv_Miss_Char(l_esc_contacts.attribute3);
	jtf_ec_util.Conv_Miss_Char(l_esc_contacts.attribute4);
	jtf_ec_util.Conv_Miss_Char(l_esc_contacts.attribute5);
	jtf_ec_util.Conv_Miss_Char(l_esc_contacts.attribute6);
	jtf_ec_util.Conv_Miss_Char(l_esc_contacts.attribute7);
	jtf_ec_util.Conv_Miss_Char(l_esc_contacts.attribute8);
	jtf_ec_util.Conv_Miss_Char(l_esc_contacts.attribute9);
	jtf_ec_util.Conv_Miss_Char(l_esc_contacts.attribute10);
	jtf_ec_util.Conv_Miss_Char(l_esc_contacts.attribute11);
	jtf_ec_util.Conv_Miss_Char(l_esc_contacts.attribute12);
	jtf_ec_util.Conv_Miss_Char(l_esc_contacts.attribute13);
	jtf_ec_util.Conv_Miss_Char(l_esc_contacts.attribute14);
	jtf_ec_util.Conv_Miss_Char(l_esc_contacts.attribute15);
	jtf_ec_util.Conv_Miss_Char(l_esc_contacts.attribute_category);

    if l_esc_contacts.escalation_notify_flag is NULL then
	l_esc_contacts.escalation_notify_flag := 'N';
    end if;

    if l_esc_contacts.escalation_requester_flag is NULL then
	l_esc_contacts.escalation_requester_flag := 'N';
    end if;

	-- check whether this is a duplicate contact. Skip it if it is.

	if jtf_ec_util.Contact_Duplicated(l_esc_contacts.contact_id,
					  l_esc_contacts.contact_type_code,
					  l_escalation_id) = FALSE then

	   JTF_EC_CONTACTS_PVT.CREATE_ESCALATION_CONTACTS(
     	   	P_API_VERSION     		=> l_api_version,
     	   	P_INIT_MSG_LIST   		=> fnd_api.g_false,
     		P_COMMIT          		=> fnd_api.g_false,
     		P_ESCALATION_ID   		=> l_escalation_id,
     		P_ESCALATION_NUMBER 		=> l_escalation_number,
     		P_CONTACT_ID        		=> l_esc_contacts.contact_id,
     		P_CONTACT_TYPE_CODE 		=> l_esc_contacts.contact_type_code,
     		P_ESCALATION_NOTIFY_FLAG	=> l_esc_contacts.escalation_notify_flag,
     		P_ESCALATION_REQUESTER_FLAG	=> l_esc_contacts.escalation_requester_flag,
     		X_ESCALATION_CONTACT_ID		=> l_escalation_contact_id,
     		X_RETURN_STATUS     		=> l_return_status,
     		X_MSG_DATA          		=> x_msg_data,
     		X_MSG_COUNT         		=> x_msg_count,
     		p_attribute1            	=>l_esc_contacts.attribute1,
     		p_attribute2               	=>l_esc_contacts.attribute2,
     		p_attribute3            	=>l_esc_contacts.attribute3,
     		p_attribute4            	=>l_esc_contacts.attribute4,
     		p_attribute5            	=>l_esc_contacts.attribute5,
     		p_attribute6            	=>l_esc_contacts.attribute6,
     		p_attribute7            	=>l_esc_contacts.attribute7,
     		p_attribute8            	=>l_esc_contacts.attribute8,
     		p_attribute9            	=>l_esc_contacts.attribute9,
     		p_attribute10           	=>l_esc_contacts.attribute10,
     		p_attribute11           	=>l_esc_contacts.attribute11,
     		p_attribute12           	=>l_esc_contacts.attribute12,
     		p_attribute13           	=>l_esc_contacts.attribute13,
     		p_attribute14           	=>l_esc_contacts.attribute14,
     		p_attribute15           	=>l_esc_contacts.attribute15,
     		p_attribute_category    	=>l_esc_contacts.attribute_category
);

     	  if (l_return_status = fnd_api.g_ret_sts_error) then
    	  	raise fnd_api.g_exc_error;
     	  elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
    	  	raise fnd_api.g_exc_unexpected_error;
     	  end if;

        else

          fnd_message.set_name('JTF', 'JTF_API_ALL_DUPLICATE_VALUE');
          fnd_message.set_token('API_NAME', l_api_name);
          fnd_message.set_token('DUPLICATE_VAL_PARAM', 'Contact ID: ' || to_char(l_esc_contacts.contact_id));
          fnd_msg_pub.add;
          raise fnd_api.g_exc_error;

	end if;

EXCEPTION

WHEN 	fnd_api.g_exc_error
THEN
	ROLLBACK TO Create_Esc_Contacts;
        x_return_status := fnd_api.g_ret_sts_error;
        fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
            );

WHEN 	fnd_api.g_exc_unexpected_error
THEN

        ROLLBACK TO Create_Esc_Contacts;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
            );

WHEN OTHERS
THEN
        ROLLBACK TO Create_Esc_Contacts;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	if 	FND_MSG_PUB.Check_Msg_Level
		(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	then
    	    	FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
	end if;

        fnd_msg_pub.count_and_get ( p_count => x_msg_count, p_data => x_msg_data);

END Create_Esc_Contacts;

-------------------------------------------------------------------------------------------------------
-- Create_Esc_Reference - private procedure
-------------------------------------------------------------------------------------------------------

PROCEDURE Create_Esc_Reference(	p_reference_documents_rec IN	Esc_Ref_Docs_Rec_Type,
			       	p_esc_id		IN	NUMBER,
				p_esc_number		IN	VARCHAR2,
				x_msg_count           	OUT NOCOPY     NUMBER,
				x_msg_data            	OUT NOCOPY     VARCHAR2,
				x_esc_reference_id	OUT NOCOPY	NUMBER,
			       	x_return_status       	OUT NOCOPY     VARCHAR2) Is

l_reference_documents	Esc_Ref_Docs_Rec_Type	:= p_reference_documents_rec;
l_escalation_id		jtf_tasks_b.task_id%TYPE	:= p_esc_id;
l_escalation_number	jtf_tasks_b.task_number%TYPE	:= p_esc_number;
l_return_status		varchar2(1) 	:= 'x';
l_task_ref_id		jtf_task_references_b.task_reference_id%TYPE	:= NULL; --esc id where ref doc is escalated
l_api_name 		varchar2(30) 	:= 'Create_Esc_Reference';
l_escalation_reference_id jtf_task_references_b.task_reference_id%TYPE;

BEGIN

SAVEPOINT	Create_Esc_Reference;

	--  Initialize API return status to success

x_return_status := FND_API.G_RET_STS_SUCCESS;

        l_return_status := 'x';

	jtf_ec_util.Conv_Miss_Char(l_reference_documents.object_type_code);
	jtf_ec_util.Conv_Miss_Char(l_reference_documents.object_name);
	jtf_ec_util.Conv_Miss_Num(l_reference_documents.object_id);
	jtf_ec_util.Conv_Miss_Char(l_reference_documents.reference_code);
	jtf_ec_util.Conv_Miss_Char(l_reference_documents.attribute1);
	jtf_ec_util.Conv_Miss_Char(l_reference_documents.attribute2);
	jtf_ec_util.Conv_Miss_Char(l_reference_documents.attribute3);
	jtf_ec_util.Conv_Miss_Char(l_reference_documents.attribute4);
	jtf_ec_util.Conv_Miss_Char(l_reference_documents.attribute5);
	jtf_ec_util.Conv_Miss_Char(l_reference_documents.attribute6);
	jtf_ec_util.Conv_Miss_Char(l_reference_documents.attribute7);
	jtf_ec_util.Conv_Miss_Char(l_reference_documents.attribute8);
	jtf_ec_util.Conv_Miss_Char(l_reference_documents.attribute9);
	jtf_ec_util.Conv_Miss_Char(l_reference_documents.attribute10);
	jtf_ec_util.Conv_Miss_Char(l_reference_documents.attribute11);
	jtf_ec_util.Conv_Miss_Char(l_reference_documents.attribute12);
	jtf_ec_util.Conv_Miss_Char(l_reference_documents.attribute13);
	jtf_ec_util.Conv_Miss_Char(l_reference_documents.attribute14);
	jtf_ec_util.Conv_Miss_Char(l_reference_documents.attribute15);
	jtf_ec_util.Conv_Miss_Char(l_reference_documents.attribute_category);

	if  (l_reference_documents.object_id is not NULL or
	    l_reference_documents.object_name is not NULL)
	and l_reference_documents.object_type_code is not NULL
        then
    		if jtf_ec_util.Validate_Lookup('JTF_TASK_REFERENCE_CODES',
				l_reference_documents.reference_code) = FALSE
    		then
	 		jtf_ec_util.Add_Invalid_Argument_Msg(l_api_name,		     							     l_reference_documents.reference_code, 					      			     'reference_code');
			raise fnd_api.g_exc_error;
    		end if;

	-- check whether the same document is passed twice. If yes - skip it;

		if jtf_ec_util.Reference_Duplicated(l_reference_documents.object_type_code,
				     	     l_reference_documents.object_id,
				     	     l_reference_documents.object_name,
					     l_reference_documents.reference_code,
					     l_escalation_id) = FALSE then

		    if l_reference_documents.reference_code = 'ESC' then

	   	   	   if jtf_ec_util.check_if_escalated(l_reference_documents.object_type_code,
					     	l_reference_documents.object_id,
					     	l_reference_documents.object_name,
						l_task_ref_id) = TRUE then

    			      fnd_message.set_name ('JTF', 'JTF_TK_ESC_DOC_EXIST');
			      fnd_message.set_token('OBJECT_TYPE',l_reference_documents.object_type_code);
			      fnd_message.set_token('OBJECT_NUMBER',l_reference_documents.object_name);
			      fnd_msg_pub.Add;
			      raise fnd_api.g_exc_error;
		          end if;
		    end if;

		   JTF_EC_REFERENCES_PVT.CREATE_REFERENCES(
     			P_API_VERSION       => 1.0,
     			P_INIT_MSG_LIST     => fnd_api.g_true,
     			P_COMMIT            => fnd_api.g_false,
     			P_ESCALATION_ID     => l_escalation_id,
     			P_ESCALATION_NUMBER => l_escalation_number,
     			P_OBJECT_TYPE_CODE  => l_reference_documents.object_type_code,
     			P_OBJECT_NAME       => l_reference_documents.object_name,
     			P_OBJECT_ID         => l_reference_documents.object_id,
     			P_OBJECT_DETAILS    => NULL,
     			P_REFERENCE_CODE    => l_reference_documents.reference_code,
     			P_USAGE             => NULL, -- l_reference_documents.usage,
     			X_RETURN_STATUS     => l_return_status,
     			X_MSG_DATA          => x_msg_data,
     			X_MSG_COUNT         => x_msg_count,
     			X_ESCALATION_REFERENCE_ID=>l_escalation_reference_id,
        		p_attribute1            => l_reference_documents.attribute1,
        		p_attribute2            => l_reference_documents.attribute2,
        		p_attribute3            => l_reference_documents.attribute3,
        		p_attribute4            => l_reference_documents.attribute4,
        		p_attribute5            => l_reference_documents.attribute5,
        		p_attribute6            => l_reference_documents.attribute6,
       			p_attribute7            => l_reference_documents.attribute7,
        		p_attribute8            => l_reference_documents.attribute8,
        		p_attribute9            => l_reference_documents.attribute9,
        		p_attribute10           => l_reference_documents.attribute10,
        		p_attribute11           => l_reference_documents.attribute11,
        		p_attribute12           => l_reference_documents.attribute12,
        		p_attribute13           => l_reference_documents.attribute13,
        		p_attribute14           => l_reference_documents.attribute14,
        		p_attribute15           => l_reference_documents.attribute15,
        		p_attribute_category    => l_reference_documents.attribute_category);

     			if (l_return_status = fnd_api.g_ret_sts_error) then
    			  raise fnd_api.g_exc_error;
     			elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
    			  raise fnd_api.g_exc_unexpected_error;
     			end if;
                end if;
	else

-- in case the object_id/name or object_code are not passed

	jtf_ec_util.Add_Invalid_Argument_Msg(l_api_name, 'NULL', 'object_id');
	jtf_ec_util.Add_Invalid_Argument_Msg(l_api_name, 'NULL', 'object_name');
	jtf_ec_util.Add_Invalid_Argument_Msg(l_api_name, 'NULL', 'object_type_code');
	raise fnd_api.g_exc_error;

	end if;

EXCEPTION

WHEN 	fnd_api.g_exc_error
THEN
	ROLLBACK TO Create_Esc_Reference;
        x_return_status := fnd_api.g_ret_sts_error;
        fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
            );

WHEN 	fnd_api.g_exc_unexpected_error
THEN

        ROLLBACK TO Create_Esc_Reference;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get ( p_count => x_msg_count,
            			p_data => x_msg_data);

WHEN OTHERS
THEN
        ROLLBACK TO Create_Esc_Reference;
	x_return_status := fnd_api.g_ret_sts_unexp_error;

	if 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	then
    	    	FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
	end if;

        fnd_msg_pub.count_and_get ( p_count => x_msg_count,
				   p_data => x_msg_data);
END Create_Esc_Reference;

PROCEDURE CREATE_ESCALATION (
	p_api_version         	IN	NUMBER,
	p_init_msg_list       	IN	VARCHAR2 DEFAULT fnd_api.g_false,
	p_commit              	IN	VARCHAR2 DEFAULT fnd_api.g_false,
	x_return_status       	OUT NOCOPY     VARCHAR2,
	x_msg_count           	OUT NOCOPY     NUMBER,
	x_msg_data            	OUT NOCOPY     VARCHAR2,
  	p_resp_appl_id		IN      NUMBER,
  	p_resp_id		IN      NUMBER,
  	p_user_id		IN      NUMBER,
  	p_login_id		IN      NUMBER,
	p_esc_id		IN	jtf_tasks_b.task_id%TYPE	:=NULL,
--	p_esc_number		IN	jtf_tasks_b.task_number%TYPE	:=NULL,
	p_esc_record		IN	Esc_Rec_Type,
	p_reference_documents	IN	Esc_Ref_Docs_Tbl_Type,
	p_esc_contacts		IN	Esc_Contacts_Tbl_Type,
	p_cont_points		IN	Esc_Cont_Points_Tbl_Type,
	p_notes			IN	Notes_Tbl_Type,
	x_esc_id		OUT NOCOPY     NUMBER,
	x_esc_number		OUT NOCOPY	NUMBER,
	x_workflow_process_id	OUT NOCOPY	VARCHAR2) Is

l_api_version     	CONSTANT NUMBER 	:= 1.0;
l_api_name		CONSTANT VARCHAR2(30)   := 'CREATE_ESCALATION';
l_esc_record		Esc_Rec_Type 	:= p_esc_record;
l_reference_documents	Esc_Ref_Docs_Tbl_Type	:= p_reference_documents;
l_esc_contacts		Esc_Contacts_Tbl_Type	:= p_esc_contacts;
l_cont_points		Esc_Cont_Points_Tbl_Type := p_cont_points;
l_escalation_id		jtf_tasks_b.task_id%TYPE	:= p_esc_id;
l_escalation_number	jtf_tasks_b.task_number%TYPE;
l_return_status		varchar2(1) := 'x';
l_owner_id		jtf_tasks_b.owner_id%TYPE:=NULL;
l_req_count		NUMBER := 0;
l_escalation_contact_id jtf_task_contacts.task_contact_id%TYPE;
l_escalation_reference_id jtf_task_references_b.task_reference_id%TYPE;
l_temp			VARCHAR2(10);
l_esc_status_id		jtf_tasks_b.task_status_id%TYPE;
l_task_phone_id		jtf_task_phones.task_phone_id%TYPE := NULL;
l_user_id 		NUMBER := p_user_id;
l_resp_appl_id  	NUMBER := p_resp_appl_id;
l_resp_id		NUMBER := p_resp_id;
l_login_id		NUMBER := p_login_id;
l_notes			Notes_Tbl_Type := p_notes;
l_note_id		NUMBER;
l_note_context_id 	NUMBER;
l_notif_not_sent 	VARCHAR2(2000);
l_wf_process_id		NUMBER;

cursor esc_owner(p_resource_id NUMBER)  is
SELECT 'x'
from jtf_rs_emp_dtls_vl
where resource_id = p_resource_id
and (sysdate between nvl(start_date_active, sysdate)
and nvl(end_date_active, sysdate));

cursor 	task_number(p_task_id NUMBER) is
SELECT 	task_number
FROM 	jtf_tasks_b
WHERE 	task_id = p_task_id;

BEGIN

SAVEPOINT	Create_Escalation;

-- Standard call to check for call compatibility.

IF NOT FND_API.Compatible_API_Call ( 	l_api_version,
           	    	    	 	p_api_version,
    	    	    	    	    	l_api_name,
			    	    	G_PKG_NAME)
THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

-- Check p_init_msg_list

IF FND_API.To_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
END IF;

	--  Initialize API return status to success

x_return_status := FND_API.G_RET_STS_SUCCESS;

----------------------------------------------------------------------------------------------------
-- standard customer user hook pre-processing
----------------------------------------------------------------------------------------------------
  if ( jtf_usr_hks.ok_to_execute( g_pkg_name, l_api_name, 'B', 'C' ) ) then
	jtf_ec_cuhk.Create_Escalation_Pre(
		p_esc_id		=> l_escalation_id,
		p_esc_record		=> l_esc_record,
		p_reference_documents	=> l_reference_documents,
		p_esc_contacts		=> l_esc_contacts,
		p_cont_points		=> l_cont_points,
		p_notes			=> l_notes,
		x_return_status       	=> l_return_status,
		x_msg_count           	=> x_msg_count,
		x_msg_data            	=> x_msg_data);

       if l_return_status = fnd_api.g_ret_sts_error then
      	  raise fnd_api.g_exc_error;
       elsif l_return_status = fnd_api.g_ret_sts_unexp_error then
          raise fnd_api.g_exc_unexpected_error;
       end if;

  end if;
----------------------------------------------------------------------------------------------------
-- standard verticle industry user hook pre-processing
----------------------------------------------------------------------------------------------------
  if ( jtf_usr_hks.ok_to_execute( g_pkg_name, l_api_name, 'B', 'V' ) ) then
	jtf_ec_vuhk.Create_Escalation_Pre(
		p_esc_id		=> l_escalation_id,
		p_esc_record		=> l_esc_record,
		p_reference_documents	=> l_reference_documents,
		p_esc_contacts		=> l_esc_contacts,
		p_cont_points		=> l_cont_points,
		p_notes			=> l_notes,
		x_return_status       	=> l_return_status,
		x_msg_count           	=> x_msg_count,
		x_msg_data            	=> x_msg_data);

       if l_return_status = fnd_api.g_ret_sts_error then
      	  raise fnd_api.g_exc_error;
       elsif l_return_status = fnd_api.g_ret_sts_unexp_error then
          raise fnd_api.g_exc_unexpected_error;
       end if;

  end if;

-------------------------------------------------------------------------
-- parameters validation
-------------------------------------------------------------------------
-- validate p_user
-------------------------------------------------------------------------

if l_user_id is NOT NULL then
	jtf_ec_util.Validate_Who_Info(	l_api_name, l_user_id,
			  		l_login_id, l_return_status);
     	if (l_return_status = fnd_api.g_ret_sts_error) then
    	  raise fnd_api.g_exc_error;
     	elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
    	  raise fnd_api.g_exc_unexpected_error;
     	end if;
else
	jtf_ec_util.Add_Invalid_Argument_Msg(l_api_name, 'NULL' ,'user_id');
	raise fnd_api.g_exc_error;
end if;

    if l_esc_record.esc_name is NULL or l_esc_record.esc_name = fnd_api.g_miss_char then
	l_esc_record.esc_name := g_escalation_name;
    end if;

    if l_esc_record.esc_open_date is NULL or l_esc_record.esc_open_date = fnd_api.g_miss_date then
	l_esc_record.esc_open_date := sysdate;
    end if;

-------------------------------------------------------------------------
-- validate owner -- check whether the owner is passed and if it is of correct type
-- the rest of the validation is in the tasks api
-------------------------------------------------------------------------

    l_return_status := 'x';

    if l_esc_record.esc_owner_id is NULL or l_esc_record.esc_owner_id = fnd_api.g_miss_num then
	l_esc_record.esc_owner_id := FND_PROFILE.Value_Specific('JTF_EC_DEFAULT_OWNER',
						l_user_id, l_resp_id, l_resp_appl_id);
    end if;

--Bug 2723761
--jtf_ec_util.validate_owner(l_esc_record.esc_owner_id, g_escalation_owner_type_code, l_return_status);
	if l_esc_record.esc_owner_type_code is NULL OR
	   l_esc_record.esc_owner_type_code = fnd_api.g_miss_char then
		l_esc_record.esc_owner_type_code := g_escalation_owner_type_code;
	end if;

    jtf_ec_util.validate_owner(	l_esc_record.esc_owner_id,
				l_esc_record.esc_owner_type_code,
				l_return_status);
    if l_return_status <> fnd_api.g_ret_sts_success then
	raise fnd_api.g_exc_error;
    end if;

-------------------------------------------------------------------------
-- validate status
-- if the status is not passed it will be defaulted from a profile option
-------------------------------------------------------------------------

    if (l_esc_record.status_id = fnd_api.g_miss_num or l_esc_record.status_id is NULL)
       and  (l_esc_record.status_name = fnd_api.g_miss_char or l_esc_record.status_name is NULL)
    then
	l_esc_record.status_id := FND_PROFILE.Value_Specific('JTF_EC_DEFAULT_STATUS',
				l_user_id, l_resp_id, l_resp_appl_id);
    end if;

    l_return_status := 'x';

    jtf_ec_util.Validate_Esc_Status(p_esc_status_id => l_esc_record.status_id,
				    p_esc_status_name => l_esc_record.status_name,
				    x_return_status =>	l_return_status,
				    x_esc_status_id => l_esc_status_id);

    if l_return_status <> fnd_api.g_ret_sts_success then
	raise fnd_api.g_exc_error;
    end if;

-------------------------------------------------------------------------
-- validate escalation reason
-- if the reason code is not passed it will be defaulted from a profile option
-------------------------------------------------------------------------

    if (l_esc_record.reason_code = fnd_api.g_miss_char or l_esc_record.reason_code is NULL)
    then
	l_esc_record.reason_code := FND_PROFILE.Value_Specific('JTF_EC_DEFAULT_REASON_CODE',
				l_user_id,
				l_resp_id,
				l_resp_appl_id);
    end if;

    if jtf_ec_util.Validate_Lookup('JTF_TASK_REASON_CODES',
				l_esc_record.reason_code) = FALSE
    then
	 jtf_ec_util.Add_Invalid_Argument_Msg(l_api_name, l_esc_record.reason_code, 'reason_code');
	 raise fnd_api.g_exc_error;
    end if;

-------------------------------------------------------------------------
-- validate escalation level
-- if the level is not passed it will be defaulted from a profile option
-------------------------------------------------------------------------

    if (l_esc_record.escalation_level = fnd_api.g_miss_char or l_esc_record.escalation_level is NULL)
    then
	l_esc_record.escalation_level := FND_PROFILE.Value_Specific('JTF_EC_DEFAULT_ESCALATION_LEVEL',
					l_user_id, l_resp_id,
					l_resp_appl_id);
    end if;

    if jtf_ec_util.Validate_Lookup('JTF_TASK_ESC_LEVEL',
				l_esc_record.escalation_level ) = FALSE
    then
	jtf_ec_util.Add_Invalid_Argument_Msg(l_api_name, l_esc_record.escalation_level, 'escalation_level');
	raise fnd_api.g_exc_error;
    end if;

-------------------------------------------------------------------------
-- Create escalation header
-------------------------------------------------------------------------

-------------------------------------------------------------------------
-- convert the missing fields to NULL
-------------------------------------------------------------------------

	jtf_ec_util.Conv_Miss_Char(l_esc_record.esc_name);
	jtf_ec_util.Conv_Miss_Char(l_esc_record.esc_description);
	jtf_ec_util.Conv_Miss_Char(l_esc_record.status_name);
	jtf_ec_util.Conv_Miss_Num(l_esc_record.status_id);
	jtf_ec_util.Conv_Miss_Date(l_esc_record.esc_open_date);
	jtf_ec_util.Conv_Miss_Num(l_esc_record.esc_owner_id);
	jtf_ec_util.Conv_Miss_Char(l_esc_record.esc_owner_type_code);  --bug 2723761
	jtf_ec_util.Conv_Miss_Num(l_esc_record.customer_id);
	jtf_ec_util.Conv_Miss_Char(l_esc_record.customer_number);
	jtf_ec_util.Conv_Miss_Num(l_esc_record.cust_account_id);
	jtf_ec_util.Conv_Miss_Char(l_esc_record.cust_account_number);
	jtf_ec_util.Conv_Miss_Num(l_esc_record.cust_address_id);
	jtf_ec_util.Conv_Miss_Char(l_esc_record.cust_address_number);
	jtf_ec_util.Conv_Miss_Date(l_esc_record.esc_target_date);
	jtf_ec_util.Conv_Miss_Char(l_esc_record.reason_code);
	jtf_ec_util.Conv_Miss_Char(l_esc_record.escalation_level);
	jtf_ec_util.Conv_Miss_Char(l_esc_record.attribute1);
	jtf_ec_util.Conv_Miss_Char(l_esc_record.attribute2);
	jtf_ec_util.Conv_Miss_Char(l_esc_record.attribute3);
	jtf_ec_util.Conv_Miss_Char(l_esc_record.attribute4);
	jtf_ec_util.Conv_Miss_Char(l_esc_record.attribute5);
	jtf_ec_util.Conv_Miss_Char(l_esc_record.attribute6);
	jtf_ec_util.Conv_Miss_Char(l_esc_record.attribute7);
	jtf_ec_util.Conv_Miss_Char(l_esc_record.attribute8);
	jtf_ec_util.Conv_Miss_Char(l_esc_record.attribute9);
	jtf_ec_util.Conv_Miss_Char(l_esc_record.attribute10);
	jtf_ec_util.Conv_Miss_Char(l_esc_record.attribute11);
	jtf_ec_util.Conv_Miss_Char(l_esc_record.attribute12);
	jtf_ec_util.Conv_Miss_Char(l_esc_record.attribute13);
	jtf_ec_util.Conv_Miss_Char(l_esc_record.attribute14);
	jtf_ec_util.Conv_Miss_Char(l_esc_record.attribute15);
	jtf_ec_util.Conv_Miss_Char(l_esc_record.attribute_category);

-- Bug 2650521
     JTF_EC_PVT.CREATE_ESCALATION (
     P_API_VERSION     		=> l_api_version,
     P_INIT_MSG_LIST   		=> fnd_api.g_false,
     P_COMMIT          		=> fnd_api.g_false,
     p_esc_id			=> l_escalation_id,
     P_ESCALATION_NAME 		=> l_esc_record.esc_name,
     P_DESCRIPTION     		=> l_esc_record.esc_description,
     P_ESCALATION_STATUS_NAME 	=> l_esc_record.status_name,
     P_ESCALATION_STATUS_ID   	=>l_esc_status_id ,
     P_ESCALATION_PRIORITY_NAME	=>NULL,
     P_ESCALATION_PRIORITY_ID  	=>NULL,
     P_OPEN_DATE        	=>l_esc_record.esc_open_date,
     P_CLOSE_DATE              	=>NULL,
     P_ESCALATION_OWNER_ID     	=>l_esc_record.esc_owner_id,
     P_ESCALATION_OWNER_TYPE_CODE => l_esc_record.esc_owner_type_code,   --bug 2723761
 --    P_OWNER_TERRITORY_ID  	=>l_esc_record.esc_territory_id,
     P_ASSIGNED_BY_NAME        	=>NULL,
     P_ASSIGNED_BY_ID          	=>NULL,
     P_CUSTOMER_NUMBER         	=>l_esc_record.customer_number,
     P_CUSTOMER_ID             	=>l_esc_record.customer_id,
     P_CUST_ACCOUNT_NUMBER     	=>l_esc_record.cust_account_number,
     P_CUST_ACCOUNT_ID        	=>l_esc_record.cust_account_id,
     P_ADDRESS_ID              	=>l_esc_record.cust_address_id,
     P_ADDRESS_NUMBER          	=>l_esc_record.cust_address_number,
     P_TARGET_DATE       	=>l_esc_record.esc_target_date,
     P_REASON_CODE             	=>l_esc_record.reason_code,
     P_PRIVATE_FLAG            	=>NULL, --l_esc_record.private_flag,
     P_PUBLISH_FLAG            	=>NULL, --l_esc_record.publish_flag,
     P_WORKFLOW_PROCESS_ID    	=>NULL,
     P_ESCALATION_LEVEL        	=>l_esc_record.escalation_level,
     X_RETURN_STATUS           	=>l_return_status,
     X_MSG_COUNT               	=>x_msg_count,
     X_MSG_DATA                	=>x_msg_data,
     X_ESCALATION_ID           	=>l_escalation_id,
     p_attribute1            	=>l_esc_record.attribute1,
     p_attribute2               =>l_esc_record.attribute2,
     p_attribute3            	=>l_esc_record.attribute3,
     p_attribute4            	=>l_esc_record.attribute4,
     p_attribute5            	=>l_esc_record.attribute5,
     p_attribute6            	=>l_esc_record.attribute6,
     p_attribute7            	=>l_esc_record.attribute7,
     p_attribute8            	=>l_esc_record.attribute8,
     p_attribute9            	=>l_esc_record.attribute9,
     p_attribute10           	=>l_esc_record.attribute10,
     p_attribute11           	=>l_esc_record.attribute11,
     p_attribute12           	=>l_esc_record.attribute12,
     p_attribute13           	=>l_esc_record.attribute13,
     p_attribute14           	=>l_esc_record.attribute14,
     p_attribute15           	=>l_esc_record.attribute15,
     p_attribute_category    	=>l_esc_record.attribute_category
     );

     if (l_return_status = fnd_api.g_ret_sts_error) then
    	raise fnd_api.g_exc_error;
     elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
    	raise fnd_api.g_exc_unexpected_error;
     end if;

	open task_number(l_escalation_id);
	fetch task_number into l_escalation_number;
	if task_number%NOTFOUND then
	   close task_number;
           RAISE fnd_api.g_exc_unexpected_error;
        end if;
        close task_number;

     for j in 1..l_esc_contacts.COUNT loop

	l_return_status := 'x';

      if l_esc_contacts(j).action_code = 'I' then

	Create_Esc_Contacts(p_esc_contacts_rec => l_esc_contacts(j),
			   -- p_cont_points => l_cont_points,
			    p_esc_id => l_escalation_id,
			    p_esc_number => l_escalation_number,
			    x_msg_count => x_msg_count,
			    x_msg_data => x_msg_data,
			    x_esc_contact_id => l_escalation_contact_id,
			    x_return_status => l_return_status);

     	if (l_return_status = fnd_api.g_ret_sts_error) then
    		raise fnd_api.g_exc_error;
     	elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
    		raise fnd_api.g_exc_unexpected_error;
     	end if;

      end if;

    end loop;

-------------------------------------------------------------------------
-- validate Requester
-------------------------------------------------------------------------

    l_return_status := 'x';

   jtf_ec_util.Validate_Requester(l_escalation_id, l_return_status);

    if l_return_status <> fnd_api.g_ret_sts_success then
	raise fnd_api.g_exc_error;
    end if;

-------------------------------------------------------------------------
-- ** Insert the contact points
-------------------------------------------------------------------------

	for j in 1..l_cont_points.COUNT loop

		if l_cont_points(j).action_code = 'I' then

		   l_return_status := 'x';

	-- check whether this is a valid contact for this escalation. Also get the task contact id.

		   jtf_ec_util.Validate_Contact_id(l_cont_points(j).contact_id,
						     l_cont_points(j).contact_type_code,
		    	      			     l_escalation_id,
						     l_escalation_contact_id,
						     l_return_status);

     		   if (l_return_status = fnd_api.g_ret_sts_error) then
    			raise fnd_api.g_exc_error;
     		   elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
    			raise fnd_api.g_exc_unexpected_error;
     		   end if;

		jtf_ec_util.Conv_Miss_Char(l_cont_points(j).attribute1);
		jtf_ec_util.Conv_Miss_Char(l_cont_points(j).attribute2);
		jtf_ec_util.Conv_Miss_Char(l_cont_points(j).attribute3);
		jtf_ec_util.Conv_Miss_Char(l_cont_points(j).attribute4);
		jtf_ec_util.Conv_Miss_Char(l_cont_points(j).attribute5);
		jtf_ec_util.Conv_Miss_Char(l_cont_points(j).attribute6);
		jtf_ec_util.Conv_Miss_Char(l_cont_points(j).attribute7);
		jtf_ec_util.Conv_Miss_Char(l_cont_points(j).attribute8);
		jtf_ec_util.Conv_Miss_Char(l_cont_points(j).attribute9);
		jtf_ec_util.Conv_Miss_Char(l_cont_points(j).attribute10);
		jtf_ec_util.Conv_Miss_Char(l_cont_points(j).attribute11);
		jtf_ec_util.Conv_Miss_Char(l_cont_points(j).attribute12);
		jtf_ec_util.Conv_Miss_Char(l_cont_points(j).attribute13);
		jtf_ec_util.Conv_Miss_Char(l_cont_points(j).attribute14);
		jtf_ec_util.Conv_Miss_Char(l_cont_points(j).attribute15);
		jtf_ec_util.Conv_Miss_Char(l_cont_points(j).attribute_category);

	-- insert the phone_id (contact_point) for this contact

		  Jtf_Task_Phones_Pub.create_task_phones (
        		p_api_version   	=> l_api_version,
        		p_init_msg_list         => fnd_api.g_false,
        		p_commit                => fnd_api.g_false,
        		p_task_contact_id       => l_escalation_contact_id,
			p_phone_id              => l_cont_points(j).contact_point_id,
        		x_task_phone_id         => l_task_phone_id,
        		x_return_status         => l_return_status,
        		x_msg_data              => x_msg_data,
        		x_msg_count             => x_msg_count,
        		p_attribute1            => l_cont_points(j).attribute1,
        		p_attribute2            => l_cont_points(j).attribute2,
        		p_attribute3            => l_cont_points(j).attribute3,
        		p_attribute4            => l_cont_points(j).attribute4,
        		p_attribute5            => l_cont_points(j).attribute5,
        		p_attribute6            => l_cont_points(j).attribute6,
       			p_attribute7            => l_cont_points(j).attribute7,
        		p_attribute8            => l_cont_points(j).attribute8,
        		p_attribute9            => l_cont_points(j).attribute9,
        		p_attribute10           => l_cont_points(j).attribute10,
        		p_attribute11           => l_cont_points(j).attribute11,
        		p_attribute12           => l_cont_points(j).attribute12,
        		p_attribute13           => l_cont_points(j).attribute13,
        		p_attribute14           => l_cont_points(j).attribute14,
        		p_attribute15           => l_cont_points(j).attribute15,
        		p_attribute_category    => l_cont_points(j).attribute_category
    			);

     	  	 if (l_return_status = fnd_api.g_ret_sts_error) then
    	  		raise fnd_api.g_exc_error;
     	  	 elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
    	  		raise fnd_api.g_exc_unexpected_error;
     	  	 end if;

		end if;

  end loop;

-------------------------------------------------------------------------
-- Insert the Reference Documents
-------------------------------------------------------------------------

   for j in 1..l_reference_documents.COUNT loop

	---------------------------------------------------------------------------------
	-- check reference code
	-- if the reference code is not passed it will be defaulted from a profile option
	----------------------------------------------------------------------------------

     if  l_reference_documents(j).action_code = 'I' then

    	if (l_reference_documents(j).reference_code = fnd_api.g_miss_char
	   OR 		    	   l_reference_documents(j).reference_code is NULL)
    	then
	   l_reference_documents(j).reference_code := FND_PROFILE.Value_Specific('JTF_EC_DEFAULT_REF_TYPE',
					    l_user_id, l_resp_id, l_resp_appl_id);
        end if;

	Create_Esc_Reference(	l_reference_documents(j),
			       	l_escalation_id,
				l_escalation_number,
				x_msg_count,
				x_msg_data,
				l_escalation_reference_id,
			       	l_return_status);

     	if (l_return_status = fnd_api.g_ret_sts_error) then
    		raise fnd_api.g_exc_error;
     	elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
    		raise fnd_api.g_exc_unexpected_error;
     	end if;

     end if;

   end loop;

-------------------------------------------------------------------------------------------
-- Create Notes
-------------------------------------------------------------------------------------------

for j in 1..l_notes.COUNT loop

	l_return_status := 'x';

	Create_Esc_Note(  l_notes(j),
			  l_escalation_id,
			  g_escalation_code,
			  l_user_id,
			  l_login_id,
			  x_msg_count,
			  x_msg_data,
			  l_note_id,
			  l_return_status);

     if (l_return_status = fnd_api.g_ret_sts_error) then
    	raise fnd_api.g_exc_error;
     elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
    	raise fnd_api.g_exc_unexpected_error;
     end if;

end loop;

-------------------------------------------------------------------------------------
-- Send Notifications. Call to Workflow. JTFEC WF item.
-------------------------------------------------------------------------------------

   JTF_EC_WORKFLOW_PKG.Start_Resc_Workflow(
       P_API_VERSION             =>l_api_version,
       P_INIT_MSG_LIST           =>fnd_api.g_false,
       P_COMMIT                  =>fnd_api.g_false,
       X_RETURN_STATUS           =>l_return_status,
       X_MSG_COUNT               =>x_msg_count,
       X_MSG_DATA                =>x_msg_data,
       P_TASK_ID                 =>l_escalation_id,
       P_DOC_CREATED             =>'Y',
       x_notif_not_sent	 	 => l_notif_not_sent,
       X_WF_PROCESS_ID           =>l_wf_process_id);

     if (l_return_status = fnd_api.g_ret_sts_error) then
    	raise fnd_api.g_exc_error;
     elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
    	raise fnd_api.g_exc_unexpected_error;
     end if;

-- Insert the wf_process_id

	 update jtf_tasks_b
         set workflow_process_id = l_wf_process_id
         where task_id = l_escalation_id;

----------------------------------------------------------------------------------------------------
-- standard verticle industry user hook post-processing
----------------------------------------------------------------------------------------------------
  if ( jtf_usr_hks.ok_to_execute( g_pkg_name, l_api_name, 'A', 'V' ) ) then
	jtf_ec_vuhk.Create_Escalation_Post(
		p_esc_id		=> l_escalation_id,
		p_esc_record		=> l_esc_record,
		p_reference_documents	=> l_reference_documents,
		p_esc_contacts		=> l_esc_contacts,
		p_cont_points		=> l_cont_points,
		p_notes			=> l_notes,
		x_return_status       	=> l_return_status,
		x_msg_count           	=> x_msg_count,
		x_msg_data            	=> x_msg_data);

       if l_return_status = fnd_api.g_ret_sts_error then
      	  raise fnd_api.g_exc_error;
       elsif l_return_status = fnd_api.g_ret_sts_unexp_error then
          raise fnd_api.g_exc_unexpected_error;
       end if;

  end if;

----------------------------------------------------------------------------------------------------
-- standard customer user hook post-processing
----------------------------------------------------------------------------------------------------
  if ( jtf_usr_hks.ok_to_execute( g_pkg_name, l_api_name, 'A', 'C' ) ) then
	jtf_ec_cuhk.Create_Escalation_Post(
		p_esc_id		=> l_escalation_id,
		p_esc_record		=> l_esc_record,
		p_reference_documents	=> l_reference_documents,
		p_esc_contacts		=> l_esc_contacts,
		p_cont_points		=> l_cont_points,
		p_notes			=> l_notes,
		x_return_status       	=> l_return_status,
		x_msg_count           	=> x_msg_count,
		x_msg_data            	=> x_msg_data);

       if l_return_status = fnd_api.g_ret_sts_error then
      	  raise fnd_api.g_exc_error;
       elsif l_return_status = fnd_api.g_ret_sts_unexp_error then
          raise fnd_api.g_exc_unexpected_error;
       end if;

  end if;

	-- Standard check of p_commit.
	x_esc_id := l_escalation_id;
	x_esc_number := l_escalation_number;
        x_workflow_process_id := l_wf_process_id;

	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;

	fnd_msg_pub.count_and_get
    	(  	p_count	=>      x_msg_count,
        	p_data 	=>	x_msg_data
    	);

EXCEPTION

WHEN 	fnd_api.g_exc_error
THEN
	ROLLBACK TO Create_Escalation;
        x_return_status := fnd_api.g_ret_sts_error;

        fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
            );

WHEN 	fnd_api.g_exc_unexpected_error
THEN

        ROLLBACK TO Create_Escalation;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get ( p_count => x_msg_count,
            			p_data => x_msg_data);

WHEN OTHERS
THEN
        ROLLBACK TO Create_Escalation;
	x_return_status := fnd_api.g_ret_sts_unexp_error;

	if 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	then
    	    	FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
	end if;

        fnd_msg_pub.count_and_get ( p_count => x_msg_count,
				   p_data => x_msg_data);
END CREATE_ESCALATION;

PROCEDURE UPDATE_ESCALATION  (
	p_api_version         	IN	NUMBER,
	p_init_msg_list       	IN	VARCHAR2 DEFAULT fnd_api.g_false,
	p_commit              	IN	VARCHAR2 DEFAULT fnd_api.g_false,
	x_return_status       	OUT NOCOPY     VARCHAR2,
	x_msg_count           	OUT NOCOPY     NUMBER,
	x_msg_data            	OUT NOCOPY     VARCHAR2,
  	p_resp_appl_id		IN      NUMBER	:= NULL,
  	p_resp_id		IN      NUMBER	:= NULL,
  	p_user_id		IN      NUMBER	:= NULL, -- used for last updated by
  	p_login_id		IN      NUMBER	:= NULL,
	p_esc_id		IN	jtf_tasks_b.task_id%TYPE	:=NULL,
	p_esc_number		IN	jtf_tasks_b.task_number%TYPE	:=NULL,
	p_object_version	IN	NUMBER,
	p_esc_record		IN	Esc_Rec_Type,
	p_reference_documents	IN	Esc_Ref_Docs_Tbl_Type,
	p_esc_contacts		IN	Esc_Contacts_Tbl_Type,
	p_cont_points		IN	Esc_Cont_Points_Tbl_Type,
	p_notes			IN	Notes_Tbl_Type,
        x_object_version_number OUT NOCOPY	NUMBER,
	x_workflow_process_id	OUT NOCOPY	VARCHAR2) Is

l_api_version     	CONSTANT NUMBER 	:= 1.0;
l_api_name		CONSTANT VARCHAR2(30)   := 'UPDATE_ESCALATION';
l_esc_record		Esc_Rec_Type 	:= p_esc_record;
l_reference_documents	Esc_Ref_Docs_Tbl_Type	:= p_reference_documents;
l_esc_contacts		Esc_Contacts_Tbl_Type	:= p_esc_contacts;
l_cont_points		Esc_Cont_Points_Tbl_Type := p_cont_points;
l_notes			Notes_Tbl_Type	:= p_notes;
l_note_id		jtf_notes_b.jtf_note_id%TYPE;
l_escalation_id		jtf_tasks_b.task_id%TYPE	:= NULL;
l_escalation_number	jtf_tasks_b.task_number%TYPE	:= NULL;
l_esc_status_id		jtf_tasks_b.task_status_id%TYPE;
l_object_version_number jtf_tasks_b.object_version_number%TYPE := p_object_version;
l_user_id 		NUMBER := p_user_id;
l_resp_appl_id  	NUMBER := p_resp_appl_id;
l_resp_id		NUMBER := p_resp_id;
l_login_id		NUMBER := p_login_id;
l_return_status		varchar2(1) := 'x';
l_closed_flag		varchar2(1) := 'N';
l_esc_close_date	jtf_tasks_b.actual_end_date%TYPE;
l_esc_task_id		jtf_tasks_b.task_id%TYPE	:= NULL;  --esc id where ref doc is escalated
l_task_ref_id		jtf_task_references_b.task_reference_id%TYPE;
l_escalation_reference_id jtf_task_references_b.task_reference_id%TYPE;
l_escalation_contact_id jtf_task_references_b.task_reference_id%TYPE;
l_task_phone_id		jtf_task_phones.task_phone_id%TYPE := NULL;
l_owner_changed		VARCHAR2(1) 	:= 'N';
l_level_changed		VARCHAR2(1)	:= 'N';
l_status_changed	VARCHAR2(1)	:= 'N';
l_target_date_changed	VARCHAR2(1)	:= 'N';
l_old_owner_id		jtf_tasks_b.owner_id%TYPE;
l_old_status_id		jtf_tasks_b.task_status_id%TYPE;
l_old_escalation_level	jtf_tasks_b.escalation_level%TYPE;
l_old_target_date	jtf_tasks_b.planned_end_date%TYPE;
l_notif_not_sent 	VARCHAR2(2000);
l_wf_process_id		NUMBER;
l_object_name		jtf_task_references_b.object_name%TYPE;
l_object_id		jtf_task_references_b.object_id%TYPE;
l_object_type_code	jtf_task_references_b.object_type_code%TYPE;

cursor c_cont_phone_id (p_task_contact_id NUMBER) is
select task_phone_id, object_version_number
from jtf_task_phones
where task_contact_id = p_task_contact_id;

cursor c_get_old_esc_data(p_escalation_id NUMBER) Is
select 	owner_id, task_status_id, escalation_level, planned_end_date
from 	jtf_tasks_b
where 	task_id = p_escalation_id;

cursor c_get_ref_details(p_task_ref_id NUMBER) Is
Select  object_type_code,
	object_id,
       	object_name
from	jtf_task_references_b
where 	task_reference_id = p_task_ref_id;

BEGIN

SAVEPOINT	Update_Escalation;

-- Standard call to check for call compatibility.

IF NOT FND_API.Compatible_API_Call ( 	l_api_version, p_api_version,
    	    	    	    	    	l_api_name, G_PKG_NAME)
THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

-- Check p_init_msg_list

IF FND_API.To_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
END IF;

	--  Initialize API return status to success

x_return_status := FND_API.G_RET_STS_SUCCESS;

--------------------------------------------------------------------------------------------
-- standard customer user hook pre-processing
--------------------------------------------------------------------------------------------
  if ( jtf_usr_hks.ok_to_execute( g_pkg_name, l_api_name, 'B', 'C' ) ) then
	jtf_ec_cuhk.Update_Escalation_Pre(
		p_esc_id		=> l_escalation_id,
		p_esc_number		=> l_escalation_number,
		p_object_version	=> l_object_version_number,
		p_esc_record		=> l_esc_record,
		p_reference_documents	=> l_reference_documents,
		p_esc_contacts		=> l_esc_contacts,
		p_cont_points		=> l_cont_points,
		p_notes			=> l_notes,
		x_return_status       	=> l_return_status,
		x_msg_count           	=> x_msg_count,
		x_msg_data            	=> x_msg_data);

       if l_return_status = fnd_api.g_ret_sts_error then
      	  raise fnd_api.g_exc_error;
       elsif l_return_status = fnd_api.g_ret_sts_unexp_error then
          raise fnd_api.g_exc_unexpected_error;
       end if;

  end if;
--------------------------------------------------------------------------------------------
-- standard verticle industry user hook pre-processing
--------------------------------------------------------------------------------------------
  if ( jtf_usr_hks.ok_to_execute( g_pkg_name, l_api_name, 'B', 'V' ) ) then

	jtf_ec_vuhk.Update_Escalation_Pre(
		p_esc_id		=> l_escalation_id,
		p_esc_number		=> l_escalation_number,
		p_object_version	=> l_object_version_number,
		p_esc_record		=> l_esc_record,
		p_reference_documents	=> l_reference_documents,
		p_esc_contacts		=> l_esc_contacts,
		p_cont_points		=> l_cont_points,
		p_notes			=> l_notes,
		x_return_status       	=> l_return_status,
		x_msg_count           	=> x_msg_count,
		x_msg_data            	=> x_msg_data);

       if l_return_status = fnd_api.g_ret_sts_error then
      	  raise fnd_api.g_exc_error;
       elsif l_return_status = fnd_api.g_ret_sts_unexp_error then
          raise fnd_api.g_exc_unexpected_error;
       end if;

  end if;

-------------------------------------------------------------------------
-- parameters validation
-------------------------------------------------------------------------
-- validate p_user
-------------------------------------------------------------------------

if l_user_id is NOT NULL then
	jtf_ec_util.Validate_Who_Info(	l_api_name, l_user_id,
			  		l_login_id, l_return_status);
     	if (l_return_status = fnd_api.g_ret_sts_error) then
    	  raise fnd_api.g_exc_error;
     	elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
    	  raise fnd_api.g_exc_unexpected_error;
     	end if;
else
	jtf_ec_util.Add_Invalid_Argument_Msg(l_api_name, 'NULL' ,'user_id');
	raise fnd_api.g_exc_error;
end if;

-------------------------------------------------------------------------
-- Validate Escalation Task
-- Performs also number to id conversion
-------------------------------------------------------------------------

if p_esc_id <> fnd_api.g_miss_num  then
	l_escalation_id := p_esc_id;
    	if p_esc_number <> fnd_api.g_miss_char then
		jtf_ec_util.add_param_ignored_msg(l_api_name, 'p_esc_number');
	end if;
elsif p_esc_number <> fnd_api.g_miss_char then
	l_escalation_number := p_esc_number;
else jtf_ec_util.add_missing_param_msg(l_api_name, 'p_esc_name');
end if;

jtf_ec_util.Validate_Esc_Document(l_escalation_id, l_escalation_number,
		      l_esc_task_id,	-- converted number to id
		      l_return_status);

if (l_return_status = fnd_api.g_ret_sts_error) then
    	raise fnd_api.g_exc_error;
elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
    	raise fnd_api.g_exc_unexpected_error;
end if;

l_escalation_id := l_esc_task_id;

-------------------------------------------------------------------------
-- parameters validation
--
-- check whether some required parameters are set to NULL
-------------------------------------------------------------------------
-- validate status
-------------------------------------------------------------------------
    l_esc_status_id := l_esc_record.status_id;

    if (l_esc_record.status_id is NULL)
       and (l_esc_record.status_name is NULL)
    then
      	jtf_ec_util.Add_Invalid_Argument_Msg(l_api_name, 'NULL', 'status_id');
     	jtf_ec_util.Add_Invalid_Argument_Msg(l_api_name, 'NULL', 'status_name');
	raise fnd_api.g_exc_error;
    end if;

    l_return_status := 'x';

if l_esc_record.status_id <> fnd_api.g_miss_num
   or l_esc_record.status_name <> fnd_api.g_miss_char then

    jtf_ec_util.Validate_Esc_Status(p_esc_status_id => l_esc_record.status_id,
				    p_esc_status_name => l_esc_record.status_name,
				    x_return_status =>	l_return_status,
				    x_esc_status_id => l_esc_status_id);

    if l_return_status <> fnd_api.g_ret_sts_success then
	raise fnd_api.g_exc_error;
    end if;

end if;

----------------------------------------------------------------------------------------
-- validate level. It is required parameter
----------------------------------------------------------------------------------------

    if l_esc_record.escalation_level is NULL then
	 jtf_ec_util.Add_Invalid_Argument_Msg(l_api_name, l_esc_record.escalation_level, 'escalation_level');
	 raise fnd_api.g_exc_error;
    elsif l_esc_record.escalation_level <> fnd_api.g_miss_char then

    	 if jtf_ec_util.Validate_Lookup('JTF_TASK_ESC_LEVEL',
				l_esc_record.escalation_level ) = FALSE
    	 then
		jtf_ec_util.Add_Invalid_Argument_Msg(l_api_name, l_esc_record.escalation_level, 'escalation_level');
	 	raise fnd_api.g_exc_error;
    	 end if;

    end if;

----------------------------------------------------------------------------------------
-- Set the close date to sysdate if it is not passed and the Status is updated to 'Closed'
----------------------------------------------------------------------------------------

    jtf_ec_util.Check_Completed_Status(l_esc_status_id, l_escalation_id,
				      l_esc_record.escalation_level,
				      l_closed_flag, l_return_status);

    if (l_return_status = fnd_api.g_ret_sts_error) then
    	raise fnd_api.g_exc_error;
    elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
    	raise fnd_api.g_exc_unexpected_error;
    elsif l_closed_flag = 'Y' then
	l_esc_close_date := sysdate;
    end if;

--Bug 2723761
-------------------------------------------------------------------------
-- validate Escalation Owner
-------------------------------------------------------------------------
	if l_esc_record.esc_owner_type_code is NULL OR
	   l_esc_record.esc_owner_type_code = fnd_api.g_miss_char then
		l_esc_record.esc_owner_type_code := g_escalation_owner_type_code;
	end if;

    jtf_ec_util.validate_owner(	l_esc_record.esc_owner_id,
				l_esc_record.esc_owner_type_code,
				l_return_status);
    if l_return_status <> fnd_api.g_ret_sts_success then
	raise fnd_api.g_exc_error;
    end if;
--End

----------------------------------------------------------------------------------------
-- validate reason code
----------------------------------------------------------------------------------------

    if (l_esc_record.reason_code <> fnd_api.g_miss_char)
    then
       	    if jtf_ec_util.Validate_Lookup('JTF_TASK_REASON_CODES',
				l_esc_record.reason_code) = FALSE
    	    then
	 	jtf_ec_util.Add_Invalid_Argument_Msg(l_api_name, l_esc_record.reason_code, 'reason_code');
		raise fnd_api.g_exc_error;
    	    end if;
    end if;

open c_get_old_esc_data(l_escalation_id);
fetch c_get_old_esc_data into 	l_old_owner_id,
				l_old_status_id, l_old_escalation_level,
				l_old_target_date;
close c_get_old_esc_data;

-------------------------------------------------------------------------
-- Update escalation header
-------------------------------------------------------------------------

--bug 2723761
if NOT (l_esc_record.esc_name = FND_API.G_MISS_CHAR
    and l_esc_record.esc_description = FND_API.G_MISS_CHAR
    and l_esc_record.status_id = FND_API.G_MISS_NUM
    and l_esc_record.status_name = FND_API.G_MISS_CHAR
    and l_esc_record.esc_owner_id = FND_API.G_MISS_NUM
    and l_esc_record.esc_owner_type_code = FND_API.G_MISS_CHAR
    and l_esc_record.cust_account_id = FND_API.G_MISS_NUM
    and l_esc_record.cust_account_number = FND_API.G_MISS_CHAR
    and l_esc_record.cust_address_id = FND_API.G_MISS_NUM
    and l_esc_record.cust_address_number = FND_API.G_MISS_CHAR
    and l_esc_record.esc_target_date	 = FND_API.G_MISS_DATE
    and l_esc_record.reason_code = FND_API.G_MISS_CHAR
    and l_esc_record.escalation_level = FND_API.G_MISS_CHAR
    and l_esc_record.attribute1 = FND_API.G_MISS_CHAR
    and l_esc_record.attribute2 = FND_API.G_MISS_CHAR
    and l_esc_record.attribute3 = FND_API.G_MISS_CHAR
    and l_esc_record.attribute4 = FND_API.G_MISS_CHAR
    and l_esc_record.attribute5 = FND_API.G_MISS_CHAR
    and l_esc_record.attribute6 = FND_API.G_MISS_CHAR
    and l_esc_record.attribute7 = FND_API.G_MISS_CHAR
    and l_esc_record.attribute8 = FND_API.G_MISS_CHAR
    and l_esc_record.attribute9 = FND_API.G_MISS_CHAR
    and l_esc_record.attribute10 = FND_API.G_MISS_CHAR
    and l_esc_record.attribute11 = FND_API.G_MISS_CHAR
    and l_esc_record.attribute12 = FND_API.G_MISS_CHAR
    and l_esc_record.attribute13 = FND_API.G_MISS_CHAR
    and l_esc_record.attribute14 = FND_API.G_MISS_CHAR
    and l_esc_record.attribute15 = FND_API.G_MISS_CHAR
    and l_esc_record.attribute_category = FND_API.G_MISS_CHAR) then

   JTF_EC_PVT.UPDATE_ESCALATION (
     P_API_VERSION     		=> l_api_version,
     P_INIT_MSG_LIST   		=> fnd_api.g_false,
     P_COMMIT          		=> fnd_api.g_false,
     P_OBJECT_VERSION_NUMBER 	=> l_object_version_number,
     P_ESCALATION_ID   		=> l_escalation_id,
     P_ESCALATION_NUMBER 	=> l_escalation_number,
     P_ESCALATION_NAME 		=> l_esc_record.esc_name,
     P_DESCRIPTION     		=> l_esc_record.esc_description,
     P_ESCALATION_STATUS_NAME 	=> l_esc_record.status_name,
     P_ESCALATION_STATUS_ID     => l_esc_status_id,
 --    P_OPEN_DATE      		=> l_esc_record.esc_open_date, -- cannot be updated
     P_CLOSE_DATE		=> l_esc_close_date,
     P_ESCALATION_PRIORITY_NAME	=> NULL,
     P_ESCALATION_PRIORITY_ID  	=> NULL,
     P_OWNER_ID     		=> l_esc_record.esc_owner_id,
     P_ESCALATION_OWNER_TYPE_CODE => l_esc_record.esc_owner_type_code,   --bug 2723761
--     P_OWNER_TERRITORY_ID       => l_esc_record.esc_territory_id, -- not updatable in the form
     P_ASSIGNED_BY_NAME         => NULL,
     P_ASSIGNED_BY_ID          	=> NULL,
--     P_CUSTOMER_NUMBER         	=> l_esc_record.customer_number, -- not updatable in the form
--     P_CUSTOMER_ID             	=> l_esc_record.customer_id,
     P_CUST_ACCOUNT_NUMBER      => l_esc_record.cust_account_number,
     P_CUST_ACCOUNT_ID         	=> l_esc_record.cust_account_id,
     P_ADDRESS_ID              	=> l_esc_record.cust_address_id,
     P_ADDRESS_NUMBER          	=> l_esc_record.cust_address_number,
     P_TARGET_DATE             	=> l_esc_record.esc_target_date,
     P_REASON_CODE             	=> l_esc_record.reason_code,
     P_PRIVATE_FLAG            	=> NULL,
     P_PUBLISH_FLAG            	=> NULL,
     P_WORKFLOW_PROCESS_ID     	=> NULL,
     P_ESCALATION_LEVEL        	=> l_esc_record.escalation_level,
     X_RETURN_STATUS           	=> l_return_status,
     X_MSG_COUNT               	=> x_msg_count,
     X_MSG_DATA                	=> x_msg_data,
     p_attribute1            	=> l_esc_record.attribute1,
     p_attribute2               => l_esc_record.attribute2,
     p_attribute3            	=> l_esc_record.attribute3,
     p_attribute4            	=> l_esc_record.attribute4,
     p_attribute5            	=> l_esc_record.attribute5,
     p_attribute6            	=> l_esc_record.attribute6,
     p_attribute7            	=> l_esc_record.attribute7,
     p_attribute8            	=> l_esc_record.attribute8,
     p_attribute9            	=> l_esc_record.attribute9,
     p_attribute10           	=> l_esc_record.attribute10,
     p_attribute11           	=> l_esc_record.attribute11,
     p_attribute12           	=> l_esc_record.attribute12,
     p_attribute13           	=> l_esc_record.attribute13,
     p_attribute14           	=> l_esc_record.attribute14,
     p_attribute15           	=> l_esc_record.attribute15,
     p_attribute_category    	=> l_esc_record.attribute_category
     );

    if (l_return_status = fnd_api.g_ret_sts_error) then
    	raise fnd_api.g_exc_error;
    elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
    	raise fnd_api.g_exc_unexpected_error;
    end if;

end if;

--------------------------------------------------------------------------------------------------
-- Update, Insert, Delete (depends on the action code)  the reference documents.
-- action_code = 'I' - inserts a new reference document.
-- action_code = 'U' - updates the reference document. Just the reference type could be updated
-- action_code = 'D' - removes a reference document
--------------------------------------------------------------------------------------------------

   for j in 1..l_reference_documents.COUNT loop

	if l_reference_documents(j).action_code = 'D' then

		l_return_status := 'x';

	-- validate the reference document against the escalation document id.

		jtf_ec_util.Validate_Task_Reference_Id(	l_reference_documents(j).reference_id,
		    	      	     			l_escalation_id, l_return_status);

    		if (l_return_status = fnd_api.g_ret_sts_error) then
    			raise fnd_api.g_exc_error;
    		elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
    			raise fnd_api.g_exc_unexpected_error;
    		end if;

		JTF_EC_REFERENCES_PVT.DELETE_REFERENCES(
     		    	P_API_VERSION      => l_api_version,
      			P_INIT_MSG_LIST    => fnd_api.g_false,
      			P_COMMIT           => fnd_api.g_false,
      			P_OBJECT_VERSION_NUMBER => l_reference_documents(j).object_version_number,
      			P_ESCALATION_REFERENCE_ID => l_reference_documents(j).reference_id,
      			X_RETURN_STATUS     =>l_return_status,
      			X_MSG_COUNT         =>x_msg_count,
      			X_MSG_DATA          =>x_msg_data);

    		if (l_return_status = fnd_api.g_ret_sts_error) then
    			raise fnd_api.g_exc_error;
    		elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
    			raise fnd_api.g_exc_unexpected_error;
    		end if;
	elsif l_reference_documents(j).action_code = 'U' then

		l_return_status := 'x';

	-- validate the reference document against the escalation document id.

		jtf_ec_util.Validate_Task_Reference_Id(	l_reference_documents(j).reference_id,
		    	      	     			l_escalation_id,
		    	             			l_return_status);

    		if (l_return_status = fnd_api.g_ret_sts_error) then
    			raise fnd_api.g_exc_error;
    		elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
    			raise fnd_api.g_exc_unexpected_error;
    		end if;

		    if l_reference_documents(j).reference_code = 'ESC' then

			 open c_get_ref_details(l_reference_documents(j).reference_id);
			 fetch c_get_ref_details into l_object_type_code, l_object_id, l_object_name;
			 close c_get_ref_details;

			if l_reference_documents(j).object_type_code <> fnd_api.g_miss_char then
				l_object_type_code := l_reference_documents(j).object_type_code;
			end if;

			if l_reference_documents(j).object_id <> fnd_api.g_miss_num then
				l_object_id := l_reference_documents(j).object_id;
			end if;

			if l_reference_documents(j).object_name <> fnd_api.g_miss_char then
				l_object_name := l_reference_documents(j).object_name;
			end if;

	   	   	   if jtf_ec_util.check_if_escalated(	l_object_type_code,
					     			l_object_id,
					     			l_object_name,
								l_task_ref_id) = TRUE then

				--  make sure that this is not this document

		  		if l_task_ref_id <> l_reference_documents(j).reference_id then
    			      		fnd_message.set_name ('JTF', 'JTF_TK_ESC_DOC_EXIST');
			      		fnd_message.set_token('OBJECT_TYPE',l_object_type_code);
			      		fnd_message.set_token('OBJECT_NUMBER',l_object_name);
			      		fnd_msg_pub.Add;
			      		raise fnd_api.g_exc_error;
			      	end if;
		           end if;

		    end if;

		if jtf_ec_util.Reference_Duplicated(l_reference_documents(j).object_type_code,
					     	     l_reference_documents(j).object_id,
					     	     l_reference_documents(j).object_name,
						     l_reference_documents(j).reference_code,
						     l_escalation_id) = FALSE then

		    JTF_EC_REFERENCES_PVT.UPDATE_REFERENCES (
     			P_API_VERSION     => l_api_version,
     			P_INIT_MSG_LIST   => fnd_api.g_false,
     			P_COMMIT          => fnd_api.g_false,
     			P_OBJECT_VERSION_NUMBER	  => l_reference_documents(j).object_version_number,
     			P_ESCALATION_REFERENCE_ID => l_reference_documents(j).reference_id,
     			P_OBJECT_TYPE_CODE        => l_reference_documents(j).object_type_code,
     			P_OBJECT_NAME             => l_reference_documents(j).object_name,
     			P_OBJECT_ID               => l_reference_documents(j).object_id,
     			P_OBJECT_DETAILS          => NULL,
     			P_REFERENCE_CODE          => l_reference_documents(j).reference_code,
     			-- P_USAGE                => NULL, -- l_reference_documents(j).usage,
     			X_RETURN_STATUS     	  => l_return_status,
     			X_MSG_DATA          	  => x_msg_data,
     			X_MSG_COUNT         	  => x_msg_count,
        		p_attribute1            => l_reference_documents(j).attribute1,
        		p_attribute2            => l_reference_documents(j).attribute2,
        		p_attribute3            => l_reference_documents(j).attribute3,
        		p_attribute4            => l_reference_documents(j).attribute4,
        		p_attribute5            => l_reference_documents(j).attribute5,
        		p_attribute6            => l_reference_documents(j).attribute6,
       			p_attribute7            => l_reference_documents(j).attribute7,
        		p_attribute8            => l_reference_documents(j).attribute8,
        		p_attribute9            => l_reference_documents(j).attribute9,
        		p_attribute10           => l_reference_documents(j).attribute10,
        		p_attribute11           => l_reference_documents(j).attribute11,
        		p_attribute12           => l_reference_documents(j).attribute12,
        		p_attribute13           => l_reference_documents(j).attribute13,
        		p_attribute14           => l_reference_documents(j).attribute14,
        		p_attribute15           => l_reference_documents(j).attribute15,
        		p_attribute_category    => l_reference_documents(j).attribute_category);

    		   if (l_return_status = fnd_api.g_ret_sts_error) then
    			raise fnd_api.g_exc_error;
    		   elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
    			raise fnd_api.g_exc_unexpected_error;
    		   end if;

		end if;

	elsif l_reference_documents(j).action_code = 'I' then

	  l_return_status := 'x';

	---------------------------------------------------------------------------------
	-- check reference code
	-- if the reference code is not passed it will be defaulted from a profile option
	----------------------------------------------------------------------------------

    	  if (l_reference_documents(j).reference_code = fnd_api.g_miss_char
	   OR 		    	     l_reference_documents(j).reference_code is NULL)
    	  then
	     l_reference_documents(j).reference_code := FND_PROFILE.Value_Specific('JTF_EC_DEFAULT_REF_TYPE',
										    l_user_id,
										    l_resp_id,
										    l_resp_appl_id);
          end if;

		Create_Esc_Reference(	l_reference_documents(j),
			       	     	l_escalation_id,
					l_escalation_number,
					x_msg_count,
					x_msg_data,
					l_escalation_reference_id,
			       		l_return_status);

     		if (l_return_status = fnd_api.g_ret_sts_error) then
    			raise fnd_api.g_exc_error;
     		elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
    			raise fnd_api.g_exc_unexpected_error;
     		end if;

	end if;

   end loop;

-------------------------------------------------------------------------------
--  Delete contact points. The Inserts and Updates are done after the contacts
--  insert since the task_contact_id is a FK in the Task_phones_table
-------------------------------------------------------------------------------

	for j in 1..l_cont_points.COUNT loop

		if l_cont_points(j).action_code = 'D' then

	-- validate the task_phone_id - must be for this escalation document

		l_return_status := 'x';

		   jtf_ec_util.validate_task_phone_id(l_cont_points(j).task_phone_id,
						     l_escalation_id,
						     l_return_status);

     		   if (l_return_status = fnd_api.g_ret_sts_error) then
    			raise fnd_api.g_exc_error;
     		   elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
    			raise fnd_api.g_exc_unexpected_error;
     		   end if;

    		    Jtf_Task_Phones_Pub.delete_task_phones (
        		p_api_version   	=> l_api_version,
        		p_init_msg_list         => fnd_api.g_false,
        		p_commit                => fnd_api.g_false,
			p_object_version_number => l_cont_points(j).object_version_number,
        		p_task_phone_id         => l_cont_points(j).task_phone_id,
        		x_return_status         => l_return_status,
        		x_msg_data              => x_msg_data,
        		x_msg_count             => x_msg_count
			);

     		   if (l_return_status = fnd_api.g_ret_sts_error) then
    			raise fnd_api.g_exc_error;
     		   elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
    			raise fnd_api.g_exc_unexpected_error;
     		   end if;

		elsif l_cont_points(j).action_code = 'U' then

		  l_return_status := 'x';

	-- validate the task_phone_id - must be for this escalation document

		   jtf_ec_util.validate_task_phone_id(l_cont_points(j).task_phone_id,
						     l_escalation_id,
						     l_return_status);

     		   if (l_return_status = fnd_api.g_ret_sts_error) then
    			raise fnd_api.g_exc_error;
     		   elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
    			raise fnd_api.g_exc_unexpected_error;
     		   end if;

		  l_return_status := 'x';

		  Jtf_Task_Phones_Pub.update_task_phones(
        		p_api_version   	=> l_api_version,
        		p_init_msg_list         => fnd_api.g_false,
        		p_commit                => fnd_api.g_false,
			p_object_version_number => l_cont_points(j).object_version_number,
        		p_task_phone_id         => l_cont_points(j).task_phone_id,
			p_phone_id              => l_cont_points(j).contact_point_id,
        		x_return_status         => l_return_status,
        		x_msg_data              => x_msg_data,
        		x_msg_count             => x_msg_count,
        		p_attribute1            => l_cont_points(j).attribute1,
        		p_attribute2            => l_cont_points(j).attribute1,
        		p_attribute3            => l_cont_points(j).attribute1,
        		p_attribute4            => l_cont_points(j).attribute1,
        		p_attribute5            => l_cont_points(j).attribute1,
        		p_attribute6            => l_cont_points(j).attribute1,
        		p_attribute7            => l_cont_points(j).attribute1,
        		p_attribute8            => l_cont_points(j).attribute1,
        		p_attribute9            => l_cont_points(j).attribute1,
        		p_attribute10           => l_cont_points(j).attribute1,
        		p_attribute11           => l_cont_points(j).attribute1,
        		p_attribute12           => l_cont_points(j).attribute1,
        		p_attribute13           => l_cont_points(j).attribute1,
        		p_attribute14           => l_cont_points(j).attribute1,
       			p_attribute15           => l_cont_points(j).attribute1,
        		p_attribute_category    => l_cont_points(j).attribute_category
    			);

     		   if (l_return_status = fnd_api.g_ret_sts_error) then
    			raise fnd_api.g_exc_error;
     		   elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
    			raise fnd_api.g_exc_unexpected_error;
     		   end if;
          end if;
  end loop;

--------------------------------------------------------------------------------------------------
-- Update, Insert, Delete (depends on the action code)  the contacts.
-- action_code = 'I' - inserts a new contact.
-- action_code = 'U' - updates an existing contact. Just the 'Notify' and 'Requester' flags could be updated.
-- action_code = 'D' - removes a contact. Also the corresponding contact details if any are removed.
--------------------------------------------------------------------------------------------------

   for j in 1..l_esc_contacts.COUNT loop

  	-- deletes an existing contact. Removes the corresponding contact points from jtf_task_phones.

	if l_esc_contacts(j).action_code = 'D' then

		l_return_status := 'x';

	-- validate the task_contact_id against the escalation_id

		jtf_ec_util.Validate_Task_Contact_Id(	l_esc_contacts(j).task_contact_id,
		    	      	   	     		l_escalation_id,
		    	           	     		l_return_status);

     		if (l_return_status = fnd_api.g_ret_sts_error) then
    			raise fnd_api.g_exc_error;
     		elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
    			raise fnd_api.g_exc_unexpected_error;
     		end if;

   		JTF_EC_CONTACTS_PVT.DELETE_ESCALATION_CONTACTS(
      			P_API_VERSION      => l_api_version,
      			P_INIT_MSG_LIST    => fnd_api.g_false,
      			P_COMMIT           => fnd_api.g_false,
      			P_OBJECT_VERSION_NUMBER => l_esc_contacts(j).object_version_number,
      			P_ESCALATION_CONTACT_ID => l_esc_contacts(j).task_contact_id,
      			X_RETURN_STATUS     => l_return_status,
      			X_MSG_COUNT         => x_msg_count,
      			X_MSG_DATA          => x_msg_data);

     		if (l_return_status = fnd_api.g_ret_sts_error) then
    			raise fnd_api.g_exc_error;
     		elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
    			raise fnd_api.g_exc_unexpected_error;
     		end if;

			-- delete the contact points

		for c in c_cont_phone_id(l_esc_contacts(j).task_contact_id) loop

    		      Jtf_Task_Phones_Pub.delete_task_phones (
        			p_api_version   	=> l_api_version,
        			p_init_msg_list         => fnd_api.g_false,
        			p_commit                => fnd_api.g_false,
				p_object_version_number => c.object_version_number,
        			p_task_phone_id         => c.task_phone_id,
        			x_return_status         => l_return_status,
        			x_msg_data              => x_msg_data,
        			x_msg_count             => x_msg_count
				);

     			if (l_return_status = fnd_api.g_ret_sts_error) then
    				raise fnd_api.g_exc_error;
     			elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
    				raise fnd_api.g_exc_unexpected_error;
     			end if;

		end loop;

	elsif l_esc_contacts(j).action_code = 'U' then

	l_return_status := 'x';

	-- currently just the escalation_notify_flag and the escalation_requester_flag
	-- can be updated. Once the contact is created the contact_type_code and
	-- the contact_id cannot be changed.

		l_esc_contacts(j).contact_id := FND_API.G_MISS_NUM;
		l_esc_contacts(j).contact_type_code := FND_API.G_MISS_CHAR;

    		if l_esc_contacts(j).escalation_notify_flag is NULL then
			l_esc_contacts(j).escalation_notify_flag := 'N';
    		end if;

    		if l_esc_contacts(j).escalation_requester_flag is NULL then
			l_esc_contacts(j).escalation_requester_flag := 'N';
    		end if;

	-- validate the task_contact_id against the escalation_id

		jtf_ec_util.Validate_Task_Contact_Id(	l_esc_contacts(j).task_contact_id,
		    	      	   	     		l_escalation_id,
		    	           	     		l_return_status);

     		if (l_return_status = fnd_api.g_ret_sts_error) then
    			raise fnd_api.g_exc_error;
     		elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
    			raise fnd_api.g_exc_unexpected_error;
     		end if;

   		JTF_EC_CONTACTS_PVT.UPDATE_ESCALATION_CONTACTS (
     			P_API_VERSION     =>  l_api_version,
     			P_INIT_MSG_LIST   =>  fnd_api.g_false,
    			P_COMMIT          =>  fnd_api.g_false,
     			P_OBJECT_VERSION_NUMBER => l_esc_contacts(j).object_version_number,
     			P_ESCALATION_CONTACT_ID => l_esc_contacts(j).task_contact_id,
     			P_CONTACT_ID        	=> l_esc_contacts(j).contact_id,
     			P_CONTACT_TYPE_CODE 	=> l_esc_contacts(j).contact_type_code,
     			P_ESCALATION_NOTIFY_FLAG => l_esc_contacts(j).escalation_notify_flag,
     			P_ESCALATION_REQUESTER_FLAG => l_esc_contacts(j).escalation_requester_flag,
     			X_RETURN_STATUS     	=> l_return_status,
     			X_MSG_DATA          	=> x_msg_data,
     			X_MSG_COUNT         	=> x_msg_count,
     			p_attribute1        	=> l_esc_contacts(j).attribute1,
     			p_attribute2        	=> l_esc_contacts(j).attribute2,
     			p_attribute3        	=> l_esc_contacts(j).attribute3,
     			p_attribute4        	=> l_esc_contacts(j).attribute4,
     			p_attribute5        	=> l_esc_contacts(j).attribute5,
     			p_attribute6        	=> l_esc_contacts(j).attribute6,
     			p_attribute7        	=> l_esc_contacts(j).attribute7,
     			p_attribute8        	=> l_esc_contacts(j).attribute8,
     			p_attribute9        	=> l_esc_contacts(j).attribute9,
     			p_attribute10        	=> l_esc_contacts(j).attribute10,
     			p_attribute11        	=> l_esc_contacts(j).attribute11,
     			p_attribute12        	=> l_esc_contacts(j).attribute12,
     			p_attribute13        	=> l_esc_contacts(j).attribute13,
     			p_attribute14        	=> l_esc_contacts(j).attribute14,
     			p_attribute15        	=> l_esc_contacts(j).attribute15,
     			p_attribute_category 	=> l_esc_contacts(j).attribute_category
     			);

     			if (l_return_status = fnd_api.g_ret_sts_error) then
    				raise fnd_api.g_exc_error;
     			elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
    				raise fnd_api.g_exc_unexpected_error;
     			end if;

	elsif l_esc_contacts(j).action_code = 'I' then

	l_return_status := 'x';

	      Create_Esc_Contacts(p_esc_contacts_rec => l_esc_contacts(j),
			   -- p_cont_points => l_cont_points,
			    p_esc_id => l_escalation_id,
			    p_esc_number => l_escalation_number,
			    x_msg_count => x_msg_count,
			    x_msg_data => x_msg_data,
			    x_esc_contact_id => l_escalation_contact_id,
			    x_return_status => l_return_status);

     		if (l_return_status = fnd_api.g_ret_sts_error) then
    			raise fnd_api.g_exc_error;
     		elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
    			raise fnd_api.g_exc_unexpected_error;
     		end if;

	end if;

   end loop;

-------------------------------------------------------------------------------
-- validate Requester. The escalation Document must have only one requester.
-------------------------------------------------------------------------------

    l_return_status := 'x';

   jtf_ec_util.Validate_Requester(l_escalation_id,
				  l_return_status);

    if l_return_status <> fnd_api.g_ret_sts_success then
	raise fnd_api.g_exc_error;
    end if;

-------------------------------------------------------------------------------
-- Update , Insert contact points. The Deletes are done before the contacts
-- deletes to avoid the deletion of the same record.
-------------------------------------------------------------------------------

	for j in 1..l_cont_points.COUNT loop

	if l_cont_points(j).action_code = 'I' then

		   l_return_status := 'x';

	-- check whether this is a valid contact for this escalation. Also get the task contact id.

		   jtf_ec_util.Validate_Contact_id(l_cont_points(j).contact_id,
						     l_cont_points(j).contact_type_code,
		    	      			     l_escalation_id,
						     l_escalation_contact_id,
						     l_return_status);

     		   if (l_return_status = fnd_api.g_ret_sts_error) then
    			raise fnd_api.g_exc_error;
     		   elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
    			raise fnd_api.g_exc_unexpected_error;
     		   end if;

		  jtf_ec_util.Conv_Miss_Char(l_cont_points(j).attribute1);
		  jtf_ec_util.Conv_Miss_Char(l_cont_points(j).attribute2);
		  jtf_ec_util.Conv_Miss_Char(l_cont_points(j).attribute3);
		  jtf_ec_util.Conv_Miss_Char(l_cont_points(j).attribute4);
		  jtf_ec_util.Conv_Miss_Char(l_cont_points(j).attribute5);
		  jtf_ec_util.Conv_Miss_Char(l_cont_points(j).attribute6);
		  jtf_ec_util.Conv_Miss_Char(l_cont_points(j).attribute7);
		  jtf_ec_util.Conv_Miss_Char(l_cont_points(j).attribute8);
		  jtf_ec_util.Conv_Miss_Char(l_cont_points(j).attribute9);
		  jtf_ec_util.Conv_Miss_Char(l_cont_points(j).attribute10);
		  jtf_ec_util.Conv_Miss_Char(l_cont_points(j).attribute11);
		  jtf_ec_util.Conv_Miss_Char(l_cont_points(j).attribute12);
		  jtf_ec_util.Conv_Miss_Char(l_cont_points(j).attribute13);
		  jtf_ec_util.Conv_Miss_Char(l_cont_points(j).attribute14);
		  jtf_ec_util.Conv_Miss_Char(l_cont_points(j).attribute15);
		  jtf_ec_util.Conv_Miss_Char(l_cont_points(j).attribute_category);

	-- create a phone_id for this contact

		  Jtf_Task_Phones_Pub.create_task_phones (
        			p_api_version   	=> l_api_version,
        			p_init_msg_list         => fnd_api.g_false,
        			p_commit                => fnd_api.g_false,
        			p_task_contact_id       => l_escalation_contact_id,
				p_phone_id              => l_cont_points(j).contact_point_id,
        			x_task_phone_id         => l_task_phone_id,
        			x_return_status         => l_return_status,
        			x_msg_data              => x_msg_data,
        			x_msg_count             => x_msg_count,
        			p_attribute1            => l_cont_points(j).attribute1,
        			p_attribute2            => l_cont_points(j).attribute2,
        			p_attribute3            => l_cont_points(j).attribute3,
        			p_attribute4            => l_cont_points(j).attribute4,
        			p_attribute5            => l_cont_points(j).attribute5,
        			p_attribute6            => l_cont_points(j).attribute6,
       				p_attribute7            => l_cont_points(j).attribute7,
        			p_attribute8            => l_cont_points(j).attribute8,
        			p_attribute9            => l_cont_points(j).attribute9,
        			p_attribute10           => l_cont_points(j).attribute10,
        			p_attribute11           => l_cont_points(j).attribute11,
        			p_attribute12           => l_cont_points(j).attribute12,
        			p_attribute13           => l_cont_points(j).attribute13,
        			p_attribute14           => l_cont_points(j).attribute14,
        			p_attribute15           => l_cont_points(j).attribute15,
        			p_attribute_category    => l_cont_points(j).attribute_category
    				);

     	  	 if (l_return_status = fnd_api.g_ret_sts_error) then
    	  		raise fnd_api.g_exc_error;
     	  	 elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
    	  		raise fnd_api.g_exc_unexpected_error;
     	  	 end if;

		end if;

	end loop;

-------------------------------------------------------------------------------------------------------------
-- Insert, Update Notes
-------------------------------------------------------------------------------------------------------------

for j in 1..l_notes.COUNT loop

   if l_notes(j).action_code = 'I' then

	l_return_status := 'x';

	Create_Esc_Note(l_notes(j),
			l_escalation_id,
			g_escalation_code,
			l_user_id,
			l_login_id,
			x_msg_count,
			x_msg_data,
			l_note_id,
			l_return_status);

     	if (l_return_status = fnd_api.g_ret_sts_error) then
    		raise fnd_api.g_exc_error;
     	elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
    		raise fnd_api.g_exc_unexpected_error;
     	end if;

   elsif l_notes(j).action_code = 'U' then

	l_return_status := 'x';

	-- check whether the note belongs to this escalation document

	jtf_ec_util.Validate_Note_Id(l_notes(j).note_id,
		    	   	     l_escalation_id,
		    	   	     l_return_status);

     	if (l_return_status = fnd_api.g_ret_sts_error) then
    		raise fnd_api.g_exc_error;
     	elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
    		raise fnd_api.g_exc_unexpected_error;
     	end if;

	jtf_notes_pub.Update_note(
		      	p_api_version    => l_api_version,
      			p_init_msg_list  => fnd_api.g_false,
      			p_commit         => fnd_api.g_false,
      			x_return_status  => l_return_status,
      			x_msg_count      => x_msg_count,
      			x_msg_data       => x_msg_data,
                        p_jtf_note_id	 => l_notes(j).note_id,
      			p_notes              => l_notes(j).note,
      			p_notes_detail       => l_notes(j).note_detail,
      			p_note_type          => l_notes(j).note_type,
      			p_note_status        => l_notes(j).note_status,
      			p_entered_by         => l_user_id,
      			p_last_updated_by    => l_user_id,
      			p_last_update_date   => SYSDATE
			);

     	  if (l_return_status = fnd_api.g_ret_sts_error) then
    	  	raise fnd_api.g_exc_error;
     	  elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
    	  	raise fnd_api.g_exc_unexpected_error;
     	  end if;

   end if;

end loop;
-------------------------------------------------------------------------------------------------------------
-- Workflow
-------------------------------------------------------------------------------------------------------------

if l_old_owner_id <> l_esc_record.esc_owner_id
   and l_esc_record.esc_owner_id <> fnd_api.g_miss_num
then
	l_owner_changed := 'Y';
end if;

if l_old_status_id <> l_esc_status_id
   and l_esc_status_id <> fnd_api.g_miss_num
then
	l_status_changed := 'Y';
end if;

if l_old_escalation_level <> l_esc_record.escalation_level
   and l_esc_record.escalation_level <> fnd_api.g_miss_char
then
	l_level_changed := 'Y';
end if;

if nvl(l_old_target_date, to_date('01/01/1000','DD/MM/YYYY')) <> nvl(l_esc_record.esc_target_date, to_date('01/01/1000','DD/MM/YYYY'))
   and nvl(l_esc_record.esc_target_date, to_date('01/01/1000','DD/MM/YYYY')) <> fnd_api.g_miss_date
then
	l_target_date_changed := 'Y';
end if;

-- send notifications if there are changes

l_return_status := 'x';

if (l_owner_changed='Y') OR (l_level_changed='Y') OR
   (l_status_changed='Y') OR (l_target_date_changed='Y') then

       JTF_EC_WORKFLOW_PKG.Start_Resc_Workflow(
       		P_API_VERSION             => l_api_version,
       		P_INIT_MSG_LIST           => fnd_api.g_false,
       		P_COMMIT                  => fnd_api.g_false,
       		X_RETURN_STATUS           => l_return_status,
       		X_MSG_COUNT               => x_msg_count,
       		X_MSG_DATA                => x_msg_data,
       		P_TASK_ID                 => l_escalation_id,
       		P_DOC_CREATED             => 'N',
       		P_OWNER_CHANGED           => l_owner_changed,
       		P_LEVEL_CHANGED           => l_level_changed,
       		P_STATUS_CHANGED	  => l_status_changed,
       		P_TARGET_DATE_CHANGED     => l_target_date_changed,
       		P_OLD_OWNER_ID            => l_old_owner_id,
       		P_OLD_LEVEL               => l_old_escalation_level,
       		P_OLD_STATUS_ID           => l_old_status_id,
       		P_OLD_TARGET_DATE         => l_old_target_date,
       		x_notif_not_sent	  => l_notif_not_sent,
       		X_WF_PROCESS_ID           => l_wf_process_id
		);

     	  	if (l_return_status = fnd_api.g_ret_sts_error) then
    	  		raise fnd_api.g_exc_error;
     	  	elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
    	  		raise fnd_api.g_exc_unexpected_error;
     	  	end if;

end if;

-- Update the wf_process_id

	 update jtf_tasks_b
         set workflow_process_id = l_wf_process_id
         where task_id = l_escalation_id;

--------------------------------------------------------------------------------------------
-- standard verticle industry user hook post-processing
--------------------------------------------------------------------------------------------
  if ( jtf_usr_hks.ok_to_execute( g_pkg_name, l_api_name, 'A', 'V' ) ) then

	jtf_ec_vuhk.Update_Escalation_Post(
		p_esc_id		=> l_escalation_id,
		p_esc_number		=> l_escalation_number,
		p_object_version	=> l_object_version_number,
		p_esc_record		=> l_esc_record,
		p_reference_documents	=> l_reference_documents,
		p_esc_contacts		=> l_esc_contacts,
		p_cont_points		=> l_cont_points,
		p_notes			=> l_notes,
		x_return_status       	=> l_return_status,
		x_msg_count           	=> x_msg_count,
		x_msg_data            	=> x_msg_data);

       if l_return_status = fnd_api.g_ret_sts_error then
      	  raise fnd_api.g_exc_error;
       elsif l_return_status = fnd_api.g_ret_sts_unexp_error then
          raise fnd_api.g_exc_unexpected_error;
       end if;

  end if;

--------------------------------------------------------------------------------------------
-- standard customer user hook post-processing
--------------------------------------------------------------------------------------------
  if ( jtf_usr_hks.ok_to_execute( g_pkg_name, l_api_name, 'A', 'C' ) ) then
	jtf_ec_cuhk.Update_Escalation_Post(
		p_esc_id		=> l_escalation_id,
		p_esc_number		=> l_escalation_number,
		p_object_version	=> l_object_version_number,
		p_esc_record		=> l_esc_record,
		p_reference_documents	=> l_reference_documents,
		p_esc_contacts		=> l_esc_contacts,
		p_cont_points		=> l_cont_points,
		p_notes			=> l_notes,
		x_return_status       	=> l_return_status,
		x_msg_count           	=> x_msg_count,
		x_msg_data            	=> x_msg_data);

       if l_return_status = fnd_api.g_ret_sts_error then
      	  raise fnd_api.g_exc_error;
       elsif l_return_status = fnd_api.g_ret_sts_unexp_error then
          raise fnd_api.g_exc_unexpected_error;
       end if;

  end if;

	x_object_version_number :=l_object_version_number;
	x_workflow_process_id := l_wf_process_id;

	-- Standard check of p_commit.

	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;

	fnd_msg_pub.count_and_get
    	(  	p_count	=>      x_msg_count,
        	p_data 	=>	x_msg_data
    	);

EXCEPTION

WHEN 	fnd_api.g_exc_error
THEN
	ROLLBACK TO Update_Escalation;
        x_return_status := fnd_api.g_ret_sts_error;
        fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
            );

WHEN 	fnd_api.g_exc_unexpected_error
THEN

        ROLLBACK TO Update_Escalation;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
            );

WHEN OTHERS
THEN
        ROLLBACK TO Update_Escalation;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	if 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	then
    	    	FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
	end if;

        fnd_msg_pub.count_and_get (
				   p_count => x_msg_count,
				   p_data => x_msg_data
				   );
END UPDATE_ESCALATION;

PROCEDURE DELETE_ESCALATION(
	p_api_version         	IN	NUMBER,
	p_init_msg_list       	IN	VARCHAR2 DEFAULT fnd_api.g_false,
	p_commit              	IN	VARCHAR2 DEFAULT fnd_api.g_false,
	x_return_status       	OUT NOCOPY     VARCHAR2,
	x_msg_count           	OUT NOCOPY     NUMBER,
	x_msg_data            	OUT NOCOPY     VARCHAR2,
  	p_user_id		IN      NUMBER,
  	p_login_id		IN      NUMBER,
	p_esc_id		IN	jtf_tasks_b.task_id%TYPE,
	p_esc_number		IN	jtf_tasks_b.task_number%TYPE,
	p_object_version	IN	NUMBER) Is

l_api_version     	CONSTANT NUMBER 	:= 1.0;
l_api_name		CONSTANT VARCHAR2(30)   := 'DELETE_ESCALATION';
l_escalation_id		jtf_tasks_b.task_id%TYPE	:= p_esc_id;
l_escalation_number	jtf_tasks_b.task_number%TYPE	:= p_esc_number;
l_return_status		varchar2(1) := 'x';
l_esc_task_id 		jtf_tasks_b.task_id%TYPE;
l_object_version_number NUMBER := p_object_version;
l_user_id		NUMBER := p_user_id;
l_login_id		NUMBER := p_login_id;

BEGIN

SAVEPOINT	Delete_Escalation;

-- Standard call to check for call compatibility.


IF NOT FND_API.Compatible_API_Call ( 	l_api_version,
           	    	    	 	p_api_version,
    	    	    	    	    	l_api_name,
			    	    	G_PKG_NAME)
THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

-- Check p_init_msg_list

IF FND_API.To_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
END IF;

	--  Initialize API return status to success

x_return_status := FND_API.G_RET_STS_SUCCESS;

--------------------------------------------------------------------------------------------
-- standard customer user hook pre-processing
--------------------------------------------------------------------------------------------
  if ( jtf_usr_hks.ok_to_execute( g_pkg_name, l_api_name, 'B', 'C' ) ) then

	jtf_ec_cuhk.Delete_Escalation_Pre(
		p_esc_id		=> l_escalation_id,
		p_esc_number		=> l_escalation_number,
		p_object_version	=> l_object_version_number,
		x_return_status       	=> l_return_status,
		x_msg_count           	=> x_msg_count,
		x_msg_data            	=> x_msg_data);

       if l_return_status = fnd_api.g_ret_sts_error then
      	  raise fnd_api.g_exc_error;
       elsif l_return_status = fnd_api.g_ret_sts_unexp_error then
          raise fnd_api.g_exc_unexpected_error;
       end if;

  end if;
--------------------------------------------------------------------------------------------
-- standard verticle industry user hook pre-processing
--------------------------------------------------------------------------------------------
  if ( jtf_usr_hks.ok_to_execute( g_pkg_name, l_api_name, 'B', 'V' ) ) then

	jtf_ec_vuhk.Delete_Escalation_Pre(
		p_esc_id		=> l_escalation_id,
		p_esc_number		=> l_escalation_number,
		p_object_version	=> l_object_version_number,
		x_return_status       	=> l_return_status,
		x_msg_count           	=> x_msg_count,
		x_msg_data            	=> x_msg_data);

       if l_return_status = fnd_api.g_ret_sts_error then
      	  raise fnd_api.g_exc_error;
       elsif l_return_status = fnd_api.g_ret_sts_unexp_error then
          raise fnd_api.g_exc_unexpected_error;
       end if;

  end if;

-------------------------------------------------------------------------
-- validation
-------------------------------------------------------------------------
-- validate p_user_id
-------------------------------------------------------------------------

if l_user_id is NOT NULL then
	jtf_ec_util.Validate_Who_Info(	l_api_name,
			  		l_user_id,
			  		l_login_id,
			  		l_return_status
  			  		);
     	if (l_return_status = fnd_api.g_ret_sts_error) then
    	  raise fnd_api.g_exc_error;
     	elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
    	  raise fnd_api.g_exc_unexpected_error;
     	end if;
else
	jtf_ec_util.Add_Invalid_Argument_Msg(l_api_name, 'NULL' ,'user_id');
	raise fnd_api.g_exc_error;
end if;

-------------------------------------------------------------------------
-- Validate Escalation Task
-- Performs also number to id conversion
-------------------------------------------------------------------------

l_return_status	:= 'x';

if p_esc_id <> fnd_api.g_miss_num  then
	l_escalation_id := p_esc_id;
    	if p_esc_number <> fnd_api.g_miss_char then
		jtf_ec_util.add_param_ignored_msg(l_api_name, 'p_esc_number');
	end if;
elsif p_esc_number <> fnd_api.g_miss_char then
	l_escalation_number := p_esc_number;
else jtf_ec_util.add_missing_param_msg(l_api_name, 'p_esc_name');
end if;

jtf_ec_util.Validate_Esc_Document(l_escalation_id,
		      l_escalation_number,
		      l_esc_task_id,	-- converted number to id
		      l_return_status);

if (l_return_status = fnd_api.g_ret_sts_error) then
    	raise fnd_api.g_exc_error;
elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
    	raise fnd_api.g_exc_unexpected_error;
end if;

l_escalation_id := l_esc_task_id;

   JTF_EC_PVT.DELETE_ESCALATION(
      		P_API_VERSION		=> l_api_version,
      		P_INIT_MSG_LIST    	=> fnd_api.g_false,
      		P_COMMIT           	=> fnd_api.g_false,
      		P_OBJECT_VERSION_NUMBER => l_object_version_number,
      		P_ESCALATION_ID    	=> l_escalation_id,
      		P_ESCALATION_NUMBER 	=> l_escalation_number,
      		X_RETURN_STATUS     	=> l_return_status,
     		X_MSG_COUNT         	=> x_msg_count,
      		X_MSG_DATA          	=> x_msg_data);

    		if (l_return_status = fnd_api.g_ret_sts_error) then
    			raise fnd_api.g_exc_error;
    		elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
    			raise fnd_api.g_exc_unexpected_error;
    		end if;

--------------------------------------------------------------------------------------------
-- standard verticle industry user hook post-processing
--------------------------------------------------------------------------------------------
  if ( jtf_usr_hks.ok_to_execute( g_pkg_name, l_api_name, 'A', 'V' ) ) then

	jtf_ec_vuhk.Delete_Escalation_Post(
		p_esc_id		=> l_escalation_id,
		p_esc_number		=> l_escalation_number,
		p_object_version	=> l_object_version_number,
		x_return_status       	=> l_return_status,
		x_msg_count           	=> x_msg_count,
		x_msg_data            	=> x_msg_data);

       if l_return_status = fnd_api.g_ret_sts_error then
      	  raise fnd_api.g_exc_error;
       elsif l_return_status = fnd_api.g_ret_sts_unexp_error then
          raise fnd_api.g_exc_unexpected_error;
       end if;

  end if;

--------------------------------------------------------------------------------------------
-- standard customer user hook post-processing
--------------------------------------------------------------------------------------------

  if ( jtf_usr_hks.ok_to_execute( g_pkg_name, l_api_name, 'A', 'C' ) ) then

	jtf_ec_cuhk.Delete_Escalation_Post(
		p_esc_id		=> l_escalation_id,
		p_esc_number		=> l_escalation_number,
		p_object_version	=> l_object_version_number,
		x_return_status       	=> l_return_status,
		x_msg_count           	=> x_msg_count,
		x_msg_data            	=> x_msg_data);

       if l_return_status = fnd_api.g_ret_sts_error then
      	  raise fnd_api.g_exc_error;
       elsif l_return_status = fnd_api.g_ret_sts_unexp_error then
          raise fnd_api.g_exc_unexpected_error;
       end if;

  end if;

	-- Standard check of p_commit.

	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;

	fnd_msg_pub.count_and_get
    	(  	p_count	=>      x_msg_count,
        	p_data 	=>	x_msg_data
    	);

EXCEPTION

WHEN 	fnd_api.g_exc_error
THEN
	ROLLBACK TO Delete_Escalation;
        x_return_status := fnd_api.g_ret_sts_error;

        fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
            );

WHEN 	fnd_api.g_exc_unexpected_error
THEN

        ROLLBACK TO Delete_Escalation;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get ( p_count => x_msg_count, p_data => x_msg_data);

WHEN OTHERS
THEN
        ROLLBACK TO Delete_Escalation;
	x_return_status := fnd_api.g_ret_sts_unexp_error;

	if 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	then
    	    	FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
	end if;

        fnd_msg_pub.count_and_get ( p_count => x_msg_count, p_data => x_msg_data);

END 	DELETE_ESCALATION;

END JTF_EC_PUB;

/
