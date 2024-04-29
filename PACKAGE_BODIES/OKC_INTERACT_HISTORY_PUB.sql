--------------------------------------------------------
--  DDL for Package Body OKC_INTERACT_HISTORY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_INTERACT_HISTORY_PUB" AS
/* $Header: OKCPIHAB.pls 120.0 2005/05/25 23:10:13 appldev noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

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
    p_notes_detail IN varchar2) IS
    BEGIN
      OKC_INTERACT_HISTORY_PVT.CREATE_INTERACT_HISTORY (
        x_return_status ,
        x_msg_count ,
        x_msg_data,
        x_interaction_id,
        p_media_type,
        p_action_item_id,
        p_outcome_id,
        p_touchpoint1_type,
        p_resource1_id,
        p_touchpoint2_type,
        p_resource2_id,
        p_contract_id,
        p_int_start_date,
        p_int_end_date,
        p_notes,
        p_notes_detail) ;
    END CREATE_INTERACT_HISTORY;
 END OKC_INTERACT_HISTORY_PUB;

/
