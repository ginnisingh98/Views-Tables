--------------------------------------------------------
--  DDL for Package HRI_OPL_JOBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OPL_JOBH" AUTHID CURRENT_USER AS
/* $Header: hripjobh.pkh 120.1.12000000.2 2007/04/12 13:26:59 smohapat noship $ */

FUNCTION get_flexfield_type(p_job_type  IN VARCHAR2,
                            p_value_set_id  IN NUMBER)
    RETURN VARCHAR2;

PROCEDURE generate_lov_views;

PROCEDURE full_refresh;

PROCEDURE full_refresh(errbuf   OUT NOCOPY VARCHAR2,
                       retcode  OUT NOCOPY VARCHAR2);

PROCEDURE incr_refresh;

PROCEDURE incr_refresh(errbuf   OUT NOCOPY VARCHAR2,
                       retcode  OUT NOCOPY VARCHAR2);

PROCEDURE incr_refresh(p_refresh_flex  IN VARCHAR2);

FUNCTION decode_keyflex_value
           (p_id_flex_num   NUMBER,
            p_job_type      VARCHAR2,
            p_segment1      VARCHAR2,
            p_segment2      VARCHAR2,
            p_segment3      VARCHAR2,
            p_segment4      VARCHAR2,
            p_segment5      VARCHAR2,
            p_segment6      VARCHAR2,
            p_segment7      VARCHAR2,
            p_segment8      VARCHAR2,
            p_segment9      VARCHAR2,
            p_segment10     VARCHAR2,
            p_segment11     VARCHAR2,
            p_segment12     VARCHAR2,
            p_segment13     VARCHAR2,
            p_segment14     VARCHAR2,
            p_segment15     VARCHAR2,
            p_segment16     VARCHAR2,
            p_segment17     VARCHAR2,
            p_segment18     VARCHAR2,
            p_segment19     VARCHAR2,
            p_segment20     VARCHAR2,
            p_segment21     VARCHAR2,
            p_segment22     VARCHAR2,
            p_segment23     VARCHAR2,
            p_segment24     VARCHAR2,
            p_segment25     VARCHAR2,
            p_segment26     VARCHAR2,
            p_segment27     VARCHAR2,
            p_segment28     VARCHAR2,
            p_segment29     VARCHAR2,
            p_segment30     VARCHAR2)
RETURN VARCHAR2;

FUNCTION decode_descr_flex_value
           (p_attribute_category  VARCHAR2,
            p_job_type            VARCHAR2,
            p_attribute1          VARCHAR2,
            p_attribute2          VARCHAR2,
            p_attribute3          VARCHAR2,
            p_attribute4          VARCHAR2,
            p_attribute5          VARCHAR2,
            p_attribute6          VARCHAR2,
            p_attribute7          VARCHAR2,
            p_attribute8          VARCHAR2,
            p_attribute9          VARCHAR2,
            p_attribute10         VARCHAR2,
            p_attribute11         VARCHAR2,
            p_attribute12         VARCHAR2,
            p_attribute13         VARCHAR2,
            p_attribute14         VARCHAR2,
            p_attribute15         VARCHAR2,
            p_attribute16         VARCHAR2,
            p_attribute17         VARCHAR2,
            p_attribute18         VARCHAR2,
            p_attribute19         VARCHAR2,
            p_attribute20         VARCHAR2)
RETURN VARCHAR2;

END hri_opl_jobh;

 

/
