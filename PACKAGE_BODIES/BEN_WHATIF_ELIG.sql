--------------------------------------------------------
--  DDL for Package Body BEN_WHATIF_ELIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_WHATIF_ELIG" as
/* $Header: benwatif.pkb 120.0 2005/05/28 09:35:40 appldev noship $ */
procedure p_rollback is
begin
  hr_utility.set_location(' Entering: p_rollback' , 10);
  rollback;
  hr_utility.set_location(' Leaving: p_rollback' , 10);
end;

--
-- This procedure returns the update mode appropriate
-- for the given table and effective_date and key.
--
Procedure Get_DT_Upd_Mode
          (p_effective_date        in  date,
           p_base_table_name       in  varchar2,
           p_base_key_column       in  varchar2,
           p_base_key_value        in  number,
           p_mode                  out nocopy varchar2
           ) is
  --
  l_correction             boolean := TRUE;
  l_update                 boolean := FALSE;
  l_update_override        boolean := FALSE;
  l_update_change_insert   boolean := FALSE;
  --
begin
  hr_utility.set_location(' Entering: Get_DT_Upd_Mode' , 10);
  --
  -- Get the appropriate update mode.
  --
  DT_Api.Find_DT_Upd_Modes(p_effective_date => p_effective_date,
                    p_base_table_name       => p_base_table_name,
                    p_base_key_column       => p_base_key_column,
                    p_base_key_value        => p_base_key_value,
                    p_correction            => l_correction,
                    p_update                => l_update,
                    p_update_override       => l_update_override,
                    p_update_change_insert  => l_update_change_insert);
  --
  if l_update_override or l_update_change_insert then
     p_mode := 'UPDATE_OVERRIDE';
  elsif l_update then
     p_mode := 'UPDATE';
  else
     p_mode := 'CORRECTION';
  end if;
  --
  hr_utility.set_location(' Leaving: Get_DT_Upd_Mode' , 10);
end;

procedure WATIF_ABSENCE_ATTENDANCES_API(
   p_person_id                      in  number
  ,p_ABSENCE_ATTENDANCE_TYPE_ID     in  varchar2
  ,p_ABS_ATTENDANCE_REASON_ID       in  varchar2
  ,p_DATE_END                       in  date
  ,p_DATE_START                     in  date
  ,p_business_group_id              in  number
  ,p_effective_date                 in  date
  ) is
  --
  cursor c_abs_att is
   select
       rowid, per_absence_attendances.*
   from per_absence_attendances
   where person_id = p_person_id  and
         absence_attendance_type_id = p_absence_attendance_type_id and
         abs_attendance_reason_id   =
             nvl(p_abs_attendance_reason_id, abs_attendance_reason_id) and
         p_effective_date between nvl(DATE_START, p_effective_date)
                            and     nvl(DATE_END, p_effective_date);
  --
  per_abs_att_rec c_abs_att%rowtype;
  --
  l_rowid varchar2(50);
begin
   hr_utility.set_location(' Entering: WATIF_ABSENCE_ATTENDANCES_API' , 10);
   --
   If p_DATE_START is null and p_DATE_END is null and
      p_ABSENCE_ATTENDANCE_TYPE_ID is null and
      p_ABS_ATTENDANCE_REASON_ID   is null then
       --
       fnd_message.set_name('BEN','BEN_91447_ALL_NULL');
       fnd_message.raise_error;
       --
   End If;
   --
   open c_abs_att;
   fetch c_abs_att into per_abs_att_rec;
   --
   if p_date_start is not null then
      per_abs_att_rec.date_start    := p_date_start;
   end if;
   --
   if p_date_end is not null then
      per_abs_att_rec.date_end      := p_date_end;
   end if;
   --
   if p_ABSENCE_ATTENDANCE_TYPE_ID is not null then
      per_abs_att_rec.ABSENCE_ATTENDANCE_TYPE_ID    := p_ABSENCE_ATTENDANCE_TYPE_ID;
   end if;
   --
   if p_ABS_ATTENDANCE_REASON_ID is not null then
      per_abs_att_rec.ABS_ATTENDANCE_REASON_ID      := p_ABS_ATTENDANCE_REASON_ID;
   end if;
   --
   if  c_abs_att%notfound Then
       Close c_abs_att;
       --
       -- Absence Attendence Record is  Not found so create one.
       --
       PER_ABSENCE_ATTENDANCES_PKG.Insert_Row(
                X_Rowid                       => l_Rowid,
                X_Absence_Attendance_Id       => per_abs_att_rec.Absence_Attendance_Id,
                X_Business_Group_Id           => p_Business_Group_Id,
                X_Absence_Attendance_Type_Id  => per_abs_att_rec.Absence_Attendance_Type_Id,
                X_Abs_Attendance_Reason_Id    => per_abs_att_rec.Abs_Attendance_Reason_Id,
                X_Person_Id                   => p_Person_Id,
                X_Authorising_Person_Id       => per_abs_att_rec.Authorising_Person_Id,
                X_Replacement_Person_Id       => per_abs_att_rec.Replacement_Person_Id,
                X_Period_Of_Incapacity_Id     => per_abs_att_rec.Period_Of_Incapacity_Id,
                X_Absence_Days                => per_abs_att_rec.Absence_Days,
                X_Absence_Hours               => per_abs_att_rec.Absence_Hours,
                X_Comments                    => per_abs_att_rec.Comments,
                X_Date_End                    => per_abs_att_rec.Date_End,
                X_Date_Notification           => per_abs_att_rec.Date_Notification,
                X_Date_Projected_End          => per_abs_att_rec.Date_Projected_End,
                X_Date_Projected_Start        => per_abs_att_rec.Date_Projected_Start,
                X_Date_Start                  => per_abs_att_rec.Date_Start,
                X_Occurrence                  => per_abs_att_rec.Occurrence,
                X_Ssp1_Issued                 => per_abs_att_rec.Ssp1_Issued,
                X_Time_End                    => per_abs_att_rec.Time_End,
                X_Time_Projected_End          => per_abs_att_rec.Time_Projected_End,
                X_Time_Projected_Start        => per_abs_att_rec.Time_Projected_Start,
                X_Time_Start                  => per_abs_att_rec.Time_Start,
                X_Attribute_Category          => per_abs_att_rec.Attribute_Category,
                X_Attribute1                  => per_abs_att_rec.Attribute1,
                X_Attribute2                  => per_abs_att_rec.Attribute2,
                X_Attribute3                  => per_abs_att_rec.Attribute3,
                X_Attribute4                  => per_abs_att_rec.Attribute4,
                X_Attribute5                  => per_abs_att_rec.Attribute5,
                X_Attribute6                  => per_abs_att_rec.Attribute6,
                X_Attribute7                  => per_abs_att_rec.Attribute7,
                X_Attribute8                  => per_abs_att_rec.Attribute8,
                X_Attribute9                  => per_abs_att_rec.Attribute9,
                X_Attribute10                  => per_abs_att_rec.Attribute10,
                X_Attribute11                  => per_abs_att_rec.Attribute11,
                X_Attribute12                  => per_abs_att_rec.Attribute12,
                X_Attribute13                  => per_abs_att_rec.Attribute13,
                X_Attribute14                  => per_abs_att_rec.Attribute14,
                X_Attribute15                  => per_abs_att_rec.Attribute15,
                X_Attribute16                  => per_abs_att_rec.Attribute16,
                X_Attribute17                  => per_abs_att_rec.Attribute17,
                X_Attribute18                  => per_abs_att_rec.Attribute18,
                X_Attribute19                  => per_abs_att_rec.Attribute19,
                X_Attribute20                  => per_abs_att_rec.Attribute20,
                X_Linked_Absence_id            => per_abs_att_rec.Linked_Absence_id,
                X_Sickness_Start_Date          => per_abs_att_rec.Sickness_Start_Date,
                X_Sickness_End_Date            => per_abs_att_rec.Sickness_End_Date,
                X_Accept_Late_Notif_Flag       => per_abs_att_rec.ACCEPT_LATE_NOTIFICATION_FLAG,
                X_Reason_For_Late_Notification => per_abs_att_rec.REASON_FOR_NOTIFICATION_DELAY,
                X_Pregnancy_Related_Illness    => per_abs_att_rec.Pregnancy_Related_Illness,
                X_Maternity_Id                 => per_abs_att_rec.Maternity_Id,
                X_ABS_INFORMATION_CATEGORY     => NULL,
                X_ABS_INFORMATION1             => NULL,
                X_ABS_INFORMATION2             => NULL,
                X_ABS_INFORMATION3             => NULL,
                X_ABS_INFORMATION4             => NULL,
                X_ABS_INFORMATION5             => NULL,
                X_ABS_INFORMATION6             => NULL,
                X_ABS_INFORMATION7             => NULL,
                X_ABS_INFORMATION8             => NULL,
                X_ABS_INFORMATION9             => NULL,
                X_ABS_INFORMATION10            => NULL,
                X_ABS_INFORMATION11            => NULL,
                X_ABS_INFORMATION12            => NULL,
                X_ABS_INFORMATION13            => NULL,
                X_ABS_INFORMATION14            => NULL,
                X_ABS_INFORMATION15            => NULL,
                X_ABS_INFORMATION16            => NULL,
                X_ABS_INFORMATION17            => NULL,
                X_ABS_INFORMATION18            => NULL,
                X_ABS_INFORMATION19            => NULL,
                X_ABS_INFORMATION20            => NULL,
                X_ABS_INFORMATION21            => NULL,
                X_ABS_INFORMATION22            => NULL,
                X_ABS_INFORMATION23            => NULL,
                X_ABS_INFORMATION24            => NULL,
                X_ABS_INFORMATION25            => NULL,
                X_ABS_INFORMATION26            => NULL,
                X_ABS_INFORMATION27            => NULL,
                X_ABS_INFORMATION28            => NULL,
                X_ABS_INFORMATION29            => NULL,
                X_ABS_INFORMATION30            => NULL
        );
       /*
       fnd_message.set_name('BEN','BEN_91440_NO_ABS_ATT');
       fnd_message.raise_error;
       */
    else
       --
       Close c_abs_att;
       --
       --
       -- Call the API -
       -- ???? Do we need to update all the Per Absence Attendences.
       --
       PER_ABSENCE_ATTENDANCES_PKG.Update_Row(
                X_Rowid                       => rowidtochar(per_abs_att_rec.Rowid),
                X_Absence_Attendance_Id       => per_abs_att_rec.Absence_Attendance_Id,
                X_Business_Group_Id           => per_abs_att_rec.Business_Group_Id,
                X_Absence_Attendance_Type_Id  => per_abs_att_rec.Absence_Attendance_Type_Id,
                X_Abs_Attendance_Reason_Id    => per_abs_att_rec.Abs_Attendance_Reason_Id,
                X_Person_Id                   => per_abs_att_rec.Person_Id,
                X_Authorising_Person_Id       => per_abs_att_rec.Authorising_Person_Id,
                X_Replacement_Person_Id       => per_abs_att_rec.Replacement_Person_Id,
                X_Period_Of_Incapacity_Id     => per_abs_att_rec.Period_Of_Incapacity_Id,
                X_Absence_Days                => per_abs_att_rec.Absence_Days,
                X_Absence_Hours               => per_abs_att_rec.Absence_Hours,
                X_Comments                    => per_abs_att_rec.Comments,
                X_Date_End                    => per_abs_att_rec.Date_End,
                X_Date_Notification           => per_abs_att_rec.Date_Notification,
                X_Date_Projected_End          => per_abs_att_rec.Date_Projected_End,
                X_Date_Projected_Start        => per_abs_att_rec.Date_Projected_Start,
                X_Date_Start                  => per_abs_att_rec.Date_Start,
                X_Occurrence                  => per_abs_att_rec.Occurrence,
                X_Ssp1_Issued                 => per_abs_att_rec.Ssp1_Issued,
                X_Time_End                    => per_abs_att_rec.Time_End,
                X_Time_Projected_End          => per_abs_att_rec.Time_Projected_End,
                X_Time_Projected_Start        => per_abs_att_rec.Time_Projected_Start,
                X_Time_Start                  => per_abs_att_rec.Time_Start,
                X_Attribute_Category          => per_abs_att_rec.Attribute_Category,
                X_Attribute1                  => per_abs_att_rec.Attribute1,
                X_Attribute2                  => per_abs_att_rec.Attribute2,
                X_Attribute3                  => per_abs_att_rec.Attribute3,
                X_Attribute4                  => per_abs_att_rec.Attribute4,
                X_Attribute5                  => per_abs_att_rec.Attribute5,
                X_Attribute6                  => per_abs_att_rec.Attribute6,
                X_Attribute7                  => per_abs_att_rec.Attribute7,
                X_Attribute8                  => per_abs_att_rec.Attribute8,
                X_Attribute9                  => per_abs_att_rec.Attribute9,
                X_Attribute10                  => per_abs_att_rec.Attribute10,
                X_Attribute11                  => per_abs_att_rec.Attribute11,
                X_Attribute12                  => per_abs_att_rec.Attribute12,
                X_Attribute13                  => per_abs_att_rec.Attribute13,
                X_Attribute14                  => per_abs_att_rec.Attribute14,
                X_Attribute15                  => per_abs_att_rec.Attribute15,
                X_Attribute16                  => per_abs_att_rec.Attribute16,
                X_Attribute17                  => per_abs_att_rec.Attribute17,
                X_Attribute18                  => per_abs_att_rec.Attribute18,
                X_Attribute19                  => per_abs_att_rec.Attribute19,
                X_Attribute20                  => per_abs_att_rec.Attribute20,
                X_Linked_Absence_id            => per_abs_att_rec.Linked_Absence_id,
                X_Sickness_Start_Date          => per_abs_att_rec.Sickness_Start_Date,
                X_Sickness_End_Date            => per_abs_att_rec.Sickness_End_Date,
                X_Accept_Late_Notif_Flag       => per_abs_att_rec.ACCEPT_LATE_NOTIFICATION_FLAG,
                X_Reason_For_Late_Notification => per_abs_att_rec.REASON_FOR_NOTIFICATION_DELAY,
                X_Pregnancy_Related_Illness    => per_abs_att_rec.Pregnancy_Related_Illness,
                X_Maternity_Id                 => per_abs_att_rec.Maternity_Id,
                X_ABS_INFORMATION_CATEGORY     => NULL,
                X_ABS_INFORMATION1             => NULL,
                X_ABS_INFORMATION2             => NULL,
                X_ABS_INFORMATION3             => NULL,
                X_ABS_INFORMATION4             => NULL,
                X_ABS_INFORMATION5             => NULL,
                X_ABS_INFORMATION6             => NULL,
                X_ABS_INFORMATION7             => NULL,
                X_ABS_INFORMATION8             => NULL,
                X_ABS_INFORMATION9             => NULL,
                X_ABS_INFORMATION10            => NULL,
                X_ABS_INFORMATION11            => NULL,
                X_ABS_INFORMATION12            => NULL,
                X_ABS_INFORMATION13            => NULL,
                X_ABS_INFORMATION14            => NULL,
                X_ABS_INFORMATION15            => NULL,
                X_ABS_INFORMATION16            => NULL,
                X_ABS_INFORMATION17            => NULL,
                X_ABS_INFORMATION18            => NULL,
                X_ABS_INFORMATION19            => NULL,
                X_ABS_INFORMATION20            => NULL,
                X_ABS_INFORMATION21            => NULL,
                X_ABS_INFORMATION22            => NULL,
                X_ABS_INFORMATION23            => NULL,
                X_ABS_INFORMATION24            => NULL,
                X_ABS_INFORMATION25            => NULL,
                X_ABS_INFORMATION26            => NULL,
                X_ABS_INFORMATION27            => NULL,
                X_ABS_INFORMATION28            => NULL,
                X_ABS_INFORMATION29            => NULL,
                X_ABS_INFORMATION30            => NULL
      );
   End If;
   --
   hr_utility.set_location(' Leaving: WATIF_ABSENCE_ATTENDANCES_API' , 10);
   --
end;



procedure WATIF_CONTACT_RELATIONSHIP_API(
   p_person_id                      in  number
  ,p_contact_person_id              in  number
  ,p_DATE_START                     in  date
  ,p_DATE_END                       in  date
  ,p_CONTACT_TYPE                   in  VARCHAR2
  ,p_PERSONAL_FLAG                  in  VARCHAR2
  ,p_START_LIFE_REASON_ID           in  NUMBER
  ,p_END_LIFE_REASON_ID             in  NUMBER
  ,p_RLTD_PER_RSDS_W_DSGNTR_FLAG    in  VARCHAR2
  ,p_business_group_id              in  number
  ,p_effective_date                 in  date
  ) is
  --
  cursor c_ctr is
   select
        rowid, per_contact_relationships.*
   from per_contact_relationships
   where person_id = p_person_id  and
         contact_person_id = p_contact_person_id and
         p_effective_date between nvl(DATE_START, p_effective_date)
                          and     nvl(DATE_END, p_effective_date);
   --
   cursor c_per_typ is
    select person_type_id
    from per_person_types
    where business_group_id = p_business_group_id
      and  system_PERSON_TYPE = 'OTHER';
   --
   l_person_type_id number;
   --
   per_ctr_rec c_ctr%rowtype;
   --
   l_contact_relationship_id      number;
   l_ctr_object_version_number    number;
   l_per_person_id                number;
   l_per_object_version_number    number;
   l_object_version_number        number;
   l_per_effective_start_date     date;
   l_per_effective_end_date       date;
   l_full_name                    per_all_people_f.full_name%type; --UTF8 Change Bug 2254683
   l_per_comment_id               number;
   l_name_combination_warning     boolean;
   l_orig_hire_warning            boolean;
   --
   l_personal_flag varchar2(1);
begin
   --
   hr_utility.set_location(' Entering: WATIF_CONTACT_RELATIONSHIP_API' , 10);
   --
   If p_DATE_START is null and p_DATE_END is null and
      p_CONTACT_TYPE is null and p_PERSONAL_FLAG is null and
      p_PERSONAL_FLAG is null and p_START_LIFE_REASON_ID is null and
      p_END_LIFE_REASON_ID is null and p_RLTD_PER_RSDS_W_DSGNTR_FLAG is null
   then
       --
       fnd_message.set_name('BEN','BEN_91447_ALL_NULL');
       fnd_message.raise_error;
       --
   End If;
   --
   if p_contact_person_id is not null then
     --
     open c_ctr;
     fetch c_ctr into per_ctr_rec;
     if  c_ctr%notfound Then
       Close c_ctr;
       --
       -- Contact Relationship Record is  Not found so error.
       --
       fnd_message.set_name('BEN','BEN_91441_NO_CTR');
       fnd_message.raise_error;
       --
     End If;
     Close c_ctr;
     --
     if p_date_start is not null then
        per_ctr_rec.date_start    := p_date_start;
     end if;
     --
     if p_date_end is not null then
        per_ctr_rec.date_end      := p_date_end;
     end if;

     if p_CONTACT_TYPE is not null then
        per_ctr_rec.CONTACT_TYPE     := p_CONTACT_TYPE;
     end if;

     if p_PERSONAL_FLAG is not null then
        per_ctr_rec.PERSONAL_FLAG     := p_PERSONAL_FLAG;
     end if;

     if p_START_LIFE_REASON_ID is not null then
        per_ctr_rec.START_LIFE_REASON_ID     := p_START_LIFE_REASON_ID;
     end if;

     if p_END_LIFE_REASON_ID is not null then
        per_ctr_rec.END_LIFE_REASON_ID     := p_END_LIFE_REASON_ID;
     end if;
     --
     -- Call update routine to update the contact relationship
     --
     --
     -- Call the API - hr_contact_rel_api.update_contact_relationships.
     --
     /* update per_contact_relationships
     set date_start = per_ctr_rec.date_start,
         date_end   = per_ctr_rec.date_end,
         CONTACT_TYPE = per_ctr_rec.CONTACT_TYPE,
         PERSONAL_FLAG = per_ctr_rec.PERSONAL_FLAG,
         START_LIFE_REASON_ID = per_ctr_rec.START_LIFE_REASON_ID,
         END_LIFE_REASON_ID = per_ctr_rec.END_LIFE_REASON_ID
     where CONTACT_RELATIONSHIP_ID = per_ctr_rec.CONTACT_RELATIONSHIP_ID; */
     --
    hr_contact_rel_api.update_contact_relationship
    (p_validate                          => false
    ,p_effective_date                    => p_effective_date
    ,p_contact_relationship_id           => per_ctr_rec.contact_relationship_id
    ,p_contact_type                      => per_ctr_rec.contact_type
    ,p_comments                          => per_ctr_rec.comments
    ,p_personal_flag                     => nvl(per_ctr_rec.personal_flag,'N')
    ,p_dependent_flag                    => nvl(per_ctr_rec.dependent_flag,'N')
    ,p_primary_contact_flag              => nvl(per_ctr_rec.primary_contact_flag,'N')
    ,p_third_party_pay_flag              => nvl(per_ctr_rec.third_party_pay_flag,'N')
    ,p_beneficiary_flag                  => nvl(per_ctr_rec.beneficiary_flag,'N')
    ,p_bondholder_flag                   => nvl(per_ctr_rec.bondholder_flag,'N')
    ,p_cont_attribute_category           => per_ctr_rec.cont_attribute_category
    ,p_cont_attribute1                   => per_ctr_rec.cont_attribute1
    ,p_cont_attribute2                   => per_ctr_rec.cont_attribute2
    ,p_cont_attribute3                   => per_ctr_rec.cont_attribute3
    ,p_cont_attribute4                   => per_ctr_rec.cont_attribute4
    ,p_cont_attribute5                   => per_ctr_rec.cont_attribute5
    ,p_cont_attribute6                   => per_ctr_rec.cont_attribute6
    ,p_cont_attribute7                   => per_ctr_rec.cont_attribute7
    ,p_cont_attribute8                   => per_ctr_rec.cont_attribute8
    ,p_cont_attribute9                   => per_ctr_rec.cont_attribute9
    ,p_cont_attribute10                  => per_ctr_rec.cont_attribute10
    ,p_cont_attribute11                  => per_ctr_rec.cont_attribute11
    ,p_cont_attribute12                  => per_ctr_rec.cont_attribute12
    ,p_cont_attribute13                  => per_ctr_rec.cont_attribute13
    ,p_cont_attribute14                  => per_ctr_rec.cont_attribute14
    ,p_cont_attribute15                  => per_ctr_rec.cont_attribute15
    ,p_cont_attribute16                  => per_ctr_rec.cont_attribute16
    ,p_cont_attribute17                  => per_ctr_rec.cont_attribute17
    ,p_cont_attribute18                  => per_ctr_rec.cont_attribute18
    ,p_cont_attribute19                  => per_ctr_rec.cont_attribute19
    ,p_cont_attribute20                  => per_ctr_rec.cont_attribute20
    ,p_object_version_number             => l_object_version_number
    );

    /* PER_CONTACT_RELATIONSHIPS_PKG.Update_Row(
                  X_Rowid  			=> rowidtochar(per_ctr_rec.Rowid),
                  X_Contact_Relationship_Id  	=> per_ctr_rec.Contact_Relationship_Id,
                  X_Business_Group_Id  		=> per_ctr_rec.Business_Group_Id,
                  X_Person_Id  			=> per_ctr_rec.Person_Id,
                  X_Contact_Person_Id  		=> per_ctr_rec.Contact_Person_Id,
                  X_Contact_Type  		=> per_ctr_rec.Contact_Type,
                  X_Comments  			=> per_ctr_rec.Comments,
                  X_Bondholder_Flag  		=> per_ctr_rec.Bondholder_Flag,
                  X_Third_Party_Pay_Flag  	=> per_ctr_rec.Third_Party_Pay_Flag,
                  X_Primary_Contact_Flag  	=> per_ctr_rec.Primary_Contact_Flag,
                  X_Cont_Attribute_Category  	=> per_ctr_rec.Cont_Attribute_Category,
                  X_Cont_Attribute1  		=> per_ctr_rec.Cont_Attribute1,
                  X_Cont_Attribute2  		=> per_ctr_rec.Cont_Attribute2,
                  X_Cont_Attribute3  		=> per_ctr_rec.Cont_Attribute3,
                  X_Cont_Attribute4  		=> per_ctr_rec.Cont_Attribute4,
                  X_Cont_Attribute5  		=> per_ctr_rec.Cont_Attribute5,
                  X_Cont_Attribute6  		=> per_ctr_rec.Cont_Attribute6,
                  X_Cont_Attribute7  		=> per_ctr_rec.Cont_Attribute7,
                  X_Cont_Attribute8  		=> per_ctr_rec.Cont_Attribute8,
                  X_Cont_Attribute9  		=> per_ctr_rec.Cont_Attribute9,
                  X_Cont_Attribute10  		=> per_ctr_rec.Cont_Attribute10,
                  X_Cont_Attribute11  		=> per_ctr_rec.Cont_Attribute11,
                  X_Cont_Attribute12  		=> per_ctr_rec.Cont_Attribute12,
                  X_Cont_Attribute13  		=> per_ctr_rec.Cont_Attribute13,
                  X_Cont_Attribute14  		=> per_ctr_rec.Cont_Attribute14,
                  X_Cont_Attribute15  		=> per_ctr_rec.Cont_Attribute15,
                  X_Cont_Attribute16  		=> per_ctr_rec.Cont_Attribute16,
                  X_Cont_Attribute17  		=> per_ctr_rec.Cont_Attribute17,
                  X_Cont_Attribute18  		=> per_ctr_rec.Cont_Attribute18,
                  X_Cont_Attribute19  		=> per_ctr_rec.Cont_Attribute19,
                  X_Cont_Attribute20  		=> per_ctr_rec.Cont_Attribute20,
                  X_Session_Date  		=> p_effective_date,  -- per_ctr_rec.Session_Date,
                  X_Person_Type_Id  		=> per_ctr_rec.Person_Type_Id,
                  X_Last_Name  			=> per_ctr_rec.Last_Name,
                  X_Comment_Id  			=> per_ctr_rec.Comment_Id,
                  X_Date_Of_Birth  		=> per_ctr_rec.Date_Of_Birth,
                  X_First_Name  			=> per_ctr_rec.First_Name,
                  X_Middle_Names  		=> per_ctr_rec.Middle_Names,
                  X_Sex  				=> per_ctr_rec.Sex,
                  X_Title  			=> per_ctr_rec.Title,
                  X_PRE_NAME_ADJUNCT  		=> per_ctr_rec.PRE_NAME_ADJUNCT,
                  X_SUFFIX  			=> per_ctr_rec.SUFFIX,
                  X_Title_Desc  			=> per_ctr_rec.Title_Desc,
                  X_National_identifier  		=> per_ctr_rec.National_identifier,
                  X_Attribute_Category  		=> per_ctr_rec.Attribute_Category,
                  X_Attribute1  			=> per_ctr_rec.Attribute1,
                  X_Attribute2  			=> per_ctr_rec.Attribute2,
                  X_Attribute3  			=> per_ctr_rec.Attribute3,
                  X_Attribute4  			=> per_ctr_rec.Attribute4,
                  X_Attribute5  			=> per_ctr_rec.Attribute5,
                  X_Attribute6  			=> per_ctr_rec.Attribute6,
                  X_Attribute7  			=> per_ctr_rec.Attribute7,
                  X_Attribute8  			=> per_ctr_rec.Attribute8,
                  X_Attribute9  			=> per_ctr_rec.Attribute9,
                  X_Attribute10  			=> per_ctr_rec.Attribute10,
                  X_Attribute11  			=> per_ctr_rec.Attribute11,
                  X_Attribute12  			=> per_ctr_rec.Attribute12,
                  X_Attribute13  			=> per_ctr_rec.Attribute13,
                  X_Attribute14  			=> per_ctr_rec.Attribute14,
                  X_Attribute15  			=> per_ctr_rec.Attribute15,
                  X_Attribute16  			=> per_ctr_rec.Attribute16,
                  X_Attribute17  			=> per_ctr_rec.Attribute17,
                  X_Attribute18  			=> per_ctr_rec.Attribute18,
                  X_Attribute19  			=> per_ctr_rec.Attribute19,
                  X_Attribute20  			=> per_ctr_rec.Attribute20,
                  X_Attribute21  			=> per_ctr_rec.Attribute21,
                  X_Attribute22  			=> per_ctr_rec.Attribute22,
                  X_Attribute23  			=> per_ctr_rec.Attribute23,
                  X_Attribute24  			=> per_ctr_rec.Attribute24,
                  X_Attribute25  			=> per_ctr_rec.Attribute25,
                  X_Attribute26  			=> per_ctr_rec.Attribute26,
                  X_Attribute27  			=> per_ctr_rec.Attribute27,
                  X_Attribute28  			=> per_ctr_rec.Attribute28,
                  X_Attribute29  			=> per_ctr_rec.Attribute29,
                  X_Attribute30  			=> per_ctr_rec.Attribute30,
                  X_Contact_Only  		=> per_ctr_rec.Contact_Only,
                  X_Reentry_Flag  		=> per_ctr_rec.Reentry_Flag,
                  X_Per_Information1  		=> per_ctr_rec.Per_Information1,
                  X_Per_Information2  		=> per_ctr_rec.Per_Information2,
                  X_Per_Information3  		=> per_ctr_rec.Per_Information3,
                  X_Per_Information4  		=> per_ctr_rec.Per_Information4,
                  X_Per_Information5  		=> per_ctr_rec.Per_Information5,
                  X_Per_Information6  		=> per_ctr_rec.Per_Information6,
                  X_Per_Information7  		=> per_ctr_rec.Per_Information7,
                  X_Per_Information8  		=> per_ctr_rec.Per_Information8,
                  X_Per_Information9  		=> per_ctr_rec.Per_Information9,
                  X_Per_Information10  		=> per_ctr_rec.Per_Information10,
                  X_Per_Information11  		=> per_ctr_rec.Per_Information11,
                  X_Per_Information12  		=> per_ctr_rec.Per_Information12,
                  X_Per_Information13  		=> per_ctr_rec.Per_Information13,
                  X_Per_Information14  		=> per_ctr_rec.Per_Information14,
                  X_Per_Information15  		=> per_ctr_rec.Per_Information15,
                  X_Per_Information16  		=> per_ctr_rec.Per_Information16,
                  X_Per_Information17  		=> per_ctr_rec.Per_Information17,
                  X_Per_Information18  		=> per_ctr_rec.Per_Information18,
                  X_Per_Information19  		=> per_ctr_rec.Per_Information19,
                  X_Per_Information20  		=> per_ctr_rec.Per_Information20,
                  X_Per_Information21  		=> per_ctr_rec.Per_Information21,
                  X_Per_Information22  		=> per_ctr_rec.Per_Information22,
                  X_Per_Information23  		=> per_ctr_rec.Per_Information23,
                  X_Per_Information24  		=> per_ctr_rec.Per_Information24,
                  X_Per_Information25  		=> per_ctr_rec.Per_Information25,
                  X_Per_Information26  		=> per_ctr_rec.Per_Information26,
                  X_Per_Information27  		=> per_ctr_rec.Per_Information27,
                  X_Per_Information28  		=> per_ctr_rec.Per_Information28,
                  X_Per_Information29  		=> per_ctr_rec.Per_Information29,
                  X_Per_Information30  		=> per_ctr_rec.Per_Information30,
                  X_Known_As  			=> per_ctr_rec.Known_As,
                  X_Date_Start  			=> per_ctr_rec.Date_Start,
                  X_Start_Life_Reason_Id  	=> per_ctr_rec.Start_Life_Reason_Id,
                  X_Date_End  			=> per_ctr_rec.Date_End,
                  X_End_Life_Reason_Id  		=> per_ctr_rec.End_Life_Reason_Id,
                  X_Rltd_Per_Rsds_W_Dsgntr_Flag  	=> per_ctr_rec.Rltd_Per_Rsds_W_Dsgntr_Flag
     ); */
   else
     --
     -- Create a contact and contact relationship record.
     --
     open c_per_typ;
      fetch c_per_typ into l_person_type_id;
     close c_per_typ;

    if p_contact_type in ('P','C','S') then
       l_personal_flag := 'Y' ;
    else
       l_personal_flag := nvl(p_personal_flag , 'N' );
    end if;

     hr_contact_rel_api.create_contact
        (
         p_validate                     => false
        ,p_start_date                   => p_date_start
        ,p_business_group_id            => p_business_group_id
        ,p_person_id                    => p_person_id
        ,p_contact_person_id            => null
        ,p_contact_type                 => p_contact_type
        ,p_ctr_comments                 => null
        ,p_primary_contact_flag         => 'N' -- null
        ,p_date_start                   => p_date_start
        ,p_start_life_reason_id         => p_start_life_reason_id
        ,p_date_end                     => p_date_end
        ,p_end_life_reason_id           => p_end_life_reason_id
        ,p_rltd_per_rsds_w_dsgntr_flag  => nvl(p_RLTD_PER_RSDS_W_DSGNTR_FLAG,'N')
        ,p_personal_flag                =>  l_personal_flag
        ,p_sequence_number              => null
        ,p_cont_attribute_category      => null
        ,p_cont_attribute1              => null
        ,p_cont_attribute2              => null
        ,p_cont_attribute3              => null
        ,p_cont_attribute4              => null
        ,p_cont_attribute5              => null
        ,p_cont_attribute6              => null
        ,p_cont_attribute7              => null
        ,p_cont_attribute8              => null
        ,p_cont_attribute9              => null
        ,p_cont_attribute10             => null
        ,p_cont_attribute11             => null
        ,p_cont_attribute12             => null
        ,p_cont_attribute13             => null
        ,p_cont_attribute14             => null
        ,p_cont_attribute15             => null
        ,p_cont_attribute16             => null
        ,p_cont_attribute17             => null
        ,p_cont_attribute18             => null
        ,p_cont_attribute19             => null
        ,p_cont_attribute20             => null
        ,p_third_party_pay_flag         => 'N'
        ,p_bondholder_flag              => 'N'
        ,p_dependent_flag               => 'Y'
        ,p_beneficiary_flag             => 'N'
        ,p_last_name                    => 'Last 1234'
        ,p_sex                          => null
        ,p_person_type_id               => l_person_type_id
        ,p_per_comments                 => null
        ,p_date_of_birth                => null
        ,p_email_address                => null
        ,p_first_name                   => 'First 1234'
        ,p_known_as                     => null
        ,p_marital_status               => null
        ,p_middle_names                 => null
        ,p_nationality                  => null
        ,p_national_identifier          => null
        ,p_previous_last_name           => null
        ,p_registered_disabled_flag     => null
        ,p_title                        => null
        ,p_work_telephone               => null
        ,p_attribute_category           => null
        ,p_attribute1                   => null
        ,p_attribute2                   => null
        ,p_attribute3                   => null
        ,p_attribute4                   => null
        ,p_attribute5                   => null
        ,p_attribute6                   => null
        ,p_attribute7                   => null
        ,p_attribute8                   => null
        ,p_attribute9                   => null
        ,p_attribute10                  => null
        ,p_attribute11                  => null
        ,p_attribute12                  => null
        ,p_attribute13                  => null
        ,p_attribute14                  => null
        ,p_attribute15                  => null
        ,p_attribute16                  => null
        ,p_attribute17                  => null
        ,p_attribute18                  => null
        ,p_attribute19                  => null
        ,p_attribute20                  => null
        ,p_attribute21                  => null
        ,p_attribute22                  => null
        ,p_attribute23                  => null
        ,p_attribute24                  => null
        ,p_attribute25                  => null
        ,p_attribute26                  => null
        ,p_attribute27                  => null
        ,p_attribute28                  => null
        ,p_attribute29                  => null
        ,p_attribute30                  => null
        ,p_per_information_category     => null
        ,p_per_information1             => null
        ,p_per_information2             => null
        ,p_per_information3             => null
        ,p_per_information4             => null
        ,p_per_information5             => null
        ,p_per_information6             => null
        ,p_per_information7             => null
        ,p_per_information8             => null
        ,p_per_information9             => null
        ,p_per_information10            => null
        ,p_per_information11            => null
        ,p_per_information12            => null
        ,p_per_information13            => null
        ,p_per_information14            => null
        ,p_per_information15            => null
        ,p_per_information16            => null
        ,p_per_information17            => null
        ,p_per_information18            => null
        ,p_per_information19            => null
        ,p_per_information20            => null
        ,p_per_information21            => null
        ,p_per_information22            => null
        ,p_per_information23            => null
        ,p_per_information24            => null
        ,p_per_information25            => null
        ,p_per_information26            => null
        ,p_per_information27            => null
        ,p_per_information28            => null
        ,p_per_information29            => null
        ,p_per_information30            => null
        ,p_correspondence_language      => null
        ,p_honors                       => null
        ,p_pre_name_adjunct             => null
        ,p_suffix                       => null
        ,p_create_mirror_flag           => null
        ,p_mirror_type                  => null
        ,p_contact_relationship_id      => l_contact_relationship_id
        ,p_ctr_object_version_number    => l_ctr_object_version_number
        ,p_per_person_id                => l_per_person_id
        ,p_per_object_version_number    => l_per_object_version_number
        ,p_per_effective_start_date     => l_per_effective_start_date
        ,p_per_effective_end_date       => l_per_effective_end_date
        ,p_full_name                    => l_full_name
        ,p_per_comment_id               => l_per_comment_id
        ,p_name_combination_warning     => l_name_combination_warning
        ,p_orig_hire_warning            => l_orig_hire_warning
        );
   end if;
   --
   hr_utility.set_location(' Leaving: WATIF_CONTACT_RELATIONSHIP_API' , 10);
   --
end;

procedure WATIF_ADDRESSES_API(
   p_person_id                      in  number
  ,p_POSTAL_CODE                    in  varchar2
  ,p_PRIMARY_FLAG                   in  varchar2
  ,p_REGION_2                       in  varchar2
  ,p_ADDRESS_TYPE                   in  varchar2
  ,p_DATE_FROM                      in  date
  ,p_DATE_TO                        in  date
  ,p_effective_date                 in  date
  ) is
  --

  --
  cursor c_addr is
   select * from per_addresses_v
    where   person_id = p_person_id  and
            p_effective_date between nvl(DATE_FROM, p_effective_date)
                             and     nvl(DATE_TO, p_effective_date) and
            PRIMARY_FLAG = 'Y';
   --
   --
   cursor csr_valid_city_state is
          select st.state_abbrev, ct.city_name, county.county_name
          from pay_us_states st,
            pay_us_counties county,
            pay_us_city_names ct,
            pay_us_zip_codes zip
          where
            zip.state_code = st.state_code and
            county.state_code = zip.state_code and
            county.county_code = zip.county_code and
            ct.state_code = zip.state_code and
            ct.county_code = zip.county_code and
            ct.city_code  = zip.city_code and
            p_postal_code between zip.zip_start and zip.zip_end and
            ct.primary_flag = 'Y';
   --
   --
   per_addr_rec c_addr%rowtype;

   l_geocodes_installed VARCHAR2(1) := 'N';
   city_state_rec csr_valid_city_state%rowtype;

   l_primary_flag VARCHAR2(1); --Bug 2856143

   --
begin
   --
   hr_utility.set_location(' Entering: WATIF_ADDRESSES_API' , 10);
   -- If postal code is null ????
   If p_postal_code is null and p_PRIMARY_FLAG is null and
      p_DATE_FROM   is null and p_DATE_TO      is null and
      p_REGION_2    is null and p_ADDRESS_TYPE is null
   then
       --
       fnd_message.set_name('BEN','BEN_91447_ALL_NULL');
       fnd_message.raise_error;
       --
   End If;
   --
   open c_addr;
   fetch c_addr into per_addr_rec;
   if  c_addr%notfound Then
       Close c_addr;
       --
       -- Address Not found so error.
       --
       fnd_message.set_name('BEN','BEN_91442_NO_ADDRESS');
       fnd_message.raise_error;
       --
   End If;
   Close c_addr;

      if p_primary_flag is not null then
         per_addr_rec.primary_flag := p_primary_flag;
      end if;
      --
      if p_REGION_2 is not null then
         per_addr_rec.REGION_2 := p_REGION_2;
      end if;
      --
      if p_ADDRESS_TYPE is not null then
         per_addr_rec.ADDRESS_TYPE := p_ADDRESS_TYPE;
      end if;
      --
      if p_date_from is not null then
         per_addr_rec.date_from    := p_date_from;
      end if;
      --
      if p_date_to is not null then
         per_addr_rec.date_to      := p_date_to;
      end if;

      -- Bug 3257985
	if p_date_from is null and p_date_to is null then
	  per_addr_rec.date_from    := greatest(per_addr_rec.date_from,p_effective_date);
	end if;
      -- Bug 3257985
    --
    -- Check if North American Geocides installed.
    --
    l_geocodes_installed := hr_general.chk_geocodes_installed;
    --
    --
    --  If US address style and GEOCODES is installed,
    --  validate for right combination of
    --  city, state and county.
    --


    if  (per_addr_rec.style in ( 'US','CA')
    and l_geocodes_installed = 'Y')
     then
      --
      if ( p_postal_code is not null and
         p_postal_code <> per_addr_rec.postal_code )
      then
         --
         -- Select the City, State for the postal code.
         --
         open csr_valid_city_state;
         fetch csr_valid_city_state into city_state_rec;
         if  csr_valid_city_state%notfound Then
             Close csr_valid_city_state;
             --
             -- City State Not Found.
             --
             fnd_message.set_name('BEN', 'BEN_91448_NO_CT_ST_CNTY');
             fnd_message.raise_error;
         End If;
         Close csr_valid_city_state;
         --
         -- Assign the fetched values to the Record fields.
         --
         per_addr_rec.postal_code  := p_postal_code;
         per_addr_rec.REGION_2     := nvl(p_REGION_2,city_state_rec.STATE_ABBREV);
         per_addr_rec.TOWN_OR_CITY := city_state_rec.city_name;
         per_addr_rec.region_1     := city_state_rec.county_name;
         --
      end if;
      --
      --
      --

      --Bug 2856143 New api being used

      		per_addresses_pkg.update_row
		(p_row_id 	   	=> per_addr_rec.ROW_ID
		,p_address_id      	=> per_addr_rec.ADDRESS_ID
		,p_business_group_id   	=> per_addr_rec.BUSINESS_GROUP_ID
		,p_person_id       	=> p_person_id
		,p_date_from       	=> per_addr_rec.DATE_FROM
		,p_primary_flag    	=> per_addr_rec.PRIMARY_FLAG
		,p_style           	=> per_addr_rec.STYLE
		,p_address_line1   	=> per_addr_rec.ADDRESS_LINE1
		,p_address_line2   	=> per_addr_rec.ADDRESS_LINE2
		,p_address_line3   	=> per_addr_rec.ADDRESS_LINE3
		,p_address_type    	=> per_addr_rec.ADDRESS_TYPE
		,p_comments        	=> per_addr_rec.COMMENTS
		,p_country         	=> per_addr_rec.COUNTRY
		,p_date_to         	=> per_addr_rec.DATE_TO
		,p_postal_code     	=> per_addr_rec.POSTAL_CODE
		,p_region_1        	=> per_addr_rec.REGION_1
		,p_region_2        	=> per_addr_rec.REGION_2
		,p_region_3        	=> per_addr_rec.REGION_3
		,p_telephone_number_1  	=> per_addr_rec.TELEPHONE_NUMBER_1
		,p_telephone_number_2  	=> per_addr_rec.TELEPHONE_NUMBER_2
		,p_telephone_number_3  	=> per_addr_rec.TELEPHONE_NUMBER_3
		,p_town_or_city    	=> per_addr_rec.TOWN_OR_CITY
		,p_request_id      	=> per_addr_rec.REQUEST_ID
		,p_program_application_id => per_addr_rec.PROGRAM_APPLICATION_ID
		,p_program_id      	=> per_addr_rec.PROGRAM_ID
		,p_program_update_date 	=> per_addr_rec.PROGRAM_UPDATE_DATE
		,p_addr_attribute_category=> per_addr_rec.ADDR_ATTRIBUTE_CATEGORY
		,p_addr_attribute1 	=> per_addr_rec.ADDR_ATTRIBUTE1
		,p_addr_attribute2 	=> per_addr_rec.ADDR_ATTRIBUTE2
		,p_addr_attribute3 	=> per_addr_rec.ADDR_ATTRIBUTE3
		,p_addr_attribute4 	=> per_addr_rec.ADDR_ATTRIBUTE4
		,p_addr_attribute5 	=> per_addr_rec.ADDR_ATTRIBUTE5
		,p_addr_attribute6 	=> per_addr_rec.ADDR_ATTRIBUTE6
		,p_addr_attribute7 	=> per_addr_rec.ADDR_ATTRIBUTE7
		,p_addr_attribute8 	=> per_addr_rec.ADDR_ATTRIBUTE8
		,p_addr_attribute9 	=> per_addr_rec.ADDR_ATTRIBUTE9
		,p_addr_attribute10	=> per_addr_rec.ADDR_ATTRIBUTE10
		,p_addr_attribute11	=> per_addr_rec.ADDR_ATTRIBUTE11
		,p_addr_attribute12	=> per_addr_rec.ADDR_ATTRIBUTE12
		,p_addr_attribute13	=> per_addr_rec.ADDR_ATTRIBUTE13
		,p_addr_attribute14	=> per_addr_rec.ADDR_ATTRIBUTE14
		,p_addr_attribute15	=> per_addr_rec.ADDR_ATTRIBUTE15
		,p_addr_attribute16	=> per_addr_rec.ADDR_ATTRIBUTE16
		,p_addr_attribute17	=> per_addr_rec.ADDR_ATTRIBUTE17
		,p_addr_attribute18	=> per_addr_rec.ADDR_ATTRIBUTE18
		,p_addr_attribute19	=> per_addr_rec.ADDR_ATTRIBUTE19
		,p_addr_attribute20	=> per_addr_rec.ADDR_ATTRIBUTE20
		,p_add_information17 	=> per_addr_rec.ADD_INFORMATION17
		,p_add_information18 	=> per_addr_rec.ADD_INFORMATION18
		,p_add_information19 	=> per_addr_rec.ADD_INFORMATION19
		,p_add_information20 	=> per_addr_rec.ADD_INFORMATION20
		,p_default_primary 	=> l_primary_flag
		);


          --Bug 2856143 APi used now is the one being used on the form PERACADR.fmb
      -- Call the API - update_us_person_address.
      /*  hr_person_address_api.update_us_person_address
        (p_validate                      => FALSE
        ,p_effective_date                => p_effective_date
        ,p_address_id                    =>per_addr_rec.address_id
        ,p_object_version_number         =>per_addr_rec.object_version_number
        ,p_date_from                     =>per_addr_rec.date_from
        ,p_date_to                       =>per_addr_rec.date_to
        ,p_address_type                  =>per_addr_rec.address_type
        ,p_comments                      =>per_addr_rec.comments
        ,p_address_line1                 =>per_addr_rec.address_line1
        ,p_address_line2                 =>per_addr_rec.address_line2
        ,p_address_line3                 =>per_addr_rec.address_line3
        ,p_city                          =>per_addr_rec.TOWN_OR_CITY
        ,p_state                         =>per_addr_rec.region_2
        ,p_zip_code                      =>per_addr_rec.postal_code
        ,p_county                        =>per_addr_rec.region_1
        ,p_country                       =>per_addr_rec.country
        ,p_telephone_number_1            =>per_addr_rec.telephone_number_1
        ,p_telephone_number_2            =>per_addr_rec.telephone_number_2
        ,p_addr_attribute_category       =>per_addr_rec.addr_attribute_category
        ,p_addr_attribute1               =>per_addr_rec.addr_attribute1
        ,p_addr_attribute2               =>per_addr_rec.addr_attribute2
        ,p_addr_attribute3               =>per_addr_rec.addr_attribute3
        ,p_addr_attribute4               =>per_addr_rec.addr_attribute4
        ,p_addr_attribute5               =>per_addr_rec.addr_attribute5
        ,p_addr_attribute6               =>per_addr_rec.addr_attribute6
        ,p_addr_attribute7               =>per_addr_rec.addr_attribute7
        ,p_addr_attribute8               =>per_addr_rec.addr_attribute8
        ,p_addr_attribute9               =>per_addr_rec.addr_attribute9
        ,p_addr_attribute10              =>per_addr_rec.addr_attribute10
        ,p_addr_attribute11              =>per_addr_rec.addr_attribute11
        ,p_addr_attribute12              =>per_addr_rec.addr_attribute12
        ,p_addr_attribute13              =>per_addr_rec.addr_attribute13
        ,p_addr_attribute14              =>per_addr_rec.addr_attribute14
        ,p_addr_attribute15              =>per_addr_rec.addr_attribute15
        ,p_addr_attribute16              =>per_addr_rec.addr_attribute16
        ,p_addr_attribute17              =>per_addr_rec.addr_attribute17
        ,p_addr_attribute18              =>per_addr_rec.addr_attribute18
        ,p_addr_attribute19              =>per_addr_rec.addr_attribute19
        ,p_addr_attribute20              =>per_addr_rec.addr_attribute20
        );
     else
      hr_person_address_api.update_person_address
        (p_validate                      => FALSE
        ,p_effective_date                => p_effective_date
        ,p_address_id                    =>per_addr_rec.address_id
        ,p_object_version_number         =>per_addr_rec.object_version_number
        ,p_date_from                     =>per_addr_rec.date_from
        ,p_date_to                       =>per_addr_rec.date_to
        ,p_address_type                  =>per_addr_rec.address_type
        ,p_comments                      =>per_addr_rec.comments
        ,p_address_line1                 =>per_addr_rec.address_line1
        ,p_address_line2                 =>per_addr_rec.address_line2
        ,p_address_line3                 =>per_addr_rec.address_line3
        ,p_town_or_city                  =>per_addr_rec.TOWN_OR_CITY
        ,p_region_1                      =>per_addr_rec.region_1
        ,p_region_2                      =>per_addr_rec.region_2
        ,p_region_3                      =>per_addr_rec.region_3
        ,p_postal_code                   =>per_addr_rec.postal_code
        ,p_country                       =>per_addr_rec.country
        ,p_telephone_number_1            =>per_addr_rec.telephone_number_1
        ,p_telephone_number_2            =>per_addr_rec.telephone_number_2
        ,p_telephone_number_3            =>per_addr_rec.telephone_number_3
        ,p_addr_attribute_category       =>per_addr_rec.addr_attribute_category
        ,p_addr_attribute1               =>per_addr_rec.addr_attribute1
        ,p_addr_attribute2               =>per_addr_rec.addr_attribute2
        ,p_addr_attribute3               =>per_addr_rec.addr_attribute3
        ,p_addr_attribute4               =>per_addr_rec.addr_attribute4
        ,p_addr_attribute5               =>per_addr_rec.addr_attribute5
        ,p_addr_attribute6               =>per_addr_rec.addr_attribute6
        ,p_addr_attribute7               =>per_addr_rec.addr_attribute7
        ,p_addr_attribute8               =>per_addr_rec.addr_attribute8
        ,p_addr_attribute9               =>per_addr_rec.addr_attribute9
        ,p_addr_attribute10              =>per_addr_rec.addr_attribute10
        ,p_addr_attribute11              =>per_addr_rec.addr_attribute11
        ,p_addr_attribute12              =>per_addr_rec.addr_attribute12
        ,p_addr_attribute13              =>per_addr_rec.addr_attribute13
        ,p_addr_attribute14              =>per_addr_rec.addr_attribute14
        ,p_addr_attribute15              =>per_addr_rec.addr_attribute15
        ,p_addr_attribute16              =>per_addr_rec.addr_attribute16
        ,p_addr_attribute17              =>per_addr_rec.addr_attribute17
        ,p_addr_attribute18              =>per_addr_rec.addr_attribute18
        ,p_addr_attribute19              =>per_addr_rec.addr_attribute19
        ,p_addr_attribute20              =>per_addr_rec.addr_attribute20
        );  */ --Bug 2856143 APi used now is the one being used on the form PERACADR.fmb
    End If;
    --
    hr_utility.set_location(' Leaving: WATIF_ADDRESSES_API' , 10);
end;



procedure WATIF_ALL_ASSIGNMENTS_F_API(
   p_person_id                      in  number
  ,p_PAY_BASIS_ID                   in number
  ,p_EMPLOYMENT_CATEGORY            in varchar2
  ,p_LABOUR_UNION_MEMBER_FLAG       in varchar2
  ,p_JOB_ID                         in number
  ,p_PAYROLL_ID                     in number
  ,p_PRIMARY_FLAG                   in varchar2
  ,p_LOCATION_ID                    in number
  ,p_CHANGE_REASON                  in varchar2
  ,p_ASSIGNMENT_TYPE                in varchar2
  ,p_ORGANIZATION_ID                in number
  ,p_POSITION_ID                    in number
  ,p_BARGAINING_UNIT_CODE           in varchar2
  ,p_NORMAL_HOURS                   in number
  ,p_FREQUENCY                      in varchar2
  ,p_ASSIGNMENT_STATUS_TYPE_ID      in number
  ,p_GRADE_ID                       in number
  ,p_PEOPLE_GROUP_ID                in  NUMBER
  ,p_HOURLY_SALARIED_CODE	    in varchar2
  ,p_ASS_ATTRIBUTE_CATEGORY         in varchar2
  ,p_ASS_ATTRIBUTE1                 in  VARCHAR2
  ,p_ASS_ATTRIBUTE10                in  VARCHAR2
  ,p_ASS_ATTRIBUTE11                in  VARCHAR2
  ,p_ASS_ATTRIBUTE12                in  VARCHAR2
  ,p_ASS_ATTRIBUTE13                in  VARCHAR2
  ,p_ASS_ATTRIBUTE14                in  VARCHAR2
  ,p_ASS_ATTRIBUTE15                in  VARCHAR2
  ,p_ASS_ATTRIBUTE16                in  VARCHAR2
  ,p_ASS_ATTRIBUTE17                in  VARCHAR2
  ,p_ASS_ATTRIBUTE18                in  VARCHAR2
  ,p_ASS_ATTRIBUTE19                in  VARCHAR2
  ,p_ASS_ATTRIBUTE2                 in  VARCHAR2
  ,p_ASS_ATTRIBUTE20                in  VARCHAR2
  ,p_ASS_ATTRIBUTE21                in  VARCHAR2
  ,p_ASS_ATTRIBUTE22                in  VARCHAR2
  ,p_ASS_ATTRIBUTE23                in  VARCHAR2
  ,p_ASS_ATTRIBUTE24                in  VARCHAR2
  ,p_ASS_ATTRIBUTE25                in  VARCHAR2
  ,p_ASS_ATTRIBUTE26                in  VARCHAR2
  ,p_ASS_ATTRIBUTE27                in  VARCHAR2
  ,p_ASS_ATTRIBUTE28                in  VARCHAR2
  ,p_ASS_ATTRIBUTE29                in  VARCHAR2
  ,p_ASS_ATTRIBUTE3                 in  VARCHAR2
  ,p_ASS_ATTRIBUTE30                in  VARCHAR2
  ,p_ASS_ATTRIBUTE4                 in  VARCHAR2
  ,p_ASS_ATTRIBUTE5                 in  VARCHAR2
  ,p_ASS_ATTRIBUTE6                 in  VARCHAR2
  ,p_ASS_ATTRIBUTE7                 in  VARCHAR2
  ,p_ASS_ATTRIBUTE8                 in  VARCHAR2
  ,p_ASS_ATTRIBUTE9                 in  VARCHAR2
  ,p_business_group_id              in  number
  ,p_effective_date                 in  date
  ) is
  --
  per_assign_rec per_all_assignments_f%rowtype;
  --
  cursor c_assign is
   select * from per_all_assignments_f
    where   person_id = p_person_id  and
            assignment_type <> 'C' and
            p_effective_date between nvl(effective_start_date, p_effective_date)
                             and     nvl(effective_end_date, p_effective_date)
            and primary_flag = 'Y';
  --
  l_soft_coding_keyflex_id             number;
  l_comment_id                         number;
  l_effective_start_date               date;
  l_effective_end_date                 date;
  l_concatenated_segments              varchar2(100);
  l_no_managers_warning                boolean;
  l_other_manager_warning              boolean;
  l_upd_mode                           varchar2(25);
  l_upd_extra_asg_flag                 boolean;
  --
  l_group_name                      varchar2(500); -- UTF8 Change Bug 2254683
  l_asg_effective_start_date        date;
  l_asg_effective_end_date          date;
  l_people_group_id                 number;
  l_org_now_no_manager_warning      boolean;
  l_spp_delete_warning              boolean;
  l_entries_changed_warning         varchar2(30);
  l_tax_district_changed_warning    boolean;
  l_special_ceiling_step_id per_all_assignments_f.special_ceiling_step_id%type;
  --
begin
   --
   hr_utility.set_location(' Entering: WATIF_ALL_ASSIGNMENTS_F_API' , 10);
   --
   If  p_PAY_BASIS_ID                   is null and
       p_EMPLOYMENT_CATEGORY            is null and
       p_JOB_ID                         is null and
       p_PAYROLL_ID                     is null and
       p_PRIMARY_FLAG                   is null and
       p_LOCATION_ID                    is null and
       p_ASSIGNMENT_TYPE                is null and
       p_ORGANIZATION_ID                is null and
       p_POSITION_ID                    is null and
       p_GRADE_ID                       is null and
       p_ASSIGNMENT_STATUS_TYPE_ID      is null and
       p_PEOPLE_GROUP_ID is null and
       p_LABOUR_UNION_MEMBER_FLAG       is null and
       p_CHANGE_REASON                  is null and
       p_BARGAINING_UNIT_CODE           is null and
       p_NORMAL_HOURS                   is null and
       p_FREQUENCY                      is null and
       p_HOURLY_SALARIED_CODE is null and
       p_ASS_ATTRIBUTE_CATEGORY is null and
       p_ASS_ATTRIBUTE1 is null and
       p_ASS_ATTRIBUTE10 is null and
       p_ASS_ATTRIBUTE11 is null and
       p_ASS_ATTRIBUTE12 is null and
       p_ASS_ATTRIBUTE13 is null and
       p_ASS_ATTRIBUTE14 is null and
       p_ASS_ATTRIBUTE15 is null and
       p_ASS_ATTRIBUTE16 is null and
       p_ASS_ATTRIBUTE17 is null and
       p_ASS_ATTRIBUTE18 is null and
       p_ASS_ATTRIBUTE19 is null and
       p_ASS_ATTRIBUTE2 is null and
       p_ASS_ATTRIBUTE20 is null and
       p_ASS_ATTRIBUTE21 is null and
       p_ASS_ATTRIBUTE22 is null and
       p_ASS_ATTRIBUTE23 is null and
       p_ASS_ATTRIBUTE24 is null and
       p_ASS_ATTRIBUTE25 is null and
       p_ASS_ATTRIBUTE26 is null and
       p_ASS_ATTRIBUTE27 is null and
       p_ASS_ATTRIBUTE28 is null and
       p_ASS_ATTRIBUTE29 is null and
       p_ASS_ATTRIBUTE3 is null and
       p_ASS_ATTRIBUTE30 is null and
       p_ASS_ATTRIBUTE4 is null and
       p_ASS_ATTRIBUTE5 is null and
       p_ASS_ATTRIBUTE6 is null and
       p_ASS_ATTRIBUTE7 is null and
       p_ASS_ATTRIBUTE8 is null and
       p_ASS_ATTRIBUTE9 is null
   then
       --
       fnd_message.set_name('BEN','BEN_91447_ALL_NULL');
       fnd_message.raise_error;
       --
   End If;
   --
   if  p_LABOUR_UNION_MEMBER_FLAG        is not null or
       p_CHANGE_REASON                   is not null or
       p_BARGAINING_UNIT_CODE            is not null or
       p_NORMAL_HOURS                    is not null or
       p_FREQUENCY                       is not null or
       p_HOURLY_SALARIED_CODE is not null or
       p_ASS_ATTRIBUTE_CATEGORY is not null or
       p_ASS_ATTRIBUTE1  is not null or
       p_ASS_ATTRIBUTE10  is not null or
       p_ASS_ATTRIBUTE11  is not null or
       p_ASS_ATTRIBUTE12  is not null or
       p_ASS_ATTRIBUTE13  is not null or
       p_ASS_ATTRIBUTE14  is not null or
       p_ASS_ATTRIBUTE15  is not null or
       p_ASS_ATTRIBUTE16  is not null or
       p_ASS_ATTRIBUTE17  is not null or
       p_ASS_ATTRIBUTE18  is not null or
       p_ASS_ATTRIBUTE19  is not null or
       p_ASS_ATTRIBUTE2  is not null or
       p_ASS_ATTRIBUTE20  is not null or
       p_ASS_ATTRIBUTE21  is not null or
       p_ASS_ATTRIBUTE22  is not null or
       p_ASS_ATTRIBUTE23  is not null or
       p_ASS_ATTRIBUTE24  is not null or
       p_ASS_ATTRIBUTE25  is not null or
       p_ASS_ATTRIBUTE26  is not null or
       p_ASS_ATTRIBUTE27  is not null or
       p_ASS_ATTRIBUTE28  is not null or
       p_ASS_ATTRIBUTE29  is not null or
       p_ASS_ATTRIBUTE3  is not null or
       p_ASS_ATTRIBUTE30  is not null or
       p_ASS_ATTRIBUTE4  is not null or
       p_ASS_ATTRIBUTE5  is not null or
       p_ASS_ATTRIBUTE6  is not null or
       p_ASS_ATTRIBUTE7  is not null or
       p_ASS_ATTRIBUTE8 is not null or
       p_ASS_ATTRIBUTE9 is not null
   then
       l_upd_extra_asg_flag := TRUE;
   end if;
   --
   If  p_PAY_BASIS_ID                   is not null or
       p_EMPLOYMENT_CATEGORY            is not null or
       p_JOB_ID                         is not null or
       p_PAYROLL_ID                     is not null or
       p_PRIMARY_FLAG                   is not null or
       p_LOCATION_ID                    is not null or
       p_ASSIGNMENT_TYPE                is not null or
       p_ORGANIZATION_ID                is not null or
       p_POSITION_ID                    is not null or
       p_GRADE_ID                       is not null or
       p_ASSIGNMENT_STATUS_TYPE_ID      is not null or
       p_PEOPLE_GROUP_ID is not null
   then
       --
       -- Use hr_assignment_api.update_emp_asg_criteria to update
       -- above data.
       --
       hr_utility.set_location('p_PAY_BASIS_ID = ' || p_PAY_BASIS_ID, 999);
       hr_utility.set_location('p_EMPLOYMENT_CATEGORY = ' || p_EMPLOYMENT_CATEGORY, 999);
       hr_utility.set_location('p_JOB_ID = ' || p_JOB_ID, 999);
       hr_utility.set_location('p_PAYROLL_ID = ' || p_PAYROLL_ID, 999);
       hr_utility.set_location('p_PRIMARY_FLAG = ' || p_PRIMARY_FLAG, 999);
       hr_utility.set_location('p_LOCATION_ID = ' || p_LOCATION_ID, 999);
       hr_utility.set_location('p_ASSIGNMENT_TYPE = ' || p_ASSIGNMENT_TYPE, 999);
       hr_utility.set_location('p_ORGANIZATION_ID = ' || p_ORGANIZATION_ID, 999);
       hr_utility.set_location('p_POSITION_ID = ' || p_POSITION_ID, 999);
       hr_utility.set_location('p_GRADE_ID = ' || p_GRADE_ID, 999);
       hr_utility.set_location('p_ASSIGNMENT_STATUS_TYPE_ID = ' || p_ASSIGNMENT_STATUS_TYPE_ID, 999);
       hr_utility.set_location('p_PEOPLE_GROUP_ID = ' || p_PEOPLE_GROUP_ID, 999);
       --
       open c_assign;
       fetch c_assign into per_assign_rec;
       if  c_assign%notfound Then
           Close c_assign;
           --
           -- Assignment Record is  Not found so error.
           --
           fnd_message.set_name('BEN','BEN_91443_NO_ASSGN');
           fnd_message.raise_error;
           --
       End If;
       Close c_assign;
       --
       if p_PAY_BASIS_ID is not null then
          per_assign_rec.PAY_BASIS_ID    := p_PAY_BASIS_ID;
       end if;
       --
       if p_EMPLOYMENT_CATEGORY is not null then
          per_assign_rec.EMPLOYMENT_CATEGORY    := p_EMPLOYMENT_CATEGORY;
       end if;
       --
       if p_JOB_ID is not null then
          per_assign_rec.JOB_ID    := p_JOB_ID;
       end if;
       --
       if p_PAYROLL_ID is not null then
          per_assign_rec.PAYROLL_ID    := p_PAYROLL_ID;
       end if;
       --
       if p_PRIMARY_FLAG is not null then
          per_assign_rec.PRIMARY_FLAG    := p_PRIMARY_FLAG;
       end if;
       --
       if p_LOCATION_ID is not null then
          per_assign_rec.LOCATION_ID    := p_LOCATION_ID;
       end if;
       --
       if p_ASSIGNMENT_TYPE is not null then
          per_assign_rec.ASSIGNMENT_TYPE    := p_ASSIGNMENT_TYPE;
       end if;
       --
       if p_ORGANIZATION_ID is not null then
          per_assign_rec.ORGANIZATION_ID    := p_ORGANIZATION_ID;
       end if;
       --
       if p_POSITION_ID is not null then
          per_assign_rec.POSITION_ID    := p_POSITION_ID;
       end if;
       --
       --
       if p_ASSIGNMENT_STATUS_TYPE_ID is not null then
          per_assign_rec.ASSIGNMENT_STATUS_TYPE_ID    := p_ASSIGNMENT_STATUS_TYPE_ID;
       end if;
       --
       if p_GRADE_ID is not null then
          per_assign_rec.GRADE_ID    := p_GRADE_ID;
       end if;
       --
       if p_PEOPLE_GROUP_ID is not null then
          per_assign_rec.PEOPLE_GROUP_ID     := p_PEOPLE_GROUP_ID;
       end if;
       --
       Get_DT_Upd_Mode
       (p_effective_date        => p_effective_date,
        p_base_table_name       => 'PER_ALL_ASSIGNMENTS_F',
        p_base_key_column       => 'ASSIGNMENT_ID',
        p_base_key_value        => per_assign_rec.assignment_id,
        p_mode                  => l_upd_mode);
       --
       hr_assignment_api.update_emp_asg_criteria
        (p_effective_date               => p_effective_date
        ,p_datetrack_update_mode        => l_upd_mode
        ,p_assignment_id                => per_assign_rec.assignment_id
        ,p_object_version_number        => per_assign_rec.object_version_number
        ,p_grade_id                     => per_assign_rec.grade_id
        ,p_position_id                  => per_assign_rec.position_id
        ,p_job_id                       => per_assign_rec.job_id
        ,p_payroll_id                   => per_assign_rec.payroll_id
        ,p_location_id                  => per_assign_rec.location_id
        ,p_special_ceiling_step_id      => l_special_ceiling_step_id
        ,p_organization_id              => per_assign_rec.organization_id
        ,p_pay_basis_id                 => per_assign_rec.pay_basis_id
        ,p_employment_category          => per_assign_rec.employment_category
        ,p_group_name                   => l_group_name
        ,p_effective_start_date         => l_asg_effective_start_date
        ,p_effective_end_date           => l_asg_effective_end_date
        ,p_people_group_id              => l_people_group_id
        ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
        ,p_other_manager_warning        => l_other_manager_warning
        ,p_spp_delete_warning           => l_spp_delete_warning
        ,p_entries_changed_warning      => l_entries_changed_warning
        ,p_tax_district_changed_warning => l_tax_district_changed_warning
        );
       --
   end if;
   --
   open c_assign;
   fetch c_assign into per_assign_rec;
   if  c_assign%notfound Then
       Close c_assign;
       --
       -- Assignment Record is  Not found so error.
       --
       fnd_message.set_name('BEN','BEN_91443_NO_ASSGN');
       fnd_message.raise_error;
       --
   End If;
   Close c_assign;
   --
   if l_upd_extra_asg_flag then
   if p_LABOUR_UNION_MEMBER_FLAG is not null then
      per_assign_rec.LABOUR_UNION_MEMBER_FLAG    := p_LABOUR_UNION_MEMBER_FLAG;
   end if;
   --
   --
   if p_CHANGE_REASON is not null then
      per_assign_rec.CHANGE_REASON    := p_CHANGE_REASON;
   end if;
   --
   --
   if p_BARGAINING_UNIT_CODE is not null then
      per_assign_rec.BARGAINING_UNIT_CODE    := p_BARGAINING_UNIT_CODE;
   end if;
   --
   --
   if p_NORMAL_HOURS is not null then
      per_assign_rec.NORMAL_HOURS    := p_NORMAL_HOURS;
   end if;
   --
   --
   if p_FREQUENCY is not null then
      per_assign_rec.FREQUENCY    := p_FREQUENCY;
   end if;

   if p_HOURLY_SALARIED_CODE is not null then
      per_assign_rec.HOURLY_SALARIED_CODE   := p_HOURLY_SALARIED_CODE;
   end if;

   if p_ASS_ATTRIBUTE_CATEGORY is not null then
      per_assign_rec.ASS_ATTRIBUTE_CATEGORY     := p_ASS_ATTRIBUTE_CATEGORY;
   end if;
   --
   if p_ASS_ATTRIBUTE1 is not null then
      per_assign_rec.ASS_ATTRIBUTE1     := p_ASS_ATTRIBUTE1;
   end if;

   if p_ASS_ATTRIBUTE10 is not null then
      per_assign_rec.ASS_ATTRIBUTE10     := p_ASS_ATTRIBUTE10;
   end if;

   if p_ASS_ATTRIBUTE11 is not null then
      per_assign_rec.ASS_ATTRIBUTE11     := p_ASS_ATTRIBUTE11;
   end if;

   if p_ASS_ATTRIBUTE12 is not null then
      per_assign_rec.ASS_ATTRIBUTE12     := p_ASS_ATTRIBUTE12;
   end if;

   if p_ASS_ATTRIBUTE13 is not null then
      per_assign_rec.ASS_ATTRIBUTE13     := p_ASS_ATTRIBUTE13;
   end if;

   if p_ASS_ATTRIBUTE14 is not null then
      per_assign_rec.ASS_ATTRIBUTE14     := p_ASS_ATTRIBUTE14;
   end if;

   if p_ASS_ATTRIBUTE15 is not null then
      per_assign_rec.ASS_ATTRIBUTE15     := p_ASS_ATTRIBUTE15;
   end if;

   if p_ASS_ATTRIBUTE16 is not null then
      per_assign_rec.ASS_ATTRIBUTE16     := p_ASS_ATTRIBUTE16;
   end if;

   if p_ASS_ATTRIBUTE17 is not null then
      per_assign_rec.ASS_ATTRIBUTE17     := p_ASS_ATTRIBUTE17;
   end if;

   if p_ASS_ATTRIBUTE18 is not null then
      per_assign_rec.ASS_ATTRIBUTE18     := p_ASS_ATTRIBUTE18;
   end if;

   if p_ASS_ATTRIBUTE19 is not null then
      per_assign_rec.ASS_ATTRIBUTE19     := p_ASS_ATTRIBUTE19;
   end if;

   if p_ASS_ATTRIBUTE2 is not null then
      per_assign_rec.ASS_ATTRIBUTE2     := p_ASS_ATTRIBUTE2;
   end if;

   if p_ASS_ATTRIBUTE20 is not null then
      per_assign_rec.ASS_ATTRIBUTE20     := p_ASS_ATTRIBUTE20;
   end if;

   if p_ASS_ATTRIBUTE21 is not null then
      per_assign_rec.ASS_ATTRIBUTE21     := p_ASS_ATTRIBUTE21;
   end if;

   if p_ASS_ATTRIBUTE22 is not null then
      per_assign_rec.ASS_ATTRIBUTE22     := p_ASS_ATTRIBUTE22;
   end if;

   if p_ASS_ATTRIBUTE23 is not null then
      per_assign_rec.ASS_ATTRIBUTE23     := p_ASS_ATTRIBUTE23;
   end if;

   if p_ASS_ATTRIBUTE24 is not null then
      per_assign_rec.ASS_ATTRIBUTE24     := p_ASS_ATTRIBUTE24;
   end if;

   if p_ASS_ATTRIBUTE25 is not null then
      per_assign_rec.ASS_ATTRIBUTE25     := p_ASS_ATTRIBUTE25;
   end if;

   if p_ASS_ATTRIBUTE26 is not null then
      per_assign_rec.ASS_ATTRIBUTE26     := p_ASS_ATTRIBUTE26;
   end if;

   if p_ASS_ATTRIBUTE27 is not null then
      per_assign_rec.ASS_ATTRIBUTE27     := p_ASS_ATTRIBUTE27;
   end if;

   if p_ASS_ATTRIBUTE28 is not null then
      per_assign_rec.ASS_ATTRIBUTE28     := p_ASS_ATTRIBUTE28;
   end if;

   if p_ASS_ATTRIBUTE29 is not null then
      per_assign_rec.ASS_ATTRIBUTE29     := p_ASS_ATTRIBUTE29;
   end if;

   if p_ASS_ATTRIBUTE3 is not null then
      per_assign_rec.ASS_ATTRIBUTE3     := p_ASS_ATTRIBUTE3;
   end if;

   if p_ASS_ATTRIBUTE30 is not null then
      per_assign_rec.ASS_ATTRIBUTE30     := p_ASS_ATTRIBUTE30;
   end if;

   if p_ASS_ATTRIBUTE4 is not null then
      per_assign_rec.ASS_ATTRIBUTE4     := p_ASS_ATTRIBUTE4;
   end if;

   if p_ASS_ATTRIBUTE5 is not null then
      per_assign_rec.ASS_ATTRIBUTE5     := p_ASS_ATTRIBUTE5;
   end if;

   if p_ASS_ATTRIBUTE6 is not null then
      per_assign_rec.ASS_ATTRIBUTE6     := p_ASS_ATTRIBUTE6;
   end if;

   if p_ASS_ATTRIBUTE7 is not null then
      per_assign_rec.ASS_ATTRIBUTE7     := p_ASS_ATTRIBUTE7;
   end if;

   if p_ASS_ATTRIBUTE8 is not null then
      per_assign_rec.ASS_ATTRIBUTE8     := p_ASS_ATTRIBUTE8;
   end if;

   if p_ASS_ATTRIBUTE9 is not null then
      per_assign_rec.ASS_ATTRIBUTE9     := p_ASS_ATTRIBUTE9;
   end if;

   Get_DT_Upd_Mode
       (p_effective_date        => p_effective_date,
        p_base_table_name       => 'PER_ALL_ASSIGNMENTS_F',
        p_base_key_column       => 'ASSIGNMENT_ID',
        p_base_key_value        => per_assign_rec.assignment_id,
        p_mode                  => l_upd_mode);

   --
   -- Call the API - hr_assignment_api.update_emp_asg :peasgapi.pkh
   --
   hr_assignment_api.update_emp_asg
   (p_validate                          => FALSE
   ,p_effective_date                    => p_effective_date
   ,p_datetrack_update_mode             => l_upd_mode -- 'CORRECTION' --  'UPDATE_OVERRIDE'
   ,p_assignment_id                     => per_assign_rec.assignment_id
   ,p_object_version_number             => per_assign_rec.object_version_number
   ,p_supervisor_id                     => per_assign_rec.supervisor_id
   ,p_assignment_number                 => per_assign_rec.assignment_number
   ,p_change_reason                     => per_assign_rec.change_reason
   ,p_LABOUR_UNION_MEMBER_FLAG          => per_assign_rec.LABOUR_UNION_MEMBER_FLAG
   ,p_BARGAINING_UNIT_CODE              => per_assign_rec.BARGAINING_UNIT_CODE
   ,p_date_probation_end                => per_assign_rec.date_probation_end
   ,p_default_code_comb_id              => per_assign_rec.default_code_comb_id
   ,p_frequency                         => per_assign_rec.frequency
   ,p_internal_address_line             => per_assign_rec.internal_address_line
   ,p_manager_flag                      => per_assign_rec.manager_flag
   ,p_normal_hours                      => per_assign_rec.normal_hours
   ,p_perf_review_period                => per_assign_rec.perf_review_period
   ,p_perf_review_period_frequency      => per_assign_rec.perf_review_period_frequency
   ,p_probation_period                  => per_assign_rec.probation_period
   ,p_probation_unit                    => per_assign_rec.probation_unit
   ,p_sal_review_period                 => per_assign_rec.sal_review_period
   ,p_sal_review_period_frequency       => per_assign_rec.sal_review_period_frequency
   ,p_set_of_books_id                   => per_assign_rec.set_of_books_id
   ,p_source_type                       => per_assign_rec.source_type
   ,p_time_normal_finish                => per_assign_rec.time_normal_finish
   ,p_time_normal_start                 => per_assign_rec.time_normal_start
   ,p_hourly_salaried_code		=> per_assign_rec.hourly_salaried_code
   ,p_ass_attribute_category            => per_assign_rec.ass_attribute_category
   ,p_ass_attribute1                    => per_assign_rec.ass_attribute1
   ,p_ass_attribute2                    => per_assign_rec.ass_attribute2
   ,p_ass_attribute3                    => per_assign_rec.ass_attribute3
   ,p_ass_attribute4                    => per_assign_rec.ass_attribute4
   ,p_ass_attribute5                    => per_assign_rec.ass_attribute5
   ,p_ass_attribute6                    => per_assign_rec.ass_attribute6
   ,p_ass_attribute7                    => per_assign_rec.ass_attribute7
   ,p_ass_attribute8                    => per_assign_rec.ass_attribute8
   ,p_ass_attribute9                    => per_assign_rec.ass_attribute9
   ,p_ass_attribute10                    => per_assign_rec.ass_attribute10
   ,p_ass_attribute11                    => per_assign_rec.ass_attribute11
   ,p_ass_attribute12                    => per_assign_rec.ass_attribute12
   ,p_ass_attribute13                    => per_assign_rec.ass_attribute13
   ,p_ass_attribute14                    => per_assign_rec.ass_attribute14
   ,p_ass_attribute15                    => per_assign_rec.ass_attribute15
   ,p_ass_attribute16                    => per_assign_rec.ass_attribute16
   ,p_ass_attribute17                    => per_assign_rec.ass_attribute17
   ,p_ass_attribute18                    => per_assign_rec.ass_attribute18
   ,p_ass_attribute19                    => per_assign_rec.ass_attribute19
   ,p_ass_attribute20                    => per_assign_rec.ass_attribute20
   ,p_ass_attribute21                    => per_assign_rec.ass_attribute21
   ,p_ass_attribute22                    => per_assign_rec.ass_attribute22
   ,p_ass_attribute23                    => per_assign_rec.ass_attribute23
   ,p_ass_attribute24                    => per_assign_rec.ass_attribute24
   ,p_ass_attribute25                    => per_assign_rec.ass_attribute25
   ,p_ass_attribute26                    => per_assign_rec.ass_attribute26
   ,p_ass_attribute27                    => per_assign_rec.ass_attribute27
   ,p_ass_attribute28                    => per_assign_rec.ass_attribute28
   ,p_ass_attribute29                    => per_assign_rec.ass_attribute29
   ,p_ass_attribute30                    => per_assign_rec.ass_attribute30
   ,p_title                              => per_assign_rec.title
--      ,p_segment1                           => per_assign_rec.segment1
--      ,p_segment2        			=> per_assign_rec.segment2
--      ,p_segment3        			=> per_assign_rec.segment3
--      ,p_segment4        			=> per_assign_rec.segment4
--      ,p_segment5        			=> per_assign_rec.segment5
--      ,p_segment6        			=> per_assign_rec.segment6
--      ,p_segment7        			=> per_assign_rec.segment7
--      ,p_segment8        			=> per_assign_rec.segment8
--      ,p_segment9        			=> per_assign_rec.segment9
--      ,p_segment10        			=> per_assign_rec.segment10
--      ,p_segment11        			=> per_assign_rec.segment11
--      ,p_segment12        			=> per_assign_rec.segment12
--      ,p_segment13        			=> per_assign_rec.segment13
--      ,p_segment14        			=> per_assign_rec.segment14
--      ,p_segment15        			=> per_assign_rec.segment15
--      ,p_segment16        			=> per_assign_rec.segment16
--      ,p_segment17        			=> per_assign_rec.segment17
--      ,p_segment18        			=> per_assign_rec.segment18
--      ,p_segment19        			=> per_assign_rec.segment19
--      ,p_segment20        			=> per_assign_rec.segment20
--      ,p_segment21        			=> per_assign_rec.segment21
--      ,p_segment22        			=> per_assign_rec.segment22
--      ,p_segment23        			=> per_assign_rec.segment23
--      ,p_segment24        			=> per_assign_rec.segment24
--      ,p_segment25        			=> per_assign_rec.segment25
--      ,p_segment26        			=> per_assign_rec.segment26
--      ,p_segment27        			=> per_assign_rec.segment27
--      ,p_segment28        			=> per_assign_rec.segment28
--      ,p_segment29        			=> per_assign_rec.segment29
--      ,p_segment30        			=> per_assign_rec.segment30
   ,p_soft_coding_keyflex_id             => l_soft_coding_keyflex_id
   ,p_comment_id        			=> l_comment_id
   ,p_effective_start_date               => l_effective_start_date
   ,p_effective_end_date                 => l_effective_end_date
   ,p_concatenated_segments              => l_concatenated_segments
   ,p_no_managers_warning                => l_no_managers_warning
   ,p_other_manager_warning              => l_other_manager_warning
   );
   --
   end if;
   hr_utility.set_location(' Leaving: WATIF_ALL_ASSIGNMENTS_F_API' , 10);
end;



procedure WATIF_ALL_PEOPLE_F_API(
   p_person_id                      in  number
  ,p_STUDENT_STATUS                 in varchar2
  ,p_MARITAL_STATUS                 in varchar2
  ,p_DATE_OF_DEATH                  in date
  ,p_DATE_OF_BIRTH                  in date
  ,p_COORD_BEN_NO_CVG_FLAG          in varchar2
  ,p_ON_MILITARY_SERVICE            in varchar2
  ,p_REGISTERED_DISABLED_FLAG       in varchar2
  ,p_USES_TOBACCO_FLAG              in varchar2
  ,p_BENEFIT_GROUP_ID               in number
  ,p_PER_INFORMATION10              in varchar2
  ,p_COORD_BEN_MED_PLN_NO           in varchar2
  ,p_DPDNT_VLNTRY_SVCE_FLAG         in varchar2
  ,p_RECEIPT_OF_DEATH_CERT_DATE     in date
  ,p_sex 			    in varchar2
   ,p_ATTRIBUTE1                    in  VARCHAR2
   ,p_ATTRIBUTE10                    in VARCHAR2
   ,p_ATTRIBUTE11                    in VARCHAR2
   ,p_ATTRIBUTE12                    in VARCHAR2
   ,p_ATTRIBUTE13                    in VARCHAR2
   ,p_ATTRIBUTE14                    in VARCHAR2
   ,p_ATTRIBUTE15                    in VARCHAR2
   ,p_ATTRIBUTE16                    in VARCHAR2
   ,p_ATTRIBUTE17                    in VARCHAR2
   ,p_ATTRIBUTE18                    in VARCHAR2
   ,p_ATTRIBUTE19                    in VARCHAR2
   ,p_ATTRIBUTE2                     in VARCHAR2
   ,p_ATTRIBUTE20                    in VARCHAR2
   ,p_ATTRIBUTE21                    in VARCHAR2
   ,p_ATTRIBUTE22                    in VARCHAR2
   ,p_ATTRIBUTE23                    in VARCHAR2
   ,p_ATTRIBUTE24                    in VARCHAR2
   ,p_ATTRIBUTE25                    in VARCHAR2
   ,p_ATTRIBUTE26                    in VARCHAR2
   ,p_ATTRIBUTE27                    in VARCHAR2
   ,p_ATTRIBUTE28                    in VARCHAR2
   ,p_ATTRIBUTE29                    in VARCHAR2
   ,p_ATTRIBUTE3                     in VARCHAR2
   ,p_ATTRIBUTE30                    in VARCHAR2
   ,p_ATTRIBUTE4                     in VARCHAR2
   ,p_ATTRIBUTE5                     in VARCHAR2
   ,p_ATTRIBUTE6                     in VARCHAR2
   ,p_ATTRIBUTE7                     in VARCHAR2
   ,p_ATTRIBUTE8                     in VARCHAR2
   ,p_ATTRIBUTE9                     in VARCHAR2
  ,p_business_group_id              in  number
  ,p_effective_date                 in  date
  ) is
  --
  per_person_rec per_all_people_f%rowtype;
  --
  cursor c_person is
   select * from per_all_people_f
    where   person_id = p_person_id  and
            p_effective_date between nvl(effective_start_date, p_effective_date)
                             and     nvl(effective_end_date, p_effective_date);
   --
   l_effective_start_date           date;
   l_effective_end_date             date;
   l_full_name                      per_all_people_f.full_name%type; -- UTF8 Change Bug 2254683
   l_comment_id                     number;
   l_name_combination_warning       boolean;
   l_assign_payroll_warning         boolean;
   l_ORIG_HIRE_WARNING              boolean;
   l_upd_mode                       varchar2(25);
   --
begin
   --
   hr_utility.set_location(' Entering: WATIF_ALL_PEOPLE_F_API' , 10);
   --
   If   p_STUDENT_STATUS                 is null and
        p_MARITAL_STATUS                 is null and
        p_DATE_OF_DEATH                  is null and
        p_DATE_OF_BIRTH                  is null and
        p_COORD_BEN_NO_CVG_FLAG          is null and
        p_COORD_BEN_MED_PLN_NO           is null and
        p_ON_MILITARY_SERVICE            is null and
        p_REGISTERED_DISABLED_FLAG       is null and
        p_USES_TOBACCO_FLAG              is null and
        p_BENEFIT_GROUP_ID               is null and
        p_PER_INFORMATION10              is null and
        p_COORD_BEN_MED_PLN_NO           is null and
        p_DPDNT_VLNTRY_SVCE_FLAG         is null and
        p_RECEIPT_OF_DEATH_CERT_DATE     is null and
	p_sex 				 is null
   then
       --
       fnd_message.set_name('BEN','BEN_91447_ALL_NULL');
       fnd_message.raise_error;
       --
   End If;
   --
   open c_person;
   fetch c_person into per_person_rec;
   if  c_person%notfound Then
       Close c_person;
       --
       -- Person Record is  Not found so error.
       --
       fnd_message.set_name('BEN','BEN_91444_NO_PER');
       fnd_message.raise_error;
       --
   End If;
   Close c_person;
   --
   if p_STUDENT_STATUS is not null then
      per_person_rec.STUDENT_STATUS    := p_STUDENT_STATUS;
   end if;
   --
   --
   if p_MARITAL_STATUS is not null then
      per_person_rec.MARITAL_STATUS    := p_MARITAL_STATUS;
   end if;
   --
   --
   if p_DATE_OF_DEATH is not null then
      per_person_rec.DATE_OF_DEATH    := p_DATE_OF_DEATH;
   end if;
   --
   --
   if p_DATE_OF_BIRTH is not null then
      per_person_rec.DATE_OF_BIRTH    := p_DATE_OF_BIRTH;
   end if;
   --
   --
   if p_COORD_BEN_NO_CVG_FLAG is not null then
      per_person_rec.COORD_BEN_NO_CVG_FLAG    := p_COORD_BEN_NO_CVG_FLAG;
   end if;
   --
   --
   if p_COORD_BEN_MED_PLN_NO is not null then
      per_person_rec.COORD_BEN_MED_PLN_NO    := p_COORD_BEN_MED_PLN_NO;
   end if;
   --
   --
   if p_ON_MILITARY_SERVICE is not null then
      per_person_rec.ON_MILITARY_SERVICE    := p_ON_MILITARY_SERVICE;
   end if;
   --
   --
   if p_REGISTERED_DISABLED_FLAG is not null then
      per_person_rec.REGISTERED_DISABLED_FLAG    := p_REGISTERED_DISABLED_FLAG;
   end if;
   --
   --
   if p_USES_TOBACCO_FLAG is not null then
      per_person_rec.USES_TOBACCO_FLAG    := p_USES_TOBACCO_FLAG;
  end if;
   --
   --
   if p_BENEFIT_GROUP_ID is not null then
      per_person_rec.BENEFIT_GROUP_ID    := p_BENEFIT_GROUP_ID;
   end if;
   --

   if p_PER_INFORMATION10 is not null then
      per_person_rec.PER_INFORMATION10     := p_PER_INFORMATION10;
   end if;

   if p_COORD_BEN_MED_PLN_NO is not null then
      per_person_rec.COORD_BEN_MED_PLN_NO     := p_COORD_BEN_MED_PLN_NO;
   end if;

   if p_DPDNT_VLNTRY_SVCE_FLAG is not null then
      per_person_rec.DPDNT_VLNTRY_SVCE_FLAG     := p_DPDNT_VLNTRY_SVCE_FLAG;
   end if;

   if p_RECEIPT_OF_DEATH_CERT_DATE is not null then
      per_person_rec.RECEIPT_OF_DEATH_CERT_DATE     := p_RECEIPT_OF_DEATH_CERT_DATE;
   end if;

   if p_sex is not null then
      per_person_rec.sex := p_sex;
   end if;

   if p_ATTRIBUTE16 is not null then
      per_person_rec.ATTRIBUTE16     := p_ATTRIBUTE16;
   end if;

   if p_ATTRIBUTE18 is not null then
      per_person_rec.ATTRIBUTE18     := p_ATTRIBUTE18;
   end if;

   if p_ATTRIBUTE19 is not null then
      per_person_rec.ATTRIBUTE19     := p_ATTRIBUTE19;
   end if;

   if p_ATTRIBUTE20 is not null then
      per_person_rec.ATTRIBUTE20     := p_ATTRIBUTE20;
   end if;

   if p_ATTRIBUTE21 is not null then
      per_person_rec.ATTRIBUTE21     := p_ATTRIBUTE21;
   end if;

   if p_ATTRIBUTE22 is not null then
      per_person_rec.ATTRIBUTE22     := p_ATTRIBUTE22;
   end if;

   if p_ATTRIBUTE23 is not null then
      per_person_rec.ATTRIBUTE23     := p_ATTRIBUTE23;
   end if;

   if p_ATTRIBUTE24 is not null then
      per_person_rec.ATTRIBUTE24     := p_ATTRIBUTE24;
   end if;

   if p_ATTRIBUTE25 is not null then
      per_person_rec.ATTRIBUTE25     := p_ATTRIBUTE25;
   end if;

   if p_ATTRIBUTE26 is not null then
      per_person_rec.ATTRIBUTE26     := p_ATTRIBUTE26;
   end if;

   if p_ATTRIBUTE27 is not null then
      per_person_rec.ATTRIBUTE27     := p_ATTRIBUTE27;
   end if;

   if p_ATTRIBUTE28 is not null then
      per_person_rec.ATTRIBUTE28     := p_ATTRIBUTE28;
   end if;

   if p_ATTRIBUTE29 is not null then
      per_person_rec.ATTRIBUTE29     := p_ATTRIBUTE29;
   end if;

   if p_ATTRIBUTE30 is not null then
      per_person_rec.ATTRIBUTE30     := p_ATTRIBUTE30;
   end if;

   if p_ATTRIBUTE1 is not null then
      per_person_rec.ATTRIBUTE1     := p_ATTRIBUTE1;
   end if;

   if p_ATTRIBUTE2 is not null then
      per_person_rec.ATTRIBUTE2     := p_ATTRIBUTE2;
   end if;

   if p_ATTRIBUTE3 is not null then
      per_person_rec.ATTRIBUTE3     := p_ATTRIBUTE3;
   end if;

   if p_ATTRIBUTE4 is not null then
      per_person_rec.ATTRIBUTE4     := p_ATTRIBUTE4;
   end if;

   if p_ATTRIBUTE5 is not null then
      per_person_rec.ATTRIBUTE5     := p_ATTRIBUTE5;
   end if;

   if p_ATTRIBUTE6 is not null then
      per_person_rec.ATTRIBUTE6     := p_ATTRIBUTE6;
   end if;

   if p_ATTRIBUTE7 is not null then
      per_person_rec.ATTRIBUTE7     := p_ATTRIBUTE7;
   end if;

   if p_ATTRIBUTE8 is not null then
      per_person_rec.ATTRIBUTE8     := p_ATTRIBUTE8;
   end if;

   if p_ATTRIBUTE9 is not null then
      per_person_rec.ATTRIBUTE9     := p_ATTRIBUTE9;
   end if;

   if p_ATTRIBUTE10 is not null then
      per_person_rec.ATTRIBUTE10     := p_ATTRIBUTE10;
   end if;

   if p_ATTRIBUTE11 is not null then
      per_person_rec.ATTRIBUTE11     := p_ATTRIBUTE11;
   end if;

   if p_ATTRIBUTE12 is not null then
      per_person_rec.ATTRIBUTE12     := p_ATTRIBUTE12;
   end if;

   if p_ATTRIBUTE13 is not null then
      per_person_rec.ATTRIBUTE13     := p_ATTRIBUTE13;
   end if;

   if p_ATTRIBUTE14 is not null then
      per_person_rec.ATTRIBUTE14     := p_ATTRIBUTE14;
   end if;

   if p_ATTRIBUTE15 is not null then
      per_person_rec.ATTRIBUTE15     := p_ATTRIBUTE15;
   end if;

   if p_ATTRIBUTE17 is not null then
      per_person_rec.ATTRIBUTE17     := p_ATTRIBUTE17;
   end if;

   --
   -- Call the API - hr_person_api.update_person
   --
   --
   Get_DT_Upd_Mode
       (p_effective_date        => p_effective_date,
        p_base_table_name       => 'PER_ALL_PEOPLE_F',
        p_base_key_column       => 'PERSON_ID',
        p_base_key_value        => per_person_rec.person_id,
        p_mode                  => l_upd_mode);
   --
  hr_person_api.update_person
   (p_validate                     => FALSE
   ,p_effective_date               => p_effective_date
   ,p_datetrack_update_mode        => l_upd_mode -- 'CORRECTION' --  'UPDATE_OVERRIDE'
   ,p_person_id                    => per_person_rec.person_id
   ,p_object_version_number        => per_person_rec.object_version_number
   ,p_person_type_id               => per_person_rec.person_type_id
   ,p_last_name                    => per_person_rec.last_name
   ,p_applicant_number             => per_person_rec.applicant_number
   ,p_comments                     => null
   ,p_date_employee_data_verified  => per_person_rec.date_employee_data_verified
   ,p_date_of_birth                => per_person_rec.date_of_birth
   ,p_email_address                => per_person_rec.email_address
   ,p_employee_number              => per_person_rec.employee_number
   ,p_expense_check_send_to_addres => per_person_rec.expense_check_send_to_address
   ,p_first_name                   => per_person_rec.first_name
   ,p_known_as                     => per_person_rec.known_as
   ,p_marital_status               => per_person_rec.marital_status
   ,p_middle_names                 => per_person_rec.middle_names
   ,p_nationality                  => per_person_rec.nationality
   ,p_national_identifier          => per_person_rec.national_identifier
   ,p_previous_last_name           => per_person_rec.previous_last_name
   ,p_registered_disabled_flag     => per_person_rec.registered_disabled_flag
   ,p_sex                          => per_person_rec.sex
   ,p_title                        => per_person_rec.title
   ,p_vendor_id                    => per_person_rec.vendor_id
   ,p_work_telephone               => per_person_rec.work_telephone
   ,p_attribute_category           => per_person_rec.attribute_category
   ,p_attribute1                   => per_person_rec.attribute1
   ,p_attribute2                   => per_person_rec.attribute2
   ,p_attribute3                   => per_person_rec.attribute3
   ,p_attribute4                   => per_person_rec.attribute4
   ,p_attribute5                   => per_person_rec.attribute5
   ,p_attribute6                   => per_person_rec.attribute6
   ,p_attribute7                   => per_person_rec.attribute7
   ,p_attribute8                   => per_person_rec.attribute8
   ,p_attribute9                   => per_person_rec.attribute9
   ,p_attribute10                   => per_person_rec.attribute10
   ,p_attribute11                   => per_person_rec.attribute11
   ,p_attribute12                   => per_person_rec.attribute12
   ,p_attribute13                   => per_person_rec.attribute13
   ,p_attribute14                   => per_person_rec.attribute14
   ,p_attribute15                   => per_person_rec.attribute15
   ,p_attribute16                   => per_person_rec.attribute16
   ,p_attribute17                   => per_person_rec.attribute17
   ,p_attribute18                   => per_person_rec.attribute18
   ,p_attribute19                   => per_person_rec.attribute19
   ,p_attribute20                   => per_person_rec.attribute20
   ,p_attribute21                   => per_person_rec.attribute21
   ,p_attribute22                   => per_person_rec.attribute22
   ,p_attribute23                   => per_person_rec.attribute23
   ,p_attribute24                   => per_person_rec.attribute24
   ,p_attribute25                   => per_person_rec.attribute25
   ,p_attribute26                   => per_person_rec.attribute26
   ,p_attribute27                   => per_person_rec.attribute27
   ,p_attribute28                   => per_person_rec.attribute28
   ,p_attribute29                   => per_person_rec.attribute29
   ,p_attribute30                   => per_person_rec.attribute30
   ,p_per_information_category    => per_person_rec.per_information_category
   ,p_per_information1        => per_person_rec.per_information1
   ,p_per_information2        => per_person_rec.per_information2
   ,p_per_information3        => per_person_rec.per_information3
   ,p_per_information4        => per_person_rec.per_information4
   ,p_per_information5        => per_person_rec.per_information5
   ,p_per_information6        => per_person_rec.per_information6
   ,p_per_information7        => per_person_rec.per_information7
   ,p_per_information8        => per_person_rec.per_information8
   ,p_per_information9        => per_person_rec.per_information9
   ,p_per_information10        => per_person_rec.per_information10
   ,p_per_information11        => per_person_rec.per_information11
   ,p_per_information12        => per_person_rec.per_information12
   ,p_per_information13        => per_person_rec.per_information13
   ,p_per_information14        => per_person_rec.per_information14
   ,p_per_information15        => per_person_rec.per_information15
   ,p_per_information16        => per_person_rec.per_information16
   ,p_per_information17        => per_person_rec.per_information17
   ,p_per_information18        => per_person_rec.per_information18
   ,p_per_information19        => per_person_rec.per_information19
   ,p_per_information20        => per_person_rec.per_information20
   ,p_per_information21        => per_person_rec.per_information21
   ,p_per_information22        => per_person_rec.per_information22
   ,p_per_information23        => per_person_rec.per_information23
   ,p_per_information24        => per_person_rec.per_information24
   ,p_per_information25        => per_person_rec.per_information25
   ,p_per_information26        => per_person_rec.per_information26
   ,p_per_information27        => per_person_rec.per_information27
   ,p_per_information28        => per_person_rec.per_information28
   ,p_per_information29        => per_person_rec.per_information29
   ,p_per_information30        => per_person_rec.per_information30
   ,p_date_of_death                  => per_person_rec.date_of_death
   ,p_background_check_status        => per_person_rec.background_check_status
   ,p_background_date_check          => per_person_rec.background_date_check
   ,p_blood_type                     => per_person_rec.blood_type
   ,p_correspondence_language        => per_person_rec.correspondence_language
   ,p_fast_path_employee             => per_person_rec.fast_path_employee
   ,p_fte_capacity                   => per_person_rec.fte_capacity
   ,p_hold_applicant_date_until      => per_person_rec.hold_applicant_date_until
   ,p_honors                         => per_person_rec.honors
   ,p_internal_location              => per_person_rec.internal_location
   ,p_last_medical_test_by           => per_person_rec.last_medical_test_by
   ,p_last_medical_test_date         => per_person_rec.last_medical_test_date
   ,p_mailstop                       => per_person_rec.mailstop
   ,p_office_number                  => per_person_rec.office_number
   ,p_on_military_service            => per_person_rec.on_military_service
   ,p_pre_name_adjunct               => per_person_rec.pre_name_adjunct
   ,p_projected_start_date           => per_person_rec.projected_start_date
   ,p_rehire_authorizor              => per_person_rec.rehire_authorizor
   ,p_rehire_recommendation          => per_person_rec.rehire_recommendation
   ,p_resume_exists                  => per_person_rec.resume_exists
   ,p_resume_last_updated            => per_person_rec.resume_last_updated
   ,p_second_passport_exists         => per_person_rec.second_passport_exists
   ,p_student_status                 => per_person_rec.student_status
   ,p_work_schedule                  => per_person_rec.work_schedule
   ,p_rehire_reason                  => per_person_rec.rehire_reason
   ,p_suffix                         => per_person_rec.suffix
   ,p_benefit_group_id               => per_person_rec.benefit_group_id
   ,P_RECEIPT_OF_DEATH_CERT_DATE     => per_person_rec.RECEIPT_OF_DEATH_CERT_DATE
   ,P_COORD_BEN_MED_PLN_NO           => per_person_rec.COORD_BEN_MED_PLN_NO
   ,P_COORD_BEN_NO_CVG_FLAG          => per_person_rec.COORD_BEN_NO_CVG_FLAG
   ,P_USES_TOBACCO_FLAG              => per_person_rec.USES_TOBACCO_FLAG
   ,P_DPDNT_ADOPTION_DATE            => per_person_rec.DPDNT_ADOPTION_DATE
   ,P_DPDNT_VLNTRY_SVCE_FLAG         => per_person_rec.DPDNT_VLNTRY_SVCE_FLAG
   ,P_ORIGINAL_DATE_OF_HIRE          => per_person_rec.ORIGINAL_DATE_OF_HIRE
   ,p_effective_start_date           => l_effective_start_date
   ,p_effective_end_date             => l_effective_end_date
   ,p_full_name                      => l_full_name
   ,p_comment_id                     => l_comment_id
   ,p_name_combination_warning       => l_name_combination_warning
   ,p_assign_payroll_warning         => l_assign_payroll_warning
   ,P_ORIG_HIRE_WARNING              => l_ORIG_HIRE_WARNING
   );
   --
   hr_utility.set_location(' Leaving: WATIF_ALL_PEOPLE_F_API' , 10);
end;





procedure WATIF_PERIODS_OF_SERVICE_API(
   p_person_id                      in  number
  ,p_per_object_version_number      in  number
  ,p_DATE_START                     in  date
  ,p_LEAVING_REASON                 in  varchar2
  ,p_ADJUSTED_SVC_DATE              in  date
  ,p_ACTUAL_TERMINATION_DATE        in  date
  ,p_FINAL_PROCESS_DATE		    in  date
  ,p_ATTRIBUTE1                     in  VARCHAR2
  ,p_ATTRIBUTE2                     in  VARCHAR2
  ,p_ATTRIBUTE3                     in  VARCHAR2
  ,p_ATTRIBUTE4                     in  VARCHAR2
  ,p_ATTRIBUTE5                     in  VARCHAR2
  ,p_ATTRIBUTE6                     in  VARCHAR2
  ,p_ATTRIBUTE7                     in  VARCHAR2
  ,p_ATTRIBUTE8                     in  VARCHAR2
  ,p_ATTRIBUTE9                     in  VARCHAR2
  ,p_ATTRIBUTE10                    in  VARCHAR2
  ,p_ATTRIBUTE11                    in  VARCHAR2
  ,p_ATTRIBUTE12                    in  VARCHAR2
  ,p_ATTRIBUTE13                    in  VARCHAR2
  ,p_ATTRIBUTE14                    in  VARCHAR2
  ,p_ATTRIBUTE15                    in  VARCHAR2
  ,p_ATTRIBUTE16                    in  VARCHAR2
  ,p_ATTRIBUTE17                    in  VARCHAR2
  ,p_ATTRIBUTE18                    in  VARCHAR2
  ,p_ATTRIBUTE19                    in  VARCHAR2
  ,p_ATTRIBUTE20                    in  VARCHAR2
  ,p_business_group_id              in  number
  ,p_effective_date                 in  date
  ) is
  --
  cursor c_per is
    select object_version_number
    from per_people_f
    where person_id = p_person_id
    and p_effective_date between effective_start_date and
                                 effective_end_date;
  --
  cursor c_service is
   select
       rowid, per_periods_of_service.*
   from per_periods_of_service
    where   person_id = p_person_id
    order by DATE_START;-- and
    --            p_effective_date between nvl(DATE_START, p_effective_date)
    --                       and     nvl(DATE_END, p_effective_date);
  --
  per_service_rec c_service%rowtype;
  --
  l_assignment_id                    number;
  l_asg_object_version_number        number;
  l_per_object_version_number        number  := p_per_object_version_number;
  l_per_effective_start_date         date;
  l_per_effective_end_date           date;
  l_assignment_sequence              number;
  l_assignment_number                varchar2(1000);
  l_rehire_reason                    varchar2(1000) := null;
  l_assign_payroll_warning           boolean;
  --
  l_supervisor_warning               boolean;
  l_event_warning                    boolean;
  l_interview_warning                boolean;
  l_review_warning                   boolean;
  l_recruiter_warning                boolean;
  l_dod_warning                      boolean;
  l_asg_future_changes_warning       boolean;
  l_entries_changed_warning          varchar2(1000);
  l_pay_proposal_warning             boolean;
  l_last_standard_process_date       date;
  l_count_payrolls 		     number;
  l_final_process_date		     date;
  --
  l_s_final_process_date              date;
  l_s_actual_termination_date         date;
  l_c_assignment_status_type_id       number;
  l_d_status                          varchar2(1000);
  l_requery_required                  varchar2(1) :=  'N';
  L_DODWARNING                        varchar2(1);
  --
begin
   --
   hr_utility.set_location(' Entering: WATIF_PERIODS_OF_SERVICE_API' , 10);
   hr_utility.set_location('p_ADJUSTED_SVC_DATE ' || p_ADJUSTED_SVC_DATE , 11);
   hr_utility.set_location('p_ACTUAL_TERMINATION_DATE ' ||p_ACTUAL_TERMINATION_DATE , 11);
   hr_utility.set_location('p_LEAVING_REASON ' ||p_LEAVING_REASON , 11);
   --
   If p_DATE_START is null and p_LEAVING_REASON is null and
      p_ADJUSTED_SVC_DATE is null and
      p_ATTRIBUTE1        is null and
      p_ATTRIBUTE2        is null and
      p_ATTRIBUTE3        is null and
      p_ATTRIBUTE4        is null and
      p_ATTRIBUTE5        is null and
      p_ATTRIBUTE6        is null and
      p_ATTRIBUTE7        is null and
      p_ATTRIBUTE8        is null and
      p_ATTRIBUTE9        is null and
      p_ATTRIBUTE10       is null and
      p_ATTRIBUTE11       is null and
      p_ATTRIBUTE12       is null and
      p_ATTRIBUTE13       is null and
      p_ATTRIBUTE14       is null and
      p_ATTRIBUTE15       is null and
      p_ATTRIBUTE16       is null and
      p_ATTRIBUTE17       is null and
      p_ATTRIBUTE18       is null and
      p_ATTRIBUTE19       is null and
      p_ATTRIBUTE20       is null and
      p_FINAL_PROCESS_DATE is null and
      p_ACTUAL_TERMINATION_DATE   is null then
       --
       fnd_message.set_name('BEN','BEN_91447_ALL_NULL');
       fnd_message.raise_error;
       --
   End If;


   if  p_adjusted_svc_date  is not null then
     -- get the object_version number for the person.
     open c_per;
     fetch c_per into l_per_object_version_number;
     close c_per;
     --
     hr_utility.set_location(' l_per_object_version_number = '||
                               to_char(l_per_object_version_number) , 10);
     -- Re hire case
     hr_employee_api.re_hire_ex_employee
      (p_validate                      => FALSE
      ,p_hire_date                     => p_effective_date
      ,p_person_id                     => p_person_id
      ,p_per_object_version_number     => l_per_object_version_number
      -- ,p_person_type_id                => hr_api.g_number
      ,p_rehire_reason                 => null
      ,p_assignment_id                 => l_assignment_id
      ,p_asg_object_version_number     => l_asg_object_version_number
      ,p_per_effective_start_date      => l_per_effective_start_date
      ,p_per_effective_end_date        => l_per_effective_end_date
      ,p_assignment_sequence           => l_assignment_sequence
      ,p_assignment_number             => l_assignment_number
      ,p_assign_payroll_warning        => l_assign_payroll_warning
      );
   elsif p_LEAVING_REASON is not null and
         p_ACTUAL_TERMINATION_DATE is not null
   then
      -- Termination case.
      --
      open c_service;
      fetch c_service into per_service_rec;
      if  c_service%notfound Then
          Close c_service;
          --
          -- Periods of Service Record is  Not found so error.
          --
          fnd_message.set_name('BEN','BEN_91445_NO_PERIODS_SERVICE');
          fnd_message.raise_error;
          --
      End If;
      Close c_service;
      --
      -- 9999 ????what to do with p_LEAVING_REASON as not used in the api call.
      --
      -- Bug : 5142 :  This API call is not creating the potential
      -- so call the procedure which is called from the form - PERWSTEM
      --
      /* hr_ex_employee_api.actual_termination_emp
        (p_validate                           => FALSE
           ,p_effective_date                => p_effective_date
           ,p_period_of_service_id          => per_service_rec.period_of_service_id
           ,p_object_version_number         => per_service_rec.object_version_number
           ,p_actual_termination_date       => p_ACTUAL_TERMINATION_DATE
           ,p_last_standard_process_date    => l_last_standard_process_date
           -- ,p_person_type_id                in     number   default hr_api.g_number
           -- ,p_assignment_status_type_id     in     number   default hr_api.g_number
           ,p_supervisor_warning            => l_supervisor_warning
           ,p_event_warning                 => l_event_warning
           ,p_interview_warning             => l_interview_warning
           ,p_review_warning                => l_review_warning
           ,p_recruiter_warning             => l_recruiter_warning
           ,p_asg_future_changes_warning    => l_asg_future_changes_warning
           ,p_entries_changed_warning       => l_entries_changed_warning
           ,p_pay_proposal_warning          => l_pay_proposal_warning
           ,p_dod_warning                   => l_dod_warning
           );
      */
      --
      --Bug 2943163

      per_periods_of_service_pkg.get_final_dates(p_period_of_service_id =>per_service_rec.PERIOD_OF_SERVICE_ID
                                               ,p_person_id => per_service_rec.PERSON_ID
                                               ,p_actual_termination_date => P_ACTUAL_TERMINATION_DATE
                                               ,p_no_payrolls => l_count_payrolls
                                               ,p_final_process_date => l_final_process_date
                                               ,p_last_standard_process_date =>l_last_standard_process_date );

       --Bug 2943163

      per_periods_of_service_pkg.update_term_row (
       p_row_id                         => rowidtochar(per_service_rec.rowid)
      ,p_period_of_service_id           => per_service_rec.PERIOD_OF_SERVICE_ID
      ,p_business_group_id              => per_service_rec.BUSINESS_GROUP_ID
      ,p_person_id                      => per_service_rec.PERSON_ID
      ,p_date_start                     => per_service_rec.DATE_START
      ,p_termination_accepted_per_id    => per_service_rec.TERMINATION_ACCEPTED_PERSON_ID
      ,p_accepted_termination_date      => per_service_rec.ACCEPTED_TERMINATION_DATE
      ,p_actual_termination_date        => p_ACTUAL_TERMINATION_DATE
      ,p_comments                       => per_service_rec.COMMENTS
      ,p_final_process_date             => nvl(p_FINAL_PROCESS_DATE, l_final_process_date)
      ,p_last_standard_process_date     => nvl(per_service_rec.LAST_STANDARD_PROCESS_DATE, l_last_standard_process_date)
      ,p_leaving_reason                 => p_LEAVING_REASON -- per_service_rec.LEAVING_REASON
      ,p_notified_termination_date      => per_service_rec.NOTIFIED_TERMINATION_DATE
      ,p_projected_termination_date     => per_service_rec.PROJECTED_TERMINATION_DATE
      ,p_request_id                     => per_service_rec.REQUEST_ID
      ,p_program_application_id         => per_service_rec.PROGRAM_APPLICATION_ID
      ,p_program_id                     => per_service_rec.PROGRAM_ID
      ,p_program_update_date            => per_service_rec.PROGRAM_UPDATE_DATE
      ,p_attribute_category             => per_service_rec.ATTRIBUTE_CATEGORY
      ,p_attribute1                     => per_service_rec.ATTRIBUTE1
      ,p_attribute2                     => per_service_rec.ATTRIBUTE2
      ,p_attribute3                     => per_service_rec.ATTRIBUTE3
      ,p_attribute4                     => per_service_rec.ATTRIBUTE4
      ,p_attribute5                     => per_service_rec.ATTRIBUTE5
      ,p_attribute6                     => per_service_rec.ATTRIBUTE6
      ,p_attribute7                     => per_service_rec.ATTRIBUTE7
      ,p_attribute8                     => per_service_rec.ATTRIBUTE8
      ,p_attribute9                     => per_service_rec.ATTRIBUTE9
      ,p_attribute10                    => per_service_rec.ATTRIBUTE10
      ,p_attribute11                    => per_service_rec.ATTRIBUTE11
      ,p_attribute12                    => per_service_rec.ATTRIBUTE12
      ,p_attribute13                    => per_service_rec.ATTRIBUTE13
      ,p_attribute14                    => per_service_rec.ATTRIBUTE14
      ,p_attribute15                    => per_service_rec.ATTRIBUTE15
      ,p_attribute16                    => per_service_rec.ATTRIBUTE16
      ,p_attribute17                    => per_service_rec.ATTRIBUTE17
      ,p_attribute18                    => per_service_rec.ATTRIBUTE18
      ,p_attribute19                    => per_service_rec.ATTRIBUTE19
      ,p_attribute20                    => per_service_rec.ATTRIBUTE20
      ,p_initiate_cancellation          => null -- per_service_rec.INITIATE_CANCELLATION
      ,p_s_final_process_date           => l_s_final_process_date
      ,p_s_actual_termination_date      => l_s_actual_termination_date
      ,p_c_assignment_status_type_id    => l_c_assignment_status_type_id
      ,p_d_status                       => l_d_status
      ,p_requery_required               => l_requery_required -- 'N' -- 999 IO
      ,p_clear_details                  => 'N'
      ,p_legislation_code               => 'US'
      ,p_pds_information_category  => per_service_rec.PDS_INFORMATION_CATEGORY
      ,p_pds_information1          => per_service_rec.PDS_INFORMATION1
      ,p_pds_information2          => per_service_rec.PDS_INFORMATION2
      ,p_pds_information3          => per_service_rec.PDS_INFORMATION3
      ,p_pds_information4          => per_service_rec.PDS_INFORMATION4
      ,p_pds_information5          => per_service_rec.PDS_INFORMATION5
      ,p_pds_information6          => per_service_rec.PDS_INFORMATION6
      ,p_pds_information7          => per_service_rec.PDS_INFORMATION7
      ,p_pds_information8          => per_service_rec.PDS_INFORMATION8
      ,p_pds_information9          => per_service_rec.PDS_INFORMATION9
      ,p_pds_information10         => per_service_rec.PDS_INFORMATION10
      ,p_pds_information11         => per_service_rec.PDS_INFORMATION11
      ,p_pds_information12         => per_service_rec.PDS_INFORMATION12
      ,p_pds_information13         => per_service_rec.PDS_INFORMATION13
      ,p_pds_information14         => per_service_rec.PDS_INFORMATION14
      ,p_pds_information15         => per_service_rec.PDS_INFORMATION15
      ,p_pds_information16         => per_service_rec.PDS_INFORMATION16
      ,p_pds_information17         => per_service_rec.PDS_INFORMATION17
      ,p_pds_information18         => per_service_rec.PDS_INFORMATION18
      ,p_pds_information19         => per_service_rec.PDS_INFORMATION19
      ,p_pds_information20         => per_service_rec.PDS_INFORMATION20
      ,p_pds_information21         => per_service_rec.PDS_INFORMATION21
      ,p_pds_information22         => per_service_rec.PDS_INFORMATION22
      ,p_pds_information23         => per_service_rec.PDS_INFORMATION23
      ,p_pds_information24         => per_service_rec.PDS_INFORMATION24
      ,p_pds_information25         => per_service_rec.PDS_INFORMATION25
      ,p_pds_information26         => per_service_rec.PDS_INFORMATION26
      ,p_pds_information27         => per_service_rec.PDS_INFORMATION27
      ,p_pds_information28         => per_service_rec.PDS_INFORMATION28
      ,p_pds_information29         => per_service_rec.PDS_INFORMATION29
      ,p_pds_information30         => per_service_rec.PDS_INFORMATION30
      ,p_adjusted_svc_date         => per_service_rec.ADJUSTED_SVC_DATE
      ,p_dodwarning                => l_dodwarning);
      --
   else
     -- Unpaid LOA.
     open c_service;
     fetch c_service into per_service_rec;
     if  c_service%notfound Then
         Close c_service;
         --
         -- Periods of Service Record is  Not found so error.
         --
         fnd_message.set_name('BEN','BEN_91445_NO_PERIODS_SERVICE');
         fnd_message.raise_error;
         --
     End If;
     Close c_service;
     --
     --
     if p_date_start is not null then
        per_service_rec.date_start    := p_date_start;
     end if;
     --
     --
     if p_LEAVING_REASON is not null then
        per_service_rec.LEAVING_REASON    := p_LEAVING_REASON;
     end if;
     --
     --
     if p_ADJUSTED_SVC_DATE is not null then
        per_service_rec.ADJUSTED_SVC_DATE    := p_ADJUSTED_SVC_DATE;
     end if;
     --
     --
     if p_ACTUAL_TERMINATION_DATE is not null then
        per_service_rec.ACTUAL_TERMINATION_DATE    := p_ACTUAL_TERMINATION_DATE;
     end if;

     if p_FINAL_PROCESS_DATE is not null then
        per_service_rec.FINAL_PROCESS_DATE := p_FINAL_PROCESS_DATE;
     end if;

     if p_ATTRIBUTE1 is not null then
        per_service_rec.ATTRIBUTE1     := p_ATTRIBUTE1;
     end if;

     if p_ATTRIBUTE2 is not null then
        per_service_rec.ATTRIBUTE2     := p_ATTRIBUTE2;
     end if;

     if p_ATTRIBUTE3 is not null then
        per_service_rec.ATTRIBUTE3     := p_ATTRIBUTE3;
     end if;

     if p_ATTRIBUTE4 is not null then
        per_service_rec.ATTRIBUTE4     := p_ATTRIBUTE4;
     end if;

     if p_ATTRIBUTE5 is not null then
        per_service_rec.ATTRIBUTE5     := p_ATTRIBUTE5;
     end if;

     if p_ATTRIBUTE6 is not null then
        per_service_rec.ATTRIBUTE6     := p_ATTRIBUTE6;
     end if;

     if p_ATTRIBUTE7 is not null then
        per_service_rec.ATTRIBUTE7     := p_ATTRIBUTE7;
     end if;

     if p_ATTRIBUTE8 is not null then
        per_service_rec.ATTRIBUTE8     := p_ATTRIBUTE8;
     end if;

     if p_ATTRIBUTE9 is not null then
        per_service_rec.ATTRIBUTE9     := p_ATTRIBUTE9;
     end if;

     if p_ATTRIBUTE10 is not null then
        per_service_rec.ATTRIBUTE10     := p_ATTRIBUTE10;
     end if;

      if p_ATTRIBUTE11 is not null then
        per_service_rec.ATTRIBUTE11     := p_ATTRIBUTE11;
     end if;

     if p_ATTRIBUTE12 is not null then
        per_service_rec.ATTRIBUTE12     := p_ATTRIBUTE12;
     end if;

     if p_ATTRIBUTE13 is not null then
        per_service_rec.ATTRIBUTE13     := p_ATTRIBUTE13;
     end if;

     if p_ATTRIBUTE14 is not null then
        per_service_rec.ATTRIBUTE14     := p_ATTRIBUTE14;
     end if;

     if p_ATTRIBUTE15 is not null then
        per_service_rec.ATTRIBUTE15     := p_ATTRIBUTE15;
     end if;

     if p_ATTRIBUTE16 is not null then
        per_service_rec.ATTRIBUTE16     := p_ATTRIBUTE16;
     end if;

     if p_ATTRIBUTE17 is not null then
        per_service_rec.ATTRIBUTE17     := p_ATTRIBUTE17;
     end if;

     if p_ATTRIBUTE18 is not null then
        per_service_rec.ATTRIBUTE18     := p_ATTRIBUTE18;
     end if;

     if p_ATTRIBUTE19 is not null then
        per_service_rec.ATTRIBUTE19     := p_ATTRIBUTE19;
     end if;

     if p_ATTRIBUTE20 is not null then
        per_service_rec.ATTRIBUTE20     := p_ATTRIBUTE20;
     end if;
     --
     -- Call the API -
     --
     PER_PERIODS_OF_SERVICE_PKG.update_row(
       p_row_id                         => rowidtochar(per_service_rec.rowid)
      ,p_period_of_service_id           => per_service_rec.period_of_service_id
      ,p_business_group_id              => per_service_rec.business_group_id
      ,p_person_id                      => per_service_rec.person_id
      ,p_date_start                     => per_service_rec.date_start
      ,p_termination_accepted_per_id    => per_service_rec.termination_accepted_person_id
      ,p_accepted_termination_date      => per_service_rec.accepted_termination_date
      ,p_actual_termination_date        => per_service_rec.actual_termination_date
      ,p_comments                       => per_service_rec.comments
      ,p_final_process_date             => per_service_rec.final_process_date
      ,p_last_standard_process_date     => per_service_rec.last_standard_process_date
      ,p_leaving_reason                 => per_service_rec.leaving_reason
      ,p_notified_termination_date      => per_service_rec.notified_termination_date
      ,p_projected_termination_date     => per_service_rec.projected_termination_date
      ,p_request_id                     => per_service_rec.request_id
      ,p_program_application_id         => per_service_rec.program_application_id
      ,p_program_id                     => per_service_rec.program_id
      ,p_program_update_date            => per_service_rec.program_update_date
      ,p_attribute_category             => per_service_rec.attribute_category
      ,p_attribute1                     => per_service_rec.attribute1
      ,p_attribute2                     => per_service_rec.attribute2
      ,p_attribute3                     => per_service_rec.attribute3
      ,p_attribute4                     => per_service_rec.attribute4
      ,p_attribute5                     => per_service_rec.attribute5
      ,p_attribute6                     => per_service_rec.attribute6
      ,p_attribute7                     => per_service_rec.attribute7
      ,p_attribute8                     => per_service_rec.attribute8
      ,p_attribute9                     => per_service_rec.attribute9
      ,p_attribute10                    => per_service_rec.attribute10
      ,p_attribute11                    => per_service_rec.attribute11
      ,p_attribute12                    => per_service_rec.attribute12
      ,p_attribute13                    => per_service_rec.attribute13
      ,p_attribute14                    => per_service_rec.attribute14
      ,p_attribute15                    => per_service_rec.attribute15
      ,p_attribute16                    => per_service_rec.attribute16
      ,p_attribute17                    => per_service_rec.attribute17
      ,p_attribute18                    => per_service_rec.attribute18
      ,p_attribute19                    => per_service_rec.attribute19
      ,p_attribute20                    => per_service_rec.attribute20
      ,p_ADJUSTED_SVC_DATE              => per_service_rec.ADJUSTED_SVC_DATE
      ,p_pds_information_category       => per_service_rec.PDS_INFORMATION_CATEGORY
      ,p_pds_information1               => per_service_rec.PDS_INFORMATION1
      ,p_pds_information2               => per_service_rec.PDS_INFORMATION2
      ,p_pds_information3               => per_service_rec.PDS_INFORMATION3
      ,p_pds_information4               => per_service_rec.PDS_INFORMATION4
      ,p_pds_information5               => per_service_rec.PDS_INFORMATION5
      ,p_pds_information6               => per_service_rec.PDS_INFORMATION6
      ,p_pds_information7               => per_service_rec.PDS_INFORMATION7
      ,p_pds_information8               => per_service_rec.PDS_INFORMATION8
      ,p_pds_information9               => per_service_rec.PDS_INFORMATION9
      ,p_pds_information10              => per_service_rec.PDS_INFORMATION10
      ,p_pds_information11              => per_service_rec.PDS_INFORMATION11
      ,p_pds_information12              => per_service_rec.PDS_INFORMATION12
      ,p_pds_information13              => per_service_rec.PDS_INFORMATION13
      ,p_pds_information14              => per_service_rec.PDS_INFORMATION14
      ,p_pds_information15              => per_service_rec.PDS_INFORMATION15
      ,p_pds_information16              => per_service_rec.PDS_INFORMATION16
      ,p_pds_information17              => per_service_rec.PDS_INFORMATION17
      ,p_pds_information18              => per_service_rec.PDS_INFORMATION18
      ,p_pds_information19              => per_service_rec.PDS_INFORMATION19
      ,p_pds_information20              => per_service_rec.PDS_INFORMATION20
      ,p_pds_information21              => per_service_rec.PDS_INFORMATION21
      ,p_pds_information22              => per_service_rec.PDS_INFORMATION22
      ,p_pds_information23              => per_service_rec.PDS_INFORMATION23
      ,p_pds_information24              => per_service_rec.PDS_INFORMATION24
      ,p_pds_information25              => per_service_rec.PDS_INFORMATION25
      ,p_pds_information26              => per_service_rec.PDS_INFORMATION26
      ,p_pds_information27              => per_service_rec.PDS_INFORMATION27
      ,p_pds_information28              => per_service_rec.PDS_INFORMATION28
      ,p_pds_information29              => per_service_rec.PDS_INFORMATION29
      ,p_pds_information30              => per_service_rec.PDS_INFORMATION30
     );
   end if;
   hr_utility.set_location(' Leaving: WATIF_PERIODS_OF_SERVICE_API' , 10);
   --
end;



procedure WATIF_PERSON_TYPE_USAGES_F_API(
   p_person_id                      in  number
  ,p_PERSON_TYPE_ID                 in varchar2
  ,p_business_group_id              in  number
  ,p_effective_date                 in  date
  ) is
  --
  per_per_usg_rec per_person_type_usages_f%rowtype;
  --
  cursor c_per_usg is
   select * from per_person_type_usages_f
    where   person_id = p_person_id  and
            p_effective_date between nvl(effective_start_date, p_effective_date)
                             and     nvl(effective_end_date, p_effective_date);
  --
  cursor c_get_per_typ is
   select pt.system_person_type, ptu.*
   from per_all_people_f per,
        per_person_types pt,
        per_person_type_usages_f ptu
   where per.person_id = p_person_id
     and per.person_type_id = pt.person_type_id
     and per.person_id = ptu.person_id
     and ptu.person_type_id = pt.person_type_id
     and p_effective_date between
                           nvl(ptu.effective_start_date, p_effective_date)
                           and nvl(ptu.effective_end_date, p_effective_date)
     and p_effective_date between
                           nvl(per.effective_start_date, p_effective_date)
                           and nvl(per.effective_end_date, p_effective_date);
  --
  cursor c_get_desired_per_typ is
   select pt.system_person_type
   from per_person_types pt
   where pt.person_type_id = p_person_type_id
     and pt.BUSINESS_GROUP_ID = p_BUSINESS_GROUP_ID
     and pt.ACTIVE_FLAG = 'Y';
  --
  l_sys_per_typ_rec                c_get_per_typ%rowtype;
  l_sys_per_typ                    varchar2(100);
  l_upd_mode                       varchar2(25);
  l_effective_start_date           date;
  l_effective_end_date             date;
  l_desired_per_typ                varchar2(100);
  --
  cursor c_service is
   select rowid, per_periods_of_service.*
   from per_periods_of_service
    where   person_id = p_person_id
    order by DATE_START;-- and
    --            p_effective_date between nvl(DATE_START, p_effective_date)
    --                       and     nvl(DATE_END, p_effective_date);
  --
  per_service_rec c_service%rowtype;
  --
  l_supervisor_warning               boolean;
  l_event_warning                    boolean;
  l_interview_warning                boolean;
  l_review_warning                   boolean;
  l_recruiter_warning                boolean;
  l_dod_warning                      boolean;
  l_asg_future_changes_warning       boolean;
  l_entries_changed_warning          varchar2(1000);
  l_pay_proposal_warning             boolean;
  l_last_standard_process_date       date;
  l_dummy_date                       date;
  l_dummy_num                        number;
  l_desired_per_typ_created          boolean := false;
  --
  --
  l_old_ptu_rec ben_ptu_ler.g_ptu_ler_rec;
  l_new_ptu_rec ben_ptu_ler.g_ptu_ler_rec;
  --
begin
  --
  hr_utility.set_location(' Entering: WATIF_PERSON_TYPE_USAGES_F_API' , 10);
  --
   If p_PERSON_TYPE_ID   is null then
       --
       fnd_message.set_name('BEN','BEN_91447_ALL_NULL');
       fnd_message.raise_error;
       --
   End If;
   --
   open c_per_usg;
   fetch c_per_usg into per_per_usg_rec;
   if  c_per_usg%notfound Then
       Close c_per_usg;
       --
       -- Person Usage Type Record is  Not found so error.
       --
       fnd_message.set_name('BEN','BEN_91446_NO_PER_USG');
       fnd_message.raise_error;
       --
   End If;
   Close c_per_usg;
   --
   -- Fixed 1558516
   --
   open c_get_per_typ;
   fetch c_get_per_typ into l_sys_per_typ_rec;
   close c_get_per_typ;
   l_sys_per_typ := l_sys_per_typ_rec.system_person_type;
   --
   -- As person type usage can't be directly updated
   -- we need to call the potential creation logic from here
   --
   l_old_ptu_rec.PERSON_ID := p_person_id;
   l_old_ptu_rec.BUSINESS_GROUP_ID := p_business_group_id;
   l_old_ptu_rec.PERSON_TYPE_ID := l_sys_per_typ_rec.PERSON_TYPE_ID;
   l_old_ptu_rec.PERSON_TYPE_USAGE_ID := l_sys_per_typ_rec.PERSON_TYPE_USAGE_ID;
   l_old_ptu_rec.EFFECTIVE_START_DATE := l_sys_per_typ_rec.EFFECTIVE_START_DATE;
   l_old_ptu_rec.EFFECTIVE_END_DATE := l_sys_per_typ_rec.EFFECTIVE_END_DATE;

   l_new_ptu_rec.PERSON_ID := p_person_id;
   l_new_ptu_rec.BUSINESS_GROUP_ID := p_business_group_id;
   l_new_ptu_rec.PERSON_TYPE_ID := p_person_type_id;
   l_new_ptu_rec.EFFECTIVE_START_DATE := p_effective_date;
   l_new_ptu_rec.EFFECTIVE_END_DATE := null;

   hr_utility.set_location('l_old_ptu_rec.PERSON_ID ' || l_old_ptu_rec.PERSON_ID, 9999);
   hr_utility.set_location('l_old_ptu_rec.BUSINESS_GROUP_ID ' || l_old_ptu_rec.BUSINESS_GROUP_ID, 9999);
   hr_utility.set_location('l_old_ptu_rec.PERSON_TYPE_ID ' || l_old_ptu_rec.PERSON_TYPE_ID, 9999);
   hr_utility.set_location('l_old_ptu_rec.PERSON_TYPE_USAGE_ID ' || l_old_ptu_rec.PERSON_TYPE_USAGE_ID, 9999);
   hr_utility.set_location('l_old_ptu_rec.EFFECTIVE_START_DATE ' || l_old_ptu_rec.EFFECTIVE_START_DATE, 9999);
   hr_utility.set_location('l_old_ptu_rec.EFFECTIVE_END_DATE ' || l_old_ptu_rec.EFFECTIVE_START_DATE, 9999);

   hr_utility.set_location('l_new_ptu_rec.PERSON_ID ' || l_old_ptu_rec.PERSON_ID, 9999);
   hr_utility.set_location('l_new_ptu_rec.BUSINESS_GROUP_ID ' || l_old_ptu_rec.BUSINESS_GROUP_ID, 9999);
   hr_utility.set_location('l_new_ptu_rec.PERSON_TYPE_ID ' || l_old_ptu_rec.PERSON_TYPE_ID, 9999);
   hr_utility.set_location('l_new_ptu_rec.EFFECTIVE_START_DATE ' || l_old_ptu_rec.EFFECTIVE_START_DATE, 9999);
   hr_utility.set_location('l_new_ptu_rec.EFFECTIVE_END_DATE ' || l_old_ptu_rec.EFFECTIVE_END_DATE, 9999);

   ben_ptu_ler.ler_chk(p_old            => l_old_ptu_rec
                     ,p_new            => l_new_ptu_rec
                     ,p_effective_date => p_effective_date);

   open c_get_desired_per_typ;
   fetch c_get_desired_per_typ into l_desired_per_typ;
   close c_get_desired_per_typ;
   --
   if l_desired_per_typ = 'EX_EMP' then
         l_desired_per_typ_created := true;
   end if;
   --
   if not l_desired_per_typ_created  then
      --
--      hr_person_type_usage_api.CREATE_PERSON_TYPE_USAGE Bug 3374767
      hr_per_type_usage_internal.CREATE_PERSON_TYPE_USAGE
      (
        p_validate                       => FALSE
       ,p_person_id                      => p_person_id
       ,p_person_type_id                 => p_person_type_id
       ,p_effective_date                 => p_effective_date
       ,p_person_type_usage_id           => l_dummy_num
       ,p_object_version_number          => l_dummy_num
       ,p_effective_start_date           => l_dummy_date
       ,p_effective_end_date             => l_dummy_date
      );
      --
   end if;
   --
   hr_utility.set_location('Person system type = ' || l_sys_per_typ, 30);
   hr_utility.set_location('Desired Person type = ' || l_desired_per_typ, 31);
   --
   if p_PERSON_TYPE_ID is not null then
      per_per_usg_rec.PERSON_TYPE_ID    := p_PERSON_TYPE_ID;
   end if;
   --
   -- If person is employee and the desired person type is
   -- Ex-emp/ex-emp-apl/retiree then terminate the person.
   --
   if l_sys_per_typ = 'EMP'  and
      l_desired_per_typ in ('EX_EMP', 'EX_EMP_APL', 'RETIREE')
   then
      --
      open c_service;
      fetch c_service into per_service_rec;
      if  c_service%notfound Then
          Close c_service;
          --
          -- Periods of Service Record is  Not found so error.
          --
          fnd_message.set_name('BEN','BEN_91445_NO_PERIODS_SERVICE');
          fnd_message.raise_error;
          --
      End If;
      Close c_service;
      --
      hr_ex_employee_api.actual_termination_emp
        (p_validate                           => FALSE
           ,p_effective_date                => p_effective_date
           ,p_period_of_service_id          => per_service_rec.period_of_service_id
           ,p_object_version_number         => per_service_rec.object_version_number
           ,p_actual_termination_date       => p_effective_date
           ,p_last_standard_process_date    => l_last_standard_process_date
           -- ,p_person_type_id                => per_per_usg_rec.PERSON_TYPE_ID
           -- ,p_assignment_status_type_id     in     number   default hr_api.g_number
           ,p_supervisor_warning            => l_supervisor_warning
           ,p_event_warning                 => l_event_warning
           ,p_interview_warning             => l_interview_warning
           ,p_review_warning                => l_review_warning
           ,p_recruiter_warning             => l_recruiter_warning
           ,p_asg_future_changes_warning    => l_asg_future_changes_warning
           ,p_entries_changed_warning       => l_entries_changed_warning
           ,p_pay_proposal_warning          => l_pay_proposal_warning
           ,p_dod_warning                   => l_dod_warning
           );
      --
      if l_desired_per_typ = 'EX_EMP' then
         l_desired_per_typ_created := true;
      end if;
      --
   end if;
   --
   /*
   if not l_desired_per_typ_created  then
      --
      hr_person_type_usage_api.CREATE_PERSON_TYPE_USAGE
      (
        p_validate                       => FALSE
       ,p_person_id                      => p_person_id
       ,p_person_type_id                 => p_person_type_id
       ,p_effective_date                 => p_effective_date
       ,p_person_type_usage_id           => l_dummy_num
       ,p_object_version_number          => l_dummy_num
       ,p_effective_start_date           => l_dummy_date
       ,p_effective_end_date             => l_dummy_date
      );
      --
   end if;
   --
   */
   /*
   Get_DT_Upd_Mode
         (p_effective_date         => p_effective_date,
           p_base_table_name       => 'PER_PERSON_TYPE_USAGES_F',
           p_base_key_column       => 'PERSON_TYPE_USAGE_ID',
           p_base_key_value        => per_per_usg_rec.PERSON_TYPE_USAGE_ID,
           p_mode                  => l_upd_mode);
   --
   -- Call the API -
   --
   hr_utility.set_location('Before hr_person_type_usage_api ' ||
                           to_char(per_per_usg_rec.person_type_id), 10);
   hr_person_type_usage_api.update_person_type_usage
     (p_validate                       => FALSE
     ,p_person_type_usage_id           => per_per_usg_rec.PERSON_TYPE_USAGE_ID
     ,p_effective_date                 => p_effective_date
     ,p_datetrack_mode                 =>  'CORRECTION' -- always use correction as this api does't allow any other mode. l_upd_mode
     ,p_object_version_number          => per_per_usg_rec.object_version_number
     ,p_person_type_id                 => per_per_usg_rec.person_type_id
     ,p_attribute_category             => per_per_usg_rec.attribute_category
     ,p_attribute1                     => per_per_usg_rec.attribute1
     ,p_attribute2                     => per_per_usg_rec.attribute2
     ,p_attribute3                     => per_per_usg_rec.attribute3
     ,p_attribute4                     => per_per_usg_rec.attribute4
     ,p_attribute5                     => per_per_usg_rec.attribute5
     ,p_attribute6                     => per_per_usg_rec.attribute6
     ,p_attribute7                     => per_per_usg_rec.attribute7
     ,p_attribute8                     => per_per_usg_rec.attribute8
     ,p_attribute9                     => per_per_usg_rec.attribute9
     ,p_attribute10                    => per_per_usg_rec.attribute10
     ,p_attribute11                    => per_per_usg_rec.attribute11
     ,p_attribute12                    => per_per_usg_rec.attribute12
     ,p_attribute13                    => per_per_usg_rec.attribute13
     ,p_attribute14                    => per_per_usg_rec.attribute14
     ,p_attribute15                    => per_per_usg_rec.attribute15
     ,p_attribute16                    => per_per_usg_rec.attribute16
     ,p_attribute17                    => per_per_usg_rec.attribute17
     ,p_attribute18                    => per_per_usg_rec.attribute18
     ,p_attribute19                    => per_per_usg_rec.attribute19
     ,p_attribute20                    => per_per_usg_rec.attribute20
     ,p_effective_start_date           => l_effective_start_date
     ,p_effective_end_date             => l_effective_end_date
     );
   */
   --
   hr_utility.set_location(' Leaving: WATIF_PERSON_TYPE_USAGES_F_API' , 10);
   --
end;
--

 procedure WATIF_CRT_ORDR_API(
   p_person_id                      in  number
  ,p_pl_id                          in number
  ,p_CRT_ORDR_TYP_CD                in  varchar2
  ,p_APLS_PERD_STRTG_DT             in  date
  ,p_APLS_PERD_ENDG_DT              in  date
  ,p_business_group_id              in  number
  ,p_effective_date                 in  date
  ) is
  --
  cursor c_crt_ordr is
   select * from ben_crt_ordr
    where   person_id         = p_person_id  and
            crt_ordr_typ_cd   = p_crt_ordr_typ_cd and
            business_group_id = p_business_group_id and
            p_effective_date between apls_perd_strtg_dt
                             and     apls_perd_endg_dt;
  --
  per_crt_ordr_rec c_crt_ordr%rowtype;
  l_object_version_number          number;
  --
 begin
   --
   hr_utility.set_location(' Leaving: WATIF_CRT_ORDR_API' , 10);
   --
   If p_CRT_ORDR_TYP_CD is null and  p_APLS_PERD_STRTG_DT  is null and
      p_APLS_PERD_ENDG_DT is null and p_pl_id is null
   then
       --
       fnd_message.set_name('BEN','BEN_91447_ALL_NULL');
       fnd_message.raise_error;
       --
   End If;
   --
   open c_crt_ordr;
   fetch c_crt_ordr into per_crt_ordr_rec;
   --
   if p_crt_ordr_typ_cd is not null then
      per_crt_ordr_rec.crt_ordr_typ_cd    := p_crt_ordr_typ_cd;
   end if;
   --
   if p_apls_perd_strtg_dt is not null then
      per_crt_ordr_rec.apls_perd_strtg_dt    := p_apls_perd_strtg_dt;
   end if;
   --
   if p_apls_perd_endg_dt is not null then
      per_crt_ordr_rec.apls_perd_endg_dt    := p_apls_perd_endg_dt;
   end if;
   --
   if p_pl_id is not null then
      per_crt_ordr_rec.pl_id    := p_pl_id;
   end if;
   --
   if p_crt_ordr_typ_cd = 'QDRO' and per_crt_ordr_rec.qdro_pct is null then
      --
      -- If crt_ordr_typ_cd = 'QDRO' then qdro_pct is defaulted to 10
      -- 9999 : Does this assumption correct?
      --
      per_crt_ordr_rec.qdro_pct := 10;
      --
   end if;
   --
   if c_crt_ordr%notfound Then
      --
      -- Error out as pl_id can't be determined.
      --
    BEN_court_orders_API.create_court_orders
     (
        p_validate                       => false
       ,p_crt_ordr_id                    => per_crt_ordr_rec.CRT_ORDR_ID
       ,p_crt_ordr_typ_cd                => per_crt_ordr_rec.CRT_ORDR_TYP_CD
       ,p_apls_perd_endg_dt              => per_crt_ordr_rec.APLS_PERD_ENDG_DT
       ,p_apls_perd_strtg_dt             => per_crt_ordr_rec.APLS_PERD_STRTG_DT
       ,p_crt_ident                      => null
       ,p_description                    => null
       ,p_detd_qlfd_ordr_dt              => null
       ,p_issue_dt                       => null
       ,p_qdro_amt                       => null
       ,p_qdro_dstr_mthd_cd              => null
       ,p_qdro_pct                       => per_crt_ordr_rec.qdro_pct
       ,p_qdro_num_pymt_val              => null
       ,p_qdro_per_perd_cd               => null
       ,p_rcvd_dt                        => null
       ,p_uom                            => null
       ,p_crt_issng                      => null
       ,p_pl_id                          => p_pl_id
       ,p_pl_typ_id                      => null -- p_pl_typ_id
       ,p_person_id                      => p_person_id
       ,p_business_group_id              => p_business_group_id
       ,p_crt_attribute_category         => null
       ,p_crt_attribute1                 => null
       ,p_crt_attribute2                 => null
       ,p_crt_attribute3                 => null
       ,p_crt_attribute4                 => null
       ,p_crt_attribute5                 => null
       ,p_crt_attribute6                 => null
       ,p_crt_attribute7                 => null
       ,p_crt_attribute8                 => null
       ,p_crt_attribute9                 => null
       ,p_crt_attribute10                => null
       ,p_crt_attribute11                => null
       ,p_crt_attribute12                => null
       ,p_crt_attribute13                => null
       ,p_crt_attribute14                => null
       ,p_crt_attribute15                => null
       ,p_crt_attribute16                => null
       ,p_crt_attribute17                => null
       ,p_crt_attribute18                => null
       ,p_crt_attribute19                => null
       ,p_crt_attribute20                => null
       ,p_crt_attribute21                => null
       ,p_crt_attribute22                => null
       ,p_crt_attribute23                => null
       ,p_crt_attribute24                => null
       ,p_crt_attribute25                => null
       ,p_crt_attribute26                => null
       ,p_crt_attribute27                => null
       ,p_crt_attribute28                => null
       ,p_crt_attribute29                => null
       ,p_crt_attribute30                => null
       ,p_object_version_number          => l_object_version_number
       ,p_effective_date                 => p_effective_date
      );
      null;
   else
      --
      BEN_court_orders_API.update_court_orders
        (p_validate           => FALSE
        ,p_CRT_ORDR_ID        => per_crt_ordr_rec.CRT_ORDR_ID
        ,p_CRT_ORDR_TYP_CD    => per_crt_ordr_rec.CRT_ORDR_TYP_CD
        ,p_APLS_PERD_ENDG_DT  => per_crt_ordr_rec.APLS_PERD_ENDG_DT
        ,p_APLS_PERD_STRTG_DT => per_crt_ordr_rec.APLS_PERD_STRTG_DT
        ,p_CRT_IDENT          => per_crt_ordr_rec.CRT_IDENT
        ,p_DESCRIPTION        => per_crt_ordr_rec.DESCRIPTION
        ,p_DETD_QLFD_ORDR_DT  => per_crt_ordr_rec.DETD_QLFD_ORDR_DT
        ,p_ISSUE_DT           => per_crt_ordr_rec.ISSUE_DT
        ,p_QDRO_AMT           => per_crt_ordr_rec.QDRO_AMT
        ,p_QDRO_DSTR_MTHD_CD  => per_crt_ordr_rec.QDRO_DSTR_MTHD_CD
        ,p_QDRO_PCT           => per_crt_ordr_rec.QDRO_PCT
        ,p_QDRO_NUM_PYMT_VAL  => per_crt_ordr_rec.QDRO_NUM_PYMT_VAL
        ,p_QDRO_PER_PERD_CD   => per_crt_ordr_rec.QDRO_PER_PERD_CD
        ,p_RCVD_DT            => per_crt_ordr_rec.RCVD_DT
        ,p_UOM                => per_crt_ordr_rec.UOM
        ,p_CRT_ISSNG          => per_crt_ordr_rec.CRT_ISSNG
        ,p_PL_ID              => per_crt_ordr_rec.PL_ID
        ,p_PL_typ_id          => per_crt_ordr_rec.PL_typ_id
        ,p_PERSON_ID          => per_crt_ordr_rec.PERSON_ID
        ,p_BUSINESS_GROUP_ID  => per_crt_ordr_rec.BUSINESS_GROUP_ID
        ,p_CRT_ATTRIBUTE_CATEGORY => per_crt_ordr_rec.CRT_ATTRIBUTE_CATEGORY
        ,p_CRT_ATTRIBUTE1     => per_crt_ordr_rec.CRT_ATTRIBUTE1
        ,p_CRT_ATTRIBUTE2     => per_crt_ordr_rec.CRT_ATTRIBUTE2
        ,p_CRT_ATTRIBUTE3     => per_crt_ordr_rec.CRT_ATTRIBUTE3
        ,p_CRT_ATTRIBUTE4     => per_crt_ordr_rec.CRT_ATTRIBUTE4
        ,p_CRT_ATTRIBUTE5     => per_crt_ordr_rec.CRT_ATTRIBUTE5
        ,p_CRT_ATTRIBUTE6     => per_crt_ordr_rec.CRT_ATTRIBUTE6
        ,p_CRT_ATTRIBUTE7     => per_crt_ordr_rec.CRT_ATTRIBUTE7
        ,p_CRT_ATTRIBUTE8     => per_crt_ordr_rec.CRT_ATTRIBUTE8
        ,p_CRT_ATTRIBUTE9     => per_crt_ordr_rec.CRT_ATTRIBUTE9
        ,p_CRT_ATTRIBUTE10     => per_crt_ordr_rec.CRT_ATTRIBUTE10
        ,p_CRT_ATTRIBUTE11     => per_crt_ordr_rec.CRT_ATTRIBUTE11
        ,p_CRT_ATTRIBUTE12     => per_crt_ordr_rec.CRT_ATTRIBUTE12
        ,p_CRT_ATTRIBUTE13     => per_crt_ordr_rec.CRT_ATTRIBUTE13
        ,p_CRT_ATTRIBUTE14     => per_crt_ordr_rec.CRT_ATTRIBUTE14
        ,p_CRT_ATTRIBUTE15     => per_crt_ordr_rec.CRT_ATTRIBUTE15
        ,p_CRT_ATTRIBUTE16     => per_crt_ordr_rec.CRT_ATTRIBUTE16
        ,p_CRT_ATTRIBUTE17     => per_crt_ordr_rec.CRT_ATTRIBUTE17
        ,p_CRT_ATTRIBUTE18     => per_crt_ordr_rec.CRT_ATTRIBUTE18
        ,p_CRT_ATTRIBUTE19     => per_crt_ordr_rec.CRT_ATTRIBUTE19
        ,p_CRT_ATTRIBUTE20     => per_crt_ordr_rec.CRT_ATTRIBUTE20
        ,p_CRT_ATTRIBUTE21     => per_crt_ordr_rec.CRT_ATTRIBUTE21
        ,p_CRT_ATTRIBUTE22     => per_crt_ordr_rec.CRT_ATTRIBUTE22
        ,p_CRT_ATTRIBUTE23     => per_crt_ordr_rec.CRT_ATTRIBUTE23
        ,p_CRT_ATTRIBUTE24     => per_crt_ordr_rec.CRT_ATTRIBUTE24
        ,p_CRT_ATTRIBUTE25     => per_crt_ordr_rec.CRT_ATTRIBUTE25
        ,p_CRT_ATTRIBUTE26     => per_crt_ordr_rec.CRT_ATTRIBUTE26
        ,p_CRT_ATTRIBUTE27     => per_crt_ordr_rec.CRT_ATTRIBUTE27
        ,p_CRT_ATTRIBUTE28     => per_crt_ordr_rec.CRT_ATTRIBUTE28
        ,p_CRT_ATTRIBUTE29     => per_crt_ordr_rec.CRT_ATTRIBUTE29
        ,p_CRT_ATTRIBUTE30     => per_crt_ordr_rec.CRT_ATTRIBUTE30
        ,p_OBJECT_VERSION_NUMBER => l_OBJECT_VERSION_NUMBER
        ,p_effective_date       => p_effective_date);
        --
   end if;
   --
   hr_utility.set_location(' Leaving: WATIF_CRT_ORDR_API' , 80);
   --
 end;


 procedure WATIF_ELIG_CVRD_DPNT_F_API(
   p_person_id                      in  number
  ,p_CVG_STRT_DT                    in  date
  ,p_CVG_THRU_DT                    in  date
  ,p_EFFECTIVE_START_DATE           in  date
  ,p_EFFECTIVE_END_DATE             in  date
  ,p_business_group_id              in  number
  ,p_effective_date                 in  date
  ) is
  --
  cursor c_cvrd_dpnt is
   select * from ben_elig_cvrd_dpnt_f;
  /*  where   person_id    = p_person_id  and
            bnfts_bal_id = p_BNFTS_BAL_ID and
            business_group_id = p_business_group_id and
            p_effective_date between effective_start_date
                             and     effective_end_date; */
  --
  l_effective_start_date           date;
  l_effective_end_date             date;
  l_object_version_number          number;
  l_upd_mode                       varchar2(50);
  --
  cvrd_dpnt_rec ben_elig_cvrd_dpnt_f%rowtype;
  --
 begin
   --
   hr_utility.set_location(' Entering: WATIF_ELIG_CVRD_DPNT_F_API' , 10);
   hr_utility.set_location(' Entering: WATIF_ELIG_CVRD_DPNT_F_API' , 80);
   --
 end;


 procedure WATIF_PER_ASG_BUDG_VAL_F_API(
   p_person_id                      in  number
  ,p_ASSIGNMENT_BUDGET_VALUE_ID     in  number
  ,p_VALUE                          in  number
  ,p_business_group_id              in  number
  ,p_effective_date                 in  date
  ) is
  --
  cursor c_asg_bud is
   select abv.*
   from per_assignment_budget_values_f abv,
        per_all_assignments_f asg
   where asg.person_id = p_person_id  and
         asg.primary_flag = 'Y'and
         asg.assignment_type <> 'C' and
         p_effective_date between nvl(asg.effective_start_date, p_effective_date)
                          and     nvl(asg.effective_end_date, p_effective_date) and
         abv.ASSIGNMENT_ID = asg.ASSIGNMENT_ID and
         abv.ASSIGNMENT_BUDGET_VALUE_ID = p_ASSIGNMENT_BUDGET_VALUE_ID and
         abv.business_group_id = p_business_group_id and
         p_effective_date between abv.effective_start_date
                          and     abv.effective_end_date;
  --
  l_effective_start_date           date;
  l_effective_end_date             date;
  l_object_version_number          number;
  l_upd_mode                       varchar2(50);
  --
  asg_bud_rec per_assignment_budget_values_f%rowtype;
  --
 begin
   --
   hr_utility.set_location(' Entering: WATIF_PER_ASG_BUDG_VAL_F_API' , 10);
   --
   If p_ASSIGNMENT_BUDGET_VALUE_ID is null and  p_VALUE  is null
   then
       --
       fnd_message.set_name('BEN','BEN_91447_ALL_NULL');
       fnd_message.raise_error;
       --
   End If;
   --
   open c_asg_bud;
   fetch c_asg_bud into asg_bud_rec;
   --
   if p_VALUE is not null then
      asg_bud_rec.VALUE    := p_VALUE;
   end if;
   --
   if p_ASSIGNMENT_BUDGET_VALUE_ID is not null then
      asg_bud_rec.ASSIGNMENT_BUDGET_VALUE_ID    := p_ASSIGNMENT_BUDGET_VALUE_ID;
   end if;
   --
   if c_asg_bud%notfound Then
      --
      -- Error out as the record not exists.
      --
      null;
   else
      --
      update per_assignment_budget_values_f
      set value = asg_bud_rec.VALUE
      where assignment_budget_value_id = p_ASSIGNMENT_BUDGET_VALUE_ID
        and business_group_id = p_business_group_id
        and p_effective_date between effective_start_date
                                 and effective_end_date;
      --
   end if;
   --
   close c_asg_bud;
   --
   hr_utility.set_location(' Entering: WATIF_PER_ASG_BUDG_VAL_F_API' , 80);
   --
 end;



procedure WATIF_PER_BNFTS_BAL_F_API(
   p_person_id                      in  number
  ,p_BNFTS_BAL_ID                   in  number
  ,p_VAL                            in  number
  ,p_EFFECTIVE_START_DATE           in  date
  ,p_EFFECTIVE_END_DATE             in  date
  ,p_business_group_id              in  number
  ,p_effective_date                 in  date
  )is
  --
  cursor c_bnfts_bal is
   select * from ben_per_bnfts_bal_f
    where   person_id    = p_person_id  and
            bnfts_bal_id = p_BNFTS_BAL_ID and
            business_group_id = p_business_group_id and
            p_effective_date between effective_start_date
                             and     effective_end_date;
  --
  l_per_bnfts_bal_id               number;
  l_effective_start_date           date;
  l_effective_end_date             date;
  l_object_version_number          number;
  l_upd_mode                       varchar2(50);
  --
  per_bnft_bal_rec ben_per_bnfts_bal_f%rowtype;
  --
begin
   --
   hr_utility.set_location(' Entering: WATIF_PER_BNFTS_BAL_F_API' , 10);
   --
   If p_BNFTS_BAL_ID is null and  p_VAL  is null and
      p_EFFECTIVE_START_DATE is null and p_EFFECTIVE_END_DATE is null
   then
       --
       fnd_message.set_name('BEN','BEN_91447_ALL_NULL');
       fnd_message.raise_error;
       --
   End If;
   --
   open c_bnfts_bal;
   fetch c_bnfts_bal into per_bnft_bal_rec;
   --
   if p_val is not null then
      per_bnft_bal_rec.val    := p_val;
   end if;
   --
   if p_bnfts_bal_id is not null then
      per_bnft_bal_rec.bnfts_bal_id    := p_bnfts_bal_id;
   end if;
   --
   if c_bnfts_bal%notfound Then
      --
      -- Create the benefit balance.
      --
      ben_person_bnfts_bal_api.create_person_bnfts_bal
      (
         p_validate                       => false
        ,p_per_bnfts_bal_id               => l_per_bnfts_bal_id
        ,p_effective_start_date           => l_effective_start_date
        ,p_effective_end_date             => l_effective_end_date
        ,p_val                            => per_bnft_bal_rec.val
        ,p_bnfts_bal_id                   => p_bnfts_bal_id
        ,p_person_id                      => p_person_id
        ,p_business_group_id              => p_business_group_id
        ,p_pbb_attribute_category         => per_bnft_bal_rec.pbb_attribute_category
        ,p_pbb_attribute1                 => per_bnft_bal_rec.pbb_attribute1
        ,p_pbb_attribute2                 => per_bnft_bal_rec.pbb_attribute2
        ,p_pbb_attribute3                 => per_bnft_bal_rec.pbb_attribute3
        ,p_pbb_attribute4                 => per_bnft_bal_rec.pbb_attribute4
        ,p_pbb_attribute5                 => per_bnft_bal_rec.pbb_attribute5
        ,p_pbb_attribute6                 => per_bnft_bal_rec.pbb_attribute6
        ,p_pbb_attribute7                 => per_bnft_bal_rec.pbb_attribute7
        ,p_pbb_attribute8                 => per_bnft_bal_rec.pbb_attribute8
        ,p_pbb_attribute9                 => per_bnft_bal_rec.pbb_attribute9
        ,p_pbb_attribute10                => per_bnft_bal_rec.pbb_attribute10
        ,p_pbb_attribute11                => per_bnft_bal_rec.pbb_attribute11
        ,p_pbb_attribute12                => per_bnft_bal_rec.pbb_attribute12
        ,p_pbb_attribute13                => per_bnft_bal_rec.pbb_attribute13
        ,p_pbb_attribute14                => per_bnft_bal_rec.pbb_attribute14
        ,p_pbb_attribute15                => per_bnft_bal_rec.pbb_attribute15
        ,p_pbb_attribute16                => per_bnft_bal_rec.pbb_attribute16
        ,p_pbb_attribute17                => per_bnft_bal_rec.pbb_attribute17
        ,p_pbb_attribute18                => per_bnft_bal_rec.pbb_attribute18
        ,p_pbb_attribute19                => per_bnft_bal_rec.pbb_attribute19
        ,p_pbb_attribute20                => per_bnft_bal_rec.pbb_attribute20
        ,p_pbb_attribute21                => per_bnft_bal_rec.pbb_attribute21
        ,p_pbb_attribute22                => per_bnft_bal_rec.pbb_attribute22
        ,p_pbb_attribute23                => per_bnft_bal_rec.pbb_attribute23
        ,p_pbb_attribute24                => per_bnft_bal_rec.pbb_attribute24
        ,p_pbb_attribute25                => per_bnft_bal_rec.pbb_attribute25
        ,p_pbb_attribute26                => per_bnft_bal_rec.pbb_attribute26
        ,p_pbb_attribute27                => per_bnft_bal_rec.pbb_attribute27
        ,p_pbb_attribute28                => per_bnft_bal_rec.pbb_attribute28
        ,p_pbb_attribute29                => per_bnft_bal_rec.pbb_attribute29
        ,p_pbb_attribute30                => per_bnft_bal_rec.pbb_attribute30
        ,p_object_version_number          => l_object_version_number
        ,p_effective_date                 => p_effective_date
      );
      --
   else
      --
      Get_DT_Upd_Mode
       (p_effective_date        => p_effective_date,
        p_base_table_name       => 'BEN_PER_BNFTS_BAL_F',
        p_base_key_column       => 'PER_BNFTS_BAL_ID',
        p_base_key_value        => per_bnft_bal_rec.per_bnfts_bal_id,
        p_mode                  => l_upd_mode);
      --
      -- Update the benefit balance.
      --
      ben_person_bnfts_bal_api.update_person_bnfts_bal
      (
         p_validate                       => false
        ,p_per_bnfts_bal_id               => per_bnft_bal_rec.per_bnfts_bal_id
        ,p_effective_start_date           => l_effective_start_date
        ,p_effective_end_date             => l_effective_end_date
        ,p_val                            => per_bnft_bal_rec.val
        ,p_bnfts_bal_id                   => p_bnfts_bal_id
        ,p_person_id                      => p_person_id
        ,p_business_group_id              => p_business_group_id
        ,p_pbb_attribute_category         => per_bnft_bal_rec.pbb_attribute_category
        ,p_pbb_attribute1                 => per_bnft_bal_rec.pbb_attribute1
        ,p_pbb_attribute2                 => per_bnft_bal_rec.pbb_attribute2
        ,p_pbb_attribute3                 => per_bnft_bal_rec.pbb_attribute3
        ,p_pbb_attribute4                 => per_bnft_bal_rec.pbb_attribute4
        ,p_pbb_attribute5                 => per_bnft_bal_rec.pbb_attribute5
        ,p_pbb_attribute6                 => per_bnft_bal_rec.pbb_attribute6
        ,p_pbb_attribute7                 => per_bnft_bal_rec.pbb_attribute7
        ,p_pbb_attribute8                 => per_bnft_bal_rec.pbb_attribute8
        ,p_pbb_attribute9                 => per_bnft_bal_rec.pbb_attribute9
        ,p_pbb_attribute10                => per_bnft_bal_rec.pbb_attribute10
        ,p_pbb_attribute11                => per_bnft_bal_rec.pbb_attribute11
        ,p_pbb_attribute12                => per_bnft_bal_rec.pbb_attribute12
        ,p_pbb_attribute13                => per_bnft_bal_rec.pbb_attribute13
        ,p_pbb_attribute14                => per_bnft_bal_rec.pbb_attribute14
        ,p_pbb_attribute15                => per_bnft_bal_rec.pbb_attribute15
        ,p_pbb_attribute16                => per_bnft_bal_rec.pbb_attribute16
        ,p_pbb_attribute17                => per_bnft_bal_rec.pbb_attribute17
        ,p_pbb_attribute18                => per_bnft_bal_rec.pbb_attribute18
        ,p_pbb_attribute19                => per_bnft_bal_rec.pbb_attribute19
        ,p_pbb_attribute20                => per_bnft_bal_rec.pbb_attribute20
        ,p_pbb_attribute21                => per_bnft_bal_rec.pbb_attribute21
        ,p_pbb_attribute22                => per_bnft_bal_rec.pbb_attribute22
        ,p_pbb_attribute23                => per_bnft_bal_rec.pbb_attribute23
        ,p_pbb_attribute24                => per_bnft_bal_rec.pbb_attribute24
        ,p_pbb_attribute25                => per_bnft_bal_rec.pbb_attribute25
        ,p_pbb_attribute26                => per_bnft_bal_rec.pbb_attribute26
        ,p_pbb_attribute27                => per_bnft_bal_rec.pbb_attribute27
        ,p_pbb_attribute28                => per_bnft_bal_rec.pbb_attribute28
        ,p_pbb_attribute29                => per_bnft_bal_rec.pbb_attribute29
        ,p_pbb_attribute30                => per_bnft_bal_rec.pbb_attribute30
        ,p_object_version_number          => per_bnft_bal_rec.object_version_number
        ,p_effective_date                 => p_effective_date
        ,p_datetrack_mode                 => l_upd_mode
      );
      --
   end if;
   Close c_bnfts_bal;
   --
   hr_utility.set_location(' Leaving: WATIF_PER_BNFTS_BAL_F_API' , 80);
   --
end;


--Bug 2831804
 procedure WATIF_PER_QUALIFICATIONS_API(
    p_person_id                      in number
   ,p_qualification_type_id          in number
   ,p_title			     in varchar2
   ,p_start_date  		     in date
   ,p_end_date			     in date
   ,p_attribute1		     in varchar2
   ,p_attribute2		     in varchar2
   ,p_attribute3		     in varchar2
   ,p_attribute4		     in varchar2
   ,p_attribute5         	     in varchar2
   ,p_attribute6		     in varchar2
   ,p_attribute7		     in varchar2
   ,p_attribute8		     in varchar2
   ,p_attribute9		     in varchar2
   ,p_attribute10		     in varchar2
   ,p_attribute11        	     in varchar2
   ,p_attribute12		     in varchar2
   ,p_attribute13		     in varchar2
   ,p_attribute14        	     in varchar2
   ,p_attribute15		     in varchar2
   ,p_attribute16		     in varchar2
   ,p_attribute17        	     in varchar2
   ,p_attribute18		     in varchar2
   ,p_attribute19		     in varchar2
   ,p_attribute20		     in varchar2
   ,p_business_group_id              in number
   ,p_effective_date                 in date
   ) is

   cursor c_person is
	select * from per_qualifications qua
         where person_id = p_person_id
	   and qua.qualification_type_id = p_qualification_type_id
	   and qua.business_group_id     = p_business_group_id
	   and p_effective_date between qua.start_date	and nvl(qua.end_date, p_effective_date);

   l_person_rec c_person%rowtype;
   l_object_version_number number;
   l_qualification_id number;
   per_qual_rec per_qualifications%rowtype;
begin

   if p_person_id is not null then
      per_qual_rec.person_id := p_person_id;
   end if;

   if p_business_group_id is not null then
      per_qual_rec.business_group_id := p_business_group_id;
   end if;

   if p_qualification_type_id is not null then
      per_qual_rec.qualification_type_id := 	p_qualification_type_id;
   end if;

   if p_title is not null then
      per_qual_rec.title  := 	p_title;
   end if;

   if p_start_date is not null then
      per_qual_rec.start_date := p_start_date;
   end if;

   if p_end_date is not null then
      per_qual_rec.end_date := p_end_date;
   end if;

   if p_attribute1 is not null then
      per_qual_rec.attribute1 := p_attribute1;
   end if;

   if p_attribute2 is not null then
      per_qual_rec.attribute2 := p_attribute2;
   end if;

   if p_attribute3 is not null then
      per_qual_rec.attribute3 := p_attribute3;
   end if;

   if p_attribute4 is not null then
      per_qual_rec.attribute4 := p_attribute4;
   end if;

   if p_attribute5 is not null then
      per_qual_rec.attribute5 := p_attribute5;
   end if;

   if p_attribute6 is not null then
      per_qual_rec.attribute6 := p_attribute6;
   end if;

   if p_attribute7 is not null then
      per_qual_rec.attribute7 := p_attribute7;
   end if;

   if p_attribute8 is not null then
      per_qual_rec.attribute8 := p_attribute8;
   end if;

   if p_attribute9 is not null then
      per_qual_rec.attribute9 := p_attribute9;
   end if;

   if p_attribute10 is not null then
      per_qual_rec.attribute10 := p_attribute10;
   end if;

   if p_attribute11 is not null then
      per_qual_rec.attribute11 := p_attribute11;
   end if;

   if p_attribute12 is not null then
      per_qual_rec.attribute12 := p_attribute12;
   end if;

   if p_attribute13 is not null then
      per_qual_rec.attribute13 := p_attribute13;
   end if;

   if p_attribute14 is not null then
      per_qual_rec.attribute14 := p_attribute14;
   end if;

   if p_attribute15 is not null then
      per_qual_rec.attribute15 := p_attribute15;
   end if;

   if p_attribute16 is not null then
      per_qual_rec.attribute16 := p_attribute16;
   end if;

   if p_attribute17 is not null then
      per_qual_rec.attribute17 := p_attribute17;
   end if;

   if p_attribute18 is not null then
      per_qual_rec.attribute18 := p_attribute18;
   end if;

   if p_attribute19 is not null then
      per_qual_rec.attribute19 := p_attribute19;
   end if;

   if p_attribute20 is not null then
      per_qual_rec.attribute20 := p_attribute20;
   end if;

   open c_person;
   fetch c_person into l_person_rec;
   if c_person%found then
     close c_person;
     PER_QUALIFICATIONS_API.UPDATE_QUALIFICATION
        (p_validate                     => FALSE
	 ,p_qualification_type_id         =>  per_qual_rec.qualification_type_id
	 ,p_title                         =>  per_qual_rec.title
 	 ,p_start_date                    =>  per_qual_rec.start_date
  	 ,p_end_date                      =>  per_qual_rec.end_date
         ,p_effective_date                =>  p_effective_date
 	 ,p_attribute1                    =>  per_qual_rec.attribute1
 	 ,p_attribute2                    =>  per_qual_rec.attribute2
 	 ,p_attribute3                    =>  per_qual_rec.attribute3
 	 ,p_attribute4                    =>  per_qual_rec.attribute4
 	 ,p_attribute5                    =>  per_qual_rec.attribute5
 	 ,p_attribute6                    =>  per_qual_rec.attribute6
 	 ,p_attribute7                    =>  per_qual_rec.attribute7
 	 ,p_attribute8                    =>  per_qual_rec.attribute8
 	 ,p_attribute9                    =>  per_qual_rec.attribute9
 	 ,p_attribute10                   =>  per_qual_rec.attribute10
 	 ,p_attribute11                   =>  per_qual_rec.attribute11
 	 ,p_attribute12                   =>  per_qual_rec.attribute12
 	 ,p_attribute13                   =>  per_qual_rec.attribute13
 	 ,p_attribute14                   =>  per_qual_rec.attribute14
 	 ,p_attribute15                   =>  per_qual_rec.attribute15
 	 ,p_attribute16                   =>  per_qual_rec.attribute16
 	 ,p_attribute17                   =>  per_qual_rec.attribute17
 	 ,p_attribute18                   =>  per_qual_rec.attribute18
 	 ,p_attribute19                   =>  per_qual_rec.attribute19
 	 ,p_attribute20                   =>  per_qual_rec.attribute20
 	 ,p_qualification_id              =>  l_person_rec.qualification_id
 	 ,p_object_version_number         =>  l_person_rec.object_version_number
        );
   else
     close c_person;
     PER_QUALIFICATIONS_API.CREATE_QUALIFICATION
  	(p_validate                      =>  FALSE
         ,p_effective_date                =>  p_effective_date
	 ,p_qualification_type_id         =>  per_qual_rec.qualification_type_id
	 ,p_business_group_id             =>  per_qual_rec.business_group_id
         ,p_person_id                     =>  per_qual_rec.person_id
 	 ,p_title                         =>  per_qual_rec.title
 	 ,p_start_date                    =>  per_qual_rec.start_date
  	 ,p_end_date                      =>  per_qual_rec.end_date
 	 ,p_attribute1                    =>  per_qual_rec.attribute1
 	 ,p_attribute2                    =>  per_qual_rec.attribute2
 	 ,p_attribute3                    =>  per_qual_rec.attribute3
 	 ,p_attribute4                    =>  per_qual_rec.attribute4
 	 ,p_attribute5                    =>  per_qual_rec.attribute5
 	 ,p_attribute6                    =>  per_qual_rec.attribute6
 	 ,p_attribute7                    =>  per_qual_rec.attribute7
 	 ,p_attribute8                    =>  per_qual_rec.attribute8
 	 ,p_attribute9                    =>  per_qual_rec.attribute9
 	 ,p_attribute10                   =>  per_qual_rec.attribute10
 	 ,p_attribute11                   =>  per_qual_rec.attribute11
 	 ,p_attribute12                   =>  per_qual_rec.attribute12
 	 ,p_attribute13                   =>  per_qual_rec.attribute13
 	 ,p_attribute14                   =>  per_qual_rec.attribute14
 	 ,p_attribute15                   =>  per_qual_rec.attribute15
 	 ,p_attribute16                   =>  per_qual_rec.attribute16
 	 ,p_attribute17                   =>  per_qual_rec.attribute17
 	 ,p_attribute18                   =>  per_qual_rec.attribute18
 	 ,p_attribute19                   =>  per_qual_rec.attribute19
 	 ,p_attribute20                   =>  per_qual_rec.attribute20
 	 ,p_qualification_id              =>  l_qualification_id
 	 ,p_object_version_number         =>  l_object_version_number
       );
   end if;
end;
-- Bug 2831804


--Bug 2831804 Competence
 procedure WATIF_PER_COMPETENCE_API(
    p_person_id                      in number
   ,p_competence_id                  in number
   ,p_proficiency_level_id	     in number
   ,p_effective_date_from	     in date
   ,p_effective_date_to		     in date
   ,p_attribute1		     in varchar2
   ,p_attribute2		     in varchar2
   ,p_attribute3		     in varchar2
   ,p_attribute4		     in varchar2
   ,p_attribute5         	     in varchar2
   ,p_attribute6		     in varchar2
   ,p_attribute7		     in varchar2
   ,p_attribute8		     in varchar2
   ,p_attribute9		     in varchar2
   ,p_attribute10		     in varchar2
   ,p_attribute11        	     in varchar2
   ,p_attribute12		     in varchar2
   ,p_attribute13		     in varchar2
   ,p_attribute14        	     in varchar2
   ,p_attribute15		     in varchar2
   ,p_attribute16		     in varchar2
   ,p_attribute17        	     in varchar2
   ,p_attribute18		     in varchar2
   ,p_attribute19		     in varchar2
   ,p_attribute20		     in varchar2
   ,p_business_group_id              in number
   ,p_effective_date                 in date
) is

cursor c_comp_rec is
	select * from per_competence_elements cel
         where cel.person_id = p_person_id
	   and cel.competence_id = p_competence_id
	   and cel.business_group_id     = p_business_group_id
	   and p_effective_date between cel.effective_date_from	and nvl(cel.effective_date_to, p_effective_date);

l_comp_elmnt_id number;
l_object_version_number number;
per_comp_elmnt_rec per_competence_elements%rowtype;
l_comp_rec c_comp_rec%rowtype;
begin
  if p_person_id is not null then
      per_comp_elmnt_rec.person_id := p_person_id;
   end if;

   if p_business_group_id is not null then
      per_comp_elmnt_rec.business_group_id := p_business_group_id;
   end if;

   if p_competence_id is not null then
      per_comp_elmnt_rec.competence_id := p_competence_id;
   end if;

   if p_proficiency_level_id is not null then
      per_comp_elmnt_rec.proficiency_level_id  := p_proficiency_level_id;
   end if;

   if p_effective_date_from is not null then
      per_comp_elmnt_rec.effective_date_from := p_effective_date_from;
   end if;

   if p_effective_date_to is not null then
      per_comp_elmnt_rec.effective_date_to:= p_effective_date_to;
   end if;

   if p_attribute1 is not null then
      per_comp_elmnt_rec.attribute1 := p_attribute1;
   end if;

   if p_attribute2 is not null then
      per_comp_elmnt_rec.attribute2 := p_attribute2;
   end if;

   if p_attribute3 is not null then
      per_comp_elmnt_rec.attribute3 := p_attribute3;
   end if;

   if p_attribute4 is not null then
      per_comp_elmnt_rec.attribute4 := p_attribute4;
   end if;

   if p_attribute5 is not null then
      per_comp_elmnt_rec.attribute5 := p_attribute5;
   end if;

   if p_attribute6 is not null then
      per_comp_elmnt_rec.attribute6 := p_attribute6;
   end if;

   if p_attribute7 is not null then
      per_comp_elmnt_rec.attribute7 := p_attribute7;
   end if;

   if p_attribute8 is not null then
      per_comp_elmnt_rec.attribute8 := p_attribute8;
   end if;

   if p_attribute9 is not null then
      per_comp_elmnt_rec.attribute9 := p_attribute9;
   end if;

   if p_attribute10 is not null then
      per_comp_elmnt_rec.attribute10 := p_attribute10;
   end if;

   if p_attribute11 is not null then
      per_comp_elmnt_rec.attribute11 := p_attribute11;
   end if;

   if p_attribute12 is not null then
      per_comp_elmnt_rec.attribute12 := p_attribute12;
   end if;

   if p_attribute13 is not null then
      per_comp_elmnt_rec.attribute13 := p_attribute13;
   end if;

   if p_attribute14 is not null then
      per_comp_elmnt_rec.attribute14 := p_attribute14;
   end if;

   if p_attribute15 is not null then
      per_comp_elmnt_rec.attribute15 := p_attribute15;
   end if;

   if p_attribute16 is not null then
      per_comp_elmnt_rec.attribute16 := p_attribute16;
   end if;

   if p_attribute17 is not null then
      per_comp_elmnt_rec.attribute17 := p_attribute17;
   end if;

   if p_attribute18 is not null then
      per_comp_elmnt_rec.attribute18 := p_attribute18;
   end if;

   if p_attribute19 is not null then
      per_comp_elmnt_rec.attribute19 := p_attribute19;
   end if;

   if p_attribute20 is not null then
      per_comp_elmnt_rec.attribute20 := p_attribute20;
   end if;

 open c_comp_rec;
 fetch c_comp_rec into l_comp_rec;
 if c_comp_rec%found then
    hr_competence_element_api.update_competence_element
  (
   p_competence_element_id  => l_comp_rec.competence_element_id
  ,p_object_version_number  => l_comp_rec.object_version_number
  ,p_proficiency_level_id   => per_comp_elmnt_rec.proficiency_level_id
  ,p_effective_date_from    => per_comp_elmnt_rec.effective_date_from
  ,p_effective_date_to      => per_comp_elmnt_rec.effective_date_to
  ,p_attribute1             => per_comp_elmnt_rec.attribute1
  ,p_attribute2             => per_comp_elmnt_rec.attribute2
  ,p_attribute3             => per_comp_elmnt_rec.attribute3
  ,p_attribute4             => per_comp_elmnt_rec.attribute4
  ,p_attribute5             => per_comp_elmnt_rec.attribute5
  ,p_attribute6             => per_comp_elmnt_rec.attribute6
  ,p_attribute7             => per_comp_elmnt_rec.attribute7
  ,p_attribute8             => per_comp_elmnt_rec.attribute8
  ,p_attribute9             => per_comp_elmnt_rec.attribute9
  ,p_attribute10            => per_comp_elmnt_rec.attribute10
  ,p_attribute11            => per_comp_elmnt_rec.attribute11
  ,p_attribute12            => per_comp_elmnt_rec.attribute12
  ,p_attribute13            => per_comp_elmnt_rec.attribute13
  ,p_attribute14            => per_comp_elmnt_rec.attribute14
  ,p_attribute15            => per_comp_elmnt_rec.attribute15
  ,p_attribute16            => per_comp_elmnt_rec.attribute16
  ,p_attribute17            => per_comp_elmnt_rec.attribute17
  ,p_attribute18            => per_comp_elmnt_rec.attribute18
  ,p_attribute19            => per_comp_elmnt_rec.attribute19
  ,p_attribute20            => per_comp_elmnt_rec.attribute20
  ,p_effective_date	    => p_effective_date
  );
 else
  hr_competence_element_api.create_competence_element
  (p_validate                     => FALSE
  ,p_competence_element_id        => l_comp_elmnt_id
  ,p_object_version_number        => l_object_version_number
  ,p_type                         => 'PERSONAL'
  ,p_business_group_id            => p_business_group_id
  ,p_competence_id                => per_comp_elmnt_rec.competence_id
  ,p_proficiency_level_id         => per_comp_elmnt_rec.proficiency_level_id
  ,p_person_id                    => per_comp_elmnt_rec.person_id
  ,p_effective_date_from          => per_comp_elmnt_rec.effective_date_from
  ,p_effective_date_to            => per_comp_elmnt_rec.effective_date_to
  ,p_attribute1                   => per_comp_elmnt_rec.attribute1
  ,p_attribute2                   => per_comp_elmnt_rec.attribute2
  ,p_attribute3                   => per_comp_elmnt_rec.attribute3
  ,p_attribute4                   => per_comp_elmnt_rec.attribute4
  ,p_attribute5                   => per_comp_elmnt_rec.attribute5
  ,p_attribute6                   => per_comp_elmnt_rec.attribute6
  ,p_attribute7                   => per_comp_elmnt_rec.attribute7
  ,p_attribute8                   => per_comp_elmnt_rec.attribute8
  ,p_attribute9                   => per_comp_elmnt_rec.attribute9
  ,p_attribute10                  => per_comp_elmnt_rec.attribute10
  ,p_attribute11                  => per_comp_elmnt_rec.attribute11
  ,p_attribute12                  => per_comp_elmnt_rec.attribute12
  ,p_attribute13                  => per_comp_elmnt_rec.attribute13
  ,p_attribute14                  => per_comp_elmnt_rec.attribute14
  ,p_attribute15                  => per_comp_elmnt_rec.attribute15
  ,p_attribute16                  => per_comp_elmnt_rec.attribute16
  ,p_attribute17                  => per_comp_elmnt_rec.attribute17
  ,p_attribute18                  => per_comp_elmnt_rec.attribute18
  ,p_attribute19                  => per_comp_elmnt_rec.attribute19
  ,p_attribute20                  => per_comp_elmnt_rec.attribute20
  ,p_effective_date		 => p_effective_date
 );
end if;
end;
--Bug 2831804 Competence

--Bug 2831804 Performance

 procedure WATIF_PER_PERFORMANCE_API(
    p_person_id                      in number
   ,p_performance_rating             in varchar2
   ,p_event_id			     in number
   ,p_review_date                    in date
   ,p_attribute1		     in varchar2
   ,p_attribute2		     in varchar2
   ,p_attribute3		     in varchar2
   ,p_attribute4		     in varchar2
   ,p_attribute5         	     in varchar2
   ,p_attribute6		     in varchar2
   ,p_attribute7		     in varchar2
   ,p_attribute8		     in varchar2
   ,p_attribute9		     in varchar2
   ,p_attribute10		     in varchar2
   ,p_attribute11        	     in varchar2
   ,p_attribute12		     in varchar2
   ,p_attribute13		     in varchar2
   ,p_attribute14        	     in varchar2
   ,p_attribute15		     in varchar2
   ,p_attribute16		     in varchar2
   ,p_attribute17        	     in varchar2
   ,p_attribute18		     in varchar2
   ,p_attribute19		     in varchar2
   ,p_attribute20		     in varchar2
   ,p_attribute21		     in varchar2
   ,p_attribute22		     in varchar2
   ,p_attribute23		     in varchar2
   ,p_attribute24		     in varchar2
   ,p_attribute25         	     in varchar2
   ,p_attribute26		     in varchar2
   ,p_attribute27		     in varchar2
   ,p_attribute28		     in varchar2
   ,p_attribute29		     in varchar2
   ,p_attribute30		     in varchar2
   ) is

cursor c_perf_rec is
	select * from per_performance_reviews prv
         where prv.person_id = p_person_id
           and review_date   = p_review_date;


l_perf_review_id number;
l_object_version_number number;
l_next_review_date_warning boolean;
per_perf_review_rec per_performance_reviews%rowtype;
l_perf_rec c_perf_rec%rowtype;
begin
   if p_person_id is not null then
      per_perf_review_rec.person_id := p_person_id;
   end if;

   if p_performance_rating is not null then
      per_perf_review_rec.performance_rating := p_performance_rating;
   end if;

   if p_event_id is not null then
      per_perf_review_rec.event_id  := p_event_id;
   end if;

   if p_review_date is not null then
         per_perf_review_rec.review_date := p_review_date;
   end if;

   if p_attribute1 is not null then
      per_perf_review_rec.attribute1 := p_attribute1;
   end if;

   if p_attribute2 is not null then
      per_perf_review_rec.attribute2 := p_attribute2;
   end if;

   if p_attribute3 is not null then
      per_perf_review_rec.attribute3 := p_attribute3;
   end if;

   if p_attribute4 is not null then
      per_perf_review_rec.attribute4 := p_attribute4;
   end if;

   if p_attribute5 is not null then
      per_perf_review_rec.attribute5 := p_attribute5;
   end if;

   if p_attribute6 is not null then
      per_perf_review_rec.attribute6 := p_attribute6;
   end if;

   if p_attribute7 is not null then
      per_perf_review_rec.attribute7 := p_attribute7;
   end if;

   if p_attribute8 is not null then
      per_perf_review_rec.attribute8 := p_attribute8;
   end if;

   if p_attribute9 is not null then
      per_perf_review_rec.attribute9 := p_attribute9;
   end if;

   if p_attribute10 is not null then
      per_perf_review_rec.attribute10 := p_attribute10;
   end if;

   if p_attribute11 is not null then
      per_perf_review_rec.attribute11 := p_attribute11;
   end if;

   if p_attribute12 is not null then
      per_perf_review_rec.attribute12 := p_attribute12;
   end if;

   if p_attribute13 is not null then
      per_perf_review_rec.attribute13 := p_attribute13;
   end if;

   if p_attribute14 is not null then
      per_perf_review_rec.attribute14 := p_attribute14;
   end if;

   if p_attribute15 is not null then
      per_perf_review_rec.attribute15 := p_attribute15;
   end if;

   if p_attribute16 is not null then
      per_perf_review_rec.attribute16 := p_attribute16;
   end if;

   if p_attribute17 is not null then
      per_perf_review_rec.attribute17 := p_attribute17;
   end if;

   if p_attribute18 is not null then
      per_perf_review_rec.attribute18 := p_attribute18;
   end if;

   if p_attribute19 is not null then
      per_perf_review_rec.attribute19 := p_attribute19;
   end if;

   if p_attribute20 is not null then
      per_perf_review_rec.attribute20 := p_attribute20;
   end if;

   if p_attribute21 is not null then
      per_perf_review_rec.attribute1  := p_attribute21;
   end if;

   if p_attribute22 is not null then
      per_perf_review_rec.attribute22 := p_attribute22;
   end if;

   if p_attribute23 is not null then
      per_perf_review_rec.attribute23 := p_attribute23;
   end if;

   if p_attribute24 is not null then
      per_perf_review_rec.attribute24 := p_attribute24;
   end if;

   if p_attribute25 is not null then
      per_perf_review_rec.attribute25 := p_attribute25;
   end if;

   if p_attribute26 is not null then
      per_perf_review_rec.attribute26 := p_attribute26;
   end if;

   if p_attribute27 is not null then
      per_perf_review_rec.attribute27 := p_attribute27;
   end if;

   if p_attribute28 is not null then
      per_perf_review_rec.attribute28 := p_attribute28;
   end if;

   if p_attribute29 is not null then
      per_perf_review_rec.attribute29 := p_attribute29;
   end if;

   if p_attribute30 is not null then
      per_perf_review_rec.attribute30 := p_attribute30;
   end if;

 open c_perf_rec;
 fetch c_perf_rec into l_perf_rec;
 if c_perf_rec%found then
    hr_perf_review_api.update_perf_review
  (
   p_performance_review_id  => l_perf_rec.performance_review_id
  ,p_object_version_number  => l_perf_rec.object_version_number
  ,p_next_review_date_warning=> l_next_review_date_warning
  ,p_review_date            => per_perf_review_rec.review_date
  ,p_performance_rating     => per_perf_review_rec.performance_rating
  ,p_event_id		    => per_perf_review_rec.event_id
  ,p_attribute1             => per_perf_review_rec.attribute1
  ,p_attribute2             => per_perf_review_rec.attribute2
  ,p_attribute3             => per_perf_review_rec.attribute3
  ,p_attribute4             => per_perf_review_rec.attribute4
  ,p_attribute5             => per_perf_review_rec.attribute5
  ,p_attribute6             => per_perf_review_rec.attribute6
  ,p_attribute7             => per_perf_review_rec.attribute7
  ,p_attribute8             => per_perf_review_rec.attribute8
  ,p_attribute9             => per_perf_review_rec.attribute9
  ,p_attribute10            => per_perf_review_rec.attribute10
  ,p_attribute11            => per_perf_review_rec.attribute11
  ,p_attribute12            => per_perf_review_rec.attribute12
  ,p_attribute13            => per_perf_review_rec.attribute13
  ,p_attribute14            => per_perf_review_rec.attribute14
  ,p_attribute15            => per_perf_review_rec.attribute15
  ,p_attribute16            => per_perf_review_rec.attribute16
  ,p_attribute17            => per_perf_review_rec.attribute17
  ,p_attribute18            => per_perf_review_rec.attribute18
  ,p_attribute19            => per_perf_review_rec.attribute19
  ,p_attribute20            => per_perf_review_rec.attribute20
  ,p_attribute21            => per_perf_review_rec.attribute21
  ,p_attribute22            => per_perf_review_rec.attribute22
  ,p_attribute23            => per_perf_review_rec.attribute23
  ,p_attribute24            => per_perf_review_rec.attribute24
  ,p_attribute25            => per_perf_review_rec.attribute25
  ,p_attribute26            => per_perf_review_rec.attribute26
  ,p_attribute27            => per_perf_review_rec.attribute27
  ,p_attribute28            => per_perf_review_rec.attribute28
  ,p_attribute29            => per_perf_review_rec.attribute29
  ,p_attribute30            => per_perf_review_rec.attribute30
  );
 else
    hr_perf_review_api.create_perf_review
  (p_performance_review_id        => l_perf_review_id
  ,p_object_version_number        => l_object_version_number
  ,p_next_review_date_warning     => l_next_review_date_warning
  ,p_performance_rating           => per_perf_review_rec.performance_rating
  ,p_event_id                     => per_perf_review_rec.event_id
  ,p_person_id                    => per_perf_review_rec.person_id
  ,p_review_date                  => per_perf_review_rec.review_date
  ,p_attribute1             	  => per_perf_review_rec.attribute1
  ,p_attribute2             	  => per_perf_review_rec.attribute2
  ,p_attribute3             	  => per_perf_review_rec.attribute3
  ,p_attribute4             	  => per_perf_review_rec.attribute4
  ,p_attribute5             	  => per_perf_review_rec.attribute5
  ,p_attribute6             	  => per_perf_review_rec.attribute6
  ,p_attribute7             	  => per_perf_review_rec.attribute7
  ,p_attribute8             	  => per_perf_review_rec.attribute8
  ,p_attribute9             	  => per_perf_review_rec.attribute9
  ,p_attribute10            	  => per_perf_review_rec.attribute10
  ,p_attribute11            	  => per_perf_review_rec.attribute11
  ,p_attribute12            	  => per_perf_review_rec.attribute12
  ,p_attribute13            	  => per_perf_review_rec.attribute13
  ,p_attribute14            	  => per_perf_review_rec.attribute14
  ,p_attribute15            	  => per_perf_review_rec.attribute15
  ,p_attribute16            	  => per_perf_review_rec.attribute16
  ,p_attribute17            	  => per_perf_review_rec.attribute17
  ,p_attribute18            	  => per_perf_review_rec.attribute18
  ,p_attribute19            	  => per_perf_review_rec.attribute19
  ,p_attribute20            	  => per_perf_review_rec.attribute20
  ,p_attribute21            	  => per_perf_review_rec.attribute21
  ,p_attribute22            	  => per_perf_review_rec.attribute22
  ,p_attribute23            	  => per_perf_review_rec.attribute23
  ,p_attribute24            	  => per_perf_review_rec.attribute24
  ,p_attribute25            	  => per_perf_review_rec.attribute25
  ,p_attribute26            	  => per_perf_review_rec.attribute26
  ,p_attribute27            	  => per_perf_review_rec.attribute27
  ,p_attribute28            	  => per_perf_review_rec.attribute28
  ,p_attribute29            	  => per_perf_review_rec.attribute29
  ,p_attribute30            	  => per_perf_review_rec.attribute30
 );
end if;
end;
--Bug 2831804 Performance

--Bug 2868775 Pay Proposal

procedure WATIF_PAY_PROPOSAL_API(
	    p_person_id                      in number
	   ,p_approved			     in varchar2
	   ,p_change_date                    in date
	   ,p_event_id                       in number
	   ,p_forced_ranking                 in number
	   ,p_last_change_date               in date
	   ,p_multiple_components            in varchar2
	   ,p_next_sal_review_date	     in date
	   ,p_next_perf_review_date	     in date
	   ,p_performance_rating             in varchar2
	   ,p_performance_review_id          in number
	   ,p_proposal_reason                in varchar2
	   ,p_proposed_salary_n              in number
	   ,p_review_date		     in date
	   ,p_attribute1		     in varchar2
	   ,p_attribute2		     in varchar2
	   ,p_attribute3		     in varchar2
	   ,p_attribute4		     in varchar2
	   ,p_attribute5         	     in varchar2
	   ,p_attribute6		     in varchar2
	   ,p_attribute7		     in varchar2
	   ,p_attribute8		     in varchar2
	   ,p_attribute9		     in varchar2
	   ,p_attribute10		     in varchar2
	   ,p_attribute11        	     in varchar2
	   ,p_attribute12		     in varchar2
	   ,p_attribute13		     in varchar2
	   ,p_attribute14        	     in varchar2
	   ,p_attribute15		     in varchar2
	   ,p_attribute16		     in varchar2
	   ,p_attribute17        	     in varchar2
	   ,p_attribute18		     in varchar2
	   ,p_attribute19		     in varchar2
	   ,p_attribute20		     in varchar2
	   ,p_business_group_id              in number
	   ,p_effective_date                 in date
	) is

	cursor c_pay_rec is
		select * from per_pay_proposals pyp
		where pyp.assignment_id  in
			      (select assignment_id
				 from per_all_assignments_f
				where person_id = p_person_id
				  and business_group_id = p_business_group_id)
		  and pyp.business_group_id     = p_business_group_id
		  and p_change_date = pyp.change_date;

	cursor c_assignment_id is
        select assignment_id from per_all_assignments_f
	 where person_id = p_person_id
	 and business_group_id = p_business_group_id;

        l_assignment_id number;
	l_object_version_number number;
	per_pay_rec per_pay_proposals%rowtype;
	l_pay_rec c_pay_rec%rowtype;

	l_pay_proposal_id number;
	l_element_entry_id number;
	l_inv_next_sal_date_warning boolean;
	l_proposed_salary_warning boolean;
	l_approved_warning boolean;
	l_payroll_warning boolean;

	begin

	  open c_assignment_id;
	  fetch c_assignment_id into l_assignment_id;
	  close c_assignment_id;


	   if p_business_group_id is not null then
	      per_pay_rec.business_group_id := p_business_group_id;
	   end if;

	   if p_approved is not null then
	      per_pay_rec.approved := p_approved;
	   end if;

	   if p_change_date is not null then
	      per_pay_rec.change_date := p_change_date;
	   end if;

	   if p_event_id is not null then
	      per_pay_rec.event_id := p_event_id;
	   end if;

	   if p_forced_ranking is not null then
	      per_pay_rec.forced_ranking := p_forced_ranking;
	   end if;

	   if p_last_change_date is not null then
	      per_pay_rec.last_change_date := p_last_change_date;
	   end if;

	   if p_multiple_components is not null then
	      per_pay_rec.multiple_components := p_multiple_components;
	   end if;

	   if p_next_sal_review_date is not null then
	      per_pay_rec.next_sal_review_date := p_next_sal_review_date;
	   end if;

	   if p_next_perf_review_date is not null then
	      per_pay_rec.next_perf_review_date := p_next_perf_review_date;
	   end if;

	   if p_performance_rating is not null then
	      per_pay_rec.performance_rating := p_performance_rating;
	   end if;

	   if p_performance_review_id is not null then
	      per_pay_rec.performance_review_id := p_performance_review_id;
	   end if;

	   if p_proposal_reason is not null then
	      per_pay_rec.proposal_reason := p_proposal_reason;
	   end if;

	   if p_proposed_salary_n is not null then
	      per_pay_rec.proposed_salary_n := p_proposed_salary_n;
	   end if;

	   if p_review_date is not null then
	      per_pay_rec.review_date := p_review_date;
	   end if;

	   if p_attribute1 is not null then
	      per_pay_rec.attribute1 := p_attribute1;
	   end if;

	   if p_attribute2 is not null then
	      per_pay_rec.attribute2 := p_attribute2;
	   end if;

	   if p_attribute3 is not null then
	      per_pay_rec.attribute3 := p_attribute3;
	   end if;

	   if p_attribute4 is not null then
	      per_pay_rec.attribute4 := p_attribute4;
	   end if;

	   if p_attribute5 is not null then
	      per_pay_rec.attribute5 := p_attribute5;
	   end if;

	   if p_attribute6 is not null then
	      per_pay_rec.attribute6 := p_attribute6;
	   end if;

	   if p_attribute7 is not null then
	      per_pay_rec.attribute7 := p_attribute7;
	   end if;

	   if p_attribute8 is not null then
	      per_pay_rec.attribute8 := p_attribute8;
	   end if;

	   if p_attribute9 is not null then
	      per_pay_rec.attribute9 := p_attribute9;
	   end if;

	   if p_attribute10 is not null then
	      per_pay_rec.attribute10 := p_attribute10;
	   end if;

	   if p_attribute11 is not null then
	      per_pay_rec.attribute11 := p_attribute11;
	   end if;

	   if p_attribute12 is not null then
	      per_pay_rec.attribute12 := p_attribute12;
	   end if;

	   if p_attribute13 is not null then
	      per_pay_rec.attribute13 := p_attribute13;
	   end if;

	   if p_attribute14 is not null then
	      per_pay_rec.attribute14 := p_attribute14;
	   end if;

	   if p_attribute15 is not null then
	      per_pay_rec.attribute15 := p_attribute15;
	   end if;

	   if p_attribute16 is not null then
	      per_pay_rec.attribute16 := p_attribute16;
	   end if;

	   if p_attribute17 is not null then
	      per_pay_rec.attribute17 := p_attribute17;
	   end if;

	   if p_attribute18 is not null then
	      per_pay_rec.attribute18 := p_attribute18;
	   end if;

	   if p_attribute19 is not null then
	      per_pay_rec.attribute19 := p_attribute19;
	   end if;

	   if p_attribute20 is not null then
	      per_pay_rec.attribute20 := p_attribute20;
	   end if;

	 open c_pay_rec;
	 fetch c_pay_rec into l_pay_rec;

	 if c_pay_rec%found then
	  close c_pay_rec;

	  hr_maintain_proposal_api.update_salary_proposal
	   (p_pay_proposal_id            => l_pay_rec.pay_proposal_id
	   ,p_change_date                => l_pay_rec.change_date
	   ,p_comments                   => per_pay_rec.comments
	   ,p_next_sal_review_date       => per_pay_rec.next_sal_review_date
	   ,p_proposal_reason            => per_pay_rec.proposal_reason
	   ,p_proposed_salary_n          => nvl(per_pay_rec.proposed_salary_n , l_pay_rec.proposed_salary_n)
	   ,p_forced_ranking             => per_pay_rec.forced_ranking
	   ,p_performance_review_id      => per_pay_rec.performance_review_id
	   ,p_attribute_category         => per_pay_rec.attribute_category
	   ,p_attribute1                 => per_pay_rec.attribute1
	   ,p_attribute2                 => per_pay_rec.attribute2
	   ,p_attribute3                 => per_pay_rec.attribute3
	   ,p_attribute4                 => per_pay_rec.attribute4
	   ,p_attribute5                 => per_pay_rec.attribute5
	   ,p_attribute6                 => per_pay_rec.attribute6
	   ,p_attribute7                 => per_pay_rec.attribute7
	   ,p_attribute8                 => per_pay_rec.attribute8
	   ,p_attribute9                 => per_pay_rec.attribute9
	   ,p_attribute10                => per_pay_rec.attribute10
	   ,p_attribute11                => per_pay_rec.attribute11
	   ,p_attribute12                => per_pay_rec.attribute12
	   ,p_attribute13                => per_pay_rec.attribute13
	   ,p_attribute14                => per_pay_rec.attribute14
	   ,p_attribute15                => per_pay_rec.attribute15
	   ,p_attribute16                => per_pay_rec.attribute16
	   ,p_attribute17                => per_pay_rec.attribute17
	   ,p_attribute18                => per_pay_rec.attribute18
	   ,p_attribute19                => per_pay_rec.attribute19
	   ,p_attribute20                => per_pay_rec.attribute20
	   ,p_object_version_number      => l_pay_rec.object_version_number
	   ,p_multiple_components        => per_pay_rec.multiple_components
	   ,p_approved                   => per_pay_rec.approved
	   ,p_validate                   => FALSE
	   ,p_inv_next_sal_date_warning  => l_inv_next_sal_date_warning
	   ,p_proposed_salary_warning    => l_proposed_salary_warning
	   ,p_approved_warning           => l_approved_warning
	   ,p_payroll_warning            => l_payroll_warning
	   );
	 else
	  close c_pay_rec;

	  hr_maintain_proposal_api.insert_salary_proposal
	     (p_pay_proposal_id            => l_pay_proposal_id
	     ,p_assignment_id              => l_assignment_id
	     ,p_business_group_id          => per_pay_rec.business_group_id
	     ,p_change_date                => per_pay_rec.change_date
	     ,p_comments                   => per_pay_rec.comments
	     ,p_next_sal_review_date       => per_pay_rec.next_sal_review_date
	     ,p_proposal_reason            => per_pay_rec.proposal_reason
	     ,p_proposed_salary_n          => per_pay_rec.proposed_salary_n
	     ,p_forced_ranking             => per_pay_rec.forced_ranking
	     ,p_performance_review_id      => per_pay_rec.performance_review_id
	     ,p_attribute_category         => per_pay_rec.attribute_category
	     ,p_attribute1                 => per_pay_rec.attribute1
	     ,p_attribute2                 => per_pay_rec.attribute2
	     ,p_attribute3                 => per_pay_rec.attribute3
	     ,p_attribute4                 => per_pay_rec.attribute4
	     ,p_attribute5                 => per_pay_rec.attribute5
	     ,p_attribute6                 => per_pay_rec.attribute6
	     ,p_attribute7                 => per_pay_rec.attribute7
	     ,p_attribute8                 => per_pay_rec.attribute8
	     ,p_attribute9                 => per_pay_rec.attribute9
	     ,p_attribute10                => per_pay_rec.attribute10
	     ,p_attribute11                => per_pay_rec.attribute11
	     ,p_attribute12                => per_pay_rec.attribute12
	     ,p_attribute13                => per_pay_rec.attribute13
	     ,p_attribute14                => per_pay_rec.attribute14
	     ,p_attribute15                => per_pay_rec.attribute15
	     ,p_attribute16                => per_pay_rec.attribute16
	     ,p_attribute17                => per_pay_rec.attribute17
	     ,p_attribute18                => per_pay_rec.attribute18
	     ,p_attribute19                => per_pay_rec.attribute19
	     ,p_attribute20                => per_pay_rec.attribute20
	     ,p_object_version_number      => l_object_version_number
	     ,p_multiple_components        => nvl(per_pay_rec.multiple_components ,'N ')
	     ,p_approved                   => per_pay_rec.approved
	     ,p_validate                   => FALSE
	     ,p_element_entry_id           => l_element_entry_id
	     ,p_inv_next_sal_date_warning  => l_inv_next_sal_date_warning
	     ,p_proposed_salary_warning    => l_proposed_salary_warning
	     ,p_approved_warning           => l_approved_warning
	     ,p_payroll_warning            => l_payroll_warning
	     );

	end if;
	end;

--Bug 2868775 Pay Proposal

 procedure WATIF_TEMPORAL_LF_EVT_API(
    p_person_id                      in number
   ,p_business_group_id              in  number
   ,p_ler_id                         in  number
   ,p_temporal_lf_evt                in  varchar2
   ,p_lf_evt_ocrd_dt                 in  date
   ,p_effective_date                 in  date
   ,p_tpf_val                        in  number default null
   ,p_cmp_val                        in  number default null
   ,p_cmp_bnft_val                   in  number default null
   ,p_cmp_bal_val                    in  number default null
   ,p_hwf_val                        in  number default null
   ,p_hwf_bnft_val                   in  number default null
   )is
   --
   l_ASSIGNMENT_BUDGET_VALUE_ID   number;
   l_ptnl_ler_for_per_id   ben_ptnl_ler_for_per.ptnl_ler_for_per_id%type;
   l_object_version_number ben_ptnl_ler_for_per.object_version_number%type;
  l_mnl_dt date;
  l_dtctd_dt   date;
  l_procd_dt   date;
  l_unprocd_dt date;
  l_voidd_dt   date;
   --
   cursor c_assign is
    select paf.ASSIGNMENT_ID,
           paf.BUSINESS_GROUP_ID,
           paf.effective_start_date,
           paf.effective_end_date
    from   per_all_people_f  per,
           per_assignments_f paf
    where  per.person_id = p_person_id
    and   paf.assignment_type <> 'C'
    and    p_effective_date
           between per.effective_start_date
           and     per.effective_end_date
    and    per.business_group_id +0 = p_business_group_id
    and    per.person_id = paf.person_id
    and    paf.business_group_id +0 = p_business_group_id
    and    paf.primary_flag = 'Y'
    and    p_effective_date
           between paf.effective_start_date
           and     paf.effective_end_date;
   --
   l_assign        c_assign%rowtype;
   --
   cursor c_exist_fte is
    select pab.ASSIGNMENT_BUDGET_VALUE_ID
    from   per_all_people_f  per,
           per_assignments_f paf,
           per_assignment_budget_values pab
    where  per.person_id = p_person_id
    and   paf.assignment_type <> 'C'
    and    p_effective_date
           between per.effective_start_date
           and     per.effective_end_date
    and    per.business_group_id +0 = p_business_group_id
    and    per.person_id = paf.person_id -- paf.assignment_id = perassignment_id
    and    paf.business_group_id +0 = p_business_group_id
    and    paf.primary_flag = 'Y'
    and    p_effective_date
           between paf.effective_start_date
           and     paf.effective_end_date
    and    pab.business_group_id +0 = paf.business_group_id
    and    pab.assignment_id = paf.assignment_id
    and    pab.unit = 'FTE';
    --
 begin
   --
   hr_utility.set_location(' Entering: WATIF_AGE_TEMPORAL_LF_EVT_API' , 10);
   --
   -- Store the user entered temporal values in the globals.
   -- When profile with compensations factor attached is looked
   -- for eligibility this value will be used instead of
   -- values from the data base.Modules : bendrpar.pkb bendefct.pkb
   --
   if p_temporal_lf_evt = 'CMP' then
      --
      if p_cmp_val is not null then
         ben_whatif_elig.g_stat_comp := p_cmp_val;
      end if;
      --
      if p_cmp_bnft_val is not null then
         ben_whatif_elig.g_bnft_bal_comp := p_cmp_bnft_val;
      end if;
      --
      if p_cmp_bal_val is not null then
         ben_whatif_elig.g_bal_comp := p_cmp_bal_val;
      end if;
      --
   elsif p_temporal_lf_evt = 'HRW' then
      --
      if p_hwf_val is not null then
         ben_whatif_elig.g_bal_hwf_val := p_hwf_val;
      end if;
      --
      if p_hwf_bnft_val is not null then
         ben_whatif_elig.g_bnft_bal_hwf_val := p_hwf_bnft_val;
      end if;
      --
   end if;
   --
   /*
     Following code commented as the effective date is set for each
     case differently.
   if p_temporal_lf_evt = 'AGE' then
      -- update all the age determination codes to as of effective date
      update ben_age_fctr
      set    AGE_DET_CD = 'AED',
             AGE_DET_RL = null
      where  business_group_id = p_business_group_id;
   elsif p_temporal_lf_evt = 'LOS' then
      update ben_los_fctr
      set    los_det_cd = 'AED',
             los_det_rl = null
      where  business_group_id = p_business_group_id;
   elsif p_temporal_lf_evt = 'CMP' then
      update ben_comp_lvl_fctr
      set    comp_lvl_det_cd = 'AED',
             comp_lvl_det_rl = null
      where  business_group_id = p_business_group_id;
   end if; */
   if p_temporal_lf_evt = 'TPF' then
      --
      null;
      /* set use primary assignment flag = y, and other flags = n;
         if a record in the per_assignment_budget_values exists then
            change all non primary ones to 0;
            change primary one to the value entered by the user;
         else
            create a record in the per_assignment_budget values if
            a primary assignment exists else error out;
         end if;
      */
      -- 9999 do I need to worry about mn_pct_val etc.,
      update ben_pct_fl_tm_fctr
      set    USE_PRMRY_ASNT_ONLY_FLAG = 'Y',
             USE_SUM_OF_ALL_ASNTS_FLAG = 'N'
      where  business_group_id = p_business_group_id;
      --
      open c_exist_fte;
      --
      fetch c_exist_fte into l_ASSIGNMENT_BUDGET_VALUE_ID;
      if c_exist_fte%notfound then
         --
         open c_assign;
         null;
         fetch c_assign into l_assign;
         if c_assign%notfound then
            --
            fnd_message.set_name('BEN','BEN_91443_NO_ASSGN');
            fnd_message.raise_error;
            --
         else
            insert into per_assignment_budget_values_f
                 (assignment_budget_value_id
                 ,business_group_id
                 ,assignment_id
                 ,last_update_date
                 ,last_updated_by
                 ,last_update_login
                 ,created_by
                 ,creation_date
                 ,unit
                 ,value
                 ,effective_start_date
                 ,effective_end_date)
           values (
                 per_assignment_budget_values_s.nextval
                 ,l_assign.business_group_id
                 ,l_assign.assignment_id
                 ,sysdate
                 ,null
                 ,null
                 ,null
                 ,sysdate
                 ,'FTE'
                 ,p_tpf_val
                 ,l_assign.effective_start_date
                 ,l_assign.effective_end_date);
         end if;
          --
      else
         --
         update PER_ASSIGNMENT_BUDGET_VALUES_F
         set    VALUE = p_tpf_val
         where  ASSIGNMENT_BUDGET_VALUE_ID =  l_ASSIGNMENT_BUDGET_VALUE_ID;
         --
      end if;
      --
      close c_exist_fte;
      --
   end if;
   --
   -- Create potential life event
   --
   ben_ptnl_ler_for_per_api.create_ptnl_ler_for_per
              (p_validate                 => false
              ,p_ptnl_ler_for_per_id      => l_ptnl_ler_for_per_id
              ,p_lf_evt_ocrd_dt           => p_lf_evt_ocrd_dt
              ,p_ptnl_ler_for_per_stat_cd => 'DTCTD'
              ,p_ntfn_dt                  => trunc(sysdate)
              ,p_ler_id                   => p_ler_id
              ,p_person_id                => p_person_id
              ,p_business_group_id        => p_business_group_id
              ,p_object_version_number    => l_object_version_number
              ,p_effective_date           => p_effective_date
              ,p_dtctd_dt                 => p_effective_date);
   --
   hr_utility.set_location(' Leaving: WATIF_AGE_TEMPORAL_LF_EVT_API' , 10);
   --
 end;
--
 procedure p_init_watif_globals is
 begin
   --
   ben_whatif_elig.g_stat_comp         := null;
   ben_whatif_elig.g_bnft_bal_comp     := null;
   ben_whatif_elig.g_bal_comp          := null;
   ben_whatif_elig.g_bnft_bal_hwf_val  := null;
   ben_whatif_elig.g_bal_hwf_val       := null;
   --
 end;
 --
END ben_whatif_elig;

/
