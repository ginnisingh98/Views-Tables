--------------------------------------------------------
--  DDL for Package Body CSF_IH_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_IH_PUB" AS
/* $Header: csfihpsb.pls 120.0 2005/05/24 17:54:39 appldev noship $ */
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
) IS
  d_interaction_rec      jtf_IH_PUB.interaction_rec_type;
  d_activities           jtf_IH_PUB.activity_tbl_type;

  begin

    d_interaction_rec.interaction_id := l_interaction_id;
    d_interaction_rec.handler_id := l_handler_id;
    d_interaction_rec.outcome_id := outcome_id;
    d_interaction_rec.resource_id := l_resource_id;
    d_interaction_rec.party_id   := l_party_id;
    d_interaction_rec.reference_form := reference_form;


    d_activities(1).action_item_id := action_item_id;
    d_activities(1).interaction_id := l_interaction_id;
    d_activities(1).outcome_id     := outcome_id;
    d_activities(1).task_id 	   := task_id;
    d_activities(1).doc_id	   := doc_id;
    d_activities(1).doc_ref	   := doc_ref;

    -- here's the delegated call to the old PL/SQL routine
    jtf_ih_pub.create_interaction(
      p_api_version  => l_api_version,
      P_user_id      => l_resource_id,
      x_return_status => l_return_status,
      x_msg_count     => l_msg_count,
      x_msg_data      => l_msg_data,
      p_interaction_rec => d_interaction_rec,
      p_activities      => d_activities );

  END Create_Interaction;

END CSF_IH_PUB;

/
