--------------------------------------------------------
--  DDL for Package Body GHR_AGENCY_POSITION_COPY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_AGENCY_POSITION_COPY" AS
/* $Header: ghpocagn.pkb 120.0 2005/05/29 03:30:12 appldev noship $ */
--
------------------------------------------------------------------
FUNCTION agency_get_max_seq (p_seq_location IN VARCHAR2
                                       ,p_business_group_id in NUMBER
                                       ,p_segment1     IN VARCHAR2
                                       ,p_segment2     IN VARCHAR2
                                       ,p_segment3     IN VARCHAR2
                                       ,p_segment4     IN VARCHAR2
                                       ,p_segment5     IN VARCHAR2
                                       ,p_segment6     IN VARCHAR2
                                       ,p_segment7     IN VARCHAR2
                                       ,p_segment8     IN VARCHAR2
                                       ,p_segment9     IN VARCHAR2
                                       ,p_segment10    IN VARCHAR2
                                       ,p_segment11    IN VARCHAR2
                                       ,p_segment12    IN VARCHAR2
                                       ,p_segment13    IN VARCHAR2
                                       ,p_segment14    IN VARCHAR2
                                       ,p_segment15    IN VARCHAR2
                                       ,p_segment16    IN VARCHAR2
                                       ,p_segment17    IN VARCHAR2
                                       ,p_segment18    IN VARCHAR2
                                       ,p_segment19    IN VARCHAR2
                                       ,p_segment20    IN VARCHAR2
                                       ,p_segment21    IN VARCHAR2
                                       ,p_segment22    IN VARCHAR2
                                       ,p_segment23    IN VARCHAR2
                                       ,p_segment24    IN VARCHAR2
                                       ,p_segment25    IN VARCHAR2
                                       ,p_segment26    IN VARCHAR2
                                       ,p_segment27    IN VARCHAR2
                                       ,p_segment28    IN VARCHAR2
                                       ,p_segment29    IN VARCHAR2
                                       ,p_segment30    IN VARCHAR2)
RETURN VARCHAR2 IS

BEGIN

  RETURN(null);

END agency_get_max_seq;

END ghr_agency_position_copy;

/
