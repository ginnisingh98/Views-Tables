--------------------------------------------------------
--  DDL for Package Body HZ_DQM_QUALITY_UH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_DQM_QUALITY_UH_PKG" AS
/* $Header: ARHDQUHB.pls 115.2 2003/12/22 21:22:01 abordia noship $ */
   FUNCTION get_quality_weighting(p_match_rule_id IN NUMBER)
    RETURN NUMBER IS
   BEGIN
        return -1;
   EXCEPTION
      WHEN OTHERS THEN
        null;
   END get_quality_weighting;

FUNCTION get_quality_score(p_match_rule_id IN NUMBER,
      p_hz_party_rec IN HZ_PARTIES%ROWTYPE)
    RETURN NUMBER IS
   BEGIN
        return -1;
   EXCEPTION
      WHEN OTHERS THEN
        null;
   END get_quality_score;

END;


/
