--------------------------------------------------------
--  DDL for Package Body FND_FLEX_PLSQL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_FLEX_PLSQL" AS
/* $Header: AFFFPLVB.pls 115.0 99/07/16 23:18:46 porting ship $ */

  FUNCTION validate(application_id         IN   NUMBER,
		    id_flex_code           IN   VARCHAR2,
		    id_flex_num            IN   NUMBER,
                    vdate                  IN   DATE,
                    segment_delimiter      IN   VARCHAR2,
                    concatenated_segments  IN   VARCHAR2,
                    numsegs                IN   NUMBER,
                    user_segment1          IN   VARCHAR2,
                    user_segment2          IN   VARCHAR2,
                    user_segment3          IN   VARCHAR2,
                    user_segment4          IN   VARCHAR2,
                    user_segment5          IN   VARCHAR2,
                    user_segment6          IN   VARCHAR2,
                    user_segment7          IN   VARCHAR2,
                    user_segment8          IN   VARCHAR2,
                    user_segment9          IN   VARCHAR2,
                    user_segment10         IN   VARCHAR2,
                    user_segment11         IN   VARCHAR2,
                    user_segment12         IN   VARCHAR2,
                    user_segment13         IN   VARCHAR2,
                    user_segment14         IN   VARCHAR2,
                    user_segment15         IN   VARCHAR2,
                    user_segment16         IN   VARCHAR2,
                    user_segment17         IN   VARCHAR2,
                    user_segment18         IN   VARCHAR2,
                    user_segment19         IN   VARCHAR2,
                    user_segment20         IN   VARCHAR2,
                    user_segment21         IN   VARCHAR2,
                    user_segment22         IN   VARCHAR2,
                    user_segment23         IN   VARCHAR2,
                    user_segment24         IN   VARCHAR2,
                    user_segment25         IN   VARCHAR2,
                    user_segment26         IN   VARCHAR2,
                    user_segment27         IN   VARCHAR2,
                    user_segment28         IN   VARCHAR2,
                    user_segment29         IN   VARCHAR2,
                    user_segment30         IN   VARCHAR2,
                    error_message          OUT  VARCHAR2)
           return BOOLEAN IS
  BEGIN
    return TRUE;
  END validate;

END FND_FLEX_PLSQL;

/
