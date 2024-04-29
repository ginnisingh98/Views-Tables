--------------------------------------------------------
--  DDL for Package Body PER_CONTACT_RELATIONSHIPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CONTACT_RELATIONSHIPS_PKG" AS
/* $Header: pecon01t.pkb 120.8.12010000.3 2009/04/09 13:39:34 pchowdav ship $ */
/*---------------------------------------------------------------------------
--
 Change List
 -----------
--
 Name		Date	    Versn   Bug	    Text
 --------------+-----------+-------+-------+-------------------------------------------
 JRhodes        09-May-94   80.0            Created Initial Version
 JRhodes        25-Jan-95   70.4            Added ATTRIBUTE21-30 for people
					    Removed AOL WHO Columns
 JRhodes        05-Apr-95   70.5            Performance fix (273826)
 TMathers       05-Jul-95   70.6            Added BENEFICIARY_FLAG,BONDHOLDER_FLAG and
                                            THIRD_PARTY_PAY_FLAG + NATIONAL_IDENTIFIER.
 SSDesai        05-Aug-95   70.8            Added Dependent and Beneficiary to
			                    Delete_Validation.
 JAlloun        08-OCT-96   70.10   366749  Added contact_only foreign key ch was picking up minimum
					    effective_start_date from per_people_f to set
					    the contacts effective_start_date !!!. Fixed the
					    problem by setting the constacts
					    effective_start_date to be the session date.
13-FEB-97   FSHOJAAS  70.12        436371   Tow parameter were added to insert and update
			                    logic (X_suffix and X_PRE_NAME_ADJUNCT).
04-MAR-97   JAlloun   70.13                 Changed all occurances of system.dual to
                                            sys.dual for next release requirements.
18-JUL-97   RKAMIYAM  70.14                 Added per_information1 to 30 and know_as cols
11-Sep-97   IHARDING  110.1        505202   Insert value 'N' for all relationship flags
                                            into PER_CONTACT_RELATIONSHIPS for the
                                            mirror contact.
04-DEC-97   IHARDING  110.2        568596   Set p_comments to null when creating
                                            a mirror contact relationship row.
05-MAY-98   CCARTER   115.1                 Changes to the following procedures resulting
                                            from OAB changes: INSERT_ROW, LOCK_ROW,
                                            UPDATE_ROW. Dependent_Flag and
                                            Beneficiary_Flag left in, in case OAB
                                            is pulled from 11.5.
15-DEC-98   CCARTER   115.3                 Sequence_number parameter and validation
					    procedure added and called from
					    Insert_Contact and Update_Row
					    procedures for OAB.
16-FEB-99   ASahay    115.4        820655   Added and condition in delete_row
                                            to_check for multiple contacts
25-OCT-99   JzyLi     115.6        963097   Replace get_full_name with
                                            hr_person.derive_full_name
22-FEB-00   ASahay    115.7        1152185  Replace appid to 800 from 801 for
                                            message PER_6996_REL_CURR_EXISTS
08-MAR-00   ASahay    115.8        1160369  Added procedure Update_Contact

08-MAR-00   pzwalker  115.9        1239046  Added call to time_validation from
                                            Update_Contact
12-MAY-00   ASahay    115.10       1295442  Added and condition in delete_validation
								    to_check for multiple contacts
19-OCT-00   GPerry    115.11       1408379  Fixed WWBUG 1408379
                                            Added hook call to OAB so life event
                                            triggers work.
13-Mar-01   KSivagur  115.12                added parameter per_information_category.
20-Jun-01   GPerry    115.13       1833930  Fixed WWBUG 1833930.
                                            Changed Check_For_Duplicate_Person
                                            so that it uses exists and also
                                            so that it uses the BG index.
21-Aug-01   adhunter  115.14                PTU changes to inserting person records
22-Aug-01   adhunter  115.15                added PTU changes to Update_Contact
30-Sep-01   wstallar  115.16                added party_id support
03-Oct-01   wstallar  115.17                added party_id support on update
10-Oct-01   adhunter  115.19       1766066  added call points to maintain_coverage
                                            and DDF cols to all procedures.
                                            Re-did delete routine.
19-Oct-01   wstallar 115.21                 add support for TCA-mapped columns
24-Oct-01   adhunter 115.23       1931258   added ben_person_delete calls in delete_row
15-Nov-01   adhunter 115.24       2073795   added validation for X_Contact_Person_Id.
16-Nov-01   adhunter 115.25                 added dbdrv line
14-Feb-02   hnarayan 115.27       1772037   added code to pass dff attributes of per_contact_relationships
						table to ben_con_ler.ler_chk procedure
 Makiko Iwamoto 2002/03/05  115.28 2225930  Added procedure chk_dates to validate
                                            if new date_start is earlier than the
                                            effective_start_date of child contact extra
                                            information records and if new date_end is
                                            later than the effective_end_date of child
                                            contact extra information records before
                                            update.
                                            Modified procedure update_contact to handle
                                            date_of_death.
                                            Modified procedure delete_row to delete
                                            child records in per_contact_extra_info_f.
26-Jul-02  irgonzal  115.29    2483186      added hr_security_internal.populate_new_person
                                            call to ensure security list maintenance
                                            gets properly updated.
06-Sep-02  vramanai  115.30     2533935     modified the cursor defination of check_person_changed
                                            in update_contact procedure, to get the value of
                                            person_type_id from per_person_type_usages
16-Sep-02  vramanai  115.31     2533935     moddified the earlier fix as there was some
                                            problem with the fix.
05-Dec-02  pkakar    115.32                 added nocopy to parameters
10-Dec-02  mbocutt   115.33     2690302     Added code to INSERT_ROW routine
                                            to improve performance of duplicate
					    person checking(cursor
					    Check_For_Duplicate_Person)
					    by allowing CBO to pick the index on
					    LAST_NAME column.
07-Jan-03  vramanai 115.34      2618454     Added a hint in cursor Check_Person_Changed for
                                            better performance.
04-Apr-04 TPAPIRED  115.35      2881631     TCA Unmerge changes
                                            commented calls to create_tca_person
                                            now this proc is called in PTUmaintain
24-Oct-03 ttagawa   115.36      3207660     chk_dates call commented out.
19-DEC-03 smparame  115.37      3326964     New procedure chk_date_of_birth added to
                                            check whether date of birth is less than
                                            or equal to to relationship start date.
                                            Procedure update_contact modified. If
                                            condition to check whether the date of
                                            birth is less than relationship start
                                            date is added.
15-APR-04 smparame  115.38      3546390     Call to chk_date_of_birth is removed.
  									                 This validation is moved to front end.
21-JUN-04 adudekul  115.39      3648765     Performance issues. In proc update_row
                                            modified check_mirror_update.
19-jan-05 irgonzal  115.40      3889584     Added call to new routine to derive
                                            person names.
21-FEB-05 smparame  115.41      4197342     Procedure delete_row modified to check whether
                                            the person Irec candidate before deleting the
                                            person record.
08-APR-05 pchowdav  115.42      4281500     update_contact modified to update the
                                            relationship records date start when the
                                            contact date of birth is updated with a later
                                            date.
12-APR-05 abparekh  115.43      4295302     Called procedure ben_ppf_ler from Insert_Row
                                            and Update_Contact to trigger life event
                                            reasons for insert/update of PER_ALL_PEOPLE_F
                                            records for a Contact
13-APR-05 abparekh  115.44      4295302     Fixed GSCC Error
15-JUN-05 bshukla   115.45      4432200     Fixed GSCC Error
06-OCT-05 irgonzal  115.46                  Fixed GSCC error: GSCC Standard - File.Pkg.9
14-DEC-05 pchowdav  115.47      4867048     Modified cursors Check_Mirror_Update and
                                            Check_Mirror to use nvl statement.
16-MAR-06 pchowdav  115.48      4763755     Modified procedure Update_Contact .
27-SEP-06 asgugupt  115.49      5415267     Modified procedure Delete_Validation .
27-NOV-06 risgupta  115.50      3988762     commented the call to cursor Check_For_Duplicate_Person
                                            for duplicate check enhancement. This duplicate check is
                                            redundent and will be taken care on contact form.
03-APR-09 pchowdav  115.54      8395666     Modified the procedure update row to call
                                            Ben validation before updating the contact type.
======================================================================================*/
-----------------------------------------------
-- Local Procedure to return Mirror Contact Type
-----------------------------------------------
FUNCTION Get_Mirror_Contact_Type(p_contact_type VARCHAR2) RETURN VARCHAR2 IS
l_Contact_Type VARCHAR2(1);
BEGIN
   IF p_Contact_Type = 'C' THEN
       l_Contact_Type := 'P';
   ELSIF p_Contact_Type = 'P' THEN
       l_Contact_Type := 'C';
   ELSIF p_Contact_Type IN ('S','F') THEN
       l_Contact_Type := p_Contact_Type;
   ELSE
       l_Contact_Type := 'M';
   END IF;
   RETURN(l_Contact_Type);
END;
--
FUNCTION check_primary_contact(p_rowid VARCHAR2
                              ,p_person_id NUMBER
                              ,p_date_start DATE
                              ,p_date_end DATE
)  RETURN BOOLEAN IS
CURSOR c IS
SELECT 'Y'
FROM   per_contact_relationships
WHERE  person_id = p_person_id
AND    primary_contact_flag = 'Y'
AND NVL(date_start, Hr_General.start_of_time) <=
				      NVL(p_date_end,Hr_General.end_of_time)
AND NVL(date_end, Hr_General.end_of_time)  >=
				      NVL(p_date_start,Hr_General.start_of_time)
AND  ((ROWID <> CHARTOROWID(p_rowid)
   AND p_rowid IS NOT NULL)
   OR (p_rowid IS NULL)
);
--
l_exists VARCHAR2(1) := 'N';
--
BEGIN
   OPEN c;
   FETCH c INTO l_exists;
   CLOSE c;
--
   RETURN(l_exists = 'Y');
END check_primary_contact;
---------------------------------------------------------------------
-- Local procedure time validation
-- Check to ensure that only one relationship of the same type exists
-- between the same two people at the same time
---------------------------------------------------------------------
FUNCTION time_validation (p_contact_type VARCHAR2,
                          p_person_id NUMBER,
                          p_contact_person_id NUMBER,
                          p_contact_relationship_id NUMBER,
                          p_date_start DATE,
                          p_date_end DATE ) RETURN BOOLEAN IS
l_records VARCHAR2(1);
l_start_of_time DATE := Hr_General.start_of_time;
l_end_of_time DATE := Hr_General.end_of_time;
CURSOR c IS
SELECT 'X'
FROM per_contact_relationships per
WHERE per.person_id = p_person_id
AND per.contact_person_id = p_contact_person_id
AND (per.contact_relationship_id <> p_contact_relationship_id
     OR p_contact_relationship_id IS NULL)
AND per.contact_type = p_contact_type
AND NVL(p_date_start,l_start_of_time) <= NVL(date_end,l_end_of_time)
AND NVL(p_date_end,l_end_of_time) >= NVL(date_start,l_start_of_time);
--
BEGIN
  OPEN c;
  FETCH c INTO l_records;
  CLOSE c;

RETURN (l_records = 'X');
END time_validation;
---------------------------------------------------------------------
-- ---------------------------------------------------------------------------
-- |-------------------------------< chk_dates >-----------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Accepts contact_relationship_id, date_start, and date_end, and check if
--   neither child record with effective_start_date earlier than the given
--   date_start exists nor child records with effective_end_date later than
--   the given date_end in per_contact_extra_info_f.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                       Reqd    Type            Description
--   x_contact_relationship_id  Yes     NUMBER          Contact Relationship ID.
--   x_date_start               No      DATE            Start Date of the
--                                                      relationship.
--   x_date_end                 No      DATE            End Date of the
--                                                      relationship.
--
-- Out Parameters:
--   None.
--
-- Post Success:
--   The process succeeds.
--
-- Post Failure:
--   The process will be terminated.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
 PROCEDURE chk_dates(
  x_contact_relationship_id     IN      per_contact_relationships.contact_relationship_id%TYPE,
  x_date_start                  IN      per_contact_relationships.date_start%TYPE,
  x_date_end                    IN      per_contact_relationships.date_end%TYPE) IS
  --
  CURSOR cel_earlier_child_exists IS
   SELECT 1
   FROM per_contact_extra_info_f
   WHERE contact_relationship_id = x_contact_relationship_id
   AND effective_start_date < x_date_start;
  --
  CURSOR cel_later_child_exists IS
   SELECT 1
   FROM per_contact_extra_info_f
   WHERE contact_relationship_id = x_contact_relationship_id
   AND effective_end_date > x_date_end;
  --
  l_dummy       VARCHAR2(1);
 BEGIN

  -- = Start date validation is executed only when x_date_start is not null.
  IF x_date_start IS NOT NULL THEN
    OPEN cel_earlier_child_exists;
    FETCH cel_earlier_child_exists INTO l_dummy;

    -- == Raise error if child record with earlier effective_start_date than the
    -- == given date_start exists.
    IF cel_earlier_child_exists%FOUND THEN
      CLOSE cel_earlier_child_exists;
      --
      hr_utility.set_message(
       applid         => 800,
       l_message_name => 'PER_6549_INVALD_REL_START_DATE');
      --
      hr_utility.raise_error;
    END IF;
    -- ==

    CLOSE cel_earlier_child_exists;
  END IF;
  -- =

  -- = End date validation is executed only when x_date_end is not null.
  IF x_date_end IS NOT NULL THEN
    OPEN cel_later_child_exists;
    FETCH cel_later_child_exists INTO l_dummy;

    -- == Raise error if child record with later effective_end_date than the
    -- == given date_end exists.
    IF cel_later_child_exists%FOUND THEN
      CLOSE cel_later_child_exists;
      --
      hr_utility.set_message(
       applid         => 800,
       l_message_name => 'PER_50044_INVALID_REL_END_DATE');
      --
      hr_utility.raise_error;
    END IF;
    -- ==

    CLOSE cel_later_child_exists;
  END IF;
  -- =

 END chk_dates;
--
PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Party_Id                            NUMBER ,
                     X_Contact_Relationship_Id      IN OUT NOCOPY NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Person_Id                    IN OUT NOCOPY NUMBER,
                     X_Contact_Person_Id            IN OUT NOCOPY NUMBER,
                     X_Contact_Type                 IN OUT NOCOPY VARCHAR2,
                     X_Comments                            VARCHAR2,
                     X_Bondholder_Flag                     VARCHAR2,
                     X_Third_Party_Pay_Flag                VARCHAR2,
                     X_Primary_Contact_Flag                VARCHAR2,
                     X_Cont_Attribute_Category             VARCHAR2,
                     X_Cont_Attribute1                     VARCHAR2,
                     X_Cont_Attribute2                     VARCHAR2,
                     X_Cont_Attribute3                     VARCHAR2,
                     X_Cont_Attribute4                     VARCHAR2,
                     X_Cont_Attribute5                     VARCHAR2,
                     X_Cont_Attribute6                     VARCHAR2,
                     X_Cont_Attribute7                     VARCHAR2,
                     X_Cont_Attribute8                     VARCHAR2,
                     X_Cont_Attribute9                     VARCHAR2,
                     X_Cont_Attribute10                    VARCHAR2,
                     X_Cont_Attribute11                    VARCHAR2,
                     X_Cont_Attribute12                    VARCHAR2,
                     X_Cont_Attribute13                    VARCHAR2,
                     X_Cont_Attribute14                    VARCHAR2,
                     X_Cont_Attribute15                    VARCHAR2,
                     X_Cont_Attribute16                    VARCHAR2,
                     X_Cont_Attribute17                    VARCHAR2,
                     X_Cont_Attribute18                    VARCHAR2,
                     X_Cont_Attribute19                    VARCHAR2,
                     X_Cont_Attribute20                    VARCHAR2,
                     X_Cont_Information_Category             VARCHAR2,
                     X_Cont_Information1                     VARCHAR2,
                     X_Cont_Information2                     VARCHAR2,
                     X_Cont_Information3                     VARCHAR2,
                     X_Cont_Information4                     VARCHAR2,
                     X_Cont_Information5                     VARCHAR2,
                     X_Cont_Information6                     VARCHAR2,
                     X_Cont_Information7                     VARCHAR2,
                     X_Cont_Information8                     VARCHAR2,
                     X_Cont_Information9                     VARCHAR2,
                     X_Cont_Information10                    VARCHAR2,
                     X_Cont_Information11                    VARCHAR2,
                     X_Cont_Information12                    VARCHAR2,
                     X_Cont_Information13                    VARCHAR2,
                     X_Cont_Information14                    VARCHAR2,
                     X_Cont_Information15                    VARCHAR2,
                     X_Cont_Information16                    VARCHAR2,
                     X_Cont_Information17                    VARCHAR2,
                     X_Cont_Information18                    VARCHAR2,
                     X_Cont_Information19                    VARCHAR2,
                     X_Cont_Information20                    VARCHAR2,
                     X_Session_Date                        DATE,
                     X_Person_Type_Id                      NUMBER,
                     X_Last_Name                           VARCHAR2,
                     X_Comment_Id                          NUMBER,
                     X_Date_Of_Birth                       DATE,
                     X_First_Name                          VARCHAR2,
                     X_Middle_Names                        VARCHAR2,
                     X_Sex                                 VARCHAR2,
                     X_Title                               VARCHAR2,
		     X_PRE_NAME_ADJUNCT		   	   VARCHAR2,
		     X_SUFFIX				   VARCHAR2,
                     X_Title_Desc                          VARCHAR2,
                     X_national_identifier                 VARCHAR2,
                     X_Attribute_Category                  VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2,
                     X_Attribute16                         VARCHAR2,
                     X_Attribute17                         VARCHAR2,
                     X_Attribute18                         VARCHAR2,
                     X_Attribute19                         VARCHAR2,
                     X_Attribute20                         VARCHAR2,
                     X_Attribute21                         VARCHAR2,
                     X_Attribute22                         VARCHAR2,
                     X_Attribute23                         VARCHAR2,
                     X_Attribute24                         VARCHAR2,
                     X_Attribute25                         VARCHAR2,
                     X_Attribute26                         VARCHAR2,
                     X_Attribute27                         VARCHAR2,
                     X_Attribute28                         VARCHAR2,
                     X_Attribute29                         VARCHAR2,
                     X_Attribute30                         VARCHAR2,
                     X_Reentry_Flag                        IN OUT NOCOPY NUMBER,
                     X_Per_Information_Category            VARCHAR2,
                     X_Per_Information1                    VARCHAR2,
                     X_Per_Information2                    VARCHAR2,
                     X_Per_Information3                    VARCHAR2,
                     X_Per_Information4                    VARCHAR2,
                     X_Per_Information5                    VARCHAR2,
                     X_Per_Information6                    VARCHAR2,
                     X_Per_Information7                    VARCHAR2,
                     X_Per_Information8                    VARCHAR2,
                     X_Per_Information9                    VARCHAR2,
                     X_Per_Information10                   VARCHAR2,
                     X_Per_Information11                   VARCHAR2,
                     X_Per_Information12                   VARCHAR2,
                     X_Per_Information13                   VARCHAR2,
                     X_Per_Information14                   VARCHAR2,
                     X_Per_Information15                   VARCHAR2,
                     X_Per_Information16                   VARCHAR2,
                     X_Per_Information17                   VARCHAR2,
                     X_Per_Information18                   VARCHAR2,
                     X_Per_Information19                   VARCHAR2,
                     X_Per_Information20                   VARCHAR2,
                     X_Per_Information21                   VARCHAR2,
                     X_Per_Information22                   VARCHAR2,
                     X_Per_Information23                   VARCHAR2,
                     X_Per_Information24                   VARCHAR2,
                     X_Per_Information25                   VARCHAR2,
                     X_Per_Information26                   VARCHAR2,
                     X_Per_Information27                   VARCHAR2,
                     X_Per_Information28                   VARCHAR2,
                     X_Per_Information29                   VARCHAR2,
                     X_Per_Information30                   VARCHAR2,
                     X_Known_As                            VARCHAR2,
                     X_Date_Start                          DATE,
                     X_Start_Life_Reason_Id                VARCHAR2,
                     X_Date_End                            DATE,
                     X_End_Life_Reason_Id                  VARCHAR2,
                     X_Rltd_Per_Rsds_W_Dsgntr_Flag         VARCHAR2,
                     X_Personal_Flag                       VARCHAR2,
		     X_Sequence_Number                     NUMBER,
                     X_Create_Mirror_Flag                  VARCHAR2,
                     X_Mirror_Type                         VARCHAR2,
                     X_Dependent_Flag                      VARCHAR2,
                     X_Beneficiary_Flag                    VARCHAR2,
                     X_marital_status                      VARCHAR2 ,
                     X_nationality          		   VARCHAR2 ,
                     X_blood_type            		   VARCHAR2 ,
                     X_correspondence_language 		   VARCHAR2 ,
                     X_honors                 		   VARCHAR2 ,
                     X_rehire_authorizor      		   VARCHAR2 ,
                     X_rehire_recommendation  		   VARCHAR2 ,
                     X_resume_exists          		   VARCHAR2 ,
                     X_resume_last_updated    		   DATE ,
                     X_second_passport_exists 		   VARCHAR2 ,
                     X_student_status     		   VARCHAR2 ,
                     X_date_of_death      		   DATE ,
                     X_uses_tobacco_flag  		   VARCHAR2 ,
                     X_town_of_birth      		   VARCHAR2 ,
                     X_region_of_birth    		   VARCHAR2 ,
                     X_country_of_birth   		   VARCHAR2 ,
                     X_fast_path_employee 		   VARCHAR2 ,
                     X_email_address   			   VARCHAR2 ,
                     X_fte_capacity    			   VARCHAR2  ) IS

--
l_contact_type VARCHAR2(30);
l_person_id NUMBER;
l_contact_person_id NUMBER;
l_duplicate_exists VARCHAR2(1) := 'N';
l_object_version_number NUMBER;
--Local var flags for bug 505202 IJH.
l_Third_Party_Pay_Flag    VARCHAR2(1) := 'N';
l_Primary_Contact_Flag    VARCHAR2(1) := 'N';
l_rltd_per_rsds_w_dsgntr_flag VARCHAR2(1) := 'N';
l_personal_flag           VARCHAR2(1) := 'N';
l_dependent_flag          VARCHAR2(1) := 'N';
l_beneficiary_flag        VARCHAR2(1) := 'N';
l_sequence_number NUMBER;
--
l_first_char  VARCHAR2(5) := substr( x_last_name , 1 , 1 ) ;
l_second_char VARCHAR2(5) := substr( x_last_name , 2 , 1 ) ;
l_ul_check    VARCHAR2(15) := upper(l_first_char)||lower(l_second_char)||'%';
l_lu_check    VARCHAR2(15) := lower(l_first_char)||upper(l_second_char)||'%';
l_uu_check    VARCHAR2(15) := upper(l_first_char)||upper(l_second_char)||'%';
l_ll_check    VARCHAR2(15) := lower(l_first_char)||lower(l_second_char)||'%';

--
-- WWBUG 1833930.
-- Changed cursor to use the business group index and to use an exists
-- statement rather than the full table scan.
--
CURSOR Check_For_Duplicate_Person IS
SELECT 'Y'
FROM   sys.dual
WHERE  EXISTS (SELECT NULL
               FROM   per_all_people_f
               WHERE  UPPER(last_name) = UPPER(X_Last_Name)
               AND   (   last_name like l_ul_check
                      or last_name like l_lu_check
                      or last_name like l_uu_check
                      or last_name like l_ll_check)
               AND    (UPPER(first_name) = UPPER(X_first_name)
                      OR X_first_name IS NULL
                      OR first_name IS NULL)
               AND   (date_of_birth = X_date_of_birth
                      OR X_date_of_birth IS NULL
                      OR date_of_birth IS NULL)
               AND    business_group_id = X_business_group_id);
-- fix for bug 2073795
--
CURSOR csr_per_exists is
select 'Y'
from dual
where exists
(select 'Y'
from per_all_people_f
where person_id = X_Contact_Person_Id);
--
l_dummy varchar2(10);
--
------------------------------------------------------------
-- Local procedure to insert individual contact row
--
PROCEDURE Insert_Contact IS
   CURSOR C IS
    SELECT ROWID FROM PER_CONTACT_RELATIONSHIPS
    WHERE contact_relationship_id = X_Contact_Relationship_Id;
--
   CURSOR C2 IS
    SELECT per_contact_relationships_s.NEXTVAL FROM sys.dual;
  --
  -- Start of Fix for WWBUG 1408379
  --
  l_old ben_con_ler.g_con_ler_rec;
  l_new ben_con_ler.g_con_ler_rec;
  --
  -- End of Fix for WWBUG 1408379
  --
BEGIN
   IF (X_Contact_Relationship_Id IS NULL) THEN
     OPEN C2;
     FETCH C2 INTO X_Contact_Relationship_Id;
     CLOSE C2;
   END IF;
  IF X_contact_relationship_id IS NOT NULL THEN
  NULL;
  END IF;
--
-- Call to sequence number validation
--
  chk_sequence_number(p_contact_relationship_id => X_contact_relationship_id
				 ,p_sequence_number => X_sequence_number
				 ,p_contact_person_id => X_contact_person_id
				 ,p_person_id         => X_person_id
				 );
--
-- Check to ensure that only one relationship of the same type exists
-- between the same two people at the same time
--
  IF time_validation(p_contact_type => X_contact_type
                    ,p_person_id => X_person_id
                    ,p_contact_person_id => X_contact_person_id
                    ,p_contact_relationship_id => X_contact_relationship_id
                    ,p_date_start => X_date_start
                    ,p_date_end => X_date_end
) THEN
      hr_utility.set_message(800,'PER_6996_REL_CURR_EXISTS');
      hr_utility.raise_error;
  END IF;
--
  INSERT INTO PER_CONTACT_RELATIONSHIPS(
          contact_relationship_id,
          business_group_id,
          person_id,
          contact_person_id,
          contact_type,
          comments,
          Bondholder_Flag,
          Third_Party_Pay_Flag,
          primary_contact_flag,
          cont_attribute_category,
          cont_attribute1,
          cont_attribute2,
          cont_attribute3,
          cont_attribute4,
          cont_attribute5,
          cont_attribute6,
          cont_attribute7,
          cont_attribute8,
          cont_attribute9,
          cont_attribute10,
          cont_attribute11,
          cont_attribute12,
          cont_attribute13,
          cont_attribute14,
          cont_attribute15,
          cont_attribute16,
          cont_attribute17,
          cont_attribute18,
          cont_attribute19,
          cont_attribute20,
          cont_information_category,
          cont_information1,
          cont_information2,
          cont_information3,
          cont_information4,
          cont_information5,
          cont_information6,
          cont_information7,
          cont_information8,
          cont_information9,
          cont_information10,
          cont_information11,
          cont_information12,
          cont_information13,
          cont_information14,
          cont_information15,
          cont_information16,
          cont_information17,
          cont_information18,
          cont_information19,
          cont_information20,
         date_start,
          start_life_reason_id,
          date_end,
          end_life_reason_id,
          rltd_per_rsds_w_dsgntr_flag,
          personal_flag,
	  sequence_number,
          dependent_flag,
          beneficiary_flag

        ) VALUES (
          X_Contact_Relationship_Id,
          X_Business_Group_Id,
          X_Person_Id,
          X_Contact_Person_Id,
          X_Contact_Type,
          X_Comments,
          X_Bondholder_Flag,
          l_Third_Party_Pay_Flag,
          l_Primary_Contact_Flag,
          X_Cont_Attribute_Category,
          X_Cont_Attribute1,
          X_Cont_Attribute2,
          X_Cont_Attribute3,
          X_Cont_Attribute4,
          X_Cont_Attribute5,
          X_Cont_Attribute6,
          X_Cont_Attribute7,
          X_Cont_Attribute8,
          X_Cont_Attribute9,
          X_Cont_Attribute10,
          X_Cont_Attribute11,
          X_Cont_Attribute12,
          X_Cont_Attribute13,
          X_Cont_Attribute14,
          X_Cont_Attribute15,
          X_Cont_Attribute16,
          X_Cont_Attribute17,
          X_Cont_Attribute18,
          X_Cont_Attribute19,
          X_Cont_Attribute20,
          X_Cont_Information_Category,
          X_Cont_Information1,
          X_Cont_Information2,
          X_Cont_Information3,
          X_Cont_Information4,
          X_Cont_Information5,
          X_Cont_Information6,
          X_Cont_Information7,
          X_Cont_Information8,
          X_Cont_Information9,
          X_Cont_Information10,
          X_Cont_Information11,
          X_Cont_Information12,
          X_Cont_Information13,
          X_Cont_Information14,
          X_Cont_Information15,
          X_Cont_Information16,
          X_Cont_Information17,
          X_Cont_Information18,
          X_Cont_Information19,
          X_Cont_Information20,
          X_Date_Start,
          X_Start_Life_Reason_Id,
          X_Date_End,
          X_End_Life_Reason_Id,
          l_Rltd_Per_Rsds_W_Dsgntr_Flag,
          X_personal_flag,
	  l_sequence_number,
          X_dependent_flag,
          X_beneficiary_flag
  );
--
  --
  -- Start of Fix for 1408379
  --
  l_new.person_id := x_person_id;
  l_new.contact_person_id := x_contact_person_id;
  l_new.business_group_id := x_business_group_id;
  l_new.date_start := x_date_start;
  l_new.date_end := x_date_end;
  l_new.contact_type := x_contact_type;
  l_new.personal_flag := x_personal_flag;
  l_new.start_life_reason_id := x_start_life_reason_id;
  l_new.end_life_reason_id := x_end_life_reason_id;
  l_new.rltd_per_rsds_w_dsgntr_flag := l_rltd_per_rsds_w_dsgntr_flag;
  l_new.contact_relationship_id := x_contact_relationship_id;
  --
  -- Bug 1772037 fix
  --
  l_new.cont_attribute1  := x_cont_attribute1  ;
  l_new.cont_attribute2  := x_cont_attribute2  ;
  l_new.cont_attribute3  := x_cont_attribute3  ;
  l_new.cont_attribute4  := x_cont_attribute4  ;
  l_new.cont_attribute5  := x_cont_attribute5  ;
  l_new.cont_attribute6  := x_cont_attribute6  ;
  l_new.cont_attribute7  := x_cont_attribute7  ;
  l_new.cont_attribute8  := x_cont_attribute8  ;
  l_new.cont_attribute9  := x_cont_attribute9  ;
  l_new.cont_attribute10 := x_cont_attribute10 ;
  l_new.cont_attribute11 := x_cont_attribute11 ;
  l_new.cont_attribute12 := x_cont_attribute12 ;
  l_new.cont_attribute13 := x_cont_attribute13 ;
  l_new.cont_attribute14 := x_cont_attribute14 ;
  l_new.cont_attribute15 := x_cont_attribute15 ;
  l_new.cont_attribute16 := x_cont_attribute16 ;
  l_new.cont_attribute17 := x_cont_attribute17 ;
  l_new.cont_attribute18 := x_cont_attribute18 ;
  l_new.cont_attribute19 := x_cont_attribute19 ;
  l_new.cont_attribute20 := x_cont_attribute20 ;
  --
  -- End fix 1772037
  --
  ben_con_ler.ler_chk(p_old            => l_old,
                      p_new            => l_new,
                      p_effective_date => NVL(x_date_start,SYSDATE));
  --
  -- End of Fix for 1408379
  --
  hr_utility.set_location('Insert_contact',1);
  OPEN C;
  FETCH C INTO X_Rowid;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE C;
END Insert_Contact;
------------------------------------------------------------
-- Local procedure to insert individual person row
--

FUNCTION Insert_Person RETURN NUMBER IS
--
   l_person per_all_people_f%ROWTYPE;
--
   l_person_id       NUMBER;
   l_person_type_id  NUMBER;
   l_rowid           VARCHAR2(30);
   l_full_name       VARCHAR2(240);
   l_order_name      varchar2(240);
   l_global_name     varchar2(240);
   l_local_name      varchar2(240);

   l_effective_start_date DATE;
   l_effective_end_date DATE;
   l_start_date DATE;
   l_dup_name VARCHAR2(1);
--
CURSOR C IS
SELECT ROWID
FROM   per_people_f
WHERE  person_id = X_Person_Id;
--
CURSOR C2 IS
SELECT per_people_s.NEXTVAL
FROM sys.dual;
--
CURSOR c_person IS
  SELECT *
  FROM   per_all_people_f
  WHERE  person_id = l_person_id
  AND    l_effective_start_date
         BETWEEN effective_start_date
         AND     effective_end_date;
--
-- Bug 4295302
--
l_ppf_ler_new_rec   ben_ppf_ler.g_ppf_ler_rec;
l_ppf_ler_old_rec   ben_ppf_ler.g_ppf_ler_rec;
--
BEGIN
--
   --hr_person.derive_full_name (x_first_name, x_middle_names,
   --  x_last_name, x_known_as, x_title, x_suffix, x_pre_name_adjunct,
   --  x_date_of_birth, NULL, x_business_group_id, l_full_name,
   --  l_dup_name);
      hr_person_name.derive_person_names
      (p_format_name        =>  NULL, -- generate all names
       p_business_group_id  =>  x_business_group_id,
       p_person_id          =>  NULL,
       p_first_name         =>  x_first_name,
       p_middle_names       =>  x_middle_names,
       p_last_name          =>  x_last_name,
       p_known_as           =>  x_known_as,
       p_title              =>  x_title,
       p_suffix             =>  x_suffix,
       p_pre_name_adjunct   =>  x_pre_name_adjunct,
       p_date_of_birth      =>  x_date_of_birth,
       p_previous_last_name =>  NULL,
       p_email_address      =>  x_email_address  ,
       p_employee_number    =>  NULL,
       p_applicant_number   =>  NULL,
       p_npw_number         =>  NULL,
       p_per_information1   =>  x_per_information1  ,
       p_per_information2   =>  x_per_information2  ,
       p_per_information3   =>  x_per_information3  ,
       p_per_information4   =>  x_per_information4  ,
       p_per_information5   =>  x_per_information5  ,
       p_per_information6   =>  x_per_information6  ,
       p_per_information7   =>  x_per_information7  ,
       p_per_information8   =>  x_per_information8  ,
       p_per_information9   =>  x_per_information9  ,
       p_per_information10  =>  x_per_information10  ,
       p_per_information11  =>  x_per_information11  ,
       p_per_information12  =>  x_per_information12  ,
       p_per_information13  =>  x_per_information13  ,
       p_per_information14  =>  x_per_information14  ,
       p_per_information15  =>  x_per_information15  ,
       p_per_information16  =>  x_per_information16  ,
       p_per_information17  =>  x_per_information17  ,
       p_per_information18  =>  x_per_information18  ,
       p_per_information19  =>  x_per_information19  ,
       p_per_information20  =>  x_per_information20  ,
       p_per_information21  =>  x_per_information21  ,
       p_per_information22  =>  x_per_information22  ,
       p_per_information23  =>  x_per_information23  ,
       p_per_information24  =>  x_per_information24  ,
       p_per_information25  =>  x_per_information25  ,
       p_per_information26  =>  x_per_information26  ,
       p_per_information27  =>  x_per_information27  ,
       p_per_information28  =>  x_per_information28  ,
       p_per_information29  =>  x_per_information29  ,
       p_per_information30  =>  x_per_information30  ,
       p_attribute1         =>  x_attribute1  ,
       p_attribute2         =>  x_attribute2  ,
       p_attribute3         =>  x_attribute3  ,
       p_attribute4         =>  x_attribute4  ,
       p_attribute5         =>  x_attribute5  ,
       p_attribute6         =>  x_attribute6  ,
       p_attribute7         =>  x_attribute7  ,
       p_attribute8         =>  x_attribute8  ,
       p_attribute9         =>  x_attribute9  ,
       p_attribute10        =>  x_attribute10  ,
       p_attribute11        =>  x_attribute11  ,
       p_attribute12        =>  x_attribute12  ,
       p_attribute13        =>  x_attribute13  ,
       p_attribute14        =>  x_attribute14  ,
       p_attribute15        =>  x_attribute15  ,
       p_attribute16        =>  x_attribute16  ,
       p_attribute17        =>  x_attribute17  ,
       p_attribute18        =>  x_attribute18  ,
       p_attribute19        =>  x_attribute19  ,
       p_attribute20        =>  x_attribute20  ,
       p_attribute21        =>  x_attribute21  ,
       p_attribute22        =>  x_attribute22  ,
       p_attribute23        =>  x_attribute23,
       p_attribute24        =>  x_attribute24,
       p_attribute25        =>  x_attribute25,
       p_attribute26        =>  x_attribute26,
       p_attribute27        =>  x_attribute27,
       p_attribute28        =>  x_attribute28,
       p_attribute29        =>  x_attribute29,
       p_attribute30        =>  x_attribute30,
       p_full_name          => l_full_name,
       p_order_name         => l_order_name,
       p_global_name        => l_global_name,
       p_local_name         => l_local_name,
       p_duplicate_flag     => l_dup_name
       );
   --
   l_effective_end_date 	:= Hr_General.end_of_time;
   l_effective_start_date 	:= x_session_date;
   l_start_date 		:= x_session_date;
   --
   OPEN C2;
   FETCH C2 INTO l_person_id;
   CLOSE C2;
   --
   -- Verify party id, if one is passed in
   IF x_party_id IS NOT NULL THEN
     --
     per_per_bus.chk_party_id
       (p_person_id             => l_person_id
       ,p_party_id              => x_party_id
       ,p_effective_date        => l_effective_start_date
       ,p_object_version_number => NULL);
   END IF;

   INSERT INTO PER_PEOPLE_F(
          person_id,
          effective_start_date,
          effective_end_date,
          business_group_id,
          person_type_id,
          last_name,
          start_date,
          comment_id,
          current_applicant_flag,
          current_emp_or_apl_flag,
          current_employee_flag,
          date_of_birth,
          first_name,
          full_name,
          middle_names,
          sex,
          title,
	       pre_name_adjunct,
	       suffix,
          national_identifier,
          attribute_category,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          attribute16,
          attribute17,
          attribute18,
          attribute19,
          attribute20,
          attribute21,
          attribute22,
          attribute23,
          attribute24,
          attribute25,
          attribute26,
          attribute27,
          attribute28,
          attribute29,
          attribute30,
          Per_Information_category,
          Per_Information1,
          Per_Information2,
          Per_Information3,
          Per_Information4,
          Per_Information5,
          Per_Information6,
          Per_Information7,
          Per_Information8,
          Per_Information9,
          Per_Information10,
          Per_Information11,
          Per_Information12,
          Per_Information13,
          Per_Information14,
          Per_Information15,
          Per_Information16,
          Per_Information17,
          Per_Information18,
          Per_Information19,
          Per_Information20,
          Per_Information21,
          Per_Information22,
          Per_Information23,
          Per_Information24,
          Per_Information25,
          Per_Information26,
          Per_Information27,
          Per_Information28,
          Per_Information29,
          Per_Information30,
          Known_As,
	       Party_Id,
          marital_status,
          nationality,
          blood_type,
          correspondence_language,
          honors,
          rehire_authorizor,
          rehire_recommendation,
          resume_exists,
          resume_last_updated,
          second_passport_exists,
          student_status,
          date_of_death,
          uses_tobacco_flag,
          town_of_birth,
          region_of_birth,
          country_of_birth,
          fast_path_employee,
          email_address,
          fte_capacity,
          global_name,    -- #3889584
          local_name,
          order_name
         ) VALUES (
          l_person_id,
          l_effective_start_date,
          l_effective_end_date,
          X_Business_Group_Id,
          hr_person_type_usage_info.get_default_person_type_id(X_Person_Type_Id),
--          X_Person_Type_Id,
          X_Last_Name,
          l_start_date,
          X_Comment_Id,
          NULL,
          NULL,
          NULL,
          X_Date_Of_Birth,
          X_First_Name,
          l_full_name,
          X_Middle_Names,
          X_Sex,
          X_Title,
          X_PRE_NAME_ADJUNCT,
	       X_SUFFIX,
          X_National_Identifier,
          X_Attribute_Category,
          X_Attribute1,
          X_Attribute2,
          X_Attribute3,
          X_Attribute4,
          X_Attribute5,
          X_Attribute6,
          X_Attribute7,
          X_Attribute8,
          X_Attribute9,
          X_Attribute10,
          X_Attribute11,
          X_Attribute12,
          X_Attribute13,
          X_Attribute14,
          X_Attribute15,
          X_Attribute16,
          X_Attribute17,
          X_Attribute18,
          X_Attribute19,
          X_Attribute20,
          X_Attribute21,
          X_Attribute22,
          X_Attribute23,
          X_Attribute24,
          X_Attribute25,
          X_Attribute26,
          X_Attribute27,
          X_Attribute28,
          X_Attribute29,
          X_Attribute30,
          X_Per_Information_category,
          X_Per_Information1,
          X_Per_Information2,
          X_Per_Information3,
          X_Per_Information4,
          X_Per_Information5,
          X_Per_Information6,
          X_Per_Information7,
          X_Per_Information8,
          X_Per_Information9,
          X_Per_Information10,
          X_Per_Information11,
          X_Per_Information12,
          X_Per_Information13,
          X_Per_Information14,
          X_Per_Information15,
          X_Per_Information16,
          X_Per_Information17,
          X_Per_Information18,
          X_Per_Information19,
          X_Per_Information20,
          X_Per_Information21,
          X_Per_Information22,
          X_Per_Information23,
          X_Per_Information24,
          X_Per_Information25,
          X_Per_Information26,
          X_Per_Information27,
          X_Per_Information28,
          X_Per_Information29,
          X_Per_Information30,
          X_Known_As,
	       X_Party_Id,
          X_marital_status,
          X_nationality,
          X_blood_type,
          X_correspondence_language,
          X_honors,
          X_rehire_authorizor,
          X_rehire_recommendation,
          X_resume_exists,
          X_resume_last_updated,
          X_second_passport_exists,
          X_student_status,
          X_date_of_death,
          X_uses_tobacco_flag,
          X_town_of_birth,
          X_region_of_birth,
          X_country_of_birth,
          X_fast_path_employee,
          X_email_address,
          X_fte_capacity,
          l_global_name,  -- #3889584
          l_local_name,
          l_order_name
  );
--2483186: now we are securing by contacts,
-- the security list maintenance must be done for all
-- inserts (note CWK are done in their own API anyway, not here)
--

   hr_utility.set_location('pecon01t.insert_row',70);
   --
   -- Bug 4295302
   --
   l_ppf_ler_new_rec.business_group_id		:= x_business_group_id;
   l_ppf_ler_new_rec.person_id			:= l_person_id;
   l_ppf_ler_new_rec.effective_start_date	:= l_effective_start_date;
   l_ppf_ler_new_rec.effective_end_date          := l_effective_end_date;
   l_ppf_ler_new_rec.date_of_birth               := x_date_of_birth;
   l_ppf_ler_new_rec.date_of_death               := x_date_of_death;
   l_ppf_ler_new_rec.marital_status              := x_marital_status;
   l_ppf_ler_new_rec.sex                         := x_sex;
   l_ppf_ler_new_rec.student_status              := x_student_status;
   l_ppf_ler_new_rec.uses_tobacco_flag           := x_uses_tobacco_flag;
   /*
   l_ppf_ler_new_rec.benefit_group_id            := l_ppf_ler_old_rec.benefit_group_id;
   l_ppf_ler_new_rec.DPDNT_VLNTRY_SVCE_FLAG      := l_ppf_ler_old_rec.dpdnt_vlntry_svce_flag;
   l_ppf_ler_new_rec.RECEIPT_OF_DEATH_CERT_DATE  := l_ppf_ler_old_rec.receipt_of_death_cert_date;
   l_ppf_ler_new_rec.on_military_service         := l_ppf_ler_old_rec.on_military_service;
   l_ppf_ler_new_rec.registered_disabled_flag    := l_ppf_ler_old_rec.registered_disabled_flag;
   l_ppf_ler_new_rec.coord_ben_med_pln_no        := l_ppf_ler_old_rec.coord_ben_med_pln_no;
   l_ppf_ler_new_rec.coord_ben_no_cvg_flag       := l_ppf_ler_old_rec.coord_ben_no_cvg_flag;
   */
   l_ppf_ler_new_rec.per_information10           := x_per_information10;
   l_ppf_ler_new_rec.attribute1                  := x_attribute1;
   l_ppf_ler_new_rec.attribute2                  := x_attribute2;
   l_ppf_ler_new_rec.attribute3                  := x_attribute3;
   l_ppf_ler_new_rec.attribute4                  := x_attribute4;
   l_ppf_ler_new_rec.attribute5                  := x_attribute5;
   l_ppf_ler_new_rec.attribute6                  := x_attribute6;
   l_ppf_ler_new_rec.attribute7                  := x_attribute7;
   l_ppf_ler_new_rec.attribute8                  := x_attribute8;
   l_ppf_ler_new_rec.attribute9                  := x_attribute9;
   l_ppf_ler_new_rec.attribute10                 := x_attribute10;
   l_ppf_ler_new_rec.attribute11                 := x_attribute11;
   l_ppf_ler_new_rec.attribute12                 := x_attribute12;
   l_ppf_ler_new_rec.attribute13                 := x_attribute13;
   l_ppf_ler_new_rec.attribute14                 := x_attribute14;
   l_ppf_ler_new_rec.attribute15                 := x_attribute15;
   l_ppf_ler_new_rec.attribute16                 := x_attribute16;
   l_ppf_ler_new_rec.attribute17                 := x_attribute17;
   l_ppf_ler_new_rec.attribute18                 := x_attribute18;
   l_ppf_ler_new_rec.attribute19                 := x_attribute19;
   l_ppf_ler_new_rec.attribute20                 := x_attribute20;
   l_ppf_ler_new_rec.attribute21                 := x_attribute21;
   l_ppf_ler_new_rec.attribute22                 := x_attribute22;
   l_ppf_ler_new_rec.attribute23                 := x_attribute23;
   l_ppf_ler_new_rec.attribute24                 := x_attribute24;
   l_ppf_ler_new_rec.attribute25                 := x_attribute25;
   l_ppf_ler_new_rec.attribute26                 := x_attribute26;
   l_ppf_ler_new_rec.attribute27                 := x_attribute27;
   l_ppf_ler_new_rec.attribute28                 := x_attribute28;
   l_ppf_ler_new_rec.attribute29                 := x_attribute29;
   l_ppf_ler_new_rec.attribute30                 := x_attribute30;
   --
   -- This procedure is will create potential life event reasons if the Person Change
   -- criteria is met (a part of Oracle Advanced Benefits functionality)
   --
   ben_ppf_ler.ler_chk( p_old            => l_ppf_ler_old_rec
                       ,p_new            => l_ppf_ler_new_rec
                       ,p_effective_date => x_session_date );

   --

   --
   -- Bug 4295302
   --

   --
   hr_security_internal.populate_new_person
   (p_business_group_id=>x_business_group_id
   ,p_person_id        =>l_person_id);
   --
   hr_utility.set_location('pecon01t.insert_row',75);
--
--
   /* BEGIN OF PARTY_ID WORK */
  /* This is being commented out as part of TCA party unmerge. This part of the code
   is being called from per_person_type_usage_internal.maintain_person_type_usage
  -- tpapired
  --
  OPEN c_person;
    --
    FETCH c_person INTO l_person;
    --
  CLOSE c_person;
  --
  per_hrtca_merge.create_tca_person(p_rec => l_person);
  --
  hr_utility.set_location('UPDATING party id',10);
  --
  -- Now assign the resulting party id back to the record.
  --
  IF x_party_id IS NULL THEN
    UPDATE per_people_f
       SET party_id = l_person.party_id
     WHERE person_id = l_person_id;
  END IF;
  --
  */
  /* END OF PARTY ID WORK */
hr_utility.set_location('Insert_person',2);
  OPEN C;
  FETCH C INTO l_Rowid;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE C;
--
-- added for PTU
--
    IF X_Person_Type_Id IS NOT NULL AND X_Person_Type_Id <> hr_api.g_number THEN
      BEGIN
        SELECT   person_type_id INTO l_person_type_id
        FROM     per_person_types
        WHERE    person_type_id = X_Person_Type_Id
        AND      business_group_id = X_Business_Group_Id
        AND      active_flag = 'Y'
        AND      system_person_type = 'OTHER';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          hr_utility.set_message(801, 'HR_7513_PER_TYPE_INVALID');
          hr_utility.raise_error;
      END;
      l_person_type_id := X_Person_Type_Id;
    ELSE
      l_person_type_id :=  hr_person_type_usage_info.get_default_person_type_id
                         (X_Business_Group_Id,
                          'OTHER');
    END IF;
    --
hr_per_type_usage_internal.maintain_person_type_usage
(p_effective_date       => x_session_date
,p_person_id            => l_person_id
,p_person_type_id       => l_person_type_id
);
--
-- end of PTU changes
--
  RETURN(l_person_id);
END Insert_Person;

----------------------------------------------
-- Main procedure
--
BEGIN
-- Check to ensure that there is only one primary contact for the person
--
   IF X_Primary_Contact_Flag = 'Y' AND
     check_primary_contact(p_rowid => X_Rowid
                          ,p_person_id => X_Person_Id
                          ,p_date_start => X_date_start
                          ,p_date_end => X_date_end
) THEN
      hr_utility.set_message(801,'PER_7125_EMP_CON_PRIMARY');
      hr_utility.raise_error;
   END IF;
--
-- 2073795: added validation for X_Contact_Person_Id. If the form has previously failed a multi
-- record insert, it still passes id values and person is not created. This is a problem.
--
  if X_Contact_Person_Id is not null then
    open csr_per_exists;
    fetch csr_per_exists into l_dummy;
    if csr_per_exists%notfound then
      X_Contact_Person_Id := null;
    else
      null;
    end if;
    close csr_per_exists;
  end if;
--
-- If the Contact Person is null then this is a new person and a row must
-- be created in PER_PEOPLE_F
--
   IF X_Contact_Person_Id IS NULL THEN
   -- Need re-entrant code to be able to warn user that a potentially duplicate
   -- person may be created
   --
     -- START commented by risgupta for duplicate check enhancement bug 3988762
     -- This duplicate check will be taken care on contact form
     /*IF X_Reentry_Flag = 1 THEN

         OPEN Check_For_Duplicate_Person;
         FETCH Check_For_Duplicate_Person INTO l_duplicate_exists;
         CLOSE Check_For_Duplicate_Person;
         IF l_duplicate_exists = 'Y' THEN
            X_Reentry_Flag := 2;
            RETURN;
         END IF;
      END IF;*/
      -- END 3988762

      X_Contact_Person_Id := Insert_Person;
   END IF;
--
-- Prepare variables prior to creating Contact Relationship and its mirror
--
   l_contact_type := X_Contact_Type;
   l_person_id := X_Person_Id;
   l_contact_person_id := X_Contact_Person_Id;
hr_utility.set_location('X_cont_type : '||X_Contact_Type,10);
hr_utility.set_location('X_Mirr_type : '||X_Mirror_Type,20);
hr_utility.set_location('X_Cont_per_id : '||TO_CHAR(X_Contact_Person_Id),30);

--
-- Insert the Mirror Relationship
--
  IF  X_Create_Mirror_Flag = 'Y' THEN
   X_Contact_Type := X_Mirror_Type;
--
   X_Person_Id := l_contact_person_id;
   X_Contact_Person_Id := l_person_id;
   l_Third_Party_Pay_Flag     := 'N';
   l_Primary_Contact_Flag     := 'N';
   l_dependent_flag           := 'N';
   l_beneficiary_flag         := 'N';
   l_Rltd_Per_Rsds_W_Dsgntr_Flag := X_Rltd_Per_Rsds_W_Dsgntr_Flag;
   l_personal_flag            := X_personal_flag;
   l_sequence_number          := NULL;
   --
   Insert_Contact;
  END IF;
--
-- Insert the Real Relationship
--
   X_Contact_Type := l_contact_type;
   X_Person_Id := l_person_id;
   X_Contact_Person_Id := l_contact_person_id;
   X_Rowid := '';
   X_Contact_Relationship_Id := '';
   l_Third_Party_Pay_Flag := X_Third_Party_Pay_Flag;
   l_Primary_Contact_Flag := X_Primary_Contact_Flag;
   l_Rltd_Per_Rsds_W_Dsgntr_Flag := X_Rltd_Per_Rsds_W_Dsgntr_Flag;
   l_personal_flag       := X_personal_flag;
   l_sequence_number     := X_sequence_number;
--
   Insert_Contact;
  --
  -- 1766066: added call for contact start date enh.
  --
  per_people12_pkg.maintain_coverage(p_person_id      => X_Contact_Person_Id
                                    ,p_type           => 'CONT'
                                    );
  -- 1766066 end.
END Insert_Row;

PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Contact_Relationship_Id               NUMBER,
                   X_Business_Group_Id                     NUMBER,
                   X_Person_Id                             NUMBER,
                   X_Contact_Person_Id                     NUMBER,
                   X_Contact_Type                          VARCHAR2,
                   X_Comments                              VARCHAR2,
                   X_Bondholder_Flag                       VARCHAR2,
                   X_Third_Party_Pay_Flag                  VARCHAR2,
                   X_Primary_Contact_Flag                  VARCHAR2,
                   X_Cont_Attribute_Category               VARCHAR2,
                   X_Cont_Attribute1                       VARCHAR2,
                   X_Cont_Attribute2                       VARCHAR2,
                   X_Cont_Attribute3                       VARCHAR2,
                   X_Cont_Attribute4                       VARCHAR2,
                   X_Cont_Attribute5                       VARCHAR2,
                   X_Cont_Attribute6                       VARCHAR2,
                   X_Cont_Attribute7                       VARCHAR2,
                   X_Cont_Attribute8                       VARCHAR2,
                   X_Cont_Attribute9                       VARCHAR2,
                   X_Cont_Attribute10                      VARCHAR2,
                   X_Cont_Attribute11                      VARCHAR2,
                   X_Cont_Attribute12                      VARCHAR2,
                   X_Cont_Attribute13                      VARCHAR2,
                   X_Cont_Attribute14                      VARCHAR2,
                   X_Cont_Attribute15                      VARCHAR2,
                   X_Cont_Attribute16                      VARCHAR2,
                   X_Cont_Attribute17                      VARCHAR2,
                   X_Cont_Attribute18                      VARCHAR2,
                   X_Cont_Attribute19                      VARCHAR2,
                   X_Cont_Attribute20                      VARCHAR2,
                   X_Cont_Information_Category               VARCHAR2,
                   X_Cont_Information1                       VARCHAR2,
                   X_Cont_Information2                       VARCHAR2,
                   X_Cont_Information3                       VARCHAR2,
                   X_Cont_Information4                       VARCHAR2,
                   X_Cont_Information5                       VARCHAR2,
                   X_Cont_Information6                       VARCHAR2,
                   X_Cont_Information7                       VARCHAR2,
                   X_Cont_Information8                       VARCHAR2,
                   X_Cont_Information9                       VARCHAR2,
                   X_Cont_Information10                      VARCHAR2,
                   X_Cont_Information11                      VARCHAR2,
                   X_Cont_Information12                      VARCHAR2,
                   X_Cont_Information13                      VARCHAR2,
                   X_Cont_Information14                      VARCHAR2,
                   X_Cont_Information15                      VARCHAR2,
                   X_Cont_Information16                      VARCHAR2,
                   X_Cont_Information17                      VARCHAR2,
                   X_Cont_Information18                      VARCHAR2,
                   X_Cont_Information19                      VARCHAR2,
                   X_Cont_Information20                      VARCHAR2,
                   X_Per_Information1                    VARCHAR2,
                   X_Per_Information2                    VARCHAR2,
                   X_Per_Information3                    VARCHAR2,
                   X_Per_Information4                    VARCHAR2,
                   X_Per_Information5                    VARCHAR2,
                   X_Per_Information6                    VARCHAR2,
                   X_Per_Information7                    VARCHAR2,
                   X_Per_Information8                    VARCHAR2,
                   X_Per_Information9                    VARCHAR2,
                   X_Per_Information10                   VARCHAR2,
                   X_Per_Information11                   VARCHAR2,
                   X_Per_Information12                   VARCHAR2,
                   X_Per_Information13                   VARCHAR2,
                   X_Per_Information14                   VARCHAR2,
                   X_Per_Information15                   VARCHAR2,
                   X_Per_Information16                   VARCHAR2,
                   X_Per_Information17                   VARCHAR2,
                   X_Per_Information18                   VARCHAR2,
                   X_Per_Information19                   VARCHAR2,
                   X_Per_Information20                   VARCHAR2,
                   X_Per_Information21                   VARCHAR2,
                   X_Per_Information22                   VARCHAR2,
                   X_Per_Information23                   VARCHAR2,
                   X_Per_Information24                   VARCHAR2,
                   X_Per_Information25                   VARCHAR2,
                   X_Per_Information26                   VARCHAR2,
                   X_Per_Information27                   VARCHAR2,
                   X_Per_Information28                   VARCHAR2,
                   X_Per_Information29                   VARCHAR2,
                   X_Per_Information30                   VARCHAR2,
                   X_Known_As                            VARCHAR2,
                     X_Date_Start                          DATE,
                     X_Start_Life_Reason_Id                VARCHAR2,
                     X_Date_End                            DATE,
                     X_End_Life_Reason_Id                  VARCHAR2,
                     X_Rltd_Per_Rsds_W_Dsgntr_Flag         VARCHAR2,
                     X_Personal_Flag                       VARCHAR2,
		     X_Sequence_Number                     NUMBER,
                     X_Dependent_Flag                      VARCHAR2,
                     X_Beneficiary_Flag                    VARCHAR2

) IS
  CURSOR C IS
      SELECT *
      FROM   PER_CONTACT_RELATIONSHIPS
      WHERE  ROWID = X_Rowid
      FOR UPDATE OF Contact_Relationship_Id NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE C;
--
Recinfo.contact_type := RTRIM(Recinfo.contact_type);
Recinfo.comments := RTRIM(Recinfo.comments);
Recinfo.Bondholder_Flag:=RTRIM(Recinfo.Bondholder_Flag);
Recinfo.Third_Party_Pay_Flag    :=RTRIM(Recinfo.Third_Party_Pay_Flag);
Recinfo.primary_contact_flag := RTRIM(Recinfo.primary_contact_flag);
Recinfo.cont_attribute_category := RTRIM(Recinfo.cont_attribute_category);
Recinfo.cont_attribute1 := RTRIM(Recinfo.cont_attribute1);
Recinfo.cont_attribute2 := RTRIM(Recinfo.cont_attribute2);
Recinfo.cont_attribute3 := RTRIM(Recinfo.cont_attribute3);
Recinfo.cont_attribute4 := RTRIM(Recinfo.cont_attribute4);
Recinfo.cont_attribute5 := RTRIM(Recinfo.cont_attribute5);
Recinfo.cont_attribute6 := RTRIM(Recinfo.cont_attribute6);
Recinfo.cont_attribute7 := RTRIM(Recinfo.cont_attribute7);
Recinfo.cont_attribute8 := RTRIM(Recinfo.cont_attribute8);
Recinfo.cont_attribute9 := RTRIM(Recinfo.cont_attribute9);
Recinfo.cont_attribute10 := RTRIM(Recinfo.cont_attribute10);
Recinfo.cont_attribute11 := RTRIM(Recinfo.cont_attribute11);
Recinfo.cont_attribute12 := RTRIM(Recinfo.cont_attribute12);
Recinfo.cont_attribute13 := RTRIM(Recinfo.cont_attribute13);
Recinfo.cont_attribute14 := RTRIM(Recinfo.cont_attribute14);
Recinfo.cont_attribute15 := RTRIM(Recinfo.cont_attribute15);
Recinfo.cont_attribute16 := RTRIM(Recinfo.cont_attribute16);
Recinfo.cont_attribute17 := RTRIM(Recinfo.cont_attribute17);
Recinfo.cont_attribute18 := RTRIM(Recinfo.cont_attribute18);
Recinfo.cont_attribute19 := RTRIM(Recinfo.cont_attribute19);
Recinfo.cont_attribute20 := RTRIM(Recinfo.cont_attribute20);
Recinfo.cont_information_category := RTRIM(Recinfo.cont_information_category);
Recinfo.cont_information1 := RTRIM(Recinfo.cont_information1);
Recinfo.cont_information2 := RTRIM(Recinfo.cont_information2);
Recinfo.cont_information3 := RTRIM(Recinfo.cont_information3);
Recinfo.cont_information4 := RTRIM(Recinfo.cont_information4);
Recinfo.cont_information5 := RTRIM(Recinfo.cont_information5);
Recinfo.cont_information6 := RTRIM(Recinfo.cont_information6);
Recinfo.cont_information7 := RTRIM(Recinfo.cont_information7);
Recinfo.cont_information8 := RTRIM(Recinfo.cont_information8);
Recinfo.cont_information9 := RTRIM(Recinfo.cont_information9);
Recinfo.cont_information10 := RTRIM(Recinfo.cont_information10);
Recinfo.cont_information11 := RTRIM(Recinfo.cont_information11);
Recinfo.cont_information12 := RTRIM(Recinfo.cont_information12);
Recinfo.cont_information13 := RTRIM(Recinfo.cont_information13);
Recinfo.cont_information14 := RTRIM(Recinfo.cont_information14);
Recinfo.cont_information15 := RTRIM(Recinfo.cont_information15);
Recinfo.cont_information16 := RTRIM(Recinfo.cont_information16);
Recinfo.cont_information17 := RTRIM(Recinfo.cont_information17);
Recinfo.cont_information18 := RTRIM(Recinfo.cont_information18);
Recinfo.cont_information19 := RTRIM(Recinfo.cont_information19);
Recinfo.cont_information20 := RTRIM(Recinfo.cont_information20);
Recinfo.date_start       := RTRIM(Recinfo.date_start);
Recinfo.start_life_reason_id := RTRIM(Recinfo.start_life_reason_id);
Recinfo.date_end          := RTRIM(Recinfo.date_end);
Recinfo.end_life_reason_id :=RTRIM(Recinfo.end_life_reason_id);
Recinfo.rltd_per_rsds_w_dsgntr_flag :=RTRIM(Recinfo.rltd_per_rsds_w_dsgntr_flag);
Recinfo.personal_flag := RTRIM(Recinfo.personal_flag);
Recinfo.sequence_number := RTRIM(Recinfo.sequence_number);
Recinfo.dependent_flag := RTRIM(Recinfo.dependent_flag);
Recinfo.beneficiary_flag := RTRIM(Recinfo.beneficiary_flag);

--
RETURN;
  IF (
          (   (Recinfo.contact_relationship_id = X_Contact_Relationship_Id)
           OR (    (Recinfo.contact_relationship_id IS NULL)
               AND (X_Contact_Relationship_Id IS NULL)))
      AND (   (Recinfo.business_group_id = X_Business_Group_Id)
           OR (    (Recinfo.business_group_id IS NULL)
               AND (X_Business_Group_Id IS NULL)))
      AND (   (Recinfo.person_id = X_Person_Id)
           OR (    (Recinfo.person_id IS NULL)
               AND (X_Person_Id IS NULL)))
      AND (   (Recinfo.contact_person_id = X_Contact_Person_Id)
           OR (    (Recinfo.contact_person_id IS NULL)
               AND (X_Contact_Person_Id IS NULL)))
      AND (   (Recinfo.contact_type = X_Contact_Type)
           OR (    (Recinfo.contact_type IS NULL)
               AND (X_Contact_Type IS NULL)))
      AND (   (Recinfo.comments = X_Comments)
           OR (    (Recinfo.comments IS NULL)
               AND (X_Comments IS NULL)))
      AND (   (Recinfo.primary_contact_flag = X_Primary_Contact_Flag)
           OR (    (Recinfo.primary_contact_flag IS NULL)
               AND (X_Primary_Contact_Flag IS NULL)))
      AND (   (Recinfo.cont_attribute_category = X_Cont_Attribute_Category)
           OR (    (Recinfo.cont_attribute_category IS NULL)
               AND (X_Cont_Attribute_Category IS NULL)))
      AND (   (Recinfo.cont_attribute1 = X_Cont_Attribute1)
           OR (    (Recinfo.cont_attribute1 IS NULL)
               AND (X_Cont_Attribute1 IS NULL)))
      AND (   (Recinfo.cont_attribute2 = X_Cont_Attribute2)
           OR (    (Recinfo.cont_attribute2 IS NULL)
               AND (X_Cont_Attribute2 IS NULL)))
      AND (   (Recinfo.cont_attribute3 = X_Cont_Attribute3)
           OR (    (Recinfo.cont_attribute3 IS NULL)
               AND (X_Cont_Attribute3 IS NULL)))
      AND (   (Recinfo.cont_attribute4 = X_Cont_Attribute4)
           OR (    (Recinfo.cont_attribute4 IS NULL)
               AND (X_Cont_Attribute4 IS NULL)))
      AND (   (Recinfo.cont_attribute5 = X_Cont_Attribute5)
           OR (    (Recinfo.cont_attribute5 IS NULL)
               AND (X_Cont_Attribute5 IS NULL)))
      AND (   (Recinfo.cont_attribute6 = X_Cont_Attribute6)
           OR (    (Recinfo.cont_attribute6 IS NULL)
               AND (X_Cont_Attribute6 IS NULL)))
      AND (   (Recinfo.cont_attribute7 = X_Cont_Attribute7)
           OR (    (Recinfo.cont_attribute7 IS NULL)
               AND (X_Cont_Attribute7 IS NULL)))
      AND (   (Recinfo.cont_attribute8 = X_Cont_Attribute8)
           OR (    (Recinfo.cont_attribute8 IS NULL)
               AND (X_Cont_Attribute8 IS NULL)))
      AND (   (Recinfo.cont_attribute9 = X_Cont_Attribute9)
           OR (    (Recinfo.cont_attribute9 IS NULL)
               AND (X_Cont_Attribute9 IS NULL)))
      AND (   (Recinfo.cont_attribute10 = X_Cont_Attribute10)
           OR (    (Recinfo.cont_attribute10 IS NULL)
               AND (X_Cont_Attribute10 IS NULL)))
      AND (   (Recinfo.cont_attribute11 = X_Cont_Attribute11)
           OR (    (Recinfo.cont_attribute11 IS NULL)
               AND (X_Cont_Attribute11 IS NULL)))
      AND (   (Recinfo.cont_attribute12 = X_Cont_Attribute12)
           OR (    (Recinfo.cont_attribute12 IS NULL)
               AND (X_Cont_Attribute12 IS NULL)))
      AND (   (Recinfo.cont_attribute13 = X_Cont_Attribute13)
           OR (    (Recinfo.cont_attribute13 IS NULL)
               AND (X_Cont_Attribute13 IS NULL)))
      AND (   (Recinfo.cont_attribute14 = X_Cont_Attribute14)
           OR (    (Recinfo.cont_attribute14 IS NULL)
               AND (X_Cont_Attribute14 IS NULL)))
      AND (   (Recinfo.cont_attribute15 = X_Cont_Attribute15)
           OR (    (Recinfo.cont_attribute15 IS NULL)
               AND (X_Cont_Attribute15 IS NULL)))
      AND (   (Recinfo.cont_attribute16 = X_Cont_Attribute16)
           OR (    (Recinfo.cont_attribute16 IS NULL)
               AND (X_Cont_Attribute16 IS NULL)))
      AND (   (Recinfo.cont_attribute17 = X_Cont_Attribute17)
           OR (    (Recinfo.cont_attribute17 IS NULL)
               AND (X_Cont_Attribute17 IS NULL)))
      AND (   (Recinfo.cont_attribute18 = X_Cont_Attribute18)
           OR (    (Recinfo.cont_attribute18 IS NULL)
               AND (X_Cont_Attribute18 IS NULL)))
      AND (   (Recinfo.cont_attribute19 = X_Cont_Attribute19)
           OR (    (Recinfo.cont_attribute19 IS NULL)
               AND (X_Cont_Attribute19 IS NULL)))
      AND (   (Recinfo.cont_attribute20 = X_Cont_Attribute20)
           OR (    (Recinfo.cont_attribute20 IS NULL)
               AND (X_Cont_Attribute20 IS NULL)))
      AND (   (Recinfo.cont_information_category = X_Cont_Information_Category)
           OR (    (Recinfo.cont_information_category IS NULL)
               AND (X_Cont_Information_Category IS NULL)))
      AND (   (Recinfo.cont_information1 = X_Cont_Information1)
           OR (    (Recinfo.cont_information1 IS NULL)
               AND (X_Cont_Information1 IS NULL)))
      AND (   (Recinfo.cont_information2 = X_Cont_Information2)
           OR (    (Recinfo.cont_information2 IS NULL)
               AND (X_Cont_Information2 IS NULL)))
      AND (   (Recinfo.cont_information3 = X_Cont_Information3)
           OR (    (Recinfo.cont_information3 IS NULL)
               AND (X_Cont_Information3 IS NULL)))
      AND (   (Recinfo.cont_information4 = X_Cont_Information4)
           OR (    (Recinfo.cont_information4 IS NULL)
               AND (X_Cont_Information4 IS NULL)))
      AND (   (Recinfo.cont_information5 = X_Cont_Information5)
           OR (    (Recinfo.cont_information5 IS NULL)
               AND (X_Cont_Information5 IS NULL)))
      AND (   (Recinfo.cont_information6 = X_Cont_Information6)
           OR (    (Recinfo.cont_information6 IS NULL)
               AND (X_Cont_Information6 IS NULL)))
      AND (   (Recinfo.cont_information7 = X_Cont_Information7)
           OR (    (Recinfo.cont_information7 IS NULL)
               AND (X_Cont_Information7 IS NULL)))
      AND (   (Recinfo.cont_information8 = X_Cont_Information8)
           OR (    (Recinfo.cont_information8 IS NULL)
               AND (X_Cont_Information8 IS NULL)))
      AND (   (Recinfo.cont_information9 = X_Cont_Information9)
           OR (    (Recinfo.cont_information9 IS NULL)
               AND (X_Cont_Information9 IS NULL)))
      AND (   (Recinfo.cont_information10 = X_Cont_Information10)
           OR (    (Recinfo.cont_information10 IS NULL)
               AND (X_Cont_Information10 IS NULL)))
      AND (   (Recinfo.cont_information11 = X_Cont_Information11)
           OR (    (Recinfo.cont_information11 IS NULL)
               AND (X_Cont_Information11 IS NULL)))
      AND (   (Recinfo.cont_information12 = X_Cont_Information12)
           OR (    (Recinfo.cont_information12 IS NULL)
               AND (X_Cont_Information12 IS NULL)))
      AND (   (Recinfo.cont_information13 = X_Cont_Information13)
           OR (    (Recinfo.cont_information13 IS NULL)
               AND (X_Cont_Information13 IS NULL)))
      AND (   (Recinfo.cont_information14 = X_Cont_Information14)
           OR (    (Recinfo.cont_information14 IS NULL)
               AND (X_Cont_Information14 IS NULL)))
      AND (   (Recinfo.cont_information15 = X_Cont_Information15)
           OR (    (Recinfo.cont_information15 IS NULL)
               AND (X_Cont_Information15 IS NULL)))
      AND (   (Recinfo.cont_information16 = X_Cont_Information16)
           OR (    (Recinfo.cont_information16 IS NULL)
               AND (X_Cont_Information16 IS NULL)))
      AND (   (Recinfo.cont_information17 = X_Cont_Information17)
           OR (    (Recinfo.cont_information17 IS NULL)
               AND (X_Cont_Information17 IS NULL)))
      AND (   (Recinfo.cont_information18 = X_Cont_Information18)
           OR (    (Recinfo.cont_information18 IS NULL)
               AND (X_Cont_Information18 IS NULL)))
      AND (   (Recinfo.cont_information19 = X_Cont_Information19)
           OR (    (Recinfo.cont_information19 IS NULL)
               AND (X_Cont_Information19 IS NULL)))
      AND (   (Recinfo.cont_information20 = X_Cont_Information20)
           OR (    (Recinfo.cont_information20 IS NULL)
               AND (X_Cont_Information20 IS NULL)))

          ) THEN
      IF (
      (   (Recinfo.Bondholder_Flag = X_Bondholder_Flag)
           OR (    (Recinfo.Bondholder_Flag IS NULL)
               AND (X_Bondholder_Flag IS NULL)))
      AND (   (Recinfo.Third_Party_Pay_Flag = X_Third_Party_Pay_Flag)
           OR (    (Recinfo.Third_Party_Pay_Flag IS NULL)
               AND (X_Third_Party_Pay_Flag IS NULL)))
      AND (  (Recinfo.Date_Start = X_Date_Start)
         OR ( (Recinfo.Date_Start IS NULL)
          AND (X_Date_Start IS NULL)))
  AND ( (Recinfo.Start_Life_Reason_Id =X_Start_life_reason_id)
        OR ( (Recinfo.Start_life_reason_id IS NULL)
         AND (X_Start_Life_Reason_Id IS NULL)))
   AND   ( (Recinfo.Date_End = X_date_end)
        OR ( (Recinfo.Date_End IS NULL)
          AND (X_Date_end IS NULL)))
 AND  ((Recinfo.End_Life_reason_id = x_end_life_reason_id)
         OR ( (Recinfo.end_life_reason_id IS NULL)
          AND (X_end_life_reason_id IS NULL)))
 AND  ( (Recinfo.Rltd_per_rsds_w_dsgntr_flag = X_rltd_per_rsds_w_dsgntr_flag)
    OR ( (Recinfo.rltd_per_rsds_w_dsgntr_flag IS NULL)
    AND (x_rltd_per_rsds_w_dsgntr_flag IS NULL)))
 AND  ( (Recinfo.Personal_flag = X_Personal_flag)
    OR ( (Recinfo.personal_flag IS NULL)
    AND (x_personal_flag IS NULL)))
 AND  ( (Recinfo.Sequence_number = X_Sequence_number)
    OR ( (Recinfo.sequence_number IS NULL)
    AND (x_sequence_number IS NULL)))
 AND  ( (Recinfo.Dependent_flag = X_Dependent_flag)
    OR ( (Recinfo.dependent_flag IS NULL)
    AND (x_dependent_flag IS NULL)))
 AND  ( (Recinfo.Beneficiary_flag = X_Beneficiary_flag)
    OR ( (Recinfo.beneficiary_flag IS NULL)
    AND (x_beneficiary_flag IS NULL)))


)
     THEN
       RETURN;
     END IF;
  ELSE
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
END Lock_Row;

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Contact_Relationship_Id             NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Person_Id                           NUMBER,
                     X_Contact_Person_Id                   NUMBER,
                     X_Contact_Type                        VARCHAR2,
                     X_Comments                            VARCHAR2,
                     X_Bondholder_Flag                     VARCHAR2,
                     X_Third_Party_Pay_Flag                VARCHAR2,
                     X_Primary_Contact_Flag                VARCHAR2,
                     X_Cont_Attribute_Category             VARCHAR2,
                     X_Cont_Attribute1                     VARCHAR2,
                     X_Cont_Attribute2                     VARCHAR2,
                     X_Cont_Attribute3                     VARCHAR2,
                     X_Cont_Attribute4                     VARCHAR2,
                     X_Cont_Attribute5                     VARCHAR2,
                     X_Cont_Attribute6                     VARCHAR2,
                     X_Cont_Attribute7                     VARCHAR2,
                     X_Cont_Attribute8                     VARCHAR2,
                     X_Cont_Attribute9                     VARCHAR2,
                     X_Cont_Attribute10                    VARCHAR2,
                     X_Cont_Attribute11                    VARCHAR2,
                     X_Cont_Attribute12                    VARCHAR2,
                     X_Cont_Attribute13                    VARCHAR2,
                     X_Cont_Attribute14                    VARCHAR2,
                     X_Cont_Attribute15                    VARCHAR2,
                     X_Cont_Attribute16                    VARCHAR2,
                     X_Cont_Attribute17                    VARCHAR2,
                     X_Cont_Attribute18                    VARCHAR2,
                     X_Cont_Attribute19                    VARCHAR2,
                     X_Cont_Attribute20                    VARCHAR2,
                     X_Cont_Information_Category             VARCHAR2,
                     X_Cont_Information1                     VARCHAR2,
                     X_Cont_Information2                     VARCHAR2,
                     X_Cont_Information3                     VARCHAR2,
                     X_Cont_Information4                     VARCHAR2,
                     X_Cont_Information5                     VARCHAR2,
                     X_Cont_Information6                     VARCHAR2,
                     X_Cont_Information7                     VARCHAR2,
                     X_Cont_Information8                     VARCHAR2,
                     X_Cont_Information9                     VARCHAR2,
                     X_Cont_Information10                    VARCHAR2,
                     X_Cont_Information11                    VARCHAR2,
                     X_Cont_Information12                    VARCHAR2,
                     X_Cont_Information13                    VARCHAR2,
                     X_Cont_Information14                    VARCHAR2,
                     X_Cont_Information15                    VARCHAR2,
                     X_Cont_Information16                    VARCHAR2,
                     X_Cont_Information17                    VARCHAR2,
                     X_Cont_Information18                    VARCHAR2,
                     X_Cont_Information19                    VARCHAR2,
                     X_Cont_Information20                    VARCHAR2,
                     X_Session_Date                        DATE,
                     X_Date_Start                          DATE,
                     X_Start_Life_Reason_Id                VARCHAR2,
                     X_Date_End                            DATE,
                     X_End_Life_Reason_Id                  VARCHAR2,
                     X_Rltd_Per_Rsds_W_Dsgntr_Flag         VARCHAR2,
                     X_Personal_Flag                       VARCHAR2,
		     X_Sequence_Number                     NUMBER,
                     X_Dependent_Flag                      VARCHAR2,
                     X_Beneficiary_Flag                    VARCHAR2

) IS
---------------------------------------------
-- Local Declarations
--
l_exists VARCHAR2(1) := 'N';
l_mirror_update VARCHAR2(1) := 'N';
l_mirror_rowid VARCHAR2(30);
l_mirror_contact_type VARCHAR2(1);
l_others_exist VARCHAR2(1) := 'N';
l_rel_changed_cobra_exists VARCHAR2(1) := 'N';
l_old_mirror_contact_type VARCHAR2(30);
l_contact_type VARCHAR2(30);
l_date_start DATE;
--
--fix for bug 4867048.
CURSOR Check_Mirror_Update IS
SELECT 'Y'
FROM   per_contact_relationships
WHERE  ROWID = CHARTOROWID(X_Rowid)
AND( nvl(date_start,hr_api.g_date)            <> nvl(X_date_start,hr_api.g_date)
OR     nvl(start_life_reason_id,hr_api.g_number) <> nvl(X_start_life_reason_Id,hr_api.g_number)
OR     nvl(date_end,hr_api.g_date)               <> nvl(X_date_end,hr_api.g_date)
OR     nvl(end_life_reason_id,hr_api.g_number)   <> nvl(X_end_life_reason_id,hr_api.g_number)
OR     nvl(rltd_per_rsds_w_dsgntr_flag,hr_api.g_varchar2) <> nvl(X_rltd_per_rsds_w_dsgntr_flag,hr_api.g_varchar2)
OR     nvl(personal_flag,hr_api.g_varchar2)      <> nvl(X_personal_flag,hr_api.g_varchar2));
--
CURSOR Check_Mirror IS
SELECT ROWIDTOCHAR(ROWID)
FROM   per_contact_relationships
WHERE  contact_person_id = X_Person_Id
AND    person_id = X_Contact_Person_Id
AND    contact_type = l_old_mirror_contact_type
AND  nvl(date_start,hr_api.g_date) =nvl(l_date_start,hr_api.g_date)--fix for bug 4867048.
FOR UPDATE OF Contact_Type;
--
CURSOR Check_Relationship_Changed IS
SELECT 'Y'
FROM   per_contact_relationships
WHERE  contact_relationship_id = X_Contact_Relationship_Id
AND    contact_type <> X_Contact_Type
AND EXISTS
     (SELECT NULL
      FROM   per_cobra_cov_enrollments
      WHERE  CONTACT_RELATIONSHIP_ID = X_Contact_Relationship_Id);
--
  --
  -- Start of Fix for WWBUG 1408379
  --
  CURSOR c1 IS
    SELECT *
    FROM   per_contact_relationships
    WHERE  ROWID = CHARTOROWID(l_mirror_rowid);
  --
  CURSOR c2 IS
    SELECT *
    FROM   per_contact_relationships
    WHERE  ROWID = x_rowid;
  --
  l_c1 c1%ROWTYPE;
  l_rows_found BOOLEAN := FALSE;
  l_old ben_con_ler.g_con_ler_rec;
  l_new ben_con_ler.g_con_ler_rec;
  --
  -- End of Fix for WWBUG 1408379
  --
---------------------------------------------
-- Main Procedure
--
BEGIN
--

-- fix for bug8395666
if hr_general.chk_product_installed(805) = 'TRUE' then
 ben_ELIG_DPNT_api.chk_enrt_for_dpnt(
    p_dpnt_person_id                => X_Contact_Person_Id
   ,p_dpnt_rltp_id                  => X_Contact_Relationship_Id
   ,p_rltp_type                     => X_Contact_Type
   ,p_business_group_id             => X_Business_Group_Id);
end if;


SELECT date_start, contact_type
INTO l_date_start, l_contact_type
FROM per_contact_relationships
WHERE ROWID = CHARTOROWID(X_rowid);
--
-- Find the mirror_contact_type before update to locate
-- the correct mirror relationship for update.
--
l_old_mirror_contact_type := Get_Mirror_Contact_Type(l_contact_type);
--
-- Check to ensure that there is only one primary contact for the person
--
   IF X_Primary_Contact_Flag = 'Y' AND
      check_primary_contact(p_rowid => X_Rowid
                           ,p_person_id => X_Person_Id
                           ,p_date_start => X_date_start
                           ,p_date_end   => X_date_end) THEN
      hr_utility.set_message(801,'PER_7125_EMP_CON_PRIMARY');
      hr_utility.raise_error;
   END IF;
--
-- Call to sequence number validation
--
  chk_sequence_number(p_contact_relationship_id => X_contact_relationship_id
                                 ,p_sequence_number => X_sequence_number
				 ,p_contact_person_id => X_contact_person_id
				 ,p_person_id         => X_person_id
				 );
  --
  -- Check to ensure that only one relationship of the same type exists
  -- between the same two people at the same time (Bug 1239406)
  --
  IF time_validation(p_contact_type => X_contact_type
                    ,p_person_id => X_person_id
                    ,p_contact_person_id => X_contact_person_id
                    ,p_contact_relationship_id => X_contact_relationship_id
                    ,p_date_start => X_date_start
                    ,p_date_end => X_date_end
  ) THEN
      hr_utility.set_message(800,'PER_6996_REL_CURR_EXISTS');
      hr_utility.raise_error;
  END IF;
   --
/*
   -- Bug.3207660
   -- This validation guarantees all PER_CONTACT_EXTRA_INFO_F records
   -- are within CTR.DATE_START and CTR.DATE_END date range.
   -- Now the validation is relaxed(removed).
   -- PER_CONTACT_EXTRA_INFO_F records can stay outside the range of CTR.
   -- Note the validation that PER_CONTACT_EXTRA_INFO_F records must be
   -- within the date range of PER_ALL_PEOPLE_F is still alive.
   chk_dates(
    x_contact_relationship_id => x_contact_relationship_id,
    x_date_start              => x_date_start,
    x_date_end                => x_date_end);
*/
   --
  --
  -- If the Contact_Type has change then do not attempt to update the
  -- mirror image. If contact_type is unchanged then update the mirror.
  --
  OPEN  Check_Mirror_Update;
  FETCH Check_Mirror_Update INTO l_mirror_update;
  CLOSE Check_Mirror_Update;
  --
  IF l_mirror_update = 'Y' THEN
     OPEN Check_Mirror;
     FETCH Check_Mirror INTO l_mirror_rowid;
     IF Check_Mirror%FOUND THEN
        --
        -- Start of Fix for WWBUG 1408379
        --
        OPEN c1;
          --
          FETCH c1 INTO l_c1;
          IF c1%FOUND THEN
            --
            l_rows_found := TRUE;
            --
          END IF;
          --
        CLOSE c1;
        --
        UPDATE per_contact_relationships
        SET
            date_start                  = X_date_start
           ,start_life_reason_id        = X_start_life_reason_id
           ,date_end                    = X_date_end
           ,end_life_reason_id          = X_end_life_reason_id
           ,rltd_per_rsds_w_dsgntr_flag = X_rltd_per_rsds_w_dsgntr_flag
           ,personal_flag               = X_personal_flag
        WHERE ROWID = CHARTOROWID(l_mirror_rowid);
        --
        IF l_rows_found THEN
          --
          l_old.person_id := l_c1.person_id;
          l_old.contact_person_id := l_c1.contact_person_id;
          l_old.business_group_id := l_c1.business_group_id;
          l_old.date_start := l_c1.date_start;
          l_old.date_end := l_c1.date_end;
          l_old.contact_type := l_c1.contact_type;
          l_old.personal_flag := l_c1.personal_flag;
          l_old.start_life_reason_id := l_c1.start_life_reason_id;
          l_old.end_life_reason_id := l_c1.end_life_reason_id;
          l_old.rltd_per_rsds_w_dsgntr_flag := l_c1.rltd_per_rsds_w_dsgntr_flag;
          l_old.contact_relationship_id := l_c1.contact_relationship_id;
          -- Bug 1772037 fix
          l_old.cont_attribute1  := l_c1.cont_attribute1  ;
          l_old.cont_attribute2  := l_c1.cont_attribute2  ;
          l_old.cont_attribute3  := l_c1.cont_attribute3  ;
          l_old.cont_attribute4  := l_c1.cont_attribute4  ;
          l_old.cont_attribute5  := l_c1.cont_attribute5  ;
          l_old.cont_attribute6  := l_c1.cont_attribute6  ;
          l_old.cont_attribute7  := l_c1.cont_attribute7  ;
          l_old.cont_attribute8  := l_c1.cont_attribute8  ;
          l_old.cont_attribute9  := l_c1.cont_attribute9  ;
          l_old.cont_attribute10 := l_c1.cont_attribute10 ;
          l_old.cont_attribute11 := l_c1.cont_attribute11 ;
          l_old.cont_attribute12 := l_c1.cont_attribute12 ;
          l_old.cont_attribute13 := l_c1.cont_attribute13 ;
          l_old.cont_attribute14 := l_c1.cont_attribute14 ;
          l_old.cont_attribute15 := l_c1.cont_attribute15 ;
          l_old.cont_attribute16 := l_c1.cont_attribute16 ;
          l_old.cont_attribute17 := l_c1.cont_attribute17 ;
          l_old.cont_attribute18 := l_c1.cont_attribute18 ;
          l_old.cont_attribute19 := l_c1.cont_attribute19 ;
          l_old.cont_attribute20 := l_c1.cont_attribute20 ;
          -- End fix 1772037
          l_new.person_id := l_c1.person_id;
          l_new.contact_person_id := l_c1.contact_person_id;
          l_new.business_group_id := l_c1.business_group_id;
          l_new.date_start := x_date_start;
          l_new.date_end := x_date_end;
          l_new.contact_type := l_c1.contact_type;
          l_new.personal_flag := x_personal_flag;
          l_new.start_life_reason_id := x_start_life_reason_id;
          l_new.end_life_reason_id := x_end_life_reason_id;
          l_new.rltd_per_rsds_w_dsgntr_flag := x_rltd_per_rsds_w_dsgntr_flag;
          l_new.contact_relationship_id := l_c1.contact_relationship_id;
          -- Bug 1772037 fix
          l_new.cont_attribute1  := x_cont_attribute1  ;
          l_new.cont_attribute2  := x_cont_attribute2  ;
          l_new.cont_attribute3  := x_cont_attribute3  ;
          l_new.cont_attribute4  := x_cont_attribute4  ;
          l_new.cont_attribute5  := x_cont_attribute5  ;
          l_new.cont_attribute6  := x_cont_attribute6  ;
          l_new.cont_attribute7  := x_cont_attribute7  ;
          l_new.cont_attribute8  := x_cont_attribute8  ;
          l_new.cont_attribute9  := x_cont_attribute9  ;
          l_new.cont_attribute10 := x_cont_attribute10 ;
          l_new.cont_attribute11 := x_cont_attribute11 ;
          l_new.cont_attribute12 := x_cont_attribute12 ;
          l_new.cont_attribute13 := x_cont_attribute13 ;
          l_new.cont_attribute14 := x_cont_attribute14 ;
          l_new.cont_attribute15 := x_cont_attribute15 ;
          l_new.cont_attribute16 := x_cont_attribute16 ;
          l_new.cont_attribute17 := x_cont_attribute17 ;
          l_new.cont_attribute18 := x_cont_attribute18 ;
          l_new.cont_attribute19 := x_cont_attribute19 ;
          l_new.cont_attribute20 := x_cont_attribute20 ;
          -- End fix 1772037
          --
          ben_con_ler.ler_chk(p_old             => l_old,
                              p_new             => l_new,
                              p_effective_date  => NVL(x_date_start,SYSDATE));
          --
        END IF;
        --
     END IF;
     CLOSE Check_Mirror;
  END IF;
  --
  -- Update the base Contact_Relationship record
  --
  --
  -- Start of Fix for WWBUG 1408379
  --
  OPEN c2;
    --
    FETCH c2 INTO l_c1;
    --
    IF c2%FOUND THEN
      --
      l_rows_found := TRUE;
      --
    ELSE
      --
      l_rows_found := FALSE;
      --
    END IF;
    --
  CLOSE c2;
  --
  UPDATE PER_CONTACT_RELATIONSHIPS
  SET
    contact_relationship_id                   =    X_Contact_Relationship_Id,
    business_group_id                         =    X_Business_Group_Id,
    person_id                                 =    X_Person_Id,
    contact_person_id                         =    X_Contact_Person_Id,
    contact_type                              =    X_Contact_Type,
    comments                                  =    X_Comments,
    Bondholder_Flag                           =    X_Bondholder_Flag,
    Third_Party_Pay_Flag                      =    X_Third_Party_Pay_Flag,
    primary_contact_flag                      =    X_Primary_Contact_Flag,
    cont_attribute_category                   =    X_Cont_Attribute_Category,
    cont_attribute1                           =    X_Cont_Attribute1,
    cont_attribute2                           =    X_Cont_Attribute2,
    cont_attribute3                           =    X_Cont_Attribute3,
    cont_attribute4                           =    X_Cont_Attribute4,
    cont_attribute5                           =    X_Cont_Attribute5,
    cont_attribute6                           =    X_Cont_Attribute6,
    cont_attribute7                           =    X_Cont_Attribute7,
    cont_attribute8                           =    X_Cont_Attribute8,
    cont_attribute9                           =    X_Cont_Attribute9,
    cont_attribute10                          =    X_Cont_Attribute10,
    cont_attribute11                          =    X_Cont_Attribute11,
    cont_attribute12                          =    X_Cont_Attribute12,
    cont_attribute13                          =    X_Cont_Attribute13,
    cont_attribute14                          =    X_Cont_Attribute14,
    cont_attribute15                          =    X_Cont_Attribute15,
    cont_attribute16                          =    X_Cont_Attribute16,
    cont_attribute17                          =    X_Cont_Attribute17,
    cont_attribute18                          =    X_Cont_Attribute18,
    cont_attribute19                          =    X_Cont_Attribute19,
    cont_attribute20                          =    X_Cont_Attribute20,
    cont_information_category                   =    X_Cont_Information_Category,
    cont_information1                           =    X_Cont_Information1,
    cont_information2                           =    X_Cont_Information2,
    cont_information3                           =    X_Cont_Information3,
    cont_information4                           =    X_Cont_Information4,
    cont_information5                           =    X_Cont_Information5,
    cont_information6                           =    X_Cont_Information6,
    cont_information7                           =    X_Cont_Information7,
    cont_information8                           =    X_Cont_Information8,
    cont_information9                           =    X_Cont_Information9,
    cont_information10                          =    X_Cont_Information10,
    cont_information11                          =    X_Cont_Information11,
    cont_information12                          =    X_Cont_Information12,
    cont_information13                          =    X_Cont_Information13,
    cont_information14                          =    X_Cont_Information14,
    cont_information15                          =    X_Cont_Information15,
    cont_information16                          =    X_Cont_Information16,
    cont_information17                          =    X_Cont_Information17,
    cont_information18                          =    X_Cont_Information18,
    cont_information19                          =    X_Cont_Information19,
    cont_information20                          =    X_Cont_Information20,
    date_start                                =    X_date_start,
    start_life_reason_id                      =    X_start_life_reason_id,
    date_end                                  =    X_date_end,
    end_life_reason_id                        =    X_end_life_reason_id,
    rltd_per_rsds_w_dsgntr_flag               =    X_rltd_per_rsds_w_dsgntr_flag,
    personal_flag                             =    X_personal_flag,
    sequence_number                           =    X_sequence_number,
    dependent_flag                            =    X_dependent_flag,
    beneficiary_flag                          =    X_beneficiary_flag

 WHERE ROWID = X_rowid;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
  --
  IF l_rows_found THEN
    --
    l_old.person_id := l_c1.person_id;
    l_old.contact_person_id := l_c1.contact_person_id;
    l_old.business_group_id := l_c1.business_group_id;
    l_old.date_start := l_c1.date_start;
    l_old.date_end := l_c1.date_end;
    l_old.contact_type := l_c1.contact_type;
    l_old.personal_flag := l_c1.personal_flag;
    l_old.start_life_reason_id := l_c1.start_life_reason_id;
    l_old.end_life_reason_id := l_c1.end_life_reason_id;
    l_old.rltd_per_rsds_w_dsgntr_flag := l_c1.rltd_per_rsds_w_dsgntr_flag;
    l_old.contact_relationship_id := l_c1.contact_relationship_id;
    -- Bug 1772037 fix
    l_old.cont_attribute1  := l_c1.cont_attribute1  ;
    l_old.cont_attribute2  := l_c1.cont_attribute2  ;
    l_old.cont_attribute3  := l_c1.cont_attribute3  ;
    l_old.cont_attribute4  := l_c1.cont_attribute4  ;
    l_old.cont_attribute5  := l_c1.cont_attribute5  ;
    l_old.cont_attribute6  := l_c1.cont_attribute6  ;
    l_old.cont_attribute7  := l_c1.cont_attribute7  ;
    l_old.cont_attribute8  := l_c1.cont_attribute8  ;
    l_old.cont_attribute9  := l_c1.cont_attribute9  ;
    l_old.cont_attribute10 := l_c1.cont_attribute10 ;
    l_old.cont_attribute11 := l_c1.cont_attribute11 ;
    l_old.cont_attribute12 := l_c1.cont_attribute12 ;
    l_old.cont_attribute13 := l_c1.cont_attribute13 ;
    l_old.cont_attribute14 := l_c1.cont_attribute14 ;
    l_old.cont_attribute15 := l_c1.cont_attribute15 ;
    l_old.cont_attribute16 := l_c1.cont_attribute16 ;
    l_old.cont_attribute17 := l_c1.cont_attribute17 ;
    l_old.cont_attribute18 := l_c1.cont_attribute18 ;
    l_old.cont_attribute19 := l_c1.cont_attribute19 ;
    l_old.cont_attribute20 := l_c1.cont_attribute20 ;
    -- End fix 1772037
    l_new.person_id := x_person_id;
    l_new.contact_person_id := x_contact_person_id;
    l_new.business_group_id := x_business_group_id;
    l_new.date_start := x_date_start;
    l_new.date_end := x_date_end;
    l_new.contact_type := x_contact_type;
    l_new.personal_flag := x_personal_flag;
    l_new.start_life_reason_id := x_start_life_reason_id;
    l_new.end_life_reason_id := x_end_life_reason_id;
    l_new.rltd_per_rsds_w_dsgntr_flag := x_rltd_per_rsds_w_dsgntr_flag;
    l_new.contact_relationship_id := x_contact_relationship_id;
    -- Bug 1772037 fix
    l_new.cont_attribute1  := x_cont_attribute1  ;
    l_new.cont_attribute2  := x_cont_attribute2  ;
    l_new.cont_attribute3  := x_cont_attribute3  ;
    l_new.cont_attribute4  := x_cont_attribute4  ;
    l_new.cont_attribute5  := x_cont_attribute5  ;
    l_new.cont_attribute6  := x_cont_attribute6  ;
    l_new.cont_attribute7  := x_cont_attribute7  ;
    l_new.cont_attribute8  := x_cont_attribute8  ;
    l_new.cont_attribute9  := x_cont_attribute9  ;
    l_new.cont_attribute10 := x_cont_attribute10 ;
    l_new.cont_attribute11 := x_cont_attribute11 ;
    l_new.cont_attribute12 := x_cont_attribute12 ;
    l_new.cont_attribute13 := x_cont_attribute13 ;
    l_new.cont_attribute14 := x_cont_attribute14 ;
    l_new.cont_attribute15 := x_cont_attribute15 ;
    l_new.cont_attribute16 := x_cont_attribute16 ;
    l_new.cont_attribute17 := x_cont_attribute17 ;
    l_new.cont_attribute18 := x_cont_attribute18 ;
    l_new.cont_attribute19 := x_cont_attribute19 ;
    l_new.cont_attribute20 := x_cont_attribute20 ;
    -- End fix 1772037
    --
    ben_con_ler.ler_chk(p_old            => l_old,
                        p_new            => l_new,
                        p_effective_date => NVL(x_date_start,SYSDATE));
    --
  END IF;
  --
  -- 1766066: added call for contact start date enh.
  --
  if (X_Date_Start is not null
      and X_Date_Start < l_date_start) then
   per_people12_pkg.maintain_coverage(p_person_id      => X_Contact_Person_Id
                                     ,p_type           => 'CONT'
                                     );
  end if;
  -- 1766066 end.
  --
END Update_Row;

PROCEDURE Delete_Row(X_Rowid VARCHAR2
                    ,X_Person_Id NUMBER
                    ,X_Contact_Person_Id NUMBER
                    ,X_Contact_Relationship_Id NUMBER
                    ,X_Date_Start DATE
                    ,X_Contact_Type VARCHAR2) IS
l_mirror_type VARCHAR2(1);
--
BEGIN
-- Bug 2017198: have switched the order of deletes alongside change in peper-2t.pkb
-- for function multiple_contacts

-- Delete the base contact relationship
--
  DELETE FROM PER_CONTACT_RELATIONSHIPS
  WHERE  ROWID = X_Rowid;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

-- Delete the Mirror Relationship
--
  IF X_contact_type IN ('C','P','S') THEN
    l_mirror_type := Get_Mirror_Contact_Type(p_contact_type =>X_Contact_Type);
--
    DELETE FROM PER_CONTACT_RELATIONSHIPS
    WHERE person_id = X_Contact_Person_Id
    AND   contact_person_id = X_Person_Id
    AND   contact_type = l_mirror_type
    AND   date_start = X_date_start;

  ELSE NULL;
  END IF;

-- if the person is a Contact Only and
-- there exists Person Analyses Records and
-- their Person Type is 'OTHER' then
-- delete any comments for the person
-- delete the person
--
-- bug fix 4197342
-- condition added to check whether the person is an irec candidate.

  IF hr_contact_relationships.contact_only(X_Contact_Person_Id) = 'Y'
     AND hr_contact_relationships.multiple_contacts(X_Contact_Person_Id) = 'N'
     AND NOT irc_candidate_test.is_person_a_candidate(X_Contact_Person_Id)
  THEN
--
-- Check foreign key tables
--
    Delete_Validation(X_Contact_Person_Id
                     ,X_Contact_Relationship_Id);
   --
   DELETE FROM per_contact_extra_info_f
   WHERE contact_relationship_id = x_contact_relationship_id;
   --
-- added for 1931258
    ben_person_delete.perform_ri_check(X_Contact_Person_Id);

      DELETE FROM hr_comments h
      WHERE h.comment_id IN
           (SELECT comment_id
            FROM PER_ALL_PEOPLE_F paf
            WHERE paf.person_id = X_Contact_Person_Id);

-- added for 1931258
    ben_person_delete.delete_ben_rows(X_Contact_Person_Id);

      DELETE per_all_people_f
      WHERE person_id = X_Contact_Person_Id;

  END IF;
END Delete_Row;

PROCEDURE Delete_Validation(X_Person_Id NUMBER
                           ,X_Contact_Relationship_Id NUMBER) IS

l_address_exists VARCHAR2(1) := 'N';
l_cobra_exists VARCHAR2(1) := 'N';
l_dependent_exists VARCHAR2(1) := 'N';
l_beneficiary_exists VARCHAR2(1) := 'N';
l_pa_exists VARCHAR2(1) := 'N';
--
CURSOR Personal_Analyses IS
SELECT  'Y'
FROM    per_person_analyses
WHERE   person_id = X_Person_Id;
--
CURSOR Address IS
SELECT 'Y'
FROM   per_addresses
WHERE  person_id = X_Person_Id;
--
CURSOR COBRA IS
SELECT 'Y'
FROM   per_cobra_cov_enrollments
WHERE  CONTACT_RELATIONSHIP_ID = X_Contact_Relationship_Id;
--
--Changes for Bug no 5415267 starts here
CURSOR Benificiary IS
SELECT 'Y'
FROM   BEN_BENEFICIARIES_X
WHERE  source_id = X_Person_Id;
--Changes for Bug no 5415267 ends here
BEGIN
--
--Changes for Bug no 5415267 starts here

    OPEN Benificiary;
    FETCH Benificiary INTO l_beneficiary_exists;
    CLOSE Benificiary;
--
    IF l_beneficiary_exists = 'Y' THEN
      hr_utility.set_message(801,'HR_7993_CONTACT_BENEFIT_EXISTS');
      hr_utility.raise_error;
    END IF;
--Changes for Bug no 5415267 ends here

-- if the person is a Contact Only then
-- do foreign key checks ie. address
--
-- Bug 1295442 Added check for multiple contacts
--
  IF hr_contact_relationships.contact_only(X_Person_Id) = 'Y'
   AND hr_contact_relationships.multiple_contacts(X_Person_Id) = 'N'
   THEN

    OPEN Personal_Analyses;
    FETCH Personal_Analyses INTO l_pa_exists;
    CLOSE Personal_Analyses;
--
    IF l_pa_exists = 'Y' THEN
      hr_utility.set_message(801,'HR_51600_EMP_SIT_EXIST');
      hr_utility.raise_error;
    END IF;
--
    OPEN Address;
    FETCH Address INTO l_address_exists;
    CLOSE Address;
--
    IF l_address_exists = 'Y' THEN
      hr_utility.set_message(801,'PER_7101_EMP_ENTER_DEL_ADDR');
      hr_utility.raise_error;
    END IF;
--

    OPEN COBRA;
    FETCH COBRA INTO l_cobra_exists;
    CLOSE COBRA;
--
    IF l_cobra_exists = 'Y' THEN
      hr_utility.set_message(801,'HR_6975_CONTACT_COBRA_EXISTS');
      hr_utility.raise_error;
    END IF;
--
    -- Check to see if Personal Payment Method exists
    -- where contact is the Payee.
    --
    hr_contact_relationships.check_ppm(p_contact_id => X_Person_Id
                         ,p_contact_relationship_id => X_Contact_Relationship_Id
                         ,p_mode => 'D');
  END IF;
END;
--
PROCEDURE chk_sequence_number(p_contact_relationship_id IN NUMBER,
                              p_sequence_number IN NUMBER,
			      p_contact_person_id IN NUMBER,
			      p_person_id IN NUMBER) IS
--
l_sequence_number NUMBER;
l_sequence_other  NUMBER;
l_old_seq_number NUMBER;
--
CURSOR csr_seq IS
SELECT sequence_number
FROM per_contact_relationships con
WHERE con.person_id = p_person_id
AND con.contact_person_id = p_contact_person_id
AND con.sequence_number  <> p_sequence_number;
--
CURSOR csr_old_seq IS
SELECT sequence_number
FROM per_contact_relationships con
WHERE con.person_id = p_person_id
AND con.contact_person_id = p_contact_person_id
AND con.contact_relationship_id = p_contact_relationship_id;
--
CURSOR csr_seq_others IS
SELECT sequence_number
FROM per_contact_relationships con
WHERE con.person_id = p_person_id
AND con.contact_person_id <> p_contact_person_id
AND   con.sequence_number = p_sequence_number;
--
BEGIN
   --
  IF (p_contact_relationship_id IS NOT NULL) THEN
    OPEN csr_old_seq;
    FETCH csr_old_seq INTO l_old_seq_number;
    CLOSE csr_old_seq;
  END IF;

     IF p_sequence_number IS NOT NULL AND
       p_contact_person_id IS NOT NULL THEN
       IF l_old_seq_number IS NULL THEN
         OPEN csr_seq;
         FETCH csr_seq INTO l_sequence_number;
         IF csr_seq%FOUND THEN
           CLOSE csr_seq;
           hr_utility.set_message('800','PER_52509_USE_SEQ_NO');
           hr_utility.raise_error;
         ELSE
           OPEN csr_seq_others;
           FETCH csr_seq_others INTO l_sequence_other;
           IF csr_seq_others%FOUND THEN
             CLOSE csr_seq_others;
             hr_utility.set_message('800','PER_52510_DIFF_SEQ_NO');
             hr_utility.raise_error;
           END IF;
         END IF;
       ELSIF p_sequence_number <> l_old_seq_number THEN
       hr_utility.set_message('800','PER_52511_SEQ_NO_UPD');
       hr_utility.raise_error;
       END IF;
    ELSIF l_old_seq_number IS NOT NULL THEN
      hr_utility.set_message('800','PER_52511_SEQ_NO_UPD');
      hr_utility.raise_error;
    END IF;
END chk_sequence_number;
--
-- Update Contact Person details
--
PROCEDURE Update_Contact(X_Business_Group_Id                   NUMBER,
                     X_Person_Id                           NUMBER,
                     X_Contact_Person_Id                   NUMBER,
                     X_Session_Date                        DATE,
                     X_Person_Type_Id                      NUMBER,
                     X_Last_Name                           VARCHAR2,
                     X_Comment_Id                          NUMBER,
                     X_Date_Of_Birth                       DATE,
                     x_date_of_death       DATE,
                     X_First_Name                          VARCHAR2,
                     X_Middle_Names                        VARCHAR2,
                     X_Sex                                 VARCHAR2,
                     X_Title                               VARCHAR2,
		               X_PRE_NAME_ADJUNCT		   	   VARCHAR2,
		               X_SUFFIX				   VARCHAR2,
                     X_Title_Desc                          VARCHAR2,
                     X_National_Identifier                 VARCHAR2,
                     X_Attribute_Category                  VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2,
                     X_Attribute16                         VARCHAR2,
                     X_Attribute17                         VARCHAR2,
                     X_Attribute18                         VARCHAR2,
                     X_Attribute19                         VARCHAR2,
                     X_Attribute20                         VARCHAR2,
                     X_Attribute21                         VARCHAR2,
                     X_Attribute22                         VARCHAR2,
                     X_Attribute23                         VARCHAR2,
                     X_Attribute24                         VARCHAR2,
                     X_Attribute25                         VARCHAR2,
                     X_Attribute26                         VARCHAR2,
                     X_Attribute27                         VARCHAR2,
                     X_Attribute28                         VARCHAR2,
                     X_Attribute29                         VARCHAR2,
                     X_Attribute30                         VARCHAR2,
                     X_Contact_Only                        VARCHAR2,
                     X_Reentry_flag                        IN OUT NOCOPY NUMBER,
                     X_Per_Information_category            VARCHAR2,
                     X_Per_Information1                    VARCHAR2,
                     X_Per_Information2                    VARCHAR2,
                     X_Per_Information3                    VARCHAR2,
                     X_Per_Information4                    VARCHAR2,
                     X_Per_Information5                    VARCHAR2,
                     X_Per_Information6                    VARCHAR2,
                     X_Per_Information7                    VARCHAR2,
                     X_Per_Information8                    VARCHAR2,
                     X_Per_Information9                    VARCHAR2,
                     X_Per_Information10                   VARCHAR2,
                     X_Per_Information11                   VARCHAR2,
                     X_Per_Information12                   VARCHAR2,
                     X_Per_Information13                   VARCHAR2,
                     X_Per_Information14                   VARCHAR2,
                     X_Per_Information15                   VARCHAR2,
                     X_Per_Information16                   VARCHAR2,
                     X_Per_Information17                   VARCHAR2,
                     X_Per_Information18                   VARCHAR2,
                     X_Per_Information19                   VARCHAR2,
                     X_Per_Information20                   VARCHAR2,
                     X_Per_Information21                   VARCHAR2,
                     X_Per_Information22                   VARCHAR2,
                     X_Per_Information23                   VARCHAR2,
                     X_Per_Information24                   VARCHAR2,
                     X_Per_Information25                   VARCHAR2,
                     X_Per_Information26                   VARCHAR2,
                     X_Per_Information27                   VARCHAR2,
                     X_Per_Information28                   VARCHAR2,
                     X_Per_Information29                   VARCHAR2,
                     X_Per_Information30                   VARCHAR2,
                     X_Known_As                            VARCHAR2
) IS
---------------------------------------------
-- Local Declarations
--
l_exists VARCHAR2(1) := 'N';
l_ctype_changed VARCHAR2(1) := 'N';
l_others_exist VARCHAR2(1) := 'N';
--
--
CURSOR Check_Person_Changed IS
SELECT /*+ NO_EXPAND */ 'Y'
FROM   per_all_people_f ppf,per_person_type_usages ptu
WHERE  ppf.person_id=X_Contact_Person_id
AND    X_Session_Date BETWEEN
        ppf.effective_start_date AND ppf.effective_end_date
AND    ppf.last_name = X_Last_Name
AND    ptu.person_id=ppf.person_id
AND    ptu.person_type_id = X_Person_Type_Id
AND (( ppf.comment_id = X_Comment_Id)
   OR (ppf.comment_id IS NULL AND X_Comment_Id IS NULL))
AND (( ppf.date_of_birth = X_Date_Of_Birth)
   OR (ppf.date_of_birth IS NULL AND X_Date_Of_Birth IS NULL))
 AND ((ppf.date_of_death = x_date_of_death)
  OR  (ppf.date_of_death IS NULL AND x_date_of_death IS NULL))
AND (( ppf.first_name = X_First_Name)
   OR (ppf.first_name IS NULL AND X_First_Name IS NULL))
AND (( ppf.middle_names = X_Middle_Names)
   OR (ppf.middle_names IS NULL AND X_Middle_Names IS NULL))
AND (( ppf.sex = X_Sex)
   OR (ppf.sex IS NULL AND X_Sex IS NULL))
AND (( ppf.title = X_Title)
   OR (ppf.title IS NULL AND X_Title IS NULL))
AND (( ppf.pre_name_adjunct = X_pre_name_adjunct)
   OR (ppf.pre_name_adjunct IS NULL AND X_pre_name_adjunct IS NULL))
AND (( ppf.suffix = X_suffix)
   OR (ppf.suffix IS NULL AND X_suffix IS NULL))
AND (( ppf.national_identifier = X_national_identifier)
   OR (ppf.national_identifier IS NULL AND X_national_identifier IS NULL))
AND (( ppf.attribute_category = X_Attribute_Category)
   OR (ppf.attribute_category IS NULL AND X_Attribute_Category IS NULL))
AND (( ppf.attribute1 = X_Attribute1)
   OR (ppf.attribute1 IS NULL AND X_Attribute1 IS NULL))
AND (( ppf.attribute2 = X_Attribute2)
   OR (ppf.attribute2 IS NULL AND X_Attribute2 IS NULL))
AND (( ppf.attribute3 = X_Attribute3)
   OR (ppf.attribute3 IS NULL AND X_Attribute3 IS NULL))
AND (( ppf.attribute4 = X_Attribute4)
   OR (ppf.attribute4 IS NULL AND X_Attribute4 IS NULL))
AND (( ppf.attribute5 = X_Attribute5)
   OR (ppf.attribute5 IS NULL AND X_Attribute5 IS NULL))
AND (( ppf.attribute6 = X_Attribute6)
   OR (ppf.attribute6 IS NULL AND X_Attribute6 IS NULL))
AND (( ppf.attribute7 = X_Attribute7)
   OR (ppf.attribute7 IS NULL AND X_Attribute7 IS NULL))
AND (( ppf.attribute8 = X_Attribute8)
   OR (ppf.attribute8 IS NULL AND X_Attribute8 IS NULL))
AND (( ppf.attribute9 = X_Attribute9)
   OR (ppf.attribute9 IS NULL AND X_Attribute9 IS NULL))
AND (( ppf.attribute10 = X_Attribute10)
   OR (ppf.attribute10 IS NULL AND X_Attribute10 IS NULL))
AND (( ppf.attribute11 = X_Attribute11)
   OR (ppf.attribute11 IS NULL AND X_Attribute11 IS NULL))
AND (( ppf.attribute12 = X_Attribute12)
   OR (ppf.attribute12 IS NULL AND X_Attribute12 IS NULL))
AND (( ppf.attribute13 = X_Attribute13)
   OR (ppf.attribute13 IS NULL AND X_Attribute13 IS NULL))
AND (( ppf.attribute14 = X_Attribute14)
   OR (ppf.attribute14 IS NULL AND X_Attribute14 IS NULL))
AND (( ppf.attribute15 = X_Attribute15)
   OR (ppf.attribute15 IS NULL AND X_Attribute15 IS NULL))
AND (( ppf.attribute16 = X_Attribute16)
   OR (ppf.attribute16 IS NULL AND X_Attribute16 IS NULL))
AND (( ppf.attribute17 = X_Attribute17)
   OR (ppf.attribute17 IS NULL AND X_Attribute17 IS NULL))
AND (( ppf.attribute18 = X_Attribute18)
   OR (ppf.attribute18 IS NULL AND X_Attribute18 IS NULL))
AND (( ppf.attribute19 = X_Attribute19)
   OR (ppf.attribute19 IS NULL AND X_Attribute19 IS NULL))
AND (( ppf.attribute20 = X_Attribute20)
   OR (ppf.attribute20 IS NULL AND X_Attribute20 IS NULL))
AND (( ppf.attribute21 = X_Attribute11)
   OR (ppf.attribute21 IS NULL AND X_Attribute21 IS NULL))
AND (( ppf.attribute22 = X_Attribute22)
   OR (ppf.attribute22 IS NULL AND X_Attribute22 IS NULL))
AND (( ppf.attribute23 = X_Attribute23)
   OR (ppf.attribute23 IS NULL AND X_Attribute23 IS NULL))
AND (( ppf.attribute24 = X_Attribute24)
   OR (ppf.attribute24 IS NULL AND X_Attribute24 IS NULL))
AND (( ppf.attribute25 = X_Attribute25)
   OR (ppf.attribute25 IS NULL AND X_Attribute25 IS NULL))
AND (( ppf.attribute26 = X_Attribute26)
   OR (ppf.attribute26 IS NULL AND X_Attribute26 IS NULL))
AND (( ppf.attribute27 = X_Attribute27)
   OR (ppf.attribute27 IS NULL AND X_Attribute27 IS NULL))
AND (( ppf.attribute28 = X_Attribute28)
   OR (ppf.attribute28 IS NULL AND X_Attribute28 IS NULL))
AND (( ppf.attribute29 = X_Attribute29)
   OR (ppf.attribute29 IS NULL AND X_Attribute29 IS NULL))
AND (( ppf.attribute30 = X_Attribute30)
   OR (ppf.attribute30 IS NULL AND X_Attribute30 IS NULL))
AND (( ppf.per_information_category = X_per_information_category)
   OR (ppf.per_information_category IS NULL AND X_per_information_category IS NULL))
AND (( ppf.per_information1 = X_per_information1)
   OR (ppf.per_information1 IS NULL AND X_per_information1 IS NULL))
AND (( ppf.per_information2 = X_per_information2)
   OR (ppf.per_information2 IS NULL AND X_per_information2 IS NULL))
AND (( ppf.per_information3 = X_per_information3)
   OR (ppf.per_information3 IS NULL AND X_per_information3 IS NULL))
AND (( ppf.per_information4 = X_per_information4)
   OR (ppf.per_information4 IS NULL AND X_per_information4 IS NULL))
AND (( ppf.per_information5 = X_per_information5)
   OR (ppf.per_information5 IS NULL AND X_per_information5 IS NULL))
AND (( ppf.per_information6 = X_per_information6)
   OR (ppf.per_information6 IS NULL AND X_per_information6 IS NULL))
AND (( ppf.per_information7 = X_per_information7)
   OR (ppf.per_information7 IS NULL AND X_per_information7 IS NULL))
AND (( ppf.per_information8 = X_per_information8)
   OR (ppf.per_information8 IS NULL AND X_per_information8 IS NULL))
AND (( ppf.per_information9 = X_per_information9)
   OR (ppf.per_information9 IS NULL AND X_per_information9 IS NULL))
AND (( ppf.per_information10 = X_per_information10)
   OR (ppf.per_information10 IS NULL AND X_per_information10 IS NULL))
AND (( ppf.per_information11 = X_per_information11)
   OR (ppf.per_information11 IS NULL AND X_per_information11 IS NULL))
AND (( ppf.per_information12 = X_per_information12)
   OR (ppf.per_information12 IS NULL AND X_per_information12 IS NULL))
AND (( ppf.per_information13 = X_per_information13)
   OR (ppf.per_information13 IS NULL AND X_per_information13 IS NULL))
AND (( ppf.per_information14 = X_per_information14)
   OR (ppf.per_information14 IS NULL AND X_per_information14 IS NULL))
AND (( ppf.per_information15 = X_per_information15)
   OR (ppf.per_information15 IS NULL AND X_per_information15 IS NULL))
AND (( ppf.per_information16 = X_per_information16)
   OR (ppf.per_information16 IS NULL AND X_per_information16 IS NULL))
AND (( ppf.per_information17 = X_per_information17)
   OR (ppf.per_information17 IS NULL AND X_per_information17 IS NULL))
AND (( ppf.per_information18 = X_per_information18)
   OR (ppf.per_information18 IS NULL AND X_per_information18 IS NULL))
AND (( ppf.per_information19 = X_per_information19)
   OR (ppf.per_information19 IS NULL AND X_per_information19 IS NULL))
AND (( ppf.per_information20 = X_per_information20)
   OR (ppf.per_information20 IS NULL AND X_per_information20 IS NULL))
AND (( ppf.per_information21 = X_per_information21)
   OR (ppf.per_information21 IS NULL AND X_per_information21 IS NULL))
AND (( ppf.per_information22 = X_per_information22)
   OR (ppf.per_information22 IS NULL AND X_per_information22 IS NULL))
AND (( ppf.per_information23 = X_per_information23)
   OR (ppf.per_information23 IS NULL AND X_per_information23 IS NULL))
AND (( ppf.per_information24 = X_per_information24)
   OR (ppf.per_information24 IS NULL AND X_per_information24 IS NULL))
AND (( ppf.per_information25 = X_per_information25)
   OR (ppf.per_information25 IS NULL AND X_per_information25 IS NULL))
AND (( ppf.per_information26 = X_per_information26)
   OR (ppf.per_information26 IS NULL AND X_per_information26 IS NULL))
AND (( ppf.per_information27 = X_per_information27)
   OR (ppf.per_information27 IS NULL AND X_per_information27 IS NULL))
AND (( ppf.per_information28 = X_per_information28)
   OR (ppf.per_information28 IS NULL AND X_per_information28 IS NULL))
AND (( ppf.per_information29 = X_per_information29)
   OR (ppf.per_information29 IS NULL AND X_per_information29 IS NULL))
AND (( ppf.per_information30 = X_per_information30)
   OR (ppf.per_information30 IS NULL AND X_per_information30 IS NULL))
AND (( ppf.known_as = X_known_as)
   OR (ppf.known_as IS NULL AND X_known_as IS NULL));
--
CURSOR Check_For_Person_Rows IS
SELECT 'Y'
FROM   per_all_people_f
WHERE  person_id = X_Contact_Person_Id
HAVING COUNT(person_id) > 1;
--
-- bug fix 4281500 start here --
-- Cursor to check whether
-- relationship with an end date
-- earlier than date of brith exists.

cursor csr_chk_rel is
   select contact_relationship_id
   from   per_contact_relationships
   where contact_person_id = X_contact_Person_Id
   and date_end < x_date_of_birth;

l_con_rel_id per_contact_relationships.contact_relationship_id%type;

-- cursor to fetch contact relationship details
-- of the records to be updated.

cursor csr_rel is
   select c.*,rowidtochar(rowid) row_id
   from   per_contact_relationships c
   where  c.contact_person_id = X_contact_Person_Id
   and c.date_start < x_date_of_birth;

-- bug fix 4281500 ends here -----

---------------------------------------------------------
-- Local Procedure to Update Person
--
--
PROCEDURE Update_Person IS
--
   l_full_name     VARCHAR2(240);
   l_global_name   VARCHAR2(240);
   l_local_name    VARCHAR2(240);
   l_order_name    VARCHAR2(240);
   l_person_id     NUMBER;
   l_rowid         VARCHAR2(30):=null;
   l_dup_name      VARCHAR2(1);
   l_previous_last_name per_all_people_f.previous_last_name%TYPE;
   l_email_address      per_all_people_f.email_address%TYPE;
   l_employee_number    per_all_people_f.employee_number%TYPE;
   l_applicant_number   per_all_people_f.applicant_number%TYPE;
   l_npw_number         per_all_people_f.npw_number%TYPE;
   --
   CURSOR Lock_Person_Row IS
     SELECT ROWIDTOCHAR(ROWID)
          , previous_last_name, email_address, employee_number -- #3889584
          , applicant_number, npw_number
     FROM   per_all_people_f
     WHERE  person_id = X_Contact_Person_Id;
--Locking of row is cauising ORA-1002, if any statements present in
--cursor for loop. Have logged bug 2030142 for this, for now will
--remove the lock.
--  FOR UPDATE OF person_id;
--
-- Changes for HR/TCA Merge
  cursor c_person is
    select *
    from   per_all_people_f
    where  ROWID =CHARTOROWID(l_rowid);
--
  l_person per_all_people_f%rowtype;
  --
  -- Bug 4295302
  --
  CURSOR get_old_ppf (cv_person_id IN NUMBER)
  IS
     SELECT person_id, business_group_id, effective_start_date,
            effective_end_date, date_of_birth, date_of_death,
            on_military_service, marital_status, registered_disabled_flag,
            sex, student_status, benefit_group_id, coord_ben_no_cvg_flag,
            uses_tobacco_flag, coord_ben_med_pln_no, per_information10,
            dpdnt_vlntry_svce_flag, receipt_of_death_cert_date, attribute1,
            attribute2, attribute3, attribute4, attribute5, attribute6,
            attribute7, attribute8, attribute9, attribute10, attribute11,
            attribute12, attribute13, attribute14, attribute15, attribute16,
            attribute17, attribute18, attribute19, attribute20, attribute21,
            attribute22, attribute23, attribute24, attribute25, attribute26,
            attribute27, attribute28, attribute29, attribute30, NULL
       FROM per_all_people_f
      WHERE x_session_date BETWEEN effective_start_date AND effective_end_date
        AND person_id = cv_person_id;
  --
  l_ppf_ler_new_rec   ben_ppf_ler.g_ppf_ler_rec;
  l_ppf_ler_old_rec   ben_ppf_ler.g_ppf_ler_rec;
  --
  -- Bug 4295302
  --
--
BEGIN
  -- Get the New Full Name
  --hr_person.derive_full_name (x_first_name, x_middle_names,
  --   x_last_name, x_known_as, x_title, x_suffix, x_pre_name_adjunct,
  --   x_date_of_birth, x_person_type_id, x_business_group_id, l_full_name,
  --   l_dup_name);
--
-- Select for update
--
  --
  -- Bug 4295302
  --
  open get_old_ppf(cv_person_id => x_contact_person_id);
    --
    fetch get_old_ppf into l_ppf_ler_old_rec;
    --
  close get_old_ppf;
  --
  l_ppf_ler_new_rec.business_group_id		:= x_business_group_id;
  l_ppf_ler_new_rec.person_id			:= X_Contact_Person_Id;
  l_ppf_ler_new_rec.effective_start_date	:= x_session_date;
  l_ppf_ler_new_rec.effective_end_date          := l_ppf_ler_old_rec.effective_end_date;
  l_ppf_ler_new_rec.date_of_birth               := x_date_of_birth;
  l_ppf_ler_new_rec.date_of_death               := x_date_of_death;
  l_ppf_ler_new_rec.marital_status              := l_ppf_ler_old_rec.marital_status;
  l_ppf_ler_new_rec.on_military_service         := l_ppf_ler_old_rec.on_military_service;
  l_ppf_ler_new_rec.registered_disabled_flag    := l_ppf_ler_old_rec.registered_disabled_flag;
  l_ppf_ler_new_rec.sex                         := x_sex;
  l_ppf_ler_new_rec.student_status              := l_ppf_ler_old_rec.student_status;
  l_ppf_ler_new_rec.coord_ben_med_pln_no        := l_ppf_ler_old_rec.coord_ben_med_pln_no;
  l_ppf_ler_new_rec.coord_ben_no_cvg_flag       := l_ppf_ler_old_rec.coord_ben_no_cvg_flag;
  l_ppf_ler_new_rec.uses_tobacco_flag           := l_ppf_ler_old_rec.uses_tobacco_flag; --
  l_ppf_ler_new_rec.benefit_group_id            := l_ppf_ler_old_rec.benefit_group_id; --
  l_ppf_ler_new_rec.DPDNT_VLNTRY_SVCE_FLAG      := l_ppf_ler_old_rec.dpdnt_vlntry_svce_flag; --
  l_ppf_ler_new_rec.RECEIPT_OF_DEATH_CERT_DATE  := l_ppf_ler_old_rec.receipt_of_death_cert_date; --
  l_ppf_ler_new_rec.per_information10           := x_per_information10;
  l_ppf_ler_new_rec.attribute1                  := x_attribute1;
  l_ppf_ler_new_rec.attribute2                  := x_attribute2;
  l_ppf_ler_new_rec.attribute3                  := x_attribute3;
  l_ppf_ler_new_rec.attribute4                  := x_attribute4;
  l_ppf_ler_new_rec.attribute5                  := x_attribute5;
  l_ppf_ler_new_rec.attribute6                  := x_attribute6;
  l_ppf_ler_new_rec.attribute7                  := x_attribute7;
  l_ppf_ler_new_rec.attribute8                  := x_attribute8;
  l_ppf_ler_new_rec.attribute9                  := x_attribute9;
  l_ppf_ler_new_rec.attribute10                 := x_attribute10;
  l_ppf_ler_new_rec.attribute11                 := x_attribute11;
  l_ppf_ler_new_rec.attribute12                 := x_attribute12;
  l_ppf_ler_new_rec.attribute13                 := x_attribute13;
  l_ppf_ler_new_rec.attribute14                 := x_attribute14;
  l_ppf_ler_new_rec.attribute15                 := x_attribute15;
  l_ppf_ler_new_rec.attribute16                 := x_attribute16;
  l_ppf_ler_new_rec.attribute17                 := x_attribute17;
  l_ppf_ler_new_rec.attribute18                 := x_attribute18;
  l_ppf_ler_new_rec.attribute19                 := x_attribute19;
  l_ppf_ler_new_rec.attribute20                 := x_attribute20;
  l_ppf_ler_new_rec.attribute21                 := x_attribute21;
  l_ppf_ler_new_rec.attribute22                 := x_attribute22;
  l_ppf_ler_new_rec.attribute23                 := x_attribute23;
  l_ppf_ler_new_rec.attribute24                 := x_attribute24;
  l_ppf_ler_new_rec.attribute25                 := x_attribute25;
  l_ppf_ler_new_rec.attribute26                 := x_attribute26;
  l_ppf_ler_new_rec.attribute27                 := x_attribute27;
  l_ppf_ler_new_rec.attribute28                 := x_attribute28;
  l_ppf_ler_new_rec.attribute29                 := x_attribute29;
  l_ppf_ler_new_rec.attribute30                 := x_attribute30;
  --
  -- Bug 4295302
  --
  OPEN Lock_Person_Row;
  LOOP
    FETCH Lock_Person_Row
          INTO l_rowid
             , l_previous_last_name, l_email_address, l_employee_number
             , l_applicant_number, l_npw_number;
    EXIT WHEN Lock_Person_Row%NOTFOUND;

   hr_utility.set_location('update_contact.update_person',10);

   hr_person_name.derive_person_names  -- #3889584
   (p_format_name        =>  NULL,  -- generate all names
    p_business_group_id  =>  x_business_group_id,
    p_person_id          =>  NULL,  -- X_Contact_Person_Id
    p_first_name         =>  x_first_name,
    p_middle_names       =>  x_middle_names,
    p_last_name          =>  x_last_name,
    p_known_as           =>  x_known_as,
    p_title              =>  x_title,
    p_suffix             =>  x_suffix,
    p_pre_name_adjunct   =>  x_pre_name_adjunct,
    p_date_of_birth      =>  x_date_of_birth,
    p_previous_last_name =>  l_previous_last_name  ,
    p_email_address      =>  l_email_address  ,
    p_employee_number    =>  l_employee_number  ,
    p_applicant_number   =>  l_applicant_number  ,
    p_npw_number         =>  l_npw_number  ,
    p_per_information1   =>  x_per_information1  ,
    p_per_information2   =>  x_per_information2  ,
    p_per_information3   =>  x_per_information3  ,
    p_per_information4   =>  x_per_information4  ,
    p_per_information5   =>  x_per_information5  ,
    p_per_information6   =>  x_per_information6  ,
    p_per_information7   =>  x_per_information7  ,
    p_per_information8   =>  x_per_information8  ,
    p_per_information9   =>  x_per_information9  ,
    p_per_information10  =>  x_per_information10  ,
    p_per_information11  =>  x_per_information11  ,
    p_per_information12  =>  x_per_information12  ,
    p_per_information13  =>  x_per_information13  ,
    p_per_information14  =>  x_per_information14  ,
    p_per_information15  =>  x_per_information15  ,
    p_per_information16  =>  x_per_information16  ,
    p_per_information17  =>  x_per_information17  ,
    p_per_information18  =>  x_per_information18  ,
    p_per_information19  =>  x_per_information19  ,
    p_per_information20  =>  x_per_information20  ,
    p_per_information21  =>  x_per_information21  ,
    p_per_information22  =>  x_per_information22  ,
    p_per_information23  =>  x_per_information23  ,
    p_per_information24  =>  x_per_information24  ,
    p_per_information25  =>  x_per_information25  ,
    p_per_information26  =>  x_per_information26  ,
    p_per_information27  =>  x_per_information27  ,
    p_per_information28  =>  x_per_information28  ,
    p_per_information29  =>  x_per_information29  ,
    p_per_information30  =>  x_per_information30  ,
    p_attribute1         =>  x_attribute1  ,
    p_attribute2         =>  x_attribute2  ,
    p_attribute3         =>  x_attribute3  ,
    p_attribute4         =>  x_attribute4  ,
    p_attribute5         =>  x_attribute5  ,
    p_attribute6         =>  x_attribute6  ,
    p_attribute7         =>  x_attribute7  ,
    p_attribute8         =>  x_attribute8  ,
    p_attribute9         =>  x_attribute9  ,
    p_attribute10        =>  x_attribute10  ,
    p_attribute11        =>  x_attribute11  ,
    p_attribute12        =>  x_attribute12  ,
    p_attribute13        =>  x_attribute13  ,
    p_attribute14        =>  x_attribute14  ,
    p_attribute15        =>  x_attribute15  ,
    p_attribute16        =>  x_attribute16  ,
    p_attribute17        =>  x_attribute17  ,
    p_attribute18        =>  x_attribute18  ,
    p_attribute19        =>  x_attribute19  ,
    p_attribute20        =>  x_attribute20  ,
    p_attribute21        =>  x_attribute21  ,
    p_attribute22        =>  x_attribute22  ,
    p_attribute23        =>  x_attribute23,
    p_attribute24        =>  x_attribute24,
    p_attribute25        =>  x_attribute25,
    p_attribute26        =>  x_attribute26,
    p_attribute27        =>  x_attribute27,
    p_attribute28        =>  x_attribute28,
    p_attribute29        =>  x_attribute29,
    p_attribute30        =>  x_attribute30,
    p_full_name          => l_full_name,
    p_order_name         => l_order_name,
    p_global_name        => l_global_name,
    p_local_name         => l_local_name,
    p_duplicate_flag     => l_dup_name
    );
  UPDATE PER_ALL_PEOPLE_F
  SET
    person_type_id                            =    -- X_Person_Type_Id,
                 hr_person_type_usage_info.get_default_person_type_id(X_Person_Type_Id),
    last_name                                 =    X_Last_Name,
    comment_id                                =    X_Comment_Id,
    date_of_birth                             =    X_Date_Of_Birth,
    date_of_death                             =    x_date_of_death,
    first_name                                =    X_First_Name,
    full_name                                 =    l_full_name,
    middle_names                              =    X_Middle_Names,
    sex                                       =    X_Sex,
    title                                     =    X_Title,
    pre_name_adjunct			                   =    X_pre_name_adjunct,
    suffix				                         =    X_SUFFIX,
    national_identifier                       =    X_National_Identifier,
    attribute_category                        =    X_Attribute_Category,
    attribute1                                =    X_Attribute1,
    attribute2                                =    X_Attribute2,
    attribute3                                =    X_Attribute3,
    attribute4                                =    X_Attribute4,
    attribute5                                =    X_Attribute5,
    attribute6                                =    X_Attribute6,
    attribute7                                =    X_Attribute7,
    attribute8                                =    X_Attribute8,
    attribute9                                =    X_Attribute9,
    attribute10                               =    X_Attribute10,
    attribute11                               =    X_Attribute11,
    attribute12                               =    X_Attribute12,
    attribute13                               =    X_Attribute13,
    attribute14                               =    X_Attribute14,
    attribute15                               =    X_Attribute15,
    attribute16                               =    X_Attribute16,
    attribute17                               =    X_Attribute17,
    attribute18                               =    X_Attribute18,
    attribute19                               =    X_Attribute19,
    attribute20                               =    X_Attribute20,
    attribute21                               =    X_Attribute21,
    attribute22                               =    X_Attribute22,
    attribute23                               =    X_Attribute23,
    attribute24                               =    X_Attribute24,
    attribute25                               =    X_Attribute25,
    attribute26                               =    X_Attribute26,
    attribute27                               =    X_Attribute27,
    attribute28                               =    X_Attribute28,
    attribute29                               =    X_Attribute29,
    attribute30                               =    X_Attribute30,
    per_information_category	              =    X_Per_Information_category,
    per_information1                          =    X_per_information1,
    per_information2                          =    X_per_information2,
    per_information3                          =    X_per_information3,
    per_information4                          =    X_per_information4,
    per_information5                          =    X_per_information5,
    per_information6                          =    X_per_information6,
    per_information7                          =    X_per_information7,
    per_information8                          =    X_per_information8,
    per_information9                          =    X_per_information9,
    per_information10                         =    X_per_information10,
    per_information11                         =    X_per_information11,
    per_information12                         =    X_per_information12,
    per_information13                         =    X_per_information13,
    per_information14                         =    X_per_information14,
    per_information15                         =    X_per_information15,
    per_information16                         =    X_per_information16,
    per_information17                         =    X_per_information17,
    per_information18                         =    X_per_information18,
    per_information19                         =    X_per_information19,
    per_information20                         =    X_per_information20,
    per_information21                         =    X_per_information21,
    per_information22                         =    X_per_information22,
    per_information23                         =    X_per_information23,
    per_information24                         =    X_per_information24,
    per_information25                         =    X_per_information25,
    per_information26                         =    X_per_information26,
    per_information27                         =    X_per_information27,
    per_information28                         =    X_per_information28,
    per_information29                         =    X_per_information29,
    per_information30                         =    X_per_information30,
    known_as                                  =    X_known_as,
    global_name                               =    l_global_name,
    local_name                                =    l_local_name,
    order_name                                =    l_order_name

  WHERE ROWID = CHARTOROWID(l_rowid);
   hr_utility.set_location('update_contact.update_person',20);


  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
--
-- PTU changes
   hr_utility.set_location('update_contact.update_person',30);

--
hr_per_type_usage_internal.maintain_person_type_usage
(p_effective_date       => X_Session_Date
,p_person_id            => X_Contact_Person_Id
,p_person_type_id       => X_Person_Type_Id
,p_datetrack_update_mode => 'CORRECTION'   --since the person record is only corrected too
);
--
   hr_utility.set_location('update_contact.update_person',40);

-- end of PTU changes
--

  END LOOP;
  --
  -- Bug 4295302
  --
  -- This procedure is will create potential life event reasons if the Person Change
  -- criteria is met (a part of Oracle Advanced Benefits functionality)
  --
  ben_ppf_ler.ler_chk( p_old            => l_ppf_ler_old_rec
                      ,p_new            => l_ppf_ler_new_rec
                      ,p_effective_date => x_session_date );

  --
  -- Bug 4295302
  --
  --HR/TCA merge changes
  if l_rowid is not null then
    open c_person;
       --
       fetch c_person into l_person;
       --
    close c_person;
    hr_utility.set_location('update_person - before TCA update',100);
    hr_utility.set_location('update_person - party_id='||l_person.party_id,200);
    hr_utility.set_location('update_person - first_name='||l_person.first_name,200);
    --
    per_hrtca_merge.update_tca_person(p_Rec => l_person);
    --
    hr_utility.set_location('update_person - after TCA update',300);
  end if;
  CLOSE Lock_Person_Row;
END Update_Person;
---------------------------------------------
-- Main Procedure
--
BEGIN
--
  -- Determine whether the person has been updated
  -- i.e. check whether the Contact Only flag = 'Y' and if it is then
  -- check that the actual values have changed on the person record
  -- for the current person record
  --
  hr_utility.set_location('per_contact_relationships_pkg.update_contact',1);
  IF X_Contact_Only = 'Y' THEN
     -- bug fix 4281500 starts here --
     -- check if there exist a reslationship record with end date
     -- earlier than new DOB.

     if x_date_of_birth is not null then
        open csr_chk_rel;
        fetch csr_chk_rel into l_con_rel_id;
        if csr_chk_rel%found then
           close csr_chk_rel;
           hr_utility.set_message(
            applid         => 800,
            l_message_name => 'PER_449600_INVALD_DOB');
            --
           hr_utility.raise_error;
        end if;
        close csr_chk_rel;
     end if;

     -- bug fix 4281500 ends here --
     OPEN  Check_Person_Changed;
     FETCH Check_Person_Changed INTO l_exists;
     CLOSE Check_Person_Changed;
     --
     IF l_exists = 'N' THEN
     --
     -- If the person has details in the future or past then we must ask
     -- whether these should be overridden. The first time this code is
     -- called REENTRY_FLAG = 1 and the check is performed. If we need to
     -- ask the question set REENTRY_FLAG = 2 and exit.
     -- The second time in will happen if the update is to proceed.
     --
hr_utility.trace('Calling Check_For_Person_Rows');
        IF X_Reentry_Flag = 1 THEN
           OPEN Check_For_Person_Rows;
           FETCH Check_For_Person_Rows INTO l_others_exist;
           CLOSE Check_For_Person_Rows;
           --
           IF l_others_exist = 'Y' THEN
              X_Reentry_Flag := 2;
              RETURN;
           END IF;
        END IF;
        hr_utility.set_location('update_contact',2);
        Update_Person;
       -- bug fix 4281500 starts here --
        -- call to update the relationship records
        -- having start date earlier than date of birth
        if x_date_of_birth is not null then
          for rel_rec in csr_rel
          loop
           --
           PER_CONTACT_RELATIONSHIPS_PKG.Update_Row(
             X_Rowid                => rel_rec.Row_Id,
             X_Contact_Relationship_Id=> rel_rec.Contact_Relationship_Id,
             X_Business_Group_Id    => rel_rec.Business_Group_Id,
             X_Person_Id            => rel_rec.Person_Id,
             X_Contact_Person_Id    => rel_rec.Contact_Person_Id,
             X_Contact_Type         => rel_rec.Contact_Type,
             X_Comments             => rel_rec.Comments,
             X_Bondholder_Flag      => rel_rec.Bondholder_Flag,
             X_third_party_pay_Flag       => rel_rec.third_party_pay_Flag,
             X_Primary_Contact_Flag => rel_rec.Primary_Contact_Flag,
             X_Cont_Attribute_Category=> rel_rec.Cont_Attribute_Category,
             X_Cont_Attribute1      => rel_rec.Cont_Attribute1,
             X_Cont_Attribute2      => rel_rec.Cont_Attribute2,
             X_Cont_Attribute3      => rel_rec.Cont_Attribute3,
             X_Cont_Attribute4      => rel_rec.Cont_Attribute4,
             X_Cont_Attribute5      => rel_rec.Cont_Attribute5,
             X_Cont_Attribute6      => rel_rec.Cont_Attribute6,
             X_Cont_Attribute7      => rel_rec.Cont_Attribute7,
             X_Cont_Attribute8      => rel_rec.Cont_Attribute8,
             X_Cont_Attribute9      => rel_rec.Cont_Attribute9,
             X_Cont_Attribute10     => rel_rec.Cont_Attribute10,
             X_Cont_Attribute11     => rel_rec.Cont_Attribute11,
             X_Cont_Attribute12     => rel_rec.Cont_Attribute12,
             X_Cont_Attribute13     => rel_rec.Cont_Attribute13,
             X_Cont_Attribute14     => rel_rec.Cont_Attribute14,
             X_Cont_Attribute15     => rel_rec.Cont_Attribute15,
             X_Cont_Attribute16     => rel_rec.Cont_Attribute16,
             X_Cont_Attribute17     => rel_rec.Cont_Attribute17,
             X_Cont_Attribute18     => rel_rec.Cont_Attribute18,
             X_Cont_Attribute19     => rel_rec.Cont_Attribute19,
             X_Cont_Attribute20     => rel_rec.Cont_Attribute20,
             X_Cont_Information_Category => rel_rec.Cont_Information_Category,
             X_Cont_Information1      => rel_rec.Cont_Information1,
             X_Cont_Information2      => rel_rec.Cont_Information2,
             X_Cont_Information3      => rel_rec.Cont_Information3,
             X_Cont_Information4      => rel_rec.Cont_Information4,
             X_Cont_Information5      => rel_rec.Cont_Information5,
             X_Cont_Information6      => rel_rec.Cont_Information6,
             X_Cont_Information7      => rel_rec.Cont_Information7,
             X_Cont_Information8      => rel_rec.Cont_Information8,
             X_Cont_Information9      => rel_rec.Cont_Information9,
             X_Cont_Information10     => rel_rec.Cont_Information10,
             X_Cont_Information11     => rel_rec.Cont_Information11,
             X_Cont_Information12     => rel_rec.Cont_Information12,
             X_Cont_Information13     => rel_rec.Cont_Information13,
             X_Cont_Information14     => rel_rec.Cont_Information14,
             X_Cont_Information15     => rel_rec.Cont_Information15,
             X_Cont_Information16     => rel_rec.Cont_Information16,
             X_Cont_Information17     => rel_rec.Cont_Information17,
             X_Cont_Information18     => rel_rec.Cont_Information18,
             X_Cont_Information19     => rel_rec.Cont_Information19,
             X_Cont_Information20     => rel_rec.Cont_Information20,
             X_Session_Date         => X_Session_Date,
             X_Date_Start           => X_date_of_birth,
             X_Start_Life_Reason_Id => rel_rec.start_life_reason_id,
             X_Date_End             => rel_rec.date_end,
             X_End_Life_Reason_Id   => rel_rec.end_life_reason_id,
             X_Rltd_Per_Rsds_W_Dsgntr_Flag => rel_rec.rltd_per_rsds_w_dsgntr_flag,
             X_Personal_Flag        => rel_rec.personal_flag,
             X_Sequence_Number      => rel_rec.sequence_number,
             X_Dependent_Flag       => rel_rec.dependent_flag,
             X_Beneficiary_Flag     => rel_rec.beneficiary_flag
           );

           --
         end loop;
       end if;
        -- bug fix 4281500 ends here --
     END IF;
  END IF;
  --
  --
  hr_utility.set_location('update_contact',3);

  /*IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;*/-- fix for bug 4763755.

END Update_Contact;

END PER_CONTACT_RELATIONSHIPS_PKG;

/
