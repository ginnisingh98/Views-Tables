--------------------------------------------------------
--  DDL for Package PER_GRADES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_GRADES_PKG" AUTHID CURRENT_USER as
/* $Header: pegrd01t.pkh 115.4 2003/05/23 17:44:36 kjagadee ship $ */

-- Standard insert procedure

procedure insert_row(
      p_row_id                      in out nocopy varchar2,
      p_grade_id                    in out nocopy number,
      p_business_group_id           number,
      p_grade_definition_id         number,
      p_date_from                   date,
      p_sequence                    number,
      p_comments                    varchar2,
      p_date_to                     date,
      p_name                        varchar2,
      p_request_id                  number,
      p_program_application_id      number,
      p_program_id                  number,
      p_program_update_date         date,
      p_attribute_category          varchar2,
      p_attribute1                  varchar2,
      p_attribute2                  varchar2,
      p_attribute3                  varchar2,
      p_attribute4                  varchar2,
      p_attribute5                  varchar2,
      p_attribute6                  varchar2,
      p_attribute7                  varchar2,
      p_attribute8                  varchar2,
      p_attribute9                  varchar2,
      p_attribute10                 varchar2,
      p_attribute11                 varchar2,
      p_attribute12                 varchar2,
      p_attribute13                 varchar2,
      p_attribute14                 varchar2,
      p_attribute15                 varchar2,
      p_attribute16                 varchar2,
      p_attribute17                 varchar2,
      p_attribute18                 varchar2,
      p_attribute19                 varchar2,
      p_attribute20                 varchar2,
      p_language_code               varchar2 default hr_api.userenv_lang);


--standard delete procedure

procedure delete_row(p_row_id varchar2,
                     p_grd_id in number);


--standard lock procedure

procedure lock_row (
      p_row_id                      varchar2,
      p_grade_id                    number,
      p_business_group_id           number,
      p_grade_definition_id         number,
      p_date_from                   date,
      p_sequence                    number,
      p_comments                    varchar2,
      p_date_to                     date,
      p_name                        varchar2,
      p_request_id                  number,
      p_program_application_id      number,
      p_program_id                  number,
      p_program_update_date         date,
      p_attribute_category          varchar2,
      p_attribute1                  varchar2,
      p_attribute2                  varchar2,
      p_attribute3                  varchar2,
      p_attribute4                  varchar2,
      p_attribute5                  varchar2,
      p_attribute6                  varchar2,
      p_attribute7                  varchar2,
      p_attribute8                  varchar2,
      p_attribute9                  varchar2,
      p_attribute10                 varchar2,
      p_attribute11                 varchar2,
      p_attribute12                 varchar2,
      p_attribute13                 varchar2,
      p_attribute14                 varchar2,
      p_attribute15                 varchar2,
      p_attribute16                 varchar2,
      p_attribute17                 varchar2,
      p_attribute18                 varchar2,
      p_attribute19                 varchar2,
      p_attribute20                 varchar2,
      p_language_code               varchar2 default hr_api.userenv_lang);


--standard update procedure

procedure update_row(
      p_row_id                      varchar2,
      p_grade_id                    number,
      p_business_group_id           number,
      p_grade_definition_id         number,
      p_date_from                   date,
      p_sequence                    number,
      p_comments                    varchar2,
      p_date_to                     date,
      p_name                        varchar2,
      p_request_id                  number,
      p_program_application_id      number,
      p_program_id                  number,
      p_program_update_date         date,
      p_attribute_category          varchar2,
      p_attribute1                  varchar2,
      p_attribute2                  varchar2,
      p_attribute3                  varchar2,
      p_attribute4                  varchar2,
      p_attribute5                  varchar2,
      p_attribute6                  varchar2,
      p_attribute7                  varchar2,
      p_attribute8                  varchar2,
      p_attribute9                  varchar2,
      p_attribute10                 varchar2,
      p_attribute11                 varchar2,
      p_attribute12                 varchar2,
      p_attribute13                 varchar2,
      p_attribute14                 varchar2,
      p_attribute15                 varchar2,
      p_attribute16                 varchar2,
      p_attribute17                 varchar2,
      p_attribute18                 varchar2,
      p_attribute19                 varchar2,
      p_attribute20                 varchar2,
      p_language_code               varchar2 default hr_api.userenv_lang);


procedure stbdelvl(
      p_grd_id                      number);


procedure postup1(
      p_seq                         NUMBER,
      p_s_seq  IN OUT NOCOPY               NUMBER,
      p_lastup                      NUMBER,
      p_login                       NUMBER,
      p_grd_id                      NUMBER,
      p_bgroup                      NUMBER,
      l_exists OUT NOCOPY                  VARCHAR2);


procedure postup2(
      p_grd_id                      NUMBER,
      p_bgroup                      NUMBER,
      p_date_from                   DATE,
      p_date_to                     DATE,
      p_eot                         DATE,
      p_date_to_old                 DATE);


procedure gstruct(
      p_b_group                     number,
      p_s_def_col IN OUT NOCOPY            varchar2);


PROCEDURE b_check_grade_date_from (
      p_grd_id                      NUMBER,
      p_date_from                   DATE);


PROCEDURE chk_flex_def (
      p_rwid                        VARCHAR2,
      p_grd_id                      NUMBER,
      p_bgroup_id                   NUMBER,
      p_grdef_id                    NUMBER);


PROCEDURE chk_grade (
      p_rwid                        VARCHAR2,
      p_bgroup_id                   NUMBER,
      p_seg                         VARCHAR2,
      p_popid  OUT NOCOPY                  VARCHAR2,
      p_fail   OUT NOCOPY                  BOOLEAN);

procedure old_date_to(p_grd_id IN NUMBER,
		      p_old_date IN OUT NOCOPY DATE);


procedure chk_seq(p_rwid in varchar2,
                  p_bgroup in number,
                  p_seq in number);

-- Start of Bug fix 2400465
-- ----------------------------------------------------------------------------
-- |-------------------< chk_date_from >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure will check any valid grade rate is existing(attached)
--  for this grade id with effective from date is before the from date
--  of the grade.
--
-- Prerequisites:
--   A valid grade must be existing .
--
-- In Parameters:
--   Name                          Reqd  Type          Description
--   p_grade_id                    yes   number        System assigned id for
--                                                     the grade
--   p_date_from                   yes   date          New from date of the
--                                                     grade
-- Post Success:
--   User cannot modify the grade from date to a date less than the effective
--   from date of a grade rate which is attached to this grade. User will
--   be stopped with the dispaly of an appropriate message
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Internal developement use.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_date_from(p_grade_id in number,
                        p_date_from in date);

-- ----------------------------------------------------------------------------
-- |-------------------< chk_end_date >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure will check any valid grade rate is existing for this
--  grade with effective end date is greater than the end date of grade
--
-- Prerequisites:
--   A valid grade must be existing .
--
-- In Parameters:
--   Name                          Reqd  Type          Description
--   p_grade_id                    yes   number        System assigned id for
--                                                     the grade
--   p_date_to                     yes   date          New date to for the
--                                                     grade
-- Post Success:
--   User cannot modify the grade "date to" to a date less than the effective
--   end date of a grade rate which is attached to this grade. A message
--   will be displayed to the user for the same.
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Internal developement use.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_end_date(p_grade_id in number,
                       p_date_to in date);
-- End of fix

end PER_GRADES_PKG;

 

/
