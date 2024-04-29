--------------------------------------------------------
--  DDL for Package JTF_EC_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_EC_VUHK" AUTHID CURRENT_USER as
/* $Header: jtfecvhs.pls 115.2 2002/11/28 05:53:44 siyappan ship $ */
--/**==================================================================*
--|   Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA   |
--|                        All rights reserved.                        |
--+====================================================================+
-- Start of comments
--	API name 	: JTF_EC_VUHK
--	Type		: Public.
--	Function	: This is a  Vertical Industry User Hooks API.
--			  The  Vertical Industry can add customization procedures here
--   			  for Pre and Post Processing.
--	Pre-reqs	: None.
--	Parameters	: Please look at the JTF_EC_PUB api for the parameters description
--      name                 direction  type     required?
--      ----                 ---------  ----     ---------
--      x_return_status       	OUT     VARCHAR2  required
--      x_msg_count           	OUT     NUMBER	  required
--      x_msg_data            	OUT     VARCHAR2  required
--
--	Version		: 1.0
-------------------------------------------------------------------------------------------
--				History
-------------------------------------------------------------------------------------------
--	06-OCT-00	tivanov		Created.
--	27-NOV-02	siyappan	Added NOCOPY hint for OUT/IN OUT parameters.
---------------------------------------------------------------------------------
--
-- End of comments


G_PKG_NAME   		CONSTANT VARCHAR2(30) := 'JTF_EC_VUHK';

-------------------------------------------------------------------------------------------
-- Vertical Industry Procedure for pre processing Create Escalation
-------------------------------------------------------------------------------------------


PROCEDURE Create_Escalation_Pre(
		p_esc_id		IN OUT NOCOPY	jtf_tasks_b.task_id%TYPE,
		p_esc_record		IN OUT NOCOPY	jtf_ec_pub.Esc_Rec_Type,
		p_reference_documents	IN OUT NOCOPY	jtf_ec_pub.Esc_Ref_Docs_Tbl_Type,
		p_esc_contacts		IN OUT NOCOPY	jtf_ec_pub.Esc_Contacts_Tbl_Type,
		p_cont_points		IN OUT NOCOPY	jtf_ec_pub.Esc_Cont_Points_Tbl_Type,
		p_notes			IN OUT NOCOPY	jtf_ec_pub.Notes_Tbl_Type,
		x_return_status       	OUT NOCOPY     VARCHAR2,
		x_msg_count           	OUT NOCOPY     NUMBER,
		x_msg_data            	OUT NOCOPY     VARCHAR2);

-------------------------------------------------------------------------------------------
-- Vertical Industry Procedure for post processing Create Escalation
-------------------------------------------------------------------------------------------


PROCEDURE Create_Escalation_Post(
		p_esc_id		IN 	jtf_tasks_b.task_id%TYPE,
		p_esc_record		IN 	jtf_ec_pub.Esc_Rec_Type,
		p_reference_documents	IN 	jtf_ec_pub.Esc_Ref_Docs_Tbl_Type,
		p_esc_contacts		IN 	jtf_ec_pub.Esc_Contacts_Tbl_Type,
		p_cont_points		IN 	jtf_ec_pub.Esc_Cont_Points_Tbl_Type,
		p_notes			IN 	jtf_ec_pub.Notes_Tbl_Type,
		x_return_status       	OUT NOCOPY     VARCHAR2,
		x_msg_count           	OUT NOCOPY     NUMBER,
		x_msg_data            	OUT NOCOPY     VARCHAR2);

-------------------------------------------------------------------------------------------
-- Vertical Industry Procedure for pre processing Update Escalation
-------------------------------------------------------------------------------------------


PROCEDURE Update_Escalation_Pre(
		p_esc_id		IN OUT NOCOPY 	jtf_tasks_b.task_id%TYPE,
		p_esc_number		IN OUT NOCOPY	jtf_tasks_b.task_number%TYPE,
		p_object_version	IN OUT NOCOPY 	NUMBER,
		p_esc_record		IN OUT NOCOPY	jtf_ec_pub.Esc_Rec_Type,
		p_reference_documents	IN OUT NOCOPY	jtf_ec_pub.Esc_Ref_Docs_Tbl_Type,
		p_esc_contacts		IN OUT NOCOPY	jtf_ec_pub.Esc_Contacts_Tbl_Type,
		p_cont_points		IN OUT NOCOPY	jtf_ec_pub.Esc_Cont_Points_Tbl_Type,
		p_notes			IN OUT NOCOPY	jtf_ec_pub.Notes_Tbl_Type,
		x_return_status       	OUT NOCOPY     VARCHAR2,
		x_msg_count           	OUT NOCOPY     NUMBER,
		x_msg_data            	OUT NOCOPY     VARCHAR2);

-------------------------------------------------------------------------------------------
-- Vertical Industry Procedure for post processing Update Escalation
-------------------------------------------------------------------------------------------

PROCEDURE Update_Escalation_Post(
		p_esc_id		IN  	jtf_tasks_b.task_id%TYPE,
		p_esc_number		IN 	jtf_tasks_b.task_number%TYPE,
		p_object_version	IN  	NUMBER,
		p_esc_record		IN 	jtf_ec_pub.Esc_Rec_Type,
		p_reference_documents	IN 	jtf_ec_pub.Esc_Ref_Docs_Tbl_Type,
		p_esc_contacts		IN 	jtf_ec_pub.Esc_Contacts_Tbl_Type,
		p_cont_points		IN 	jtf_ec_pub.Esc_Cont_Points_Tbl_Type,
		p_notes			IN 	jtf_ec_pub.Notes_Tbl_Type,
		x_return_status       	OUT NOCOPY     VARCHAR2,
		x_msg_count           	OUT NOCOPY     NUMBER,
		x_msg_data            	OUT NOCOPY     VARCHAR2);


-------------------------------------------------------------------------------------------
-- Vertical Industry Procedure for pre processing Delete Escalation
-------------------------------------------------------------------------------------------


PROCEDURE Delete_Escalation_Pre(
		p_esc_id		IN OUT NOCOPY 	jtf_tasks_b.task_id%TYPE,
		p_esc_number		IN OUT NOCOPY	jtf_tasks_b.task_number%TYPE,
		p_object_version	IN OUT NOCOPY 	NUMBER,
		x_return_status       	OUT NOCOPY     VARCHAR2,
		x_msg_count           	OUT NOCOPY     NUMBER,
		x_msg_data            	OUT NOCOPY     VARCHAR2);


-------------------------------------------------------------------------------------------
-- Vertical Industry Procedure for post processing Delete Escalation
-------------------------------------------------------------------------------------------

PROCEDURE Delete_Escalation_Post(
		p_esc_id		IN  	jtf_tasks_b.task_id%TYPE :=NULL,
		p_esc_number		IN 	jtf_tasks_b.task_number%TYPE :=NULL,
		p_object_version	IN  	NUMBER,
		x_return_status       	OUT NOCOPY     VARCHAR2,
		x_msg_count           	OUT NOCOPY     NUMBER,
		x_msg_data            	OUT NOCOPY     VARCHAR2);


END JTF_EC_VUHK;

 

/
