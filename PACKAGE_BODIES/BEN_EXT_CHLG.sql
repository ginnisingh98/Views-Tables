--------------------------------------------------------
--  DDL for Package Body BEN_EXT_CHLG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_CHLG" as
/* $Header: benxchlg.pkb 120.14.12010000.4 2009/11/24 06:56:25 vkodedal ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+
--
Name
        Benefit Extract Change Log
Purpose
        This package is used to log changes for benefit extract
History
        Date             Who        Version    What?
        10/28/98         Pdas       115.0      Created.
        11/04/98         Pdas       115.1      Added change_exists_in_mem
                                               procedure
        12/18/98         Pdas       115.2      Modified log_per_chg
                                               procedure
        12/18/98         Pdas       115.3      Modified log_per_chg to include
                                               session date
        12/21/98         Pdas       115.4      Added History Info.
        12/29/98         Pdas       115.5      Added prmtr_03..prmtr_07.
        02/24/99         mhoyes     115.6      Modified log_add_chg passed in
                                               old business_group_id  to
                                               ben_ext_chg_evt_api.create_ext_chg_evt
                                               rather than the new value
        03/08/99         tmathers   115.7      Changed MON-YYYY to /MM/YYYY.
        09 Mar 99        G Perry    115.8      IS to AS.
        23 Mar 99        thayden    115.9      Added procedure log_benefit_chg.
        12 May 99        isen       115.10     Added new change events
        26 May 99        thayden    115.11     Remove 'bobby' etc.
        16 Jun 99        isen       115.12     Added new change events
        24 Jun 99        isen       115.13     Added new change events, period of service etc.
        13 Jul 99        isen       115.14     Removed change of primary address logging for
                                               insert of new primary address record - bug 2485
        15 Jul 99        isen       115.15     Fixed bug arising out of above change
        20 Jul 99        isen       115.16     Added log_abs_chg for absence change events
        09 Aug 99        isen       115.17     Added new and old values
        29 Sep 99        isen       115.18     Added new change events
        05 Oct 99        thayden    115.19     Added Reinstate Benefit.
        12 Oct 99        thayden    115.20     Fixed person type usages bug.
        19 Oct 99        thayden    115.21     Fixed application bug.
        09 Nov 99        thayden    115.22     Fix BC date format bug. 1050311
        25 Jan 99        thayden    115.23     New arguments for TBBC and TBAC.
        26 Jan 99        thayden    115.24     Added log_dependent_chg.
        28 Jan 99        thayden    115.25     Old New values for COPR
        30 Jan 99        thayden    115.26     Added element entries.
        15 Mar 00        shdas      115.27     fixed bug 1187479. changed log_benefit_chg.
        15 Mar 00        thayden    115.28     COUN old and new values.
        20 Mar 00        shdas      115.29     CCFN,CCPA,CCMA,CCGE,CCDB,
                                               added log_cont_chg
        07 Nov 00        tilak      115.30     COCN- update primary country is added
        01 Dec 00        rchase     115.31     Bug 1518466. Make sure the payroll is
                                               a change and not an add.
        09 Jan 00        tmathers   115.32     Bug 1530471. Added nvl
                                               around p_new_rec.date_start.
                                               in log_cont_chg.
        24 jul 01        tilak      115.31     email can be more than 200 char ,change logh support
                                               200 only   so the value is substr to 200
        26 jul o1        tilak      115.32     COPOS cahnge of periods of service added
        27 oct 01        tjesumic   115.33     l_full_name lenght was 50 , changed to full name type
                                               bug : 2070576 fixed
        06 feb 02        tjesdumic  115.36     delete EE entry fixed by changing UPDATE to DELETE
        11 mar 02        tjesumic   115.37     UTF8 changes , variable size set dynomically
        14 Mar 02        rpillay    115.38     UTF Changes Bug 2254683
        23 May 02        tjesumic   115.39     change log for per_information1, per_informatiuon10
                                               uses_tobacco_flag added
        30 may 02        tjesumic   115.40     log_per_pay procedured added for base salary change
                                               log_school_chg procedure added
                                               log_prem_mo_chg proecude added
                                               Address are substring to 600  fro bug 2383576
       31 may 02         tjesumic   115.41     Curosr c_old_sal cahnged ,date param added

       13-Aug 02         glingapp   115.42     Bug 1554477 Modified code to trigger extract change event when
        				       home phone, fax, work phone, mobile is entered deleted or updated,
        				       date_to for phones is entered, when working hours of assignment is
                                                updated
       15-Jul-03         tjesumic   115.43    for COTR the effective date is passed instead of sysdate to
                                              change event effective date
       18-Jul-03         tjesumic   115.44    for COTR the actual termn date is passed instead of sysdate
                                              Since the changes effected from termination date, termn date
                                              became effective date for the changes
       09-Jan-04         rpgupta   115.45     Bug 3361237 Do not pass date to find business group.
                                              A person can only have one business group. Hence its ok
                                              if we get from the first record returned
       10-Jan-03         tjesumic  115.46     coen added for employee number
       09-Jan-04         rpgupta   115.47     Make change eff dt for delete phones as
                                              greatest(nvl(dt_to, dt_from), sysdate)
       26-Jan-04         vjhanak   115.48     Changes made to track the creation of secondary
                                              employeee assignment for NL.
       24-Feb-05         vborkar   115.49     In calls to ben_ext_chg_evt_api.create_ext_chg_evt,
                                              whenever person's full name was getting truncated
					                          to 200 characters, increased it to 240 characters.
       24-mar-05         tjesumic  115.50     position added in log
       11-Aug-05         rgajula   115.51     Bug 4539732  Changed the date type of l_chg_eff_dt to
                                              date table type in procedure log_pos_chg.
       30-Aug-05         tjesumic  115.52     log_per_chg overload procedure created,
                                              that will be called from SSHR api
       26-Sep-05         tjesumic  115.53     ethnick orign lookup values stored for old value and new values
                                              insted of the codes
       14-Oct-05         vjhanak   115.54     Changes made to track the change to ASG Softcoded KFF id
       28-Oct-05         rgajula   115.55     Bug 4699556 Made changes in the log_add_chg where previously when APA
                                              and AMA both were triggered at the same time only APA was logged .
                                              Chaged the code so as to log the events independent of each other.
       31-Oct-05         rbingi    115.55     4705814, passing person_type ( Initially passed NULLs )
                                              to Old, New Values for 'A%PTU' change event
       27-Dec-05         rtagarra  115.57     Function "HR_GENERAL.DECODE_LOOKUP" has been called for
                                              bug#4699913 so that meaning ll be
					      populated instead of lookup code for Assignment Category.
       01-Sep-06         tjesumic  115.59     new change event added to log changes of contact of any person type
                                              CCNFN,CCNDB,CCNDD,CCNSS,CCNGE,CCNRE,CCNPC,CCNPA,CCNMA
       14-Sep-06         tjesumic  115.60     log_per_pay_chg's  cursor c_person is opend withing the changes
       14-Nov-06         tjesumic   115.62   per_pay_proposal trigger moved to api (pepyprhi.pkb 115.60)
                                             the global record changed to have all the column of the table
                                             for future requirements.
                                             Rqd: pepyprhi.pkb,115.60 benxchglg.pkb 115.28,benxbstg.sql 115.3
       14-Nov-06         tjesumic  115.63    approved status for old record is fixed
       09-Jan-07         tjesumic  115.64    the lookup code COPMPRM changed to CCOPMPRM
       09-Jan-07         tjesumic  115.65    the lookup code COPMPRM changed to CCOPMPRM
       08-Jul-08         pvelugul  115.66    Modified for 6517369.
       24-Nov-09         vkodedal  115.67    Overloaded log_asg_chg, called from core HR bug#9092938

*/
--

function change_exists_in_db
         (p_person_id     in    number
         ,p_chg_evt_cd    in    varchar2
         ,p_chg_eff_dt    in    date
         ) return boolean is
--
  cursor get_change is
  SELECT null
  FROM   ben_ext_chg_evt_log a
  WHERE  a.person_id = p_person_id
  AND    a.chg_evt_cd = p_chg_evt_cd
  AND    trunc(a.chg_eff_dt) = trunc(p_chg_eff_dt);
--
  l_proc          varchar2(80) := 'ben_ext_chlg.change_exists_in_db';
  l_dummy         varchar2(30);
  l_return        boolean;
--
begin
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
--
  open get_change;
  fetch get_change into l_dummy;
--
  if get_change%found then
    l_return := TRUE;
  else
    l_return := FALSE;
  end if;
--
  close get_change;
--
  return (l_return);
--
  hr_utility.set_location('Exiting:'|| l_proc, 99);
--
end change_exists_in_db;
--
--
function change_exists_in_mem
         (p_chg_evt_tab   in    g_char_tab_type
         ,p_chg_eff_tab   in    g_date_tab_type
         ,p_chg_evt_cd    in    varchar2
         ,p_chg_eff_dt    in    date
         ) return boolean is
--
  l_proc          varchar2(80) := 'ben_ext_chlg.change_exists_in_mem';
  l_counter       number := 0;
  l_return        boolean := FALSE;
--
begin
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
--
  for l_counter in 1..p_chg_evt_tab.count loop
    if p_chg_evt_tab(l_counter) = p_chg_evt_cd
       and p_chg_eff_tab(l_counter) = p_chg_eff_dt then
      l_return := TRUE;
      exit;
    end if;
  end loop;
--
  return (l_return);
--
  hr_utility.set_location('Exiting:'|| l_proc, 99);
--
end change_exists_in_mem;
--
------------------------------------------------------------------------
function change_event_is_enabled
         (p_chg_evt_cd     in    varchar2
         ,p_effective_date in    date
         ) return boolean is
--
  cursor c_lookup_is_enabled is
  SELECT null
  FROM   hr_lookups h
  WHERE  h.lookup_type = 'BEN_EXT_CHG_EVT'
  AND    h.lookup_code = p_chg_evt_cd
  AND    h.enabled_flag = 'Y'
  AND    p_effective_date between nvl(start_date_active,p_effective_date)
          and nvl(end_date_active,p_effective_date);
--
  l_proc          varchar2(80) := 'ben_ext_chlg.change_event_is_enabled';
  l_dummy         varchar2(30);
  l_return        boolean;
--
begin
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
--
  open c_lookup_is_enabled;
  fetch c_lookup_is_enabled into l_dummy;
--
  if c_lookup_is_enabled%found then
    l_return := TRUE;
  else
    l_return := FALSE;
  end if;
--
  close c_lookup_is_enabled;
--
  return (l_return);
--
  hr_utility.set_location('Exiting:'|| l_proc, 99);
--
end change_event_is_enabled;
--



--- this is a overlaod procedure to call from SSHR4
 procedure log_per_chg
  (p_event        in   varchar2
  ,p_old_rec      in   per_per_shd.g_rec_type
  ,p_new_rec      in   per_per_shd.g_rec_type
--  ,p_mode         in   varchar2
  )is

  l_old_rec           ben_ext_chlg.g_per_rec_type;
  l_new_rec           ben_ext_chlg.g_per_rec_type;
  l_event             varchar2(10) ;
--
  l_proc               varchar2(100) := 'ben_ext_chlg.log_per_chg';
begin

  hr_utility.set_location('Entering:'|| l_proc, 05);


  l_old_rec.national_identifier := p_old_rec.national_identifier;
  l_old_rec.full_name := p_old_rec.full_name;
  l_old_rec.last_name := p_old_rec.last_name;
  l_old_rec.first_name := p_old_rec.first_name;
  l_old_rec.middle_names := p_old_rec.middle_names;
  l_old_rec.title := p_old_rec.title;
  l_old_rec.pre_name_adjunct := p_old_rec.pre_name_adjunct;
  l_old_rec.suffix := p_old_rec.suffix;
  l_old_rec.known_as := p_old_rec.known_as;
  l_old_rec.previous_last_name := p_old_rec.previous_last_name;
  l_old_rec.date_of_birth := p_old_rec.date_of_birth;
  l_old_rec.sex := p_old_rec.sex;
  l_old_rec.marital_status := p_old_rec.marital_status;
  l_old_rec.person_id := p_old_rec.person_id;
  l_old_rec.person_type_id := p_old_rec.person_type_id;
  l_old_rec.business_group_id := p_old_rec.business_group_id;
  l_old_rec.registered_disabled_flag := p_old_rec.registered_disabled_flag;
  l_old_rec.benefit_group_id := p_old_rec.benefit_group_id;
  l_old_rec.student_status := p_old_rec.student_status;
  l_old_rec.date_of_death := p_old_rec.date_of_death;
  l_old_rec.date_employee_data_verified := p_old_rec.date_employee_data_verified;
  l_old_rec.effective_start_date :=p_old_rec.effective_start_date;
  l_old_rec.effective_end_date :=p_old_rec.effective_end_date;
  l_old_rec.attribute1 :=p_old_rec.attribute1;
  l_old_rec.attribute2 :=p_old_rec.attribute2;
  l_old_rec.attribute3 :=p_old_rec.attribute3;
  l_old_rec.attribute4 :=p_old_rec.attribute4;
  l_old_rec.attribute5 :=p_old_rec.attribute5;
  l_old_rec.attribute6 :=p_old_rec.attribute6;
  l_old_rec.attribute7 :=p_old_rec.attribute7;
  l_old_rec.attribute8 :=p_old_rec.attribute8;
  l_old_rec.attribute9 :=p_old_rec.attribute9;
  l_old_rec.attribute10 :=p_old_rec.attribute10;
  l_old_rec.email_address :=p_old_rec.email_address;
  l_old_rec.per_information1 :=p_old_rec.per_information1;
  l_old_rec.per_information2 :=p_old_rec.per_information2;
  l_old_rec.per_information3 :=p_old_rec.per_information3;
  l_old_rec.per_information4 :=p_old_rec.per_information4;
  l_old_rec.attribute5 :=p_old_rec.attribute5;
  l_old_rec.attribute6 :=p_old_rec.attribute6;
  l_old_rec.attribute7 :=p_old_rec.attribute7;
  l_old_rec.attribute8 :=p_old_rec.attribute8;
  l_old_rec.attribute9 :=p_old_rec.attribute9;
  l_old_rec.attribute10 :=p_old_rec.attribute10;
  l_old_rec.email_address :=p_old_rec.email_address;
  l_old_rec.per_information1 :=p_old_rec.per_information1;
  l_old_rec.per_information2 :=p_old_rec.per_information2;
  l_old_rec.per_information3 :=p_old_rec.per_information3;
  l_old_rec.per_information4 :=p_old_rec.per_information4;
  l_old_rec.per_information5 :=p_old_rec.per_information5;
  l_old_rec.per_information6 :=p_old_rec.per_information6;
  l_old_rec.per_information7 :=p_old_rec.per_information7;
  l_old_rec.per_information8 :=p_old_rec.per_information8;
  l_old_rec.per_information9 :=p_old_rec.per_information9;
  l_old_rec.per_information10 :=p_old_rec.per_information10;
  l_old_rec.per_information11 :=p_old_rec.per_information11;
  l_old_rec.per_information12 :=p_old_rec.per_information12;
  l_old_rec.per_information13 :=p_old_rec.per_information13;
  l_old_rec.per_information14 :=p_old_rec.per_information14;
  l_old_rec.per_information15 :=p_old_rec.per_information15;
  l_old_rec.per_information16 :=p_old_rec.per_information16;
  l_old_rec.per_information17 :=p_old_rec.per_information17;
  l_old_rec.per_information18 :=p_old_rec.per_information18;
  l_old_rec.per_information19 :=p_old_rec.per_information19;
  l_old_rec.per_information20 :=p_old_rec.per_information20;
  l_old_rec.per_information21 :=p_old_rec.per_information21;
  l_old_rec.per_information22 :=p_old_rec.per_information22;
  l_old_rec.per_information23 :=p_old_rec.per_information23;
  l_old_rec.per_information24 :=p_old_rec.per_information24;
  l_old_rec.per_information25 :=p_old_rec.per_information25;
  l_old_rec.per_information26 :=p_old_rec.per_information26;
  l_old_rec.per_information27 :=p_old_rec.per_information27;
  l_old_rec.per_information28 :=p_old_rec.per_information28;
  l_old_rec.per_information29 :=p_old_rec.per_information29;
  l_old_rec.per_information30 :=p_old_rec.per_information30;
  l_old_rec.correspondence_language :=p_old_rec.correspondence_language;
  l_old_rec.uses_tobacco_flag :=p_old_rec.uses_tobacco_flag;
  l_old_rec.employee_number   :=p_old_rec.employee_number;
--
  l_new_rec.national_identifier := p_new_rec.national_identifier;
  l_new_rec.full_name := p_new_rec.full_name;
  l_new_rec.last_name := p_new_rec.last_name;
  l_new_rec.first_name := p_new_rec.first_name;
  l_new_rec.middle_names := p_new_rec.middle_names;
  l_new_rec.title := p_new_rec.title;
  l_new_rec.pre_name_adjunct := p_new_rec.pre_name_adjunct;
  l_new_rec.suffix := p_new_rec.suffix;
  l_new_rec.known_as := p_new_rec.known_as;
  l_new_rec.previous_last_name := p_new_rec.previous_last_name;
  l_new_rec.date_of_birth := p_new_rec.date_of_birth;
  l_new_rec.sex := p_new_rec.sex;
  l_new_rec.marital_status := p_new_rec.marital_status;
  l_new_rec.person_id := p_new_rec.person_id;
  l_new_rec.person_type_id := p_new_rec.person_type_id;
  l_new_rec.business_group_id := p_new_rec.business_group_id;
  l_new_rec.registered_disabled_flag := p_new_rec.registered_disabled_flag;
  l_new_rec.benefit_group_id := p_new_rec.benefit_group_id;
  l_new_rec.student_status := p_new_rec.student_status;
  l_new_rec.date_of_death := p_new_rec.date_of_death;
  l_new_rec.date_employee_data_verified := p_new_rec.date_employee_data_verified;
  l_new_rec.effective_start_date :=p_new_rec.effective_start_date;
  l_new_rec.effective_end_date :=p_new_rec.effective_end_date;
  l_new_rec.attribute1 :=p_new_rec.attribute1;
  l_new_rec.attribute2 :=p_new_rec.attribute2;
  l_new_rec.attribute3 :=p_new_rec.attribute3;
  l_new_rec.attribute4 :=p_new_rec.attribute4;
  l_new_rec.attribute5 :=p_new_rec.attribute5;
  l_new_rec.attribute6 :=p_new_rec.attribute6;
  l_new_rec.attribute7 :=p_new_rec.attribute7;
  l_new_rec.attribute8 :=p_new_rec.attribute8;
  l_new_rec.attribute9 :=p_new_rec.attribute9;
  l_new_rec.attribute10 :=p_new_rec.attribute10;
  l_new_rec.email_address :=p_new_rec.email_address;
  l_new_rec.per_information1 :=p_new_rec.per_information1;
  l_new_rec.per_information2 :=p_new_rec.per_information2;
  l_new_rec.per_information3 :=p_new_rec.per_information3;
  l_new_rec.per_information4 :=p_new_rec.per_information4;
  l_new_rec.per_information5 :=p_new_rec.per_information5;
  l_new_rec.per_information6 :=p_new_rec.per_information6;
  l_new_rec.per_information7 :=p_new_rec.per_information7;
  l_new_rec.per_information8 :=p_new_rec.per_information8;
  l_new_rec.per_information9 :=p_new_rec.per_information9;
  l_new_rec.per_information10 :=p_new_rec.per_information10;
  l_new_rec.per_information11 :=p_new_rec.per_information11;
  l_new_rec.per_information12 :=p_new_rec.per_information12;
  l_new_rec.per_information13 :=p_new_rec.per_information13;
  l_new_rec.per_information14 :=p_new_rec.per_information14;
  l_new_rec.per_information15 :=p_new_rec.per_information15;
  l_new_rec.per_information16 :=p_new_rec.per_information16;
  l_new_rec.per_information17 :=p_new_rec.per_information17;
  l_new_rec.per_information18 :=p_new_rec.per_information18;
  l_new_rec.per_information19 :=p_new_rec.per_information19;
  l_new_rec.per_information20 :=p_new_rec.per_information20;
  l_new_rec.per_information21 :=p_new_rec.per_information21;
  l_new_rec.per_information22 :=p_new_rec.per_information22;
  l_new_rec.per_information23 :=p_new_rec.per_information23;
  l_new_rec.per_information24 :=p_new_rec.per_information24;
  l_new_rec.per_information25 :=p_new_rec.per_information25;
  l_new_rec.per_information26 :=p_new_rec.per_information26;
  l_new_rec.per_information27 :=p_new_rec.per_information27;
  l_new_rec.per_information28 :=p_new_rec.per_information28;
  l_new_rec.per_information29 :=p_new_rec.per_information29;
  l_new_rec.per_information30 :=p_new_rec.per_information30;
  l_new_rec.correspondence_language :=p_new_rec.correspondence_language;
  l_new_rec.uses_tobacco_flag :=p_new_rec.uses_tobacco_flag;
  l_new_rec.employee_number   :=p_new_rec.employee_number;

  if p_new_rec.effective_start_date = p_old_rec.effective_start_date then
    l_new_rec.update_mode := 'CORRECTION';
    l_old_rec.update_mode := 'CORRECTION';
  else
    l_new_rec.update_mode := 'UPDATE';
    l_old_rec.update_mode := 'UPDATE';
  end if;

  l_event  := nvl(p_event ,'UPDATE') ;

  log_per_chg
  (p_event   => p_event
  ,p_old_rec => l_old_rec
  ,p_new_rec => l_new_rec
  );
  hr_utility.set_location('Exiting:'|| l_proc, 99);
end ;

------------------------------------------------------------------------------------------
procedure log_per_chg
          (p_event     in  varchar2
          ,p_old_rec   in  g_per_rec_type
          ,p_new_rec   in  g_per_rec_type
          ) is
--
  l_chg_evt_tab           g_char_tab_type;
  l_cont_chg_evt_tab      g_char_tab_type;
  l_prmtr_01_tab          g_char_tab_type;
  l_prmtr_02_tab          g_char_tab_type;
  l_prmtr_03_tab          g_char_tab_type;
  l_prmtr_04_tab          g_char_tab_type;
  l_prmtr_05_tab          g_char_tab_type;
  l_prmtr_06_tab          g_char_tab_type;
  l_prmtr_07_tab          g_char_tab_type;
  l_old_val1              g_old_val;
  l_old_val2              g_old_val;
  l_old_val3              g_old_val;
  l_old_val4              g_old_val;
  l_old_val5              g_old_val;
  l_old_val6              g_old_val;
  l_new_val1              g_new_val;
  l_new_val2              g_new_val;
  l_new_val3              g_new_val;
  l_new_val4              g_new_val;
  l_new_val5              g_new_val;
  l_new_val6              g_new_val;
  l_tab_counter           binary_integer := 0;
  l_ini_tab_counter       binary_integer ;
  l_chg_eff_dt            date;
  l_count                 number;
  l_ext_chg_evt_log_id    number;
  l_object_version_number number;
--
  cursor c_lookup_value
    (p_lookup_type hr_lookups.lookup_type%type
    ,p_lookup_code hr_lookups.lookup_code%type
    )
  is
  select meaning
  from hr_lookups hl
  where hl.lookup_type = p_lookup_type
  and hl.lookup_code = p_lookup_code;

  cursor c_benefits_group(p_benfts_grp_id ben_benfts_grp.benfts_grp_id%type)
  is
  select name
  from ben_benfts_grp bbg
  where bbg.benfts_grp_id = p_benfts_grp_id;
--
  cursor c_relationship(p_person_id number) is
  SELECT pcr.contact_relationship_id,pcr.person_id
  FROM   per_contact_relationships pcr,
         hr_lookups hl
  WHERE  pcr.contact_person_id = p_person_id
  AND    pcr.contact_type = hl.lookup_code
  AND    hl.lookup_type = 'CONTACT';
  --
  cursor c_person_type(p_person_type_id number) is
  select ppt.system_person_type
  from   per_person_types ppt
  where  ppt.person_type_id = p_person_type_id;

  -- Get all the contact relationship person
  cursor c_con_relationship(p_person_id number , p_date date ) is
  SELECT pcr.contact_relationship_id, pcr.person_id,pcr.contact_type
  FROM   per_contact_relationships pcr
  WHERE  pcr.contact_person_id = p_person_id
  AND    pcr.personal_flag = 'Y'
  and    p_date between  pcr.date_start and nvl(pcr.date_end, p_date)
   ;




  l_old_marital_status        hr_lookups.meaning%type ;
  l_new_marital_status        hr_lookups.meaning%type ;
  l_old_sex                   hr_lookups.meaning%type ;
  l_new_sex                   hr_lookups.meaning%type ;
  l_old_disability_status     hr_lookups.meaning%type ;
  l_new_disability_status     hr_lookups.meaning%type ;
  l_old_benefits_group        ben_benfts_grp.name%type;
  l_new_benefits_group        ben_benfts_grp.name%type;
  l_old_student_status        hr_lookups.meaning%type ;
  l_new_student_status        hr_lookups.meaning%type ;
  l_old_ethnic_group          hr_lookups.meaning%type ;
  l_new_ethnic_group          hr_lookups.meaning%type ;
  l_relationship              per_all_people_f.person_id%type;
  l_contact                   per_contact_relationships.contact_relationship_id%type;
  l_person_type               per_person_types.system_person_type%type ;
--
  l_proc               varchar2(100) := 'ben_ext_chlg.log_per_chg';
--
begin
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
--
  if p_event = 'UPDATE' then
--
    if nvl(p_old_rec.national_identifier, '000-00-0000')
        <> nvl(p_new_rec.national_identifier, '000-00-0000') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COSS';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.national_identifier;
      l_new_val1(l_tab_counter) := p_new_rec.national_identifier;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
    end if;
    if nvl(p_old_rec.full_name, '$$$$$&&&')
        <> nvl(p_new_rec.full_name, '$$$$$&&&') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COUN';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := substr(p_old_rec.full_name,1,240);
      l_old_val2(l_tab_counter) := p_old_rec.title;
      l_old_val3(l_tab_counter) := p_old_rec.first_name;
      l_old_val4(l_tab_counter) := p_old_rec.middle_names;
      l_old_val5(l_tab_counter) := p_old_rec.last_name;
      l_old_val6(l_tab_counter) := p_old_rec.suffix;
      l_new_val1(l_tab_counter) := substr(p_new_rec.full_name,1,240);
      l_new_val2(l_tab_counter) := p_new_rec.title;
      l_new_val3(l_tab_counter) := p_new_rec.first_name;
      l_new_val4(l_tab_counter) := p_new_rec.middle_names;
      l_new_val5(l_tab_counter) := p_new_rec.last_name;
      l_new_val6(l_tab_counter) := p_new_rec.suffix;
    end if;
    if nvl(p_old_rec.first_name, '$$$$$&&&')
        <> nvl(p_new_rec.first_name, '$$$$$&&&') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COFN';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.first_name;
      l_new_val1(l_tab_counter) := p_new_rec.first_name;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
    end if;
    if nvl(p_old_rec.last_name, '$$$$$&&&')
        <> nvl(p_new_rec.last_name, '$$$$$&&&') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COLN';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.last_name;
      l_new_val1(l_tab_counter) := p_new_rec.last_name;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
    end if;
    if nvl(p_old_rec.middle_names, '$$$$$&&&')
        <> nvl(p_new_rec.middle_names, '$$$$$&&&') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COMN';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.middle_names;
      l_new_val1(l_tab_counter) := p_new_rec.middle_names;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
    end if;
    if nvl(p_old_rec.title, '$$$$$&&&')
        <> nvl(p_new_rec.title, '$$$$$&&&') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CONT';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.title;
      l_new_val1(l_tab_counter) := p_new_rec.title;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
    end if;
    if nvl(p_old_rec.suffix, '$$$$$&&&')
        <> nvl(p_new_rec.suffix, '$$$$$&&&') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CONS';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.suffix;
      l_new_val1(l_tab_counter) := p_new_rec.suffix;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
    end if;
    if nvl(p_old_rec.pre_name_adjunct, '$$$$$&&&')
        <> nvl(p_new_rec.pre_name_adjunct, '$$$$$&&&') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CONA';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.pre_name_adjunct;
      l_new_val1(l_tab_counter) := p_new_rec.pre_name_adjunct;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
    end if;
    if nvl(p_old_rec.known_as, '$$$$$&&&')
        <> nvl(p_new_rec.known_as, '$$$$$&&&') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COKA';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.known_as;
      l_new_val1(l_tab_counter) := p_new_rec.known_as;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
    end if;
    if nvl(p_old_rec.previous_last_name, '$$$$$&&&')
        <> nvl(p_new_rec.previous_last_name, '$$$$$&&&') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COPL';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.previous_last_name;
      l_new_val1(l_tab_counter) := p_new_rec.previous_last_name;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
    end if;
    if nvl(p_old_rec.date_of_birth, to_date('01/01/0001', 'dd/mm/yyyy'))
        <> nvl(p_new_rec.date_of_birth, to_date('01/01/0001', 'dd/mm/yyyy')) then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CODB';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := to_char(p_old_rec.date_of_birth, 'mm/dd/yyyy');
      l_new_val1(l_tab_counter) := to_char(p_new_rec.date_of_birth, 'mm/dd/yyyy');
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
    end if;
    if nvl(p_old_rec.date_of_death, to_date('01/01/0001', 'dd/mm/yyyy'))
        <> nvl(p_new_rec.date_of_death, to_date('01/01/0001', 'dd/mm/yyyy')) then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CODD';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := to_char(p_old_rec.date_of_death, 'mm/dd/yyyy');
      l_new_val1(l_tab_counter) := to_char(p_new_rec.date_of_death, 'mm/dd/yyyy');
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
    end if;
    if (nvl(p_old_rec.date_employee_data_verified, to_date('01/01/0001', 'dd/mm/yyyy'))
        <> nvl(p_new_rec.date_employee_data_verified, to_date('01/01/0001', 'dd/mm/yyyy')) or
        (p_old_rec.date_employee_data_verified is null and
         p_new_rec.date_employee_data_verified is not null) or
        (p_old_rec.date_employee_data_verified is not null and
         p_new_rec.date_employee_data_verified is null))  then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COPV';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := to_char(p_old_rec.date_employee_data_verified, 'mm/dd/yyyy');
      l_new_val1(l_tab_counter) := to_char(p_new_rec.date_employee_data_verified, 'mm/dd/yyyy');
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
    end if;
    if nvl(p_old_rec.marital_status, '$')
        <> nvl(p_new_rec.marital_status, '$') then
      -- read marital status from lookup table
      open c_lookup_value('MAR_STATUS', p_old_rec.marital_status);
      fetch c_lookup_value into l_old_marital_status;
      close c_lookup_value;
      open c_lookup_value('MAR_STATUS', p_new_rec.marital_status);
      fetch c_lookup_value into l_new_marital_status;
      close c_lookup_value;

      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COM';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := l_old_marital_status;
      l_new_val1(l_tab_counter) := l_new_marital_status;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
    end if;
    if nvl(p_old_rec.sex, '$')
        <> nvl(p_new_rec.sex, '$') then
      -- read gender from lookup table
      open c_lookup_value('SEX', p_old_rec.sex);
      fetch c_lookup_value into l_old_sex;
      close c_lookup_value;
      open c_lookup_value('SEX', p_new_rec.sex);
      fetch c_lookup_value into l_new_sex;
      close c_lookup_value;

      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COG';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := l_old_sex;
      l_new_val1(l_tab_counter) := l_new_sex;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
    end if;
    if nvl(p_old_rec.registered_disabled_flag, '$')
        <> nvl(p_new_rec.registered_disabled_flag, '$') then
      -- read disability status from lookup table
      open c_lookup_value('REGISTERED_DISABLED', p_old_rec.registered_disabled_flag);
      fetch c_lookup_value into l_old_disability_status;
      close c_lookup_value;
      open c_lookup_value('REGISTERED_DISABLED', p_new_rec.registered_disabled_flag);
      fetch c_lookup_value into l_new_disability_status;
      close c_lookup_value;

      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CODS';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := l_old_disability_status;
      l_new_val1(l_tab_counter) := l_new_disability_status;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
    end if;
    if nvl(p_old_rec.benefit_group_id, 1)
        <> nvl(p_new_rec.benefit_group_id, 1) then
      -- read old and new benefits group values
      open c_benefits_group(p_old_rec.benefit_group_id);
      fetch c_benefits_group into l_old_benefits_group;
      close c_benefits_group;
      open c_benefits_group(p_new_rec.benefit_group_id);
      fetch c_benefits_group into l_new_benefits_group;
      close c_benefits_group;

      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COBG';
      l_prmtr_01_tab(l_tab_counter) := p_old_rec.benefit_group_id;
      l_prmtr_02_tab(l_tab_counter) := p_new_rec.benefit_group_id;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := l_old_benefits_group;
      l_new_val1(l_tab_counter) := l_new_benefits_group;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
    end if;
    if nvl(p_old_rec.student_status, '$')
        <> nvl(p_new_rec.student_status, '$') then
      -- read student status from lookup table
      open c_lookup_value('STUDENT_STATUS', p_old_rec.student_status);
      fetch c_lookup_value into l_old_student_status;
      close c_lookup_value;
      open c_lookup_value('STUDENT_STATUS', p_new_rec.student_status);
      fetch c_lookup_value into l_new_student_status;
      close c_lookup_value;

      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COST';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := l_old_student_status;
      l_new_val1(l_tab_counter) := l_new_student_status;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
    end if;
    if nvl(p_old_rec.attribute1, '$')
        <> nvl(p_new_rec.attribute1, '$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COPF01';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.attribute1;
      l_new_val1(l_tab_counter) := p_new_rec.attribute1;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
    end if;
    if nvl(p_old_rec.attribute2, '$')
        <> nvl(p_new_rec.attribute2, '$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COPF02';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.attribute2;
      l_new_val1(l_tab_counter) := p_new_rec.attribute2;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
    end if;
    if nvl(p_old_rec.attribute3, '$')
        <> nvl(p_new_rec.attribute3, '$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COPF03';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.attribute3;
      l_new_val1(l_tab_counter) := p_new_rec.attribute3;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
    end if;
    if nvl(p_old_rec.attribute4, '$')
        <> nvl(p_new_rec.attribute4, '$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COPF04';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.attribute4;
      l_new_val1(l_tab_counter) := p_new_rec.attribute4;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
    end if;
    if nvl(p_old_rec.attribute5, '$')
        <> nvl(p_new_rec.attribute5, '$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COPF05';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.attribute5;
      l_new_val1(l_tab_counter) := p_new_rec.attribute5;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
    end if;
    if nvl(p_old_rec.attribute6, '$')
        <> nvl(p_new_rec.attribute6, '$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COPF06';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.attribute6;
      l_new_val1(l_tab_counter) := p_new_rec.attribute6;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
    end if;
    if nvl(p_old_rec.attribute7, '$')
        <> nvl(p_new_rec.attribute7, '$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COPF07';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.attribute7;
      l_new_val1(l_tab_counter) := p_new_rec.attribute7;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
    end if;
    if nvl(p_old_rec.attribute8, '$')
        <> nvl(p_new_rec.attribute8, '$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COPF08';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.attribute8;
      l_new_val1(l_tab_counter) := p_new_rec.attribute8;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
    end if;
    if nvl(p_old_rec.attribute9, '$')
        <> nvl(p_new_rec.attribute9, '$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COPF09';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.attribute9;
      l_new_val1(l_tab_counter) := p_new_rec.attribute9;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
    end if;
    if nvl(p_old_rec.attribute10, '$')
        <> nvl(p_new_rec.attribute10, '$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COPF10';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.attribute10;
      l_new_val1(l_tab_counter) := p_new_rec.attribute10;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
    end if;
    if nvl(p_old_rec.email_address, '$')
        <> nvl(p_new_rec.email_address, '$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COEA';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := substr(p_old_rec.email_address,1,240);
      l_new_val1(l_tab_counter) := substr(p_new_rec.email_address,1,240);
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
    end if;
    if nvl(p_old_rec.per_information10, '$')
        <> nvl(p_new_rec.per_information10, '$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CCOPMD';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.per_information10;
      l_new_val1(l_tab_counter) := p_new_rec.per_information10;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
    end if;
    if nvl(p_old_rec.per_information1, '$')
        <> nvl(p_new_rec.per_information1, '$') then

       -- read ethnic group from lookup table
      open c_lookup_value('US_ETHNIC_GROUP', p_old_rec.per_information1);
      fetch c_lookup_value into l_old_ethnic_group;
      close c_lookup_value;
      open c_lookup_value('US_ETHNIC_GROUP', p_new_rec.per_information1);
      fetch c_lookup_value into l_new_ethnic_group;
      close c_lookup_value;
      ---

      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CETHORG';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := l_old_ethnic_group;
      l_new_val1(l_tab_counter) := l_new_ethnic_group;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
    end if;
    if nvl(p_old_rec.correspondence_language, '$')
        <> nvl(p_new_rec.correspondence_language, '$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CLANG';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.correspondence_language;
      l_new_val1(l_tab_counter) := p_new_rec.correspondence_language;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
    end if;

    if nvl(p_old_rec.uses_tobacco_flag, '$')
        <> nvl(p_new_rec.uses_tobacco_flag, '$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CTOBAC';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.uses_tobacco_flag;
      l_new_val1(l_tab_counter) := p_new_rec.uses_tobacco_flag;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
    end if;



    if nvl(p_old_rec.employee_number, '$')
        <> nvl(p_new_rec.employee_number, '$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COEN';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.employee_number;
      l_new_val1(l_tab_counter) := p_new_rec.employee_number;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
    end if;

  end if;
  for l_count in 1..l_chg_evt_tab.count loop
   if change_event_is_enabled(l_chg_evt_tab(l_count),p_new_rec.effective_start_date) then
    ben_ext_chg_evt_api.create_ext_chg_evt
    (p_validate                    => FALSE
    ,p_ext_chg_evt_log_id          => l_ext_chg_evt_log_id
    ,p_chg_evt_cd                  => l_chg_evt_tab(l_count)
    ,p_chg_eff_dt                  => p_new_rec.effective_start_date
    ,p_prmtr_01                    => l_prmtr_01_tab(l_count)
    ,p_prmtr_02                    => l_prmtr_02_tab(l_count)
    ,p_prmtr_03                    => l_prmtr_03_tab(l_count)
    ,p_prmtr_04                    => l_prmtr_04_tab(l_count)
    ,p_prmtr_05                    => l_prmtr_05_tab(l_count)
    ,p_prmtr_06                    => l_prmtr_06_tab(l_count)
    ,p_prmtr_07                    => l_prmtr_07_tab(l_count)
    ,p_prmtr_10                    => p_new_rec.update_mode
    ,p_person_id                   => p_new_rec.person_id
    ,p_business_group_id           => p_new_rec.business_group_id
    ,p_object_version_number       => l_object_version_number
    ,p_effective_date              => p_new_rec.effective_start_date
    ,p_old_val1                    => l_old_val1(l_count)
    ,p_old_val2                    => l_old_val2(l_count)
    ,p_old_val3                    => l_old_val3(l_count)
    ,p_old_val4                    => l_old_val4(l_count)
    ,p_old_val5                    => l_old_val5(l_count)
    ,p_old_val6                    => l_old_val6(l_count)
    ,p_new_val1                    => l_new_val1(l_count)
    ,p_new_val2                    => l_new_val2(l_count)
    ,p_new_val3                    => l_new_val3(l_count)
    ,p_new_val4                    => l_new_val4(l_count)
    ,p_new_val5                    => l_new_val5(l_count)
    ,p_new_val6                    => l_new_val6(l_count)
    );
   end if;
  end loop;
  --
  --for contact data change
  -- For contact there will be two type og log will  be created
  -- only when the person type is contact - this is old one and maintained for backwdrd compatibility
  -- aonther one for all the contact person regardless of person type - this is new one

  open c_relationship(p_new_rec.person_id);
  fetch c_relationship into l_contact,l_relationship;
  if c_relationship%notfound then
    close c_relationship;
  elsif c_relationship%found then
      close c_relationship;
      open c_person_type(p_new_rec.person_type_id);
      fetch c_person_type into l_person_type;
      if c_person_type%notfound then
        close c_person_type;
      else
        if l_person_type = 'OTHER' then
           close c_person_type;
           l_ini_tab_counter := l_tab_counter;
          if nvl(p_old_rec.full_name, '$$$$$&&&')
             <> nvl(p_new_rec.full_name, '$$$$$&&&') then
             l_tab_counter := l_tab_counter + 1;
             l_cont_chg_evt_tab(l_tab_counter) := 'CCFN';
             l_prmtr_01_tab(l_tab_counter) := null;
             l_prmtr_02_tab(l_tab_counter) := null;
             l_prmtr_03_tab(l_tab_counter) := null;
             l_prmtr_04_tab(l_tab_counter) := null;
             l_prmtr_05_tab(l_tab_counter) := null;
             l_prmtr_06_tab(l_tab_counter) := null;
             l_prmtr_07_tab(l_tab_counter) := null;
             l_old_val1(l_tab_counter) := substr(p_old_rec.full_name,1,240);
             l_old_val2(l_tab_counter) := p_old_rec.title;
             l_old_val3(l_tab_counter) := p_old_rec.first_name;
             l_old_val4(l_tab_counter) := p_old_rec.middle_names;
             l_old_val5(l_tab_counter) := p_old_rec.last_name;
             l_old_val6(l_tab_counter) := p_old_rec.suffix;
             l_new_val1(l_tab_counter) := substr(p_new_rec.full_name,1,240);
             l_new_val2(l_tab_counter) := p_new_rec.title;
             l_new_val3(l_tab_counter) := p_new_rec.first_name;
             l_new_val4(l_tab_counter) := p_new_rec.middle_names;
             l_new_val5(l_tab_counter) := p_new_rec.last_name;
             l_new_val6(l_tab_counter) := p_new_rec.suffix;
          end if;
          if nvl(p_old_rec.date_of_birth, to_date('01/01/0001', 'dd/mm/yyyy'))
             <> nvl(p_new_rec.date_of_birth, to_date('01/01/0001', 'dd/mm/yyyy')) then
             l_tab_counter := l_tab_counter + 1;
             l_cont_chg_evt_tab(l_tab_counter) := 'CCDB';
             l_prmtr_01_tab(l_tab_counter) := null;
             l_prmtr_02_tab(l_tab_counter) := null;
             l_prmtr_03_tab(l_tab_counter) := null;
             l_prmtr_04_tab(l_tab_counter) := null;
             l_prmtr_05_tab(l_tab_counter) := null;
             l_prmtr_06_tab(l_tab_counter) := null;
             l_prmtr_07_tab(l_tab_counter) := null;
             l_old_val1(l_tab_counter) := substr(p_new_rec.full_name,1,240);
             l_new_val1(l_tab_counter) := substr(p_new_rec.full_name,1,240);
             l_old_val2(l_tab_counter) := to_char(p_old_rec.date_of_birth, 'mm/dd/yyyy');
             l_new_val2(l_tab_counter) := to_char(p_new_rec.date_of_birth, 'mm/dd/yyyy');
             l_old_val3(l_tab_counter) := null;
             l_old_val4(l_tab_counter) := null;
             l_old_val5(l_tab_counter) := null;
             l_old_val6(l_tab_counter) := null;
             l_new_val3(l_tab_counter) := null;
             l_new_val4(l_tab_counter) := null;
             l_new_val5(l_tab_counter) := null;
             l_new_val6(l_tab_counter) := null;
          end if;
          if nvl(p_old_rec.date_of_death, to_date('01/01/0001', 'dd/mm/yyyy'))
             <> nvl(p_new_rec.date_of_death, to_date('01/01/0001', 'dd/mm/yyyy')) then
             l_tab_counter := l_tab_counter + 1;
             l_cont_chg_evt_tab(l_tab_counter) := 'CCDD';
             l_prmtr_01_tab(l_tab_counter) := null;
             l_prmtr_02_tab(l_tab_counter) := null;
             l_prmtr_03_tab(l_tab_counter) := null;
             l_prmtr_04_tab(l_tab_counter) := null;
             l_prmtr_05_tab(l_tab_counter) := null;
             l_prmtr_06_tab(l_tab_counter) := null;
             l_prmtr_07_tab(l_tab_counter) := null;
             l_old_val1(l_tab_counter) := substr(p_new_rec.full_name,1,240);
             l_new_val1(l_tab_counter) := substr(p_new_rec.full_name,1,240);
             l_old_val2(l_tab_counter) := to_char(p_old_rec.date_of_death, 'mm/dd/yyyy');
             l_new_val2(l_tab_counter) := to_char(p_new_rec.date_of_death, 'mm/dd/yyyy');
             l_old_val3(l_tab_counter) := null;
             l_old_val4(l_tab_counter) := null;
             l_old_val5(l_tab_counter) := null;
             l_old_val6(l_tab_counter) := null;
             l_new_val3(l_tab_counter) := null;
             l_new_val4(l_tab_counter) := null;
             l_new_val5(l_tab_counter) := null;
             l_new_val6(l_tab_counter) := null;
          end if;
          if nvl(p_old_rec.national_identifier, '000-00-0000')
             <> nvl(p_new_rec.national_identifier, '000-00-0000') then
             l_tab_counter := l_tab_counter + 1;
             l_cont_chg_evt_tab(l_tab_counter) := 'CCSS';
             l_prmtr_01_tab(l_tab_counter) := null;
             l_prmtr_02_tab(l_tab_counter) := null;
             l_prmtr_03_tab(l_tab_counter) := null;
             l_prmtr_04_tab(l_tab_counter) := null;
             l_prmtr_05_tab(l_tab_counter) := null;
             l_prmtr_06_tab(l_tab_counter) := null;
             l_prmtr_07_tab(l_tab_counter) := null;
             l_old_val1(l_tab_counter) := substr(p_new_rec.full_name,1,240);
             l_new_val1(l_tab_counter) := substr(p_new_rec.full_name,1,240);
             l_old_val2(l_tab_counter) := p_old_rec.national_identifier;
             l_new_val2(l_tab_counter) := p_new_rec.national_identifier;
             l_old_val3(l_tab_counter) := null;
             l_old_val4(l_tab_counter) := null;
             l_old_val5(l_tab_counter) := null;
             l_old_val6(l_tab_counter) := null;
             l_new_val3(l_tab_counter) := null;
             l_new_val4(l_tab_counter) := null;
             l_new_val5(l_tab_counter) := null;
             l_new_val6(l_tab_counter) := null;
          end if;
          if nvl(p_old_rec.sex, '$')
             <> nvl(p_new_rec.sex, '$') then
             -- read gender from lookup table
             open c_lookup_value('SEX', p_old_rec.sex);
             fetch c_lookup_value into l_old_sex;
             close c_lookup_value;
             open c_lookup_value('SEX', p_new_rec.sex);
             fetch c_lookup_value into l_new_sex;
             close c_lookup_value;

             l_tab_counter := l_tab_counter + 1;
             l_cont_chg_evt_tab(l_tab_counter) := 'CCGE';
             l_prmtr_01_tab(l_tab_counter) := null;
             l_prmtr_02_tab(l_tab_counter) := null;
             l_prmtr_03_tab(l_tab_counter) := null;
             l_prmtr_04_tab(l_tab_counter) := null;
             l_prmtr_05_tab(l_tab_counter) := null;
             l_prmtr_06_tab(l_tab_counter) := null;
             l_prmtr_07_tab(l_tab_counter) := null;
             l_old_val1(l_tab_counter) := substr(p_new_rec.full_name,1,240);
             l_new_val1(l_tab_counter) := substr(p_new_rec.full_name,1,240);
             l_old_val2(l_tab_counter) := l_old_sex;
             l_new_val2(l_tab_counter) := l_new_sex;
             l_old_val3(l_tab_counter) := null;
             l_old_val4(l_tab_counter) := null;
             l_old_val5(l_tab_counter) := null;
             l_old_val6(l_tab_counter) := null;
             l_new_val3(l_tab_counter) := null;
             l_new_val4(l_tab_counter) := null;
             l_new_val5(l_tab_counter) := null;
             l_new_val6(l_tab_counter) := null;
          end if;
          for l_count in l_ini_tab_counter+1..l_ini_tab_counter+l_cont_chg_evt_tab.count loop
              if change_event_is_enabled(l_cont_chg_evt_tab(l_count),p_new_rec.effective_start_date)
                 then

                 ben_ext_chg_evt_api.create_ext_chg_evt
                 (p_validate                    => FALSE
                 ,p_ext_chg_evt_log_id          => l_ext_chg_evt_log_id
                 ,p_chg_evt_cd                  => l_cont_chg_evt_tab(l_count)
                 ,p_chg_eff_dt                  => p_new_rec.effective_start_date
                 ,p_prmtr_01                    => to_char(l_contact)
                 ,p_prmtr_02                    => l_prmtr_02_tab(l_count)
                 ,p_prmtr_03                    => l_prmtr_03_tab(l_count)
                 ,p_prmtr_04                    => l_prmtr_04_tab(l_count)
                 ,p_prmtr_05                    => l_prmtr_05_tab(l_count)
                 ,p_prmtr_06                    => to_char(p_new_rec.person_id)
                 ,p_prmtr_07                    => l_prmtr_07_tab(l_count)
                 ,p_prmtr_10                    => p_new_rec.update_mode
                 ,p_person_id                   => l_relationship
                 ,p_business_group_id           => p_new_rec.business_group_id
                 ,p_object_version_number       => l_object_version_number
                 ,p_effective_date              => p_new_rec.effective_start_date
                 ,p_old_val1                    => l_old_val1(l_count)
                 ,p_old_val2                    => l_old_val2(l_count)
                 ,p_old_val3                    => l_old_val3(l_count)
                 ,p_old_val4                    => l_old_val4(l_count)
                 ,p_old_val5                    => l_old_val5(l_count)
                 ,p_old_val6                    => l_old_val6(l_count)
                 ,p_new_val1                    => l_new_val1(l_count)
                 ,p_new_val2                    => l_new_val2(l_count)
                 ,p_new_val3                    => l_new_val3(l_count)
                 ,p_new_val4                    => l_new_val4(l_count)
                 ,p_new_val5                    => l_new_val5(l_count)
                 ,p_new_val6                    => l_new_val6(l_count)
                 );
              end if;
          end loop;
       end if;
       ------

    end if;

    -- the counter logic changed here, cause the person id may change for every row

    open c_con_relationship(p_new_rec.person_id , p_new_rec.effective_start_date );
    Loop
       fetch c_con_relationship into l_contact,l_relationship , l_person_type ;
       Exit When  c_con_relationship%notfound ;
       hr_utility.set_location ( 'Contact person ' || l_relationship , 11 ) ;
       hr_utility.set_location ( 'relation type ' || l_person_type , 11 ) ;
       l_ini_tab_counter :=  1 ;
       l_tab_counter     :=  0 ;
       l_cont_chg_evt_tab.delete   ;

       if nvl(p_old_rec.full_name, '$$$$$&&&')
          <> nvl(p_new_rec.full_name, '$$$$$&&&') then
          l_tab_counter := l_tab_counter + 1;
          l_cont_chg_evt_tab(l_tab_counter) := 'CCNFN';
          l_prmtr_01_tab(l_tab_counter) := l_contact;
          l_prmtr_02_tab(l_tab_counter) := l_person_type;
          l_prmtr_03_tab(l_tab_counter) := null;
          l_prmtr_04_tab(l_tab_counter) := null;
          l_prmtr_05_tab(l_tab_counter) := null;
          l_prmtr_06_tab(l_tab_counter) := null;
          l_prmtr_07_tab(l_tab_counter) := null;
          l_old_val1(l_tab_counter) := substr(p_old_rec.full_name,1,240);
          l_old_val2(l_tab_counter) := p_old_rec.title;
          l_old_val3(l_tab_counter) := p_old_rec.first_name;
          l_old_val4(l_tab_counter) := p_old_rec.middle_names;
          l_old_val5(l_tab_counter) := p_old_rec.last_name;
          l_old_val6(l_tab_counter) := p_old_rec.suffix;
          l_new_val1(l_tab_counter) := substr(p_new_rec.full_name,1,240);
          l_new_val2(l_tab_counter) := p_new_rec.title;
          l_new_val3(l_tab_counter) := p_new_rec.first_name;
          l_new_val4(l_tab_counter) := p_new_rec.middle_names;
          l_new_val5(l_tab_counter) := p_new_rec.last_name;
          l_new_val6(l_tab_counter) := p_new_rec.suffix;
       end if;
       if nvl(p_old_rec.date_of_birth, to_date('01/01/0001', 'dd/mm/yyyy'))
          <> nvl(p_new_rec.date_of_birth, to_date('01/01/0001', 'dd/mm/yyyy')) then
          l_tab_counter := l_tab_counter + 1;
          l_cont_chg_evt_tab(l_tab_counter) := 'CCNDB';
          l_prmtr_01_tab(l_tab_counter) := l_contact;
          l_prmtr_02_tab(l_tab_counter) := l_person_type;
          l_prmtr_03_tab(l_tab_counter) := null;
          l_prmtr_04_tab(l_tab_counter) := null;
          l_prmtr_05_tab(l_tab_counter) := null;
          l_prmtr_06_tab(l_tab_counter) := null;
          l_prmtr_07_tab(l_tab_counter) := null;
          l_old_val1(l_tab_counter) := substr(p_new_rec.full_name,1,240);
          l_new_val1(l_tab_counter) := substr(p_new_rec.full_name,1,240);
          l_old_val2(l_tab_counter) := to_char(p_old_rec.date_of_birth, 'mm/dd/yyyy');
          l_new_val2(l_tab_counter) := to_char(p_new_rec.date_of_birth, 'mm/dd/yyyy');
          l_old_val3(l_tab_counter) := null;
          l_old_val4(l_tab_counter) := null;
          l_old_val5(l_tab_counter) := null;
          l_old_val6(l_tab_counter) := null;
          l_new_val3(l_tab_counter) := null;
          l_new_val4(l_tab_counter) := null;
          l_new_val5(l_tab_counter) := null;
          l_new_val6(l_tab_counter) := null;
       end if;
       if nvl(p_old_rec.date_of_death, to_date('01/01/0001', 'dd/mm/yyyy'))
          <> nvl(p_new_rec.date_of_death, to_date('01/01/0001', 'dd/mm/yyyy')) then
          l_tab_counter := l_tab_counter + 1;
          l_cont_chg_evt_tab(l_tab_counter) := 'CCNDD';
          l_prmtr_01_tab(l_tab_counter) := l_contact;
          l_prmtr_02_tab(l_tab_counter) := l_person_type;
          l_prmtr_03_tab(l_tab_counter) := null;
          l_prmtr_04_tab(l_tab_counter) := null;
          l_prmtr_05_tab(l_tab_counter) := null;
          l_prmtr_06_tab(l_tab_counter) := null;
          l_prmtr_07_tab(l_tab_counter) := null;
          l_old_val1(l_tab_counter) := substr(p_new_rec.full_name,1,240);
          l_new_val1(l_tab_counter) := substr(p_new_rec.full_name,1,240);
          l_old_val2(l_tab_counter) := to_char(p_old_rec.date_of_death, 'mm/dd/yyyy');
          l_new_val2(l_tab_counter) := to_char(p_new_rec.date_of_death, 'mm/dd/yyyy');
          l_old_val3(l_tab_counter) := null;
          l_old_val4(l_tab_counter) := null;
          l_old_val5(l_tab_counter) := null;
          l_old_val6(l_tab_counter) := null;
          l_new_val3(l_tab_counter) := null;
          l_new_val4(l_tab_counter) := null;
          l_new_val5(l_tab_counter) := null;
          l_new_val6(l_tab_counter) := null;
       end if;
       if nvl(p_old_rec.national_identifier, '000-00-0000')
          <> nvl(p_new_rec.national_identifier, '000-00-0000') then
          l_tab_counter := l_tab_counter + 1;
          l_cont_chg_evt_tab(l_tab_counter) := 'CCNSS';
          l_prmtr_01_tab(l_tab_counter) := l_contact;
          l_prmtr_02_tab(l_tab_counter) := l_person_type;
          l_prmtr_03_tab(l_tab_counter) := null;
          l_prmtr_04_tab(l_tab_counter) := null;
          l_prmtr_05_tab(l_tab_counter) := null;
          l_prmtr_06_tab(l_tab_counter) := null;
          l_prmtr_07_tab(l_tab_counter) := null;
          l_old_val1(l_tab_counter) := substr(p_new_rec.full_name,1,240);
          l_new_val1(l_tab_counter) := substr(p_new_rec.full_name,1,240);
          l_old_val2(l_tab_counter) := p_old_rec.national_identifier;
          l_new_val2(l_tab_counter) := p_new_rec.national_identifier;
          l_old_val3(l_tab_counter) := null;
          l_old_val4(l_tab_counter) := null;
          l_old_val5(l_tab_counter) := null;
          l_old_val6(l_tab_counter) := null;
          l_new_val3(l_tab_counter) := null;
          l_new_val4(l_tab_counter) := null;
          l_new_val5(l_tab_counter) := null;
          l_new_val6(l_tab_counter) := null;
       end if;
       if nvl(p_old_rec.sex, '$')
          <> nvl(p_new_rec.sex, '$') then
          -- read gender from lookup table
          open c_lookup_value('SEX', p_old_rec.sex);
          fetch c_lookup_value into l_old_sex;
          close c_lookup_value;
          open c_lookup_value('SEX', p_new_rec.sex);
          fetch c_lookup_value into l_new_sex;
          close c_lookup_value;

          l_tab_counter := l_tab_counter + 1;
          l_cont_chg_evt_tab(l_tab_counter) := 'CCNGE';
          l_prmtr_01_tab(l_tab_counter) := l_contact;
          l_prmtr_02_tab(l_tab_counter) := l_person_type;
          l_prmtr_03_tab(l_tab_counter) := null;
          l_prmtr_04_tab(l_tab_counter) := null;
          l_prmtr_05_tab(l_tab_counter) := null;
          l_prmtr_06_tab(l_tab_counter) := null;
          l_prmtr_07_tab(l_tab_counter) := null;
          l_old_val1(l_tab_counter) := substr(p_new_rec.full_name,1,240);
          l_new_val1(l_tab_counter) := substr(p_new_rec.full_name,1,240);
          l_old_val2(l_tab_counter) := l_old_sex;
          l_new_val2(l_tab_counter) := l_new_sex;
          l_old_val3(l_tab_counter) := null;
          l_old_val4(l_tab_counter) := null;
          l_old_val5(l_tab_counter) := null;
          l_old_val6(l_tab_counter) := null;
          l_new_val3(l_tab_counter) := null;
          l_new_val4(l_tab_counter) := null;
          l_new_val5(l_tab_counter) := null;
          l_new_val6(l_tab_counter) := null;
       end if;
       -- insert the row for every relation , the person id may change for every row
       for l_count in 1  .. l_tab_counter  loop

           hr_utility.set_location ( ' change event  ' || l_cont_chg_evt_tab(l_count)  , 11 ) ;
           if change_event_is_enabled(l_cont_chg_evt_tab(l_count),p_new_rec.effective_start_date)
              then

              ben_ext_chg_evt_api.create_ext_chg_evt
                 (p_validate                    => FALSE
                 ,p_ext_chg_evt_log_id          => l_ext_chg_evt_log_id
                 ,p_chg_evt_cd                  => l_cont_chg_evt_tab(l_count)
                 ,p_chg_eff_dt                  => p_new_rec.effective_start_date
                 ,p_prmtr_01                    => l_prmtr_01_tab(l_count)
                 ,p_prmtr_02                    => l_prmtr_02_tab(l_count)
                 ,p_prmtr_03                    => l_prmtr_03_tab(l_count)
                 ,p_prmtr_04                    => l_prmtr_04_tab(l_count)
                 ,p_prmtr_05                    => l_prmtr_05_tab(l_count)
                 ,p_prmtr_06                    => to_char(p_new_rec.person_id)
                 ,p_prmtr_07                    => l_prmtr_07_tab(l_count)
                 ,p_prmtr_10                    => p_new_rec.update_mode
                 ,p_person_id                   => l_relationship
                 ,p_business_group_id           => p_new_rec.business_group_id
                 ,p_object_version_number       => l_object_version_number
                 ,p_effective_date              => p_new_rec.effective_start_date
                 ,p_old_val1                    => l_old_val1(l_count)
                 ,p_old_val2                    => l_old_val2(l_count)
                 ,p_old_val3                    => l_old_val3(l_count)
                 ,p_old_val4                    => l_old_val4(l_count)
                 ,p_old_val5                    => l_old_val5(l_count)
                 ,p_old_val6                    => l_old_val6(l_count)
                 ,p_new_val1                    => l_new_val1(l_count)
                 ,p_new_val2                    => l_new_val2(l_count)
                 ,p_new_val3                    => l_new_val3(l_count)
                 ,p_new_val4                    => l_new_val4(l_count)
                 ,p_new_val5                    => l_new_val5(l_count)
                 ,p_new_val6                    => l_new_val6(l_count)
                 );
           end if;
       end loop;

    End Loop ;
    close c_con_relationship ;
    ----
 end if;
--
  hr_utility.set_location('Exiting:'|| l_proc, 99);
--
end log_per_chg;
--
procedure log_cont_chg
          (
           p_old_rec   in  g_cont_rec_type
          ,p_new_rec   in  g_cont_rec_type
          ) is
   --
  l_proc               varchar2(100) := 'ben_ext_chlg.log_cont_chg';
  l_tab_counter        binary_integer := 0;
  l_old_contact_type                   varchar2(100) ;
  l_new_contact_type                   varchar2(100) ;
  l_person_type                        per_person_types.system_person_type%type;
  l_full_name                          per_all_people_f.full_name%type ;
  l_chg_evt_tab           g_char_tab_type;
  l_chg_eff_tab           g_date_tab_type;
  l_prmtr_01_tab          g_char_tab_type;
  l_prmtr_02_tab          g_char_tab_type;
  l_prmtr_03_tab          g_char_tab_type;
  l_prmtr_04_tab          g_char_tab_type;
  l_prmtr_05_tab          g_char_tab_type;
  l_prmtr_06_tab          g_char_tab_type;
  l_prmtr_07_tab          g_char_tab_type;
  l_old_val1              g_old_val;
  l_old_val2              g_old_val;
  l_old_val3              g_old_val;
  l_old_val4              g_old_val;
  l_old_val5              g_old_val;
  l_old_val6              g_old_val;
  l_new_val1              g_new_val;
  l_new_val2              g_new_val;
  l_new_val3              g_new_val;
  l_new_val4              g_new_val;
  l_new_val5              g_new_val;
  l_new_val6              g_new_val;
  l_chg_eff_dt            date;
  l_count                 number;
  l_ext_chg_evt_log_id    number;
  l_object_version_number number;
  --
  cursor c_person_type(p_person_id number) is
  select ppt.system_person_type,ppf.full_name
  from   per_person_types ppt,per_all_people_f ppf
  where  ppf.person_type_id = ppt.person_type_id
  and    ppf.person_id = p_person_id;
  --
  cursor c_lookup_value
    (p_lookup_code hr_lookups.lookup_code%type
    )
  is
  select meaning
  from hr_lookups hl
  where hl.lookup_type = 'CONTACT'
  and hl.lookup_code = p_lookup_code;
begin
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
--
  open c_person_type(p_new_rec.contact_person_id);
  fetch c_person_type into l_person_type,l_full_name;
  if c_person_type%notfound then
     close c_person_type;
  else

     close c_person_type;
     open c_lookup_value( p_old_rec.contact_type);
     fetch c_lookup_value into l_old_contact_type;
     close c_lookup_value;
     hr_utility.set_location ( 'old contact  ' || l_old_contact_type,99) ;
     open c_lookup_value( p_new_rec.contact_type);
     fetch c_lookup_value into l_new_contact_type;
     close c_lookup_value;
     hr_utility.set_location ( 'new contact  ' || l_new_contact_type,99) ;

     if l_person_type = 'OTHER' then
        l_tab_counter := l_tab_counter + 1;

        hr_utility.set_location ( 'change evnt ' ,99) ;
        --
        -- Handle web case where date_start is null
        --
        l_chg_evt_tab(l_tab_counter) := 'CCRE';
        l_chg_eff_tab(l_tab_counter) := nvl(p_new_rec.date_start,sysdate);
        l_prmtr_01_tab(l_tab_counter) := null;
        l_prmtr_02_tab(l_tab_counter) := null;
        l_prmtr_03_tab(l_tab_counter) := null;
        l_prmtr_04_tab(l_tab_counter) := null;
        l_prmtr_05_tab(l_tab_counter) := null;
        l_prmtr_06_tab(l_tab_counter) := null;
        l_prmtr_07_tab(l_tab_counter) := null;
        l_old_val1(l_tab_counter) := substr(l_full_name,1,240);
        l_new_val1(l_tab_counter) := substr(l_full_name,1,240);
        l_old_val2(l_tab_counter) := l_old_contact_type;
        l_new_val2(l_tab_counter) := l_new_contact_type;
        l_old_val3(l_tab_counter) := null;
        l_old_val4(l_tab_counter) := null;
        l_old_val5(l_tab_counter) := null;
        l_old_val6(l_tab_counter) := null;
        l_new_val3(l_tab_counter) := null;
        l_new_val4(l_tab_counter) := null;
        l_new_val5(l_tab_counter) := null;
        l_new_val6(l_tab_counter) := null;
     end if ;
     --- for every person contact changes
     l_tab_counter := l_tab_counter + 1;

     hr_utility.set_location ( 'change evnt ' ,99) ;
     --
     -- Handle web case where date_start is null
     --
     l_chg_evt_tab(l_tab_counter) := 'CCNRE';
     l_chg_eff_tab(l_tab_counter) := nvl(p_new_rec.date_start,sysdate);
     l_prmtr_01_tab(l_tab_counter) := null;
     l_prmtr_02_tab(l_tab_counter) := null;
     l_prmtr_03_tab(l_tab_counter) := null;
     l_prmtr_04_tab(l_tab_counter) := null;
     l_prmtr_05_tab(l_tab_counter) := null;
     l_prmtr_06_tab(l_tab_counter) := null;
     l_prmtr_07_tab(l_tab_counter) := null;
     l_old_val1(l_tab_counter) := substr(l_full_name,1,240);
     l_new_val1(l_tab_counter) := substr(l_full_name,1,240);
     l_old_val2(l_tab_counter) := l_old_contact_type;
     l_new_val2(l_tab_counter) := l_new_contact_type;
     l_old_val3(l_tab_counter) := null;
     l_old_val4(l_tab_counter) := null;
     l_old_val5(l_tab_counter) := null;
     l_old_val6(l_tab_counter) := null;
     l_new_val3(l_tab_counter) := null;
     l_new_val4(l_tab_counter) := null;
     l_new_val5(l_tab_counter) := null;
     l_new_val6(l_tab_counter) := null;

  end if;
  for l_count in 1..l_chg_evt_tab.count loop
    if change_event_is_enabled(l_chg_evt_tab(l_count),trunc(sysdate)) then
       hr_utility.set_location ( 'calling api ' ,99) ;
       ben_ext_chg_evt_api.create_ext_chg_evt
        (p_validate                    => FALSE
        ,p_ext_chg_evt_log_id          => l_ext_chg_evt_log_id
        ,p_chg_evt_cd                  => l_chg_evt_tab(l_count)
        ,p_chg_eff_dt                  => l_chg_eff_tab(l_count)
        ,p_prmtr_01                    => l_prmtr_01_tab(l_count)
        ,p_prmtr_02                    => l_prmtr_02_tab(l_count)
        ,p_prmtr_03                    => l_prmtr_03_tab(l_count)
        ,p_prmtr_04                    => l_prmtr_04_tab(l_count)
        ,p_prmtr_05                    => l_prmtr_05_tab(l_count)
        ,p_prmtr_06                    => l_prmtr_06_tab(l_count)
        ,p_prmtr_07                    => l_prmtr_07_tab(l_count)
        ,p_person_id                   => p_new_rec.person_id
        ,p_business_group_id           => p_new_rec.business_group_id
        ,p_object_version_number       => l_object_version_number
        ,p_effective_date              => trunc(sysdate)
        ,p_old_val1                    => l_old_val1(l_count)
        ,p_old_val2                    => l_old_val2(l_count)
        ,p_old_val3                    => l_old_val3(l_count)
        ,p_old_val4                    => l_old_val4(l_count)
        ,p_old_val5                    => l_old_val5(l_count)
        ,p_old_val6                    => l_old_val6(l_count)
        ,p_new_val1                    => l_new_val1(l_count)
        ,p_new_val2                    => l_new_val2(l_count)
        ,p_new_val3                    => l_new_val3(l_count)
        ,p_new_val4                    => l_new_val4(l_count)
        ,p_new_val5                    => l_new_val5(l_count)
        ,p_new_val6                    => l_new_val6(l_count)
        );
    end if;
 end loop;
--
 hr_utility.set_location('Exiting:'|| l_proc, 99);
--
end log_cont_chg;
--
procedure log_add_chg
          (p_event       in  varchar2
          ,p_old_rec   in  g_add_rec_type
          ,p_new_rec   in  g_add_rec_type
          ) is
   --
   l_proc               varchar2(100) := 'ben_ext_chlg.log_add_chg';
   --
  l_chg_evt_tab           g_char_tab_type;
  l_chg_eff_tab           g_date_tab_type;
  l_prmtr_01_tab          g_char_tab_type;
  l_prmtr_02_tab          g_char_tab_type;
  l_prmtr_03_tab          g_char_tab_type;
  l_prmtr_04_tab          g_char_tab_type;
  l_prmtr_05_tab          g_char_tab_type;
  l_prmtr_06_tab          g_char_tab_type;
  l_prmtr_07_tab          g_char_tab_type;
  l_old_val1              g_old_val;
  l_old_val2              g_old_val;
  l_old_val3              g_old_val;
  l_old_val4              g_old_val;
  l_old_val5              g_old_val;
  l_old_val6              g_old_val;
  l_new_val1              g_new_val;
  l_new_val2              g_new_val;
  l_new_val3              g_new_val;
  l_new_val4              g_new_val;
  l_new_val5              g_new_val;
  l_new_val6              g_new_val;
  l_tab_counter           binary_integer := 0;
  l_ini_tab_counter       binary_integer ;
  l_chg_eff_dt            date;
  l_chg_occured           boolean := FALSE;
  l_chg_mail_add          boolean := FALSE;
  l_count                 number;
  l_ext_chg_evt_log_id    number;
  l_object_version_number number;
  l_person_id             number;
  l_business_group_id     number;
  l_relationship          per_all_people_f.person_id%type;
  l_name                  per_all_people_f.full_name%type;
  l_contact               per_contact_relationships.contact_relationship_id%type;
  --
  cursor c_relationship(p_person_id number) is
  SELECT pcr.contact_relationship_id,pcr.person_id,ppf.full_name
  FROM   per_contact_relationships pcr,
         per_all_people_f ppf,
         per_person_types ppt,
         hr_lookups hl
  WHERE  pcr.contact_person_id = p_person_id
  AND    ppf.person_id = p_person_id
  AND    ppf.person_type_id = ppt.person_type_id
  AND    ppt.system_person_type = 'OTHER'
  AND    pcr.contact_type = hl.lookup_code
  AND    hl.lookup_type = 'CONTACT';

  cursor c_con_relationship(p_person_id number,p_effective_date date) is
  SELECT pcr.contact_relationship_id,pcr.person_id,ppf.full_name
  FROM   per_contact_relationships pcr,
         per_all_people_f ppf,
         hr_lookups hl
  WHERE  pcr.contact_person_id = p_person_id
  AND    ppf.person_id = p_person_id
  AND    pcr.contact_type = hl.lookup_code
  AND    hl.lookup_type = 'CONTACT'
  AND    pcr.personal_flag = 'Y'
  and    p_effective_date between  pcr.date_start and nvl(pcr.date_end, p_effective_date)

  ;
--
begin
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
--
  if p_event = 'INSERT' then
    l_person_id         := p_new_rec.person_id;
    l_business_group_id := p_new_rec.business_group_id;
    --
    if p_new_rec.primary_flag = 'Y' then
       -- if this is the first primary address then 'APA' (add primary address)
       -- if it is not the first primary address then 'COPR'
       --(change of primary address)
       if g_prev_upd_adr_person_id  = p_new_rec.person_id and
          g_prev_upd_adr_primary_flag = p_new_rec.primary_flag and
          g_prev_upd_adr_to_date = (p_new_rec.date_from-1) then

         l_chg_eff_dt := p_new_rec.date_from;
         l_tab_counter := l_tab_counter + 1;
         l_chg_evt_tab(l_tab_counter) := 'COPR';
         l_chg_eff_tab(l_tab_counter) := l_chg_eff_dt;
         l_prmtr_01_tab(l_tab_counter) := p_new_rec.address_id;
         l_prmtr_02_tab(l_tab_counter) := g_prev_upd_adr_address_id;
         l_prmtr_03_tab(l_tab_counter) := null;
         l_prmtr_04_tab(l_tab_counter) := null;
         l_prmtr_05_tab(l_tab_counter) := null;
         l_prmtr_06_tab(l_tab_counter) := null;
         l_prmtr_07_tab(l_tab_counter) := null;
         l_old_val1(l_tab_counter)     :=rtrim(substrb(g_prev_upd_adr_address_line1||' '||
                                      g_prev_upd_adr_address_line2||' '||
                                      g_prev_upd_adr_address_line3,1,600));
         l_old_val2(l_tab_counter) := g_prev_upd_adr_town_or_city;
         l_old_val3(l_tab_counter) := g_prev_upd_adr_region_2;
         l_old_val4(l_tab_counter) := g_prev_upd_adr_postal_code;
         l_old_val5(l_tab_counter) := g_prev_upd_adr_region_3;
         l_old_val6(l_tab_counter) := g_prev_upd_adr_region_1;
         l_new_val1(l_tab_counter) := rtrim(substrb(p_new_rec.address_line1||' '||
                                      p_new_rec.address_line2||' '||
                                      p_new_rec.address_line3,1,600));
         l_new_val2(l_tab_counter) := p_new_rec.town_or_city;
         l_new_val3(l_tab_counter) := p_new_rec.region_2;
         l_new_val4(l_tab_counter) := p_new_rec.postal_code;
         l_new_val5(l_tab_counter) := p_new_rec.region_3;
         l_new_val6(l_tab_counter) := p_new_rec.region_1;
       else
         l_chg_eff_dt := p_new_rec.date_from;
         l_tab_counter := l_tab_counter + 1;
         l_chg_evt_tab(l_tab_counter) := 'APA';
         l_chg_eff_tab(l_tab_counter) := l_chg_eff_dt;
         l_prmtr_01_tab(l_tab_counter) := p_new_rec.address_id;
         l_prmtr_02_tab(l_tab_counter) := null;
         l_prmtr_03_tab(l_tab_counter) := null;
         l_prmtr_04_tab(l_tab_counter) := null;
         l_prmtr_05_tab(l_tab_counter) := null;
         l_prmtr_06_tab(l_tab_counter) := null;
         l_prmtr_07_tab(l_tab_counter) := null;
         l_old_val1(l_tab_counter) := null;
         l_old_val2(l_tab_counter) := null;
         l_old_val3(l_tab_counter) := null;
         l_old_val4(l_tab_counter) := null;
         l_old_val5(l_tab_counter) := null;
         l_old_val6(l_tab_counter) := null;
         l_new_val1(l_tab_counter) := rtrim(substrb( p_new_rec.address_line1||' '||
                                      p_new_rec.address_line2||' '||
                                      p_new_rec.address_line3 , 1,600));
         l_new_val2(l_tab_counter) := p_new_rec.town_or_city;
         l_new_val3(l_tab_counter) := p_new_rec.region_2;
         l_new_val4(l_tab_counter) := p_new_rec.postal_code;
         l_new_val5(l_tab_counter) := p_new_rec.region_3;
         l_new_val6(l_tab_counter) := p_new_rec.region_1;
       end if;
    --
    --record change event(update contact's primary address) for participant.
    --- create only for the person, his person type is contact
    open c_relationship(p_new_rec.person_id);
    fetch c_relationship into l_contact,l_relationship,l_name;
    if c_relationship%notfound then
    close c_relationship;
    elsif c_relationship%found then
      close c_relationship;
      if g_prev_upd_adr_person_id  = p_new_rec.person_id and
          g_prev_upd_adr_primary_flag = p_new_rec.primary_flag and
          g_prev_upd_adr_to_date = (p_new_rec.date_from-1) then
         l_chg_eff_dt := p_new_rec.date_from;
         l_tab_counter := l_tab_counter + 1;
         l_chg_evt_tab(l_tab_counter) := 'CCPA';
         l_chg_eff_tab(l_tab_counter) := l_chg_eff_dt;
         l_prmtr_01_tab(l_tab_counter) := to_char(l_contact);
         l_prmtr_02_tab(l_tab_counter) := p_new_rec.address_id;
         l_prmtr_03_tab(l_tab_counter) := g_prev_upd_adr_address_id;
         l_prmtr_04_tab(l_tab_counter) := null;
         l_prmtr_05_tab(l_tab_counter) := null;
         l_prmtr_06_tab(l_tab_counter) := null;
         l_prmtr_07_tab(l_tab_counter) := null;
         l_old_val1(l_tab_counter) := rtrim(substrb(l_name,1,240));
         l_new_val1(l_tab_counter) := rtrim(substrb(l_name,1,240));
         l_old_val2(l_tab_counter) := rtrim(substrb( g_prev_upd_adr_address_line1||' '||
                                      g_prev_upd_adr_address_line2||' '||
                                      g_prev_upd_adr_address_line3,1,600));
         l_old_val3(l_tab_counter) := g_prev_upd_adr_town_or_city;
         l_old_val4(l_tab_counter) := g_prev_upd_adr_region_2;
         l_old_val5(l_tab_counter) := g_prev_upd_adr_postal_code;
         l_old_val6(l_tab_counter) := g_prev_upd_adr_region_3;
         l_new_val2(l_tab_counter) := rtrim(substrb( p_new_rec.address_line1||' '||
                                      p_new_rec.address_line2||' '||
                                      p_new_rec.address_line3,1,600));
         l_new_val3(l_tab_counter) := p_new_rec.town_or_city;
         l_new_val4(l_tab_counter) := p_new_rec.region_2;
         l_new_val5(l_tab_counter) := p_new_rec.postal_code;
         l_new_val6(l_tab_counter) := p_new_rec.region_3;
       end if;
     end if;

     --- create log for all the person from relationship
    open c_con_relationship(p_new_rec.person_id,l_chg_eff_dt);
    Loop
       fetch c_con_relationship into l_contact,l_relationship,l_name;
       Exit when c_con_relationship%notfound ;
       if g_prev_upd_adr_person_id  = p_new_rec.person_id and
          g_prev_upd_adr_primary_flag = p_new_rec.primary_flag and
          g_prev_upd_adr_to_date = (p_new_rec.date_from-1) then
          l_chg_eff_dt := p_new_rec.date_from;
          l_tab_counter := l_tab_counter + 1;
          l_chg_evt_tab(l_tab_counter) := 'CCNPA';
          l_chg_eff_tab(l_tab_counter) := l_chg_eff_dt;
          l_prmtr_01_tab(l_tab_counter) := to_char(l_contact);
          l_prmtr_02_tab(l_tab_counter) := p_new_rec.address_id;
          l_prmtr_03_tab(l_tab_counter) := g_prev_upd_adr_address_id;
          l_prmtr_04_tab(l_tab_counter) := null;
          l_prmtr_05_tab(l_tab_counter) := null;
          l_prmtr_06_tab(l_tab_counter) := null;
          l_prmtr_07_tab(l_tab_counter) := l_relationship;
          l_old_val1(l_tab_counter) := rtrim(substrb(l_name,1,240));
          l_new_val1(l_tab_counter) := rtrim(substrb(l_name,1,240));
          l_old_val2(l_tab_counter) := rtrim(substrb( g_prev_upd_adr_address_line1||' '||
                                       g_prev_upd_adr_address_line2||' '||
                                       g_prev_upd_adr_address_line3,1,600));
          l_old_val3(l_tab_counter) := g_prev_upd_adr_town_or_city;
          l_old_val4(l_tab_counter) := g_prev_upd_adr_region_2;
          l_old_val5(l_tab_counter) := g_prev_upd_adr_postal_code;
          l_old_val6(l_tab_counter) := g_prev_upd_adr_region_3;
          l_new_val2(l_tab_counter) := rtrim(substrb( p_new_rec.address_line1||' '||
                                       p_new_rec.address_line2||' '||
                                       p_new_rec.address_line3,1,600));
          l_new_val3(l_tab_counter) := p_new_rec.town_or_city;
          l_new_val4(l_tab_counter) := p_new_rec.region_2;
          l_new_val5(l_tab_counter) := p_new_rec.postal_code;
          l_new_val6(l_tab_counter) := p_new_rec.region_3;
       end if ;
          --- change of mailing address
       if (p_new_rec.address_type <> nvl(p_old_rec.address_type,'$$')
          and p_new_rec.address_type = 'M' ) OR
          (p_old_rec.address_type = 'M' and p_new_rec.date_to is null
          and p_old_rec.date_to is not null )  then

             l_chg_eff_dt := p_new_rec.date_from;
             l_tab_counter := l_tab_counter + 1;
             l_chg_evt_tab(l_tab_counter) := 'CCNMA';
             l_chg_eff_tab(l_tab_counter) := l_chg_eff_dt;
             l_prmtr_01_tab(l_tab_counter) := to_char(l_contact);
             l_prmtr_02_tab(l_tab_counter) := p_new_rec.address_id;
             l_prmtr_03_tab(l_tab_counter) := null;
             l_prmtr_04_tab(l_tab_counter) := null;
             l_prmtr_05_tab(l_tab_counter) := null;
             l_prmtr_06_tab(l_tab_counter) := null;
             l_prmtr_07_tab(l_tab_counter) := l_relationship;
             l_old_val1(l_tab_counter) := substr(l_name,1,240);
             l_new_val1(l_tab_counter) := substr(l_name,1,240);
             l_old_val2(l_tab_counter) := rtrim(substrb( p_old_rec.address_line1||' '||
                                          p_old_rec.address_line2||' '||
                                          p_old_rec.address_line3,1,600));
             l_old_val3(l_tab_counter) := p_old_rec.town_or_city;
             l_old_val4(l_tab_counter) := p_old_rec.region_2;
             l_old_val5(l_tab_counter) := p_old_rec.postal_code;
             l_old_val6(l_tab_counter) := p_old_rec.region_3;
             l_new_val2(l_tab_counter) := rtrim(substrb( p_new_rec.address_line1||' '||
                                          p_new_rec.address_line2||' '||
                                          p_new_rec.address_line3,1,600));
             l_new_val3(l_tab_counter) := p_new_rec.town_or_city;
             l_new_val4(l_tab_counter) := p_new_rec.region_2;
             l_new_val5(l_tab_counter) := p_new_rec.postal_code;
             l_new_val6(l_tab_counter) := p_new_rec.region_3;

        end if ;

     End Loop  ;
     close c_con_relationship;


--Bug 4699556 removed the elseif for AMA and added the below statement
-- so that if both APA and AMA are triggered at the same time both get logged.
   end if;
--End Bug 4699556
    -- record change events for creation of mailing address

    if p_new_rec.address_type = 'M' then
        l_chg_eff_dt := p_new_rec.date_from;
        l_tab_counter := l_tab_counter + 1;
        l_chg_evt_tab(l_tab_counter) := 'AMA';
        l_chg_eff_tab(l_tab_counter) := l_chg_eff_dt;
        l_prmtr_01_tab(l_tab_counter) := p_new_rec.address_id;
        l_prmtr_02_tab(l_tab_counter) := null;
        l_prmtr_03_tab(l_tab_counter) := null;
        l_prmtr_04_tab(l_tab_counter) := null;
        l_prmtr_05_tab(l_tab_counter) := null;
        l_prmtr_06_tab(l_tab_counter) := null;
        l_prmtr_07_tab(l_tab_counter) := null;
        l_old_val1(l_tab_counter) := null;
        l_old_val2(l_tab_counter) := null;
        l_old_val3(l_tab_counter) := null;
        l_old_val4(l_tab_counter) := null;
        l_old_val5(l_tab_counter) := null;
        l_old_val6(l_tab_counter) := null;
        l_new_val1(l_tab_counter) :=  rtrim(substrb( p_new_rec.address_line1||' '||
                                     p_new_rec.address_line2||' '||
                                     p_new_rec.address_line3,1,600));
        l_new_val2(l_tab_counter) := p_new_rec.town_or_city;
        l_new_val3(l_tab_counter) := p_new_rec.region_2;
        l_new_val4(l_tab_counter) := p_new_rec.postal_code;
        l_new_val5(l_tab_counter) := p_new_rec.region_3;
        l_new_val6(l_tab_counter) := p_new_rec.region_1;
    --record change event(update contact's mailing address) for participant.
    open c_relationship(p_new_rec.person_id);
    fetch c_relationship into l_contact,l_relationship,l_name;
    if c_relationship%notfound then
      close c_relationship;
    elsif c_relationship%found then
      close c_relationship;
        l_chg_eff_dt := p_new_rec.date_from;
        l_tab_counter := l_tab_counter + 1;
        l_chg_evt_tab(l_tab_counter) := 'CCMA';
        l_chg_eff_tab(l_tab_counter) := l_chg_eff_dt;
        l_prmtr_01_tab(l_tab_counter) := to_char(l_contact);
        l_prmtr_02_tab(l_tab_counter) := p_new_rec.address_id;
        l_prmtr_03_tab(l_tab_counter) := null;
        l_prmtr_04_tab(l_tab_counter) := null;
        l_prmtr_05_tab(l_tab_counter) := null;
        l_prmtr_06_tab(l_tab_counter) := null;
        l_prmtr_07_tab(l_tab_counter) := l_relationship;
        l_old_val1(l_tab_counter) := substr(l_name,1,240);
        l_new_val1(l_tab_counter) := substr(l_name,1,240);
        l_old_val2(l_tab_counter) := null;
        l_old_val3(l_tab_counter) := null;
        l_old_val4(l_tab_counter) := null;
        l_old_val5(l_tab_counter) := null;
        l_old_val6(l_tab_counter) := null;
        l_new_val2(l_tab_counter) := rtrim(substrb( p_new_rec.address_line1||' '||
                                     p_new_rec.address_line2||' '||
                                     p_new_rec.address_line3,1,600));
        l_new_val3(l_tab_counter) := p_new_rec.town_or_city;
        l_new_val4(l_tab_counter) := p_new_rec.region_2;
        l_new_val5(l_tab_counter) := p_new_rec.postal_code;
        l_new_val6(l_tab_counter) := p_new_rec.region_3;
    end if;
  end if;
    --
    --
  elsif p_event = 'DELETE' then
    l_person_id := p_old_rec.person_id;
    l_business_group_id := p_old_rec.business_group_id;
    --
    -- record change events for deletion of mailing address
    if p_old_rec.address_type = 'M' and p_old_rec.primary_flag = 'N'
        and p_old_rec.date_to is null then
        l_chg_eff_dt:= trunc(sysdate);
        l_tab_counter := l_tab_counter + 1;
        l_chg_evt_tab(l_tab_counter) := 'DMA';
        l_chg_eff_tab(l_tab_counter) := l_chg_eff_dt;
        l_prmtr_01_tab(l_tab_counter) := p_old_rec.address_id;
        l_prmtr_02_tab(l_tab_counter) := null;
        l_prmtr_03_tab(l_tab_counter) := null;
        l_prmtr_04_tab(l_tab_counter) := null;
        l_prmtr_05_tab(l_tab_counter) := null;
        l_prmtr_06_tab(l_tab_counter) := null;
        l_prmtr_07_tab(l_tab_counter) := null;
        l_old_val1(l_tab_counter) :=  rtrim(substrb( p_old_rec.address_line1||' '||
                                     p_old_rec.address_line2||' '||
                                     p_old_rec.address_line3,1,600));
        l_old_val2(l_tab_counter) := p_old_rec.town_or_city;
        l_old_val3(l_tab_counter) := p_old_rec.region_2;
        l_old_val4(l_tab_counter) := p_old_rec.postal_code;
        l_old_val5(l_tab_counter) := p_old_rec.region_3;
        l_old_val6(l_tab_counter) := p_old_rec.region_1;
        l_new_val1(l_tab_counter) := null;
        l_new_val2(l_tab_counter) := null;
        l_new_val3(l_tab_counter) := null;
        l_new_val4(l_tab_counter) := null;
        l_new_val5(l_tab_counter) := null;
        l_new_val6(l_tab_counter) := null;
    end if;
    --
--
  elsif p_event = 'UPDATE' then
  -- cache this data for later use.
  hr_utility.set_location(' in address changes ' , 673);
  g_prev_upd_adr_person_id       :=    p_new_rec.person_id;
  g_prev_upd_adr_primary_flag    :=    p_new_rec.primary_flag;
  g_prev_upd_adr_to_date         :=    p_new_rec.date_to;
  g_prev_upd_adr_address_line1   :=    p_new_rec.address_line1;
  g_prev_upd_adr_address_line2   :=    p_new_rec.address_line2;
  g_prev_upd_adr_address_line3   :=    p_new_rec.address_line3;
  g_prev_upd_adr_country         :=    p_new_rec.country;
  g_prev_upd_adr_postal_code     :=    p_new_rec.postal_code;
  g_prev_upd_adr_region_1        :=    p_new_rec.region_1;
  g_prev_upd_adr_region_2        :=    p_new_rec.region_2;
  g_prev_upd_adr_region_3        :=    p_new_rec.region_3;
  g_prev_upd_adr_town_or_city    :=    p_new_rec.town_or_city;
  g_prev_upd_adr_address_id      :=    p_new_rec.address_id;
  --

  l_person_id := p_new_rec.person_id;
  l_business_group_id := p_new_rec.business_group_id;
    --
    if p_old_rec.primary_flag = p_new_rec.primary_flag
       and p_new_rec.primary_flag = 'Y' and p_old_rec.date_to is null then

      l_chg_eff_dt := p_new_rec.date_from;
      if nvl(p_old_rec.address_line1, 'address_line1')
         <> nvl(p_new_rec.address_line1, 'address_line1')
         or
         nvl(p_old_rec.address_line2, 'address_line2')
         <> nvl(p_new_rec.address_line2, 'address_line2')
         or
         nvl(p_old_rec.address_line3, 'address_line3')
         <> nvl(p_new_rec.address_line3, 'address_line3')
         then
          l_chg_occured := TRUE;
          l_tab_counter := l_tab_counter + 1;
          l_chg_evt_tab(l_tab_counter) := 'CORS';
          l_chg_eff_tab(l_tab_counter) := l_chg_eff_dt;
          l_prmtr_01_tab(l_tab_counter) := p_old_rec.address_id;
          l_prmtr_02_tab(l_tab_counter) := null;
          l_prmtr_03_tab(l_tab_counter) := null;
          l_prmtr_04_tab(l_tab_counter) := null;
          l_prmtr_05_tab(l_tab_counter) := null;
          l_prmtr_06_tab(l_tab_counter) := null;
          l_prmtr_07_tab(l_tab_counter) := null;
          l_old_val1(l_tab_counter) := rtrim(substrb( p_old_rec.address_line1||' '||
                                       p_old_rec.address_line2||' '||
                                       p_old_rec.address_line3,1,600));
          l_old_val2(l_tab_counter) := null;
          l_old_val3(l_tab_counter) := null;
          l_old_val4(l_tab_counter) := null;
          l_old_val5(l_tab_counter) := null;
          l_old_val6(l_tab_counter) := null;
          l_new_val1(l_tab_counter) :=  rtrim(substrb( p_new_rec.address_line1||' '||
                                       p_new_rec.address_line2||' '||
                                       p_new_rec.address_line3,1,600));
          l_new_val2(l_tab_counter) := null;
          l_new_val3(l_tab_counter) := null;
          l_new_val4(l_tab_counter) := null;
          l_new_val5(l_tab_counter) := null;
          l_new_val6(l_tab_counter) := null;
      end if;
      if upper(nvl(p_old_rec.postal_code, 'postal_code'))
         <> upper(nvl(p_new_rec.postal_code, 'postal_code')) then
          l_chg_occured := TRUE;
          l_tab_counter := l_tab_counter + 1;
          l_chg_evt_tab(l_tab_counter) := 'CORP';
          l_chg_eff_tab(l_tab_counter) := l_chg_eff_dt;
          l_prmtr_01_tab(l_tab_counter) := p_old_rec.address_id;
          l_prmtr_02_tab(l_tab_counter) := null;
          l_prmtr_03_tab(l_tab_counter) := null;
          l_prmtr_04_tab(l_tab_counter) := null;
          l_prmtr_05_tab(l_tab_counter) := null;
          l_prmtr_06_tab(l_tab_counter) := null;
          l_prmtr_07_tab(l_tab_counter) := null;
          l_old_val1(l_tab_counter) := p_old_rec.postal_code;
          l_old_val2(l_tab_counter) := null;
          l_old_val3(l_tab_counter) := null;
          l_old_val4(l_tab_counter) := null;
          l_old_val5(l_tab_counter) := null;
          l_old_val6(l_tab_counter) := null;
          l_new_val1(l_tab_counter) := p_new_rec.postal_code;
          l_new_val2(l_tab_counter) := null;
          l_new_val3(l_tab_counter) := null;
          l_new_val4(l_tab_counter) := null;
          l_new_val5(l_tab_counter) := null;
          l_new_val6(l_tab_counter) := null;
      end if;
      if upper(nvl(p_old_rec.region_1, 'region_1'))
         <> upper(nvl(p_new_rec.region_1, 'region_1')) then
          l_chg_occured := TRUE;
          l_tab_counter := l_tab_counter + 1;
          l_chg_evt_tab(l_tab_counter) := 'COPE';
          l_chg_eff_tab(l_tab_counter) := l_chg_eff_dt;
          l_prmtr_01_tab(l_tab_counter) := p_old_rec.address_id;
          l_prmtr_02_tab(l_tab_counter) := null;
          l_prmtr_03_tab(l_tab_counter) := null;
          l_prmtr_04_tab(l_tab_counter) := null;
          l_prmtr_05_tab(l_tab_counter) := null;
          l_prmtr_06_tab(l_tab_counter) := null;
          l_prmtr_07_tab(l_tab_counter) := null;
          l_old_val1(l_tab_counter) := p_old_rec.region_1;
          l_old_val2(l_tab_counter) := null;
          l_old_val3(l_tab_counter) := null;
          l_old_val4(l_tab_counter) := null;
          l_old_val5(l_tab_counter) := null;
          l_old_val6(l_tab_counter) := null;
          l_new_val1(l_tab_counter) := p_new_rec.region_1;
          l_new_val2(l_tab_counter) := null;
          l_new_val3(l_tab_counter) := null;
          l_new_val4(l_tab_counter) := null;
          l_new_val5(l_tab_counter) := null;
          l_new_val6(l_tab_counter) := null;
      end if;
      if upper(nvl(p_old_rec.region_2, 'region_2'))
         <> upper(nvl(p_new_rec.region_2, 'region_2')) then
          l_chg_occured := TRUE;
          l_tab_counter := l_tab_counter + 1;
          l_chg_evt_tab(l_tab_counter) := 'COPS';
          l_chg_eff_tab(l_tab_counter) := l_chg_eff_dt;
          l_prmtr_01_tab(l_tab_counter) := p_old_rec.address_id;
          l_prmtr_02_tab(l_tab_counter) := null;
          l_prmtr_03_tab(l_tab_counter) := null;
          l_prmtr_04_tab(l_tab_counter) := null;
          l_prmtr_05_tab(l_tab_counter) := null;
          l_prmtr_06_tab(l_tab_counter) := null;
          l_prmtr_07_tab(l_tab_counter) := null;
          l_old_val1(l_tab_counter) := p_old_rec.region_2;
          l_old_val2(l_tab_counter) := null;
          l_old_val3(l_tab_counter) := null;
          l_old_val4(l_tab_counter) := null;
          l_old_val5(l_tab_counter) := null;
          l_old_val6(l_tab_counter) := null;
          l_new_val1(l_tab_counter) := p_new_rec.region_2;
          l_new_val2(l_tab_counter) := null;
          l_new_val3(l_tab_counter) := null;
          l_new_val4(l_tab_counter) := null;
          l_new_val5(l_tab_counter) := null;
          l_new_val6(l_tab_counter) := null;
      end if;
      if upper(nvl(p_old_rec.region_3, 'region_3'))
         <> upper(nvl(p_new_rec.region_3, 'region_3')) then
          l_chg_occured := TRUE;
          l_tab_counter := l_tab_counter + 1;
          l_chg_evt_tab(l_tab_counter) := 'COPC';
          l_chg_eff_tab(l_tab_counter) := l_chg_eff_dt;
          l_prmtr_01_tab(l_tab_counter) := p_old_rec.address_id;
          l_prmtr_02_tab(l_tab_counter) := null;
          l_prmtr_03_tab(l_tab_counter) := null;
          l_prmtr_04_tab(l_tab_counter) := null;
          l_prmtr_05_tab(l_tab_counter) := null;
          l_prmtr_06_tab(l_tab_counter) := null;
          l_prmtr_07_tab(l_tab_counter) := null;
          l_old_val1(l_tab_counter) := p_old_rec.region_3;
          l_old_val2(l_tab_counter) := null;
          l_old_val3(l_tab_counter) := null;
          l_old_val4(l_tab_counter) := null;
          l_old_val5(l_tab_counter) := null;
          l_old_val6(l_tab_counter) := null;
          l_new_val1(l_tab_counter) := p_new_rec.region_3;
          l_new_val2(l_tab_counter) := null;
          l_new_val3(l_tab_counter) := null;
          l_new_val4(l_tab_counter) := null;
          l_new_val5(l_tab_counter) := null;
          l_new_val6(l_tab_counter) := null;
      end if;
      if upper(nvl(p_old_rec.town_or_city, 'town_or_city'))
         <> upper(nvl(p_new_rec.town_or_city, 'town_or_city')) then
          l_chg_occured := TRUE;
          l_tab_counter := l_tab_counter + 1;
          l_chg_evt_tab(l_tab_counter) := 'CORC';
          l_chg_eff_tab(l_tab_counter) := l_chg_eff_dt;
          l_prmtr_01_tab(l_tab_counter) := p_old_rec.address_id;
          l_prmtr_02_tab(l_tab_counter) := null;
          l_prmtr_03_tab(l_tab_counter) := null;
          l_prmtr_04_tab(l_tab_counter) := null;
          l_prmtr_05_tab(l_tab_counter) := null;
          l_prmtr_06_tab(l_tab_counter) := null;
          l_prmtr_07_tab(l_tab_counter) := null;
          l_old_val1(l_tab_counter) := p_old_rec.town_or_city;
          l_old_val2(l_tab_counter) := null;
          l_old_val3(l_tab_counter) := null;
          l_old_val4(l_tab_counter) := null;
          l_old_val5(l_tab_counter) := null;
          l_old_val6(l_tab_counter) := null;
          l_new_val1(l_tab_counter) := p_new_rec.town_or_city;
          l_new_val2(l_tab_counter) := null;
          l_new_val3(l_tab_counter) := null;
          l_new_val4(l_tab_counter) := null;
          l_new_val5(l_tab_counter) := null;
          l_new_val6(l_tab_counter) := null;
      end if;

      if upper(nvl(p_old_rec.country, 'country'))
         <> upper(nvl(p_new_rec.country, 'country')) then
          l_chg_occured := TRUE;
          l_tab_counter := l_tab_counter + 1;
          l_chg_evt_tab(l_tab_counter) := 'COCN';
          l_chg_eff_tab(l_tab_counter) := l_chg_eff_dt;
          l_prmtr_01_tab(l_tab_counter) := p_old_rec.address_id;
          l_prmtr_02_tab(l_tab_counter) := null;
          l_prmtr_03_tab(l_tab_counter) := null;
          l_prmtr_04_tab(l_tab_counter) := null;
          l_prmtr_05_tab(l_tab_counter) := null;
          l_prmtr_06_tab(l_tab_counter) := null;
          l_prmtr_07_tab(l_tab_counter) := null;
          l_old_val1(l_tab_counter) := p_old_rec.country;
          l_old_val2(l_tab_counter) := null;
          l_old_val3(l_tab_counter) := null;
          l_old_val4(l_tab_counter) := null;
          l_old_val5(l_tab_counter) := null;
          l_old_val6(l_tab_counter) := null;
          l_new_val1(l_tab_counter) := p_new_rec.country;
          l_new_val2(l_tab_counter) := null;
          l_new_val3(l_tab_counter) := null;
          l_new_val4(l_tab_counter) := null;
          l_new_val5(l_tab_counter) := null;
          l_new_val6(l_tab_counter) := null;
      end if;
     if l_chg_occured then
        l_tab_counter := l_tab_counter + 1;
        l_chg_evt_tab(l_tab_counter) := 'COPR';
        l_chg_eff_tab(l_tab_counter) := l_chg_eff_dt;
        l_prmtr_01_tab(l_tab_counter) := p_old_rec.address_id;
        l_prmtr_02_tab(l_tab_counter) := null;
        l_prmtr_03_tab(l_tab_counter) := null;
        l_prmtr_04_tab(l_tab_counter) := null;
        l_prmtr_05_tab(l_tab_counter) := null;
        l_prmtr_06_tab(l_tab_counter) := null;
        l_prmtr_07_tab(l_tab_counter) := null;
        l_old_val1(l_tab_counter) := rtrim(substrb( p_old_rec.address_line1||' '||
                                     p_old_rec.address_line2||' '||
                                     p_old_rec.address_line3,1,600));
        l_old_val2(l_tab_counter) := p_old_rec.town_or_city;
        l_old_val3(l_tab_counter) := p_old_rec.region_2;
        l_old_val4(l_tab_counter) := p_old_rec.postal_code;
        l_old_val5(l_tab_counter) := p_old_rec.region_3;
        l_old_val6(l_tab_counter) := p_old_rec.region_1;
        l_new_val1(l_tab_counter) := rtrim(substrb( p_new_rec.address_line1||' '||
                                     p_new_rec.address_line2||' '||
                                     p_new_rec.address_line3,1,600));
        l_new_val2(l_tab_counter) := p_new_rec.town_or_city;
        l_new_val3(l_tab_counter) := p_new_rec.region_2;
        l_new_val4(l_tab_counter) := p_new_rec.postal_code;
        l_new_val5(l_tab_counter) := p_new_rec.region_3;
        l_new_val6(l_tab_counter) := p_new_rec.region_1;
      end if;
         --for contact data change
      if ((l_chg_occured)
      or (nvl(p_old_rec.date_from,
         to_date('01/01/0001', 'DD/MM/YYYY'))
         <> nvl(p_new_rec.date_from,
         to_date('01/01/0001', 'DD/MM/YYYY')))) then

         open c_relationship(p_new_rec.person_id);
         fetch c_relationship into l_contact,l_relationship,l_name;
         if c_relationship%notfound then
           close c_relationship;
         elsif c_relationship%found then
           close c_relationship;
         l_tab_counter := l_tab_counter + 1;
         l_chg_evt_tab(l_tab_counter) := 'CCPA';
         l_chg_eff_tab(l_tab_counter) := l_chg_eff_dt;
         l_prmtr_01_tab(l_tab_counter) := to_char(l_contact);
         l_prmtr_02_tab(l_tab_counter) := p_new_rec.address_id;
         l_prmtr_03_tab(l_tab_counter) := null;
         l_prmtr_04_tab(l_tab_counter) := null;
         l_prmtr_05_tab(l_tab_counter) := null;
         l_prmtr_06_tab(l_tab_counter) := null;
         l_prmtr_07_tab(l_tab_counter) := l_relationship;
         l_old_val1(l_tab_counter) := substr(l_name,1,240);
         l_new_val1(l_tab_counter) := substr(l_name,1,240);
         l_old_val2(l_tab_counter) :=  rtrim(substrb(p_old_rec.address_line1||' '||
                                     p_old_rec.address_line2||' '||
                                     p_old_rec.address_line3,1,600));
         l_old_val3(l_tab_counter) := p_old_rec.town_or_city;
         l_old_val4(l_tab_counter) := p_old_rec.region_2;
         l_old_val5(l_tab_counter) := p_old_rec.postal_code;
         l_old_val6(l_tab_counter) := p_old_rec.region_3;
         l_new_val2(l_tab_counter) := rtrim(substrb( p_new_rec.address_line1||' '||
                                      p_new_rec.address_line2||' '||
                                      p_new_rec.address_line3,1,600));
         l_new_val3(l_tab_counter) := p_new_rec.town_or_city;
         l_new_val4(l_tab_counter) := p_new_rec.region_2;
         l_new_val5(l_tab_counter) := p_new_rec.postal_code;
         l_new_val6(l_tab_counter) := p_new_rec.region_3;
         end if;
      end if;
      if nvl(p_old_rec.date_from,
         to_date('01/01/0001', 'DD/MM/YYYY'))
         <> nvl(p_new_rec.date_from,
         to_date('01/01/0001', 'DD/MM/YYYY')) then
          l_tab_counter := l_tab_counter + 1;
          l_chg_evt_tab(l_tab_counter) := 'COPR';
          l_chg_eff_tab(l_tab_counter) := l_chg_eff_dt;
          l_prmtr_01_tab(l_tab_counter) := p_old_rec.address_id;
          l_prmtr_02_tab(l_tab_counter) := null;
          l_prmtr_03_tab(l_tab_counter) := null;
          l_prmtr_04_tab(l_tab_counter) := null;
          l_prmtr_05_tab(l_tab_counter) := null;
          l_prmtr_06_tab(l_tab_counter) := null;
          l_prmtr_07_tab(l_tab_counter) := null;
        l_old_val1(l_tab_counter) := rtrim(substrb( p_old_rec.address_line1||' '||
                                     p_old_rec.address_line2||' '||
                                     p_old_rec.address_line3,1,600));
        l_old_val2(l_tab_counter) := p_old_rec.town_or_city;
        l_old_val3(l_tab_counter) := p_old_rec.region_2;
        l_old_val4(l_tab_counter) := p_old_rec.postal_code;
        l_old_val5(l_tab_counter) := p_old_rec.region_3;
        l_old_val6(l_tab_counter) := p_old_rec.region_1;
        l_new_val1(l_tab_counter) :=  rtrim(substrb( p_new_rec.address_line1||' '||
                                     p_new_rec.address_line2||' '||
                                     p_new_rec.address_line3,1,600));
        l_new_val2(l_tab_counter) := p_new_rec.town_or_city;
        l_new_val3(l_tab_counter) := p_new_rec.region_2;
        l_new_val4(l_tab_counter) := p_new_rec.postal_code;
        l_new_val5(l_tab_counter) := p_new_rec.region_3;
        l_new_val6(l_tab_counter) := p_new_rec.region_1;
      end if;


    end if;
--
    -- also log change events for mailing address
    if p_new_rec.address_type <> nvl(p_old_rec.address_type,'$$')
          and p_new_rec.address_type = 'M' then
        l_chg_eff_dt := p_new_rec.date_from;
        l_tab_counter := l_tab_counter + 1;
        l_chg_evt_tab(l_tab_counter) := 'AMA';
        l_chg_eff_tab(l_tab_counter) := l_chg_eff_dt;
        l_prmtr_01_tab(l_tab_counter) := p_new_rec.address_id;
        l_prmtr_02_tab(l_tab_counter) := null;
        l_prmtr_03_tab(l_tab_counter) := null;
        l_prmtr_04_tab(l_tab_counter) := null;
        l_prmtr_05_tab(l_tab_counter) := null;
        l_prmtr_06_tab(l_tab_counter) := null;
        l_prmtr_07_tab(l_tab_counter) := null;
        l_old_val1(l_tab_counter) := null;
        l_old_val2(l_tab_counter) := null;
        l_old_val3(l_tab_counter) := null;
        l_old_val4(l_tab_counter) := null;
        l_old_val5(l_tab_counter) := null;
        l_old_val6(l_tab_counter) := null;
        l_new_val1(l_tab_counter) :=  rtrim(substrb( p_new_rec.address_line1||' '||
                                     p_new_rec.address_line2||' '||
                                     p_new_rec.address_line3,1,600));
        l_new_val2(l_tab_counter) := p_new_rec.town_or_city;
        l_new_val3(l_tab_counter) := p_new_rec.region_2;
        l_new_val4(l_tab_counter) := p_new_rec.postal_code;
        l_new_val5(l_tab_counter) := p_new_rec.region_3;
        l_new_val6(l_tab_counter) := p_new_rec.region_1;
    end if;

    if p_old_rec.address_type = 'M'
          and p_new_rec.date_to is null
          and p_old_rec.date_to is not null then
        l_chg_eff_dt := p_new_rec.date_from;
        l_tab_counter := l_tab_counter + 1;
        l_chg_evt_tab(l_tab_counter) := 'AMA';
        l_chg_eff_tab(l_tab_counter) := l_chg_eff_dt;
        l_prmtr_01_tab(l_tab_counter) := p_new_rec.address_id;
        l_prmtr_02_tab(l_tab_counter) := null;
        l_prmtr_03_tab(l_tab_counter) := null;
        l_prmtr_04_tab(l_tab_counter) := null;
        l_prmtr_05_tab(l_tab_counter) := null;
        l_prmtr_06_tab(l_tab_counter) := null;
        l_prmtr_07_tab(l_tab_counter) := null;
        l_old_val1(l_tab_counter) := null;
        l_old_val2(l_tab_counter) := null;
        l_old_val3(l_tab_counter) := null;
        l_old_val4(l_tab_counter) := null;
        l_old_val5(l_tab_counter) := null;
        l_old_val6(l_tab_counter) := null;
        l_new_val1(l_tab_counter) :=  rtrim(substrb( p_new_rec.address_line1||' '||
                                     p_new_rec.address_line2||' '||
                                     p_new_rec.address_line3,1,600));
        l_new_val2(l_tab_counter) := p_new_rec.town_or_city;
        l_new_val3(l_tab_counter) := p_new_rec.region_2;
        l_new_val4(l_tab_counter) := p_new_rec.postal_code;
        l_new_val5(l_tab_counter) := p_new_rec.region_3;
        l_new_val6(l_tab_counter) := p_new_rec.region_1;
    end if;

    if nvl(p_new_rec.address_type,'$$') <> p_old_rec.address_type
          and p_old_rec.address_type = 'M' then
      l_chg_eff_dt := trunc(sysdate);
        l_tab_counter := l_tab_counter + 1;
        l_chg_evt_tab(l_tab_counter) := 'DMA';
        l_chg_eff_tab(l_tab_counter) := l_chg_eff_dt;
        l_prmtr_01_tab(l_tab_counter) := p_old_rec.address_id;
        l_prmtr_02_tab(l_tab_counter) := null;
        l_prmtr_03_tab(l_tab_counter) := null;
        l_prmtr_04_tab(l_tab_counter) := null;
        l_prmtr_05_tab(l_tab_counter) := null;
        l_prmtr_06_tab(l_tab_counter) := null;
        l_prmtr_07_tab(l_tab_counter) := null;
        l_old_val1(l_tab_counter) :=  rtrim(substrb( p_old_rec.address_line1||' '||
                                     p_old_rec.address_line2||' '||
                                     p_old_rec.address_line3,1,600));
        l_old_val2(l_tab_counter) := p_old_rec.town_or_city;
        l_old_val3(l_tab_counter) := p_old_rec.region_2;
        l_old_val4(l_tab_counter) := p_old_rec.postal_code;
        l_old_val5(l_tab_counter) := p_old_rec.region_3;
        l_old_val6(l_tab_counter) := p_old_rec.region_1;
        l_new_val1(l_tab_counter) := null;
        l_new_val2(l_tab_counter) := null;
        l_new_val3(l_tab_counter) := null;
        l_new_val4(l_tab_counter) := null;
        l_new_val5(l_tab_counter) := null;
        l_new_val6(l_tab_counter) := null;
    end if;

    if p_old_rec.address_type = 'M'
          and p_new_rec.date_to is not null
          and p_old_rec.date_to is null then
      l_chg_eff_dt := p_new_rec.date_to;
        l_tab_counter := l_tab_counter + 1;
        l_chg_evt_tab(l_tab_counter) := 'DMA';
        l_chg_eff_tab(l_tab_counter) := l_chg_eff_dt;
        l_prmtr_01_tab(l_tab_counter) := p_old_rec.address_id;
        l_prmtr_02_tab(l_tab_counter) := null;
        l_prmtr_03_tab(l_tab_counter) := null;
        l_prmtr_04_tab(l_tab_counter) := null;
        l_prmtr_05_tab(l_tab_counter) := null;
        l_prmtr_06_tab(l_tab_counter) := null;
        l_prmtr_07_tab(l_tab_counter) := null;
        l_old_val1(l_tab_counter) :=  rtrim(substrb( p_old_rec.address_line1||' '||
                                     p_old_rec.address_line2||' '||
                                     p_old_rec.address_line3,1,600));
        l_old_val2(l_tab_counter) := p_old_rec.town_or_city;
        l_old_val3(l_tab_counter) := p_old_rec.region_2;
        l_old_val4(l_tab_counter) := p_old_rec.postal_code;
        l_old_val5(l_tab_counter) := p_old_rec.region_3;
        l_old_val6(l_tab_counter) := p_old_rec.region_1;
        l_new_val1(l_tab_counter) := null;
        l_new_val2(l_tab_counter) := null;
        l_new_val3(l_tab_counter) := null;
        l_new_val4(l_tab_counter) := null;
        l_new_val5(l_tab_counter) := null;
        l_new_val6(l_tab_counter) := null;
    end if;
    --
    if p_old_rec.address_type = p_new_rec.address_type
       and p_new_rec.address_type = 'M' then
      if nvl(p_new_rec.date_from,
         to_date('01/01/0001', 'DD/MM/YYYY'))
         < trunc(sysdate) then
        if nvl(p_new_rec.date_to,
           to_date('31/12/4712', 'DD/MM/YYYY'))
           < trunc(sysdate) then
          l_chg_eff_dt := p_new_rec.date_to;
        else
          l_chg_eff_dt := trunc(sysdate);
        end if;
      else
        l_chg_eff_dt := p_new_rec.date_from;
      end if;
      if upper(nvl(p_old_rec.town_or_city, 'town_or_city'))
         <> upper(nvl(p_new_rec.town_or_city, 'town_or_city')) then
          l_chg_occured := TRUE;
          l_tab_counter := l_tab_counter + 1;
          l_chg_evt_tab(l_tab_counter) := 'COMC';
          l_chg_eff_tab(l_tab_counter) := l_chg_eff_dt;
          l_prmtr_01_tab(l_tab_counter) := p_old_rec.address_id;
          l_prmtr_02_tab(l_tab_counter) := null;
          l_prmtr_03_tab(l_tab_counter) := null;
          l_prmtr_04_tab(l_tab_counter) := null;
          l_prmtr_05_tab(l_tab_counter) := null;
          l_prmtr_06_tab(l_tab_counter) := null;
          l_prmtr_07_tab(l_tab_counter) := null;
          l_old_val1(l_tab_counter) := p_old_rec.town_or_city;
          l_old_val2(l_tab_counter) := null;
          l_old_val3(l_tab_counter) := null;
          l_old_val4(l_tab_counter) := null;
          l_old_val5(l_tab_counter) := null;
          l_old_val6(l_tab_counter) := null;
          l_new_val1(l_tab_counter) := p_new_rec.town_or_city;
          l_new_val2(l_tab_counter) := null;
          l_new_val3(l_tab_counter) := null;
          l_new_val4(l_tab_counter) := null;
          l_new_val5(l_tab_counter) := null;
          l_new_val6(l_tab_counter) := null;
      end if;
      if upper(nvl(p_old_rec.postal_code, 'postal_code'))
         <> upper(nvl(p_new_rec.postal_code, 'postal_code')) then
          l_chg_occured := TRUE;
          l_tab_counter := l_tab_counter + 1;
          l_chg_evt_tab(l_tab_counter) := 'COMP';
          l_chg_eff_tab(l_tab_counter) := l_chg_eff_dt;
          l_prmtr_01_tab(l_tab_counter) := p_old_rec.address_id;
          l_prmtr_02_tab(l_tab_counter) := null;
          l_prmtr_03_tab(l_tab_counter) := null;
          l_prmtr_04_tab(l_tab_counter) := null;
          l_prmtr_05_tab(l_tab_counter) := null;
          l_prmtr_06_tab(l_tab_counter) := null;
          l_prmtr_07_tab(l_tab_counter) := null;
          l_old_val1(l_tab_counter) := p_old_rec.postal_code;
          l_old_val2(l_tab_counter) := null;
          l_old_val3(l_tab_counter) := null;
          l_old_val4(l_tab_counter) := null;
          l_old_val5(l_tab_counter) := null;
          l_old_val6(l_tab_counter) := null;
          l_new_val1(l_tab_counter) := p_new_rec.postal_code;
          l_new_val2(l_tab_counter) := null;
          l_new_val3(l_tab_counter) := null;
          l_new_val4(l_tab_counter) := null;
          l_new_val5(l_tab_counter) := null;
          l_new_val6(l_tab_counter) := null;
      end if;
      if nvl(p_old_rec.address_line1, 'address_line1')
         <> nvl(p_new_rec.address_line1, 'address_line1')
         or
         nvl(p_old_rec.address_line2, 'address_line2')
         <> nvl(p_new_rec.address_line2, 'address_line2')
         or
         nvl(p_old_rec.address_line3, 'address_line3')
         <> nvl(p_new_rec.address_line3, 'address_line3')
          then
          l_chg_occured := TRUE;
          l_tab_counter := l_tab_counter + 1;
          l_chg_evt_tab(l_tab_counter) := 'COMS';
          l_chg_eff_tab(l_tab_counter) := l_chg_eff_dt;
          l_prmtr_01_tab(l_tab_counter) := p_old_rec.address_id;
          l_prmtr_02_tab(l_tab_counter) := null;
          l_prmtr_03_tab(l_tab_counter) := null;
          l_prmtr_04_tab(l_tab_counter) := null;
          l_prmtr_05_tab(l_tab_counter) := null;
          l_prmtr_06_tab(l_tab_counter) := null;
          l_prmtr_07_tab(l_tab_counter) := null;
          l_old_val1(l_tab_counter) :=  rtrim(substrb( p_old_rec.address_line1||' '||
                                       p_old_rec.address_line2||' '||
                                       p_old_rec.address_line3,1,600));
          l_old_val2(l_tab_counter) := null;
          l_old_val3(l_tab_counter) := null;
          l_old_val4(l_tab_counter) := null;
          l_old_val5(l_tab_counter) := null;
          l_old_val6(l_tab_counter) := null;
          l_new_val1(l_tab_counter) := rtrim(substrb( p_new_rec.address_line1||' '||
                                       p_new_rec.address_line2||' '||
                                       p_new_rec.address_line3,1,600));
          l_new_val2(l_tab_counter) := null;
          l_new_val3(l_tab_counter) := null;
          l_new_val4(l_tab_counter) := null;
          l_new_val5(l_tab_counter) := null;
          l_new_val6(l_tab_counter) := null;
      end if;
      if upper(nvl(p_old_rec.region_1, 'region_1'))
         <> upper(nvl(p_new_rec.region_1, 'region_1')) then
          l_chg_occured := TRUE;
          l_tab_counter := l_tab_counter + 1;
          l_chg_evt_tab(l_tab_counter) := 'COMR';
          l_chg_eff_tab(l_tab_counter) := l_chg_eff_dt;
          l_prmtr_01_tab(l_tab_counter) := p_old_rec.address_id;
          l_prmtr_02_tab(l_tab_counter) := null;
          l_prmtr_03_tab(l_tab_counter) := null;
          l_prmtr_04_tab(l_tab_counter) := null;
          l_prmtr_05_tab(l_tab_counter) := null;
          l_prmtr_06_tab(l_tab_counter) := null;
          l_prmtr_07_tab(l_tab_counter) := null;
          l_old_val1(l_tab_counter) := p_old_rec.region_1;
          l_old_val2(l_tab_counter) := null;
          l_old_val3(l_tab_counter) := null;
          l_old_val4(l_tab_counter) := null;
          l_old_val5(l_tab_counter) := null;
          l_old_val6(l_tab_counter) := null;
          l_new_val1(l_tab_counter) := p_new_rec.region_1;
          l_new_val2(l_tab_counter) := null;
          l_new_val3(l_tab_counter) := null;
          l_new_val4(l_tab_counter) := null;
          l_new_val5(l_tab_counter) := null;
          l_new_val6(l_tab_counter) := null;
      end if;
      if upper(nvl(p_old_rec.region_2, 'region_2'))
         <> upper(nvl(p_new_rec.region_2, 'region_2')) then
          l_chg_occured := TRUE;
          l_tab_counter := l_tab_counter + 1;
          l_chg_evt_tab(l_tab_counter) := 'COMT';
          l_chg_eff_tab(l_tab_counter) := l_chg_eff_dt;
          l_prmtr_01_tab(l_tab_counter) := p_old_rec.address_id;
          l_prmtr_02_tab(l_tab_counter) := null;
          l_prmtr_03_tab(l_tab_counter) := null;
          l_prmtr_04_tab(l_tab_counter) := null;
          l_prmtr_05_tab(l_tab_counter) := null;
          l_prmtr_06_tab(l_tab_counter) := null;
          l_prmtr_07_tab(l_tab_counter) := null;
          l_old_val1(l_tab_counter) := p_old_rec.region_2;
          l_old_val2(l_tab_counter) := null;
          l_old_val3(l_tab_counter) := null;
          l_old_val4(l_tab_counter) := null;
          l_old_val5(l_tab_counter) := null;
          l_old_val6(l_tab_counter) := null;
          l_new_val1(l_tab_counter) := p_new_rec.region_2;
          l_new_val2(l_tab_counter) := null;
          l_new_val3(l_tab_counter) := null;
          l_new_val4(l_tab_counter) := null;
          l_new_val5(l_tab_counter) := null;
          l_new_val6(l_tab_counter) := null;
      end if;
      if upper(nvl(p_old_rec.region_3, 'region_3'))
         <> upper(nvl(p_new_rec.region_3, 'region_3')) then
          l_chg_occured := TRUE;
          l_tab_counter := l_tab_counter + 1;
          l_chg_evt_tab(l_tab_counter) := 'COMO';
          l_chg_eff_tab(l_tab_counter) := l_chg_eff_dt;
          l_prmtr_01_tab(l_tab_counter) := p_old_rec.address_id;
          l_prmtr_02_tab(l_tab_counter) := null;
          l_prmtr_03_tab(l_tab_counter) := null;
          l_prmtr_04_tab(l_tab_counter) := null;
          l_prmtr_05_tab(l_tab_counter) := null;
          l_prmtr_06_tab(l_tab_counter) := null;
          l_prmtr_07_tab(l_tab_counter) := null;
          l_old_val1(l_tab_counter) := p_old_rec.region_3;
          l_old_val2(l_tab_counter) := null;
          l_old_val3(l_tab_counter) := null;
          l_old_val4(l_tab_counter) := null;
          l_old_val5(l_tab_counter) := null;
          l_old_val6(l_tab_counter) := null;
          l_new_val1(l_tab_counter) := p_new_rec.region_3;
          l_new_val2(l_tab_counter) := null;
          l_new_val3(l_tab_counter) := null;
          l_new_val4(l_tab_counter) := null;
          l_new_val5(l_tab_counter) := null;
          l_new_val6(l_tab_counter) := null;
      end if;
    --
    -- for contact change of mailing address
      if p_new_rec.address_type <> nvl(p_old_rec.address_type,'$$')
          and p_new_rec.address_type = 'M' then
        l_chg_mail_add := true;
      elsif p_old_rec.address_type = 'M'
          and p_new_rec.date_to is null
          and p_old_rec.date_to is not null then
        l_chg_mail_add := true;
      end if;
      if l_chg_occured or l_chg_mail_add then
      --fnd_message.set_name('BEN','ddddsss'||to_char(l_relationship));
      --fnd_message.raise_error;
         open c_relationship(p_new_rec.person_id);
         fetch c_relationship into l_contact,l_relationship,l_name;
         if c_relationship%notfound then
           close c_relationship;
         elsif c_relationship%found then
           close c_relationship;
         l_tab_counter := l_tab_counter + 1;
         l_chg_evt_tab(l_tab_counter) := 'CCMA';
         l_chg_eff_tab(l_tab_counter) := l_chg_eff_dt;
         l_prmtr_01_tab(l_tab_counter) := to_char(l_contact);
         l_prmtr_02_tab(l_tab_counter) := p_new_rec.address_id;
         l_prmtr_03_tab(l_tab_counter) := null;
         l_prmtr_04_tab(l_tab_counter) := null;
         l_prmtr_05_tab(l_tab_counter) := null;
         l_prmtr_06_tab(l_tab_counter) := null;
         l_prmtr_07_tab(l_tab_counter) := l_relationship;
         l_old_val1(l_tab_counter) := substr(l_name,1,240);
         l_new_val1(l_tab_counter) := substr(l_name,1,240);
         l_old_val2(l_tab_counter) := rtrim(substrb( p_old_rec.address_line1||' '||
                                     p_old_rec.address_line2||' '||
                                     p_old_rec.address_line3,1,600));
         l_old_val3(l_tab_counter) := p_old_rec.town_or_city;
         l_old_val4(l_tab_counter) := p_old_rec.region_2;
         l_old_val5(l_tab_counter) := p_old_rec.postal_code;
         l_old_val6(l_tab_counter) := p_old_rec.region_3;
         l_new_val2(l_tab_counter) :=  rtrim(substrb( p_new_rec.address_line1||' '||
                                      p_new_rec.address_line2||' '||
                                      p_new_rec.address_line3,1,600));
         l_new_val3(l_tab_counter) := p_new_rec.town_or_city;
         l_new_val4(l_tab_counter) := p_new_rec.region_2;
         l_new_val5(l_tab_counter) := p_new_rec.postal_code;
         l_new_val6(l_tab_counter) := p_new_rec.region_3;
         end if;
      end if;
    end if;
  end if;
--
  hr_utility.set_location('Continuing:'|| l_proc, 20);
  hr_utility.set_location('BGP ID:'||p_new_rec.business_group_id||' '||l_proc, 30);
  for l_count in 1..l_chg_evt_tab.count loop
   if change_event_is_enabled(l_chg_evt_tab(l_count),trunc(sysdate)) then
      if l_chg_evt_tab(l_count) in ('CCPA','CCMA','CCNPA','CCNMA') then
        l_person_id := nvl(l_prmtr_07_tab(l_count),l_relationship);
      end if;
      ben_ext_chg_evt_api.create_ext_chg_evt
        (p_validate                    => FALSE
        ,p_ext_chg_evt_log_id          => l_ext_chg_evt_log_id
        ,p_chg_evt_cd                  => l_chg_evt_tab(l_count)
        ,p_chg_eff_dt                  => l_chg_eff_tab(l_count)
        ,p_person_id                   => l_person_id
        --
        -- <BUG_FIX> Passed in old rec rather than new rec on delete
        --           no new rec will exist
        --
        ,p_prmtr_01                    => l_prmtr_01_tab(l_count)
        ,p_prmtr_02                    => l_prmtr_02_tab(l_count)
        ,p_prmtr_03                    => l_prmtr_03_tab(l_count)
        ,p_prmtr_04                    => l_prmtr_04_tab(l_count)
        ,p_prmtr_05                    => l_prmtr_05_tab(l_count)
        ,p_prmtr_06                    => l_prmtr_06_tab(l_count)
        ,p_prmtr_07                    => l_prmtr_07_tab(l_count)
        ,p_business_group_id           => l_business_group_id
        ,p_object_version_number       => l_object_version_number
        ,p_effective_date              => trunc(sysdate)
        ,p_old_val1                    => l_old_val1(l_count)
        ,p_old_val2                    => l_old_val2(l_count)
        ,p_old_val3                    => l_old_val3(l_count)
        ,p_old_val4                    => l_old_val4(l_count)
        ,p_old_val5                    => l_old_val5(l_count)
        ,p_old_val6                    => l_old_val6(l_count)
        ,p_new_val1                    => l_new_val1(l_count)
        ,p_new_val2                    => l_new_val2(l_count)
        ,p_new_val3                    => l_new_val3(l_count)
        ,p_new_val4                    => l_new_val4(l_count)
        ,p_new_val5                    => l_new_val5(l_count)
        ,p_new_val6                    => l_new_val6(l_count)
        );
   end if;
  end loop;
--
  hr_utility.set_location('Exiting:'|| l_proc, 99);
--
end log_add_chg;

----- this is a overlaod procedure to call from core HR
procedure log_asg_chg
  (p_event        in   varchar2
  ,p_old_rec      in   per_asg_shd.g_rec_type
  ,p_new_rec      in   per_asg_shd.g_rec_type
  ) is

  l_old_rec           ben_ext_chlg.g_asg_rec_type;
  l_new_rec           ben_ext_chlg.g_asg_rec_type;
  l_event             varchar2(10) ;
--
  l_proc               varchar2(100) := 'ben_ext_chlg.log_asg_chg';
begin

  hr_utility.set_location('Entering:'|| l_proc, 05);
  -------------
  l_old_rec.assignment_id  := p_old_rec.assignment_id;
  l_old_rec.assignment_status_type_id  := p_old_rec.assignment_status_type_id;
  l_old_rec.hourly_salaried_code  := p_old_rec.hourly_salaried_code;
  l_old_rec.normal_hours := p_old_rec.normal_hours;
  l_old_rec.location_id := p_old_rec.location_id;
  l_old_rec.position_id := p_old_rec.position_id;
  l_old_rec.employment_category := p_old_rec.employment_category;
  l_old_rec.person_id := p_old_rec.person_id;
  l_old_rec.assignment_type := p_old_rec.assignment_type;
  l_old_rec.business_group_id := p_old_rec.business_group_id;
  l_old_rec.effective_start_date :=p_old_rec.effective_start_date;
  l_old_rec.effective_end_date :=p_old_rec.effective_end_date;
  l_old_rec.ass_attribute1 :=p_old_rec.ass_attribute1;
  l_old_rec.ass_attribute2 :=p_old_rec.ass_attribute2;
  l_old_rec.ass_attribute3 :=p_old_rec.ass_attribute3;
  l_old_rec.ass_attribute4 :=p_old_rec.ass_attribute4;
  l_old_rec.ass_attribute5 :=p_old_rec.ass_attribute5;
  l_old_rec.ass_attribute6 :=p_old_rec.ass_attribute6;
  l_old_rec.ass_attribute7 :=p_old_rec.ass_attribute7;
  l_old_rec.ass_attribute8 :=p_old_rec.ass_attribute8;
  l_old_rec.ass_attribute9 :=p_old_rec.ass_attribute9;
  l_old_rec.ass_attribute10 :=p_old_rec.ass_attribute10;
  l_old_rec.payroll_id :=p_old_rec.payroll_id;
  l_old_rec.grade_id :=p_old_rec.grade_id;
  l_old_rec.primary_flag := p_old_rec.primary_flag;
  l_old_rec.soft_coding_keyflex_id := p_old_rec.soft_coding_keyflex_id;

-----------------------------new record---------------------
  l_new_rec.assignment_id  := p_new_rec.assignment_id ;
  l_new_rec.assignment_status_type_id  := p_new_rec.assignment_status_type_id ;
  l_new_rec.hourly_salaried_code  := p_new_rec.hourly_salaried_code;
  l_new_rec.normal_hours := p_new_rec.normal_hours;
  l_new_rec.location_id := p_new_rec.location_id;
  l_new_rec.position_id := p_new_rec.position_id;
  l_new_rec.employment_category := p_new_rec.employment_category;
  l_new_rec.person_id := p_new_rec.person_id;
  l_new_rec.assignment_type := p_new_rec.assignment_type;
  l_new_rec.business_group_id := p_new_rec.business_group_id;
  l_new_rec.effective_start_date :=p_new_rec.effective_start_date;
  l_new_rec.effective_end_date :=p_new_rec.effective_end_date;
  l_new_rec.ass_attribute1 :=p_new_rec.ass_attribute1;
  l_new_rec.ass_attribute2 :=p_new_rec.ass_attribute2;
  l_new_rec.ass_attribute3 :=p_new_rec.ass_attribute3;
  l_new_rec.ass_attribute4 :=p_new_rec.ass_attribute4;
  l_new_rec.ass_attribute5 :=p_new_rec.ass_attribute5;
  l_new_rec.ass_attribute6 :=p_new_rec.ass_attribute6;
  l_new_rec.ass_attribute7 :=p_new_rec.ass_attribute7;
  l_new_rec.ass_attribute8 :=p_new_rec.ass_attribute8;
  l_new_rec.ass_attribute9 :=p_new_rec.ass_attribute9;
  l_new_rec.ass_attribute10 :=p_new_rec.ass_attribute10;
  l_new_rec.payroll_id :=p_new_rec.payroll_id;
  l_new_rec.grade_id :=p_new_rec.grade_id;
  l_new_rec.primary_flag := p_new_rec.primary_flag;
  l_new_rec.soft_coding_keyflex_id := p_new_rec.soft_coding_keyflex_id;
  ---------------------

  if p_new_rec.effective_start_date = p_old_rec.effective_start_date then
    l_new_rec.update_mode := 'CORRECTION';
    l_old_rec.update_mode := 'CORRECTION';
  else
    l_new_rec.update_mode := 'UPDATE';
    l_old_rec.update_mode := 'UPDATE';
  end if;

  l_event  := nvl(p_event ,'UPDATE') ;
  ---------------
  log_asg_chg
  (p_event   => p_event
  ,p_old_rec => l_old_rec
  ,p_new_rec => l_new_rec
  );
  ---------------

  hr_utility.set_location('Exiting:'|| l_proc, 99);

end ;
--
procedure log_asg_chg
          (p_event     in  varchar2
          ,p_old_rec   in  g_asg_rec_type
          ,p_new_rec   in  g_asg_rec_type
          ) is
--
  l_chg_evt_tab           g_char_tab_type;
  l_prmtr_01_tab          g_char_tab_type;
  l_prmtr_02_tab          g_char_tab_type;
  l_prmtr_03_tab          g_char_tab_type;
  l_prmtr_04_tab          g_char_tab_type;
  l_prmtr_05_tab          g_char_tab_type;
  l_prmtr_06_tab          g_char_tab_type;
  l_prmtr_07_tab          g_char_tab_type;
  l_new_val1              g_new_val;
  l_new_val2              g_new_val;
  l_new_val3              g_new_val;
  l_new_val4              g_new_val;
  l_new_val5              g_new_val;
  l_new_val6              g_new_val;
  l_old_val1              g_old_val;
  l_old_val2              g_old_val;
  l_old_val3              g_old_val;
  l_old_val4              g_old_val;
  l_old_val5              g_old_val;
  l_old_val6              g_old_val;
  l_tab_counter           binary_integer := 0;
  l_chg_eff_dt            date;
  l_count                 number;
  l_ext_chg_evt_log_id    number;
  l_object_version_number number;
--


  cursor c_position(p_position_id number ,
                    p_effective_date date )
  is
  select name
  from HR_ALL_POSITIONS_F   pos
  where pos.position_id = p_position_id
   and  p_effective_date between nvl(pos.effective_start_date, sysdate)
                       and nvl(pos.effective_end_date, sysdate)
  ;


  cursor c_location(p_location_id hr_locations_all.location_id%type)
  is
  select location_code
  from hr_locations_all hl
  where hl.location_id = p_location_id;

  cursor c_assignment_status
    (p_assignment_status_type_id per_assignment_status_types.assignment_status_type_id%type)
  is
  select ast.user_status
  from per_assignment_status_types ast
  where ast.assignment_status_type_id = p_assignment_status_type_id;

  cursor c_payroll_name
    (p_payroll_id     pay_all_payrolls_f.payroll_id%type
    ,p_effective_date date)
  is
  select ppf.payroll_name
  from pay_all_payrolls_f ppf
  where payroll_id = p_payroll_id
  and p_effective_date between nvl(ppf.effective_start_date, sysdate)
                       and nvl(ppf.effective_end_date, sysdate);

  cursor c_grade_name
    (p_grade_id number ,p_effective_date date) is
    select g.name
    from per_grades g
    where g.grade_id = p_grade_id
      and g.date_from <= p_effective_date
      and ((g.date_to is null) or (g.date_to >= p_effective_date )) ;
--

  l_old_position           HR_ALL_POSITIONS_F.name%type;
  l_new_position           HR_ALL_POSITIONS_F.name%type;
  l_old_location          hr_locations_all.location_code%type; -- UTF Change Bug 2254683
  l_new_location          hr_locations_all.location_code%type; -- UTF Change Bug 2254683
  l_old_assignment_status per_assignment_status_types.user_status%type; -- UTF Change Bug 2254683
  l_new_assignment_status per_assignment_status_types.user_status%type; -- UTF Change Bug 2254683
  l_old_payroll_name      pay_all_payrolls_f.payroll_name%type; --UTF Change Bug 2254683
  l_new_payroll_name      pay_all_payrolls_f.payroll_name%type; --UTF Change Bug 2254683
  l_old_grade_name        per_grades.name%type;
  l_new_grade_name        per_grades.name%type;
--
  l_proc          varchar2(80) := 'ben_ext_chlg.log_asg_chg';
--
begin
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
--
  if p_event = 'UPDATE' then
--
    if nvl(p_old_rec.assignment_status_type_id, 1)
        <> nvl(p_new_rec.assignment_status_type_id, 1) then

      -- read old and new assignment status
      open c_assignment_status(p_old_rec.assignment_status_type_id);
      fetch c_assignment_status into l_old_assignment_status;
      close c_assignment_status;
      open c_assignment_status(p_new_rec.assignment_status_type_id);
      fetch c_assignment_status into l_new_assignment_status;
      close c_assignment_status;

      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COAS';
      l_prmtr_01_tab(l_tab_counter) := p_old_rec.assignment_id;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter)     := l_old_assignment_status;
      l_new_val1(l_tab_counter)     := l_new_assignment_status;
    end if;
    if nvl(p_old_rec.hourly_salaried_code, '$')
        <> nvl(p_new_rec.hourly_salaried_code, '$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COHS';
      l_prmtr_01_tab(l_tab_counter) := p_old_rec.assignment_id;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter)     := p_old_rec.hourly_salaried_code;
      l_new_val1(l_tab_counter)     := p_new_rec.hourly_salaried_code;
    end if;
    if nvl(p_old_rec.location_id, 1)
        <> nvl(p_new_rec.location_id, 1) then
      -- read old and new locations
      open c_location(p_old_rec.location_id);
      fetch c_location into l_old_location;
      close c_location;
      open c_location(p_new_rec.location_id);
      fetch c_location into l_new_location;
      close c_location;
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COAL';
      l_prmtr_01_tab(l_tab_counter) := p_old_rec.assignment_id;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter)     := l_old_location;
      l_new_val1(l_tab_counter)     := l_new_location;
    end if;

    if nvl(p_old_rec.position_id, 1)
        <> nvl(p_new_rec.position_id, 1) then
      -- read old and new position
      open c_position(p_old_rec.position_id , p_new_rec.effective_start_date  );
      fetch c_position into l_old_position;
      close c_position;
      open c_position(p_new_rec.position_id , p_new_rec.effective_start_date );
      fetch c_position into l_new_position;
      close c_position;
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COAPOS';
      l_prmtr_01_tab(l_tab_counter) := p_old_rec.assignment_id;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter)     := l_old_position;
      l_new_val1(l_tab_counter)     := l_new_position;
    end if;

    if nvl(p_old_rec.employment_category, '$')
        <> nvl(p_new_rec.employment_category, '$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COEC';
      l_prmtr_01_tab(l_tab_counter) := p_old_rec.assignment_id;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter)     := HR_GENERAL.DECODE_LOOKUP('EMP_CAT',p_old_rec.employment_category); --bug#4699913
      l_new_val1(l_tab_counter)     := HR_GENERAL.DECODE_LOOKUP('EMP_CAT',p_new_rec.employment_category); --bug#4699913;
    end if;
    if nvl(p_old_rec.assignment_type, '$') <> 'B' and p_new_rec.assignment_type = 'B' then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'ABA';
      l_prmtr_01_tab(l_tab_counter) := p_old_rec.assignment_id;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter)     := null;
      l_new_val1(l_tab_counter)     := null;
    end if;
    if nvl(p_old_rec.ass_attribute1, '$')
        <> nvl(p_new_rec.ass_attribute1, '$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COAF01';
      l_prmtr_01_tab(l_tab_counter) := p_old_rec.assignment_id;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter)     := p_old_rec.ass_attribute1;
      l_new_val1(l_tab_counter)     := p_new_rec.ass_attribute1;
    end if;
    if nvl(p_old_rec.ass_attribute2, '$')
        <> nvl(p_new_rec.ass_attribute2, '$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COAF02';
      l_prmtr_01_tab(l_tab_counter) := p_old_rec.assignment_id;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter)     := p_old_rec.ass_attribute2;
      l_new_val1(l_tab_counter)     := p_new_rec.ass_attribute2;
    end if;
    if nvl(p_old_rec.ass_attribute3, '$')
        <> nvl(p_new_rec.ass_attribute3, '$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COAF03';
      l_prmtr_01_tab(l_tab_counter) := p_old_rec.assignment_id;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter)     := p_old_rec.ass_attribute3;
      l_new_val1(l_tab_counter)     := p_new_rec.ass_attribute3;
    end if;
    if nvl(p_old_rec.ass_attribute4, '$')
        <> nvl(p_new_rec.ass_attribute4, '$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COAF04';
      l_prmtr_01_tab(l_tab_counter) := p_old_rec.assignment_id;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter)     := p_old_rec.ass_attribute4;
      l_new_val1(l_tab_counter)     := p_new_rec.ass_attribute4;
    end if;
    if nvl(p_old_rec.ass_attribute5, '$')
        <> nvl(p_new_rec.ass_attribute5, '$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COAF05';
      l_prmtr_01_tab(l_tab_counter) := p_old_rec.assignment_id;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter)     := p_old_rec.ass_attribute5;
      l_new_val1(l_tab_counter)     := p_new_rec.ass_attribute5;
    end if;
    if nvl(p_old_rec.ass_attribute6, '$')
        <> nvl(p_new_rec.ass_attribute6, '$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COAF06';
      l_prmtr_01_tab(l_tab_counter) := p_old_rec.assignment_id;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter)     := p_old_rec.ass_attribute6;
      l_new_val1(l_tab_counter)     := p_new_rec.ass_attribute6;
    end if;
    if nvl(p_old_rec.ass_attribute7, '$')
        <> nvl(p_new_rec.ass_attribute7, '$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COAF07';
      l_prmtr_01_tab(l_tab_counter) := p_old_rec.assignment_id;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter)     := p_old_rec.ass_attribute7;
      l_new_val1(l_tab_counter)     := p_new_rec.ass_attribute7;
    end if;
    if nvl(p_old_rec.ass_attribute8, '$')
        <> nvl(p_new_rec.ass_attribute8, '$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COAF08';
      l_prmtr_01_tab(l_tab_counter) := p_old_rec.assignment_id;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter)     := p_old_rec.ass_attribute8;
      l_new_val1(l_tab_counter)     := p_new_rec.ass_attribute8;
    end if;
    if nvl(p_old_rec.ass_attribute9, '$')
        <> nvl(p_new_rec.ass_attribute9, '$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COAF09';
      l_prmtr_01_tab(l_tab_counter) := p_old_rec.assignment_id;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter)     := p_old_rec.ass_attribute9;
      l_new_val1(l_tab_counter)     := p_new_rec.ass_attribute9;
    end if;
    if nvl(p_old_rec.ass_attribute10, '$')
        <> nvl(p_new_rec.ass_attribute10, '$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COAF10';
      l_prmtr_01_tab(l_tab_counter) := p_old_rec.assignment_id;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter)     := p_old_rec.ass_attribute10;
      l_new_val1(l_tab_counter)     := p_new_rec.ass_attribute10;
    end if;
    if (nvl(p_old_rec.payroll_id, -1)
        <> nvl(p_new_rec.payroll_id, -1))
        --RCHASE make sure the payroll is a change and not an add
        and (p_old_rec.payroll_id is not null) then
      open c_payroll_name(p_old_rec.payroll_id, p_new_rec.effective_start_date);
      fetch c_payroll_name into l_old_payroll_name;
      close c_payroll_name;
      open c_payroll_name(p_new_rec.payroll_id, p_new_rec.effective_start_date);
      fetch c_payroll_name into l_new_payroll_name;
      close c_payroll_name;
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COPP';
      l_prmtr_01_tab(l_tab_counter) := p_old_rec.assignment_id;
      l_prmtr_02_tab(l_tab_counter) := p_old_rec.payroll_id;
      l_prmtr_03_tab(l_tab_counter) := p_new_rec.payroll_id;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter)     := l_old_payroll_name;
      l_new_val1(l_tab_counter)     := l_new_payroll_name;
    end if;
    if (nvl(p_old_rec.grade_id, -1)
        <> nvl(p_new_rec.grade_id, -1))  then
      open c_grade_name(p_old_rec.grade_id, p_new_rec.effective_start_date);
      fetch c_grade_name into l_old_grade_name;
      close c_grade_name;
      open c_grade_name(p_new_rec.grade_id, p_new_rec.effective_start_date);
      fetch c_grade_name into l_new_grade_name;
      close c_grade_name;
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CGRDID';
      l_prmtr_01_tab(l_tab_counter) := p_old_rec.assignment_id;
      l_prmtr_02_tab(l_tab_counter) := p_old_rec.grade_id;
      l_prmtr_03_tab(l_tab_counter) := p_new_rec.grade_id;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter)     := l_old_grade_name;
      l_new_val1(l_tab_counter)     := l_new_grade_name;
    end if;

--Start Bug 1554477
    if nvl(p_old_rec.normal_hours, '0')
        <> nvl(p_new_rec.normal_hours, '0') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CWH';
      l_prmtr_01_tab(l_tab_counter) := p_old_rec.assignment_id;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter)     := p_old_rec.normal_hours;
      l_new_val1(l_tab_counter)     := p_new_rec.normal_hours;
    end if;
  --End Bug 1554477
  --
  -- vjhanak
  if nvl(p_old_rec.soft_coding_keyflex_id, '0')
        <> nvl(p_new_rec.soft_coding_keyflex_id, '0') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COSCKFF';
      l_prmtr_01_tab(l_tab_counter) := p_old_rec.assignment_id;
      l_prmtr_02_tab(l_tab_counter) := fnd_date.date_to_canonical(TRUNC(p_old_rec.effective_start_date));
      l_prmtr_03_tab(l_tab_counter) := fnd_date.date_to_canonical(TRUNC(p_old_rec.effective_end_date));
      l_prmtr_04_tab(l_tab_counter) := fnd_date.date_to_canonical(TRUNC(p_new_rec.effective_start_date));
      l_prmtr_05_tab(l_tab_counter) := fnd_date.date_to_canonical(TRUNC(p_new_rec.effective_end_date));
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter)     := p_old_rec.soft_coding_keyflex_id;
      l_new_val1(l_tab_counter)     := p_new_rec.soft_coding_keyflex_id;
    end if;
  -- vjhanak

  elsif p_event = 'INSERT' then
    if p_new_rec.assignment_type = 'B' then
      --l_person_id          := p_new_rec.person_id;
      --l_business_group_id  := p_new_rec.business_group_id;
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'ABA';
      l_prmtr_01_tab(l_tab_counter) := p_new_rec.assignment_id;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter)     := null;
      l_new_val1(l_tab_counter)     := null;
    end if;

    -- rpinjala
    IF p_new_rec.assignment_type   = 'E' AND
       nvl(p_new_rec.primary_flag,'N') = 'N'    THEN
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'ASEA';
      l_prmtr_01_tab(l_tab_counter) := p_new_rec.assignment_id;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter)     := null;
      l_new_val1(l_tab_counter)     := p_new_rec.effective_start_date;
    END IF;
    -- rpinjala

    --Start Bug 1554477
    if p_new_rec.normal_hours is not null then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CWH';
      l_prmtr_01_tab(l_tab_counter) := p_new_rec.assignment_id;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter)     := null;
      l_new_val1(l_tab_counter)     := p_new_rec.normal_hours;
    end if;
  --End Bug 1554477
  --
  end if;
--
  for l_count in 1..l_chg_evt_tab.count loop
   if change_event_is_enabled(l_chg_evt_tab(l_count),p_new_rec.effective_start_date) then
    ben_ext_chg_evt_api.create_ext_chg_evt
    (p_validate                    => FALSE
    ,p_ext_chg_evt_log_id          => l_ext_chg_evt_log_id
    ,p_chg_evt_cd                  => l_chg_evt_tab(l_count)
    ,p_chg_eff_dt                  => p_new_rec.effective_start_date
    ,p_prmtr_01                    => l_prmtr_01_tab(l_count)
    ,p_prmtr_02                    => l_prmtr_02_tab(l_count)
    ,p_prmtr_03                    => l_prmtr_03_tab(l_count)
    ,p_prmtr_04                    => l_prmtr_04_tab(l_count)
    ,p_prmtr_05                    => l_prmtr_05_tab(l_count)
    ,p_prmtr_06                    => l_prmtr_06_tab(l_count)
    ,p_prmtr_07                    => l_prmtr_07_tab(l_count)
    ,p_prmtr_10                    => p_new_rec.update_mode
    ,p_person_id                   => p_new_rec.person_id
    ,p_business_group_id           => p_new_rec.business_group_id
    ,p_object_version_number       => l_object_version_number
    ,p_effective_date              => p_new_rec.effective_start_date
    ,p_new_val1                    => l_new_val1(l_count)
    ,p_old_val1                    => l_old_val1(l_count)
    );
   end if;
  end loop;
--
  hr_utility.set_location('Exiting:'|| l_proc, 99);
--
end log_asg_chg;
--
procedure log_abs_chg
          (p_event     in  varchar2
          ,p_old_rec   in  g_abs_rec_type
          ,p_new_rec   in  g_abs_rec_type
          ) is
--
  l_chg_evt_tab           g_char_tab_type;
  l_prmtr_01_tab          g_char_tab_type;
  l_prmtr_02_tab          g_char_tab_type;
  l_prmtr_03_tab          g_char_tab_type;
  l_prmtr_04_tab          g_char_tab_type;
  l_prmtr_05_tab          g_char_tab_type;
  l_prmtr_06_tab          g_char_tab_type;
  l_prmtr_07_tab          g_char_tab_type;
  l_new_val1              g_new_val;
  l_new_val2              g_new_val;
  l_new_val3              g_new_val;
  l_new_val4              g_new_val;
  l_new_val5              g_new_val;
  l_new_val6              g_new_val;
  l_old_val1              g_old_val;
  l_old_val2              g_old_val;
  l_old_val3              g_old_val;
  l_old_val4              g_old_val;
  l_old_val5              g_old_val;
  l_old_val6              g_old_val;
  l_tab_counter           binary_integer := 0;
  l_chg_eff_dt            date;
  l_person_id             number;
  l_business_group_id     number;
  l_count                 number;
  l_ext_chg_evt_log_id    number;
  l_object_version_number number;
--
  l_old_absence_type          varchar2(100);
  l_new_absence_type          varchar2(100);
  l_old_absence_reason        varchar2(100);
  l_new_absence_reason        varchar2(100);
--
  l_proc          varchar2(80) := 'ben_ext_chlg.log_abs_chg';
--
-- cursor definitions
--
  cursor c_absence_type(p_absence_attendance_type_id number)
  is
  select aat.name
  from per_absence_attendance_types aat
  where aat.absence_attendance_type_id = p_absence_attendance_type_id;

  cursor c_absence_reason(p_abs_attendance_reason_id  number)
  is
  select aar.name
  from per_abs_attendance_reasons aar
  where aar.abs_attendance_reason_id = p_abs_attendance_reason_id;
--
begin
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
--
  if p_event = 'UPDATE' then
--
    l_business_group_id := p_new_rec.business_group_id;
    l_person_id := p_new_rec.person_id;
    if nvl(p_old_rec.abs_attendance_reason_id, 1)
        <> nvl(p_new_rec.abs_attendance_reason_id, 1) then

      -- get old and new absence reason
      open c_absence_reason(p_old_rec.abs_attendance_reason_id);
      fetch c_absence_reason into l_old_absence_reason;
      close c_absence_reason;
      open c_absence_reason(p_new_rec.abs_attendance_reason_id);
      fetch c_absence_reason into l_new_absence_reason;
      close c_absence_reason;

      l_chg_eff_dt := trunc(sysdate);
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COAR';
      l_prmtr_01_tab(l_tab_counter) := p_old_rec.absence_attendance_id;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter)     := l_old_absence_reason;
      l_old_val2(l_tab_counter)     := null;
      l_old_val3(l_tab_counter)     := null;
      l_old_val4(l_tab_counter)     := null;
      l_new_val1(l_tab_counter)     := l_new_absence_reason;
      l_new_val2(l_tab_counter)     := null;
      l_new_val3(l_tab_counter)     := null;
      l_new_val4(l_tab_counter)     := null;
    end if;
    if nvl(p_old_rec.date_start, to_date('01/01/0001', 'dd/mm/yyyy'))
        <> nvl(p_new_rec.date_start, to_date('01/01/0001', 'dd/mm/yyyy')) then
      l_chg_eff_dt := trunc(sysdate);
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COAAS';
      l_prmtr_01_tab(l_tab_counter) := p_old_rec.absence_attendance_id;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter)     := to_char(p_old_rec.date_start, 'mm/dd/yyyy');
      l_old_val2(l_tab_counter)     := null;
      l_old_val3(l_tab_counter)     := null;
      l_old_val4(l_tab_counter)     := null;
      l_new_val1(l_tab_counter)     := to_char(p_new_rec.date_start, 'mm/dd/yyyy');
      l_new_val2(l_tab_counter)     := null;
      l_new_val3(l_tab_counter)     := null;
      l_new_val4(l_tab_counter)     := null;
    end if;
    if nvl(p_old_rec.date_end, to_date('01/01/0001', 'dd/mm/yyyy'))
        <> nvl(p_new_rec.date_end, to_date('01/01/0001', 'dd/mm/yyyy')) then
      l_chg_eff_dt := trunc(sysdate);
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'COAAE';
      l_prmtr_01_tab(l_tab_counter) := p_old_rec.absence_attendance_id;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter)     := to_char(p_old_rec.date_end, 'mm/dd/yyyy');
      l_old_val2(l_tab_counter)     := null;
      l_old_val3(l_tab_counter)     := null;
      l_old_val4(l_tab_counter)     := null;
      l_new_val1(l_tab_counter)     := to_char(p_new_rec.date_end, 'mm/dd/yyyy');
      l_new_val2(l_tab_counter)     := null;
      l_new_val3(l_tab_counter)     := null;
      l_new_val4(l_tab_counter)     := null;
    end if;
  --
  elsif p_event = 'INSERT' then
  --
    open c_absence_type(p_new_rec.absence_attendance_type_id);
    fetch c_absence_type into l_new_absence_type;
    close c_absence_type;
    open c_absence_reason(p_new_rec.abs_attendance_reason_id);
    fetch c_absence_reason into l_new_absence_reason;
    close c_absence_reason;
    --
    l_business_group_id := p_new_rec.business_group_id;
    l_person_id := p_new_rec.person_id;
    l_chg_eff_dt := trunc(nvl(nvl(p_new_rec.date_start,p_new_rec.date_projected_start), sysdate));
    l_tab_counter := l_tab_counter + 1;
    l_chg_evt_tab(l_tab_counter) := 'AA';
    l_prmtr_01_tab(l_tab_counter) := p_new_rec.absence_attendance_id;
    l_prmtr_02_tab(l_tab_counter) := null;
    l_prmtr_03_tab(l_tab_counter) := null;
    l_prmtr_04_tab(l_tab_counter) := null;
    l_prmtr_05_tab(l_tab_counter) := null;
    l_prmtr_06_tab(l_tab_counter) := null;
    l_prmtr_07_tab(l_tab_counter) := null;
    l_old_val1(l_tab_counter)     := null;
    l_old_val2(l_tab_counter)     := null;
    l_old_val3(l_tab_counter)     := null;
    l_old_val4(l_tab_counter)     := null;
    l_new_val1(l_tab_counter)     := l_new_absence_type;
    l_new_val2(l_tab_counter)     := l_new_absence_reason;
    l_new_val3(l_tab_counter)     := p_new_rec.date_start;
    l_new_val4(l_tab_counter)     := p_new_rec.date_end;
  --
  elsif p_event = 'DELETE' then
  --
    open c_absence_type(p_old_rec.absence_attendance_type_id);
    fetch c_absence_type into l_old_absence_type;
    close c_absence_type;
    open c_absence_reason(p_old_rec.abs_attendance_reason_id);
    fetch c_absence_reason into l_old_absence_reason;
    close c_absence_reason;
    --
    l_business_group_id := p_old_rec.business_group_id;
    l_person_id := p_old_rec.person_id;
    l_chg_eff_dt := trunc(sysdate);
    l_tab_counter := l_tab_counter + 1;
    l_chg_evt_tab(l_tab_counter) := 'DA';
    l_prmtr_01_tab(l_tab_counter) := p_old_rec.absence_attendance_id;
    l_prmtr_02_tab(l_tab_counter) := null;
    l_prmtr_03_tab(l_tab_counter) := null;
    l_prmtr_04_tab(l_tab_counter) := null;
    l_prmtr_05_tab(l_tab_counter) := null;
    l_prmtr_06_tab(l_tab_counter) := null;
    l_prmtr_07_tab(l_tab_counter) := null;
    l_old_val1(l_tab_counter)     := l_old_absence_type;
    l_old_val2(l_tab_counter)     := l_old_absence_reason;
    l_old_val3(l_tab_counter)     := p_old_rec.date_start;
    l_old_val4(l_tab_counter)     := p_old_rec.date_end;
    l_new_val1(l_tab_counter)     := null;
    l_new_val2(l_tab_counter)     := null;
    l_new_val3(l_tab_counter)     := null;
    l_new_val4(l_tab_counter)     := null;
  --
  end if;
  --
--
  for l_count in 1..l_chg_evt_tab.count loop
   if change_event_is_enabled(l_chg_evt_tab(l_count),l_chg_eff_dt) then
    ben_ext_chg_evt_api.create_ext_chg_evt
    (p_validate                    => FALSE
    ,p_ext_chg_evt_log_id          => l_ext_chg_evt_log_id
    ,p_chg_evt_cd                  => l_chg_evt_tab(l_count)
    ,p_chg_eff_dt                  => l_chg_eff_dt
    ,p_prmtr_01                    => l_prmtr_01_tab(l_count)
    ,p_prmtr_02                    => l_prmtr_02_tab(l_count)
    ,p_prmtr_03                    => l_prmtr_03_tab(l_count)
    ,p_prmtr_04                    => l_prmtr_04_tab(l_count)
    ,p_prmtr_05                    => l_prmtr_05_tab(l_count)
    ,p_prmtr_06                    => l_prmtr_06_tab(l_count)
    ,p_prmtr_07                    => l_prmtr_07_tab(l_count)
    ,p_prmtr_10                    => p_new_rec.update_mode
    ,p_person_id                   => l_person_id
    ,p_business_group_id           => l_business_group_id
    ,p_object_version_number       => l_object_version_number
    ,p_effective_date              => l_chg_eff_dt
    ,p_new_val1                    => l_new_val1(l_count)
    ,p_new_val2                    => l_new_val2(l_count)
    ,p_new_val3                    => l_new_val3(l_count)
    ,p_new_val4                    => l_new_val4(l_count)
    ,p_old_val1                    => l_old_val1(l_count)
    ,p_old_val2                    => l_old_val2(l_count)
    ,p_old_val3                    => l_old_val3(l_count)
    ,p_old_val4                    => l_old_val4(l_count)
    );
   end if;
  end loop;
--
  hr_utility.set_location('Exiting:'|| l_proc, 99);
--
end log_abs_chg;
--
--
procedure log_benefit_chg(
        p_action                in varchar2, -- CREATE, REINSTATE, UPDATE, or DELETE
        p_pl_id                in number default null,
        p_old_pl_id            in number default null,
        p_oipl_id              in number default null,
        p_old_oipl_id          in number default null,
        p_enrt_cvg_strt_dt     in date default null,
        p_enrt_cvg_end_dt      in date default null,
        p_old_enrt_cvg_strt_dt in date default null,
        p_old_enrt_cvg_end_dt  in date default null,
        p_bnft_amt             in number default null,
        p_old_bnft_amt         in number default null,
        p_pen_attribute1       in varchar2 default null,
        p_pen_attribute2       in varchar2 default null,
        p_pen_attribute3       in varchar2 default null,
        p_pen_attribute4       in varchar2 default null,
        p_pen_attribute5       in varchar2 default null,
        p_pen_attribute6       in varchar2 default null,
        p_pen_attribute7       in varchar2 default null,
        p_pen_attribute8       in varchar2 default null,
        p_pen_attribute9       in varchar2 default null,
        p_pen_attribute10      in varchar2 default null,
        p_old_pen_attribute1   in varchar2 default null,
        p_old_pen_attribute2   in varchar2 default null,
        p_old_pen_attribute3   in varchar2 default null,
        p_old_pen_attribute4   in varchar2 default null,
        p_old_pen_attribute5   in varchar2 default null,
        p_old_pen_attribute6   in varchar2 default null,
        p_old_pen_attribute7   in varchar2 default null,
        p_old_pen_attribute8   in varchar2 default null,
        p_old_pen_attribute9   in varchar2 default null,
        p_old_pen_attribute10  in varchar2 default null,
        p_effective_start_date in date default null,
        p_effective_end_date   in date default null,
        p_prtt_enrt_rslt_id    in number default null,
        p_old_prtt_enrt_rslt_id in number default null,
        p_per_in_ler_id        in number default null,
        p_old_per_in_ler_id    in number default null,
        p_person_id            in number,
        p_business_group_id    in number,
        p_effective_date       in date ) is

  -- Local variable declarations
  --
  l_proc         varchar2(72) := 'ben_ext_chlg.log_benefit_chg';

  l_new_plan_name              ben_pl_f.name%type;
  l_old_plan_name              ben_pl_f.name%type;
  l_new_option_name            ben_opt_f.name%type;
  l_old_option_name            ben_opt_f.name%type;
  --
  l_ext_chg_evt_log_id number;
  l_object_version_number number;
  --
  -- Cursor declarations.
  cursor c_plan_name(p_pl_id number)
  is
  select name
  from ben_pl_f pl
  where pl.pl_id = p_pl_id
  and p_effective_date between pl.effective_start_date and pl.effective_end_date;

  cursor c_option_name(p_oipl_id number)
  is
  select opt.name
  from ben_oipl_f cop,
       ben_opt_f opt
  where cop.oipl_id = p_oipl_id
  and p_effective_date between cop.effective_start_date and cop.effective_end_date
  and cop.opt_id = opt.opt_id
  and p_effective_date between opt.effective_start_date and opt.effective_end_date;
  --
  begin
    --
    hr_utility.set_location('Entering:'||l_proc, 10);
    --
    -- Get the new values to be store or updated
    --
    if p_prtt_enrt_rslt_id is not null then
       --  fetch descriptions for old and new values.
       null;
    end if;
    --
    if p_action = 'CREATE' then
      --
      open c_plan_name(p_pl_id);
      fetch c_plan_name into l_new_plan_name;
      close c_plan_name;
      open c_option_name(p_oipl_id);
      fetch c_option_name into l_new_option_name;
      close c_option_name;
      --
     /* updating benefit amount actually creates a new result.
      so we need to add the following check to see if it's only
      a benefit amount update in which case we want the change log
      to show 'Update enrollment coverage amount'--shdas*/

      if p_old_pl_id is not null and p_pl_id = p_old_pl_id then
           if p_old_oipl_id is null or (p_old_oipl_id
           is not null and p_oipl_id = p_old_oipl_id) then
              if nvl(p_bnft_amt,0) <> nvl(p_old_bnft_amt,0) and
              change_event_is_enabled('COECA',p_effective_date) then
                 ben_ext_chg_evt_api.create_ext_chg_evt
                 (p_validate                    => FALSE
                 ,p_ext_chg_evt_log_id          => l_ext_chg_evt_log_id
                 ,p_chg_evt_cd                  => 'COECA'  -- Change Coverage Amount
                 ,p_chg_eff_dt                  => p_effective_date
                 ,p_prmtr_01                    => to_char(p_pl_id)
                 ,p_prmtr_02                    => to_char(p_oipl_id)
                 ,p_prmtr_03                    => to_char(p_prtt_enrt_rslt_id)
                 ,p_prmtr_05                    => to_char(p_per_in_ler_id)
                 ,p_person_id                   => p_person_id
                 ,p_business_group_id           => p_business_group_id
                 ,p_object_version_number       => l_object_version_number
                 ,p_effective_date              => p_effective_date
                 ,p_old_val1                    => p_old_bnft_amt
                 ,p_new_val1                    => p_bnft_amt
                 );
               end if;
            end if;
        --
      else

      if change_event_is_enabled('AB',p_effective_date) then
       ben_ext_chg_evt_api.create_ext_chg_evt
      (p_validate                    => FALSE
      ,p_ext_chg_evt_log_id          => l_ext_chg_evt_log_id
      ,p_chg_evt_cd                  => 'AB'  -- Add Benefit
      ,p_chg_eff_dt                  => p_effective_date
      ,p_prmtr_01                    => to_char(p_pl_id)
      ,p_prmtr_02                    => to_char(p_oipl_id)
      ,p_prmtr_03                    => to_char(p_prtt_enrt_rslt_id)
      ,p_prmtr_05                    => to_char(p_per_in_ler_id)
      ,p_person_id                   => p_person_id
      ,p_business_group_id           => p_business_group_id
      ,p_object_version_number       => l_object_version_number
      ,p_effective_date              => p_effective_date
      ,p_new_val1                    => l_new_plan_name
      ,p_new_val2                    => l_new_option_name
      ,p_new_val3                    => p_enrt_cvg_strt_dt
      ,p_new_val4                    => p_enrt_cvg_end_dt
      );
      end if;
     --
    end if;
    end if;  -- CREATE
    --
    if p_action = 'REINSTATE' then
      --
      open c_plan_name(p_pl_id);
      fetch c_plan_name into l_new_plan_name;
      close c_plan_name;
      open c_option_name(p_oipl_id);
      fetch c_option_name into l_new_option_name;
      close c_option_name;
      --
      if change_event_is_enabled('RB',p_effective_date) then
      ben_ext_chg_evt_api.create_ext_chg_evt
      (p_validate                    => FALSE
      ,p_ext_chg_evt_log_id          => l_ext_chg_evt_log_id
      ,p_chg_evt_cd                  => 'RB'  -- Reinstate Benefit
      ,p_chg_eff_dt                  => p_effective_date
      ,p_prmtr_01                    => to_char(p_pl_id)
      ,p_prmtr_02                    => to_char(p_oipl_id)
      ,p_prmtr_03                    => to_char(p_prtt_enrt_rslt_id)
      ,p_prmtr_05                    => to_char(p_per_in_ler_id)
      ,p_person_id                   => p_person_id
      ,p_business_group_id           => p_business_group_id
      ,p_object_version_number       => l_object_version_number
      ,p_effective_date              => p_effective_date
      ,p_old_val1                    => l_new_plan_name  --same as old
      ,p_old_val2                    => l_new_option_name -- same as old
      ,p_old_val3                    => p_old_enrt_cvg_strt_dt
      ,p_old_val4                    => p_old_enrt_cvg_end_dt
      ,p_new_val1                    => l_new_plan_name
      ,p_new_val2                    => l_new_option_name
      ,p_new_val3                    => p_enrt_cvg_strt_dt
      ,p_new_val4                    => p_enrt_cvg_end_dt
      );
      end if;
      --
    end if;  -- REINSTATE
    --
    if p_action = 'UPDATE' then

      if p_pl_id <> p_old_pl_id then
        --
        -- For Extract purposes, we recognize an update to plan as 2 separate
        -- changes:  Terminate Benefit, and Add Benefit.
        --
        if p_effective_date < p_old_enrt_cvg_strt_dt then
          --
          open c_plan_name(p_old_pl_id);
          fetch c_plan_name into l_old_plan_name;
          close c_plan_name;
          open c_option_name(p_old_oipl_id);
          fetch c_option_name into l_old_option_name;
          close c_option_name;
         --
         if change_event_is_enabled('TBBC',p_effective_date) then
          ben_ext_chg_evt_api.create_ext_chg_evt
          (p_validate                    => FALSE
          ,p_ext_chg_evt_log_id          => l_ext_chg_evt_log_id
          ,p_chg_evt_cd                  => 'TBBC'  -- Terminate Benefit before Coverage
          ,p_chg_eff_dt                  => p_effective_date  --??
          ,p_prmtr_01                    => to_char(p_old_pl_id)
          ,p_prmtr_02                    => to_char(p_old_oipl_id)
          ,p_prmtr_03                    => to_char(p_old_prtt_enrt_rslt_id)
          ,p_prmtr_05                    => to_char(p_old_per_in_ler_id)
          ,p_person_id                   => p_person_id
          ,p_business_group_id           => p_business_group_id
          ,p_object_version_number       => l_object_version_number
          ,p_effective_date              => p_effective_date
          ,p_old_val1                    => l_old_plan_name
          ,p_old_val2                    => l_old_option_name
          ,p_old_val3                    => p_old_enrt_cvg_strt_dt
          ,p_old_val4                    => p_old_enrt_cvg_end_dt
          ,p_new_val1                    => l_old_plan_name  --same value as new
          ,p_new_val2                    => l_old_option_name --same value as new
          ,p_new_val3                    => p_old_enrt_cvg_strt_dt
          ,p_new_val4                    => (p_old_enrt_cvg_strt_dt-1)--?
          );
         end if;
          --
        else
          --
          open c_plan_name(p_old_pl_id);
          fetch c_plan_name into l_old_plan_name;
          close c_plan_name;
          open c_option_name(p_old_oipl_id);
          fetch c_option_name into l_old_option_name;
          close c_option_name;

         if change_event_is_enabled('TBAC',p_effective_date) then
          ben_ext_chg_evt_api.create_ext_chg_evt
          (p_validate                    => FALSE
          ,p_ext_chg_evt_log_id          => l_ext_chg_evt_log_id
          ,p_chg_evt_cd                  => 'TBAC'  -- Terminate Benefit after Coverage
          ,p_chg_eff_dt                  => p_effective_date --??
          ,p_prmtr_01                    => to_char(p_old_pl_id)
          ,p_prmtr_02                    => to_char(p_old_oipl_id)
          ,p_prmtr_03                    => to_char(p_old_prtt_enrt_rslt_id)
          ,p_prmtr_05                    => to_char(p_old_per_in_ler_id)
          ,p_person_id                   => p_person_id
          ,p_business_group_id           => p_business_group_id
          ,p_object_version_number       => l_object_version_number
          ,p_effective_date              => p_effective_date
          ,p_old_val1                    => l_old_plan_name
          ,p_old_val2                    => l_old_option_name
          ,p_old_val3                    => p_old_enrt_cvg_strt_dt
          ,p_old_val4                    => p_old_enrt_cvg_end_dt
          ,p_new_val1                    => l_old_plan_name  --same value as new
          ,p_new_val2                    => l_old_option_name --same value as new
          ,p_new_val3                    => p_old_enrt_cvg_strt_dt
          ,p_new_val4                    => (p_old_enrt_cvg_strt_dt-1)--?
          );
         end if;
          --
        end if;  -- eff date
        --
        open c_plan_name(p_pl_id);
        fetch c_plan_name into l_new_plan_name;
        close c_plan_name;
        open c_option_name(p_oipl_id);
        fetch c_option_name into l_new_option_name;
        close c_option_name;

       if change_event_is_enabled('AB',p_effective_date) then
        ben_ext_chg_evt_api.create_ext_chg_evt
        (p_validate                    => FALSE
        ,p_ext_chg_evt_log_id          => l_ext_chg_evt_log_id
        ,p_chg_evt_cd                  => 'AB'  -- Add Benefit
        ,p_chg_eff_dt                  => p_effective_date
        ,p_prmtr_01                    => to_char(p_pl_id)
        ,p_prmtr_02                    => to_char(p_oipl_id)
        ,p_prmtr_03                    => to_char(p_prtt_enrt_rslt_id)
        ,p_prmtr_05                    => to_char(p_per_in_ler_id)
        ,p_person_id                   => p_person_id
        ,p_business_group_id           => p_business_group_id
        ,p_object_version_number       => l_object_version_number
        ,p_effective_date              => p_effective_date
        ,p_new_val1                    => l_new_plan_name
        ,p_new_val2                    => l_new_option_name
        ,p_new_val3                    => p_enrt_cvg_strt_dt
        ,p_new_val4                    => hr_api.g_eot --?
        );
       end if;
        --
      else -- plan did not change
	  --
        if p_oipl_id <> p_old_oipl_id then
          --
          open c_plan_name(p_pl_id);
          fetch c_plan_name into l_new_plan_name;
          close c_plan_name;
          open c_option_name(p_oipl_id);
          fetch c_option_name into l_new_option_name;
          close c_option_name;
          open c_option_name(p_old_oipl_id);
          fetch c_option_name into l_old_option_name;
          close c_option_name;
         --
         if change_event_is_enabled('UOBO',p_effective_date) then
          ben_ext_chg_evt_api.create_ext_chg_evt
          (p_validate                    => FALSE
          ,p_ext_chg_evt_log_id          => l_ext_chg_evt_log_id
          ,p_chg_evt_cd                  => 'UOBO'  -- Change of Option
          ,p_chg_eff_dt                  => p_effective_date
          ,p_prmtr_01                    => to_char(p_pl_id)
          ,p_prmtr_02                    => to_char(p_oipl_id)
          ,p_prmtr_03                    => to_char(p_prtt_enrt_rslt_id)
          ,p_prmtr_05                    => to_char(p_per_in_ler_id)
          ,p_prmtr_07                    => to_char(p_old_oipl_id)
          ,p_person_id                   => p_person_id
          ,p_business_group_id           => p_business_group_id
          ,p_object_version_number       => l_object_version_number
          ,p_effective_date              => p_effective_date
          ,p_old_val1                    => l_new_plan_name  -- same val as old
          ,p_old_val2                    => l_old_option_name
          ,p_new_val1                    => l_new_plan_name
          ,p_new_val2                    => l_new_option_name
          );
         end if;
 	    --
        end if;
        --
	if p_enrt_cvg_strt_dt <> p_old_enrt_cvg_strt_dt then
          --
        if change_event_is_enabled('CCSD',p_effective_date) then
          ben_ext_chg_evt_api.create_ext_chg_evt
          (p_validate                    => FALSE
          ,p_ext_chg_evt_log_id          => l_ext_chg_evt_log_id
          ,p_chg_evt_cd                  => 'CCSD'  -- Change Coverage Start Date
          ,p_chg_eff_dt                  => p_effective_date
          ,p_prmtr_01                    => to_char(p_pl_id)
          ,p_prmtr_02                    => to_char(p_oipl_id)
          ,p_prmtr_03                    => to_char(p_prtt_enrt_rslt_id)
          ,p_prmtr_05                    => to_char(p_per_in_ler_id)
          ,p_person_id                   => p_person_id
          ,p_business_group_id           => p_business_group_id
          ,p_object_version_number       => l_object_version_number
          ,p_effective_date              => p_effective_date
          ,p_old_val3                    => p_old_enrt_cvg_strt_dt
          ,p_new_val3                    => p_enrt_cvg_strt_dt
          );
         end if;
      end if;
        --
	if p_enrt_cvg_end_dt <> p_old_enrt_cvg_end_dt then
          --
        if change_event_is_enabled('CCED',p_effective_date) then
          ben_ext_chg_evt_api.create_ext_chg_evt
          (p_validate                    => FALSE
          ,p_ext_chg_evt_log_id          => l_ext_chg_evt_log_id
          ,p_chg_evt_cd                  => 'CCED'  -- Change Coverage End Date
          ,p_chg_eff_dt                  => p_effective_date
          ,p_prmtr_01                    => to_char(p_pl_id)
          ,p_prmtr_02                    => to_char(p_oipl_id)
          ,p_prmtr_03                    => to_char(p_prtt_enrt_rslt_id)
          ,p_prmtr_05                    => to_char(p_per_in_ler_id)
          ,p_person_id                   => p_person_id
          ,p_business_group_id           => p_business_group_id
          ,p_object_version_number       => l_object_version_number
          ,p_effective_date              => p_effective_date
          ,p_old_val4                    => p_old_enrt_cvg_end_dt
          ,p_new_val4                    => p_enrt_cvg_end_dt
          );
        end if;
      end if;
        --
	if p_bnft_amt <> p_old_bnft_amt then
          --
        if change_event_is_enabled('COECA',p_effective_date) then
          ben_ext_chg_evt_api.create_ext_chg_evt
          (p_validate                    => FALSE
          ,p_ext_chg_evt_log_id          => l_ext_chg_evt_log_id
          ,p_chg_evt_cd                  => 'COECA'  -- Change Coverage Amount
          ,p_chg_eff_dt                  => p_effective_date
          ,p_prmtr_01                    => to_char(p_pl_id)
          ,p_prmtr_02                    => to_char(p_oipl_id)
          ,p_prmtr_03                    => to_char(p_prtt_enrt_rslt_id)
          ,p_prmtr_05                    => to_char(p_per_in_ler_id)
          ,p_person_id                   => p_person_id
          ,p_business_group_id           => p_business_group_id
          ,p_object_version_number       => l_object_version_number
          ,p_effective_date              => p_effective_date
          ,p_old_val1                    => p_old_bnft_amt
          ,p_new_val1                    => p_bnft_amt
          );
        end if;
      end if;
        --
	if p_pen_attribute1 <> p_old_pen_attribute1 then
          --
        if change_event_is_enabled('COEF01',p_effective_date) then
          ben_ext_chg_evt_api.create_ext_chg_evt
          (p_validate                    => FALSE
          ,p_ext_chg_evt_log_id          => l_ext_chg_evt_log_id
          ,p_chg_evt_cd                  => 'COEF01'  -- Change Flex field
          ,p_chg_eff_dt                  => p_effective_date
          ,p_prmtr_01                    => to_char(p_pl_id)
          ,p_prmtr_02                    => to_char(p_oipl_id)
          ,p_prmtr_03                    => to_char(p_prtt_enrt_rslt_id)
          ,p_prmtr_05                    => to_char(p_per_in_ler_id)
          ,p_person_id                   => p_person_id
          ,p_business_group_id           => p_business_group_id
          ,p_object_version_number       => l_object_version_number
          ,p_effective_date              => p_effective_date
          ,p_old_val1                    => p_old_pen_attribute1
          ,p_new_val1                    => p_pen_attribute1
          );
        end if;
      end if;
        --
	if p_pen_attribute2 <> p_old_pen_attribute2 then
          --
        if change_event_is_enabled('COEF02',p_effective_date) then
          ben_ext_chg_evt_api.create_ext_chg_evt
          (p_validate                    => FALSE
          ,p_ext_chg_evt_log_id          => l_ext_chg_evt_log_id
          ,p_chg_evt_cd                  => 'COEF02'  -- Change Flex field
          ,p_chg_eff_dt                  => p_effective_date
          ,p_prmtr_01                    => to_char(p_pl_id)
          ,p_prmtr_02                    => to_char(p_oipl_id)
          ,p_prmtr_03                    => to_char(p_prtt_enrt_rslt_id)
          ,p_prmtr_05                    => to_char(p_per_in_ler_id)
          ,p_person_id                   => p_person_id
          ,p_business_group_id           => p_business_group_id
          ,p_object_version_number       => l_object_version_number
          ,p_effective_date              => p_effective_date
          ,p_old_val1                    => p_old_pen_attribute2
          ,p_new_val1                    => p_pen_attribute2
          );
        end if;
      end if;
        --
        --
	if p_pen_attribute3 <> p_old_pen_attribute3 then
          --
        if change_event_is_enabled('COEF03',p_effective_date) then
          ben_ext_chg_evt_api.create_ext_chg_evt
          (p_validate                    => FALSE
          ,p_ext_chg_evt_log_id          => l_ext_chg_evt_log_id
          ,p_chg_evt_cd                  => 'COEF03'  -- Change Flex field
          ,p_chg_eff_dt                  => p_effective_date
          ,p_prmtr_01                    => to_char(p_pl_id)
          ,p_prmtr_02                    => to_char(p_oipl_id)
          ,p_prmtr_03                    => to_char(p_prtt_enrt_rslt_id)
          ,p_prmtr_05                    => to_char(p_per_in_ler_id)
          ,p_person_id                   => p_person_id
          ,p_business_group_id           => p_business_group_id
          ,p_object_version_number       => l_object_version_number
          ,p_effective_date              => p_effective_date
          ,p_old_val1                    => p_old_pen_attribute3
          ,p_new_val1                    => p_pen_attribute3
          );
        end if;
      end if;
      --
	if p_pen_attribute4 <> p_old_pen_attribute4 then
          --
        if change_event_is_enabled('COEF04',p_effective_date) then
          ben_ext_chg_evt_api.create_ext_chg_evt
          (p_validate                    => FALSE
          ,p_ext_chg_evt_log_id          => l_ext_chg_evt_log_id
          ,p_chg_evt_cd                  => 'COEF04'  -- Change Flex field
          ,p_chg_eff_dt                  => p_effective_date
          ,p_prmtr_01                    => to_char(p_pl_id)
          ,p_prmtr_02                    => to_char(p_oipl_id)
          ,p_prmtr_03                    => to_char(p_prtt_enrt_rslt_id)
          ,p_prmtr_05                    => to_char(p_per_in_ler_id)
          ,p_person_id                   => p_person_id
          ,p_business_group_id           => p_business_group_id
          ,p_object_version_number       => l_object_version_number
          ,p_effective_date              => p_effective_date
          ,p_old_val1                    => p_old_pen_attribute4
          ,p_new_val1                    => p_pen_attribute4
          );
        end if;
      end if;
      --
	if p_pen_attribute5 <> p_old_pen_attribute5 then
          --
        if change_event_is_enabled('COEF05',p_effective_date) then
          ben_ext_chg_evt_api.create_ext_chg_evt
          (p_validate                    => FALSE
          ,p_ext_chg_evt_log_id          => l_ext_chg_evt_log_id
          ,p_chg_evt_cd                  => 'COEF05'  -- Change Flex field
          ,p_chg_eff_dt                  => p_effective_date
          ,p_prmtr_01                    => to_char(p_pl_id)
          ,p_prmtr_02                    => to_char(p_oipl_id)
          ,p_prmtr_03                    => to_char(p_prtt_enrt_rslt_id)
          ,p_prmtr_05                    => to_char(p_per_in_ler_id)
          ,p_person_id                   => p_person_id
          ,p_business_group_id           => p_business_group_id
          ,p_object_version_number       => l_object_version_number
          ,p_effective_date              => p_effective_date
          ,p_old_val1                    => p_old_pen_attribute5
          ,p_new_val1                    => p_pen_attribute5
          );
        end if;
      end if;
        --
	if p_pen_attribute6 <> p_old_pen_attribute6 then
          --
        if change_event_is_enabled('COEF06',p_effective_date) then
          ben_ext_chg_evt_api.create_ext_chg_evt
          (p_validate                    => FALSE
          ,p_ext_chg_evt_log_id          => l_ext_chg_evt_log_id
          ,p_chg_evt_cd                  => 'COEF06'  -- Change Flex field
          ,p_chg_eff_dt                  => p_effective_date
          ,p_prmtr_01                    => to_char(p_pl_id)
          ,p_prmtr_02                    => to_char(p_oipl_id)
          ,p_prmtr_03                    => to_char(p_prtt_enrt_rslt_id)
          ,p_prmtr_05                    => to_char(p_per_in_ler_id)
          ,p_person_id                   => p_person_id
          ,p_business_group_id           => p_business_group_id
          ,p_object_version_number       => l_object_version_number
          ,p_effective_date              => p_effective_date
          ,p_old_val1                    => p_old_pen_attribute6
          ,p_new_val1                    => p_pen_attribute6
          );
        end if;
      end if;
        --
	if p_pen_attribute7 <> p_old_pen_attribute7 then
          --
        if change_event_is_enabled('COEF07',p_effective_date) then
          ben_ext_chg_evt_api.create_ext_chg_evt
          (p_validate                    => FALSE
          ,p_ext_chg_evt_log_id          => l_ext_chg_evt_log_id
          ,p_chg_evt_cd                  => 'COEF07'  -- Change Flex field
          ,p_chg_eff_dt                  => p_effective_date
          ,p_prmtr_01                    => to_char(p_pl_id)
          ,p_prmtr_02                    => to_char(p_oipl_id)
          ,p_prmtr_03                    => to_char(p_prtt_enrt_rslt_id)
          ,p_prmtr_05                    => to_char(p_per_in_ler_id)
          ,p_person_id                   => p_person_id
          ,p_business_group_id           => p_business_group_id
          ,p_object_version_number       => l_object_version_number
          ,p_effective_date              => p_effective_date
          ,p_old_val1                    => p_old_pen_attribute7
          ,p_new_val1                    => p_pen_attribute7
          );
        end if;
      end if;
        --
	if p_pen_attribute8 <> p_old_pen_attribute8 then
          --
        if change_event_is_enabled('COEF08',p_effective_date) then
          ben_ext_chg_evt_api.create_ext_chg_evt
          (p_validate                    => FALSE
          ,p_ext_chg_evt_log_id          => l_ext_chg_evt_log_id
          ,p_chg_evt_cd                  => 'COEF08'  -- Change Flex field
          ,p_chg_eff_dt                  => p_effective_date
          ,p_prmtr_01                    => to_char(p_pl_id)
          ,p_prmtr_02                    => to_char(p_oipl_id)
          ,p_prmtr_03                    => to_char(p_prtt_enrt_rslt_id)
          ,p_prmtr_05                    => to_char(p_per_in_ler_id)
          ,p_person_id                   => p_person_id
          ,p_business_group_id           => p_business_group_id
          ,p_object_version_number       => l_object_version_number
          ,p_effective_date              => p_effective_date
          ,p_old_val1                    => p_old_pen_attribute8
          ,p_new_val1                    => p_pen_attribute8
          );
        end if;
      end if;
        --
	if p_pen_attribute9 <> p_old_pen_attribute9 then
          --
        if change_event_is_enabled('COEF09',p_effective_date) then
          ben_ext_chg_evt_api.create_ext_chg_evt
          (p_validate                    => FALSE
          ,p_ext_chg_evt_log_id          => l_ext_chg_evt_log_id
          ,p_chg_evt_cd                  => 'COEF09'  -- Change Flex field
          ,p_chg_eff_dt                  => p_effective_date
          ,p_prmtr_01                    => to_char(p_pl_id)
          ,p_prmtr_02                    => to_char(p_oipl_id)
          ,p_prmtr_03                    => to_char(p_prtt_enrt_rslt_id)
          ,p_prmtr_05                    => to_char(p_per_in_ler_id)
          ,p_person_id                   => p_person_id
          ,p_business_group_id           => p_business_group_id
          ,p_object_version_number       => l_object_version_number
          ,p_effective_date              => p_effective_date
          ,p_old_val1                    => p_old_pen_attribute9
          ,p_new_val1                    => p_pen_attribute9
          );
        end if;
      end if;
        --
	if p_pen_attribute10 <> p_old_pen_attribute10 then
          --
        if change_event_is_enabled('COEF10',p_effective_date) then
          ben_ext_chg_evt_api.create_ext_chg_evt
          (p_validate                    => FALSE
          ,p_ext_chg_evt_log_id          => l_ext_chg_evt_log_id
          ,p_chg_evt_cd                  => 'COEF10'  -- Change Flex field
          ,p_chg_eff_dt                  => p_effective_date
          ,p_prmtr_01                    => to_char(p_pl_id)
          ,p_prmtr_02                    => to_char(p_oipl_id)
          ,p_prmtr_03                    => to_char(p_prtt_enrt_rslt_id)
          ,p_prmtr_05                    => to_char(p_per_in_ler_id)
          ,p_person_id                   => p_person_id
          ,p_business_group_id           => p_business_group_id
          ,p_object_version_number       => l_object_version_number
          ,p_effective_date              => p_effective_date
          ,p_old_val1                    => p_old_pen_attribute10
          ,p_new_val1                    => p_pen_attribute10
          );
        end if;
       end if;  -- attribute10 <>...
        --
      end if; -- plan changed?
      --
    end if;  -- UPDATE
    --
    if p_action = 'DELETE' then
      --
      if nvl(p_enrt_cvg_end_dt,p_effective_date) < p_enrt_cvg_strt_dt then
          --
        open c_plan_name(p_old_pl_id);
        fetch c_plan_name into l_old_plan_name;
        close c_plan_name;
        open c_option_name(p_old_oipl_id);
        fetch c_option_name into l_old_option_name;
        close c_option_name;
        --
       if change_event_is_enabled('TBBC',p_effective_date) then
        ben_ext_chg_evt_api.create_ext_chg_evt
        (p_validate                    => FALSE
        ,p_ext_chg_evt_log_id          => l_ext_chg_evt_log_id
        ,p_chg_evt_cd                  => 'TBBC'  -- Terminate Benefit before Coverage
        ,p_chg_eff_dt                  => p_effective_date
        ,p_prmtr_01                    => to_char(p_old_pl_id)
        ,p_prmtr_02                    => to_char(p_old_oipl_id)
        ,p_prmtr_03                    => to_char(p_prtt_enrt_rslt_id)
        ,p_prmtr_05                    => to_char(p_per_in_ler_id)
        ,p_person_id                   => p_person_id
        ,p_business_group_id           => p_business_group_id
        ,p_object_version_number       => l_object_version_number
        ,p_effective_date              => p_effective_date
        ,p_old_val1                    => l_old_plan_name
        ,p_old_val2                    => l_old_option_name
        ,p_old_val3                    => p_old_enrt_cvg_strt_dt
        ,p_old_val4                    => p_old_enrt_cvg_end_dt
        ,p_new_val1                    => l_old_plan_name  --same value as new
        ,p_new_val2                    => l_old_option_name --same value as new
        ,p_new_val3                    => p_enrt_cvg_strt_dt
        ,p_new_val4                    => p_enrt_cvg_end_dt
        );
       end if;
        --
      else
        --
        open c_plan_name(p_old_pl_id);
        fetch c_plan_name into l_old_plan_name;
        close c_plan_name;
        open c_option_name(p_old_oipl_id);
        fetch c_option_name into l_old_option_name;
        close c_option_name;

        if change_event_is_enabled('TBAC',p_effective_date) then
         ben_ext_chg_evt_api.create_ext_chg_evt
        (p_validate                    => FALSE
        ,p_ext_chg_evt_log_id          => l_ext_chg_evt_log_id
        ,p_chg_evt_cd                  => 'TBAC'  -- Terminate Benefit after Coverage
        ,p_chg_eff_dt                  => p_effective_date
        ,p_prmtr_01                    => to_char(p_old_pl_id)
        ,p_prmtr_02                    => to_char(p_old_oipl_id)
        ,p_prmtr_03                    => to_char(p_prtt_enrt_rslt_id)
        ,p_prmtr_05                    => to_char(p_per_in_ler_id)
        ,p_person_id                   => p_person_id
        ,p_business_group_id           => p_business_group_id
        ,p_object_version_number       => l_object_version_number
        ,p_effective_date              => p_effective_date
        ,p_old_val1                    => l_old_plan_name
        ,p_old_val2                    => l_old_option_name
        ,p_old_val3                    => p_old_enrt_cvg_strt_dt
        ,p_old_val4                    => p_old_enrt_cvg_end_dt
        ,p_new_val1                    => l_old_plan_name  --same value as new
        ,p_new_val2                    => l_old_option_name --same value as new
        ,p_new_val3                    => p_enrt_cvg_strt_dt
        ,p_new_val4                    => p_enrt_cvg_end_dt
        );
       end if;
        --
      end if; -- eff date
      --
    end if;  -- DELETE
    --
    --
    hr_utility.set_location('Exiting:'||l_proc, 99);
    --
  END log_benefit_chg;
--
procedure log_dependent_chg(
        p_action               in varchar2, -- CREATE, REINSTATE, or DELETE
        p_pl_id                in number default null,
        p_oipl_id              in number default null,
        p_cvg_strt_dt          in date default null,
        p_cvg_end_dt           in date default null,
        p_old_cvg_strt_dt      in date default null,
        p_old_cvg_end_dt       in date default null,
        p_effective_start_date in date default null,
        p_effective_end_date   in date default null,
        p_prtt_enrt_rslt_id    in number default null,
        p_per_in_ler_id        in number default null,
        p_elig_cvrd_dpnt_id    in number default null,
        p_person_id            in number,
        p_dpnt_person_id       in number,
        p_business_group_id    in number,
        p_effective_date       in date) is

  -- Local variable declarations
  --
  l_proc         varchar2(72) := 'ben_ext_chlg.log_dependent_chg';

  l_plan_name              ben_pl_f.name%type;
  l_option_name            ben_opt_f.name%type;
  l_dpnt_full_name             per_all_people_f.full_name%type;
  l_relationship               varchar2(200);
  --
  l_ext_chg_evt_log_id number;
  l_object_version_number number;
  --
  -- Cursor declarations.
  cursor c_plan_name(p_pl_id number)  is
  select pl.name
  from ben_pl_f pl
  where pl.pl_id = p_pl_id
  and p_effective_date between pl.effective_start_date and pl.effective_end_date;
  --
  cursor c_option_name(p_oipl_id number)
  is
  select opt.name
  from ben_oipl_f cop,
       ben_opt_f opt
  where cop.oipl_id = p_oipl_id
  and p_effective_date between cop.effective_start_date and cop.effective_end_date
  and cop.opt_id = opt.opt_id
  and p_effective_date between opt.effective_start_date and opt.effective_end_date;
  --
  cursor c_dpnt_full_name (p_person_id number) is
  SELECT ppf.full_name
  FROM   per_all_people_f ppf
  WHERE  ppf.person_id = p_person_id
  AND    p_effective_date between ppf.effective_start_date
         and ppf.effective_end_date
  AND    ppf.business_group_id = p_business_group_id;
  --
  cursor c_relationship(p_person_id number
                       ,p_dpnt_person_id number)is
  SELECT hl.meaning
  FROM   per_contact_relationships pcr,
         hr_lookups hl
  WHERE  pcr.person_id = p_person_id
  AND    pcr.contact_person_id = p_dpnt_person_id
  AND    pcr.contact_type = hl.lookup_code
  AND    hl.lookup_type = 'CONTACT';
  --
  --
  begin
    --
    hr_utility.set_location('Entering:'||l_proc, 10);
    --
    -- Get the new values to be store or updated
    --
      open c_plan_name(p_pl_id);
      fetch c_plan_name into l_plan_name;
      close c_plan_name;
      open c_option_name(p_oipl_id);
      fetch c_option_name into l_option_name;
      close c_option_name;
      open c_dpnt_full_name(p_dpnt_person_id);
      fetch c_dpnt_full_name into l_dpnt_full_name;
      close c_dpnt_full_name;
      open c_relationship(p_person_id, p_dpnt_person_id);
      fetch c_relationship into l_relationship;
      close c_relationship;
    --
    if p_action = 'CREATE' then
      --
      -- When we are creating a new dependent record we must record 2 records to
      -- the change log.  'Add Dependent' for the employee person, and 'Add Benefit'
      -- for the dependent person.
      --
      if change_event_is_enabled('AB',p_effective_date) then
       ben_ext_chg_evt_api.create_ext_chg_evt
      (p_validate                    => FALSE
      ,p_ext_chg_evt_log_id          => l_ext_chg_evt_log_id
      ,p_chg_evt_cd                  => 'AB'  -- Add Benefit
      ,p_chg_eff_dt                  => p_effective_date
      ,p_prmtr_01                    => to_char(p_pl_id)
      ,p_prmtr_02                    => to_char(p_oipl_id)
      ,p_prmtr_03                    => to_char(p_prtt_enrt_rslt_id)
      ,p_prmtr_04                    => to_char(p_elig_cvrd_dpnt_id)
      ,p_prmtr_05                    => to_char(p_per_in_ler_id)
      ,p_prmtr_06                    => to_char(p_person_id)
      ,p_person_id                   => p_dpnt_person_id
      ,p_business_group_id           => p_business_group_id
      ,p_object_version_number       => l_object_version_number
      ,p_effective_date              => p_effective_date
      ,p_new_val1                    => l_plan_name
      ,p_new_val2                    => l_option_name
      ,p_new_val3                    => p_cvg_strt_dt
      ,p_new_val4                    => p_cvg_end_dt
      );
      end if;
      --
      if change_event_is_enabled('AD',p_effective_date) then
       ben_ext_chg_evt_api.create_ext_chg_evt
      (p_validate                    => FALSE
      ,p_ext_chg_evt_log_id          => l_ext_chg_evt_log_id
      ,p_chg_evt_cd                  => 'AD'  -- Add Dependent
      ,p_chg_eff_dt                  => p_effective_date
      ,p_prmtr_01                    => to_char(p_pl_id)
      ,p_prmtr_02                    => to_char(p_oipl_id)
      ,p_prmtr_03                    => to_char(p_prtt_enrt_rslt_id)
      ,p_prmtr_04                    => to_char(p_elig_cvrd_dpnt_id)
      ,p_prmtr_05                    => to_char(p_per_in_ler_id)
      ,p_prmtr_06                    => to_char(p_dpnt_person_id)
      ,p_person_id                   => p_person_id
      ,p_business_group_id           => p_business_group_id
      ,p_object_version_number       => l_object_version_number
      ,p_effective_date              => p_effective_date
      ,p_new_val1                    => l_plan_name
      ,p_new_val2                    => l_option_name
      ,p_new_val3                    => p_cvg_strt_dt
      ,p_new_val4                    => p_cvg_end_dt
      ,p_new_val5                    => l_dpnt_full_name
      ,p_new_val6                    => l_relationship
      );
     end if;
    --
    elsif p_action = 'REINSTATE' then
      --
     if change_event_is_enabled('RB',p_effective_date) then
      ben_ext_chg_evt_api.create_ext_chg_evt
      (p_validate                    => FALSE
      ,p_ext_chg_evt_log_id          => l_ext_chg_evt_log_id
      ,p_chg_evt_cd                  => 'RB'  -- Reinstate Benefit
      ,p_chg_eff_dt                  => p_effective_date
      ,p_prmtr_01                    => to_char(p_pl_id)
      ,p_prmtr_02                    => to_char(p_oipl_id)
      ,p_prmtr_03                    => to_char(p_prtt_enrt_rslt_id)
      ,p_prmtr_04                    => to_char(p_elig_cvrd_dpnt_id)
      ,p_prmtr_05                    => to_char(p_per_in_ler_id)
      ,p_prmtr_06                    => to_char(p_person_id)
      ,p_person_id                   => p_dpnt_person_id
      ,p_business_group_id           => p_business_group_id
      ,p_object_version_number       => l_object_version_number
      ,p_effective_date              => p_effective_date
      ,p_old_val1                    => l_plan_name
      ,p_old_val2                    => l_option_name
      ,p_old_val3                    => p_old_cvg_strt_dt
      ,p_old_val4                    => p_old_cvg_end_dt
      ,p_new_val1                    => l_plan_name
      ,p_new_val2                    => l_option_name
      ,p_new_val3                    => p_cvg_strt_dt
      ,p_new_val4                    => p_cvg_end_dt
      );
      end if;
      --
     if change_event_is_enabled('AD',p_effective_date) then
      ben_ext_chg_evt_api.create_ext_chg_evt
      (p_validate                    => FALSE
      ,p_ext_chg_evt_log_id          => l_ext_chg_evt_log_id
      ,p_chg_evt_cd                  => 'AD' -- Add dependent  This should later change to
                                             -- Reinstate Dependent.
      ,p_chg_eff_dt                  => p_effective_date
      ,p_prmtr_01                    => to_char(p_pl_id)
      ,p_prmtr_02                    => to_char(p_oipl_id)
      ,p_prmtr_03                    => to_char(p_prtt_enrt_rslt_id)
      ,p_prmtr_04                    => to_char(p_elig_cvrd_dpnt_id)
      ,p_prmtr_05                    => to_char(p_per_in_ler_id)
      ,p_prmtr_06                    => to_char(p_dpnt_person_id)
      ,p_person_id                   => p_person_id
      ,p_business_group_id           => p_business_group_id
      ,p_object_version_number       => l_object_version_number
      ,p_effective_date              => p_effective_date
      ,p_old_val1                    => l_plan_name
      ,p_old_val2                    => l_option_name
      ,p_old_val3                    => p_old_cvg_strt_dt
      ,p_old_val4                    => p_old_cvg_end_dt
      ,p_old_val5                    => l_dpnt_full_name
      ,p_old_val6                    => l_relationship
      ,p_new_val1                    => l_plan_name
      ,p_new_val2                    => l_option_name
      ,p_new_val3                    => p_cvg_strt_dt
      ,p_new_val4                    => p_cvg_end_dt
      ,p_new_val5                    => l_dpnt_full_name
      ,p_new_val6                    => l_relationship
      );
      end if;
    --
    elsif p_action = 'DELETE' then
      --
      if p_cvg_end_dt < p_cvg_strt_dt then
          --
       if change_event_is_enabled('TBBC',p_effective_date) then
        ben_ext_chg_evt_api.create_ext_chg_evt
        (p_validate                    => FALSE
        ,p_ext_chg_evt_log_id          => l_ext_chg_evt_log_id
        ,p_chg_evt_cd                  => 'TBBC'  -- Terminate Benefit before Coverage
        ,p_chg_eff_dt                  => p_effective_date
        ,p_prmtr_01                    => to_char(p_pl_id)
        ,p_prmtr_02                    => to_char(p_oipl_id)
        ,p_prmtr_03                    => to_char(p_prtt_enrt_rslt_id)
        ,p_prmtr_04                    => to_char(p_elig_cvrd_dpnt_id)
        ,p_prmtr_05                    => to_char(p_per_in_ler_id)
        ,p_prmtr_06                    => to_char(p_person_id)
        ,p_person_id                   => p_dpnt_person_id
        ,p_business_group_id           => p_business_group_id
        ,p_object_version_number       => l_object_version_number
        ,p_effective_date              => p_effective_date
        ,p_old_val1                    => l_plan_name
        ,p_old_val2                    => l_option_name
        ,p_old_val3                    => p_old_cvg_strt_dt
        ,p_old_val4                    => p_old_cvg_end_dt
        ,p_new_val1                    => l_plan_name
        ,p_new_val2                    => l_option_name
        ,p_new_val3                    => p_cvg_strt_dt
        ,p_new_val4                    => p_cvg_end_dt
        );
       end if;
        --
      else
        --
       if change_event_is_enabled('TBAC',p_effective_date) then
        ben_ext_chg_evt_api.create_ext_chg_evt
        (p_validate                    => FALSE
        ,p_ext_chg_evt_log_id          => l_ext_chg_evt_log_id
        ,p_chg_evt_cd                  => 'TBAC'  -- Terminate Benefit after Coverage
        ,p_chg_eff_dt                  => p_effective_date
        ,p_prmtr_01                    => to_char(p_pl_id)
        ,p_prmtr_02                    => to_char(p_oipl_id)
        ,p_prmtr_03                    => to_char(p_prtt_enrt_rslt_id)
        ,p_prmtr_04                    => to_char(p_elig_cvrd_dpnt_id)
        ,p_prmtr_05                    => to_char(p_per_in_ler_id)
        ,p_prmtr_06                    => to_char(p_person_id)
        ,p_person_id                   => p_dpnt_person_id
        ,p_business_group_id           => p_business_group_id
        ,p_object_version_number       => l_object_version_number
        ,p_effective_date              => p_effective_date
        ,p_old_val1                    => l_plan_name
        ,p_old_val2                    => l_option_name
        ,p_old_val3                    => p_old_cvg_strt_dt
        ,p_old_val4                    => p_old_cvg_end_dt
        ,p_new_val1                    => l_plan_name
        ,p_new_val2                    => l_option_name
        ,p_new_val3                    => p_cvg_strt_dt
        ,p_new_val4                    => p_cvg_end_dt
        );
       end if;
        --
      end if; -- eff date
      --
      if change_event_is_enabled('DD',p_effective_date) then
       ben_ext_chg_evt_api.create_ext_chg_evt
        (p_validate                    => FALSE
        ,p_ext_chg_evt_log_id          => l_ext_chg_evt_log_id
        ,p_chg_evt_cd                  => 'DD'  -- Delete Dependent
        ,p_chg_eff_dt                  => p_effective_date
        ,p_prmtr_01                    => to_char(p_pl_id)
        ,p_prmtr_02                    => to_char(p_oipl_id)
        ,p_prmtr_03                    => to_char(p_prtt_enrt_rslt_id)
        ,p_prmtr_04                    => to_char(p_elig_cvrd_dpnt_id)
        ,p_prmtr_05                    => to_char(p_per_in_ler_id)
        ,p_prmtr_06                    => to_char(p_dpnt_person_id)
        ,p_person_id                   => p_person_id
        ,p_business_group_id           => p_business_group_id
        ,p_object_version_number       => l_object_version_number
        ,p_effective_date              => p_effective_date
        ,p_old_val1                    => l_plan_name
        ,p_old_val2                    => l_option_name
        ,p_old_val3                    => p_old_cvg_strt_dt
        ,p_old_val4                    => p_old_cvg_end_dt
        ,p_old_val5                    => l_dpnt_full_name
        ,p_old_val6                    => l_relationship
        ,p_new_val1                    => l_plan_name
        ,p_new_val2                    => l_option_name
        ,p_new_val3                    => p_cvg_strt_dt
        ,p_new_val4                    => p_cvg_end_dt
        ,p_new_val5                    => l_dpnt_full_name
        ,p_new_val6                    => l_relationship
        );
       end if;
    end if;
  --
  hr_utility.set_location('Exiting:'||l_proc, 99);
--
end log_dependent_chg;
--
procedure log_pcp_chg(
        p_action               in varchar2,
        p_ext_ident            in varchar2 default null,
        p_old_ext_ident        in varchar2 default null,
        p_name                 in varchar2 default null,
        p_old_name             in varchar2 default null,
        p_prmry_care_prvdr_typ_cd in varchar2 default null,
        p_old_prmry_care_prvdr_typ_cd in varchar2 default null,
        p_prmry_care_prvdr_id  in number default null,
        p_elig_cvrd_dpnt_id    in number default null,
        p_prtt_enrt_rslt_id    in number default null,
        p_effective_start_date in date default null,
        p_effective_end_date   in date default null,
        p_business_group_id    in number,
        p_effective_date       in date) is
  --
  -- Local variable declarations
  --
  l_proc         varchar2(72) := 'ben_ext_chlg.log_pcp_chg';
  l_relationship              per_all_people_f.person_id%type;
  l_contact                   per_contact_relationships.contact_relationship_id%type;
  l_name                      per_all_people_f.full_name%type;
  --
  cursor c_relationship(p_person_id number) is
  SELECT pcr.contact_relationship_id,pcr.person_id,ppf.full_name
  FROM   per_contact_relationships pcr,
         per_all_people_f ppf,
         per_person_types ppt,
         hr_lookups hl
  WHERE  pcr.contact_person_id = p_person_id
  AND    ppf.person_id = p_person_id
  AND    ppf.person_type_id = ppt.person_type_id
  AND    ppt.system_person_type = 'OTHER'
  AND    pcr.contact_type = hl.lookup_code
  AND    hl.lookup_type = 'CONTACT';

  cursor c_con_relationship(p_person_id number) is
  SELECT pcr.contact_relationship_id,pcr.person_id,ppf.full_name
  FROM   per_contact_relationships pcr,
         per_all_people_f ppf,
         hr_lookups hl
  WHERE  pcr.contact_person_id = p_person_id
  AND    ppf.person_id = p_person_id
  AND    pcr.contact_type = hl.lookup_code
  AND    hl.lookup_type = 'CONTACT'
  AND    pcr.personal_flag = 'Y'
  and    p_effective_date between  pcr.date_start and nvl(pcr.date_end, p_effective_date)
  ;

--
cursor c_prtt_person_id
  is
  select pen.person_id
  from ben_prtt_enrt_rslt_f pen
  where pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
  and pen.business_group_id  = p_business_group_id
  and p_effective_date between pen.effective_start_date and pen.effective_end_date;

  cursor c_elig_cvrd_person_id
  is
  select ecd.dpnt_person_id
  from ben_elig_cvrd_dpnt_f ecd
  where ecd.elig_cvrd_dpnt_id = p_elig_cvrd_dpnt_id
  and ecd.business_group_id = p_business_group_id
  and p_effective_date between ecd.effective_start_date and ecd.effective_end_date;

  cursor c_prmry_care_prvdr_type(prmry_care_prvdr_typ_cd in varchar2)
  is
  select hl.meaning
  from hr_lookups hl
  where hl.lookup_type = 'BEN_PRMRY_CARE_PRVDR_TYP'
  and hl.lookup_code = prmry_care_prvdr_typ_cd;
  --
  l_person_id                 number;
  l_prmry_care_prvdr_typ_cd   varchar2(50);
  v_prmry_care_prvdr_typ_cd   varchar2(50);
  l_old_prmry_care_prvdr_typ_cd   varchar2(50);
  l_object_version_number     number;
  l_ext_chg_evt_log_id        number;
  l_pcp_chg boolean := FALSE;
  --
  begin
    --
    hr_utility.set_location('Entering:'||l_proc, 10);
    --
    -- Get the values to be store or updated
  if p_prtt_enrt_rslt_id is not null then
    open c_prtt_person_id;
    fetch c_prtt_person_id into l_person_id;
    close c_prtt_person_id;
  elsif p_elig_cvrd_dpnt_id is not null then
    open c_elig_cvrd_person_id;
    fetch c_elig_cvrd_person_id into l_person_id;
    close c_elig_cvrd_person_id;
  end if;
  if p_prmry_care_prvdr_typ_cd is not null then
    open c_prmry_care_prvdr_type(p_prmry_care_prvdr_typ_cd);
    fetch c_prmry_care_prvdr_type into l_prmry_care_prvdr_typ_cd;
    close c_prmry_care_prvdr_type;
  end if;
  if p_old_prmry_care_prvdr_typ_cd is not null then
    open c_prmry_care_prvdr_type(p_old_prmry_care_prvdr_typ_cd);
    fetch c_prmry_care_prvdr_type into l_old_prmry_care_prvdr_typ_cd;
    close c_prmry_care_prvdr_type;
  end if;
  --
  --
  if p_action = 'CREATE' then
    if change_event_is_enabled('APCP',p_effective_date) then
     l_pcp_chg := TRUE;
     if l_person_id is not null then
     ben_ext_chg_evt_api.create_ext_chg_evt
     (p_validate              => FALSE
     ,p_ext_chg_evt_log_id    => l_ext_chg_evt_log_id
     ,p_chg_evt_cd            => 'APCP'
     ,p_chg_eff_dt            => p_effective_date
     ,p_prmtr_03              => p_prtt_enrt_rslt_id
     ,p_prmtr_04              => p_elig_cvrd_dpnt_id
     ,p_prmtr_08              => p_prmry_care_prvdr_id
     ,p_person_id             => l_person_id
     ,p_business_group_id     => p_business_group_id
     ,p_object_version_number => l_object_version_number
     ,p_effective_date        => p_effective_date
     ,p_new_val1              => p_name
     ,p_new_val2              => p_ext_ident
     ,p_new_val3              => l_prmry_care_prvdr_typ_cd);
     end if;
    end if;
    --
  elsif p_action = 'UPDATE' then

   if p_prmry_care_prvdr_typ_cd <> p_old_prmry_care_prvdr_typ_cd then
    --
    if change_event_is_enabled('COPT',p_effective_date) then
     l_pcp_chg := TRUE;
     ben_ext_chg_evt_api.create_ext_chg_evt
    (p_validate                 => FALSE
    ,p_ext_chg_evt_log_id     => l_ext_chg_evt_log_id
    ,p_chg_evt_cd             => 'COPT'
     ,p_chg_eff_dt            => p_effective_date
     ,p_prmtr_03              => p_prtt_enrt_rslt_id
     ,p_prmtr_04              => p_elig_cvrd_dpnt_id
     ,p_prmtr_08              => p_prmry_care_prvdr_id
     ,p_person_id             => l_person_id
     ,p_business_group_id     => p_business_group_id
     ,p_object_version_number => l_object_version_number
     ,p_effective_date        => p_effective_date
     ,p_old_val1              => p_old_name
     ,p_old_val2              => p_old_ext_ident
     ,p_old_val3              => l_old_prmry_care_prvdr_typ_cd
     ,p_new_val1              => p_old_name
     ,p_new_val2              => p_old_ext_ident
     ,p_new_val3              => l_prmry_care_prvdr_typ_cd);
    end if;
    --
   end if;
   --
   if p_name <> p_old_name then
    --
    if change_event_is_enabled('COPN',p_effective_date) then
     l_pcp_chg := TRUE;
     ben_ext_chg_evt_api.create_ext_chg_evt
     (p_validate              => FALSE
     ,p_ext_chg_evt_log_id    => l_ext_chg_evt_log_id
     ,p_chg_evt_cd            => 'COPN'
     ,p_chg_eff_dt            => p_effective_date
     ,p_prmtr_03              => p_prtt_enrt_rslt_id
     ,p_prmtr_04              => p_elig_cvrd_dpnt_id
     ,p_prmtr_08              => p_prmry_care_prvdr_id
     ,p_person_id             => l_person_id
     ,p_business_group_id     => p_business_group_id
     ,p_object_version_number => l_object_version_number
     ,p_effective_date        => p_effective_date
     ,p_old_val1              => p_old_name
     ,p_old_val2              => p_old_ext_ident
     ,p_old_val3              => l_old_prmry_care_prvdr_typ_cd
     ,p_new_val1              => p_name
     ,p_new_val2              => p_old_ext_ident
     ,p_new_val3              => l_old_prmry_care_prvdr_typ_cd);
     end if;
    --
    end if;
    --
    if p_ext_ident <> p_old_ext_ident then
     if change_event_is_enabled('COPI',p_effective_date) then
      ben_ext_chg_evt_api.create_ext_chg_evt
     (p_validate               => FALSE
     ,p_ext_chg_evt_log_id    => l_ext_chg_evt_log_id
     ,p_chg_evt_cd            => 'COPI'
     ,p_chg_eff_dt            => p_effective_date
     ,p_prmtr_03              => p_prtt_enrt_rslt_id
     ,p_prmtr_04              => p_elig_cvrd_dpnt_id
     ,p_prmtr_08              => p_prmry_care_prvdr_id
     ,p_person_id             => l_person_id
     ,p_business_group_id     => p_business_group_id
     ,p_object_version_number => l_object_version_number
     ,p_effective_date        => p_effective_date
     ,p_old_val1              => p_old_name
     ,p_old_val2              => p_old_ext_ident
     ,p_old_val3              => l_old_prmry_care_prvdr_typ_cd
     ,p_new_val1              => p_old_name
     ,p_new_val2              => p_ext_ident
     ,p_new_val3              => l_old_prmry_care_prvdr_typ_cd);
    end if;
    --
   end if;
  --
  elsif p_action = 'DELETE' then
  --
     if change_event_is_enabled('DPCP',p_effective_date) then
     l_pcp_chg := TRUE;
      ben_ext_chg_evt_api.create_ext_chg_evt
     (p_validate               => FALSE
     ,p_ext_chg_evt_log_id    => l_ext_chg_evt_log_id
     ,p_chg_evt_cd            => 'DPCP'
     ,p_chg_eff_dt            => p_effective_date
     ,p_prmtr_03              => p_prtt_enrt_rslt_id
     ,p_prmtr_04              => p_elig_cvrd_dpnt_id
     ,p_prmtr_08              => p_prmry_care_prvdr_id
     ,p_person_id             => l_person_id
     ,p_business_group_id     => p_business_group_id
     ,p_object_version_number => l_object_version_number
     ,p_effective_date        => p_effective_date
     ,p_old_val1              => p_old_name
     ,p_old_val2              => p_old_ext_ident
     ,p_old_val3              => l_old_prmry_care_prvdr_typ_cd);
    end if;
  --
  end if;  --p_action
  --record change event(update contact's primary care provider) for participant.
  if l_pcp_chg then
    -- only the person type is contact
    open c_relationship(l_person_id);
    fetch c_relationship into l_contact,l_relationship,l_name;
    if c_relationship%notfound then
      close c_relationship;
    elsif c_relationship%found then
      close c_relationship;
      l_person_id := l_relationship;
      if p_action = 'CREATE' then
        ben_ext_chg_evt_api.create_ext_chg_evt
        (p_validate              => FALSE
        ,p_ext_chg_evt_log_id    => l_ext_chg_evt_log_id
        ,p_chg_evt_cd            => 'CCPC'
        ,p_chg_eff_dt            => p_effective_date
        ,p_prmtr_01              => l_relationship
        ,p_prmtr_03              => p_prtt_enrt_rslt_id
        ,p_prmtr_04              => p_elig_cvrd_dpnt_id
        ,p_prmtr_08              => p_prmry_care_prvdr_id
        ,p_person_id             => l_person_id
        ,p_business_group_id     => p_business_group_id
        ,p_object_version_number => l_object_version_number
        ,p_effective_date        => p_effective_date
        ,p_new_val1              => substr(l_name,1,240)
        ,p_new_val2              => substr(p_name,1,240)
        ,p_new_val3              => l_prmry_care_prvdr_typ_cd);
      elsif p_action = 'UPDATE' then
        if p_prmry_care_prvdr_typ_cd is not null then
           v_prmry_care_prvdr_typ_cd := l_prmry_care_prvdr_typ_cd;
        else
           v_prmry_care_prvdr_typ_cd := l_old_prmry_care_prvdr_typ_cd;
        end if;
         ben_ext_chg_evt_api.create_ext_chg_evt
         (p_validate              => FALSE
          ,p_ext_chg_evt_log_id    => l_ext_chg_evt_log_id
          ,p_chg_evt_cd            => 'CCPC'
          ,p_chg_eff_dt            => p_effective_date
          ,p_prmtr_01              => l_relationship
          ,p_prmtr_03              => p_prtt_enrt_rslt_id
          ,p_prmtr_04              => p_elig_cvrd_dpnt_id
          ,p_prmtr_08              => p_prmry_care_prvdr_id
          ,p_person_id             => l_person_id
          ,p_business_group_id     => p_business_group_id
          ,p_object_version_number => l_object_version_number
          ,p_effective_date        => p_effective_date
          ,p_old_val1              => substr(l_name,1,200)
          ,p_old_val2              => p_old_name
          ,p_old_val3              => l_old_prmry_care_prvdr_typ_cd
          ,p_new_val1              => substr(l_name,1,240)
          ,p_new_val2              => substr(p_name,1,240)
          ,p_new_val3              => v_prmry_care_prvdr_typ_cd);
       elsif p_action = 'DELETE' then
         ben_ext_chg_evt_api.create_ext_chg_evt
         (p_validate               => FALSE
          ,p_ext_chg_evt_log_id    => l_ext_chg_evt_log_id
          ,p_chg_evt_cd            => 'CCPC'
          ,p_chg_eff_dt            => p_effective_date
          ,p_prmtr_01              => l_relationship
          ,p_prmtr_03              => p_prtt_enrt_rslt_id
          ,p_prmtr_04              => p_elig_cvrd_dpnt_id
          ,p_prmtr_08              => p_prmry_care_prvdr_id
          ,p_person_id             => l_person_id
          ,p_business_group_id     => p_business_group_id
          ,p_object_version_number => l_object_version_number
          ,p_effective_date        => p_effective_date
          ,p_old_val1              => substr(l_name,1,240)
          ,p_old_val2              => p_old_name
          ,p_old_val3              => l_old_prmry_care_prvdr_typ_cd);
       end if;
    end if;

    --- all the contact relationship  person

    open c_con_relationship(l_person_id);
    Loop
      fetch c_con_relationship into l_contact,l_relationship,l_name;
      exit when c_con_relationship%notfound ;
      l_person_id := l_relationship;
      if p_action = 'CREATE' then
         ben_ext_chg_evt_api.create_ext_chg_evt
            (p_validate              => FALSE
            ,p_ext_chg_evt_log_id    => l_ext_chg_evt_log_id
            ,p_chg_evt_cd            => 'CCNPC'
            ,p_chg_eff_dt            => p_effective_date
            ,p_prmtr_01              => l_relationship
            ,p_prmtr_03              => p_prtt_enrt_rslt_id
            ,p_prmtr_04              => p_elig_cvrd_dpnt_id
            ,p_prmtr_08              => p_prmry_care_prvdr_id
            ,p_person_id             => l_person_id
            ,p_business_group_id     => p_business_group_id
            ,p_object_version_number => l_object_version_number
            ,p_effective_date        => p_effective_date
            ,p_new_val1              => substr(l_name,1,240)
            ,p_new_val2              => substr(p_name,1,240)
            ,p_new_val3              => l_prmry_care_prvdr_typ_cd);
      elsif p_action = 'UPDATE' then
         if p_prmry_care_prvdr_typ_cd is not null then
            v_prmry_care_prvdr_typ_cd := l_prmry_care_prvdr_typ_cd;
         else
            v_prmry_care_prvdr_typ_cd := l_old_prmry_care_prvdr_typ_cd;
         end if;
         ben_ext_chg_evt_api.create_ext_chg_evt
            (p_validate              => FALSE
            ,p_ext_chg_evt_log_id    => l_ext_chg_evt_log_id
            ,p_chg_evt_cd            => 'CCNPC'
            ,p_chg_eff_dt            => p_effective_date
            ,p_prmtr_01              => l_relationship
            ,p_prmtr_03              => p_prtt_enrt_rslt_id
            ,p_prmtr_04              => p_elig_cvrd_dpnt_id
            ,p_prmtr_08              => p_prmry_care_prvdr_id
            ,p_person_id             => l_person_id
            ,p_business_group_id     => p_business_group_id
            ,p_object_version_number => l_object_version_number
            ,p_effective_date        => p_effective_date
            ,p_old_val1              => substr(l_name,1,200)
            ,p_old_val2              => p_old_name
            ,p_old_val3              => l_old_prmry_care_prvdr_typ_cd
            ,p_new_val1              => substr(l_name,1,240)
            ,p_new_val2              => substr(p_name,1,240)
            ,p_new_val3              => v_prmry_care_prvdr_typ_cd);
      elsif p_action = 'DELETE' then
         ben_ext_chg_evt_api.create_ext_chg_evt
            (p_validate               => FALSE
            ,p_ext_chg_evt_log_id    => l_ext_chg_evt_log_id
            ,p_chg_evt_cd            => 'CCNPC'
            ,p_chg_eff_dt            => p_effective_date
            ,p_prmtr_01              => l_relationship
            ,p_prmtr_03              => p_prtt_enrt_rslt_id
            ,p_prmtr_04              => p_elig_cvrd_dpnt_id
            ,p_prmtr_08              => p_prmry_care_prvdr_id
            ,p_person_id             => l_person_id
            ,p_business_group_id     => p_business_group_id
            ,p_object_version_number => l_object_version_number
            ,p_effective_date        => p_effective_date
            ,p_old_val1              => substr(l_name,1,240)
            ,p_old_val2              => p_old_name
            ,p_old_val3              => l_old_prmry_care_prvdr_typ_cd);
       end if;
    End Loop ;
    close c_con_relationship;
    -- end of creating log for all relationship
  --
  end if;  --p_action
  hr_utility.set_location('Exiting:'||l_proc, 99);
--
end log_pcp_chg;
--
procedure log_pos_chg
          (p_event     in  varchar2
          ,p_old_rec   in  g_pos_rec_type
          ,p_new_rec   in  g_pos_rec_type
          ) is
--
  l_chg_evt_tab           g_char_tab_type;
  l_prmtr_01_tab          g_char_tab_type;
  l_prmtr_02_tab          g_char_tab_type;
  l_prmtr_03_tab          g_char_tab_type;
  l_prmtr_04_tab          g_char_tab_type;
  l_prmtr_05_tab          g_char_tab_type;
  l_prmtr_06_tab          g_char_tab_type;
  l_prmtr_07_tab          g_char_tab_type;
  l_new_val1              g_new_val;
  l_new_val2              g_new_val;
  l_new_val3              g_new_val;
  l_new_val4              g_new_val;
  l_new_val5              g_new_val;
  l_new_val6              g_new_val;
  l_old_val1              g_old_val;
  l_old_val2              g_old_val;
  l_old_val3              g_old_val;
  l_old_val4              g_old_val;
  l_old_val5              g_old_val;
  l_old_val6              g_old_val;
  l_tab_counter           binary_integer := 0;
--Bug 4539732  Changed the date type of l_chg_eff_dt to date table type
  l_chg_eff_dt            g_date_tab_type;
--End Bug 4539732
  l_count                 number;
  l_ext_chg_evt_log_id    number;
  l_object_version_number number;
--
  l_proc         varchar2(72) := 'ben_ext_chlg.log_pos_chg';
--
begin
--
  hr_utility.set_location('Entering:'||l_proc, 10);


--
  if p_event = 'UPDATE' then
--
    if p_old_rec.actual_termination_date is null and p_new_rec.actual_termination_date is not null then
      l_tab_counter := l_tab_counter + 1;
--Bug 4539732  Store the change effective date for each event in its own place
      l_chg_eff_dt(l_tab_counter) := p_new_rec.actual_termination_date;
--End Bug 4539732
      l_chg_evt_tab(l_tab_counter) := 'AAT';
      l_prmtr_01_tab(l_tab_counter) := p_old_rec.period_of_service_id;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter)     := p_old_rec.actual_termination_date;
      l_new_val1(l_tab_counter)     := p_new_rec.actual_termination_date;
    end if;
    if p_old_rec.actual_termination_date is not null and
         p_new_rec.actual_termination_date is not null and
         p_old_rec.actual_termination_date <> p_new_rec.actual_termination_date then
      l_tab_counter := l_tab_counter + 1;
--Bug 4539732  Store the change effective date for each event in its own place
      l_chg_eff_dt(l_tab_counter) := p_new_rec.actual_termination_date;
--End Bug 4539732
      l_chg_evt_tab(l_tab_counter) := 'COAT';
      l_prmtr_01_tab(l_tab_counter) := p_old_rec.period_of_service_id;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter)     := p_old_rec.actual_termination_date;
      l_new_val1(l_tab_counter)     := p_new_rec.actual_termination_date;
    end if;
    if p_old_rec.actual_termination_date is not null and p_new_rec.actual_termination_date is null then
      l_tab_counter := l_tab_counter + 1;
--Bug 4539732  Store the change effective date for each event in its own place
      l_chg_eff_dt(l_tab_counter) := p_old_rec.actual_termination_date;
--End Bug 4539732
      l_chg_evt_tab(l_tab_counter) := 'DAT';
      l_prmtr_01_tab(l_tab_counter) := p_old_rec.period_of_service_id;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter)     := p_old_rec.actual_termination_date;
      l_new_val1(l_tab_counter)     := null;
    end if;
    if nvl(p_old_rec.leaving_reason,'*') <> nvl(p_new_rec.leaving_reason,'*') then
      l_tab_counter := l_tab_counter + 1;
--Bug 4539732  Store the change effective date for each event in its own place
      l_chg_eff_dt(l_tab_counter) := nvl(p_old_rec.actual_termination_date,trunc(sysdate));
--      truncated the sysdate so that only date gets into rather than time also getting into the table
--End Bug 4539732
      l_chg_evt_tab(l_tab_counter) := 'COTR';
      l_prmtr_01_tab(l_tab_counter) := p_old_rec.period_of_service_id;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter)     := p_old_rec.leaving_reason;
      l_new_val1(l_tab_counter)     := p_new_rec.leaving_reason;
    end if;
   if p_old_rec.date_start is not null and
         p_new_rec.date_start is not null and
         p_old_rec.date_start <> p_new_rec.date_start then
      l_tab_counter := l_tab_counter + 1;
--Bug 4539732  Store the change effective date for each event in its own place
      l_chg_eff_dt(l_tab_counter) := p_new_rec.date_start;
--End Bug 4539732
      l_chg_evt_tab(l_tab_counter) := 'COPOS';
      l_prmtr_01_tab(l_tab_counter) := p_old_rec.period_of_service_id;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter)     := p_old_rec.date_start;
      l_new_val1(l_tab_counter)     := p_new_rec.date_start;
    end if;
  --
  elsif p_event = 'INSERT' then
      l_tab_counter := l_tab_counter + 1;
--Bug 4539732  Store the change effective date for each event in its own place
      l_chg_eff_dt(l_tab_counter) := p_new_rec.date_start;
--End Bug 4539732
      l_chg_evt_tab(l_tab_counter) := 'APS';
      l_prmtr_01_tab(l_tab_counter) := p_new_rec.period_of_service_id;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter)     := null;
      l_new_val1(l_tab_counter)     := p_new_rec.date_start;
  end if;
--
  for l_count in 1..l_chg_evt_tab.count loop
   if change_event_is_enabled(l_chg_evt_tab(l_count),l_chg_eff_dt(l_count)) then
--Bug 4539732  Create ext change event with each event having its own l_chg_eff_dt
    ben_ext_chg_evt_api.create_ext_chg_evt
    (p_validate                    => FALSE
    ,p_ext_chg_evt_log_id          => l_ext_chg_evt_log_id
    ,p_chg_evt_cd                  => l_chg_evt_tab(l_count)
    ,p_chg_eff_dt                  => l_chg_eff_dt(l_count)
    ,p_prmtr_01                    => l_prmtr_01_tab(l_count)
    ,p_prmtr_02                    => l_prmtr_02_tab(l_count)
    ,p_prmtr_03                    => l_prmtr_03_tab(l_count)
    ,p_prmtr_04                    => l_prmtr_04_tab(l_count)
    ,p_prmtr_05                    => l_prmtr_05_tab(l_count)
    ,p_prmtr_06                    => l_prmtr_06_tab(l_count)
    ,p_prmtr_07                    => l_prmtr_07_tab(l_count)
    ,p_prmtr_10                    => p_new_rec.update_mode
    ,p_person_id                   => p_new_rec.person_id
    ,p_business_group_id           => p_new_rec.business_group_id
    ,p_object_version_number       => l_object_version_number
    ,p_effective_date              => l_chg_eff_dt(l_count)
    ,p_new_val1                    => l_new_val1(l_count)
    ,p_old_val1                    => l_old_val1(l_count)
    );
--End Bug 4539732
   end if;
  end loop;
--
  hr_utility.set_location('Exiting:'||l_proc, 99);
--
end log_pos_chg;
--
procedure log_apl_chg
          (p_event     in  varchar2
          ,p_old_rec   in  g_apl_rec_type
          ,p_new_rec   in  g_apl_rec_type
          ) is
--
  l_chg_evt_tab           g_char_tab_type;
  l_prmtr_01_tab          g_char_tab_type;
  l_prmtr_02_tab          g_char_tab_type;
  l_prmtr_03_tab          g_char_tab_type;
  l_prmtr_04_tab          g_char_tab_type;
  l_prmtr_05_tab          g_char_tab_type;
  l_prmtr_06_tab          g_char_tab_type;
  l_prmtr_07_tab          g_char_tab_type;
  l_new_val1              g_new_val;
  l_new_val2              g_new_val;
  l_new_val3              g_new_val;
  l_new_val4              g_new_val;
  l_new_val5              g_new_val;
  l_new_val6              g_new_val;
  l_old_val1              g_old_val;
  l_old_val2              g_old_val;
  l_old_val3              g_old_val;
  l_old_val4              g_old_val;
  l_old_val5              g_old_val;
  l_old_val6              g_old_val;
  l_tab_counter           binary_integer := 0;
  l_chg_eff_dt            date;
  l_count                 number;
  l_ext_chg_evt_log_id    number;
  l_object_version_number number;
--
  l_proc         varchar2(72) := 'ben_ext_chlg.log_apl_chg';
--
  cursor c_termination_reason (p_termination_reason per_applications.termination_reason%type)
  is
  select hl.meaning
  from   hr_lookups hl
  where  hl.lookup_type = 'TERM_APL_REASON'
  and    hl.lookup_code = p_termination_reason
  and    hl.enabled_flag = 'Y';
--
  l_old_termination_reason  varchar2(50);
  l_new_termination_reason  varchar2(50);
--
begin
--
  hr_utility.set_location('Entering:'||l_proc, 10);
-- removed because the pos leaving reason should
-- have been used.
null;
--
  hr_utility.set_location('Exiting:'||l_proc, 99);
--
end log_apl_chg;
--


procedure log_prem_mo_chg
          (p_event     in  varchar2
          ,p_old_rec   in  g_prem_mo_rec_type
          ,p_new_rec   in  g_prem_mo_rec_type
          )is
--
  l_person_id             number ;
  l_ext_chg_evt_log_id    number ;
  l_object_version_number number;

  Cursor c_person(p_prtt_prem_id number) is
  select person_id
   from ben_per_in_ler  pil,
        ben_prtt_prem_f ppe
  where ppe.prtt_prem_id = p_prtt_prem_id
    and ppe.per_in_ler_id = pil.per_in_ler_id ;
--
  l_proc         varchar2(72) := 'ben_ext_chlg.log_prem_mo_chg';
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  open c_person(p_new_rec.prtt_prem_id) ;
  fetch c_person into l_person_id  ;
  close c_person ;

  if  p_new_rec.val <> p_old_rec.val then
      -- before the fix there was a typo in lookp code
      -- lookup code is COPMPRM, event logged for CCOPMPRM
      -- this is fixed by obsolete the COPMPRM and added CCOPMPRM in lookup
      -- the code support for COPMPRM to make sure the customer has no problem
      -- if the data is logged, ct can get the data by changing the setup at anytime

       hr_utility.set_location('valiating chg evt cd :', 10);
      if (change_event_is_enabled('COPMPRM',p_new_rec.effective_start_date) or
          change_event_is_enabled('CCOPMPRM',p_new_rec.effective_start_date) )  then

          hr_utility.set_location('calling  log event :', 10);

          ben_ext_chg_evt_api.create_ext_chg_evt
             (p_validate              => FALSE
              ,p_ext_chg_evt_log_id    => l_ext_chg_evt_log_id
              ,p_chg_evt_cd            => 'CCOPMPRM'
              ,p_chg_eff_dt            => p_new_rec.effective_start_date
              ,p_business_group_id     => p_new_rec.business_group_id
              ,p_person_id             => l_person_id
              ,p_object_version_number => l_object_version_number
              ,p_effective_date        => p_new_rec.effective_start_date
              ,p_old_val1              => p_old_rec.val
              ,p_old_val2              => p_old_rec.cr_val
              ,p_old_val3              => p_old_rec.mo_num
              ,p_old_val4              => p_old_rec.yr_num
              ,p_new_val1              => p_new_rec.val
              ,p_new_val2              => p_new_rec.cr_val
              ,p_new_val3              => p_new_rec.mo_num
              ,p_new_val4              => p_new_rec.yr_num
             );

       end if ;
  end if ;
--
  hr_utility.set_location('Exiting:'||l_proc, 99);
--
end log_prem_mo_chg;

--
procedure log_school_chg
          (p_event     in  varchar2
          ,p_old_rec   in  g_per_school_rec_type
          ,p_new_rec   in  g_per_school_rec_type
          ) is
--
  l_old_name     PER_ESTABLISHMENTS.name%type ;
  l_new_name     PER_ESTABLISHMENTS.name%type ;
  l_ext_chg_evt_log_id    number ;
  l_object_version_number number;

  Cursor c_name(p_establishment_id number) is
  select name from PER_ESTABLISHMENTS
  where establishment_id = p_establishment_id ;

--
  l_proc         varchar2(72) := 'ben_ext_chlg.log_school_chg';
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  open c_name(p_old_rec.establishment_id) ;
  fetch c_name into l_old_name  ;
  close c_name ;

  open c_name(p_new_rec.establishment_id) ;
  fetch c_name into l_new_name  ;
  close c_name ;

  if  nvl(l_new_name,'$$$$') <> nvl(l_old_name,'$$$$')
      or p_new_rec.attended_start_date <> p_old_rec.attended_start_date
      or p_new_rec.attended_end_date <> p_old_rec.attended_end_date then
      if change_event_is_enabled('COSCOL',p_new_rec.attended_start_date) then
          ben_ext_chg_evt_api.create_ext_chg_evt
             (p_validate              => FALSE
              ,p_ext_chg_evt_log_id    => l_ext_chg_evt_log_id
              ,p_chg_evt_cd            => 'COSCOL'
              ,p_chg_eff_dt            => p_new_rec.attended_start_date
              ,p_business_group_id     => p_new_rec.business_group_id
              ,p_person_id             => p_new_rec.person_id
              ,p_object_version_number => l_object_version_number
              ,p_effective_date        => p_new_rec.attended_start_date
              ,p_old_val1              => l_old_name
              ,p_old_val2              => p_old_rec.attended_start_date
              ,p_old_val3              => p_old_rec.attended_end_date
              ,p_new_val1              => l_new_name
              ,p_new_val2              => p_new_rec.attended_start_date
              ,p_new_val3              => p_new_rec.attended_end_date
             );
       end if ;
  end if ;
--
  hr_utility.set_location('Exiting:'||l_proc, 99);
--
end log_school_chg;




procedure log_per_pay_chg
          (p_event     in  varchar2
          ,p_old_rec   in  g_per_pay_rec_type
          ,p_new_rec   in  g_per_pay_rec_type
          ) is
--
  l_chg_eff_dt            date;
  l_count                 number;
  l_ext_chg_evt_log_id    number;
  l_object_version_number number;
--
  l_proc         varchar2(72) := 'ben_ext_chlg.log_per_pay_chg';
 cursor c_person (p_assignment_id number)
  is
  select person_id ,business_group_id
  from   per_all_Assignments_f  asg
  where  asg.assignment_id  = p_assignment_id ;
--
   cursor c_old_sal(p_assignment_id number,p_change_date date)  is
     select
     proposed_salary_n, approved
     from per_pay_proposals b
      where
          b.assignment_id = p_assignment_id
          and b.change_date =
          (select max(d.change_date)
             from  per_pay_proposals d
             where  d.assignment_id = b.assignment_id
             and approved = 'Y'
             and change_date < p_change_date  )
           ;


  l_person_id              number ;
  l_business_group_id      number ;
  l_old_proposed_salary_n  per_pay_proposals.proposed_salary_n%type := p_old_rec.proposed_salary_n;
  l_old_approved           per_pay_proposals.approved%type ;
--
begin
--

  hr_utility.set_location('Entering:'||l_proc, 10);
  hr_utility.set_location('assignment_id:'||p_new_rec.assignment_id, 10);
 /*
 open c_person(p_new_rec.assignment_id);
 fetch c_person into l_person_id,l_business_group_id ;
 close c_person ;
 */
 hr_utility.set_location(' EVENT ' || p_event, 99 );

 --- previously part of trigger  now the trigger moved to api (pepyprhi.pkb)
 --- so the approved validation moved here

 if nvl(p_new_rec.approved,'N') = 'Y' then
    if p_event = 'INSERT' then
       hr_utility.set_location('change_date' || p_new_rec.change_date,10);
       open c_old_sal(p_new_rec.assignment_id,p_new_rec.change_date);
       fetch c_old_sal into l_old_proposed_salary_n ,l_old_approved ;
       close c_old_sal ;
        hr_utility.set_location('salary ' || l_old_proposed_salary_n,10);
     end if ;



     if nvl(l_old_proposed_salary_n,-1) <> nvl(p_new_rec.proposed_salary_n,-1)
       or nvl(nvl(l_old_approved,p_old_rec.approved),'N') <> nvl(p_new_rec.approved,'N')  then

         if change_event_is_enabled('COBSAL',p_new_rec.change_date) then

            open c_person(p_new_rec.assignment_id);
            fetch c_person into l_person_id,l_business_group_id ;
            close c_person ;

             ben_ext_chg_evt_api.create_ext_chg_evt
                (p_validate              => FALSE
                ,p_ext_chg_evt_log_id    => l_ext_chg_evt_log_id
                ,p_chg_evt_cd            => 'COBSAL'
                ,p_chg_eff_dt            => p_new_rec.change_date
                ,p_business_group_id     => l_business_group_id
                ,p_person_id             => l_person_id
                ,p_object_version_number => l_object_version_number
                ,p_effective_date        => nvl(p_new_rec.change_date,p_new_rec.last_change_date)
                ,p_old_val1              => l_old_proposed_salary_n
                ,p_old_val2              => nvl(l_old_approved,p_old_rec.approved)
                ,p_new_val1              => p_new_rec.proposed_salary_n
                ,p_new_val2              => p_new_rec.approved
               );
           End if;
    end if ;
 end if ;
--
  hr_utility.set_location('Exiting:'||l_proc, 99);
--
end log_per_pay_chg;

----

procedure log_phn_chg
          (p_event     in  varchar2
          ,p_old_rec   in  g_phn_rec_type
          ,p_new_rec   in  g_phn_rec_type
          ) is
--
  l_chg_evt_tab           g_char_tab_type;
  l_prmtr_01_tab          g_char_tab_type;
  l_prmtr_02_tab          g_char_tab_type;
  l_prmtr_03_tab          g_char_tab_type;
  l_prmtr_04_tab          g_char_tab_type;
  l_prmtr_05_tab          g_char_tab_type;
  l_prmtr_06_tab          g_char_tab_type;
  l_prmtr_07_tab          g_char_tab_type;
  l_new_val1              g_new_val;
  l_new_val2              g_new_val;
  l_new_val3              g_new_val;
  l_new_val4              g_new_val;
  l_new_val5              g_new_val;
  l_new_val6              g_new_val;
  l_old_val1              g_old_val;
  l_old_val2              g_old_val;
  l_old_val3              g_old_val;
  l_old_val4              g_old_val;
  l_old_val5              g_old_val;
  l_old_val6              g_old_val;
  l_tab_counter           binary_integer := 0;
  l_chg_eff_dt            date;
  l_count                 number := 0;
  l_ext_chg_evt_log_id    number;
  l_object_version_number number;
--
  l_proc         varchar2(72) := 'ben_ext_chlg.log_phn_chg';
--
  cursor c_termination_reason (p_termination_reason per_applications.termination_reason%type)
  is
  select meaning
  from   hr_lookups hl
  where  hl.lookup_type = 'TERM_APL_REASON'
  and    hl.lookup_code = p_termination_reason
  and    hl.enabled_flag = 'Y';
--
  cursor c_business_group_id(p_person_id per_all_people_f.person_id%type
				    /* ,p_effective_dt date */-- commented for bug 3361237
					)
  is
  select ppf.business_group_id
  from   per_all_people_f ppf
  where  ppf.person_id = p_person_id;
/*  and    p_effective_dt between nvl(ppf.effective_start_date, sysdate)
                        and nvl(ppf.effective_end_date, sysdate);*/
-- commented for bug 3361237
--
  l_old_termination_reason  varchar2(50);
  l_new_termination_reason  varchar2(50);
  l_chg_evt_code            varchar2(10);
  l_business_group_id       number;
  l_person_id               number;       --Bug 1554477
  l_update_mode             varchar2(15); --Bug 1554477
--
begin
--
  hr_utility.set_location('Entering:'||l_proc, 10);
--
  if p_event = 'UPDATE' and p_new_rec.parent_table = 'PER_ALL_PEOPLE_F'
    and p_new_rec.phone_type in ('H1', 'W1', 'HF','M') then
--
    --Start Bug 1554477
      if p_old_rec.date_to is null and
            p_new_rec.date_to is not null then

        if p_new_rec.phone_type = 'H1' then
          l_chg_evt_code := 'AHPDT';
        elsif p_new_rec.phone_type = 'W1' then
          l_chg_evt_code := 'AWPDT';
        elsif p_new_rec.phone_type = 'HF' then
          l_chg_evt_code := 'AFPDT';
        elsif p_new_rec.phone_type = 'M' then
          l_chg_evt_code := 'AMDT';
        end if;
        l_chg_eff_dt := nvl(p_new_rec.date_to, sysdate);
        l_tab_counter := l_tab_counter + 1;
        l_chg_evt_tab(l_tab_counter) := l_chg_evt_code;
        l_prmtr_01_tab(l_tab_counter) := p_old_rec.phone_id;
        l_prmtr_02_tab(l_tab_counter) := null;
        l_prmtr_03_tab(l_tab_counter) := null;
        l_prmtr_04_tab(l_tab_counter) := null;
        l_prmtr_05_tab(l_tab_counter) := null;
        l_prmtr_06_tab(l_tab_counter) := null;
        l_prmtr_07_tab(l_tab_counter) := null;
        l_old_val1(l_tab_counter)     := p_old_rec.phone_number;
        l_new_val1(l_tab_counter)     := null;
        --
        l_update_mode := p_new_rec.update_mode;
        l_person_id := p_new_rec.parent_id;
       end if;
     --End Bug 1554477

      if nvl(p_old_rec.phone_number, '$') <>
           nvl(p_new_rec.phone_number, '$') then
        if p_new_rec.phone_type = 'H1' then
          l_chg_evt_code := 'COHP';
        elsif p_new_rec.phone_type = 'W1' then
          l_chg_evt_code := 'COWP';
        elsif p_new_rec.phone_type = 'HF' then
          l_chg_evt_code := 'COFP';
        elsif p_new_rec.phone_type = 'M' then	--Bug 1554477
          l_chg_evt_code := 'CMP';
        end if;
        l_chg_eff_dt := nvl(p_new_rec.date_from, sysdate);
        l_tab_counter := l_tab_counter + 1;
        l_chg_evt_tab(l_tab_counter) := l_chg_evt_code;
        l_prmtr_01_tab(l_tab_counter) := p_old_rec.phone_id;
        l_prmtr_02_tab(l_tab_counter) := null;
        l_prmtr_03_tab(l_tab_counter) := null;
        l_prmtr_04_tab(l_tab_counter) := null;
        l_prmtr_05_tab(l_tab_counter) := null;
        l_prmtr_06_tab(l_tab_counter) := null;
        l_prmtr_07_tab(l_tab_counter) := null;
        l_old_val1(l_tab_counter)     := p_old_rec.phone_number;
        l_new_val1(l_tab_counter)     := p_new_rec.phone_number;
        --
        l_update_mode := p_new_rec.update_mode;
        l_person_id := p_new_rec.parent_id;
       end if;

 --Start Bug 1554477
   elsif p_event = 'INSERT' and p_new_rec.parent_table = 'PER_ALL_PEOPLE_F'
    and p_new_rec.phone_type in ('H1', 'W1', 'HF', 'M') then
--
        if p_old_rec.date_to is null and
            p_new_rec.date_to is not null then
        if p_new_rec.phone_type = 'H1' then
          l_chg_evt_code := 'AHPDT';
        elsif p_new_rec.phone_type = 'W1' then
          l_chg_evt_code := 'AWPDT';
        elsif p_new_rec.phone_type = 'HF' then
          l_chg_evt_code := 'AFPDT';
        elsif p_new_rec.phone_type = 'M' then
          l_chg_evt_code := 'AMDT';
        end if;
        l_chg_eff_dt := nvl(p_new_rec.date_to, sysdate);
        l_tab_counter := l_tab_counter + 1;
        l_chg_evt_tab(l_tab_counter) := l_chg_evt_code;
        l_prmtr_01_tab(l_tab_counter) := p_old_rec.phone_id;
        l_prmtr_02_tab(l_tab_counter) := null;
        l_prmtr_03_tab(l_tab_counter) := null;
        l_prmtr_04_tab(l_tab_counter) := null;
        l_prmtr_05_tab(l_tab_counter) := null;
        l_prmtr_06_tab(l_tab_counter) := null;
        l_prmtr_07_tab(l_tab_counter) := null;
        l_old_val1(l_tab_counter)     := p_new_rec.phone_number;
        l_new_val1(l_tab_counter)     := null;
        --
        l_update_mode := p_new_rec.update_mode;
        l_person_id := p_new_rec.parent_id;
        end if;

        if p_new_rec.phone_type = 'H1' then
          l_chg_evt_code := 'AHP';
        elsif p_new_rec.phone_type = 'W1' then
          l_chg_evt_code := 'AWP';
        elsif p_new_rec.phone_type = 'HF' then
          l_chg_evt_code := 'AFP';
        elsif p_new_rec.phone_type = 'M' then
          l_chg_evt_code := 'AMP';
        end if;
        l_chg_eff_dt := nvl(p_new_rec.date_from, sysdate);
        l_tab_counter := l_tab_counter + 1;
        l_chg_evt_tab(l_tab_counter) := l_chg_evt_code;
        l_prmtr_01_tab(l_tab_counter) := p_new_rec.phone_id;
        l_prmtr_02_tab(l_tab_counter) := null;
        l_prmtr_03_tab(l_tab_counter) := null;
        l_prmtr_04_tab(l_tab_counter) := null;
        l_prmtr_05_tab(l_tab_counter) := null;
        l_prmtr_06_tab(l_tab_counter) := null;
        l_prmtr_07_tab(l_tab_counter) := null;
        l_old_val1(l_tab_counter)     := null;
        l_new_val1(l_tab_counter)     := p_new_rec.phone_number;
        --

        l_update_mode := p_new_rec.update_mode;
        l_person_id := p_new_rec.parent_id;

    elsif p_event = 'DELETE' and p_old_rec.parent_table = 'PER_ALL_PEOPLE_F'
    and p_old_rec.phone_type in ('H1', 'W1', 'HF', 'M') then
--

        if p_old_rec.phone_type = 'H1' then
          l_chg_evt_code := 'DHP';
        elsif p_old_rec.phone_type = 'W1' then
          l_chg_evt_code := 'DWP';
        elsif p_old_rec.phone_type = 'HF' then
          l_chg_evt_code := 'DFP';
        elsif p_old_rec.phone_type = 'M' then
          l_chg_evt_code := 'DMP';
        end if;
        --l_chg_eff_dt := nvl(p_old_rec.date_from, sysdate);-- 3361237
        l_chg_eff_dt := greatest(nvl(p_old_rec.date_to, p_old_rec.date_from), sysdate);
        l_tab_counter := l_tab_counter + 1;
        l_chg_evt_tab(l_tab_counter) := l_chg_evt_code;
        l_prmtr_01_tab(l_tab_counter) := p_old_rec.phone_id;
        l_prmtr_02_tab(l_tab_counter) := null;
        l_prmtr_03_tab(l_tab_counter) := null;
        l_prmtr_04_tab(l_tab_counter) := null;
        l_prmtr_05_tab(l_tab_counter) := null;
        l_prmtr_06_tab(l_tab_counter) := null;
        l_prmtr_07_tab(l_tab_counter) := null;
        l_old_val1(l_tab_counter)     := p_old_rec.phone_number;
        l_new_val1(l_tab_counter)     := null;
        --

        l_update_mode := p_old_rec.update_mode;
        l_person_id := p_old_rec.parent_id;
   end if;

--Bug 1554477

--
  open c_business_group_id(l_person_id); --, l_chg_eff_dt);    -- commented for bug 3361237
-- Bug 1554477
  fetch c_business_group_id into l_business_group_id;
  close c_business_group_id;
  hr_utility.set_location('l_business_group_id:'||l_business_group_id, 876);

  for l_count in 1..l_chg_evt_tab.count loop
   if change_event_is_enabled(l_chg_evt_tab(l_count),l_chg_eff_dt) then

    ben_ext_chg_evt_api.create_ext_chg_evt
    (p_validate                    => FALSE
    ,p_ext_chg_evt_log_id          => l_ext_chg_evt_log_id
    ,p_chg_evt_cd                  => l_chg_evt_tab(l_count)
    ,p_chg_eff_dt                  => l_chg_eff_dt
    ,p_prmtr_01                    => l_prmtr_01_tab(l_count)
    ,p_prmtr_02                    => l_prmtr_02_tab(l_count)
    ,p_prmtr_03                    => l_prmtr_03_tab(l_count)
    ,p_prmtr_04                    => l_prmtr_04_tab(l_count)
    ,p_prmtr_05                    => l_prmtr_05_tab(l_count)
    ,p_prmtr_06                    => l_prmtr_06_tab(l_count)
    ,p_prmtr_07                    => l_prmtr_07_tab(l_count)
    ,p_prmtr_10                    => l_update_mode       --Bug 1554477
    ,p_person_id                   => l_person_id         --Bug 1554477
    ,p_business_group_id           => l_business_group_id
    ,p_object_version_number       => l_object_version_number
    ,p_effective_date              => l_chg_eff_dt
    ,p_new_val1                    => l_new_val1(l_count)
    ,p_old_val1                    => l_old_val1(l_count)
    );

    end if;
  end loop;
--
  hr_utility.set_location('Exiting:'||l_proc, 99);
--
end log_phn_chg;
--
procedure log_ptu_chg
          (p_event     in  varchar2
          ,p_old_rec   in  g_ptu_rec_type
          ,p_new_rec   in  g_ptu_rec_type
          ) is
--
  l_chg_evt_tab           g_char_tab_type;
  l_prmtr_01_tab          g_char_tab_type;
  l_prmtr_02_tab          g_char_tab_type;
  l_prmtr_03_tab          g_char_tab_type;
  l_prmtr_04_tab          g_char_tab_type;
  l_prmtr_05_tab          g_char_tab_type;
  l_prmtr_06_tab          g_char_tab_type;
  l_prmtr_07_tab          g_char_tab_type;
  l_new_val1              g_new_val;
  l_new_val2              g_new_val;
  l_new_val3              g_new_val;
  l_new_val4              g_new_val;
  l_new_val5              g_new_val;
  l_new_val6              g_new_val;
  l_old_val1              g_old_val;
  l_old_val2              g_old_val;
  l_old_val3              g_old_val;
  l_old_val4              g_old_val;
  l_old_val5              g_old_val;
  l_old_val6              g_old_val;
  l_tab_counter           binary_integer := 0;
  l_chg_eff_dt            date;
  l_count                 number := 0;
  l_ext_chg_evt_log_id    number;
  l_object_version_number number;
  l_old_user_person_type  ben_ext_chg_evt_log.old_val1%TYPE;
  l_old_person_typ        ben_ext_chg_evt_log.old_val1%TYPE;
  l_new_user_person_type  ben_ext_chg_evt_log.new_val1%TYPE;
  -- Bug 4705814.
--
  l_proc         varchar2(72) := 'ben_ext_chlg.log_ptu_chg';
--
  cursor c_person_type(p_person_type_id    per_person_types.person_type_id%type)
  is
  select ppt.system_person_type, ppt.user_person_type, ppt.business_group_id
  from   per_person_types ppt
  where  ppt.person_type_id = p_person_type_id;
--
  l_chg_evt_code      varchar2(30);
  l_person_type       varchar2(30);
  l_business_group_id number;
--
begin
--
  hr_utility.set_location('Entering:'||l_proc, 10);
--
  if p_event = 'INSERT' then
--
    open c_person_type(p_new_rec.person_type_id);
    fetch c_person_type into l_person_type, l_new_user_person_type, l_business_group_id;
    close c_person_type;

    l_chg_evt_code := null;
    if l_person_type = 'EMP' then
      l_chg_evt_code := 'AEPTU';
    elsif l_person_type = 'BNF' then
      l_chg_evt_code := 'ABPTU';
    elsif l_person_type = 'DPNT' then
      l_chg_evt_code := 'ADPTU';
    elsif l_person_type = 'PRTN' then
      l_chg_evt_code := 'APPTU';
    end if;

    open c_person_type(p_old_rec.person_type_id);
    fetch c_person_type into l_old_person_typ, l_old_user_person_type, l_business_group_id;
    close c_person_type;

    if l_chg_evt_code is not null then

      l_chg_eff_dt := nvl(p_new_rec.effective_start_date, sysdate);
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := l_chg_evt_code;
      l_prmtr_01_tab(l_tab_counter) := p_new_rec.person_type_usage_id;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter)     := l_old_user_person_type; -- null;
      l_new_val1(l_tab_counter)     := l_new_user_person_type; -- null;
      -- Bug 4705814, passing person_type ( Initially passed NULLs ) to Old, New Values

    end if;

  end if;
--
  for l_count in 1..l_chg_evt_tab.count loop
   if change_event_is_enabled(l_chg_evt_tab(l_count),l_chg_eff_dt) then
    ben_ext_chg_evt_api.create_ext_chg_evt
    (p_validate                    => FALSE
    ,p_ext_chg_evt_log_id          => l_ext_chg_evt_log_id
    ,p_chg_evt_cd                  => l_chg_evt_tab(l_count)
    ,p_chg_eff_dt                  => l_chg_eff_dt
    ,p_prmtr_01                    => l_prmtr_01_tab(l_count)
    ,p_prmtr_02                    => l_prmtr_02_tab(l_count)
    ,p_prmtr_03                    => l_prmtr_03_tab(l_count)
    ,p_prmtr_04                    => l_prmtr_04_tab(l_count)
    ,p_prmtr_05                    => l_prmtr_05_tab(l_count)
    ,p_prmtr_06                    => l_prmtr_06_tab(l_count)
    ,p_prmtr_07                    => l_prmtr_07_tab(l_count)
    ,p_prmtr_10                    => p_new_rec.update_mode
    ,p_person_id                   => p_new_rec.person_id
    ,p_business_group_id           => l_business_group_id
    ,p_object_version_number       => l_object_version_number
    ,p_effective_date              => l_chg_eff_dt
    ,p_new_val1                    => l_new_val1(l_count)
    ,p_old_val1                    => l_old_val1(l_count)
    );
   end if;
  end loop;
--
  hr_utility.set_location('Exiting:'||l_proc, 99);
--
end log_ptu_chg;
--
procedure log_element_chg(
        p_action               in varchar2,
        p_amt                  in number default null,
        p_old_amt              in number default null,
        p_input_value_id       in number default null,
        p_element_entry_id     in number default null,
        p_person_id            in number default null,
        p_effective_start_date in date default null,
        p_effective_end_date   in date default null,
        p_business_group_id    in number,
        p_effective_date       in date) is
--
  l_proc         varchar2(72) := 'ben_ext_chlg.log_element_chg';
--
l_object_version_number number;
l_ext_chg_evt_log_id number;
--
cursor c_get_element_info (p_input_value_id number) is
 select iv.name, et.element_name
 from pay_input_values_f iv,
      pay_element_types_f et
 where iv.input_value_id = p_input_value_id
 and   iv.element_type_id = et.element_type_id
 and   p_effective_date between iv.effective_start_date and iv.effective_end_date
 and   p_effective_date between et.effective_start_date and et.effective_end_date;
--
l_element_info c_get_element_info%rowtype;

--
begin
--
  hr_utility.set_location('Entering:'||l_proc, 10);
--
open c_get_element_info(p_input_value_id);
fetch c_get_element_info into l_element_info;
close c_get_element_info;
--
  if p_action = 'CREATE' then
    if change_event_is_enabled('AEE',p_effective_date) then
     ben_ext_chg_evt_api.create_ext_chg_evt
     (p_validate              => FALSE
     ,p_ext_chg_evt_log_id    => l_ext_chg_evt_log_id
     ,p_chg_evt_cd            => 'AEE'
     ,p_chg_eff_dt            => p_effective_date
     ,p_prmtr_01              => p_element_entry_id
     ,p_prmtr_02              => p_input_value_id
     ,p_person_id             => p_person_id
     ,p_business_group_id     => p_business_group_id
     ,p_object_version_number => l_object_version_number
     ,p_effective_date        => p_effective_date
     ,p_new_val1              => l_element_info.element_name
     ,p_new_val2              => l_element_info.name
     ,p_new_val3              => p_amt);
    end if;
    --
  elsif p_action = 'UPDATE' then
    if change_event_is_enabled('UEE',p_effective_date) then
     ben_ext_chg_evt_api.create_ext_chg_evt
     (p_validate              => FALSE
     ,p_ext_chg_evt_log_id    => l_ext_chg_evt_log_id
     ,p_chg_evt_cd            => 'UEE'
     ,p_chg_eff_dt            => p_effective_date
     ,p_prmtr_01              => p_element_entry_id
     ,p_prmtr_02              => p_input_value_id
     ,p_person_id             => p_person_id
     ,p_business_group_id     => p_business_group_id
     ,p_object_version_number => l_object_version_number
     ,p_effective_date        => p_effective_date
     ,p_old_val1              => l_element_info.element_name
     ,p_old_val2              => l_element_info.name
     ,p_old_val3              => p_old_amt
     ,p_new_val1              => l_element_info.element_name
     ,p_new_val2              => l_element_info.name
     ,p_new_val3              => p_amt);
    end if;
    --
  elsif p_action = 'DELETE' then
    hr_utility.set_location('deleteing element entry ' , 195);
    if change_event_is_enabled('DEE',p_effective_date) then
     ben_ext_chg_evt_api.create_ext_chg_evt
     (p_validate              => FALSE
     ,p_ext_chg_evt_log_id    => l_ext_chg_evt_log_id
     ,p_chg_evt_cd            => 'DEE'
     ,p_chg_eff_dt            => p_effective_date
     ,p_prmtr_01              => p_element_entry_id
     ,p_prmtr_02              => p_input_value_id
     ,p_person_id             => p_person_id
     ,p_business_group_id     => p_business_group_id
     ,p_object_version_number => l_object_version_number
     ,p_effective_date        => p_effective_date
     ,p_old_val1              => l_element_info.element_name
     ,p_old_val2              => l_element_info.name
     ,p_old_val3              => p_old_amt);
    end if;
  end if;
--
--
  hr_utility.set_location('Exiting:'||l_proc, 99);
--
end log_element_chg;
--
-- procedure for logging changes to per_disabilities_f
  procedure log_per_dis_chg
          (p_event     in  varchar2
          ,p_old_rec   in  per_dis_rec_type
          ,p_new_rec   in  per_dis_rec_type
          ) is
--
  l_chg_evt_tab           g_char_tab_type;
  l_prmtr_01_tab          g_char_tab_type;
  l_prmtr_02_tab          g_char_tab_type;
  l_prmtr_03_tab          g_char_tab_type;
  l_prmtr_04_tab          g_char_tab_type;
  l_prmtr_05_tab          g_char_tab_type;
  l_prmtr_06_tab          g_char_tab_type;
  l_prmtr_07_tab          g_char_tab_type;
  l_old_val1              g_old_val;
  l_old_val2              g_old_val;
  l_old_val3              g_old_val;
  l_old_val4              g_old_val;
  l_old_val5              g_old_val;
  l_old_val6              g_old_val;
  l_new_val1              g_new_val;
  l_new_val2              g_new_val;
  l_new_val3              g_new_val;
  l_new_val4              g_new_val;
  l_new_val5              g_new_val;
  l_new_val6              g_new_val;
  l_tab_counter           binary_integer := 0;
  l_chg_eff_dt            date;
  l_count                 number;
  l_ext_chg_evt_log_id    number;
  l_object_version_number number;
--
  cursor c_lookup_value
    (p_lookup_type hr_lookups.lookup_type%type
    ,p_lookup_code hr_lookups.lookup_code%type
    )
  is
  select meaning
  from hr_lookups hl
  where hl.lookup_type = p_lookup_type
  and hl.lookup_code = p_lookup_code;

--
  l_proc               varchar2(100) := 'ben_ext_chlg.log_per_dis_chg';
--

--
 l_old_categoryname	hr_lookups.meaning%type;
 l_new_categoryname	hr_lookups.meaning%type;
 l_old_reason		hr_lookups.meaning%type;
 l_new_reason		hr_lookups.meaning%type;
 l_old_status		hr_lookups.meaning%type;
 l_new_status		hr_lookups.meaning%type;
 l_old_incident		per_work_incidents.incident_reference%type;
 l_new_incident		per_work_incidents.incident_reference%type;
 l_old_organization	hr_all_organization_units.name%type;
 l_new_organization	hr_all_organization_units.name%type;

--
begin
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
--
  if p_event = 'UPDATE' then

  if nvl(p_old_rec.incident_id,1) <> nvl(p_new_rec.incident_id,1) then

      select incident_reference into l_old_incident
      from per_work_incidents
      where incident_id = p_old_rec.incident_id ;

      select incident_reference into l_new_incident
      from per_work_incidents
      where incident_id = l_new_incident ;

      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CINCID';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := l_old_incident;
      l_new_val1(l_tab_counter) := l_new_incident;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
  end if;

  if nvl(p_old_rec.organization_id,1) <> nvl(p_new_rec.organization_id,1) then

      select name into l_old_organization
      from hr_all_organization_units
      where organization_id = p_old_rec.organization_id ;

      select name into l_new_organization
      from hr_all_organization_units
      where organization_id = p_new_rec.organization_id ;

      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CORGID';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := l_old_organization;
      l_new_val1(l_tab_counter) := l_new_organization;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
  end if;

  if nvl(p_old_rec.registration_id,'$$$$$') <> nvl(p_new_rec.registration_id,'$$$$$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CREGID';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.registration_id;
      l_new_val1(l_tab_counter) := p_new_rec.registration_id;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
  end if;

  if nvl(p_old_rec.registration_date,to_date('01/01/0001', 'dd/mm/yyyy')) <> nvl(p_new_rec.registration_date,to_date('01/01/0001', 'dd/mm/yyyy')) then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CREGDT';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.registration_date;
      l_new_val1(l_tab_counter) := p_new_rec.registration_date;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
  end if;

  if nvl(p_old_rec.registration_exp_date,to_date('01/01/0001', 'dd/mm/yyyy')) <> nvl(p_new_rec.registration_exp_date,to_date('01/01/0001', 'dd/mm/yyyy')) then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CREGEXPDT';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.registration_exp_date;
      l_new_val1(l_tab_counter) := p_new_rec.registration_exp_date;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
  end if;

  if nvl(p_old_rec.categoryname,'$$$$$') <> nvl(p_new_rec.categoryname,'$$$$$') then
       -- read category name from lookup table
      open c_lookup_value('DISABILITY_CATEGORY', p_old_rec.categoryname);
      fetch c_lookup_value into l_old_categoryname;
      close c_lookup_value;
      open c_lookup_value('DISABILITY_CATEGORY', p_new_rec.categoryname);
      fetch c_lookup_value into l_new_categoryname;
      close c_lookup_value;
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CDISCAT';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := l_old_categoryname ;
      l_new_val1(l_tab_counter) := l_new_categoryname;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
  end if;

  if nvl(p_old_rec.description,'$$$$$') <> nvl(p_new_rec.description,'$$$$$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CDESC';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.description;
      l_new_val1(l_tab_counter) := p_new_rec.description;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
  end if;

  if nvl(p_old_rec.degree,1) <> nvl(p_new_rec.degree,1) then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CDEG';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.degree;
      l_new_val1(l_tab_counter) := p_new_rec.degree;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
  end if;

  if nvl(p_old_rec.quota_fte,1) <> nvl(p_new_rec.quota_fte,1) then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CQTA';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.quota_fte;
      l_new_val1(l_tab_counter) := p_new_rec.quota_fte;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
  end if;

  if nvl(p_old_rec.reason,'$$$$$') <> nvl(p_new_rec.reason,'$$$$$') then
       -- read reason from lookup table
      open c_lookup_value('DISABILITY_REASON', p_old_rec.reason);
      fetch c_lookup_value into l_old_reason;
      close c_lookup_value;
      open c_lookup_value('DISABILITY_REASON', p_new_rec.reason);
      fetch c_lookup_value into l_new_reason;
      close c_lookup_value;
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CDISRSN';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := l_old_reason;
      l_new_val1(l_tab_counter) := l_new_reason;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
  end if;

  if nvl(p_old_rec.pre_registration_job,'$$$$$') <> nvl(p_new_rec.pre_registration_job,'$$$$$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CPRREGJOB';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.pre_registration_job;
      l_new_val1(l_tab_counter) := p_new_rec.pre_registration_job;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
  end if;

  if nvl(p_old_rec.work_restriction,'$$$$$') <> nvl(p_new_rec.work_restriction,'$$$$$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CWRKRESTR';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.work_restriction;
      l_new_val1(l_tab_counter) := p_new_rec.work_restriction;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
  end if;


if nvl(p_old_rec.status,'$$$$$') <> nvl(p_new_rec.status,'$$$$$') then
      -- read status from lookup table
      open c_lookup_value('DISABILITY_STATUS', p_old_rec.status);
      fetch c_lookup_value into l_old_status;
      close c_lookup_value;
      open c_lookup_value('DISABILITY_STATUS', p_new_rec.status);
      fetch c_lookup_value into l_new_status;
      close c_lookup_value;
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CODS';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := l_old_status;
      l_new_val1(l_tab_counter) := l_new_status;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
  end if;

  if nvl(p_old_rec.attribute1,'$$$$$') <> nvl(p_new_rec.attribute1,'$$$$$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CATTR1';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.attribute1;
      l_new_val1(l_tab_counter) := p_new_rec.attribute1;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
  end if;

  if nvl(p_old_rec.attribute2,'$$$$$') <> nvl(p_new_rec.attribute2,'$$$$$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CATTR2';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.attribute2;
      l_new_val1(l_tab_counter) := p_new_rec.attribute2;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
  end if;

  if nvl(p_old_rec.attribute3,'$$$$$') <> nvl(p_new_rec.attribute3,'$$$$$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CATTR3';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.attribute3;
      l_new_val1(l_tab_counter) := p_new_rec.attribute3;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
  end if;

  if nvl(p_old_rec.attribute4,'$$$$$') <> nvl(p_new_rec.attribute4,'$$$$$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CATTR4';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.attribute4;
      l_new_val1(l_tab_counter) := p_new_rec.attribute4;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
  end if;

  if nvl(p_old_rec.attribute5,'$$$$$') <> nvl(p_new_rec.attribute5,'$$$$$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CATTR5';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.attribute5;
      l_new_val1(l_tab_counter) := p_new_rec.attribute5;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
  end if;

  if nvl(p_old_rec.attribute6,'$$$$$') <> nvl(p_new_rec.attribute6,'$$$$$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CATTR6';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.attribute6;
      l_new_val1(l_tab_counter) := p_new_rec.attribute6;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
  end if;

  if nvl(p_old_rec.attribute7,'$$$$$') <> nvl(p_new_rec.attribute7,'$$$$$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CATTR7';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.attribute7;
      l_new_val1(l_tab_counter) := p_new_rec.attribute7;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
  end if;

  if nvl(p_old_rec.attribute8,'$$$$$') <> nvl(p_new_rec.attribute8,'$$$$$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CATTR8';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.attribute8;
      l_new_val1(l_tab_counter) := p_new_rec.attribute8;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
  end if;

  if nvl(p_old_rec.attribute9,'$$$$$') <> nvl(p_new_rec.attribute9,'$$$$$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CATTR9';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.attribute9;
      l_new_val1(l_tab_counter) := p_new_rec.attribute9;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
  end if;

  if nvl(p_old_rec.attribute10,'$$$$$') <> nvl(p_new_rec.attribute10,'$$$$$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CATTR10';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.attribute10;
      l_new_val1(l_tab_counter) := p_new_rec.attribute10;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
  end if;

    if nvl(p_old_rec.dis_information1,'$$$$$') <> nvl(p_new_rec.dis_information1,'$$$$$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CDISINF1';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.dis_information1;
      l_new_val1(l_tab_counter) := p_new_rec.dis_information1;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
  end if;

  if nvl(p_old_rec.dis_information2,'$$$$$') <> nvl(p_new_rec.dis_information2,'$$$$$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CDISINF2';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.attribute2;
      l_new_val1(l_tab_counter) := p_new_rec.attribute2;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
  end if;

  if nvl(p_old_rec.dis_information3,'$$$$$') <> nvl(p_new_rec.dis_information3,'$$$$$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CDISINF3';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.dis_information3;
      l_new_val1(l_tab_counter) := p_new_rec.dis_information3;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
  end if;

  if nvl(p_old_rec.dis_information4,'$$$$$') <> nvl(p_new_rec.dis_information4,'$$$$$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CDISINF4';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.dis_information4;
      l_new_val1(l_tab_counter) := p_new_rec.dis_information4;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
  end if;

  if nvl(p_old_rec.dis_information5,'$$$$$') <> nvl(p_new_rec.dis_information5,'$$$$$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CDISINF5';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.dis_information5;
      l_new_val1(l_tab_counter) := p_new_rec.dis_information5;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
  end if;

  if nvl(p_old_rec.dis_information6,'$$$$$') <> nvl(p_new_rec.dis_information6,'$$$$$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CDISINF6';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.dis_information6;
      l_new_val1(l_tab_counter) := p_new_rec.dis_information6;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
  end if;

  if nvl(p_old_rec.dis_information7,'$$$$$') <> nvl(p_new_rec.dis_information7,'$$$$$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CDISINF7';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.dis_information7;
      l_new_val1(l_tab_counter) := p_new_rec.dis_information7;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
  end if;

  if nvl(p_old_rec.dis_information8,'$$$$$') <> nvl(p_new_rec.dis_information8,'$$$$$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CDISINF8';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.dis_information8;
      l_new_val1(l_tab_counter) := p_new_rec.dis_information8;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
  end if;

  if nvl(p_old_rec.dis_information9,'$$$$$') <> nvl(p_new_rec.dis_information9,'$$$$$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CDISINF9';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.dis_information9;
      l_new_val1(l_tab_counter) := p_new_rec.dis_information9;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
  end if;

  if nvl(p_old_rec.dis_information10,'$$$$$') <> nvl(p_new_rec.dis_information10,'$$$$$') then
      l_tab_counter := l_tab_counter + 1;
      l_chg_evt_tab(l_tab_counter) := 'CDISINF10';
      l_prmtr_01_tab(l_tab_counter) := null;
      l_prmtr_02_tab(l_tab_counter) := null;
      l_prmtr_03_tab(l_tab_counter) := null;
      l_prmtr_04_tab(l_tab_counter) := null;
      l_prmtr_05_tab(l_tab_counter) := null;
      l_prmtr_06_tab(l_tab_counter) := null;
      l_prmtr_07_tab(l_tab_counter) := null;
      l_old_val1(l_tab_counter) := p_old_rec.dis_information10;
      l_new_val1(l_tab_counter) := p_new_rec.dis_information10;
      l_old_val2(l_tab_counter) := null;
      l_old_val3(l_tab_counter) := null;
      l_old_val4(l_tab_counter) := null;
      l_old_val5(l_tab_counter) := null;
      l_old_val6(l_tab_counter) := null;
      l_new_val2(l_tab_counter) := null;
      l_new_val3(l_tab_counter) := null;
      l_new_val4(l_tab_counter) := null;
      l_new_val5(l_tab_counter) := null;
      l_new_val6(l_tab_counter) := null;
  end if;

 for l_count in 1..l_chg_evt_tab.count loop
   if change_event_is_enabled(l_chg_evt_tab(l_count),p_new_rec.effective_start_date) then
    ben_ext_chg_evt_api.create_ext_chg_evt
    (p_validate                    => FALSE
    ,p_ext_chg_evt_log_id          => l_ext_chg_evt_log_id
    ,p_chg_evt_cd                  => l_chg_evt_tab(l_count)
    ,p_chg_eff_dt                  => p_new_rec.effective_start_date
    ,p_prmtr_01                    => l_prmtr_01_tab(l_count)
    ,p_prmtr_02                    => l_prmtr_02_tab(l_count)
    ,p_prmtr_03                    => l_prmtr_03_tab(l_count)
    ,p_prmtr_04                    => l_prmtr_04_tab(l_count)
    ,p_prmtr_05                    => l_prmtr_05_tab(l_count)
    ,p_prmtr_06                    => l_prmtr_06_tab(l_count)
    ,p_prmtr_07                    => l_prmtr_07_tab(l_count)
    ,p_prmtr_10                    => p_new_rec.update_mode
    ,p_person_id                   => p_new_rec.person_id
    ,p_business_group_id           => p_new_rec.business_group_id
    ,p_object_version_number       => l_object_version_number
    ,p_effective_date              => p_new_rec.effective_start_date
    ,p_old_val1                    => l_old_val1(l_count)
    ,p_old_val2                    => l_old_val2(l_count)
    ,p_old_val3                    => l_old_val3(l_count)
    ,p_old_val4                    => l_old_val4(l_count)
    ,p_old_val5                    => l_old_val5(l_count)
    ,p_old_val6                    => l_old_val6(l_count)
    ,p_new_val1                    => l_new_val1(l_count)
    ,p_new_val2                    => l_new_val2(l_count)
    ,p_new_val3                    => l_new_val3(l_count)
    ,p_new_val4                    => l_new_val4(l_count)
    ,p_new_val5                    => l_new_val5(l_count)
    ,p_new_val6                    => l_new_val6(l_count)
    );
   end if;
  end loop;
  --

    ----
 end if;
--
  hr_utility.set_location('Exiting:'|| l_proc, 99);
--
end log_per_dis_chg;
--
end ben_ext_chlg;

/
