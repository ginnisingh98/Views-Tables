--------------------------------------------------------
--  DDL for Package GHR_POSITION_COPY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_POSITION_COPY" AUTHID CURRENT_USER AS
/* $Header: ghrwspoc.pkh 120.0.12010000.3 2009/05/26 12:09:34 utokachi noship $ */
--
-- ---------------------------------------------------------------------------
-- |--------------------------< get_seq_location >---------------------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   Retrieve location of sequence number in Position Key Flex.
--
-- Prerequisites:
--   Organization Id.
--
-- In Parameters:
--   p_org_id.
--
-- Post Success:
--   Returns segment name of sequence number data item.
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
function get_seq_location
   (p_org_id   in NUMBER default NULL)
    return VARCHAR2;
--
--
-- ---------------------------------------------------------------------------
-- |--------------------------< get_max_seq>--------------------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   Retrieve the maximum existing sequence value from the Position Key Flexfield
--   where all other segments are the same as position being created.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_segment1 - p_segment30.
--
-- Post Success:
--   Returns max value of existing combination or returns 1.
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
function get_max_seq
   (p_seq_location in VARCHAR2,
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
--
-- Given a position id this function will create a position record only
-- and pass back the new position id
PROCEDURE create_posn (p_pos_id              IN  NUMBER
                      ,p_effective_date_from IN  DATE
                      ,p_effective_date_to   IN  DATE
                      ,p_template_flag       IN  VARCHAR2
                      ,p_new_pos_id          OUT NOCOPY NUMBER
                      ,p_new_pos_name        OUT NOCOPY VARCHAR2
                      ,p_ovn                 OUT NOCOPY NUMBER);
--
-- Given a from position id this procedure will create ALL the extra info
-- details associated with the form position id onto the to position id
-- For position copy we will explicity exclude types:
--  GHR_US_POS_MASS_ACTIONS
--  GHR_US_POS_OBLIG
PROCEDURE create_all_posn_ei (p_pos_id_from         IN NUMBER
                             ,p_effective_date_from IN DATE
                             ,p_pos_id_to           IN NUMBER
                             ,p_effective_date_to   IN DATE);
--
-- Given a from position id and information type this procedure will create the extra info
-- details for associated with the form position id onto the to position id
PROCEDURE create_posn_ei (p_pos_id_from         IN NUMBER
                         ,p_effective_date_from IN DATE
                         ,p_pos_id_to           IN NUMBER
                         ,p_effective_date_to   IN DATE
                         ,p_info_type           IN VARCHAR2);
--
-- Given a position id this function will create a position record
-- and its associated details (currently just EI) and pass back the new position id
PROCEDURE create_full_posn (p_pos_id              IN  NUMBER
                           ,p_effective_date_from IN  DATE
                           ,p_effective_date_to   IN  DATE
                           ,p_template_flag       IN  VARCHAR2
                           ,p_new_pos_id          OUT NOCOPY NUMBER
                           ,p_new_pos_name        OUT NOCOPY VARCHAR2
                           ,p_ovn                 OUT NOCOPY NUMBER);
--
--  Update the Template Position's Organization and Job at the session date
--  This is coded because the API does not support updating these data items.
--
FUNCTION update_position (p_pos_id              IN  NUMBER
                         ,p_new_org_id         IN NUMBER
                         ,p_new_job_id         IN NUMBER)
                         return NUMBER;
--
--
END ghr_position_copy;


/
