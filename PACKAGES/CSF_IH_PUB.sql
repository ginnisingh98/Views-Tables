--------------------------------------------------------
--  DDL for Package CSF_IH_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_IH_PUB" AUTHID CURRENT_USER AS
/* $Header: csfihpss.pls 120.0 2005/05/24 17:44:25 appldev noship $ */

PROCEDURE Create_Interaction
(
	l_api_version		IN 	NUMBER,
	l_return_status		OUT nocopy	VARCHAR2,
	l_msg_count		OUT nocopy	NUMBER,
	l_msg_data		OUT nocopy	VARCHAR2,
        l_interaction_id        IN      NUMBER,
	l_handler_id		in number,
	l_resource_id		in number,
	l_party_id 		in number,
        action_item_id          IN       VARCHAR2,
        outcome_id              IN         NUMBER,
	reference_form		IN 	varchar2,
	task_id			IN 	number,
	doc_id			in 	number,
	doc_ref			in 	varchar2
) ;


END csf_IH_PUB;

 

/
