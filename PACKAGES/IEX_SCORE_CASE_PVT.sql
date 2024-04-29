--------------------------------------------------------
--  DDL for Package IEX_SCORE_CASE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_SCORE_CASE_PVT" AUTHID CURRENT_USER AS
/* $Header: iexcscrs.pls 120.0 2004/01/24 03:18:10 appldev noship $ */

   Function Calculate_Score(p_case_id IN NUMBER, p_score_component_id IN NUMBER) RETURN NUMBER;

   Function Load_Configuration(p_score_component_id IN NUMBER) RETURN BOOLEAN;

   Function ReduceScore(p_Score IN NUMBER, p_type IN NUMBER) return NUMBER;

END IEX_SCORE_CASE_PVT;

 

/
