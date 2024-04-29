--------------------------------------------------------
--  DDL for Package PON_EVAL_TEAM_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_EVAL_TEAM_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: PONVETUS.pls 120.0.12010000.3 2014/05/30 11:42:16 spapana noship $ */

PROCEDURE init_mng_eval_teams(p_auction_header_id IN NUMBER);

PROCEDURE process_mng_eval_teams(p_auction_header_id IN NUMBER);

PROCEDURE gen_eval_team_update_body(p_document_id   IN VARCHAR2,
                                    p_display_type  IN VARCHAR2,
                                    x_document      IN OUT NOCOPY CLOB,
                                    x_document_type IN OUT NOCOPY VARCHAR2);

PROCEDURE send_eval_update_scorer_notif(params VARCHAR2);

PROCEDURE gen_eval_update_scorer_body(p_document_id   IN VARCHAR2,
                                      p_display_type  IN VARCHAR2,
                                      x_document      IN OUT NOCOPY CLOB,
                                      x_document_type IN OUT NOCOPY VARCHAR2);

END PON_EVAL_TEAM_UTIL_PVT;

/
