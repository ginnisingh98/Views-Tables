--------------------------------------------------------
--  DDL for Package OKC_INTERACT_HISTORY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_INTERACT_HISTORY_PUB" AUTHID CURRENT_USER AS
/* $Header: OKCPIHAS.pls 120.0 2005/05/25 23:10:11 appldev noship $ */
  PROCEDURE CREATE_INTERACT_HISTORY (
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    x_interaction_id OUT NOCOPY NUMBER,
    p_media_type IN varchar2,
    p_action_item_id IN NUMBER,
    p_outcome_id IN NUMBER,
    p_touchpoint1_type IN VARCHAR2,
    p_resource1_id IN NUMBER,
    p_touchpoint2_type IN VARCHAR2,
    p_resource2_id IN NUMBER,
    p_contract_id IN NUMBER,
    p_int_start_date IN DATE,
    p_int_end_date IN DATE,
    p_notes IN varchar2,
    p_notes_detail IN varchar2);
 END OKC_INTERACT_HISTORY_PUB;

 

/
