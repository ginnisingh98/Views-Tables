--------------------------------------------------------
--  DDL for Package HR_GENERAL2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_GENERAL2" AUTHID CURRENT_USER AS
/* $Header: hrgenrl2.pkh 120.4.12010000.2 2008/08/06 06:29:41 ubhat ship $ */
/*
+==========================================================================+
|                       Copyright (c) 1994 Oracle Corporation              |
|                          Redwood Shores, California, USA                 |
|                               All rights reserved.                       |
+==========================================================================+
Name
        General2 HR Utilities
Purpose
        To provide widely used functions in a single shared area
        Other general purpose routines can be found in hr_utility and
        hr_chkfmt.

        See the package body for details of the functions.

Change History
stlocke  08-FEB-2001 115.00	Created.
ekim     20-JUN-2001 115.1      Added mask_characters function.
asahay   23-JUL-2001 115.2      Added is_person_type function.
wstallar 28-SEP-2001 115.3      Added functions to support duplicate
                                person checking.
wstallar 28-SEP-2001 115.4      Added funtion to derive full name
                                for display in duplicate person LoV
acowan   27-FEB-2002 115.6      Added functions to return
                                assignments status usages
dcasemor 19-MAR-2002 115.8      Added chk_utf8_col_length.
dcasemo  15-APR-2002 115.9      Removed chk_utf8_col_length.  This
                                now resides in a separate package
                                (hr_utf8_triggers).
acowan   16-MAY-2002 115.10     Added validate_upload procedure
                                for data checking entity uploads
skota    20-AUG-2002 115.11     GSCC changes
pkakar   15-OCT-2002 115.13     Added is_bg function for checking
 				the business_group_id is valid for
				a specific legislation_code
				(same as 115.12)
pkakar	 16-OCT-2002 115.15     Added is_legislation_install for
 				checking to see if a certain
				legislation has been installed
				(same as 115.14)
prsundar  28-NOV-2002 115.16    Added overloaded procedure for
       				fnd_initload
gperry    10-DEC-2002 115.17    Added nocopy compiler directives.
dharris   06-Jan-2003 115.18    Added the PUBLIC
                                function get_oracle_db_version
pattwood  17-JAN-2003 115.19    Bug 2651140. Added set_ovn procedure
                                for populating the
                                object_version_number column value
                                when this column has been added to
                                an existing table. Code originally
                                located in hrsetovn.sql
fsheikh  30-JAN-2003 115.20     Bug 2706637. Added 3 JP legislation
                                specific parameter to retieve full
                                name as per JP format.
divicker 07-APR-2003 115.21     Default 3 JP leg parameters above to
                                make file back compatible for forms
divicker 07-APR-2003 115.22     Change from default to overload.
                                Forms compile but error at runtime
ASahay   09-SEP-2003 115.23     Added function is_location_legal_adr
sgudiwad 25-SEP-2003 115.24 3136986 Added function decode_vendor
njaladi  30-dec-2003 115.25 3257115  Added overloaded function for
                               is_duplicate_person for jp legislation
dcasemor 01-Mar-2004 115.26     Bug 3346940.
                                Added supervisor_assignments_in_use.
sgelvi   31-May-2006 115.27     Added hrms_efc_column function
risgupta 27-NOV-2006 115.30     Added two overloaded function for is_duplicate_person
                                and also defined a global PL/SQL table to hold
                                duplicate records for the fix of enh duplicate person
                                #3988762

ktithy   17-APR-2008 115.31   6961892  Added new procedure
                                       SERVER_SIDE_PROFILE_PUT
				       which assigns a value to a profile
				       at Server Side.
----------------------------------------------------------------------------
*/

PROCEDURE init_fndload (p_resp_appl_id IN NUMBER);

PROCEDURE init_fndload(p_resp_appl_id IN NUMBER
		      ,p_user_id      IN NUMBER);

FUNCTION mask_characters(p_number IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION is_person_type(p_person_id 	IN NUMBER,
		  p_person_type		IN VARCHAR2,
		  p_effective_date 	IN DATE)
RETURN BOOLEAN;
--
-- --------------------------------------------------------------------------
-- |---------------< is_duplicate_person( Legislation Specific>--------------|
-- --------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This function checks for the person with same name or national identifier
--  exists in the system or not. if so then it returns true else false.
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_first_name                   Y    varchar2  First name of the person
--   p_last_name                    Y    varchar2  Last name of the person
--   p_national_identifier          Y    varchar2  National identifier of the
--                                                 person
--   p_date_of birth                Y    Date      Date of birth of the person.
--   p_leg_code                     Y    Varchar2  Legislation code of the
--                                                 Business group to which
--                                                 Person being created.
--   p_last_name_phonetic           Y    varchar2  Phonetic Last name of the
--                                                 person used for JP
--                                                 legislation.
--   p_first_name_phonetic           Y    varchar2 Phonetic first name of the
--                                                 person used for JP
--                                                 legislation.
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
-- Added for the fix of #3257115
FUNCTION is_duplicate_person(p_first_name IN VARCHAR2
                            ,p_last_name IN VARCHAR2
                            ,p_national_identifier IN VARCHAR2
                            ,p_date_of_birth IN DATE
                            ,p_leg_code IN VARCHAR2
                            ,p_first_name_phonetic IN VARCHAR2
                            ,p_last_name_phonetic IN VARCHAR2)
RETURN BOOLEAN;
-- Added for the fix of #3257115
FUNCTION is_duplicate_person(p_first_name IN VARCHAR2
                            ,p_last_name IN VARCHAR2
                            ,p_national_identifier IN VARCHAR2
                            ,p_date_of_birth IN DATE)
RETURN BOOLEAN;

-- START added for the fix of enh duplicate person #3988762

type party_id_rec is record
   (
     r_party_id      per_all_people_f.party_id%type
    ,r_person_id     per_all_people_f.person_id%type
    ,r_sec_status    varchar2(200)
    ,r_global_name   per_all_people_f.global_name%type
    ,r_BG_name       hr_all_organization_units.name%type
    ,r_location_code hr_locations_all.location_code%type
    ,r_org_name      hr_all_organization_units.name%type
    ,r_postal_code   per_addresses.postal_code%type
    ,r_national_identifier per_all_people_f.national_identifier%type
    ,r_bg_id         per_all_people_f.business_group_id%type
   );

type party_id_tbl is table of party_id_rec
index by binary_integer;

FUNCTION is_duplicate_person(p_first_name IN VARCHAR2
                            ,p_last_name IN VARCHAR2
                            ,p_national_identifier IN VARCHAR2
                            ,p_date_of_birth IN DATE
                            ,p_global_name IN VARCHAR2
                            ,p_dup_tbl OUT nocopy hr_general2.party_id_tbl)
RETURN BOOLEAN;

PROCEDURE is_duplicate_person(
                             p_business_group_id in per_all_people_f.business_group_id%TYPE
                            ,p_first_name IN VARCHAR2
                            ,p_last_name IN VARCHAR2
                            ,p_national_identifier IN VARCHAR2
                            ,p_date_of_birth IN DATE
                            ,p_per_information1 VARCHAR2 DEFAULT NULL
                            ,p_per_information2 VARCHAR2 DEFAULT NULL
                            ,p_per_information3 VARCHAR2 DEFAULT NULL
                            ,p_per_information4 VARCHAR2 DEFAULT NULL
                            ,p_per_information5 VARCHAR2 DEFAULT NULL
                            ,p_per_information6 VARCHAR2 DEFAULT NULL
                            ,p_per_information7 VARCHAR2 DEFAULT NULL
                            ,p_per_information8 VARCHAR2 DEFAULT NULL
                            ,p_per_information9 VARCHAR2 DEFAULT NULL
                            ,p_per_information10 VARCHAR2 DEFAULT NULL
                            ,p_per_information11 VARCHAR2 DEFAULT NULL
                            ,p_per_information12 VARCHAR2 DEFAULT NULL
                            ,p_per_information13 VARCHAR2 DEFAULT NULL
                            ,p_per_information14 VARCHAR2 DEFAULT NULL
                            ,p_per_information15 VARCHAR2 DEFAULT NULL
                            ,p_per_information16 VARCHAR2 DEFAULT NULL
                            ,p_per_information17 VARCHAR2 DEFAULT NULL
                            ,p_per_information18 VARCHAR2 DEFAULT NULL
                            ,p_per_information19 VARCHAR2 DEFAULT NULL
                            ,p_per_information20 VARCHAR2 DEFAULT NULL
                            ,p_per_information21 VARCHAR2 DEFAULT NULL
                            ,p_per_information22 VARCHAR2 DEFAULT NULL
                            ,p_per_information23 VARCHAR2 DEFAULT NULL
                            ,p_per_information24 VARCHAR2 DEFAULT NULL
                            ,p_per_information25 VARCHAR2 DEFAULT NULL
                            ,p_per_information26 VARCHAR2 DEFAULT NULL
                            ,p_per_information27 VARCHAR2 DEFAULT NULL
                            ,p_per_information28 VARCHAR2 DEFAULT NULL
                            ,p_per_information29 VARCHAR2 DEFAULT NULL
                            ,p_per_information30 VARCHAR2 DEFAULT NULL
                            ,p_duplicate_exists out nocopy integer
                            ,p_dup_clob OUT nocopy CLOB
                            );

-- END added for the fix of enh duplicate person #3988762

FUNCTION get_dup_external_name
RETURN VARCHAR2;

FUNCTION get_dup_no_match
RETURN VARCHAR2;

FUNCTION get_dup_no_security_char
RETURN VARCHAR2;

FUNCTION get_dup_security_status(p_party_id IN NUMBER
                                ,p_business_group_id IN NUMBER)
RETURN VARCHAR2;

FUNCTION get_dup_full_name(p_title IN VARCHAR2
                          ,p_first_name in VARCHAR2
                          ,p_middle_name in VARCHAR2
                          ,p_last_name  in VARCHAR2
                          ,p_suffix in VARCHAR2)
RETURN VARCHAR2;

FUNCTION get_dup_full_name(p_title IN VARCHAR2
                          ,p_first_name in VARCHAR2
                          ,p_middle_name in VARCHAR2
                          ,p_last_name  in VARCHAR2
                          ,p_suffix in VARCHAR2
                          ,p_leg_code in varchar2
                          ,p_jp_fname varchar2
                          ,p_jp_lname varchar2)
RETURN VARCHAR2;

-- --------------------------------------------------------------------------
-- |-------------------------< show_status_type >---------------------------|
-- --------------------------------------------------------------------------
-- using the four flags.
-- this procedure is called from (but not limited to)
-- Assignments folder form


function show_status_type(p_status IN Varchar2
                     ,p_show_emp_flag in varchar2
                     ,p_show_apl_flag in varchar2
                     ,p_show_cwk_flag in varchar2
                     ,p_show_current_flag in varchar2)
RETURN Boolean;

-- --------------------------------------------------------------------------
-- |-------------------< return_status_assignment_type >--------------------|
-- --------------------------------------------------------------------------
--
--
-- This procedure returns various flags describing the valid usage of
-- a given assignment status type
-- e.g. TERM_ASSIGN refers to a non current employee assignment
-- so p_past_flag will be 'Y' and p_emp_flag will be 'Y'

procedure return_status_assignment_type
                              (p_status   in varchar2
                              ,p_Current_flag out nocopy varchar2
                              ,p_past_flag out nocopy varchar2
                              ,p_cwk_flag out nocopy varchar2
                              ,p_emp_flag out nocopy varchar2
                              ,p_apl_flag out nocopy varchar2);

-- --------------------------------------------------------------------------
-- |-----------------------< return_status_types >--------------------------|
-- --------------------------------------------------------------------------
--
-- This function returns a list in the format ('ITEM1','ITEM2')
-- for use in the record group of assignment folder forms.
-- The items returned are those items from per_assignment_status_types
-- which  show_status_type would return true for.

function return_status_types(p_show_emp_flag in varchar2
                     ,p_show_apl_flag in varchar2
                     ,p_show_cwk_flag in varchar2
                     ,p_show_current_flag in varchar2)
return varchar2;

-- --------------------------------------------------------------------------
-- |----------------< return_assignment_type_text >-------------------------|
-- --------------------------------------------------------------------------
--
-- This function returns the applicable assignment types for a given status

function return_assignment_type_text(p_status in varchar2)
return varchar2;
--
--
function validate_upload (
p_Upload_mode           in varchar2,
p_Table_name            in varchar2,
p_new_row_updated_by    in varchar2,
p_new_row_update_date  in date,
p_Table_key_name        in varchar2,
p_table_key_value       in varchar2)
return boolean;

-- --------------------------------------------------------------------------
-- |----------------------< IS_BG FUNCTION >--------------------------------|
-- --------------------------------------------------------------------------

--
-- This function checks to see if the business_group_id given is a valid id
-- for the legislation code. If it is valid, then true is returned
--

FUNCTION is_bg(
p_business_group_id in number,
p_legislation_code in varchar2)
return boolean;

-- --------------------------------------------------------------------------
-- |---------------< IS_LEGISLATION_INTSALL FUNCTION >----------------------|
-- --------------------------------------------------------------------------

--
-- This function checks to see if the legislation_code given has been
-- installed on the application
--

FUNCTION is_legislation_install(
p_application_short_name in varchar2,
p_legislation_code in varchar2)
return boolean;

-- --------------------------------------------------------------------------
-- |-------------------< get_oracle_db_version >----------------------------|
-- --------------------------------------------------------------------------
-- This function returns the current (major) ORACLE version number in the
-- format x.x (where x is a number).
FUNCTION get_oracle_db_version RETURN NUMBER;
--
-- --------------------------------------------------------------------------
-- |---------------------------------< set_ovn >----------------------------|
-- --------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   When a non-mandatory OBJECT_VERSION_NUMBER column is added to an
--   existing table this procedure should be called to populate the column
--   value for existing rows.
--
--   It is not necessary to call this procedure when the
--   OBJECT_VERSION_NUMBER column has been included in a new table.
--
-- Prerequisites:
--   A non-mandatory OBJECT_VERSION_NUMBER column, NUMBER datatype has been
--   added to a HRMS product table which could already contain data.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_account_owner                Y    varchar2 Name of the database
--                                                account which owns the
--                                                database table.
--   p_table_name                   Y    varchar2 'ALL' or the name of
--                                                one database table in
--                                                the owning account.
--
-- Post Success:
--   Where the OBJECT_VERSION_NUMBER column is null then an initial value
--   will be populated.
--
-- Post Failure:
--   An Application or RDBMS error will be raised. If the table has an
--   _OVN database trigger this may be left in a disabled state.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure set_ovn
  (p_account_owner                 in     varchar2
  ,p_table_name                    in     varchar2
  );

-- --------------------------------------------------------------------------
-- |---------------< IS_LOCATION_LEGAL_ADR FUNCTION >----------------------|
-- --------------------------------------------------------------------------

--
-- This function checks to see if the location is a legal address
--
function is_location_legal_adr(p_location_id  in NUMBER)
return BOOLEAN;

-- newly added vendor_id attribute decode function and fix for Bug#3136986
-----------------------------------------------------------------------
function DECODE_VENDOR ( p_vendor_id   number) return varchar2 ;

-- --------------------------------------------------------------------------
-- |---------------< SUPERVISOR_ASSIGNMENTS_IN_USE >------------------------|
-- --------------------------------------------------------------------------

--
-- This function determines whether the current setup uses
-- supervisor assignments.
--
function supervisor_assignments_in_use
return VARCHAR2;
--
-- --------------------------------------------------------------------------
-- |---------------< HRMS_EFC_COLUMN >------------------------|
-- --------------------------------------------------------------------------
--
-- This function determines whether the column sent as parameter
-- is a candidate for EFC
--
function hrms_efc_column(p_table_name in VARCHAR2, p_column_name in VARCHAR2)
return VARCHAR2;
--


-- --------------------------------------------------------------------------
-- |----------------------< SERVER_SIDE_PROFILE_PUT >-----------------------|
-- --------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to assign a value to a profile at Server Side.
--
-- In Parameters:
--   Name                Reqd Type     Description
--   NAME                Y    varchar2 Profile Name
--                                     which needs to be assigned a value.
--
--   VAL                 Y    varchar2 Value for the Profile.
--
-- {End Of Comments}
--

procedure SERVER_SIDE_PROFILE_PUT(NAME in varchar2, VAL in varchar2);


END     Hr_General2;

/
