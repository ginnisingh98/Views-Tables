--------------------------------------------------------
--  DDL for Package HR_PERSON_NAME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERSON_NAME" AUTHID CURRENT_USER as
/* $Header: pepernam.pkh 120.1.12000000.2 2007/02/23 05:57:43 ktithy noship $ */
--
--
-- Package variables
--
--
  g_FULL_NAME      constant hr_name_formats.format_name%TYPE := 'FULL_NAME';
  g_ORDER_NAME     constant hr_name_formats.format_name%TYPE := 'ORDER_NAME';
  g_DISPLAY_NAME   constant hr_name_formats.format_name%TYPE := 'DISPLAY_NAME';
  g_LIST_NAME      constant hr_name_formats.format_name%TYPE := 'LIST_NAME';
--
   TYPE t_nameColumns_Rec IS RECORD
   (
      row_id                  rowid
     ,FIRST_NAME              per_all_people_f.first_name%TYPE
     ,MIDDLE_NAMES            per_all_people_f.middle_names%TYPE
     ,LAST_NAME               per_all_people_f.last_name%TYPE
     ,SUFFIX                  per_all_people_f.suffix%TYPE
     ,PRE_NAME_ADJUNCT        per_all_people_f.pre_name_adjunct%TYPE
     ,TITLE                   per_all_people_f.title%TYPE
     ,KNOWN_AS                per_all_people_f.known_as%TYPE
     ,EMAIL_ADDRESS           per_all_people_f.email_address%TYPE
     ,EMPLOYEE_NUMBER         per_all_people_f.employee_number%TYPE
     ,APPLICANT_NUMBER        per_all_people_f.applicant_number%TYPE
     ,NPW_NUMBER              per_all_people_f.npw_number%TYPE
     ,PREVIOUS_LAST_NAME      per_all_people_f.previous_last_name%TYPE
     ,PER_INFORMATION1        per_all_people_f.per_information1%TYPE
     ,PER_INFORMATION2        per_all_people_f.per_information2%TYPE
     ,PER_INFORMATION3        per_all_people_f.per_information3%TYPE
     ,PER_INFORMATION4        per_all_people_f.per_information4%TYPE
     ,PER_INFORMATION5        per_all_people_f.per_information5%TYPE
     ,PER_INFORMATION6        per_all_people_f.per_information6%TYPE
     ,PER_INFORMATION7        per_all_people_f.per_information7%TYPE
     ,PER_INFORMATION8        per_all_people_f.per_information8%TYPE
     ,PER_INFORMATION9        per_all_people_f.per_information9%TYPE
     ,PER_INFORMATION10       per_all_people_f.per_information10%TYPE
     ,PER_INFORMATION11       per_all_people_f.per_information11%TYPE
     ,PER_INFORMATION12       per_all_people_f.per_information12%TYPE
     ,PER_INFORMATION13       per_all_people_f.per_information13%TYPE
     ,PER_INFORMATION14       per_all_people_f.per_information14%TYPE
     ,PER_INFORMATION15       per_all_people_f.per_information15%TYPE
     ,PER_INFORMATION16       per_all_people_f.per_information16%TYPE
     ,PER_INFORMATION17       per_all_people_f.per_information17%TYPE
     ,PER_INFORMATION18       per_all_people_f.per_information18%TYPE
     ,PER_INFORMATION19       per_all_people_f.per_information19%TYPE
     ,PER_INFORMATION20       per_all_people_f.per_information20%TYPE
     ,PER_INFORMATION21       per_all_people_f.per_information21%TYPE
     ,PER_INFORMATION22       per_all_people_f.per_information22%TYPE
     ,PER_INFORMATION23       per_all_people_f.per_information23%TYPE
     ,PER_INFORMATION24       per_all_people_f.per_information24%TYPE
     ,PER_INFORMATION25       per_all_people_f.per_information25%TYPE
     ,PER_INFORMATION26       per_all_people_f.per_information26%TYPE
     ,PER_INFORMATION27       per_all_people_f.per_information27%TYPE
     ,PER_INFORMATION28       per_all_people_f.per_information28%TYPE
     ,PER_INFORMATION29       per_all_people_f.per_information29%TYPE
     ,PER_INFORMATION30       per_all_people_f.per_information30%TYPE
     ,ATTRIBUTE1        per_all_people_f.attribute1%TYPE
     ,ATTRIBUTE2        per_all_people_f.attribute2%TYPE
     ,ATTRIBUTE3        per_all_people_f.attribute3%TYPE
     ,ATTRIBUTE4        per_all_people_f.attribute4%TYPE
     ,ATTRIBUTE5        per_all_people_f.attribute5%TYPE
     ,ATTRIBUTE6        per_all_people_f.attribute6%TYPE
     ,ATTRIBUTE7        per_all_people_f.attribute7%TYPE
     ,ATTRIBUTE8        per_all_people_f.attribute8%TYPE
     ,ATTRIBUTE9        per_all_people_f.attribute9%TYPE
     ,ATTRIBUTE10       per_all_people_f.attribute10%TYPE
     ,ATTRIBUTE11       per_all_people_f.attribute11%TYPE
     ,ATTRIBUTE12       per_all_people_f.attribute12%TYPE
     ,ATTRIBUTE13       per_all_people_f.attribute13%TYPE
     ,ATTRIBUTE14       per_all_people_f.attribute14%TYPE
     ,ATTRIBUTE15       per_all_people_f.attribute15%TYPE
     ,ATTRIBUTE16       per_all_people_f.attribute16%TYPE
     ,ATTRIBUTE17       per_all_people_f.attribute17%TYPE
     ,ATTRIBUTE18       per_all_people_f.attribute18%TYPE
     ,ATTRIBUTE19       per_all_people_f.attribute19%TYPE
     ,ATTRIBUTE20       per_all_people_f.attribute20%TYPE
     ,ATTRIBUTE21       per_all_people_f.attribute21%TYPE
     ,ATTRIBUTE22       per_all_people_f.attribute22%TYPE
     ,ATTRIBUTE23       per_all_people_f.attribute23%TYPE
     ,ATTRIBUTE24       per_all_people_f.attribute24%TYPE
     ,ATTRIBUTE25       per_all_people_f.attribute25%TYPE
     ,ATTRIBUTE26       per_all_people_f.attribute26%TYPE
     ,ATTRIBUTE27       per_all_people_f.attribute27%TYPE
     ,ATTRIBUTE28       per_all_people_f.attribute28%TYPE
     ,ATTRIBUTE29       per_all_people_f.attribute29%TYPE
     ,ATTRIBUTE30       per_all_people_f.attribute30%TYPE
     ,FULL_NAME         per_all_people_f.full_name%TYPE
     ,ORDER_NAME        per_all_people_f.order_name%TYPE
     ,LOCAL_NAME        per_all_people_f.local_name%TYPE
     ,GLOBAL_NAME       per_all_people_f.global_name%TYPE
     ,BUSINESS_GROUP_ID per_all_people_f.business_group_id%TYPE
   );
--
-- ----------------------------------------------------------------------------
-- |---------------------< get_person_name_internal >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This function performs the construction of a formatted name character
--   string for a given person. The datetrack row will be specified by ROWID
--   for improved performance. The format mask must be passed in, if it is
--   null then null will be returned.
--   If format mask is found and token values are null, then full name
--   is returned.
--
-- Pre Conditions:
--  A ROWID of a person record must exist.
--  A valid format mask must be defined.
--
-- In Arguments:
--   Name                           Reqd Type     Description
--   p_rowid                        Yes  rowid    Rowid of the person's date
--                                                effective row in
--                                                PER_ALL_PEOPLE_F table.
--   p_format_mask                  Yes  varchar2 Actual mask used to create
--                                                names according to format.
--
-- Post Success:
--   A formatted name will be returned. This name is truncated to 240 characters.
--
-- Post Failure:
--   Name is not generated and an error is raised.
--
-- {End Of Comments}
--
function get_person_name_internal
              (p_rowid              in rowid
              ,p_format_mask        in varchar2) return varchar2;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_person_name >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function generates a formatted name for a given person (at a given
--   effective date). This format could be any format already defined in
--   the HR_NAME_FORMATS table. In case, the function is called with an
--   invalid Format Name/Mask a null name is returned.
--
-- Pre Conditions:
--  Person exists in the system as of effective date.
--
-- In Arguments:
--   Name                           Reqd Type     Description
--   p_person_id                    Yes  number   Uniquely identifes a person
--                                                record on PER_ALL_PEOPLE_F
--                                                table.
--   p_effective_date               Yes  date     Effective date to determine
--                                                unique person row.
--   p_format_name                  Yes  varchar2 Identifies format from
--                                                HR_NAME_FORMATS which will
--                                                determine the name construction.
--   p_user_format_choice           No   varchar2 User Format Choice to
--                                                identify correct format.
--
-- Post Success:
--   A formatted name will be returned. This name will be truncated to 240
--   characters, for consistency, to match the length of string that can
--   be stored in the denormalized name columns on PER_ALL_PEOPLE_F table.
--
-- Post Failure:
--   Formatted name is not generated and error is raised.
--
-- {End Of Comments}
--
function get_person_name(p_person_id          in number
                        ,p_effective_date     in date
                        ,p_format_name        in varchar2
                        ,p_user_format_choice in varchar2
                        ) return varchar2;
--
-- ----------------------------------------------------------------------------
-- |----------------------< OLD_get_person_name >-----------------------------|
-- ----------------------------------------------------------------------------
--
function get_person_name(
  p_person_id            in number,
  p_effective_date       in date default null,
  p_format               in varchar2 default null) return varchar2;
--
-- ----------------------------------------------------------------------------
-- |-------------------< OBSOLETE_get_person_name >---------------------------|
-- ----------------------------------------------------------------------------
--  *** This is left here for documentation purposes. ***
--
-- {Start Of Comments}
--
-- Description:
--   This function returns the person components.
--   If the format is specified then the components will be returned in
--   the specified format otherwise, person's full_name will be returned.
--
-- Pre Conditions:
--  If the effective_date is not specified, then sysdate will be defaulted.
--
--  This function validates only the following specified tokens.
--
--  $FI - First Name
--  $MI - Middle Name
--  $LA - Last Name
--  $PR - Prefix
--  $SU - Suffix
--  $TI - Title
--  $FU - Full Name
--  $KN - Known As
--  $IF - Initial First
--  $IM - Initial Middle
--
-- In Arguments:
--   person_id       -- person_id, if not valid exception is raised.
--   effective_date  -- date - defaults to sysdate if null
--   format          -- A string with the above tokens (eg. $FI.$MI.$LA)
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--
--   No_data_found is raised and is propagated to calling routine.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--function get_person_name(
--  p_person_id            in number,
--  p_effective_date       in date default null,
--  p_format               in varchar2 default null) return varchar2;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< derive_person_names >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure generates formatted names for a given person: full name,
--   order name, global name, local name.
--   If p_format_name is passed in then only that name is generated; however,
--   this procedure can generate all the names stored in per_all_people_f
--   whenever specified.
--
--   If format name is passed in and a format mask is found, then
--      a) if token values are not null, then formatted name is returned
--      b) if all token values are null, then null is returned.
--
--   The system will derive the name according to the following rules:
--      a) Retrieve format mask for format name and legislation
--      b) if found then, derive name according to format mask
--      c) if not found then, search for seeded stored procedure and derive
--         name.
--      d) if seeded procedure found, then derive name using existing procedure.
--      e) if seeded procedure not found, then search for seeded format mask
--         and derive name. Seeded procedure is used when deriving Full Name
--         and/or Order Name.
--      e) if seeded format mask not found, then return null.
--
-- Pre Conditions:
--  N/A
--
-- In Arguments:
--   Name                           Reqd Type     Description
--   p_format_name                  Yes  varchar2 Identifies format from
--                                                HR_NAME_FORMATS which will
--                                                determine the name
--                                                construction.
--                                                if NULL, then ALL format names
--                                                will be derived: full, order,
--                                                global and local.
--  <..Name columns..>              No            All other columns that can be
--                                                used in the formatting of a
--                                                name.
--
-- Post Success:
--   A formatted name will be returned. This name will be truncated to 240
--   characters, for consistency, to match the length of string that can
--   be stored in the denormalized name columns on PER_ALL_PEOPLE_F table.
--
-- Post Failure:
--   Formatted name is not generated and error is raised.
--
-- {End Of Comments}
--
procedure derive_person_names
(p_format_name        hr_name_formats.format_name%TYPE,
 p_business_group_id  per_all_people_f.business_group_id%TYPE,
 p_person_id          per_all_people_f.person_id%TYPE,
 p_first_name         per_all_people_f.first_name%TYPE,
 p_middle_names       per_all_people_f.middle_names%TYPE,
 p_last_name          per_all_people_f.last_name%TYPE,
 p_known_as           per_all_people_f.known_as%TYPE,
 p_title              per_all_people_f.title%TYPE,
 p_suffix             per_all_people_f.suffix%TYPE,
 p_pre_name_adjunct   per_all_people_f.pre_name_adjunct%TYPE,
 p_date_of_birth      per_all_people_f.date_of_birth%TYPE,
 p_previous_last_name per_all_people_f.previous_last_name%TYPE DEFAULT NULL,
 p_email_address      per_all_people_f.email_address%TYPE DEFAULT NULL,
 p_employee_number    per_all_people_f.employee_number%TYPE DEFAULT NULL,
 p_applicant_number   per_all_people_f.applicant_number%TYPE DEFAULT NULL,
 p_npw_number         per_all_people_f.npw_number%TYPE DEFAULT NULL,
 p_per_information1   per_all_people_f.per_information1%TYPE DEFAULT NULL,
 p_per_information2   per_all_people_f.per_information2%TYPE DEFAULT NULL,
 p_per_information3   per_all_people_f.per_information3%TYPE DEFAULT NULL,
 p_per_information4   per_all_people_f.per_information4%TYPE DEFAULT NULL,
 p_per_information5   per_all_people_f.per_information5%TYPE DEFAULT NULL,
 p_per_information6   per_all_people_f.per_information6%TYPE DEFAULT NULL,
 p_per_information7   per_all_people_f.per_information7%TYPE DEFAULT NULL,
 p_per_information8   per_all_people_f.per_information8%TYPE DEFAULT NULL,
 p_per_information9   per_all_people_f.per_information9%TYPE DEFAULT NULL,
 p_per_information10  per_all_people_f.per_information10%TYPE DEFAULT NULL,
 p_per_information11  per_all_people_f.per_information11%TYPE DEFAULT NULL,
 p_per_information12  per_all_people_f.per_information12%TYPE DEFAULT NULL,
 p_per_information13  per_all_people_f.per_information13%TYPE DEFAULT NULL,
 p_per_information14  per_all_people_f.per_information14%TYPE DEFAULT NULL,
 p_per_information15  per_all_people_f.per_information15%TYPE DEFAULT NULL,
 p_per_information16  per_all_people_f.per_information16%TYPE DEFAULT NULL,
 p_per_information17  per_all_people_f.per_information17%TYPE DEFAULT NULL,
 p_per_information18  per_all_people_f.per_information18%TYPE DEFAULT NULL,
 p_per_information19  per_all_people_f.per_information19%TYPE DEFAULT NULL,
 p_per_information20  per_all_people_f.per_information20%TYPE DEFAULT NULL,
 p_per_information21  per_all_people_f.per_information21%TYPE DEFAULT NULL,
 p_per_information22  per_all_people_f.per_information22%TYPE DEFAULT NULL,
 p_per_information23  per_all_people_f.per_information23%TYPE DEFAULT NULL,
 p_per_information24  per_all_people_f.per_information24%TYPE DEFAULT NULL,
 p_per_information25  per_all_people_f.per_information25%TYPE DEFAULT NULL,
 p_per_information26  per_all_people_f.per_information26%TYPE DEFAULT NULL,
 p_per_information27  per_all_people_f.per_information27%TYPE DEFAULT NULL,
 p_per_information28  per_all_people_f.per_information28%TYPE DEFAULT NULL,
 p_per_information29  per_all_people_f.per_information29%TYPE DEFAULT NULL,
 p_per_information30  per_all_people_f.per_information30%TYPE DEFAULT NULL,
 p_attribute1         per_all_people_f.attribute1%TYPE DEFAULT NULL,
 p_attribute2         per_all_people_f.attribute2%TYPE DEFAULT NULL,
 p_attribute3         per_all_people_f.attribute3%TYPE DEFAULT NULL,
 p_attribute4         per_all_people_f.attribute4%TYPE DEFAULT NULL,
 p_attribute5         per_all_people_f.attribute5%TYPE DEFAULT NULL,
 p_attribute6         per_all_people_f.attribute6%TYPE DEFAULT NULL,
 p_attribute7         per_all_people_f.attribute7%TYPE DEFAULT NULL,
 p_attribute8         per_all_people_f.attribute8%TYPE DEFAULT NULL,
 p_attribute9         per_all_people_f.attribute9%TYPE DEFAULT NULL,
 p_attribute10        per_all_people_f.attribute10%TYPE DEFAULT NULL,
 p_attribute11        per_all_people_f.attribute11%TYPE DEFAULT NULL,
 p_attribute12        per_all_people_f.attribute12%TYPE DEFAULT NULL,
 p_attribute13        per_all_people_f.attribute13%TYPE DEFAULT NULL,
 p_attribute14        per_all_people_f.attribute14%TYPE DEFAULT NULL,
 p_attribute15        per_all_people_f.attribute15%TYPE DEFAULT NULL,
 p_attribute16        per_all_people_f.attribute16%TYPE DEFAULT NULL,
 p_attribute17        per_all_people_f.attribute17%TYPE DEFAULT NULL,
 p_attribute18        per_all_people_f.attribute18%TYPE DEFAULT NULL,
 p_attribute19        per_all_people_f.attribute19%TYPE DEFAULT NULL,
 p_attribute20        per_all_people_f.attribute20%TYPE DEFAULT NULL,
 p_attribute21        per_all_people_f.attribute21%TYPE DEFAULT NULL,
 p_attribute22        per_all_people_f.attribute22%TYPE DEFAULT NULL,
 p_attribute23        per_all_people_f.attribute23%TYPE DEFAULT NULL,
 p_attribute24        per_all_people_f.attribute24%TYPE DEFAULT NULL,
 p_attribute25        per_all_people_f.attribute25%TYPE DEFAULT NULL,
 p_attribute26        per_all_people_f.attribute26%TYPE DEFAULT NULL,
 p_attribute27        per_all_people_f.attribute27%TYPE DEFAULT NULL,
 p_attribute28        per_all_people_f.attribute28%TYPE DEFAULT NULL,
 p_attribute29        per_all_people_f.attribute29%TYPE DEFAULT NULL,
 p_attribute30        per_all_people_f.attribute30%TYPE DEFAULT NULL,
 p_full_name          OUT NOCOPY per_all_people_f.full_name%TYPE ,
 p_order_name         OUT NOCOPY per_all_people_f.order_name%TYPE,
 p_global_name        OUT NOCOPY per_all_people_f.global_name%TYPE,
 p_local_name         OUT NOCOPY per_all_people_f.local_name%TYPE,
 p_duplicate_flag     OUT NOCOPY VARCHAR2
 );
--
--
procedure derive_person_names
(p_format_name        hr_name_formats.format_name%TYPE,
 p_business_group_id  per_all_people_f.business_group_id%TYPE,
 p_first_name         per_all_people_f.first_name%TYPE,
 p_middle_names       per_all_people_f.middle_names%TYPE,
 p_last_name          per_all_people_f.last_name%TYPE,
 p_known_as           per_all_people_f.known_as%TYPE,
 p_title              per_all_people_f.title%TYPE,
 p_suffix             per_all_people_f.suffix%TYPE,
 p_pre_name_adjunct   per_all_people_f.pre_name_adjunct%TYPE,
 p_date_of_birth      per_all_people_f.date_of_birth%TYPE,
 p_previous_last_name per_all_people_f.previous_last_name%TYPE DEFAULT NULL,
 p_email_address      per_all_people_f.email_address%TYPE DEFAULT NULL,
 p_employee_number    per_all_people_f.employee_number%TYPE DEFAULT NULL,
 p_applicant_number   per_all_people_f.applicant_number%TYPE DEFAULT NULL,
 p_npw_number         per_all_people_f.npw_number%TYPE DEFAULT NULL,
 p_per_information1   per_all_people_f.per_information1%TYPE DEFAULT NULL,
 p_per_information2   per_all_people_f.per_information2%TYPE DEFAULT NULL,
 p_per_information3   per_all_people_f.per_information3%TYPE DEFAULT NULL,
 p_per_information4   per_all_people_f.per_information4%TYPE DEFAULT NULL,
 p_per_information5   per_all_people_f.per_information5%TYPE DEFAULT NULL,
 p_per_information6   per_all_people_f.per_information6%TYPE DEFAULT NULL,
 p_per_information7   per_all_people_f.per_information7%TYPE DEFAULT NULL,
 p_per_information8   per_all_people_f.per_information8%TYPE DEFAULT NULL,
 p_per_information9   per_all_people_f.per_information9%TYPE DEFAULT NULL,
 p_per_information10  per_all_people_f.per_information10%TYPE DEFAULT NULL,
 p_per_information11  per_all_people_f.per_information11%TYPE DEFAULT NULL,
 p_per_information12  per_all_people_f.per_information12%TYPE DEFAULT NULL,
 p_per_information13  per_all_people_f.per_information13%TYPE DEFAULT NULL,
 p_per_information14  per_all_people_f.per_information14%TYPE DEFAULT NULL,
 p_per_information15  per_all_people_f.per_information15%TYPE DEFAULT NULL,
 p_per_information16  per_all_people_f.per_information16%TYPE DEFAULT NULL,
 p_per_information17  per_all_people_f.per_information17%TYPE DEFAULT NULL,
 p_per_information18  per_all_people_f.per_information18%TYPE DEFAULT NULL,
 p_per_information19  per_all_people_f.per_information19%TYPE DEFAULT NULL,
 p_per_information20  per_all_people_f.per_information20%TYPE DEFAULT NULL,
 p_per_information21  per_all_people_f.per_information21%TYPE DEFAULT NULL,
 p_per_information22  per_all_people_f.per_information22%TYPE DEFAULT NULL,
 p_per_information23  per_all_people_f.per_information23%TYPE DEFAULT NULL,
 p_per_information24  per_all_people_f.per_information24%TYPE DEFAULT NULL,
 p_per_information25  per_all_people_f.per_information25%TYPE DEFAULT NULL,
 p_per_information26  per_all_people_f.per_information26%TYPE DEFAULT NULL,
 p_per_information27  per_all_people_f.per_information27%TYPE DEFAULT NULL,
 p_per_information28  per_all_people_f.per_information28%TYPE DEFAULT NULL,
 p_per_information29  per_all_people_f.per_information29%TYPE DEFAULT NULL,
 p_per_information30  per_all_people_f.per_information30%TYPE DEFAULT NULL,
 p_attribute1         per_all_people_f.attribute1%TYPE DEFAULT NULL,
 p_attribute2         per_all_people_f.attribute2%TYPE DEFAULT NULL,
 p_attribute3         per_all_people_f.attribute3%TYPE DEFAULT NULL,
 p_attribute4         per_all_people_f.attribute4%TYPE DEFAULT NULL,
 p_attribute5         per_all_people_f.attribute5%TYPE DEFAULT NULL,
 p_attribute6         per_all_people_f.attribute6%TYPE DEFAULT NULL,
 p_attribute7         per_all_people_f.attribute7%TYPE DEFAULT NULL,
 p_attribute8         per_all_people_f.attribute8%TYPE DEFAULT NULL,
 p_attribute9         per_all_people_f.attribute9%TYPE DEFAULT NULL,
 p_attribute10        per_all_people_f.attribute10%TYPE DEFAULT NULL,
 p_attribute11        per_all_people_f.attribute11%TYPE DEFAULT NULL,
 p_attribute12        per_all_people_f.attribute12%TYPE DEFAULT NULL,
 p_attribute13        per_all_people_f.attribute13%TYPE DEFAULT NULL,
 p_attribute14        per_all_people_f.attribute14%TYPE DEFAULT NULL,
 p_attribute15        per_all_people_f.attribute15%TYPE DEFAULT NULL,
 p_attribute16        per_all_people_f.attribute16%TYPE DEFAULT NULL,
 p_attribute17        per_all_people_f.attribute17%TYPE DEFAULT NULL,
 p_attribute18        per_all_people_f.attribute18%TYPE DEFAULT NULL,
 p_attribute19        per_all_people_f.attribute19%TYPE DEFAULT NULL,
 p_attribute20        per_all_people_f.attribute20%TYPE DEFAULT NULL,
 p_attribute21        per_all_people_f.attribute21%TYPE DEFAULT NULL,
 p_attribute22        per_all_people_f.attribute22%TYPE DEFAULT NULL,
 p_attribute23        per_all_people_f.attribute23%TYPE DEFAULT NULL,
 p_attribute24        per_all_people_f.attribute24%TYPE DEFAULT NULL,
 p_attribute25        per_all_people_f.attribute25%TYPE DEFAULT NULL,
 p_attribute26        per_all_people_f.attribute26%TYPE DEFAULT NULL,
 p_attribute27        per_all_people_f.attribute27%TYPE DEFAULT NULL,
 p_attribute28        per_all_people_f.attribute28%TYPE DEFAULT NULL,
 p_attribute29        per_all_people_f.attribute29%TYPE DEFAULT NULL,
 p_attribute30        per_all_people_f.attribute30%TYPE DEFAULT NULL,
 p_full_name          OUT NOCOPY per_all_people_f.full_name%TYPE ,
 p_order_name         OUT NOCOPY per_all_people_f.order_name%TYPE,
 p_global_name        OUT NOCOPY per_all_people_f.global_name%TYPE,
 p_local_name         OUT NOCOPY per_all_people_f.local_name%TYPE
 );
--
-- ----------------------------------------------------------------------------
-- |---------------------< get_formatted_name >-------------------------------|
-- ----------------------------------------------------------------------------
-- Description:
--   This function returns the formatted name based on the column values passed
--   in as parameters. If column value is null, then token is ignored.
--
procedure get_formatted_name(p_name_values    in hr_person_name.t_nameColumns_Rec
                            ,p_formatted_name in out nocopy varchar2);
--
-- ----------------------------------------------------------------------------
-- |--------------------< derive_formatted_name >-----------------------------|
-- ----------------------------------------------------------------------------
-- Description:
--   This function returns the formatted name based on the column values passed
--   in as parameters. This version assumes all the values are already
--   cached prior to constructing the name. It derives one name at the time.
--
function derive_formatted_name
  (p_person_names_rec   in hr_person_name.t_nameColumns_Rec
  ,p_format_name        in varchar2
  ,p_legislation_code   in varchar2
  ,p_format_mask        in varchar2
  ,p_seeded_pkg         in varchar2 default NULL
  ,p_seeded_procedure   in varchar2 default NULL
  ,p_seeded_format_mask in varchar2 default NULL) return varchar2;
--
-- ----------------------------------------------------------------------------
-- |-------------------< get_seeded_procedure_name >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure get_seeded_procedure_name
   (p_format_name       IN varchar2
   ,p_legislation_code  IN varchar2
   ,p_package_name      OUT nocopy varchar2
   ,p_procedure_name    OUT nocopy varchar2 );
--
-- ----------------------------------------------------------------------------
-- |---------------------< get_formatMask_desc >-------------------------------|
-- ----------------------------------------------------------------------------
-- Description:
--   This function is used by the UI. It returns a descriptive format mask.
--   i.e. token descriptions.
--
function get_formatMask_desc(p_formatMask varchar2) return varchar2;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_token >---------------------------------------|
-- ----------------------------------------------------------------------------
-- Description:
--   Returns the token that is on a specific location within the format mask.
--   This location is determined by the p_token_number parameter.
--
function get_token(p_format_mask    in varchar2
                   ,p_token_number   in number) return varchar2;
--
-- ----------------------------------------------------------------------------
-- |----------------------< get_token_desc >----------------------------------|
-- ----------------------------------------------------------------------------
-- Description:
--   Returns the token description (lookup meaning).
--
function get_token_desc(p_token in varchar2) return varchar2;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_prefix >--------------------------------------|
-- ----------------------------------------------------------------------------
-- Description:
--   Returns the prefix associated with a particular token.
--   The p_token_number identifies the specific location within the format mask.
--
function get_prefix(p_format_mask    in varchar2
                   ,p_token_number   in number) return varchar2;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_suffix >--------------------------------------|
-- ----------------------------------------------------------------------------
-- Description:
--   Returns the suffix associated with a particular token.
--   The p_token_number identifies the specific location within the format mask.
--
function get_suffix(p_format_mask    in varchar2
                   ,p_token_number   in number) return varchar2;
--
-- ----------------------------------------------------------------------------
-- |----------------------< get_total_tokens >--------------------------------|
-- ----------------------------------------------------------------------------
-- Description:
--   Returns the number of components (tokens) used in a format mask.
--
function get_total_tokens(p_format_mask    in varchar2) return number;
--
-- ----------------------------------------------------------------------------
-- |----------------------< get_space_before >--------------------------------|
-- ----------------------------------------------------------------------------
-- Description:
--   This returns 'Y' if a white space has been used before any punctuation
--   characters within the component (suffix or prefix).
--   Otherwise, returns 'N'.
--
function get_space_before(p_component varchar2) return varchar2;
--
-- ----------------------------------------------------------------------------
-- |----------------------< get_space_after  >--------------------------------|
-- ----------------------------------------------------------------------------
-- Description:
--   This returns 'Y' if a white space has been used after any punctuation
--   characters within the component (suffix or prefix).
--   Otherwise, returns 'N'.
--
function get_space_after(p_component varchar2) return varchar2;
--
-- ----------------------------------------------------------------------------
-- |----------------------< get_punctuation  >--------------------------------|
-- ----------------------------------------------------------------------------
-- Description:
--   This returns the special characters used within the component.
--   Otherwise, returns null.
--
function get_punctuation(p_component varchar2) return varchar2;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_list_namne  >--------------------------------|
-- ----------------------------------------------------------------------------
-- Description:
--   This returns either a global or local name depending on the profile
--   option setting. This function is to be used within the inter-operable
--   views (See 4428910).
--
  function get_list_name(p_global_name in varchar2, p_local_name in varchar2)
     return varchar2;
  PRAGMA RESTRICT_REFERENCES (get_list_name, WNPS, WNDS, trust);
--
--
end hr_person_name;
--

 

/
