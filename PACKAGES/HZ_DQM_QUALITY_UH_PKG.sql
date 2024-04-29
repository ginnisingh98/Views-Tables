--------------------------------------------------------
--  DDL for Package HZ_DQM_QUALITY_UH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_DQM_QUALITY_UH_PKG" AUTHID CURRENT_USER AS
/* $Header: ARHDQUHS.pls 115.1 2003/12/22 21:22:18 abordia noship $ */

FUNCTION get_quality_weighting(p_match_rule_id IN NUMBER)    RETURN NUMBER ;

FUNCTION get_quality_score(p_match_rule_id IN NUMBER, p_hz_party_rec IN HZ_PARTIES%ROWTYPE)  RETURN NUMBER ;

END; -- Package spec


 

/
