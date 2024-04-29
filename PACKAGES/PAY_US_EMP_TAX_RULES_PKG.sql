--------------------------------------------------------
--  DDL for Package PAY_US_EMP_TAX_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_EMP_TAX_RULES_PKG" AUTHID CURRENT_USER as
/* $Header: pyustaxr.pkh 115.5 2004/01/21 07:14:13 saurgupt ship $ */
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
    Date        Name          Vers    Bug No     Description
    ----        ----          ----    ------     -----------
    OCT-22-1993 RMAMGAIN      1.0                Created with following proc.
                                                  .

    03-AUG-95	gpaytonm	40.6	Changed get_set_Def to default_tax. Added on_insert to be called
					from form such that defaulting VERTEX entries is easier to control -
					on_insert always creates one, but when defaulting want may not want
					a vertex record but do want a tax record. Added code to cater for
					unknown cities - inserts county record in this case. Altered code
					to only insert one vertex entry when work and res cities are the same
					Renamed create_tax_ele_Entry to create_vertex_entry
    30-SEP-95	lwthomps	40.7    Added new procedure Create_County_Record to create
                                        a county tax record for a city created through the
                                        form.
    14-JAN-96	lwthomps	40.7    Added new procedure update attribute for 418370.
                                        This function updates a attribute on a single record.
                                        Currently only for school district and Percent time.

    05-JUN-96	lwthomps	40.8    501979: created an overloaded version
                                        of default_tax such that it only
                                        commits when called from the Tax Form.
    18-JAN-02	fusman  	115.0   Added dbdrv commands and changed the parameters
                                        in the function Insert_Row to default null as
                                        to match the package body.
    10-MAY-02   sodhingr	115.4	Changed the default value of the parameters to
					subprogram Lock_Row,Update_Row,check_unique
    21-JAN-04   saurgupt        115.5   Bug 3354046: Change the package to make it gscc
                                        compliant.
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
                     );

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
                   );

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
                     X_Aei_Information20               VARCHAR2 default null);

PROCEDURE Delete_Row(X_Rowid VARCHAR2);

FUNCTION  check_unique(X_assignment_id         NUMBER   default null,
                       X_information_type      VARCHAR2 default null,
                       X_state_code            VARCHAR2 default null,
                       X_locality_code         VARCHAR2 default null)
RETURN NUMBER;


PROCEDURE default_tax( X_assignment_id     IN      NUMBER,
                       X_session_date      IN      DATE,
                       X_business_group_id IN      NUMBER,
                       X_resident_state    IN OUT nocopy  VARCHAR2 ,
                       X_res_state_code    IN OUT nocopy  VARCHAR2 ,
                       X_work_state        IN OUT nocopy  VARCHAR2 ,
                       X_work_state_code   IN OUT nocopy  VARCHAR2 ,
                       X_resident_locality IN OUT nocopy  VARCHAR2 ,
                       X_work_locality     IN OUT nocopy  VARCHAR2 ,
                       X_work_jurisdiction IN OUT nocopy  VARCHAR2 ,
                       X_work_loc_name     IN OUT nocopy  VARCHAR2 ,
                       X_resident_loc_name IN OUT nocopy  VARCHAR2 ,
                       X_default_or_get    IN OUT nocopy  VARCHAR2 ,
                       X_error             IN OUT nocopy  VARCHAR2 );
--
PROCEDURE default_tax( X_assignment_id     IN      NUMBER,
                       X_session_date      IN      DATE,
                       X_business_group_id IN      NUMBER,
                       X_resident_state    IN OUT nocopy  VARCHAR2 ,
                       X_res_state_code    IN OUT nocopy  VARCHAR2 ,
                       X_work_state        IN OUT nocopy  VARCHAR2 ,
                       X_work_state_code   IN OUT nocopy  VARCHAR2 ,
                       X_resident_locality IN OUT nocopy  VARCHAR2 ,
                       X_work_locality     IN OUT nocopy  VARCHAR2 ,
                       X_work_jurisdiction IN OUT nocopy  VARCHAR2 ,
                       X_work_loc_name     IN OUT nocopy  VARCHAR2 ,
                       X_resident_loc_name IN OUT nocopy  VARCHAR2 ,
                       X_default_or_get    IN OUT nocopy  VARCHAR2 ,
                       X_error             IN OUT nocopy  VARCHAR2 ,
                       X_from_form         IN      VARCHAR2);
--
PROCEDURE create_vertex_entry(
          P_mode                Varchar2,
          P_assignment_id       Number,
          P_information_type    varchar2,
          P_session_date        date,
          P_jurisdiction        varchar2,
	  p_time_in_locality	varchar2,
	  p_remainder_percent   varchar2 );
--
PROCEDURE create_wc_ele_entry(
          P_assignment_id       Number,
          P_session_date        date,
          P_jurisdiction        varchar2);
--
PROCEDURE on_insert( p_Rowid                    IN OUT nocopy VARCHAR2,
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
                     );
--
PROCEDURE Create_County_Record( P_Jurisdiction VARCHAR2,
                                P_assignment_id   NUMBER,
                                P_filing_status   VARCHAR2,
                                P_session_date    DATE );

--
------------------------------Update Attribute-----------------------------
/* This procedure is used to update single attributes within tax records.*/
/* This was created because often times attributes need to be updated on */
/* records other then the present record on the form.                    */
/* Attributes to be supported: Percent time, School district code        */
---------------------------------------------------------------------------
--
Procedure Update_Attribute( p_rowid          VARCHAR2,
                            p_attribute_type VARCHAR2,
                            p_new_value      VARCHAR2,
                            p_jurisdiction   VARCHAR2,
                            p_state_abbrev   VARCHAR2,
                            p_assignment_id  NUMBER);

--
----------------------Default_tax_with_validation-------------------------
/* Procedure to allow defaulting of taxes from the assignment and       */
/* address forms.                                                       */
--------------------------------------------------------------------------
--
PROCEDURE default_tax_with_validation(p_assignment_id     NUMBER,
                                      p_person_id         NUMBER,
                                      p_date              DATE,
                                      p_business_group_id NUMBER,
                                      p_return_code OUT nocopy   VARCHAR2,
                                      p_from_form         VARCHAR2,
                                      p_percent_time      NUMBER);
--
--------------------------Zero_out_time----------------------------------
/* Procedure to set % time in state to zero for all records, and then  */
/* the new work location can be set to 100 with update attribute       */
-------------------------------------------------------------------------
--
PROCEDURE zero_out_time(p_assignment_id     NUMBER);
--
END pay_us_emp_tax_rules_pkg;

 

/
