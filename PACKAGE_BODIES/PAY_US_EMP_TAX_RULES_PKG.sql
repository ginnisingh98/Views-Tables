--------------------------------------------------------
--  DDL for Package Body PAY_US_EMP_TAX_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_EMP_TAX_RULES_PKG" as
/* $Header: pyustaxr.pkb 115.13 2004/01/21 07:18:21 saurgupt ship $ */
--
--
 /*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : pay_us_emp_tax_rules_pkg

    Description : This package holds building blocks used in maintenace
                  of US employee tax rule using PER_ASSIGNMENT_EXTRA_INFO
                  table.

    Uses        : hr_utility

    Change List
    -----------
    Date        Name          Vers    Description
    ----        ----          ----    -----------
    OCT-22-1993 RMAMGAIN      1.0     Created with following proc.
                                               Insert_row
                                               Update_row
                                               Lock_row
                                               Delete_row
                                               check_unique
                                               get_set_def
    NOV-09-1993 RMAMGAIN      40.1    Created Procs to call
                                      call element entry API.
    NOV-14-1993 RMAMGAIN      40.2    Changes to create Ele. Ent.
                                      for PAY VALUE.
    NOV-21-1993 RMAMGAIN      40.5    Change Time in state and
                                      withholding allow. Columns
    SEP-28-1994 RMAMGAIN      40.3    BUG 1257, BUG1257
    MAR-06-1995 GPAYTONM      40.9    Added more user friendly error messages
                                      for uniqueness check
                                      (HR_7322_TAX_ONE_RULE_ONLY)
    26-APR-95	gpaytonm      40.11   Added function call to addr_val to get geo code
    22-JUN-95   gpaytonm      40.12   Changed insert_def_loc to insert default resident county
                                      record and default school district where appropriate.
                                      Changed references to PAY_US_CITIES to PAY_US_CITY_NAMES
                                      + PAY_US_ZIP_CODES
    12-JUL-95   gpaytonm      40.13   Made sure that vertex tax entry not inserted
                                      for default local county tax record.
    25-JUL-95     AForte              Changed tokenised message
                                      HR_7322_TAX_ONE_RULE_ONLY
                                      to hard coded messages
                                      HR_7719_TAX_ONE_RULE_ONLY
                                      HR_7720_TAX_ONE_RULE_ONLY and
                                      Changed tokenised message
                                      HR_13140_TAX_ELEMNT_ERROR where token was
                                      'Workers Compensation', to
                                      HR_7713_TAX_ELEMENT_ERROR
    03-AUG-95	gpaytonm       40.14  Changed get_set_Def to default_tax. Added
                                      on_insert to be called from form such that
                                      defaulting VERTEX entries is easier to
                                      control - on_insert always creates one,
                                      but when defaulting want may not want
                                      a vertex record but do want a tax record.
                                      Added code to cater for unknown cities -
                                      inserts county record in this case. Altered
                                      code to only insert one vertex entry when
                                      work and res cities are the same.
                                      Renamed create_tax_ele_Entry to create_vertex_entry
    28-SEP-95	gpaytonm	40.16	Added COMMIT in default_tax if no error
					- rather than committing on form

    22-AUG-96   lwthomps        40.18   Added 0 default values in defualt tax
                                        for state and federal supplemental
                                        tax override rates. #316663
    10-SEP-96   lwthomps        40.19   Now a county tax record is created
                                        for both the work and resident
                                        locality. #391886
    16-SEP-96   lwthomps        40.20   #390941 version 40.19skipped for
                                        P1 fix.  40.20 is 40.18 with changes.
                                        Now it will only create county record
                                        after it checks one doesn't already
                                        exists.

    17-SEP-96   lwthomps        40.21   #390941 removed unwanted dependency on
                                        316663.

    23-SEP-96   lwthomps        40.22   This merges all changes from 40.19
                                        and 40.20.  Also adds new Procedure called
                                        Create_County_Record that is called from
                                        form and creates a county record if a
                                        city record is created through the form.

    11-NOV-96   lwthomps        40.23   Adds a call to PAY_ASG_GEO_PKG.create_asg_geo_row.
                                        This is dependent on the existence of the
                                        new table: pay_us_asg_reporting.
                                        BUG: 420465.

    13-Jan-97   lwthomps        40.24   School Ditrict Changes:
                                        No longer allows the same school district code
                                        in multiple cities in the same state.  SD codes
                                        are only defaulted for Primary residences now,
                                        and if that school district exists somewhere else
                                        (another locality for this assignment) then it
                                        is set to NULL.
                                        Added Procedure Update_attribute to maintain
                                        SD codes.

    12-Feb-97   lwthomps        40.25   Leap Frog Version

    20-Feb-97   lwthomps        40.26   Merged changes from preivous leap
                                        frogged versions.
    20-Feb-97   lwthomps        40.27   Defaulting of tax rules.  Now creates
                                        records from the assignment and
                                        address forms.  268389


    05-Mar-97   jalloun         40.28   Changed all calls to sys.dual to
                                        new standard.

    07-Mar-97   lwthomps        40.29   Defaulting of tax rules.
                                        Now catches filing status and
                                        allowances from the Federal record
                                        if it is specified at the GRE level
                                        and there is an appropriate filing
                                        status for the state:
                               FIT                   SIT
                              ----------------      -------------
                              Single            ->  Single
                              Married Joint     ->  Married
                              Married Sep       ->  Married
                              Head of House     ->  Head of House

    07-Mar-97   lwthomps        40.30   Cleaned up change log.

    08-Mar-97   lwthomps        40.31   268389.  Added check for when
                                        state tax rules had been defined
                                        but no default standard chosen.

    31-Mar-97   lwthomps        40.32   268389.  Added more messages
                                        for the assignment form in default
                                        tax with validation.  Changed
                                        the date effective sections in
                                        create_vertex_entry to ensure
                                        duplicate records are not created
                                        in cases where people move into
                                        a jurisdiction earlier than the
                                        original startdate of the element
                                        entry.

    19-May-97   lwthomps        40.33   495165.  Added additional validation
                                        to default_tax_with validation such
                                        that it will not update the percent time
                                        in state if the sum accross existing
                                        records is not = 0%.

    05-JUN-97   lwthomps        40.34   Created an overloaded version of
                                        default tax such that the package
                                        only commits when entered from the
                                        Tax Rules Form.
                                        This is to fix: 501979
    16-JUL-97   lwthomps        40.35   Added additional validation in the
                                        create_vertex_entry procedure so that
                                        it checks that a vertex element entry
                                        of the same jurisdiction does not exist
                                        prior to inserting.  Previously this
                                        validation was done on the
                                        per_assignment_extra_information records
                                        only.
    07-NOV-97   lwthomps        40.36   Added additional erroring for
                                        invalid resident address and
                                        existence of tax records.  If
                                        a tax record has been deleted
                                        and the element_entry is modified
                                        it will roll back and error.
    07-NOV-97   lwthomps        40.37   Added one more check for misc
                                        error raised by other packages.
    18-MAY-98   ekim            40.39   Bug #657312.  Modified csr_qualify_info
                                        to validate against the date.
    21-Apr-99   scgrant         115.1   Multi-radix changes.
    14-Feb-00   alogue          115.4   Utf8 support.
    18-JAN-02   fusman          115.5   Added dbdrv command.
    24-JUN-02   rsirigir        115.8   Modified checkfile syntax as
                                        per bug 2429703
    09-AUG-02   ahanda          115.12  Changed cursor vtx_info.
    21-JAN-04   saurgupt        115.13  Bug 3354046: Changed definitions of
                                        cursors csr_filing_status, csr_wc_element
                                        and csr_fed_or_def to remove FTS and MJC.
*/

--
PROCEDURE Insert_Row(X_Rowid                    IN OUT nocopy VARCHAR2,
                     X_Assignment_Extra_Info_Id IN OUT nocopy NUMBER,
                     X_Assignment_Id                   NUMBER,
                     X_Information_Type                VARCHAR2,
                     X_session_date                    DATE,
                     X_jurisdiction                    VARCHAR2,
                     X_Aei_Information_Category        VARCHAR2 default null,
                     X_Aei_Information1                VARCHAR2 default null,
                     X_Aei_Information2                VARCHAR2 default null,
                     X_Aei_Information3                VARCHAR2 default null,
                     X_Aei_Information4                VARCHAR2 default null,
                     X_Aei_Information5                VARCHAR2 default null,
                     X_Aei_Information6                VARCHAR2 default null,
                     X_Aei_Information7                VARCHAR2 default null,
                     X_Aei_Information8                VARCHAR2 default null,
                     X_Aei_Information9                VARCHAR2 default null,
                     X_Aei_Information10               VARCHAR2 default null,
                     X_Aei_Information11               VARCHAR2 default null,
                     X_Aei_Information12               VARCHAR2 default null,
                     X_Aei_Information13               VARCHAR2 default null,
                     X_Aei_Information14               VARCHAR2 default null,
                     X_Aei_Information15               VARCHAR2 default null,
                     X_Aei_Information16               VARCHAR2 default null,
                     X_Aei_Information17               VARCHAR2 default null,
                     X_Aei_Information18               VARCHAR2 default null,
                     X_Aei_Information19               VARCHAR2 default null,
                     X_Aei_Information20               VARCHAR2 default null
 ) IS
   X_User_Id  NUMBER;
   X_Login_Id NUMBER;
   X_ret      NUMBER;
   X_time     varchar2(20);
   x_other_sd VARCHAR2(20);
   X_sd_rowid   VARCHAR2(30);
--
   CURSOR C IS SELECT rowid FROM PER_ASSIGNMENT_EXTRA_INFO
           WHERE assignment_extra_info_id = X_Assignment_Extra_Info_Id;
--
   CURSOR C2 IS SELECT per_assignment_extra_info_s.nextval FROM sys.dual;
--
-- Because of how we report school tax balances we need to check
-- that each local record within a state has a unique SD code
--
   CURSOR check_sd IS
       SELECT rowid
       FROM per_assignment_extra_info
       WHERE assignment_id = X_Assignment_Id
       AND   aei_information9 IS NOT NULL
       AND   Information_type = 'LOCALITY'
       AND   aei_information9 = X_Aei_Information9
       AND   aei_information1 = X_aei_information1
       AND   assignment_extra_info_id <> X_assignment_extra_info_id;

 BEGIN
--
   hr_utility.set_location('pay_us_emp_tax_rules_pkg.insert_row',1);
   X_ret     := check_unique(X_Assignment_Id, X_Information_Type,
                             X_Aei_Information1, X_Aei_Information2);
--
-- if row exist raise error
-- otherwise continue
--
   if X_ret = 0
   then
   hr_utility.set_location('pay_us_emp_tax_rules_pkg.insert_row',2);
   X_User_Id := FND_PROFILE.Value('USER_ID');
   X_Login_Id := FND_PROFILE.Value('LOGIN_ID');
   hr_utility.set_location('pay_us_emp_tax_rules_pkg.insert_row',3);
   if (X_Assignment_Extra_Info_Id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_Assignment_Extra_Info_Id;
     CLOSE C2;
   end if;

      OPEN check_sd;

   hr_utility.set_location('pay_us_emp_tax_rules_pkg.insert_row',4);
   INSERT INTO PER_ASSIGNMENT_EXTRA_INFO(
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
         last_update_login,
         assignment_extra_info_id,
         assignment_id,
         information_type,
         aei_information_category,
         aei_information1,
         aei_information2,
         aei_information3,
         aei_information4,
         aei_information5,
         aei_information6,
         aei_information7,
         aei_information8,
         aei_information9,
         aei_information10,
         aei_information11,
         aei_information12,
         aei_information13,
         aei_information14,
         aei_information15,
         aei_information16,
         aei_information17,
         aei_information18,
         aei_information19,
         aei_information20)
   VALUES (
        SYSDATE,
        X_User_Id,
        SYSDATE,
        X_User_Id,
        X_Login_Id,
        X_Assignment_Extra_Info_Id,
        X_Assignment_Id,
        X_Information_Type,
        X_Aei_Information_Category,
        X_Aei_Information1,
        X_Aei_Information2,
        X_Aei_Information3,
        X_Aei_Information4,
        X_Aei_Information5,
        X_Aei_Information6,
        X_Aei_Information7,
        X_Aei_Information8,
        X_Aei_Information9,
        X_Aei_Information10,
        X_Aei_Information11,
        X_Aei_Information12,
        X_Aei_Information13,
        X_Aei_Information14,
        X_Aei_Information15,
        X_Aei_Information16,
        X_Aei_Information17,
        X_Aei_Information18,
        X_Aei_Information19,
        X_Aei_Information20
        );
--
   hr_utility.set_location('pay_us_emp_tax_rules_pkg.insert_row',5);
--
  if sql%notfound then
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE','US_EMP_TAX.INSERT_ROW');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
  end if;
  hr_utility.set_location('pay_us_emp_tax_rules_pkg.insert_row',6);
  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
    hr_utility.set_location('pay_us_emp_tax_rules_pkg.insert_row',7);
  end if;
--
    if X_information_type = 'FEDERAL' then
    pay_us_emp_tax_rules_pkg.create_wc_ele_entry(
           P_assignment_id      => X_assignment_id,
           P_session_date       => X_session_date,
           P_jurisdiction       => X_AEI_INFORMATION18);
    else /* maintain the denormalized table */
    -- Seed table for TSL
    PAY_ASG_GEO_PKG.create_asg_geo_row(P_assignment_id => X_assignment_id,
                                       P_jurisdiction  => X_jurisdiction,
                                       P_tax_unit_id   => NULL );
    end if; --Federal
    if X_information_type = 'LOCALITY' THEN
      FETCH check_sd into X_sd_rowid;

      if check_sd%FOUND THEN --Need to wipe the school district
        Update_Attribute(p_rowid           => x_sd_rowid,
                         p_attribute_type  => 'SCHOOL',
                         p_new_value       => NULL,
                         p_jurisdiction    => NULL,
                         p_state_abbrev    => NULL,
                         p_assignment_id   => NULL);

      end if; --wiping of school dst
      IF (X_aei_information9 IS NOT NULL) THEN -- School district exists
      -- Seed table for TSL (School if local)
      PAY_ASG_GEO_PKG.create_asg_geo_row(P_assignment_id => X_assignment_id,
                                         P_jurisdiction  => substr(X_jurisdiction,1,2)||'-'||X_Aei_Information9,
                        P_tax_unit_id   => NULL );
      END IF; -- School district not null


    end if; --Locality
  hr_utility.set_location('pay_us_emp_tax_rules_pkg.insert_row',9);
  CLOSE C;
--
-- RAISE error of unique check failure
-- message set in check_unique
   else
     hr_utility.raise_error;
   end if;
      CLOSE check_sd;
--
END Insert_Row;
--
------------------------------ Lock_Row ---------------------------------
--
PROCEDURE Lock_Row(X_Rowid                             VARCHAR2,
                   X_Assignment_Extra_Info_Id          NUMBER,
                   X_Assignment_Id                     NUMBER,
                   X_Information_Type                  VARCHAR2,
                   X_Aei_Information1                  VARCHAR2 default null,
                   X_Aei_Information2                  VARCHAR2 default null,
                   X_Aei_Information3                  VARCHAR2 default null,
                   X_Aei_Information4                  VARCHAR2 default null,
                   X_Aei_Information5                  VARCHAR2 default null,
                   X_Aei_Information6                  VARCHAR2 default null,
                   X_Aei_Information7                  VARCHAR2 default null,
                   X_Aei_Information8                  VARCHAR2 default null,
                   X_Aei_Information9                  VARCHAR2 default null,
                   X_Aei_Information10                 VARCHAR2 default null,
                   X_Aei_Information11                 VARCHAR2 default null,
                   X_Aei_Information12                 VARCHAR2 default null,
                   X_Aei_Information13                 VARCHAR2 default null,
                   X_Aei_Information14                 VARCHAR2 default null,
                   X_Aei_Information15                 VARCHAR2 default null,
                   X_Aei_Information16                 VARCHAR2 default null,
                   X_Aei_Information17                 VARCHAR2 default null,
                   X_Aei_Information18                 VARCHAR2 default null,
                   X_Aei_Information19                 VARCHAR2 default null,
                   X_Aei_Information20                 VARCHAR2 default null
) IS
--
  CURSOR C IS
      SELECT *
      FROM   PER_ASSIGNMENT_EXTRA_INFO
      WHERE  rowid = X_Rowid
      FOR UPDATE of Assignment_Extra_Info_Id NOWAIT;
--
  Recinfo C%ROWTYPE;
--
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
--
--
Recinfo.aei_information1  := RTRIM(Recinfo.aei_information1);
Recinfo.aei_information2  := RTRIM(Recinfo.aei_information2);
Recinfo.aei_information3  := RTRIM(Recinfo.aei_information3);
Recinfo.aei_information4  := RTRIM(Recinfo.aei_information4);
Recinfo.aei_information5  := RTRIM(Recinfo.aei_information5);
Recinfo.aei_information6  := RTRIM(Recinfo.aei_information6);
Recinfo.aei_information7  := RTRIM(Recinfo.aei_information7);
Recinfo.aei_information8  := RTRIM(Recinfo.aei_information8);
Recinfo.aei_information9  := RTRIM(Recinfo.aei_information9);
Recinfo.aei_information10 := RTRIM(Recinfo.aei_information10);
Recinfo.aei_information11 := RTRIM(Recinfo.aei_information11);
Recinfo.aei_information12 := RTRIM(Recinfo.aei_information12);
Recinfo.aei_information13 := RTRIM(Recinfo.aei_information13);
Recinfo.aei_information14 := RTRIM(Recinfo.aei_information14);
Recinfo.aei_information15 := RTRIM(Recinfo.aei_information15);
Recinfo.aei_information16 := RTRIM(Recinfo.aei_information16);
Recinfo.aei_information17 := RTRIM(Recinfo.aei_information17);
Recinfo.aei_information18 := RTRIM(Recinfo.aei_information18);
Recinfo.aei_information19 := RTRIM(Recinfo.aei_information19);
Recinfo.aei_information20 := RTRIM(Recinfo.aei_information20);
Recinfo.information_type  := RTRIM(Recinfo.information_type);
--
--
  if (
         (   (Recinfo.assignment_extra_info_id = X_Assignment_Extra_Info_Id)
          OR (    (Recinfo.assignment_extra_info_id IS NULL)
              AND (X_Assignment_Extra_Info_Id IS NULL)))
     AND (   (Recinfo.assignment_id = X_Assignment_Id)
          OR (    (Recinfo.assignment_id IS NULL)
              AND (X_Assignment_Id IS NULL)))
     AND (   (Recinfo.information_type = X_Information_Type)
          OR (    (Recinfo.information_type IS NULL)
              AND (X_Information_Type IS NULL)))
     AND (   (Recinfo.aei_information1 = X_Aei_Information1)
          OR (    (Recinfo.aei_information1 IS NULL)
              AND (X_Aei_Information1 IS NULL)))
     AND (   (Recinfo.aei_information2 = X_Aei_Information2)
          OR (    (Recinfo.aei_information2 IS NULL)
              AND (X_Aei_Information2 IS NULL)))
     AND (   (Recinfo.aei_information3 = X_Aei_Information3)
          OR (    (Recinfo.aei_information3 IS NULL)
              AND (X_Aei_Information3 IS NULL)))
     AND (   (Recinfo.aei_information4 = X_Aei_Information4)
          OR (    (Recinfo.aei_information4 IS NULL)
              AND (X_Aei_Information4 IS NULL)))
     AND (   (Recinfo.aei_information5 = X_Aei_Information5)
          OR (    (Recinfo.aei_information5 IS NULL)
              AND (X_Aei_Information5 IS NULL)))
     AND (   (Recinfo.aei_information6 = X_Aei_Information6)
          OR (    (Recinfo.aei_information6 IS NULL)
              AND (X_Aei_Information6 IS NULL)))
     AND (   (Recinfo.aei_information7 = X_Aei_Information7)
          OR (    (Recinfo.aei_information7 IS NULL)
              AND (X_Aei_Information7 IS NULL)))
     AND (   (Recinfo.aei_information8 = X_Aei_Information8)
          OR (    (Recinfo.aei_information8 IS NULL)
              AND (X_Aei_Information8 IS NULL)))
     AND (   (Recinfo.aei_information9 = X_Aei_Information9)
          OR (    (Recinfo.aei_information9 IS NULL)
              AND (X_Aei_Information9 IS NULL)))
     AND (   (Recinfo.aei_information10 = X_Aei_Information10)
          OR (    (Recinfo.aei_information10 IS NULL)
              AND (X_Aei_Information10 IS NULL)))
     AND (   (Recinfo.aei_information11 = X_Aei_Information11)
          OR (    (Recinfo.aei_information11 IS NULL)
              AND (X_Aei_Information11 IS NULL)))
     AND (   (Recinfo.aei_information12 = X_Aei_Information12)
          OR (    (Recinfo.aei_information12 IS NULL)
              AND (X_Aei_Information12 IS NULL)))
     AND (   (Recinfo.aei_information13 = X_Aei_Information13)
          OR (    (Recinfo.aei_information13 IS NULL)
              AND (X_Aei_Information13 IS NULL)))
     AND (   (Recinfo.aei_information14 = X_Aei_Information14)
          OR (    (Recinfo.aei_information14 IS NULL)
              AND (X_Aei_Information14 IS NULL)))
     AND (   (Recinfo.aei_information15 = X_Aei_Information15)
          OR (    (Recinfo.aei_information15 IS NULL)
              AND (X_Aei_Information15 IS NULL)))
     AND (   (Recinfo.aei_information16 = X_Aei_Information16)
          OR (    (Recinfo.aei_information16 IS NULL)
              AND (X_Aei_Information16 IS NULL)))
     AND (   (Recinfo.aei_information17 = X_Aei_Information17)
          OR (    (Recinfo.aei_information17 IS NULL)
              AND (X_Aei_Information17 IS NULL)))
     AND (   (Recinfo.aei_information18 = X_Aei_Information18)
          OR (    (Recinfo.aei_information18 IS NULL)
              AND (X_Aei_Information18 IS NULL)))
     AND (   (Recinfo.aei_information19 = X_Aei_Information19)
          OR (    (Recinfo.aei_information19 IS NULL)
              AND (X_Aei_Information19 IS NULL)))
     AND (   (Recinfo.aei_information20 = X_Aei_Information20)
          OR (    (Recinfo.aei_information20 IS NULL)
              AND (X_Aei_Information20 IS NULL)))
          ) then
    return;
  else
    hr_utility.set_message(801, 'FORM_RECORD_CHANGED');
    hr_utility.raise_error;
  end if;
END Lock_Row;
--
------------------------------- Update_Row -----------------------------
--
PROCEDURE Update_Row(X_Rowid                           VARCHAR2,
                     X_assignment_id                   NUMBER,
                     X_information_type                VARCHAR2,
                     X_session_date                    DATE,
                     X_jurisdiction                    VARCHAR2,
                     X_Aei_Information1                VARCHAR2 default null,
                     X_Aei_Information2                VARCHAR2 default null,
                     X_Aei_Information3                VARCHAR2 default null,
                     X_Aei_Information4                VARCHAR2 default null,
                     X_Aei_Information5                VARCHAR2 default null,
                     X_Aei_Information6                VARCHAR2 default null,
                     X_Aei_Information7                VARCHAR2 default null,
                     X_Aei_Information8                VARCHAR2 default null,
                     X_Aei_Information9                VARCHAR2 default null,
                     X_Aei_Information10               VARCHAR2 default null,
                     X_Aei_Information11               VARCHAR2 default null,
                     X_Aei_Information12               VARCHAR2 default null,
                     X_Aei_Information13               VARCHAR2 default null,
                     X_Aei_Information14               VARCHAR2 default null,
                     X_Aei_Information15               VARCHAR2 default null,
                     X_Aei_Information16               VARCHAR2 default null,
                     X_Aei_Information17               VARCHAR2 default null,
                     X_Aei_Information18               VARCHAR2 default null,
                     X_Aei_Information19               VARCHAR2 default null,
                     X_Aei_Information20               VARCHAR2 default null
                    ) IS
  X_User_Id NUMBER;
  X_Login_Id NUMBER;
  X_time     varchar2(10);
  x_other_sd VARCHAR2(20);
  X_sd_rowid   VARCHAR2(30);
--
   CURSOR check_sd IS
       SELECT rowid
       FROM per_assignment_extra_info
       WHERE assignment_id = X_Assignment_Id
       AND   X_Aei_Information9 IS NOT NULL
       AND   Information_type = 'LOCALITY'
       AND   aei_information9 = X_Aei_Information9
       AND   aei_information1 = X_aei_information1
       AND   rowid <> X_rowid;
--
BEGIN
--
  X_User_Id  := FND_PROFILE.Value('USER_ID');
  X_Login_Id := FND_PROFILE.Value('LOGIN_ID');
--
  UPDATE PER_ASSIGNMENT_EXTRA_INFO
  SET
    last_updated_by                      =   X_User_Id,
    last_update_login                    =   X_Login_Id,
    aei_information1                     =   X_Aei_Information1,
    aei_information2                     =   X_Aei_Information2,
    aei_information3                     =   X_Aei_Information3,
    aei_information4                     =   X_Aei_Information4,
    aei_information5                     =   X_Aei_Information5,
    aei_information6                     =   X_Aei_Information6,
    aei_information7                     =   X_Aei_Information7,
    aei_information8                     =   X_Aei_Information8,
    aei_information9                     =   X_Aei_Information9,
    aei_information10                    =   X_Aei_Information10,
    aei_information11                    =   X_Aei_Information11,
    aei_information12                    =   X_Aei_Information12,
    aei_information13                    =   X_Aei_Information13,
    aei_information14                    =   X_Aei_Information14,
    aei_information15                    =   X_Aei_Information15,
    aei_information16                    =   X_Aei_Information16,
    aei_information17                    =   X_Aei_Information17,
    aei_information18                    =   X_Aei_Information18,
    aei_information19                    =   X_Aei_Information19,
    aei_information20                    =   X_Aei_Information20
  WHERE rowid = X_rowid;
--
  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  else
--
  If (X_information_type = 'STATE' or
      X_information_type = 'LOCALITY')
  then
  --
  pay_us_emp_tax_rules_pkg.create_vertex_entry(
         P_mode               => 'U',
         P_assignment_id      => X_assignment_id,
         P_information_type   => X_information_type,
         P_session_date       => X_session_date,
         P_jurisdiction       => X_jurisdiction,
         P_time_in_locality   => X_aei_information10,
	 P_remainder_percent  => X_aei_information16);
  --
  -- Now update other school Record if ness
  --
  If X_information_type = 'LOCALITY' THEN
      OPEN check_sd;
      FETCH check_sd into X_sd_rowid;

      if check_sd%FOUND THEN --Need to wipe the school district
        Update_Attribute(p_rowid           => x_sd_rowid,
                         p_attribute_type  => 'SCHOOL',
                         p_new_value       => NULL,
                         p_jurisdiction    => NULL,
                         p_state_abbrev    => NULL,
                         p_assignment_id   => NULL);
      end if; --wiping of school dst
      IF (X_aei_information9 IS NOT NULL) THEN -- School district exists
     -- Seed table for TSL (School if local)
        PAY_ASG_GEO_PKG.create_asg_geo_row(P_assignment_id => X_assignment_id,
                                           P_jurisdiction  => substr(X_jurisdiction,1,2)||'-'||X_Aei_Information9,
                                           P_tax_unit_id   => NULL );
      END IF; -- School district not null
      --
      CLOSE check_sd;


  end if; --Locality
  --
  elsif X_information_type = 'FEDERAL' then
  pay_us_emp_tax_rules_pkg.create_wc_ele_entry(
         P_assignment_id      => X_assignment_id,
         P_session_date       => X_session_date,
         P_jurisdiction       => X_AEI_INFORMATION18);
--
  end if;
--
-- Now update other school Record if ness
--
  end if;
--
END Update_Row;
--
---------------------- Delete_Row --------------------------------------
--
PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
  DELETE FROM PER_ASSIGNMENT_EXTRA_INFO
  WHERE  rowid = X_Rowid;
--
  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Delete_Row;
--
------------------------------- check_unique --------------------------
--
FUNCTION  check_unique(X_assignment_id         NUMBER   default null,
                       X_information_type      VARCHAR2 default null,
                       X_state_code            VARCHAR2 default null,
                       X_locality_code         VARCHAR2 default null)
RETURN NUMBER is
ret number :=0;
--
cursor csr_federal is
       select 1 from PER_ASSIGNMENT_EXTRA_INFO
       where  assignment_id    = X_assignment_id
         and  information_type = X_information_type;
--
cursor csr_state is
       select 1 from PER_ASSIGNMENT_EXTRA_INFO
       where  assignment_id      = X_assignment_id
         and  information_type   = X_information_type
         and  Aei_Information1   = X_state_code;
--
cursor csr_local is
       select 1 from PER_ASSIGNMENT_EXTRA_INFO
       where  assignment_id      = X_assignment_id
         and  information_type   = X_information_type
         and  Aei_Information1   = X_state_code
         and  Aei_Information2   = X_locality_code;
--
begin
  hr_utility.set_location('pay_us_emp_tax_rules_pkg.check_unique',1);
  if X_information_type = 'FEDERAL'
  then
    OPEN csr_federal;
    fetch csr_federal into ret;
    if csr_federal%FOUND then
       RETURN 1;
    else
       RETURN 0;
    end if;
    CLOSE csr_federal;
  elsif X_information_type = 'STATE'
  then
    hr_utility.set_location('pay_us_emp_tax_rules_pkg.check_unique',2);
    OPEN  csr_state;
    fetch csr_state into ret;
    if csr_state%FOUND then
       hr_utility.set_message(801,'HR_7719_TAX_ONE_RULE_ONLY');
       RETURN 1;
    else
       RETURN 0;
    end if;
    CLOSE csr_state;
  elsif X_information_type = 'LOCALITY'
  then
    hr_utility.set_location('pay_us_emp_tax_rules_pkg.check_unique',3);
    OPEN  csr_local;
    fetch csr_local into ret;
    if csr_local%FOUND then
       hr_utility.set_message(801,'HR_7720_TAX_ONE_RULE_ONLY');
       RETURN 1;
    else
       RETURN 0;
    end if;
    hr_utility.set_location('pay_us_emp_tax_rules_pkg.check_unique',4);
    CLOSE csr_local;
  end if;
  hr_utility.set_location('pay_us_emp_tax_rules_pkg.check_unique',5);
--
END check_unique;

--
----------------------------- default_tax ----------------------------
----------------------------- with commit ----------------------------

--
PROCEDURE default_tax( X_assignment_id     IN      NUMBER,
                       X_session_date      IN      DATE,
                       X_business_group_id IN      NUMBER,
                       X_resident_state    IN OUT nocopy  VARCHAR2,
                       X_res_state_code    IN OUT nocopy  VARCHAR2,
                       X_work_state        IN OUT nocopy  VARCHAR2,
                       X_work_state_code   IN OUT nocopy  VARCHAR2,
                       X_resident_locality IN OUT nocopy  VARCHAR2,
                       X_work_locality     IN OUT nocopy  VARCHAR2,
                       X_work_jurisdiction IN OUT nocopy  VARCHAR2,
                       X_work_loc_name     IN OUT nocopy  VARCHAR2 ,
                       X_resident_loc_name IN OUT nocopy  VARCHAR2 ,
                       X_default_or_get    IN OUT nocopy  VARCHAR2,
                       X_error             IN OUT nocopy  VARCHAR2)
IS
l_from_form            VARCHAR2(50) := 'Tax_Form';

BEGIN

-- Call the below pacakge and commit
pay_us_emp_tax_rules_pkg.default_tax(
                       X_assignment_id     =>     X_assignment_id,
                       X_session_date      =>     X_session_date,
                       X_business_group_id =>     X_business_group_id,
                       X_resident_state    =>     X_resident_state,
                       X_res_state_code    =>     X_res_state_code,
                       X_work_state        =>     X_work_state,
                       X_work_state_code   =>     X_work_state_code,
                       X_resident_locality =>     X_resident_locality,
                       X_work_locality     =>     X_work_locality,
                       X_work_jurisdiction =>     X_work_jurisdiction,
                       X_work_loc_name     =>     X_work_loc_name,
                       X_resident_loc_name =>     X_resident_loc_name,
                       X_default_or_get    =>     X_default_or_get,
                       X_error             =>     X_error,
                       X_from_form         =>     l_from_form);
--
COMMIT;
--
END default_tax;
--
----------------------------- default_tax ----------------------------
-----------------------------  no commit  ----------------------------
--
PROCEDURE default_tax( X_assignment_id     IN      NUMBER,
                       X_session_date      IN      DATE,
                       X_business_group_id IN      NUMBER,
                       X_resident_state    IN OUT nocopy  VARCHAR2,
                       X_res_state_code    IN OUT nocopy  VARCHAR2,
                       X_work_state        IN OUT nocopy  VARCHAR2,
                       X_work_state_code   IN OUT nocopy  VARCHAR2,
                       X_resident_locality IN OUT nocopy  VARCHAR2,
                       X_work_locality     IN OUT nocopy  VARCHAR2,
                       X_work_jurisdiction IN OUT nocopy  VARCHAR2,
                       X_work_loc_name     IN OUT nocopy  VARCHAR2 ,
                       X_resident_loc_name IN OUT nocopy  VARCHAR2 ,
                       X_default_or_get    IN OUT nocopy  VARCHAR2,
                       X_error             IN OUT nocopy  VARCHAR2,
                       X_from_form         IN      VARCHAR2)
IS
 l_ret            number := 0;
 l_state          VARCHAR2(2)  := Null;
 l_rowid          VARCHAR2(30) := Null;
 l_time_in_state  VARCHAR2(3)  := '0';
 l_remainder      VARCHAR2(3)  := '0';
 l_resident_county_name VARCHAR2(60);
 l_work_county_name VARCHAR2(60); /* 391886 */
--
-- Cursor to check whether tax rules exist
--
 CURSOR csr_check_federal is
     select 1
     from   PER_ASSIGNMENT_EXTRA_INFO
     where  assignment_id     = X_assignment_id
     and    INFORMATION_TYPE  = 'FEDERAL';
--
-- Cursor to check state tax rules exists
--
 CURSOR csr_check_state ( P_state varchar2 ) is
     select 1
     from   PER_ASSIGNMENT_EXTRA_INFO
     where  assignment_id     = X_assignment_id
     and    INFORMATION_TYPE  = 'STATE'
     and    AEI_INFORMATION1  = P_state;
--
-- Cursor to check state tax rules exists with time in state=100
--
 CURSOR csr_check_state_100 is
     select ROWID, AEI_INFORMATION1
     from   PER_ASSIGNMENT_EXTRA_INFO
     where  assignment_id     = X_assignment_id
     and    INFORMATION_TYPE  = 'STATE'
     and    fnd_number.canonical_to_number(AEI_INFORMATION13) = 100;
--
-- Cursor to check Locality tax rules exists
--
 CURSOR csr_check_local( P_state varchar2,
                  P_local varchar2) is
     select 1
     from   PER_ASSIGNMENT_EXTRA_INFO
     where  assignment_id     = X_assignment_id
     and    INFORMATION_TYPE  = 'LOCALITY'
     and    AEI_INFORMATION1  = P_state
     and    AEI_INFORMATION2  = P_local;
--
--
PROCEDURE  get_def_state_local(P_assignment_id      IN    NUMBER,
                               P_session_date       IN    DATE,
                               P_res_state          OUT nocopy   VARCHAR2,
                               P_res_state_code     OUT nocopy   VARCHAR2,
                               P_res_locality       OUT nocopy   VARCHAR2,
                               P_work_state         OUT nocopy   VARCHAR2,
                               P_work_state_code    OUT nocopy   VARCHAR2,
                               P_work_jurisdiction  OUT nocopy   VARCHAR2,
                               P_work_locality      OUT nocopy   VARCHAR2,
                               P_work_loc_name      OUT nocopy   VARCHAR2,
                               P_resident_loc_name  OUT nocopy   VARCHAR2,
                               P_work_county_name  OUT nocopy   VARCHAR2, /*391886*/
                               P_resident_county_name  OUT nocopy   VARCHAR2)
IS
--
-- declare local variables
--
  l_zip_code VARCHAR2(30);
  l_county   VARCHAR2(120);
  l_res_state_code  VARCHAR2(2);
  l_res_loc_name    VARCHAR2(30);
  l_work_state_code VARCHAR2(2);
  l_work_loc_name   VARCHAR2(30);
--
-- Cursor to get resident state
--
CURSOR csr_get_res_state is
       select psr.name,
              psr.state_code,
              psr.state_code,
              pa.town_or_city,
              pa.town_or_city,
	      pa.region_1,
	      pa.postal_code
       from   PER_ASSIGNMENTS_F   paf,
              PER_ADDRESSES       pa,
              PAY_STATE_RULES     psr
       where  paf.assignment_id         = P_assignment_id
       and    P_session_date between paf.effective_start_date and
                                     paf.effective_end_date
       and    paf.person_id             = pa.person_id
       and    pa.primary_flag           = 'Y'
       and    P_session_date between pa.date_from and
                                     nvl(pa.date_to,P_session_date)
       and    psr.state_code            = pa.region_2;
--
-- Cursor to get Work state
--
CURSOR csr_get_work_state is
       select psr.name,
              psr.state_code,
              psr.state_code,
              hl.region_1,
              hl.postal_code,
              psr.jurisdiction_code,
              hl.town_or_city,
              hl.town_or_city
       from   PER_ASSIGNMENTS_F   paf,
              HR_LOCATIONS        hl,
              PAY_STATE_RULES     psr
       where  paf.assignment_id         = P_assignment_id
       and    P_session_date between paf.effective_start_date and
                                     paf.effective_end_date
       and    paf.location_id           = hl.location_id
       and    psr.state_code            = hl.region_2;

begin
  hr_utility.set_location('pay_us_emp_tax_rules_pkg.get_def_state',1);
  OPEN  csr_get_res_state;
  FETCH csr_get_res_state into	P_res_state,
				P_res_state_code,
				l_res_state_code,
                                P_resident_loc_name,
				l_res_loc_name,
				l_county,
				l_zip_code;
  IF csr_get_res_state%NOTFOUND
  THEN
     P_res_state      := null;
     P_res_state_code := null;
     P_res_locality   := null;
  ELSE
--
-- get resident locality i.e. geo code
--
p_resident_county_name := l_county;
--
  hr_utility.set_location('pay_us_emp_tax_rules_pkg.get_def_state',2);
  P_res_locality := hr_us_ff_udfs.addr_val (
			p_state_abbrev => l_res_state_code,
			p_county_name  => l_county,
			p_city_name    => l_res_loc_name,
			p_zip_code     => l_zip_code);
  END IF;
  hr_utility.set_location('pay_us_emp_tax_rules_pkg.get_def_state',3);
  CLOSE csr_get_res_state;
--
  OPEN  csr_get_work_state;
  FETCH csr_get_work_state into  P_work_state,
				 P_work_state_code,
				 l_work_state_code,
				 l_county,
				 l_zip_code,
				 P_work_jurisdiction,
                                 P_work_loc_name,
                                 l_work_loc_name;
  IF csr_get_work_state%NOTFOUND
  THEN
     P_work_state      := null;
     P_work_state_code := null;
     P_work_locality   := null;
  ELSE
--
-- get work locality i.e. geo code
--
p_work_county_name := l_county;
--

  hr_utility.set_location('pay_us_emp_tax_rules_pkg.get_def_state',4);
  P_work_locality := hr_us_ff_udfs.addr_val (
			p_state_abbrev => l_work_state_code,
			p_county_name  => l_county,
			p_city_name    => l_work_loc_name,
			p_zip_code     => l_zip_code);
  END IF;
  hr_utility.set_location('pay_us_emp_tax_rules_pkg.get_def_state',5);
  CLOSE csr_get_work_state;
--
END get_def_state_local;
--


FUNCTION insert_def_fed_rec(P_assignment_id    NUMBER,
                            p_session_date     DATE,
                            P_sui_state        VARCHAR2)
RETURN NUMBER IS
--
p_filing_status  varchar2(2);
P_eic_fstatus    varchar2(2);
P_temp           varchar2(30);
P_id             number;
--
CURSOR csr_filing_status is
       select lookup_code
       from   hr_lookups
       where  lookup_type    = 'US_FIT_FILING_STATUS'
       and    upper(meaning) = 'SINGLE';
--
CURSOR csr_eic_fstatus is
       select lookup_code
       from   hr_lookups
       where  lookup_type    = 'US_EIC_FILING_STATUS'
       and    upper(meaning) = 'NO EIC';
--

begin
--
  OPEN  csr_filing_status;
  hr_utility.set_location('pay_us_emp_tax_rules_pkg.ins_def_feder',1);
  FETCH csr_filing_status into p_filing_status;
  IF csr_filing_status%NOTFOUND then
     hr_utility.set_message(801,'HR_6091_DEF_MISSING_LOOKUPS');
     hr_utility.set_message_token('LOOKUP_TYPE ','US_FIT_FILING_STATUS');
     hr_utility.raise_error;
  end if;
  CLOSE csr_filing_status;
--
--
  hr_utility.set_location('pay_us_emp_tax_rules_pkg.get_def_feder',1);
  OPEN  csr_eic_fstatus;
  FETCH csr_eic_fstatus into P_eic_fstatus;
  IF csr_eic_fstatus%NOTFOUND then
     hr_utility.set_message(801,'HR_6091_DEF_MISSING_LOOKUPS');
     hr_utility.set_message_token('LOOKUP_TYPE ','US_EIC_FILING_STATUS');
     hr_utility.raise_error;
  end if;
  CLOSE csr_eic_fstatus;
--
-- Insert Federal Tax record
--
hr_utility.set_location('pay_us_emp_tax_rules_pkg.get_def_feder',4);
PAY_US_EMP_TAX_RULES_PKG.Insert_Row(
           X_Rowid                    => P_temp,
           X_Assignment_Extra_Info_Id => P_id,
           X_Assignment_Id            => P_assignment_id,
           X_Information_Type         => 'FEDERAL',
           X_session_date             => P_session_date,
           X_jurisdiction             => null,
           X_Aei_Information_Category => 'FEDERAL',
           X_Aei_Information1         => '0',
           X_Aei_Information2         => '0',
           X_Aei_Information3         => Null,
           X_Aei_Information4         => P_filing_status,
           X_Aei_Information5         => '0',
           X_Aei_Information6         => 'N',
           X_Aei_Information7         => 'N',
           X_Aei_Information8         => 'N',
           X_Aei_Information9         => 'N',
           X_Aei_Information10        => 'N',
           X_Aei_Information11        => 'N',
           X_Aei_Information12        => P_eic_fstatus,
           X_Aei_Information13        => Null,
           X_Aei_Information14        => '0',
           X_Aei_Information15        => '0',
           X_Aei_Information16        => Null,
           X_Aei_Information17        => '0',/*316663 default supp override=0*/
           X_Aei_Information18        => P_sui_state,
           X_Aei_Information19        => Null,
           X_Aei_Information20        => Null);
--
hr_utility.set_location('pay_us_emp_tax_rules_pkg.get_def_feder',5);
--
RETURN P_id;
--
END  insert_def_fed_rec;
--
-- Insert state record
--

FUNCTION insert_def_state_rec(P_assignment_id     NUMBER,
                              P_state_code        VARCHAR2,
                              P_session_date      DATE,
                              P_time_in_state     VARCHAR2,
                              P_remainder         VARCHAR2)
RETURN NUMBER IS
--
P_temp           varchar2(30);
P_id             number;
P_jurisdiction   varchar2(30) :=null;
l_filing_status  varchar2(30);
l_def_pref  varchar2(30);
l_allowances      number;
--
CURSOR csr_get_jurisdiction is
       select jurisdiction_code
       from   pay_state_rules
       where  state_code = P_state_code;

-- This cursor gets the filing status and exemptions from the federal record
-- if needed

CURSOR csr_filing_status is
       select hl.lookup_code, peft.withholding_allowances  -- Bug 3354046: Table pay_us_states is added to remove 2 MJC and FTS on table
       from   hr_lookups hl,                               -- pay_state_rules(table in def. of view pay_emp_fed_tax_v1)
              pay_emp_fed_tax_v1 peft,
              pay_us_states pus
       where  hl.lookup_type    = 'US_FS_'||substr(p_jurisdiction,1,2)
       and    upper(hl.meaning) = decode(
              upper(substr(peft.filing_status,1,7)),
                           'MARRIED',
                           'MARRIED',
                           upper(peft.filing_status))
       and    peft.assignment_id = p_assignment_id
       and    pus.state_code = substr(peft.sui_jurisdiction_code,1,2)
       and    pus.state_abbrev = peft.sui_state_code
       and    pus.state_name = peft.sui_state_name;
--
CURSOR csr_fed_or_def is                                  -- Bug 3354046: Index has been forced on table pay_state_rules to remove FTS and
       select /*+ index (sr PAY_STATE_RULES_PK)           -- MJC.
               ordered */hoi.org_information12
       from   per_assignments_f paf,
              hr_soft_coding_keyflex hsck,
              hr_organization_information hoi ,
              pay_state_rules sr
       where  paf.assignment_id = p_assignment_id
       and    SR.state_code = hoi.org_information1
       and    hoi.organization_id = hsck.segment1
       and    hoi.org_information_context = 'State Tax Rules'
       and    paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
       and    sr.jurisdiction_code = substr(p_jurisdiction,1,2)||'-000-0000';

begin
--
  hr_utility.set_location('pay_us_emp_tax_rules_pkg.ins_def_state',1);
  OPEN  csr_get_jurisdiction;
  FETCH csr_get_jurisdiction into P_jurisdiction;
  IF csr_get_jurisdiction%NOTFOUND then
     hr_utility.set_message(801,'HR_6091_DEF_MISSING_LOOKUPS');
     hr_utility.set_message_token('LOOKUP_TYPE ','pay_state_rules');
     hr_utility.raise_error;
  end if;
  CLOSE csr_get_jurisdiction;
  hr_utility.set_location('pay_us_emp_tax_rules_pkg.ins_def_state',1.3);

  OPEN  csr_fed_or_def;
  hr_utility.set_location('pay_us_emp_tax_rules_pkg.ins_def_state',1.4);
  FETCH csr_fed_or_def into l_def_pref;
  hr_utility.set_location('pay_us_emp_tax_rules_pkg.ins_def_state',1.5);
  IF csr_fed_or_def%NOTFOUND
     OR l_def_pref = 'SINGLE_ZERO'
     OR l_def_pref IS NULL then
     l_def_pref := 'SINGLE_ZERO';
     l_filing_status := '1';
     l_allowances := 0;
  end if;
  hr_utility.set_location('pay_us_emp_tax_rules_pkg.ins_def_state',1.6);
  CLOSE csr_fed_or_def;

  hr_utility.set_location('pay_us_emp_tax_rules_pkg.ins_def_state',1.7);
  IF l_def_pref = 'FED_DEF' then
    OPEN  csr_filing_status;
    FETCH csr_filing_status into l_filing_status, l_allowances;
    IF csr_filing_status%NOTFOUND then
       l_filing_status := '1';
       l_allowances := 0;
    end if;
    CLOSE csr_filing_status;
  end if;
--
-- Insert State Tax record
--
  hr_utility.set_location('pay_us_emp_tax_rules_pkg.ins_def_state',2);
PAY_US_EMP_TAX_RULES_PKG.Insert_Row(
           X_Rowid                    => P_temp,
           X_Assignment_Extra_Info_Id => P_id,
           X_Assignment_Id            => P_assignment_id,
           X_Information_Type         => 'STATE',
           X_session_date             => P_session_date,
           X_jurisdiction             => P_jurisdiction,
           X_Aei_Information_Category => 'STATE',
           X_Aei_Information1         => P_state_code,
           X_Aei_Information2         => l_filing_status,
           X_Aei_Information3         => 'N',
           X_Aei_Information4         => 'N',
           X_Aei_Information5         => 'N',
           X_Aei_Information6         => 'N',
           X_Aei_Information7         => 'Y',
           X_Aei_Information8         => '0',
           X_Aei_Information9         => '0',
           X_Aei_Information10        => fnd_number.number_to_canonical(l_allowances),
           X_Aei_Information11        => '0',
           X_Aei_Information12        => Null,
           X_Aei_Information13        => P_time_in_state,
           X_Aei_Information14        => '0',
           X_Aei_Information15        => '0',
           X_Aei_Information16        => P_remainder,
           X_Aei_Information17        => Null,
           X_Aei_Information18        => '0',  /*316663 Supp Override rate =0*/
           X_Aei_Information19        => Null,
           X_Aei_Information20        => Null);
--
  hr_utility.set_location('pay_us_emp_tax_rules_pkg.ins_def_state',3);
--
-- NOTE: do not call create_vertex_entry here since we NEVER want to create
--	 an entry for either the resident or work state since this will
--	 be covered when we default the associated city record for resident
--	 or work location.
--
RETURN P_id;
--
END  insert_def_state_rec;
--
--
FUNCTION insert_def_loc_rec(P_assignment_id    NUMBER,
                            P_state_code       VARCHAR2,
                            P_session_date     DATE,
                            P_locality_code    VARCHAR2,
                            P_locality_name    VARCHAR2,
                            P_locality_county  VARCHAR2,
                            P_time_in_local    VARCHAR2,
			    p_resident_flag    VARCHAR2 DEFAULT 'N')
RETURN NUMBER IS
--
l_filing_status  varchar2(2);
l_temp           varchar2(30);
l_id             number;
l_test             number;  /* 390941 */
l_city_sd_code	 VARCHAR2(5) := NULL;
l_county_sd_code VARCHAR2(5) := NULL;
l_county_locality_code VARCHAR2(11);
--
CURSOR csr_county_exists (Jurisdiction varchar2) is   /* 390941 */
       select 1
       from per_assignment_extra_info
       where assignment_id = P_assignment_id
       and aei_information2 = Jurisdiction;


CURSOR csr_filing_status is
       select lookup_code
       from   hr_lookups
       where  lookup_type    = 'US_LIT_FILING_STATUS'
       and    upper(meaning) = 'SINGLE';
--
CURSOR csr_get_county_sd IS
	SELECT	school_dst_code
	FROM	pay_us_county_school_dsts
	WHERE	STATE_CODE  = fnd_number.canonical_to_number(substr(P_locality_code,1,2))
	AND	COUNTY_CODE = fnd_number.canonical_to_number(substr(P_locality_code,4,3))
        AND     p_resident_flag = 'Y'
	ORDER BY fnd_number.canonical_to_number(school_dst_code);
--
CURSOR csr_get_city_sd IS
	SELECT	school_dst_code
	FROM	pay_us_city_school_dsts
	WHERE	STATE_CODE  = fnd_number.canonical_to_number(substr(P_locality_code,1,2))
	AND	COUNTY_CODE = fnd_number.canonical_to_number(substr(P_locality_code,4,3))
	AND	CITY_CODE   = fnd_number.canonical_to_number(substr(P_locality_code,8,4))
        AND     p_resident_flag = 'Y'
	ORDER BY fnd_number.canonical_to_number(school_dst_code);
--
begin
--
  hr_utility.set_location('pay_us_emp_tax_rules_pkg.insert_def_loc_rec',1);
  OPEN  csr_filing_status;
  FETCH csr_filing_status into l_filing_status;
  IF csr_filing_status%NOTFOUND then
     hr_utility.set_message(801,'HR_6091_DEF_MISSING_LOOKUPS');
     hr_utility.set_message_token('LOOKUP_TYPE ','US_LIT_FILING_STATUS');
     hr_utility.raise_error;
  end if;
  CLOSE csr_filing_status;
--
-- check if entering resident record which will require default
-- city and county records with school districts
-- get county name. city and county sd codes if applicable and insert
-- county resident tax record.
-- However, don't bother if locality being defaulted is for an unknown
-- city (i.e. p_locality_code is a county code - addr_Val returns county
-- geo code for unknown cities) because this will be a county tax record
-- anyway.
--
/* bug391886 Now county record is constructed if this is a resident or
   work address*/
/*  IF ( (p_resident_flag = 'Y') OR
       (SUBSTR(p_locality_code, 8,4) = '0000') OR (1=1))
  THEN */

      l_county_locality_code := (SUBSTR(P_locality_code,1,7)||'0000');
      --
      OPEN csr_county_exists(l_county_locality_code); /* 390941 */
      FETCH csr_county_exists into l_test; /* 390941 */

      --
      -- get county school district /* Why? if it is going to be at
      -- the city level then there is no point.  No longer defaulting.
      --
      hr_utility.set_location('pay_us_emp_tax_rules_pkg.insert_def_loc_rec',2);
      --OPEN  csr_get_county_sd;
      --FETCH csr_get_county_sd INTO l_county_sd_code;
      --CLOSE csr_get_county_sd;
--
IF csr_county_exists%NOTFOUND THEN /* 390941 */

--
-- Insert Local County Tax record
--
hr_utility.set_location('pay_us_emp_tax_rules_pkg.insert_def_loc_rec',3);
PAY_US_EMP_TAX_RULES_PKG.Insert_Row(
           X_Rowid                    => l_temp,
           X_Assignment_Extra_Info_Id => l_id,
           X_Assignment_Id            => P_assignment_id,
           X_Information_Type         => 'LOCALITY',
           X_session_date             => P_session_date,
           X_jurisdiction             => l_county_locality_code,
           X_Aei_Information_Category => 'LOCALITY',
           X_Aei_Information1         => P_state_code,
           X_Aei_Information2         => l_county_locality_code,
           X_Aei_Information3         => l_filing_status,
           X_Aei_Information4         => '0',
           X_Aei_Information5         => '0',
           X_Aei_Information6         => '0',
           X_Aei_Information7         => 'N',
           X_Aei_Information8         => 'Y',
           X_Aei_Information9         => l_county_sd_code,
           X_Aei_Information10        => '0',
           X_Aei_Information11        => '0',
           X_Aei_Information12        => '0',
           X_Aei_Information13        => P_locality_county,
           X_Aei_Information14        => Null,
           X_Aei_Information15        => Null,
           X_Aei_Information16        => Null,
           X_Aei_Information17        => Null,
           X_Aei_Information18        => Null,
           X_Aei_Information19        => Null,
           X_Aei_Information20        => Null);
    --
    -- don't need assignment_extra_info_id for anything
    -- if do not set this to null then the local tax insert
    -- does not bother to get a new id - therefore giving
    -- duplicate key type error!
    --
    -- Also, do NOT need to insert VERTEX record for default
    -- county record - will insert VERTEX record for unknown city
    -- later
    --
END IF; /* 390941 */
close csr_county_exists; /* 390941 */
      l_id := NULL;
    --
/*END IF; -- (p_resident_flag = 'Y') REMOVED FOR BUG 391886*/
    --
--
-- check that we are not defaulting for an unknown city. If we are then
-- skip insert of employee tax record as it will have been entered already
-- above as a county tax record and go striaght to inserting the VERTEX
-- entry for the unknown city
--
IF (SUBSTR(p_locality_code, 8,4) <> '0000')
THEN
  --
  -- get city school district
  --
  hr_utility.set_location('pay_us_emp_tax_rules_pkg.insert_def_loc_rec',4);
  /* Commenting out the defaulting of school district to take care of
	  Bug 643121 */
  -- OPEN  csr_get_city_sd;
  -- FETCH csr_get_city_sd INTO l_city_sd_code;
  -- CLOSE csr_get_city_sd;
  --
--
-- Insert Local Tax record
--
hr_utility.set_location('pay_us_emp_tax_rules_pkg.insert_def_loc_rec',5);
PAY_US_EMP_TAX_RULES_PKG.Insert_Row(
           X_Rowid                    => l_temp,
           X_Assignment_Extra_Info_Id => l_id,
           X_Assignment_Id            => P_assignment_id,
           X_Information_Type         => 'LOCALITY',
           X_session_date             => P_session_date,
           X_jurisdiction             => P_locality_code,
           X_Aei_Information_Category => 'LOCALITY',
           X_Aei_Information1         => P_state_code,
           X_Aei_Information2         => P_locality_code,
           X_Aei_Information3         => l_filing_status,
           X_Aei_Information4         => '0',
           X_Aei_Information5         => '0',
           X_Aei_Information6         => '0',
           X_Aei_Information7         => 'N',
           X_Aei_Information8         => 'Y',
           X_Aei_Information9         => l_city_sd_code,
           X_Aei_Information10        => P_time_in_local,
           X_Aei_Information11        => '0',
           X_Aei_Information12        => '0',
           X_Aei_Information13        => P_locality_name,
           X_Aei_Information14        => Null,
           X_Aei_Information15        => Null,
           X_Aei_Information16        => Null,
           X_Aei_Information17        => Null,
           X_Aei_Information18        => Null,
           X_Aei_Information19        => Null,
           X_Aei_Information20        => Null);
--
hr_utility.set_location('pay_us_emp_tax_rules_pkg.insert_def_loc_rec',6);
--
END IF; -- IF (SUBSTR(p_locality_code, 8,4) <> '0000')
--
    pay_us_emp_tax_rules_pkg.create_vertex_entry(
	   P_mode		=> 'I',
	   P_assignment_id	=> P_assignment_id,
	   P_information_type	=> 'LOCALITY',
	   P_session_date	=> X_session_date,
	   P_jurisdiction	=> P_locality_code,
	   P_time_in_locality   => P_time_in_local,
	   P_remainder_percent  => NULL);
--
hr_utility.set_location('pay_us_emp_tax_rules_pkg.insert_def_loc_rec',7);
--
  RETURN l_id;
--
END  insert_def_loc_rec;
--
--
-- MAIN PROCEDURE
--
--
BEGIN
--
-- Get State code and Locality from the Address
--
--  hr_utility.trace_on;
   hr_utility.set_location('pay_us_emp_tax_rules_pkg.main_proc',1);
   X_error := 'Y';
   get_def_state_local(P_assignment_id      => X_assignment_id,
                       P_session_date       => X_session_date,
                       P_res_state          => X_resident_state,
                       P_res_state_code     => X_res_state_code,
                       P_res_locality       => X_resident_locality,
                       P_work_state         => X_work_state,
                       P_work_state_code    => X_work_state_code,
                       P_work_jurisdiction  => X_work_jurisdiction,
                       P_work_locality      => X_work_locality,
                       P_work_loc_name      => X_work_loc_name,
                       P_resident_loc_name  => X_resident_loc_name,
		       P_work_county_name   => l_work_county_name,/*391886*/
		       P_resident_county_name => l_resident_county_name);
   hr_utility.set_location('pay_us_emp_tax_rules_pkg.main_proc',2);
-- Check
--
--
IF (X_res_state_code  is not null AND
    X_work_state_code is not null)
THEN
--
     OPEN  csr_check_federal;
     FETCH csr_check_federal into l_ret;
     --
     IF csr_check_federal%NOTFOUND
     THEN
--
--   Insert default values
--
--   Federal
--
        l_ret := insert_def_fed_rec(X_assignment_id,
                                    X_session_date,
                                    X_work_jurisdiction);
--
--   State
--
        IF X_work_locality is null
	THEN
           l_remainder := '100';
        ELSE
           l_remainder := '0';
        END IF;
	--
	-- if PWS and PRS are different insert one state record for each
	--
        IF X_res_state_code <> X_work_state_code
	THEN
           l_ret := insert_def_state_rec(X_assignment_id,
                                         X_work_state_code,
                                         X_session_date,
                                         '100',
                                         l_remainder);
           l_ret := insert_def_state_rec(X_assignment_id,
                                         X_res_state_code,
                                         X_session_date,
                                         '0',
                                         '0');
        ELSE
	--
	-- insert one state record
	--
           l_ret := insert_def_state_rec(X_assignment_id,
                                         X_res_state_code,
                                         X_session_date,
                                         '100',
                                         l_remainder);
        END IF;
--
--  Locality
--
   hr_utility.set_location('pay_us_emp_tax_rules_pkg.main_proc',3);
	--
	-- if PW locality and PR locality are different insert one
	-- locality record for each
	--
        IF (X_work_locality <> X_resident_locality)
	THEN
           l_ret := insert_def_loc_rec(X_assignment_id,
                              X_work_state_code,
                              X_session_date,
                              X_work_locality,
                              X_work_loc_name,
			      l_work_county_name, /*391886*/
                              100);
           l_ret := insert_def_loc_rec(X_assignment_id,
                              X_res_state_code,
                              X_session_date,
                              X_resident_locality,
                              X_resident_loc_name,
                              l_resident_county_name,
                              0,
			      p_resident_flag => 'Y');
        ELSE
           l_ret := insert_def_loc_rec(X_assignment_id,
                              X_res_state_code,
                              X_session_date,
                              X_resident_locality,
                              X_resident_loc_name,
                              l_resident_county_name,
                              100,
			      p_resident_flag => 'Y');
        END IF;
     hr_utility.set_location('pay_us_emp_tax_rules_pkg.main_proc',4);
     --
     ELSE -- (IF csr_check_federal%NOTFOUND)
     --
     -- Check whether states exist
     --
       OPEN  csr_check_state (X_work_state_code);
       FETCH csr_check_state INTO l_ret;
       IF csr_check_state%NOTFOUND
       THEN
          hr_utility.set_location('pay_us_emp_tax_rules_pkg.main_proc',5);
          l_time_in_state := '0';
          l_ret := insert_def_state_rec(X_assignment_id,
                                        X_work_state_code,
                                        X_session_date,
                                        l_time_in_state,
                                        '0');
       END IF;
       CLOSE csr_check_state;
--
       hr_utility.set_location('pay_us_emp_tax_rules_pkg.main_proc',6);
       IF X_work_state_code <> X_res_state_code
       THEN
          OPEN  csr_check_state (X_res_state_code);
          FETCH csr_check_state INTO l_ret;
          IF csr_check_state%NOTFOUND
	  THEN
             l_ret := insert_def_state_rec(X_assignment_id,
                                           X_res_state_code,
                                           X_session_date,
                                           '0',
                                           '0');
          END IF;
          CLOSE csr_check_state;
       END IF;
       hr_utility.set_location('pay_us_emp_tax_rules_pkg.main_proc',7);
--
       IF X_resident_locality is not null
       THEN
          OPEN  csr_check_local(X_res_state_code, X_resident_locality);
          FETCH csr_check_local into l_ret;
          IF csr_check_local%NOTFOUND
	  THEN
            l_ret := insert_def_loc_rec(X_assignment_id,
                                        X_res_state_code,
                                        X_session_date,
                                        X_resident_locality,
                                        X_resident_loc_name,
                                        l_resident_county_name,
                                        '0',
					p_resident_flag => 'Y');
          END IF;
          CLOSE csr_check_local;
       END IF;
       hr_utility.set_location('pay_us_emp_tax_rules_pkg.main_proc',8);
--
       IF (X_work_locality is not null AND
          (X_work_locality <> X_resident_locality))
       THEN
          OPEN  csr_check_local(X_work_state_code, X_work_locality);
          FETCH csr_check_local into l_ret;
          IF csr_check_local%NOTFOUND
	  THEN
             l_ret := insert_def_loc_rec(X_assignment_id,
                                X_work_state_code,
                                X_session_date,
                                X_work_locality,
                                X_work_loc_name,
                                l_work_county_name,/*391886*/
                                '0');
          END IF;
          CLOSE csr_check_local;
       END IF;
       hr_utility.set_location('pay_us_emp_tax_rules_pkg.main_proc',9);
--
     END IF;
     CLOSE csr_check_federal;
     X_error := 'N';
--
-- since there are no erorrs then commit
-- moving commit from form to server now that commits in plsql
-- are kosha
-- Moving because of 268389.
--     COMMIT;
--
  ELSE
     X_error := 'Y';
  END IF;
  hr_utility.set_location('pay_us_emp_tax_rules_pkg.main_proc',10);
--
END default_tax;

--
--------------------------- create_vertex_entry --------------------
PROCEDURE create_vertex_entry(
          P_mode                Varchar2,
          P_assignment_id       Number,
          P_information_type    varchar2,
          P_session_date        date,
          P_jurisdiction        varchar2,
	  p_time_in_locality	varchar2,
	  p_remainder_percent   varchar2 ) IS
--
-- Declare table for input value Id and Screen Value
inp_value_id_tbl hr_entry.number_table;
scr_valuetbl     hr_entry.varchar2_table;
--
-- Local Varailbles
--
P_element_type_id     number       :=0;
P_element_link_id     number       :=0;
P_inp_1               number       :=0;
P_inp_2               number       :=0;
P_inp_3               number       :=0;
P_iname               varchar2(80) :=null;
P_inp                 number       :=0;
P_element_entry_id    number       :=0;
P_effective_stdt      date         :=null;
P_effective_end_date  date         :=null;
P_ins_or_upd          varchar2(1)  :='N';
P_time		      varchar2(60);

-- Cursor to get the vertex element and link
CURSOR csr_tax_element is
       select pet.ELEMENT_TYPE_ID,
              piv.INPUT_VALUE_ID,
              piv.NAME
       from   PAY_ELEMENT_TYPES_F pet,
              PAY_INPUT_VALUES_F  piv
       where  PET.ELEMENT_NAME    = 'VERTEX'
       and    P_session_date between pet.effective_start_date and
                                     pet.effective_end_date
       and    pet.element_type_id = piv.element_type_id
       and    P_session_date between piv.effective_start_date and
                                     piv.effective_end_date ;

-- Cursor to find out whether a element entry exists for the jurisdiction
-- The date effectiveness of this is being removed to
-- prevent duplicate vertex element entries. Mar 31, 1997
-- In addition the start date is pulled back if the session date
-- is prior to the start date of the existing entry and entry values

CURSOR csr_chk_entry is
       select pee.ELEMENT_ENTRY_ID,
              pee.EFFECTIVE_START_DATE
       from   PAY_ELEMENT_ENTRIES_F      pee,
              PAY_ELEMENT_ENTRY_VALUES_F peev
       where  pee.assignment_id       = P_assignment_id
       --and    P_session_date between pee.effective_start_date and
       --                              pee.effective_end_date
       and    pee.element_link_id     = P_element_link_id
       and    pee.element_entry_id    = peev.element_entry_id
       --and    P_session_date between peev.effective_start_date and
       --                              peev.effective_end_date
       and    peev.input_value_id     = P_inp_2
       and    peev.screen_entry_value = p_jurisdiction;

-- Get Effective_start_Date of assignment
CURSOR csr_get_eff_Date is
       select effective_start_date
       from   PER_ASSIGNMENTS_F
       where  assignment_id = P_assignment_id
       and    P_session_date between effective_start_date and
                                     effective_end_date;
--
-- MAIN Procedure
--
begin
--
hr_utility.set_location('PAY_US_EMP_TAX_RULES_PKG.Ele_entry',1);
--
-- set p_time
--
IF (p_information_type = 'LOCALITY')
THEN
    p_time := p_time_in_locality;
ELSE
    p_time := p_remainder_percent;
END IF;
--
OPEN  csr_tax_element;
LOOP
  FETCH csr_tax_element INTO p_element_type_id,
                             P_inp, P_iname;
  EXIT WHEN csr_tax_element%NOTFOUND;
--
  IF upper(P_iname) = 'JURISDICTION'
  THEN
     P_inp_2 := P_inp;
  ELSIF upper(P_iname) = 'PERCENTAGE'
  THEN
     P_inp_3 := P_inp;
  ELSIF upper(P_iname) = 'PAY VALUE'
  THEN
   P_inp_1 := P_inp;
  END IF;
--
END LOOP;
--
CLOSE csr_tax_element;
hr_utility.set_location('PAY_US_EMP_TAX_RULES_PKG.Ele_entry',4);
--
IF P_inp_2 is null OR P_inp_3 is null OR P_inp_1 is null OR
   P_inp_2 = 0 OR     P_inp_3 = 0     OR P_inp_1 = 0
THEN
     hr_utility.set_message(801, 'HR_13140_TAX_ELEMENT_ERROR');
     hr_utility.set_message_token('1','VERTEX');
     hr_utility.raise_error;
END IF;
hr_utility.set_location('PAY_US_EMP_TAX_RULES_PKG.Ele_entry',6);
--
-- Get element link
P_element_link_id := hr_entry_api.get_link(
                       P_assignment_id   => P_assignment_id,
                       P_element_type_id => P_element_type_id,
                       P_session_date    => P_session_date);
--
IF P_element_link_id is null OR P_element_link_id = 0
THEN
     hr_utility.set_message(801, 'HR_13140_TAX_ELEMENT_ERROR');
     hr_utility.set_message_token('1','VERTEX');
     hr_utility.raise_error;
END IF;
hr_utility.set_location('PAY_US_EMP_TAX_RULES_PKG.Ele_entry',7);
--
-- Store Input value ID into table
--
inp_value_id_tbl(1) := P_inp_1;
inp_value_id_tbl(2) := P_inp_2;
inp_value_id_tbl(3) := P_inp_3;
scr_valuetbl(1)     := null;
scr_valuetbl(2)     := P_jurisdiction;
scr_valuetbl(3)     := nvl(P_time,'0');
--
if P_mode = 'I' then
--
-- Get effective Start date of the assignment
--
   OPEN  csr_get_eff_date;
   FETCH csr_get_eff_date into P_effective_stdt;
   if csr_get_eff_date%NOTFOUND then
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','ASG ELE ENTRY CREATION');
      hr_utility.set_message_token('STEP','10');
      hr_utility.raise_error;
   end if;
   CLOSE csr_get_eff_date;
--
   OPEN  csr_chk_entry;
   FETCH csr_chk_entry into p_element_entry_id, P_effective_stdt;
   IF csr_chk_entry%NOTFOUND THEN
-- Insert the element entry
--
     p_ins_or_upd := 'I';
   ELSE
     p_ins_or_upd := 'U';
   END IF;
   CLOSE  csr_chk_entry;

   hr_utility.set_location('PAY_US_EMP_TAX_RULES_PKG.Ele_entry',8);
elsif P_mode = 'U' OR p_ins_or_upd = 'U' then
--
-- Get Element entry id
--
   hr_utility.set_location('PAY_US_EMP_TAX_RULES_PKG.Ele_entry',10);
   OPEN  csr_chk_entry;
   FETCH csr_chk_entry into p_element_entry_id, P_effective_stdt;
   if csr_chk_entry%NOTFOUND then
--
     OPEN  csr_get_eff_date;
     FETCH csr_get_eff_date into P_effective_stdt;
     if csr_get_eff_date%NOTFOUND then
        hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
        hr_utility.set_message_token('PROCEDURE','ASG ELE ENTRY CREATION');
        hr_utility.set_message_token('STEP','12');
        hr_utility.raise_error;
     end if;
     CLOSE csr_get_eff_date;
     p_ins_or_upd := 'I';
   else
     p_ins_or_upd := 'U';
     IF P_effective_stdt > p_session_date THEN
        P_effective_stdt := p_session_date;
        -- change effective start date to new date
        -- Changed March 31, 1997
        -- Entries
        UPDATE pay_element_entries_f
        SET effective_start_date = P_effective_stdt
        WHERE element_entry_id = p_element_entry_id;
        -- entry values Values
        UPDATE pay_element_entry_values_f
        SET effective_start_date = P_effective_stdt
        WHERE element_entry_id = p_element_entry_id;
     END IF;
   end if;
--
   CLOSE csr_chk_entry;
end if;
--
-- Check whether to insert or Update
--
if P_ins_or_upd = 'I' then
   hr_utility.set_location('PAY_US_EMP_TAX_RULES_PKG.Ele_entry',14);
   hr_entry_api.insert_element_entry(
                p_effective_start_date     => P_effective_stdt,
                p_effective_end_date       => p_effective_end_date,
                p_element_entry_id         => p_element_entry_id,
                p_assignment_id            => P_assignment_id,
                p_element_link_id          => P_element_link_id,
                p_creator_type             => 'UT',
                p_entry_type               => 'E',
                p_num_entry_values         => 3,
                p_input_value_id_tbl       => inp_value_id_tbl,
                p_entry_value_tbl          => scr_valuetbl);
elsif P_ins_or_upd = 'U' then
   hr_utility.set_location('PAY_US_EMP_TAX_RULES_PKG.Ele_entry',16);
   hr_entry_api.update_element_entry(
                p_dt_update_mode           => 'CORRECTION',
                p_session_date             => P_effective_stdt,
                p_element_entry_id         => p_element_entry_id,
                p_num_entry_values         => 3,
                p_input_value_id_tbl       => inp_value_id_tbl,
                p_entry_value_tbl          => scr_valuetbl);
end if;
--
END create_vertex_entry;
--
--  Create Workers Compensation Element entries.
--------------------------- create_wc_ele_entry --------------------
--
PROCEDURE create_wc_ele_entry(
          P_assignment_id       Number,
          P_session_date        date,
          P_jurisdiction        varchar2)  IS

-- Declare table for input value Id and Screen Value
inp_value_id_tbl hr_entry.number_table;
scr_valuetbl     hr_entry.varchar2_table;

-- Local Varailbles
P_element_type_id     number       :=0;
P_element_link_id     number       :=0;
P_inp_1               number       :=0;
P_inp_2               number       :=0;
P_iname               varchar2(80) :=null;
P_inp                 number       :=0;
P_element_entry_id    number       :=0;
P_effective_stdt      date         :=null;
P_effective_end_date  date         :=null;
p_ins_or_upd          varchar2(1)  :=null;

-- Cursor to get the Workers Compensation element and link
CURSOR csr_wc_element is
       select pet.ELEMENT_TYPE_ID,              -- Bug 3354046: Upper clause is removed around pet.element_name and WORKERS COMPENSATION
              piv.INPUT_VALUE_ID,               -- changed to Workers Compensation to remove FTS on pay_element_types_f.
              piv.NAME
       from   PAY_ELEMENT_TYPES_F pet,
              PAY_INPUT_VALUES_F  piv
       where  PET.ELEMENT_NAME = 'Workers Compensation'
       and    P_session_date between pet.effective_start_date and
                                     pet.effective_end_date
       and    pet.element_type_id = piv.element_type_id
       and    P_session_date between piv.effective_start_date and
                                     piv.effective_end_date ;

-- Cursor to find out whether a element entry exists for the jurisdiction

CURSOR csr_chk_entry is
       select pee.ELEMENT_ENTRY_ID,
              pee.EFFECTIVE_START_DATE
       from   PAY_ELEMENT_ENTRIES_F      pee
       where  pee.assignment_id       = P_assignment_id
       and    P_session_date between pee.effective_start_date and
                                     pee.effective_end_date
       and    pee.element_link_id     = P_element_link_id;

-- Get Effective_start_Date of assignment
CURSOR csr_get_eff_Date is
       select effective_start_date
       from   PER_ASSIGNMENTS_F
       where  assignment_id = P_assignment_id
       and    P_session_date between effective_start_date and
                                     effective_end_date;
--
-- MAIN Procedure
--
begin
--
hr_utility.set_location('PAY_US_EMP_TAX_RULES_PKG.WC_ele_ent',1);
OPEN  csr_wc_element;
LOOP
  FETCH csr_wc_element INTO p_element_type_id,
                            P_inp, P_iname;
  EXIT WHEN csr_wc_element%NOTFOUND;
  IF upper(P_iname) = 'JURISDICTION'
  THEN
     P_inp_2 := P_inp;
  ELSIF upper(P_iname) = 'PAY VALUE'
  THEN
   P_inp_1 := P_inp;
  end if;
--
END LOOP;
--
CLOSE csr_wc_element;
hr_utility.set_location('PAY_US_EMP_TAX_RULES_PKG.WC_Ele_entry',4);
--
IF P_inp_1 = 0 OR P_inp_2 = 0 OR P_inp_2 is null OR P_inp_1 is null
THEN
  hr_utility.set_message(801, 'HR_7713_TAX_ELEMENT_ERROR');
  hr_utility.raise_error;
END IF;
--
-- Get element link
--
P_element_link_id := hr_entry_api.get_link(
                       P_assignment_id   => P_assignment_id,
                       P_element_type_id => P_element_type_id,
                       P_session_date    => P_session_date);
--
IF P_element_link_id is null OR P_element_link_id = 0
THEN
     hr_utility.set_message(801, 'HR_7713_TAX_ELEMENT_ERROR');
     hr_utility.raise_error;
END IF;
hr_utility.set_location('PAY_US_EMP_TAX_RULES_PKG.Ele_entry',5);
--
-- Store Input value ID into table
--
inp_value_id_tbl(1) := P_inp_1;
inp_value_id_tbl(2) := P_inp_2;
scr_valuetbl(1)     := null;
scr_valuetbl(2)     := P_jurisdiction;
--
--
-- Get Element entry id
--
   OPEN  csr_chk_entry;
   FETCH csr_chk_entry into p_element_entry_id, P_effective_stdt;
   if csr_chk_entry%NOTFOUND then
     p_ins_or_upd := 'I';
   else
     p_ins_or_upd := 'U';
   end if;
--
   CLOSE csr_chk_entry;
--
-- Get effective Start date of the assignment
--
   if P_effective_stdt is null OR p_ins_or_upd = 'I' then
   OPEN  csr_get_eff_date;
   FETCH csr_get_eff_date into P_effective_stdt;
   if csr_get_eff_date%NOTFOUND then
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','ASG WC ELE ENTRY CREATION');
      hr_utility.set_message_token('STEP','10');
      hr_utility.raise_error;
   end if;
   CLOSE csr_get_eff_date;
   end if;
   hr_utility.set_location('PAY_US_EMP_TAX_RULES_PKG.WC_Ele_entry',8);
--
--
-- Check whether to insert or Update
--
if P_ins_or_upd = 'I' then
   hr_utility.set_location('PAY_US_EMP_TAX_RULES_PKG.WC_Ele_entry',14);
   hr_entry_api.insert_element_entry(
                p_effective_start_date     => P_effective_stdt,
                p_effective_end_date       => p_effective_end_date,
                p_element_entry_id         => p_element_entry_id,
                p_assignment_id            => P_assignment_id,
                p_element_link_id          => P_element_link_id,
                p_creator_type             => 'UT',
                p_entry_type               => 'E',
                p_num_entry_values         => 2,
                p_input_value_id_tbl       => inp_value_id_tbl,
                p_entry_value_tbl          => scr_valuetbl);
elsif P_ins_or_upd = 'U' then
   hr_utility.set_location('PAY_US_EMP_TAX_RULES_PKG.WC_Ele_entry',16);
   hr_entry_api.update_element_entry(
                p_dt_update_mode           => 'CORRECTION',
                p_session_date             => P_effective_stdt,
                p_element_entry_id         => p_element_entry_id,
                p_num_entry_values         => 2,
                p_input_value_id_tbl       => inp_value_id_tbl,
                p_entry_value_tbl          => scr_valuetbl);
end if;
--
END create_wc_ele_entry;
--
PROCEDURE on_insert( p_rowid                    IN OUT nocopy VARCHAR2,
                     p_Assignment_Extra_Info_Id IN OUT nocopy NUMBER,
                     p_Assignment_Id                   NUMBER,
                     p_Information_Type                VARCHAR2,
                     p_session_date                    DATE,
                     p_jurisdiction                    VARCHAR2,
                     p_Aei_Information_Category        VARCHAR2,
                     p_Aei_Information1                VARCHAR2,
                     p_Aei_Information2                VARCHAR2,
                     p_Aei_Information3                VARCHAR2,
                     p_Aei_Information4                VARCHAR2,
                     p_Aei_Information5                VARCHAR2,
                     p_Aei_Information6                VARCHAR2,
                     p_Aei_Information7                VARCHAR2,
                     p_Aei_Information8                VARCHAR2,
                     p_Aei_Information9                VARCHAR2,
                     p_Aei_Information10               VARCHAR2,
                     p_Aei_Information11               VARCHAR2,
                     p_Aei_Information12               VARCHAR2,
                     p_Aei_Information13               VARCHAR2,
                     p_Aei_Information14               VARCHAR2,
                     p_Aei_Information15               VARCHAR2,
                     p_Aei_Information16               VARCHAR2,
                     p_Aei_Information17               VARCHAR2,
                     p_Aei_Information18               VARCHAR2,
                     p_Aei_Information19               VARCHAR2,
                     p_Aei_Information20               VARCHAR2
                     ) IS
BEGIN
--
PAY_US_EMP_TAX_RULES_PKG.Insert_Row(
           X_Rowid                    => p_Rowid                   ,
           X_Assignment_Extra_Info_Id => p_Assignment_Extra_Info_Id,
           X_Assignment_Id            => p_Assignment_Id           ,
           X_Information_Type         => p_Information_Type        ,
           X_session_date             => p_session_date            ,
           X_jurisdiction             => p_jurisdiction            ,
           X_Aei_Information_Category => p_Aei_Information_Category,
           X_Aei_Information1         => p_Aei_Information1        ,
           X_Aei_Information2         => p_Aei_Information2        ,
           X_Aei_Information3         => p_Aei_Information3        ,
           X_Aei_Information4         => p_Aei_Information4        ,
           X_Aei_Information5         => p_Aei_Information5        ,
           X_Aei_Information6         => p_Aei_Information6        ,
           X_Aei_Information7         => p_Aei_Information7        ,
           X_Aei_Information8         => p_Aei_Information8        ,
           X_Aei_Information9         => p_Aei_Information9        ,
           X_Aei_Information10        => p_Aei_Information10       ,
           X_Aei_Information11        => p_Aei_Information11       ,
           X_Aei_Information12        => p_Aei_Information12       ,
           X_Aei_Information13        => p_Aei_Information13       ,
           X_Aei_Information14        => p_Aei_Information14       ,
           X_Aei_Information15        => p_Aei_Information15       ,
           X_Aei_Information16        => p_Aei_Information16       ,
           X_Aei_Information17        => p_Aei_Information17       ,
           X_Aei_Information18        => p_Aei_Information18       ,
           X_Aei_Information19        => p_Aei_Information19       ,
           X_Aei_Information20        => p_Aei_Information20);
--
 hr_utility.set_location('pay_us_emp_tax_rules_pkg.on_insert',11);
    pay_us_emp_tax_rules_pkg.create_vertex_entry(
           P_mode               => 'I',
           P_assignment_id      => p_assignment_id,
           P_information_type   => p_information_type,
           P_session_date       => p_session_date,
           P_jurisdiction       => p_jurisdiction,
           P_time_in_locality   => p_aei_information10,
           P_remainder_percent  => p_aei_information16);
--
END on_insert;
--
------------------------------Insert County Record-----------------------------
/* This function inserts a county record if a city record is inserted from the form */

Procedure create_county_record( P_Jurisdiction varchar2,
                                P_assignment_id   number,
                                P_filing_status   varchar2,
                                P_session_date    date
                                )
is

l_assignment_id        number;
l_session_date         date;
l_county_locality_code varchar2(30);
l_filing_status        varchar2(30):= 'SINGLE';
l_county_sd_code       varchar2(30):= NULL;
l_state_code           varchar2(30):= 'U';
l_locality_county      varchar2(30):= 'UNKNOWN';
l_locality_code        varchar2(30);
l_temp                 varchar2(30);
l_message              varchar2(30);
l_id                   NUMBER := NULL;
l_count                NUMBER := 0;

/* Cursor to get the the county School district */
CURSOR csr_get_county_sd(Jurisdiction varchar2) IS
      SELECT  school_dst_code
      FROM    pay_us_county_school_dsts
      WHERE   STATE_CODE  = fnd_number.canonical_to_number(substr(Jurisdiction,1,2))
      AND     COUNTY_CODE = fnd_number.canonical_to_number(substr(Jurisdiction,4,3))
      ORDER BY TO_NUMBER(school_dst_code);

/* Check if county record already exists */
CURSOR csr_county_for_city is
      select 1
      from per_assignment_extra_info
      where assignment_id = P_assignment_id
      and   aei_information2 = substr(P_jurisdiction,1,6)||'-0000';

/* Get state abbreviation */
CURSOR csr_state_abbrev is
      select state_abbrev
      from pay_us_states
      where state_code = fnd_number.canonical_to_number(substr(P_jurisdiction,1,2));

/* Gets the county name */

CURSOR csr_county_name is
      select county_name
      from pay_us_counties
      where fnd_number.canonical_to_number(substr(P_jurisdiction, 1,2)) = state_code
      and   fnd_number.canonical_to_number(substr(P_jurisdiction, 4,3)) = county_code;


BEGIN  /* create_county_record */

OPEN csr_county_for_city;
FETCH csr_county_for_city INTO l_temp;

/* Check if county record already exists, if not then create one */

IF csr_county_for_city%notfound THEN /* insert county record for new city record */

l_assignment_id := p_assignment_id;
l_session_date  := p_session_date;
l_county_locality_code := substr(p_jurisdiction,1,6)||'-0000';
l_filing_status := p_filing_status;


/* Must get school district code */
/* Commenting out for Bug 643121 */
-- OPEN csr_get_county_sd(l_locality_code);
-- FETCH csr_get_county_sd INTO l_county_sd_code;
-- CLOSE csr_get_county_sd;

/* get the State Abbreviation */
OPEN csr_state_abbrev;
FETCH csr_state_abbrev INTO l_state_code;
CLOSE csr_state_abbrev;

/* Get county name */
OPEN csr_county_name;
FETCH csr_county_name INTO l_locality_county;
CLOSE csr_county_name;

      /*Insert county record */
             PAY_US_EMP_TAX_RULES_PKG.Insert_Row(
           X_Rowid                    => l_temp,
           X_Assignment_Extra_Info_Id => l_id,
           X_Assignment_Id            => l_assignment_id,
           X_Information_Type         => 'LOCALITY',
           X_session_date             => l_session_date,
           X_jurisdiction             => l_county_locality_code,
           X_Aei_Information_Category => 'LOCALITY',
           X_Aei_Information1         => l_state_code,
           X_Aei_Information2         => l_county_locality_code,
           X_Aei_Information3         => l_filing_status,
           X_Aei_Information4         => '0',
           X_Aei_Information5         => '0',
           X_Aei_Information6         => '0',
           X_Aei_Information7         => 'N',
           X_Aei_Information8         => 'Y',
           X_Aei_Information9         => l_county_sd_code,
           X_Aei_Information10        => '0',
           X_Aei_Information11        => '0',
           X_Aei_Information12        => '0',
           X_Aei_Information13        => l_locality_county,
           X_Aei_Information14        => Null,
           X_Aei_Information15        => Null,
           X_Aei_Information16        => Null,
           X_Aei_Information17        => Null,
           X_Aei_Information18        => Null,
           X_Aei_Information19        => Null,
           X_Aei_Information20        => Null);

  l_id := NULL;

END IF; /* County record already exists */



close csr_county_for_city;

END;   /*create_county_record*/

------------------------------Update Attribute-----------------------------
/* This procedure is used to update single attributes within tax records.*/
/* This was created because often times attributes need to be updated on */
/* records other then the present record on the form.                    */
/* Attributes to be supported: Percent time, School district code        */
---------------------------------------------------------------------------

Procedure Update_Attribute( p_rowid          VARCHAR2,
                            p_attribute_type VARCHAR2,
                            p_new_value      VARCHAR2,
                            p_jurisdiction   VARCHAR2,
                            p_state_abbrev   VARCHAR2,
                            p_assignment_id  NUMBER)
IS

BEGIN
--
 hr_utility.set_location('pay_us_emp_tax_rules_pkg.update_attribute '||p_assignment_id||'    '||p_jurisdiction,0);
IF  p_attribute_type = 'SCHOOL' THEN
   UPDATE per_assignment_extra_info
   SET aei_information9 = p_new_value
   where rowid = p_rowid;
 hr_utility.set_location('pay_us_emp_tax_rules_pkg.update_attribute',1);
--
ELSIF  p_attribute_type = 'PERCENT TIME' THEN
   /* for Locality */
   UPDATE per_assignment_extra_info
   SET aei_information10 = p_new_value
   WHERE information_type = 'LOCALITY'
   AND   aei_information2 = p_jurisdiction
   AND   assignment_id = p_assignment_id;
--
   /* for State */
   UPDATE per_assignment_extra_info
   SET aei_information13 = p_new_value
   WHERE information_type = 'STATE'
   AND   aei_information1 = p_state_abbrev
   AND   assignment_id = p_assignment_id;
 hr_utility.set_location('pay_us_emp_tax_rules_pkg.update_attribute',2);
--
   /* for Federal update the SUI state */
   UPDATE per_assignment_extra_info
   SET aei_information18 = substr(p_jurisdiction,1,2)||'-000-0000'
   WHERE information_type = 'FEDERAL'
   AND   assignment_id = p_assignment_id;
--
END IF;
--
--
END; /* Update_attribute */
--
--
-- This procedure is for the defaulting of tax records from forms
-- other than the W4(PAYEETAX) form
-- It has more detailed error messages and effects time in state.
--
PROCEDURE default_tax_with_validation(p_assignment_id     NUMBER,
                                      p_person_id         NUMBER,
                                      p_date              DATE,
                                      p_business_group_id NUMBER,
                                      p_return_code OUT nocopy  VARCHAR2,
                                      p_from_form         VARCHAR2,
                                      p_percent_time      NUMBER)
IS
--
l_return_code VARCHAR2(100) := 'Continue';
l_verified              NUMBER;
l_time                  NUMBER;
l_assignment_id         NUMBER;
l_exists                VARCHAR2(100);
l_res_state             VARCHAR2(100);
l_res_state_code        VARCHAR2(100);
l_res_locality          VARCHAR2(100);
l_work_state            VARCHAR2(100);
l_work_state_code       VARCHAR2(100);
l_work_jurisdiction     VARCHAR2(100);
l_work_locality         VARCHAR2(100);
l_work_loc_name         VARCHAR2(100);
l_resident_loc_name     VARCHAR2(100);
l_work_county_name      VARCHAR2(100);
l_resident_county_name  VARCHAR2(100);
l_d_or_g                VARCHAR2(100) := NULL;
l_error                 VARCHAR2(100) := NULL;
l_county                VARCHAR2(100);
l_zip_code              VARCHAR2(100);
--
-- Checks for qaulifying conditions for the assignment to be
-- defaulted.
--
CURSOR csr_qualify_info(per_id NUMBER) IS
SELECT assignment_id
FROM per_assignments_f
WHERE person_id = per_id
AND   assignment_type = 'E'
AND   location_id IS NOT NULL
AND   payroll_id IS NOT NULL
AND   pay_basis_id IS NOT NULL
AND   primary_flag = 'Y'
AND   p_date between effective_start_date
      and effective_end_date;
--
--Gets the Primary assignment if called from
--a form other than the assignment form.
--
CURSOR csr_person_info(per_id NUMBER) IS
SELECT paf.assignment_id
FROM per_assignments_f paf,
     per_people_f ppf,
     per_addresses pa
WHERE paf.person_id = ppf.person_id
AND   paf.assignment_type = 'E'
AND   ppf.person_id = pa.person_id
AND   pa.primary_flag = 'Y'
AND   paf.location_id IS NOT NULL
AND   paf.payroll_id IS NOT NULL
AND   paf.person_id = per_id;
--
-- Gets Work Information
--
CURSOR csr_get_work is
       select
              psr.state_code,
              hl.region_1,
              hl.postal_code,
              hl.town_or_city
       from   PER_ASSIGNMENTS_F   paf,
              HR_LOCATIONS        hl,
              PAY_STATE_RULES     psr
       where  paf.assignment_id         = P_assignment_id
       and    P_date between paf.effective_start_date and
                                     paf.effective_end_date
       and    paf.location_id           = hl.location_id
       and    psr.state_code            = hl.region_2;
--
CURSOR csr_chk_percent_state IS
SELECT sum(time_in_state)
FROM pay_emp_state_tax_v1
WHERE assignment_id = p_assignment_id;
--
CURSOR csr_check_aei_exists(p_work_jur  VARCHAR2)  IS
Select jurisdiction_code
From pay_emp_local_tax_v1
where assignment_id = p_assignment_id
and jurisdiction_code =p_work_jur;

--
BEGIN /* BEGIN DEFAULT TAX WITH VALIDATION */
--
  hr_utility.set_location('pay_us_emp_tax_rules_pkg.validate_default',0);
  IF p_from_form = 'Address' THEN
--
     hr_utility.set_location('pay_us_emp_tax_rules_pkg.validate_default',1);
--
--   Check for primary assignment
--
     OPEN csr_qualify_info(p_person_id);
     FETCH csr_qualify_info INTO l_assignment_id;

     hr_utility.set_location('pay_us_emp_tax_rules_pkg.validate_default',1.5);
--   If one doesn't exist, or person is not an employee
--   then quit and return to address form(No message)
     IF csr_qualify_info%NOTFOUND THEN
        hr_utility.set_location('pay_us_emp_tax_rules_pkg.validate_default',2);
        l_return_code := 'No Assignment';
     END IF;
--
     CLOSE csr_qualify_info;
  END IF; /* End of address form specific */
--
  IF p_from_form = 'Assignment' OR l_return_code = 'Continue' THEN
     hr_utility.set_location('pay_us_emp_tax_rules_pkg.validate_default',3);
--   Now check for all information: Payroll, home address
     OPEN csr_person_info(p_person_id);
     FETCH csr_person_info INTO l_verified;
--
     IF p_assignment_id IS NOT NULL THEN
          l_assignment_id := p_assignment_id;
     END IF;
-- If one or more of these things does not exist then do not create
-- tax records
     IF csr_person_info%NOTFOUND THEN
        hr_utility.set_location('pay_us_emp_tax_rules_pkg.validate_default',4);
        l_return_code := 'Incomplete';
     END IF;
     CLOSE csr_person_info;
--
  END IF;
--
  IF l_return_code = 'Continue' THEN /* NOW default this */
      pay_us_emp_tax_rules_pkg.default_tax(
                       X_assignment_id     =>     l_assignment_id,
                       X_session_date      =>     p_date,
                       X_business_group_id =>     p_business_group_id,
                       X_resident_state    =>     l_res_state,
                       X_res_state_code    =>     l_res_state_code,
                       X_work_state        =>     l_work_state,
                       X_work_state_code   =>     l_work_state_code,
                       X_resident_locality =>     l_res_locality,
                       X_work_locality     =>     l_work_locality,
                       X_work_jurisdiction =>     l_work_jurisdiction,
                       X_work_loc_name     =>     l_work_loc_name,
                       X_resident_loc_name =>     l_resident_loc_name,
                       X_default_or_get    =>     l_d_or_g,
                       X_error             =>     l_error,
                       X_from_form         =>     p_from_form );
   --
   hr_utility.set_location('pay_us_emp_tax_rules_pkg.validate_default',5);
   --
   -- Check for unvalidated Locations
   --
    IF l_res_locality is null then
      hr_utility.set_message(801,'HR_7556_TAY_NO_RES_ADDRESS');
      hr_utility.raise_error;
    END IF;

   IF l_work_state IS NULL OR l_error = 'Y' THEN
      hr_utility.set_message(801, 'HR_7557_TAY_NO_WOK_ADDRESS');
      hr_utility.raise_error;
   END IF;
   --
   --   Now if calling form was the assignment then need to set the
   --   work state and locality to 100%
    IF p_from_form = 'Assignment' THEN
      hr_utility.set_location('pay_us_emp_tax_rules_pkg.validate_default',6);
       -- First check that time in state is less set to zero
       --
       OPEN csr_chk_percent_state;
       FETCH csr_chk_percent_state INTO l_time;
       --
       IF l_time = 0 THEN
           --Update the tax record for state and locality --
           --Need to get Work Geocode--
         OPEN  csr_get_work;
         FETCH csr_get_work into    l_work_state_code,
                                 l_county,
                                 l_zip_code,
                                 l_work_loc_name;

         CLOSE  csr_get_work;
      --
         l_work_jurisdiction := hr_us_ff_udfs.addr_val (
                        p_state_abbrev => l_work_state_code,
                        p_county_name  => l_county,
                        p_city_name    => l_work_loc_name,
                        p_zip_code     => l_zip_code);
      --
         OPEN csr_check_aei_exists(l_work_jurisdiction);
         FETCH csr_check_aei_exists INTO l_exists;
         IF csr_check_aei_exists%FOUND THEN
          update_attribute(  p_rowid    => NULL,
                         p_attribute_type => 'PERCENT TIME',
                         p_new_value      => '100',
                         p_jurisdiction   => l_work_jurisdiction,
                         p_state_abbrev   => l_work_state_code,
                         p_assignment_id  => l_assignment_id);
      --
         hr_utility.set_location('pay_us_emp_tax_rules_pkg.validate_default '||l_work_jurisdiction,7);

   --
   --    Update the vertex element entry
   --
         pay_us_emp_tax_rules_pkg.create_vertex_entry(
         P_mode               => 'U',
         P_assignment_id      => l_assignment_id,
         P_information_type   => 'LOCALITY',
         P_session_date       => p_date,
         P_jurisdiction       => l_work_jurisdiction,
         P_time_in_locality   => '100',
         P_remainder_percent  => NULL);
   --
   --    Update the Workers Compenstion Element Entry
   --
         pay_us_emp_tax_rules_pkg.create_wc_ele_entry(
           P_assignment_id      => l_assignment_id,
           P_session_date       => p_date,
           P_jurisdiction       => substr(l_work_jurisdiction,1,2)||'-000-0000');
         ELSE /* NO tax records exists */
              /* Note:  This is the same error raised */
              /* if there is not location address */
            hr_utility.set_message(801, 'HR_7557_TAY_NO_WOK_ADDRESS');
            hr_utility.raise_error;
         END IF; /* end confirm tax record exists */
      END IF; /*Percent time = 0 */
     CLOSE csr_chk_percent_state;
     --
     END IF; /* Maintenance of the percent time in state */

   END IF; /* Records have been defaulted */
--
 p_return_code := l_return_code;
END; /*default_tax_with_validation */
--
---Zero out time in state and localities in preparation for setting---
---the new work location to 100%---
-- Currently this is called by the assignment form to
-- zero out all element_entries/tax records so if another error
-- is captured we do not end up with the sum of the  entries having
-- more than 100% time in jurisdiction.
--
PROCEDURE zero_out_time(p_assignment_id     NUMBER)
IS

-- Cursor to retreive the jurisdictions for all existing
-- VERTEX element entries
CURSOR vtx_info IS
SELECT peev.screen_entry_value jurisdiction,
       peef.effective_start_date start_date
  FROM  pay_element_entry_values_f peev,
        pay_element_entries_f peef,
        pay_element_links_f pel,
        pay_input_values_f piv,
        pay_element_types_f pet
  WHERE pet.element_name = 'VERTEX'
    AND pet.element_type_id = piv.element_type_id
    AND pel.element_type_id = pet.element_type_id
    AND peef.element_link_id = pel.element_link_id
    AND piv.input_value_id = 0 + peev.input_value_id
    AND peev.element_entry_id = peef.element_entry_id
    AND p_assignment_id = peef.assignment_id
    AND piv.name = 'Jurisdiction' ;
--
--
l_information_type  VARCHAR2(50);

BEGIN /* Zero out time */
-- hr_utility.trace_on('Y');
hr_utility.set_location('pay_us_emp_tax_rules_pkg.zero_out',1);
/* Set all tax records to zero percent time in state */
--
-- Localities
--
UPDATE per_assignment_extra_info
SET aei_information10 = 0
WHERE assignment_id = p_assignment_id
  AND INFORMATION_TYPE = 'LOCALITY';
hr_utility.set_location('pay_us_emp_tax_rules_pkg.zero_out',5);
--
-- States
--
UPDATE per_assignment_extra_info
SET aei_information13 = 0,
    aei_information16 = 0  /* Remainder percent */
WHERE assignment_id = p_assignment_id
  AND INFORMATION_TYPE = 'STATE';
--
--The part below was originaly included for performance but is now
--being changed to an API call.
--******************************************************
--UPDATE pay_element_entry_values
--SET screen_entry_value = '0'
--WHERE element_entry_value_id in
--( SELECT peev.element_entry_value_id
--  FROM pay_element_entry_values_f peev, pay_element_entries_f peef,
--         pay_input_values_f piv,
--       pay_element_types_f pet
--  WHERE pet.element_name = 'VERTEX'
--    AND pet.element_type_id = piv.element_type_id
--    AND piv.input_value_id = 0 + peev.input_value_id
--    AND peev.element_entry_id = peef.element_entry_id
--    AND p_assignment_id = peef.assignment_id
--    AND piv.name = 'Percentage' );
-- *****************************************************
-- Now loop through all VERTEX element entries
-- and set them to zero.  This will get much more complicated
-- with date tracking and should be self maintained within
-- the create_vertex_entry package.
--
FOR cur_rec IN vtx_info LOOP
--
  IF cur_rec.jurisdiction LIKE '%-000-0000' THEN
    l_information_type := 'State';
  ELSE
    l_information_type := 'Locality';
  END IF;
--
  pay_us_emp_tax_rules_pkg.create_vertex_entry(
         P_mode               => 'U',
         P_assignment_id      => p_assignment_id,
         P_information_type   => l_information_type,
         P_session_date       => cur_rec.start_date,
         P_jurisdiction       => cur_rec.jurisdiction,
         P_time_in_locality   => '0',
         P_remainder_percent  => '0');
--
END LOOP;
--
hr_utility.set_location('pay_us_emp_tax_rules_pkg.zero_out',10);
-- hr_utility.trace_off;
END; /* zero out time */
--
END pay_us_emp_tax_rules_pkg;

/
