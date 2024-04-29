--------------------------------------------------------
--  DDL for Package Body PER_ZA_WSP_LOOKUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ZA_WSP_LOOKUP" as
/* $Header: perzawsp.pkb 120.3.12010000.2 2008/08/06 09:36:57 ubhat ship $ */
  G_ATTRIBUTE_CATEGORY   Constant varchar2(100) := 'ZA_WSP_SKILLS_PRIORITIES';
  g_p_lpath_lookup_type  Constant varchar2(40)  := 'ZA_WSP_LEARNING_PATHS';
  g_p_course_lookup_type Constant varchar2(40)  := 'ZA_WSP_COURSES';
  g_p_cert_lookup_type   Constant varchar2(40)  := 'ZA_WSP_CERTIFICATIONS';
  g_t_lpath_lookup_type  Constant varchar2(40)  := 'ZA_ATR_LEARNING_PATHS';
  g_t_course_lookup_type Constant varchar2(40)  := 'ZA_ATR_COURSES';
  g_t_cert_lookup_type   Constant varchar2(40)  := 'ZA_ATR_CERTIFICATIONS';
  g_t_comp_lookup_type   Constant varchar2(40)  := 'ZA_ATR_COMPETENCIES';
  g_t_qual_lookup_type   Constant varchar2(40)  := 'ZA_ATR_QUALIFICATIONS';
  G_WSP_CAT_ATTRIBUTE_CATEGORY   Constant varchar2(100) := 'ZA_WSP_OCC_CAT';
  G_WSP_CAT_LOOKUP_TYPE  Constant varchar2(80) := 'ZA_WSP_OCCUPATIONAL_CATEGORIES';


  g_plan_year_start_date   date;
  g_plan_year_end_date     date;
  g_trnd_year_start_date   date;
  g_trnd_year_end_date     date;
  g_usr_tab_id             number;

 type t_unique_id is table of number index by varchar2(15);

 tab_usr_row_ids  t_unique_id;


/****************************************************************************
    Name        : set_wsp_cat_attr_cat
    Description : called from wsp_lookup_values
                  set the attribute category in lookup_values for lookup_types
                  ZA_WSP_OCCUPATIONAL_CATEGORIES wher it is missing
*****************************************************************************/
PROCEDURE set_wsp_cat_attr_cat is

Begin
   Update fnd_lookup_values
   Set    ATTRIBUTE_CATEGORY = G_WSP_CAT_ATTRIBUTE_CATEGORY
   Where  lookup_type = G_WSP_CAT_LOOKUP_TYPE
   And    ATTRIBUTE_CATEGORY IS null
   AND    security_group_id = fnd_global.lookup_security_group(lookup_type,3)
   AND    lookup_code NOT IN
          ( Select lookup_code
            FROM   hr_lookups
            Where  lookup_type = 'ZA_EMP_EQ_OCCUPATIONAL_CAT'
            );

END set_wsp_cat_attr_cat;


/****************************************************************************
    Name        : validate_lookup_meaning
    Description : called from LOOKUP_VAL_INSERT_ROW
                  LOOKUP_VAL_INSERT_ROW creats row in the fnd_lookup_values
                  If the meaning column is duplicate it prefix
                  year and duplicate no to meaning
*****************************************************************************/

  function validate_lookup_meaning
            (
               P_LOOKUP_TYPE in varchar2
            ,  P_MEANING     in varchar2
            ,  p_lookup_code in number
            ) return varchar2
         Is
  l_count number;
  l_meaning varchar2(100);
  begin
    hr_utility.set_location('inside validate_lookup_meaning',1);
    hr_utility.set_location('P_MEANING ' || P_MEANING,1);
     select count(*)
            into l_count
     from
            fnd_lookup_values
     Where  lookup_type = P_LOOKUP_TYPE
     and    MEANING     = P_MEANING
     and    lookup_code <> p_lookup_code
     AND    security_group_id = fnd_global.lookup_security_group(P_LOOKUP_TYPE,3);

    hr_utility.set_location('l_count ' || l_count,1);
    hr_utility.set_location('fnd_global.lookup_security_group(P_LOOKUP_TYPE,3) ' || fnd_global.lookup_security_group(P_LOOKUP_TYPE,3),1);

     if l_count = 0 then
          l_MEANING := P_Meaning;
     else
        l_count := nvl(to_number(substr(P_MEANING,5,instr(P_MEANING,':')-5)),0) +1;
        l_meaning := substr(p_meaning,1,4)||l_count||substr(P_MEANING,instr(P_MEANING,':'));
        l_meaning := substr(l_meaning,1,80);
        l_MEANING := validate_lookup_meaning
            (
               P_LOOKUP_TYPE => P_LOOKUP_TYPE
            ,  P_MEANING     => l_MEANING
            ,  p_lookup_code => p_lookup_code
            );

     end if;
     return l_meaning;

  end validate_lookup_meaning;


/****************************************************************************
    Name        : LOOKUP_VAL_INSERT_ROW
    Description : LOOKUP_VAL_INSERT_ROW creats row in the fnd_lookup_values
                  lookup_code will have the YEAR appneded with id
*****************************************************************************/

  procedure LOOKUP_VAL_INSERT_ROW
                     (  P_LOOKUP_TYPE       in  varchar2
                     , P_LOOKUP_CODE        in  varchar2
                     , P_ATTRIBUTE1         in  varchar2
                     , P_ATTRIBUTE2         in  varchar2
                     , P_ATTRIBUTE3         in  varchar2
                     , P_ATTRIBUTE4         in  varchar2
                     , P_ATTRIBUTE5         in  varchar2
                     , P_ATTRIBUTE6         in  varchar2
                     , P_ATTRIBUTE7         in  varchar2
                     , P_ATTRIBUTE8         in  varchar2
                     , P_ATTRIBUTE9         in  varchar2
                     , P_ATTRIBUTE10        in  varchar2
                     , P_ATTRIBUTE11        in  varchar2
                     , P_ATTRIBUTE12        in  varchar2
                     , P_ATTRIBUTE13        in  varchar2
                     , P_ATTRIBUTE14        in  varchar2
                     , P_ATTRIBUTE15        in  varchar2
                     , P_ENABLED_FLAG       in  varchar2
                     , P_MEANING            in  varchar2
                     , P_DESCRIPTION        in  varchar2
                     , P_START_DATE_ACTIVE  in  varchar2
                     , P_END_DATE_ACTIVE    in  varchar2
                       )
is
    l_row_id varchar2(100);
    l_count  number(3);
    l_meaning varchar2(100);
    len_desc  number(3);
    lenb_desc number(3);
    L_DESCRIPTION varchar2(300);
begin
  Select count(*)
      INTO l_count
  From
        FND_LOOKUP_values
  where
        lookup_type = P_LOOKUP_TYPE
  and   lookup_code = P_LOOKUP_CODE
  AND   security_group_id = fnd_global.lookup_security_group(P_LOOKUP_TYPE,3);

  hr_utility.set_location('inside LOOKUP_VAL_INSERT_ROW',1);
  hr_utility.set_location('P_LOOKUP_TYPE' || P_LOOKUP_TYPE,1);
  hr_utility.set_location('P_LOOKUP_CODE' || P_LOOKUP_CODE,1);

  hr_utility.set_location('P_START_DATE_ACTIVE' || P_START_DATE_ACTIVE,1);
  hr_utility.set_location('P_END_DATE_ACTIVE' || P_END_DATE_ACTIVE,1);


  if l_count = 0 then


   l_meaning := validate_lookup_meaning
           (
              P_LOOKUP_TYPE => P_LOOKUP_TYPE
           ,  P_MEANING     => P_MEANING
           ,  P_LOOKUP_CODE => P_LOOKUP_CODE
           );
  hr_utility.set_location('l_meaning' || l_meaning,1);

  hr_utility.set_location('calling FND_LOOKUP_VALUES_PKG.INSERT_ROW',1);
  hr_utility.set_location('fnd_global.lookup_security_group(P_LOOKUP_TYPE,3)'|| fnd_global.lookup_security_group(P_LOOKUP_TYPE,3),1);

/*Changes for Bug 6898734 */
  len_desc:=length(P_DESCRIPTION);
  SELECT vsize(P_DESCRIPTION) INTO lenb_desc FROM dual;

  hr_utility.set_location('len_desription:'|| len_desc,1);
  hr_utility.set_location('len_bytes_desription:'|| lenb_desc,1);

  L_DESCRIPTION := P_DESCRIPTION;
  hr_utility.set_location('Before Loop',1);

  WHILE lenb_desc > 240
  loop
      len_desc:=length(L_DESCRIPTION);
      L_DESCRIPTION:=substr(L_DESCRIPTION,1,len_desc-1);
      SELECT vsize(L_DESCRIPTION) INTO lenb_desc FROM dual;
  END loop;
  hr_utility.set_location('After loop',1);

/* End changes for Bug 6898734 */

      FND_LOOKUP_VALUES_PKG.INSERT_ROW(
        X_ROWID               => l_row_id,
        X_LOOKUP_TYPE         => P_LOOKUP_TYPE,
        X_SECURITY_GROUP_ID   => fnd_global.lookup_security_group(P_LOOKUP_TYPE,3),
        X_VIEW_APPLICATION_ID => 3,
        X_LOOKUP_CODE         => P_LOOKUP_CODE,
        X_TAG                 => null,
        X_ATTRIBUTE_CATEGORY  => G_ATTRIBUTE_CATEGORY,
        X_ATTRIBUTE1          => P_ATTRIBUTE1,
        X_ATTRIBUTE2          => P_ATTRIBUTE2,
        X_ATTRIBUTE3          => P_ATTRIBUTE3,
        X_ATTRIBUTE4          => P_ATTRIBUTE4,
        X_ATTRIBUTE5          => P_ATTRIBUTE5,
        X_ATTRIBUTE6          => P_ATTRIBUTE6,
        X_ATTRIBUTE7          => P_ATTRIBUTE7,
        X_ATTRIBUTE8          => P_ATTRIBUTE8,
        X_ATTRIBUTE9          => P_ATTRIBUTE9,
        X_ATTRIBUTE10         => P_ATTRIBUTE10,
        X_ATTRIBUTE11         => P_ATTRIBUTE11,
        X_ATTRIBUTE12         => P_ATTRIBUTE12,
        X_ATTRIBUTE13         => P_ATTRIBUTE13,
        X_ATTRIBUTE14         => P_ATTRIBUTE14,
        X_ATTRIBUTE15         => P_ATTRIBUTE15,
        X_ENABLED_FLAG        => P_ENABLED_FLAG,
        X_START_DATE_ACTIVE   => P_START_DATE_ACTIVE,
        X_END_DATE_ACTIVE     => P_END_DATE_ACTIVE,
        X_TERRITORY_CODE      => null,
        X_MEANING             => l_meaning,
        X_DESCRIPTION         => L_DESCRIPTION,
        X_CREATION_DATE       => trunc(sysdate),
        X_CREATED_BY          => 1,
        X_LAST_UPDATE_DATE    => trunc(sysdate),
        X_LAST_UPDATED_BY     => 1,
        X_LAST_UPDATE_LOGIN   => 0);
  end if;
end LOOKUP_VAL_INSERT_ROW;


/****************************************************************************
    Name        : create_lookup_values
    Description : If the parameter passed to the concurrent programe is create
                  this procedure will be called.
                  It deletes the existing lookup_values for the year and
                  create freshly.
*****************************************************************************/

  Procedure create_lookup_values
                      (errbuf           out nocopy varchar2,
                      retcode           out nocopy number,
                      --p_business_group_id in number,
                      p_year              in number,
                      p_plan_trng_ind     in varchar2,
                      p_del_mode          in varchar2)
             is
-- Query for OLM plan for next year
-- Query for the Courses
   Cursor csr_wsp_plan_courses
            (p_start_date in date
            , p_end_date  in date
            , p_year1     in number
            )
    is
        select OAV.ACTIVITY_VERSION_ID LOOKUP_CODE,
               substr(p_year1||':'||OAV_TL.VERSION_NAME ,1,80) MEANING,
               substr(OAV_TL.DESCRIPTION,1,240) DESCRIPTION,
               OAV_TL.LANGUAGE,
               OAV_TL.Source_Lang
        From  OTA_ACTIVITY_VERSIONS OAV
            , OTA_ACTIVITY_VERSIONS_TL OAV_TL
            , HR_ORGANIZATION_INFORMATION org_i
        Where OAV.BUSINESS_GROUP_ID = org_i.ORGANIZATION_ID
        and   org_i.ORG_INFORMATION_CONTEXT = 'Business Group Information'
        And   org_i.ORG_INFORMATION9 = 'ZA'
        and   OAV.START_DATE <= p_end_date
        and   ( OAV.END_DATE >= p_start_date
              OR
                OAV.END_DATE is null)
        and   OAV.activity_version_id = OAV_TL.activity_version_id
        and   OAV_TL.LANGUAGE = userenv('LANG');


-- Query for Learning paths.
    Cursor csr_wsp_plan_LP
            (p_start_date in date
            , p_end_date  in date
            , p_year1     in number
            )
     is
        Select OLP.LEARNING_PATH_ID LOOKUP_CODE,
               substr(p_year1||':'||OLP_TL.NAME,1,80)   MEANING,
               substr(OLP_TL.DESCRIPTION,1,240) DESCRIPTION,
               OLP_TL.LANGUAGE,
               OLP_TL.Source_Lang
        From   OTA_LEARNING_PATHS OLP
             , OTA_LEARNING_PATHS_TL OLP_TL
             , HR_ORGANIZATION_INFORMATION org_i
        Where OLP.business_group_id = org_i.ORGANIZATION_ID
        and   org_i.ORG_INFORMATION_CONTEXT = 'Business Group Information'
        And   org_i.ORG_INFORMATION9 = 'ZA'
        And   OLP.path_source_code = 'CATALOG' --Only for Bg level not at Mgr /Emp/Appriasal
        And   OLP.START_DATE_ACTIVE <= p_end_date
        And   ( OLP.END_DATE_ACTIVE >= p_start_date
              OR
                OLP.END_DATE_ACTIVE is null)
        And   OLP.LEARNING_PATH_ID = OLP_TL.LEARNING_PATH_ID
        And   OLP_TL.language = userenv('LANG') ;

-- Query for certifications
    Cursor csr_wsp_plan_crt
            (p_start_date in date
            , p_end_date  in date
            , p_year1     in number
            )
     is
        Select OC.CERTIFICATION_ID LOOKUP_CODE,
               substr(p_year1||':'||OC_TL.NAME,1,80)   MEANING,
               substr(OC_TL.DESCRIPTION,1,240) DESCRIPTION,
               OC_TL.LANGUAGE,
               OC_TL.Source_Lang
        From   OTA_CERTIFICATIONS_B OC
             , OTA_CERTIFICATIONS_TL OC_TL
             , HR_ORGANIZATION_INFORMATION org_i
        Where OC.business_group_id = org_i.ORGANIZATION_ID
        and   org_i.ORG_INFORMATION_CONTEXT = 'Business Group Information'
        And   org_i.ORG_INFORMATION9 = 'ZA'
        And   OC.START_DATE_ACTIVE <= p_end_date
        And   ( OC.END_DATE_ACTIVE >= p_start_date
              OR
                OC.END_DATE_ACTIVE is null)
        And   OC.CERTIFICATION_ID = OC_TL.CERTIFICATION_ID
        And   OC_TL.language = userenv('LANG') ;


-- Competencies
-- Start Date can not be null
    Cursor csr_wsp_comp
            (p_start_date in date
            , p_end_date  in date
            , p_year1     in number
            )
      is
        Select PC.COMPETENCE_ID LOOKUP_CODE,
               substr(p_year1||':'||PC_TL.NAME,1,80) MEANING,
               substr(PC_TL.NAME,decode(sign(length(PC_TL.NAME)-240),1,-240,1)) DESCRIPTION,
               PC_TL.LANGUAGE,
               PC_TL.Source_Lang,
               PC.business_group_id
    From   PER_COMPETENCES PC
         , PER_COMPETENCES_TL PC_TL
    Where PC.COMPETENCE_ID   = PC_TL.COMPETENCE_ID
    And   PC_TL.language     = userenv('LANG')
    and   PC.DATE_FROM      <= p_end_date
    and  ( PC.DATE_TO       >= p_start_date
         OR PC.DATE_TO is null)
    and  (nvl(PC.business_group_id,0) =0
         Or exists
            ( Select 1 from
              HR_ORGANIZATION_INFORMATION org_i
              Where PC.business_group_id = org_i.ORGANIZATION_ID
              And   org_i.ORG_INFORMATION_CONTEXT = 'Business Group Information'
              And   org_i.ORG_INFORMATION9 = 'ZA')
          )
     And exists
     (  Select 1 from
           Per_competence_elements pce
         , HR_ORGANIZATION_INFORMATION org_i
         , per_all_people_f pp
         , per_all_assignments_f paa
         Where pce.competence_id = pc.COMPETENCE_ID
         And   pce.type = 'PERSONAL'
         And   pce.person_id = pp.person_id
         And   pce.EFFECTIVE_DATE_FROM between pp.effective_start_date
                                       and     pp.effective_end_date
         And   paa.person_id = pp.person_id
         And   paa.assignment_type = 'E'
         And   paa.primary_flag = 'Y'
         And   pce.EFFECTIVE_DATE_FROM between paa.effective_start_date
                                                         and     paa.effective_end_date
         and   pce.EFFECTIVE_DATE_FROM between g_trnd_year_start_date
                                     And     g_trnd_year_end_date
         and   pce.business_group_id = org_i.ORGANIZATION_ID
         And   org_i.ORG_INFORMATION_CONTEXT = 'Business Group Information'
         And   org_i.ORG_INFORMATION9 = 'ZA'
      );


    --  Qualifications

    -- BUSINESS_GROUP_ID can be 0 for global QUalification and can be null.
    -- Start Date and End Date both can be null
    Cursor csr_wsp_qual
            (p_start_date in date
            , p_end_date  in date
            , p_year1     in number
            )
     is
        Select  pqt.qualification_type_id LOOKUP_CODE
              , substr(p_year1||':'||pqtl.NAME,1,80) MEANING
                  , pqtl.NAME DESCRIPTION
         from
           per_qualification_types pqt
        ,  per_qualification_types_tl pqtl
        Where pqt.qualification_type_id = pqtl.qualification_type_id
        and   pqtl.language = userenv('LANG')
        and   pqt.qualification_type_id in
        (   Select pq.qualification_type_id
           from
                per_qualifications pq
              , PER_ESTABLISHMENT_ATTENDANCES pea
              , per_all_people_f pp
              , per_all_assignments_f        paa
                    , HR_ORGANIZATION_INFORMATION org_i
           Where pqt.qualification_type_id = pq.qualification_type_id
           And   paa.person_id = pp.person_id
           and   paa.assignment_type = 'E'
           and   paa.primary_flag = 'Y'
           and   pq.AWARDED_DATE between paa.effective_start_date
                                 and     paa.effective_end_date
           And   pea.ATTENDANCE_ID (+) = pq.attendance_id
           and   pq.AWARDED_DATE between g_trnd_year_start_date
               And     g_trnd_year_end_date
           and   nvl(pea.person_id,pq.person_id) = pp.person_id
           and   pq.AWARDED_DATE between pp.effective_start_date
                                 and     pp.effective_end_date
           And   pp.business_group_id = org_i.ORGANIZATION_ID
           And   org_i.ORG_INFORMATION_CONTEXT = 'Business Group Information'
           And   org_i.ORG_INFORMATION9 = 'ZA'
         );

    ---- End for trained/Completed
    l_count number;

  Begin

    If p_plan_trng_ind = '10' OR p_plan_trng_ind = '20' then

      /* Deleting the existing lookup_values from plan type for this year*/
      If p_del_mode = 'Y' then
         Delete from fnd_lookup_values
         Where lookup_type in
               ( g_p_lpath_lookup_type
               , g_p_course_lookup_type
               , g_p_cert_lookup_type
               )
         AND   security_group_id = fnd_global.lookup_security_group(lookup_type,3)
         And   substr(lookup_code,1,4) = p_year;
       end if;

      /* Calling create looukp values for planed Learning paths */
      for lp_rec in csr_wsp_plan_LP
                   ( g_plan_year_start_date
                   , g_plan_year_end_date
                   , p_year
                   )
      loop
          Select count(*)
               into l_count
          From
                OTA_LP_ENROLLMENTS OLE
              , HR_ORGANIZATION_INFORMATION org_i
              , OTA_LP_MEMBER_ENROLLMENTS OLME
              , per_all_people_f pp
              , per_all_assignments_f        paa
          Where OLE.LEARNING_PATH_ID = lp_rec.LOOKUP_CODE
          And   OLME.LP_ENROLLMENT_ID = OLE.LP_ENROLLMENT_ID
          And   OLE.PATH_STATUS_CODE  <> 'CANCELLED'
          And   ( OLE.COMPLETION_DATE between g_plan_year_start_date
                                      And     g_plan_year_end_date
                OR
                OLE.COMPLETION_DATE IS null)
          AND   pp.person_id = OLE.PERSON_ID
          And   paa.person_id = pp.person_id
          and   paa.assignment_type = 'E'
          and   paa.primary_flag = 'Y'
          and   OLE.business_group_id = paa.BUSINESS_GROUP_ID
          And   org_i.ORG_INFORMATION_CONTEXT = 'Business Group Information'
          And   org_i.ORG_INFORMATION9 = 'ZA';

         if l_count > 0 then

            LOOKUP_VAL_INSERT_ROW
              (  P_LOOKUP_TYPE      => g_p_lpath_lookup_type
              , P_LOOKUP_CODE       => p_year||lp_rec.LOOKUP_CODE
              , P_ATTRIBUTE1        => null
              , P_ATTRIBUTE2        => null
              , P_ATTRIBUTE3        => null
              , P_ATTRIBUTE4        => null
              , P_ATTRIBUTE5        => null
              , P_ATTRIBUTE6        => null
              , P_ATTRIBUTE7        => null
              , P_ATTRIBUTE8        => null
              , P_ATTRIBUTE9        => null
              , P_ATTRIBUTE10       => null
              , P_ATTRIBUTE11       => null
              , P_ATTRIBUTE12       => null
              , P_ATTRIBUTE13       => null
              , P_ATTRIBUTE14       => null
              , P_ATTRIBUTE15       => null
              , P_ENABLED_FLAG      => 'Y'
              , P_MEANING           => lp_rec.MEANING
              , P_DESCRIPTION       => lp_rec.DESCRIPTION
              , P_START_DATE_ACTIVE => g_plan_year_start_date
              , P_END_DATE_ACTIVE   => g_plan_year_end_date
              );
         end if;

      end loop;
      /* Calling create looukp values for planed Courses */
      for course_rec in csr_wsp_plan_courses
                   ( g_plan_year_start_date
                   , g_plan_year_end_date
                   , p_year
                   )
      loop
         Select count(*)
                into l_count
         from
               OTA_EVENTS oe
            ,  OTA_DELEGATE_BOOKINGS odb
            ,  OTA_BOOKING_STATUS_TYPES obst
            ,  HR_ORGANIZATION_INFORMATION org_i
            ,  per_all_people_f pp
            , per_all_assignments_f        paa
             wHERE ACTIVITY_VERSION_ID = course_rec.LOOKUP_CODE
             aND   oe.EVENT_TYPE in ( 'SCHEDULED', 'SELFPACED')
             AND   OE.course_START_DATE <= g_plan_year_end_date
             AND   NVL(OE.course_end_DATE, g_plan_year_start_date) >= g_plan_year_start_date
             aND   ODB.EVENT_ID = oe.EVENT_ID
             And   ODB.INTERNAL_BOOKING_FLAG = 'Y'
             And   paa.person_id = pp.person_id
             and   paa.assignment_type = 'E'
             and   paa.primary_flag = 'Y'
             and   ODB.DATE_BOOKING_PLACED between paa.effective_start_date
                                           and     paa.effective_end_date
             And   pp.person_id    =  ODB.DELEGATE_PERSON_ID
             And   ODB.DATE_BOOKING_PLACED between pp.effective_start_date
                                           and     pp.effective_end_date
             And   paa.business_group_id = org_i.ORGANIZATION_ID
             And   org_i.ORG_INFORMATION_CONTEXT = 'Business Group Information'
             And   org_i.ORG_INFORMATION9 = 'ZA'
             aND  OBST.BOOKING_STATUS_TYPE_ID = odb.BOOKING_STATUS_TYPE_ID
             AND  obst.TYPE IN ('P','W','R','A'); -- 'C'' cANCELLED, 'P' Palced , 'W' Waitlisted, 'R' Requested, 'A' Attended


              if l_count > 0 then
                 LOOKUP_VAL_INSERT_ROW
                   (  P_LOOKUP_TYPE      => g_p_course_lookup_type
                   , P_LOOKUP_CODE       => p_year||course_rec.LOOKUP_CODE
                   , P_ATTRIBUTE1        => null
                   , P_ATTRIBUTE2        => null
                   , P_ATTRIBUTE3        => null
                   , P_ATTRIBUTE4        => null
                   , P_ATTRIBUTE5        => null
                   , P_ATTRIBUTE6        => null
                   , P_ATTRIBUTE7        => null
                   , P_ATTRIBUTE8        => null
                   , P_ATTRIBUTE9        => null
                   , P_ATTRIBUTE10       => null
                   , P_ATTRIBUTE11       => null
                   , P_ATTRIBUTE12       => null
                   , P_ATTRIBUTE13       => null
                   , P_ATTRIBUTE14       => null
                   , P_ATTRIBUTE15       => null
                   , P_ENABLED_FLAG      => 'Y'
                   , P_MEANING           => course_rec.MEANING
                   , P_DESCRIPTION       => course_rec.DESCRIPTION
                   , P_START_DATE_ACTIVE => g_plan_year_start_date
                   , P_END_DATE_ACTIVE   => g_plan_year_end_date
                   );
              end if;
      end loop;
      /* Calling create looukp values for planed Certifications */
      for cert_rec in csr_wsp_plan_crt
                   ( g_plan_year_start_date
                   , g_plan_year_end_date
                   , p_year
                   )
      loop
          Select count(*)
                       into l_count
                From
                       OTA_CERT_ENROLLMENTS OCE
                    ,  HR_ORGANIZATION_INFORMATION org_i
                    ,  per_all_people_f pp
                    , per_all_assignments_f        paa
                Where
                      OCE.CERTIFICATION_ID = cert_rec.LOOKUP_CODE
                And   OCE.PERSON_ID         = PP.person_id
                And   paa.person_id = pp.person_id
                and   paa.assignment_type = 'E'
                and   paa.primary_flag = 'Y'
                AND   org_i.ORGANIZATION_ID = paa.business_group_id
                And   OCE.CERTIFICATION_STATUS_CODE = 'ENROLLED'
                And  ( OCE.COMPLETION_DATE  Between g_plan_year_start_date
                                           And     g_plan_year_end_date
                     OR
                     OCE.COMPLETION_DATE IS null)
          And   org_i.ORG_INFORMATION_CONTEXT = 'Business Group Information'
          And   org_i.ORG_INFORMATION9 = 'ZA';

       if l_count > 0 then
          LOOKUP_VAL_INSERT_ROW
            (  P_LOOKUP_TYPE      => g_p_cert_lookup_type
            , P_LOOKUP_CODE       => p_year||cert_rec.LOOKUP_CODE
            , P_ATTRIBUTE1        => null
            , P_ATTRIBUTE2        => null
            , P_ATTRIBUTE3        => null
            , P_ATTRIBUTE4        => null
            , P_ATTRIBUTE5        => null
            , P_ATTRIBUTE6        => null
            , P_ATTRIBUTE7        => null
            , P_ATTRIBUTE8        => null
            , P_ATTRIBUTE9        => null
            , P_ATTRIBUTE10       => null
            , P_ATTRIBUTE11       => null
            , P_ATTRIBUTE12       => null
            , P_ATTRIBUTE13       => null
            , P_ATTRIBUTE14       => null
            , P_ATTRIBUTE15       => null
            , P_ENABLED_FLAG      => 'Y'
            , P_MEANING           => cert_rec.MEANING
            , P_DESCRIPTION       => cert_rec.DESCRIPTION
            , P_START_DATE_ACTIVE => g_plan_year_start_date
            , P_END_DATE_ACTIVE   => g_plan_year_end_date
            );
        end if;
      end loop;

    end if;

    If p_plan_trng_ind = '10' OR p_plan_trng_ind = '30' then
      If p_del_mode = 'Y' then
         Delete from fnd_lookup_values
         Where lookup_type in
               ( g_t_lpath_lookup_type
               , g_t_course_lookup_type
               , g_t_cert_lookup_type
               , g_t_comp_lookup_type
               , g_t_qual_lookup_type
               )
         AND   security_group_id = fnd_global.lookup_security_group(lookup_type,3)
         And   substr(lookup_code,1,4) = p_year - 1;
      end if;

      /* Calling create looukp values for trained Learning paths */
      for lp_rec in csr_wsp_plan_LP
                   ( g_trnd_year_start_date
                   , g_trnd_year_end_date
                   , p_year -1
                   )
      loop
         Select count(*)
               into l_count
          From
                OTA_LP_ENROLLMENTS OLE
              , HR_ORGANIZATION_INFORMATION org_i
              , OTA_LP_MEMBER_ENROLLMENTS OLME
          Where OLE.LEARNING_PATH_ID = lp_rec.LOOKUP_CODE
          And   OLE.PATH_STATUS_CODE  = 'COMPLETED'
          And   OLME.LP_ENROLLMENT_ID = OLE.LP_ENROLLMENT_ID
          And   OLE.COMPLETION_DATE between g_trnd_year_start_date
                                     And     g_trnd_year_end_date
          and   OLE.business_group_id = org_i.ORGANIZATION_ID
          And   org_i.ORG_INFORMATION_CONTEXT = 'Business Group Information'
          And   org_i.ORG_INFORMATION9 = 'ZA';

         if l_count > 0 then
             LOOKUP_VAL_INSERT_ROW
               (  P_LOOKUP_TYPE      => g_t_lpath_lookup_type
               , P_LOOKUP_CODE       => p_year -1||lp_rec.LOOKUP_CODE
               , P_ATTRIBUTE1        => null
               , P_ATTRIBUTE2        => null
               , P_ATTRIBUTE3        => null
               , P_ATTRIBUTE4        => null
               , P_ATTRIBUTE5        => null
               , P_ATTRIBUTE6        => null
               , P_ATTRIBUTE7        => null
               , P_ATTRIBUTE8        => null
               , P_ATTRIBUTE9        => null
               , P_ATTRIBUTE10       => null
               , P_ATTRIBUTE11       => null
               , P_ATTRIBUTE12       => null
               , P_ATTRIBUTE13       => null
               , P_ATTRIBUTE14       => null
               , P_ATTRIBUTE15       => null
               , P_ENABLED_FLAG      => 'Y'
               , P_MEANING           => lp_rec.MEANING
               , P_DESCRIPTION       => lp_rec.DESCRIPTION
               , P_START_DATE_ACTIVE => g_trnd_year_start_date
               , P_END_DATE_ACTIVE   => g_trnd_year_end_date
               );
          end if;
      end loop;
      /* Calling create looukp values for trained Courses */
      for course_rec in csr_wsp_plan_courses
                   ( g_trnd_year_start_date
                   , g_trnd_year_end_date
                   , p_year -1
                   )
      loop

            Select count(*)
                   into l_count
            from
                  OTA_EVENTS oe
               ,  OTA_DELEGATE_BOOKINGS odb
               ,  OTA_BOOKING_STATUS_TYPES obst
               ,  HR_ORGANIZATION_INFORMATION org_i
               ,  per_all_people_f pp
               ,  per_all_assignments_f        paa
            wHERE ACTIVITY_VERSION_ID = course_rec.LOOKUP_CODE
            aND   oe.EVENT_TYPE in ( 'SCHEDULED', 'SELFPACED')
            AND   OE.course_START_DATE <= g_trnd_year_end_date
            AND   NVL(OE.course_end_DATE, g_trnd_year_start_date) >= g_trnd_year_start_date
            aND   ODB.EVENT_ID = oe.EVENT_ID
            And   ODB.INTERNAL_BOOKING_FLAG = 'Y'
            And   paa.person_id = pp.person_id
            and   paa.assignment_type = 'E'
            and   paa.primary_flag = 'Y'
            AND   odb.DATE_STATUS_CHANGED BETWEEN g_trnd_year_start_date
                                            And  g_trnd_year_end_date
            and   odb.DATE_STATUS_CHANGED between paa.effective_start_date
                                              and     paa.effective_end_date
            And   pp.person_id = odb.DELEGATE_PERSON_ID
            And   odb.DATE_STATUS_CHANGED between pp.effective_start_date
                                          and     pp.effective_end_date
            And   odb.business_group_id = org_i.ORGANIZATION_ID
            And   org_i.ORG_INFORMATION_CONTEXT = 'Business Group Information'
            And   org_i.ORG_INFORMATION9 = 'ZA'
            aND  OBST.BOOKING_STATUS_TYPE_ID = odb.BOOKING_STATUS_TYPE_ID
            AND  obst.TYPE = 'A'; -- Attended

         if l_count > 0 then
             LOOKUP_VAL_INSERT_ROW
               (  P_LOOKUP_TYPE      => g_t_course_lookup_type
               , P_LOOKUP_CODE       => p_year -1||course_rec.LOOKUP_CODE
               , P_ATTRIBUTE1        => null
               , P_ATTRIBUTE2        => null
               , P_ATTRIBUTE3        => null
               , P_ATTRIBUTE4        => null
               , P_ATTRIBUTE5        => null
               , P_ATTRIBUTE6        => null
               , P_ATTRIBUTE7        => null
               , P_ATTRIBUTE8        => null
               , P_ATTRIBUTE9        => null
               , P_ATTRIBUTE10       => null
               , P_ATTRIBUTE11       => null
               , P_ATTRIBUTE12       => null
               , P_ATTRIBUTE13       => null
               , P_ATTRIBUTE14       => null
               , P_ATTRIBUTE15       => null
               , P_ENABLED_FLAG      => 'Y'
               , P_MEANING           => course_rec.MEANING
               , P_DESCRIPTION       => course_rec.DESCRIPTION
               , P_START_DATE_ACTIVE => g_trnd_year_start_date
               , P_END_DATE_ACTIVE   => g_trnd_year_end_date
               );
         end if;
      end loop;
      /* Calling create looukp values for Trained Certifications */
      for cert_rec in csr_wsp_plan_crt
                   ( g_trnd_year_start_date
                   , g_trnd_year_end_date
                   , p_year -1
                   )
      loop

         Select count(*)
                into l_count
         From
                OTA_CERT_ENROLLMENTS OCE
             ,  HR_ORGANIZATION_INFORMATION org_i
         Where
               OCE.CERTIFICATION_ID = cert_rec.LOOKUP_CODE
         And   OCE.BUSINESS_GROUP_ID = org_i.ORGANIZATION_ID
         And   OCE.CERTIFICATION_STATUS_CODE = 'CERTIFIED'
         And   OCE.COMPLETION_DATE  Between g_trnd_year_start_date
                                   And     g_trnd_year_end_date
         And   org_i.ORG_INFORMATION_CONTEXT = 'Business Group Information'
         And   org_i.ORG_INFORMATION9 = 'ZA';

        if l_count > 0 then
          LOOKUP_VAL_INSERT_ROW
            (  P_LOOKUP_TYPE      => g_t_cert_lookup_type
            , P_LOOKUP_CODE       => p_year -1||cert_rec.LOOKUP_CODE
            , P_ATTRIBUTE1        => null
            , P_ATTRIBUTE2        => null
            , P_ATTRIBUTE3        => null
            , P_ATTRIBUTE4        => null
            , P_ATTRIBUTE5        => null
            , P_ATTRIBUTE6        => null
            , P_ATTRIBUTE7        => null
            , P_ATTRIBUTE8        => null
            , P_ATTRIBUTE9        => null
            , P_ATTRIBUTE10       => null
            , P_ATTRIBUTE11       => null
            , P_ATTRIBUTE12       => null
            , P_ATTRIBUTE13       => null
            , P_ATTRIBUTE14       => null
            , P_ATTRIBUTE15       => null
            , P_ENABLED_FLAG      => 'Y'
            , P_MEANING           => cert_rec.MEANING
            , P_DESCRIPTION       => cert_rec.DESCRIPTION
            , P_START_DATE_ACTIVE => g_trnd_year_start_date
            , P_END_DATE_ACTIVE   => g_trnd_year_end_date
            );
        end if;
      end loop;

      for comp_rec in csr_wsp_comp
                   ( g_trnd_year_start_date
                   , g_trnd_year_end_date
                   , p_year -1
                   )
      loop
          LOOKUP_VAL_INSERT_ROW
            (  P_LOOKUP_TYPE      => g_t_comp_lookup_type
            , P_LOOKUP_CODE       => p_year -1||comp_rec.LOOKUP_CODE
            , P_ATTRIBUTE1        => null
            , P_ATTRIBUTE2        => null
            , P_ATTRIBUTE3        => null
            , P_ATTRIBUTE4        => null
            , P_ATTRIBUTE5        => null
            , P_ATTRIBUTE6        => null
            , P_ATTRIBUTE7        => null
            , P_ATTRIBUTE8        => null
            , P_ATTRIBUTE9        => null
            , P_ATTRIBUTE10       => null
            , P_ATTRIBUTE11       => null
            , P_ATTRIBUTE12       => null
            , P_ATTRIBUTE13       => null
            , P_ATTRIBUTE14       => null
            , P_ATTRIBUTE15       => null
            , P_ENABLED_FLAG      => 'Y'
            , P_MEANING           => comp_rec.MEANING
            , P_DESCRIPTION       => comp_rec.DESCRIPTION
            , P_START_DATE_ACTIVE => g_trnd_year_start_date
            , P_END_DATE_ACTIVE   => g_trnd_year_end_date
            );

      end loop;

      for qual_rec in csr_wsp_qual
                   ( g_trnd_year_start_date
                   , g_trnd_year_end_date
                   , p_year -1
                   )
      loop
          LOOKUP_VAL_INSERT_ROW
            (  P_LOOKUP_TYPE      => g_t_qual_lookup_type
            , P_LOOKUP_CODE       => p_year -1||qual_rec.LOOKUP_CODE
            , P_ATTRIBUTE1        => null
            , P_ATTRIBUTE2        => null
            , P_ATTRIBUTE3        => null
            , P_ATTRIBUTE4        => null
            , P_ATTRIBUTE5        => null
            , P_ATTRIBUTE6        => null
            , P_ATTRIBUTE7        => null
            , P_ATTRIBUTE8        => null
            , P_ATTRIBUTE9        => null
            , P_ATTRIBUTE10       => null
            , P_ATTRIBUTE11       => null
            , P_ATTRIBUTE12       => null
            , P_ATTRIBUTE13       => null
            , P_ATTRIBUTE14       => null
            , P_ATTRIBUTE15       => null
            , P_ENABLED_FLAG      => 'Y'
            , P_MEANING           => qual_rec.MEANING
            , P_DESCRIPTION       => qual_rec.DESCRIPTION
            , P_START_DATE_ACTIVE => g_trnd_year_start_date
            , P_END_DATE_ACTIVE   => g_trnd_year_end_date
            );

      end loop;

    end if;

  end create_lookup_values;

  Procedure refresh_lookup_values
                      (errbuf             out nocopy varchar2,
                      retcode             out nocopy number,
                      p_year              in         number,
                      p_plan_trng_ind     in         varchar2)
                      is
  Begin
    If p_plan_trng_ind = '10' OR p_plan_trng_ind = '20' then
       Update fnd_lookup_values
         Set ATTRIBUTE_CATEGORY = G_ATTRIBUTE_CATEGORY
       Where lookup_type in
             (
               g_p_lpath_lookup_type
             , g_p_course_lookup_type
             , g_p_cert_lookup_type
             )
       And   ATTRIBUTE_CATEGORY is null
       And  security_group_id = fnd_global.lookup_security_group(lookup_type,3);

    end if;

    If p_plan_trng_ind = '10' OR p_plan_trng_ind = '30' then
       Update fnd_lookup_values
         Set ATTRIBUTE_CATEGORY = G_ATTRIBUTE_CATEGORY
       Where lookup_type in
             (
               g_t_lpath_lookup_type
             , g_t_course_lookup_type
             , g_t_cert_lookup_type
             , g_t_comp_lookup_type
             , g_t_qual_lookup_type
             )
       And   security_group_id = fnd_global.lookup_security_group(lookup_type,3)
       And   ATTRIBUTE_CATEGORY is null;

    end if;

    create_lookup_values
                   (errbuf               => errbuf
                   , retcode             => retcode
                   , p_year              => p_year
                   , p_plan_trng_ind     => p_plan_trng_ind
                   , p_del_mode            => 'N' -- N do not delete the existing lookup values
                   );

  end refresh_lookup_values;

/****************************************************************************
    Name        : val_usr_row
    Description : Validate the passed user_row
                  if the user row does not fall in current period
                  will create the user and

*****************************************************************************/

  procedure val_usr_row
                     ( P_user_row_id in number
                     , p_year        in number
                     , p_from_year   in number
                     , errbuf        out nocopy varchar2
                     , retcode       out nocopy number
                     )
            is
  cursor csr_usr_row ( p_from_start_date date
                     , p_from_end_date   date
                     , p_start_date      date
                      )
         is
         select user_row_id,
                user_table_id,
                ROW_LOW_RANGE_OR_NAME,
                DISPLAY_SEQUENCE,
                business_group_id,
                legislation_code,
                row_high_range,
                effective_end_date
         from pay_user_rows_f usr
         where usr.user_row_id = P_user_row_id
         and  usr.effective_end_date =
              (
              Select max(usr1.effective_end_date)
                From pay_user_rows_f usr1
                Where usr1.user_row_id = P_user_row_id
                And   usr.effective_end_date >= p_from_start_date
                And   usr.effective_start_date <= p_from_end_date
              )
         and usr.effective_end_date < p_start_date;

   cursor csr_usr_val( p_from_start_date date
                     , p_from_end_date   date
                     , p_start_date      date
                     ) is
   select  USER_COLUMN_INSTANCE_ID
          ,EFFECTIVE_START_DATE
          ,EFFECTIVE_END_DATE
          ,USER_ROW_ID
          ,USER_COLUMN_ID
          ,BUSINESS_GROUP_ID
          ,LEGISLATION_CODE
          ,LEGISLATION_SUBGROUP
          ,VALUE
   from pay_user_column_instances_f puv
   Where puv.user_row_id = p_user_row_id
   and   puv.EFFECTIVE_END_DATE =
         (
         select max(puv1.EFFECTIVE_END_DATE)
           From  pay_user_column_instances_f puv1
           Where puv1.EFFECTIVE_END_DATE >= p_from_start_date
           and   puv1.EFFECTIVE_START_DATE <= p_from_end_date
         )
    and  puv.effective_end_date < p_start_date;

  l_disable_range_overlap_check BOOLEAN DEFAULT TRUE;
  l_count                       number;
  l_range_overlapped            BOOLEAN;
  l_row_high_range              number;
  l_user_row_id                 number;
  l_user_col_inst_id            number;
  l_obj_ver                     number;
  l_from_start_date             date;
  l_from_end_date               date;
  l_start_date                  date;
  l_end_date                    date;
  l_year                        number;
  l_from_year                   number;
  begin
  IF P_user_row_id IS NOT NULL then
  l_from_year := p_from_year - 1;
  l_year      := p_year -1;
      hr_utility.set_location('inside val_usr_row',1);
      hr_utility.set_location('P_user_row_id '|| P_user_row_id,1);
    l_from_start_date := to_date(to_char(g_plan_year_start_date,'DD-MM-')||l_from_year,'DD-MM-YYYY');
      hr_utility.set_location('l_from_start_date '|| l_from_start_date,1);
    l_from_end_date   := to_date(to_char(g_plan_year_end_date,'DD-MM-')||p_from_year,'DD-MM-YYYY');
      hr_utility.set_location('l_from_end_date '|| l_from_end_date,1);

    l_start_date := to_date(to_char(g_plan_year_start_date,'DD-MM-')||l_year,'DD-MM-YYYY');
      hr_utility.set_location('l_start_date '|| l_start_date,1);
    l_end_date   := to_date(to_char(g_plan_year_end_date,'DD-MM-')||p_year,'DD-MM-YYYY');
      hr_utility.set_location('l_end_date '|| l_end_date,1);
    if tab_usr_row_ids.exists(P_user_row_id) then
       hr_utility.set_location('tab_usr_row_ids.exists(P_user_row_id)',1);
    else
        for rec_usr_row in csr_usr_row
                         ( l_from_start_date
                         , l_from_end_date
                         , l_start_date
                         )
        loop
           Select count(*) into l_obj_ver
                  From pay_user_rows_f usr1
               Where usr1.user_row_id = P_user_row_id
               And   usr1.effective_end_date >= l_start_date
               And   usr1.effective_start_date <= l_end_date;
            IF l_obj_ver > 0 THEN
                              --fnd_message.set_name('PER','PER_34003_USER_ROW_OVERLAP');
                              --fnd_message.error;
               hr_utility.set_location('PER_34003_USER_ROW_OVERLAP ',1);
               errbuf := substr(fnd_message.get_string('PER','PER_34003_USER_ROW_OVERLAP'),1,255);
               retcode := P_user_row_id;
           --exit;
            else
                l_user_row_id := P_user_row_id;
                l_obj_ver     := 1;
                hr_utility.set_location('Calling pay_user_row_api.create_user_row ',1);
                pay_user_row_api.create_user_row(
                  p_validate                           => FALSE
                 ,p_effective_date               => l_start_date
                 ,p_user_table_id                => rec_usr_row.user_table_id
                 ,p_row_low_range_or_name        => rec_usr_row.ROW_LOW_RANGE_OR_NAME
                 ,p_display_sequence             => rec_usr_row.DISPLAY_SEQUENCE
                 ,p_business_group_id            => rec_usr_row.business_group_id
                 ,p_legislation_code             => rec_usr_row.legislation_code
                 ,p_disable_range_overlap_check  => l_disable_range_overlap_check
                 ,p_disable_units_check          => TRUE
                 ,p_row_high_range               => rec_usr_row.row_high_range
                 ,p_user_row_id                  => l_user_row_id
                 ,p_object_version_number        => l_obj_ver
                 ,p_effective_start_date               => l_start_date
                 ,p_effective_end_date                 => l_end_date);
            for rec_usr_val in csr_usr_val
                         ( l_from_start_date
                         , l_from_end_date
                         , l_start_date
                         )
            loop
             l_user_col_inst_id := rec_usr_val.user_column_instance_id;
             hr_utility.set_location('Calling pay_user_column_instance_api.create_user_column_instance ',1);
             pay_user_column_instance_api.create_user_column_instance
                   ( p_validate                => FALSE
                   , p_effective_date          => l_start_date
                   , p_user_row_id             => l_user_row_id
                   , p_user_column_id          => rec_usr_val.user_column_id
                   , p_value                   => rec_usr_val.value
                   , p_business_group_id       => rec_usr_val.business_group_id
                   , p_legislation_code        => rec_usr_val.legislation_code
                   , p_user_column_instance_id => l_user_col_inst_id
                   , p_object_version_number   => l_obj_ver
                   , p_effective_start_date    => l_start_date
                   , p_effective_end_date      => l_end_date);
            end loop;
                END IF;
        end loop;
        hr_utility.set_location('setting in pl/sql table P_user_row_id ' || P_user_row_id,1);
        tab_usr_row_ids(P_user_row_id) := P_user_row_id;
    end if;
  END if;
      hr_utility.set_location('Back from val_usr_row ',1);

  end val_usr_row;


/****************************************************************************
    Name        : copy_lookup_values
    Description : If the parameter passed to the concurrent programe is Copy
                  this procedure will be called.
                  It copies the lookup along with priorities from already
                  created lookups.
*****************************************************************************/


   Procedure copy_lookup_values
                     (errbuf            out nocopy varchar2,
                      retcode           out nocopy number,
                      --p_business_group_id in number,
                      p_year              in number,
                      P_from_year         in number,
                      p_plan_trng_ind     in varchar2)
          is
    l_count      number;
    l_plan_count number;
    l_trnd_count number;
    Cursor csr_cp_lookup_values
                  ( l_lookup_type in varchar2
                  , l_year        in number
                  , l_from_year   in number
                  ) is
    select l_year || substr(lookup_code,5) lookup_code
         , lookup_type
      ,  LANGUAGE
      ,  l_year || substr(MEANING,5) MEANING
      ,  DESCRIPTION
      ,  ENABLED_FLAG
--      ,  to_date(to_char(START_DATE_ACTIVE,'DD-MM')||p_year -1,'DD-MM-YYYY')  START_DATE_ACTIVE
--      ,  to_date(to_char(END_DATE_ACTIVE,'DD-MM')||p_year,'DD-MM-YYYY') END_DATE_ACTIVE
      ,  SOURCE_LANG
      ,  SECURITY_GROUP_ID
      ,  VIEW_APPLICATION_ID
      ,  TERRITORY_CODE
      ,  ATTRIBUTE_CATEGORY
      ,  ATTRIBUTE1
      ,  ATTRIBUTE2
      ,  ATTRIBUTE3
      ,  ATTRIBUTE4
      ,  ATTRIBUTE5
      ,  ATTRIBUTE6
      ,  ATTRIBUTE7
      ,  ATTRIBUTE8
      ,  ATTRIBUTE9
      ,  ATTRIBUTE10
      ,  ATTRIBUTE11
      ,  ATTRIBUTE12
      ,  ATTRIBUTE13
      ,  ATTRIBUTE14
      ,  ATTRIBUTE15
    from fnd_lookup_values
    Where lookup_type = l_lookup_type
    and   substr(lookup_code,1,4) = to_char(l_from_year)
    And  security_group_id = fnd_global.lookup_security_group(l_lookup_type,3)
    and (ATTRIBUTE1 ||ATTRIBUTE2 ||ATTRIBUTE3 ||ATTRIBUTE4 ||
        ATTRIBUTE5 ||ATTRIBUTE6 ||ATTRIBUTE7 ||ATTRIBUTE8 ||
        ATTRIBUTE9 ||ATTRIBUTE10||ATTRIBUTE11||ATTRIBUTE12||
        ATTRIBUTE13||ATTRIBUTE14||ATTRIBUTE15) is not null;


   begin

   hr_utility.SET_LOCATION('Inside copy_lookup_values',1);
   hr_utility.SET_LOCATION('p_year '||p_year,1);
   hr_utility.SET_LOCATION('P_from_year ' || P_from_year,1);
   hr_utility.SET_LOCATION('p_plan_trng_ind ' || p_plan_trng_ind,1);


   select count(*) into l_trnd_count
   from   fnd_lookup_values
   Where  lookup_type in
            (
               g_t_lpath_lookup_type
             , g_t_course_lookup_type
             , g_t_cert_lookup_type
            )
   AND security_group_id       = fnd_global.lookup_security_group(lookup_type,3)
   and substr(lookup_code,1,4) = p_year-1;

   hr_utility.SET_LOCATION('l_trnd_count ' || l_trnd_count,1);

   select count(*) into l_plan_count
   from   fnd_lookup_values
   Where  lookup_type in
            (
               g_p_lpath_lookup_type
             , g_p_course_lookup_type
             , g_p_cert_lookup_type
            )
   AND security_group_id       = fnd_global.lookup_security_group(lookup_type,3)
   and substr(lookup_code,1,4) = p_year;

   hr_utility.SET_LOCATION('l_plan_count ' || l_plan_count,1);

   l_count := l_trnd_count + l_plan_count;

   if l_count = 0 then
     tab_usr_row_ids.delete;
         if p_plan_trng_ind = '20' or p_plan_trng_ind = '10' then

   hr_utility.SET_LOCATION('calling Planned g_p_lpath_lookup_type ' ,1);

         for csr_lp_rec in csr_cp_lookup_values
                         ( g_p_lpath_lookup_type
                         ,  p_year
                         ,  p_from_year
                         )
         loop
-- Check if the priority copying is available in the period

          val_usr_row(csr_lp_rec.ATTRIBUTE1,p_year,p_from_year,errbuf,retcode);
          val_usr_row(csr_lp_rec.ATTRIBUTE2,p_year,p_from_year,errbuf,retcode);
          val_usr_row(csr_lp_rec.ATTRIBUTE3,p_year,p_from_year,errbuf,retcode);
          val_usr_row(csr_lp_rec.ATTRIBUTE4,p_year,p_from_year,errbuf,retcode);
          val_usr_row(csr_lp_rec.ATTRIBUTE5,p_year,p_from_year,errbuf,retcode);
          val_usr_row(csr_lp_rec.ATTRIBUTE6,p_year,p_from_year,errbuf,retcode);
          val_usr_row(csr_lp_rec.ATTRIBUTE7,p_year,p_from_year,errbuf,retcode);
          val_usr_row(csr_lp_rec.ATTRIBUTE8,p_year,p_from_year,errbuf,retcode);
          val_usr_row(csr_lp_rec.ATTRIBUTE9,p_year,p_from_year,errbuf,retcode);
          val_usr_row(csr_lp_rec.ATTRIBUTE10,p_year,p_from_year,errbuf,retcode);
          val_usr_row(csr_lp_rec.ATTRIBUTE11,p_year,p_from_year,errbuf,retcode);
          val_usr_row(csr_lp_rec.ATTRIBUTE12,p_year,p_from_year,errbuf,retcode);
          val_usr_row(csr_lp_rec.ATTRIBUTE13,p_year,p_from_year,errbuf,retcode);
          val_usr_row(csr_lp_rec.ATTRIBUTE14,p_year,p_from_year,errbuf,retcode);
          val_usr_row(csr_lp_rec.ATTRIBUTE15,p_year,p_from_year,errbuf,retcode);

          LOOKUP_VAL_INSERT_ROW
            (  P_LOOKUP_TYPE      => csr_lp_rec.LOOKUP_TYPE
            , P_LOOKUP_CODE       => csr_lp_rec.LOOKUP_CODE
            , P_ATTRIBUTE1        => csr_lp_rec.ATTRIBUTE1
            , P_ATTRIBUTE2        => csr_lp_rec.ATTRIBUTE2
            , P_ATTRIBUTE3        => csr_lp_rec.ATTRIBUTE3
            , P_ATTRIBUTE4        => csr_lp_rec.ATTRIBUTE4
            , P_ATTRIBUTE5        => csr_lp_rec.ATTRIBUTE5
            , P_ATTRIBUTE6        => csr_lp_rec.ATTRIBUTE6
            , P_ATTRIBUTE7        => csr_lp_rec.ATTRIBUTE7
            , P_ATTRIBUTE8        => csr_lp_rec.ATTRIBUTE8
            , P_ATTRIBUTE9        => csr_lp_rec.ATTRIBUTE9
            , P_ATTRIBUTE10       => csr_lp_rec.ATTRIBUTE10
            , P_ATTRIBUTE11       => csr_lp_rec.ATTRIBUTE11
            , P_ATTRIBUTE12       => csr_lp_rec.ATTRIBUTE12
            , P_ATTRIBUTE13       => csr_lp_rec.ATTRIBUTE13
            , P_ATTRIBUTE14       => csr_lp_rec.ATTRIBUTE14
            , P_ATTRIBUTE15       => csr_lp_rec.ATTRIBUTE15
            , P_ENABLED_FLAG      => 'Y'
            , P_MEANING           => csr_lp_rec.MEANING
            , P_DESCRIPTION       => csr_lp_rec.DESCRIPTION
            , P_START_DATE_ACTIVE => g_plan_year_start_date
            , P_END_DATE_ACTIVE   => g_plan_year_end_date
            );
         end loop;

   hr_utility.SET_LOCATION('calling planned g_p_cert_lookup_type ' ,1);
         for csr_cert_rec in csr_cp_lookup_values
                         ( g_p_cert_lookup_type
                         ,  p_year
                         ,  p_from_year
                         )
         loop
-- Check if the priority copying is available in the period

          val_usr_row(csr_cert_rec.ATTRIBUTE1,p_year,p_from_year,errbuf,retcode);
          val_usr_row(csr_cert_rec.ATTRIBUTE2,p_year,p_from_year,errbuf,retcode);
          val_usr_row(csr_cert_rec.ATTRIBUTE3,p_year,p_from_year,errbuf,retcode);
          val_usr_row(csr_cert_rec.ATTRIBUTE4,p_year,p_from_year,errbuf,retcode);
          val_usr_row(csr_cert_rec.ATTRIBUTE5,p_year,p_from_year,errbuf,retcode);
          val_usr_row(csr_cert_rec.ATTRIBUTE6,p_year,p_from_year,errbuf,retcode);
          val_usr_row(csr_cert_rec.ATTRIBUTE7,p_year,p_from_year,errbuf,retcode);
          val_usr_row(csr_cert_rec.ATTRIBUTE8,p_year,p_from_year,errbuf,retcode);
          val_usr_row(csr_cert_rec.ATTRIBUTE9,p_year,p_from_year,errbuf,retcode);
          val_usr_row(csr_cert_rec.ATTRIBUTE10,p_year,p_from_year,errbuf,retcode);
          val_usr_row(csr_cert_rec.ATTRIBUTE11,p_year,p_from_year,errbuf,retcode);
          val_usr_row(csr_cert_rec.ATTRIBUTE12,p_year,p_from_year,errbuf,retcode);
          val_usr_row(csr_cert_rec.ATTRIBUTE13,p_year,p_from_year,errbuf,retcode);
          val_usr_row(csr_cert_rec.ATTRIBUTE14,p_year,p_from_year,errbuf,retcode);
          val_usr_row(csr_cert_rec.ATTRIBUTE15,p_year,p_from_year,errbuf,retcode);

          LOOKUP_VAL_INSERT_ROW
            (  P_LOOKUP_TYPE      => csr_cert_rec.LOOKUP_TYPE
            , P_LOOKUP_CODE       => csr_cert_rec.LOOKUP_CODE
            , P_ATTRIBUTE1        => csr_cert_rec.ATTRIBUTE1
            , P_ATTRIBUTE2        => csr_cert_rec.ATTRIBUTE2
            , P_ATTRIBUTE3        => csr_cert_rec.ATTRIBUTE3
            , P_ATTRIBUTE4        => csr_cert_rec.ATTRIBUTE4
            , P_ATTRIBUTE5        => csr_cert_rec.ATTRIBUTE5
            , P_ATTRIBUTE6        => csr_cert_rec.ATTRIBUTE6
            , P_ATTRIBUTE7        => csr_cert_rec.ATTRIBUTE7
            , P_ATTRIBUTE8        => csr_cert_rec.ATTRIBUTE8
            , P_ATTRIBUTE9        => csr_cert_rec.ATTRIBUTE9
            , P_ATTRIBUTE10       => csr_cert_rec.ATTRIBUTE10
            , P_ATTRIBUTE11       => csr_cert_rec.ATTRIBUTE11
            , P_ATTRIBUTE12       => csr_cert_rec.ATTRIBUTE12
            , P_ATTRIBUTE13       => csr_cert_rec.ATTRIBUTE13
            , P_ATTRIBUTE14       => csr_cert_rec.ATTRIBUTE14
            , P_ATTRIBUTE15       => csr_cert_rec.ATTRIBUTE15
            , P_ENABLED_FLAG      => 'Y'
            , P_MEANING           => csr_cert_rec.MEANING
            , P_DESCRIPTION       => csr_cert_rec.DESCRIPTION
            , P_START_DATE_ACTIVE => g_plan_year_start_date
            , P_END_DATE_ACTIVE   => g_plan_year_end_date
            );
         end loop;

   hr_utility.SET_LOCATION('calling planned g_p_course_lookup_type ' ,1);

         for csr_crs_rec in csr_cp_lookup_values
                         (  g_p_course_lookup_type
                         ,  p_year
                         ,  p_from_year
                         )
         loop

          val_usr_row(csr_crs_rec.ATTRIBUTE1,p_year,p_from_year,errbuf,retcode);
          val_usr_row(csr_crs_rec.ATTRIBUTE2,p_year,p_from_year,errbuf,retcode);
          val_usr_row(csr_crs_rec.ATTRIBUTE3,p_year,p_from_year,errbuf,retcode);
          val_usr_row(csr_crs_rec.ATTRIBUTE4,p_year,p_from_year,errbuf,retcode);
          val_usr_row(csr_crs_rec.ATTRIBUTE5,p_year,p_from_year,errbuf,retcode);
          val_usr_row(csr_crs_rec.ATTRIBUTE6,p_year,p_from_year,errbuf,retcode);
          val_usr_row(csr_crs_rec.ATTRIBUTE7,p_year,p_from_year,errbuf,retcode);
          val_usr_row(csr_crs_rec.ATTRIBUTE8,p_year,p_from_year,errbuf,retcode);
          val_usr_row(csr_crs_rec.ATTRIBUTE9,p_year,p_from_year,errbuf,retcode);
          val_usr_row(csr_crs_rec.ATTRIBUTE10,p_year,p_from_year,errbuf,retcode);
          val_usr_row(csr_crs_rec.ATTRIBUTE11,p_year,p_from_year,errbuf,retcode);
          val_usr_row(csr_crs_rec.ATTRIBUTE12,p_year,p_from_year,errbuf,retcode);
          val_usr_row(csr_crs_rec.ATTRIBUTE13,p_year,p_from_year,errbuf,retcode);
          val_usr_row(csr_crs_rec.ATTRIBUTE14,p_year,p_from_year,errbuf,retcode);
          val_usr_row(csr_crs_rec.ATTRIBUTE15,p_year,p_from_year,errbuf,retcode);

          LOOKUP_VAL_INSERT_ROW
            (  P_LOOKUP_TYPE      => csr_crs_rec.LOOKUP_TYPE
            , P_LOOKUP_CODE       => csr_crs_rec.LOOKUP_CODE
            , P_ATTRIBUTE1        => csr_crs_rec.ATTRIBUTE1
            , P_ATTRIBUTE2        => csr_crs_rec.ATTRIBUTE2
            , P_ATTRIBUTE3        => csr_crs_rec.ATTRIBUTE3
            , P_ATTRIBUTE4        => csr_crs_rec.ATTRIBUTE4
            , P_ATTRIBUTE5        => csr_crs_rec.ATTRIBUTE5
            , P_ATTRIBUTE6        => csr_crs_rec.ATTRIBUTE6
            , P_ATTRIBUTE7        => csr_crs_rec.ATTRIBUTE7
            , P_ATTRIBUTE8        => csr_crs_rec.ATTRIBUTE8
            , P_ATTRIBUTE9        => csr_crs_rec.ATTRIBUTE9
            , P_ATTRIBUTE10       => csr_crs_rec.ATTRIBUTE10
            , P_ATTRIBUTE11       => csr_crs_rec.ATTRIBUTE11
            , P_ATTRIBUTE12       => csr_crs_rec.ATTRIBUTE12
            , P_ATTRIBUTE13       => csr_crs_rec.ATTRIBUTE13
            , P_ATTRIBUTE14       => csr_crs_rec.ATTRIBUTE14
            , P_ATTRIBUTE15       => csr_crs_rec.ATTRIBUTE15
            , P_ENABLED_FLAG      => 'Y'
            , P_MEANING           => csr_crs_rec.MEANING
            , P_DESCRIPTION       => csr_crs_rec.DESCRIPTION
            , P_START_DATE_ACTIVE => g_plan_year_start_date
            , P_END_DATE_ACTIVE   => g_plan_year_end_date
            );
         end loop;
   hr_utility.SET_LOCATION('After planned g_p_course_lookup_type ' ,1);
   hr_utility.SET_LOCATION('Calling planned create_lookup_values ' ,1);
              create_lookup_values
             (errbuf               => errbuf
             , retcode             => retcode
             , p_year              => p_year
             , p_plan_trng_ind     => '20'
             , p_del_mode            => 'N' -- N do not delete the existing lookup values
             );
         end if;
         if p_plan_trng_ind = '30' OR p_plan_trng_ind = '10' then

         tab_usr_row_ids.delete;

   hr_utility.SET_LOCATION('calling Completed g_t_lpath_lookup_type ' ,1);

         for csr_lp_rec in csr_cp_lookup_values
                        (  g_t_lpath_lookup_type
                         ,  p_year - 1
                         ,  p_from_year - 1
                         )
         loop
          val_usr_row(csr_lp_rec.ATTRIBUTE1,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_lp_rec.ATTRIBUTE2,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_lp_rec.ATTRIBUTE3,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_lp_rec.ATTRIBUTE4,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_lp_rec.ATTRIBUTE5,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_lp_rec.ATTRIBUTE6,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_lp_rec.ATTRIBUTE7,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_lp_rec.ATTRIBUTE8,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_lp_rec.ATTRIBUTE9,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_lp_rec.ATTRIBUTE10,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_lp_rec.ATTRIBUTE11,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_lp_rec.ATTRIBUTE12,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_lp_rec.ATTRIBUTE13,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_lp_rec.ATTRIBUTE14,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_lp_rec.ATTRIBUTE15,p_year-1,p_from_year-1,errbuf,retcode);

          LOOKUP_VAL_INSERT_ROW
            (  P_LOOKUP_TYPE      => csr_lp_rec.LOOKUP_TYPE
            , P_LOOKUP_CODE       => csr_lp_rec.LOOKUP_CODE
            , P_ATTRIBUTE1        => csr_lp_rec.ATTRIBUTE1
            , P_ATTRIBUTE2        => csr_lp_rec.ATTRIBUTE2
            , P_ATTRIBUTE3        => csr_lp_rec.ATTRIBUTE3
            , P_ATTRIBUTE4        => csr_lp_rec.ATTRIBUTE4
            , P_ATTRIBUTE5        => csr_lp_rec.ATTRIBUTE5
            , P_ATTRIBUTE6        => csr_lp_rec.ATTRIBUTE6
            , P_ATTRIBUTE7        => csr_lp_rec.ATTRIBUTE7
            , P_ATTRIBUTE8        => csr_lp_rec.ATTRIBUTE8
            , P_ATTRIBUTE9        => csr_lp_rec.ATTRIBUTE9
            , P_ATTRIBUTE10       => csr_lp_rec.ATTRIBUTE10
            , P_ATTRIBUTE11       => csr_lp_rec.ATTRIBUTE11
            , P_ATTRIBUTE12       => csr_lp_rec.ATTRIBUTE12
            , P_ATTRIBUTE13       => csr_lp_rec.ATTRIBUTE13
            , P_ATTRIBUTE14       => csr_lp_rec.ATTRIBUTE14
            , P_ATTRIBUTE15       => csr_lp_rec.ATTRIBUTE15
            , P_ENABLED_FLAG      => 'Y'
            , P_MEANING           => csr_lp_rec.MEANING
            , P_DESCRIPTION       => csr_lp_rec.DESCRIPTION
            , P_START_DATE_ACTIVE => g_trnd_year_start_date
            , P_END_DATE_ACTIVE   => g_trnd_year_end_date
            );
         end loop;

   hr_utility.SET_LOCATION('calling trained g_t_course_lookup_type ' ,1);

         for csr_cert_rec in csr_cp_lookup_values
                         (  g_t_course_lookup_type
                         ,  p_year - 1
                         ,  p_from_year - 1
                         )
         loop

          val_usr_row(csr_cert_rec.ATTRIBUTE1,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_cert_rec.ATTRIBUTE2,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_cert_rec.ATTRIBUTE3,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_cert_rec.ATTRIBUTE4,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_cert_rec.ATTRIBUTE5,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_cert_rec.ATTRIBUTE6,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_cert_rec.ATTRIBUTE7,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_cert_rec.ATTRIBUTE8,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_cert_rec.ATTRIBUTE9,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_cert_rec.ATTRIBUTE10,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_cert_rec.ATTRIBUTE11,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_cert_rec.ATTRIBUTE12,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_cert_rec.ATTRIBUTE13,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_cert_rec.ATTRIBUTE14,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_cert_rec.ATTRIBUTE15,p_year-1,p_from_year-1,errbuf,retcode);

   hr_utility.SET_LOCATION('calling trained LOOKUP_VAL_INSERT_ROW ' ,1);

          LOOKUP_VAL_INSERT_ROW
            (  P_LOOKUP_TYPE      => csr_cert_rec.LOOKUP_TYPE
            , P_LOOKUP_CODE       => csr_cert_rec.LOOKUP_CODE
            , P_ATTRIBUTE1        => csr_cert_rec.ATTRIBUTE1
            , P_ATTRIBUTE2        => csr_cert_rec.ATTRIBUTE2
            , P_ATTRIBUTE3        => csr_cert_rec.ATTRIBUTE3
            , P_ATTRIBUTE4        => csr_cert_rec.ATTRIBUTE4
            , P_ATTRIBUTE5        => csr_cert_rec.ATTRIBUTE5
            , P_ATTRIBUTE6        => csr_cert_rec.ATTRIBUTE6
            , P_ATTRIBUTE7        => csr_cert_rec.ATTRIBUTE7
            , P_ATTRIBUTE8        => csr_cert_rec.ATTRIBUTE8
            , P_ATTRIBUTE9        => csr_cert_rec.ATTRIBUTE9
            , P_ATTRIBUTE10       => csr_cert_rec.ATTRIBUTE10
            , P_ATTRIBUTE11       => csr_cert_rec.ATTRIBUTE11
            , P_ATTRIBUTE12       => csr_cert_rec.ATTRIBUTE12
            , P_ATTRIBUTE13       => csr_cert_rec.ATTRIBUTE13
            , P_ATTRIBUTE14       => csr_cert_rec.ATTRIBUTE14
            , P_ATTRIBUTE15       => csr_cert_rec.ATTRIBUTE15
            , P_ENABLED_FLAG      => 'Y'
            , P_MEANING           => csr_cert_rec.MEANING
            , P_DESCRIPTION       => csr_cert_rec.DESCRIPTION
            , P_START_DATE_ACTIVE => g_trnd_year_start_date
            , P_END_DATE_ACTIVE   => g_trnd_year_end_date
            );
         end loop;

   hr_utility.SET_LOCATION('calling trained g_t_cert_lookup_type ' ,1);

         for csr_crs_rec in csr_cp_lookup_values
                         (  g_t_cert_lookup_type
                         ,  p_year - 1
                         ,  p_from_year - 1
                         )
         loop

          val_usr_row(csr_crs_rec.ATTRIBUTE1,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_crs_rec.ATTRIBUTE2,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_crs_rec.ATTRIBUTE3,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_crs_rec.ATTRIBUTE4,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_crs_rec.ATTRIBUTE5,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_crs_rec.ATTRIBUTE6,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_crs_rec.ATTRIBUTE7,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_crs_rec.ATTRIBUTE8,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_crs_rec.ATTRIBUTE9,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_crs_rec.ATTRIBUTE10,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_crs_rec.ATTRIBUTE11,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_crs_rec.ATTRIBUTE12,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_crs_rec.ATTRIBUTE13,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_crs_rec.ATTRIBUTE14,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_crs_rec.ATTRIBUTE15,p_year-1,p_from_year-1,errbuf,retcode);

          LOOKUP_VAL_INSERT_ROW
            (  P_LOOKUP_TYPE      => csr_crs_rec.LOOKUP_TYPE
            , P_LOOKUP_CODE       => csr_crs_rec.LOOKUP_CODE
            , P_ATTRIBUTE1        => csr_crs_rec.ATTRIBUTE1
            , P_ATTRIBUTE2        => csr_crs_rec.ATTRIBUTE2
            , P_ATTRIBUTE3        => csr_crs_rec.ATTRIBUTE3
            , P_ATTRIBUTE4        => csr_crs_rec.ATTRIBUTE4
            , P_ATTRIBUTE5        => csr_crs_rec.ATTRIBUTE5
            , P_ATTRIBUTE6        => csr_crs_rec.ATTRIBUTE6
            , P_ATTRIBUTE7        => csr_crs_rec.ATTRIBUTE7
            , P_ATTRIBUTE8        => csr_crs_rec.ATTRIBUTE8
            , P_ATTRIBUTE9        => csr_crs_rec.ATTRIBUTE9
            , P_ATTRIBUTE10       => csr_crs_rec.ATTRIBUTE10
            , P_ATTRIBUTE11       => csr_crs_rec.ATTRIBUTE11
            , P_ATTRIBUTE12       => csr_crs_rec.ATTRIBUTE12
            , P_ATTRIBUTE13       => csr_crs_rec.ATTRIBUTE13
            , P_ATTRIBUTE14       => csr_crs_rec.ATTRIBUTE14
            , P_ATTRIBUTE15       => csr_crs_rec.ATTRIBUTE15
            , P_ENABLED_FLAG      => 'Y'
            , P_MEANING           => csr_crs_rec.MEANING
            , P_DESCRIPTION       => csr_crs_rec.DESCRIPTION
            , P_START_DATE_ACTIVE => g_trnd_year_start_date
            , P_END_DATE_ACTIVE   => g_trnd_year_end_date
            );
         end loop;

   hr_utility.SET_LOCATION('calling trained g_t_comp_lookup_type ' ,1);

         for csr_comp_rec in csr_cp_lookup_values
                         (  g_t_comp_lookup_type
                         ,  p_year - 1
                         ,  p_from_year - 1
                         )
         loop

          val_usr_row(csr_comp_rec.ATTRIBUTE1,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_comp_rec.ATTRIBUTE2,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_comp_rec.ATTRIBUTE3,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_comp_rec.ATTRIBUTE4,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_comp_rec.ATTRIBUTE5,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_comp_rec.ATTRIBUTE6,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_comp_rec.ATTRIBUTE7,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_comp_rec.ATTRIBUTE8,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_comp_rec.ATTRIBUTE9,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_comp_rec.ATTRIBUTE10,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_comp_rec.ATTRIBUTE11,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_comp_rec.ATTRIBUTE12,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_comp_rec.ATTRIBUTE13,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_comp_rec.ATTRIBUTE14,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_comp_rec.ATTRIBUTE15,p_year-1,p_from_year-1,errbuf,retcode);

          LOOKUP_VAL_INSERT_ROW
            (  P_LOOKUP_TYPE      => csr_comp_rec.LOOKUP_TYPE
            , P_LOOKUP_CODE       => csr_comp_rec.LOOKUP_CODE
            , P_ATTRIBUTE1        => csr_comp_rec.ATTRIBUTE1
            , P_ATTRIBUTE2        => csr_comp_rec.ATTRIBUTE2
            , P_ATTRIBUTE3        => csr_comp_rec.ATTRIBUTE3
            , P_ATTRIBUTE4        => csr_comp_rec.ATTRIBUTE4
            , P_ATTRIBUTE5        => csr_comp_rec.ATTRIBUTE5
            , P_ATTRIBUTE6        => csr_comp_rec.ATTRIBUTE6
            , P_ATTRIBUTE7        => csr_comp_rec.ATTRIBUTE7
            , P_ATTRIBUTE8        => csr_comp_rec.ATTRIBUTE8
            , P_ATTRIBUTE9        => csr_comp_rec.ATTRIBUTE9
            , P_ATTRIBUTE10       => csr_comp_rec.ATTRIBUTE10
            , P_ATTRIBUTE11       => csr_comp_rec.ATTRIBUTE11
            , P_ATTRIBUTE12       => csr_comp_rec.ATTRIBUTE12
            , P_ATTRIBUTE13       => csr_comp_rec.ATTRIBUTE13
            , P_ATTRIBUTE14       => csr_comp_rec.ATTRIBUTE14
            , P_ATTRIBUTE15       => csr_comp_rec.ATTRIBUTE15
            , P_ENABLED_FLAG      => 'Y'
            , P_MEANING           => csr_comp_rec.MEANING
            , P_DESCRIPTION       => csr_comp_rec.DESCRIPTION
            , P_START_DATE_ACTIVE => g_trnd_year_start_date
            , P_END_DATE_ACTIVE   => g_trnd_year_end_date
            );
         end loop;

   hr_utility.SET_LOCATION('calling trained g_t_qual_lookup_type ' ,1);

         for csr_qual_rec in csr_cp_lookup_values
                         (  g_t_qual_lookup_type
                         ,  p_year - 1
                         ,  p_from_year - 1
                         )
         loop

          val_usr_row(csr_qual_rec.ATTRIBUTE1,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_qual_rec.ATTRIBUTE2,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_qual_rec.ATTRIBUTE3,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_qual_rec.ATTRIBUTE4,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_qual_rec.ATTRIBUTE5,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_qual_rec.ATTRIBUTE6,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_qual_rec.ATTRIBUTE7,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_qual_rec.ATTRIBUTE8,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_qual_rec.ATTRIBUTE9,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_qual_rec.ATTRIBUTE10,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_qual_rec.ATTRIBUTE11,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_qual_rec.ATTRIBUTE12,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_qual_rec.ATTRIBUTE13,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_qual_rec.ATTRIBUTE14,p_year-1,p_from_year-1,errbuf,retcode);
          val_usr_row(csr_qual_rec.ATTRIBUTE15,p_year-1,p_from_year-1,errbuf,retcode);

          LOOKUP_VAL_INSERT_ROW
            (  P_LOOKUP_TYPE      => csr_qual_rec.LOOKUP_TYPE
            , P_LOOKUP_CODE       => csr_qual_rec.LOOKUP_CODE
            , P_ATTRIBUTE1        => csr_qual_rec.ATTRIBUTE1
            , P_ATTRIBUTE2        => csr_qual_rec.ATTRIBUTE2
            , P_ATTRIBUTE3        => csr_qual_rec.ATTRIBUTE3
            , P_ATTRIBUTE4        => csr_qual_rec.ATTRIBUTE4
            , P_ATTRIBUTE5        => csr_qual_rec.ATTRIBUTE5
            , P_ATTRIBUTE6        => csr_qual_rec.ATTRIBUTE6
            , P_ATTRIBUTE7        => csr_qual_rec.ATTRIBUTE7
            , P_ATTRIBUTE8        => csr_qual_rec.ATTRIBUTE8
            , P_ATTRIBUTE9        => csr_qual_rec.ATTRIBUTE9
            , P_ATTRIBUTE10       => csr_qual_rec.ATTRIBUTE10
            , P_ATTRIBUTE11       => csr_qual_rec.ATTRIBUTE11
            , P_ATTRIBUTE12       => csr_qual_rec.ATTRIBUTE12
            , P_ATTRIBUTE13       => csr_qual_rec.ATTRIBUTE13
            , P_ATTRIBUTE14       => csr_qual_rec.ATTRIBUTE14
            , P_ATTRIBUTE15       => csr_qual_rec.ATTRIBUTE15
            , P_ENABLED_FLAG      => 'Y'
            , P_MEANING           => csr_qual_rec.MEANING
            , P_DESCRIPTION       => csr_qual_rec.DESCRIPTION
            , P_START_DATE_ACTIVE => g_trnd_year_start_date
            , P_END_DATE_ACTIVE   => g_trnd_year_end_date
            );
         end loop;
              create_lookup_values
             (errbuf               => errbuf
             , retcode             => retcode
             , p_year              => p_year
             , p_plan_trng_ind     => '30'
             , p_del_mode          => 'N' -- N do not delete the existing lookup values
             );
         end if;
        end if;
    tab_usr_row_ids.delete;
   End copy_lookup_values;


/****************************************************************************
    Name        : copy_plan_2_trining
    Description : If the parameter passed to the concurrent programe is Copy
                  plan to trained this procedure will be called.
                  It copies the lookup along with priorities from already
                  created plan lookups to trained one.
*****************************************************************************/

  Procedure copy_plan_2_trining
                      (errbuf               out nocopy varchar2,
                      retcode               out nocopy number,
                      p_year              in number,
                      P_from_year         in number)
          is
    l_count number;
    Cursor csr_cp_plan_2_train
                  ( l_lookup_type in varchar2
                  ) is
    select p_year -1 || substr(lookup_code,5) lookup_code
         , lookup_type
      ,  LANGUAGE
      ,  MEANING
      ,  DESCRIPTION
      ,  ENABLED_FLAG
      ,  g_trnd_year_start_date START_DATE_ACTIVE
      ,  g_trnd_year_end_date END_DATE_ACTIVE
      ,  SOURCE_LANG
      ,  SECURITY_GROUP_ID
      ,  VIEW_APPLICATION_ID
      ,  TERRITORY_CODE
      ,  ATTRIBUTE_CATEGORY
      ,  ATTRIBUTE1
      ,  ATTRIBUTE2
      ,  ATTRIBUTE3
      ,  ATTRIBUTE4
      ,  ATTRIBUTE5
      ,  ATTRIBUTE6
      ,  ATTRIBUTE7
      ,  ATTRIBUTE8
      ,  ATTRIBUTE9
      ,  ATTRIBUTE10
      ,  ATTRIBUTE11
      ,  ATTRIBUTE12
      ,  ATTRIBUTE13
      ,  ATTRIBUTE14
      ,  ATTRIBUTE15
    from fnd_lookup_values
    Where lookup_type = l_lookup_type
    and   substr(lookup_code,1,4) = to_char(P_from_year)
    And   security_group_id = fnd_global.lookup_security_group(l_lookup_type,3)
    and (ATTRIBUTE1 ||ATTRIBUTE2 ||ATTRIBUTE3 ||ATTRIBUTE4 ||
        ATTRIBUTE5 ||ATTRIBUTE6 ||ATTRIBUTE7 ||ATTRIBUTE8 ||
        ATTRIBUTE9 ||ATTRIBUTE10||ATTRIBUTE11||ATTRIBUTE12||
        ATTRIBUTE13||ATTRIBUTE14||ATTRIBUTE15) is not null;

    begin
       hr_utility.set_location ('Inside copy_plan_2_trining ' ,1);
       hr_utility.set_location ('p_year ' || p_year,1);
       hr_utility.set_location ('P_from_year ' || P_from_year ,1);


        select count(*) into l_count
         from   fnd_lookup_values
         Where  lookup_type in
                (
                  g_t_lpath_lookup_type
                , g_t_course_lookup_type
                , g_t_cert_lookup_type
                )
         And security_group_id       = fnd_global.lookup_security_group(lookup_type,3)
         and substr(lookup_code,1,4) = to_char(p_year-1);

       hr_utility.set_location ('l_count ' || l_count ,2);

    if l_count = 0 then
            tab_usr_row_ids.delete;
        for plan_2_train_rec in csr_cp_plan_2_train
                                 (g_p_lpath_lookup_type
                                 )
        loop
       hr_utility.set_location ('Inside g_p_lpath_lookup_type ' ,1);

          val_usr_row(plan_2_train_rec.ATTRIBUTE1,p_year - 1,p_from_year,errbuf,retcode);
          val_usr_row(plan_2_train_rec.ATTRIBUTE2,p_year - 1,p_from_year,errbuf,retcode);
          val_usr_row(plan_2_train_rec.ATTRIBUTE3,p_year - 1,p_from_year,errbuf,retcode);
          val_usr_row(plan_2_train_rec.ATTRIBUTE4,p_year - 1,p_from_year,errbuf,retcode);
          val_usr_row(plan_2_train_rec.ATTRIBUTE5,p_year - 1,p_from_year,errbuf,retcode);
          val_usr_row(plan_2_train_rec.ATTRIBUTE6,p_year - 1,p_from_year,errbuf,retcode);
          val_usr_row(plan_2_train_rec.ATTRIBUTE7,p_year - 1,p_from_year,errbuf,retcode);
          val_usr_row(plan_2_train_rec.ATTRIBUTE8,p_year - 1,p_from_year,errbuf,retcode);
          val_usr_row(plan_2_train_rec.ATTRIBUTE9,p_year - 1,p_from_year,errbuf,retcode);
          val_usr_row(plan_2_train_rec.ATTRIBUTE10,p_year - 1,p_from_year,errbuf,retcode);
          val_usr_row(plan_2_train_rec.ATTRIBUTE11,p_year - 1,p_from_year,errbuf,retcode);
          val_usr_row(plan_2_train_rec.ATTRIBUTE12,p_year - 1,p_from_year,errbuf,retcode);
          val_usr_row(plan_2_train_rec.ATTRIBUTE13,p_year - 1,p_from_year,errbuf,retcode);
          val_usr_row(plan_2_train_rec.ATTRIBUTE14,p_year - 1,p_from_year,errbuf,retcode);
          val_usr_row(plan_2_train_rec.ATTRIBUTE15,p_year - 1,p_from_year,errbuf,retcode);

          LOOKUP_VAL_INSERT_ROW
            (  P_LOOKUP_TYPE      => g_t_lpath_lookup_type
            , P_LOOKUP_CODE       => plan_2_train_rec.LOOKUP_CODE
            , P_ATTRIBUTE1        => plan_2_train_rec.ATTRIBUTE1
            , P_ATTRIBUTE2        => plan_2_train_rec.ATTRIBUTE2
            , P_ATTRIBUTE3        => plan_2_train_rec.ATTRIBUTE3
            , P_ATTRIBUTE4        => plan_2_train_rec.ATTRIBUTE4
            , P_ATTRIBUTE5        => plan_2_train_rec.ATTRIBUTE5
            , P_ATTRIBUTE6        => plan_2_train_rec.ATTRIBUTE6
            , P_ATTRIBUTE7        => plan_2_train_rec.ATTRIBUTE7
            , P_ATTRIBUTE8        => plan_2_train_rec.ATTRIBUTE8
            , P_ATTRIBUTE9        => plan_2_train_rec.ATTRIBUTE9
            , P_ATTRIBUTE10       => plan_2_train_rec.ATTRIBUTE10
            , P_ATTRIBUTE11       => plan_2_train_rec.ATTRIBUTE11
            , P_ATTRIBUTE12       => plan_2_train_rec.ATTRIBUTE12
            , P_ATTRIBUTE13       => plan_2_train_rec.ATTRIBUTE13
            , P_ATTRIBUTE14       => plan_2_train_rec.ATTRIBUTE14
            , P_ATTRIBUTE15       => plan_2_train_rec.ATTRIBUTE15
            , P_ENABLED_FLAG      => 'Y'
            , P_MEANING           => plan_2_train_rec.MEANING
            , P_DESCRIPTION       => plan_2_train_rec.DESCRIPTION
            , P_START_DATE_ACTIVE => plan_2_train_rec.START_DATE_ACTIVE
            , P_END_DATE_ACTIVE   => plan_2_train_rec.END_DATE_ACTIVE
            );


      end loop;

        for plan_2_train_rec in csr_cp_plan_2_train
                                 (g_p_course_lookup_type
                                 )
        loop
       hr_utility.set_location ('Inside g_p_course_lookup_type ' ,1);
          val_usr_row(plan_2_train_rec.ATTRIBUTE1,p_year - 1,p_from_year,errbuf,retcode);
          val_usr_row(plan_2_train_rec.ATTRIBUTE2,p_year - 1,p_from_year,errbuf,retcode);
          val_usr_row(plan_2_train_rec.ATTRIBUTE3,p_year - 1,p_from_year,errbuf,retcode);
          val_usr_row(plan_2_train_rec.ATTRIBUTE4,p_year - 1,p_from_year,errbuf,retcode);
          val_usr_row(plan_2_train_rec.ATTRIBUTE5,p_year - 1,p_from_year,errbuf,retcode);
          val_usr_row(plan_2_train_rec.ATTRIBUTE6,p_year - 1,p_from_year,errbuf,retcode);
          val_usr_row(plan_2_train_rec.ATTRIBUTE7,p_year - 1,p_from_year,errbuf,retcode);
          val_usr_row(plan_2_train_rec.ATTRIBUTE8,p_year - 1,p_from_year,errbuf,retcode);
          val_usr_row(plan_2_train_rec.ATTRIBUTE9,p_year - 1,p_from_year,errbuf,retcode);
          val_usr_row(plan_2_train_rec.ATTRIBUTE10,p_year - 1,p_from_year,errbuf,retcode);
          val_usr_row(plan_2_train_rec.ATTRIBUTE11,p_year - 1,p_from_year,errbuf,retcode);
          val_usr_row(plan_2_train_rec.ATTRIBUTE12,p_year - 1,p_from_year,errbuf,retcode);
          val_usr_row(plan_2_train_rec.ATTRIBUTE13,p_year - 1,p_from_year,errbuf,retcode);
          val_usr_row(plan_2_train_rec.ATTRIBUTE14,p_year - 1,p_from_year,errbuf,retcode);
          val_usr_row(plan_2_train_rec.ATTRIBUTE15,p_year - 1,p_from_year,errbuf,retcode);

          LOOKUP_VAL_INSERT_ROW
            (  P_LOOKUP_TYPE      => g_t_course_lookup_type
            , P_LOOKUP_CODE       => plan_2_train_rec.LOOKUP_CODE
            , P_ATTRIBUTE1        => plan_2_train_rec.ATTRIBUTE1
            , P_ATTRIBUTE2        => plan_2_train_rec.ATTRIBUTE2
            , P_ATTRIBUTE3        => plan_2_train_rec.ATTRIBUTE3
            , P_ATTRIBUTE4        => plan_2_train_rec.ATTRIBUTE4
            , P_ATTRIBUTE5        => plan_2_train_rec.ATTRIBUTE5
            , P_ATTRIBUTE6        => plan_2_train_rec.ATTRIBUTE6
            , P_ATTRIBUTE7        => plan_2_train_rec.ATTRIBUTE7
            , P_ATTRIBUTE8        => plan_2_train_rec.ATTRIBUTE8
            , P_ATTRIBUTE9        => plan_2_train_rec.ATTRIBUTE9
            , P_ATTRIBUTE10       => plan_2_train_rec.ATTRIBUTE10
            , P_ATTRIBUTE11       => plan_2_train_rec.ATTRIBUTE11
            , P_ATTRIBUTE12       => plan_2_train_rec.ATTRIBUTE12
            , P_ATTRIBUTE13       => plan_2_train_rec.ATTRIBUTE13
            , P_ATTRIBUTE14       => plan_2_train_rec.ATTRIBUTE14
            , P_ATTRIBUTE15       => plan_2_train_rec.ATTRIBUTE15
            , P_ENABLED_FLAG      => 'Y'
            , P_MEANING           => plan_2_train_rec.MEANING
            , P_DESCRIPTION       => plan_2_train_rec.DESCRIPTION
            , P_START_DATE_ACTIVE => plan_2_train_rec.START_DATE_ACTIVE
            , P_END_DATE_ACTIVE   => plan_2_train_rec.END_DATE_ACTIVE
            );


      end loop;
        for plan_2_train_rec in csr_cp_plan_2_train
                                 (g_p_cert_lookup_type
                                 )
        loop
       hr_utility.set_location ('Inside g_p_cert_lookup_type ' ,1);
          val_usr_row(plan_2_train_rec.ATTRIBUTE1,p_year - 1,p_from_year,errbuf,retcode);
          val_usr_row(plan_2_train_rec.ATTRIBUTE2,p_year - 1,p_from_year,errbuf,retcode);
          val_usr_row(plan_2_train_rec.ATTRIBUTE3,p_year - 1,p_from_year,errbuf,retcode);
          val_usr_row(plan_2_train_rec.ATTRIBUTE4,p_year - 1,p_from_year,errbuf,retcode);
          val_usr_row(plan_2_train_rec.ATTRIBUTE5,p_year - 1,p_from_year,errbuf,retcode);
          val_usr_row(plan_2_train_rec.ATTRIBUTE6,p_year - 1,p_from_year,errbuf,retcode);
          val_usr_row(plan_2_train_rec.ATTRIBUTE7,p_year - 1,p_from_year,errbuf,retcode);
          val_usr_row(plan_2_train_rec.ATTRIBUTE8,p_year - 1,p_from_year,errbuf,retcode);
          val_usr_row(plan_2_train_rec.ATTRIBUTE9,p_year - 1,p_from_year,errbuf,retcode);
          val_usr_row(plan_2_train_rec.ATTRIBUTE10,p_year - 1,p_from_year,errbuf,retcode);
          val_usr_row(plan_2_train_rec.ATTRIBUTE11,p_year - 1,p_from_year,errbuf,retcode);
          val_usr_row(plan_2_train_rec.ATTRIBUTE12,p_year - 1,p_from_year,errbuf,retcode);
          val_usr_row(plan_2_train_rec.ATTRIBUTE13,p_year - 1,p_from_year,errbuf,retcode);
          val_usr_row(plan_2_train_rec.ATTRIBUTE14,p_year - 1,p_from_year,errbuf,retcode);
          val_usr_row(plan_2_train_rec.ATTRIBUTE15,p_year - 1,p_from_year,errbuf,retcode);

          LOOKUP_VAL_INSERT_ROW
            (  P_LOOKUP_TYPE      => g_t_cert_lookup_type
            , P_LOOKUP_CODE       => plan_2_train_rec.LOOKUP_CODE
            , P_ATTRIBUTE1        => plan_2_train_rec.ATTRIBUTE1
            , P_ATTRIBUTE2        => plan_2_train_rec.ATTRIBUTE2
            , P_ATTRIBUTE3        => plan_2_train_rec.ATTRIBUTE3
            , P_ATTRIBUTE4        => plan_2_train_rec.ATTRIBUTE4
            , P_ATTRIBUTE5        => plan_2_train_rec.ATTRIBUTE5
            , P_ATTRIBUTE6        => plan_2_train_rec.ATTRIBUTE6
            , P_ATTRIBUTE7        => plan_2_train_rec.ATTRIBUTE7
            , P_ATTRIBUTE8        => plan_2_train_rec.ATTRIBUTE8
            , P_ATTRIBUTE9        => plan_2_train_rec.ATTRIBUTE9
            , P_ATTRIBUTE10       => plan_2_train_rec.ATTRIBUTE10
            , P_ATTRIBUTE11       => plan_2_train_rec.ATTRIBUTE11
            , P_ATTRIBUTE12       => plan_2_train_rec.ATTRIBUTE12
            , P_ATTRIBUTE13       => plan_2_train_rec.ATTRIBUTE13
            , P_ATTRIBUTE14       => plan_2_train_rec.ATTRIBUTE14
            , P_ATTRIBUTE15       => plan_2_train_rec.ATTRIBUTE15
            , P_ENABLED_FLAG      => 'Y'
            , P_MEANING           => plan_2_train_rec.MEANING
            , P_DESCRIPTION       => plan_2_train_rec.DESCRIPTION
            , P_START_DATE_ACTIVE => plan_2_train_rec.START_DATE_ACTIVE
            , P_END_DATE_ACTIVE   => plan_2_train_rec.END_DATE_ACTIVE
            );


      end loop;
                tab_usr_row_ids.delete;
                end if;

   end copy_plan_2_trining;

/****************************************************************************
    Name        : wsp_populate_udt
    Description : It create user columns in PAY_USER_COLUMNS each for
                  South Africa specific Legal Entity.

*****************************************************************************/
  Procedure wsp_populate_udt is

        Cursor cur_leg_entity is
                Select org_unit.organization_id
                     , org_unit.organization_id || '_' || substr(org_unit_tl.NAME,1,79 - length(org_unit.organization_id)) user_column_name
                     , org_unit.BUSINESS_GROUP_ID BUSINESS_GROUP_ID
                     , org_bg.ORG_INFORMATION9 legislation_code
                from  hr_organization_information org_Legal_ent
                    , hr_all_organization_units   org_unit
                    , hr_organization_information org_bg
                    , hr_all_organization_units_tl org_unit_tl
                Where org_Legal_ent.ORG_INFORMATION_CONTEXT = 'CLASS'
                And   org_Legal_ent.ORG_INFORMATION1  =  'HR_LEGAL'
                and   org_Legal_ent.ORGANIZATION_ID   = org_unit.ORGANIZATION_ID
                And   org_bg.ORGANIZATION_ID          = org_unit.BUSINESS_GROUP_ID
                And   org_bg.ORG_INFORMATION_CONTEXT  = 'Business Group Information'
                And   org_bg.ORG_INFORMATION9         = 'ZA'
                And   org_unit_tl.ORGANIZATION_ID     = org_unit.ORGANIZATION_ID
                And   org_unit_tl.LANGUAGE            = userenv('LANG')
          And not exists
                ( Select 1
                  from  PAY_USER_TABLES     PUT
                      , PAY_USER_COLUMNS    PUC
                      , PAY_USER_COLUMNS_TL PUC_TL
                  Where PUT.USER_TABLE_NAME     = 'ZA_WSP_SKILLS_PRIORITIES'
                  And   PUT.legislation_code    = 'ZA'
                  And   PUT.USER_TABLE_ID       = PUC.USER_TABLE_ID
                  And   PUC_TL.USER_COLUMN_ID   = PUC.USER_COLUMN_ID
                  And   PUC_TL.language         = userenv('LANG')
                  And   PUC_TL.USER_COLUMN_NAME = org_unit.organization_id || '_' || substr(org_unit_tl.NAME,1,79 - length(org_unit.organization_id))
                );
   l_row_id varchar2(100);
   l_usr_col_id varchar2(100);
   l_user_table_id number;
  Begin
        Select PUT.USER_TABLE_ID
               into l_user_table_id
        From   PAY_USER_TABLES     PUT
        Where PUT.USER_TABLE_NAME     = 'ZA_WSP_SKILLS_PRIORITIES'
        And   PUT.legislation_code    = 'ZA';

                for legal_entity_rec in cur_leg_entity
                loop

              pay_user_columns_pkg.insert_row (
                      p_rowid                => l_row_id,
                      p_user_column_id       => l_usr_col_id,
                      p_user_table_id        => l_user_table_id,
                      p_business_group_id    => legal_entity_rec.business_group_id,
                      p_legislation_code     => legal_entity_rec.legislation_code,
                      p_legislation_subgroup => null,
                      p_user_column_name     => legal_entity_rec.user_column_name,
                      p_formula_id           => null ) ;
        end loop;
  End wsp_populate_udt;


/* Main procedure
   It i getting called from concurrent programe
*/

/****************************************************************************
    Name        : wsp_lookup_values
    Description : Main . It is getting called from Concurrent programe

*****************************************************************************/

  Procedure wsp_lookup_values
                      (errbuf           out nocopy varchar2,
                      retcode          out nocopy number,
                      p_syncronise        in varchar2,
                      p_year              in number,
                      P_mode              in varchar2,
                      p_from_year         in number,
                      p_plan_trng_ind     in varchar2)
                      Is

  begin
    retcode := 0;
--    hr_utility.trace_on(null,'ZAWSP');
    hr_utility.set_location('In wsp_lookup_values',10);
    hr_utility.set_location('p_syncronise    :' || p_syncronise,20);
    hr_utility.set_location('p_year          :' || p_year,20);
    hr_utility.set_location('P_mode          :' || P_mode,20);
    hr_utility.set_location('p_from_year     :' || p_from_year,20);
    hr_utility.set_location('p_plan_trng_ind :' || p_plan_trng_ind,20);


    if p_syncronise = '10' or p_syncronise = '40' then
                         wsp_populate_udt;
    end if;

-- 30 Set the attribute
    if p_syncronise = '30' or p_syncronise = '40' then
                         set_wsp_cat_attr_cat;
    end if;

    if p_syncronise = '20' or p_syncronise = '40' then
    /* Initialising start and end date for plan and TRAINED */
    Select to_date('01-04-'||(p_year-1),'DD-MM-YYYY')
         , to_date('31-03-'|| p_year   ,'DD-MM-YYYY')
         , to_date('01-04-'||(p_year-2),'DD-MM-YYYY')
         , to_date('31-03-'||(p_year-1),'DD-MM-YYYY')
       INTO
           g_plan_year_start_date
         , g_plan_year_end_date
         , g_trnd_year_start_date
         , g_trnd_year_end_date
    From Dual;

    hr_utility.set_location('g_plan_year_start_date    :' || g_plan_year_start_date,30);
    hr_utility.set_location('g_plan_year_end_date      :' || g_plan_year_end_date,30);
    hr_utility.set_location('g_trnd_year_start_date    :' || g_trnd_year_start_date,30);
    hr_utility.set_location('g_trnd_year_end_date      :' || g_trnd_year_end_date,30);

    if  P_mode = '10' then -- Create
    /* create the look up values
   it will delete existing lookup values for passed year
   and create freash lookup values*/
   hr_utility.set_location('Calling create_lookup_values' ,40);
       create_lookup_values
                      (errbuf               => errbuf
                      , retcode             => retcode
                      --, p_business_group_id => p_business_group_id
                      , p_year              => p_year
                      , p_plan_trng_ind     => p_plan_trng_ind
                      , p_del_mode            => 'Y' -- if values exists delete and re create
                      );
    elsif P_mode = '20' then -- refresh
   hr_utility.set_location('Calling refresh_lookup_values' ,50);
    /* refresh the lookup values
   it will do the following
   1) add the Attribute_category where it is missing
   2) add new rows in lookup values if new Learning Path,
      Courses, Certification, Competencies and Qualifictios added
   */
       refresh_lookup_values
                      (errbuf               => errbuf
                      , retcode             => retcode
                      --, p_business_group_id => p_business_group_id
                      , p_year              => p_year
                      , p_plan_trng_ind     => p_plan_trng_ind
                      );
    elsif P_mode = '30' then -- Copy Plan to TRAINED
/* Create the lookup values for plan as create
   and copy previous years plan to current years TRAINED
*/
   hr_utility.set_location('Calling copy_plan_2_trining' ,50);
     copy_plan_2_trining
               ( errbuf          => errbuf
               , retcode         => retcode
               , p_year          => p_year
               , P_from_year     => P_from_year
               );


    elsif p_mode = '40' then -- Copy Plan to Plan and TRained to Trained
/* Create the lookup values for plan as create
   and copy previous years plan to current years TRAINED
*/
   hr_utility.set_location('Calling copy_lookup_values' ,60);
      copy_lookup_values
                  (errbuf          => errbuf
                  ,retcode          => retcode
                  ,p_year           => p_year
                  ,P_from_year      => P_from_year
                  ,p_plan_trng_ind  => p_plan_trng_ind
                  );

    else
    errbuf  := 'Invalid mode option :' || p_mode || ':';
    retcode := -1;

    end if;
   end if; -- End if p_syncronise = '10' or p_syncronise = '30'
--   hr_utility.trace_off;
    EXCEPTION
    WHEN OTHERS then
        errbuf := substr(SQLERRM,1,255);
        retcode := sqlcode;

  End wsp_lookup_values;
/*
valueset : valueset_wsp_copy_year
*/
function vs_wsp_c_yr
            (
               p_lookup_code in varchar2,
               p_lookup_type in varchar2
             ) return varchar2
         Is
		wsp_copy_year varchar2(100);
		wsp_lookup_type varchar2(10);
begin
if (p_lookup_type = 'ZA_WSP_LEARNING_PATHS'  OR p_lookup_type = 'ZA_WSP_COURSES' OR p_lookup_type =  'ZA_WSP_CERTIFICATIONS' ) then
	wsp_lookup_type := 'WSP';
else if (p_lookup_type = 'ZA_ATR_LEARNING_PATHS'  OR p_lookup_type = 'ZA_ATR_COURSES' OR p_lookup_type =  'ZA_ATR_CERTIFICATIONS' OR p_lookup_type = 'ZA_ATR_QUALIFICATIONS') then
	wsp_lookup_type := 'ATR';
else
	wsp_lookup_type := 'NONE';
end if;
end if;
--
--
if wsp_lookup_type <> 'NONE' then
select decode(instr(wsp_lookup_type,'ATR'),0,substr(p_lookup_code,1,4),substr(p_lookup_code,1,4)+1)
into wsp_copy_year
from dual;
end if;


return wsp_copy_year;

EXCEPTION
 WHEN OTHERS then
				null;

end vs_wsp_c_yr;


end PER_ZA_WSP_LOOKUP;

/
