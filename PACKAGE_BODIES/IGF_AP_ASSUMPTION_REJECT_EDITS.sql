--------------------------------------------------------
--  DDL for Package Body IGF_AP_ASSUMPTION_REJECT_EDITS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_ASSUMPTION_REJECT_EDITS" AS
/* $Header: IGFAP33B.pls 120.1 2006/04/09 23:49:35 ridas noship $ */

/***************************************************************
Created By		:	masehgal
Date Created By	:	03-Feb-2003
Purpose		:	To Check Valid Date
Known Limitations,Enhancements or Remarks
Change History	:
Who			When		What
***************************************************************/

/*  DO NOT DELETE the code commented here
    It is likely to be pulled in in a forthcoming CCR
  --  CURSOR to be used for fetching the Correction ISIR for the Student
  --  (  For  edits  2008, 2012, 2025, 2041, 2046, 2060, 2062 )
  CURSOR   get_corr_record ( cp_base_id    igf_ap_isir_matched.base_id%TYPE )  IS
     SELECT *
       FROM igf_ap_isir_matched   isir
      WHERE isir.base_id  =  cp_base_id
        AND isir.system_record_type = 'CORRECTION' ;

  corr_rec    get_corr_record%ROWTYPE ;
*/


PROCEDURE assume_values  (
                           p_isir_rec       IN  OUT NOCOPY  igf_ap_isir_matched%ROWTYPE ,
	                        l_sys_batch_yr   IN              VARCHAR2
                         ) AS
/***************************************************************
Created By		:	masehgal
Date Created By	:	03-Feb-2003
Purpose		:	To make assumption values
Known Limitations,Enhancements or Remarks
Change History	:
Who			When		What
***************************************************************/

     PROCEDURE chk_num (
                         p_number  IN           VARCHAR2 ,
                         ret_num   OUT NOCOPY   NUMBER
                       ) IS
     /***************************************************************
       Created By		:	masehgal
       Date Created By	:	03-Feb-2003
       Purpose		:	To Check Valid Date
       Known Limitations,Enhancements or Remarks
       Change History	:
       Who			When		What
     ***************************************************************/

     BEGIN
        ret_num := TO_NUMBER( p_number ) ;
     EXCEPTION
        WHEN VALUE_ERROR THEN
             ret_num := NULL ;
     END chk_num ;


     PROCEDURE  a_date_prior_birth  AS
     /***************************************************************
       Created By		:	masehgal
       Date Created By	:	03-Feb-2003
       Purpose		:	To make assumption for Date of Prior Birth Field
       Known Limitations,Enhancements or Remarks
       Change History	:
       Who			When		What
     ***************************************************************/
     --          p_isir_rec.stud_dob_before_date     (1)
     --          p_isir_rec.date_of_birth            (2)
     --          p_isir_rec.a_date_of_birth

     l_prior_date   igf_ap_isir_matched_all.date_of_birth%TYPE ;

     BEGIN
        l_prior_date := igf_ap_efc_subf.efc_cutoff_date ( l_sys_batch_yr ) ;
        --  EDIT 1001
        IF (    ( p_isir_rec.stud_dob_before_date  IS NULL  OR  p_isir_rec.stud_dob_before_date = '2' )
            AND (    p_isir_rec.date_of_birth IS NOT NULL
                 AND p_isir_rec.date_of_birth < l_prior_date )
           )     THEN
                 -- assume value  ;
                 -- skip remaining edits on this field.
                 p_isir_rec.a_date_of_birth := '1' ;
        ELSE
           -- Edit 1001 not met
           -- Process EDIT 1002
           IF (    ( p_isir_rec.stud_dob_before_date IS NULL OR  p_isir_rec.stud_dob_before_date = '1' )
               AND (    p_isir_rec.date_of_birth IS NOT NULL
                    AND p_isir_rec.date_of_birth >= l_prior_date )
              )     THEN
                    -- assume value  ;
                    -- skip remaining edits on this field.
                    p_isir_rec.a_date_of_birth := '2' ;
           ELSE
                 -- Edit 1002 not met
                 -- Process EDIT 1003
                 IF (    p_isir_rec.stud_dob_before_date IS NULL
                     AND p_isir_rec.date_of_birth IS NULL
                    )    THEN
                         -- assume value  ;
                         p_isir_rec.a_date_of_birth := '2' ;
                 END IF ;
           END IF ;
        END IF ;

     END a_date_prior_birth ;


     PROCEDURE  a_stud_married AS
     /***************************************************************
       Created By		:	masehgal
       Date Created By	:	03-Feb-2003
       Purpose		:	To make assumption for Student's Marital Status
       Known Limitations,Enhancements or Remarks
       Change History	:
       Who			When		What
     ***************************************************************/
     --             p_isir_rec.s_married                  (1)
     --             p_isir_rec.s_marital_status           (2)
     --             p_isir_rec.s_num_family_members       (3)
     --             p_isir_rec.s_have_children            (4)
     --             p_isir_rec.legal_dependents           (5)
     --             p_isir_rec.spouse_income_from_work    (6)
     --             p_isir_rec.a_student_married

     BEGIN
        -- EDIT 1004
        IF (    ( p_isir_rec.s_married IS NULL    OR    p_isir_rec.s_married = '2' )
            AND   p_isir_rec.s_marital_status IN ('2','3')
           )      THEN
                  -- assume value
                  -- skip remainig edits on this field
                  p_isir_rec.a_student_married := '1' ;
        ELSE
           -- EDIT 1005
           IF (   ( p_isir_rec.s_married IS NULL   OR    p_isir_rec.s_married = '1')
               AND  p_isir_rec.s_marital_status = '1'
              )     THEN
                    -- assume value
                    -- skip remainig edits on this field
                    p_isir_rec.a_student_married := '2' ;
           ELSE
              -- EDIT 1006
              IF (    ( p_isir_rec.s_married IS NULL   OR   p_isir_rec.s_married =  '1' )
                  AND   p_isir_rec.s_marital_status IS NULL
                  AND (    p_isir_rec.s_num_family_members IS NULL
                       OR  p_isir_rec.s_num_family_members = 0
                       OR  p_isir_rec.s_num_family_members = 1 )
                 )     THEN
                       -- assume value
                       -- skip remainig edits on this field
                       p_isir_rec.a_student_married := '2' ;
              ELSE
                 -- EDIT 1007
                 IF (    p_isir_rec.s_married IS NULL
                     AND p_isir_rec.s_marital_status IS NULL
                     AND p_isir_rec.s_num_family_members = 2
                     AND p_isir_rec.s_have_children = '2'
                     AND p_isir_rec.legal_dependents = '2'
                    )    THEN
                         -- assume value
                         -- skip remainig edits on this field
                         p_isir_rec.a_student_married := '1' ;
                 ELSE
                     -- EDIT 1008
                     IF (    ( p_isir_rec.s_married IS NULL   OR   p_isir_rec.s_married = '1' )
                         AND   p_isir_rec.s_marital_status IS NULL
                         AND   p_isir_rec.s_num_family_members = 2
                         AND ( p_isir_rec.s_have_children =  '1'   OR   p_isir_rec.legal_dependents =  '1' )
                        )     THEN
                              -- assume value
                              -- skip remainig edits on this field
                              p_isir_rec.a_student_married := '2' ;
                     ELSE
                        -- EDIT 1009
                        IF (    ( p_isir_rec.s_married IS NULL   OR   p_isir_rec.s_married = '2')
                            AND   p_isir_rec.s_marital_status  IS NULL
                            AND   p_isir_rec.s_num_family_members = 2
                            AND   p_isir_rec.s_have_children IS NULL
                            AND   p_isir_rec.legal_dependents IS NULL
                            AND ( p_isir_rec.spouse_income_from_work is not NULL   AND   p_isir_rec.spouse_income_from_work <> 0 )
                           )      THEN
                                  -- assume value
                                  -- skip remainig edits on this field
                                  p_isir_rec.a_student_married := '1' ;
                        ELSE
                           -- EDIT 1010
                           IF (    ( p_isir_rec.s_married IS NULL   OR   p_isir_rec.s_married = '1')
                               AND   p_isir_rec.s_marital_status IS NULL
                               AND   p_isir_rec.s_num_family_members = 2
                               AND   p_isir_rec.s_have_children IS NULL
                               AND   p_isir_rec.legal_dependents IS NULL
                               AND ( p_isir_rec.spouse_income_from_work IS NULL   OR   p_isir_rec.spouse_income_from_work = 0 )
                              )      THEN
                                     -- assume value
                                     -- skip remainig edits on this field
                                     p_isir_rec.a_student_married := '2' ;
                           ELSE
                              -- EDIT 1011
                              IF (    ( p_isir_rec.s_married IS NULL   OR   p_isir_rec.s_married = '2' )
                                  AND   p_isir_rec.s_marital_status  IS NULL
                                  AND   p_isir_rec.s_num_family_members > 2
                                  AND ( p_isir_rec.spouse_income_from_work is not NULL   AND   p_isir_rec.spouse_income_from_work <> 0)
                                 )      THEN
                                        -- assume value
                                        -- skip remainig edits on this field
                                        p_isir_rec.a_student_married := '1' ;
                              ELSE
                                 -- EDIT 1012
                                 IF (    ( p_isir_rec.s_married IS NULL   OR   p_isir_rec.s_married = '1')
                                     AND   p_isir_rec.s_marital_status  IS NULL
                                     AND   p_isir_rec.s_num_family_members > 2
                                     AND ( p_isir_rec.spouse_income_from_work IS NULL   OR   p_isir_rec.spouse_income_from_work = 0 )
                                    )      THEN
                                           -- assume value
                                           -- skip remainig edits on this field
                                           p_isir_rec.a_student_married := '2' ;
                                 END IF ;  -- Edit 1012
                              END IF ;  -- Edit 1011
                           END IF ;  -- Edit 1010
                       END IF ;  -- Edit 1009
                    END IF ;  -- Edit 1008
                 END IF ;  -- Edit 1007
              END IF ;  -- Edit 1006
           END IF ;  -- Edit 1005
        END IF ;  -- Edit 1004

     END a_stud_married;


     PROCEDURE  a_stud_have_children AS
     /***************************************************************
       Created By		:	masehgal
       Date Created By	:	03-Feb-2003
       Purpose		:	To make assumption for Student's Children
       Known Limitations,Enhancements or Remarks
       Change History	:
       Who			When		What
     ***************************************************************/
     --           p_isir_rec.s_num_family_members    (1)
     --           p_isir_rec.s_have_children         (2)
     --           p_isir_rec.legal_dependents        (3)
     --           p_isir_rec.a_have_children
     --           p_isir_rec.a_s_have_dependents

     BEGIN
        -- Edit 1013
        IF (    (   p_isir_rec.s_num_family_members IS NULL
                 OR p_isir_rec.s_num_family_members = 0
                 OR p_isir_rec.s_num_family_members = 1 )
            AND  p_isir_rec.s_have_children = '1'
           )     THEN
                 -- assume value
                 p_isir_rec.a_have_children := '2' ;
        END IF ;
     END a_stud_have_children;


     PROCEDURE  a_stud_legal_depend AS
     /***************************************************************
       Created By		:	masehgal
       Date Created By	:	03-Feb-2003
       Purpose		:	To make assumption for Student's Legal Dependents
       Known Limitations,Enhancements or Remarks
       Change History	:
       Who			When		What
     ***************************************************************/
     --           p_isir_rec.s_num_family_members    (1)
     --           p_isir_rec.s_have_children         (2)
     --           p_isir_rec.legal_dependents        (3)
     --           p_isir_rec.a_have_children
     --           p_isir_rec.a_s_have_dependents

     BEGIN
        -- Edit 1013
        IF (    (   p_isir_rec.s_num_family_members IS NULL
                 OR p_isir_rec.s_num_family_members = 0
                 OR p_isir_rec.s_num_family_members = 1 )
            AND  p_isir_rec.legal_dependents = '1'
           )     THEN
                 -- assume value
                 p_isir_rec.a_s_have_dependents := '2' ;
        END IF ;

     END a_stud_legal_depend;


     PROCEDURE  a_stud_veteran_status AS
     /***************************************************************
       Created By		:	masehgal
       Date Created By	:	03-Feb-2003
       Purpose		:	To make assumption Student's Veteran Status
       Known Limitations,Enhancements or Remarks
       Change History	:
       Who			When		What
     ***************************************************************/
     --              p_isir_rec.s_veteran      (1)
     --              p_isir_rec.va_match_flag  (2)
     --              p_isir_rec.a_va_status

     BEGIN
        -- Edit 1014
        IF p_isir_rec.batch_year IN ('6','7') THEN
          -- this edit not required for award year 5
          NULL;
        ELSE
          IF (    p_isir_rec.s_veteran = '1'
              AND p_isir_rec.va_match_flag IN ('2','3')
             )    THEN
                  -- assume value
                  p_isir_rec.a_va_status := '2' ;
          END IF ;
        END IF;

     END a_stud_veteran_status;


     PROCEDURE  assum_depend_status AS
     /***************************************************************
       Created By		:	masehgal
       Date Created By	:	03-Feb-2003
       Purpose		:	To make assumption for Student's Dependency Status
       Known Limitations,Enhancements or Remarks
       Change History	:
       Who			When		What
     ***************************************************************/
     --           p_isir_rec.a_date_of_birth            (1)
     --           p_isir_rec.stud_dob_before_date       (2)
     --           p_isir_rec.a_va_status                (3)
     --           p_isir_rec.s_veteran                  (4)
     --           p_isir_rec.deg_beyond_bachelor        (5)
     --           p_isir_rec.a_student_married          (6)
     --           p_isir_rec.s_married                  (7)
     --           p_isir_rec.orphan_ward_of_court       (8)
     --           p_isir_rec.a_have_children            (9)
     --           p_isir_rec.s_have_children            (10)
     --           p_isir_rec.a_s_have_dependents        (11)
     --           p_isir_rec.legal_dependents           (12)
     --           p_isir_rec.dependency_status
     --           p_isir_rec.dependency_override_ind    (14)

     BEGIN
        -- Dependency Edit --1015
        IF (   (NVL (p_isir_rec.a_date_of_birth     , p_isir_rec.stud_dob_before_date ) = '1' )
            OR (NVL (p_isir_rec.a_va_status         , p_isir_rec.s_veteran            ) = '1' )
            OR (NVL (p_isir_rec.deg_beyond_bachelor , '0'                             ) = '1' )
            OR (NVL (p_isir_rec.orphan_ward_of_court, '0'                             ) = '1' )
            OR (NVL (p_isir_rec.a_have_children     , p_isir_rec.s_have_children      ) = '1' )
            OR (NVL (p_isir_rec.a_s_have_dependents , p_isir_rec.legal_dependents     ) = '1' )
            OR (NVL (p_isir_rec.a_student_married   , p_isir_rec.s_married            ) = '1' )
           )    THEN
                --  assume values ;
                -- skip remainig edits on this field
                p_isir_rec.dependency_status := 'I' ;
        ELSE --1016
               --  assume values ;
               -- skip remainig edits on this field
               p_isir_rec.dependency_status := 'D' ;
        END IF ;

        --Edit 1017 (new edit 1016)
        IF  p_isir_rec.dependency_status = 'D' AND p_isir_rec.dependency_override_ind = '1'  THEN
            p_isir_rec.dependency_status := 'I' ;
        END IF ;
     END assum_depend_status;


     PROCEDURE  a_p_marital_status AS
     /***************************************************************
       Created By		:	masehgal
       Date Created By	:	03-Feb-2003
       Purpose		:	To make assumption for Parent's Marital Status
       Known Limitations,Enhancements or Remarks
       Change History	:
       Who			When		What
     ***************************************************************/
     --              p_isir_rec.p_marital_status           (1)
     --              p_isir_rec.p_num_family_member        (2)
     --              p_isir_rec.a_p_marital_status

     BEGIN
        -- Edit  2001
        IF (    p_isir_rec.p_marital_status IS NULL
            AND p_isir_rec.p_num_family_member > 2
           )    THEN
                -- assume value ;
                p_isir_rec.a_p_marital_status := '1' ;
        END IF ;

        -- Edit 2002
        IF (    p_isir_rec.p_marital_status IS NULL
            AND p_isir_rec.p_num_family_member = 2
           )    THEN
                -- assume value ;
                p_isir_rec.a_p_marital_status := '2' ;
        END IF ;

     END a_p_marital_status;


     PROCEDURE  a_p_num_in_fam AS
     /***************************************************************
       Created By		:	masehgal
       Date Created By	:	03-Feb-2003
       Purpose		:	To make assumption for Parent's Family Number
       Known Limitations,Enhancements or Remarks
       Change History	:
       Who			When		What
     ***************************************************************/
     --           p_isir_rec.p_num_family_member  (1)
     --           p_isir_rec.a_p_marital_status   (2)
     --           p_isir_rec.p_marital_status     (3)
     --           p_isir_rec.a_parents_num_family

     BEGIN

        -- Edit 2003
        IF (    (   p_isir_rec.p_num_family_member IS NULL
                 OR p_isir_rec.p_num_family_member = 1
                 OR p_isir_rec.p_num_family_member = 2     )
            AND ( p_isir_rec.p_marital_status = '1' )
           )     THEN
                 -- assume value ;
                 p_isir_rec.a_parents_num_family := 3 ;
        END IF ;

        -- Edit 2004
        IF (    (     NVL ( p_isir_rec.a_parents_num_family, p_isir_rec.p_num_family_member) IS NULL
                  OR  NVL ( p_isir_rec.a_parents_num_family, p_isir_rec.p_num_family_member) = 1 )
            AND ( p_isir_rec.p_marital_status  IN ('2','3','4'))
           )     THEN
                 -- assume value ;
                 p_isir_rec.a_parents_num_family := 2 ;
        END IF ;

     END a_p_num_in_fam;


     PROCEDURE  a_p_num_in_col AS
     /***************************************************************
       Created By		:	masehgal
       Date Created By	:	03-Feb-2003
       Purpose		:	To make assumption for Parent's Number of Family Members in College
       Known Limitations,Enhancements or Remarks
       Change History	:
       Who			When		What
     ***************************************************************/
     --              p_isir_rec.p_num_in_college        (1)
     --              p_isir_rec.a_parents_num_family    (2)
     --              p_isir_rec.p_num_family_member     (3)
     --              p_isir_rec.faa_adjustment          (4)
     --              p_isir_rec.a_p_marital_status      (5)
     --              p_isir_rec.p_marital_status        (6)
     --              p_isir_rec.system_record_type      (7)
     --              p_isir_rec.a_parents_num_college

     BEGIN
        -- Edit 2005
        IF ( p_isir_rec.p_num_in_college IS NULL   OR   p_isir_rec.p_num_in_college = 0 ) THEN
             -- assume value ;
             p_isir_rec.a_parents_num_college := 1 ;
        END IF ;

        -- Edit 2006
        IF (    NVL ( p_isir_rec.a_parents_num_college, p_isir_rec.p_num_in_college) = NVL ( p_isir_rec.a_parents_num_family, p_isir_rec.p_num_family_member )
            AND NVL ( p_isir_rec.a_parents_num_college, p_isir_rec.p_num_in_college) > 1
            AND NVL ( p_isir_rec.faa_adjustment,'2' ) <> '1'
           )    THEN
                -- assume value ;
                p_isir_rec.a_parents_num_college := 1 ;
        END IF ;

        -- Edit 2007
        IF p_isir_rec.assum_override_1 = '1' THEN
           NULL ;
        ELSE
           -- if override is not set only then make assumptions

          -- Edit 2007 .. if Override not set
/*  DO NOT DELETE the code commented here
    It is likely to be pulled in in a forthcoming CCR

                 IF     p_isir_rec.system_record_type <> 'CORRECTION'
                    AND p_isir_rec.p_num_in_college > 6 THEN
*/
           IF  NVL ( p_isir_rec.a_parents_num_college, p_isir_rec.p_num_in_college) > 6 THEN
               -- assume value ;
               p_isir_rec.a_parents_num_college := 1 ;
           END IF;

/*  DO NOT DELETE the code commented here
    It is likely to be pulled in in a forthcoming CCR
                       -- Edit 2008
                       -- Select the Correction Record for the same student and in that record
                       IF  corr_rec.p_num_in_college > 6 THEN
                           -- Assume value ;
                           -- skip remainig edits on this field
                           p_isir_rec.a_parents_num_college := NULL ;
                       END IF ; -- Edit 2008
*/
        END IF ; -- for override condition

        -- Edit 2009
        IF NVL ( p_isir_rec.a_parents_num_college, p_isir_rec.p_num_in_college) > NVL ( p_isir_rec.a_parents_num_family, p_isir_rec.p_num_family_member )  THEN
           -- Assume value ;
           p_isir_rec.a_parents_num_college := 1 ;
        END IF ;

        -- Edit 2010
        IF (    NVL ( p_isir_rec.a_parents_num_college, p_isir_rec.p_num_in_college) > NVL ( p_isir_rec.a_parents_num_family, p_isir_rec.p_num_family_member ) - 2
            AND p_isir_rec.p_marital_status = '1'
            AND NVL ( p_isir_rec.faa_adjustment, '2')  <> '1'
           )    THEN
                --Assume value ;
                p_isir_rec.a_parents_num_college := NVL ( p_isir_rec.a_parents_num_family, p_isir_rec.p_num_family_member ) - 2  ;
        END IF ;


     END a_p_num_in_col;


     PROCEDURE  a_p_agi AS
     /***************************************************************
       Created By		:	masehgal
       Date Created By	:	03-Feb-2003
       Purpose		:	To make assumption for Parent's AGI
       Known Limitations,Enhancements or Remarks
       Change History	:
       Who			When		What
     ***************************************************************/
     --              p_isir_rec.p_adjusted_gross_income    (1)
     --              p_isir_rec.p_type_tax_return          (2)
     --              p_isir_rec.p_tax_return_status        (3)
     --              p_isir_rec.f_income_work              (4)
     --              p_isir_rec.m_income_work              (5)
     --              p_isir_rec.system_record_type         (6)
     --              p_isir_rec.a_parents_agi

     BEGIN
        -- Edit 2011
        IF p_isir_rec.assum_override_2 = '1' THEN
           NULL ;
        ELSE
           -- skip assumption if override flag set
/*  DO NOT DELETE the code commented here
    It is likely to be pulled in in a forthcoming CCR

           IF      p_isir_rec.system_record_type <> 'CORRECTION'
              AND (p_isir_rec.p_adjusted_gross_income IS NULL   OR   p_isir_rec.p_adjusted_gross_income = 0 )
*/
           IF (    (p_isir_rec.p_adjusted_gross_income IS NULL   OR   p_isir_rec.p_adjusted_gross_income = 0 )
               AND (     p_isir_rec.p_type_tax_return IS NOT NULL
                    OR ( p_isir_rec.p_type_tax_return IS NULL   AND   p_isir_rec.p_tax_return_status in ('1','2')))
               AND (   ( p_isir_rec.f_income_work IS NOT NULL   AND   p_isir_rec.f_income_work <> 0 )
                    OR ( p_isir_rec.m_income_work IS NOT NULL   AND   p_isir_rec.m_income_work <> 0 ) )
              )     THEN
                    -- assume value ;
                    IF NVL(p_isir_rec.f_income_work,0) + NVL(p_isir_rec.m_income_work,0) > 999999 THEN
                       p_isir_rec.a_parents_agi := 999999 ;
                    ELSIF NVL(p_isir_rec.f_income_work,0) + NVL(p_isir_rec.m_income_work,0) < -999999 THEN
                       p_isir_rec.a_parents_agi := -999999 ;
                    ELSE
                       p_isir_rec.a_parents_agi := NVL(p_isir_rec.f_income_work,0) + NVL(p_isir_rec.m_income_work,0);
                    END IF ;
           END IF ; -- Edit 2011

/*
           -- ASSUMED EDIT FOR -VE to +VE Conversion
           IF NVL(p_isir_rec.a_parents_agi , p_isir_rec.p_adjusted_gross_income) < 0 THEN
                -- assume value ;
                p_isir_rec.a_parents_agi := 0 - NVL(p_isir_rec.a_parents_agi , p_isir_rec.p_adjusted_gross_income) ;
           END IF ;  -- Edit ends
*/


/*  DO NOT DELETE the code commented here
    It is likely to be pulled in in a forthcoming CCR
           -- Edit 2012
           IF     p_isir_rec.system_record_type <> 'CORRECTION'
              --  Select the Correction Record for the same student and in that record (1) = 0
              AND corr_rec.p_adjusted_gross_income = 0  THEN
                  -- assume value ;
                  p_isir_rec.a_parents_agi := NULL ;
           END IF ; -- Edit 2012
*/
        END IF ; -- Override condition

     END a_p_agi;


     PROCEDURE  a_f_work_income AS
     /***************************************************************
       Created By		:	masehgal
       Date Created By	:	03-Feb-2003
       Purpose		:	To make assumption for Father's Income from work
       Known Limitations,Enhancements or Remarks
       Change History	:
       Who			When		What
     ***************************************************************/
     --              p_isir_rec.a_parents_agi              (1)
     --              p_isir_rec.p_adjusted_gross_income    (2)
     --              p_isir_rec.p_tax_return_status        (3)
     --              p_isir_rec.f_income_work              (4)
     --              p_isir_rec.m_income_work              (5)
     --              p_isir_rec.p_cal_tax_status           (6)
     --              p_isir_rec.a_f_work_income

     BEGIN

        -- Edit 2013
        IF (     NVL ( p_isir_rec.a_parents_agi, p_isir_rec.p_adjusted_gross_income ) > 0
            AND   p_isir_rec.p_tax_return_status = '3'
            AND ( p_isir_rec.f_income_work IS NULL   OR   p_isir_rec.f_income_work = 0 )
            AND ( p_isir_rec.m_income_work IS NULL   OR   p_isir_rec.m_income_work = 0 )
           )      THEN
                  -- assume value ;
                  p_isir_rec.a_f_work_income := NVL ( p_isir_rec.a_parents_agi, p_isir_rec.p_adjusted_gross_income ) ;
        END IF ; -- Edit 2013
     END a_f_work_income;


     PROCEDURE  a_p_tax_status AS
     /***************************************************************
       Created By		:	masehgal
       Date Created By	:	03-Feb-2003
       Purpose		:	To make assumption for Parent's Tax Status
       Known Limitations,Enhancements or Remarks
       Change History	:
       Who			When		      What
       ridas    04-Apr-06     Added new logic for Edits 2016 and 2018 for Award Year 06-07
                              FA160 build
     ***************************************************************/
     --              p_isir_rec.p_type_tax_return          (1)
     --              p_isir_rec.p_tax_return_status        (2)
     --              p_isir_rec.a_parents_agi              (3)
     --              p_isir_rec.p_adjusted_gross_income    (4)
     --              p_isir_rec.p_cal_tax_status

     BEGIN
        -- Edit  2014
        IF p_isir_rec.p_type_tax_return is not NULL THEN
           -- assume value ;
           p_isir_rec.p_cal_tax_status  := '1' ;
        END IF ;

        -- Edit 2015
        IF (    p_isir_rec.p_type_tax_return IS NULL
            AND NVL ( p_isir_rec.p_cal_tax_status, p_isir_rec.p_tax_return_status) IN ('1','2')
           )    THEN
                -- assume value ;
                p_isir_rec.p_cal_tax_status  := '1' ;
        END IF ;

        -- Edit 2016
        IF p_isir_rec.batch_year = '7' THEN
          IF (p_isir_rec.p_type_tax_return IS NULL AND NVL(p_isir_rec.p_cal_tax_status, p_isir_rec.p_tax_return_status) IS NULL
               AND (NVL(p_isir_rec.a_parents_agi ,p_isir_rec.p_adjusted_gross_income) IS NOT NULL
               AND NVL(p_isir_rec.a_parents_agi ,p_isir_rec.p_adjusted_gross_income) <>0)
              ) THEN
               -- assume value
               p_isir_rec.p_cal_tax_status  := '1' ;
          END IF;
        ELSE
          IF (    p_isir_rec.p_type_tax_return IS NULL
              AND NVL ( p_isir_rec.p_cal_tax_status, p_isir_rec.p_tax_return_status) IS NULL
              AND (NVL(p_isir_rec.a_parents_agi ,p_isir_rec.p_adjusted_gross_income) IS NOT NULL )
             )     THEN
                   -- assume value ;
               p_isir_rec.p_cal_tax_status  := '1' ;
          END IF ;
        END IF; --Edit 2016

        -- Edit 2017
        IF (    p_isir_rec.p_type_tax_return IS NULL
            AND NVL ( p_isir_rec.p_cal_tax_status, p_isir_rec.p_tax_return_status) = '3'
           )    THEN
                -- assume value ;
                p_isir_rec.p_cal_tax_status  := '4' ;
        END IF ;

        -- Edit 2018
        IF p_isir_rec.batch_year = '7' THEN
           IF (p_isir_rec.p_type_tax_return IS NULL AND NVL ( p_isir_rec.p_cal_tax_status, p_isir_rec.p_tax_return_status) IS NULL
              AND (NVL (p_isir_rec.a_parents_agi ,p_isir_rec.p_adjusted_gross_income) IS NULL
                   OR NVL (p_isir_rec.a_parents_agi ,p_isir_rec.p_adjusted_gross_income) =0)
              ) THEN
               -- assume value ;
               p_isir_rec.p_cal_tax_status  := '4' ;
           END IF ;
        ELSE
           IF (    p_isir_rec.p_type_tax_return IS NULL
                AND NVL ( p_isir_rec.p_cal_tax_status, p_isir_rec.p_tax_return_status) IS NULL
                AND NVL (p_isir_rec.a_parents_agi ,p_isir_rec.p_adjusted_gross_income) IS NULL
               )    THEN
                    -- assume value ;
                p_isir_rec.p_cal_tax_status  := '4' ;
           END IF ;
        END IF ; -- Edit 2018

     END a_p_tax_status;

/*
     PROCEDURE ASSUMED_EDIT_FOR_P_AGI  AS

     BEGIN
        -- ASSUMED EDIT FOR -VE to +VE Conversion
         IF (     NVL(p_isir_rec.a_parents_agi , p_isir_rec.p_adjusted_gross_income) < 0
              AND p_isir_rec.p_tax_return_status in ('1','2')
            ) THEN
              -- assume value ;
              p_isir_rec.a_parents_agi := 0 - p_isir_rec.a_parents_agi ;
        END IF ;  -- Edit 2019
     END ASSUMED_EDIT_FOR_P_AGI;
*/


     PROCEDURE  a_p_us_tax_paid AS
     /***************************************************************
       Created By		:	masehgal
       Date Created By	:	03-Feb-2003
       Purpose		:	To make assumption for Parent's Tax Payment Status
       Known Limitations,Enhancements or Remarks
       Change History	:
       Who			When		What
     ***************************************************************/
     --           p_isir_rec.p_taxes_paid         (1)
     --           p_isir_rec.p_cal_tax_status     (2)
     --           p_isir_rec.a_p_us_tax_paid

     BEGIN
        -- Edit 2019
        IF (    p_isir_rec.p_taxes_paid IS NULL
            AND NVL ( p_isir_rec.p_cal_tax_status, p_isir_rec.p_tax_return_status) IN ('1','2','3')
           )    THEN
                -- assume value ;
                p_isir_rec.a_p_us_tax_paid := 0 ;
        END IF ;  -- Edit 2019
     END a_p_us_tax_paid;


     PROCEDURE  a_f_work_income_resume AS
     /***************************************************************
       Created By		:	masehgal
       Date Created By	:	03-Feb-2003
       Purpose		:	To make assumption for Mother's Income from work
       Known Limitations,Enhancements or Remarks
       Change History	:
       Who			When		What
     ***************************************************************/
     -- p_isir_rec.f_income_work            (1)
     -- p_isir_rec.m_income_work            (2)
     -- p_isir_rec.a_parents_agi            (3)
     -- p_isir_rec.p_adjusted_gross_income  (4)
     -- p_isir_rec.a_f_work_income
     -- p_isir_rec.a_f_work_income

     BEGIN
        -- Edit 2020
        IF (    NVL( p_isir_rec.a_f_work_income, p_isir_rec.f_income_work) IS NULL
            AND    ( p_isir_rec.m_income_work IS NULL  OR  p_isir_rec.m_income_work = 0 )
            AND (    NVL( p_isir_rec.a_parents_agi ,p_isir_rec.p_adjusted_gross_income ) IS NOT NULL
                 AND NVL( p_isir_rec.a_parents_agi ,p_isir_rec.p_adjusted_gross_income ) <> 0        )
           )     THEN
                 -- assume value
                 p_isir_rec.a_f_work_income := NVL (p_isir_rec.a_parents_agi ,p_isir_rec.p_adjusted_gross_income ) ;
        END IF ;

        -- Edit 2022
        IF (    NVL ( p_isir_rec.a_f_work_income, p_isir_rec.f_income_work) <  0
            AND NVL ( p_isir_rec.p_cal_tax_status, p_isir_rec.p_tax_return_status) IN ('4','5')
           )    THEN
                -- assume value
                p_isir_rec.a_f_work_income := 0 - NVL ( p_isir_rec.a_f_work_income, p_isir_rec.f_income_work) ;
        END IF ; -- Edit 2022

     END a_f_work_income_resume;


     PROCEDURE  a_m_work_income AS
     /***************************************************************
       Created By		:	masehgal
       Date Created By	:	03-Feb-2003
       Purpose		:	To make assumption for Mother's Income from work
       Known Limitations,Enhancements or Remarks
       Change History	:
       Who			When		What
     ***************************************************************/
     --              p_isir_rec.a_f_work_income         (1)
     --              p_isir_rec.f_income_work           (2)
     --              p_isir_rec.m_income_work           (3)
     --              p_isir_rec.a_parents_agi           (4)
     --              p_isir_rec.p_adjusted_gross_income (5)
     --              p_isir_rec.a_m_work_income

     BEGIN
        -- Edit 2021
        IF (    NVL(p_isir_rec.a_f_work_income, p_isir_rec.f_income_work) = 0
            AND p_isir_rec.m_income_work IS NULL
            AND (    NVL (p_isir_rec.a_parents_agi ,p_isir_rec.p_adjusted_gross_income ) IS NOT NULL
                 AND NVL (p_isir_rec.a_parents_agi ,p_isir_rec.p_adjusted_gross_income ) <> 0        )
           )     THEN
                 -- assume value
                 -- skip remaining edits on this field
                 p_isir_rec.a_m_work_income := NVL (p_isir_rec.a_parents_agi ,p_isir_rec.p_adjusted_gross_income ) ;
        END IF ;

        -- Edit 2023
        IF (    NVL ( p_isir_rec.a_m_work_income , p_isir_rec.m_income_work) <  0
            AND NVL ( p_isir_rec.p_cal_tax_status, p_isir_rec.p_tax_return_status) IN ('4','5')
           )    THEN
                -- assume value
                p_isir_rec.a_m_work_income := 0 - p_isir_rec.m_income_work ;
        END IF ; -- Edit 2023
     END a_m_work_income ;


     PROCEDURE  a_p_total_wsc AS
     /***************************************************************
       Created By		:	masehgal
       Date Created By	:	03-Feb-2003
       Purpose		:	To make assumption for Parent's Total Income from Worksheet C
       Known Limitations,Enhancements or Remarks
       Change History	:
       Who			When		What
     ***************************************************************/
     -- p_isir_rec.p_income_wsc             (1)
     -- p_isir_rec.a_parents_agi            (2)
     -- p_isir_rec.p_adjusted_gross_income  (3)
     -- p_isir_rec.p_income_wsa             (4)
     -- p_isir_rec.p_income_wsb             (5)
     -- p_isir_rec.p_cal_tax_status         (6)
     -- p_isir_rec.a_f_work_income          (7)
     -- p_isir_rec.f_income_work            (8)
     -- p_isir_rec.a_m_work_income          (9)
     -- p_isir_rec.m_income_work            (10)
     -- p_isir_rec.system_record_type       (11)
     -- p_isir_rec.a_p_total_wsc

     BEGIN

        -- Edit 2024
        IF p_isir_rec.assum_override_5 = '1'  THEN
           NULL ;
        ELSE
           -- skip assumption if override flag is set
/*  DO NOT DELETE the code commented here
    It is likely to be pulled in in a forthcoming CCR

           IF      p_isir_rec.system_record_type <> 'CORRECTION'
              AND (     (p_isir_rec.p_income_wsc > 0
*/
           IF (    (     (p_isir_rec.p_income_wsc > 0
                     AND (   (    NVL ( p_isir_rec.p_cal_tax_status, p_isir_rec.p_tax_return_status) IN ('1','2','3')
                              AND p_isir_rec.p_income_wsc > 0.9 * (GREATEST (NVL (NVL (p_isir_rec.a_parents_agi, p_isir_rec.p_adjusted_gross_income ) ,0 ) , 0 )  +
                                                                   GREATEST (     NVL (p_isir_rec.p_income_wsa ,0 ),0 )                                         +
                                                                   GREATEST (     NVL (p_isir_rec.p_income_wsb ,0 ),0 )                                         ) ) )
                          OR (    NVL ( p_isir_rec.p_cal_tax_status, p_isir_rec.p_tax_return_status) IN ('4','5')
                              AND p_isir_rec.p_income_wsc > 0.9 * (GREATEST (NVL (NVL (p_isir_rec.a_f_work_income, p_isir_rec.f_income_work )         ,0 ) , 0 )  +
                                                                   GREATEST (NVL (NVL (p_isir_rec.a_m_work_income, p_isir_rec.m_income_work )         ,0 ) , 0 )  +
                                                                   GREATEST (     NVL (p_isir_rec.p_income_wsa ,0 ),0 )                                         +
                                                                   GREATEST (     NVL (p_isir_rec.p_income_wsb ,0 ),0 )                                         ) ) ) )
              )      THEN
                     -- Assume value ;
                     p_isir_rec.a_p_total_wsc := 0 ;
           END IF ; -- Edit 2024

/*  DO NOT DELETE the code commented here
    It is likely to be pulled in in a forthcoming CCR

           -- do not skip Edit 2025
           -- Edit 2025
           IF     p_isir_rec.system_record_type <> 'CORRECTION'
              AND (     (corr_rec.p_income_wsc > 0
                   AND (   (    corr_rec.p_cal_tax_status IN ('1','2','3')
                            AND corr_rec.p_income_wsc > 0.9 * (GREATEST (NVL (NVL (corr_rec.a_parents_agi, corr_rec.p_adjusted_gross_income ) ,0 ) , 0 )  +
                                                               GREATEST (     NVL (corr_rec.p_income_wsa ,0 ),0 )                                         +
                                                               GREATEST (     NVL (corr_rec.p_income_wsb ,0 ),0 )                                         ) ) )
                        OR (    corr_rec.p_cal_tax_status IN ('4','5')
                            AND corr_rec.p_income_wsc > 0.9 * (GREATEST (NVL (NVL (corr_rec.a_f_work_income, corr_rec.f_income_work )         ,0 ) , 0 )  +
                                                               GREATEST (NVL (NVL (corr_rec.a_m_work_income, corr_rec.m_income_work )         ,0 ) , 0 )  +
                                                               GREATEST (     NVL (corr_rec.p_income_wsa ,0 ),0 )                                         +
                                                               GREATEST (     NVL (corr_rec.p_income_wsb ,0 ),0 )                                         ) ) ) )   THEN
                                -- Assume value ;
                                p_isir_rec.a_p_total_wsc := NULL ;
           END IF ; -- Edit 2025
*/
        END IF ; -- Override Condition

     END a_p_total_wsc;


     PROCEDURE  a_stud_citizenship AS
     /***************************************************************
       Created By		:	masehgal
       Date Created By	:	03-Feb-2003
       Purpose		:	To make assumption for Student's Citizenship
       Known Limitations,Enhancements or Remarks
       Change History	:
       Who			When		What
     ***************************************************************/
     --              p_isir_rec.citizenship_status      (1)
     --              p_isir_rec.alien_reg_number        (2)
     --              p_isir_rec.ssn_match_flag          (3)
     --              p_isir_rec.ssa_citizenship_flag    (4)
     --              p_isir_rec.a_citizenship

     l_val_num   NUMBER ;

     BEGIN
        chk_num ( p_isir_rec.alien_reg_number , l_val_num ) ;
        -- Edit 2026
        IF (    p_isir_rec.citizenship_status IS NULL
            AND (l_val_num is not NULL   AND   LENGTH(l_val_num) < 9   AND   LENGTH(l_val_num) > 7 )
           )     THEN
                 -- assume value ;
                 p_isir_rec.a_citizenship := '2' ;
        END IF ;

        -- Edit 2027
        IF (    (p_isir_rec.citizenship_status IS NULL     OR   p_isir_rec.citizenship_status = '2')
            AND  p_isir_rec.alien_reg_number IS NULL
            AND  p_isir_rec.ssn_match_flag = 4
            AND (p_isir_rec.ssa_citizenship_flag IS NULL   OR   p_isir_rec.ssa_citizenship_flag = 'A')
           )     THEN
                 -- assume value
                 p_isir_rec.a_citizenship := '1' ;
        END IF ; -- Edit 2027

     END a_stud_citizenship;


     PROCEDURE  a_stud_marital_status AS
     /***************************************************************
       Created By		:	masehgal
       Date Created By	:	03-Feb-2003
       Purpose		:	To make assumption for Student's Marital Status
       Known Limitations,Enhancements or Remarks
       Change History	:
       Who			When		What
     ***************************************************************/
     --              p_isir_rec.dependency_status        (1)
     --              p_isir_rec.s_marital_status         (2)
     --              p_isir_rec.s_num_family_members     (3)
     --              p_isir_rec.a_have_children          (4)
     --              p_isir_rec.s_have_children          (5)
     --              p_isir_rec.a_s_have_dependents      (6)
     --              p_isir_rec.legal_dependents         (7)
     --              p_isir_rec.spouse_income_from_work  (8)
     --              p_isir_rec.a_student_marital_status

     BEGIN
        -- Edit 2028
        IF (    p_isir_rec.dependency_status = 'I'
            AND p_isir_rec.s_marital_status IS NULL
            AND p_isir_rec.s_num_family_members = 1
           )    THEN
                -- assume value
                p_isir_rec.a_student_marital_status := '1' ;
        END IF ;

        -- Edit 2029
        IF (    p_isir_rec.dependency_status = 'I'
               AND NVL( p_isir_rec.a_student_marital_status, p_isir_rec.s_marital_status ) IS NULL
               AND p_isir_rec.s_num_family_members = 2
               AND NVL(p_isir_rec.a_have_children ,p_isir_rec.s_have_children) = '2'
               AND NVL(p_isir_rec.a_s_have_dependents ,p_isir_rec.legal_dependents) = '2'
              )    THEN
                   -- assume value
                   p_isir_rec.a_student_marital_status := '2' ;
        END IF ;

        -- Edit 2030
        IF (    p_isir_rec.dependency_status = 'I'
            AND NVL( p_isir_rec.a_student_marital_status, p_isir_rec.s_marital_status )  IS NULL
            AND p_isir_rec.s_num_family_members = 2
            AND NVL(p_isir_rec.a_have_children , p_isir_rec.s_have_children) = '1'
            AND NVL(p_isir_rec.a_s_have_dependents , p_isir_rec.legal_dependents) = '1'
           )    THEN
                -- assume value
                p_isir_rec.a_student_marital_status := '1' ;
        END IF ;

        -- Edit 2031
        IF (      p_isir_rec.dependency_status = 'I'
            AND   NVL( p_isir_rec.a_student_marital_status, p_isir_rec.s_marital_status )  IS NULL
            AND   p_isir_rec.s_num_family_members = 2
            AND ( p_isir_rec.spouse_income_from_work is not NULL   AND   p_isir_rec.spouse_income_from_work <> 0 )
           )      THEN
                  -- assume value
                  p_isir_rec.a_student_marital_status := '2' ;
        END IF ;

        -- Edit 2032
        IF (      p_isir_rec.dependency_status = 'I'
            AND   NVL( p_isir_rec.a_student_marital_status, p_isir_rec.s_marital_status )  IS NULL
            AND   p_isir_rec.s_num_family_members = 2
            AND ( p_isir_rec.spouse_income_from_work IS NULL   OR   p_isir_rec.spouse_income_from_work = 0 )
           )      THEN
                  -- assume value
                  p_isir_rec.a_student_marital_status := '1' ;
        END IF ;

        -- Edit 2033
        IF (      p_isir_rec.dependency_status = 'I'
            AND   NVL( p_isir_rec.a_student_marital_status, p_isir_rec.s_marital_status ) IS NULL
            AND   p_isir_rec.s_num_family_members > 2
            AND ( p_isir_rec.spouse_income_from_work is not NULL   AND   p_isir_rec.spouse_income_from_work <> 0 )
           )      THEN
                  -- assume value
                  p_isir_rec.a_student_marital_status := '2' ;
        END IF ;

        -- Edit 2034
        IF (      p_isir_rec.dependency_status = 'I'
            AND   NVL( p_isir_rec.a_student_marital_status, p_isir_rec.s_marital_status ) IS NULL
            AND   p_isir_rec.s_num_family_members > 2
            AND ( p_isir_rec.spouse_income_from_work IS NULL   OR   p_isir_rec.spouse_income_from_work = 0)
           )      THEN
                  -- assume value
                  p_isir_rec.a_student_marital_status := '1' ;
        END IF ;


     END a_stud_marital_status;


     PROCEDURE  a_stud_num_in_family AS
     /***************************************************************
       Created By		:	masehgal
       Date Created By	:	03-Feb-2003
       Purpose		:	To make assumption for Student's Number in Family
       Known Limitations,Enhancements or Remarks
       Change History	:
       Who			When		What
     ***************************************************************/
     --              p_isir_rec.dependency_status          (1)
     --              p_isir_rec.a_student_marital_status   (2)
     --              p_isir_rec.s_marital_status           (3)
     --              p_isir_rec.s_num_family_members       (4)
     --              p_isir_rec.a_have_children            (5)
     --              p_isir_rec.s_have_children            (6)
     --              p_isir_rec.a_s_have_dependents        (7)
     --              p_isir_rec.legal_dependents           (8)
     --              p_isir_rec.spouse_income_from_work    (9)
     --              p_isir_rec.a_s_num_in_family

     BEGIN
        -- Edit 2035
        IF (     p_isir_rec.dependency_status = 'I'
            AND  NVL( p_isir_rec.a_student_marital_status, p_isir_rec.s_marital_status ) = '2'
            AND (p_isir_rec.s_num_family_members IS NULL   OR   p_isir_rec.s_num_family_members = 0)
           )     THEN
                 -- assume value ;
                 p_isir_rec.a_s_num_in_family := 2 ;
        END IF ;

        -- Edit 2036
        IF (     p_isir_rec.dependency_status = 'I'
            AND  NVL( p_isir_rec.a_student_marital_status, p_isir_rec.s_marital_status ) in ('1','3')
            AND (    NVL (p_isir_rec.a_s_num_in_family , p_isir_rec.s_num_family_members ) IS NULL
                 OR  NVL (p_isir_rec.a_s_num_in_family , p_isir_rec.s_num_family_members ) = 0 )
           )     THEN
                 -- assume value ;
                 p_isir_rec.a_s_num_in_family := 1 ;
        END IF ;

        -- Edit 2037
        IF (     p_isir_rec.dependency_status = 'I'
            AND  NVL( p_isir_rec.a_student_marital_status, p_isir_rec.s_marital_status ) = '2'
            AND  NVL (p_isir_rec.a_s_num_in_family , p_isir_rec.s_num_family_members ) = 1
            AND (p_isir_rec.spouse_income_from_work is not NULL   AND   p_isir_rec.spouse_income_from_work <> 0 )
           )     THEN
                 -- assume value ;
                 p_isir_rec.a_s_num_in_family := 2 ;
        END IF ;

        -- Edit 2038
        IF (    p_isir_rec.dependency_status = 'I'
            AND NVL( p_isir_rec.a_student_marital_status, p_isir_rec.s_marital_status ) in ('1','3')
            AND NVL (p_isir_rec.a_s_num_in_family , p_isir_rec.s_num_family_members ) > 1
            AND NVL( p_isir_rec.a_have_children , p_isir_rec.s_have_children ) = '2'
            AND NVL( p_isir_rec.a_s_have_dependents , p_isir_rec.legal_dependents ) = '2'
           )    THEN
                -- assume value ;
                p_isir_rec.a_s_num_in_family := 1 ;
        END IF ; -- Edit 2038

     END a_stud_num_in_family;


     PROCEDURE  a_stud_num_in_college AS
     /***************************************************************
       Created By		:	masehgal
       Date Created By	:	03-Feb-2003
       Purpose		:	To make assumption for Student's Number in College
       Known Limitations,Enhancements or Remarks
       Change History	:
       Who			When		What
     ***************************************************************/
     --              p_isir_rec.dependency_status       (1)
     --              p_isir_rec.s_num_in_college        (2)
     --              p_isir_rec.a_s_num_in_family       (3)
     --              p_isir_rec.s_num_family_members    (4)
     --              p_isir_rec.system_record_type      (5)
     --              p_isir_rec.a_s_num_in_college

     BEGIN
        -- Edit 2039
        IF (     p_isir_rec.dependency_status = 'I'
            AND (p_isir_rec.s_num_in_college IS NULL   OR   p_isir_rec.s_num_in_college = 0 )
           )     THEN
                 -- assume value ;
                 p_isir_rec.a_s_num_in_college := 1;
        END IF ;

        -- Edit 2040
        IF p_isir_rec.assum_override_3 = '1'  THEN
           NULL ;
        ELSE
            -- skip assumption if override SET
/*  DO NOT DELETE the code commented here
    It is likely to be pulled in in a forthcoming CCR

              IF     p_isir_rec.system_record_type <> 'CORRECTION'
                 AND p_isir_rec.dependency_status = 'I'
*/
           IF (    p_isir_rec.dependency_status = 'I'
               AND NVL ( p_isir_rec.a_s_num_in_college , p_isir_rec.s_num_in_college ) > 2
               AND NVL ( p_isir_rec.a_s_num_in_college , p_isir_rec.s_num_in_college ) = NVL( p_isir_rec.a_s_num_in_family , p_isir_rec.s_num_family_members )
              )    THEN
                   -- assume value ;
                   -- skip other edits on this field
                   p_isir_rec.a_s_num_in_college := 1;
           END IF ;
        END IF ; -- override condition

        -- Edit 2042
        IF (    p_isir_rec.dependency_status = 'I'
            AND NVL ( p_isir_rec.a_s_num_in_college , p_isir_rec.s_num_in_college ) > NVL( p_isir_rec.a_s_num_in_family , p_isir_rec.s_num_family_members )
            )    THEN
                 -- assume value ;
                 -- skip othjer edits on this field
                 p_isir_rec.a_s_num_in_college := 1 ;
        END IF ; -- Edit 2042

/*  DO NOT DELETE the code commented here
    It is likely to be pulled in in a forthcoming CCR

              -- Edit 2041
              IF     p_isir_rec.system_record_type <> 'CORRECTION'
                 --  Select the Correction Record for the same student and in that record
                 AND corr_rec.s_num_in_college > 2
                 AND NVL( corr_rec.a_s_num_in_family , corr_rec.s_num_family_members ) > 2
                 AND corr_rec.s_num_in_college = NVL( corr_rec.a_s_num_in_family , corr_rec.s_num_family_members ) THEN
                     -- assume value ;
                     -- skip othjer edits on this field
                     corr_rec.a_s_num_in_college := NULL ;
              ELSE
                 -- Edit 2043
                 IF     p_isir_rec.dependency_status = 'I'
                    AND p_isir_rec.s_num_in_college > NVL( p_isir_rec.a_s_num_in_family , p_isir_rec.s_num_family_members )  THEN
                        -- assume value ;
                        p_isir_rec.a_s_num_in_college := 1 ;
                 END IF ; -- Edit 2043
              END IF ; -- Edit 2041
*/

     END a_stud_num_in_college;



     PROCEDURE  a_stud_marital_status_resume AS
     /***************************************************************
       Created By		:	masehgal
       Date Created By	:	03-Feb-2003
       Purpose		:	To make assumption for Student's Number in Family
       Known Limitations,Enhancements or Remarks
       Change History	:
       Who			When		What
     ***************************************************************/
     --              p_isir_rec.dependency_status          (1)
     --              p_isir_rec.a_student_marital_status   (2)
     --              p_isir_rec.s_marital_status           (3)
     --              p_isir_rec.s_num_family_members       (4)
     --              p_isir_rec.a_have_children            (5)
     --              p_isir_rec.s_have_children            (6)
     --              p_isir_rec.a_s_have_dependents        (7)
     --              p_isir_rec.legal_dependents           (8)
     --              p_isir_rec.spouse_income_from_work    (9)
     --              p_isir_rec.a_s_num_in_family

        -- Edit 2043
     BEGIN
        IF (    p_isir_rec.dependency_status = 'D'
            AND NVL( p_isir_rec.a_student_marital_status, p_isir_rec.s_marital_status ) IS NULL
           )    THEN
                -- assume value
                p_isir_rec.a_student_marital_status := '1' ;
        END IF ; -- Edit 2043
     END a_stud_marital_status_resume ;


     PROCEDURE  a_spouse_work_income AS
     /***************************************************************
       Created By		:	masehgal
       Date Created By	:	03-Feb-2003
       Purpose		:	To make assumption for Spouse's Income from work
       Known Limitations,Enhancements or Remarks
       Change History	:
       Who			When		What
     ***************************************************************/
     --              p_isir_rec.dependency_status          (1)
     --              p_isir_rec.a_student_marital_status   (2)
     --              p_isir_rec.s_marital_status           (3)
     --              p_isir_rec.spouse_income_from_work    (4)
     --              p_isir_rec.a_spouse_income_work

     BEGIN
         -- Edit 2044
         IF (     p_isir_rec.dependency_status = 'D'
             AND  NVL( p_isir_rec.a_student_marital_status, p_isir_rec.s_marital_status ) = '1'
             AND (p_isir_rec.spouse_income_from_work IS NOT NULL  AND  p_isir_rec.spouse_income_from_work <> 0 )
            )     THEN
                  -- assume value ;
                  p_isir_rec.a_spouse_income_work := 0 ;
         END IF ; -- Edit 2044
     END a_spouse_work_income;


     PROCEDURE  a_stud_agi AS
     /***************************************************************
       Created By		:	masehgal
       Date Created By	:	03-Feb-2003
       Purpose		:	To make assumption for Student's AGI
       Known Limitations,Enhancements or Remarks
       Change History	:
       Who			When		What
     ***************************************************************/
     --              p_isir_rec.s_adjusted_gross_income    (1)
     --              p_isir_rec.s_type_tax_return          (2)
     --              p_isir_rec.s_tax_return_status        (3)
     --              p_isir_rec.s_income_from_work         (4)
     --              p_isir_rec.spouse_income_from_work    (5)
     --              p_isir_rec.system_record_type         (6)
     --              p_isir_rec.a_student_agi

     BEGIN
        -- Edit 2045
        IF p_isir_rec.assum_override_4  = '1' THEN
           NULL ;
        ELSE
           -- skip assumption if override set
/*  DO NOT DELETE the code commented here
    It is likely to be pulled in in a forthcoming CCR

           IF    p_isir_rec.system_record_type <> 'CORRECTION'
             AND (p_isir_rec.s_adjusted_gross_income IS NULL  OR     p_isir_rec.s_adjusted_gross_income = 0 )
*/
           IF (    (p_isir_rec.s_adjusted_gross_income IS NULL  OR     p_isir_rec.s_adjusted_gross_income = 0 )
               AND (p_isir_rec.s_type_tax_return IS NOT NULL    OR    (       p_isir_rec.s_type_tax_return IS NULL
                                                                        AND   p_isir_rec.s_tax_return_status IN ('1','2')))
               AND (   (p_isir_rec.s_income_from_work IS NOT NULL       AND   p_isir_rec.s_income_from_work <> 0 )
                    OR (    NVL(p_isir_rec.a_spouse_income_work, p_isir_rec.spouse_income_from_work ) IS NOT NULL
                        AND NVL(p_isir_rec.a_spouse_income_work, p_isir_rec.spouse_income_from_work ) <> 0 ))
              )     THEN
                    -- assume value ;
                    -- skip other edits on this field
                    IF NVL(p_isir_rec.s_income_from_work,0) + NVL(NVL(p_isir_rec.a_spouse_income_work, p_isir_rec.spouse_income_from_work ),0) > 999999 THEN
                       p_isir_rec.a_student_agi := 999999 ;
                    ELSIF NVL(p_isir_rec.s_income_from_work,0) + NVL(NVL(p_isir_rec.a_spouse_income_work, p_isir_rec.spouse_income_from_work ),0) < -999999 THEN
                       p_isir_rec.a_student_agi := -999999 ;
                    ELSE
                       p_isir_rec.a_student_agi := NVL(p_isir_rec.s_income_from_work,0) + NVL(NVL(p_isir_rec.a_spouse_income_work, p_isir_rec.spouse_income_from_work ),0) ;
                    END IF ;
           END IF ; -- Edit 2045
        END IF ; -- Override Condition


/*  DO NOT DELETE the code commented here
    It is likely to be pulled in in a forthcoming CCR

           -- Edit 2046
           IF     p_isir_rec.system_record_type <> 'CORRECTION'
              --  Select the Correction Record for the same student and in that record  if    (1)   =  0
              AND corr_rec.s_adjusted_gross_income = 0  THEN
                  -- assume vaue
                  p_isir_rec.a_student_agi := NULL ;
           END IF ; -- Edit 2046
*/

     END a_stud_agi;


     PROCEDURE  a_stud_work_income AS
     /***************************************************************
       Created By		:	masehgal
       Date Created By	:	03-Feb-2003
       Purpose		:	To make assumption for Student's Income from Work
       Known Limitations,Enhancements or Remarks
       Change History	:
       Who			When		What
     ***************************************************************/
     --              p_isir_rec.a_student_agi              (1)
     --              p_isir_rec.s_adjusted_gross_income    (2)
     --              p_isir_rec.s_tax_return_status        (3)
     --              p_isir_rec.s_income_from_work         (4)
     --              p_isir_rec.spouse_income_from_work    (5)
     --              p_isir_rec.a_s_income_work

     BEGIN
        -- Edit 2047
        IF (     NVL( p_isir_rec.a_student_agi , p_isir_rec.s_adjusted_gross_income ) > 0
            AND  p_isir_rec.s_tax_return_status = '3'
            AND (p_isir_rec.s_income_from_work IS NULL   OR   p_isir_rec.s_income_from_work = 0 )
            AND (    NVL(p_isir_rec.a_spouse_income_work, p_isir_rec.spouse_income_from_work ) IS NULL
                 OR  NVL(p_isir_rec.a_spouse_income_work, p_isir_rec.spouse_income_from_work )= 0 )
           )     THEN
                 -- assume value ;
                 p_isir_rec.a_s_income_work := NVL( p_isir_rec.a_student_agi , p_isir_rec.s_adjusted_gross_income ) ;
        END IF ; -- Edit 2047

     END a_stud_work_income;


     PROCEDURE  a_stud_tax_status AS
     /***************************************************************
       Created By		:	masehgal
       Date Created By	:	03-Feb-2003
       Purpose		:	To make assumption for Student's Tax Status
       Known Limitations,Enhancements or Remarks
       Change History	:
       Who			When		      What
       ridas    04-Apr-06     Added new logic for Edits 2050 and 2052 for Award Year 06-07
                              FA160 build

     ***************************************************************/
     --              p_isir_rec.s_type_tax_return       (1)
     --              p_isir_rec.s_tax_return_status     (2)
     --              p_isir_rec.a_student_agi           (3)
     --              p_isir_rec.s_adjusted_gross_income (4)
     --              p_isir_rec.s_cal_tax_status

     BEGIN
        -- Edit 2048
        IF p_isir_rec.s_type_tax_return IS NOT NULL THEN
            -- assume value ;
            p_isir_rec.s_cal_tax_status := '1' ;
        END IF ;

        -- Edit 2049
        IF (    p_isir_rec.s_type_tax_return IS NULL
            AND NVL ( p_isir_rec.s_cal_tax_status , p_isir_rec.s_tax_return_status ) IN ('1','2')
           )    THEN
                -- assume value ;
                p_isir_rec.s_cal_tax_status := '1' ;
        END IF ;

        -- Edit 2050
        IF p_isir_rec.batch_year = '7' THEN
           IF (p_isir_rec.s_type_tax_return IS NULL AND NVL ( p_isir_rec.s_cal_tax_status , p_isir_rec.s_tax_return_status ) IS NULL
              AND (NVL( p_isir_rec.a_student_agi , p_isir_rec.s_adjusted_gross_income ) > 0
                   OR NVL( p_isir_rec.a_student_agi , p_isir_rec.s_adjusted_gross_income ) < 0 )
             ) THEN
                 -- assume value ;
                 p_isir_rec.s_cal_tax_status := '1' ;
           END IF;
        ELSE
           IF (    p_isir_rec.s_type_tax_return IS NULL
                AND NVL ( p_isir_rec.s_cal_tax_status , p_isir_rec.s_tax_return_status ) IS NULL
                AND (   NVL( p_isir_rec.a_student_agi , p_isir_rec.s_adjusted_gross_income ) = 0
                     OR NVL( p_isir_rec.a_student_agi , p_isir_rec.s_adjusted_gross_income ) > 0
                     OR NVL( p_isir_rec.a_student_agi , p_isir_rec.s_adjusted_gross_income ) < 0 )
                    )   THEN
                        -- assume value ;
                 p_isir_rec.s_cal_tax_status := '1' ;
           END IF ;
        END IF; -- Edit 2050


        -- Edit 2051
        IF (    p_isir_rec.s_type_tax_return IS NULL
            AND NVL ( p_isir_rec.s_cal_tax_status , p_isir_rec.s_tax_return_status ) = '3'
           )    THEN
                -- assume value ;
                p_isir_rec.s_cal_tax_status := '4' ;
        END IF ;

        -- Edit 2052
        IF p_isir_rec.batch_year = '7' THEN
           IF (p_isir_rec.s_type_tax_return IS NULL
               AND NVL ( p_isir_rec.s_cal_tax_status , p_isir_rec.s_tax_return_status ) IS NULL
               AND (NVL( p_isir_rec.a_student_agi , p_isir_rec.s_adjusted_gross_income ) IS NULL
                    OR NVL( p_isir_rec.a_student_agi , p_isir_rec.s_adjusted_gross_income) = 0)
              )    THEN
                 -- assume value ;
                 p_isir_rec.s_cal_tax_status := '4' ;
           END IF ;
        ELSE
           IF (    p_isir_rec.s_type_tax_return IS NULL
              AND NVL ( p_isir_rec.s_cal_tax_status , p_isir_rec.s_tax_return_status ) IS NULL
              AND NVL( p_isir_rec.a_student_agi , p_isir_rec.s_adjusted_gross_income ) IS NULL
             )    THEN
                  -- assume value ;
                 p_isir_rec.s_cal_tax_status := '4' ;
           END IF ;
        END IF ; -- Edit 2052

     END a_stud_tax_status;


     PROCEDURE  a_stud_us_tax_paid AS
     /***************************************************************
       Created By		:	masehgal
       Date Created By	:	03-Feb-2003
       Purpose		:	To make assumption for Student's Tax Payment Status
       Known Limitations,Enhancements or Remarks
       Change History	:
       Who			When		What
     ***************************************************************/
     --              p_isir_rec.s_fed_taxes_paid     (1)
     --              p_isir_rec.s_cal_tax_status     (2)
     --              p_isir_rec.a_s_us_tax_paid

     BEGIN
        -- Edit 2053
        IF (    p_isir_rec.s_fed_taxes_paid IS NULL
            AND NVL ( p_isir_rec.s_cal_tax_status , p_isir_rec.s_tax_return_status ) IN ('1','2','3')
           )    THEN
                -- assume value ;
                p_isir_rec.a_s_us_tax_paid := 0 ;
        END IF ; -- Edit 2053
     END a_stud_us_tax_paid;


     PROCEDURE  a_stud_work_income_resume AS
     /***************************************************************
       Created By		:	masehgal
       Date Created By	:	03-Feb-2003
       Purpose		:	To make assumption for Student's Income from Work
       Known Limitations,Enhancements or Remarks
       Change History	:
       Who			When		What
     ***************************************************************/
     --              p_isir_rec.dependency_status          (1)
     --              p_isir_rec.a_student_agi              (2)
     --              p_isir_rec.s_adjusted_gross_income    (3)
     --              p_isir_rec.s_income_from_work         (4)
     --              p_isir_rec.spouse_income_from_work    (5)
     --              p_isir_rec.s_cal_tax_status           (6)
     --              p_isir_rec.a_s_income_work

     BEGIN
        -- Edit 2054
        IF (     p_isir_rec.dependency_status = 'D'
            AND  NVL( p_isir_rec.a_student_agi , p_isir_rec.s_adjusted_gross_income ) IS NOT NULL
            AND  NVL( p_isir_rec.a_student_agi , p_isir_rec.s_adjusted_gross_income ) <> 0
            AND  p_isir_rec.s_income_from_work IS NULL
           )     THEN
                 -- assume value ;
                 p_isir_rec.a_s_income_work := NVL( p_isir_rec.a_student_agi , p_isir_rec.s_adjusted_gross_income );
        END IF ;

        -- Edit 2055
        IF (     p_isir_rec.dependency_status = 'I'
            AND  NVL( p_isir_rec.a_student_agi , p_isir_rec.s_adjusted_gross_income ) IS NOT NULL
            AND  NVL( p_isir_rec.a_student_agi , p_isir_rec.s_adjusted_gross_income ) <> 0
            AND  NVL ( p_isir_rec.a_s_income_work , p_isir_rec.s_income_from_work ) IS NULL
            AND (    NVL(p_isir_rec.a_spouse_income_work, p_isir_rec.spouse_income_from_work ) IS NULL
                 OR  NVL(p_isir_rec.a_spouse_income_work, p_isir_rec.spouse_income_from_work )= 0 )
                )    THEN
                     -- assume value ;
                     p_isir_rec.a_s_income_work := NVL( p_isir_rec.a_student_agi , p_isir_rec.s_adjusted_gross_income );
        END IF ;

        -- Edit 2056
        IF (    NVL ( p_isir_rec.a_s_income_work , p_isir_rec.s_income_from_work ) < 0
            AND NVL ( p_isir_rec.s_cal_tax_status , p_isir_rec.s_tax_return_status ) in ('4','5')
           )    THEN
                -- assume value ;
                p_isir_rec.a_s_income_work := 0 - p_isir_rec.s_income_from_work ;
        END IF ; -- Edit 2056

     END a_stud_work_income_resume ;


     PROCEDURE  a_spouse_work_income_resume AS
     /***************************************************************
       Created By		:	masehgal
       Date Created By	:	03-Feb-2003
       Purpose		:	To make assumption for Student's Income from Work
       Known Limitations,Enhancements or Remarks
       Change History	:
       Who			When		What
     ***************************************************************/
     --              p_isir_rec.dependency_status          (1)
     --              p_isir_rec.a_student_agi              (2)
     --              p_isir_rec.s_adjusted_gross_income    (3)
     --              p_isir_rec.a_s_income_work            (4)
     --              p_isir_rec.s_income_from_work         (5)
     --              p_isir_rec.spouse_income_from_work    (6)
     --              p_isir_rec.s_cal_tax_status           (7)
     --              p_isir_rec.a_student_marital_status   (8)
     --              p_isir_rec.s_marital_status           (9)
     --              p_isir_rec.a_spouse_income_work

     BEGIN

        -- Edit 2057
        IF (     p_isir_rec.dependency_status = 'I'
            AND (    NVL( p_isir_rec.a_student_agi , p_isir_rec.s_adjusted_gross_income ) IS NOT NULL
                 AND NVL( p_isir_rec.a_student_agi , p_isir_rec.s_adjusted_gross_income ) <> 0 )
            AND  NVL( p_isir_rec.a_s_income_work , p_isir_rec.s_income_from_work ) = 0
            AND  p_isir_rec.spouse_income_from_work IS NULL
            AND  NVL( p_isir_rec.a_student_marital_status, p_isir_rec.s_marital_status ) = '2'
           )     THEN
                 -- assume value ;
                 p_isir_rec.a_spouse_income_work := NVL( p_isir_rec.a_student_agi , p_isir_rec.s_adjusted_gross_income ) ;

        END IF ;

        -- Edit 2058
        IF (    p_isir_rec.dependency_status = 'I'
            AND NVL ( p_isir_rec.a_spouse_income_work , p_isir_rec.spouse_income_from_work ) < 0
            AND NVL ( p_isir_rec.s_cal_tax_status , p_isir_rec.s_tax_return_status ) in ('4','5')
           )    THEN
                -- assume value ;
                p_isir_rec.a_spouse_income_work := 0 - NVL ( p_isir_rec.a_spouse_income_work , p_isir_rec.spouse_income_from_work )  ;

        END IF ; -- Edit 2058

     END a_spouse_work_income_resume;


     PROCEDURE  a_stud_total_wsc AS
     /***************************************************************
       Created By		:	masehgal
       Date Created By	:	03-Feb-2003
       Purpose		:	To make assumption for Student's Total Income from Worksheet C
       Known Limitations,Enhancements or Remarks
       Change History	:
       Who			When		What
     ***************************************************************/
     --              p_isir_rec.s_toa_amt_from_wsc         (1)
     --              p_isir_rec.dependency_status          (2)
     --              p_isir_rec.a_student_agi              (3)
     --              p_isir_rec.s_adjusted_gross_income    (4)
     --              p_isir_rec.s_toa_amt_from_wsa         (5)
     --              p_isir_rec.s_toa_amt_from_wsb         (6)
     --              p_isir_rec.s_cal_tax_status           (7)
     --              p_isir_rec.a_s_income_work            (8)
     --              p_isir_rec.s_income_from_work         (9)
     --              p_isir_rec.a_spouse_income_work       (10)
     --              p_isir_rec.spouse_income_from_work    (11)
     --              p_isir_rec.system_record_type         (12)
     --              p_isir_rec.a_s_total_wsc

     BEGIN
        -- Edit 2059, 2061
        IF p_isir_rec.assum_override_6 = '1' THEN
           NULL ;
        ELSE
           -- skip edit if override SET
/*  DO NOT DELETE the code commented here
    It is likely to be pulled in in a forthcoming CCR

           IF     p_isir_rec.system_record_type <> 'CORRECTION'
              AND (   (    p_isir_rec.dependency_status IN ('I','D')
*/
           IF (    (   (    p_isir_rec.dependency_status IN ('I','D')
                        AND p_isir_rec.s_toa_amt_from_wsc > 0
                        AND p_isir_rec.s_toa_amt_from_wsc >= (GREATEST (NVL (NVL ( p_isir_rec.a_student_agi , p_isir_rec.s_adjusted_gross_income ) , 0 ), 0 )  +
                                                              GREATEST      (NVL ( p_isir_rec.s_toa_amt_from_wsa , 0   ) , 0 )                               +
                                                              GREATEST      (NVL ( p_isir_rec.s_toa_amt_from_wsb , 0   ) , 0 )                                )
                        AND NVL ( p_isir_rec.s_cal_tax_status , p_isir_rec.s_tax_return_status ) IN ('1','2','3')    )
                    OR (    p_isir_rec.dependency_status IN ('I','D')
                        AND p_isir_rec.s_toa_amt_from_wsc > 0
                        AND p_isir_rec.s_toa_amt_from_wsc >= (GREATEST (NVL (NVL ( p_isir_rec.a_s_income_work      , p_isir_rec.s_income_from_work     ) , 0 ), 0 )  +
                                                              GREATEST (NVL (NVL ( p_isir_rec.a_spouse_income_work , p_isir_rec.spouse_income_from_work) , 0 ), 0 )  +
                                                              GREATEST      (NVL ( p_isir_rec.s_toa_amt_from_wsa , 0   ) , 0 )                                     +
                                                              GREATEST      (NVL ( p_isir_rec.s_toa_amt_from_wsb , 0   ) , 0 )                                      )
                        AND NVL ( p_isir_rec.s_cal_tax_status , p_isir_rec.s_tax_return_status ) IN ('4','5')        )  )
              )     THEN
                    -- assume value ;
                    -- skip remainig edits on this field
                    p_isir_rec.a_s_total_wsc := 0 ;
           END IF ; -- Edit 2059, 2061

/*  DO NOT DELETE the code commented here
    It is likely to be pulled in in a forthcoming CCR

           -- Edit 2060, 2062
           -- select values from the correction record and check...
           IF     p_isir_rec.system_record_type <> 'CORRECTION'
              AND (   (    corr_rec.dependency_status IN ('I','D')
                       AND corr_rec.s_toa_amt_from_wsc > 0
                       AND corr_rec.s_toa_amt_from_wsc >= (GREATEST (NVL (NVL ( corr_rec.a_student_agi , corr_rec.s_adjusted_gross_income ) , 0 ), 0 )  +
                                                           GREATEST      (NVL ( corr_rec.s_toa_amt_from_wsa , 0   ) , 0 )                               +
                                                           GREATEST      (NVL ( corr_rec.s_toa_amt_from_wsb , 0   ) , 0, l_s_wsb )                       )
                       AND corr_rec.s_cal_tax_status IN ( '1',  '2' , '3' )                                  )
                   OR (    corr_rec.dependency_status IN ('I','D')
                       AND corr_rec.s_toa_amt_from_wsc > 0
                       AND corr_rec.s_toa_amt_from_wsc >= (GREATEST (NVL (NVL ( corr_rec.a_s_income_work      , corr_rec.s_income_from_work     ) , 0 ), 0 )  +
                                                           GREATEST (NVL (NVL ( corr_rec.a_spouse_income_work , corr_rec.spouse_income_from_work) , 0 ), 0 )  +
                                                           GREATEST      (NVL ( corr_rec.s_toa_amt_from_wsa , 0   ) , 0 )                               +
                                                           GREATEST      (NVL ( corr_rec.s_toa_amt_from_wsb , 0   ) , 0, l_s_wsb )                       )
                       AND corr_rec.s_cal_tax_status IN ( '4',  '5')                                               )  )   THEN
                           -- assume value ;
                           -- skip remainig edits on this field
                           p_isir_rec.a_s_total_wsc := NULL ;
           END IF ; -- Edit 2060, 2062
*/
        END IF ; -- Override Condition
     END a_stud_total_wsc;


BEGIN -- main assumptions

/*  DO NOT DELETE the code commented here
    It is likely to be pulled in in a forthcoming CCR

   -- open correction cursor and fetch correction values
   OPEN  get_corr_record ( p_isir_rec.base_id ) ;
   FETCH get_corr_record INTO corr_rec ;
   CLOSE get_corr_record ;
*/

   -- Calls to the local procedures sequentially ;
   -- Model Determination related Edits
   a_date_prior_birth ;
   a_stud_married ;
   a_stud_have_children ;
   a_stud_legal_depend ;
   a_stud_veteran_status ;
   assum_depend_status ;

 -- Calculate parent releated assumed values for students only if he is a dependenty
   IF p_isir_rec.dependency_status = 'D' THEN
      a_p_marital_status ;
      a_p_num_in_fam ;
      a_p_num_in_col ;
      a_p_agi ;
      a_f_work_income ;
      a_p_tax_status ;
      a_p_us_tax_paid ;
      a_f_work_income_resume ;
      a_m_work_income ;
      a_p_total_wsc ;
   END IF;

   a_stud_citizenship ;
   a_stud_marital_status ;
   a_stud_num_in_family ;
   a_stud_num_in_college ;
   a_stud_marital_status_resume ;
   a_spouse_work_income ;
   a_stud_agi ;
   a_stud_work_income ;
   a_stud_tax_status ;
   a_stud_us_tax_paid ;
   a_stud_work_income_resume ;
   a_spouse_work_income_resume ;
   a_stud_total_wsc ;

EXCEPTION
  WHEN OTHERS THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
       FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_ASSUMPTION_REJECT_EDITS.ASSUME_VALUES' );
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
END assume_values ;


PROCEDURE reject_edits ( p_isir_rec      IN  OUT NOCOPY   igf_ap_isir_matched%ROWTYPE ,
	                      p_sys_batch_yr  IN               VARCHAR2 ,
                         p_reject_codes      OUT NOCOPY   VARCHAR2 )   AS
/***************************************************************
Created By		:	masehgal
Date Created By	:	03-Feb-2003
Purpose		:	To display reject reasons for Student
Known Limitations,Enhancements or Remarks
Change History	:
Who			When		What
***************************************************************/

   PROCEDURE reject_edit_4001   AS
   /***************************************************************
   Created By		:	masehgal
   Date Created By	:	03-Feb-2003
   Purpose		:	To display reject reasons for Student
   Known Limitations,Enhancements or Remarks
   Change History	:
   Who			When		What
   ***************************************************************/
   -- Application Model                      p_isir_rec.dependency_status       (1)
   -- Parents' Adjusted Gross Income         p_isir_rec.p_adjusted_gross_income (2)
   -- Fathers' Income From Work              p_isir_rec.f_income_work           (3)
   -- Mothers' Income From Work              p_isir_rec.m_income_work           (4)
   -- Parents Total Amount from Worksheet    p_isir_rec.p_income_wsa            (5)
   -- Parents Total  Amountfrom Worksheet    p_isir_rec.p_income_wsb            (6)

   BEGIN
      IF (    p_isir_rec.dependency_status = 'D'   AND   p_isir_rec.p_adjusted_gross_income IS NULL
          AND p_isir_rec.f_income_work IS NULL     AND   p_isir_rec.m_income_work IS NULL
          AND p_isir_rec.p_income_wsa IS NULL      AND   p_isir_rec.p_income_wsb IS NULL
         )    THEN
              -- append reject code ;     stack  reject message ;
              p_reject_codes := p_reject_codes || '02' ;
              FND_MESSAGE.SET_NAME('IGF','IGF_AP_REJECT_EDIT_4001');
              IGS_GE_MSG_STACK.ADD;
      END IF ;
   END reject_edit_4001 ;


   PROCEDURE reject_edit_4002   AS
   /***************************************************************
   Created By		:	masehgal
   Date Created By	:	03-Feb-2003
   Purpose		:	To display reject reasons for Student
   Known Limitations,Enhancements or Remarks
   Change History	:
   Who			When		What
   ***************************************************************/
   -- Application Model                   p_isir_rec.dependency_status          (1)
   -- Student's Adjusted Gross Income     p_isir_rec.s_adjusted_gross_income    (2)
   -- Student's Income From Work          p_isir_rec.s_income_from_work         (3)
   -- Spouse's Income From Work           p_isir_rec.spouse_income_from_work    (4)
   -- Student Total Amountfrom WorksheetA p_isir_rec.s_toa_amt_from_wsa         (5)
   -- Student Total Amountfrom WorksheetB p_isir_rec.s_toa_amt_from_wsb         (6)

   BEGIN
      IF (    p_isir_rec.dependency_status = 'I'       AND   p_isir_rec.s_adjusted_gross_income IS NULL
          AND p_isir_rec.s_income_from_work IS NULL    AND   p_isir_rec.spouse_income_from_work IS NULL
          AND p_isir_rec.s_toa_amt_from_wsa  IS NULL   AND   p_isir_rec.s_toa_amt_from_wsb IS NULL
         )    THEN
              -- append reject code ;   stack  reject message ;
              p_reject_codes := p_reject_codes || '02' ;
              FND_MESSAGE.SET_NAME('IGF','IGF_AP_REJECT_EDIT_4002');
              IGS_GE_MSG_STACK.ADD;
      END IF ;
   END reject_edit_4002 ;


   PROCEDURE reject_edit_4003   AS
   /***************************************************************
   Created By		:	masehgal
   Date Created By	:	03-Feb-2003
   Purpose		:	To display reject reasons for Student
   Known Limitations,Enhancements or Remarks
   Change History	:
   Who			When		What
   ***************************************************************/
   -- Application Model             p_isir_rec.dependency_status       (1)
   -- Simplified Need Test          p_isir_rec.simplified_need_test    (2)
   -- Automatic Zero EFC            p_isir_rec.auto_zero_efc           (3)
   -- Net Worth of Investments      p_isir_rec.auto_zero_efc   (4)
   -- Net Worth of Business/ Farm   p_isir_rec.p_busi_farm_networth    (5)
   -- Cash , Savings and Checks     p_isir_rec.p_cash_savings            (6)

   BEGIN
      IF (    p_isir_rec.dependency_status = 'D'           AND  NVL( p_isir_rec.simplified_need_test, 'N') <> 'Y'
          AND NVL( p_isir_rec.auto_zero_efc, 'N') <> 'Y'   AND  p_isir_rec.p_investment_networth IS NULL
          AND p_isir_rec.p_business_networth IS NULL       AND  p_isir_rec.p_cash_saving IS NULL
          AND  p_isir_rec.s_investment_networth IS NULL    AND  p_isir_rec.s_busi_farm_networth IS NULL
          AND  p_isir_rec.s_cash_savings IS NULL
         )    THEN
              -- append reject code ;  stack  reject message ;
              p_reject_codes := p_reject_codes || '01' ;
              FND_MESSAGE.SET_NAME('IGF','IGF_AP_REJECT_EDIT_4003');
              IGS_GE_MSG_STACK.ADD;
      END IF ;
   END reject_edit_4003 ;


   PROCEDURE reject_edit_4004   AS
   /***************************************************************
   Created By		:	masehgal
   Date Created By	:	03-Feb-2003
   Purpose		:	To display reject reasons for Student
   Known Limitations,Enhancements or Remarks
   Change History	:
   Who			When		What
   ***************************************************************/
   -- Application Model          p_isir_rec.dependency_status       (1)
   -- Simplified Need Test       p_isir_rec.simplified_need_test    (2)
   -- Automatic Zero EFC         p_isir_rec.auto_zero_efc           (3)
   -- Net Worth of Investments   p_isir_rec.s_investment_networth   (4)
   -- Net Worth of Business/Farm p_isir_rec.s_busi_farm_networth    (5)
   -- Cash , Savings and Checks  p_isir_rec.s_cash_savings          (6)

   BEGIN
      IF (    p_isir_rec.dependency_status = 'I'           AND  NVL( p_isir_rec.simplified_need_test, 'N') <> 'Y'
          AND NVL( p_isir_rec.auto_zero_efc, 'N') <> 'Y'   AND  p_isir_rec.s_investment_networth IS NULL
          AND p_isir_rec.s_busi_farm_networth IS NULL      AND  p_isir_rec.s_cash_savings IS NULL
         )    THEN
              -- append reject code ;stack  reject message ;
              p_reject_codes := p_reject_codes || '01' ;
              FND_MESSAGE.SET_NAME('IGF','IGF_AP_REJECT_EDIT_4004');
              IGS_GE_MSG_STACK.ADD;
      END IF ;
   END reject_edit_4004 ;


   PROCEDURE reject_edit_4005   AS
   /***************************************************************
   Created By		:	masehgal
   Date Created By	:	03-Feb-2003
   Purpose		:	To display reject reasons for Student
   Known Limitations,Enhancements or Remarks
   Change History	:
   Who			When		What
   ***************************************************************/
   -- Assumed Citizenship  p_isir_rec.a_citizenship        (1)
   -- Citizenship Status   p_isir_rec.citizenship_status   (2)

   BEGIN
      IF (   NVL ( p_isir_rec.a_citizenship , p_isir_rec.citizenship_status ) IS NULL
          OR NVL ( p_isir_rec.a_citizenship , p_isir_rec.citizenship_status ) = '3'
         )   THEN
             -- append reject code ;stack  reject message ;
             p_reject_codes := p_reject_codes || '17' ;
             FND_MESSAGE.SET_NAME('IGF','IGF_AP_REJECT_EDIT_4005');
             IGS_GE_MSG_STACK.ADD;
      END IF ;
   END reject_edit_4005 ;


   PROCEDURE reject_edit_4006   AS
   /***************************************************************
   Created By		:	masehgal
   Date Created By	:	03-Feb-2003
   Purpose		:	To display reject reasons for Student
   Known Limitations,Enhancements or Remarks
   Change History	:
   Who			When		What
   ***************************************************************/
   -- First Name           p_isir_rec.first_name           (1)
   -- Last Name            p_isir_rec.last_name            (2)
   -- System Record Type   p_isir_rec.system_record_type   (3)

   BEGIN
      IF (    p_isir_rec.first_name IS NULL
          AND p_isir_rec.last_name  IS NULL
         )    THEN
              -- append reject code ;stack  reject message ;
              p_reject_codes := p_reject_codes || '13' ;
              FND_MESSAGE.SET_NAME('IGF','IGF_AP_REJECT_EDIT_4006');
              IGS_GE_MSG_STACK.ADD;
      END IF ;
   END reject_edit_4006 ;


   PROCEDURE reject_edit_4007_4008   AS
   /***************************************************************
   Created By		:	masehgal
   Date Created By	:	03-Feb-2003
   Purpose		:	To display reject reasons for Student
   Known Limitations,Enhancements or Remarks
   Change History	:
   Who			When		What
   ***************************************************************/
   -- First Name           p_isir_rec.first_name           (1)
   -- Last Name            p_isir_rec.last_name            (2)
   -- System Record Type   p_isir_rec.system_record_type   (3)

   BEGIN
/*  DO NOT DELETE the code commented here
    It is likely to be pulled in in a forthcoming CCR

      IF       p_isir_rec.system_record_type <> 'CORRECTION'
         AND ( p_isir_rec.first_name IS NULL   OR   p_isir_rec.last_name IS NULL )  THEN

               --   Select the Correction Record for the same student and in that record
               IF NOT ( corr_rec.first_name IS NULL    OR    corr_rec.last_name IS NULL )  THEN
*/
      IF     ( p_isir_rec.first_name IS NULL   OR   p_isir_rec.last_name IS NULL )  THEN
                  -- append reject code ; stack  reject message ;
                  p_reject_codes := p_reject_codes || 'N ' ;
                  FND_MESSAGE.SET_NAME('IGF','IGF_AP_REJECT_EDIT_4007');
                  IGS_GE_MSG_STACK.ADD;
--             END IF ;
      END IF ;
   END reject_edit_4007_4008 ;


   PROCEDURE reject_edit_4015_4013   AS
   /***************************************************************
   Created By		:	masehgal
   Date Created By	:	03-Feb-2003
   Purpose		:	To display reject reasons for Student
   Known Limitations,Enhancements or Remarks
   Change History	:
   Who			When		What
   ***************************************************************/
   -- date of birth           p_isir_rec.date_of_birth        (1)
   -- ssn match flag          p_isir_rec.ssn_match_flag       (2)
   -- system record type      p_isir_rec.system_record_type   (3)


   BEGIN

      IF p_isir_rec.date_of_birth IS NULL THEN
         -- append reject code ;stack  reject message
         p_reject_codes := p_reject_codes || '05' ;
         FND_MESSAGE.SET_NAME('IGF','IGF_AP_REJECT_EDIT_4013');
         IGS_GE_MSG_STACK.ADD;
      END IF ;
   END reject_edit_4015_4013 ;


   PROCEDURE reject_edit_4016_4014_4015(p_sys_batch_yr IN VARCHAR2 )  AS
   /***************************************************************
   Created By		:	masehgal
   Date Created By	:	03-Feb-2003
   Purpose		:	To display reject reasons for Student
   Known Limitations,Enhancements or Remarks
   Change History	:
   Who			When		What
   nsidana   11/18/2003   FA129 EFC updates for 2004-2005.
   cdcruz    12/31/2003   Bug# 3330571 Corrected the date being displayed for Reject
                          Edit 4014.
   ridas     04/04/2006   Added new maximum date for Award Year 06-07
                          FA160
   ***************************************************************/
   -- date of birth           p_isir_rec.date_of_birth        (1)
   -- ssn match flag          p_isir_rec.ssn_match_flag       (2)
   -- system record type      p_isir_rec.system_record_type   (3)

   min_date   DATE := TO_DATE('1899/12/31','YYYY/MM/DD');
   max_date   DATE;

   BEGIN
      IF (p_sys_batch_yr='0304') THEN
           max_date   := TO_DATE('1929/01/01','YYYY/MM/DD');
      ELSIF p_sys_batch_yr = '0405' THEN
           max_date    := TO_DATE('1930/01/01','YYYY/MM/DD');
      ELSIF p_sys_batch_yr = '0506' THEN
           max_date    := TO_DATE('1931/01/01','YYYY/MM/DD');
      ELSIF p_sys_batch_yr = '0607' THEN
           max_date    := TO_DATE('1932/01/01','YYYY/MM/DD');
     ELSE
           max_date    := TO_DATE('1928/01/01','YYYY/MM/DD');
     END IF;

      IF (    min_date < p_isir_rec.date_of_birth
          AND p_isir_rec.date_of_birth < max_date
          AND NVL ( p_isir_rec.ssn_match_flag, '3' ) <>  '4'
         )    THEN
                 -- append reject code ;  stack  reject message ;
                 p_reject_codes := p_reject_codes || 'A ' ;
                 FND_MESSAGE.SET_NAME('IGF','IGF_AP_REJECT_EDIT_4014');
                 FND_MESSAGE.SET_TOKEN ('MAX_YR', TO_CHAR ((max_date - 1), 'YYYY'));
                 IGS_GE_MSG_STACK.ADD;
      END IF ;
   END reject_edit_4016_4014_4015 ;


   PROCEDURE reject_edit_4018_4016_4017(p_sys_batch_yr IN VARCHAR2 )  AS
   /***************************************************************
   Created By		:	masehgal
   Date Created By	:	03-Feb-2003
   Purpose		:	To display reject reasons for Student
   Known Limitations,Enhancements or Remarks
   Change History	:
   Who			When		What
   nsidana  11/18/2003  FA129 EFC updates for 2004-2005
   ridas    04/04/2006  Added new minimum date for Award Year 06-07
                        FA160
   ***************************************************************/
   -- Application Model             p_isir_rec.dependency_status    (1)
   -- Date of Birth                 p_isir_rec.date_of_birth        (2)
   -- Orphan or  Ward  Of Court     p_isir_rec.orphan_ward_of_court (3)
   -- SSN Match Flag                p_isir_rec.ssn_match_flag       (4)
   -- System  Record  Type          p_isir_rec.system_record_type   (5)

   min_date    DATE;

   BEGIN
       IF p_sys_batch_yr = '0304' THEN
          min_date     := TO_DATE('1987/09/01','YYYY/MM/DD');
       ELSIF p_sys_batch_yr = '0405' THEN
          min_date     := TO_DATE('1988/09/01','YYYY/MM/DD');
       ELSIF p_sys_batch_yr = '0506' THEN
          min_date     := TO_DATE('1989/09/01','YYYY/MM/DD');
       ELSIF p_sys_batch_yr = '0607' THEN
          min_date     := TO_DATE('1990/09/01','YYYY/MM/DD');
       ELSE
          min_date     := TO_DATE('1986/09/01','YYYY/MM/DD');
       END IF;

      IF (     p_isir_rec.dependency_status =  'I'
          AND ( min_date < p_isir_rec.date_of_birth   AND   p_isir_rec.date_of_birth < TRUNC( SYSDATE) )
          AND  NVL( p_isir_rec.orphan_ward_of_court,'2') <> '1'
          AND  NVL( p_isir_rec.ssn_match_flag,'3') <> '4'
         )     THEN
                --append reject code ;  stack  reject message ;
                p_reject_codes := p_reject_codes || 'B ' ;
                FND_MESSAGE.SET_NAME('IGF','IGF_AP_REJECT_EDIT_4016');
                IGS_GE_MSG_STACK.ADD;
      END IF ;

   END reject_edit_4018_4016_4017 ;


   PROCEDURE reject_edit_4020_4018   AS
   /***************************************************************
   Created By		:	masehgal
   Date Created By	:	03-Feb-2003
   Purpose		:	To display reject reasons for Student
   Known Limitations,Enhancements or Remarks
   Change History	:
   Who			When		What
   ***************************************************************/
   -- Application Model                         p_isir_rec.dependency_status          (1)
   -- Assumed Parents' US Tax Paid              p_isir_rec.a_p_us_tax_paid            (2)
   -- Parents' U.S. Income Tax Paid             p_isir_rec.p_taxes_paid               (3)
   -- Assumed Parents' Adjusted Gross Income    p_isir_rec.a_parents_agi              (4)
   -- Parents' Adjusted Gross Income            p_isir_rec.p_adjusted_gross_income    (5)

   BEGIN
      IF (     p_isir_rec.dependency_status = 'D'
          AND (    NVL ( p_isir_rec.a_p_us_tax_paid , p_isir_rec.p_taxes_paid ) IS NOT NULL
               AND NVL ( p_isir_rec.a_p_us_tax_paid , p_isir_rec.p_taxes_paid ) > 0         )
          AND  NVL ( p_isir_rec.a_p_us_tax_paid , p_isir_rec.p_taxes_paid ) >= NVL ( p_isir_rec.a_parents_agi , p_isir_rec.p_adjusted_gross_income )
         )     THEN
               -- append reject code ;stack  reject message ;
               p_reject_codes := p_reject_codes || '12' ;
               FND_MESSAGE.SET_NAME('IGF','IGF_AP_REJECT_EDIT_4018');
               IGS_GE_MSG_STACK.ADD;
      END IF ;
   END reject_edit_4020_4018 ;


   PROCEDURE reject_edit_4019   AS
   /***************************************************************
   Created By		:	masehgal
   Date Created By	:	03-Feb-2003
   Purpose		:	To display reject reasons for Student
   Known Limitations,Enhancements or Remarks
   Change History	:
   Who			When		What
   ***************************************************************/
   -- Application Model                   p_isir_rec.dependency_status          (1)
   -- Assumed Students' US Tax Paid       p_isir_rec.a_s_us_tax_paid            (2)
   -- Students' U.S. Income Tax Paid      p_isir_rec.s_fed_taxes_paid           (3)
   -- Assumed Student's Gross Income      p_isir_rec.a_student_agi              (4)
   -- Student's Adjusted Gross Income     p_isir_rec.s_adjusted_gross_income    (5)

   BEGIN
      IF (     p_isir_rec.dependency_status = 'I'
          AND (      NVL ( p_isir_rec.a_s_us_tax_paid , p_isir_rec.s_fed_taxes_paid ) IS NOT NULL
               AND   NVL ( p_isir_rec.a_s_us_tax_paid, p_isir_rec.s_fed_taxes_paid ) > 0           )
          AND  NVL ( p_isir_rec.a_s_us_tax_paid , p_isir_rec.s_fed_taxes_paid ) >=  NVL ( p_isir_rec.a_student_agi , p_isir_rec.s_adjusted_gross_income )
         )     THEN
               -- append reject code ;stack  reject message ;
               p_reject_codes := p_reject_codes || '12' ;
               FND_MESSAGE.SET_NAME('IGF','IGF_AP_REJECT_EDIT_4019');
               IGS_GE_MSG_STACK.ADD;
      END IF ;
   END reject_edit_4019 ;


   PROCEDURE reject_edit_4021   AS
   /***************************************************************
   Created By		:	svuppala
   Date Created By	:	16-Nov-2004
   Purpose		:	To display reject reasons for Student
   Known Limitations,Enhancements or Remarks
   Change History	:
   Who			When		What
   ***************************************************************/
   -- Application Model                   p_isir_rec.dependency_status          (1)
   -- Assumed Students' US Tax Paid       p_isir_rec.a_s_us_tax_paid            (2)
   -- Students' U.S. Income Tax Paid      p_isir_rec.s_fed_taxes_paid           (3)
   -- Assumed Student's Gross Income      p_isir_rec.a_student_agi              (4)
   -- Student's Adjusted Gross Income     p_isir_rec.s_adjusted_gross_income    (5)

   BEGIN
      IF (     p_isir_rec.dependency_status = 'I'
          AND (      NVL ( p_isir_rec.a_s_us_tax_paid , p_isir_rec.s_fed_taxes_paid ) IS NOT NULL
               AND   NVL ( p_isir_rec.a_s_us_tax_paid, p_isir_rec.s_fed_taxes_paid ) > 0           )
          AND  NVL ( p_isir_rec.a_s_us_tax_paid , p_isir_rec.s_fed_taxes_paid ) >=
               NVL ( p_isir_rec.a_student_agi , p_isir_rec.s_adjusted_gross_income )
         )     THEN
               -- append reject code ;stack  reject message ;
               p_reject_codes := p_reject_codes || '03' ;
               FND_MESSAGE.SET_NAME('IGF','IGF_AP_REJECT_EDIT_4021');
               IGS_GE_MSG_STACK.ADD;
      END IF ;
   END reject_edit_4021 ;


   PROCEDURE reject_edit_4045_4047   AS
   /***************************************************************
    Created By           :        ridas
    Date Created By      :        04-Apr-2006
    Purpose              :        To display reject reasons for Student
    Known Limitations,Enhancements or Remarks
    Change History       :
    Who                  When                What
    ***************************************************************/
    -- Dependency Status                   p_isir_rec.dependency_status          (1)
    -- Father's SSN Match Flag             p_isir_rec.father_ssn_match_type      (2)
    -- Mother's SSN Match Flag             p_isir_rec.mother_ssn_match_type      (3)
   BEGIN
     --edit 4045
     IF (       p_isir_rec.dependency_status = 'D'
           AND  p_isir_rec.father_ssn_match_type = '3'
           AND  p_isir_rec.mother_ssn_match_type <> '4')
      THEN

              p_reject_codes := p_reject_codes || 'E' ;
              FND_MESSAGE.SET_NAME('IGF','IGF_AP_REJECT_EDIT_4045');
              IGS_GE_MSG_STACK.ADD;
     END IF ;

     --edit 4047
     IF (       p_isir_rec.dependency_status = 'D'
           AND  p_isir_rec.mother_ssn_match_type = '3'
           AND  p_isir_rec.father_ssn_match_type <> '4')
      THEN

              p_reject_codes := p_reject_codes || 'F' ;
              FND_MESSAGE.SET_NAME('IGF','IGF_AP_REJECT_EDIT_4047');
              IGS_GE_MSG_STACK.ADD;
     END IF ;
   END reject_edit_4045_4047 ;



 PROCEDURE reject_edit_4049   AS
   /***************************************************************
   Created By		:	svuppala
   Date Created By	:	16-Nov-2004
   Purpose		:	To display reject reasons for Student
   Known Limitations,Enhancements or Remarks
   Change History	:
   Who			When		What
   ***************************************************************/
   -- Application Model                   p_isir_rec.dependency_status          (1)
   -- Assumed Students' US Tax Paid       p_isir_rec.a_s_us_tax_paid            (2)
   -- Students' U.S. Income Tax Paid      p_isir_rec.s_fed_taxes_paid           (3)
   -- Assumed Student's Gross Income      p_isir_rec.a_student_agi              (4)
   -- Student's Adjusted Gross Income     p_isir_rec.s_adjusted_gross_income    (5)

   BEGIN
      IF (       p_isir_rec.dependency_status = 'D'
            AND  p_isir_rec.FATHER_SSN = RPAD('0', LENGTH(p_isir_rec.FATHER_SSN),'0')
            AND  (p_isir_rec.MOTHER_SSN IS NULL OR p_isir_rec.MOTHER_SSN =
                                                        RPAD('0', LENGTH(p_isir_rec.MOTHER_SSN),'0'))
            AND  p_isir_rec.P_TAX_RETURN_STATUS IN ('1','2')
            AND  NVL ( p_isir_rec.P_TYPE_TAX_RETURN,'0') <> '3' )
       THEN

               p_reject_codes := p_reject_codes || 'J' ;
               FND_MESSAGE.SET_NAME('IGF','IGF_AP_REJECT_EDIT_4049');
               IGS_GE_MSG_STACK.ADD;
      END IF ;
   END reject_edit_4049 ;


   PROCEDURE reject_edit_4051   AS
   /***************************************************************
   Created By		:	svuppala
   Date Created By	:	16-Nov-2004
   Purpose		:	To display reject reasons for Student
   Known Limitations,Enhancements or Remarks
   Change History	:
   Who			When		What
   ***************************************************************/
   -- Application Model                   p_isir_rec.dependency_status          (1)
   -- Assumed Students' US Tax Paid       p_isir_rec.a_s_us_tax_paid            (2)
   -- Students' U.S. Income Tax Paid      p_isir_rec.s_fed_taxes_paid           (3)
   -- Assumed Student's Gross Income      p_isir_rec.a_student_agi              (4)
   -- Student's Adjusted Gross Income     p_isir_rec.s_adjusted_gross_income    (5)

   BEGIN
      IF (       p_isir_rec.dependency_status = 'D'
            AND  p_isir_rec.mother_SSN = RPAD('0', LENGTH(p_isir_rec.mother_SSN),'0')
            AND  (p_isir_rec.father_SSN IS NULL OR p_isir_rec.father_SSN =
                                                        RPAD('0', LENGTH(p_isir_rec.father_SSN),'0'))
            AND  p_isir_rec.P_TAX_RETURN_STATUS IN ('1','2')
            AND  NVL ( p_isir_rec.P_TYPE_TAX_RETURN,'0') <> '3' )
       THEN

               p_reject_codes := p_reject_codes || 'K' ;
               FND_MESSAGE.SET_NAME('IGF','IGF_AP_REJECT_EDIT_4051');
               IGS_GE_MSG_STACK.ADD;
      END IF ;
   END reject_edit_4051 ;

   PROCEDURE reject_edit_4022_4020_4021   AS
   /***************************************************************
   Created By		:	masehgal
   Date Created By	:	03-Feb-2003
   Purpose		:	To display reject reasons for Student
   Known Limitations,Enhancements or Remarks
   Change History	:
   Who			When		What
   ***************************************************************/
   -- Application Model                         p_isir_rec.dependency_status          (1)
   -- Assumed Parents' US Tax Paid              p_isir_rec.a_p_us_tax_paid            (2)
   -- Parents' U.S. Income Tax Paid             p_isir_rec.p_taxes_paid               (3)
   -- Assumed Parents' Adjusted Gross Income    p_isir_rec.a_parents_agi              (4)
   -- Parents' Adjusted Gross Income            p_isir_rec.p_adjusted_gross_income    (5)
   -- FAA Adjustment                            p_isir_rec.faa_adjustment             (6)
   -- System  Record  Type                      p_isir_rec.system_record_type         (7)

   BEGIN
/*  DO NOT DELETE the code commented here
    It is likely to be pulled in in a forthcoming CCR

      IF      p_isir_rec.system_record_type <> 'CORRECTION'
         AND  p_isir_rec.dependency_status = 'D'
*/
      IF (     p_isir_rec.dependency_status = 'D'
          AND (    NVL( p_isir_rec.a_p_us_tax_paid , p_isir_rec.p_taxes_paid ) IS NOT NULL
               AND NVL( p_isir_rec.a_p_us_tax_paid , p_isir_rec.p_taxes_paid ) > 0           )
          AND  NVL( p_isir_rec.a_p_us_tax_paid  , p_isir_rec.p_taxes_paid ) >= 0.4 * NVL( p_isir_rec.a_parents_agi, p_isir_rec.p_adjusted_gross_income )
          AND  NVL( p_isir_rec.a_p_us_tax_paid  , p_isir_rec.p_taxes_paid ) <  NVL( p_isir_rec.a_parents_agi , p_isir_rec.p_adjusted_gross_income )
          AND  NVL( p_isir_rec.faa_adjustment, '2' ) <> '1'
         )     THEN
/*  DO NOT DELETE the code commented here
    It is likely to be pulled in in a forthcoming CCR

              --   Select the Correction Record for the same student and in that record
              IF NOT ( NVL ( corr_rec.a_p_us_tax_paid  , corr_rec.p_taxes_paid  ) <> NVL ( p_isir_rec.a_p_us_tax_paid  , p_isir_rec.p_taxes_paid ) )  THEN
*/
                 -- append reject code ;  stack  reject message ;
                 p_reject_codes := p_reject_codes || 'C ' ;
                 FND_MESSAGE.SET_NAME('IGF','IGF_AP_REJECT_EDIT_4020');
                 IGS_GE_MSG_STACK.ADD;
--            END IF ;
      END IF ;
   END reject_edit_4022_4020_4021 ;


   PROCEDURE reject_edit_4024_4022_4023   AS
   /***************************************************************
   Created By		:	masehgal
   Date Created By	:	03-Feb-2003
   Purpose		:	To display reject reasons for Student
   Known Limitations,Enhancements or Remarks
   Change History	:
   Who			When		What
   ***************************************************************/
   -- Application Model                p_isir_rec.dependency_status       (1)
   -- Assumed Students' US Tax Paid    p_isir_rec.a_s_us_tax_paid         (2)
   -- Students'  U.S. Income Tax Paid  p_isir_rec.s_fed_taxes_paid        (3)
   -- Assumed Student's Gross Income   p_isir_rec.a_student_agi           (4)
   -- Student's Adjusted Gross Income  p_isir_rec.s_adjusted_gross_income (5)
   -- FAA Adjustment                   p_isir_rec.faa_adjustment          (6)
   -- System  Record  Type             p_isir_rec.system_record_type      (7)

   BEGIN
/*  DO NOT DELETE the code commented here
    It is likely to be pulled in in a forthcoming CCR

      IF      p_isir_rec.system_record_type <> 'CORRECTION'
         AND  p_isir_rec.dependency_status =  'I'
*/
      IF (     p_isir_rec.dependency_status =  'I'
          AND (     NVL( p_isir_rec.a_s_us_tax_paid , p_isir_rec.s_fed_taxes_paid ) IS NOT NULL
               AND  NVL( p_isir_rec.a_s_us_tax_paid , p_isir_rec.s_fed_taxes_paid ) > 0         )
          AND  NVL( p_isir_rec.a_s_us_tax_paid , p_isir_rec.s_fed_taxes_paid ) >= 0.4 * (NVL( p_isir_rec.a_student_agi , p_isir_rec.s_adjusted_gross_income ))
          AND  NVL( p_isir_rec.a_s_us_tax_paid , p_isir_rec.s_fed_taxes_paid ) <  NVL ( p_isir_rec.a_student_agi, p_isir_rec.s_adjusted_gross_income )
          AND  NVL( p_isir_rec.faa_adjustment,'2') <> '1'
         )     THEN
/*  DO NOT DELETE the code commented here
    It is likely to be pulled in in a forthcoming CCR

              --   Select the Correction Record for the same student and in that record
              IF  NOT ( NVL( corr_rec.a_s_us_tax_paid , corr_rec.s_fed_taxes_paid ) <> NVL ( p_isir_rec.a_s_us_tax_paid , p_isir_rec.s_fed_taxes_paid ) )  THEN
*/
                  -- append reject code ; stack  reject message ;
                  p_reject_codes := p_reject_codes || 'C ' ;
                  FND_MESSAGE.SET_NAME('IGF','IGF_AP_REJECT_EDIT_4022');
                  IGS_GE_MSG_STACK.ADD;
 --           END IF ;
      END IF ;
   END reject_edit_4024_4022_4023 ;


   PROCEDURE reject_edit_4028_4024   AS
   /***************************************************************
   Created By		:	masehgal
   Date Created By	:	03-Feb-2003
   Purpose		:	To display reject reasons for Student
   Known Limitations,Enhancements or Remarks
   Change History	:
   Who			When		What
   nsidana 11/18/2003   FA129 EFC updates for 2004-2005
                                        This is reject edit 4024 for the year 0304 and 4026 for year 0405
   ***************************************************************/
   -- Application Model                   p_isir_rec.dependency_status    (1)
   -- Assumed Parents' Marital Status     p_isir_rec.a_p_marital_status   (2)
   -- Parents' Marital Status             p_isir_rec.p_marital_status     (3)
   -- Assumed Parents' Number in Family   p_isir_rec.a_parents_num_family (4)
   -- Parent's' Number of Family Members  p_isir_rec.p_num_family_member  (5)

   BEGIN
      IF (     p_isir_rec.dependency_status = 'D'
          AND  p_isir_rec.p_marital_status  IS NULL
          AND (    NVL ( p_isir_rec.a_parents_num_family , p_isir_rec.p_num_family_member ) IS NULL
               OR  NVL ( p_isir_rec.a_parents_num_family , p_isir_rec.p_num_family_member ) = 0
               OR  NVL ( p_isir_rec.a_parents_num_family , p_isir_rec.p_num_family_member ) = 1     )
         )     THEN
               -- append reject code ;stack  reject message ;
               p_reject_codes := p_reject_codes || '10' ;
               FND_MESSAGE.SET_NAME('IGF','IGF_AP_REJECT_EDIT_4024');
               IGS_GE_MSG_STACK.ADD;
      END IF ;
   END reject_edit_4028_4024 ;


   PROCEDURE reject_edit_4029_4025   AS
   /***************************************************************
   Created By		:	masehgal
   Date Created By	:	03-Feb-2003
   Purpose		:	To display reject reasons for Student
   Known Limitations,Enhancements or Remarks
   Change History	:
   Who			When		What
    nsidana 11/18/2003   FA129 EFC updates for 2004-2005
                                      This is reject edit 4025 for the year 0304 and 4027 for year 0405
   ***************************************************************/
   -- Application Model                   p_isir_rec.dependency_status          (1)
   -- Assumed Students' Marital Status    p_isir_rec.a_student_marital_status   (2)
   -- Students' Marital Status            p_isir_rec.s_marital_status           (3)
   -- Assumed Students' Number in Family  p_isir_rec.a_s_num_in_family          (4)
   -- Students' Number of Family Members  p_isir_rec.s_num_family_members       (5)

   BEGIN
      IF (     p_isir_rec.dependency_status = 'I'
          AND  NVL( p_isir_rec.a_student_marital_status, p_isir_rec.s_marital_status ) IS NULL
          AND (   NVL ( p_isir_rec.a_s_num_in_family , p_isir_rec.s_num_family_members ) IS NULL
               OR NVL ( p_isir_rec.a_s_num_in_family , p_isir_rec.s_num_family_members ) = 0
               OR NVL ( p_isir_rec.a_s_num_in_family , p_isir_rec.s_num_family_members ) = 1     )
         )     THEN
               -- append reject code ;stack  reject message
               p_reject_codes := p_reject_codes || '10' ;
               FND_MESSAGE.SET_NAME('IGF','IGF_AP_REJECT_EDIT_4025');
               IGS_GE_MSG_STACK.ADD;
      END IF ;
   END reject_edit_4029_4025 ;

   PROCEDURE reject_edit_4026_4024_4025_new (p_sys_batch_yr IN VARCHAR2) AS
   /***************************************************************
   Created By		:	nsidana
   Date Created By	:11/18/2003
   Purpose		:	To display reject reasons for Student
   Known Limitations,Enhancements or Remarks
   Change History	:
   Who			When		What
   ***************************************************************/
    BEGIN

        IF p_sys_batch_yr  = '0304' then
            RETURN;
        END IF;

        IF (p_isir_rec.dependency_status = 'D'    AND
             (NVL(p_isir_rec.a_s_us_tax_paid , p_isir_rec.s_fed_taxes_paid ) IS NOT NULL) AND
             (NVL(p_isir_rec.a_s_us_tax_paid, p_isir_rec.s_fed_taxes_paid ) > 0)  AND
             (NVL ( p_isir_rec.a_s_us_tax_paid , p_isir_rec.s_fed_taxes_paid ) < NVL ( p_isir_rec.a_student_agi , p_isir_rec.s_adjusted_gross_income ))    AND
             (NVL (p_isir_rec.a_s_us_tax_paid, p_isir_rec.s_fed_taxes_paid) >= 0.4* NVL (p_isir_rec.a_student_agi, p_isir_rec.s_adjusted_gross_income))  AND
             (NVL(p_isir_rec.faa_adjustment, '2' ) <> '1'))
        THEN
             p_reject_codes := p_reject_codes || 'G' ;
             FND_MESSAGE.SET_NAME('IGF','IGF_AP_REJECT_EDIT_4024_25_NEW');
             IGS_GE_MSG_STACK.ADD;
        END IF ;
    END reject_edit_4026_4024_4025_new ;

   PROCEDURE reject_edit_4030_4026_4027   AS
   /***************************************************************
   Created By		:	masehgal
   Date Created By	:	03-Feb-2003
   Purpose		:	To display reject reasons for Student
   Known Limitations,Enhancements or Remarks
   Change History	:
   Who			When		What
    nsidana 11/18/2003   FA129 EFC updates for 2004-2005
                                        This is reject edit 4026_4027 for the year 0304 and 4028_4028
                                         for year 0405
   ***************************************************************/
   -- Application Model                   p_isir_rec.dependency_status       (1)
   -- Assumed Parents' Number in Family   p_isir_rec.a_parents_num_family    (2)
   -- Parents' Number of Family Members   p_isir_rec.p_num_family_member     (3)
   -- FAA Adjustment                      p_isir_rec.faa_adjustment          (4)
   -- System  Record  Type                p_isir_rec.system_record_type      (5)

   BEGIN
/*  DO NOT DELETE the code commented here
    It is likely to be pulled in in a forthcoming CCR

      IF     p_isir_rec.system_record_type <> 'CORRECTION'
         AND p_isir_rec.dependency_status =  'D'
*/
      IF (    p_isir_rec.dependency_status = 'D'
          AND NVL( p_isir_rec.a_parents_num_family , p_isir_rec.p_num_family_member ) >= 15
          AND NVL( p_isir_rec.faa_adjustment,'2') <> '1'
         )    THEN
/*  DO NOT DELETE the code commented here
    It is likely to be pulled in in a forthcoming CCR

             --   Select the Correction Record for the same student and in that record
             IF  NOT ( NVL ( corr_rec.a_parents_num_family , corr_rec.p_num_family_member ) <> NVL ( p_isir_rec.a_parents_num_family , p_isir_rec.p_num_family_member ) )  THEN
*/
                 -- append reject code ; stack  reject message ;
                 p_reject_codes := p_reject_codes || 'W ' ;
                 FND_MESSAGE.SET_NAME('IGF','IGF_AP_REJECT_EDIT_4026');
                 IGS_GE_MSG_STACK.ADD;
--           END IF ;
      END IF ;
   END reject_edit_4030_4026_4027 ;


   PROCEDURE reject_edit_4032_4028_4029   AS
   /***************************************************************
   Created By		:	masehgal
   Date Created By	:	03-Feb-2003
   Purpose		:	To display reject reasons for Student
   Known Limitations,Enhancements or Remarks
   Change History	:
   Who			When		What
    nsidana 11/18/2003   FA129 EFC updates for 2004-2005
                                      This is reject edit 4028_4029 for the year 0304 and 4030_31
                                      for year 0405
   ***************************************************************/
   -- Application Model                   p_isir_rec.dependency_status       (1)
   -- Assumed Students' Number in Family  p_isir_rec.a_s_num_in_family       (2)
   -- Students' Number of Family Members  p_isir_rec.s_num_family_members    (3)
   -- FAA Adjustment                      p_isir_rec.faa_adjustment          (4)
   -- System Record Type                  p_isir_rec.system_record_type      (5)

   BEGIN
/*  DO NOT DELETE the code commented here
    It is likely to be pulled in in a forthcoming CCR

      IF     p_isir_rec.system_record_type <> 'CORRECTION'
         AND p_isir_rec.dependency_status =  'I'
*/
      IF (    p_isir_rec.dependency_status =  'I'
          AND NVL ( p_isir_rec.a_s_num_in_family , p_isir_rec.s_num_family_members ) >= 15
          AND NVL ( p_isir_rec.faa_adjustment,'2') <> '1'
         )    THEN
/*  DO NOT DELETE the code commented here
    It is likely to be pulled in in a forthcoming CCR

             --   Select the Correction Record for the same student and in that record
             IF NOT ( NVL (corr_rec.a_s_num_in_family ,corr_rec.s_num_family_members ) <> NVL ( p_isir_rec.a_s_num_in_family , p_isir_rec.s_num_family_members ) )  THEN
*/
                -- append reject code ; stack  reject message ;
                 p_reject_codes := p_reject_codes || 'W ' ;
                FND_MESSAGE.SET_NAME('IGF','IGF_AP_REJECT_EDIT_4028');
                IGS_GE_MSG_STACK.ADD;
--           END IF ;
      END IF ;
   END reject_edit_4032_4028_4029 ;


   PROCEDURE reject_edit_4034_4030   AS
      /***************************************************************
   Created By		:	masehgal
   Date Created By	:	03-Feb-2003
   Purpose		:	To display reject reasons for Student
   Known Limitations,Enhancements or Remarks
   Change History	:
   Who			When		What
    nsidana 11/18/2003   FA129 EFC updates for 2004-2005
                                      This is reject edit 4030 for the year 0304 and 4032 for year 0405
   ***************************************************************/
   -- Application Model                         p_isir_rec.dependency_status       (1)
   -- Parents' Marital Status                   p_isir_rec.p_marital_status        (3)
   -- Assumed Fathers' Income Earned from Work  p_isir_rec.a_f_work_income         (4)
   -- Father's Income From Work                 p_isir_rec.f_income_work           (5)
   -- Assumed Mothers Income from  Work         p_isir_rec.a_m_work_income         (6)
   -- Mothers Income from Work                  p_isir_rec.m_income_work           (7)
   -- FAA Adjustment                            p_isir_rec.faa_adjustment          (8)

   BEGIN
      IF (     p_isir_rec.dependency_status = 'D'
--          AND  NVL( p_isir_rec.p_marital_status, '1' ) IN ('2','3','4')
          AND  p_isir_rec.p_marital_status IN ('2','3','4')
          AND (    NVL( p_isir_rec.a_f_work_income , p_isir_rec.f_income_work ) IS NOT NULL
               AND NVL( NVL ( p_isir_rec.a_f_work_income , p_isir_rec.f_income_work ), 1 ) <>  0 )
          AND (    NVL( p_isir_rec.a_m_work_income , p_isir_rec.m_income_work ) IS NOT NULL
               AND NVL( NVL ( p_isir_rec.a_m_work_income , p_isir_rec.m_income_work ), 1 ) <>  0 )
          AND  NVL( p_isir_rec.faa_adjustment,'2') <> '1'
         )     THEN
               -- append reject code ;stack  reject message
               p_reject_codes := p_reject_codes || '11' ;
               FND_MESSAGE.SET_NAME('IGF','IGF_AP_REJECT_EDIT_4030');
               IGS_GE_MSG_STACK.ADD;
      END IF ;
   END reject_edit_4034_4030 ;


   PROCEDURE reject_edit_4035_4031   AS
   /***************************************************************
   Created By		:	masehgal
   Date Created By	:	03-Feb-2003
   Purpose		:	To display reject reasons for Student
   Known Limitations,Enhancements or Remarks
   Change History	:
   Who			When		What
    nsidana 11/18/2003   FA129 EFC updates for 2004-2005
                                      This is reject edit 4031for the year 0304 and 4033 for year 0405
   ***************************************************************/
   -- Application Model                   p_isir_rec.dependency_status          (1)
   -- Assumed Students' Marital Status    p_isir_rec.a_student_marital_status   (2)
   -- Students' Marital Status            p_isir_rec.s_marital_status           (3)
   -- Assumed Spouse Income From Work     p_isir_rec.a_spouse_income_work       (4)
   -- Spouse Income From  Work            p_isir_rec.spouse_income_from_work    (5)
   -- FAA Adjustment                      p_isir_rec.faa_adjustment             (6)

   BEGIN
      IF (     p_isir_rec.dependency_status = 'I'
          AND  NVL( p_isir_rec.a_student_marital_status, p_isir_rec.s_marital_status ) IN ('1','3')
          AND (    NVL ( p_isir_rec.a_spouse_income_work , p_isir_rec.spouse_income_from_work ) IS NOT NULL
               AND NVL ( NVL ( p_isir_rec.a_spouse_income_work , p_isir_rec.spouse_income_from_work ), 1) <> 0 )
          AND  NVL ( p_isir_rec.faa_adjustment,'2') <> '1'
         )     THEN
               -- append reject code ;stack  reject message ;
               p_reject_codes := p_reject_codes || '11' ;
               FND_MESSAGE.SET_NAME('IGF','IGF_AP_REJECT_EDIT_4031');
               IGS_GE_MSG_STACK.ADD;
      END IF ;
   END reject_edit_4035_4031 ;


   PROCEDURE reject_edit_4036_4032   AS
   /***************************************************************
   Created By		:	masehgal
   Date Created By	:	03-Feb-2003
   Purpose		:	To display reject reasons for Student
   Known Limitations,Enhancements or Remarks
   Change History	:
   Who			When		What
    nsidana 11/18/2003   FA129 EFC updates for 2004-2005
                                      This is reject edit 4032 for the year 0304 and 4034 for year 0405
   ***************************************************************/
   -- Application Model    p_isir_rec.dependency_status    (1)
   -- Signed By            p_isir_rec.signed_by            (2)

   BEGIN
      IF (     p_isir_rec.dependency_status = 'D'
          AND (p_isir_rec.signed_by IS NULL   OR   p_isir_rec.signed_by = 'A' )
         )     THEN
               -- append reject code ;stack  reject message ;
               p_reject_codes := p_reject_codes || '15' ;
               FND_MESSAGE.SET_NAME('IGF','IGF_AP_REJECT_EDIT_4032');
               IGS_GE_MSG_STACK.ADD;
      END IF ;
   END reject_edit_4036_4032 ;


   PROCEDURE reject_edit_4037_4033   AS
   /***************************************************************
   Created By		:	masehgal
   Date Created By	:	03-Feb-2003
   Purpose		:	To display reject reasons for Student
   Known Limitations,Enhancements or Remarks
   Change History	:
   Who			When		What
    nsidana 11/18/2003   FA129 EFC updates for 2004-2005
                                      This is reject edit 4033 for the year 0304 and 4035 for year 0405
   ***************************************************************/
   -- Application Model    p_isir_rec.dependency_status    (1)
   -- Signed By            p_isir_rec.signed_by            (2)

   BEGIN
      IF (     p_isir_rec.dependency_status = 'I'
          AND (p_isir_rec.signed_by IS NULL   OR   p_isir_rec.signed_by = 'P' )
         )     THEN
               -- append reject code ;stack  reject message ;
               p_reject_codes := p_reject_codes || '14' ;
               FND_MESSAGE.SET_NAME('IGF','IGF_AP_REJECT_EDIT_4033');
               IGS_GE_MSG_STACK.ADD;
      END IF ;
   END reject_edit_4037_4033 ;


   PROCEDURE reject_edit_4038_4034(p_sys_batch_yr IN VARCHAR2) AS
   /***************************************************************
   Created By		:	masehgal
   Date Created By	:	03-Feb-2003
   Purpose		:	To display reject reasons for Student
   Known Limitations,Enhancements or Remarks
   Change History	:
   Who			When		What
   nsidana 11/18/2003 FA129 EFC updates for 2004-2005.
                                      This is reject edit 4034 for year 0304 and edit 4036 for year 0405.
   ***************************************************************/
   -- Application Model                p_isir_rec.dependency_status    (1)
   -- Father's / Step Father's SSN     p_isir_rec.father_ssn           (2)
   -- Mother's / Step Mother's SSN     p_isir_rec.mother_ssn           (3)

   BEGIN
      IF p_sys_batch_yr = '0304' THEN
            IF (p_isir_rec.dependency_status = 'D'  AND
                  p_isir_rec.father_ssn IS NULL  AND
                  p_isir_rec.mother_ssn IS NULL )
             THEN
                    -- append reject code ;stack  reject message ;
                    p_reject_codes := p_reject_codes || '09' ;
                    FND_MESSAGE.SET_NAME('IGF','IGF_AP_REJECT_EDIT_4034');
                    IGS_GE_MSG_STACK.ADD;
            END IF ;
      ELSIF p_sys_batch_yr = '0405' THEN
             IF (p_isir_rec.dependency_status = 'D'  AND
                  (p_isir_rec.father_ssn IS NULL  OR  p_isir_rec.f_last_name IS NULL OR p_isir_rec. FATHER_STEP_FATHER_BIRTH_DATE IS NULL)   AND
                  (p_isir_rec.mother_ssn IS NULL  OR p_isir_rec.m_last_name IS NULL  OR p_isir_rec. MOTHER_STEP_MOTHER_BIRTH_DATE IS NULL))
             THEN
                  p_reject_codes := p_reject_codes || '09' ;
                  FND_MESSAGE.SET_NAME('IGF','IGF_AP_REJECT_EDIT_4034_NEW');
                  IGS_GE_MSG_STACK.ADD;
              END IF ;
      END IF;
   END reject_edit_4038_4034 ;


BEGIN
/*
   -- open correction cursor and fetch correction values
   OPEN  get_corr_record ( p_isir_rec.base_id ) ;
   FETCH get_corr_record INTO corr_rec ;
   CLOSE get_corr_record ;
*/

   -- initialize reject_code holder
   p_reject_codes := NULL ;
   -- Call reject reasons sequentially
   reject_edit_4001 ;
   reject_edit_4002 ;
   reject_edit_4003 ;
   reject_edit_4004 ;
   reject_edit_4005 ;
   reject_edit_4006 ;
   IF NVL(p_isir_rec.reject_override_n,'2') <> '1' THEN
      reject_edit_4007_4008 ;
   END IF ;
   reject_edit_4015_4013 ;
   IF NVL(p_isir_rec.reject_override_a,'2') <> '1' THEN
     reject_edit_4016_4014_4015(p_sys_batch_yr) ;
   END IF ;
   IF NVL(p_isir_rec.reject_override_b,'2') <> '1' THEN
      reject_edit_4018_4016_4017(p_sys_batch_yr);
   END IF ;
   reject_edit_4020_4018 ;

   IF p_sys_batch_yr IN ('0304','0405') THEN
      reject_edit_4019;
   ELSE
    reject_edit_4021;
   END IF ;

   IF NVL(p_isir_rec.reject_override_c,'2') <> '1' THEN
      reject_edit_4022_4020_4021 ;
      reject_edit_4024_4022_4023 ;
   END IF ;

   --Bug #4937475
   IF NVL(p_isir_rec.reject_override_g_flag,'2') <> '1' THEN
      reject_edit_4026_4024_4025_new(p_sys_batch_yr) ;   -- nsidana 11/18/2003 : New reject edit added aspart of FA129 (EFC updates for 2004-2005).
   END IF;

   reject_edit_4028_4024 ;
   reject_edit_4029_4025 ;
   IF NVL(p_isir_rec.reject_override_w,'2') <> '1' THEN
      reject_edit_4030_4026_4027 ;
      reject_edit_4032_4028_4029 ;
   END IF ;
   reject_edit_4034_4030 ;
   reject_edit_4035_4031 ;
   reject_edit_4036_4032 ;
   reject_edit_4037_4033 ;
   reject_edit_4038_4034 (p_sys_batch_yr);

   IF p_sys_batch_yr NOT IN ('0304','0405') THEN
      reject_edit_4049;
   END IF;

   IF p_sys_batch_yr NOT IN ('0304','0405') THEN
      reject_edit_4051;
      reject_edit_4045_4047;
   END IF;


EXCEPTION
  WHEN OTHERS THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
       FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_ASSUMPTION_REJECT_EDITS.REJECT_EDITS' );
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;

END reject_edits ;


END igf_ap_assumption_reject_edits;

/
