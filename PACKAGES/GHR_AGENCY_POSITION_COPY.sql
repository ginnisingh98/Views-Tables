--------------------------------------------------------
--  DDL for Package GHR_AGENCY_POSITION_COPY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_AGENCY_POSITION_COPY" AUTHID CURRENT_USER AS
/* $Header: ghpocagn.pkh 120.0 2005/05/29 03:30:19 appldev noship $ */
--
-- ---------------------------------------------------------------------------
-- |--------------------------<agency_get_max_seq>--------------------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   Allows clients to override the Federal get_max_seq routine and
-- hence return their own values.  Should be used if position sequence
-- is using a sequence generator or other method for generating sequence.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_segment1 - p_segment30.
--
-- Post Success:
--   Returns a numeric value.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Developer Implementation Notes:
--
-- Access Status:
--
--
-- {End of Comments}
-- ---------------------------------------------------------------------------
function agency_get_max_seq
   (p_seq_location in VARCHAR2,
    p_business_group_id in NUMBER default NULL,
    p_segment1    in VARCHAR2 default NULL,
    p_segment2    in VARCHAR2 default NULL,
    p_segment3    in VARCHAR2 default NULL,
    p_segment4    in VARCHAR2 default NULL,
    p_segment5    in VARCHAR2 default NULL,
    p_segment6    in VARCHAR2 default NULL,
    p_segment7    in VARCHAR2 default NULL,
    p_segment8    in VARCHAR2 default NULL,
    p_segment9    in VARCHAR2 default NULL,
    p_segment10    in VARCHAR2 default NULL,
    p_segment11    in VARCHAR2 default NULL,
    p_segment12    in VARCHAR2 default NULL,
    p_segment13    in VARCHAR2 default NULL,
    p_segment14    in VARCHAR2 default NULL,
    p_segment15    in VARCHAR2 default NULL,
    p_segment16    in VARCHAR2 default NULL,
    p_segment17    in VARCHAR2 default NULL,
    p_segment18    in VARCHAR2 default NULL,
    p_segment19    in VARCHAR2 default NULL,
    p_segment20    in VARCHAR2 default NULL,
    p_segment21    in VARCHAR2 default NULL,
    p_segment22    in VARCHAR2 default NULL,
    p_segment23    in VARCHAR2 default NULL,
    p_segment24    in VARCHAR2 default NULL,
    p_segment25    in VARCHAR2 default NULL,
    p_segment26    in VARCHAR2 default NULL,
    p_segment27    in VARCHAR2 default NULL,
    p_segment28    in VARCHAR2 default NULL,
    p_segment29    in VARCHAR2 default NULL,
    p_segment30    in VARCHAR2 default NULL)
  return VARCHAR2;

----------------------------------------------------------------------------
END ghr_agency_position_copy;

--



 

/
