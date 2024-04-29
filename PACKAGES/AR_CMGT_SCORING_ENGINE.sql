--------------------------------------------------------
--  DDL for Package AR_CMGT_SCORING_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_CMGT_SCORING_ENGINE" AUTHID CURRENT_USER AS
 /* $Header: ARCMGSES.pls 120.1 2004/12/03 01:45:31 orashid noship $  */

g_data_case_folder_id           NUMBER;

PROCEDURE GENERATE_SCORE(
            p_case_folder_id    IN      NUMBER,
            p_score             OUT NOCOPY     NUMBER,
            p_error_msg         OUT NOCOPY     VARCHAR2,
            p_resultout         OUT NOCOPY     VARCHAR2);

PROCEDURE GENERATE_SCORE(
            p_case_folder_id    IN      NUMBER,
            p_score_model_id    IN      NUMBER,
            p_score             OUT NOCOPY     NUMBER,
            p_error_msg         OUT NOCOPY     VARCHAR2,
            p_resultout         OUT NOCOPY     VARCHAR2);


FUNCTION    get_score (
            p_score_model_id        IN      NUMBER,
            p_data_point_id         IN      NUMBER,
	    p_case_folder_id	    IN	    NUMBER,
            p_data_point_value      IN      VARCHAR2 default null)
        return NUMBER;
END AR_CMGT_SCORING_ENGINE;

 

/
