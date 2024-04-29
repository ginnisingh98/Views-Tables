--------------------------------------------------------
--  DDL for Package PER_SIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SIT_PKG" AUTHID CURRENT_USER as
/* $Header: pesit01t.pkh 115.1 2003/02/10 17:21:37 eumenyio ship $ */
--
----------------------------------------------------------------------
-- check_unique_sit
--
--    Ensures that the Special Info Type is unique within the Business Group
--
procedure check_unique_sit(p_special_information_type_id in number
                          ,p_bg_id                       in number
                          ,p_id_flex_num                 in number);
--
----------------------------------------------------------------------
-- sit_flex_used
--
--    Determines whether the Flex Structure has been used in Personal
--    Analyses
--
function sit_flex_used(p_bg_id number
                      ,p_id_flex_num number) return boolean;
--
----------------------------------------------------------------------
-- sit_del_validation
--
--      Delete Validation
--
procedure sit_del_validation(p_bg_id number
                            ,p_id_flex_num number);
----------------------------------------------------------------------
--
procedure populate_fields(p_id_flex_num number
                         ,p_name IN OUT NOCOPY varchar2
                         ,p_flex_enabled IN OUT NOCOPY varchar2);

----------------------------------------------------------------------
-- get_special_info_type_id
--
--       Retrives next UNIQUE ID
--
function get_special_info_type_id return number;

----------------------------------------------------------------------
-- ins_sit
--
--       Inserts a record into PER_SPECIAL_INFO_TYPES
--
procedure ins_sit (p_SPECIAL_INFORMATION_TYPE_ID     in out nocopy NUMBER,
                   p_BUSINESS_GROUP_ID               in NUMBER,
                   p_ID_FLEX_NUM                     in NUMBER,
                   p_COMMENTS                        in varchar2,
                   p_ENABLED_FLAG                    in VARCHAR2,
                   p_REQUEST_ID                      in NUMBER,
                   p_PROGRAM_APPLICATION_ID          in NUMBER,
                   p_PROGRAM_ID                      in NUMBER,
                   p_PROGRAM_UPDATE_DATE             in DATE,
                   p_ATTRIBUTE_CATEGORY              in VARCHAR2,
                   p_ATTRIBUTE1                      in VARCHAR2,
                   p_ATTRIBUTE2                      in VARCHAR2,
                   p_ATTRIBUTE3                      in VARCHAR2,
                   p_ATTRIBUTE4                      in VARCHAR2,
                   p_ATTRIBUTE5                      in VARCHAR2,
                   p_ATTRIBUTE6                      in VARCHAR2,
                   p_ATTRIBUTE7                      in VARCHAR2,
                   p_ATTRIBUTE8                      in VARCHAR2,
                   p_ATTRIBUTE9                      in VARCHAR2,
                   p_ATTRIBUTE10                     in VARCHAR2,
                   p_ATTRIBUTE11                     in VARCHAR2,
                   p_ATTRIBUTE12                     in VARCHAR2,
                   p_ATTRIBUTE13                     in VARCHAR2,
                   p_ATTRIBUTE14                     in VARCHAR2,
                   p_ATTRIBUTE15                     in VARCHAR2,
                   p_ATTRIBUTE16                     in VARCHAR2,
                   p_ATTRIBUTE17                     in VARCHAR2,
                   p_ATTRIBUTE18                     in VARCHAR2,
                   p_ATTRIBUTE19                     in VARCHAR2,
                   p_ATTRIBUTE20                     in VARCHAR2,
                   p_MULTIPLE_OCCURRENCES_FLAG       in VARCHAR2);

----------------------------------------------------------------------
-- lck
--
--       Locks a record in PER_SPECIAL_INFO_TYPES
--
Procedure lck ( p_special_information_type_id  in number );

----------------------------------------------------------------------
-- upd_sit
--
--       Updates a record into PER_SPECIAL_INFO_TYPES
--
procedure upd_sit (p_SPECIAL_INFORMATION_TYPE_ID     in NUMBER,
                   p_BUSINESS_GROUP_ID               in NUMBER,
                   p_ID_FLEX_NUM                     in NUMBER,
                   p_COMMENTS                        in VARCHAR2,
                   p_ENABLED_FLAG                    in VARCHAR2,
                   p_REQUEST_ID                      in NUMBER,
                   p_PROGRAM_APPLICATION_ID          in NUMBER,
                   p_PROGRAM_ID                      in NUMBER,
                   p_PROGRAM_UPDATE_DATE             in DATE,
                   p_ATTRIBUTE_CATEGORY              in VARCHAR2,
                   p_ATTRIBUTE1                      in VARCHAR2,
                   p_ATTRIBUTE2                      in VARCHAR2,
                   p_ATTRIBUTE3                      in VARCHAR2,
                   p_ATTRIBUTE4                      in VARCHAR2,
                   p_ATTRIBUTE5                      in VARCHAR2,
                   p_ATTRIBUTE6                      in VARCHAR2,
                   p_ATTRIBUTE7                      in VARCHAR2,
                   p_ATTRIBUTE8                      in VARCHAR2,
                   p_ATTRIBUTE9                      in VARCHAR2,
                   p_ATTRIBUTE10                     in VARCHAR2,
                   p_ATTRIBUTE11                     in VARCHAR2,
                   p_ATTRIBUTE12                     in VARCHAR2,
                   p_ATTRIBUTE13                     in VARCHAR2,
                   p_ATTRIBUTE14                     in VARCHAR2,
                   p_ATTRIBUTE15                     in VARCHAR2,
                   p_ATTRIBUTE16                     in VARCHAR2,
                   p_ATTRIBUTE17                     in VARCHAR2,
                   p_ATTRIBUTE18                     in VARCHAR2,
                   p_ATTRIBUTE19                     in VARCHAR2,
                   p_ATTRIBUTE20                     in VARCHAR2,
                   p_MULTIPLE_OCCURRENCES_FLAG       in VARCHAR2);
--
----------------------------------------------------------------------
-- reset_usages
--
--       Removes any records in PER_SPECIAL_INFO_TYPE_USAGES which have
--       had their associated flag reset
--       Calls add_usage to insert any new usages for each category
--
--
procedure reset_usages (p_special_information_type_id in number,
                        p_job_category                in varchar2,
                        p_position_category           in varchar2,
                        p_skill_category              in varchar2,
                        p_other_category              in varchar2,
                        p_osha_category               in varchar2,
                        p_ada_category                in varchar2);

----------------------------------------------------------------------
-- del_sit
--
--       Deletes a record from PER_SPECIAL_INFO_TYPES
--       Calls delete_usages to also delete associated category usages
--
procedure del_sit (p_special_information_type_id in number);
--
--

----------------------------------------------------------------------
-- sit in use
--
-- checks if a special info types in a given category are in use
-- used in the check that a type can be reverted back to not being in a
-- category
--
----------------------------------------------------------------------
--
function sit_in_use (p_business_group_id in number,
                     p_id_flex_num in number,
                     p_category    in varchar2) return boolean;
--

END PER_SIT_PKG;

 

/
