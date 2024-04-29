--------------------------------------------------------
--  DDL for Package Body HR_PROCESS_CONTACT_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PROCESS_CONTACT_SS" AS
/* $Header: hrconwrs.pkb 120.5.12000000.4 2007/05/17 09:08:25 rachakra ship $*/
 --
 -- Package scope global variables.
 --
 g_package                   varchar2(30)   := 'HR_PROCESS_CONTACT_SS';
 g_data_error                exception;
 g_no_changes                exception;
 -- g_date_format  constant     varchar2(10):='RRRR/MM/DD';

 l_message_number            VARCHAR2(10);
 --
 -- Global cursor
 --
  CURSOR gc_get_cur_contact_data
         (p_contact_relationship_id      in number
         ,p_eff_date                     in date default trunc(sysdate)
          )
  IS
     SELECT
     contact_relationship_id,
     contact_type,
     comments,
     primary_contact_flag,
     third_party_pay_flag,
     bondholder_flag,
     date_start,
     start_life_reason_id,
     date_end,
     end_life_reason_id,
     rltd_per_rsds_w_dsgntr_flag,
     personal_flag,
     sequence_number,
     dependent_flag,
     beneficiary_flag,
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
     CONT_INFORMATION_CATEGORY,
     CONT_INFORMATION1  ,
     CONT_INFORMATION2  ,
     CONT_INFORMATION3  ,
     CONT_INFORMATION4  ,
     CONT_INFORMATION5  ,
     CONT_INFORMATION6  ,
     CONT_INFORMATION7  ,
     CONT_INFORMATION8  ,
     CONT_INFORMATION9  ,
     CONT_INFORMATION10 ,
     CONT_INFORMATION11 ,
     CONT_INFORMATION12 ,
     CONT_INFORMATION13 ,
     CONT_INFORMATION14 ,
     CONT_INFORMATION15 ,
     CONT_INFORMATION16 ,
     CONT_INFORMATION17 ,
     CONT_INFORMATION18 ,
     CONT_INFORMATION19 ,
     CONT_INFORMATION20 ,
     pcr.object_version_number
  FROM
     per_contact_relationships pcr
     ,per_all_people_f pap
     ,hr_comments        hc
  WHERE  pcr.contact_relationship_id = p_contact_relationship_id
    AND  pcr.contact_person_id = pap.person_id
    AND  p_eff_date BETWEEN pap.effective_start_date and pap.effective_end_date
    AND  hc.comment_id (+) = pap.comment_id;

-- ---------------------------------------------------------------------------
-- ---------------------- < p_del_cont_primary_addr> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will delete the address if the shared residence flag
--          is checked and primary address already exists.
-- ---------------------------------------------------------------------------
--
PROCEDURE p_del_cont_primary_addr
   (p_contact_relationship_id          in  number
   )
is
  --
  CURSOR c_cont_primary_addr
  IS
     SELECT addr.address_id
     FROM per_contact_relationships pcr
         ,per_addresses addr
     WHERE  pcr.contact_relationship_id = p_contact_relationship_id
       and  pcr.contact_person_id = addr.person_id
       and  trunc(sysdate) between addr.date_from
                               and nvl(addr.date_to, trunc(sysdate))
       and  addr.primary_flag  = 'Y'
       --
       -- Bug 2652114 : Do not delete the address if contact is already a employee
       -- otherwise his payroll will get affected.
       --
       and not exists
             (select null
              from per_all_assignments_f asg
              where trunc(sysdate) between asg.effective_start_date
                                       and asg.effective_end_date
                and asg.person_id = addr.person_id
                and asg.primary_flag = 'Y'
                and asg.assignment_type = 'E'
             );

  --
  l_cont_primary_addr c_cont_primary_addr%rowtype;
  l_proc varchar2(72) :=  g_package ||  'p_del_cont_primary_addr';

  --
begin
  --
  hr_utility.set_Location('Entering'||l_proc,5);
  OPEN c_cont_primary_addr;
  FETCH c_cont_primary_addr into l_cont_primary_addr;
  --
  IF c_cont_primary_addr%FOUND
  THEN
    --
    -- Delete the contacts primary address.
    -- As there is no API to do the delete we have to physically call the
    -- the delete statement.
    --
      hr_utility.set_Location('IF c_cont_primary_addr FOUND:'||l_proc,10);
    delete from per_addresses
      where address_id = l_cont_primary_addr.address_id;
    --
  END IF;
  --
  CLOSE c_cont_primary_addr;
  --
  hr_utility.set_Location('Exiting :'||l_proc,15);
end p_del_cont_primary_addr;
/* 999 Delete before arcsin
-- ----------------------------------------------------------------------------
-- |------------------------------< get_varchar2_value >------------------------|
-- ----------------------------------------------------------------------------
function get_varchar2_value
  (p_transaction_step_id       in      number
  ,p_name                      in      varchar2
  ) return varchar2 is

  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  l_proc   varchar2(72)  := g_package||'get_varchar2_value';
  l_insert boolean := false;
  l_name           hr_api_transaction_values.name%type;
  l_varchar2_value  varchar2(1000);
  --
  cursor csr_hatv is
    select hatv.varchar2_value
    from   hr_api_transaction_values hatv
    where  hatv.transaction_step_id = p_transaction_step_id
    and    hatv.name                = l_name;
  --
begin

  hr_utility.set_location('Entering:'|| l_proc, 5);
  -- upper the parameter name
  l_name := upper(p_name);
  -- select the transaction value details
  open csr_hatv;
  fetch csr_hatv
  into l_varchar2_value;

  if csr_hatv%notfound then
    -- parameter does not exist
    close csr_hatv;
    hr_utility.raise_error;
  end if;
  close csr_hatv;
  --
  return l_varchar2_value;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end get_varchar2_value;
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------------< get_number_value >------------------------|
-- ----------------------------------------------------------------------------
function get_number_value
  (p_transaction_step_id       in      number
  ,p_name                      in      varchar2
  ) return number is

  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  l_proc   varchar2(72)  := g_package||'get_number_value';
  l_insert boolean := false;
  l_name           hr_api_transaction_values.name%type;
  l_number_value  number;
  --
  cursor csr_hatv is
    select hatv.number_value
    from   hr_api_transaction_values hatv
    where  hatv.transaction_step_id = p_transaction_step_id
    and    hatv.name                = l_name;
  --
begin

  hr_utility.set_location('Entering:'|| l_proc, 5);
  -- upper the parameter name
  l_name := upper(p_name);
  -- select the transaction value details
  open csr_hatv;
  fetch csr_hatv
  into l_number_value;

  if csr_hatv%notfound then
    -- parameter does not exist
  hr_utility.set_location('If Parameter does not exist'|| l_proc, 10);
    close csr_hatv;
    hr_utility.raise_error;
  end if;
  close csr_hatv;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 15);
  return l_number_value;

end get_number_value;
--
-- ---------------------------------------------------------------------------
-- ---------------------- < get_contact_relationship_tt> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get which regions are changed in earlier save
--          in the current transaction.  This is invoked when a user click BACK
--          button to go back from the Review page to Update page to correct
--          typos or make further changes.  Hence, we need to use the item_type
--          item_key passed in to retrieve the transaction record.
--          This is also used when the user first time navigates to review page.
--          Based on the output of this procedure Review page layout is built.
--          Ex : If contacts and phone changed then both are shown, if Only
--          phone changed then shows phone data.
-- ---------------------------------------------------------------------------
--
PROCEDURE get_contact_regions_status_tt
   (p_item_type                       in  varchar2
   ,p_item_key                        in  varchar2
   ,p_activity_id                     in  varchar2
   ,p_trans_rec_count                 out nocopy number
   ,p_contact_changed                 out nocopy varchar2
   ,p_phone_changed                   out nocopy varchar2
   ,p_address_changed                 out nocopy varchar2
   ,p_second_address_changed          out nocopy varchar2
   ,p_parent_id                       out nocopy varchar2
   ,p_contact_person_id               out nocopy varchar2
   ,p_contact_relationship_id         out nocopy varchar2
   ,p_contact_operation               out nocopy varchar2
   ,p_shared_Residence_Flag           out nocopy varchar2
   ,p_save_mode                       out nocopy varchar2
   ,p_address_id                      out nocopy varchar2
   ,p_contact_step_id                 out nocopy varchar2
   ,p_phone_step_id                   out nocopy varchar2
   ,p_address_step_id                 out nocopy varchar2
   ,p_second_address_step_id          out nocopy varchar2
   ,p_first_name                      out nocopy varchar2
   ,p_last_name                       out nocopy varchar2
   ,p_contact_set                     in  varchar2
   )
is
  --
  l_trans_step_id                    number default null;
  l_trans_rec_count                  integer default 0;
  l_trans_step_ids       hr_util_web.g_varchar2_tab_type;
  l_trans_obj_vers_nums  hr_util_web.g_varchar2_tab_type;
  l_trans_step_rows                  NUMBER  ;
  ln_index                           number  default 0;
  l_id                               number;
  l_contact_step_id                  varchar2(100) := null;
  l_phone_step_id                    varchar2(100) := null;
  l_address_step_id                  varchar2(100) := null;
  l_second_address_step_id           varchar2(100) := null;
  l_addr_person_id                   varchar2(100) := null;
  -- 2447751 change starts
  l_first_name     PER_ALL_PEOPLE_F.FIRST_NAME%TYPE := null;
  l_last_name      PER_ALL_PEOPLE_F.LAST_NAME%TYPE := null;
  -- 2447751 change ends
  l_prmry_flag                       varchar2(100) := null;
  -- StartRegistration
  l_contact_set                      varchar2(5) := null;
  l_contact_operation                varchar2(100) := null;
  l_shared_Residence_Flag            varchar2(100) := null;
  l_local_shared_Residence_Flag      varchar2(100) := null;
  l_save_mode                        varchar2(100) := null;
  l_contact_person_id                varchar2(100) := null;
  l_proc   varchar2(72)  := g_package||'get_contact_regions_status_tt';

  --
  CURSOR c_get_names
  IS
     SELECT last_name, first_name
     from per_all_people_f
     WHERE  person_id = p_contact_person_id
       AND  trunc(sysdate) BETWEEN effective_start_date and effective_end_date;

  --
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_contact_changed   := 'N';
  p_phone_changed     := 'N';
  p_address_changed   := 'N';
--shdas
  p_second_address_changed   := 'N';
--shdas
  p_parent_id         := null;
  p_contact_person_id := null;
  p_contact_relationship_id  := null;
  p_address_id        := null;
  --
  -- For a given item key, there could be multiple transaction steps saved.
  -- Get whether transaction data is written for contacts, phone, address.
  --
  hr_transaction_api.get_transaction_step_info
             (p_item_type              => p_item_type
             ,p_item_key               => p_item_key
             ,p_activity_id            => p_activity_id
             ,p_transaction_step_id    => l_trans_step_ids
             ,p_object_version_number  => l_trans_obj_vers_nums
             ,p_rows                   => l_trans_step_rows);

  --
  -- ---------------------------------------------------------------------
  -- NOTE:We need to adjust the index which referrences l_trans_step_ids
  --    by 1 because that table was created with the index starts at 0
  --    in hr_transaction_api.get_transaction_step_info.
  -- ---------------------------------------------------------------------
  --
  ln_index := 0;
  --
  hr_utility.set_location('Entering For Loop:'||l_proc, 10);
  FOR j in 1..l_trans_step_rows
  LOOP
    -- StartRegistration
    -- Get the contact set from java and compare with the contact set id
    -- in each step.
    -- if the step doesnot match, ignore the step and go to next step.
    --
    begin
      l_contact_set := hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => l_trans_step_ids(ln_index)
        ,p_name                => 'P_CONTACT_SET');
    exception
     when others then
      --
      hr_utility.set_location('Exception:'||l_proc,555);
      l_contact_set := 1;
      --
    end;
    --
    if l_contact_set is null then
       --
        l_contact_set := 1;
       --
    end if;

   -- Save for later changes
   begin
      if l_contact_operation is null then
        l_contact_operation := hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => l_trans_step_ids(ln_index)
        ,p_name                => 'P_CONTACT_OPERATION');
      end if;
   /* fix sansingh , at this juncture check if
      l_contact_operation from earlier check is null, the same information is stored
       as P_PER_OR_CONTACT by PHONE NUMBER  region
       so obtain l_contact_operation from here
         */
      if l_contact_operation is null then
        l_contact_operation := hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => l_trans_step_ids(ln_index)
        ,p_name                => 'P_PER_OR_CONTACT');
      end if;
      /*
        fix sansingh if l_contact_operation is still null ,it means that only address region was get updated
         where the same values is saved as  P_CONTACT_OR_PERSON ,
         so obtain l_contact_operation from here
      */
      if l_contact_operation is null then
         l_contact_operation := hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => l_trans_step_ids(ln_index)
        ,p_name                => 'P_CONTACT_OR_PERSON');
      end if;
   exception
     when others then
      --
      hr_utility.set_location('Exception:'||l_proc,560);
      l_contact_operation := null ;
      --
    end;
    --
   -- Get the Save Mode
   begin
     --
       if l_save_mode is null then
       --
       l_save_mode :=  hr_transaction_api.get_varchar2_value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name                => 'P_SAVE_MODE');
       --
       end if;
     --
    exception
     when others then
      --
      hr_utility.set_location('Exception:'||l_proc,565);
      l_save_mode := null ;
      --
    end;
    --
    if l_contact_set is null then
       --
       l_contact_set := 1;
       --
    end if;
    --
    if  l_contact_set = p_contact_set then
      --
   -- Get Shared Residence Flag
   begin
     --
       --
       l_shared_Residence_Flag := hr_transaction_api.get_varchar2_value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name                => 'P_RLTD_PER_RSDS_W_DSGNTR_FLAG');
       --
       if l_shared_Residence_Flag is null then
          l_shared_Residence_Flag := l_local_shared_Residence_Flag ;
       else
          l_local_shared_Residence_Flag := l_shared_Residence_Flag;
       end if;
       --
    exception
     when others then
      --
      hr_utility.set_location('Exception:'||l_proc,570);
      l_shared_Residence_Flag := l_local_shared_Residence_Flag ;
      --
   end;

      -- Now check the transaction data for each region.
      -- If transaction data exists that means the region
      -- was modified.

      --
      -- Check Contact.
      --
      if (p_contact_changed = 'N') then
        --
        begin
         --l_id := hr_transaction_api.get_number_value
         l_id := get_number_value
                     (p_transaction_step_id => l_trans_step_ids(ln_index)
                     ,p_name                => 'P_CONTACT_PERSON_ID');

         p_contact_changed := 'Y';
         p_contact_person_id := to_char(l_id);
         l_contact_step_id   :=  l_trans_step_ids(ln_index);
         --
         l_id := get_number_value
                     (p_transaction_step_id => l_trans_step_ids(ln_index)
                     ,p_name                => 'P_CONTACT_RELATIONSHIP_ID');

         p_contact_relationship_id := to_char(l_id);
         --
         l_first_name        := hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => l_trans_step_ids(ln_index)
                                ,p_name                =>upper( 'p_first_name'));
         --
         l_last_name         := hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => l_trans_step_ids(ln_index)
                                ,p_name                =>upper( 'p_last_name'));
         --
        exception
          when others then
             null;
        end;
      end if;
      --
      -- Check phone
      --
      if (p_phone_changed = 'N') then
        --
        begin
         -- l_id := hr_transaction_api.get_number_value
         l_id := get_number_value
                     (p_transaction_step_id => l_trans_step_ids(ln_index)
                     ,p_name                => 'P_PHONE_ID');
         --
         p_phone_changed   := 'Y';

         l_phone_step_id   :=  l_trans_step_ids(ln_index);

         l_id := hr_transaction_api.get_number_value
                     (p_transaction_step_id => l_trans_step_ids(ln_index)
                     ,p_name                => 'P_PERSON_ID');
         --
         p_parent_id := to_char(l_id);
         l_contact_person_id := p_parent_id;
         if (p_contact_relationship_id is null) then
           l_id := get_number_value
                     (p_transaction_step_id => l_trans_step_ids(ln_index)
                     ,p_name                => 'P_CONTACT_RELATIONSHIP_ID');

             p_contact_relationship_id := to_char(l_id);
         end if;
         --
        exception
          when others then
             null;
        end;
      end if;

      --
      -- Check Address.
      --
      if (p_address_changed = 'N') then
        --
        begin
         l_id := get_number_value
                     (p_transaction_step_id => l_trans_step_ids(ln_index)
                     ,p_name                => 'P_ADDRESS_ID');
         l_prmry_flag         := hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => l_trans_step_ids(ln_index)
                                ,p_name                => 'P_PRIMARY_FLAG');

         if (l_prmry_flag = 'Y') then
            p_address_changed := 'Y';

            p_address_id      := to_char(l_id);
            l_address_step_id   :=  l_trans_step_ids(ln_index);

            l_addr_person_id := hr_transaction_api.get_number_value
                             (p_transaction_step_id => l_trans_step_ids(ln_index)
                             ,p_name                => 'P_PERSON_ID');
            l_contact_person_id := l_addr_person_id;
         end if;
         if (p_contact_relationship_id is null) then
           l_id := get_number_value
                     (p_transaction_step_id => l_trans_step_ids(ln_index)
                     ,p_name                => 'P_CONTACT_RELATIONSHIP_ID');
             p_contact_relationship_id := to_char(l_id);
         end if;
        exception
          when others then
             null;
        end;
        --
      end if;
      --
      if (p_second_address_changed = 'N') then
        --
        begin
         l_id := get_number_value
                     (p_transaction_step_id => l_trans_step_ids(ln_index)
                     ,p_name                => 'P_ADDRESS_ID');

         l_prmry_flag         := hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => l_trans_step_ids(ln_index)
                                ,p_name                => 'P_PRIMARY_FLAG');

         if (l_prmry_flag = 'N') then
            p_second_address_changed := 'Y';
            p_address_id      := to_char(l_id);

            l_second_address_step_id   :=  l_trans_step_ids(ln_index);

            l_addr_person_id := hr_transaction_api.get_number_value
                             (p_transaction_step_id => l_trans_step_ids(ln_index)
                             ,p_name                => 'P_PERSON_ID');
            l_contact_person_id := l_addr_person_id;
         end if;
         if (p_contact_relationship_id is null) then
           l_id := get_number_value
                     (p_transaction_step_id => l_trans_step_ids(ln_index)
                     ,p_name                => 'P_CONTACT_RELATIONSHIP_ID');

             p_contact_relationship_id := to_char(l_id);
         end if;
        exception
          when others then
             null;
        end;
        --
      end if;

    end if; -- end check for current contact set
    --
    ln_index := ln_index + 1;
    l_trans_rec_count  := l_trans_rec_count  + 1;
    p_second_address_step_id  := l_second_address_step_id;
    p_address_step_id  := l_address_step_id;
    p_contact_step_id  := l_contact_step_id;
    p_phone_step_id    := l_phone_step_id;
    p_contact_person_id := nvl(nvl(p_contact_person_id, l_addr_person_id), p_parent_id);
    --
    if (p_contact_person_id > 0) and (p_contact_changed = 'N') then
         --
         -- It could be possible that only address or phone data was
         -- updated, so we need to pass back the first name, last name to display as
         -- context.
         --
         open  c_get_names;
         fetch c_get_names into l_last_name, l_first_name;
         close c_get_names;
         --
    end if;
    --
  END LOOP;

  --
  p_last_name         := l_last_name;
  p_first_name        := l_first_name;
  p_contact_operation := l_contact_operation ;
  p_save_mode         := l_save_mode;
  p_shared_residence_flag := l_shared_residence_flag;
  p_trans_rec_count := l_trans_rec_count;

  hr_utility.set_location('Exiting For Loop:'||l_proc, 20);
  /* fix sansingh
   before leaving check if p_contact_person_id is populated or not
   if only phone or address region is updated , p_contact_person_id
   would not be populated , it would be actually stored as p_person_id in that case for the transaction step
   so populating p_contact_person_id with the same
  */
  if (p_contact_person_id is null) then
    p_contact_person_id := l_contact_person_id;
  end if;

  hr_utility.set_location('Exiting:'||l_proc, 25);
  --
EXCEPTION
   WHEN OTHERS THEN
      fnd_message.set_name('PER', SQLERRM ||' '||to_char(SQLCODE));
      hr_utility.set_location('Exception OTHERS:'||l_proc,555);
      hr_utility.raise_error;
  --

end get_contact_regions_status_tt;

--
-- ---------------------------------------------------------------------------
-- ---------------------- < get_contact_relationship_tt> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are saved earlier
--          in the current transaction.  This is invoked when a user click BACK
--          button to go back from the Review page to Update page to correct
--          typos or make further changes.  Hence, we need to use the item_type
--          item_key passed in to retrieve the transaction record.
--          This is an overloaded version.
-- ---------------------------------------------------------------------------
--
PROCEDURE get_contact_relationship_tt
   (p_item_type                       in  varchar2
   ,p_item_key                        in  varchar2
   ,p_activity_id                     in  number
   -- 9999 What is this parameter.
   ,p_trans_rec_count                 out nocopy number
   ,p_effective_date                  out nocopy date
   -- 9999 What is this parameter.
   ,p_attribute_update_mode           out nocopy varchar2
   ,P_CONTACT_RELATIONSHIP_ID         out nocopy NUMBER
   ,P_CONTACT_TYPE                    out nocopy VARCHAR2
   ,P_COMMENTS                        out nocopy VARCHAR2
   ,P_PRIMARY_CONTACT_FLAG            out nocopy VARCHAR2
   ,P_THIRD_PARTY_PAY_FLAG            out nocopy VARCHAR2
   ,p_bondholder_flag                 out nocopy varchar2
   ,p_date_start                      out nocopy date
   ,p_start_life_reason_id            out nocopy number
   ,p_date_end                        out nocopy date
   ,p_end_life_reason_id              out nocopy number
   ,p_rltd_per_rsds_w_dsgntr_flag      out nocopy varchar2
   ,p_personal_flag                    out nocopy varchar2
   ,p_sequence_number                  out nocopy number
   ,p_dependent_flag                   out nocopy varchar2
   ,p_beneficiary_flag                 out nocopy varchar2
   ,p_cont_attribute_category          out nocopy varchar2
   ,p_cont_attribute1                  out nocopy varchar2
   ,p_cont_attribute2                  out nocopy varchar2
   ,p_cont_attribute3                  out nocopy varchar2
   ,p_cont_attribute4                  out nocopy varchar2
   ,p_cont_attribute5                  out nocopy varchar2
   ,p_cont_attribute6                  out nocopy varchar2
   ,p_cont_attribute7                  out nocopy varchar2
   ,p_cont_attribute8                  out nocopy varchar2
   ,p_cont_attribute9                  out nocopy varchar2
   ,p_cont_attribute10                  out nocopy varchar2
   ,p_cont_attribute11                  out nocopy varchar2
   ,p_cont_attribute12                  out nocopy varchar2
   ,p_cont_attribute13                  out nocopy varchar2
   ,p_cont_attribute14                  out nocopy varchar2
   ,p_cont_attribute15                  out nocopy varchar2
   ,p_cont_attribute16                  out nocopy varchar2
   ,p_cont_attribute17                  out nocopy varchar2
   ,p_cont_attribute18                  out nocopy varchar2
   ,p_cont_attribute19                  out nocopy varchar2
   ,p_cont_attribute20                  out nocopy varchar2
   ,P_CONT_INFORMATION_CATEGORY         out nocopy varchar2
   ,P_CONT_INFORMATION1                 out nocopy varchar2
   ,P_CONT_INFORMATION2                 out nocopy varchar2
   ,P_CONT_INFORMATION3                 out nocopy varchar2
   ,P_CONT_INFORMATION4                 out nocopy varchar2
   ,P_CONT_INFORMATION5                 out nocopy varchar2
   ,P_CONT_INFORMATION6                 out nocopy varchar2
   ,P_CONT_INFORMATION7                 out nocopy varchar2
   ,P_CONT_INFORMATION8                 out nocopy varchar2
   ,P_CONT_INFORMATION9                 out nocopy varchar2
   ,P_CONT_INFORMATION10                out nocopy varchar2
   ,P_CONT_INFORMATION11                out nocopy varchar2
   ,P_CONT_INFORMATION12                out nocopy varchar2
   ,P_CONT_INFORMATION13                out nocopy varchar2
   ,P_CONT_INFORMATION14                out nocopy varchar2
   ,P_CONT_INFORMATION15                out nocopy varchar2
   ,P_CONT_INFORMATION16                out nocopy varchar2
   ,P_CONT_INFORMATION17                out nocopy varchar2
   ,P_CONT_INFORMATION18                out nocopy varchar2
   ,P_CONT_INFORMATION19                out nocopy varchar2
   ,P_CONT_INFORMATION20                out nocopy varchar2
   ,p_object_version_number             out nocopy number
   -- 9999 What is this parameter.
   ,p_review_proc_call                    out nocopy varchar2
)is

  l_transaction_step_id        number default null;
  l_trans_obj_vers_num         number default null;
  l_transaction_rec_count      integer default 0;
  l_proc   varchar2(72)  := g_package||'get_contact_relationship_tt';

begin
    hr_utility.set_location('Entering:'||l_proc, 5);
  -- ------------------------------------------------------------------
  -- Check if there are any transaction rec already saved for the current
  -- transaction. This is used for re-display the Update page when a user
  -- clicks the Back button on the Review page to go back to the Update page
  -- to make further changes or to correct errors.
  -----------------------------------------------------------------------------
  hr_transaction_api.get_transaction_step_info
     (p_item_type              => p_item_type
     ,p_item_key               => p_item_key
     ,p_activity_id            => p_activity_id
     ,p_transaction_step_id    => l_transaction_step_id
     ,p_object_version_number  => l_trans_obj_vers_num);


  IF l_transaction_step_id > 0
  THEN
     hr_utility.set_location('l_transaction_step_id > 0:'||l_proc, 10);
     l_transaction_rec_count := 1;
  ELSE
     hr_utility.set_location('l_transaction_step_id < 0:'||l_proc, 10);
     l_transaction_rec_count := 0;
     return;
  END IF;
  --
  -- -------------------------------------------------------------------
  -- There are some changes made earlier in the transaction.
  -- Retrieve the data and return to caller.
  -- -------------------------------------------------------------------
  --
  -- Now get the transaction data for the given step
  get_contact_relationship_tt(
    p_transaction_step_id          => l_transaction_step_id
   ,p_effective_date               => p_effective_date
   -- 9999 What is this parameter
   ,p_attribute_update_mode        => p_attribute_update_mode
   ,P_CONTACT_RELATIONSHIP_ID      =>  P_CONTACT_RELATIONSHIP_ID
   ,P_CONTACT_TYPE                 =>  P_CONTACT_TYPE
   ,P_COMMENTS                     =>  P_COMMENTS
   ,P_PRIMARY_CONTACT_FLAG         =>  P_PRIMARY_CONTACT_FLAG
   ,P_THIRD_PARTY_PAY_FLAG         =>  P_THIRD_PARTY_PAY_FLAG
   ,p_bondholder_flag              =>  p_bondholder_flag
   ,p_date_start                   =>  p_date_start
   ,p_start_life_reason_id         =>  p_start_life_reason_id
   ,p_date_end                     =>  p_date_end
   ,p_end_life_reason_id           =>  p_end_life_reason_id
   ,p_rltd_per_rsds_w_dsgntr_flag  =>  p_rltd_per_rsds_w_dsgntr_flag
   ,p_personal_flag                =>  p_personal_flag
   ,p_sequence_number              =>  p_sequence_number
   ,p_dependent_flag               =>  p_dependent_flag
   ,p_beneficiary_flag             =>  p_beneficiary_flag
   ,p_cont_attribute_category      =>  p_cont_attribute_category
   ,p_cont_attribute1              =>  p_cont_attribute1
   ,p_cont_attribute2              =>  p_cont_attribute2
   ,p_cont_attribute3              =>  p_cont_attribute3
   ,p_cont_attribute4              =>  p_cont_attribute4
   ,p_cont_attribute5              =>  p_cont_attribute5
   ,p_cont_attribute6              =>  p_cont_attribute6
   ,p_cont_attribute7              =>  p_cont_attribute7
   ,p_cont_attribute8              =>  p_cont_attribute8
   ,p_cont_attribute9              =>  p_cont_attribute9
   ,p_cont_attribute10             =>  p_cont_attribute10
   ,p_cont_attribute11             =>  p_cont_attribute11
   ,p_cont_attribute12             =>  p_cont_attribute12
   ,p_cont_attribute13             =>  p_cont_attribute13
   ,p_cont_attribute14             =>  p_cont_attribute14
   ,p_cont_attribute15             =>  p_cont_attribute15
   ,p_cont_attribute16             =>  p_cont_attribute16
   ,p_cont_attribute17             =>  p_cont_attribute17
   ,p_cont_attribute18             =>  p_cont_attribute18
   ,p_cont_attribute19             =>  p_cont_attribute19
   ,p_cont_attribute20             =>  p_cont_attribute20
   ,p_object_version_number        =>  p_object_version_number
   ,P_CONT_INFORMATION_CATEGORY    => P_CONT_INFORMATION_CATEGORY
   ,P_CONT_INFORMATION1            => P_CONT_INFORMATION1
   ,P_CONT_INFORMATION2            => P_CONT_INFORMATION2
   ,P_CONT_INFORMATION3            => P_CONT_INFORMATION3
   ,P_CONT_INFORMATION4            => P_CONT_INFORMATION4
   ,P_CONT_INFORMATION5            => P_CONT_INFORMATION5
   ,P_CONT_INFORMATION6            => P_CONT_INFORMATION6
   ,P_CONT_INFORMATION7            => P_CONT_INFORMATION7
   ,P_CONT_INFORMATION8            => P_CONT_INFORMATION8
   ,P_CONT_INFORMATION9            => P_CONT_INFORMATION9
   ,P_CONT_INFORMATION10           => P_CONT_INFORMATION10
   ,P_CONT_INFORMATION11           => P_CONT_INFORMATION11
   ,P_CONT_INFORMATION12           => P_CONT_INFORMATION12
   ,P_CONT_INFORMATION13           => P_CONT_INFORMATION13
   ,P_CONT_INFORMATION14           => P_CONT_INFORMATION14
   ,P_CONT_INFORMATION15           => P_CONT_INFORMATION15
   ,P_CONT_INFORMATION16           => P_CONT_INFORMATION16
   ,P_CONT_INFORMATION17           => P_CONT_INFORMATION17
   ,P_CONT_INFORMATION18           => P_CONT_INFORMATION18
   ,P_CONT_INFORMATION19           => P_CONT_INFORMATION19
   ,P_CONT_INFORMATION20           => P_CONT_INFORMATION20
   ,p_review_proc_call             => p_review_proc_call
   );
 --
 p_trans_rec_count := l_transaction_rec_count;
 hr_utility.set_location('Exiting:'||l_proc, 15);
 --
EXCEPTION
   WHEN g_data_error THEN
      hr_utility.set_location('Exception:g_data_error'||l_proc,555);
      RAISE;


END get_contact_relationship_tt;
--
-- ---------------------------------------------------------------------------
-- ---------------------- < get_contact_relationship_tt> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are pending for
--          approval in workflow for a transaction step id.
--          This is the procedure which does the actual work.
-- ---------------------------------------------------------------------------
procedure get_contact_relationship_tt
   (p_transaction_step_id             in  number
   ,p_effective_date                  out nocopy date
   -- 9999 What is this paramter.
   ,p_attribute_update_mode           out nocopy varchar2
   ,P_CONTACT_RELATIONSHIP_ID         out nocopy NUMBER
   ,P_CONTACT_TYPE                    out nocopy VARCHAR2
   ,P_COMMENTS                        out nocopy VARCHAR2
   ,P_PRIMARY_CONTACT_FLAG            out nocopy VARCHAR2
   ,P_THIRD_PARTY_PAY_FLAG            out nocopy VARCHAR2
   ,p_bondholder_flag                 out nocopy varchar2
   ,p_date_start                      out nocopy date
   ,p_start_life_reason_id            out nocopy number
   ,p_date_end                        out nocopy date
   ,p_end_life_reason_id              out nocopy number
   ,p_rltd_per_rsds_w_dsgntr_flag      out nocopy varchar2
   ,p_personal_flag                    out nocopy varchar2
   ,p_sequence_number                  out nocopy number
   ,p_dependent_flag                   out nocopy varchar2
   ,p_beneficiary_flag                 out nocopy varchar2
   ,p_cont_attribute_category          out nocopy varchar2
   ,p_cont_attribute1                  out nocopy varchar2
   ,p_cont_attribute2                  out nocopy varchar2
   ,p_cont_attribute3                  out nocopy varchar2
   ,p_cont_attribute4                  out nocopy varchar2
   ,p_cont_attribute5                  out nocopy varchar2
   ,p_cont_attribute6                  out nocopy varchar2
   ,p_cont_attribute7                  out nocopy varchar2
   ,p_cont_attribute8                  out nocopy varchar2
   ,p_cont_attribute9                  out nocopy varchar2
   ,p_cont_attribute10                  out nocopy varchar2
   ,p_cont_attribute11                  out nocopy varchar2
   ,p_cont_attribute12                  out nocopy varchar2
   ,p_cont_attribute13                  out nocopy varchar2
   ,p_cont_attribute14                  out nocopy varchar2
   ,p_cont_attribute15                  out nocopy varchar2
   ,p_cont_attribute16                  out nocopy varchar2
   ,p_cont_attribute17                  out nocopy varchar2
   ,p_cont_attribute18                  out nocopy varchar2
   ,p_cont_attribute19                  out nocopy varchar2
   ,p_cont_attribute20                  out nocopy varchar2
   ,P_CONT_INFORMATION_CATEGORY         out nocopy varchar2
   ,P_CONT_INFORMATION1                 out nocopy varchar2
   ,P_CONT_INFORMATION2                 out nocopy varchar2
   ,P_CONT_INFORMATION3                 out nocopy varchar2
   ,P_CONT_INFORMATION4                 out nocopy varchar2
   ,P_CONT_INFORMATION5                 out nocopy varchar2
   ,P_CONT_INFORMATION6                 out nocopy varchar2
   ,P_CONT_INFORMATION7                 out nocopy varchar2
   ,P_CONT_INFORMATION8                 out nocopy varchar2
   ,P_CONT_INFORMATION9                 out nocopy varchar2
   ,P_CONT_INFORMATION10                out nocopy varchar2
   ,P_CONT_INFORMATION11                out nocopy varchar2
   ,P_CONT_INFORMATION12                out nocopy varchar2
   ,P_CONT_INFORMATION13                out nocopy varchar2
   ,P_CONT_INFORMATION14                out nocopy varchar2
   ,P_CONT_INFORMATION15                out nocopy varchar2
   ,P_CONT_INFORMATION16                out nocopy varchar2
   ,P_CONT_INFORMATION17                out nocopy varchar2
   ,P_CONT_INFORMATION18                out nocopy varchar2
   ,P_CONT_INFORMATION19                out nocopy varchar2
   ,P_CONT_INFORMATION20                out nocopy varchar2
   ,p_object_version_number             out nocopy number
   -- 9999 What is this parameter.
   ,p_review_proc_call                out nocopy varchar2
)is
 --
 --
   l_proc   varchar2(72)  := g_package||'get_contact_relationship_tt';

BEGIN
  --
  p_effective_date:=
    hr_transaction_api.get_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_EFFECTIVE_DATE');
  --
  hr_utility.set_location('P_EFFECTIVE_DATE', 2222);
  P_ATTRIBUTE_UPDATE_MODE := 'update';
  /*
  -- 9999 delete it later if not required.
  p_attribute_update_mode :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE_UPDATE_MODE');
  hr_utility.set_location('P_ATTRIBUTE_UPDATE_MODE', 2222);
  */
  --
  P_CONTACT_RELATIONSHIP_ID  :=
      hr_transaction_api.get_NUMBER_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_CONTACT_RELATIONSHIP_ID');
  hr_utility.set_location('P_CONTACT_RELATIONSHIP_ID', 2222);
  --
  P_CONTACT_TYPE  :=
      hr_transaction_api.get_VARCHAR2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_CONTACT_TYPE');
  hr_utility.set_location('P_CONTACT_TYPE', 2222);
  --
  P_COMMENTS  :=
      hr_transaction_api.get_VARCHAR2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_COMMENTS');
  hr_utility.set_location('P_COMMENTS', 2222);
  --
  P_PRIMARY_CONTACT_FLAG  :=
      hr_transaction_api.get_VARCHAR2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_PRIMARY_CONTACT_FLAG');
  hr_utility.set_location('P_PRIMARY_CONTACT_FLAG', 2222);
  --
  P_THIRD_PARTY_PAY_FLAG  :=
      hr_transaction_api.get_VARCHAR2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_THIRD_PARTY_PAY_FLAG');
  hr_utility.set_location('P_THIRD_PARTY_PAY_FLAG', 2222);
  --
  p_bondholder_flag  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_BONDHOLDER_FLAG');
  hr_utility.set_location('P_BONDHOLDER_FLAG', 2222);
  --
  p_date_start  :=
      hr_transaction_api.get_date_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_DATE_START');
  hr_utility.set_location('P_DATE_START', 2222);
  --
  p_start_life_reason_id  :=
      hr_transaction_api.get_number_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_START_LIFE_REASON_ID');
  hr_utility.set_location('P_START_LIFE_REASON_ID', 2222);
  --
  p_date_end  :=
      hr_transaction_api.get_date_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_DATE_END');
  hr_utility.set_location('P_DATE_END', 2222);
  --
  p_end_life_reason_id  :=
      hr_transaction_api.get_number_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_END_LIFE_REASON_ID');
  hr_utility.set_location('P_END_LIFE_REASON_ID', 2222);
  --
  p_rltd_per_rsds_w_dsgntr_flag  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_RLTD_PER_RSDS_W_DSGNTR_FLAG');
  hr_utility.set_location('P_RLTD_PER_RSDS_W_DSGNTR_FLAG', 2222);
  --
  p_personal_flag  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_PERSONAL_FLAG');
  hr_utility.set_location('P_PERSONAL_FLAG', 2222);
  --
  p_sequence_number  :=
      hr_transaction_api.get_number_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_SEQUENCE_NUMBER');
  hr_utility.set_location('P_SEQUENCE_NUMBER', 2222);
  --
  p_dependent_flag  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_DEPENDENT_FLAG');
  hr_utility.set_location('P_DEPENDENT_FLAG', 2222);
  --
  p_beneficiary_flag  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_BENEFICIARY_FLAG');
  hr_utility.set_location('P_BENEFICIARY_FLAG', 2222);
  --
  p_cont_attribute_category  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_CONT_ATTRIBUTE_CATEGORY');
  hr_utility.set_location('P_CONT_ATTRIBUTE_CATEGORY', 2222);
  --
  p_cont_attribute1  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_CONT_ATTRIBUTE1');
  hr_utility.set_location('P_CONT_ATTRIBUTE1', 2222);
  --
  p_cont_attribute2  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_CONT_ATTRIBUTE2');
  hr_utility.set_location('P_CONT_ATTRIBUTE2', 2222);
  --
  p_cont_attribute3  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_CONT_ATTRIBUTE3');
  hr_utility.set_location('P_CONT_ATTRIBUTE3', 2222);
  --
  p_cont_attribute4  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_CONT_ATTRIBUTE4');
  hr_utility.set_location('P_CONT_ATTRIBUTE4', 2222);
  --
  p_cont_attribute5  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_CONT_ATTRIBUTE5');
  hr_utility.set_location('P_CONT_ATTRIBUTE5', 2222);
  --
  p_cont_attribute6  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_CONT_ATTRIBUTE6');
  hr_utility.set_location('P_CONT_ATTRIBUTE6', 2222);
  --
  p_cont_attribute7  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_CONT_ATTRIBUTE7');
  hr_utility.set_location('P_CONT_ATTRIBUTE7', 2222);
  --
  p_cont_attribute8  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_CONT_ATTRIBUTE8');
  hr_utility.set_location('P_CONT_ATTRIBUTE8', 2222);
  --
  p_cont_attribute9  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_CONT_ATTRIBUTE9');
  hr_utility.set_location('P_CONT_ATTRIBUTE9', 2222);
  --
  p_cont_attribute10  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_CONT_ATTRIBUTE10');
  hr_utility.set_location('P_CONT_ATTRIBUTE10', 2222);
  --
  p_cont_attribute11  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_CONT_ATTRIBUTE11');
  hr_utility.set_location('P_CONT_ATTRIBUTE11', 2222);
  --
  p_cont_attribute12  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_CONT_ATTRIBUTE12');
  hr_utility.set_location('P_CONT_ATTRIBUTE12', 2222);
  --
  p_cont_attribute13  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_CONT_ATTRIBUTE13');
  hr_utility.set_location('P_CONT_ATTRIBUTE13', 2222);
  --
  p_cont_attribute14  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_CONT_ATTRIBUTE14');
  hr_utility.set_location('P_CONT_ATTRIBUTE14', 2222);
  --
  p_cont_attribute15  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_CONT_ATTRIBUTE15');
  hr_utility.set_location('P_CONT_ATTRIBUTE15', 2222);
  --
  p_cont_attribute16  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_CONT_ATTRIBUTE16');
  hr_utility.set_location('P_CONT_ATTRIBUTE16', 2222);
  --
  p_cont_attribute17  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_CONT_ATTRIBUTE17');
  hr_utility.set_location('P_CONT_ATTRIBUTE17', 2222);
  --
  p_cont_attribute18  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_CONT_ATTRIBUTE18');
  hr_utility.set_location('P_CONT_ATTRIBUTE18', 2222);
  --
  p_cont_attribute19  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_CONT_ATTRIBUTE19');
  hr_utility.set_location('P_CONT_ATTRIBUTE19', 2222);
  --
  p_cont_attribute20  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_CONT_ATTRIBUTE20');
  hr_utility.set_location('p_cont_attribute20', 2222);
  --
  p_object_version_number  :=
      hr_transaction_api.get_number_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_OBJECT_VERSION_NUMBER');
  hr_utility.set_location('p_object_version_number', 2222);
  --
  p_review_proc_call :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_REVIEW_PROC_CALL');
  hr_utility.set_location('P_REVIEW_PROC_CALL', 2222);
  --
  --
  P_CONT_INFORMATION_CATEGORY  :=
      hr_transaction_api.get_VARCHAR2_value
            (p_transaction_step_id => p_transaction_step_id
            ,p_name                => 'P_CONT_INFORMATION_CATEGORY');
  --
  P_CONT_INFORMATION1  :=
      hr_transaction_api.get_VARCHAR2_value
            (p_transaction_step_id => p_transaction_step_id
            ,p_name                => 'P_CONT_INFORMATION1');
  --
  P_CONT_INFORMATION2  :=
      hr_transaction_api.get_VARCHAR2_value
            (p_transaction_step_id => p_transaction_step_id
            ,p_name                => 'P_CONT_INFORMATION2');
  --
  P_CONT_INFORMATION3  :=
      hr_transaction_api.get_VARCHAR2_value
            (p_transaction_step_id => p_transaction_step_id
            ,p_name                => 'P_CONT_INFORMATION3');
  --
  P_CONT_INFORMATION4  :=
      hr_transaction_api.get_VARCHAR2_value
            (p_transaction_step_id => p_transaction_step_id
            ,p_name                => 'P_CONT_INFORMATION4');
  --
  P_CONT_INFORMATION5  :=
      hr_transaction_api.get_VARCHAR2_value
            (p_transaction_step_id => p_transaction_step_id
            ,p_name                => 'P_CONT_INFORMATION5');
  --
  P_CONT_INFORMATION6  :=
       hr_transaction_api.get_VARCHAR2_value
            (p_transaction_step_id => p_transaction_step_id
            ,p_name                => 'P_CONT_INFORMATION6');
  --
  P_CONT_INFORMATION7  :=
       hr_transaction_api.get_VARCHAR2_value
            (p_transaction_step_id => p_transaction_step_id
            ,p_name                => 'P_CONT_INFORMATION7');
  --
  P_CONT_INFORMATION8  :=
       hr_transaction_api.get_VARCHAR2_value
            (p_transaction_step_id => p_transaction_step_id
            ,p_name                => 'P_CONT_INFORMATION8');
  --
  P_CONT_INFORMATION9  :=
       hr_transaction_api.get_VARCHAR2_value
            (p_transaction_step_id => p_transaction_step_id
            ,p_name                => 'P_CONT_INFORMATION9');
  --
  P_CONT_INFORMATION10  :=
       hr_transaction_api.get_VARCHAR2_value
            (p_transaction_step_id => p_transaction_step_id
            ,p_name                => 'P_CONT_INFORMATION10');
   --
   P_CONT_INFORMATION11  :=
       hr_transaction_api.get_VARCHAR2_value
            (p_transaction_step_id => p_transaction_step_id
            ,p_name                => 'P_CONT_INFORMATION11');
   --
   P_CONT_INFORMATION12  :=
        hr_transaction_api.get_VARCHAR2_value
            (p_transaction_step_id => p_transaction_step_id
            ,p_name                => 'P_CONT_INFORMATION12');
   --
   P_CONT_INFORMATION13  :=
        hr_transaction_api.get_VARCHAR2_value
            (p_transaction_step_id => p_transaction_step_id
            ,p_name                => 'P_CONT_INFORMATION13');
   --
   P_CONT_INFORMATION14  :=
        hr_transaction_api.get_VARCHAR2_value
            (p_transaction_step_id => p_transaction_step_id
            ,p_name                => 'P_CONT_INFORMATION14');
   --
   P_CONT_INFORMATION15  :=
        hr_transaction_api.get_VARCHAR2_value
            (p_transaction_step_id => p_transaction_step_id
            ,p_name                => 'P_CONT_INFORMATION15');
   --
   P_CONT_INFORMATION16  :=
        hr_transaction_api.get_VARCHAR2_value
            (p_transaction_step_id => p_transaction_step_id
            ,p_name                => 'P_CONT_INFORMATION16');
   --
   P_CONT_INFORMATION17  :=
        hr_transaction_api.get_VARCHAR2_value
            (p_transaction_step_id => p_transaction_step_id
            ,p_name                => 'P_CONT_INFORMATION17');
   --
   P_CONT_INFORMATION18  :=
        hr_transaction_api.get_VARCHAR2_value
            (p_transaction_step_id => p_transaction_step_id
            ,p_name                => 'P_CONT_INFORMATION18');
   --
   P_CONT_INFORMATION19  :=
        hr_transaction_api.get_VARCHAR2_value
            (p_transaction_step_id => p_transaction_step_id
            ,p_name                => 'P_CONT_INFORMATION19');
   --
   P_CONT_INFORMATION20  :=
        hr_transaction_api.get_VARCHAR2_value
            (p_transaction_step_id => p_transaction_step_id
            ,p_name                => 'P_CONT_INFORMATION20');
   --
hr_utility.set_location('Exiting:'||l_proc, 15);
EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('Exception:'||l_proc,555);
      fnd_message.set_name('PER', SQLERRM ||' '||to_char(SQLCODE));
      hr_utility.raise_error;
      --RAISE;

END get_contact_relationship_tt;

-- ----------------------------------------------------------------------------
 -- |-------------------------< check_ni_unique>------------------------|
 -- ----------------------------------------------------------------------------
 -- this procedure checks if the SSN entered is duplicate or not.If value of profile
 -- HR: NI Unique Error or Warning is 'Warning' then warning is raised for duplicate
 -- SSN entered else if value is 'Error' or null then error is raised.

procedure check_ni_unique(
p_national_identifier          in        varchar2    default null
,p_business_group_id           in        number
,p_person_id                   in        number
,p_ni_duplicate_warn_or_err    out nocopy       varchar2) is

 l_warning                           boolean default false;
 l_warning_or_error                  varchar2(20);
 l_proc   varchar2(72)  := g_package||'check_ni_unique';

begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.clear_message();
  hr_utility.clear_warning();


  l_warning_or_error := fnd_profile.value('PER_NI_UNIQUE_ERROR_WARNING');
  if l_warning_or_error is null then
    l_warning_or_error:= 'ERROR';
    hr_utility.set_location('l_warning_or_error:'||l_proc,10 );
  end if;

  if p_national_identifier is not null then

      hr_utility.set_location('p_national_identifier is not null:'||l_proc,15 );
      hr_ni_chk_pkg.check_ni_unique(p_national_identifier => p_national_identifier
                                   ,p_person_id => p_person_id
                                   ,p_business_group_id => p_business_group_id
                                   ,p_raise_error_or_warning => l_warning_or_error);


  l_warning := hr_utility.check_warning();
   if l_warning then
    hr_utility.set_location('if l_warning:'||l_proc,20);
    p_ni_duplicate_warn_or_err := 'WARNING';
   else
    hr_utility.set_location('else part of if l_warning:'||l_proc,25);
    p_ni_duplicate_warn_or_err := 'NONE';
   end if;
  end if;

  hr_utility.set_location('Exiting:'||l_proc, 30);
   exception
   when others then
   hr_utility.set_location('Exception:'||l_proc,555);
  if not l_warning then
    p_ni_duplicate_warn_or_err := 'ERROR';
    raise;
  end if;

  end check_ni_unique;
--
--
--

--
-- 99999
-- In update_person of hrperwrs.pkb p_login_person_id,
-- p_process_section_name, p_action_type, p_review_page_region_code
-- are there what is the significance of it.
--
-- 99999
-- Write something similar to hr_process_person_ss.is_rec_changed
-- validate_basic_details,
-- 99999
-- Include the following code in update_contact_relationship
-- --
--  l_count := l_count + 1;
--  l_transaction_table(l_count).param_name := 'P_PROCESS_SECTION_NAME';
--  l_transaction_table(l_count).param_value := p_process_section_name;
 -- l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--  l_count := l_count + 1;
--  l_transaction_table(l_count).param_name := 'P_ACTION_TYPE';
--  l_transaction_table(l_count).param_value := p_action_type;
--  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
--9999
-- Put the errors like :
--   WHEN g_data_error THEN
--    hr_utility.raise_error;
--
--  WHEN g_no_changes THEN
--    hr_utility.set_message(800, 'HR_PERINFO_NO_CHANGES');
--    hr_utility.raise_error;
--
--  WHEN others THEN
--    hr_utility.raise_error;
-- 9999
--
  /*
  ||===========================================================================
  || PROCEDURE: update_contact_relationship
  ||---------------------------------------------------------------------------
  ||
  || Description:
  || Description:
  ||     This procedure will call the actual API -
  ||                hr_contact_rel_api.update_contact_relationship()
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||     Contains entire list of parameters that are defined in the actual
  ||     API. For details see peaddapi.pkb file.
  ||
  || out nocopy Arguments:
  ||
  || In out nocopy Arguments:
  ||
  || Post Success:
  ||     Executes the API call.
  ||
  || Post Failure:
  ||     Raises an exception
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */

PROCEDURE update_contact_relationship
  (p_validate                      in        varchar2  default 'Y'
  ,p_cont_effective_date           in        date
  ,p_contact_relationship_id       in        number
  ,p_contact_type                  in        varchar2  default hr_api.g_varchar2
  ,p_ctr_comments                  in        long      default hr_api.g_varchar2
  ,p_primary_contact_flag          in        varchar2  default hr_api.g_varchar2
  ,p_third_party_pay_flag          in        varchar2  default hr_api.g_varchar2
  ,p_bondholder_flag               in        varchar2  default hr_api.g_varchar2
  ,p_date_start                    in        date      default hr_api.g_date
  ,p_start_life_reason_id          in        number    default hr_api.g_number
  ,p_date_end                      in        date      default hr_api.g_date
  ,p_end_life_reason_id            in        number    default hr_api.g_number
  ,p_rltd_per_rsds_w_dsgntr_flag   in        varchar2  default hr_api.g_varchar2
  ,p_personal_flag                 in        varchar2  default hr_api.g_varchar2
  ,p_sequence_number               in        number    default hr_api.g_number
  ,p_dependent_flag                in        varchar2  default hr_api.g_varchar2
  ,p_beneficiary_flag              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute_category       in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute1               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute2               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute3               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute4               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute5               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute6               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute7               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute8               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute9               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute10              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute11              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute12              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute13              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute14              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute15              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute16              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute17              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute18              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute19              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute20              in        varchar2  default hr_api.g_varchar2
  ,p_person_id                     in        number
  ,p_login_person_id               in        number    default hr_api.g_number
  ,p_cont_object_version_number    in out nocopy    number
  ,p_item_type                     in        varchar2
  ,p_item_key                      in        varchar2
  ,p_activity_id                   in        number
  ,p_action                        in        varchar2 -- this is p_action_type
  ,p_process_section_name          in        varchar2
  ,p_review_page_region_code       in        varchar2 default hr_api.g_varchar2

  -- Update_person parameters

  ,p_per_effective_date           in      date
  ,p_datetrack_update_mode        in      varchar2
  ,p_cont_person_id               in      number
  ,p_per_object_version_number    in out nocopy  number
  ,p_person_type_id               in      number   default hr_api.g_number
  ,p_last_name                    in      varchar2 default hr_api.g_varchar2
  ,p_applicant_number             in      varchar2 default hr_api.g_varchar2
  ,p_per_comments                 in      varchar2 default hr_api.g_varchar2
  ,p_date_employee_data_verified  in      date     default hr_api.g_date
  ,p_date_of_birth                in      date     default hr_api.g_date
  ,p_email_address                in      varchar2 default hr_api.g_varchar2
  ,p_employee_number              in out nocopy  varchar2
  ,p_expense_check_send_to_addres in      varchar2 default hr_api.g_varchar2
  ,p_first_name                   in      varchar2 default hr_api.g_varchar2
  ,p_known_as                     in      varchar2 default hr_api.g_varchar2
  ,p_marital_status               in      varchar2 default hr_api.g_varchar2
  ,p_middle_names                 in      varchar2 default hr_api.g_varchar2
  ,p_nationality                  in      varchar2 default hr_api.g_varchar2
  ,p_national_identifier          in      varchar2 default hr_api.g_varchar2
  ,p_previous_last_name           in      varchar2 default hr_api.g_varchar2
  ,p_registered_disabled_flag     in      varchar2 default hr_api.g_varchar2
  ,p_sex                          in      varchar2 default hr_api.g_varchar2
  ,p_title                        in      varchar2 default hr_api.g_varchar2
  ,p_vendor_id                    in      number   default hr_api.g_number
  ,p_work_telephone               in      varchar2 default hr_api.g_varchar2
  ,p_attribute_category           in      varchar2 default hr_api.g_varchar2
  ,p_attribute1                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute2                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute3                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute4                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute5                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute6                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute7                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute8                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute9                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute10                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute11                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute12                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute13                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute14                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute15                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute16                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute17                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute18                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute19                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute20                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute21                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute22                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute23                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute24                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute25                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute26                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute27                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute28                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute29                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute30                  in      varchar2 default hr_api.g_varchar2
  ,p_per_information_category     in      varchar2 default hr_api.g_varchar2
  ,p_per_information1             in      varchar2 default hr_api.g_varchar2
  ,p_per_information2             in      varchar2 default hr_api.g_varchar2
  ,p_per_information3             in      varchar2 default hr_api.g_varchar2
  ,p_per_information4             in      varchar2 default hr_api.g_varchar2
  ,p_per_information5             in      varchar2 default hr_api.g_varchar2
  ,p_per_information6             in      varchar2 default hr_api.g_varchar2
  ,p_per_information7             in      varchar2 default hr_api.g_varchar2
  ,p_per_information8             in      varchar2 default hr_api.g_varchar2
  ,p_per_information9             in      varchar2 default hr_api.g_varchar2
  ,p_per_information10            in      varchar2 default hr_api.g_varchar2
  ,p_per_information11            in      varchar2 default hr_api.g_varchar2
  ,p_per_information12            in      varchar2 default hr_api.g_varchar2
  ,p_per_information13            in      varchar2 default hr_api.g_varchar2
  ,p_per_information14            in      varchar2 default hr_api.g_varchar2
  ,p_per_information15            in      varchar2 default hr_api.g_varchar2
  ,p_per_information16            in      varchar2 default hr_api.g_varchar2
  ,p_per_information17            in      varchar2 default hr_api.g_varchar2
  ,p_per_information18            in      varchar2 default hr_api.g_varchar2
  ,p_per_information19            in      varchar2 default hr_api.g_varchar2
  ,p_per_information20            in      varchar2 default hr_api.g_varchar2
  ,p_per_information21            in      varchar2 default hr_api.g_varchar2
  ,p_per_information22            in      varchar2 default hr_api.g_varchar2
  ,p_per_information23            in      varchar2 default hr_api.g_varchar2
  ,p_per_information24            in      varchar2 default hr_api.g_varchar2
  ,p_per_information25            in      varchar2 default hr_api.g_varchar2
  ,p_per_information26            in      varchar2 default hr_api.g_varchar2
  ,p_per_information27            in      varchar2 default hr_api.g_varchar2
  ,p_per_information28            in      varchar2 default hr_api.g_varchar2
  ,p_per_information29            in      varchar2 default hr_api.g_varchar2
  ,p_per_information30            in      varchar2 default hr_api.g_varchar2
  ,p_date_of_death                in      date     default hr_api.g_date
  ,p_background_check_status      in      varchar2 default hr_api.g_varchar2
  ,p_background_date_check        in      date     default hr_api.g_date
  ,p_blood_type                   in      varchar2 default hr_api.g_varchar2
  ,p_correspondence_language      in      varchar2 default hr_api.g_varchar2
  ,p_fast_path_employee           in      varchar2 default hr_api.g_varchar2
  ,p_fte_capacity                 in      number   default hr_api.g_number
  ,p_hold_applicant_date_until    in      date     default hr_api.g_date
  ,p_honors                       in      varchar2 default hr_api.g_varchar2
  ,p_internal_location            in      varchar2 default hr_api.g_varchar2
  ,p_last_medical_test_by         in      varchar2 default hr_api.g_varchar2
  ,p_last_medical_test_date       in      date     default hr_api.g_date
  ,p_mailstop                     in      varchar2 default hr_api.g_varchar2
  ,p_office_number                in      varchar2 default hr_api.g_varchar2
  ,p_on_military_service          in      varchar2 default hr_api.g_varchar2
  ,p_pre_name_adjunct             in      varchar2 default hr_api.g_varchar2
  ,p_projected_start_date         in      date     default hr_api.g_date
  ,p_rehire_authorizor            in      varchar2 default hr_api.g_varchar2
  ,p_rehire_recommendation        in      varchar2 default hr_api.g_varchar2
  ,p_resume_exists                in      varchar2 default hr_api.g_varchar2
  ,p_resume_last_updated          in      date     default hr_api.g_date
  ,p_second_passport_exists       in      varchar2 default hr_api.g_varchar2
  ,p_student_status               in      varchar2 default hr_api.g_varchar2
  ,p_work_schedule                in      varchar2 default hr_api.g_varchar2
  ,p_rehire_reason                in      varchar2 default hr_api.g_varchar2
  ,p_suffix                       in      varchar2 default hr_api.g_varchar2
  ,p_benefit_group_id             in      number   default hr_api.g_number
  ,p_receipt_of_death_cert_date   in      date     default hr_api.g_date
  ,p_coord_ben_med_pln_no         in      varchar2 default hr_api.g_varchar2
  ,p_coord_ben_no_cvg_flag        in      varchar2 default hr_api.g_varchar2
  ,p_uses_tobacco_flag            in      varchar2 default hr_api.g_varchar2
  ,p_dpdnt_adoption_date          in      date     default hr_api.g_date
  ,p_dpdnt_vlntry_svce_flag       in      varchar2 default hr_api.g_varchar2
  ,p_original_date_of_hire        in      date     default hr_api.g_date
  ,p_adjusted_svc_date            in      date     default hr_api.g_date
  ,p_town_of_birth                in      varchar2 default hr_api.g_varchar2
  ,p_region_of_birth              in      varchar2 default hr_api.g_varchar2
  ,p_country_of_birth             in      varchar2 default hr_api.g_varchar2
  ,p_global_person_id             in      varchar2 default hr_api.g_varchar2
  ,p_business_group_id            in      number   default hr_api.g_number
  ,p_contact_operation            in      varchar2 default hr_api.g_varchar2
  ,p_emrg_cont_flag               in      varchar2 default hr_api.g_varchar2
  ,p_dpdnt_bnf_flag               in      varchar2 default hr_api.g_varchar2
  ,p_save_mode                    in      varchar2 default null
  ,P_CONT_INFORMATION_CATEGORY    in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION1            in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION2            in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION3            in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION4            in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION5            in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION6            in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION7            in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION8            in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION9            in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION10           in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION11           in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION12           in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION13           in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION14           in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION15           in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION16           in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION17           in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION18           in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION19           in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION20           in        varchar2    default hr_api.g_varchar2
  ,p_effective_start_date         out nocopy     date
  ,p_effective_end_date           out nocopy     date
  ,p_full_name                    out nocopy     varchar2
  ,p_comment_id                   out nocopy     number
  ,p_name_combination_warning     out nocopy     varchar2
  ,p_assign_payroll_warning       out nocopy     varchar2
  ,p_orig_hire_warning            out nocopy     varchar2
  ,p_ni_duplicate_warn_or_err   out nocopy     varchar2
  ,p_orig_rel_type                in varchar2      default null

 ) IS

   cursor get_emrg_primary_cont_flag(p_contact_relationship_id     number
                            ,p_contact_person_id           number
                            ,p_person_id number)
   is
   select primary_contact_flag --'N'
   from PER_CONTACT_RELATIONSHIPS
   where person_id = p_person_id
   and contact_person_id = p_contact_person_id
   and contact_type = 'EMRG'
   and trunc(sysdate) >= decode(date_start,null,trunc(sysdate),trunc(date_start))
   and trunc(sysdate) <  decode(date_end,null,trunc(sysdate)+1,trunc(date_end)) ;
--   and primary_contact_flag = 'Y';
      --
      l_transaction_table            hr_transaction_ss.transaction_table;
      l_transaction_step_id          hr_api_transaction_steps.transaction_step_id%type;
      l_trs_object_version_number    hr_api_transaction_steps.object_version_number%type;
      l_cont_old_ovn                 number ;
      l_per_old_ovn                  number;
      l_old_contact_relationship_id  number;
      l_employee_number              per_all_people_f.employee_number%type ;
      l_count                        INTEGER := 0;
      l_attribute_update_mode        varchar2(100) default  null;
      l_validate                     boolean  default false;
      l_basic_details_changed        boolean default null;
      l_per_name_combination_warning VARCHAR2(100) default null;
      l_per_assign_payroll_warning   VARCHAR2(100) default null;
      l_per_orig_hire_warning        VARCHAR2(100) default null;
      l_per_details_changed          boolean default null;
      l_vendor_id                     number default null;
      l_sequence_number               number default null;
      l_benefit_group_id              number default null;
      l_fte_capacity                  number default null;
      l_result                     varchar2(100) default null;
      l_transaction_id             number default null;
      --
      l_effective_start_date             date default null;
      l_effective_end_date               date default null;
      l_per_ovn                          number default null;
      l_full_name                        per_all_people_f.full_name%type default null;
      l_comment_id                       number default null;
      l_name_combination_warning         boolean default null ;
      l_assign_payroll_warning           boolean default null ;
      l_orig_hire_warning                boolean default null ;
      -- StartRegistration
      l_contact_set                       number;
      -- EndRegistration
      l_start_life_reason_id              number := null;
      l_end_life_reason_id                number := null;
      l_contact_relationship_id           number := null;
      l_person_type_id                    number := null;
      -- Bug 2315163
      l_is_emergency_contact              varchar2(50) default null ;
      l_is_dpdnt_bnf                      varchar2(50) default null;
      l_emrg_primary_cont_flag            varchar2(30) default 'N';

      l_date_start                        date := p_date_start;
      l_proc   varchar2(72)  := g_package||'update_contact_relationship';

  --
 BEGIN
  --
  hr_utility.set_location('Entering hr_contact_rel_api.update_contact_relationship', 5);
  --
  IF upper(p_action) = g_change
  THEN
     l_attribute_update_mode := g_attribute_update;
  ELSE
     IF upper(p_action) = g_correct
     THEN
        l_attribute_update_mode := g_attribute_correct;
     END IF;
  END IF;

  hr_utility.set_location('l_attribute_update_mode=' ||
                          l_attribute_update_mode, 10);

 -- Bug no:2263008 fix begins

   check_ni_unique(
     p_national_identifier => p_national_identifier
     ,p_business_group_id => p_business_group_id
     ,p_person_id => p_cont_person_id
     ,p_ni_duplicate_warn_or_err => p_ni_duplicate_warn_or_err);

   --Bug no:2263008 fix ends.

  l_cont_old_ovn := p_cont_object_version_number;
  l_old_contact_relationship_id := p_contact_relationship_id;
  l_per_old_ovn  := p_per_object_version_number;
  l_employee_number := p_employee_number ;
  --
  -- We will always save to transaction table regardless of whether the update is
  -- for approval or not.  Therefore, the validate_mode for calling the person
  -- api should always be set to true.
  --
  l_start_life_reason_id  := p_start_life_reason_id;
  if  p_start_life_reason_id <=0 then
      l_start_life_reason_id  := null;
  end if;

  l_end_life_reason_id      := p_end_life_reason_id;
  if p_end_life_reason_id   <= 0 then
     l_end_life_reason_id      := null;
  end if;

  l_contact_relationship_id := p_contact_relationship_id;
  if p_contact_relationship_id  <= 0 then
     l_contact_relationship_id   := null;
  end if;
/*
  l_sequence_number  := p_sequence_number;
  if p_sequence_number  <= 0 then
     l_sequence_number  := null;
  end if;
*/

  l_person_type_id :=  p_person_type_id ;
  if p_person_type_id <= 0 then
     l_person_type_id  := null;
  end if;

   IF p_validate = 'N' OR p_validate IS NULL
   THEN
      l_validate := false;
   ELSE
      l_validate := true;
   END IF;

  SAVEPOINT  before_entering_into_update ;

  hr_utility.set_location('Before calling is_rec_changed', 15);
  --
  l_sequence_number  := p_sequence_number;
  --
  IF p_sequence_number <= 0
  THEN
     l_sequence_number := null;
  ELSE
     l_sequence_number := p_vendor_id;
  END IF;
  --
  if p_contact_operation not in ( 'EMER_CR_NEW_REL', 'DPDNT_CR_NEW_REL') Then
    --
    -- Check if the record has changed
    --
-- Bug 3469145 : Not passing p_primary_contact_flag value as it contains data respective to
-- the Emergency relationship and here all the data belong to the other relationship.

   l_basic_details_changed := hr_process_contact_ss.is_rec_changed(
    p_effective_date            =>  p_cont_effective_date
   ,p_contact_relationship_id   =>  l_contact_relationship_id
   ,p_contact_type      	=>  p_contact_type
   ,p_comments      		=>  p_ctr_comments
--   ,p_primary_contact_flag      =>  p_primary_contact_flag
   ,p_third_party_pay_flag      =>  p_third_party_pay_flag
   ,p_bondholder_flag      	=>  p_bondholder_flag
   ,p_date_start      		=>  p_date_start
   ,p_start_life_reason_id      =>  l_start_life_reason_id
   ,p_date_end      		=>  p_date_end
   ,p_end_life_reason_id      	=>  l_end_life_reason_id
   ,p_rltd_per_rsds_w_dsgntr_flag      =>  p_rltd_per_rsds_w_dsgntr_flag
   ,p_personal_flag         =>  p_personal_flag
--   ,p_sequence_number       =>  l_sequence_number
   ,p_dependent_flag        =>  p_dependent_flag
   ,p_beneficiary_flag      =>  p_beneficiary_flag
   ,p_cont_attribute_category      =>  p_cont_attribute_category
   ,p_cont_attribute1       =>  p_cont_attribute1
   ,p_cont_attribute2       =>  p_cont_attribute2
   ,p_cont_attribute3       =>  p_cont_attribute3
   ,p_cont_attribute4       =>  p_cont_attribute4
   ,p_cont_attribute5       =>  p_cont_attribute5
   ,p_cont_attribute6       =>  p_cont_attribute6
   ,p_cont_attribute7       =>  p_cont_attribute7
   ,p_cont_attribute8       =>  p_cont_attribute8
   ,p_cont_attribute9       =>  p_cont_attribute9
   ,p_cont_attribute10      =>  p_cont_attribute10
   ,p_cont_attribute11      =>  p_cont_attribute11
   ,p_cont_attribute12      =>  p_cont_attribute12
   ,p_cont_attribute13      =>  p_cont_attribute13
   ,p_cont_attribute14      =>  p_cont_attribute14
   ,p_cont_attribute15      =>  p_cont_attribute15
   ,p_cont_attribute16      =>  p_cont_attribute16
   ,p_cont_attribute17      =>  p_cont_attribute17
   ,p_cont_attribute18      =>  p_cont_attribute18
   ,p_cont_attribute19      =>  p_cont_attribute19
   ,p_cont_attribute20      =>  p_cont_attribute20
   ,P_CONT_INFORMATION_CATEGORY => P_CONT_INFORMATION_CATEGORY
   ,P_CONT_INFORMATION1     => P_CONT_INFORMATION1
   ,P_CONT_INFORMATION2     => P_CONT_INFORMATION2
   ,P_CONT_INFORMATION3     => P_CONT_INFORMATION3
   ,P_CONT_INFORMATION4     => P_CONT_INFORMATION4
   ,P_CONT_INFORMATION5     => P_CONT_INFORMATION5
   ,P_CONT_INFORMATION6     => P_CONT_INFORMATION6
   ,P_CONT_INFORMATION7     => P_CONT_INFORMATION7
   ,P_CONT_INFORMATION8     => P_CONT_INFORMATION8
   ,P_CONT_INFORMATION9     => P_CONT_INFORMATION9
   ,P_CONT_INFORMATION10    => P_CONT_INFORMATION10
   ,P_CONT_INFORMATION11    => P_CONT_INFORMATION11
   ,P_CONT_INFORMATION12    => P_CONT_INFORMATION12
   ,P_CONT_INFORMATION13    => P_CONT_INFORMATION13
   ,P_CONT_INFORMATION14    => P_CONT_INFORMATION14
   ,P_CONT_INFORMATION15    => P_CONT_INFORMATION15
   ,P_CONT_INFORMATION16    => P_CONT_INFORMATION16
   ,P_CONT_INFORMATION17    => P_CONT_INFORMATION17
   ,P_CONT_INFORMATION18    => P_CONT_INFORMATION18
   ,P_CONT_INFORMATION19    => P_CONT_INFORMATION19
   ,P_CONT_INFORMATION20    => P_CONT_INFORMATION20
   ,p_object_version_number =>  p_cont_object_version_number
   );
   --
  else
   --
   l_basic_details_changed := true;
   --
  end if;

-- Bug 3504216  : Checking if primary cont flag has changed or not.
-- If primary contact flag has changed then setting l_basic_details_changed as true.
-- Primary flag checkbox is availaible only in Emergency Contact.So checking for
-- change in primary contact only when in Emerg Update.

if p_contact_operation in ('EMRG_OVRW_UPD') then
    hr_utility.set_location('if p_contact_operation in EMRG_OVRW_UPD:'||l_proc,20);
    open get_emrg_primary_cont_flag(l_contact_relationship_id,
                                    p_cont_person_id,
                                    p_person_id);
    fetch get_emrg_primary_cont_flag into l_emrg_primary_cont_flag;
    if nvl(l_emrg_primary_cont_flag,'N') <> nvl(p_primary_contact_flag,'N') then
       l_basic_details_changed := true;
       validate_primary_cont_flag(
         p_contact_relationship_id => l_contact_relationship_id
        ,p_primary_contact_flag    => p_primary_contact_flag
        ,p_date_start              => sysdate
        ,p_contact_person_id       => p_cont_person_id
        ,p_object_version_number   => p_cont_object_version_number);
    end if;
    close get_emrg_primary_cont_flag;
end if;

  IF l_basic_details_changed and
     p_contact_operation not in ( 'EMER_CR_NEW_REL', 'DPDNT_CR_NEW_REL') and
     nvl(p_save_mode, 'NVL') <> 'SAVE_FOR_LATER'
  THEN

    -- Call the actual API.
    --
    hr_utility.set_location('Calling hr_contact_rel_api.update_contact_relationship', 25);
    --
    if (nvl(p_rltd_per_rsds_w_dsgntr_flag , 'N') = 'Y') then
       --
       p_del_cont_primary_addr
       (p_contact_relationship_id          => p_contact_relationship_id);
       --
    end if;

    l_emrg_primary_cont_flag := p_primary_contact_flag;

    -- if primary contact flag already exists for the emergeny relationship
    -- then do not update again

 /*   open get_emrg_primary_cont_flag(l_contact_relationship_id,
                                    p_cont_person_id,
                                    p_person_id);
    fetch get_emrg_primary_cont_flag into l_emrg_primary_cont_flag;
    if get_emrg_primary_cont_flag%notfound then
       l_emrg_primary_cont_flag := p_primary_contact_flag;
    end if;
    close get_emrg_primary_cont_flag; */
-- Bug 3306000 :

validate_rel_start_date (
   p_person_id         => p_person_id
  ,p_item_key          => p_item_key
  ,p_save_mode         => p_save_mode
  ,p_date_start        => l_date_start
  ,p_date_of_birth     => p_date_of_birth );

    --
    hr_contact_rel_api.update_contact_relationship(
        p_validate                          => l_validate
       ,p_effective_date                    => p_cont_effective_date
       ,p_contact_relationship_id           => l_contact_relationship_id
       ,p_contact_type                      => p_contact_type
       ,p_comments                          => p_ctr_comments
--       ,p_primary_contact_flag              => l_emrg_primary_cont_flag
       ,p_third_party_pay_flag              => p_third_party_pay_flag
       ,p_bondholder_flag                   => p_bondholder_flag
       ,p_date_start                        => p_date_start
       ,p_start_life_reason_id              => l_start_life_reason_id
       ,p_date_end                          => p_date_end
       ,p_end_life_reason_id                => l_end_life_reason_id
       ,p_rltd_per_rsds_w_dsgntr_flag       => p_rltd_per_rsds_w_dsgntr_flag
       ,p_personal_flag                     => p_personal_flag
 --      ,p_sequence_number                   => l_sequence_number
       ,p_dependent_flag                    => p_dependent_flag
       ,p_beneficiary_flag                  => p_beneficiary_flag
       ,p_cont_attribute_category           => p_cont_attribute_category
       ,p_cont_attribute1                   => p_cont_attribute1
       ,p_cont_attribute2                   => p_cont_attribute2
       ,p_cont_attribute3                   => p_cont_attribute3
       ,p_cont_attribute4                   => p_cont_attribute4
       ,p_cont_attribute5                   => p_cont_attribute5
       ,p_cont_attribute6                   => p_cont_attribute6
       ,p_cont_attribute7                   => p_cont_attribute7
       ,p_cont_attribute8                   => p_cont_attribute8
       ,p_cont_attribute9                   => p_cont_attribute9
       ,p_cont_attribute10                  => p_cont_attribute10
       ,p_cont_attribute11                  => p_cont_attribute11
       ,p_cont_attribute12                  => p_cont_attribute12
       ,p_cont_attribute13                  => p_cont_attribute13
       ,p_cont_attribute14                  => p_cont_attribute14
       ,p_cont_attribute15                  => p_cont_attribute15
       ,p_cont_attribute16                  => p_cont_attribute16
       ,p_cont_attribute17                  => p_cont_attribute17
       ,p_cont_attribute18                  => p_cont_attribute18
       ,p_cont_attribute19                  => p_cont_attribute19
       ,p_cont_attribute20                  => p_cont_attribute20
       ,P_CONT_INFORMATION_CATEGORY         => P_CONT_INFORMATION_CATEGORY
       ,P_CONT_INFORMATION1                 => P_CONT_INFORMATION1
       ,P_CONT_INFORMATION2                 => P_CONT_INFORMATION2
       ,P_CONT_INFORMATION3                 => P_CONT_INFORMATION3
       ,P_CONT_INFORMATION4                 => P_CONT_INFORMATION4
       ,P_CONT_INFORMATION5                 => P_CONT_INFORMATION5
       ,P_CONT_INFORMATION6                 => P_CONT_INFORMATION6
       ,P_CONT_INFORMATION7                 => P_CONT_INFORMATION7
       ,P_CONT_INFORMATION8                 => P_CONT_INFORMATION8
       ,P_CONT_INFORMATION9                 => P_CONT_INFORMATION9
       ,P_CONT_INFORMATION10                => P_CONT_INFORMATION10
       ,P_CONT_INFORMATION11                => P_CONT_INFORMATION11
       ,P_CONT_INFORMATION12                => P_CONT_INFORMATION12
       ,P_CONT_INFORMATION13                => P_CONT_INFORMATION13
       ,P_CONT_INFORMATION14                => P_CONT_INFORMATION14
       ,P_CONT_INFORMATION15                => P_CONT_INFORMATION15
       ,P_CONT_INFORMATION16                => P_CONT_INFORMATION16
       ,P_CONT_INFORMATION17                => P_CONT_INFORMATION17
       ,P_CONT_INFORMATION18                => P_CONT_INFORMATION18
       ,P_CONT_INFORMATION19                => P_CONT_INFORMATION19
       ,P_CONT_INFORMATION20                => P_CONT_INFORMATION20
       ,p_object_version_number             => p_cont_object_version_number
    );
    --
    --
    --
    IF hr_errors_api.errorExists
    THEN
       hr_utility.set_location('api error exists hr_contact_rel_api.update_contact_relationship', 30);
       ROLLBACK  to before_entering_into_update ;
       raise g_data_error;
    END IF;
  --
  --
  ELSE
    --
    hr_utility.set_location('No changes found  hr_contact_rel_api.update_contact_relationship', 35);
    --
  END IF;

  IF p_vendor_id = 0
  THEN
     l_vendor_id := null;
  ELSE
     l_vendor_id := p_vendor_id;
  END IF;
  --
  IF p_benefit_group_id = 0
  THEN
     l_benefit_group_id := null;
  ELSE
     l_benefit_group_id := p_benefit_group_id;
  END IF;
  --
  IF p_fte_capacity = 0
  THEN
     l_fte_capacity := null;
  ELSE
     l_fte_capacity := p_fte_capacity;
  END IF;
  --
  l_per_details_changed := hr_process_person_ss.is_rec_changed
    (p_effective_date              => p_per_effective_date
    ,p_person_id                   => p_cont_person_id
    ,p_object_version_number       => p_per_object_version_number
    ,p_person_type_id              => l_person_type_id
    ,p_last_name                   => p_last_name
    ,p_applicant_number            => p_applicant_number
    ,p_comments                    => p_per_comments
    ,p_date_employee_data_verified => p_date_employee_data_verified
    ,p_original_date_of_hire       => p_original_date_of_hire
    ,p_date_of_birth               => p_date_of_birth
    ,p_town_of_birth               => p_town_of_birth
    ,p_region_of_birth             => p_region_of_birth
    ,p_country_of_birth            => p_country_of_birth
    ,p_global_person_id            => p_global_person_id
    ,p_email_address               => p_email_address
    ,p_employee_number             => p_employee_number
    ,p_expense_check_send_to_addres => p_expense_check_send_to_addres
    ,p_first_name                  => p_first_name
    ,p_known_as                    => p_known_as
    ,p_marital_status              => p_marital_status
    ,p_middle_names                => p_middle_names
    ,p_nationality                 => p_nationality
    ,p_national_identifier         => p_national_identifier
    ,p_previous_last_name          => p_previous_last_name
    ,p_registered_disabled_flag    => p_registered_disabled_flag
    ,p_sex                         => p_sex
    ,p_title                       => p_title
    ,p_vendor_id                   => l_vendor_id
    ,p_work_telephone              => p_work_telephone
    ,p_suffix                      => p_suffix
    ,p_date_of_death               => p_date_of_death
    ,p_background_check_status     => p_background_check_status
    ,p_background_date_check       => p_background_date_check
    ,p_blood_type                  => p_blood_type
    ,p_correspondence_language     => p_correspondence_language
    ,p_fast_path_employee          => p_fast_path_employee
    ,p_fte_capacity                => l_fte_capacity
    ,p_hold_applicant_date_until   => p_hold_applicant_date_until
    ,p_honors                      => p_honors
    ,p_internal_location           => p_internal_location
    ,p_last_medical_test_by        => p_last_medical_test_by
    ,p_last_medical_test_date      => p_last_medical_test_date
    ,p_mailstop                    => p_mailstop
    ,p_office_number               => p_office_number
    ,p_on_military_service         => p_on_military_service
    ,p_pre_name_adjunct            => p_pre_name_adjunct
    ,p_projected_start_date        => p_projected_start_date
    ,p_rehire_authorizor           => p_rehire_authorizor
    ,p_rehire_recommendation       => p_rehire_recommendation
    ,p_resume_exists               => p_resume_exists
    ,p_resume_last_updated         => p_resume_last_updated
    ,p_second_passport_exists      => p_second_passport_exists
    ,p_student_status              => p_student_status
    ,p_work_schedule               => p_work_schedule
    ,p_rehire_reason               => p_rehire_reason
    ,p_benefit_group_id            => l_benefit_group_id
    ,p_receipt_of_death_cert_date  => p_receipt_of_death_cert_date
    ,p_coord_ben_med_pln_no        => p_coord_ben_med_pln_no
    ,p_coord_ben_no_cvg_flag       => p_coord_ben_no_cvg_flag
    ,p_uses_tobacco_flag           => p_uses_tobacco_flag
    ,p_dpdnt_adoption_date         => p_dpdnt_adoption_date
    ,p_dpdnt_vlntry_svce_flag      => p_dpdnt_vlntry_svce_flag
--  ,p_adjusted_svc_date           => p_adjusted_svc_date
    ,p_attribute_category          => p_attribute_category
    ,p_attribute1                  => p_attribute1
    ,p_attribute2                  => p_attribute2
    ,p_attribute3                  => p_attribute3
    ,p_attribute4                  => p_attribute4
    ,p_attribute5                  => p_attribute5
    ,p_attribute6                  => p_attribute6
    ,p_attribute7                  => p_attribute7
    ,p_attribute8                  => p_attribute8
    ,p_attribute9                  => p_attribute9
    ,p_attribute10                 => p_attribute10
    ,p_attribute11                 => p_attribute11
    ,p_attribute12                 => p_attribute12
    ,p_attribute13                 => p_attribute13
    ,p_attribute14                 => p_attribute14
    ,p_attribute15                 => p_attribute15
    ,p_attribute16                 => p_attribute16
    ,p_attribute17                 => p_attribute17
    ,p_attribute18                 => p_attribute18
    ,p_attribute19                 => p_attribute19
    ,p_attribute20                 => p_attribute20
    ,p_attribute21                 => p_attribute21
    ,p_attribute22                 => p_attribute22
    ,p_attribute23                 => p_attribute23
    ,p_attribute24                 => p_attribute24
    ,p_attribute25                 => p_attribute25
    ,p_attribute26                 => p_attribute26
    ,p_attribute27                 => p_attribute27
    ,p_attribute28                 => p_attribute28
    ,p_attribute29                 => p_attribute29
    ,p_attribute30                 => p_attribute30
    ,p_per_information_category    => p_per_information_category
    ,p_per_information1            => p_per_information1
    ,p_per_information2            => p_per_information2
    ,p_per_information3            => p_per_information3
    ,p_per_information4            => p_per_information4
    ,p_per_information5            => p_per_information5
    ,p_per_information6            => p_per_information6
    ,p_per_information7            => p_per_information7
    ,p_per_information8            => p_per_information8
    ,p_per_information9            => p_per_information9
    ,p_per_information10           => p_per_information10
    ,p_per_information11           => p_per_information11
    ,p_per_information12           => p_per_information12
    ,p_per_information13           => p_per_information13
    ,p_per_information14           => p_per_information14
    ,p_per_information15           => p_per_information15
    ,p_per_information16           => p_per_information16
    ,p_per_information17           => p_per_information17
    ,p_per_information18           => p_per_information18
    ,p_per_information19           => p_per_information19
    ,p_per_information20           => p_per_information20
    ,p_per_information21           => p_per_information21
    ,p_per_information22           => p_per_information22
    ,p_per_information23           => p_per_information23
    ,p_per_information24           => p_per_information24
    ,p_per_information25           => p_per_information25
    ,p_per_information26           => p_per_information26
    ,p_per_information27           => p_per_information27
    ,p_per_information28           => p_per_information28
    ,p_per_information29           => p_per_information29
    ,p_per_information30           => p_per_information30
    );
  --
  --
  IF  l_per_details_changed  and
      nvl(p_save_mode, 'NVL') <> 'SAVE_FOR_LATER'
  THEN
     --
     -- Call actual api itself.
     --
     l_per_ovn := p_per_object_version_number;
     l_employee_number := p_employee_number;
    --
    hr_person_api.update_person(
         p_validate                          => l_validate
         ,p_effective_date                   => p_per_effective_date
         ,p_datetrack_update_mode            => 'CORRECTION'
         ,p_person_id                        => p_cont_person_id
         ,p_object_version_number            => l_per_ovn -- p_per_object_version_number
         --,p_person_type_id                   => l_person_type_id
         ,p_last_name                        => p_last_name
         ,p_applicant_number                  => p_applicant_number
         ,p_comments                         => p_per_comments
         ,p_date_employee_data_verified      => p_date_employee_data_verified
         ,p_date_of_birth                    => p_date_of_birth
         ,p_email_address                    => p_email_address
         ,p_employee_number                  => l_employee_number
         ,p_expense_check_send_to_addres     => p_expense_check_send_to_addres
         ,p_first_name                       => p_first_name
         ,p_known_as                         => p_known_as
         ,p_marital_status                   => p_marital_status
         ,p_middle_names                     => p_middle_names
         ,p_nationality                      => p_nationality
         ,p_national_identifier              => p_national_identifier
         ,p_previous_last_name               => p_previous_last_name
         ,p_registered_disabled_flag         => p_registered_disabled_flag
         ,p_sex                              => p_sex
         ,p_title                            => p_title
         ,p_vendor_id                        => p_vendor_id
         ,p_work_telephone                   => p_work_telephone
         ,p_attribute_category               =>  p_attribute_category
         ,p_attribute1                       =>  p_attribute1
         ,p_attribute2                       =>  p_attribute2
         ,p_attribute3                       =>  p_attribute3
         ,p_attribute4                       =>  p_attribute4
         ,p_attribute5                       =>  p_attribute5
         ,p_attribute6                       =>  p_attribute6
         ,p_attribute7                       =>  p_attribute7
         ,p_attribute8                       =>  p_attribute8
         ,p_attribute9                       =>  p_attribute9
         ,p_attribute10                       =>  p_attribute10
         ,p_attribute11                       =>  p_attribute11
         ,p_attribute12                       =>  p_attribute12
         ,p_attribute13                       =>  p_attribute13
         ,p_attribute14                       =>  p_attribute14
         ,p_attribute15                       =>  p_attribute15
         ,p_attribute16                       =>  p_attribute16
         ,p_attribute17                       =>  p_attribute17
         ,p_attribute18                       =>  p_attribute18
         ,p_attribute19                       =>  p_attribute19
         ,p_attribute20                       =>  p_attribute20
         ,p_attribute21                       =>  p_attribute21
         ,p_attribute22                       =>  p_attribute22
         ,p_attribute23                       =>  p_attribute23
         ,p_attribute24                       =>  p_attribute24
         ,p_attribute25                       =>  p_attribute25
         ,p_attribute26                       =>  p_attribute26
         ,p_attribute27                       =>  p_attribute27
         ,p_attribute28                       =>  p_attribute28
         ,p_attribute29                       =>  p_attribute29
         ,p_attribute30                       =>  p_attribute30
         ,p_per_information_category          =>  p_per_information_category
         ,p_per_information1                  =>  p_per_information1
         ,p_per_information2                  =>  p_per_information2
         ,p_per_information3                  =>  p_per_information3
         ,p_per_information4                  =>  p_per_information4
         ,p_per_information5                  =>  p_per_information5
         ,p_per_information6                  =>  p_per_information6
         ,p_per_information7                  =>  p_per_information7
         ,p_per_information8                  =>  p_per_information8
         ,p_per_information9                  =>  p_per_information9
         ,p_per_information10                  =>  p_per_information10
         ,p_per_information11                  =>  p_per_information11
         ,p_per_information12                  =>  p_per_information12
         ,p_per_information13                  =>  p_per_information13
         ,p_per_information14                  =>  p_per_information14
         ,p_per_information15                  =>  p_per_information15
         ,p_per_information16                  =>  p_per_information16
         ,p_per_information17                  =>  p_per_information17
         ,p_per_information18                  =>  p_per_information18
         ,p_per_information19                  =>  p_per_information19
         ,p_per_information20                  =>  p_per_information20
         ,p_per_information21                  =>  p_per_information21
         ,p_per_information22                  =>  p_per_information22
         ,p_per_information23                  =>  p_per_information23
         ,p_per_information24                  =>  p_per_information24
         ,p_per_information25                  =>  p_per_information25
         ,p_per_information26                  =>  p_per_information26
         ,p_per_information27                  =>  p_per_information27
         ,p_per_information28                  =>  p_per_information28
         ,p_per_information29                  =>  p_per_information29
         ,p_per_information30                  =>  p_per_information30
         ,p_date_of_death                    => p_date_of_death
         ,p_background_check_status          => p_background_check_status
         ,p_background_date_check            => p_background_date_check
         ,p_blood_type                       => p_blood_type
         ,p_correspondence_language          => p_correspondence_language
         ,p_fast_path_employee               => p_fast_path_employee
         ,p_fte_capacity                     => p_fte_capacity
         ,p_hold_applicant_date_until        => p_hold_applicant_date_until
         ,p_honors                           => p_honors
         ,p_internal_location                => p_internal_location
         ,p_last_medical_test_by             => p_last_medical_test_by
         ,p_last_medical_test_date           => p_last_medical_test_date
         ,p_mailstop                         => p_mailstop
         ,p_office_number                    => p_office_number
         ,p_on_military_service              => p_on_military_service
         ,p_pre_name_adjunct                 => p_pre_name_adjunct
         ,p_projected_start_date             => p_projected_start_date
         ,p_rehire_authorizor                => p_rehire_authorizor
         ,p_rehire_recommendation            => p_rehire_recommendation
         ,p_resume_exists                    => p_resume_exists
         ,p_resume_last_updated              => p_resume_last_updated
         ,p_second_passport_exists           => p_second_passport_exists
         ,p_student_status                   => p_student_status
         ,p_work_schedule                    => p_work_schedule
         ,p_rehire_reason                    => p_rehire_reason
         ,p_suffix                           => p_suffix
         ,p_benefit_group_id                 => p_benefit_group_id
         ,p_receipt_of_death_cert_date       => p_receipt_of_death_cert_date
         ,p_coord_ben_med_pln_no             => p_coord_ben_med_pln_no
         ,p_coord_ben_no_cvg_flag            => p_coord_ben_no_cvg_flag
         ,p_uses_tobacco_flag                => p_uses_tobacco_flag
         ,p_dpdnt_adoption_date              => p_dpdnt_adoption_date
         ,p_dpdnt_vlntry_svce_flag           => p_dpdnt_vlntry_svce_flag
         ,p_original_date_of_hire            => p_original_date_of_hire
        --  ,p_adjusted_svc_date                => bb
         ,p_town_of_birth                    => p_town_of_birth
         ,p_region_of_birth                  => p_region_of_birth
         ,p_country_of_birth                 => p_country_of_birth
         ,p_global_person_id                 => p_global_person_id
         ,p_effective_start_date             =>  l_effective_start_date
         ,p_effective_end_date               =>  l_effective_end_date
         ,p_full_name                        =>  l_full_name
         ,p_comment_id                       =>  l_comment_id
         ,p_name_combination_warning         =>  l_name_combination_warning
         ,p_assign_payroll_warning           =>  l_assign_payroll_warning
         ,p_orig_hire_warning                =>  l_orig_hire_warning
  );
    --
    --
    IF hr_errors_api.errorExists
      THEN
         hr_utility.set_location('api error exists hr_process_person_ss.update_person', 40);
         ROLLBACK to  before_entering_into_update ;
         raise g_data_error;
    END IF;
  ELSE
    --
    hr_utility.set_location('No changes found in  hr_process_person_ss.update_person', 45);
    --
  END IF;

  ROLLBACK  to  before_entering_into_update ;
  --
  -- --------------------------------------------------------------------------
  -- We will write the data to transaction tables.
  -- Determine if a transaction step exists for this activity
  -- if a transaction step does exist then the transaction_step_id and
  -- object_version_number are set (i.e. not null).
  -- --------------------------------------------------------------------------
  --
  IF l_per_details_changed OR l_basic_details_changed
  THEN
    hr_utility.set_location('l_per_details_changed OR l_basic_details_changed', 50);
     -- First, check if transaction id exists or not

     l_transaction_id := hr_transaction_ss.get_transaction_id
                     (p_item_type   => p_item_type
                     ,p_item_key    => p_item_key);
     --
     --
     IF l_transaction_id is null THEN
    hr_utility.set_location('IF l_transaction_id is null THEN', 55);
        -- Start a Transaction
        hr_transaction_ss.start_transaction
           (itemtype   => p_item_type
           ,itemkey    => p_item_key
           ,actid      => p_activity_id
           ,funmode    => 'RUN'
           ,p_api_addtnl_info => p_contact_operation    --TEST
           ,p_login_person_id => nvl(p_login_person_id, p_person_id)
           ,result     => l_result);

        l_transaction_id := hr_transaction_ss.get_transaction_id
                        (p_item_type   => p_item_type
                        ,p_item_key    => p_item_key);
     END IF;
     --
     -- Create a transaction step
     --
     hr_transaction_api.create_transaction_step
        (p_validate              => false
        ,p_creator_person_id     => nvl(p_login_person_id, p_person_id)
        ,p_transaction_id        => l_transaction_id
        ,p_api_name              => g_package || '.PROCESS_API'
        ,p_item_type             => p_item_type
        ,p_item_key              => p_item_key
        ,p_activity_id           => p_activity_id
        ,p_transaction_step_id   => l_transaction_step_id
        ,p_object_version_number => l_trs_object_version_number);

     --
     hr_utility.set_location('l_transaction_step_id = '
                           || to_char(l_transaction_step_id), 30);


     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_validate');
     l_transaction_table(l_count).param_value := p_validate;
     l_transaction_table(l_count).param_data_type := upper('varchar2');
     --
     l_count:=l_count+1;
     l_transaction_table(l_count).param_name      := 'P_SAVE_MODE';
     l_transaction_table(l_count).param_value     :=  p_save_mode;
     l_transaction_table(l_count).param_data_type := 'VARCHAR2';
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_item_type');
     l_transaction_table(l_count).param_value := p_item_type;
     l_transaction_table(l_count).param_data_type := upper('varchar2');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_item_key');
     l_transaction_table(l_count).param_value := p_item_key;
     l_transaction_table(l_count).param_data_type := upper('varchar2');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_activity_id');
     l_transaction_table(l_count).param_value := p_activity_id;
     l_transaction_table(l_count).param_data_type := upper('number');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_action');
     l_transaction_table(l_count).param_value := p_action;
     l_transaction_table(l_count).param_data_type := upper('varchar2');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_process_section_name');
     l_transaction_table(l_count).param_value := p_process_section_name;
     l_transaction_table(l_count).param_data_type := upper('varchar2');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_review_page_region_code');
     l_transaction_table(l_count).param_value := p_review_page_region_code;
     l_transaction_table(l_count).param_data_type := upper('varchar2');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_business_group_id');
     l_transaction_table(l_count).param_value := p_business_group_id;
     l_transaction_table(l_count).param_data_type := upper('number');
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_person_id');
     l_transaction_table(l_count).param_value := p_person_id;
     l_transaction_table(l_count).param_data_type := upper('number');
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_login_person_id');
     l_transaction_table(l_count).param_value := p_login_person_id;
     l_transaction_table(l_count).param_data_type := upper('number');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('P_REVIEW_PROC_CALL');
     l_transaction_table(l_count).param_value := p_review_page_region_code;
     l_transaction_table(l_count).param_data_type := upper('varchar2');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name := 'P_REVIEW_ACTID';
     l_transaction_table(l_count).param_value := P_ACTIVITY_ID;
     l_transaction_table(l_count).param_data_type := 'VARCHAR2';
     --
  --END IF;
  --
  --
    IF  l_basic_details_changed  THEN
     --
    hr_utility.set_location('IF  l_basic_details_changed  THEN', 60);
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_cont_rec_changed');
     l_transaction_table(l_count).param_value := 'CHANGED';
     l_transaction_table(l_count).param_data_type := upper('varchar2');
     --
    END IF ;
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_cont_effective_date');
     l_transaction_table(l_count).param_value :=to_char( p_cont_effective_date,
   						hr_transaction_ss.g_date_format);
     l_transaction_table(l_count).param_data_type := upper('date');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_contact_relationship_id');
     l_transaction_table(l_count).param_value := l_contact_relationship_id;
     l_transaction_table(l_count).param_data_type := upper('number');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_contact_type');
     l_transaction_table(l_count).param_value := p_contact_type;
     l_transaction_table(l_count).param_data_type := upper('varchar2');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_ctr_comments');
     l_transaction_table(l_count).param_value := p_ctr_comments;
     l_transaction_table(l_count).param_data_type := upper('varchar2');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_primary_contact_flag');
     l_transaction_table(l_count).param_value := p_primary_contact_flag;
     l_transaction_table(l_count).param_data_type := upper('varchar2');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_third_party_pay_flag');
     l_transaction_table(l_count).param_value := p_third_party_pay_flag;
     l_transaction_table(l_count).param_data_type := upper('varchar2');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_bondholder_flag');
     l_transaction_table(l_count).param_value := p_bondholder_flag;
     l_transaction_table(l_count).param_data_type := upper('varchar2');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_date_start');
     l_transaction_table(l_count).param_value := to_char(p_date_start,
                                                 hr_transaction_ss.g_date_format);
     l_transaction_table(l_count).param_data_type := upper('date');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_start_life_reason_id');
     l_transaction_table(l_count).param_value := l_start_life_reason_id;
     l_transaction_table(l_count).param_data_type := upper('number');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_date_end');
     l_transaction_table(l_count).param_value :=to_char( p_date_end,
                                                 hr_transaction_ss.g_date_format);
     l_transaction_table(l_count).param_data_type := upper('date');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_end_life_reason_id');
     l_transaction_table(l_count).param_value := l_end_life_reason_id;
     l_transaction_table(l_count).param_data_type := upper('number');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_rltd_per_rsds_w_dsgntr_flag');
     l_transaction_table(l_count).param_value := p_rltd_per_rsds_w_dsgntr_flag;
     l_transaction_table(l_count).param_data_type := upper('varchar2');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_personal_flag');
     l_transaction_table(l_count).param_value := p_personal_flag;
     l_transaction_table(l_count).param_data_type := upper('varchar2');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_sequence_number');
     l_transaction_table(l_count).param_value := l_sequence_number;
     l_transaction_table(l_count).param_data_type := upper('number');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_dependent_flag');
     l_transaction_table(l_count).param_value := p_dependent_flag;
     l_transaction_table(l_count).param_data_type := upper('varchar2');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_beneficiary_flag');
     l_transaction_table(l_count).param_value := p_beneficiary_flag;
     l_transaction_table(l_count).param_data_type := upper('varchar2');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_cont_attribute_category');
     l_transaction_table(l_count).param_value := p_cont_attribute_category;
     l_transaction_table(l_count).param_data_type := upper('varchar2');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_cont_attribute1');
     l_transaction_table(l_count).param_value := p_cont_attribute1;
     l_transaction_table(l_count).param_data_type := upper('varchar2');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_cont_attribute2');
     l_transaction_table(l_count).param_value := p_cont_attribute2;
     l_transaction_table(l_count).param_data_type := upper('varchar2');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_cont_attribute3');
     l_transaction_table(l_count).param_value := p_cont_attribute3;
     l_transaction_table(l_count).param_data_type := upper('varchar2');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_cont_attribute4');
     l_transaction_table(l_count).param_value := p_cont_attribute4;
     l_transaction_table(l_count).param_data_type := upper('varchar2');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_cont_attribute5');
     l_transaction_table(l_count).param_value := p_cont_attribute5;
     l_transaction_table(l_count).param_data_type := upper('varchar2');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_cont_attribute6');
     l_transaction_table(l_count).param_value := p_cont_attribute6;
     l_transaction_table(l_count).param_data_type := upper('varchar2');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_cont_attribute7');
     l_transaction_table(l_count).param_value := p_cont_attribute7;
     l_transaction_table(l_count).param_data_type := upper('varchar2');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_cont_attribute8');
     l_transaction_table(l_count).param_value := p_cont_attribute8;
     l_transaction_table(l_count).param_data_type := upper('varchar2');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_cont_attribute9');
     l_transaction_table(l_count).param_value := p_cont_attribute9;
     l_transaction_table(l_count).param_data_type := upper('varchar2');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_cont_attribute10');
     l_transaction_table(l_count).param_value := p_cont_attribute10;
     l_transaction_table(l_count).param_data_type := upper('varchar2');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_cont_attribute11');
     l_transaction_table(l_count).param_value := p_cont_attribute11;
     l_transaction_table(l_count).param_data_type := upper('varchar2');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_cont_attribute12');
     l_transaction_table(l_count).param_value := p_cont_attribute12;
     l_transaction_table(l_count).param_data_type := upper('varchar2');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_cont_attribute13');
     l_transaction_table(l_count).param_value := p_cont_attribute13;
     l_transaction_table(l_count).param_data_type := upper('varchar2');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_cont_attribute14');
     l_transaction_table(l_count).param_value := p_cont_attribute14;
     l_transaction_table(l_count).param_data_type := upper('varchar2');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_cont_attribute15');
     l_transaction_table(l_count).param_value := p_cont_attribute15;
     l_transaction_table(l_count).param_data_type := upper('varchar2');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_cont_attribute16');
     l_transaction_table(l_count).param_value := p_cont_attribute16;
     l_transaction_table(l_count).param_data_type := upper('varchar2');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_cont_attribute17');
     l_transaction_table(l_count).param_value := p_cont_attribute17;
     l_transaction_table(l_count).param_data_type := upper('varchar2');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_cont_attribute18');
     l_transaction_table(l_count).param_value := p_cont_attribute18;
     l_transaction_table(l_count).param_data_type := upper('varchar2');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_cont_attribute19');
     l_transaction_table(l_count).param_value := p_cont_attribute19;
     l_transaction_table(l_count).param_data_type := upper('varchar2');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_cont_attribute20');
     l_transaction_table(l_count).param_value := p_cont_attribute20;
     l_transaction_table(l_count).param_data_type := upper('varchar2');
     --
     --
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_cont_object_version_number');
     l_transaction_table(l_count).param_value := l_cont_old_ovn;
     l_transaction_table(l_count).param_data_type := upper('number');
     --
     if not l_per_details_changed then
        --
        hr_utility.set_location('if not l_per_details_changed then', 65);
        l_count := l_count + 1;
        l_transaction_table(l_count).param_name :=upper('p_per_rec_changed');
        l_transaction_table(l_count).param_value := null;
        l_transaction_table(l_count).param_data_type := upper('varchar2');
        --
     end if;
     --
  --END IF ; -- End of parameters for update_contact_relationship
  --
  --
    IF  l_per_details_changed  THEN
      --
      l_count := l_count + 1;
      hr_utility.set_location('if l_per_details_changed  THEN', 70);
      l_transaction_table(l_count).param_name :=upper('p_per_rec_changed');
      l_transaction_table(l_count).param_value := 'CHANGED';
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
    END IF ;
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_per_effective_date');
      l_transaction_table(l_count).param_value := to_char(p_per_effective_date,
                                                  hr_transaction_ss.g_date_format);
      l_transaction_table(l_count).param_data_type := upper('date');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_datetrack_update_mode');
      l_transaction_table(l_count).param_value := p_datetrack_update_mode;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_cont_person_id');
      l_transaction_table(l_count).param_value := p_cont_person_id;
      l_transaction_table(l_count).param_data_type := upper('number');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_per_object_version_number');
      l_transaction_table(l_count).param_value := l_per_old_ovn;
      l_transaction_table(l_count).param_data_type := upper('number');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_person_type_id');
      l_transaction_table(l_count).param_value := l_person_type_id;
      l_transaction_table(l_count).param_data_type := upper('number');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_last_name');
      l_transaction_table(l_count).param_value := p_last_name;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_applicant_number');
      l_transaction_table(l_count).param_value := p_applicant_number;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_per_comments');
      l_transaction_table(l_count).param_value := p_per_comments;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_date_employee_data_verified');
      l_transaction_table(l_count).param_value := to_char(p_date_employee_data_verified,
                                                  hr_transaction_ss.g_date_format);
      l_transaction_table(l_count).param_data_type := upper('date');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_date_of_birth');
      l_transaction_table(l_count).param_value :=to_char( p_date_of_birth,
                                                  hr_transaction_ss.g_date_format);
      l_transaction_table(l_count).param_data_type := upper('date');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_email_address');
      l_transaction_table(l_count).param_value := p_email_address;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_employee_number');
      l_transaction_table(l_count).param_value := l_employee_number;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_expense_check_send_to_addres');
      l_transaction_table(l_count).param_value := p_expense_check_send_to_addres;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_first_name');
      l_transaction_table(l_count).param_value := p_first_name;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_known_as');
      l_transaction_table(l_count).param_value := p_known_as;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_marital_status');
      l_transaction_table(l_count).param_value := p_marital_status;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_middle_names');
      l_transaction_table(l_count).param_value := p_middle_names;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_nationality');
      l_transaction_table(l_count).param_value := p_nationality;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_national_identifier');
      l_transaction_table(l_count).param_value := p_national_identifier;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_previous_last_name');
      l_transaction_table(l_count).param_value := p_previous_last_name;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_registered_disabled_flag');
      l_transaction_table(l_count).param_value := p_registered_disabled_flag;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_sex');
      l_transaction_table(l_count).param_value := p_sex;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_title');
      l_transaction_table(l_count).param_value := p_title;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_vendor_id');
      l_transaction_table(l_count).param_value := p_vendor_id;
      l_transaction_table(l_count).param_data_type := upper('number');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_work_telephone');
      l_transaction_table(l_count).param_value := p_work_telephone;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_attribute_category');
      l_transaction_table(l_count).param_value := p_attribute_category;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_attribute1');
      l_transaction_table(l_count).param_value := p_attribute1;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_attribute2');
      l_transaction_table(l_count).param_value := p_attribute2;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_attribute3');
      l_transaction_table(l_count).param_value := p_attribute3;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_attribute4');
      l_transaction_table(l_count).param_value := p_attribute4;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_attribute5');
      l_transaction_table(l_count).param_value := p_attribute5;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_attribute6');
      l_transaction_table(l_count).param_value := p_attribute6;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_attribute7');
      l_transaction_table(l_count).param_value := p_attribute7;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_attribute8');
      l_transaction_table(l_count).param_value := p_attribute8;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_attribute9');
      l_transaction_table(l_count).param_value := p_attribute9;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_attribute10');
      l_transaction_table(l_count).param_value := p_attribute10;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_attribute11');
      l_transaction_table(l_count).param_value := p_attribute11;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_attribute12');
      l_transaction_table(l_count).param_value := p_attribute12;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_attribute13');
      l_transaction_table(l_count).param_value := p_attribute13;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_attribute14');
      l_transaction_table(l_count).param_value := p_attribute14;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_attribute15');
      l_transaction_table(l_count).param_value := p_attribute15;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_attribute16');
      l_transaction_table(l_count).param_value := p_attribute16;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_attribute17');
      l_transaction_table(l_count).param_value := p_attribute17;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_attribute18');
      l_transaction_table(l_count).param_value := p_attribute18;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_attribute19');
      l_transaction_table(l_count).param_value := p_attribute19;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_attribute20');
      l_transaction_table(l_count).param_value := p_attribute20;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_attribute21');
      l_transaction_table(l_count).param_value := p_attribute21;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_attribute22');
      l_transaction_table(l_count).param_value := p_attribute22;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_attribute23');
      l_transaction_table(l_count).param_value := p_attribute23;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_attribute24');
      l_transaction_table(l_count).param_value := p_attribute24;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_attribute25');
      l_transaction_table(l_count).param_value := p_attribute25;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_attribute26');
      l_transaction_table(l_count).param_value := p_attribute26;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_attribute27');
      l_transaction_table(l_count).param_value := p_attribute27;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_attribute28');
      l_transaction_table(l_count).param_value := p_attribute28;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_attribute29');
      l_transaction_table(l_count).param_value := p_attribute29;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_attribute30');
      l_transaction_table(l_count).param_value := p_attribute30;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_per_information_category');
      l_transaction_table(l_count).param_value := p_per_information_category;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_per_information1');
      l_transaction_table(l_count).param_value := p_per_information1;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_per_information2');
      l_transaction_table(l_count).param_value := p_per_information2;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_per_information3');
      l_transaction_table(l_count).param_value := p_per_information3;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_per_information4');
      l_transaction_table(l_count).param_value := p_per_information4;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_per_information5');
      l_transaction_table(l_count).param_value := p_per_information5;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_per_information6');
      l_transaction_table(l_count).param_value := p_per_information6;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_per_information7');
      l_transaction_table(l_count).param_value := p_per_information7;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_per_information8');
      l_transaction_table(l_count).param_value := p_per_information8;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_per_information9');
      l_transaction_table(l_count).param_value := p_per_information9;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_per_information10');
      l_transaction_table(l_count).param_value := p_per_information10;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_per_information11');
      l_transaction_table(l_count).param_value := p_per_information11;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_per_information12');
      l_transaction_table(l_count).param_value := p_per_information12;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_per_information13');
      l_transaction_table(l_count).param_value := p_per_information13;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_per_information14');
      l_transaction_table(l_count).param_value := p_per_information14;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_per_information15');
      l_transaction_table(l_count).param_value := p_per_information15;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_per_information16');
      l_transaction_table(l_count).param_value := p_per_information16;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_per_information17');
      l_transaction_table(l_count).param_value := p_per_information17;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_per_information18');
      l_transaction_table(l_count).param_value := p_per_information18;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_per_information19');
      l_transaction_table(l_count).param_value := p_per_information19;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_per_information20');
      l_transaction_table(l_count).param_value := p_per_information20;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_per_information21');
      l_transaction_table(l_count).param_value := p_per_information21;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_per_information22');
      l_transaction_table(l_count).param_value := p_per_information22;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_per_information23');
      l_transaction_table(l_count).param_value := p_per_information23;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_per_information24');
      l_transaction_table(l_count).param_value := p_per_information24;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_per_information25');
      l_transaction_table(l_count).param_value := p_per_information25;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_per_information26');
      l_transaction_table(l_count).param_value := p_per_information26;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_per_information27');
      l_transaction_table(l_count).param_value := p_per_information27;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_per_information28');
      l_transaction_table(l_count).param_value := p_per_information28;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_per_information29');
      l_transaction_table(l_count).param_value := p_per_information29;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_per_information30');
      l_transaction_table(l_count).param_value := p_per_information30;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_date_of_death');
      l_transaction_table(l_count).param_value := to_char(p_date_of_death,
                                                  hr_transaction_ss.g_date_format);
      l_transaction_table(l_count).param_data_type := upper('date');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_dpdnt_adoption_date');
      l_transaction_table(l_count).param_value :=to_char(p_dpdnt_adoption_date,
                                                       hr_transaction_ss.g_date_format);
      l_transaction_table(l_count).param_data_type := upper('date');
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_background_check_status');
      l_transaction_table(l_count).param_value := p_background_check_status;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_background_date_check');
      l_transaction_table(l_count).param_value := to_char(p_background_date_check,
                                                  hr_transaction_ss.g_date_format);
      l_transaction_table(l_count).param_data_type := upper('date');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_blood_type');
      l_transaction_table(l_count).param_value := p_blood_type;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_correspondence_language');
      l_transaction_table(l_count).param_value := p_correspondence_language;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_fast_path_employee');
      l_transaction_table(l_count).param_value := p_fast_path_employee;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_fte_capacity');
      l_transaction_table(l_count).param_value := p_fte_capacity;
      l_transaction_table(l_count).param_data_type := upper('number');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_hold_applicant_date_until');
      l_transaction_table(l_count).param_value := to_char(p_hold_applicant_date_until,
                                                       hr_transaction_ss.g_date_format);
      l_transaction_table(l_count).param_data_type := upper('date');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_honors');
      l_transaction_table(l_count).param_value := p_honors;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_internal_location');
      l_transaction_table(l_count).param_value := p_internal_location;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_last_medical_test_by');
      l_transaction_table(l_count).param_value := p_last_medical_test_by;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_last_medical_test_date');
      l_transaction_table(l_count).param_value := to_char(p_last_medical_test_date,
                                                       hr_transaction_ss.g_date_format);
      l_transaction_table(l_count).param_data_type := upper('date');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_mailstop');
      l_transaction_table(l_count).param_value := p_mailstop;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_office_number');
      l_transaction_table(l_count).param_value := p_office_number;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_on_military_service');
      l_transaction_table(l_count).param_value := p_on_military_service;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_pre_name_adjunct');
      l_transaction_table(l_count).param_value := p_pre_name_adjunct;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_projected_start_date');
      l_transaction_table(l_count).param_value := to_char(p_projected_start_date,
                                                       hr_transaction_ss.g_date_format);
      l_transaction_table(l_count).param_data_type := upper('date');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_rehire_authorizor');
      l_transaction_table(l_count).param_value := p_rehire_authorizor;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_rehire_recommendation');
      l_transaction_table(l_count).param_value := p_rehire_recommendation;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_resume_exists');
      l_transaction_table(l_count).param_value := p_resume_exists;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_resume_last_updated');
      l_transaction_table(l_count).param_value := to_char(p_resume_last_updated,
                                                       hr_transaction_ss.g_date_format);
      l_transaction_table(l_count).param_data_type := upper('date');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_second_passport_exists');
      l_transaction_table(l_count).param_value := p_second_passport_exists;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_student_status');
      l_transaction_table(l_count).param_value := p_student_status;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_work_schedule');
      l_transaction_table(l_count).param_value := p_work_schedule;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_rehire_reason');
      l_transaction_table(l_count).param_value := p_rehire_reason;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_suffix');
      l_transaction_table(l_count).param_value := p_suffix;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_benefit_group_id');
      l_transaction_table(l_count).param_value := p_benefit_group_id;
      l_transaction_table(l_count).param_data_type := upper('number');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_receipt_of_death_cert_date');
      l_transaction_table(l_count).param_value := to_char(p_receipt_of_death_cert_date,
                                                       hr_transaction_ss.g_date_format);
      l_transaction_table(l_count).param_data_type := upper('date');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_coord_ben_med_pln_no');
      l_transaction_table(l_count).param_value := p_coord_ben_med_pln_no;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_coord_ben_no_cvg_flag');
      l_transaction_table(l_count).param_value := p_coord_ben_no_cvg_flag;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_uses_tobacco_flag');
      l_transaction_table(l_count).param_value := p_uses_tobacco_flag;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_dpdnt_vlntry_svce_flag');
      l_transaction_table(l_count).param_value := p_dpdnt_vlntry_svce_flag;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_original_date_of_hire');
      l_transaction_table(l_count).param_value := to_char(p_original_date_of_hire,
                                                       hr_transaction_ss.g_date_format);
      l_transaction_table(l_count).param_data_type := upper('date');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_adjusted_svc_date');
      l_transaction_table(l_count).param_value := to_char(p_adjusted_svc_date,
                                                       hr_transaction_ss.g_date_format);
      l_transaction_table(l_count).param_data_type := upper('date');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_town_of_birth');
      l_transaction_table(l_count).param_value := p_town_of_birth;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_region_of_birth');
      l_transaction_table(l_count).param_value := p_region_of_birth;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_country_of_birth');
      l_transaction_table(l_count).param_value := p_country_of_birth;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_global_person_id');
      l_transaction_table(l_count).param_value := p_global_person_id;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      -- These are the parameters which are there in the create_contact.
      -- We need to populate null values so that we can have generic get
      -- ffunction which works for create_contact and update_contact.
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_start_date');
      l_transaction_table(l_count).param_value := to_char(p_date_start, hr_transaction_ss.g_date_format);
      l_transaction_table(l_count).param_data_type := upper('date');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_contact_person_id');
      l_transaction_table(l_count).param_value := p_cont_person_id;
      l_transaction_table(l_count).param_data_type := upper('number');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_create_mirror_flag');
      l_transaction_table(l_count).param_value := null;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_mirror_type');
      l_transaction_table(l_count).param_value := null;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_mirror_cont_attribute_cat');
      l_transaction_table(l_count).param_value := null;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_mirror_cont_attribute1');
      l_transaction_table(l_count).param_value := null;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_mirror_cont_attribute2');
      l_transaction_table(l_count).param_value := null;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_mirror_cont_attribute3');
      l_transaction_table(l_count).param_value := null;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_mirror_cont_attribute4');
      l_transaction_table(l_count).param_value := null;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_mirror_cont_attribute5');
      l_transaction_table(l_count).param_value := null;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_mirror_cont_attribute6');
      l_transaction_table(l_count).param_value := null;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_mirror_cont_attribute7');
      l_transaction_table(l_count).param_value := null;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_mirror_cont_attribute8');
      l_transaction_table(l_count).param_value := null;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_mirror_cont_attribute9');
      l_transaction_table(l_count).param_value := null;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_mirror_cont_attribute10');
      l_transaction_table(l_count).param_value := null;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_mirror_cont_attribute11');
      l_transaction_table(l_count).param_value := null;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_mirror_cont_attribute12');
      l_transaction_table(l_count).param_value := null;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_mirror_cont_attribute13');
      l_transaction_table(l_count).param_value := null;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_mirror_cont_attribute14');
      l_transaction_table(l_count).param_value := null;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_mirror_cont_attribute15');
      l_transaction_table(l_count).param_value := null;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_mirror_cont_attribute16');
      l_transaction_table(l_count).param_value := null;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_mirror_cont_attribute17');
      l_transaction_table(l_count).param_value := null;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_mirror_cont_attribute18');
      l_transaction_table(l_count).param_value := null;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_mirror_cont_attribute19');
      l_transaction_table(l_count).param_value := null;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_mirror_cont_attribute20');
      l_transaction_table(l_count).param_value := null;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      --StartRegistration
      --  This is a marker for the contact person to be used to identify the Address
      --  to be retrieved for the contact person in context in review page.
      --  The HR_LAST_CONTACT_SET is in from the work flow attribute
      begin
            l_contact_set := wf_engine.GetItemAttrNumber(itemtype => p_item_type,
                                                itemkey  => p_item_key,
                                                aname    => 'HR_CONTACT_SET');

            exception when others then
                hr_utility.set_location('Exception:'||l_proc,555);
                l_contact_set := 0;

      end;

      l_count := l_count + 1;
      l_transaction_table(l_count).param_name := 'P_CONTACT_SET';
      l_transaction_table(l_count).param_value := l_contact_set;
      l_transaction_table(l_count).param_data_type := 'VARCHAR2';
      --
      -- EndRegistration
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_contact_operation');
      l_transaction_table(l_count).param_value := p_contact_operation;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_emrg_cont_flag');
      l_transaction_table(l_count).param_value := p_emrg_cont_flag;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_dpdnt_bnf_flag');
      l_transaction_table(l_count).param_value := p_dpdnt_bnf_flag;
      l_transaction_table(l_count).param_data_type := upper('varchar2');

     --2315163fix
     --
      if p_contact_operation  in ( 'EMER_CR_NEW_CONT', 'EMER_CR_NEW_REL', 'EMRG_OVRW_UPD')
         or p_emrg_cont_flag ='Y' then
        l_is_emergency_contact := 'Yes';
      else
        l_is_emergency_contact := 'No';
      end if;

      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_is_emergency_contact');
      l_transaction_table(l_count).param_value := l_is_emergency_contact;
      l_transaction_table(l_count).param_data_type := upper('varchar2');

      if p_contact_operation  in ( 'DPDNT_CR_NEW_CONT', 'DPDNT_CR_NEW_REL',  'DPDNT_OVRW_UPD')
         or p_dpdnt_bnf_flag ='Y' then
        l_is_dpdnt_bnf := 'Yes';
      else
        l_is_dpdnt_bnf := 'No';
      end if;

      l_count := l_count + 1;
      l_transaction_table(l_count).param_name :=upper('p_is_dpdnt_bnf');
      l_transaction_table(l_count).param_value := l_is_dpdnt_bnf;
      l_transaction_table(l_count).param_data_type := upper('varchar2');
      --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_CONT_INFORMATION_CATEGORY');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION_CATEGORY;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_CONT_INFORMATION1');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION1;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_CONT_INFORMATION2');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION2;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_CONT_INFORMATION3');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION3;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_CONT_INFORMATION4');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION4;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_CONT_INFORMATION5');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION5;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_CONT_INFORMATION6');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION6;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_CONT_INFORMATION7');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION7;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_CONT_INFORMATION8');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION8;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_CONT_INFORMATION9');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION9;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_CONT_INFORMATION10');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION10;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_CONT_INFORMATION11');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION11;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_CONT_INFORMATION12');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION12;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_CONT_INFORMATION13');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION13;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_CONT_INFORMATION14');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION14;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_CONT_INFORMATION15');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION15;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_CONT_INFORMATION16');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION16;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_CONT_INFORMATION17');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION17;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_CONT_INFORMATION18');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION18;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_CONT_INFORMATION19');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION19;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_CONT_INFORMATION20');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION20;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

      hr_utility.set_location('Before Calling :hr_transaction_ss.save_transaction_step', 75);
      hr_utility.set_location('Before Calling :hr_transaction_ss.save_transaction_step '
                               || to_char(l_transaction_table.count), 75);
      --

     -- Bug 3152505 : Added the new transaction var
     l_count := l_count + 1;
     l_transaction_table(l_count).param_name :=upper('p_orig_rel_type');
     l_transaction_table(l_count).param_value := p_orig_rel_type;
     l_transaction_table(l_count).param_data_type := upper('varchar2');
    --

      hr_transaction_ss.save_transaction_step
                (p_item_type => p_item_type
                ,p_item_key => p_item_key
                ,p_login_person_id => nvl(p_login_person_id, p_person_id)
                ,p_actid => p_activity_id
                ,p_transaction_step_id => l_transaction_step_id
                ,p_api_name => g_package || '.PROCESS_API'
                ,p_transaction_data => l_transaction_table);
      --
      hr_utility.set_location('Leaving hr_process_contact_ss.update_contact_relationship', 80);

  END IF;
  --
  -- 9999 set out variables here. Do we need to set anyway.
  --
  p_name_combination_warning  :=  l_per_name_combination_warning;
  p_assign_payroll_warning    :=  l_per_assign_payroll_warning;
  p_orig_hire_warning         :=  l_per_orig_hire_warning;
  hr_utility.set_location('Exiting:'||l_proc, 85);

  EXCEPTION
    WHEN hr_utility.hr_error THEN
         -- -------------------------------------------
         -- an application error has been raised so we must
         -- redisplay the web form to display the error
         -- --------------------------------------------
         hr_utility.set_location('Exception:'||l_proc,560);
         hr_message.provide_error;
         l_message_number := hr_message.last_message_number;
         --
         -- 99999 What error messages I have to trap here.
         --
         IF l_message_number = 'APP-7165' OR
            l_message_number = 'APP-7155' THEN
            hr_utility.set_message(800, 'HR_UPDATE_NOT_ALLOWED');
            hr_utility.raise_error;
         ELSE
            hr_utility.raise_error;
         END IF;
    WHEN OTHERS THEN
      hr_utility.set_location('Exception:'||l_proc,565);
      fnd_message.set_name('PER', SQLERRM ||' '||to_char(SQLCODE));
      hr_utility.raise_error;
      --RAISE;  -- Raise error here relevant to the new tech stack.
  --
 end update_contact_relationship;
--
-- ---------------------------------------------------------------------------
-- ---------------------------- < is_rec_changed > ---------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This function will check field by field to determine if there
--          are any changes made to the record.
-- ---------------------------------------------------------------------------
FUNCTION  is_rec_changed (
   p_effective_date                in        date
  ,p_contact_relationship_id       in        number
  ,p_contact_type                  in        varchar2  default hr_api.g_varchar2
  ,p_comments                      in        long      default hr_api.g_varchar2
  ,p_primary_contact_flag          in        varchar2  default hr_api.g_varchar2
  ,p_third_party_pay_flag          in        varchar2  default hr_api.g_varchar2
  ,p_bondholder_flag               in        varchar2  default hr_api.g_varchar2
  ,p_date_start                    in        date      default hr_api.g_date
  ,p_start_life_reason_id          in        number    default hr_api.g_number
  ,p_date_end                      in        date      default hr_api.g_date
  ,p_end_life_reason_id            in        number    default hr_api.g_number
  ,p_rltd_per_rsds_w_dsgntr_flag   in        varchar2  default hr_api.g_varchar2
  ,p_personal_flag                 in        varchar2  default hr_api.g_varchar2
  ,p_sequence_number               in        number    default hr_api.g_number
  ,p_dependent_flag                in        varchar2  default hr_api.g_varchar2
  ,p_beneficiary_flag              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute_category       in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute1               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute2               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute3               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute4               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute5               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute6               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute7               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute8               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute9               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute10              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute11              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute12              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute13              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute14              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute15              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute16              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute17              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute18              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute19              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute20              in        varchar2  default hr_api.g_varchar2
-- Added new params
  ,P_CONT_INFORMATION_CATEGORY 	  in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION1            in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION2            in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION3            in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION4            in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION5            in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION6            in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION7            in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION8            in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION9            in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION10           in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION11           in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION12           in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION13           in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION14           in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION15           in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION16           in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION17           in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION18           in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION19           in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION20           in        varchar2    default hr_api.g_varchar2
  ,p_object_version_number         in        number )
return boolean  is
--
  l_rec_changed                    boolean default null;
  l_cur_contact_data               gc_get_cur_contact_data%rowtype;
  l_proc   varchar2(72)  := g_package||'is_rec_changed';
--
BEGIN
  --
--2480916 fix starts
--decommenting the fetch of cursor data as we are checking this cursor value with the current value.
--
  hr_utility.set_location('Entering:'||l_proc, 5);
  OPEN gc_get_cur_contact_data(p_contact_relationship_id => p_contact_relationship_id);
  FETCH gc_get_cur_contact_data into l_cur_contact_data;
  IF gc_get_cur_contact_data%NOTFOUND
  THEN
     hr_utility.set_location('IF gc_get_cur_contact_data NOTFOUND:'||l_proc,10 );
     CLOSE gc_get_cur_contact_data;
     raise g_data_error;
  ELSE
     hr_utility.set_location('IF gc_get_cur_contact_data FOUND:'||l_proc,15 );
     CLOSE gc_get_cur_contact_data;
  END IF;
--2480916 fix ends
--
------------------------------------------------------------------------------
-- NOTE: We need to use nvl(xxx attribute name, hr_api.g_xxxx) because the
--       parameter coming in can be null.  If we do not use nvl, then it will
--       never be equal to the database null value if the parameter value is
--       also null.
------------------------------------------------------------------------------

   --
   IF p_contact_type <> hr_api.g_varchar2
   THEN
       --
       IF nvl(p_contact_type, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.contact_type, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;
   --
   --
   IF p_comments <> hr_api.g_varchar2
   THEN
       --
       IF nvl(p_comments, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.comments, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;
   --
   --
   IF p_primary_contact_flag <> hr_api.g_varchar2
   THEN
       --
       IF nvl(p_primary_contact_flag, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.primary_contact_flag, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;
   --
   --
   IF p_third_party_pay_flag <> hr_api.g_varchar2
   THEN
       --
       IF nvl(p_third_party_pay_flag, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.third_party_pay_flag, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;
   --
   --
   IF p_bondholder_flag <> hr_api.g_varchar2
   THEN
       --
       IF nvl(p_bondholder_flag, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.bondholder_flag, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;
   --
   --
   IF p_date_start <> hr_api.g_date
   THEN
       --
       IF nvl(p_date_start, hr_api.g_date) <>
             nvl(l_cur_contact_data.date_start, hr_api.g_date)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;
   --
   --
   IF p_start_life_reason_id <> hr_api.g_number
   THEN
       --
       IF nvl(p_start_life_reason_id, hr_api.g_number) <>
             nvl(l_cur_contact_data.start_life_reason_id, hr_api.g_number)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;
   --
   --
   IF p_date_end <> hr_api.g_date
   THEN
       --
       IF nvl(p_date_end, hr_api.g_date) <>
             nvl(l_cur_contact_data.date_end, hr_api.g_date)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;
   --
   --
   IF p_end_life_reason_id <> hr_api.g_number
   THEN
       --
       IF nvl(p_end_life_reason_id, hr_api.g_number) <>
             nvl(l_cur_contact_data.end_life_reason_id, hr_api.g_number)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;
   --
   --
   IF p_rltd_per_rsds_w_dsgntr_flag <> hr_api.g_varchar2
   THEN
       --
       IF nvl(p_rltd_per_rsds_w_dsgntr_flag, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.rltd_per_rsds_w_dsgntr_flag, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;
   --
   --
   IF p_personal_flag <> hr_api.g_varchar2
   THEN
       --
       IF nvl(p_personal_flag, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.personal_flag, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;
   --
   --
   IF p_sequence_number <> hr_api.g_number
   THEN
       --
       IF nvl(p_sequence_number, hr_api.g_number) <>
             nvl(l_cur_contact_data.sequence_number, hr_api.g_number)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;
   --
   --
   IF p_dependent_flag <> hr_api.g_varchar2
   THEN
       --
       IF nvl(p_dependent_flag, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.dependent_flag, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;
   --
   --
   IF p_beneficiary_flag <> hr_api.g_varchar2
   THEN
       --
       IF nvl(p_beneficiary_flag, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.beneficiary_flag, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;
   --
   --
   IF p_cont_attribute_category <> hr_api.g_varchar2
   THEN
       --
       IF nvl(p_cont_attribute_category, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.cont_attribute_category, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;
   --
   --
   IF p_cont_attribute1 <> hr_api.g_varchar2
   THEN
       --
       IF nvl(p_cont_attribute1, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.cont_attribute1, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;
   --
   --
   IF p_cont_attribute2 <> hr_api.g_varchar2
   THEN
       --
       IF nvl(p_cont_attribute2, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.cont_attribute2, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;
   --
   --
   IF p_cont_attribute3 <> hr_api.g_varchar2
   THEN
       --
       IF nvl(p_cont_attribute3, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.cont_attribute3, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;
   --
   --
   IF p_cont_attribute4 <> hr_api.g_varchar2
   THEN
       --
       IF nvl(p_cont_attribute4, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.cont_attribute4, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;
   --
   --
   IF p_cont_attribute5 <> hr_api.g_varchar2
   THEN
       --
       IF nvl(p_cont_attribute5, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.cont_attribute5, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;
   --
   --
   IF p_cont_attribute6 <> hr_api.g_varchar2
   THEN
       --
       IF nvl(p_cont_attribute6, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.cont_attribute6, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;
   --
   --
   IF p_cont_attribute7 <> hr_api.g_varchar2
   THEN
       --
       IF nvl(p_cont_attribute7, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.cont_attribute7, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;
   --
   --
   IF p_cont_attribute8 <> hr_api.g_varchar2
   THEN
       --
       IF nvl(p_cont_attribute8, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.cont_attribute8, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;
   --
   --
   IF p_cont_attribute9 <> hr_api.g_varchar2
   THEN
       --
       IF nvl(p_cont_attribute9, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.cont_attribute9, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;
   --
   --
   IF p_cont_attribute10 <> hr_api.g_varchar2
   THEN
       --
       IF nvl(p_cont_attribute10, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.cont_attribute10, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;
   --
   --
   IF p_cont_attribute11 <> hr_api.g_varchar2
   THEN
       --
       IF nvl(p_cont_attribute11, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.cont_attribute11, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;
   --
   --
   IF p_cont_attribute12 <> hr_api.g_varchar2
   THEN
       --
       IF nvl(p_cont_attribute12, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.cont_attribute12, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;
   --
   --
   IF p_cont_attribute13 <> hr_api.g_varchar2
   THEN
       --
       IF nvl(p_cont_attribute13, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.cont_attribute13, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;
   --
   --
   IF p_cont_attribute14 <> hr_api.g_varchar2
   THEN
       --
       IF nvl(p_cont_attribute14, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.cont_attribute14, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;
   --
   --
   IF p_cont_attribute15 <> hr_api.g_varchar2
   THEN
       --
       IF nvl(p_cont_attribute15, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.cont_attribute15, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;
   --
   --
   IF p_cont_attribute16 <> hr_api.g_varchar2
   THEN
       --
       IF nvl(p_cont_attribute16, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.cont_attribute16, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;
   --
   --
   IF p_cont_attribute17 <> hr_api.g_varchar2
   THEN
       --
       IF nvl(p_cont_attribute17, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.cont_attribute17, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;
   --
   --
   IF p_cont_attribute18 <> hr_api.g_varchar2
   THEN
       --
       IF nvl(p_cont_attribute18, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.cont_attribute18, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;
   --
   --
   IF p_cont_attribute19 <> hr_api.g_varchar2
   THEN
       --
       IF nvl(p_cont_attribute19, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.cont_attribute19, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;
   --
   --
   IF p_cont_attribute20 <> hr_api.g_varchar2
   THEN
       --
       IF nvl(p_cont_attribute20, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.cont_attribute20, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;
   --
 IF P_CONT_INFORMATION1 <> hr_api.g_varchar2
   THEN
       --
       IF nvl(P_CONT_INFORMATION1, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.CONT_INFORMATION1, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;

   IF P_CONT_INFORMATION2 <> hr_api.g_varchar2
   THEN
       --
       IF nvl(P_CONT_INFORMATION2, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.CONT_INFORMATION2, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;

   IF P_CONT_INFORMATION3 <> hr_api.g_varchar2
   THEN
       --
       IF nvl(P_CONT_INFORMATION3, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.CONT_INFORMATION3, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;

   IF P_CONT_INFORMATION4 <> hr_api.g_varchar2
   THEN
       --
       IF nvl(P_CONT_INFORMATION4, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.CONT_INFORMATION4, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;

   IF P_CONT_INFORMATION5 <> hr_api.g_varchar2
   THEN
       --
       IF nvl(P_CONT_INFORMATION5, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.CONT_INFORMATION5, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;

   IF P_CONT_INFORMATION6 <> hr_api.g_varchar2
   THEN
       --
       IF nvl(P_CONT_INFORMATION6, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.CONT_INFORMATION6, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;

   IF P_CONT_INFORMATION7 <> hr_api.g_varchar2
   THEN
       --
       IF nvl(P_CONT_INFORMATION7, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.CONT_INFORMATION7, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;

   IF P_CONT_INFORMATION8 <> hr_api.g_varchar2
   THEN
       --
       IF nvl(P_CONT_INFORMATION8, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.CONT_INFORMATION8, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;

   IF P_CONT_INFORMATION9 <> hr_api.g_varchar2
   THEN
       --
       IF nvl(P_CONT_INFORMATION9, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.CONT_INFORMATION9, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;

   IF P_CONT_INFORMATION10 <> hr_api.g_varchar2
   THEN
       --
       IF nvl(P_CONT_INFORMATION10, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.CONT_INFORMATION10, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;

   IF P_CONT_INFORMATION11 <> hr_api.g_varchar2
   THEN
       --
       IF nvl(P_CONT_INFORMATION11, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.CONT_INFORMATION11, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;

   IF P_CONT_INFORMATION12 <> hr_api.g_varchar2
   THEN
       --
       IF nvl(P_CONT_INFORMATION12, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.CONT_INFORMATION12, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;

   IF P_CONT_INFORMATION13 <> hr_api.g_varchar2
   THEN
       --
       IF nvl(P_CONT_INFORMATION13, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.CONT_INFORMATION13, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;

   IF P_CONT_INFORMATION14 <> hr_api.g_varchar2
   THEN
       --
       IF nvl(P_CONT_INFORMATION14, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.CONT_INFORMATION14, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;

   IF P_CONT_INFORMATION15 <> hr_api.g_varchar2
   THEN
       --
       IF nvl(P_CONT_INFORMATION15, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.CONT_INFORMATION15, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;

   IF P_CONT_INFORMATION16 <> hr_api.g_varchar2
   THEN
       --
       IF nvl(P_CONT_INFORMATION16, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.CONT_INFORMATION16, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;

   IF P_CONT_INFORMATION17 <> hr_api.g_varchar2
   THEN
       --
       IF nvl(P_CONT_INFORMATION17, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.CONT_INFORMATION17, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;

   IF P_CONT_INFORMATION18 <> hr_api.g_varchar2
   THEN
       --
       IF nvl(P_CONT_INFORMATION18, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.CONT_INFORMATION18, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;

   IF P_CONT_INFORMATION19 <> hr_api.g_varchar2
   THEN
       --
       IF nvl(P_CONT_INFORMATION19, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.CONT_INFORMATION19, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;

   IF P_CONT_INFORMATION20 <> hr_api.g_varchar2
   THEN
       --
       IF nvl(P_CONT_INFORMATION20, hr_api.g_varchar2) <>
             nvl(l_cur_contact_data.CONT_INFORMATION20, hr_api.g_varchar2)
       THEN
            l_rec_changed := TRUE;
            goto finish;
       END IF;
       --
   END IF;
   --
   <<finish>>
   --
  hr_utility.set_location('Exiting:'||l_proc, 20);
  RETURN l_rec_changed;


  EXCEPTION
  When g_data_error THEN
  hr_utility.set_location('Exception:When g_data_error THEN'||l_proc,555);
       raise;

  When others THEN
    hr_utility.set_location('  When others THEN'||l_proc,560);
      fnd_message.set_name('PER', SQLERRM ||' '||to_char(SQLCODE));
      hr_utility.raise_error;
       --raise;

  END is_rec_changed;


-- ---------------------------------------------------------------------------
-- ---------------------- < get_contact_from_tt> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are saved earlier
--          in the current transaction.  This is invoked when a user click BACK
--          button to go back from the Review page to Update page to correct
--          typos or make further changes.  Hence, we need to use the item_type
--          item_key passed in to retrieve the transaction record.
--          This is an overloaded version.
-- ---------------------------------------------------------------------------

procedure get_contact_from_tt
  (
   p_start_date                   out nocopy        date
  ,p_business_group_id            out nocopy        number
  ,p_person_id                    out nocopy        number
  ,p_contact_person_id            out nocopy        number
  ,p_contact_type                 out nocopy        varchar2
  ,p_ctr_comments                 out nocopy        varchar2
  ,p_primary_contact_flag         out nocopy        varchar2
  ,p_date_start                   out nocopy        date
  ,p_start_life_reason_id         out nocopy        number
  ,p_date_end                     out nocopy        date
  ,p_end_life_reason_id           out nocopy        number
  ,p_rltd_per_rsds_w_dsgntr_flag  out nocopy        varchar2
  ,p_personal_flag                out nocopy        varchar2
  ,p_sequence_number              out nocopy        number
  ,p_cont_attribute_category      out nocopy        varchar2
  ,p_cont_attribute1              out nocopy        varchar2
  ,p_cont_attribute2              out nocopy        varchar2
  ,p_cont_attribute3              out nocopy        varchar2
  ,p_cont_attribute4              out nocopy        varchar2
  ,p_cont_attribute5              out nocopy        varchar2
  ,p_cont_attribute6              out nocopy        varchar2
  ,p_cont_attribute7              out nocopy        varchar2
  ,p_cont_attribute8              out nocopy        varchar2
  ,p_cont_attribute9              out nocopy        varchar2
  ,p_cont_attribute10             out nocopy        varchar2
  ,p_cont_attribute11             out nocopy        varchar2
  ,p_cont_attribute12             out nocopy        varchar2
  ,p_cont_attribute13             out nocopy        varchar2
  ,p_cont_attribute14             out nocopy        varchar2
  ,p_cont_attribute15             out nocopy        varchar2
  ,p_cont_attribute16             out nocopy        varchar2
  ,p_cont_attribute17             out nocopy        varchar2
  ,p_cont_attribute18             out nocopy        varchar2
  ,p_cont_attribute19             out nocopy        varchar2
  ,p_cont_attribute20             out nocopy        varchar2
  ,p_third_party_pay_flag         out nocopy        varchar2
  ,p_bondholder_flag              out nocopy        varchar2
  ,p_dependent_flag               out nocopy        varchar2
  ,p_beneficiary_flag             out nocopy        varchar2
  ,p_last_name                    out nocopy        varchar2
  ,p_sex                          out nocopy        varchar2
  ,p_sex_meaning                  out nocopy        varchar2
  ,p_person_type_id               out nocopy        number
  ,p_per_comments                 out nocopy        varchar2
  ,p_date_of_birth                out nocopy        date
  ,p_email_address                out nocopy        varchar2
  ,p_first_name                   out nocopy        varchar2
  ,p_known_as                     out nocopy        varchar2
  ,p_marital_status               out nocopy        varchar2
  ,p_marital_status_meaning       out nocopy        varchar2
  ,p_student_status               out nocopy        varchar2
  ,p_student_status_meaning       out nocopy        varchar2
  ,p_middle_names                 out nocopy        varchar2
  ,p_nationality                  out nocopy        varchar2
  ,p_national_identifier          out nocopy        varchar2
  ,p_previous_last_name           out nocopy        varchar2
  ,p_registered_disabled_flag     out nocopy        varchar2
  ,p_registered_disabled          out nocopy        varchar2
  ,p_title                        out nocopy        varchar2
  ,p_work_telephone               out nocopy        varchar2
  ,p_attribute_category           out nocopy        varchar2
  ,p_attribute1                   out nocopy        varchar2
  ,p_attribute2                   out nocopy        varchar2
  ,p_attribute3                   out nocopy        varchar2
  ,p_attribute4                   out nocopy        varchar2
  ,p_attribute5                   out nocopy        varchar2
  ,p_attribute6                   out nocopy        varchar2
  ,p_attribute7                   out nocopy        varchar2
  ,p_attribute8                   out nocopy        varchar2
  ,p_attribute9                   out nocopy        varchar2
  ,p_attribute10                  out nocopy        varchar2
  ,p_attribute11                  out nocopy        varchar2
  ,p_attribute12                  out nocopy        varchar2
  ,p_attribute13                  out nocopy        varchar2
  ,p_attribute14                  out nocopy        varchar2
  ,p_attribute15                  out nocopy        varchar2
  ,p_attribute16                  out nocopy        varchar2
  ,p_attribute17                  out nocopy        varchar2
  ,p_attribute18                  out nocopy        varchar2
  ,p_attribute19                  out nocopy        varchar2
  ,p_attribute20                  out nocopy        varchar2
  ,p_attribute21                  out nocopy        varchar2
  ,p_attribute22                  out nocopy        varchar2
  ,p_attribute23                  out nocopy        varchar2
  ,p_attribute24                  out nocopy        varchar2
  ,p_attribute25                  out nocopy        varchar2
  ,p_attribute26                  out nocopy        varchar2
  ,p_attribute27                  out nocopy        varchar2
  ,p_attribute28                  out nocopy        varchar2
  ,p_attribute29                  out nocopy        varchar2
  ,p_attribute30                  out nocopy        varchar2
  ,p_per_information_category     out nocopy        varchar2
  ,p_per_information1             out nocopy        varchar2
  ,p_per_information2             out nocopy        varchar2
  ,p_per_information3             out nocopy        varchar2
  ,p_per_information4             out nocopy        varchar2
  ,p_per_information5             out nocopy        varchar2
  ,p_per_information6             out nocopy        varchar2
  ,p_per_information7             out nocopy        varchar2
  ,p_per_information8             out nocopy        varchar2
  ,p_per_information9             out nocopy        varchar2
  ,p_per_information10            out nocopy        varchar2
  ,p_per_information11            out nocopy        varchar2
  ,p_per_information12            out nocopy        varchar2
  ,p_per_information13            out nocopy        varchar2
  ,p_per_information14            out nocopy        varchar2
  ,p_per_information15            out nocopy        varchar2
  ,p_per_information16            out nocopy        varchar2
  ,p_per_information17            out nocopy        varchar2
  ,p_per_information18            out nocopy        varchar2
  ,p_per_information19            out nocopy        varchar2
  ,p_per_information20            out nocopy        varchar2
  ,p_per_information21            out nocopy        varchar2
  ,p_per_information22            out nocopy        varchar2
  ,p_per_information23            out nocopy        varchar2
  ,p_per_information24            out nocopy        varchar2
  ,p_per_information25            out nocopy        varchar2
  ,p_per_information26            out nocopy        varchar2
  ,p_per_information27            out nocopy        varchar2
  ,p_per_information28            out nocopy        varchar2
  ,p_per_information29            out nocopy        varchar2
  ,p_per_information30            out nocopy        varchar2
  ,p_uses_tobacco_flag            out nocopy        varchar2
  ,p_uses_tobacco_meaning         out nocopy        varchar2
  ,p_on_military_service          out nocopy        varchar2
  ,p_on_military_service_meaning  out nocopy        varchar2
  ,p_dpdnt_vlntry_svce_flag       out nocopy        varchar2
  ,p_dpdnt_vlntry_svce_meaning    out nocopy        varchar2
  ,p_correspondence_language      out nocopy        varchar2
  ,p_honors                       out nocopy        varchar2
  ,p_pre_name_adjunct             out nocopy        varchar2
  ,p_suffix                       out nocopy        varchar2
  ,p_create_mirror_flag           out nocopy        varchar2
  ,p_mirror_type                  out nocopy        varchar2
  ,p_mirror_cont_attribute_cat    out nocopy        varchar2
  ,p_mirror_cont_attribute1       out nocopy        varchar2
  ,p_mirror_cont_attribute2       out nocopy        varchar2
  ,p_mirror_cont_attribute3       out nocopy        varchar2
  ,p_mirror_cont_attribute4       out nocopy        varchar2
  ,p_mirror_cont_attribute5       out nocopy        varchar2
  ,p_mirror_cont_attribute6       out nocopy        varchar2
  ,p_mirror_cont_attribute7       out nocopy        varchar2
  ,p_mirror_cont_attribute8       out nocopy        varchar2
  ,p_mirror_cont_attribute9       out nocopy        varchar2
  ,p_mirror_cont_attribute10      out nocopy        varchar2
  ,p_mirror_cont_attribute11      out nocopy        varchar2
  ,p_mirror_cont_attribute12      out nocopy        varchar2
  ,p_mirror_cont_attribute13      out nocopy        varchar2
  ,p_mirror_cont_attribute14      out nocopy        varchar2
  ,p_mirror_cont_attribute15      out nocopy        varchar2
  ,p_mirror_cont_attribute16      out nocopy        varchar2
  ,p_mirror_cont_attribute17      out nocopy        varchar2
  ,p_mirror_cont_attribute18      out nocopy        varchar2
  ,p_mirror_cont_attribute19      out nocopy        varchar2
  ,p_mirror_cont_attribute20      out nocopy        varchar2
  ,p_item_type                    in         varchar2
  ,p_item_key                     in         varchar2
  ,p_activity_id                  in         number
  ,p_action                       out nocopy        varchar2
  ,p_login_person_id              out nocopy        number
  ,p_process_section_name         out nocopy        varchar2
  ,p_review_page_region_code      out nocopy        varchar2
  -- Bug 1914891
  ,p_date_of_death                out nocopy        date
  ,p_dpdnt_adoption_date          out nocopy        date
  ,p_title_meaning                out nocopy        varchar2
  ,p_contact_type_meaning         out nocopy        varchar2
  ,p_contact_operation            out nocopy        varchar2
  ,p_emrg_cont_flag               out nocopy        varchar2
  ,p_dpdnt_bnf_flag               out nocopy        varchar2
  ,p_contact_relationship_id      out nocopy        number
  ,p_cont_object_version_number   out nocopy        number
  -- bug# 2315163
  ,p_is_emrg_cont                 out nocopy        varchar2
  ,p_is_dpdnt_bnf                 out nocopy        varchar2
  ,P_CONT_INFORMATION_CATEGORY    out nocopy        varchar2
  ,P_CONT_INFORMATION1            out nocopy        varchar2
  ,P_CONT_INFORMATION2            out nocopy        varchar2
  ,P_CONT_INFORMATION3            out nocopy        varchar2
  ,P_CONT_INFORMATION4            out nocopy        varchar2
  ,P_CONT_INFORMATION5            out nocopy        varchar2
  ,P_CONT_INFORMATION6            out nocopy        varchar2
  ,P_CONT_INFORMATION7            out nocopy        varchar2
  ,P_CONT_INFORMATION8            out nocopy        varchar2
  ,P_CONT_INFORMATION9            out nocopy        varchar2
  ,P_CONT_INFORMATION10           out nocopy        varchar2
  ,P_CONT_INFORMATION11           out nocopy        varchar2
  ,P_CONT_INFORMATION12           out nocopy        varchar2
  ,P_CONT_INFORMATION13           out nocopy        varchar2
  ,P_CONT_INFORMATION14           out nocopy        varchar2
  ,P_CONT_INFORMATION15           out nocopy        varchar2
  ,P_CONT_INFORMATION16           out nocopy        varchar2
  ,P_CONT_INFORMATION17           out nocopy        varchar2
  ,P_CONT_INFORMATION18           out nocopy        varchar2
  ,P_CONT_INFORMATION19           out nocopy        varchar2
  ,P_CONT_INFORMATION20           out nocopy        varchar2)


IS
  l_transaction_step_id        number default null;
  l_trans_obj_vers_num         number default null;
  l_transaction_rec_count      integer default 0;
  l_proc   varchar2(72)  := g_package||'get_contact_from_tt';

BEGIN

  -- ------------------------------------------------------------------
  -- Check if there are any transaction rec already saved for the current
  -- transaction. This is used for re-display the Update page when a user
  -- clicks the Back button on the Review page to go back to the Update page
  -- to make further changes or to correct errors.
  -----------------------------------------------------------------------------
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_transaction_api.get_transaction_step_info
     (p_item_type              => p_item_type
     ,p_item_key               => p_item_key
     ,p_activity_id            => p_activity_id
     ,p_transaction_step_id    => l_transaction_step_id
     ,p_object_version_number  => l_trans_obj_vers_num);

  IF l_transaction_step_id > 0
  THEN
     l_transaction_rec_count := 1;
  ELSE
     l_transaction_rec_count := 0;
     hr_utility.set_location('Exiting thru Else part of l_transaction_step_id > 0 :'||l_proc, 10);
     return;
  END IF;
  --
  -- -------------------------------------------------------------------
  -- There are some changes made earlier in the transaction.
  -- Retrieve the data and return to caller.
  -- -------------------------------------------------------------------
  --
  -- Now get the transaction data for the given step
   get_contact_from_tt (
   p_transaction_step_id     	=>  l_transaction_step_id
   ,p_start_date     		=>  p_start_date
   ,p_business_group_id     	=>  p_business_group_id
   ,p_person_id     		=>  p_person_id
   ,p_contact_person_id     	=>  p_contact_person_id
   ,p_contact_type     		=>  p_contact_type
   ,p_ctr_comments     		=>  p_ctr_comments
   ,p_primary_contact_flag     	=>  p_primary_contact_flag
   ,p_date_start     		=>  p_date_start
   ,p_start_life_reason_id     	=>  p_start_life_reason_id
   ,p_date_end     		=>  p_date_end
   ,p_end_life_reason_id     	=>  p_end_life_reason_id
   ,p_rltd_per_rsds_w_dsgntr_flag     =>  p_rltd_per_rsds_w_dsgntr_flag
   ,p_personal_flag     	=>  p_personal_flag
   ,p_sequence_number     	=>  p_sequence_number
   ,p_cont_attribute_category   =>  p_cont_attribute_category
   ,p_cont_attribute1     	=>  p_cont_attribute1
   ,p_cont_attribute2     	=>  p_cont_attribute2
   ,p_cont_attribute3     	=>  p_cont_attribute3
   ,p_cont_attribute4     	=>  p_cont_attribute4
   ,p_cont_attribute5     	=>  p_cont_attribute5
   ,p_cont_attribute6     	=>  p_cont_attribute6
   ,p_cont_attribute7     	=>  p_cont_attribute7
   ,p_cont_attribute8     	=>  p_cont_attribute8
   ,p_cont_attribute9     =>  p_cont_attribute9
   ,p_cont_attribute10     =>  p_cont_attribute10
   ,p_cont_attribute11     =>  p_cont_attribute11
   ,p_cont_attribute12     =>  p_cont_attribute12
   ,p_cont_attribute13     =>  p_cont_attribute13
   ,p_cont_attribute14     =>  p_cont_attribute14
   ,p_cont_attribute15     =>  p_cont_attribute15
   ,p_cont_attribute16     =>  p_cont_attribute16
   ,p_cont_attribute17     =>  p_cont_attribute17
   ,p_cont_attribute18     =>  p_cont_attribute18
   ,p_cont_attribute19     =>  p_cont_attribute19
   ,p_cont_attribute20     =>  p_cont_attribute20
   ,p_third_party_pay_flag     =>  p_third_party_pay_flag
   ,p_bondholder_flag     	=>  p_bondholder_flag
   ,p_dependent_flag     	=>  p_dependent_flag
   ,p_beneficiary_flag     	=>  p_beneficiary_flag
   ,p_last_name     		=>  p_last_name
   ,p_sex     			=>  p_sex
   ,p_sex_meaning               =>  p_sex_meaning
   ,p_person_type_id     =>  p_person_type_id
   ,p_per_comments     =>  p_per_comments
   ,p_date_of_birth     =>  p_date_of_birth
   ,p_email_address     =>  p_email_address
   ,p_first_name     =>  p_first_name
   ,p_known_as     =>  p_known_as
   ,p_marital_status     =>  p_marital_status
   ,p_marital_status_meaning     =>  p_marital_status_meaning
   ,p_student_status     =>  p_student_status
   ,p_student_status_meaning     =>  p_student_status_meaning
   ,p_middle_names     =>  p_middle_names
   ,p_nationality     =>  p_nationality
   ,p_national_identifier     =>  p_national_identifier
   ,p_previous_last_name     =>  p_previous_last_name
   ,p_registered_disabled_flag     =>  p_registered_disabled_flag
   ,p_registered_disabled          =>  p_registered_disabled
   ,p_title     =>  p_title
   ,p_work_telephone     =>  p_work_telephone
   ,p_attribute_category     =>  p_attribute_category
   ,p_attribute1     =>  p_attribute1
   ,p_attribute2     =>  p_attribute2
   ,p_attribute3     =>  p_attribute3
   ,p_attribute4     =>  p_attribute4
   ,p_attribute5     =>  p_attribute5
   ,p_attribute6     =>  p_attribute6
   ,p_attribute7     =>  p_attribute7
   ,p_attribute8     =>  p_attribute8
   ,p_attribute9     =>  p_attribute9
   ,p_attribute10     =>  p_attribute10
   ,p_attribute11     =>  p_attribute11
   ,p_attribute12     =>  p_attribute12
   ,p_attribute13     =>  p_attribute13
   ,p_attribute14     =>  p_attribute14
   ,p_attribute15     =>  p_attribute15
   ,p_attribute16     =>  p_attribute16
   ,p_attribute17     =>  p_attribute17
   ,p_attribute18     =>  p_attribute18
   ,p_attribute19     =>  p_attribute19
   ,p_attribute20     =>  p_attribute20
   ,p_attribute21     =>  p_attribute21
   ,p_attribute22     =>  p_attribute22
   ,p_attribute23     =>  p_attribute23
   ,p_attribute24     =>  p_attribute24
   ,p_attribute25     =>  p_attribute25
   ,p_attribute26     =>  p_attribute26
   ,p_attribute27     =>  p_attribute27
   ,p_attribute28     =>  p_attribute28
   ,p_attribute29     =>  p_attribute29
   ,p_attribute30     =>  p_attribute30
   ,p_per_information_category     =>  p_per_information_category
   ,p_per_information1     =>  p_per_information1
   ,p_per_information2     =>  p_per_information2
   ,p_per_information3     =>  p_per_information3
   ,p_per_information4     =>  p_per_information4
   ,p_per_information5     =>  p_per_information5
   ,p_per_information6     =>  p_per_information6
   ,p_per_information7     =>  p_per_information7
   ,p_per_information8     =>  p_per_information8
   ,p_per_information9     =>  p_per_information9
   ,p_per_information10     =>  p_per_information10
   ,p_per_information11     =>  p_per_information11
   ,p_per_information12     =>  p_per_information12
   ,p_per_information13     =>  p_per_information13
   ,p_per_information14     =>  p_per_information14
   ,p_per_information15     =>  p_per_information15
   ,p_per_information16     =>  p_per_information16
   ,p_per_information17     =>  p_per_information17
   ,p_per_information18     =>  p_per_information18
   ,p_per_information19     =>  p_per_information19
   ,p_per_information20     =>  p_per_information20
   ,p_per_information21     =>  p_per_information21
   ,p_per_information22     =>  p_per_information22
   ,p_per_information23     =>  p_per_information23
   ,p_per_information24     =>  p_per_information24
   ,p_per_information25     =>  p_per_information25
   ,p_per_information26     =>  p_per_information26
   ,p_per_information27     =>  p_per_information27
   ,p_per_information28     =>  p_per_information28
   ,p_per_information29     =>  p_per_information29
   ,p_per_information30     =>  p_per_information30
   ,p_uses_tobacco_flag         =>  p_uses_tobacco_flag
   ,p_uses_tobacco_meaning      =>  p_uses_tobacco_meaning
   ,p_on_military_service       =>  p_on_military_service
   ,p_on_military_service_meaning => p_on_military_service_meaning
   ,p_dpdnt_vlntry_svce_flag      => p_dpdnt_vlntry_svce_flag
   ,p_dpdnt_vlntry_svce_meaning   => p_dpdnt_vlntry_svce_meaning
   ,p_correspondence_language     =>  p_correspondence_language
   ,p_honors     		=>  p_honors
   ,p_pre_name_adjunct     	=>  p_pre_name_adjunct
   ,p_suffix     		=>  p_suffix
   ,p_create_mirror_flag     	=>  p_create_mirror_flag
   ,p_mirror_type     		=>  p_mirror_type
   ,p_mirror_cont_attribute_cat     =>  p_mirror_cont_attribute_cat
   ,p_mirror_cont_attribute1     =>  p_mirror_cont_attribute1
   ,p_mirror_cont_attribute2     =>  p_mirror_cont_attribute2
   ,p_mirror_cont_attribute3     =>  p_mirror_cont_attribute3
   ,p_mirror_cont_attribute4     =>  p_mirror_cont_attribute4
   ,p_mirror_cont_attribute5     =>  p_mirror_cont_attribute5
   ,p_mirror_cont_attribute6     =>  p_mirror_cont_attribute6
   ,p_mirror_cont_attribute7     =>  p_mirror_cont_attribute7
   ,p_mirror_cont_attribute8     =>  p_mirror_cont_attribute8
   ,p_mirror_cont_attribute9     =>  p_mirror_cont_attribute9
   ,p_mirror_cont_attribute10     =>  p_mirror_cont_attribute10
   ,p_mirror_cont_attribute11     =>  p_mirror_cont_attribute11
   ,p_mirror_cont_attribute12     =>  p_mirror_cont_attribute12
   ,p_mirror_cont_attribute13     =>  p_mirror_cont_attribute13
   ,p_mirror_cont_attribute14     =>  p_mirror_cont_attribute14
   ,p_mirror_cont_attribute15     =>  p_mirror_cont_attribute15
   ,p_mirror_cont_attribute16     =>  p_mirror_cont_attribute16
   ,p_mirror_cont_attribute17     =>  p_mirror_cont_attribute17
   ,p_mirror_cont_attribute18     =>  p_mirror_cont_attribute18
   ,p_mirror_cont_attribute19     =>  p_mirror_cont_attribute19
   ,p_mirror_cont_attribute20     =>  p_mirror_cont_attribute20
   ,p_cont_information_category   =>  p_cont_information_category
   ,p_cont_information1           =>  p_cont_information1
   ,p_cont_information2           =>  p_cont_information2
   ,p_cont_information3           =>  p_cont_information3
   ,p_cont_information4           =>  p_cont_information4
   ,p_cont_information5           =>  p_cont_information5
   ,p_cont_information6           =>  p_cont_information6
   ,p_cont_information7           =>  p_cont_information7
   ,p_cont_information8           =>  p_cont_information8
   ,p_cont_information9           =>  p_cont_information9
   ,p_cont_information10          =>  p_cont_information10
   ,p_cont_information11          =>  p_cont_information11
   ,p_cont_information12          =>  p_cont_information12
   ,p_cont_information13          =>  p_cont_information13
   ,p_cont_information14          =>  p_cont_information14
   ,p_cont_information15          =>  p_cont_information15
   ,p_cont_information16          =>  p_cont_information16
   ,p_cont_information17          =>  p_cont_information17
   ,p_cont_information18          =>  p_cont_information18
   ,p_cont_information19          =>  p_cont_information19
   ,p_cont_information20          =>  p_cont_information20
   ,p_action     		=>  p_action
   ,p_login_person_id     	=>  p_login_person_id
   ,p_process_section_name     	=>  p_process_section_name
   ,p_review_page_region_code   =>  p_review_page_region_code
   -- Bug 1914891
   ,p_date_of_death             =>  p_date_of_death
   -- ikasire
   ,p_dpdnt_adoption_date       =>  p_dpdnt_adoption_date
   ,p_title_meaning             =>  p_title_meaning
   ,p_contact_type_meaning      =>  p_contact_type_meaning
   ,p_contact_operation         =>  p_contact_operation
   ,p_emrg_cont_flag            =>  p_emrg_cont_flag
   ,p_dpdnt_bnf_flag            =>  p_dpdnt_bnf_flag
   ,p_contact_relationship_id   =>  p_contact_relationship_id
   ,p_cont_object_version_number=>  p_cont_object_version_number
   --bug# 2315163
   ,p_is_emrg_cont              =>  p_is_emrg_cont
   ,p_is_dpdnt_bnf              =>  p_is_dpdnt_bnf
  );

hr_utility.set_location('Exiting:'||l_proc, 15);

 EXCEPTION
   WHEN g_data_error THEN
   hr_utility.set_location('WHEN g_data_error THEN'||l_proc,555);
      RAISE;
 END get_contact_from_tt;
-- ---------------------------------------------------------------------------
-- ---------------------- < get_contact_from_tt> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are pending for 9999(?)
--          approval in workflow for a transaction step id.
--          This is the procedure which does the actual work.
-- ---------------------------------------------------------------------------

procedure get_contact_from_tt
  (p_transaction_step_id          in         number
  ,p_start_date                   out nocopy        date
  ,p_business_group_id            out nocopy        number
  ,p_person_id                    out nocopy        number
  ,p_contact_person_id            out nocopy        number
  ,p_contact_type                 out nocopy        varchar2
  ,p_ctr_comments                 out nocopy        varchar2
  ,p_primary_contact_flag         out nocopy        varchar2
  ,p_date_start                   out nocopy        date
  ,p_start_life_reason_id         out nocopy        number
  ,p_date_end                     out nocopy        date
  ,p_end_life_reason_id           out nocopy        number
  ,p_rltd_per_rsds_w_dsgntr_flag  out nocopy        varchar2
  ,p_personal_flag                out nocopy        varchar2
  ,p_sequence_number              out nocopy        number
  ,p_cont_attribute_category      out nocopy        varchar2
  ,p_cont_attribute1              out nocopy        varchar2
  ,p_cont_attribute2              out nocopy        varchar2
  ,p_cont_attribute3              out nocopy        varchar2
  ,p_cont_attribute4              out nocopy        varchar2
  ,p_cont_attribute5              out nocopy        varchar2
  ,p_cont_attribute6              out nocopy        varchar2
  ,p_cont_attribute7              out nocopy        varchar2
  ,p_cont_attribute8              out nocopy        varchar2
  ,p_cont_attribute9              out nocopy        varchar2
  ,p_cont_attribute10             out nocopy        varchar2
  ,p_cont_attribute11             out nocopy        varchar2
  ,p_cont_attribute12             out nocopy        varchar2
  ,p_cont_attribute13             out nocopy        varchar2
  ,p_cont_attribute14             out nocopy        varchar2
  ,p_cont_attribute15             out nocopy        varchar2
  ,p_cont_attribute16             out nocopy        varchar2
  ,p_cont_attribute17             out nocopy        varchar2
  ,p_cont_attribute18             out nocopy        varchar2
  ,p_cont_attribute19             out nocopy        varchar2
  ,p_cont_attribute20             out nocopy        varchar2
  ,p_third_party_pay_flag         out nocopy        varchar2
  ,p_bondholder_flag              out nocopy        varchar2
  ,p_dependent_flag               out nocopy        varchar2
  ,p_beneficiary_flag             out nocopy        varchar2
  ,p_last_name                    out nocopy        varchar2
  ,p_sex                          out nocopy        varchar2
  ,p_sex_meaning                  out nocopy        varchar2
  ,p_person_type_id               out nocopy        number
  ,p_per_comments                 out nocopy        varchar2
  ,p_date_of_birth                out nocopy        date
  ,p_email_address                out nocopy        varchar2
  ,p_first_name                   out nocopy        varchar2
  ,p_known_as                     out nocopy        varchar2
  ,p_marital_status               out nocopy        varchar2
  ,p_marital_status_meaning       out nocopy        varchar2
  ,p_student_status               out nocopy        varchar2
  ,p_student_status_meaning       out nocopy        varchar2
  ,p_middle_names                 out nocopy        varchar2
  ,p_nationality                  out nocopy        varchar2
  ,p_national_identifier          out nocopy        varchar2
  ,p_previous_last_name           out nocopy        varchar2
  ,p_registered_disabled_flag     out nocopy        varchar2
  ,p_registered_disabled          out nocopy        varchar2
  ,p_title                        out nocopy        varchar2
  ,p_work_telephone               out nocopy        varchar2
  ,p_attribute_category           out nocopy        varchar2
  ,p_attribute1                   out nocopy        varchar2
  ,p_attribute2                   out nocopy        varchar2
  ,p_attribute3                   out nocopy        varchar2
  ,p_attribute4                   out nocopy        varchar2
  ,p_attribute5                   out nocopy        varchar2
  ,p_attribute6                   out nocopy        varchar2
  ,p_attribute7                   out nocopy        varchar2
  ,p_attribute8                   out nocopy        varchar2
  ,p_attribute9                   out nocopy        varchar2
  ,p_attribute10                  out nocopy        varchar2
  ,p_attribute11                  out nocopy        varchar2
  ,p_attribute12                  out nocopy        varchar2
  ,p_attribute13                  out nocopy        varchar2
  ,p_attribute14                  out nocopy        varchar2
  ,p_attribute15                  out nocopy        varchar2
  ,p_attribute16                  out nocopy        varchar2
  ,p_attribute17                  out nocopy        varchar2
  ,p_attribute18                  out nocopy        varchar2
  ,p_attribute19                  out nocopy        varchar2
  ,p_attribute20                  out nocopy        varchar2
  ,p_attribute21                  out nocopy        varchar2
  ,p_attribute22                  out nocopy        varchar2
  ,p_attribute23                  out nocopy        varchar2
  ,p_attribute24                  out nocopy        varchar2
  ,p_attribute25                  out nocopy        varchar2
  ,p_attribute26                  out nocopy        varchar2
  ,p_attribute27                  out nocopy        varchar2
  ,p_attribute28                  out nocopy        varchar2
  ,p_attribute29                  out nocopy        varchar2
  ,p_attribute30                  out nocopy        varchar2
  ,p_per_information_category     out nocopy        varchar2
  ,p_per_information1             out nocopy        varchar2
  ,p_per_information2             out nocopy        varchar2
  ,p_per_information3             out nocopy        varchar2
  ,p_per_information4             out nocopy        varchar2
  ,p_per_information5             out nocopy        varchar2
  ,p_per_information6             out nocopy        varchar2
  ,p_per_information7             out nocopy        varchar2
  ,p_per_information8             out nocopy        varchar2
  ,p_per_information9             out nocopy        varchar2
  ,p_per_information10            out nocopy        varchar2
  ,p_per_information11            out nocopy        varchar2
  ,p_per_information12            out nocopy        varchar2
  ,p_per_information13            out nocopy        varchar2
  ,p_per_information14            out nocopy        varchar2
  ,p_per_information15            out nocopy        varchar2
  ,p_per_information16            out nocopy        varchar2
  ,p_per_information17            out nocopy        varchar2
  ,p_per_information18            out nocopy        varchar2
  ,p_per_information19            out nocopy        varchar2
  ,p_per_information20            out nocopy        varchar2
  ,p_per_information21            out nocopy        varchar2
  ,p_per_information22            out nocopy        varchar2
  ,p_per_information23            out nocopy        varchar2
  ,p_per_information24            out nocopy        varchar2
  ,p_per_information25            out nocopy        varchar2
  ,p_per_information26            out nocopy        varchar2
  ,p_per_information27            out nocopy        varchar2
  ,p_per_information28            out nocopy        varchar2
  ,p_per_information29            out nocopy        varchar2
  ,p_per_information30            out nocopy        varchar2
  ,p_uses_tobacco_flag            out nocopy        varchar2
  ,p_uses_tobacco_meaning         out nocopy        varchar2
  ,p_on_military_service          out nocopy        varchar2
  ,p_on_military_service_meaning  out nocopy        varchar2
  ,p_dpdnt_vlntry_svce_flag       out nocopy        varchar2
  ,p_dpdnt_vlntry_svce_meaning    out nocopy        varchar2
  ,p_correspondence_language      out nocopy        varchar2
  ,p_honors                       out nocopy        varchar2
  ,p_pre_name_adjunct             out nocopy        varchar2
  ,p_suffix                       out nocopy        varchar2
  ,p_create_mirror_flag           out nocopy        varchar2
  ,p_mirror_type                  out nocopy        varchar2
  ,p_mirror_cont_attribute_cat    out nocopy        varchar2
  ,p_mirror_cont_attribute1       out nocopy        varchar2
  ,p_mirror_cont_attribute2       out nocopy        varchar2
  ,p_mirror_cont_attribute3       out nocopy        varchar2
  ,p_mirror_cont_attribute4       out nocopy        varchar2
  ,p_mirror_cont_attribute5       out nocopy        varchar2
  ,p_mirror_cont_attribute6       out nocopy        varchar2
  ,p_mirror_cont_attribute7       out nocopy        varchar2
  ,p_mirror_cont_attribute8       out nocopy        varchar2
  ,p_mirror_cont_attribute9       out nocopy        varchar2
  ,p_mirror_cont_attribute10      out nocopy        varchar2
  ,p_mirror_cont_attribute11      out nocopy        varchar2
  ,p_mirror_cont_attribute12      out nocopy        varchar2
  ,p_mirror_cont_attribute13      out nocopy        varchar2
  ,p_mirror_cont_attribute14      out nocopy        varchar2
  ,p_mirror_cont_attribute15      out nocopy        varchar2
  ,p_mirror_cont_attribute16      out nocopy        varchar2
  ,p_mirror_cont_attribute17      out nocopy        varchar2
  ,p_mirror_cont_attribute18      out nocopy        varchar2
  ,p_mirror_cont_attribute19      out nocopy        varchar2
  ,p_mirror_cont_attribute20      out nocopy        varchar2
  ,p_action                       out nocopy        varchar2
  ,p_login_person_id              out nocopy        number
  ,p_process_section_name         out nocopy        varchar2
  ,p_review_page_region_code      out nocopy        varchar2
  -- Bug 1914891
  ,p_date_of_death                out nocopy        date
  -- ikasire
  ,p_dpdnt_adoption_date          out nocopy        date
  ,p_title_meaning                out nocopy        varchar2
  ,p_contact_type_meaning         out nocopy        varchar2
  ,p_contact_operation            out nocopy        varchar2
  ,p_emrg_cont_flag               out nocopy        varchar2
  ,p_dpdnt_bnf_flag               out nocopy        varchar2
  ,p_contact_relationship_id      out nocopy        number
  ,p_cont_object_version_number   out nocopy        number
--bug# 2315163
  ,p_is_emrg_cont                 out nocopy        varchar2
  ,p_is_dpdnt_bnf                 out nocopy        varchar2
  ,P_CONT_INFORMATION_CATEGORY    out nocopy        varchar2
  ,P_CONT_INFORMATION1            out nocopy        varchar2
  ,P_CONT_INFORMATION2            out nocopy        varchar2
  ,P_CONT_INFORMATION3            out nocopy        varchar2
  ,P_CONT_INFORMATION4            out nocopy        varchar2
  ,P_CONT_INFORMATION5            out nocopy        varchar2
  ,P_CONT_INFORMATION6            out nocopy        varchar2
  ,P_CONT_INFORMATION7            out nocopy        varchar2
  ,P_CONT_INFORMATION8            out nocopy        varchar2
  ,P_CONT_INFORMATION9            out nocopy        varchar2
  ,P_CONT_INFORMATION10           out nocopy        varchar2
  ,P_CONT_INFORMATION11           out nocopy        varchar2
  ,P_CONT_INFORMATION12           out nocopy        varchar2
  ,P_CONT_INFORMATION13           out nocopy        varchar2
  ,P_CONT_INFORMATION14           out nocopy        varchar2
  ,P_CONT_INFORMATION15           out nocopy        varchar2
  ,P_CONT_INFORMATION16           out nocopy        varchar2
  ,P_CONT_INFORMATION17           out nocopy        varchar2
  ,P_CONT_INFORMATION18           out nocopy        varchar2
  ,P_CONT_INFORMATION19           out nocopy        varchar2
  ,P_CONT_INFORMATION20           out nocopy        varchar2
) IS

 l_proc   varchar2(72)  := g_package||'get_contact_from_tt';

 BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);

  hr_utility.set_location('Setting the attributes:'||l_proc,10 );
  p_cont_object_version_number :=
      hr_transaction_api.get_number_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_cont_object_version_number'));

  p_contact_relationship_id :=
      hr_transaction_api.get_number_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_contact_relationship_id'));

  p_contact_operation  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_contact_operation'));

  p_emrg_cont_flag  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_emrg_cont_flag'));

  p_dpdnt_bnf_flag  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_dpdnt_bnf_flag'));

  --bug# 2315163
  p_is_emrg_cont    :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_is_emergency_contact'));

  p_is_dpdnt_bnf    :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_is_dpdnt_bnf'));


  -- Bug 1914891
  --
  p_date_of_death  :=
      hr_transaction_api.get_date_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_date_of_death'));
  --
  -- ikasire
  --
  p_dpdnt_adoption_date  :=
      hr_transaction_api.get_date_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_dpdnt_adoption_date'));
  --
  p_start_date  :=
      hr_transaction_api.get_date_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_start_date'));
  --
  p_business_group_id  :=
      hr_transaction_api.get_number_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_business_group_id'));
  --
  p_person_id  :=
      hr_transaction_api.get_number_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_person_id'));
  --
  p_contact_person_id  :=
      hr_transaction_api.get_number_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_contact_person_id'));
  --
  p_contact_type  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_contact_type'));
  --
  -- Bug 1914891
  --
  p_contact_type_meaning := HR_GENERAL.DECODE_LOOKUP('CONTACT',p_contact_type);
  --
  p_ctr_comments  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_ctr_comments'));
  --
  p_primary_contact_flag  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_primary_contact_flag'));
  --
  p_date_start  :=
      hr_transaction_api.get_date_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_date_start'));
  --
  p_start_life_reason_id  :=
      hr_transaction_api.get_number_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_start_life_reason_id'));
  --
  p_date_end  :=
      hr_transaction_api.get_date_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_date_end'));
  --
  p_end_life_reason_id  :=
      hr_transaction_api.get_number_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_end_life_reason_id'));
  --
  p_rltd_per_rsds_w_dsgntr_flag  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_rltd_per_rsds_w_dsgntr_flag'));
  --
  p_personal_flag  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_personal_flag'));
  --
  p_sequence_number  :=
      hr_transaction_api.get_number_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_sequence_number'));
  --
  p_cont_attribute_category  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_cont_attribute_category'));
  --
  p_cont_attribute1  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_cont_attribute1'));
  --
  p_cont_attribute2  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_cont_attribute2'));
  --
  p_cont_attribute3  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_cont_attribute3'));
  --
  p_cont_attribute4  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_cont_attribute4'));
  --
  p_cont_attribute5  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_cont_attribute5'));
  --
  p_cont_attribute6  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_cont_attribute6'));
  --
  p_cont_attribute7  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_cont_attribute7'));
  --
  p_cont_attribute8  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_cont_attribute8'));
  --
  p_cont_attribute9  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_cont_attribute9'));
  --
  p_cont_attribute10  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_cont_attribute10'));
  --
  p_cont_attribute11  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_cont_attribute11'));
  --
  p_cont_attribute12  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_cont_attribute12'));
  --
  p_cont_attribute13  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_cont_attribute13'));
  --
  p_cont_attribute14  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_cont_attribute14'));
  --
  p_cont_attribute15  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_cont_attribute15'));
  --
  p_cont_attribute16  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_cont_attribute16'));
  --
  p_cont_attribute17  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_cont_attribute17'));
  --
  p_cont_attribute18  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_cont_attribute18'));
  --
  p_cont_attribute19  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_cont_attribute19'));
  --
  p_cont_attribute20  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_cont_attribute20'));
  --
  p_third_party_pay_flag  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_third_party_pay_flag'));
  --
  p_bondholder_flag  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_bondholder_flag'));
  --
  p_dependent_flag  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_dependent_flag'));
  --
  p_beneficiary_flag  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_beneficiary_flag'));
  --
  p_last_name  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_last_name'));
  --
  p_sex  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_sex'));
  --
  p_sex_meaning  :=  HR_GENERAL.DECODE_LOOKUP('SEX',p_sex); -- 7777
  --
  p_uses_tobacco_flag  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_uses_tobacco_flag'));
  --
  p_uses_tobacco_meaning  :=  HR_GENERAL.DECODE_LOOKUP('TOBACCO_USER',p_uses_tobacco_flag); -- 7777
  --
  p_on_military_service  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_on_military_service'));
  --
  p_on_military_service_meaning  :=  HR_GENERAL.DECODE_LOOKUP('YES_NO',p_on_military_service); -- 7777
  --
  p_dpdnt_vlntry_svce_flag  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_dpdnt_vlntry_svce_flag'));
  --
  p_dpdnt_vlntry_svce_meaning    :=  HR_GENERAL.DECODE_LOOKUP('YES_NO',p_dpdnt_vlntry_svce_flag); -- 7777
  --
  p_person_type_id  :=
      hr_transaction_api.get_number_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_person_type_id'));
  --
  p_per_comments  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_per_comments'));
  --
  p_date_of_birth  :=
      hr_transaction_api.get_date_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_date_of_birth'));
  --
  p_email_address  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_email_address'));
  --
  p_first_name  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_first_name'));
  --
  p_known_as  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_known_as'));
  --
  p_marital_status  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_marital_status'));
  --
  p_marital_status_meaning  :=  HR_GENERAL.DECODE_LOOKUP('MAR_STATUS',p_marital_status); -- 7777
  --
  --
  p_student_status  :=  -- 12345
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_student_status'));
  --
  p_student_status_meaning  :=  HR_GENERAL.DECODE_LOOKUP('STUDENT_STATUS',p_student_status); -- 7777
  --
  p_middle_names  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_middle_names'));
  --
  p_nationality  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_nationality'));
  --
  p_national_identifier  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_national_identifier'));
  --
  p_previous_last_name  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_previous_last_name'));
  --
  p_registered_disabled_flag  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_registered_disabled_flag'));
  --
  p_registered_disabled       :=  HR_GENERAL.DECODE_LOOKUP('REGISTERED_DISABLED', p_registered_disabled_flag);
  --
  p_title  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_title'));
  --
  -- Bug 1914891
  --
  p_title_meaning := HR_GENERAL.DECODE_LOOKUP('TITLE', p_title);
  --
  p_work_telephone  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_work_telephone'));
  --
  p_attribute_category  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_attribute_category'));
  --
  p_attribute1  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_attribute1'));
  --
  p_attribute2  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_attribute2'));
  --
  p_attribute3  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_attribute3'));
  --
  p_attribute4  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_attribute4'));
  --
  p_attribute5  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_attribute5'));
  --
  p_attribute6  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_attribute6'));
  --
  p_attribute7  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_attribute7'));
  --
  p_attribute8  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_attribute8'));
  --
  p_attribute9  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_attribute9'));
  --
  p_attribute10  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_attribute10'));
  --
  p_attribute11  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_attribute11'));
  --
  p_attribute12  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_attribute12'));
  --
  p_attribute13  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_attribute13'));
  --
  p_attribute14  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_attribute14'));
  --
  p_attribute15  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_attribute15'));
  --
  p_attribute16  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_attribute16'));
  --
  p_attribute17  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_attribute17'));
  --
  p_attribute18  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_attribute18'));
  --
  p_attribute19  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_attribute19'));
  --
  p_attribute20  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_attribute20'));
  --
  p_attribute21  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_attribute21'));
  --
  p_attribute22  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_attribute22'));
  --
  p_attribute23  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_attribute23'));
  --
  p_attribute24  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_attribute24'));
  --
  p_attribute25  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_attribute25'));
  --
  p_attribute26  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_attribute26'));
  --
  p_attribute27  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_attribute27'));
  --
  p_attribute28  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_attribute28'));
  --
  p_attribute29  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_attribute29'));
  --
  p_attribute30  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_attribute30'));
  --
  p_per_information_category  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_per_information_category'));
  --
  p_per_information1  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_per_information1'));
  --
  p_per_information2  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_per_information2'));
  --
  p_per_information3  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_per_information3'));
  --
  p_per_information4  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_per_information4'));
  --
  p_per_information5  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_per_information5'));
  --
  p_per_information6  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_per_information6'));
  --
  p_per_information7  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_per_information7'));
  --
  p_per_information8  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_per_information8'));
  --
  p_per_information9  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_per_information9'));
  --
  p_per_information10  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_per_information10'));
  --
  p_per_information11  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_per_information11'));
  --
  p_per_information12  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_per_information12'));
  --
  p_per_information13  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_per_information13'));
  --
  p_per_information14  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_per_information14'));
  --
  p_per_information15  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_per_information15'));
  --
  p_per_information16  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_per_information16'));
  --
  p_per_information17  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_per_information17'));
  --
  p_per_information18  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_per_information18'));
  --
  p_per_information19  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_per_information19'));
  --
  p_per_information20  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_per_information20'));
  --
  p_per_information21  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_per_information21'));
  --
  p_per_information22  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_per_information22'));
  --
  p_per_information23  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_per_information23'));
  --
  p_per_information24  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_per_information24'));
  --
  p_per_information25  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_per_information25'));
  --
  p_per_information26  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_per_information26'));
  --
  p_per_information27  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_per_information27'));
  --
  p_per_information28  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_per_information28'));
  --
  p_per_information29  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_per_information29'));
  --
  p_per_information30  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_per_information30'));
  --
  p_correspondence_language  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_correspondence_language'));
  --
  p_honors  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_honors'));
  --
  p_pre_name_adjunct  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_pre_name_adjunct'));
  --
  p_suffix  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_suffix'));
  --
  p_create_mirror_flag  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_create_mirror_flag'));
  --
  p_mirror_type  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_mirror_type'));
  --
  p_mirror_cont_attribute_cat  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_mirror_cont_attribute_cat'));
  --
  p_mirror_cont_attribute1  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_mirror_cont_attribute1'));
  --
  p_mirror_cont_attribute2  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_mirror_cont_attribute2'));
  --
  p_mirror_cont_attribute3  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_mirror_cont_attribute3'));
  --
  p_mirror_cont_attribute4  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_mirror_cont_attribute4'));
  --
  p_mirror_cont_attribute5  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_mirror_cont_attribute5'));
  --
  p_mirror_cont_attribute6  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_mirror_cont_attribute6'));
  --
  p_mirror_cont_attribute7  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_mirror_cont_attribute7'));
  --
  p_mirror_cont_attribute8  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_mirror_cont_attribute8'));
  --
  p_mirror_cont_attribute9  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_mirror_cont_attribute9'));
  --
  p_mirror_cont_attribute10  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_mirror_cont_attribute10'));
  --
  p_mirror_cont_attribute11  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_mirror_cont_attribute11'));
  --
  p_mirror_cont_attribute12  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_mirror_cont_attribute12'));
  --
  p_mirror_cont_attribute13  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_mirror_cont_attribute13'));
  --
  p_mirror_cont_attribute14  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_mirror_cont_attribute14'));
  --
  p_mirror_cont_attribute15  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_mirror_cont_attribute15'));
  --
  p_mirror_cont_attribute16  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_mirror_cont_attribute16'));
  --
  p_mirror_cont_attribute17  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_mirror_cont_attribute17'));
  --
  p_mirror_cont_attribute18  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_mirror_cont_attribute18'));
  --
  p_mirror_cont_attribute19  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_mirror_cont_attribute19'));
  --
  p_mirror_cont_attribute20  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_mirror_cont_attribute20'));
  --
/*
  p_item_type  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_item_type'));
  --
  p_item_key  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_item_key'));
  --
  p_activity_id  :=
      hr_transaction_api.get_number_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_activity_id'));
*/
  --
  p_action  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_action'));
  --
  p_login_person_id  :=
      hr_transaction_api.get_number_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_login_person_id'));
  --
  p_process_section_name  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_process_section_name'));
  --
  p_review_page_region_code  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'P_REVIEW_PROC_CALL'));

  --
  P_CONT_INFORMATION_CATEGORY  :=
      hr_transaction_api.get_VARCHAR2_value
            (p_transaction_step_id => p_transaction_step_id
            ,p_name                => 'P_CONT_INFORMATION_CATEGORY');
  --
  P_CONT_INFORMATION1  :=
      hr_transaction_api.get_VARCHAR2_value
            (p_transaction_step_id => p_transaction_step_id
            ,p_name                => 'P_CONT_INFORMATION1');
  --
  P_CONT_INFORMATION2  :=
      hr_transaction_api.get_VARCHAR2_value
            (p_transaction_step_id => p_transaction_step_id
            ,p_name                => 'P_CONT_INFORMATION2');
  --
  P_CONT_INFORMATION3  :=
      hr_transaction_api.get_VARCHAR2_value
            (p_transaction_step_id => p_transaction_step_id
            ,p_name                => 'P_CONT_INFORMATION3');
  --
  P_CONT_INFORMATION4  :=
      hr_transaction_api.get_VARCHAR2_value
            (p_transaction_step_id => p_transaction_step_id
            ,p_name                => 'P_CONT_INFORMATION4');
  --
  P_CONT_INFORMATION5  :=
      hr_transaction_api.get_VARCHAR2_value
            (p_transaction_step_id => p_transaction_step_id
            ,p_name                => 'P_CONT_INFORMATION5');
  --
  P_CONT_INFORMATION6  :=
       hr_transaction_api.get_VARCHAR2_value
            (p_transaction_step_id => p_transaction_step_id
            ,p_name                => 'P_CONT_INFORMATION6');
  --
  P_CONT_INFORMATION7  :=
       hr_transaction_api.get_VARCHAR2_value
            (p_transaction_step_id => p_transaction_step_id
            ,p_name                => 'P_CONT_INFORMATION7');
  --
  P_CONT_INFORMATION8  :=
       hr_transaction_api.get_VARCHAR2_value
            (p_transaction_step_id => p_transaction_step_id
            ,p_name                => 'P_CONT_INFORMATION8');
  --
  P_CONT_INFORMATION9  :=
       hr_transaction_api.get_VARCHAR2_value
            (p_transaction_step_id => p_transaction_step_id
            ,p_name                => 'P_CONT_INFORMATION9');
  --
  P_CONT_INFORMATION10  :=
       hr_transaction_api.get_VARCHAR2_value
            (p_transaction_step_id => p_transaction_step_id
            ,p_name                => 'P_CONT_INFORMATION10');
   --
   P_CONT_INFORMATION11  :=
       hr_transaction_api.get_VARCHAR2_value
            (p_transaction_step_id => p_transaction_step_id
            ,p_name                => 'P_CONT_INFORMATION11');
   --
   P_CONT_INFORMATION12  :=
        hr_transaction_api.get_VARCHAR2_value
            (p_transaction_step_id => p_transaction_step_id
            ,p_name                => 'P_CONT_INFORMATION12');
   --
   P_CONT_INFORMATION13  :=
        hr_transaction_api.get_VARCHAR2_value
            (p_transaction_step_id => p_transaction_step_id
            ,p_name                => 'P_CONT_INFORMATION13');
   --
   P_CONT_INFORMATION14  :=
        hr_transaction_api.get_VARCHAR2_value
            (p_transaction_step_id => p_transaction_step_id
            ,p_name                => 'P_CONT_INFORMATION14');
   --
   P_CONT_INFORMATION15  :=
        hr_transaction_api.get_VARCHAR2_value
            (p_transaction_step_id => p_transaction_step_id
            ,p_name                => 'P_CONT_INFORMATION15');
   --
   P_CONT_INFORMATION16  :=
        hr_transaction_api.get_VARCHAR2_value
            (p_transaction_step_id => p_transaction_step_id
            ,p_name                => 'P_CONT_INFORMATION16');
   --
   P_CONT_INFORMATION17  :=
        hr_transaction_api.get_VARCHAR2_value
            (p_transaction_step_id => p_transaction_step_id
            ,p_name                => 'P_CONT_INFORMATION17');
   --
   P_CONT_INFORMATION18  :=
        hr_transaction_api.get_VARCHAR2_value
            (p_transaction_step_id => p_transaction_step_id
            ,p_name                => 'P_CONT_INFORMATION18');
   --
   P_CONT_INFORMATION19  :=
        hr_transaction_api.get_VARCHAR2_value
            (p_transaction_step_id => p_transaction_step_id
            ,p_name                => 'P_CONT_INFORMATION19');
   --
   P_CONT_INFORMATION20  :=
        hr_transaction_api.get_VARCHAR2_value
            (p_transaction_step_id => p_transaction_step_id
            ,p_name                => 'P_CONT_INFORMATION20');
   --
          hr_utility.set_location('End of setting the attributes:'||l_proc,15 );
          hr_utility.set_location('Exiting:'||l_proc, 20);

 EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('Exception:'||l_proc,555);
      fnd_message.set_name('PER', SQLERRM ||' '||to_char(SQLCODE));
      hr_utility.raise_error;
   --RAISE;

 END get_contact_from_tt;
 --
  /*
  ||===========================================================================
  || PROCEDURE: create_contact_tt
  ||---------------------------------------------------------------------------
  ||
  || Description:
  || Description:
  ||     This procedure will call the actual API -
  ||                hr_contact_rel_api.create_contact_tt()
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||     Contains entire list of parameters that are defined in the actual
  ||     API. For details see pecrlapi.pkb file.
  ||
  || out nocopy Arguments:
  ||
  || In out nocopy Arguments:
  ||
  || Post Success:
  ||     Executes the API call.
  ||
  || Post Failure:
  ||     Raises an exception
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */

procedure create_contact_tt
  (p_validate                     in        number     default 0
  ,p_start_date                   in        date
  ,p_business_group_id            in        number
  ,p_person_id                    in        number
  ,p_contact_person_id            in        number      default null
  ,p_contact_type                 in        varchar2
  ,p_ctr_comments                 in        varchar2    default null
  ,p_primary_contact_flag         in        varchar2    default 'N'
  ,p_date_start                   in        date        default null
  ,p_start_life_reason_id         in        number      default null
  ,p_date_end                     in        date        default null
  ,p_end_life_reason_id           in        number      default null
  ,p_rltd_per_rsds_w_dsgntr_flag  in        varchar2    default 'N'
  ,p_personal_flag                in        varchar2    default 'N'
  ,p_sequence_number              in        number      default null
  ,p_cont_attribute_category      in        varchar2    default null
  ,p_cont_attribute1              in        varchar2    default null
  ,p_cont_attribute2              in        varchar2    default null
  ,p_cont_attribute3              in        varchar2    default null
  ,p_cont_attribute4              in        varchar2    default null
  ,p_cont_attribute5              in        varchar2    default null
  ,p_cont_attribute6              in        varchar2    default null
  ,p_cont_attribute7              in        varchar2    default null
  ,p_cont_attribute8              in        varchar2    default null
  ,p_cont_attribute9              in        varchar2    default null
  ,p_cont_attribute10             in        varchar2    default null
  ,p_cont_attribute11             in        varchar2    default null
  ,p_cont_attribute12             in        varchar2    default null
  ,p_cont_attribute13             in        varchar2    default null
  ,p_cont_attribute14             in        varchar2    default null
  ,p_cont_attribute15             in        varchar2    default null
  ,p_cont_attribute16             in        varchar2    default null
  ,p_cont_attribute17             in        varchar2    default null
  ,p_cont_attribute18             in        varchar2    default null
  ,p_cont_attribute19             in        varchar2    default null
  ,p_cont_attribute20             in        varchar2    default null
  ,p_third_party_pay_flag         in        varchar2    default 'N'
  ,p_bondholder_flag              in        varchar2    default 'N'
  ,p_dependent_flag               in        varchar2    default 'N'
  ,p_beneficiary_flag             in        varchar2    default 'N'
  ,p_last_name                    in        varchar2    default null
  ,p_sex                          in        varchar2    default null
  ,p_person_type_id               in        number      default null
  ,p_per_comments                 in        varchar2    default null
  ,p_date_of_birth                in        date        default null
  ,p_email_address                in        varchar2    default null
  ,p_first_name                   in        varchar2    default null
  ,p_known_as                     in        varchar2    default null
  ,p_marital_status               in        varchar2    default null
  ,p_middle_names                 in        varchar2    default null
  ,p_nationality                  in        varchar2    default null
  ,p_national_identifier          in        varchar2    default null
  ,p_previous_last_name           in        varchar2    default null
  ,p_registered_disabled_flag     in        varchar2    default null
  ,p_title                        in        varchar2    default null
  ,p_work_telephone               in        varchar2    default null
  ,p_attribute_category           in        varchar2    default null
  ,p_attribute1                   in        varchar2    default null
  ,p_attribute2                   in        varchar2    default null
  ,p_attribute3                   in        varchar2    default null
  ,p_attribute4                   in        varchar2    default null
  ,p_attribute5                   in        varchar2    default null
  ,p_attribute6                   in        varchar2    default null
  ,p_attribute7                   in        varchar2    default null
  ,p_attribute8                   in        varchar2    default null
  ,p_attribute9                   in        varchar2    default null
  ,p_attribute10                  in        varchar2    default null
  ,p_attribute11                  in        varchar2    default null
  ,p_attribute12                  in        varchar2    default null
  ,p_attribute13                  in        varchar2    default null
  ,p_attribute14                  in        varchar2    default null
  ,p_attribute15                  in        varchar2    default null
  ,p_attribute16                  in        varchar2    default null
  ,p_attribute17                  in        varchar2    default null
  ,p_attribute18                  in        varchar2    default null
  ,p_attribute19                  in        varchar2    default null
  ,p_attribute20                  in        varchar2    default null
  ,p_attribute21                  in        varchar2    default null
  ,p_attribute22                  in        varchar2    default null
  ,p_attribute23                  in        varchar2    default null
  ,p_attribute24                  in        varchar2    default null
  ,p_attribute25                  in        varchar2    default null
  ,p_attribute26                  in        varchar2    default null
  ,p_attribute27                  in        varchar2    default null
  ,p_attribute28                  in        varchar2    default null
  ,p_attribute29                  in        varchar2    default null
  ,p_attribute30                  in        varchar2    default null
  ,p_per_information_category     in        varchar2    default null
  ,p_per_information1             in        varchar2    default null
  ,p_per_information2             in        varchar2    default null
  ,p_per_information3             in        varchar2    default null
  ,p_per_information4             in        varchar2    default null
  ,p_per_information5             in        varchar2    default null
  ,p_per_information6             in        varchar2    default null
  ,p_per_information7             in        varchar2    default null
  ,p_per_information8             in        varchar2    default null
  ,p_per_information9             in        varchar2    default null
  ,p_per_information10            in        varchar2    default null
  ,p_per_information11            in        varchar2    default null
  ,p_per_information12            in        varchar2    default null
  ,p_per_information13            in        varchar2    default null
  ,p_per_information14            in        varchar2    default null
  ,p_per_information15            in        varchar2    default null
  ,p_per_information16            in        varchar2    default null
  ,p_per_information17            in        varchar2    default null
  ,p_per_information18            in        varchar2    default null
  ,p_per_information19            in        varchar2    default null
  ,p_per_information20            in        varchar2    default null
  ,p_per_information21            in        varchar2    default null
  ,p_per_information22            in        varchar2    default null
  ,p_per_information23            in        varchar2    default null
  ,p_per_information24            in        varchar2    default null
  ,p_per_information25            in        varchar2    default null
  ,p_per_information26            in        varchar2    default null
  ,p_per_information27            in        varchar2    default null
  ,p_per_information28            in        varchar2    default null
  ,p_per_information29            in        varchar2    default null
  ,p_per_information30            in        varchar2    default null
  ,p_correspondence_language      in        varchar2    default null
  ,p_honors                       in        varchar2    default null
  ,p_pre_name_adjunct             in        varchar2    default null
  ,p_suffix                       in        varchar2    default null
  ,p_create_mirror_flag           in        varchar2    default 'N'
  ,p_mirror_type                  in        varchar2    default null
  ,p_mirror_cont_attribute_cat    in        varchar2    default null
  ,p_mirror_cont_attribute1       in        varchar2    default null
  ,p_mirror_cont_attribute2       in        varchar2    default null
  ,p_mirror_cont_attribute3       in        varchar2    default null
  ,p_mirror_cont_attribute4       in        varchar2    default null
  ,p_mirror_cont_attribute5       in        varchar2    default null
  ,p_mirror_cont_attribute6       in        varchar2    default null
  ,p_mirror_cont_attribute7       in        varchar2    default null
  ,p_mirror_cont_attribute8       in        varchar2    default null
  ,p_mirror_cont_attribute9       in        varchar2    default null
  ,p_mirror_cont_attribute10      in        varchar2    default null
  ,p_mirror_cont_attribute11      in        varchar2    default null
  ,p_mirror_cont_attribute12      in        varchar2    default null
  ,p_mirror_cont_attribute13      in        varchar2    default null
  ,p_mirror_cont_attribute14      in        varchar2    default null
  ,p_mirror_cont_attribute15      in        varchar2    default null
  ,p_mirror_cont_attribute16      in        varchar2    default null
  ,p_mirror_cont_attribute17      in        varchar2    default null
  ,p_mirror_cont_attribute18      in        varchar2    default null
  ,p_mirror_cont_attribute19      in        varchar2    default null
  ,p_mirror_cont_attribute20      in        varchar2    default null
  ,p_item_type                    in        varchar2
  ,p_item_key                     in        varchar2
  ,p_activity_id                  in        number
  ,p_action                       in        varchar2
  ,p_login_person_id              in        number
  ,p_process_section_name         in        varchar2
  ,p_review_page_region_code      in        varchar2 default null

  ,p_adjusted_svc_date            in      date     default null
  ,p_datetrack_update_mode        in      varchar2 default hr_api.g_correction -- 9999
  ,p_applicant_number             in      varchar2 default null
  ,p_background_check_status      in      varchar2 default null
  ,p_background_date_check        in      date     default null
  ,p_benefit_group_id             in      number   default null
  ,p_blood_type                   in      varchar2 default null
  ,p_coord_ben_med_pln_no         in      varchar2 default null
  ,p_coord_ben_no_cvg_flag        in      varchar2 default null
  ,p_country_of_birth             in      varchar2 default null
  ,p_date_employee_data_verified  in      date     default null
  ,p_date_of_death                in      date     default null
  ,p_dpdnt_adoption_date          in      date     default null
  ,p_dpdnt_vlntry_svce_flag       in      varchar2 default null
  ,p_employee_number              in out nocopy  varchar2
  ,p_expense_check_send_to_addres in      varchar2 default null
  ,p_fast_path_employee           in      varchar2 default null
  ,p_fte_capacity                 in      number   default null
  ,p_global_person_id             in      varchar2 default null
  ,p_hold_applicant_date_until    in      date     default null
  ,p_internal_location            in      varchar2 default null
  ,p_last_medical_test_by         in      varchar2 default null
  ,p_last_medical_test_date       in      date     default null
  ,p_mailstop                     in      varchar2 default null
  ,p_office_number                in      varchar2 default null
  ,p_on_military_service          in      varchar2 default null
  ,p_original_date_of_hire        in      date     default null
  ,p_projected_start_date         in      date     default null
  ,p_receipt_of_death_cert_date   in      date     default null
  ,p_region_of_birth              in      varchar2 default null
  ,p_rehire_authorizor            in      varchar2 default null
  ,p_rehire_recommendation        in      varchar2 default null
  ,p_rehire_reason                in      varchar2 default null
  ,p_resume_exists                in      varchar2 default null
  ,p_resume_last_updated          in      date     default null
  ,p_second_passport_exists       in      varchar2 default null
  ,p_student_status               in      varchar2 default null
  ,p_town_of_birth                in      varchar2 default null
  ,p_uses_tobacco_flag            in      varchar2 default null
  ,p_vendor_id                    in      number   default null
  ,p_work_schedule                in      varchar2 default null
  ,p_contact_operation            in      varchar2 default null
  ,p_emrg_cont_flag               in      varchar2 default 'N'
  ,p_dpdnt_bnf_flag               in      varchar2 default 'N'
  ,p_save_mode                    in      varchar2  default null
-- Added new paramets
  ,P_CONT_INFORMATION_CATEGORY 	  in      varchar2    default null
  ,P_CONT_INFORMATION1            in      varchar2    default null
  ,P_CONT_INFORMATION2            in      varchar2    default null
  ,P_CONT_INFORMATION3            in      varchar2    default null
  ,P_CONT_INFORMATION4            in      varchar2    default null
  ,P_CONT_INFORMATION5            in      varchar2    default null
  ,P_CONT_INFORMATION6            in      varchar2    default null
  ,P_CONT_INFORMATION7            in      varchar2    default null
  ,P_CONT_INFORMATION8            in      varchar2    default null
  ,P_CONT_INFORMATION9            in      varchar2    default null
  ,P_CONT_INFORMATION10           in      varchar2    default null
  ,P_CONT_INFORMATION11           in      varchar2    default null
  ,P_CONT_INFORMATION12           in      varchar2    default null
  ,P_CONT_INFORMATION13           in      varchar2    default null
  ,P_CONT_INFORMATION14           in      varchar2    default null
  ,P_CONT_INFORMATION15           in      varchar2    default null
  ,P_CONT_INFORMATION16           in      varchar2    default null
  ,P_CONT_INFORMATION17           in      varchar2    default null
  ,P_CONT_INFORMATION18           in      varchar2    default null
  ,P_CONT_INFORMATION19           in      varchar2    default null
  ,P_CONT_INFORMATION20           in      varchar2    default null
--bug 4634855
  ,P_MIRROR_CONT_INFORMATION_CAT  in      varchar2    default null
  ,P_MIRROR_CONT_INFORMATION1     in      varchar2    default null
  ,P_MIRROR_CONT_INFORMATION2     in      varchar2    default null
  ,P_MIRROR_CONT_INFORMATION3     in      varchar2    default null
  ,P_MIRROR_CONT_INFORMATION4     in      varchar2    default null
  ,P_MIRROR_CONT_INFORMATION5     in      varchar2    default null
  ,P_MIRROR_CONT_INFORMATION6     in      varchar2    default null
  ,P_MIRROR_CONT_INFORMATION7     in      varchar2    default null
  ,P_MIRROR_CONT_INFORMATION8     in      varchar2    default null
  ,P_MIRROR_CONT_INFORMATION9     in      varchar2    default null
  ,P_MIRROR_CONT_INFORMATION10     in      varchar2    default null
  ,P_MIRROR_CONT_INFORMATION11     in      varchar2    default null
  ,P_MIRROR_CONT_INFORMATION12     in      varchar2    default null
  ,P_MIRROR_CONT_INFORMATION13     in      varchar2    default null
  ,P_MIRROR_CONT_INFORMATION14     in      varchar2    default null
  ,P_MIRROR_CONT_INFORMATION15     in      varchar2    default null
  ,P_MIRROR_CONT_INFORMATION16     in      varchar2    default null
  ,P_MIRROR_CONT_INFORMATION17     in      varchar2    default null
  ,P_MIRROR_CONT_INFORMATION18     in      varchar2    default null
  ,P_MIRROR_CONT_INFORMATION19     in      varchar2    default null
  ,P_MIRROR_CONT_INFORMATION20     in      varchar2    default null

  ,p_contact_relationship_id      out nocopy number
  ,p_ctr_object_version_number    out nocopy number
  ,p_per_person_id                out nocopy number
  ,p_per_object_version_number    out nocopy number
  ,p_per_effective_start_date     out nocopy date
  ,p_per_effective_end_date       out nocopy date
  ,p_full_name                    out nocopy varchar2
  ,p_per_comment_id               out nocopy number
  ,p_con_name_combination_warning out nocopy varchar2
  ,p_per_name_combination_warning out nocopy varchar2
  ,p_con_orig_hire_warning            out nocopy varchar2
  ,p_per_orig_hire_warning            out nocopy varchar2
  ,p_per_assign_payroll_warning       out nocopy varchar2
  ,p_ni_duplicate_warn_or_err   out nocopy varchar2

 )
 IS
  l_count                        INTEGER := 0;
  l_transaction_table            hr_transaction_ss.transaction_table;
  l_transaction_step_id          hr_api_transaction_steps.transaction_step_id%type;
  l_object_version_number        hr_api_transaction_steps.object_version_number%type;
  l_attribute_update_mode        varchar2(100) default  null;
  l_validate_mode                boolean  default false;
  l_con_name_combination_warning boolean;
  l_per_name_combination_warning boolean;
  l_con_orig_hire_warning        boolean;
  l_per_orig_hire_warning        boolean;
  l_con_assign_payroll_warning   boolean;
  l_per_assign_payroll_warning   boolean;
  l_con_rec_changed              boolean default false ;
  --
  -- StartRegistration changes
  --
  l_start_life_reason_id              number := null;
  l_end_life_reason_id                number := null;
  l_contact_relationship_id           number := null;
  l_sequence_number                   number := null;
  l_person_type_id                    number := null;
  --
  l_person_id                         number := null;
  l_transaction_id                    number default null;
  l_trans_obj_vers_num                number default null;
  l_result                            varchar2(100) default null;
  l_reg_per_ovn                       number default null;
  l_reg_employee_number               number default null;
  l_reg_asg_ovn                       number default null;
  l_reg_full_name                     per_all_people_f.full_name%type default null;
  l_reg_assignment_id                 number;
  l_reg_per_effective_start_date      date;
  l_reg_per_effective_end_date        date;
  l_reg_per_comment_id                number;
  l_reg_assignment_sequence           number;
  l_reg_assignment_number             varchar2(50);
  l_reg_name_combination_warning      boolean;
  l_reg_assign_payroll_warning        boolean;
  l_reg_orig_hire_warning             boolean;
  --Startregistration
  l_contact_set                       number;
  l_primary_contact_added             number := 0;
  --
  -- EndRegistration
  -- bug# 2168275, 2123868
  l_validate_g_per_step_id            number;
  l_main_per_eff_start_date           date;
  l_main_per_date_of_birth            date;
  l_start_date                        date;
  -- bug# 2315163
  l_is_emergency_contact              varchar2(50) default null;
  l_is_dpdnt_bnf                      varchar2(50) default null;
  l_proc   varchar2(72)  := g_package||'create_contact_tt';

--
BEGIN
  --
hr_utility.set_location('Entering:'||l_proc, 5);

-- Bug no:2263008 fix begins

check_ni_unique(
  p_national_identifier => p_national_identifier
  ,p_business_group_id => p_business_group_id
  ,p_person_id => p_contact_person_id
  ,p_ni_duplicate_warn_or_err => p_ni_duplicate_warn_or_err);

--Bug no:2263008 fix ends.
  --
-- bug#  2146328
  IF p_primary_contact_flag = 'Y' then

       -- Check if there are already any contacts as primary added.
       --
      hr_utility.set_location('IF p_primary_contact_flag =Y :'||l_proc,10 );
      BEGIN
         select count(hats.transaction_step_id)
         into   l_primary_contact_added
         from   hr_api_transaction_steps hats,
                hr_api_transaction_values hatv
         where  hats.item_type = p_item_type
         and    hats.item_key  = p_item_key
         and    hats.api_name  = 'HR_PROCESS_CONTACT_SS.PROCESS_CREATE_CONTACT_API'
         and    hats.transaction_step_id = hatv.transaction_step_id
         and    hatv.varchar2_value = 'Y'
         and    hatv.name = upper('p_primary_contact_flag');

        hr_utility.set_location(
           'HR_PROCESS_CONTACT_SS.create_contact_tt : Check if primary contact already added in previous step : '||l_primary_contact_added, 2146328);

      EXCEPTION
         WHEN others THEN
           null;

      END;

      IF l_primary_contact_added >0 then

         hr_utility.set_location('l_primary_contact_added >0:'||l_proc,15 );
         hr_utility.set_message(800, 'PER_289574_EMP_CON_PRIMARY');
         hr_utility.raise_error;


      END IF;

  END IF;   --p_primary_contact_flag = 'Y'

--end bug#2146328

  SAVEPOINT create_contact_tt_start;
  --
  IF upper(p_action) = g_change
  THEN
     l_attribute_update_mode := g_attribute_update;
  ELSE
     IF upper(p_action) = g_correct
     THEN
        l_attribute_update_mode := g_attribute_correct;
     END IF;
  END IF;
  hr_utility.set_location('Setting l_attribute_update_mode ', 20);
  --
  hr_utility.set_location('Calling hr_contact_rel_api.create_contact', 25);
  --
  -- Call the actual API.
  --
  -- Check if the record has changed is not necessary as it's a create.
  --
  -- The validate_mode for calling the create_contact
  -- api should always be set to true.
  --
  IF p_validate = 1 OR p_validate IS NULL
  THEN
      l_validate_mode := false;
  ELSE
      l_validate_mode := true;
  END IF;
  --
  -- StartRegistration changes
  --
  l_person_id := p_person_id;

 /*
--  bug # 2168275
   requirement : If relation_ship_start_date < (DOB of Employee) or (DOB of Contact), then
                 raise error message PER_50386_CON_SDT_LES_EMP_BDT.

    1. Get emplyee record start date

        if employee id is available, then
            get  Employee_DOB from per_people_f
        else
            get Employee_DOB from transaction_step

    1. if l_main_per_date_of_birth is not null and l_main_per_date_of_birth > p_date_start then
        raise error;
        set errormessage .....
    elsif p_date_of_birth is not null and p_date_of_birth > p_date_start then
        raise error;
        set errormessage .....

    2. Compare the DOBs with  p_date_start
        If  Employee_DOB > p_date_start then
            raise error.
        Else
            If  p_date_of_birth > p_date_start then
            raise error.

--  end bug # 2168275

--  bug # 2123868
   requirement : Contact record Start Date should be last of
                A.  Earliest contact Relation ship start dates
                B.  Employee Person reocrd Start date

    1. Get emplyee record start date

        If employee id is available, then
            get employee_effective_start_date from per_people_f
        Else
            get the employee_effective_start_date from trx

    2. Set p_date_start to last of

         begin
         if contact_person_id not null them
            get l_ear_con_Rel_start_date from per_contact_relationships
            set l_ear_con_Rel_start_date to  l_start_date
         else
            set relation_ship_start_date to  l_start_date
         exception
         end

         If employee_effective_start_date > l_start_date  then
            set l_start_date to employee_effective_start_date

--  end bug # 2123868



  --bug # 2168275,2123868
  begin

    if l_person_id is not null then
        select  min(p.date_of_birth) , min(p.effective_start_date)
        into    l_main_per_date_of_birth , l_main_per_eff_start_date
        from    per_people_f p
        where   p.person_id = l_person_id;
    else
        begin
            select nvl(max(hats1.transaction_step_id),0)
            into   l_validate_g_per_step_id
            from   hr_api_transaction_steps hats1
            where  hats1.item_type = 'HRSSA'
            and    hats1.item_key  = p_item_key
            and    hats1.api_name  in( 'HR_PROCESS_PERSON_SS.PROCESS_API', 'BEN_PROCESS_COBRA_PERSON_SS.PROCESS_API');

            l_main_per_date_of_birth := hr_transaction_api.get_date_value
                                (p_transaction_step_id => l_validate_g_per_step_id
                                ,p_name => 'P_DATE_OF_BIRTH') ;

            l_main_per_eff_start_date := hr_transaction_api.get_date_value
                                (p_transaction_step_id => l_validate_g_per_step_id
                                ,p_name => 'P_EFFECTIVE_DATE');

        exception
            when others then
            null;
        end;

    end if; --l_person_id is/not null

    -- raise error if relationship start date is earlier tahn date of birth
-- fix for bug # 2221040
    if  nvl(p_save_mode, 'NVL') <> 'SAVE_FOR_LATER'
      then
       if l_main_per_date_of_birth is not null and l_main_per_date_of_birth > p_date_start then
          hr_utility.set_message(800, 'PER_50386_CON_SDT_LES_EMP_BDT');
          hr_utility.raise_error;
       elsif p_date_of_birth is not null and p_date_of_birth > p_date_start then
          hr_utility.set_message(800, 'PER_50386_CON_SDT_LES_EMP_BDT');
          hr_utility.raise_error;
       end if;
    end if;
*/
begin

l_main_per_eff_start_date := p_date_start;

validate_rel_start_date (
   p_person_id     => p_person_id
  ,p_item_key      => p_item_key
  ,p_save_mode     => p_save_mode
  ,p_date_start    => l_main_per_eff_start_date
  ,p_date_of_birth => p_date_of_birth);

    l_start_date :=  p_start_date ;

    if p_contact_person_id is not null then

        begin
           hr_utility.set_location('if p_contact_person_id is not null then'||l_proc,30 );
            select min(date_start)
            into   l_start_date
            from   per_contact_relationships
            where  contact_person_id = p_contact_person_id;
        exception
            when others then
            null;
        end;
   /* bug #2224609
    else
        l_start_date := p_date_start;
   */
    end if;

    if l_main_per_eff_start_date > l_start_date  then
        l_start_date := l_main_per_eff_start_date;
    end if;

  end;
  -- end bug # 2168275,2123868
  --
  if (l_person_id is null or l_person_id = -1) and
     nvl(p_save_mode, 'NVL') <> 'SAVE_FOR_LATER'
  then
     hr_utility.set_location('l_person_id is null or l_person_id = -1 and not SFL'||l_proc,35 );
     --
     -- Either create a dummy person or temp solution use the p_login_person_id
     --
     -- l_person_id := p_login_person_id; This is for testing only.
      hr_employee_api.create_employee
      (p_validate                      => false  --in     boolean  default false
      --,p_hire_date                     => nvl(p_start_date,trunc(sysdate))
      ,p_hire_date                     => nvl(l_start_date,trunc(sysdate))
      ,p_business_group_id             => p_business_group_id
      ,p_last_name                     => 'XXX_MR_REGI'
      ,p_sex                           => 'M'
      ,p_employee_number               => l_reg_employee_number         --   in out varchar2
      ,p_person_id                     => l_person_id                   --   out number
      ,p_assignment_id                 => l_reg_assignment_id           --   out number
      ,p_per_object_version_number     => l_reg_per_ovn                 --   out number
      ,p_asg_object_version_number     => l_reg_asg_ovn                 --   out number
      ,p_per_effective_start_date      => l_reg_per_effective_start_date --   out date
      ,p_per_effective_end_date        => l_reg_per_effective_end_date   --   out date
      ,p_full_name                     => l_reg_full_name                --   out varchar2
      ,p_per_comment_id                => l_reg_per_comment_id           --   out number
      ,p_assignment_sequence           => l_reg_assignment_sequence      --   out number
      ,p_assignment_number             => l_reg_assignment_number        --   out varchar2
      ,p_name_combination_warning      => l_reg_name_combination_warning --   out boolean
      ,p_assign_payroll_warning        => l_reg_assign_payroll_warning   --   out boolean
      ,p_orig_hire_warning             => l_reg_orig_hire_warning        --  out boolean
      );
     --
  end if;
  --
  -- EndRegistration
  --
  l_start_life_reason_id  := p_start_life_reason_id;
  if  p_start_life_reason_id <=0 then
      l_start_life_reason_id  := null;
  end if;

  l_end_life_reason_id      := p_end_life_reason_id;
  if p_end_life_reason_id   <= 0 then
     l_end_life_reason_id      := null;
  end if;

  l_contact_relationship_id := p_contact_relationship_id;
  if p_contact_relationship_id  <= 0 then
     l_contact_relationship_id   := null;
  end if;

  l_sequence_number  := p_sequence_number;
  if p_sequence_number  <= 0 then
     l_sequence_number  := null;
  end if;

  l_person_type_id :=  p_person_type_id ;
  if (p_person_type_id <= 0 OR p_person_type_id is null) then
     l_person_type_id :=  hr_person_type_usage_info.get_default_person_type_id
                 (p_business_group_id,
              'OTHER');
  end if;
  --
  -- set the validation to false as the person_id is necessary for
  -- update_person api.
  --
  if  nvl(p_save_mode, 'NVL') <> 'SAVE_FOR_LATER'
  then
       hr_utility.set_location('p_save_mode not SFL'||l_proc,40 );

   --
 -- Bug 3152505 : calling call_contact_api
 --   hr_contact_rel_api.create_contact(
    call_contact_api(
    p_validate                 		=>  false -- l_validate_mode
   ,p_start_date               		=>  l_start_date --p_start_date
   ,p_business_group_id        		=>  p_business_group_id
   ,p_person_id                		=>  l_person_id
   ,p_contact_person_id        		=>  p_contact_person_id
   ,p_contact_type             		=>  p_contact_type
   ,p_ctr_comments             		=>  p_ctr_comments
   ,p_primary_contact_flag     		=>  p_primary_contact_flag
   ,p_date_start               		=>  p_date_start
   ,p_start_life_reason_id     		=>  l_start_life_reason_id
   ,p_date_end                 		=>  p_date_end
   ,p_end_life_reason_id       		=>  l_end_life_reason_id
   ,p_rltd_per_rsds_w_dsgntr_flag     	=>  p_rltd_per_rsds_w_dsgntr_flag
   ,p_personal_flag                   	=>  p_personal_flag
   ,p_sequence_number                 	=>  l_sequence_number
   ,p_cont_attribute_category     	=>  p_cont_attribute_category
   ,p_cont_attribute1                 	=>  p_cont_attribute1
   ,p_cont_attribute2                 	=>  p_cont_attribute2
   ,p_cont_attribute3                 	=>  p_cont_attribute3
   ,p_cont_attribute4                 	=>  p_cont_attribute4
   ,p_cont_attribute5     		=>  p_cont_attribute5
   ,p_cont_attribute6     		=>  p_cont_attribute6
   ,p_cont_attribute7     		=>  p_cont_attribute7
   ,p_cont_attribute8     		=>  p_cont_attribute8
   ,p_cont_attribute9     		=>  p_cont_attribute9
   ,p_cont_attribute10     		=>  p_cont_attribute10
   ,p_cont_attribute11     		=>  p_cont_attribute11
   ,p_cont_attribute12     		=>  p_cont_attribute12
   ,p_cont_attribute13     		=>  p_cont_attribute13
   ,p_cont_attribute14     		=>  p_cont_attribute14
   ,p_cont_attribute15     		=>  p_cont_attribute15
   ,p_cont_attribute16     		=>  p_cont_attribute16
   ,p_cont_attribute17     		=>  p_cont_attribute17
   ,p_cont_attribute18     		=>  p_cont_attribute18
   ,p_cont_attribute19     		=>  p_cont_attribute19
   ,p_cont_attribute20    		=>  p_cont_attribute20
   ,p_third_party_pay_flag     		=>  p_third_party_pay_flag
   ,p_bondholder_flag     		=>  p_bondholder_flag
   ,p_dependent_flag     		=>  p_dependent_flag
   ,p_beneficiary_flag     		=>  p_beneficiary_flag
   ,p_last_name     			=>  p_last_name
   ,p_sex     				=>  p_sex
   ,p_person_type_id     		=>  l_person_type_id
   ,p_per_comments     			=>  p_per_comments
   ,p_date_of_birth     		=>  p_date_of_birth
   ,p_email_address     		=>  p_email_address
   ,p_first_name     			=>  p_first_name
   ,p_known_as     			=>  p_known_as
   ,p_marital_status     		=>  p_marital_status
   ,p_middle_names     			=>  p_middle_names
   ,p_nationality     			=>  p_nationality
   ,p_national_identifier     		=>  p_national_identifier
   ,p_previous_last_name     		=>  p_previous_last_name
   ,p_registered_disabled_flag     	=>  p_registered_disabled_flag
   ,p_title     			=>  p_title
   ,p_work_telephone     		=>  p_work_telephone
   ,p_attribute_category     		=>  p_attribute_category
   ,p_attribute1     			=>  p_attribute1
   ,p_attribute2     			=>  p_attribute2
   ,p_attribute3     			=>  p_attribute3
   ,p_attribute4     			=>  p_attribute4
   ,p_attribute5     			=>  p_attribute5
   ,p_attribute6     			=>  p_attribute6
   ,p_attribute7     			=>  p_attribute7
   ,p_attribute8     			=>  p_attribute8
   ,p_attribute9     			=>  p_attribute9
   ,p_attribute10     			=>  p_attribute10
   ,p_attribute11     			=>  p_attribute11
   ,p_attribute12     			=>  p_attribute12
   ,p_attribute13     			=>  p_attribute13
   ,p_attribute14     			=>  p_attribute14
   ,p_attribute15     			=>  p_attribute15
   ,p_attribute16     			=>  p_attribute16
   ,p_attribute17     			=>  p_attribute17
   ,p_attribute18     			=>  p_attribute18
   ,p_attribute19     			=>  p_attribute19
   ,p_attribute20     			=>  p_attribute20
   ,p_attribute21     			=>  p_attribute21
   ,p_attribute22     			=>  p_attribute22
   ,p_attribute23     			=>  p_attribute23
   ,p_attribute24     			=>  p_attribute24
   ,p_attribute25     			=>  p_attribute25
   ,p_attribute26     			=>  p_attribute26
   ,p_attribute27     			=>  p_attribute27
   ,p_attribute28     			=>  p_attribute28
   ,p_attribute29     			=>  p_attribute29
   ,p_attribute30     			=>  p_attribute30
   ,p_per_information_category     	=>  p_per_information_category
   ,p_per_information1      =>  p_per_information1
   ,p_per_information2      =>  p_per_information2
   ,p_per_information3      =>  p_per_information3
   ,p_per_information4      =>  p_per_information4
   ,p_per_information5      =>  p_per_information5
   ,p_per_information6      =>  p_per_information6
   ,p_per_information7      =>  p_per_information7
   ,p_per_information8      =>  p_per_information8
   ,p_per_information9      =>  p_per_information9
   ,p_per_information10     =>  p_per_information10
   ,p_per_information11     =>  p_per_information11
   ,p_per_information12     =>  p_per_information12
   ,p_per_information13     =>  p_per_information13
   ,p_per_information14     =>  p_per_information14
   ,p_per_information15     =>  p_per_information15
   ,p_per_information16     =>  p_per_information16
   ,p_per_information17     =>  p_per_information17
   ,p_per_information18     =>  p_per_information18
   ,p_per_information19     =>  p_per_information19
   ,p_per_information20     =>  p_per_information20
   ,p_per_information21     =>  p_per_information21
   ,p_per_information22     =>  p_per_information22
   ,p_per_information23     =>  p_per_information23
   ,p_per_information24     =>  p_per_information24
   ,p_per_information25     =>  p_per_information25
   ,p_per_information26     =>  p_per_information26
   ,p_per_information27     =>  p_per_information27
   ,p_per_information28     =>  p_per_information28
   ,p_per_information29     =>  p_per_information29
   ,p_per_information30     =>  p_per_information30
   ,p_correspondence_language   =>  p_correspondence_language
   ,p_honors     		=>  p_honors
   ,p_pre_name_adjunct     	=>  p_pre_name_adjunct
   ,p_suffix     		=>  p_suffix
   ,p_create_mirror_flag     	=>  p_create_mirror_flag
   ,p_mirror_type     		=>  p_mirror_type
   ,p_mirror_cont_attribute_cat   =>  p_mirror_cont_attribute_cat
   ,p_mirror_cont_attribute1      =>  p_mirror_cont_attribute1
   ,p_mirror_cont_attribute2      =>  p_mirror_cont_attribute2
   ,p_mirror_cont_attribute3      =>  p_mirror_cont_attribute3
   ,p_mirror_cont_attribute4      =>  p_mirror_cont_attribute4
   ,p_mirror_cont_attribute5      =>  p_mirror_cont_attribute5
   ,p_mirror_cont_attribute6      =>  p_mirror_cont_attribute6
   ,p_mirror_cont_attribute7      =>  p_mirror_cont_attribute7
   ,p_mirror_cont_attribute8      =>  p_mirror_cont_attribute8
   ,p_mirror_cont_attribute9      =>  p_mirror_cont_attribute9
   ,p_mirror_cont_attribute10     =>  p_mirror_cont_attribute10
   ,p_mirror_cont_attribute11     =>  p_mirror_cont_attribute11
   ,p_mirror_cont_attribute12     =>  p_mirror_cont_attribute12
   ,p_mirror_cont_attribute13     =>  p_mirror_cont_attribute13
   ,p_mirror_cont_attribute14     =>  p_mirror_cont_attribute14
   ,p_mirror_cont_attribute15     =>  p_mirror_cont_attribute15
   ,p_mirror_cont_attribute16     =>  p_mirror_cont_attribute16
   ,p_mirror_cont_attribute17     =>  p_mirror_cont_attribute17
   ,p_mirror_cont_attribute18     =>  p_mirror_cont_attribute18
   ,p_mirror_cont_attribute19     =>  p_mirror_cont_attribute19
   ,p_mirror_cont_attribute20     =>  p_mirror_cont_attribute20
   ,P_CONT_INFORMATION_CATEGORY   => P_CONT_INFORMATION_CATEGORY
   ,P_CONT_INFORMATION1           => P_CONT_INFORMATION1
   ,P_CONT_INFORMATION2           => P_CONT_INFORMATION2
   ,P_CONT_INFORMATION3           => P_CONT_INFORMATION3
   ,P_CONT_INFORMATION4           => P_CONT_INFORMATION4
   ,P_CONT_INFORMATION5           => P_CONT_INFORMATION5
   ,P_CONT_INFORMATION6           => P_CONT_INFORMATION6
   ,P_CONT_INFORMATION7           => P_CONT_INFORMATION7
   ,P_CONT_INFORMATION8           => P_CONT_INFORMATION8
   ,P_CONT_INFORMATION9           => P_CONT_INFORMATION9
   ,P_CONT_INFORMATION10          => P_CONT_INFORMATION10
   ,P_CONT_INFORMATION11          => P_CONT_INFORMATION11
   ,P_CONT_INFORMATION12          => P_CONT_INFORMATION12
   ,P_CONT_INFORMATION13          => P_CONT_INFORMATION13
   ,P_CONT_INFORMATION14          => P_CONT_INFORMATION14
   ,P_CONT_INFORMATION15          => P_CONT_INFORMATION15
   ,P_CONT_INFORMATION16          => P_CONT_INFORMATION16
   ,P_CONT_INFORMATION17          => P_CONT_INFORMATION17
   ,P_CONT_INFORMATION18          => P_CONT_INFORMATION18
   ,P_CONT_INFORMATION19          => P_CONT_INFORMATION19
   ,P_CONT_INFORMATION20          => P_CONT_INFORMATION20
   ,P_MIRROR_CONT_INFORMATION_CAT => P_MIRROR_CONT_INFORMATION_CAT
   ,P_MIRROR_CONT_INFORMATION1    => P_MIRROR_CONT_INFORMATION1
   ,P_MIRROR_CONT_INFORMATION2    => P_MIRROR_CONT_INFORMATION2
   ,P_MIRROR_CONT_INFORMATION3    => P_MIRROR_CONT_INFORMATION3
   ,P_MIRROR_CONT_INFORMATION4    => P_MIRROR_CONT_INFORMATION4
   ,P_MIRROR_CONT_INFORMATION5    => P_MIRROR_CONT_INFORMATION5
   ,P_MIRROR_CONT_INFORMATION6    => P_MIRROR_CONT_INFORMATION6
   ,P_MIRROR_CONT_INFORMATION7    => P_MIRROR_CONT_INFORMATION7
   ,P_MIRROR_CONT_INFORMATION8    => P_MIRROR_CONT_INFORMATION8
   ,P_MIRROR_CONT_INFORMATION9    => P_MIRROR_CONT_INFORMATION9
   ,P_MIRROR_CONT_INFORMATION10    => P_MIRROR_CONT_INFORMATION10
   ,P_MIRROR_CONT_INFORMATION11    => P_MIRROR_CONT_INFORMATION11
   ,P_MIRROR_CONT_INFORMATION12    => P_MIRROR_CONT_INFORMATION12
   ,P_MIRROR_CONT_INFORMATION13    => P_MIRROR_CONT_INFORMATION13
   ,P_MIRROR_CONT_INFORMATION14    => P_MIRROR_CONT_INFORMATION14
   ,P_MIRROR_CONT_INFORMATION15    => P_MIRROR_CONT_INFORMATION15
   ,P_MIRROR_CONT_INFORMATION16    => P_MIRROR_CONT_INFORMATION16
   ,P_MIRROR_CONT_INFORMATION17    => P_MIRROR_CONT_INFORMATION17
   ,P_MIRROR_CONT_INFORMATION18    => P_MIRROR_CONT_INFORMATION18
   ,P_MIRROR_CONT_INFORMATION19    => P_MIRROR_CONT_INFORMATION19
   ,P_MIRROR_CONT_INFORMATION20    => P_MIRROR_CONT_INFORMATION20
   ,p_contact_relationship_id     => l_contact_relationship_id
   ,p_ctr_object_version_number   => p_ctr_object_version_number
   ,p_per_person_id               => p_per_person_id
   ,p_per_object_version_number   => p_per_object_version_number
   ,p_per_effective_start_date    => p_per_effective_start_date
   ,p_per_effective_end_date      => p_per_effective_end_date
   ,p_full_name                   => p_full_name
   ,p_per_comment_id              => p_per_comment_id
   ,p_name_combination_warning    => l_con_name_combination_warning
   ,p_orig_hire_warning           => l_con_orig_hire_warning
   ,p_contact_operation           => p_contact_operation
   ,p_emrg_cont_flag              => p_emrg_cont_flag
   );
   --
  end if;
  --
  -- Validating the update_person
  --

  hr_utility.set_location('After calling validate proceses ', 45);
  --
  IF hr_errors_api.errorExists
  THEN
     hr_utility.set_location('api error exists hr_contact_rel_api.create_contact', 50);
     rollback to create_contact_tt_start  ;
     raise g_data_error;
  END IF;

   l_con_rec_changed := is_con_rec_changed(
    p_adjusted_svc_date     	=>  p_adjusted_svc_date
   ,p_applicant_number     	=>  p_applicant_number
   ,p_background_check_status   =>  p_background_check_status
   ,p_background_date_check     =>  p_background_date_check
   ,p_benefit_group_id     	=>  p_benefit_group_id
   ,p_blood_type     		=>  p_blood_type
   ,p_coord_ben_med_pln_no     	=>  p_coord_ben_med_pln_no
   ,p_coord_ben_no_cvg_flag     =>  p_coord_ben_no_cvg_flag
   ,p_country_of_birth     	=>  p_country_of_birth
   ,p_date_employee_data_verified  =>  p_date_employee_data_verified
   ,p_date_of_death     	=>  p_date_of_death
   ,p_dpdnt_adoption_date     	=>  p_dpdnt_adoption_date
   ,p_dpdnt_vlntry_svce_flag    =>  p_dpdnt_vlntry_svce_flag
   ,p_expense_check_send_to_addres     =>  p_expense_check_send_to_addres
   ,p_fast_path_employee     	=>  p_fast_path_employee
   ,p_fte_capacity     		=>  p_fte_capacity
   ,p_global_person_id     	=>  p_global_person_id
   ,p_hold_applicant_date_until     =>  p_hold_applicant_date_until
   ,p_internal_location     	=>  p_internal_location
   ,p_last_medical_test_by      =>  p_last_medical_test_by
   ,p_last_medical_test_date    =>  p_last_medical_test_date
   ,p_mailstop     		=>  p_mailstop
   ,p_office_number     	=>  p_office_number
   ,p_on_military_service     	=>  p_on_military_service
   ,p_original_date_of_hire     =>  p_original_date_of_hire
   ,p_projected_start_date      =>  p_projected_start_date
   ,p_receipt_of_death_cert_date     =>  p_receipt_of_death_cert_date
   ,p_region_of_birth     	=>  p_region_of_birth
   ,p_rehire_authorizor     	=>  p_rehire_authorizor
   ,p_rehire_recommendation     =>  p_rehire_recommendation
   ,p_rehire_reason     	=>  p_rehire_reason
   ,p_resume_exists     	=>  p_resume_exists
   ,p_resume_last_updated     	=>  p_resume_last_updated
   ,p_second_passport_exists    =>  p_second_passport_exists
   ,p_student_status     	=>  p_student_status
   ,p_town_of_birth     	=>  p_town_of_birth
   ,p_uses_tobacco_flag     	=>  p_uses_tobacco_flag
   ,p_vendor_id     		=>  p_vendor_id
   ,p_work_schedule     	=>  p_work_schedule ) ;

 IF l_con_rec_changed and
    nvl(p_save_mode, 'NVL') <> 'SAVE_FOR_LATER'
 THEN
    --
    -- Get the Employee number from the Database;
    --
    hr_utility.set_location('Declaring the Cursor c_pap'||l_proc,50);
    DECLARE
               CURSOR c_pap IS SELECT employee_number FROM per_all_people_f
                            WHERE person_id = p_per_person_id
                            AND  p_start_date BETWEEN
                                 effective_start_date AND effective_end_date ;
               l_pap    c_pap%ROWTYPE;

    BEGIN
               --
               OPEN c_pap ;
               FETCH c_pap INTO l_pap ;
               CLOSE c_pap ;
               --
               p_employee_number := l_pap.employee_number ;
               --
    EXCEPTION WHEN OTHERS THEN
    hr_utility.set_location('Exception in c_pap Cursor:'||l_proc,555);
             raise ;
    END;
    --
    hr_utility.set_location('Calling hr_person_api.update_person '||l_proc,55);
    hr_person_api.update_person (
      p_validate      			=>  l_validate_mode
     ,p_effective_date      		=>  l_start_date
                                           --p_start_date  --9999p_effective_date
     ,p_datetrack_update_mode      	=>  hr_api.g_correction
                                            -- 9999 p_datetrack_update_mode
     ,p_person_id      			=>  p_per_person_id
     ,p_object_version_number      	=>  p_per_object_version_number
     --  ,p_person_type_id       	=>  p_person_type_id
     -- ,p_last_name       		=>  p_last_name
     ,p_applicant_number       	        =>  p_applicant_number
     --,p_comments       		=>  p_ctr_comments
     ,p_date_employee_data_verified     =>  p_date_employee_data_verified
     --  ,p_date_of_birth       	=>  p_date_of_birth
     --  ,p_email_address       	=>  p_email_address
     ,p_employee_number       	        =>  p_employee_number    --in out nocopy Param
     ,p_expense_check_send_to_addres    =>  p_expense_check_send_to_addres
     --  ,p_first_name        	        =>  p_first_name
     --  ,p_known_as        	        =>  p_known_as
     --  ,p_marital_status              =>  p_marital_status
     --  ,p_middle_names                =>  p_middle_names
     --  ,p_nationality       		=>  p_nationality
     --  ,p_national_identifier       	=>  p_national_identifier
     --  ,p_previous_last_name       	=>  p_previous_last_name
     --  ,p_registered_disabled_flag    =>  p_registered_disabled_flag
     --  ,p_sex       			=>  p_sex
     --  ,p_title       		=>  p_title
     ,p_vendor_id       		=>  p_vendor_id
     --  ,p_work_telephone       	=>  p_work_telephone
     ,p_date_of_death       	        =>  p_date_of_death
     ,p_background_check_status         =>  p_background_check_status
     ,p_background_date_check           =>  p_background_date_check
     ,p_blood_type       		=>  p_blood_type
     --   ,p_correspondence_language    =>  p_correspondence_language
     ,p_fast_path_employee       	=>  p_fast_path_employee
     ,p_fte_capacity       	        =>  p_fte_capacity
     ,p_hold_applicant_date_until       =>  p_hold_applicant_date_until
     --   ,p_honors       		=>  p_honors
     ,p_internal_location       	=>  p_internal_location
     ,p_last_medical_test_by            =>  p_last_medical_test_by
     ,p_last_medical_test_date          =>  p_last_medical_test_date
     ,p_mailstop       		        =>  p_mailstop
     ,p_office_number       	        =>  p_office_number
     ,p_on_military_service       	=>  p_on_military_service
     --   ,p_pre_name_adjunct       	=>  p_pre_name_adjunct
     ,p_projected_start_date            =>  p_projected_start_date
     ,p_rehire_authorizor       	=>  p_rehire_authorizor
     ,p_rehire_recommendation           =>  p_rehire_recommendation
     ,p_resume_exists            	=>  p_resume_exists
     ,p_resume_last_updated             =>  p_resume_last_updated
     ,p_second_passport_exists          =>  p_second_passport_exists
     ,p_student_status       	        =>  p_student_status
     ,p_work_schedule       	        =>  p_work_schedule
     ,p_rehire_reason       	        =>  p_rehire_reason
     --   ,p_suffix       		=>  p_suffix
     ,p_benefit_group_id       	        =>  p_benefit_group_id
     ,p_receipt_of_death_cert_date      =>  p_receipt_of_death_cert_date
     ,p_coord_ben_med_pln_no            =>  p_coord_ben_med_pln_no
     ,p_coord_ben_no_cvg_flag           =>  p_coord_ben_no_cvg_flag
     ,p_uses_tobacco_flag       	=>  p_uses_tobacco_flag
     ,p_dpdnt_adoption_date       	=>  p_dpdnt_adoption_date
     ,p_dpdnt_vlntry_svce_flag          =>  p_dpdnt_vlntry_svce_flag
     ,p_original_date_of_hire           =>  p_original_date_of_hire
     ,p_adjusted_svc_date       	=>  p_adjusted_svc_date
     ,p_town_of_birth       	        =>  p_town_of_birth
     ,p_region_of_birth       	        =>  p_region_of_birth
     ,p_country_of_birth       	        =>  p_country_of_birth
     ,p_global_person_id       	        =>  p_global_person_id
     -- Out Parameters
     ,p_effective_start_date            =>  p_per_effective_start_date
     ,p_effective_end_date       	=>  p_per_effective_end_date
     ,p_full_name       		=>  p_full_name
     ,p_comment_id       		=>  p_per_comment_id
     ,p_name_combination_warning        =>  l_per_name_combination_warning
     ,p_assign_payroll_warning          =>  l_per_assign_payroll_warning
     ,p_orig_hire_warning       	=>  l_per_orig_hire_warning
    );
    --
    hr_utility.set_location('After calling validate proceses ', 65);
    --
    IF hr_errors_api.errorExists
    THEN
      hr_utility.set_location('api error exists  hr_person_api.update_person ', 67);
      rollback to create_contact_tt_start  ;
      raise g_data_error;
    END IF;

  END IF; -- End if for is_con_rec_changed

  rollback to create_contact_tt_start  ;

  if l_per_assign_payroll_warning then
     p_per_assign_payroll_warning := 'Y';
  else
     p_per_assign_payroll_warning := 'N';
  end if;
  --
  if l_con_name_combination_warning then
     p_con_name_combination_warning := 'Y';
  else
     p_con_name_combination_warning := 'N';
  end if;
  --
  if l_per_name_combination_warning then
     p_per_name_combination_warning := 'Y';
  else
     p_per_name_combination_warning := 'N';
  end if;
  --
  if l_con_orig_hire_warning then
     p_con_orig_hire_warning := 'Y';
  else
     p_con_orig_hire_warning := 'N';
  end if;
  --
  if l_per_orig_hire_warning then
     p_per_orig_hire_warning := 'Y';
  else
     p_per_orig_hire_warning := 'N';
  end if;
  --
  -- --------------------------------------------------------------------------
  -- We will write the data to transaction tables.
  -- Determine if a transaction step exists for this activity
  -- if a transaction step does exist then the transaction_step_id and
  -- object_version_number are set (i.e. not null).
  -- --------------------------------------------------------------------------
  --
  /* StartRegistration : Begin code addition */
  --
  -- First, check if transaction id exists or not
  l_transaction_id := hr_transaction_ss.get_transaction_id
                     (p_item_type   => p_item_type
                     ,p_item_key    => p_item_key);
  --
  IF l_transaction_id is null THEN
     -- Start a Transaction
        hr_transaction_ss.start_transaction
           (itemtype   => p_item_type
           ,itemkey    => p_item_key
           ,actid      => p_activity_id
           ,funmode    => 'RUN'
           ,p_api_addtnl_info => p_contact_operation  --TEST
           ,p_login_person_id => nvl(p_login_person_id, p_person_id)
           ,result     => l_result);

        l_transaction_id := hr_transaction_ss.get_transaction_id
                        (p_item_type   => p_item_type
                        ,p_item_key    => p_item_key);
  END IF;
  --
  -- Create a transaction step
  --
  hr_transaction_api.create_transaction_step
     (p_validate              => false
     ,p_creator_person_id     => nvl(p_login_person_id, p_person_id)
     ,p_transaction_id        => l_transaction_id
     ,p_api_name              => g_package || '.PROCESS_CREATE_CONTACT_API'
     ,p_item_type             => p_item_type
     ,p_item_key              => p_item_key
     ,p_activity_id           => p_activity_id
     ,p_transaction_step_id   => l_transaction_step_id
     ,p_object_version_number => l_trans_obj_vers_num);

  /* EndRegistration : code addition */

  SAVEPOINT create_contact_tt;

  --
  -- This parameter will be used in the process_api for calling update_person
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_CONT_REC_CHANGED';
  l_transaction_table(l_count).param_value := 'CHANGED';
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_contact_operation');
  l_transaction_table(l_count).param_value := p_contact_operation;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_emrg_cont_flag');
  l_transaction_table(l_count).param_value := p_emrg_cont_flag;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_dpdnt_bnf_flag');
  l_transaction_table(l_count).param_value := p_dpdnt_bnf_flag;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  -- bug# 2315163
  --
  if p_contact_operation    in( 'EMER_CR_NEW_CONT','EMER_CR_NEW_REL', 'EMRG_OVRW_UPD')
     or p_emrg_cont_flag    =   'Y' then

      l_is_emergency_contact := 'Yes';
  else
      l_is_emergency_contact := 'No';
  end if;

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_is_emergency_contact');
  l_transaction_table(l_count).param_value := l_is_emergency_contact;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  if p_contact_operation  in ( 'DPDNT_CR_NEW_CONT', 'DPDNT_CR_NEW_REL',  'DPDNT_OVRW_UPD')
     or p_dpdnt_bnf_flag    =   'Y' then

      l_is_dpdnt_bnf := 'Yes';
  else
      l_is_dpdnt_bnf := 'No';
  end if;

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := upper('p_is_dpdnt_bnf');
  l_transaction_table(l_count).param_value := l_is_dpdnt_bnf;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count:=l_count+1;
  l_transaction_table(l_count).param_name      := 'P_SAVE_MODE';
  l_transaction_table(l_count).param_value     :=  p_save_mode;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_contact_relationship_id');
  l_transaction_table(l_count).param_value := null ;
  l_transaction_table(l_count).param_data_type := upper('number');
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_cont_object_version_number');
  l_transaction_table(l_count).param_value := null ;
  l_transaction_table(l_count).param_data_type := upper('number');

  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_start_date');
  --  l_transaction_table(l_count).param_value := to_char(p_start_date
  l_transaction_table(l_count).param_value := to_char(l_start_date
                      , hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := upper('date');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_business_group_id');
  l_transaction_table(l_count).param_value := p_business_group_id;
  l_transaction_table(l_count).param_data_type := upper('number');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_person_id');
  l_transaction_table(l_count).param_value := p_person_id;
  l_transaction_table(l_count).param_data_type := upper('number');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_contact_person_id');
  l_transaction_table(l_count).param_value := p_contact_person_id;
  l_transaction_table(l_count).param_data_type := upper('number');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_contact_type');
  l_transaction_table(l_count).param_value := p_contact_type;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_ctr_comments');
  l_transaction_table(l_count).param_value := p_ctr_comments;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_primary_contact_flag');
  l_transaction_table(l_count).param_value := p_primary_contact_flag;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_date_start');
  l_transaction_table(l_count).param_value := to_char(p_date_start
                                          , hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := upper('date');
  --
  -- StartRegistration
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_start_life_reason_id');
  l_transaction_table(l_count).param_value := l_start_life_reason_id;
  l_transaction_table(l_count).param_data_type := upper('number');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_date_end');
  l_transaction_table(l_count).param_value := to_char(p_date_end
                                          , hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := upper('date');
  --
  -- StartRegistration
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_end_life_reason_id');
  l_transaction_table(l_count).param_value := l_end_life_reason_id;
  l_transaction_table(l_count).param_data_type := upper('number');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_rltd_per_rsds_w_dsgntr_flag');
  l_transaction_table(l_count).param_value := p_rltd_per_rsds_w_dsgntr_flag;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_personal_flag');
  l_transaction_table(l_count).param_value := p_personal_flag;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  -- StartRegistration
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_sequence_number');
  l_transaction_table(l_count).param_value := l_sequence_number;
  l_transaction_table(l_count).param_data_type := upper('number');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_cont_attribute_category');
  l_transaction_table(l_count).param_value := p_cont_attribute_category;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_cont_attribute1');
  l_transaction_table(l_count).param_value := p_cont_attribute1;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_cont_attribute2');
  l_transaction_table(l_count).param_value := p_cont_attribute2;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_cont_attribute3');
  l_transaction_table(l_count).param_value := p_cont_attribute3;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_cont_attribute4');
  l_transaction_table(l_count).param_value := p_cont_attribute4;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_cont_attribute5');
  l_transaction_table(l_count).param_value := p_cont_attribute5;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_cont_attribute6');
  l_transaction_table(l_count).param_value := p_cont_attribute6;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_cont_attribute7');
  l_transaction_table(l_count).param_value := p_cont_attribute7;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_cont_attribute8');
  l_transaction_table(l_count).param_value := p_cont_attribute8;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_cont_attribute9');
  l_transaction_table(l_count).param_value := p_cont_attribute9;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_cont_attribute10');
  l_transaction_table(l_count).param_value := p_cont_attribute10;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_cont_attribute11');
  l_transaction_table(l_count).param_value := p_cont_attribute11;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_cont_attribute12');
  l_transaction_table(l_count).param_value := p_cont_attribute12;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_cont_attribute13');
  l_transaction_table(l_count).param_value := p_cont_attribute13;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_cont_attribute14');
  l_transaction_table(l_count).param_value := p_cont_attribute14;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_cont_attribute15');
  l_transaction_table(l_count).param_value := p_cont_attribute15;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_cont_attribute16');
  l_transaction_table(l_count).param_value := p_cont_attribute16;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_cont_attribute17');
  l_transaction_table(l_count).param_value := p_cont_attribute17;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_cont_attribute18');
  l_transaction_table(l_count).param_value := p_cont_attribute18;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_cont_attribute19');
  l_transaction_table(l_count).param_value := p_cont_attribute19;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_cont_attribute20');
  l_transaction_table(l_count).param_value := p_cont_attribute20;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_third_party_pay_flag');
  l_transaction_table(l_count).param_value := p_third_party_pay_flag;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_bondholder_flag');
  l_transaction_table(l_count).param_value := p_bondholder_flag;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_dependent_flag');
  l_transaction_table(l_count).param_value := p_dependent_flag;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_beneficiary_flag');
  l_transaction_table(l_count).param_value := p_beneficiary_flag;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_last_name');
  l_transaction_table(l_count).param_value := p_last_name;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_sex');
  l_transaction_table(l_count).param_value := p_sex;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  -- StartRegistration
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_person_type_id');
  l_transaction_table(l_count).param_value := l_person_type_id;
  l_transaction_table(l_count).param_data_type := upper('number');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_per_comments');
  l_transaction_table(l_count).param_value := p_per_comments;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_date_of_birth');
  l_transaction_table(l_count).param_value :=
                to_char(p_date_of_birth , hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := upper('date');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_email_address');
  l_transaction_table(l_count).param_value := p_email_address;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_first_name');
  l_transaction_table(l_count).param_value := p_first_name;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_known_as');
  l_transaction_table(l_count).param_value := p_known_as;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_marital_status');
  l_transaction_table(l_count).param_value := p_marital_status;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_middle_names');
  l_transaction_table(l_count).param_value := p_middle_names;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_nationality');
  l_transaction_table(l_count).param_value := p_nationality;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_national_identifier');
  l_transaction_table(l_count).param_value := p_national_identifier;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_previous_last_name');
  l_transaction_table(l_count).param_value := p_previous_last_name;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_registered_disabled_flag');
  l_transaction_table(l_count).param_value := p_registered_disabled_flag;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_title');
  l_transaction_table(l_count).param_value := p_title;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_work_telephone');
  l_transaction_table(l_count).param_value := p_work_telephone;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_attribute_category');
  l_transaction_table(l_count).param_value := p_attribute_category;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_attribute1');
  l_transaction_table(l_count).param_value := p_attribute1;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_attribute2');
  l_transaction_table(l_count).param_value := p_attribute2;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_attribute3');
  l_transaction_table(l_count).param_value := p_attribute3;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_attribute4');
  l_transaction_table(l_count).param_value := p_attribute4;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_attribute5');
  l_transaction_table(l_count).param_value := p_attribute5;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_attribute6');
  l_transaction_table(l_count).param_value := p_attribute6;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_attribute7');
  l_transaction_table(l_count).param_value := p_attribute7;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_attribute8');
  l_transaction_table(l_count).param_value := p_attribute8;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_attribute9');
  l_transaction_table(l_count).param_value := p_attribute9;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_attribute10');
  l_transaction_table(l_count).param_value := p_attribute10;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_attribute11');
  l_transaction_table(l_count).param_value := p_attribute11;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_attribute12');
  l_transaction_table(l_count).param_value := p_attribute12;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_attribute13');
  l_transaction_table(l_count).param_value := p_attribute13;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_attribute14');
  l_transaction_table(l_count).param_value := p_attribute14;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_attribute15');
  l_transaction_table(l_count).param_value := p_attribute15;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_attribute16');
  l_transaction_table(l_count).param_value := p_attribute16;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_attribute17');
  l_transaction_table(l_count).param_value := p_attribute17;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_attribute18');
  l_transaction_table(l_count).param_value := p_attribute18;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_attribute19');
  l_transaction_table(l_count).param_value := p_attribute19;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_attribute20');
  l_transaction_table(l_count).param_value := p_attribute20;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_attribute21');
  l_transaction_table(l_count).param_value := p_attribute21;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_attribute22');
  l_transaction_table(l_count).param_value := p_attribute22;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_attribute23');
  l_transaction_table(l_count).param_value := p_attribute23;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_attribute24');
  l_transaction_table(l_count).param_value := p_attribute24;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_attribute25');
  l_transaction_table(l_count).param_value := p_attribute25;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_attribute26');
  l_transaction_table(l_count).param_value := p_attribute26;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_attribute27');
  l_transaction_table(l_count).param_value := p_attribute27;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_attribute28');
  l_transaction_table(l_count).param_value := p_attribute28;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_attribute29');
  l_transaction_table(l_count).param_value := p_attribute29;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_attribute30');
  l_transaction_table(l_count).param_value := p_attribute30;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_per_information_category');
  l_transaction_table(l_count).param_value := p_per_information_category;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_per_information1');
  l_transaction_table(l_count).param_value := p_per_information1;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_per_information2');
  l_transaction_table(l_count).param_value := p_per_information2;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_per_information3');
  l_transaction_table(l_count).param_value := p_per_information3;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_per_information4');
  l_transaction_table(l_count).param_value := p_per_information4;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_per_information5');
  l_transaction_table(l_count).param_value := p_per_information5;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_per_information6');
  l_transaction_table(l_count).param_value := p_per_information6;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_per_information7');
  l_transaction_table(l_count).param_value := p_per_information7;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_per_information8');
  l_transaction_table(l_count).param_value := p_per_information8;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_per_information9');
  l_transaction_table(l_count).param_value := p_per_information9;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_per_information10');
  l_transaction_table(l_count).param_value := p_per_information10;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_per_information11');
  l_transaction_table(l_count).param_value := p_per_information11;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_per_information12');
  l_transaction_table(l_count).param_value := p_per_information12;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_per_information13');
  l_transaction_table(l_count).param_value := p_per_information13;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_per_information14');
  l_transaction_table(l_count).param_value := p_per_information14;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_per_information15');
  l_transaction_table(l_count).param_value := p_per_information15;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_per_information16');
  l_transaction_table(l_count).param_value := p_per_information16;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_per_information17');
  l_transaction_table(l_count).param_value := p_per_information17;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_per_information18');
  l_transaction_table(l_count).param_value := p_per_information18;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_per_information19');
  l_transaction_table(l_count).param_value := p_per_information19;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_per_information20');
  l_transaction_table(l_count).param_value := p_per_information20;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_per_information21');
  l_transaction_table(l_count).param_value := p_per_information21;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_per_information22');
  l_transaction_table(l_count).param_value := p_per_information22;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_per_information23');
  l_transaction_table(l_count).param_value := p_per_information23;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_per_information24');
  l_transaction_table(l_count).param_value := p_per_information24;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_per_information25');
  l_transaction_table(l_count).param_value := p_per_information25;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_per_information26');
  l_transaction_table(l_count).param_value := p_per_information26;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_per_information27');
  l_transaction_table(l_count).param_value := p_per_information27;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_per_information28');
  l_transaction_table(l_count).param_value := p_per_information28;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_per_information29');
  l_transaction_table(l_count).param_value := p_per_information29;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_per_information30');
  l_transaction_table(l_count).param_value := p_per_information30;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_correspondence_language');
  l_transaction_table(l_count).param_value := p_correspondence_language;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_honors');
  l_transaction_table(l_count).param_value := p_honors;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_pre_name_adjunct');
  l_transaction_table(l_count).param_value := p_pre_name_adjunct;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_suffix');
  l_transaction_table(l_count).param_value := p_suffix;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_create_mirror_flag');
  l_transaction_table(l_count).param_value := p_create_mirror_flag;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_mirror_type');
  l_transaction_table(l_count).param_value := p_mirror_type;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_mirror_cont_attribute_cat');
  l_transaction_table(l_count).param_value := p_mirror_cont_attribute_cat;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_mirror_cont_attribute1');
  l_transaction_table(l_count).param_value := p_mirror_cont_attribute1;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_mirror_cont_attribute2');
  l_transaction_table(l_count).param_value := p_mirror_cont_attribute2;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_mirror_cont_attribute3');
  l_transaction_table(l_count).param_value := p_mirror_cont_attribute3;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_mirror_cont_attribute4');
  l_transaction_table(l_count).param_value := p_mirror_cont_attribute4;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_mirror_cont_attribute5');
  l_transaction_table(l_count).param_value := p_mirror_cont_attribute5;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_mirror_cont_attribute6');
  l_transaction_table(l_count).param_value := p_mirror_cont_attribute6;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_mirror_cont_attribute7');
  l_transaction_table(l_count).param_value := p_mirror_cont_attribute7;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_mirror_cont_attribute8');
  l_transaction_table(l_count).param_value := p_mirror_cont_attribute8;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_mirror_cont_attribute9');
  l_transaction_table(l_count).param_value := p_mirror_cont_attribute9;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_mirror_cont_attribute10');
  l_transaction_table(l_count).param_value := p_mirror_cont_attribute10;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_mirror_cont_attribute11');
  l_transaction_table(l_count).param_value := p_mirror_cont_attribute11;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_mirror_cont_attribute12');
  l_transaction_table(l_count).param_value := p_mirror_cont_attribute12;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_mirror_cont_attribute13');
  l_transaction_table(l_count).param_value := p_mirror_cont_attribute13;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_mirror_cont_attribute14');
  l_transaction_table(l_count).param_value := p_mirror_cont_attribute14;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_mirror_cont_attribute15');
  l_transaction_table(l_count).param_value := p_mirror_cont_attribute15;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_mirror_cont_attribute16');
  l_transaction_table(l_count).param_value := p_mirror_cont_attribute16;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_mirror_cont_attribute17');
  l_transaction_table(l_count).param_value := p_mirror_cont_attribute17;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_mirror_cont_attribute18');
  l_transaction_table(l_count).param_value := p_mirror_cont_attribute18;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_mirror_cont_attribute19');
  l_transaction_table(l_count).param_value := p_mirror_cont_attribute19;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_mirror_cont_attribute20');
  l_transaction_table(l_count).param_value := p_mirror_cont_attribute20;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_item_type');
  l_transaction_table(l_count).param_value := p_item_type;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_item_key');
  l_transaction_table(l_count).param_value := p_item_key;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  -- 9999 This may not be necessary as it is same as P_REVIEW_ACTID.
  -- Check it and delete it after complete testing.
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_activity_id');
  l_transaction_table(l_count).param_value := p_activity_id;
  l_transaction_table(l_count).param_data_type := upper('number');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_action');
  l_transaction_table(l_count).param_value := p_action;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_login_person_id');
  l_transaction_table(l_count).param_value := p_login_person_id;
  l_transaction_table(l_count).param_data_type := upper('number');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_process_section_name');
  l_transaction_table(l_count).param_value := p_process_section_name;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  -- 77777
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_REVIEW_PROC_CALL');
  l_transaction_table(l_count).param_value := p_review_page_region_code;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_REVIEW_ACTID';
  l_transaction_table(l_count).param_value := P_ACTIVITY_ID;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_adjusted_svc_date');
  l_transaction_table(l_count).param_value :=
            to_char(p_adjusted_svc_date , hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := upper('date');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_datetrack_update_mode');
  l_transaction_table(l_count).param_value := p_datetrack_update_mode;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_applicant_number');
  l_transaction_table(l_count).param_value := p_applicant_number;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_background_check_status');
  l_transaction_table(l_count).param_value := p_background_check_status;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_background_date_check');
  l_transaction_table(l_count).param_value :=
            to_char(p_background_date_check , hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := upper('date');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_benefit_group_id');
  l_transaction_table(l_count).param_value := p_benefit_group_id;
  l_transaction_table(l_count).param_data_type := upper('number');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_blood_type');
  l_transaction_table(l_count).param_value := p_blood_type;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_coord_ben_med_pln_no');
  l_transaction_table(l_count).param_value := p_coord_ben_med_pln_no;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_coord_ben_no_cvg_flag');
  l_transaction_table(l_count).param_value := p_coord_ben_no_cvg_flag;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_country_of_birth');
  l_transaction_table(l_count).param_value := p_country_of_birth;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_date_employee_data_verified');
  l_transaction_table(l_count).param_value :=
            to_char(p_date_employee_data_verified , hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := upper('date');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_date_of_death');
  l_transaction_table(l_count).param_value :=
            to_char(p_date_of_death , hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := upper('date');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_dpdnt_adoption_date');
  l_transaction_table(l_count).param_value :=
            to_char(p_dpdnt_adoption_date , hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := upper('date');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_dpdnt_vlntry_svce_flag');
  l_transaction_table(l_count).param_value := p_dpdnt_vlntry_svce_flag;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_employee_number');
  l_transaction_table(l_count).param_value := p_employee_number;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_expense_check_send_to_addres');
  l_transaction_table(l_count).param_value := p_expense_check_send_to_addres;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_fast_path_employee');
  l_transaction_table(l_count).param_value := p_fast_path_employee;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_fte_capacity');
  l_transaction_table(l_count).param_value := p_fte_capacity;
  l_transaction_table(l_count).param_data_type := upper('number');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_global_person_id');
  l_transaction_table(l_count).param_value := p_global_person_id;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_hold_applicant_date_until');
  l_transaction_table(l_count).param_value :=
            to_char(p_hold_applicant_date_until , hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := upper('date');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_internal_location');
  l_transaction_table(l_count).param_value := p_internal_location;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_last_medical_test_by');
  l_transaction_table(l_count).param_value := p_last_medical_test_by;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_last_medical_test_date');
  l_transaction_table(l_count).param_value :=
            to_char(p_last_medical_test_date , hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := upper('date');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_mailstop');
  l_transaction_table(l_count).param_value := p_mailstop;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_office_number');
  l_transaction_table(l_count).param_value := p_office_number;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_on_military_service');
  l_transaction_table(l_count).param_value := p_on_military_service;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_original_date_of_hire');
  l_transaction_table(l_count).param_value :=
            to_char(p_original_date_of_hire , hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := upper('date');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_projected_start_date');
  l_transaction_table(l_count).param_value :=
            to_char(p_projected_start_date , hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := upper('date');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_receipt_of_death_cert_date');
  l_transaction_table(l_count).param_value :=
            to_char(p_receipt_of_death_cert_date , hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := upper('date');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_region_of_birth');
  l_transaction_table(l_count).param_value := p_region_of_birth;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_rehire_authorizor');
  l_transaction_table(l_count).param_value := p_rehire_authorizor;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_rehire_recommendation');
  l_transaction_table(l_count).param_value := p_rehire_recommendation;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_rehire_reason');
  l_transaction_table(l_count).param_value := p_rehire_reason;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_resume_exists');
  l_transaction_table(l_count).param_value := p_resume_exists;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_resume_last_updated');
  l_transaction_table(l_count).param_value := to_char(p_resume_last_updated , hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := upper('date');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_second_passport_exists');
  l_transaction_table(l_count).param_value := p_second_passport_exists;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_student_status');
  l_transaction_table(l_count).param_value := p_student_status;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_town_of_birth');
  l_transaction_table(l_count).param_value := p_town_of_birth;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_uses_tobacco_flag');
  l_transaction_table(l_count).param_value := p_uses_tobacco_flag;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_vendor_id');
  l_transaction_table(l_count).param_value := p_vendor_id;
  l_transaction_table(l_count).param_data_type := upper('number');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_work_schedule');
  l_transaction_table(l_count).param_value := p_work_schedule;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  -- These are the parameters which are there in the update_contact.
  -- We need to populate null values so that we can have generic get
  -- function which works for create_contact and update_contact.
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_cont_effective_date');
  l_transaction_table(l_count).param_value := null;
  l_transaction_table(l_count).param_data_type := upper('date');
  --
  l_transaction_table(l_count).param_name :=upper('p_cont_object_version_number');
  l_transaction_table(l_count).param_value := null;
  l_transaction_table(l_count).param_data_type := upper('number');
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_per_effective_date');
  l_transaction_table(l_count).param_value := null;
  l_transaction_table(l_count).param_data_type := upper('date');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('p_cont_person_id');
  l_transaction_table(l_count).param_value := p_contact_person_id;
  l_transaction_table(l_count).param_data_type := upper('number');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_CONT_INFORMATION_CATEGORY');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION_CATEGORY;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_CONT_INFORMATION1');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION1;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_CONT_INFORMATION2');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION2;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_CONT_INFORMATION3');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION3;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_CONT_INFORMATION4');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION4;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_CONT_INFORMATION5');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION5;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_CONT_INFORMATION6');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION6;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_CONT_INFORMATION7');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION7;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_CONT_INFORMATION8');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION8;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_CONT_INFORMATION9');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION9;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_CONT_INFORMATION10');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION10;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_CONT_INFORMATION11');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION11;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_CONT_INFORMATION12');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION12;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_CONT_INFORMATION13');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION13;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_CONT_INFORMATION14');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION14;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_CONT_INFORMATION15');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION15;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_CONT_INFORMATION16');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION16;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_CONT_INFORMATION17');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION17;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_CONT_INFORMATION18');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION18;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_CONT_INFORMATION19');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION19;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_CONT_INFORMATION20');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION20;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_MIRROR_CONT_INFORMATION_CAT');
  l_transaction_table(l_count).param_value := P_MIRROR_CONT_INFORMATION_CAT;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_MIRROR_CONT_INFORMATION1');
  l_transaction_table(l_count).param_value := P_CONT_INFORMATION1;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_MIRROR_CONT_INFORMATION2');
  l_transaction_table(l_count).param_value := P_MIRROR_CONT_INFORMATION2;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_MIRROR_CONT_INFORMATION3');
  l_transaction_table(l_count).param_value := P_MIRROR_CONT_INFORMATION3;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_MIRROR_CONT_INFORMATION4');
  l_transaction_table(l_count).param_value := P_MIRROR_CONT_INFORMATION4;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_MIRROR_CONT_INFORMATION5');
  l_transaction_table(l_count).param_value := P_MIRROR_CONT_INFORMATION5;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_MIRROR_CONT_INFORMATION6');
  l_transaction_table(l_count).param_value := P_MIRROR_CONT_INFORMATION6;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_MIRROR_CONT_INFORMATION7');
  l_transaction_table(l_count).param_value := P_MIRROR_CONT_INFORMATION7;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_MIRROR_CONT_INFORMATION8');
  l_transaction_table(l_count).param_value := P_MIRROR_CONT_INFORMATION8;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_MIRROR_CONT_INFORMATION9');
  l_transaction_table(l_count).param_value := P_MIRROR_CONT_INFORMATION9;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_MIRROR_CONT_INFORMATION10');
  l_transaction_table(l_count).param_value := P_MIRROR_CONT_INFORMATION10;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_MIRROR_CONT_INFORMATION11');
  l_transaction_table(l_count).param_value := P_MIRROR_CONT_INFORMATION11;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_MIRROR_CONT_INFORMATION12');
  l_transaction_table(l_count).param_value := P_MIRROR_CONT_INFORMATION12;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_MIRROR_CONT_INFORMATION13');
  l_transaction_table(l_count).param_value := P_MIRROR_CONT_INFORMATION13;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_MIRROR_CONT_INFORMATION14');
  l_transaction_table(l_count).param_value := P_MIRROR_CONT_INFORMATION14;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_MIRROR_CONT_INFORMATION15');
  l_transaction_table(l_count).param_value := P_MIRROR_CONT_INFORMATION15;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_MIRROR_CONT_INFORMATION16');
  l_transaction_table(l_count).param_value := P_MIRROR_CONT_INFORMATION16;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_MIRROR_CONT_INFORMATION17');
  l_transaction_table(l_count).param_value := P_MIRROR_CONT_INFORMATION17;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_MIRROR_CONT_INFORMATION18');
  l_transaction_table(l_count).param_value := P_MIRROR_CONT_INFORMATION18;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_MIRROR_CONT_INFORMATION19');
  l_transaction_table(l_count).param_value := P_MIRROR_CONT_INFORMATION19;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --
  --

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :=upper('P_MIRROR_CONT_INFORMATION20');
  l_transaction_table(l_count).param_value := P_MIRROR_CONT_INFORMATION20;
  l_transaction_table(l_count).param_data_type := upper('varchar2');

  --StartRegistration
  --  This is a marker for the contact person to be used to identify the Address
  --  to be retrieved for the contact person in context in review page.
  --  The HR_LAST_CONTACT_SET is in from the work flow attribute
  begin
       l_contact_set := wf_engine.GetItemAttrNumber(itemtype => p_item_type,
                                                    itemkey  => p_item_key,
                                                    aname    => 'HR_CONTACT_SET');

       exception when others then
            hr_utility.set_location('Exception:'||l_proc,560);
            l_contact_set := 0;

  end;

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_CONTACT_SET';
  l_transaction_table(l_count).param_value := l_contact_set;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --EndRegistration
  hr_utility.set_location('Before Calling :hr_transaction_ss.save_transaction_step', 90);
  --
  hr_transaction_ss.save_transaction_step
                (p_item_type            => p_item_type
                ,p_item_key             => p_item_key
                ,p_login_person_id      => nvl(p_login_person_id, p_person_id) -- Registration
                -- ,p_login_person_id      =>  p_person_id
                ,p_actid                => p_activity_id
                ,p_transaction_step_id  => l_transaction_step_id
                ,p_api_name             => g_package || '.PROCESS_CREATE_CONTACT_API'
                ,p_transaction_data     => l_transaction_table);
  --
--  hr_utility.set_location('Leaving hr_contact_rel_api.create_contact_tt', 100);

  hr_utility.set_location('Exiting:'||l_proc,100);
  --
  -- 9999 What full_name code is doing? Do we need to add?
  -- 9999 Any warnings do we need to pass back to java code?
  -- 9999 Reset the object version number.
  --
  EXCEPTION
    WHEN hr_utility.hr_error THEN
         -- -------------------------------------------
         -- an application error has been raised so we must
         -- redisplay the web form to display the error
         -- --------------------------------------------
         hr_utility.set_location('Exception:'||l_proc,565);
         hr_message.provide_error;
         l_message_number := hr_message.last_message_number;
         --
         -- 99999 What error messages I have to trap here.
         --
         IF l_message_number = 'APP-7165' OR
            l_message_number = 'APP-7155' THEN
            hr_utility.set_message(800, 'HR_UPDATE_NOT_ALLOWED');
            hr_utility.raise_error;
         ELSE
            hr_utility.raise_error;
         END IF;
    WHEN OTHERS THEN
      hr_utility.set_location('Exception:'||l_proc,570);
      fnd_message.set_name('PER', SQLERRM ||' '||to_char(SQLCODE));
      hr_utility.raise_error;
      --RAISE;  -- Raise error here relevant to the new tech stack.
 --
 END create_contact_tt;
--

Function is_con_rec_changed (
  p_adjusted_svc_date            in      date     default hr_api.g_date
  ,p_applicant_number             in      varchar2 default hr_api.g_varchar2
  ,p_background_check_status      in      varchar2 default hr_api.g_varchar2
  ,p_background_date_check        in      date     default hr_api.g_date
  ,p_benefit_group_id             in      number   default hr_api.g_number
  ,p_blood_type                   in      varchar2 default hr_api.g_varchar2
  ,p_coord_ben_med_pln_no         in      varchar2 default hr_api.g_varchar2
  ,p_coord_ben_no_cvg_flag        in      varchar2 default hr_api.g_varchar2
  ,p_country_of_birth             in      varchar2 default hr_api.g_varchar2
  ,p_date_employee_data_verified  in      date     default hr_api.g_date
  ,p_date_of_death                in      date     default hr_api.g_date
  ,p_dpdnt_adoption_date          in      date     default hr_api.g_date
  ,p_dpdnt_vlntry_svce_flag       in      varchar2 default hr_api.g_varchar2
  ,p_expense_check_send_to_addres in      varchar2 default hr_api.g_varchar2
  ,p_fast_path_employee           in      varchar2 default hr_api.g_varchar2
  ,p_fte_capacity                 in      number   default hr_api.g_number
  ,p_global_person_id             in      varchar2 default hr_api.g_varchar2
  ,p_hold_applicant_date_until    in      date     default hr_api.g_date
  ,p_internal_location            in      varchar2 default hr_api.g_varchar2
  ,p_last_medical_test_by         in      varchar2 default hr_api.g_varchar2
  ,p_last_medical_test_date       in      date     default hr_api.g_date
  ,p_mailstop                     in      varchar2 default hr_api.g_varchar2
  ,p_office_number                in      varchar2 default hr_api.g_varchar2
  ,p_on_military_service          in      varchar2 default hr_api.g_varchar2
  ,p_original_date_of_hire        in      date     default hr_api.g_date
  ,p_projected_start_date         in      date     default hr_api.g_date
  ,p_receipt_of_death_cert_date   in      date     default hr_api.g_date
  ,p_region_of_birth              in      varchar2 default hr_api.g_varchar2
  ,p_rehire_authorizor            in      varchar2 default hr_api.g_varchar2
  ,p_rehire_recommendation        in      varchar2 default hr_api.g_varchar2
  ,p_rehire_reason                in      varchar2 default hr_api.g_varchar2
  ,p_resume_exists                in      varchar2 default hr_api.g_varchar2
  ,p_resume_last_updated          in      date     default hr_api.g_date
  ,p_second_passport_exists       in      varchar2 default hr_api.g_varchar2
  ,p_student_status               in      varchar2 default hr_api.g_varchar2
  ,p_town_of_birth                in      varchar2 default hr_api.g_varchar2
  ,p_uses_tobacco_flag            in      varchar2 default hr_api.g_varchar2
  ,p_vendor_id                    in      number   default hr_api.g_number
  ,p_work_schedule                in      varchar2 default hr_api.g_varchar2  )
  return boolean is
  --
  l_rec_changed                    boolean default FALSE;
  l_proc   varchar2(72)  := g_package||'is_con_rec_changed';

BEGIN
   --
   hr_utility.set_location('Entering:'||l_proc, 5);
   IF p_adjusted_svc_date <> hr_api.g_date
   THEN
            l_rec_changed := TRUE;
            goto finish;
   END IF;
   --
   --
   IF p_applicant_number <> hr_api.g_varchar2
   THEN
            l_rec_changed := TRUE;
            goto finish;
   END IF;
   --
   --
   IF p_background_check_status <> hr_api.g_varchar2
   THEN
            l_rec_changed := TRUE;
            goto finish;
   END IF;
   --
   --
   IF p_background_date_check <> hr_api.g_date
   THEN
            l_rec_changed := TRUE;
            goto finish;
   END IF;
   --
   --
   IF p_benefit_group_id <> hr_api.g_number
   THEN
            l_rec_changed := TRUE;
            goto finish;
   END IF;
   --
   --
   IF p_blood_type <> hr_api.g_varchar2
   THEN
            l_rec_changed := TRUE;
            goto finish;
   END IF;
   --
   --
   IF p_coord_ben_med_pln_no <> hr_api.g_varchar2
   THEN
            l_rec_changed := TRUE;
            goto finish;
   END IF;
   --
   --
   IF p_coord_ben_no_cvg_flag <> hr_api.g_varchar2
   THEN
            l_rec_changed := TRUE;
            goto finish;
   END IF;
   --
   --
   IF p_country_of_birth <> hr_api.g_varchar2
   THEN
            l_rec_changed := TRUE;
            goto finish;
   END IF;
   --
   --
   IF p_date_employee_data_verified <> hr_api.g_date
   THEN
            l_rec_changed := TRUE;
            goto finish;
   END IF;
   --
   --
   IF p_date_of_death <> hr_api.g_date
   THEN
            l_rec_changed := TRUE;
            goto finish;
   END IF;
   --
   --
   IF p_dpdnt_adoption_date <> hr_api.g_date
   THEN
            l_rec_changed := TRUE;
            goto finish;
   END IF;
   --
   --
   IF p_dpdnt_vlntry_svce_flag <> hr_api.g_varchar2
   THEN
            l_rec_changed := TRUE;
            goto finish;
   END IF;
   --
   --
   IF p_expense_check_send_to_addres <> hr_api.g_varchar2
   THEN
            l_rec_changed := TRUE;
            goto finish;
   END IF;
   --
   --
   IF p_fast_path_employee <> hr_api.g_varchar2
   THEN
            l_rec_changed := TRUE;
            goto finish;
   END IF;
   --
   --
   IF p_fte_capacity <> hr_api.g_number
   THEN
            l_rec_changed := TRUE;
            goto finish;
   END IF;
   --
   --
   IF p_global_person_id <> hr_api.g_varchar2
   THEN
            l_rec_changed := TRUE;
            goto finish;
   END IF;
   --
   --
   IF p_hold_applicant_date_until <> hr_api.g_date
   THEN
            l_rec_changed := TRUE;
            goto finish;
   END IF;
   --
   --
   IF p_internal_location <> hr_api.g_varchar2
   THEN
            l_rec_changed := TRUE;
            goto finish;
   END IF;
   --
   --
   IF p_last_medical_test_by <> hr_api.g_varchar2
   THEN
            l_rec_changed := TRUE;
            goto finish;
   END IF;
   --
   --
   IF p_last_medical_test_date <> hr_api.g_date
   THEN
            l_rec_changed := TRUE;
            goto finish;
   END IF;
   --
   --
   IF p_mailstop <> hr_api.g_varchar2
   THEN
            l_rec_changed := TRUE;
            goto finish;
   END IF;
   --
   --
   IF p_office_number <> hr_api.g_varchar2
   THEN
            l_rec_changed := TRUE;
            goto finish;
   END IF;
   --
   --
   IF p_on_military_service <> hr_api.g_varchar2
   THEN
            l_rec_changed := TRUE;
            goto finish;
   END IF;
   --
   --
   IF p_original_date_of_hire <> hr_api.g_date
   THEN
            l_rec_changed := TRUE;
            goto finish;
   END IF;
   --
   --
   IF p_projected_start_date <> hr_api.g_date
   THEN
            l_rec_changed := TRUE;
            goto finish;
   END IF;
   --
   --
   IF p_receipt_of_death_cert_date <> hr_api.g_date
   THEN
            l_rec_changed := TRUE;
            goto finish;
   END IF;
   --
   --
   IF p_region_of_birth <> hr_api.g_varchar2
   THEN
            l_rec_changed := TRUE;
            goto finish;
   END IF;
   --
   --
   IF p_rehire_authorizor <> hr_api.g_varchar2
   THEN
            l_rec_changed := TRUE;
            goto finish;
   END IF;
   --
   --
   IF p_rehire_recommendation <> hr_api.g_varchar2
   THEN
            l_rec_changed := TRUE;
            goto finish;
   END IF;
   --
   --
   IF p_rehire_reason <> hr_api.g_varchar2
   THEN
            l_rec_changed := TRUE;
            goto finish;
   END IF;
   --
   --
   IF p_resume_exists <> hr_api.g_varchar2
   THEN
            l_rec_changed := TRUE;
            goto finish;
   END IF;
   --
   --
   IF p_resume_last_updated <> hr_api.g_date
   THEN
            l_rec_changed := TRUE;
            goto finish;
   END IF;
   --
   --
   IF p_second_passport_exists <> hr_api.g_varchar2
   THEN
            l_rec_changed := TRUE;
            goto finish;
   END IF;
   --
   --
   IF p_student_status <> hr_api.g_varchar2
   THEN
            l_rec_changed := TRUE;
            goto finish;
   END IF;
   --
   --
   IF p_town_of_birth <> hr_api.g_varchar2
   THEN
            l_rec_changed := TRUE;
            goto finish;
   END IF;
   --
   --
   IF p_uses_tobacco_flag <> hr_api.g_varchar2
   THEN
            l_rec_changed := TRUE;
            goto finish;
   END IF;
   --
   --
   IF p_vendor_id <> hr_api.g_number
   THEN
            l_rec_changed := TRUE;
            goto finish;
   END IF;
   --
   --
   IF p_work_schedule <> hr_api.g_varchar2
   THEN
            l_rec_changed := TRUE;
            goto finish;
   END IF;
   --
   hr_utility.set_location('Exiting:'||l_proc, 10);
    <<finish>>
    return l_rec_changed ;
EXCEPTION
  When g_data_error THEN
  hr_utility.set_location('Exception g_data_error:'||l_proc,555);
       raise;

  When others THEN
       hr_utility.set_location('Exception others:'||l_proc,555);
      fnd_message.set_name('PER', SQLERRM ||' '||to_char(SQLCODE));
      hr_utility.raise_error;
       --raise;

END is_con_rec_changed;
--
-- ---------------------------------------------------------------------------
-- ----------------------------- < process_create_contact_api > --------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will be invoked in workflow notification
--          when an approver approves all the changes.  This procedure
--          will call the api to update to the database with p_validate
--          equal to false.
-- ---------------------------------------------------------------------------
PROCEDURE process_create_contact_api
          (p_validate IN BOOLEAN DEFAULT FALSE
          ,p_transaction_step_id IN NUMBER
          ,p_effective_date      in varchar2 default null
)
IS
--
  l_person_id                        per_all_people_f.person_id%type
                                     default null;
  l_full_name                        per_all_people_f.full_name%type;
  l_per_comment_id                   per_all_people_f.comment_id%type;
  l_con_name_combination_warning boolean;
  l_per_name_combination_warning boolean;
  l_con_orig_hire_warning        boolean;
  l_per_orig_hire_warning        boolean;
  l_con_assign_payroll_warning   boolean;
  l_per_assign_payroll_warning   boolean;

  l_ovn                              number default null;
  l_per_person_id                    per_all_people_f.person_id%type
                                     default null;
  l_contact_relationship_id          number default null;
  l_ctr_object_version_number        number default null;
  l_per_object_version_number        number default null;
  l_per_effective_start_date         date default null;
  l_per_effective_end_date           date default null;
  l_con_rec_changed                  VARCHAR2(100) default null;
  l_effective_date                   date default null ;
  l_employee_number	             per_all_people_f.employee_number%type default null ;
  -- Bug 1919795
  l_contact_type                     varchar2(100);
  l_MIRROR_TYPE                      varchar2(100);
  l_CREATE_MIRROR_FLAG               varchar2(100);
  --
  l_contact_operation                varchar2(100);
  l_dpdnt_bnf_flag                   varchar2(100);
  l_emrg_cont_flag                   varchar2(100);
  l_dpdnt_bnf_contact_type           varchar2(100);
  l_dpdnt_bnf_personal_flag          varchar2(100);
  l_personal_flag                    varchar2(100);
  l_primary_contact_flag             varchar2(100);
  --
  l_full_name1                       per_all_people_f.full_name%type;
  l_per_comment_id1                  per_all_people_f.comment_id%type;
  l_con_name_combination_warnin1    boolean;
  l_con_orig_hire_warning1           boolean;
  l_per_person_id1                   per_all_people_f.person_id%type
                                     default null;
  l_contact_relationship_id1         number default null;
  l_ctr_object_version_number1       number default null;
  l_per_object_version_number1       number default null;
  l_per_effective_start_date1        date default null;
  l_per_effective_end_date1          date default null;
  -- bug# 2115552
  -- Using this value for  P_PRIMARY_CONTACT_FLAG for addl relationship
  l_addl_primary_contact_flag        varchar2(100);
  l_proc   varchar2(72)  := g_package||'process_create_contact_api';
  --
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  SAVEPOINT process_create_contact_api;

  --
  -- Get the person_id first.  If it is null, that means we'll create a new
  -- contact.  If it is not null, error out.

  l_person_id := hr_transaction_api.get_number_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PERSON_ID');
  --
  -- StartRegistration
  --
  if l_person_id is null or l_person_id < 0 then
  hr_utility.set_location('l_person_id is null or l_person_id < 0:'||l_proc,10 );
     --
      --
      -- l_person_id := hr_process_person_ss.g_person_id;
      -- Adding the session id check to avoid connection pooling problems.
        if (( hr_process_person_ss.g_person_id is not null) and
                (hr_process_person_ss.g_session_id= ICX_SEC.G_SESSION_ID)) then
            l_person_id := hr_process_person_ss.g_person_id;
        end if;

     --
  end if;
  --
  -- EndRegistration
  --
  begin
    l_con_rec_changed := hr_transaction_api.get_VARCHAR2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name                => 'P_CONT_REC_CHANGED') ;
  exception when others then
    hr_utility.set_location('Exception Others:'||l_proc,555);
    l_con_rec_changed := 'NOTCHANGED';
  end;
  --
  l_effective_date  := hr_transaction_api.get_DATE_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name                => 'P_START_DATE') ;
  --
  -- SFL changes.
  --
  if (p_effective_date is not null) then
  hr_utility.set_location('p_effective_date is not null:'||l_proc,15 );
    l_effective_date:= to_date(p_effective_date,g_date_format);
    --
  else
       --
       l_effective_date:= to_date(
        hr_transaction_ss.get_wf_effective_date
        (p_transaction_step_id => p_transaction_step_id),g_date_format);
       --
  end if;
  --
  -- For normal commit the effective date should come from txn tbales.
  --
  if not p_validate then
     --
     hr_utility.set_location('if not p_validate then:'||l_proc,20 );
     l_effective_date := hr_transaction_api.get_DATE_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_START_DATE');
     --
  end if;
  --
  --
  -- Bug 1919795 : create mirror relationship for contact types of
  --               P,C,S.
  --
  l_contact_type :=   hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONTACT_TYPE');
  --
  l_MIRROR_TYPE := hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_TYPE');
  --
  l_CREATE_MIRROR_FLAG := hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_TYPE');
  --
  if l_contact_type in ('P', 'C', 'S') then
      --
      l_CREATE_MIRROR_FLAG := 'Y';
      --
      if l_contact_type = 'P' then
         l_MIRROR_TYPE := 'C';
      elsif l_contact_type = 'C' then
         l_MIRROR_TYPE := 'P';
      elsif l_contact_type = 'S' then
         l_MIRROR_TYPE := 'S';
      end if;
      --
  end if;
  --
  --
  l_contact_operation :=   hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONTACT_OPERATION');
  --
  l_dpdnt_bnf_flag    :=   hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_DPDNT_BNF_FLAG');
  --
  l_emrg_cont_flag    :=   hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_EMRG_CONT_FLAG');
  --
  l_personal_flag     := hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PERSONAL_FLAG');
  --
  l_primary_contact_flag :=hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PRIMARY_CONTACT_FLAG');
  --

  if l_contact_operation = 'EMER_CR_NEW_CONT' then
       hr_utility.set_location('if l_contact_operation is EMER_CR_NEW_CONT:'||l_proc,25 );
     --
 -- Bug 3152505 : When in Emergency contact, we always will create two relationship.
 -- One as "Emergency" and other the selected Relationship.
     if /*l_dpdnt_bnf_flag = 'Y' and */l_contact_type <> 'EMRG' then
        --
        l_dpdnt_bnf_contact_type   := l_contact_type;
        l_dpdnt_bnf_personal_flag  := 'Y';
        --
     end if;
     l_contact_type  := 'EMRG';
     l_personal_flag := 'N';
     l_MIRROR_TYPE := null ;
     l_CREATE_MIRROR_FLAG := 'N';
     --
  end if;
  --
  -- l_dpdnt_bnf_contact_type and  l_dpdnt_bnf_personal_flag are reused for
  -- Creation of Emergency Relation in the Depenendents process also.
  -- In this case for the Dependent Creation we need to change the
  -- primaryContactFlag to 'N' and what ever primaryContactFlag is passed
  -- from the java site, we need to pass it to the Emregency contact
  -- Creation.
  if l_contact_operation = 'DPDNT_CR_NEW_CONT' then
     --
     if l_emrg_cont_flag = 'Y' and l_contact_type <> 'EMRG' then
        --
        l_dpdnt_bnf_contact_type   := 'EMRG';
        l_dpdnt_bnf_personal_flag  := 'N';
        l_primary_contact_flag := 'N' ; -- This is not used for EMRG
        --
     end if;
     --
  end if;
  --
  IF l_person_id IS NOT NULL
  THEN
    hr_contact_rel_api.create_contact(
      P_VALIDATE  => p_validate
      --
      ,P_START_DATE  => l_effective_date
      --
      ,P_BUSINESS_GROUP_ID  =>
         hr_transaction_api.get_NUMBER_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_BUSINESS_GROUP_ID')
      --
      ,P_PERSON_ID  =>  l_person_id
      /* StartRegistration
         hr_transaction_api.get_NUMBER_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PERSON_ID')
      EndRegistration */
      --
      -- 9999 In case of P_CONTACT_PERSON_ID is -1 then
      -- pass null value rather than -1
      --
      ,P_CONTACT_PERSON_ID  =>
         hr_transaction_api.get_NUMBER_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONTACT_PERSON_ID')
      --
      ,P_CONTACT_TYPE  =>  l_contact_type /*
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONTACT_TYPE') */
      --
      ,P_CTR_COMMENTS  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CTR_COMMENTS')
      --
      ,P_PRIMARY_CONTACT_FLAG  => l_primary_contact_flag /*
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PRIMARY_CONTACT_FLAG')  */
      --
      ,P_DATE_START  =>
         hr_transaction_api.get_DATE_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_DATE_START')
      --
      ,P_START_LIFE_REASON_ID  =>
         hr_transaction_api.get_NUMBER_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_START_LIFE_REASON_ID')
      --
      ,P_DATE_END  =>
         hr_transaction_api.get_DATE_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_DATE_END')
      --
      ,P_END_LIFE_REASON_ID  =>
         hr_transaction_api.get_NUMBER_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_END_LIFE_REASON_ID')
      --
      ,P_RLTD_PER_RSDS_W_DSGNTR_FLAG  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_RLTD_PER_RSDS_W_DSGNTR_FLAG')
      --
      ,P_PERSONAL_FLAG  =>  l_personal_flag /*
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PERSONAL_FLAG') */
      --
      ,P_SEQUENCE_NUMBER  =>
         hr_transaction_api.get_NUMBER_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_SEQUENCE_NUMBER')
      --
      ,P_CONT_ATTRIBUTE_CATEGORY  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE_CATEGORY')
      --
      ,P_CONT_ATTRIBUTE1  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE1')
      --
      ,P_CONT_ATTRIBUTE2  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE2')
      --
      ,P_CONT_ATTRIBUTE3  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE3')
      --
      ,P_CONT_ATTRIBUTE4  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE4')
      --
      ,P_CONT_ATTRIBUTE5  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE5')
      --
      ,P_CONT_ATTRIBUTE6  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE6')
      --
      ,P_CONT_ATTRIBUTE7  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE7')
      --
      ,P_CONT_ATTRIBUTE8  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE8')
      --
      ,P_CONT_ATTRIBUTE9  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE9')
      --
      ,P_CONT_ATTRIBUTE10  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE10')
      --
      ,P_CONT_ATTRIBUTE11  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE11')
      --
      ,P_CONT_ATTRIBUTE12  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE12')
      --
      ,P_CONT_ATTRIBUTE13  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE13')
      --
      ,P_CONT_ATTRIBUTE14  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE14')
      --
      ,P_CONT_ATTRIBUTE15  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE15')
      --
      ,P_CONT_ATTRIBUTE16  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE16')
      --
      ,P_CONT_ATTRIBUTE17  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE17')
      --
      ,P_CONT_ATTRIBUTE18  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE18')
      --
      ,P_CONT_ATTRIBUTE19  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE19')
      --
      ,P_CONT_ATTRIBUTE20  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE20')
      --
      ,P_THIRD_PARTY_PAY_FLAG  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_THIRD_PARTY_PAY_FLAG')
      --
      ,P_BONDHOLDER_FLAG  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_BONDHOLDER_FLAG')
      --
      ,P_DEPENDENT_FLAG  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_DEPENDENT_FLAG')
      --
      ,P_BENEFICIARY_FLAG  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_BENEFICIARY_FLAG')
      --
      ,P_LAST_NAME  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_LAST_NAME')
      --
      ,P_SEX  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_SEX')
      --
      ,P_PERSON_TYPE_ID  =>
         hr_transaction_api.get_NUMBER_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PERSON_TYPE_ID')
      --
      ,P_PER_COMMENTS  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_COMMENTS')
      --
      ,P_DATE_OF_BIRTH  =>
         hr_transaction_api.get_DATE_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_DATE_OF_BIRTH')
      --
      ,P_EMAIL_ADDRESS  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_EMAIL_ADDRESS')
      --
      ,P_FIRST_NAME  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_FIRST_NAME')
      --
      ,P_KNOWN_AS  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_KNOWN_AS')
      --
      ,P_MARITAL_STATUS  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MARITAL_STATUS')
      --
      ,P_MIDDLE_NAMES  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIDDLE_NAMES')
      --
      ,P_NATIONALITY  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_NATIONALITY')
      --
      ,P_NATIONAL_IDENTIFIER  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_NATIONAL_IDENTIFIER')
      --
      ,P_PREVIOUS_LAST_NAME  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PREVIOUS_LAST_NAME')
      --
      ,P_REGISTERED_DISABLED_FLAG  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_REGISTERED_DISABLED_FLAG')
      --
      ,P_TITLE  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_TITLE')
      --
      ,P_WORK_TELEPHONE  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_WORK_TELEPHONE')
      --
      ,P_ATTRIBUTE_CATEGORY  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE_CATEGORY')
      --
      ,P_ATTRIBUTE1  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE1')
      --
      ,P_ATTRIBUTE2  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE2')
      --
      ,P_ATTRIBUTE3  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE3')
      --
      ,P_ATTRIBUTE4  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE4')
      --
      ,P_ATTRIBUTE5  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE5')
      --
      ,P_ATTRIBUTE6  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE6')
      --
      ,P_ATTRIBUTE7  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE7')
      --
      ,P_ATTRIBUTE8  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE8')
      --
      ,P_ATTRIBUTE9  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE9')
      --
      ,P_ATTRIBUTE10  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE10')
      --
      ,P_ATTRIBUTE11  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE11')
      --
      ,P_ATTRIBUTE12  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE12')
      --
      ,P_ATTRIBUTE13  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE13')
      --
      ,P_ATTRIBUTE14  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE14')
      --
      ,P_ATTRIBUTE15  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE15')
      --
      ,P_ATTRIBUTE16  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE16')
      --
      ,P_ATTRIBUTE17  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE17')
      --
      ,P_ATTRIBUTE18  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE18')
      --
      ,P_ATTRIBUTE19  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE19')
      --
      ,P_ATTRIBUTE20  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE20')
      --
      ,P_ATTRIBUTE21  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE21')
      --
      ,P_ATTRIBUTE22  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE22')
      --
      ,P_ATTRIBUTE23  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE23')
      --
      ,P_ATTRIBUTE24  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE24')
      --
      ,P_ATTRIBUTE25  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE25')
      --
      ,P_ATTRIBUTE26  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE26')
      --
      ,P_ATTRIBUTE27  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE27')
      --
      ,P_ATTRIBUTE28  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE28')
      --
      ,P_ATTRIBUTE29  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE29')
      --
      ,P_ATTRIBUTE30  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE30')
      --
      ,P_PER_INFORMATION_CATEGORY  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION_CATEGORY')
      --
      ,P_PER_INFORMATION1  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION1')
      --
      ,P_PER_INFORMATION2  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION2')
      --
      ,P_PER_INFORMATION3  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION3')
      --
      ,P_PER_INFORMATION4  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION4')
      --
      ,P_PER_INFORMATION5  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION5')
      --
      ,P_PER_INFORMATION6  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION6')
      --
      ,P_PER_INFORMATION7  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION7')
      --
      ,P_PER_INFORMATION8  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION8')
      --
      ,P_PER_INFORMATION9  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION9')
      --
      ,P_PER_INFORMATION10  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION10')
      --
      ,P_PER_INFORMATION11  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION11')
      --
      ,P_PER_INFORMATION12  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION12')
      --
      ,P_PER_INFORMATION13  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION13')
      --
      ,P_PER_INFORMATION14  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION14')
      --
      ,P_PER_INFORMATION15  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION15')
      --
      ,P_PER_INFORMATION16  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION16')
      --
      ,P_PER_INFORMATION17  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION17')
      --
      ,P_PER_INFORMATION18  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION18')
      --
      ,P_PER_INFORMATION19  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION19')
      --
      ,P_PER_INFORMATION20  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION20')
      --
      ,P_PER_INFORMATION21  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION21')
      --
      ,P_PER_INFORMATION22  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION22')
      --
      ,P_PER_INFORMATION23  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION23')
      --
      ,P_PER_INFORMATION24  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION24')
      --
      ,P_PER_INFORMATION25  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION25')
      --
      ,P_PER_INFORMATION26  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION26')
      --
      ,P_PER_INFORMATION27  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION27')
      --
      ,P_PER_INFORMATION28  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION28')
      --
      ,P_PER_INFORMATION29  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION29')
      --
      ,P_PER_INFORMATION30  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION30')
      --
      ,P_CORRESPONDENCE_LANGUAGE  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CORRESPONDENCE_LANGUAGE')
      --
      ,P_HONORS  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_HONORS')
      --
      ,P_PRE_NAME_ADJUNCT  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PRE_NAME_ADJUNCT')
      --
      ,P_SUFFIX  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_SUFFIX')
      --
      ,P_CREATE_MIRROR_FLAG  =>  l_CREATE_MIRROR_FLAG
      /* Bug 1919795
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CREATE_MIRROR_FLAG')
      */
      --
      ,P_MIRROR_TYPE  => l_MIRROR_TYPE
      /* Bug 1919795
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_TYPE')
      */
      --
      ,P_MIRROR_CONT_ATTRIBUTE_CAT  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE_CAT')
      --
      ,P_MIRROR_CONT_ATTRIBUTE1  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE1')
      --
      ,P_MIRROR_CONT_ATTRIBUTE2  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE2')
      --
      ,P_MIRROR_CONT_ATTRIBUTE3  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE3')
      --
      ,P_MIRROR_CONT_ATTRIBUTE4  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE4')
      --
      ,P_MIRROR_CONT_ATTRIBUTE5  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE5')
      --
      ,P_MIRROR_CONT_ATTRIBUTE6  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE6')
      --
      ,P_MIRROR_CONT_ATTRIBUTE7  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE7')
      --
      ,P_MIRROR_CONT_ATTRIBUTE8  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE8')
      --
      ,P_MIRROR_CONT_ATTRIBUTE9  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE9')
      --
      ,P_MIRROR_CONT_ATTRIBUTE10  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE10')
      --
      ,P_MIRROR_CONT_ATTRIBUTE11  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE11')
      --
      ,P_MIRROR_CONT_ATTRIBUTE12  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE12')
      --
      ,P_MIRROR_CONT_ATTRIBUTE13  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE13')
      --
      ,P_MIRROR_CONT_ATTRIBUTE14  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE14')
      --
      ,P_MIRROR_CONT_ATTRIBUTE15  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE15')
      --
      ,P_MIRROR_CONT_ATTRIBUTE16  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE16')
      --
      ,P_MIRROR_CONT_ATTRIBUTE17  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE17')
      --
      ,P_MIRROR_CONT_ATTRIBUTE18  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE18')
      --
      ,P_MIRROR_CONT_ATTRIBUTE19  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE19')
      --
      ,P_MIRROR_CONT_ATTRIBUTE20  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE20')
      --
      ,P_CONTACT_RELATIONSHIP_ID  	=> L_CONTACT_RELATIONSHIP_ID
      --
      ,P_CTR_OBJECT_VERSION_NUMBER  	=> L_CTR_OBJECT_VERSION_NUMBER
      --
      ,P_PER_PERSON_ID  		=> L_PER_PERSON_ID
      --
      ,P_PER_OBJECT_VERSION_NUMBER  	=> L_PER_OBJECT_VERSION_NUMBER
      --
      ,P_PER_EFFECTIVE_START_DATE  	=> L_PER_EFFECTIVE_START_DATE
      --
      ,P_PER_EFFECTIVE_END_DATE  	=> L_PER_EFFECTIVE_END_DATE
      --
      ,P_FULL_NAME  			=> L_FULL_NAME
      --
      ,P_PER_COMMENT_ID  		=> L_PER_COMMENT_ID
      --
      ,P_NAME_COMBINATION_WARNING  	=> L_CON_NAME_COMBINATION_WARNING
      --
      ,P_ORIG_HIRE_WARNING  		=> L_CON_ORIG_HIRE_WARNING
      --
	,P_CONT_INFORMATION_CATEGORY  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_CONT_INFORMATION_CATEGORY')
              --
      ,P_CONT_INFORMATION1  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_CONT_INFORMATION1')
              --
      ,P_CONT_INFORMATION2  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_CONT_INFORMATION2')
              --
      ,P_CONT_INFORMATION3  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_CONT_INFORMATION3')
              --
      ,P_CONT_INFORMATION4  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_CONT_INFORMATION4')
              --
      ,P_CONT_INFORMATION5  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_CONT_INFORMATION5')
              --
      ,P_CONT_INFORMATION6  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_CONT_INFORMATION6')
              --
      ,P_CONT_INFORMATION7  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_CONT_INFORMATION7')
              --
      ,P_CONT_INFORMATION8  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_CONT_INFORMATION8')
              --
      ,P_CONT_INFORMATION9  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_CONT_INFORMATION9')
              --
      ,P_CONT_INFORMATION10  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_CONT_INFORMATION10')
              --
      ,P_CONT_INFORMATION11  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_CONT_INFORMATION11')
              --
      ,P_CONT_INFORMATION12  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_CONT_INFORMATION12')
              --
      ,P_CONT_INFORMATION13  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_CONT_INFORMATION13')
              --
      ,P_CONT_INFORMATION14  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_CONT_INFORMATION14')
              --
      ,P_CONT_INFORMATION15  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_CONT_INFORMATION15')
              --
      ,P_CONT_INFORMATION16  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_CONT_INFORMATION16')
              --
      ,P_CONT_INFORMATION17  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_CONT_INFORMATION17')
              --
      ,P_CONT_INFORMATION18  =>
                hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_CONT_INFORMATION18')
              --
      ,P_CONT_INFORMATION19  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_CONT_INFORMATION19')
              --
      ,P_CONT_INFORMATION20  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_CONT_INFORMATION20')
              --
      ,P_MIRROR_CONT_INFORMATION_CAT  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_MIRROR_CONT_INFORMATION_CAT')
              --
      ,P_MIRROR_CONT_INFORMATION1  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_MIRROR_CONT_INFORMATION1')
              --
      ,P_MIRROR_CONT_INFORMATION2  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_MIRROR_CONT_INFORMATION2')
              --
      ,P_MIRROR_CONT_INFORMATION3  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_MIRROR_CONT_INFORMATION3')
              --
      ,P_MIRROR_CONT_INFORMATION4  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_MIRROR_CONT_INFORMATION4')
              --
      ,P_MIRROR_CONT_INFORMATION5  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_MIRROR_CONT_INFORMATION5')
              --
      ,P_MIRROR_CONT_INFORMATION6  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_MIRROR_CONT_INFORMATION6')
              --
      ,P_MIRROR_CONT_INFORMATION7  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_MIRROR_CONT_INFORMATION7')
              --
      ,P_MIRROR_CONT_INFORMATION8  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_MIRROR_CONT_INFORMATION8')
              --
      ,P_MIRROR_CONT_INFORMATION9  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_MIRROR_CONT_INFORMATION9')
              --
      ,P_MIRROR_CONT_INFORMATION10  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_MIRROR_CONT_INFORMATION10')
              --
      ,P_MIRROR_CONT_INFORMATION11  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_MIRROR_CONT_INFORMATION11')
              --
      ,P_MIRROR_CONT_INFORMATION12  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_MIRROR_CONT_INFORMATION12')
              --
      ,P_MIRROR_CONT_INFORMATION13  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_MIRROR_CONT_INFORMATION13')
              --
      ,P_MIRROR_CONT_INFORMATION14  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_MIRROR_CONT_INFORMATION14')
              --
      ,P_MIRROR_CONT_INFORMATION15  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_MIRROR_CONT_INFORMATION15')
              --
      ,P_MIRROR_CONT_INFORMATION16  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_MIRROR_CONT_INFORMATION16')
              --
      ,P_MIRROR_CONT_INFORMATION17  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_MIRROR_CONT_INFORMATION17')
              --
      ,P_MIRROR_CONT_INFORMATION18  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_MIRROR_CONT_INFORMATION18')
              --
      ,P_MIRROR_CONT_INFORMATION19 =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_MIRROR_CONT_INFORMATION19')
              --
      ,P_MIRROR_CONT_INFORMATION20  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_MIRROR_CONT_INFORMATION20')
     );
     --
     IF l_con_rec_changed = 'CHANGED'
     THEN
        --
        -- Get the Employee number from the Database;
        --
        hr_utility.set_location('Before declaring the Cursor c_pap:'||l_proc, 30);
        DECLARE
               CURSOR c_pap IS SELECT employee_number FROM per_all_people_f
			    WHERE person_id = L_PER_PERSON_ID
			    AND  l_effective_date BETWEEN
				 effective_start_date AND effective_end_date ;
               l_pap    c_pap%ROWTYPE;

        BEGIN
               --
        hr_utility.set_location('Working on the Cursor c_pap:'||l_proc, 35);
               OPEN c_pap ;
	       FETCH c_pap INTO l_pap ;
               CLOSE c_pap ;
               --
               l_employee_number := l_pap.employee_number ;
               --
        EXCEPTION WHEN OTHERS THEN
        hr_utility.set_location('Exception: Others'||l_proc,555);
             raise ;
        END;

        -- For processing the update_person_api
        hr_person_api.update_person (
   	  p_validate                          =>  p_validate
   	 ,p_effective_date                    =>  l_effective_date
   	 ,p_datetrack_update_mode             =>  hr_api.g_correction
                                              -- 9999 p_datetrack_update_mode
   	 ,p_person_id                         =>  L_PER_PERSON_ID
     	 ,p_object_version_number             =>  L_PER_OBJECT_VERSION_NUMBER
         ,p_employee_number		      =>  l_employee_number
         -- Bug 2652114
         /*
         ,p_adjusted_svc_date  =>
             hr_transaction_api.get_date_value
                  (p_transaction_step_id   => p_transaction_step_id
                    ,p_name                =>upper('p_adjusted_svc_date'))
         */
         --
         ,p_applicant_number  =>
             hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id   => p_transaction_step_id
                    ,p_name                =>upper('p_applicant_number'))
         --
         ,p_background_check_status  =>
             hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id   => p_transaction_step_id
                    ,p_name                =>upper('p_background_check_status'))
         --
         ,p_background_date_check  =>
             hr_transaction_api.get_date_value
                  (p_transaction_step_id   => p_transaction_step_id
                    ,p_name                =>upper('p_background_date_check'))
         --
         ,p_benefit_group_id  =>
             hr_transaction_api.get_number_value
                  (p_transaction_step_id   => p_transaction_step_id
                    ,p_name                =>upper('p_benefit_group_id'))
         --
         ,p_blood_type  =>
             hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id   => p_transaction_step_id
                    ,p_name                =>upper('p_blood_type'))
         --
         ,p_coord_ben_med_pln_no  =>
             hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id   => p_transaction_step_id
                    ,p_name                =>upper('p_coord_ben_med_pln_no'))
         --
         ,p_coord_ben_no_cvg_flag  =>
             hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id   => p_transaction_step_id
                    ,p_name                =>upper('p_coord_ben_no_cvg_flag'))
         --
         ,p_country_of_birth  =>
             hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id   => p_transaction_step_id
                    ,p_name                =>upper('p_country_of_birth'))
         --
         ,p_date_employee_data_verified  =>
             hr_transaction_api.get_date_value
                  (p_transaction_step_id   => p_transaction_step_id
                    ,p_name                =>upper('p_date_employee_data_verified'))
         --
         ,p_date_of_death  =>
             hr_transaction_api.get_date_value
                  (p_transaction_step_id   => p_transaction_step_id
                    ,p_name                =>upper('p_date_of_death'))
         --
         ,p_dpdnt_adoption_date  =>
             hr_transaction_api.get_date_value
                  (p_transaction_step_id   => p_transaction_step_id
                    ,p_name                =>upper('p_dpdnt_adoption_date'))
         --
         ,p_dpdnt_vlntry_svce_flag  =>
             hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id   => p_transaction_step_id
                    ,p_name                =>upper('p_dpdnt_vlntry_svce_flag'))
         --
         ,p_expense_check_send_to_addres  =>
             hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id   => p_transaction_step_id
                    ,p_name                =>upper('p_expense_check_send_to_addres'))
         --
         ,p_fast_path_employee  =>
             hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id   => p_transaction_step_id
                    ,p_name                =>upper('p_fast_path_employee'))
          --
         ,p_fte_capacity  =>
             hr_transaction_api.get_number_value
                  (p_transaction_step_id   => p_transaction_step_id
                    ,p_name                =>upper('p_fte_capacity'))
         --
         ,p_global_person_id  =>
             hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id   => p_transaction_step_id
                    ,p_name                =>upper('p_global_person_id'))
         --
         ,p_hold_applicant_date_until  =>
             hr_transaction_api.get_date_value
                  (p_transaction_step_id   => p_transaction_step_id
                    ,p_name                =>upper('p_hold_applicant_date_until'))
         --
         ,p_internal_location  =>
             hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id   => p_transaction_step_id
                    ,p_name                =>upper('p_internal_location'))
         --
         ,p_last_medical_test_by  =>
             hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id   => p_transaction_step_id
                    ,p_name                =>upper('p_last_medical_test_by'))
         --
         ,p_last_medical_test_date  =>
             hr_transaction_api.get_date_value
                  (p_transaction_step_id   => p_transaction_step_id
                    ,p_name                =>upper('p_last_medical_test_date'))
         --
         ,p_mailstop  =>
             hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id   => p_transaction_step_id
                    ,p_name                =>upper('p_mailstop'))
         --
         ,p_office_number  =>
             hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id   => p_transaction_step_id
                    ,p_name                =>upper('p_office_number'))
         --
         ,p_on_military_service  =>
             hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id   => p_transaction_step_id
                    ,p_name                =>upper('p_on_military_service'))
         --
         -- Bug 2652114
         /*
         ,p_original_date_of_hire  =>
             hr_transaction_api.get_date_value
                  (p_transaction_step_id   => p_transaction_step_id
                    ,p_name                =>upper('p_original_date_of_hire'))
         */
         --
         ,p_projected_start_date  =>
             hr_transaction_api.get_date_value
                  (p_transaction_step_id   => p_transaction_step_id
                    ,p_name                =>upper('p_projected_start_date'))
         --
         ,p_receipt_of_death_cert_date  =>
             hr_transaction_api.get_date_value
                  (p_transaction_step_id   => p_transaction_step_id
                    ,p_name                =>upper('p_receipt_of_death_cert_date'))
         --
         ,p_region_of_birth  =>
             hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id   => p_transaction_step_id
                    ,p_name                =>upper('p_region_of_birth'))
         --
         ,p_rehire_authorizor  =>
             hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id   => p_transaction_step_id
                    ,p_name                =>upper('p_rehire_authorizor'))
         --
         ,p_rehire_recommendation  =>
             hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id   => p_transaction_step_id
                    ,p_name                =>upper('p_rehire_recommendation'))
         --
         ,p_rehire_reason  =>
             hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id   => p_transaction_step_id
                    ,p_name                =>upper('p_rehire_reason'))
         --
         ,p_resume_exists  =>
             hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id   => p_transaction_step_id
                    ,p_name                =>upper('p_resume_exists'))
         --
         ,p_resume_last_updated  =>
             hr_transaction_api.get_date_value
                  (p_transaction_step_id   => p_transaction_step_id
                    ,p_name                =>upper('p_resume_last_updated'))
         --
         ,p_second_passport_exists  =>
             hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id   => p_transaction_step_id
                    ,p_name                =>upper('p_second_passport_exists'))
         --
         ,p_student_status  =>
             hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id   => p_transaction_step_id
                    ,p_name                =>upper('p_student_status'))
         --
         ,p_town_of_birth  =>
             hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id   => p_transaction_step_id
                    ,p_name                =>upper('p_town_of_birth'))
         --
         ,p_uses_tobacco_flag  =>
             hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id   => p_transaction_step_id
                    ,p_name                =>upper('p_uses_tobacco_flag'))
         --
         ,p_vendor_id  =>
             hr_transaction_api.get_number_value
                  (p_transaction_step_id   => p_transaction_step_id
                    ,p_name                =>upper('p_vendor_id'))
         --
         ,p_work_schedule  =>
             hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id   => p_transaction_step_id
                    ,p_name                =>upper('p_work_schedule'))
         --
         ,p_effective_start_date              =>  l_per_effective_start_date
         ,p_effective_end_date                =>  l_per_effective_end_date
         ,p_full_name                         =>  l_full_name
         ,p_comment_id                        =>  l_per_comment_id
         ,p_name_combination_warning          =>  l_per_name_combination_warning
         ,p_assign_payroll_warning            =>  l_per_assign_payroll_warning
         ,p_orig_hire_warning                 =>  l_per_orig_hire_warning
         );

       END IF ;
       --
       if l_contact_operation = 'EMER_CR_NEW_CONT' OR
          l_contact_operation = 'DPDNT_CR_NEW_CONT' then
          --

          hr_utility.set_location('EMER_CR_NEW_CONT or DPDNT_CR_NEW_CONT:'||l_proc, 35);
-- Bug 3152505 : When in Emergency contact, we always will create two relationship.
-- One as "Emergency" and other the selected Relationship.
          if ( /*l_dpdnt_bnf_flag = 'Y' and*/ l_dpdnt_bnf_contact_type <> 'EMRG'
                                      and l_contact_operation = 'EMER_CR_NEW_CONT' ) OR
             ( l_emrg_cont_flag = 'Y' and l_contact_operation = 'DPDNT_CR_NEW_CONT' ) then


            if l_dpdnt_bnf_contact_type in ('P', 'C', 'S') then
                --
                l_CREATE_MIRROR_FLAG := 'Y';
                --
                if l_dpdnt_bnf_contact_type = 'P' then
                   l_MIRROR_TYPE := 'C';
                elsif l_dpdnt_bnf_contact_type = 'C' then
                   l_MIRROR_TYPE := 'P';
                elsif l_dpdnt_bnf_contact_type = 'S' then
                   l_MIRROR_TYPE := 'S';
                end if;
                --
            else
                --
                l_CREATE_MIRROR_FLAG := 'N' ;
                l_MIRROR_TYPE := null ;
                --
            end if;

--             l_CREATE_MIRROR_FLAG := 'N' ;
--             l_MIRROR_TYPE := null ;
--
-- Bug # 2115552
          if l_contact_operation = 'EMER_CR_NEW_CONT' then

             l_addl_primary_contact_flag := 'N';
          else
             l_addl_primary_contact_flag  :=
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_PRIMARY_CONTACT_FLAG');
          end if;
--
--
               hr_contact_rel_api.create_contact(
                P_VALIDATE  => p_validate
                --
                ,P_START_DATE  =>          l_effective_date
                --
                ,P_BUSINESS_GROUP_ID  =>
                   hr_transaction_api.get_NUMBER_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_BUSINESS_GROUP_ID')
                --
                ,P_PERSON_ID  =>  l_person_id
                --
                ,P_CONTACT_PERSON_ID  =>   l_per_person_id
                --
                ,P_CONTACT_TYPE  => l_dpdnt_bnf_contact_type
                --
                ,P_CTR_COMMENTS  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_CTR_COMMENTS')
                --
 -- Bug # 2115552
                ,P_PRIMARY_CONTACT_FLAG  => l_addl_primary_contact_flag

/*                ,P_PRIMARY_CONTACT_FLAG  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_PRIMARY_CONTACT_FLAG')
*/
                --
                ,P_DATE_START  =>
                   hr_transaction_api.get_DATE_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_DATE_START')
                --
                ,P_START_LIFE_REASON_ID  =>
                   hr_transaction_api.get_NUMBER_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_START_LIFE_REASON_ID')
                --
                ,P_DATE_END  =>
                   hr_transaction_api.get_DATE_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_DATE_END')
                --
                ,P_END_LIFE_REASON_ID  =>
                   hr_transaction_api.get_NUMBER_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_END_LIFE_REASON_ID')
                --
                ,P_RLTD_PER_RSDS_W_DSGNTR_FLAG  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_RLTD_PER_RSDS_W_DSGNTR_FLAG')
                --
                ,P_PERSONAL_FLAG  =>  l_dpdnt_bnf_personal_flag
                --
                ,P_SEQUENCE_NUMBER  =>
                   hr_transaction_api.get_NUMBER_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_SEQUENCE_NUMBER')
                --
                ,P_CONT_ATTRIBUTE_CATEGORY  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_CONT_ATTRIBUTE_CATEGORY')
                --
                ,P_CONT_ATTRIBUTE1  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_CONT_ATTRIBUTE1')
                --
                ,P_CONT_ATTRIBUTE2  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_CONT_ATTRIBUTE2')
                --
                ,P_CONT_ATTRIBUTE3  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_CONT_ATTRIBUTE3')
                --
                ,P_CONT_ATTRIBUTE4  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_CONT_ATTRIBUTE4')
                --
                ,P_CONT_ATTRIBUTE5  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_CONT_ATTRIBUTE5')
                --
                ,P_CONT_ATTRIBUTE6  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_CONT_ATTRIBUTE6')
                --
                ,P_CONT_ATTRIBUTE7  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_CONT_ATTRIBUTE7')
                --
                ,P_CONT_ATTRIBUTE8  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_CONT_ATTRIBUTE8')
                --
                ,P_CONT_ATTRIBUTE9  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_CONT_ATTRIBUTE9')
                --
                ,P_CONT_ATTRIBUTE10  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_CONT_ATTRIBUTE10')
                --
                ,P_CONT_ATTRIBUTE11  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_CONT_ATTRIBUTE11')
                --
                ,P_CONT_ATTRIBUTE12  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_CONT_ATTRIBUTE12')
                --
                ,P_CONT_ATTRIBUTE13  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_CONT_ATTRIBUTE13')
                --
                ,P_CONT_ATTRIBUTE14  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_CONT_ATTRIBUTE14')
                --
                ,P_CONT_ATTRIBUTE15  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_CONT_ATTRIBUTE15')
                --
                ,P_CONT_ATTRIBUTE16  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_CONT_ATTRIBUTE16')
                --
                ,P_CONT_ATTRIBUTE17  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_CONT_ATTRIBUTE17')
                --
                ,P_CONT_ATTRIBUTE18  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_CONT_ATTRIBUTE18')
                --
                ,P_CONT_ATTRIBUTE19  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_CONT_ATTRIBUTE19')
                --
                ,P_CONT_ATTRIBUTE20  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_CONT_ATTRIBUTE20')
                --
                ,P_THIRD_PARTY_PAY_FLAG  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_THIRD_PARTY_PAY_FLAG')
                --
                ,P_BONDHOLDER_FLAG  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_BONDHOLDER_FLAG')
                --
                ,P_DEPENDENT_FLAG  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_DEPENDENT_FLAG')
                --
                ,P_BENEFICIARY_FLAG  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_BENEFICIARY_FLAG')
                --
                ,P_CREATE_MIRROR_FLAG  =>  l_CREATE_MIRROR_FLAG
                --
                ,P_MIRROR_TYPE  => l_MIRROR_TYPE
                --
                ,P_MIRROR_CONT_ATTRIBUTE_CAT  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE_CAT')
                --
                ,P_MIRROR_CONT_ATTRIBUTE1  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE1')
                --
                ,P_MIRROR_CONT_ATTRIBUTE2  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE2')
                --
                ,P_MIRROR_CONT_ATTRIBUTE3  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE3')
                --
                ,P_MIRROR_CONT_ATTRIBUTE4  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE4')
                --
                ,P_MIRROR_CONT_ATTRIBUTE5  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE5')
                --
                ,P_MIRROR_CONT_ATTRIBUTE6  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE6')
                --
                ,P_MIRROR_CONT_ATTRIBUTE7  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE7')
                --
                ,P_MIRROR_CONT_ATTRIBUTE8  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE8')
                --
                ,P_MIRROR_CONT_ATTRIBUTE9  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE9')
                --
                ,P_MIRROR_CONT_ATTRIBUTE10  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE10')
                --
                ,P_MIRROR_CONT_ATTRIBUTE11  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE11')
                --
                ,P_MIRROR_CONT_ATTRIBUTE12  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE12')
                --
                ,P_MIRROR_CONT_ATTRIBUTE13  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE13')
                --
                ,P_MIRROR_CONT_ATTRIBUTE14  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE14')
                --
                ,P_MIRROR_CONT_ATTRIBUTE15  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE15')
                --
                ,P_MIRROR_CONT_ATTRIBUTE16  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE16')
                --
                ,P_MIRROR_CONT_ATTRIBUTE17  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE17')
                --
                ,P_MIRROR_CONT_ATTRIBUTE18  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE18')
                --
                ,P_MIRROR_CONT_ATTRIBUTE19  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE19')
                --
                ,P_MIRROR_CONT_ATTRIBUTE20  =>
                   hr_transaction_api.get_VARCHAR2_value
                     (p_transaction_step_id => p_transaction_step_id
                     ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE20')
                --

                ,P_CONTACT_RELATIONSHIP_ID  	=> L_CONTACT_RELATIONSHIP_ID1
                --
                ,P_CTR_OBJECT_VERSION_NUMBER 	=> L_CTR_OBJECT_VERSION_NUMBER1
                --
                ,P_PER_PERSON_ID  		=> L_PER_PERSON_ID1
                --
                ,P_PER_OBJECT_VERSION_NUMBER 	=> L_PER_OBJECT_VERSION_NUMBER1
                --
                ,P_PER_EFFECTIVE_START_DATE  	=> L_PER_EFFECTIVE_START_DATE1
                --
                ,P_PER_EFFECTIVE_END_DATE  	=> L_PER_EFFECTIVE_END_DATE1
                --
                ,P_FULL_NAME  		=> L_FULL_NAME1
                --
                ,P_PER_COMMENT_ID  		=> L_PER_COMMENT_ID1
                --
                ,P_NAME_COMBINATION_WARNING  	=> L_CON_NAME_COMBINATION_WARNIN1
                --
                ,P_ORIG_HIRE_WARNING  	=> L_CON_ORIG_HIRE_WARNING1
		--
               ,P_CONT_INFORMATION_CATEGORY  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_CONT_INFORMATION_CATEGORY')
              --
              ,P_CONT_INFORMATION1  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_CONT_INFORMATION1')
              --
              ,P_CONT_INFORMATION2  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_CONT_INFORMATION2')
              --
              ,P_CONT_INFORMATION3  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_CONT_INFORMATION3')
              --
              ,P_CONT_INFORMATION4  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_CONT_INFORMATION4')
              --
              ,P_CONT_INFORMATION5  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_CONT_INFORMATION5')
              --
              ,P_CONT_INFORMATION6  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_CONT_INFORMATION6')
              --
              ,P_CONT_INFORMATION7  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_CONT_INFORMATION7')
              --
              ,P_CONT_INFORMATION8  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_CONT_INFORMATION8')
              --
              ,P_CONT_INFORMATION9  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_CONT_INFORMATION9')
              --
              ,P_CONT_INFORMATION10  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_CONT_INFORMATION10')
              --
              ,P_CONT_INFORMATION11  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_CONT_INFORMATION11')
              --
              ,P_CONT_INFORMATION12  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_CONT_INFORMATION12')
              --
              ,P_CONT_INFORMATION13  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_CONT_INFORMATION13')
              --
              ,P_CONT_INFORMATION14  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_CONT_INFORMATION14')
              --
              ,P_CONT_INFORMATION15  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_CONT_INFORMATION15')
              --
              ,P_CONT_INFORMATION16  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_CONT_INFORMATION16')
              --
              ,P_CONT_INFORMATION17  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_CONT_INFORMATION17')
              --
              ,P_CONT_INFORMATION18  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_CONT_INFORMATION18')
              --
              ,P_CONT_INFORMATION19  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_CONT_INFORMATION19')
              --
              ,P_CONT_INFORMATION20  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_CONT_INFORMATION20')
	      --
      	     ,P_MIRROR_CONT_INFORMATION_CAT  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_MIRROR_CONT_INFORMATION_CAT')
              --
             ,P_MIRROR_CONT_INFORMATION1  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_MIRROR_CONT_INFORMATION1')
              --
             ,P_MIRROR_CONT_INFORMATION2  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_MIRROR_CONT_INFORMATION2')
              --
             ,P_MIRROR_CONT_INFORMATION3  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_MIRROR_CONT_INFORMATION3')
              --
             ,P_MIRROR_CONT_INFORMATION4  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_MIRROR_CONT_INFORMATION4')
              --
             ,P_MIRROR_CONT_INFORMATION5  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_MIRROR_CONT_INFORMATION5')
              --
             ,P_MIRROR_CONT_INFORMATION6  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_MIRROR_CONT_INFORMATION6')
              --
             ,P_MIRROR_CONT_INFORMATION7  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_MIRROR_CONT_INFORMATION7')
              --
             ,P_MIRROR_CONT_INFORMATION8  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_MIRROR_CONT_INFORMATION8')
              --
             ,P_MIRROR_CONT_INFORMATION9  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_MIRROR_CONT_INFORMATION9')
              --
             ,P_MIRROR_CONT_INFORMATION10  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_MIRROR_CONT_INFORMATION10')
              --
             ,P_MIRROR_CONT_INFORMATION11  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_MIRROR_CONT_INFORMATION11')
              --
             ,P_MIRROR_CONT_INFORMATION12  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_MIRROR_CONT_INFORMATION12')
              --
             ,P_MIRROR_CONT_INFORMATION13  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_MIRROR_CONT_INFORMATION13')
              --
             ,P_MIRROR_CONT_INFORMATION14  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_MIRROR_CONT_INFORMATION14')
              --
             ,P_MIRROR_CONT_INFORMATION15  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_MIRROR_CONT_INFORMATION15')
              --
             ,P_MIRROR_CONT_INFORMATION16  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_MIRROR_CONT_INFORMATION16')
              --
             ,P_MIRROR_CONT_INFORMATION17  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_MIRROR_CONT_INFORMATION17')
              --
             ,P_MIRROR_CONT_INFORMATION18  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_MIRROR_CONT_INFORMATION18')
              --
             ,P_MIRROR_CONT_INFORMATION19 =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_MIRROR_CONT_INFORMATION19')
              --
             ,P_MIRROR_CONT_INFORMATION20  =>
                 hr_transaction_api.get_VARCHAR2_value
                   (p_transaction_step_id => p_transaction_step_id
                   ,p_name                => 'P_MIRROR_CONT_INFORMATION20')
               );
             --
          end if;
          --
  end if;
  --
       --
       -- Store the l_per_person_id in package global so that it
       -- can be used by create phone.
       --
       g_contact_person_id := L_PER_PERSON_ID;
       --
  END IF;
  --
  IF l_per_assign_payroll_warning THEN
     -- ------------------------------------------------------------
     -- The assign payroll warning has been set so we must set the
     -- error so we can retrieve the text using fnd_message.get
     -- -------------------------------------------------------------
     -- as of now, 09/07/00, we don't know how to handle warnings yet. So, we
     -- just don't do anything.
     null;
  END IF;
  --
  IF p_validate = true THEN
     ROLLBACK TO process_create_contact_api;
  END IF;
--

EXCEPTION
  WHEN hr_utility.hr_error THEN
  hr_utility.set_location('Exception:WHEN hr_utility.hr_error THEN'||l_proc,565);
    -- -----------------------------------------------------------------
    -- An application error has been raised by the API so we must set
    -- the error.
    -- -----------------------------------------------------------------
        ROLLBACK TO process_create_contact_api;
        RAISE;

END process_create_contact_api;
--

-- ---------------------------------------------------------------------------
-- ----------------------------- < process_api > -----------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will be invoked in workflow notification
--          when an approver approves all the changes.  This procedure
--          will call the api to update to the database with p_validate
--          equal to false.
-- ---------------------------------------------------------------------------
PROCEDURE process_api
  (p_validate IN BOOLEAN DEFAULT FALSE
  ,p_transaction_step_id IN NUMBER
  ,p_effective_date      in varchar2 default null
)
IS
   cursor get_emrg_relid_ovn(p_contact_relationship_id     number
                            ,p_contact_person_id           number
                            ,p_person_id number)
   is
   select contact_relationship_id,
          object_version_number,
          primary_contact_flag
   from PER_CONTACT_RELATIONSHIPS
   where person_id = p_person_id
   and contact_person_id = p_contact_person_id
   and contact_type = 'EMRG'
   and trunc(sysdate) >= decode(date_start,null,trunc(sysdate),trunc(date_start))
   and trunc(sysdate) <  decode(date_end,null,trunc(sysdate)+1,trunc(date_end));

   cursor get_other_relid_ovn(p_contact_person_id           number
                            ,p_person_id number)
   is
   select contact_relationship_id,
          object_version_number
   from PER_CONTACT_RELATIONSHIPS
   where person_id = p_person_id
   and contact_person_id = p_contact_person_id
   and trunc(sysdate) >= decode(date_start,null,trunc(sysdate),trunc(date_start))
   and trunc(sysdate) <  decode(date_end,null,trunc(sysdate)+1,trunc(date_end));

  --
  l_effective_start_date             date default null;
  l_effective_end_date               date default null;
  l_ovn                              number default null;
  l_per_ovn			     number default null;
  l_employee_number		     per_all_people_f.employee_number%type default null;
  l_contact_relationship_id          number default null;
  l_per_rec_changed	             varchar2(100) default 'NOTCHANGED' ;
  l_cont_rec_changed                 varchar2(100) default 'NOTCHANGED' ;
  l_full_name                        per_all_people_f.full_name%type default null;
  l_comment_id                       number default null;
  l_name_combination_warning         boolean default null ;
  l_assign_payroll_warning           boolean default null ;
  l_orig_hire_warning                boolean default null ;
  l_datetrack_update_mode            varchar2(100);
  l_process_section                  varchar2(100);
  --
  l_contact_operation                varchar2(100);
  l_contact_type                     varchar2(100);
  l_personal_flag                    varchar2(100);
  l_full_name1                       per_all_people_f.full_name%type;
  l_per_comment_id1                  per_all_people_f.comment_id%type;
  l_con_name_combination_warnin1    boolean;
  l_con_orig_hire_warning1           boolean;
  l_per_person_id1                   per_all_people_f.person_id%type
                                     default null;
  l_contact_relationship_id1         number default null;
  l_ctr_object_version_number1       number default null;
  l_per_object_version_number1       number default null;
  l_per_effective_start_date1        date default null;
  l_per_effective_end_date1          date default null;
  l_effective_date                   date default null;
  --
  l_date_sart                        date;
  l_date_end                         date;
  l_action                           varchar2(20);
  l_orig_rel_type                    varchar2(30);
  l_primary_contact_flag             varchar2(100);
  l_emrg_ovn                         number default null;
  l_emrg_relid                       number default null;
  l_other_ovn                         number default null;
  l_other_relid                       number default null;
  l_emrg_primary_cont_flag           varchar2(100);
  l_proc   varchar2(72)  := g_package||'process_api';

--- bug 5894873
  l_start_contact_date                date;
  l_old_contact_relationship_id       number;

  p_rowid varchar2(300);
  l_CONTACT_RELATIONSHIP_ID_1 number;
  skip_contact_create_flg number := 0;

--- bug 5894873

BEGIN
  --
  --  hr_utility.set_location('Entering hr_process_contact_ss.process_api', 100);
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
  SAVEPOINT update_cont_relationship;

  -- Change for Approvals for contact.
  -- Get the process section.
  --
  l_process_section := hr_transaction_api.get_varchar2_value
                        (p_transaction_step_id => p_transaction_step_id
                         ,p_name =>upper( 'P_PROCESS_SECTION_NAME'));
  --
  if l_process_section = 'DELETE_CONTACTS' then
     --
     hr_utility.set_location('DELETE_CONTACTS:'||l_proc, 10);
     process_end_api
          (p_validate            => p_validate
          ,p_transaction_step_id => p_transaction_step_id
          -- SFL changes
          ,p_effective_date      => p_effective_date
     );
     --
     hr_utility.set_location('Leaving hr_process_contact_ss.process_api', 100);
     return;
     --
 -- end if;
  else -- l_process_section is not 'DELETE_CONTACTS'
 --
  -- SFL changes

         is_address_updated(
                                 P_CONTACT_RELATIONSHIP_ID  => hr_transaction_api.get_NUMBER_value
                                                                                               (p_transaction_step_id => p_transaction_step_id
			                 ,p_name                => 'P_CONTACT_RELATIONSHIP_ID')
                                ,P_DATE_START  =>                            hr_transaction_api.get_DATE_value
			                 (p_transaction_step_id => p_transaction_step_id
         	                                                                     ,p_name                => 'P_DATE_START')
                               ,p_transaction_step_id => p_transaction_step_id
 	    ,p_CONTACT_PERSON_ID =>                hr_transaction_api.get_NUMBER_value
			                (p_transaction_step_id => p_transaction_step_id
        			                 ,p_name                => 'P_CONTACT_PERSON_ID')
           	    , p_PERSON_ID =>       	                  hr_transaction_api.get_NUMBER_value
			                 (p_transaction_step_id => p_transaction_step_id
         			                 ,p_name                => 'P_PERSON_ID'));
  begin
     --
     l_per_rec_changed   := hr_transaction_api.get_varchar2_value
	   (p_transaction_step_id => p_transaction_step_id
	   ,p_name                => 'p_per_rec_changed') ;
     --
  exception
     when others then
       l_per_rec_changed   := 'NULL';
  end;

  IF l_per_rec_changed = 'CHANGED' THEN
           --
    l_per_ovn           :=  hr_transaction_api.get_number_value
	   (p_transaction_step_id => p_transaction_step_id
	   ,p_name                => 'p_per_object_version_number') ;
         --
    l_employee_number   :=  hr_transaction_api.get_varchar2_value
	   (p_transaction_step_id => p_transaction_step_id
	   ,p_name                => 'p_employee_number') ;

    l_datetrack_update_mode :=
		 hr_transaction_api.get_varchar2_value
		 (p_transaction_step_id   => p_transaction_step_id
		  ,p_name                 =>upper('p_datetrack_update_mode'));
    --
    if l_datetrack_update_mode = 'CORRECT' then
       l_datetrack_update_mode := 'CORRECTION';
    else
       -- 9999 Do we need a different mode.
       l_datetrack_update_mode := 'CORRECTION';
    end if;
    --
    if not p_validate then
     --
     l_effective_date := hr_transaction_api.get_DATE_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_EFFECTIVE_DATE');
     --
    end if;
    --
    hr_person_api.update_person(

	 p_validate  =>  p_validate
      --
	 ,p_effective_date  => l_effective_date
                 /*
		 hr_transaction_api.get_date_value
		 (p_transaction_step_id   => p_transaction_step_id
		  ,p_name                 =>upper('p_per_effective_date'))
                 */
      --
	 ,p_datetrack_update_mode  =>  l_datetrack_update_mode
      -- 9999
      --          hr_transaction_api.get_varchar2_value
      --          (p_transaction_step_id   => p_transaction_step_id
      --               ,p_name             =>upper('p_datetrack_update_mode'))
      --
	 ,p_person_id  =>
		 hr_transaction_api.get_number_value
		 (p_transaction_step_id   => p_transaction_step_id
		  ,p_name                 =>upper('p_cont_person_id'))
      --
	 ,p_object_version_number  => l_per_ovn
      --

    ---------------------------------------------------------------------------
    -- Bug 1937643 Fix Begins - 08/04/2002
    -- With the PTU model, the per_all_people_f.person_type_id stores only the
    -- default user flavor of the system_person_type.  The true user flavor
    -- for the system_person_type is stored in per_person_type_usages_f table.
    -- Since the current Personal Information Contacts region
    -- does not allow a user to choose any user flavor, so we do not pass in
    -- p_person_type_id when calling the hr_person_api.update_person.  That way,
    -- the api will understand that the person_type is not changed and will not
    -- update the person_type_id in per_person_type_usages_f table as is.  If we
    -- pass the per_all_people_f.person_type_id to the api,the person_type_id in
    -- per_person_type_usages_f table will be updated with that value which will
    -- overwrite the true user flavor of the system person type with the
    -- default user flavor person type.  This may not be desirable.
    -- When we allow a user to select user flavors of person type in Contacts
    -- region, the commented out code needs to change and the whole package
    -- of this hrconwrs.pkb needs to get the true person_type_id from the
    -- per_person_type_usages_f table.
    ---------------------------------------------------------------------------
    /*
	 ,p_person_type_id  =>
		 hr_transaction_api.get_number_value
		 (p_transaction_step_id   => p_transaction_step_id
		  ,p_name                 =>upper('p_person_type_id'))
    */
      --
	 ,p_last_name  =>
		 hr_transaction_api.get_varchar2_value
                (p_transaction_step_id   => p_transaction_step_id
                 ,p_name                 =>upper('p_last_name'))
      --
        ,p_applicant_number  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_applicant_number'))
      --
         ,p_comments  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_per_comments'))
      --
         ,p_date_employee_data_verified  =>
                 hr_transaction_api.get_date_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_date_employee_data_verified'))
      --
         ,p_date_of_birth  =>
                 hr_transaction_api.get_date_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_date_of_birth'))
      --
         ,p_email_address  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_email_address'))
      --
         ,p_employee_number  =>  l_employee_number
      --
         ,p_expense_check_send_to_addres  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_expense_check_send_to_addres'))
      --
         ,p_first_name  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_first_name'))
      --
         ,p_known_as  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_known_as'))
      --
         ,p_marital_status  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_marital_status'))
      --
         ,p_middle_names  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_middle_names'))
      --
         ,p_nationality  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_nationality'))
      --
         ,p_national_identifier  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_national_identifier'))
      --
         ,p_previous_last_name  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_previous_last_name'))
      --
         ,p_registered_disabled_flag  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_registered_disabled_flag'))
      --
         ,p_sex  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_sex'))
      --
         ,p_title  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_title'))
      --
         ,p_vendor_id  =>
                 hr_transaction_api.get_number_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_vendor_id'))
      --
         ,p_work_telephone  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_work_telephone'))
      --
         ,p_attribute_category  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_attribute_category'))
      --
         ,p_attribute1  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_attribute1'))
      --
         ,p_attribute2  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_attribute2'))
      --
         ,p_attribute3  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_attribute3'))
      --
         ,p_attribute4  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_attribute4'))
      --
         ,p_attribute5  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_attribute5'))
      --
         ,p_attribute6  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_attribute6'))
      --
         ,p_attribute7  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_attribute7'))
      --
         ,p_attribute8  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_attribute8'))
      --
         ,p_attribute9  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_attribute9'))
      --
         ,p_attribute10  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_attribute10'))
      --
         ,p_attribute11  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_attribute11'))
      --
         ,p_attribute12  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_attribute12'))
      --
         ,p_attribute13  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_attribute13'))
      --
         ,p_attribute14  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_attribute14'))
      --
         ,p_attribute15  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_attribute15'))
      --
         ,p_attribute16  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_attribute16'))
      --
         ,p_attribute17  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_attribute17'))
      --
         ,p_attribute18  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_attribute18'))
      --
         ,p_attribute19  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_attribute19'))
      --
         ,p_attribute20  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_attribute20'))
      --
         ,p_attribute21  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_attribute21'))
      --
         ,p_attribute22  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_attribute22'))
      --
         ,p_attribute23  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_attribute23'))
      --
         ,p_attribute24  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_attribute24'))
      --
         ,p_attribute25  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_attribute25'))
      --
         ,p_attribute26  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_attribute26'))
      --
         ,p_attribute27  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_attribute27'))
      --
         ,p_attribute28  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_attribute28'))
      --
         ,p_attribute29  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_attribute29'))
      --
         ,p_attribute30  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_attribute30'))
      --
         ,p_per_information_category  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_per_information_category'))
      --
         ,p_per_information1  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_per_information1'))
      --
         ,p_per_information2  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_per_information2'))
      --
         ,p_per_information3  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_per_information3'))
      --
         ,p_per_information4  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_per_information4'))
      --
         ,p_per_information5  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_per_information5'))
      --
         ,p_per_information6  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_per_information6'))
      --
         ,p_per_information7  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_per_information7'))
      --
         ,p_per_information8  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_per_information8'))
      --
         ,p_per_information9  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_per_information9'))
      --
         ,p_per_information10  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_per_information10'))
      --
         ,p_per_information11  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_per_information11'))
      --
         ,p_per_information12  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_per_information12'))
      --
         ,p_per_information13  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_per_information13'))
      --
         ,p_per_information14  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_per_information14'))
      --
         ,p_per_information15  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_per_information15'))
      --
         ,p_per_information16  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_per_information16'))
      --
         ,p_per_information17  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_per_information17'))
      --
         ,p_per_information18  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_per_information18'))
      --
         ,p_per_information19  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_per_information19'))
      --
         ,p_per_information20  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_per_information20'))
      --
         ,p_per_information21  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_per_information21'))
      --
         ,p_per_information22  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_per_information22'))
      --
         ,p_per_information23  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_per_information23'))
      --
         ,p_per_information24  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_per_information24'))
      --
         ,p_per_information25  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_per_information25'))
      --
         ,p_per_information26  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_per_information26'))
      --
         ,p_per_information27  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_per_information27'))
      --
         ,p_per_information28  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_per_information28'))
      --
         ,p_per_information29  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_per_information29'))
      --
         ,p_per_information30  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_per_information30'))
      --
         ,p_date_of_death  =>
                 hr_transaction_api.get_date_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_date_of_death'))
      --
         ,p_background_check_status  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_background_check_status'))
      --
         ,p_background_date_check  =>
                 hr_transaction_api.get_date_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_background_date_check'))
      --
         ,p_blood_type  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_blood_type'))
      --
         ,p_correspondence_language  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_correspondence_language'))
      --
         ,p_fast_path_employee  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_fast_path_employee'))
      --
         ,p_fte_capacity  =>
                 hr_transaction_api.get_number_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_fte_capacity'))
      --
         ,p_hold_applicant_date_until  =>
                 hr_transaction_api.get_date_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_hold_applicant_date_until'))
      --
         ,p_honors  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_honors'))
      --
         ,p_internal_location  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_internal_location'))
      --
         ,p_last_medical_test_by  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_last_medical_test_by'))
      --
         ,p_last_medical_test_date  =>
                 hr_transaction_api.get_date_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_last_medical_test_date'))
      --
         ,p_mailstop  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_mailstop'))
      --
         ,p_office_number  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_office_number'))
      --
         ,p_on_military_service  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_on_military_service'))
      --
         ,p_pre_name_adjunct  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_pre_name_adjunct'))
      --
         ,p_projected_start_date  =>
                 hr_transaction_api.get_date_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_projected_start_date'))
      --
         ,p_rehire_authorizor  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_rehire_authorizor'))
      --
         ,p_rehire_recommendation  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_rehire_recommendation'))
      --
         ,p_resume_exists  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_resume_exists'))
      --
         ,p_resume_last_updated  =>
                 hr_transaction_api.get_date_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_resume_last_updated'))
      --
         ,p_second_passport_exists  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_second_passport_exists'))
      --
         ,p_student_status  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_student_status'))
      --
         ,p_work_schedule  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_work_schedule'))
      --
         ,p_rehire_reason  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_rehire_reason'))
      --
         ,p_suffix  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_suffix'))
      --
         ,p_benefit_group_id  =>
                 hr_transaction_api.get_number_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_benefit_group_id'))
      --
         ,p_receipt_of_death_cert_date  =>
                 hr_transaction_api.get_date_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_receipt_of_death_cert_date'))
      --
         ,p_coord_ben_med_pln_no  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_coord_ben_med_pln_no'))
      --
         ,p_coord_ben_no_cvg_flag  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_coord_ben_no_cvg_flag'))
      --
         ,p_uses_tobacco_flag  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_uses_tobacco_flag'))
      --
         ,p_dpdnt_adoption_date  =>
                 hr_transaction_api.get_date_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_dpdnt_adoption_date'))
      --
         ,p_dpdnt_vlntry_svce_flag  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_dpdnt_vlntry_svce_flag'))
      --
      /*
      -- Bug 2652114 : As the java code passes null value do not pass the null value
      -- to api. SS contacts module is not allowed to modify adjusted service date
      -- and original_date_of_hire
      -- So not necessary to pass the parameter.
      --
         ,p_original_date_of_hire  =>
                 hr_transaction_api.get_date_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_original_date_of_hire'))
      --
         ,p_adjusted_svc_date  =>
                 hr_transaction_api.get_date_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_adjusted_svc_date'))
      */
      --
         ,p_town_of_birth  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_town_of_birth'))
      --
         ,p_region_of_birth  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_region_of_birth'))
      --
         ,p_country_of_birth  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_country_of_birth'))
      --
         ,p_global_person_id  =>
                 hr_transaction_api.get_varchar2_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_global_person_id'))
      --
         ,p_effective_start_date  =>      l_effective_start_date
      --
         ,p_effective_end_date  =>        l_effective_end_date
      --
         ,p_full_name  =>                 l_full_name
      --
         ,p_comment_id  =>                l_comment_id
      --
         ,p_name_combination_warning  =>  l_name_combination_warning
      --
         ,p_assign_payroll_warning  =>    l_assign_payroll_warning
      --
         ,p_orig_hire_warning  =>         l_orig_hire_warning
      --
    );
    --
  END IF;

  hr_utility.set_location('p_effective_date = ' || p_effective_date, 999);
  if (p_effective_date is not null) then

    l_effective_date:= to_date(p_effective_date,g_date_format);

  else
       l_effective_date:= to_date(
         hr_transaction_ss.get_wf_effective_date
        (p_transaction_step_id => p_transaction_step_id),g_date_format);

  end if;
  --
  -- For normal commit the effective date should come from txn tbales.
  --
  if not p_validate then
  --
     l_effective_date := hr_transaction_api.get_DATE_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_EFFECTIVE_DATE');
  --
  end if;
  hr_utility.set_location('l_effective_date = ' || l_effective_date, 999);
  --
  --
  -- Get the contact_relationship_id  first.  If it is null, that means
  -- this is error and raise the error. -- add the error name 99999.
  --
  l_cont_rec_changed := hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => p_transaction_step_id
                         ,p_name =>upper( 'p_cont_rec_changed'));

  --
  l_contact_relationship_id := hr_transaction_api.get_number_value
			(p_transaction_step_id => p_transaction_step_id
				,p_name => 'P_CONTACT_RELATIONSHIP_ID');
  --
  l_ovn := hr_transaction_api.get_number_value
	     (p_transaction_step_id => p_transaction_step_id
	     ,p_name => 'P_CONT_OBJECT_VERSION_NUMBER');

  --
  l_action := hr_transaction_api.get_varchar2_value
             (p_transaction_step_id => p_transaction_step_id
             ,p_name =>upper( 'p_action'));
  --
  l_orig_rel_type :=  hr_transaction_api.get_VARCHAR2_value
	       (p_transaction_step_id => p_transaction_step_id
               ,p_name                => upper('p_orig_rel_type'));

   --
  l_contact_operation  :=
      hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                =>upper( 'p_contact_operation'));


  IF l_contact_relationship_id IS NOT NULL AND
     l_cont_rec_changed = 'CHANGED' and l_contact_relationship_id > 0
  THEN
    --
    -- If shared residence flag is yes then delete the contacts primary
    -- address.
    --
    if (hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_RLTD_PER_RSDS_W_DSGNTR_FLAG') = 'Y') then
       --
       p_del_cont_primary_addr
       (p_contact_relationship_id
            => hr_transaction_api.get_NUMBER_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_CONTACT_RELATIONSHIP_ID')
       );
       --
    end if;

    l_date_sart := hr_transaction_api.get_DATE_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_DATE_START');
    --
   l_primary_contact_flag :=
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PRIMARY_CONTACT_FLAG');
   if l_primary_contact_flag = null then
      l_primary_contact_flag := 'N';
   end if;


  if l_action = 'UPDATE' then
   if l_orig_rel_type <> 'EMRG' then

---bug 5894873
---if earlier start date of contact is greater than or equals to the new date, then delete the contact,
---and create a new one. Else update the contact, and then create one.

   l_old_contact_relationship_id :=
        hr_transaction_api.get_NUMBER_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONTACT_RELATIONSHIP_ID');

    begin
        select nvl(date_start,trunc(sysdate))
        into l_start_contact_date
        from per_contact_relationships
        where contact_relationship_id = l_old_contact_relationship_id
        and object_version_number = l_ovn;
    exception
     when others then
     l_start_contact_date := l_date_sart;
    end;


    if l_start_contact_date > l_date_sart then
    /***********************************************************************************************
     hr_contact_rel_api.delete_contact_relationship method is commented out as this method
     did not support when contact is only one, i.e, it is not dual maintained. So from now
     PER_CONTACT_RELATIONSHIPS_PKG.Update_Row is called as core HR team is use it for the same pourpose.
     This row handler makes all necessary changes of the per_all_people_f and per_contact_relationships table
     One new check is add here with the help of the variable of skip_contact_create_flg
     This is, do not create a contact if already did so with this row handler method and has not set
     the end date of that row
     ***********************************************************************************************
     */

    /*hr_contact_rel_api.delete_contact_relationship(
       p_validate                => p_validate
      ,P_CONTACT_RELATIONSHIP_ID  =>
         hr_transaction_api.get_NUMBER_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONTACT_RELATIONSHIP_ID')
      ,p_object_version_number   => l_ovn
     );
    */
        l_CONTACT_RELATIONSHIP_ID_1 := hr_transaction_api.get_number_value
         (p_transaction_step_id => p_transaction_step_id
    	 ,p_name => 'P_CONTACT_RELATIONSHIP_ID');

    select rowid
    into p_rowid
    from per_contact_relationships
    where CONTACT_RELATIONSHIP_ID = l_CONTACT_RELATIONSHIP_ID_1;

    hr_utility.set_location('before call PER_CONTACT_RELATIONSHIPS_PKG.Update_Row:X_Contact_Relationship_Id:' || l_CONTACT_RELATIONSHIP_ID_1 , 5);

    PER_CONTACT_RELATIONSHIPS_PKG.Update_Row(
                     X_Rowid => p_rowid
                     , X_Contact_Relationship_Id => l_CONTACT_RELATIONSHIP_ID_1
                     , X_Business_Group_Id => hr_transaction_api.get_NUMBER_value
           					   (p_transaction_step_id => p_transaction_step_id
           					   ,p_name                => 'P_BUSINESS_GROUP_ID')
                     , X_Person_Id => hr_transaction_api.get_number_value
	                                           (p_transaction_step_id   => p_transaction_step_id
                                                   ,p_name                 =>upper('p_person_id'))
                     , X_Contact_Person_Id => hr_transaction_api.get_number_value
                                              (p_transaction_step_id   => p_transaction_step_id
                                              ,p_name                 =>upper('p_cont_person_id'))
                     , X_Contact_Type => hr_transaction_api.get_VARCHAR2_value
	   			       (p_transaction_step_id => p_transaction_step_id
           			       ,p_name                => 'P_CONTACT_TYPE')
                     , X_Comments => hr_transaction_api.get_VARCHAR2_value
                                   (p_transaction_step_id => p_transaction_step_id
           		           ,p_name                => 'P_CTR_COMMENTS')
                     , X_Bondholder_Flag => hr_transaction_api.get_VARCHAR2_value
           				  (p_transaction_step_id => p_transaction_step_id
		           		  ,p_name                => 'P_BONDHOLDER_FLAG')
                     , X_Third_Party_Pay_Flag => hr_transaction_api.get_VARCHAR2_value
           				       (p_transaction_step_id => p_transaction_step_id
           				       ,p_name                => 'P_THIRD_PARTY_PAY_FLAG')
                     , X_Primary_Contact_Flag => hr_transaction_api.get_VARCHAR2_value
                                               (p_transaction_step_id => p_transaction_step_id
                                               ,p_name                => 'P_PRIMARY_CONTACT_FLAG')
                     , X_Cont_Attribute_Category => hr_transaction_api.get_VARCHAR2_value
           					  (p_transaction_step_id => p_transaction_step_id
           				          ,p_name                => 'P_CONT_ATTRIBUTE_CATEGORY')
                     , X_Cont_Attribute1 => hr_transaction_api.get_VARCHAR2_value
                                          (p_transaction_step_id => p_transaction_step_id
                                          ,p_name                => 'P_CONT_ATTRIBUTE1')
                     , X_Cont_Attribute2 => hr_transaction_api.get_VARCHAR2_value
                                          (p_transaction_step_id => p_transaction_step_id
                                          ,p_name                => 'P_CONT_ATTRIBUTE2')
                     , X_Cont_Attribute3 => hr_transaction_api.get_VARCHAR2_value
                                          (p_transaction_step_id => p_transaction_step_id
                                          ,p_name                => 'P_CONT_ATTRIBUTE3')
                     , X_Cont_Attribute4 => hr_transaction_api.get_VARCHAR2_value
                                          (p_transaction_step_id => p_transaction_step_id
                                          ,p_name                => 'P_CONT_ATTRIBUTE4')
                     , X_Cont_Attribute5 => hr_transaction_api.get_VARCHAR2_value
                                          (p_transaction_step_id => p_transaction_step_id
                                          ,p_name                => 'P_CONT_ATTRIBUTE5')
                     , X_Cont_Attribute6 => hr_transaction_api.get_VARCHAR2_value
                                          (p_transaction_step_id => p_transaction_step_id
                                          ,p_name                => 'P_CONT_ATTRIBUTE6')
                     , X_Cont_Attribute7 => hr_transaction_api.get_VARCHAR2_value
                                          (p_transaction_step_id => p_transaction_step_id
                                          ,p_name                => 'P_CONT_ATTRIBUTE7')
                     , X_Cont_Attribute8 => hr_transaction_api.get_VARCHAR2_value
                                          (p_transaction_step_id => p_transaction_step_id
                                          ,p_name                => 'P_CONT_ATTRIBUTE8')
                     , X_Cont_Attribute9 => hr_transaction_api.get_VARCHAR2_value
                                          (p_transaction_step_id => p_transaction_step_id
                                          ,p_name                => 'P_CONT_ATTRIBUTE9')
                     , X_Cont_Attribute10 => hr_transaction_api.get_VARCHAR2_value
                                          (p_transaction_step_id => p_transaction_step_id
                                          ,p_name                => 'P_CONT_ATTRIBUTE10')
                     , X_Cont_Attribute11 => hr_transaction_api.get_VARCHAR2_value
                                          (p_transaction_step_id => p_transaction_step_id
                                          ,p_name                => 'P_CONT_ATTRIBUTE11')
                     , X_Cont_Attribute12 => hr_transaction_api.get_VARCHAR2_value
                                          (p_transaction_step_id => p_transaction_step_id
                                          ,p_name                => 'P_CONT_ATTRIBUTE12')
                     , X_Cont_Attribute13 => hr_transaction_api.get_VARCHAR2_value
                                          (p_transaction_step_id => p_transaction_step_id
                                          ,p_name                => 'P_CONT_ATTRIBUTE13')
                     , X_Cont_Attribute14 => hr_transaction_api.get_VARCHAR2_value
                                          (p_transaction_step_id => p_transaction_step_id
                                          ,p_name                => 'P_CONT_ATTRIBUTE14')
                     , X_Cont_Attribute15 => hr_transaction_api.get_VARCHAR2_value
                                          (p_transaction_step_id => p_transaction_step_id
                                          ,p_name                => 'P_CONT_ATTRIBUTE15')
                     , X_Cont_Attribute16 => hr_transaction_api.get_VARCHAR2_value
                                          (p_transaction_step_id => p_transaction_step_id
                                          ,p_name                => 'P_CONT_ATTRIBUTE16')
                     , X_Cont_Attribute17 => hr_transaction_api.get_VARCHAR2_value
                                          (p_transaction_step_id => p_transaction_step_id
                                          ,p_name                => 'P_CONT_ATTRIBUTE17')
                     , X_Cont_Attribute18 => hr_transaction_api.get_VARCHAR2_value
                                          (p_transaction_step_id => p_transaction_step_id
                                          ,p_name                => 'P_CONT_ATTRIBUTE18')
                     , X_Cont_Attribute19 => hr_transaction_api.get_VARCHAR2_value
                                          (p_transaction_step_id => p_transaction_step_id
                                          ,p_name                => 'P_CONT_ATTRIBUTE19')
                     , X_Cont_Attribute20 => hr_transaction_api.get_VARCHAR2_value
                                          (p_transaction_step_id => p_transaction_step_id
                                          ,p_name                => 'P_CONT_ATTRIBUTE20')
                     , X_Cont_Information_Category => hr_transaction_api.get_VARCHAR2_value
           				  (p_transaction_step_id => p_transaction_step_id
           				  ,p_name                => 'P_PER_INFORMATION_CATEGORY')
                     , X_Cont_Information1 => hr_transaction_api.get_VARCHAR2_value
            				    (p_transaction_step_id => p_transaction_step_id
           				    ,p_name                => 'P_CONT_INFORMATION1')
                     , X_Cont_Information2 => hr_transaction_api.get_VARCHAR2_value
            				    (p_transaction_step_id => p_transaction_step_id
           				    ,p_name                => 'P_CONT_INFORMATION2')
                     , X_Cont_Information3 => hr_transaction_api.get_VARCHAR2_value
            				    (p_transaction_step_id => p_transaction_step_id
           				    ,p_name                => 'P_CONT_INFORMATION3')
                     , X_Cont_Information4 => hr_transaction_api.get_VARCHAR2_value
            				    (p_transaction_step_id => p_transaction_step_id
           				    ,p_name                => 'P_CONT_INFORMATION4')
                     , X_Cont_Information5 => hr_transaction_api.get_VARCHAR2_value
            				    (p_transaction_step_id => p_transaction_step_id
           				    ,p_name                => 'P_CONT_INFORMATION5')
                     , X_Cont_Information6 => hr_transaction_api.get_VARCHAR2_value
            				    (p_transaction_step_id => p_transaction_step_id
           				    ,p_name                => 'P_CONT_INFORMATION6')
                     , X_Cont_Information7 => hr_transaction_api.get_VARCHAR2_value
            				    (p_transaction_step_id => p_transaction_step_id
           				    ,p_name                => 'P_CONT_INFORMATION7')
                     , X_Cont_Information8 => hr_transaction_api.get_VARCHAR2_value
            				    (p_transaction_step_id => p_transaction_step_id
           				    ,p_name                => 'P_CONT_INFORMATION8')
                     , X_Cont_Information9 => hr_transaction_api.get_VARCHAR2_value
            				    (p_transaction_step_id => p_transaction_step_id
           				    ,p_name                => 'P_CONT_INFORMATION9')
                     , X_Cont_Information10 => hr_transaction_api.get_VARCHAR2_value
            				    (p_transaction_step_id => p_transaction_step_id
           				    ,p_name                => 'P_CONT_INFORMATION10')
                     , X_Cont_Information11 => hr_transaction_api.get_VARCHAR2_value
            				    (p_transaction_step_id => p_transaction_step_id
           				    ,p_name                => 'P_CONT_INFORMATION11')
                     , X_Cont_Information12 => hr_transaction_api.get_VARCHAR2_value
            				    (p_transaction_step_id => p_transaction_step_id
           				    ,p_name                => 'P_CONT_INFORMATION12')
                     , X_Cont_Information13 => hr_transaction_api.get_VARCHAR2_value
            				    (p_transaction_step_id => p_transaction_step_id
           				    ,p_name                => 'P_CONT_INFORMATION13')
                     , X_Cont_Information14 => hr_transaction_api.get_VARCHAR2_value
            				    (p_transaction_step_id => p_transaction_step_id
           				    ,p_name                => 'P_CONT_INFORMATION14')
                     , X_Cont_Information15 => hr_transaction_api.get_VARCHAR2_value
            				    (p_transaction_step_id => p_transaction_step_id
           				    ,p_name                => 'P_CONT_INFORMATION15')
                     , X_Cont_Information16 => hr_transaction_api.get_VARCHAR2_value
            				    (p_transaction_step_id => p_transaction_step_id
           				    ,p_name                => 'P_CONT_INFORMATION16')
                     , X_Cont_Information17 => hr_transaction_api.get_VARCHAR2_value
            				    (p_transaction_step_id => p_transaction_step_id
           				    ,p_name                => 'P_CONT_INFORMATION17')
                     , X_Cont_Information18 => hr_transaction_api.get_VARCHAR2_value
            				    (p_transaction_step_id => p_transaction_step_id
           				    ,p_name                => 'P_CONT_INFORMATION18')
                     , X_Cont_Information19 => hr_transaction_api.get_VARCHAR2_value
            				    (p_transaction_step_id => p_transaction_step_id
           				    ,p_name                => 'P_CONT_INFORMATION19')
                     , X_Cont_Information20 => hr_transaction_api.get_VARCHAR2_value
            				    (p_transaction_step_id => p_transaction_step_id
           				    ,p_name                => 'P_CONT_INFORMATION20')
                     , X_Session_Date => null --- this session_date is not used in PER_CONTACT_RELATIONSHIPS_PKG.update_row method, so null is pass here
                     , X_Date_Start => hr_transaction_api.get_DATE_value
           			     (p_transaction_step_id => p_transaction_step_id
           			     ,p_name                => 'P_DATE_START')
                     , X_Start_Life_Reason_Id => hr_transaction_api.get_NUMBER_value
           				       (p_transaction_step_id => p_transaction_step_id
           				       ,p_name                => 'P_START_LIFE_REASON_ID')
                     , X_Date_End => hr_transaction_api.get_DATE_value
           			   (p_transaction_step_id => p_transaction_step_id
           			   ,p_name                => 'P_DATE_END')
                     , X_End_Life_Reason_Id => hr_transaction_api.get_NUMBER_value
           				     (p_transaction_step_id => p_transaction_step_id
           				     ,p_name                => 'P_END_LIFE_REASON_ID')
                     , X_Rltd_Per_Rsds_W_Dsgntr_Flag => hr_transaction_api.get_VARCHAR2_value
           					      (p_transaction_step_id => p_transaction_step_id
           					      ,p_name                => 'P_RLTD_PER_RSDS_W_DSGNTR_FLAG')
                     , X_Personal_Flag => hr_transaction_api.get_VARCHAR2_value
           				(p_transaction_step_id => p_transaction_step_id
           				,p_name                => 'P_PERSONAL_FLAG')
		     , X_Sequence_Number => hr_transaction_api.get_NUMBER_value
                                        (p_transaction_step_id => p_transaction_step_id
           				,p_name                => 'P_SEQUENCE_NUMBER')
                     , X_Dependent_Flag => hr_transaction_api.get_varchar2_value
        				 (p_transaction_step_id => p_transaction_step_id
        				 ,p_name                => 'P_DEPENDENT_FLAG')
                     , X_Beneficiary_Flag => hr_transaction_api.get_varchar2_value
        				   (p_transaction_step_id => p_transaction_step_id
        				   ,p_name                => 'P_BENEFICIARY_FLAG')
    );
    skip_contact_create_flg := 1;

    else
    l_date_end := trunc(l_date_sart) -1;
    hr_contact_rel_api.update_contact_relationship(
       p_validate                => p_validate
      ,P_EFFECTIVE_DATE         =>l_effective_date
      ,p_object_version_number   => l_ovn
      ,P_CONTACT_RELATIONSHIP_ID  =>
         hr_transaction_api.get_NUMBER_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONTACT_RELATIONSHIP_ID')
      ,p_date_end     => l_date_end
     );
     end if;
---bug 5894873


    -- end date the old relationship
/* commented for the bug bug 5894873
    l_date_end := trunc(l_date_sart) -1;
    hr_contact_rel_api.update_contact_relationship(
       p_validate                => p_validate
      ,P_EFFECTIVE_DATE         =>l_effective_date
      ,p_object_version_number   => l_ovn
      ,P_CONTACT_RELATIONSHIP_ID  =>
         hr_transaction_api.get_NUMBER_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONTACT_RELATIONSHIP_ID')
      ,p_date_end     => l_date_end
     );
commented for the bug bug 5894873
*/
   end if;
   -- if primary contact flag is checked/unchecked apply it emrg record and not for
   -- other personal relationship record
    open get_emrg_relid_ovn(
            hr_transaction_api.get_NUMBER_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONTACT_RELATIONSHIP_ID')
           ,hr_transaction_api.get_number_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 => 'P_CONTACT_PERSON_ID')
           ,hr_transaction_api.get_number_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 => 'P_PERSON_ID'));
    fetch get_emrg_relid_ovn into l_emrg_relid, l_emrg_ovn, l_emrg_primary_cont_flag;
    if get_emrg_relid_ovn%found then
     if((l_emrg_primary_cont_flag <> 'Y' and l_primary_contact_flag = 'Y') OR
        (l_emrg_primary_cont_flag <> 'N' and l_primary_contact_flag = 'N')) then
-- Bug 3504216 :  passing date_start as sysdate
        hr_contact_rel_api.update_contact_relationship(
         p_validate                => p_validate
        ,P_EFFECTIVE_DATE         =>l_effective_date
        ,p_object_version_number   => l_emrg_ovn
        ,P_CONTACT_RELATIONSHIP_ID  => l_emrg_relid
        ,P_PRIMARY_CONTACT_FLAG     => l_primary_contact_flag
	,P_DATE_START              => sysdate
       );
     end if;
     l_primary_contact_flag := 'N';
    end if;
    close get_emrg_relid_ovn;
   if skip_contact_create_flg <> 1 then -- 5894873
    hr_contact_rel_api.create_contact(
      P_VALIDATE  => p_validate
      --
      ,P_START_DATE  => l_effective_date
      --
      ,P_BUSINESS_GROUP_ID  =>
         hr_transaction_api.get_NUMBER_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_BUSINESS_GROUP_ID')
      --
      ,P_PERSON_ID  =>
          hr_transaction_api.get_number_value
	          (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_person_id'))
      --
      ,P_CONTACT_PERSON_ID  =>
         hr_transaction_api.get_number_value
	          (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_cont_person_id'))
      --
      ,P_CONTACT_TYPE  =>
         hr_transaction_api.get_VARCHAR2_value
	   (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONTACT_TYPE')
      --
      ,P_CTR_COMMENTS  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CTR_COMMENTS')
      --
      ,P_PRIMARY_CONTACT_FLAG  => l_primary_contact_flag
      --
      ,P_DATE_START  => l_date_sart

      --
      ,P_START_LIFE_REASON_ID  =>
         hr_transaction_api.get_NUMBER_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_START_LIFE_REASON_ID')
      --
      ,P_DATE_END  =>
         hr_transaction_api.get_DATE_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_DATE_END')
      --
      ,P_END_LIFE_REASON_ID  =>
         hr_transaction_api.get_NUMBER_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_END_LIFE_REASON_ID')
      --
      ,P_RLTD_PER_RSDS_W_DSGNTR_FLAG  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_RLTD_PER_RSDS_W_DSGNTR_FLAG')
      --
      ,P_PERSONAL_FLAG  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PERSONAL_FLAG')
      --
      ,P_SEQUENCE_NUMBER  =>
         hr_transaction_api.get_NUMBER_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_SEQUENCE_NUMBER')
      --
      ,P_CONT_ATTRIBUTE_CATEGORY  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE_CATEGORY')
      --
      ,P_CONT_ATTRIBUTE1  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE1')
      --
      ,P_CONT_ATTRIBUTE2  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE2')
      --
      ,P_CONT_ATTRIBUTE3  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE3')
      --
      ,P_CONT_ATTRIBUTE4  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE4')
      --
      ,P_CONT_ATTRIBUTE5  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE5')
      --
      ,P_CONT_ATTRIBUTE6  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE6')
      --
      ,P_CONT_ATTRIBUTE7  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE7')
      --
      ,P_CONT_ATTRIBUTE8  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE8')
      --
      ,P_CONT_ATTRIBUTE9  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE9')
      --
      ,P_CONT_ATTRIBUTE10  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE10')
      --
      ,P_CONT_ATTRIBUTE11  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE11')
      --
      ,P_CONT_ATTRIBUTE12  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE12')
      --
      ,P_CONT_ATTRIBUTE13  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE13')
      --
      ,P_CONT_ATTRIBUTE14  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE14')
      --
      ,P_CONT_ATTRIBUTE15  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE15')
      --
      ,P_CONT_ATTRIBUTE16  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE16')
      --
      ,P_CONT_ATTRIBUTE17  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE17')
      --
      ,P_CONT_ATTRIBUTE18  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE18')
      --
      ,P_CONT_ATTRIBUTE19  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE19')
      --
      ,P_CONT_ATTRIBUTE20  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE20')
      --
      ,P_THIRD_PARTY_PAY_FLAG  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_THIRD_PARTY_PAY_FLAG')
      --
      ,P_BONDHOLDER_FLAG  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_BONDHOLDER_FLAG')
      --
      ,P_DEPENDENT_FLAG  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_DEPENDENT_FLAG')
      --
      ,P_BENEFICIARY_FLAG  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_BENEFICIARY_FLAG')
      --
      ,P_LAST_NAME  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_LAST_NAME')
      --
      ,P_SEX  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_SEX')
      --
      ,P_PERSON_TYPE_ID  =>
         hr_transaction_api.get_NUMBER_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PERSON_TYPE_ID')
      --
      ,P_PER_COMMENTS  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_COMMENTS')
      --
      ,P_DATE_OF_BIRTH  =>
         hr_transaction_api.get_DATE_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_DATE_OF_BIRTH')
      --
      ,P_EMAIL_ADDRESS  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_EMAIL_ADDRESS')
      --
      ,P_FIRST_NAME  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_FIRST_NAME')
      --
      ,P_KNOWN_AS  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_KNOWN_AS')
      --
      ,P_MARITAL_STATUS  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MARITAL_STATUS')
      --
      ,P_MIDDLE_NAMES  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIDDLE_NAMES')
      --
      ,P_NATIONALITY  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_NATIONALITY')
      --
      ,P_NATIONAL_IDENTIFIER  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_NATIONAL_IDENTIFIER')
      --
      ,P_PREVIOUS_LAST_NAME  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PREVIOUS_LAST_NAME')
      --
      ,P_REGISTERED_DISABLED_FLAG  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_REGISTERED_DISABLED_FLAG')
      --
      ,P_TITLE  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_TITLE')
      --
      ,P_WORK_TELEPHONE  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_WORK_TELEPHONE')
      --
      ,P_ATTRIBUTE_CATEGORY  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE_CATEGORY')
      --
      ,P_ATTRIBUTE1  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE1')
      --
      ,P_ATTRIBUTE2  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE2')
      --
      ,P_ATTRIBUTE3  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE3')
      --
      ,P_ATTRIBUTE4  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE4')
      --
      ,P_ATTRIBUTE5  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE5')
      --
      ,P_ATTRIBUTE6  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE6')
      --
      ,P_ATTRIBUTE7  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE7')
      --
      ,P_ATTRIBUTE8  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE8')
      --
      ,P_ATTRIBUTE9  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE9')
      --
      ,P_ATTRIBUTE10  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE10')
      --
      ,P_ATTRIBUTE11  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE11')
      --
      ,P_ATTRIBUTE12  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE12')
      --
      ,P_ATTRIBUTE13  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE13')
      --
      ,P_ATTRIBUTE14  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE14')
      --
      ,P_ATTRIBUTE15  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE15')
      --
      ,P_ATTRIBUTE16  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE16')
      --
      ,P_ATTRIBUTE17  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE17')
      --
      ,P_ATTRIBUTE18  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE18')
      --
      ,P_ATTRIBUTE19  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE19')
      --
      ,P_ATTRIBUTE20  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE20')
      --
      ,P_ATTRIBUTE21  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE21')
      --
      ,P_ATTRIBUTE22  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE22')
      --
      ,P_ATTRIBUTE23  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE23')
      --
      ,P_ATTRIBUTE24  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE24')
      --
      ,P_ATTRIBUTE25  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE25')
      --
      ,P_ATTRIBUTE26  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE26')
      --
      ,P_ATTRIBUTE27  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE27')
      --
      ,P_ATTRIBUTE28  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE28')
      --
      ,P_ATTRIBUTE29  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE29')
      --
      ,P_ATTRIBUTE30  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_ATTRIBUTE30')
      --
      ,P_PER_INFORMATION_CATEGORY  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION_CATEGORY')
      --
      ,P_PER_INFORMATION1  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION1')
      --
      ,P_PER_INFORMATION2  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION2')
      --
      ,P_PER_INFORMATION3  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION3')
      --
      ,P_PER_INFORMATION4  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION4')
      --
      ,P_PER_INFORMATION5  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION5')
      --
      ,P_PER_INFORMATION6  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION6')
      --
      ,P_PER_INFORMATION7  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION7')
      --
      ,P_PER_INFORMATION8  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION8')
      --
      ,P_PER_INFORMATION9  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION9')
      --
      ,P_PER_INFORMATION10  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION10')
      --
      ,P_PER_INFORMATION11  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION11')
      --
      ,P_PER_INFORMATION12  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION12')
      --
      ,P_PER_INFORMATION13  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION13')
      --
      ,P_PER_INFORMATION14  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION14')
      --
      ,P_PER_INFORMATION15  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION15')
      --
      ,P_PER_INFORMATION16  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION16')
      --
      ,P_PER_INFORMATION17  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION17')
      --
      ,P_PER_INFORMATION18  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION18')
      --
      ,P_PER_INFORMATION19  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION19')
      --
      ,P_PER_INFORMATION20  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION20')
      --
      ,P_PER_INFORMATION21  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION21')
      --
      ,P_PER_INFORMATION22  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION22')
      --
      ,P_PER_INFORMATION23  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION23')
      --
      ,P_PER_INFORMATION24  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION24')
      --
      ,P_PER_INFORMATION25  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION25')
      --
      ,P_PER_INFORMATION26  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION26')
      --
      ,P_PER_INFORMATION27  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION27')
      --
      ,P_PER_INFORMATION28  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION28')
      --
      ,P_PER_INFORMATION29  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION29')
      --
      ,P_PER_INFORMATION30  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PER_INFORMATION30')
      --
      ,P_CORRESPONDENCE_LANGUAGE  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CORRESPONDENCE_LANGUAGE')
      --
      ,P_HONORS  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_HONORS')
      --
      ,P_PRE_NAME_ADJUNCT  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PRE_NAME_ADJUNCT')
      --
      ,P_SUFFIX  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_SUFFIX')
      --
      ,P_CREATE_MIRROR_FLAG  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CREATE_MIRROR_FLAG')

      --
      ,P_MIRROR_TYPE  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_TYPE')

      --
      ,P_MIRROR_CONT_ATTRIBUTE_CAT  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE_CAT')
      --
      ,P_MIRROR_CONT_ATTRIBUTE1  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE1')
      --
      ,P_MIRROR_CONT_ATTRIBUTE2  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE2')
      --
      ,P_MIRROR_CONT_ATTRIBUTE3  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE3')
      --
      ,P_MIRROR_CONT_ATTRIBUTE4  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE4')
      --
      ,P_MIRROR_CONT_ATTRIBUTE5  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE5')
      --
      ,P_MIRROR_CONT_ATTRIBUTE6  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE6')
      --
      ,P_MIRROR_CONT_ATTRIBUTE7  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE7')
      --
      ,P_MIRROR_CONT_ATTRIBUTE8  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE8')
      --
      ,P_MIRROR_CONT_ATTRIBUTE9  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE9')
      --
      ,P_MIRROR_CONT_ATTRIBUTE10  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE10')
      --
      ,P_MIRROR_CONT_ATTRIBUTE11  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE11')
      --
      ,P_MIRROR_CONT_ATTRIBUTE12  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE12')
      --
      ,P_MIRROR_CONT_ATTRIBUTE13  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE13')
      --
      ,P_MIRROR_CONT_ATTRIBUTE14  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE14')
      --
      ,P_MIRROR_CONT_ATTRIBUTE15  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE15')
      --
      ,P_MIRROR_CONT_ATTRIBUTE16  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE16')
      --
      ,P_MIRROR_CONT_ATTRIBUTE17  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE17')
      --
      ,P_MIRROR_CONT_ATTRIBUTE18  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE18')
      --
      ,P_MIRROR_CONT_ATTRIBUTE19  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE19')
      --
      ,P_MIRROR_CONT_ATTRIBUTE20  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE20')
      --
      ,P_CONTACT_RELATIONSHIP_ID  	=> l_contact_relationship_id1
      --
      ,P_CTR_OBJECT_VERSION_NUMBER  	=> l_ctr_object_version_number1
      --
      ,P_PER_PERSON_ID  		=> l_per_person_id1
      --
      ,P_PER_OBJECT_VERSION_NUMBER  	=> l_per_object_version_number1
      --
      ,P_PER_EFFECTIVE_START_DATE  	=> l_per_effective_start_date1
      --
      ,P_PER_EFFECTIVE_END_DATE  	=> l_per_effective_end_date1
      --
      ,P_FULL_NAME  			=> l_full_name
      --
      ,P_PER_COMMENT_ID  		=> l_per_comment_id1
      --
      ,P_NAME_COMBINATION_WARNING  	=> l_con_name_combination_warnin1
      --
      ,P_ORIG_HIRE_WARNING  		=> l_con_orig_hire_warning1
      --
      ,P_CONT_INFORMATION_CATEGORY  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION_CATEGORY')
      --
      ,P_CONT_INFORMATION1  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION1')
      --
      ,P_CONT_INFORMATION2  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION2')
      --
      ,P_CONT_INFORMATION3  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION3')
      --
      ,P_CONT_INFORMATION4  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION4')
      --
      ,P_CONT_INFORMATION5  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION5')
      --
      ,P_CONT_INFORMATION6  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INORMATION6')
      --
      ,P_CONT_INFORMATION7  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION7')
      --
      ,P_CONT_INFORMATION8  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION8')
      --
      ,P_CONT_INFORMATION9  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION9')
      --
      ,P_CONT_INFORMATION10  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION10')
      --
      ,P_CONT_INFORMATION11  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION11')
      --
      ,P_CONT_INFORMATION12  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION12')
      --
      ,P_CONT_INFORMATION13  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION13')
      --
      ,P_CONT_INFORMATION14  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION14')
      --
      ,P_CONT_INFORMATION15  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION15')
      --
      ,P_CONT_INFORMATION16  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION16')
      --
      ,P_CONT_INFORMATION17  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION17')
      --
      ,P_CONT_INFORMATION18  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION18')
      --
      ,P_CONT_INFORMATION19  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION19')
      --
      ,P_CONT_INFORMATION20  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION20')
     );

    end if; -- end if of skip_contact_create_flg --- 5894873

    else

   -- if primary contact flag is checked apply it emrg record and not for
   -- other personal relationship record

   if (l_contact_operation = 'EMRG_OVRW_UPD' and (l_primary_contact_flag = 'Y' or
       l_primary_contact_flag = 'N')) then
    open get_emrg_relid_ovn(
            hr_transaction_api.get_NUMBER_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONTACT_RELATIONSHIP_ID')
           ,hr_transaction_api.get_number_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 => 'P_CONTACT_PERSON_ID')
           ,hr_transaction_api.get_number_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 => 'P_PERSON_ID'));
-- Bug 3469145 : updating the primary cont flag if it has changed.
-- Bug 3504216 :  passing date_start as sysdate
    fetch get_emrg_relid_ovn into l_emrg_relid, l_emrg_ovn, l_emrg_primary_cont_flag;
    if get_emrg_relid_ovn%found then
     if((l_emrg_primary_cont_flag <> 'Y' and l_primary_contact_flag = 'Y') OR
        (l_emrg_primary_cont_flag <> 'N' and l_primary_contact_flag = 'N')) then
        hr_contact_rel_api.update_contact_relationship(
         p_validate                => p_validate
        ,P_EFFECTIVE_DATE          =>l_effective_date
        ,p_object_version_number   => l_emrg_ovn
        ,P_CONTACT_RELATIONSHIP_ID => l_emrg_relid
        ,P_PRIMARY_CONTACT_FLAG    => l_primary_contact_flag
	,P_DATE_START              => sysdate
       );
     end if;
     l_primary_contact_flag := 'N';
    end if;
    close get_emrg_relid_ovn;
   end if;

    hr_contact_rel_api.update_contact_relationship(

      P_VALIDATE  =>  p_validate
      --
      ,P_EFFECTIVE_DATE  =>  l_effective_date
         /* SFL changes
         hr_transaction_api.get_DATE_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'p_cont_EFFECTIVE_DATE')
         */
      --
      ,P_CONTACT_RELATIONSHIP_ID  =>
         hr_transaction_api.get_NUMBER_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONTACT_RELATIONSHIP_ID')
      --
      ,P_CONTACT_TYPE  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONTACT_TYPE')
      --

      ,P_COMMENTS  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CTR_COMMENTS')
      --
 -- Bug 3617667 : Not passign Primary Cont flag.Its only availaible in Emerg region.
 --     ,P_PRIMARY_CONTACT_FLAG  => l_primary_contact_flag
      --
      ,P_THIRD_PARTY_PAY_FLAG  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_THIRD_PARTY_PAY_FLAG')
      --
      ,P_BONDHOLDER_FLAG  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_BONDHOLDER_FLAG')
      --
      ,P_DATE_START  =>
         hr_transaction_api.get_DATE_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_DATE_START')
      --
      ,P_START_LIFE_REASON_ID  =>
         hr_transaction_api.get_NUMBER_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_START_LIFE_REASON_ID')
      --
      ,P_DATE_END  =>
         hr_transaction_api.get_DATE_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_DATE_END')
      --
      ,P_END_LIFE_REASON_ID  =>
         hr_transaction_api.get_NUMBER_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_END_LIFE_REASON_ID')
      --
      ,P_RLTD_PER_RSDS_W_DSGNTR_FLAG  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_RLTD_PER_RSDS_W_DSGNTR_FLAG')
      --
      ,P_PERSONAL_FLAG  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PERSONAL_FLAG')
      --
   /*   ,P_SEQUENCE_NUMBER  =>
         hr_transaction_api.get_NUMBER_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_SEQUENCE_NUMBER') */

      --
      ,P_DEPENDENT_FLAG  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_DEPENDENT_FLAG')
      --
      ,P_BENEFICIARY_FLAG  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_BENEFICIARY_FLAG')
      --
      ,P_CONT_ATTRIBUTE_CATEGORY  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE_CATEGORY')
      --
      ,P_CONT_ATTRIBUTE1  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE1')
      --
      ,P_CONT_ATTRIBUTE2  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE2')
      --
      ,P_CONT_ATTRIBUTE3  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE3')
      --
      ,P_CONT_ATTRIBUTE4  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE4')
      --
      ,P_CONT_ATTRIBUTE5  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE5')
      --
      ,P_CONT_ATTRIBUTE6  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE6')
      --
      ,P_CONT_ATTRIBUTE7  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE7')
      --
      ,P_CONT_ATTRIBUTE8  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE8')
      --
      ,P_CONT_ATTRIBUTE9  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE9')
      --
      ,P_CONT_ATTRIBUTE10  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE10')
      --
      ,P_CONT_ATTRIBUTE11  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE11')
      --
      ,P_CONT_ATTRIBUTE12  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE12')
      --
      ,P_CONT_ATTRIBUTE13  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE13')
      --
      ,P_CONT_ATTRIBUTE14  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE14')
      --
      ,P_CONT_ATTRIBUTE15  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE15')
      --
      ,P_CONT_ATTRIBUTE16  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE16')
      --
      ,P_CONT_ATTRIBUTE17  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE17')
      --
      ,P_CONT_ATTRIBUTE18  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE18')
      --
      ,P_CONT_ATTRIBUTE19  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE19')
      --
      ,P_CONT_ATTRIBUTE20  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE20')
      --
      ,P_CONT_INFORMATION_CATEGORY  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION_CATEGORY')
      --
      ,P_CONT_INFORMATION1  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION1')
      --
      ,P_CONT_INFORMATION2  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION2')
      --
      ,P_CONT_INFORMATION3  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION3')
      --
      ,P_CONT_INFORMATION4  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION4')
      --
      ,P_CONT_INFORMATION5  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION5')
      --
      ,P_CONT_INFORMATION6  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION6')
      --
      ,P_CONT_INFORMATION7  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION7')
      --
      ,P_CONT_INFORMATION8  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION8')
      --
      ,P_CONT_INFORMATION9  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION9')
      --
      ,P_CONT_INFORMATION10  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION10')
      --
      ,P_CONT_INFORMATION11  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION11')
      --
      ,P_CONT_INFORMATION12  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION12')
      --
      ,P_CONT_INFORMATION13  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION13')
      --
      ,P_CONT_INFORMATION14  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION14')
      --
      ,P_CONT_INFORMATION15  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION15')
      --
      ,P_CONT_INFORMATION16  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION16')
      --
      ,P_CONT_INFORMATION17  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION17')
      --
      ,P_CONT_INFORMATION18  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION18')
      --
      ,P_CONT_INFORMATION19  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION19')
      --
      ,P_CONT_INFORMATION20  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION20')
      --
      ,P_OBJECT_VERSION_NUMBER  =>  l_ovn
      --
    );
  end if;
  ELSE
    --
    l_contact_type :=
       hr_transaction_api.get_VARCHAR2_value
         (p_transaction_step_id => p_transaction_step_id
          ,p_name                => 'P_CONTACT_TYPE') ;

    --
    l_personal_flag :=
       hr_transaction_api.get_VARCHAR2_value
          (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PERSONAL_FLAG') ;
    --
    if l_contact_operation = 'EMER_CR_NEW_REL' then
      --
      l_contact_type := 'EMRG' ;
      l_personal_flag:= 'N' ;
      --
    else
      --
      l_personal_flag := 'Y' ;
      --
    end if;
    --
    if  l_contact_operation in ( 'EMER_CR_NEW_REL', 'DPDNT_CR_NEW_REL') then
        --

	open get_other_relid_ovn(
            hr_transaction_api.get_number_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 => 'P_CONTACT_PERSON_ID')
           ,hr_transaction_api.get_number_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 => 'P_PERSON_ID'));
    fetch get_other_relid_ovn into l_other_relid, l_other_ovn;
    if get_other_relid_ovn%found then
         hr_contact_rel_api.update_contact_relationship(

      P_VALIDATE  =>  p_validate
      --
      ,P_EFFECTIVE_DATE  =>  l_effective_date

      ,P_CONTACT_RELATIONSHIP_ID  =>     l_other_relid
      --
      ,P_CONTACT_TYPE  =>
            hr_transaction_api.get_VARCHAR2_value
                (p_transaction_step_id => p_transaction_step_id
                ,p_name                => 'P_CONTACT_TYPE')
      --
      ,P_COMMENTS  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CTR_COMMENTS')

      ,P_THIRD_PARTY_PAY_FLAG  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_THIRD_PARTY_PAY_FLAG')
      --
      ,P_BONDHOLDER_FLAG  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_BONDHOLDER_FLAG')
      --
      ,P_DATE_START  =>
         hr_transaction_api.get_DATE_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_DATE_START')
      --
     -- bug 4775133 ,P_START_LIFE_REASON_ID  =>
       --  hr_transaction_api.get_NUMBER_value
       --    (p_transaction_step_id => p_transaction_step_id
       --    ,p_name                => 'P_START_LIFE_REASON_ID')
      --
      ,P_DATE_END  =>
         hr_transaction_api.get_DATE_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_DATE_END')
      --
      ,P_END_LIFE_REASON_ID  =>
         hr_transaction_api.get_NUMBER_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_END_LIFE_REASON_ID')
      --
      ,P_RLTD_PER_RSDS_W_DSGNTR_FLAG  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_RLTD_PER_RSDS_W_DSGNTR_FLAG')
      --
      ,P_PERSONAL_FLAG  => 'Y'
      --
      ,P_DEPENDENT_FLAG  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_DEPENDENT_FLAG')
      --
      ,P_BENEFICIARY_FLAG  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_BENEFICIARY_FLAG')
      --
      ,P_CONT_ATTRIBUTE_CATEGORY  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE_CATEGORY')
      --
      ,P_CONT_ATTRIBUTE1  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE1')
      --
      ,P_CONT_ATTRIBUTE2  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE2')
      --
      ,P_CONT_ATTRIBUTE3  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE3')
      --
      ,P_CONT_ATTRIBUTE4  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE4')
      --
      ,P_CONT_ATTRIBUTE5  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE5')
      --
      ,P_CONT_ATTRIBUTE6  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE6')
      --
      ,P_CONT_ATTRIBUTE7  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE7')
      --
      ,P_CONT_ATTRIBUTE8  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE8')
      --
      ,P_CONT_ATTRIBUTE9  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE9')
      --
      ,P_CONT_ATTRIBUTE10  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE10')
      --
      ,P_CONT_ATTRIBUTE11  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE11')
      --
      ,P_CONT_ATTRIBUTE12  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE12')
      --
      ,P_CONT_ATTRIBUTE13  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE13')
      --
      ,P_CONT_ATTRIBUTE14  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE14')
      --
      ,P_CONT_ATTRIBUTE15  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE15')
      --
      ,P_CONT_ATTRIBUTE16  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE16')
      --
      ,P_CONT_ATTRIBUTE17  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE17')
      --
      ,P_CONT_ATTRIBUTE18  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE18')
      --
      ,P_CONT_ATTRIBUTE19  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE19')
      --
      ,P_CONT_ATTRIBUTE20  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_ATTRIBUTE20')
      --
      ,P_CONT_INFORMATION_CATEGORY  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION_CATEGORY')
      --
      ,P_CONT_INFORMATION1  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION1')
      --
      ,P_CONT_INFORMATION2  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION2')
      --
      ,P_CONT_INFORMATION3  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION3')
      --
      ,P_CONT_INFORMATION4  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION4')
      --
      ,P_CONT_INFORMATION5  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION5')
      --
      ,P_CONT_INFORMATION6  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION6')
      --
      ,P_CONT_INFORMATION7  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION7')
      --
      ,P_CONT_INFORMATION8  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION8')
      --
      ,P_CONT_INFORMATION9  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION9')
      --
      ,P_CONT_INFORMATION10  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION10')
      --
      ,P_CONT_INFORMATION11  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION11')
      --
      ,P_CONT_INFORMATION12  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION12')
      --
      ,P_CONT_INFORMATION13  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION13')
      --
      ,P_CONT_INFORMATION14  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION14')
      --
      ,P_CONT_INFORMATION15  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION15')
      --
      ,P_CONT_INFORMATION16  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION16')
      --
      ,P_CONT_INFORMATION17  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION17')
      --
      ,P_CONT_INFORMATION18  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION18')
      --
      ,P_CONT_INFORMATION19  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION19')
      --
      ,P_CONT_INFORMATION20  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION20')
      --
      ,P_OBJECT_VERSION_NUMBER  =>  l_other_ovn
      --
    );
    end if;
      close get_other_relid_ovn;

         hr_contact_rel_api.create_contact(
          P_VALIDATE  => p_validate
          --
          ,P_START_DATE  =>          l_effective_date
             /*
             hr_transaction_api.get_DATE_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_CONT_EFFECTIVE_DATE')
             */
          --
          ,P_BUSINESS_GROUP_ID  =>
             hr_transaction_api.get_NUMBER_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_BUSINESS_GROUP_ID')
          --
          ,P_PERSON_ID  =>
              hr_transaction_api.get_number_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_person_id'))
          --
          ,P_CONTACT_PERSON_ID  =>
              hr_transaction_api.get_number_value
                 (p_transaction_step_id   => p_transaction_step_id
                  ,p_name                 =>upper('p_cont_person_id'))
          --
          ,P_CONTACT_TYPE  => l_contact_type
          --
          ,P_CTR_COMMENTS  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_CTR_COMMENTS')
          --
          ,P_PRIMARY_CONTACT_FLAG  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_PRIMARY_CONTACT_FLAG')
          --
          ,P_DATE_START  =>
             hr_transaction_api.get_DATE_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_DATE_START')
          --
          ,P_START_LIFE_REASON_ID  =>
             hr_transaction_api.get_NUMBER_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_START_LIFE_REASON_ID')
          --
          ,P_DATE_END  =>
             hr_transaction_api.get_DATE_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_DATE_END')
          --
          ,P_END_LIFE_REASON_ID  =>
             hr_transaction_api.get_NUMBER_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_END_LIFE_REASON_ID')
          --
          ,P_RLTD_PER_RSDS_W_DSGNTR_FLAG  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_RLTD_PER_RSDS_W_DSGNTR_FLAG')
          --
          ,P_PERSONAL_FLAG  =>  l_personal_flag
          --
          ,P_SEQUENCE_NUMBER  =>
             hr_transaction_api.get_NUMBER_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_SEQUENCE_NUMBER')
          --
          ,P_CONT_ATTRIBUTE_CATEGORY  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_CONT_ATTRIBUTE_CATEGORY')
          --
          ,P_CONT_ATTRIBUTE1  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_CONT_ATTRIBUTE1')
          --
          ,P_CONT_ATTRIBUTE2  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_CONT_ATTRIBUTE2')
          --
          ,P_CONT_ATTRIBUTE3  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_CONT_ATTRIBUTE3')
          --
          ,P_CONT_ATTRIBUTE4  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_CONT_ATTRIBUTE4')
          --
          ,P_CONT_ATTRIBUTE5  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_CONT_ATTRIBUTE5')
          --
          ,P_CONT_ATTRIBUTE6  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_CONT_ATTRIBUTE6')
          --
          ,P_CONT_ATTRIBUTE7  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_CONT_ATTRIBUTE7')
          --
          ,P_CONT_ATTRIBUTE8  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_CONT_ATTRIBUTE8')
          --
          ,P_CONT_ATTRIBUTE9  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_CONT_ATTRIBUTE9')
          --
          ,P_CONT_ATTRIBUTE10  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_CONT_ATTRIBUTE10')
          --
          ,P_CONT_ATTRIBUTE11  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_CONT_ATTRIBUTE11')
          --
          ,P_CONT_ATTRIBUTE12  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_CONT_ATTRIBUTE12')
          --
          ,P_CONT_ATTRIBUTE13  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_CONT_ATTRIBUTE13')
          --
          ,P_CONT_ATTRIBUTE14  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_CONT_ATTRIBUTE14')
          --
          ,P_CONT_ATTRIBUTE15  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_CONT_ATTRIBUTE15')
          --
          ,P_CONT_ATTRIBUTE16  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_CONT_ATTRIBUTE16')
          --
          ,P_CONT_ATTRIBUTE17  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_CONT_ATTRIBUTE17')
          --
          ,P_CONT_ATTRIBUTE18  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_CONT_ATTRIBUTE18')
          --
          ,P_CONT_ATTRIBUTE19  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_CONT_ATTRIBUTE19')
          --
          ,P_CONT_ATTRIBUTE20  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_CONT_ATTRIBUTE20')
          --
          ,P_THIRD_PARTY_PAY_FLAG  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_THIRD_PARTY_PAY_FLAG')
          --
          ,P_BONDHOLDER_FLAG  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_BONDHOLDER_FLAG')
          --
          ,P_DEPENDENT_FLAG  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_DEPENDENT_FLAG')
          --
          ,P_BENEFICIARY_FLAG  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_BENEFICIARY_FLAG')
          --
          ,P_CREATE_MIRROR_FLAG  =>  'N' -- Change later get from txn tables.
          --
          ,P_MIRROR_TYPE  => null
          --
          ,P_MIRROR_CONT_ATTRIBUTE_CAT  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE_CAT')
          --
          ,P_MIRROR_CONT_ATTRIBUTE1  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE1')
          --
          ,P_MIRROR_CONT_ATTRIBUTE2  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE2')
          --
          ,P_MIRROR_CONT_ATTRIBUTE3  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE3')
          --
          ,P_MIRROR_CONT_ATTRIBUTE4  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE4')
          --
          ,P_MIRROR_CONT_ATTRIBUTE5  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE5')
          --
          ,P_MIRROR_CONT_ATTRIBUTE6  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE6')
          --
          ,P_MIRROR_CONT_ATTRIBUTE7  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE7')
          --
          ,P_MIRROR_CONT_ATTRIBUTE8  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE8')
          --
          ,P_MIRROR_CONT_ATTRIBUTE9  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE9')
          --
          ,P_MIRROR_CONT_ATTRIBUTE10  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE10')
          --
          ,P_MIRROR_CONT_ATTRIBUTE11  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE11')
          --
          ,P_MIRROR_CONT_ATTRIBUTE12  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE12')
          --
          ,P_MIRROR_CONT_ATTRIBUTE13  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE13')
          --
          ,P_MIRROR_CONT_ATTRIBUTE14  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE14')
          --
          ,P_MIRROR_CONT_ATTRIBUTE15  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE15')
          --
          ,P_MIRROR_CONT_ATTRIBUTE16  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE16')
          --
          ,P_MIRROR_CONT_ATTRIBUTE17  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE17')
          --
          ,P_MIRROR_CONT_ATTRIBUTE18  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE18')
          --
          ,P_MIRROR_CONT_ATTRIBUTE19  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE19')
          --
          ,P_MIRROR_CONT_ATTRIBUTE20  =>
             hr_transaction_api.get_VARCHAR2_value
               (p_transaction_step_id => p_transaction_step_id
               ,p_name                => 'P_MIRROR_CONT_ATTRIBUTE20')
          --

          ,P_CONTACT_RELATIONSHIP_ID  	=> L_CONTACT_RELATIONSHIP_ID1
          --
          ,P_CTR_OBJECT_VERSION_NUMBER 	=> L_CTR_OBJECT_VERSION_NUMBER1
          --
          ,P_PER_PERSON_ID  		=> L_PER_PERSON_ID1
          --
          ,P_PER_OBJECT_VERSION_NUMBER 	=> L_PER_OBJECT_VERSION_NUMBER1
          --
          ,P_PER_EFFECTIVE_START_DATE  	=> L_PER_EFFECTIVE_START_DATE1
          --
          ,P_PER_EFFECTIVE_END_DATE  	=> L_PER_EFFECTIVE_END_DATE1
          --
          ,P_FULL_NAME  		=> L_FULL_NAME1
          --
          ,P_PER_COMMENT_ID  		=> L_PER_COMMENT_ID1
          --
          ,P_NAME_COMBINATION_WARNING  	=> L_CON_NAME_COMBINATION_WARNIN1
          --
          ,P_ORIG_HIRE_WARNING  	=> L_CON_ORIG_HIRE_WARNING1
          --
          ,P_CONT_INFORMATION_CATEGORY  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION_CATEGORY')
      --
      ,P_CONT_INFORMATION1  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION1')
      --
      ,P_CONT_INFORMATION2  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION2')
      --
      ,P_CONT_INFORMATION3  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION3')
      --
      ,P_CONT_INFORMATION4  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION4')
      --
      ,P_CONT_INFORMATION5  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION5')
      --
      ,P_CONT_INFORMATION6  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION6')
      --
      ,P_CONT_INFORMATION7  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION7')
      --
      ,P_CONT_INFORMATION8  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION8')
      --
      ,P_CONT_INFORMATION9  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION9')
      --
      ,P_CONT_INFORMATION10  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION10')
      --
      ,P_CONT_INFORMATION11  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION11')
      --
      ,P_CONT_INFORMATION12  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION12')
      --
      ,P_CONT_INFORMATION13  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION13')
      --
      ,P_CONT_INFORMATION14  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION14')
      --
      ,P_CONT_INFORMATION15  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION15')
      --
      ,P_CONT_INFORMATION16  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION16')
      --
      ,P_CONT_INFORMATION17  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION17')
      --
      ,P_CONT_INFORMATION18  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION18')
      --
      ,P_CONT_INFORMATION19  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION19')
      --
      ,P_CONT_INFORMATION20  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONT_INFORMATION20')
         );
         --
    end if;
    --
  END IF;

  --
  IF p_validate THEN
     hr_utility.set_location('Rollback hr_process_contact_ss.process_api', 100);
     ROLLBACK TO update_cont_relationship;
  END IF;
  --
  -- bug# 2080032
  end if; -- l_process_section = 'DELETE_CONTACTS'

  hr_utility.set_location('Leaving hr_process_contact_ss.process_api', 100);
  --
EXCEPTION
  WHEN hr_utility.hr_error THEN
  hr_utility.set_location('Exception:  WHEN hr_utility.hr_error THEN'||l_proc,555);
    -- -----------------------------------------------------------------
    -- An application error has been raised by the API so we must set
    -- the error.
    -- -----------------------------------------------------------------
    ROLLBACK TO update_cont_relationship;
    RAISE;
    --
END process_api;
--
 --
-- bug 5652542
-- In same transaction if we update both the contact and his address details and also change the relationship start date to a lower value
-- per_people12_pkg updates the contact's person and address data. This changes the ovn and hence error. Contact's person data was
-- taken care by calling person api before contact api. But address issue is fixed with below code. This checks for the conditions when address
-- could have been updated and sets the global variable. Address api checks for this variable and increases the ovn by 1 if it is true.

procedure is_address_updated
  (P_CONTACT_RELATIONSHIP_ID in number
            ,P_DATE_START  in date
            ,p_transaction_step_id IN NUMBER
            ,p_contact_person_id in number
            ,p_person_id in number) is
  l_date_start   date := hr_api.g_date;
  l_pds_date_start date;
  l_cont_start_date date;
  l_proc   varchar2(72)  := g_package||'will_address_be_changed';
  l_cov_date_start date;
  l_dummy varchar2(10);
  cursor csr_address(c_person_id number, c_date_from date) is
    select 'Y'
    from per_addresses
    where person_id = c_person_id
    and date_from = c_date_from
    and primary_flag='Y';

  cursor csr_contact_api(c_transaction_step_id number) is
    select 'Y' from hr_api_transaction_steps where transaction_id =
    (select transaction_id from hr_api_transaction_steps where transaction_step_id =
    c_transaction_step_id) and api_name='HR_PROCESS_ADDRESS_SS.PROCESS_API';

begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  open csr_contact_api(p_transaction_step_id);
  fetch csr_contact_api into l_dummy;
  if csr_contact_api%found then
    if p_contact_relationship_id is not null then
      select date_start into l_date_start from per_contact_relationships where
      contact_relationship_id = p_contact_relationship_id;
    end if;
    if (p_date_start < l_date_start or l_date_start = hr_api.g_date) then
      select max(date_start) into l_pds_date_start from per_periods_of_service
      where person_id = p_person_id;
        if l_pds_date_start > p_date_start then
          l_cov_date_start := l_pds_date_start;
        else
          l_cov_date_start := p_date_start;
        end if;
        select min(effective_start_date) into l_cont_start_date from per_all_people_f
        where person_id=p_contact_person_id;
        if (l_cov_date_start < l_cont_start_date) then
          open csr_address(p_contact_person_id,l_cont_start_date);
          fetch csr_address into l_dummy;
          if csr_address%found then
            hr_process_contact_ss.g_is_address_updated := true;
          end if;
          close csr_address;
        end if;
    end if;
  end if;
  close csr_contact_api;
  hr_utility.set_location('Leaving:'||l_proc, 20);

end is_address_updated;

  /*
  ||===========================================================================
  || PROCEDURE: end_contact_relationship
  ||---------------------------------------------------------------------------
  ||
  || Description:
  || Description:
  ||     This procedure will call the actual API -
  ||                hr_contact_rel_api.update_contact_relationship()
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||     Contains entire list of parameters that are defined in the actual
  ||     API. For details see peaddapi.pkb file.
  ||
  || out nocopy Arguments:
  ||
  || In out nocopy Arguments:
  ||
  || Post Success:
  ||     Executes the API call.
  ||
  || Post Failure:
  ||     Raises an exception
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */

PROCEDURE end_contact_relationship
  (p_validate                      in        number  default 0
  ,p_effective_date                in        date
  ,p_contact_relationship_id       in        number
  ,p_contact_type                  in        varchar2  default hr_api.g_varchar2
  ,p_comments                      in        long      default hr_api.g_varchar2
  ,p_primary_contact_flag          in        varchar2  default hr_api.g_varchar2
  ,p_third_party_pay_flag          in        varchar2  default hr_api.g_varchar2
  ,p_bondholder_flag               in        varchar2  default hr_api.g_varchar2
  ,p_date_start                    in        date      default hr_api.g_date
  ,p_start_life_reason_id          in        number    default hr_api.g_number
  ,p_date_end                      in        date      default hr_api.g_date
  ,p_end_life_reason_id            in        number    default hr_api.g_number
  ,p_rltd_per_rsds_w_dsgntr_flag   in        varchar2  default hr_api.g_varchar2
  ,p_personal_flag                 in        varchar2  default hr_api.g_varchar2
  ,p_sequence_number               in        number    default hr_api.g_number
  ,p_dependent_flag                in        varchar2  default hr_api.g_varchar2
  ,p_beneficiary_flag              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute_category       in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute1               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute2               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute3               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute4               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute5               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute6               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute7               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute8               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute9               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute10              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute11              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute12              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute13              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute14              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute15              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute16              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute17              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute18              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute19              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute20              in        varchar2  default hr_api.g_varchar2
  ,p_person_id                     in        number
  ,p_object_version_number         in out nocopy    number
  ,p_item_type                     in        varchar2
  ,p_item_key                      in        varchar2
  ,p_activity_id                   in        number
  ,p_action                        in        varchar2
  ,p_process_section_name          in        varchar2
  ,p_review_page_region_code       in        varchar2 default hr_api.g_varchar2
  ,p_save_mode                     in        varchar2  default null
 -- SFL needs it bug #2082333
  ,p_login_person_id               in        number
  ,p_contact_person_id             in        number
  -- Bug 2723267
  ,p_contact_operation             in        varchar2
  -- Bug 3152505
  ,p_end_other_rel                 in        varchar2
  ,p_other_rel_id                  in        number
 ) IS
  --

   cursor get_other_rel_ovn(p_contact_relationship_id  number)
   is
	select object_version_number
	from per_contact_relationships
	where contact_relationship_id = p_contact_relationship_id
	and trunc(sysdate) between nvl(date_start, trunc(sysdate))
	and nvl(date_end, trunc(sysdate));

  l_transaction_table            hr_transaction_ss.transaction_table;
  l_transaction_step_id          hr_api_transaction_steps.transaction_step_id%type;
  l_trs_object_version_number    hr_api_transaction_steps.object_version_number%type;
  l_old_ovn                      number;
  l_old_contact_relationship_id  number;
  l_count                        INTEGER := 0;
  l_transaction_id             number default null;
  l_trans_obj_vers_num         number default null;
  l_result                     varchar2(100) default null;
  l_end_life_reason            varchar2(100) default null;

  l_other_rel_object_ver_no    number;
  l_proc   varchar2(72)  := g_package||'end_contact_relationship';
  --
 BEGIN
  --


  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_old_ovn := p_object_version_number;
  l_old_contact_relationship_id := p_contact_relationship_id;
  if(p_contact_operation = 'EMRG_OVRW_DEL' and p_other_rel_id is not null and p_other_rel_id <> -1 ) then
     l_old_contact_relationship_id := p_other_rel_id;
  end if;

  --
  -- Call the actual API.
  --
  hr_utility.set_location('Calling hr_contact_rel_api.update_contact_relationship', 10);
  --
  if nvl(p_save_mode, 'NVL') <> 'SAVE_FOR_LATER' then
     --
     hr_contact_rel_api.update_contact_relationship(
        p_validate                          =>  hr_java_conv_util_ss.get_boolean (
                                                    p_number => p_validate)
       ,p_effective_date                    => p_effective_date
       ,p_contact_relationship_id           => p_contact_relationship_id
       ,p_contact_type                      => p_contact_type
       ,p_comments                          => p_comments
       ,p_primary_contact_flag              => p_primary_contact_flag
       ,p_third_party_pay_flag              => p_third_party_pay_flag
       ,p_bondholder_flag                   => p_bondholder_flag
       ,p_date_start                        => p_date_start
       ,p_start_life_reason_id              => p_start_life_reason_id
       ,p_date_end                          => p_date_end
       ,p_end_life_reason_id                => p_end_life_reason_id
       ,p_rltd_per_rsds_w_dsgntr_flag       => p_rltd_per_rsds_w_dsgntr_flag
       ,p_personal_flag                     => p_personal_flag
       ,p_sequence_number                   => p_sequence_number
       ,p_dependent_flag                    => p_dependent_flag
       ,p_beneficiary_flag                  => p_beneficiary_flag
       ,p_cont_attribute_category           => p_cont_attribute_category
       ,p_cont_attribute1                   => p_cont_attribute1
       ,p_cont_attribute2                   => p_cont_attribute2
       ,p_cont_attribute3                   => p_cont_attribute3
       ,p_cont_attribute4                   => p_cont_attribute4
       ,p_cont_attribute5                   => p_cont_attribute5
       ,p_cont_attribute6                   => p_cont_attribute6
       ,p_cont_attribute7                   => p_cont_attribute7
       ,p_cont_attribute8                   => p_cont_attribute8
       ,p_cont_attribute9                   => p_cont_attribute9
       ,p_cont_attribute10                  => p_cont_attribute10
       ,p_cont_attribute11                  => p_cont_attribute11
       ,p_cont_attribute12                  => p_cont_attribute12
       ,p_cont_attribute13                  => p_cont_attribute13
       ,p_cont_attribute14                  => p_cont_attribute14
       ,p_cont_attribute15                  => p_cont_attribute15
       ,p_cont_attribute16                  => p_cont_attribute16
       ,p_cont_attribute17                  => p_cont_attribute17
       ,p_cont_attribute18                  => p_cont_attribute18
       ,p_cont_attribute19                  => p_cont_attribute19
       ,p_cont_attribute20                  => p_cont_attribute20
       ,p_object_version_number             => p_object_version_number
     );

     if p_end_other_rel = 'Y' then
      hr_utility.set_location('Fecthing l_other_rel_object_ver_no:'||l_proc, 15);
      open get_other_rel_ovn(p_other_rel_id);
      fetch get_other_rel_ovn into l_other_rel_object_ver_no;
      if get_other_rel_ovn%notfound then
         l_other_rel_object_ver_no := 1;
      end if;
      close get_other_rel_ovn;

      hr_contact_rel_api.update_contact_relationship(
        p_validate                          =>  hr_java_conv_util_ss.get_boolean (
                                                    p_number => p_validate)
       ,p_effective_date                    => p_effective_date
-- Bug 3152505 : Passing the other contact relationship id
       ,p_contact_relationship_id           => p_other_rel_id
       ,p_contact_type                      => p_contact_type
       ,p_comments                          => p_comments
       ,p_primary_contact_flag              => p_primary_contact_flag
       ,p_third_party_pay_flag              => p_third_party_pay_flag
       ,p_bondholder_flag                   => p_bondholder_flag
       ,p_date_start                        => p_date_start
       ,p_start_life_reason_id              => p_start_life_reason_id
       ,p_date_end                          => p_date_end
       ,p_end_life_reason_id                => p_end_life_reason_id
       ,p_rltd_per_rsds_w_dsgntr_flag       => p_rltd_per_rsds_w_dsgntr_flag
       ,p_personal_flag                     => p_personal_flag
       ,p_sequence_number                   => p_sequence_number
       ,p_dependent_flag                    => p_dependent_flag
       ,p_beneficiary_flag                  => p_beneficiary_flag
       ,p_cont_attribute_category           => p_cont_attribute_category
       ,p_cont_attribute1                   => p_cont_attribute1
       ,p_cont_attribute2                   => p_cont_attribute2
       ,p_cont_attribute3                   => p_cont_attribute3
       ,p_cont_attribute4                   => p_cont_attribute4
       ,p_cont_attribute5                   => p_cont_attribute5
       ,p_cont_attribute6                   => p_cont_attribute6
       ,p_cont_attribute7                   => p_cont_attribute7
       ,p_cont_attribute8                   => p_cont_attribute8
       ,p_cont_attribute9                   => p_cont_attribute9
       ,p_cont_attribute10                  => p_cont_attribute10
       ,p_cont_attribute11                  => p_cont_attribute11
       ,p_cont_attribute12                  => p_cont_attribute12
       ,p_cont_attribute13                  => p_cont_attribute13
       ,p_cont_attribute14                  => p_cont_attribute14
       ,p_cont_attribute15                  => p_cont_attribute15
       ,p_cont_attribute16                  => p_cont_attribute16
       ,p_cont_attribute17                  => p_cont_attribute17
       ,p_cont_attribute18                  => p_cont_attribute18
       ,p_cont_attribute19                  => p_cont_attribute19
       ,p_cont_attribute20                  => p_cont_attribute20
       ,p_object_version_number             => l_other_rel_object_ver_no
     );
    end if;
     --
  end if;
  --
  -- --------------------------------------------------------------------------
  -- We will write the data to transaction tables.
  -- Determine if a transaction step exists for this activity
  -- if a transaction step does exist then the transaction_step_id and
  -- object_version_number are set (i.e. not null).
  -- --------------------------------------------------------------------------
  hr_utility.set_location('Call :get_transaction_step_info'||l_proc, 20);
  hr_transaction_api.get_transaction_step_info
                (p_item_type             => p_item_type
                ,p_item_key              => p_item_key
                ,p_activity_id           => p_activity_id
                ,p_transaction_step_id   => l_transaction_step_id
                ,p_object_version_number => l_trs_object_version_number);
  --
  hr_utility.set_location('l_transaction_step_id = ' || to_char(l_transaction_step_id), 25);
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_EFFECTIVE_DATE';
  l_transaction_table(l_count).param_value := to_char(P_EFFECTIVE_DATE,
                                              hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
  --
  l_count:=l_count+1;
  l_transaction_table(l_count).param_name      := 'P_SAVE_MODE';
  l_transaction_table(l_count).param_value     :=  p_save_mode;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  -- SFL changes bug #2082333
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PERSON_ID';
  l_transaction_table(l_count).param_value := p_person_id;
  l_transaction_table(l_count).param_data_type := 'NUMBER';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_LOGIN_PERSON_ID';
  l_transaction_table(l_count).param_value := p_login_person_id;
  l_transaction_table(l_count).param_data_type := 'NUMBER';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_CONTACT_PERSON_ID';
  l_transaction_table(l_count).param_value := p_contact_person_id;
  l_transaction_table(l_count).param_data_type := 'NUMBER';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :='P_ITEM_TYPE';
  l_transaction_table(l_count).param_value := p_item_type;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
  --
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name :='P_ITEM_KEY';
  l_transaction_table(l_count).param_value := p_item_key;
  l_transaction_table(l_count).param_data_type := upper('varchar2');
-- End SFL changes bug #2082333
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_OLD_OBJECT_VERSION_NUMBER';
  l_transaction_table(l_count).param_value := l_old_ovn;
  l_transaction_table(l_count).param_data_type := 'NUMBER';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_CONTACT_RELATIONSHIP_ID';
  l_transaction_table(l_count).param_value := P_CONTACT_RELATIONSHIP_ID;
  l_transaction_table(l_count).param_data_type := 'NUMBER';
  --
  -- 9999 What does this do
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_OLD_CONTACT_RELATIONSHIP_ID';
  l_transaction_table(l_count).param_value := l_OLD_CONTACT_RELATIONSHIP_ID;
  l_transaction_table(l_count).param_data_type := 'NUMBER';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_CONTACT_TYPE';
  l_transaction_table(l_count).param_value := P_CONTACT_TYPE;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_COMMENTS';
  l_transaction_table(l_count).param_value := P_COMMENTS;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PRIMARY_CONTACT_FLAG';
  l_transaction_table(l_count).param_value := P_PRIMARY_CONTACT_FLAG;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_THIRD_PARTY_PAY_FLAG';
  l_transaction_table(l_count).param_value := P_THIRD_PARTY_PAY_FLAG;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_BONDHOLDER_FLAG';
  l_transaction_table(l_count).param_value := P_BONDHOLDER_FLAG;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_DATE_START';
  l_transaction_table(l_count).param_value := to_char(P_DATE_START,
                                              hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_START_LIFE_REASON_ID';
  l_transaction_table(l_count).param_value := P_START_LIFE_REASON_ID;
  l_transaction_table(l_count).param_data_type := 'NUMBER';
  --
  hr_utility.set_location('P_DATE_END = ' || to_char(P_DATE_END), 30);
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_DATE_END';
  l_transaction_table(l_count).param_value := to_char(P_DATE_END,
                                              hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_END_LIFE_REASON_ID';
  l_transaction_table(l_count).param_value := P_END_LIFE_REASON_ID;
  l_transaction_table(l_count).param_data_type := 'NUMBER';
 --
 -- bug # 2080032
  if P_END_LIFE_REASON_ID IS NOT NULL THEN

    select   max(BLF.NAME) End_Relation_Reason
    into l_end_life_reason
    from BEN_LER_F BLF
    where BLF.LER_ID = P_END_LIFE_REASON_ID;

   end if;

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_END_LIFE_REASON';
  l_transaction_table(l_count).param_value := l_end_life_reason;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_RLTD_PER_RSDS_W_DSGNTR_FLAG';
  l_transaction_table(l_count).param_value := P_RLTD_PER_RSDS_W_DSGNTR_FLAG;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PERSONAL_FLAG';
  l_transaction_table(l_count).param_value := P_PERSONAL_FLAG;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_SEQUENCE_NUMBER';
  l_transaction_table(l_count).param_value := P_SEQUENCE_NUMBER;
  l_transaction_table(l_count).param_data_type := 'NUMBER';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_DEPENDENT_FLAG';
  l_transaction_table(l_count).param_value := P_DEPENDENT_FLAG;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_BENEFICIARY_FLAG';
  l_transaction_table(l_count).param_value := P_BENEFICIARY_FLAG;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_CONT_ATTRIBUTE_CATEGORY';
  l_transaction_table(l_count).param_value := P_CONT_ATTRIBUTE_CATEGORY;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_CONT_ATTRIBUTE1';
  l_transaction_table(l_count).param_value := P_CONT_ATTRIBUTE1;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_CONT_ATTRIBUTE2';
  l_transaction_table(l_count).param_value := P_CONT_ATTRIBUTE2;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_CONT_ATTRIBUTE3';
  l_transaction_table(l_count).param_value := P_CONT_ATTRIBUTE3;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_CONT_ATTRIBUTE4';
  l_transaction_table(l_count).param_value := P_CONT_ATTRIBUTE4;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_CONT_ATTRIBUTE5';
  l_transaction_table(l_count).param_value := P_CONT_ATTRIBUTE5;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_CONT_ATTRIBUTE6';
  l_transaction_table(l_count).param_value := P_CONT_ATTRIBUTE6;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_CONT_ATTRIBUTE7';
  l_transaction_table(l_count).param_value := P_CONT_ATTRIBUTE7;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_CONT_ATTRIBUTE8';
  l_transaction_table(l_count).param_value := P_CONT_ATTRIBUTE8;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_CONT_ATTRIBUTE9';
  l_transaction_table(l_count).param_value := P_CONT_ATTRIBUTE9;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_CONT_ATTRIBUTE10';
  l_transaction_table(l_count).param_value := P_CONT_ATTRIBUTE10;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_CONT_ATTRIBUTE11';
  l_transaction_table(l_count).param_value := P_CONT_ATTRIBUTE11;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_CONT_ATTRIBUTE12';
  l_transaction_table(l_count).param_value := P_CONT_ATTRIBUTE12;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_CONT_ATTRIBUTE13';
  l_transaction_table(l_count).param_value := P_CONT_ATTRIBUTE13;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_CONT_ATTRIBUTE14';
  l_transaction_table(l_count).param_value := P_CONT_ATTRIBUTE14;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_CONT_ATTRIBUTE15';
  l_transaction_table(l_count).param_value := P_CONT_ATTRIBUTE15;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_CONT_ATTRIBUTE16';
  l_transaction_table(l_count).param_value := P_CONT_ATTRIBUTE16;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_CONT_ATTRIBUTE17';
  l_transaction_table(l_count).param_value := P_CONT_ATTRIBUTE17;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_CONT_ATTRIBUTE18';
  l_transaction_table(l_count).param_value := P_CONT_ATTRIBUTE18;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --

  l_transaction_table(l_count).param_name := 'P_CONT_ATTRIBUTE19';
  l_transaction_table(l_count).param_value := P_CONT_ATTRIBUTE19;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_CONT_ATTRIBUTE20';
  l_transaction_table(l_count).param_value := P_CONT_ATTRIBUTE20;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_OBJECT_VERSION_NUMBER';
  l_transaction_table(l_count).param_value := P_OBJECT_VERSION_NUMBER;
  l_transaction_table(l_count).param_data_type := 'NUMBER';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_REVIEW_PROC_CALL';
  l_transaction_table(l_count).param_value := p_review_page_region_code;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_REVIEW_ACTID';
  l_transaction_table(l_count).param_value := p_activity_id;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PROCESS_SECTION_NAME';
  l_transaction_table(l_count).param_value := p_process_section_name;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --

 -- Bug 2723267 Fix Start
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_CONTACT_OPERATION';
    l_transaction_table(l_count).param_value := p_contact_operation;
    l_transaction_table(l_count).param_data_type := 'VARCHAR2';
 -- Bug 2723267 Fix End

-- Bug 3152505 : adding 3 new params.

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_OTHER_REL_ID';
  l_transaction_table(l_count).param_value := p_other_rel_id;
  l_transaction_table(l_count).param_data_type := 'NUMBER';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_END_OTHER_REL';
  l_transaction_table(l_count).param_value := p_end_other_rel;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_OTHER_REL_OBJ_VER_NO';
  l_transaction_table(l_count).param_value := l_other_rel_object_ver_no;
  l_transaction_table(l_count).param_data_type := 'NUMBER';

  hr_utility.set_location('Before Calling :hr_transaction_ss.save_transaction_step', 30);
  hr_utility.set_location('Before Calling :hr_transaction_ss.save_transaction_step ' || to_char(l_transaction_table.count), 35);
  --
  hr_transaction_ss.save_transaction_step
                (p_item_type => p_item_type
                ,p_item_key => p_item_key
                ,p_login_person_id => nvl(p_login_person_id,p_person_id)
                ,p_actid => p_activity_id
                ,p_transaction_step_id => l_transaction_step_id
                ,p_api_addtnl_info => p_contact_operation
                -- ,p_api_name => g_package || '.PROCESS_END_API'
                -- Change for contacts approvals.
                ,p_api_name => g_package || '.PROCESS_API'
                ,p_transaction_data => l_transaction_table);
  --
  hr_utility.set_location('Leaving hr_contact_rel_api.update_contact_relationship', 40);
  --
  EXCEPTION
    WHEN hr_utility.hr_error THEN
    hr_utility.set_location('Exception:hr_utility.hr_error THEN'||l_proc,555);
         -- -------------------------------------------
         -- an application error has been raised so we must
         -- redisplay the web form to display the error
         -- --------------------------------------------
         hr_message.provide_error;
         l_message_number := hr_message.Last_message_number;
         --
         -- 99999 What error messages I have to trap here.
         --
         IF l_message_number = 'APP-7165' OR
            l_message_number = 'APP-7155' THEN
            hr_utility.set_message(800, 'HR_UPDATE_NOT_ALLOWED');
            hr_utility.raise_error;
         ELSE
            hr_utility.raise_error;
         END IF;
    WHEN OTHERS THEN
        hr_utility.set_location('Exception:Others'||l_proc,555);
      fnd_message.set_name('PER', SQLERRM ||' '||to_char(SQLCODE));
      hr_utility.raise_error;
--      RAISE;  -- Raise error here relevant to the new tech stack.
  --
 end end_contact_relationship;
 --
 --
 -- ---------------------------------------------------------------------------
 -- ----------------------------- < process_end_api > -----------------------------
 -- ---------------------------------------------------------------------------
 -- Purpose: This procedure will be invoked in workflow notification
 --          when an approver approves all the changes.  This procedure
 --          will call the api to update to the database with p_validate
 --          equal to false.
 -- ---------------------------------------------------------------------------
 PROCEDURE process_end_api
          (p_validate IN BOOLEAN DEFAULT FALSE
          ,p_transaction_step_id IN NUMBER
          ,p_effective_date      in varchar2 default null
)
 IS
  --
  l_effective_start_date             date default null;
  l_effective_end_date               date default null;
  l_ovn                              number default null;
  l_contact_relationship_id          number default null;
  l_effective_date                   date;

  l_del_other_rel                    varchar2(5);
  --
  l_other_rel_ovn                    number default null;
  l_proc   varchar2(72)  := g_package||'process_end_api';

 BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);

  SAVEPOINT end_cont_relationship;
  --
  -- SFL changes
  --
  if (p_effective_date is not null) then
  hr_utility.set_location('Eff date is not Null:'||l_proc, 10);
    l_effective_date := to_date(p_effective_date,g_date_format);
  else
       --
         hr_utility.set_location('Eff date is  Null:'||l_proc, 15);
       l_effective_date:= to_date(
         hr_transaction_ss.get_wf_effective_date
        (p_transaction_step_id => p_transaction_step_id),g_date_format);
       --
  end if;
  -- For normal commit the effective date should come from txn tbales.
  --
  if not p_validate then
     --
       hr_utility.set_location(' not p_validate:'||l_proc, 20);
     l_effective_date := hr_transaction_api.get_DATE_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_EFFECTIVE_DATE');
     --
  end if;
  --
  -- Get the contact_relationship_id  first.  If it is null, that means
  -- this is error and raise the error. -- add the error name 99999.
  --
  l_contact_relationship_id := hr_transaction_api.get_number_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_CONTACT_RELATIONSHIP_ID');
  --
  l_ovn := hr_transaction_api.get_number_value
             (p_transaction_step_id => p_transaction_step_id
             ,p_name => 'P_OBJECT_VERSION_NUMBER');
  --
  l_other_rel_ovn := hr_transaction_api.get_NUMBER_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_OTHER_REL_OBJ_VER_NO') ;
  --
  IF l_contact_relationship_id IS NOT NULL
  THEN
    hr_utility.set_location('l_contact_relationship_id is not NULL:'||l_proc, 25);
    --
    hr_contact_rel_api.update_contact_relationship(
      p_validate                => p_validate
      --
      ,P_EFFECTIVE_DATE         =>l_effective_date
         /*
         hr_transaction_api.get_DATE_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_EFFECTIVE_DATE')
         */
      --
      ,p_object_version_number   => l_ovn
      --
      -- 9999 What value to pass on.
      /* ,p_attribute_update_mode   => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE_UPDATE_MODE')
      */
      --
      ,P_CONTACT_RELATIONSHIP_ID  =>
         hr_transaction_api.get_NUMBER_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONTACT_RELATIONSHIP_ID')
      --
     /*
      ,P_CONTACT_TYPE  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_CONTACT_TYPE')
      --
      ,P_COMMENTS  =>
         hr_transaction_api.get_varchar2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_COMMENTS')
      --
      ,P_PRIMARY_CONTACT_FLAG  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PRIMARY_CONTACT_FLAG')
      --
      ,P_THIRD_PARTY_PAY_FLAG  =>
         hr_transaction_api.get_VARCHAR2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_THIRD_PARTY_PAY_FLAG')
      --
      ,p_bondholder_flag  =>
         hr_transaction_api.get_varchar2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'p_bondholder_flag')
      --
      ,p_date_start  =>
         hr_transaction_api.get_date_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'p_date_start')
      --
      ,p_start_life_reason_id  =>
         hr_transaction_api.get_number_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'p_start_life_reason_id')
      --
      */
      ,p_date_end  =>
         hr_transaction_api.get_date_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'p_date_end')
      --
      --bug# 2080032
      ,p_end_life_reason_id  =>
         hr_transaction_api.get_number_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'p_end_life_reason_id')
      --
   /*
     ,p_rltd_per_rsds_w_dsgntr_flag  =>
         hr_transaction_api.get_varchar2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'p_rltd_per_rsds_w_dsgntr_flag')
      --
      ,p_personal_flag  =>
         hr_transaction_api.get_varchar2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'p_personal_flag')
      --
      ,p_sequence_number  =>
         hr_transaction_api.get_number_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'p_sequence_number')
      --
      ,p_dependent_flag  =>
         hr_transaction_api.get_varchar2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'p_dependent_flag')
      --
      ,p_beneficiary_flag  =>
         hr_transaction_api.get_varchar2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'p_beneficiary_flag')
      --
      ,p_cont_attribute_category  =>
         hr_transaction_api.get_varchar2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'p_cont_attribute_category')
      --
      ,p_cont_attribute1  =>
         hr_transaction_api.get_varchar2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'p_cont_attribute1')
      --
      ,p_cont_attribute2  =>
         hr_transaction_api.get_varchar2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'p_cont_attribute2')
      --
      ,p_cont_attribute3  =>
         hr_transaction_api.get_varchar2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'p_cont_attribute3')
      --
      ,p_cont_attribute4  =>
         hr_transaction_api.get_varchar2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'p_cont_attribute4')
      --
      ,p_cont_attribute5  =>
         hr_transaction_api.get_varchar2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'p_cont_attribute5')
      --
      ,p_cont_attribute6  =>
         hr_transaction_api.get_varchar2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'p_cont_attribute6')
      --
      ,p_cont_attribute7  =>
         hr_transaction_api.get_varchar2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'p_cont_attribute7')
      --
      ,p_cont_attribute8  =>
         hr_transaction_api.get_varchar2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'p_cont_attribute8')
      --
      ,p_cont_attribute9  =>
         hr_transaction_api.get_varchar2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'p_cont_attribute9')
      --
      ,p_cont_attribute10  =>
         hr_transaction_api.get_varchar2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'p_cont_attribute10')
      --
      ,p_cont_attribute11  =>
         hr_transaction_api.get_varchar2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'p_cont_attribute11')
      --
      ,p_cont_attribute12  =>
         hr_transaction_api.get_varchar2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'p_cont_attribute12')
      --
      ,p_cont_attribute13  =>
         hr_transaction_api.get_varchar2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'p_cont_attribute13')
      --
      ,p_cont_attribute14  =>
         hr_transaction_api.get_varchar2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'p_cont_attribute14')
      --
      ,p_cont_attribute15  =>
         hr_transaction_api.get_varchar2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'p_cont_attribute15')
      --
      ,p_cont_attribute16  =>
         hr_transaction_api.get_varchar2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'p_cont_attribute16')
      --
      ,p_cont_attribute17  =>
         hr_transaction_api.get_varchar2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'p_cont_attribute17')
      --
      ,p_cont_attribute18  =>
         hr_transaction_api.get_varchar2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'p_cont_attribute18')
      --
      ,p_cont_attribute19  =>
         hr_transaction_api.get_varchar2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'p_cont_attribute19')
      --
      ,p_cont_attribute20  =>
         hr_transaction_api.get_varchar2_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'p_cont_attribute20')
      --
      */
    );
-- Bug 3152505 : calling the update_api for second time if user has checked the check bux for deleting
-- the other relationship also.
    l_del_other_rel := hr_transaction_api.get_VARCHAR2_value
                             (p_transaction_step_id => p_transaction_step_id
                             ,p_name                => 'P_END_OTHER_REL');

    if  l_del_other_rel = 'Y' then
    hr_utility.set_location('if  l_del_other_rel Y:'||l_proc, 30);
    hr_contact_rel_api.update_contact_relationship(
       p_validate                => p_validate
      ,P_EFFECTIVE_DATE         =>l_effective_date
      ,p_object_version_number   => l_other_rel_ovn
      ,P_CONTACT_RELATIONSHIP_ID  =>
         hr_transaction_api.get_NUMBER_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_OTHER_REL_ID')
      ,p_date_end  =>
         hr_transaction_api.get_date_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'p_date_end')
      ,p_end_life_reason_id  =>
         hr_transaction_api.get_number_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'p_end_life_reason_id')
    );
    end if;
  ELSE
     -- Error message goes here as the contact_relationshipid is null. 9999
     null;
  END IF;
  --
  IF p_validate = true THEN
         hr_utility.set_location('p_validate = true'||l_proc, 35);
     ROLLBACK TO end_cont_relationship;
  END IF;
  hr_utility.set_location('Exiting:'||l_proc, 40);
  --
 EXCEPTION
  WHEN hr_utility.hr_error THEN
  hr_utility.set_location('Exception:hr_utility.hr_error'||l_proc,555);
    -- -----------------------------------------------------------------
    -- An application error has been raised by the API so we must set
    -- the error.
    -- -----------------------------------------------------------------
    ROLLBACK TO end_cont_relationship;
    RAISE;
    --
 END process_end_api;
 --
 -- ----------------------------------------------------------------------------
 -- |-------------------------< is_contact_added>------------------------|
 -- ----------------------------------------------------------------------------
 -- Purpose: This procedure will be called from contacts subprocess, which will  -- determine if the control sholud go to the contacts page again or to the
 -- conatcs decision page.
 -- Case1 : If no contacts were added in this session Then Goto Decision page
 --         ( may be from contacts - back button )
 -- Case2 : If there are some contacts added,Then Goto Contacts page to show
 --         last contact added
 --         (coming from back button)
 PROCEDURE is_contact_added
 (itemtype in     varchar2
  ,itemkey  in     varchar2
  ,actid    in     number
  ,funcmode in     varchar2
  ,resultout   out nocopy varchar2)
 is
   l_contact_set            wf_activity_attr_values.number_value%type;
   l_proc   varchar2(72)  := g_package||'is_contact_added';
 begin
 --
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_contact_set := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'HR_CONTACT_SET');

     if    l_contact_set > 0  then
        hr_utility.set_location('l_contact_set > 0:'||l_proc, 10);
        -- Goto Contacts page
        resultout := 'COMPLETE:'|| 'Y';
     else
        -- Goto Decision page
        hr_utility.set_location('l_contact_set <= 0:'||l_proc, 15);
        resultout := 'COMPLETE:'|| 'N';
     end if;
  hr_utility.set_location('Exiting:'||l_proc, 20);
 EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location('Exception:OTHERS'||l_proc,555);
    WF_CORE.CONTEXT(g_package
                   ,'is_contact_added'
                   ,itemtype
                   ,itemkey
                   ,to_char(actid)
                   ,funcmode);
    RAISE;
 end is_contact_added;
 --
-- -------------------------------------------------------------------------
--   Delete_transaction_steps is used by contacts. This will delete the
--   Transaction steps from the pages from which the user went  back to the
--   current contact page using the contact set.
-- -------------------------------------------------------------------------
PROCEDURE delete_transaction_steps(
  p_item_type IN     varchar2,
  p_item_key  IN     varchar2,
  p_actid     IN     varchar2,
  p_login_person_id  IN varchar2) IS

  l_trans_step_ids      hr_util_web.g_varchar2_tab_type;
  l_trans_obj_vers_num  hr_util_web.g_varchar2_tab_type;
  l_trans_step_rows     NUMBER;
  l_contact_set         varchar2(5) := null;
  l_wf_contact_set      NUMBER := null;
  l_proc   varchar2(72)  := g_package||'delete_transaction_steps';

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_transaction_api.get_transaction_step_info (
    p_Item_Type             => p_item_type,
    p_Item_Key              => p_item_key,
    p_activity_id           => to_number(p_actid),
    p_transaction_step_id   => l_trans_step_ids,
    p_object_version_number => l_trans_obj_vers_num,
    p_rows                  => l_trans_step_rows
  );


 -- Get the contact set from java and compare with the contact set id in each step.
 -- if the step doesnot match, ignore the step and go to next step.


--
--  This is a marker for the contact person to be used to identify the
--  transactiion steps to be retrieved for the contact person in context.
--  The HR_LAST_CONTACT_SET is in from the work flow attribute
  BEGIN
      l_wf_contact_set := wf_engine.GetItemAttrNumber(itemtype => p_item_type,
                                                      itemkey  => p_item_key,
                                                      aname    => 'HR_CONTACT_SET');

      exception when others then
           hr_utility.set_location('Exception:others'||l_proc,555);
           l_wf_contact_set := 1000;
           -- can't let anyone have so many dependants anyway!

  END;

  hr_utility.set_location('before starting For Loop:'||l_proc, 10);
  FOR i IN 0..(l_trans_step_rows - 1) LOOP

      begin
        l_contact_set := hr_transaction_api.get_varchar2_value
                        (p_transaction_step_id => l_trans_step_ids(i)
                        ,p_name                => 'P_CONTACT_SET');
      exception
        when others then
         hr_utility.set_location('Exception:Others'||l_proc,555);
         l_contact_set := 1;
      end;

      if l_contact_set is null then
         l_contact_set := 1;
      end if;

      if  l_contact_set >= l_wf_contact_set then
          hr_transaction_ss.delete_transaction_step
          (p_transaction_step_id => l_trans_step_ids(i)
          ,p_object_version_number => l_trans_obj_vers_num(i)
          ,p_login_person_id => p_login_person_id);
      end if;

  END LOOP;

  --hr_utility.set_message(801, 'HR_51750_WEB_TRANSAC_STARTED');
  --hr_utility.raise_error;
hr_utility.set_location('Exiting:'||l_proc, 15);
EXCEPTION
  WHEN OTHERS THEN
      hr_utility.set_location('Exception:Others'||l_proc,555);
      fnd_message.set_name('PER', SQLERRM ||' '||to_char(SQLCODE));
      hr_utility.raise_error;
    --raise;
END delete_transaction_steps;
--
-- my delete
-- -------------------------------------------------------------------------
--  Delete_transaction_steps overloaded is used by contacts in registration
--  flow.  This will delete the Transaction steps from the pages from which
--  the user went back to the current contact page.
--  It uses the contact set and p_mode to determine which contacts to delete
-- -------------------------------------------------------------------------
PROCEDURE delete_transaction_steps(
  p_item_type IN     varchar2,
  p_item_key  IN     varchar2,
  p_actid     IN     varchar2,
  p_login_person_id  IN varchar2,
  p_mode IN varchar2) IS

  l_trans_step_ids      hr_util_web.g_varchar2_tab_type;
  l_trans_obj_vers_num  hr_util_web.g_varchar2_tab_type;
  l_trans_step_rows     NUMBER;
  l_contact_set         varchar2(5) := null;
  l_wf_contact_set      NUMBER := null;
  l_proc   varchar2(72)  := g_package||'delete_transaction_steps';

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_transaction_api.get_transaction_step_info (
    p_Item_Type             => p_item_type,
    p_Item_Key              => p_item_key,
    p_activity_id           => to_number(p_actid),
    p_transaction_step_id   => l_trans_step_ids,
    p_object_version_number => l_trans_obj_vers_num,
    p_rows                  => l_trans_step_rows
  );


 -- Get the contact set from java and compare with the contact set id in each step.
 -- if the step doesnot match, ignore the step and go to next step.


--
--  This is a marker for the contact person to be used to identify the
--  transactiion steps to be retrieved for the contact person in context.
--  The HR_LAST_CONTACT_SET is in from the work flow attribute
  BEGIN
      l_wf_contact_set := wf_engine.GetItemAttrNumber(itemtype => p_item_type,
                                                      itemkey  => p_item_key,
                                                      aname    => 'HR_CONTACT_SET');

      exception when others then
      hr_utility.set_location('Exception:Others'||l_proc,555);
           l_wf_contact_set := 1000;
           -- can't let anyone have so many dependants anyway!

  END;

  hr_utility.set_location('Before Entering For Loop:'||l_proc,10 );
  FOR i IN 0..(l_trans_step_rows - 1) LOOP

      begin
        l_contact_set := hr_transaction_api.get_varchar2_value
                        (p_transaction_step_id => l_trans_step_ids(i)
                        ,p_name                => 'P_CONTACT_SET');
      exception
        when others then
        hr_utility.set_location('Exception:Others'||l_proc,555);
         l_contact_set := 1;
      end;

      if l_contact_set is null then
         l_contact_set := 1;
      end if;

     -- When the procedure is called from 'Do not add Contacts'
     -- button in 'Add contacts yes no' page
      if p_mode = 'ALL' then
            hr_transaction_ss.delete_transaction_step
            (p_transaction_step_id => l_trans_step_ids(i)
            ,p_object_version_number => l_trans_obj_vers_num(i)
            ,p_login_person_id => p_login_person_id);

     -- When the procedure is called from 'add another Contact'
     -- button in contacts page
      elsif p_mode = 'THIS' then
        if  l_contact_set = l_wf_contact_set then
            hr_transaction_ss.delete_transaction_step
            (p_transaction_step_id => l_trans_step_ids(i)
            ,p_object_version_number => l_trans_obj_vers_num(i)
            ,p_login_person_id => p_login_person_id);
        end if;

     -- When the procedure is called from 'Next' button
     -- in contacts page
      elsif p_mode = 'THIS AND ABOVE' then
        if  l_contact_set >= l_wf_contact_set then
            hr_transaction_ss.delete_transaction_step
            (p_transaction_step_id => l_trans_step_ids(i)
            ,p_object_version_number => l_trans_obj_vers_num(i)
            ,p_login_person_id => p_login_person_id);
        end if;
      end if;

  END LOOP;
  hr_utility.set_location('End of For Loop:'||l_proc,15 );

  --hr_utility.set_message(801, 'HR_51750_WEB_TRANSAC_STARTED');
  --hr_utility.raise_error;
  hr_utility.set_location('Exiting:'||l_proc, 20);

EXCEPTION
  WHEN OTHERS THEN
      hr_utility.set_location('Exception:Others'||l_proc,555);
      fnd_message.set_name('PER', SQLERRM ||' '||to_char(SQLCODE));
      hr_utility.raise_error;
    --raise;
END delete_transaction_steps;
--

-- mydelete
--
procedure update_object_version
  (p_transaction_step_id in     number
  ,p_login_person_id in number) is

/*
  cursor csr_new_object_number(p_asg_id in number) is
  select object_version_number
    from per_all_assignments_f
   where assignment_id = p_asg_id
     and assignment_type = 'E'
   order by object_version_number desc;
*/

  l_old_object_number number;
  l_assignment_id number;
  l_new_object_number number;
  l_proc   varchar2(72)  := g_package||'update_object_version';

begin
hr_utility.set_location('Entering:'||l_proc, 5);
/*
  l_assignment_id :=
      hr_transaction_api.get_number_value
      (p_transaction_step_id =>  p_transaction_step_id
      ,p_name                => 'P_ASSIGNMENT_ID');

    open csr_new_object_number(l_assignment_id);
    fetch csr_new_object_number into l_new_object_number;
    close csr_new_object_number;

  l_old_object_number :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id =>  p_transaction_step_id
    ,p_name                => 'P_OBJECT_VERSION_NUMBER');

  if l_old_object_number <> l_new_object_number then
    hr_transaction_api.set_number_value
    (p_transaction_step_id =>  p_transaction_step_id
    ,p_person_id           => p_login_person_id
    ,p_name                => 'P_OBJECT_VERSION_NUMBER'
    ,p_value               => l_new_object_number);
  end if;
*/
hr_utility.set_location('Exiting:'||l_proc, 15);
null;

end update_object_version;
--
procedure call_contact_api
  (p_validate                     in        boolean     default false
  ,p_start_date                   in        date
  ,p_business_group_id            in        number
  ,p_person_id                    in        number
  ,p_contact_person_id            in        number      default null
  ,p_contact_type                 in        varchar2
  ,p_ctr_comments                 in        varchar2    default null
  ,p_primary_contact_flag         in        varchar2    default 'N'
  ,p_date_start                   in        date        default null
  ,p_start_life_reason_id         in        number      default null
  ,p_date_end                     in        date        default null
  ,p_end_life_reason_id           in        number      default null
  ,p_rltd_per_rsds_w_dsgntr_flag  in        varchar2    default 'N'
  ,p_personal_flag                in        varchar2    default 'N'
  ,p_sequence_number              in        number      default null
  ,p_cont_attribute_category      in        varchar2    default null
  ,p_cont_attribute1              in        varchar2    default null
  ,p_cont_attribute2              in        varchar2    default null
  ,p_cont_attribute3              in        varchar2    default null
  ,p_cont_attribute4              in        varchar2    default null
  ,p_cont_attribute5              in        varchar2    default null
  ,p_cont_attribute6              in        varchar2    default null
  ,p_cont_attribute7              in        varchar2    default null
  ,p_cont_attribute8              in        varchar2    default null
  ,p_cont_attribute9              in        varchar2    default null
  ,p_cont_attribute10             in        varchar2    default null
  ,p_cont_attribute11             in        varchar2    default null
  ,p_cont_attribute12             in        varchar2    default null
  ,p_cont_attribute13             in        varchar2    default null
  ,p_cont_attribute14             in        varchar2    default null
  ,p_cont_attribute15             in        varchar2    default null
  ,p_cont_attribute16             in        varchar2    default null
  ,p_cont_attribute17             in        varchar2    default null
  ,p_cont_attribute18             in        varchar2    default null
  ,p_cont_attribute19             in        varchar2    default null
  ,p_cont_attribute20             in        varchar2    default null
  ,p_cont_information_category      in        varchar2    default null
  ,p_cont_information1              in        varchar2    default null
  ,p_cont_information2              in        varchar2    default null
  ,p_cont_information3              in        varchar2    default null
  ,p_cont_information4              in        varchar2    default null
  ,p_cont_information5              in        varchar2    default null
  ,p_cont_information6              in        varchar2    default null
  ,p_cont_information7              in        varchar2    default null
  ,p_cont_information8              in        varchar2    default null
  ,p_cont_information9              in        varchar2    default null
  ,p_cont_information10             in        varchar2    default null
  ,p_cont_information11             in        varchar2    default null
  ,p_cont_information12             in        varchar2    default null
  ,p_cont_information13             in        varchar2    default null
  ,p_cont_information14             in        varchar2    default null
  ,p_cont_information15             in        varchar2    default null
  ,p_cont_information16             in        varchar2    default null
  ,p_cont_information17             in        varchar2    default null
  ,p_cont_information18             in        varchar2    default null
  ,p_cont_information19             in        varchar2    default null
  ,p_cont_information20             in        varchar2    default null
  ,p_third_party_pay_flag         in        varchar2    default 'N'
  ,p_bondholder_flag              in        varchar2    default 'N'
  ,p_dependent_flag               in        varchar2    default 'N'
  ,p_beneficiary_flag             in        varchar2    default 'N'
  ,p_last_name                    in        varchar2    default null
  ,p_sex                          in        varchar2    default null
  ,p_person_type_id               in        number      default null
  ,p_per_comments                 in        varchar2    default null
  ,p_date_of_birth                in        date        default null
  ,p_email_address                in        varchar2    default null
  ,p_first_name                   in        varchar2    default null
  ,p_known_as                     in        varchar2    default null
  ,p_marital_status               in        varchar2    default null
  ,p_middle_names                 in        varchar2    default null
  ,p_nationality                  in        varchar2    default null
  ,p_national_identifier          in        varchar2    default null
  ,p_previous_last_name           in        varchar2    default null
  ,p_registered_disabled_flag     in        varchar2    default null
  ,p_title                        in        varchar2    default null
  ,p_work_telephone               in        varchar2    default null
  ,p_attribute_category           in        varchar2    default null
  ,p_attribute1                   in        varchar2    default null
  ,p_attribute2                   in        varchar2    default null
  ,p_attribute3                   in        varchar2    default null
  ,p_attribute4                   in        varchar2    default null
  ,p_attribute5                   in        varchar2    default null
  ,p_attribute6                   in        varchar2    default null
  ,p_attribute7                   in        varchar2    default null
  ,p_attribute8                   in        varchar2    default null
  ,p_attribute9                   in        varchar2    default null
  ,p_attribute10                  in        varchar2    default null
  ,p_attribute11                  in        varchar2    default null
  ,p_attribute12                  in        varchar2    default null
  ,p_attribute13                  in        varchar2    default null
  ,p_attribute14                  in        varchar2    default null
  ,p_attribute15                  in        varchar2    default null
  ,p_attribute16                  in        varchar2    default null
  ,p_attribute17                  in        varchar2    default null
  ,p_attribute18                  in        varchar2    default null
  ,p_attribute19                  in        varchar2    default null
  ,p_attribute20                  in        varchar2    default null
  ,p_attribute21                  in        varchar2    default null
  ,p_attribute22                  in        varchar2    default null
  ,p_attribute23                  in        varchar2    default null
  ,p_attribute24                  in        varchar2    default null
  ,p_attribute25                  in        varchar2    default null
  ,p_attribute26                  in        varchar2    default null
  ,p_attribute27                  in        varchar2    default null
  ,p_attribute28                  in        varchar2    default null
  ,p_attribute29                  in        varchar2    default null
  ,p_attribute30                  in        varchar2    default null
  ,p_per_information_category     in        varchar2    default null
  ,p_per_information1             in        varchar2    default null
  ,p_per_information2             in        varchar2    default null
  ,p_per_information3             in        varchar2    default null
  ,p_per_information4             in        varchar2    default null
  ,p_per_information5             in        varchar2    default null
  ,p_per_information6             in        varchar2    default null
  ,p_per_information7             in        varchar2    default null
  ,p_per_information8             in        varchar2    default null
  ,p_per_information9             in        varchar2    default null
  ,p_per_information10            in        varchar2    default null
  ,p_per_information11            in        varchar2    default null
  ,p_per_information12            in        varchar2    default null
  ,p_per_information13            in        varchar2    default null
  ,p_per_information14            in        varchar2    default null
  ,p_per_information15            in        varchar2    default null
  ,p_per_information16            in        varchar2    default null
  ,p_per_information17            in        varchar2    default null
  ,p_per_information18            in        varchar2    default null
  ,p_per_information19            in        varchar2    default null
  ,p_per_information20            in        varchar2    default null
  ,p_per_information21            in        varchar2    default null
  ,p_per_information22            in        varchar2    default null
  ,p_per_information23            in        varchar2    default null
  ,p_per_information24            in        varchar2    default null
  ,p_per_information25            in        varchar2    default null
  ,p_per_information26            in        varchar2    default null
  ,p_per_information27            in        varchar2    default null
  ,p_per_information28            in        varchar2    default null
  ,p_per_information29            in        varchar2    default null
  ,p_per_information30            in        varchar2    default null
  ,p_correspondence_language      in        varchar2    default null
  ,p_honors                       in        varchar2    default null
  ,p_pre_name_adjunct             in        varchar2    default null
  ,p_suffix                       in        varchar2    default null
  ,p_create_mirror_flag           in        varchar2    default 'N'
  ,p_mirror_type                  in        varchar2    default null
  ,p_mirror_cont_attribute_cat    in        varchar2    default null
  ,p_mirror_cont_attribute1       in        varchar2    default null
  ,p_mirror_cont_attribute2       in        varchar2    default null
  ,p_mirror_cont_attribute3       in        varchar2    default null
  ,p_mirror_cont_attribute4       in        varchar2    default null
  ,p_mirror_cont_attribute5       in        varchar2    default null
  ,p_mirror_cont_attribute6       in        varchar2    default null
  ,p_mirror_cont_attribute7       in        varchar2    default null
  ,p_mirror_cont_attribute8       in        varchar2    default null
  ,p_mirror_cont_attribute9       in        varchar2    default null
  ,p_mirror_cont_attribute10      in        varchar2    default null
  ,p_mirror_cont_attribute11      in        varchar2    default null
  ,p_mirror_cont_attribute12      in        varchar2    default null
  ,p_mirror_cont_attribute13      in        varchar2    default null
  ,p_mirror_cont_attribute14      in        varchar2    default null
  ,p_mirror_cont_attribute15      in        varchar2    default null
  ,p_mirror_cont_attribute16      in        varchar2    default null
  ,p_mirror_cont_attribute17      in        varchar2    default null
  ,p_mirror_cont_attribute18      in        varchar2    default null
  ,p_mirror_cont_attribute19      in        varchar2    default null
  ,p_mirror_cont_attribute20      in        varchar2    default null
  ,p_mirror_cont_information_cat    in        varchar2    default null
  ,p_mirror_cont_information1       in        varchar2    default null
  ,p_mirror_cont_information2       in        varchar2    default null
  ,p_mirror_cont_information3       in        varchar2    default null
  ,p_mirror_cont_information4       in        varchar2    default null
  ,p_mirror_cont_information5       in        varchar2    default null
  ,p_mirror_cont_information6       in        varchar2    default null
  ,p_mirror_cont_information7       in        varchar2    default null
  ,p_mirror_cont_information8       in        varchar2    default null
  ,p_mirror_cont_information9       in        varchar2    default null
  ,p_mirror_cont_information10      in        varchar2    default null
  ,p_mirror_cont_information11      in        varchar2    default null
  ,p_mirror_cont_information12      in        varchar2    default null
  ,p_mirror_cont_information13      in        varchar2    default null
  ,p_mirror_cont_information14      in        varchar2    default null
  ,p_mirror_cont_information15      in        varchar2    default null
  ,p_mirror_cont_information16      in        varchar2    default null
  ,p_mirror_cont_information17      in        varchar2    default null
  ,p_mirror_cont_information18      in        varchar2    default null
  ,p_mirror_cont_information19      in        varchar2    default null
  ,p_mirror_cont_information20      in        varchar2    default null
--
  ,p_contact_relationship_id      out nocopy number
  ,p_ctr_object_version_number    out nocopy number
  ,p_per_person_id                out nocopy number
  ,p_per_object_version_number    out nocopy number
  ,p_per_effective_start_date     out nocopy date
  ,p_per_effective_end_date       out nocopy date
  ,p_full_name                    out nocopy varchar2
  ,p_per_comment_id               out nocopy number
  ,p_name_combination_warning     out nocopy boolean
  ,p_orig_hire_warning            out nocopy boolean
--
  ,p_contact_operation               in        varchar2
  ,p_emrg_cont_flag                  in        varchar2   default 'N'
  )
 is
 l_proc   varchar2(72)  := g_package||'call_contact_api';
 begin

 /*
  if p_primary_contact_flag is 'Y', then use it only first emergency relationship and not for
  other personal relationship, if not u will get
  This employee already has a primary contact. Cause: You are trying to enter more than one
  primary contact for an employee. Action: Uncheck the Primary Contact check box and save your contact
  information.*/

 hr_utility.set_location('Entering:'||l_proc, 5);
 hr_contact_rel_api.create_contact(
    p_validate                 		=>  p_validate -- l_validate_mode
   ,p_start_date               		=>  p_start_date --p_start_date
   ,p_business_group_id        		=>  p_business_group_id
   ,p_person_id                		=>  p_person_id
   ,p_contact_person_id        		=>  p_contact_person_id
   ,p_contact_type             		=>  p_contact_type
   ,p_ctr_comments             		=>  p_ctr_comments
   ,p_primary_contact_flag     		=>  'N'
   ,p_date_start               		=>  p_date_start
   ,p_start_life_reason_id     		=>  p_start_life_reason_id
   ,p_date_end                 		=>  p_date_end
   ,p_end_life_reason_id       		=>  p_end_life_reason_id
   ,p_rltd_per_rsds_w_dsgntr_flag     	=>  p_rltd_per_rsds_w_dsgntr_flag
   ,p_personal_flag                   	=>  p_personal_flag
   ,p_sequence_number                 	=>  p_sequence_number
   ,p_cont_attribute_category     	=>  p_cont_attribute_category
   ,p_cont_attribute1                 	=>  p_cont_attribute1
   ,p_cont_attribute2                 	=>  p_cont_attribute2
   ,p_cont_attribute3                 	=>  p_cont_attribute3
   ,p_cont_attribute4                 	=>  p_cont_attribute4
   ,p_cont_attribute5     		=>  p_cont_attribute5
   ,p_cont_attribute6     		=>  p_cont_attribute6
   ,p_cont_attribute7     		=>  p_cont_attribute7
   ,p_cont_attribute8     		=>  p_cont_attribute8
   ,p_cont_attribute9     		=>  p_cont_attribute9
   ,p_cont_attribute10     		=>  p_cont_attribute10
   ,p_cont_attribute11     		=>  p_cont_attribute11
   ,p_cont_attribute12     		=>  p_cont_attribute12
   ,p_cont_attribute13     		=>  p_cont_attribute13
   ,p_cont_attribute14     		=>  p_cont_attribute14
   ,p_cont_attribute15     		=>  p_cont_attribute15
   ,p_cont_attribute16     		=>  p_cont_attribute16
   ,p_cont_attribute17     		=>  p_cont_attribute17
   ,p_cont_attribute18     		=>  p_cont_attribute18
   ,p_cont_attribute19     		=>  p_cont_attribute19
   ,p_cont_attribute20    		=>  p_cont_attribute20
   ,p_cont_information_category         =>  p_cont_information_category
   ,p_cont_information1                 =>  p_cont_information1
   ,p_cont_information2                 =>  p_cont_information2
   ,p_cont_information3                 =>  p_cont_information3
   ,p_cont_information4                 =>  p_cont_information4
   ,p_cont_information5                 =>  p_cont_information5
   ,p_cont_information6                 =>  p_cont_information6
   ,p_cont_information7                 =>  p_cont_information7
   ,p_cont_information8                 =>  p_cont_information8
   ,p_cont_information9                 =>  p_cont_information9
   ,p_cont_information10                =>  p_cont_information10
   ,p_cont_information11                =>  p_cont_information11
   ,p_cont_information12                =>  p_cont_information12
   ,p_cont_information13                =>  p_cont_information13
   ,p_cont_information14                =>  p_cont_information14
   ,p_cont_information15                =>  p_cont_information15
   ,p_cont_information16                =>  p_cont_information16
   ,p_cont_information17                =>  p_cont_information17
   ,p_cont_information18                =>  p_cont_information18
   ,p_cont_information19                =>  p_cont_information19
   ,p_cont_information20                =>  p_cont_information20
   ,p_third_party_pay_flag     		=>  p_third_party_pay_flag
   ,p_bondholder_flag     		=>  p_bondholder_flag
   ,p_dependent_flag     		=>  p_dependent_flag
   ,p_beneficiary_flag     		=>  p_beneficiary_flag
   ,p_last_name     			=>  p_last_name
   ,p_sex     				=>  p_sex
   ,p_person_type_id     		=>  p_person_type_id
   ,p_per_comments     			=>  p_per_comments
   ,p_date_of_birth     		=>  p_date_of_birth
   ,p_email_address     		=>  p_email_address
   ,p_first_name     			=>  p_first_name
   ,p_known_as     			=>  p_known_as
   ,p_marital_status     		=>  p_marital_status
   ,p_middle_names     			=>  p_middle_names
   ,p_nationality     			=>  p_nationality
   ,p_national_identifier     		=>  p_national_identifier
   ,p_previous_last_name     		=>  p_previous_last_name
   ,p_registered_disabled_flag     	=>  p_registered_disabled_flag
   ,p_title     			=>  p_title
   ,p_work_telephone     		=>  p_work_telephone
   ,p_attribute_category     		=>  p_attribute_category
   ,p_attribute1     			=>  p_attribute1
   ,p_attribute2     			=>  p_attribute2
   ,p_attribute3     			=>  p_attribute3
   ,p_attribute4     			=>  p_attribute4
   ,p_attribute5     			=>  p_attribute5
   ,p_attribute6     			=>  p_attribute6
   ,p_attribute7     			=>  p_attribute7
   ,p_attribute8     			=>  p_attribute8
   ,p_attribute9     			=>  p_attribute9
   ,p_attribute10     			=>  p_attribute10
   ,p_attribute11     			=>  p_attribute11
   ,p_attribute12     			=>  p_attribute12
   ,p_attribute13     			=>  p_attribute13
   ,p_attribute14     			=>  p_attribute14
   ,p_attribute15     			=>  p_attribute15
   ,p_attribute16     			=>  p_attribute16
   ,p_attribute17     			=>  p_attribute17
   ,p_attribute18     			=>  p_attribute18
   ,p_attribute19     			=>  p_attribute19
   ,p_attribute20     			=>  p_attribute20
   ,p_attribute21     			=>  p_attribute21
   ,p_attribute22     			=>  p_attribute22
   ,p_attribute23     			=>  p_attribute23
   ,p_attribute24     			=>  p_attribute24
   ,p_attribute25     			=>  p_attribute25
   ,p_attribute26     			=>  p_attribute26
   ,p_attribute27     			=>  p_attribute27
   ,p_attribute28     			=>  p_attribute28
   ,p_attribute29     			=>  p_attribute29
   ,p_attribute30     			=>  p_attribute30
   ,p_per_information_category     	=>  p_per_information_category
   ,p_per_information1      =>  p_per_information1
   ,p_per_information2      =>  p_per_information2
   ,p_per_information3      =>  p_per_information3
   ,p_per_information4      =>  p_per_information4
   ,p_per_information5      =>  p_per_information5
   ,p_per_information6      =>  p_per_information6
   ,p_per_information7      =>  p_per_information7
   ,p_per_information8      =>  p_per_information8
   ,p_per_information9      =>  p_per_information9
   ,p_per_information10     =>  p_per_information10
   ,p_per_information11     =>  p_per_information11
   ,p_per_information12     =>  p_per_information12
   ,p_per_information13     =>  p_per_information13
   ,p_per_information14     =>  p_per_information14
   ,p_per_information15     =>  p_per_information15
   ,p_per_information16     =>  p_per_information16
   ,p_per_information17     =>  p_per_information17
   ,p_per_information18     =>  p_per_information18
   ,p_per_information19     =>  p_per_information19
   ,p_per_information20     =>  p_per_information20
   ,p_per_information21     =>  p_per_information21
   ,p_per_information22     =>  p_per_information22
   ,p_per_information23     =>  p_per_information23
   ,p_per_information24     =>  p_per_information24
   ,p_per_information25     =>  p_per_information25
   ,p_per_information26     =>  p_per_information26
   ,p_per_information27     =>  p_per_information27
   ,p_per_information28     =>  p_per_information28
   ,p_per_information29     =>  p_per_information29
   ,p_per_information30     =>  p_per_information30
   ,p_correspondence_language   =>  p_correspondence_language
   ,p_honors     		=>  p_honors
   ,p_pre_name_adjunct     	=>  p_pre_name_adjunct
   ,p_suffix     		=>  p_suffix
   ,p_create_mirror_flag     	=>  p_create_mirror_flag
   ,p_mirror_type     		=>  p_mirror_type
   ,p_mirror_cont_attribute_cat   =>  p_mirror_cont_attribute_cat
   ,p_mirror_cont_attribute1      =>  p_mirror_cont_attribute1
   ,p_mirror_cont_attribute2      =>  p_mirror_cont_attribute2
   ,p_mirror_cont_attribute3      =>  p_mirror_cont_attribute3
   ,p_mirror_cont_attribute4      =>  p_mirror_cont_attribute4
   ,p_mirror_cont_attribute5      =>  p_mirror_cont_attribute5
   ,p_mirror_cont_attribute6      =>  p_mirror_cont_attribute6
   ,p_mirror_cont_attribute7      =>  p_mirror_cont_attribute7
   ,p_mirror_cont_attribute8      =>  p_mirror_cont_attribute8
   ,p_mirror_cont_attribute9      =>  p_mirror_cont_attribute9
   ,p_mirror_cont_attribute10     =>  p_mirror_cont_attribute10
   ,p_mirror_cont_attribute11     =>  p_mirror_cont_attribute11
   ,p_mirror_cont_attribute12     =>  p_mirror_cont_attribute12
   ,p_mirror_cont_attribute13     =>  p_mirror_cont_attribute13
   ,p_mirror_cont_attribute14     =>  p_mirror_cont_attribute14
   ,p_mirror_cont_attribute15     =>  p_mirror_cont_attribute15
   ,p_mirror_cont_attribute16     =>  p_mirror_cont_attribute16
   ,p_mirror_cont_attribute17     =>  p_mirror_cont_attribute17
   ,p_mirror_cont_attribute18     =>  p_mirror_cont_attribute18
   ,p_mirror_cont_attribute19     =>  p_mirror_cont_attribute19
   ,p_mirror_cont_attribute20     =>  p_mirror_cont_attribute20
   ,P_MIRROR_CONT_INFORMATION_CAT => P_MIRROR_CONT_INFORMATION_CAT
   ,P_MIRROR_CONT_INFORMATION1    => P_MIRROR_CONT_INFORMATION1
   ,P_MIRROR_CONT_INFORMATION2    => P_MIRROR_CONT_INFORMATION2
   ,P_MIRROR_CONT_INFORMATION3    => P_MIRROR_CONT_INFORMATION3
   ,P_MIRROR_CONT_INFORMATION4    => P_MIRROR_CONT_INFORMATION4
   ,P_MIRROR_CONT_INFORMATION5    => P_MIRROR_CONT_INFORMATION5
   ,P_MIRROR_CONT_INFORMATION6    => P_MIRROR_CONT_INFORMATION6
   ,P_MIRROR_CONT_INFORMATION7    => P_MIRROR_CONT_INFORMATION7
   ,P_MIRROR_CONT_INFORMATION8    => P_MIRROR_CONT_INFORMATION8
   ,P_MIRROR_CONT_INFORMATION9    => P_MIRROR_CONT_INFORMATION9
   ,P_MIRROR_CONT_INFORMATION10    => P_MIRROR_CONT_INFORMATION10
   ,P_MIRROR_CONT_INFORMATION11    => P_MIRROR_CONT_INFORMATION11
   ,P_MIRROR_CONT_INFORMATION12    => P_MIRROR_CONT_INFORMATION12
   ,P_MIRROR_CONT_INFORMATION13    => P_MIRROR_CONT_INFORMATION13
   ,P_MIRROR_CONT_INFORMATION14    => P_MIRROR_CONT_INFORMATION14
   ,P_MIRROR_CONT_INFORMATION15    => P_MIRROR_CONT_INFORMATION15
   ,P_MIRROR_CONT_INFORMATION16    => P_MIRROR_CONT_INFORMATION16
   ,P_MIRROR_CONT_INFORMATION17    => P_MIRROR_CONT_INFORMATION17
   ,P_MIRROR_CONT_INFORMATION18    => P_MIRROR_CONT_INFORMATION18
   ,P_MIRROR_CONT_INFORMATION19    => P_MIRROR_CONT_INFORMATION19
   ,P_MIRROR_CONT_INFORMATION20    => P_MIRROR_CONT_INFORMATION20
   ,p_contact_relationship_id     => p_contact_relationship_id
   ,p_ctr_object_version_number   => p_ctr_object_version_number
   ,p_per_person_id               => p_per_person_id
   ,p_per_object_version_number   => p_per_object_version_number
   ,p_per_effective_start_date    => p_per_effective_start_date
   ,p_per_effective_end_date      => p_per_effective_end_date
   ,p_full_name                   => p_full_name
   ,p_per_comment_id              => p_per_comment_id
   ,p_name_combination_warning    => p_name_combination_warning
   ,p_orig_hire_warning           => p_orig_hire_warning
   );
   --
  if (p_contact_operation in ('EMER_CR_NEW_CONT','EMER_CR_NEW_REL')) OR (p_emrg_cont_flag = 'Y') then
  hr_utility.set_location('EMER_CR_NEW_CONT or EMER_CR_NEW_REL:'||l_proc, 10);
  hr_contact_rel_api.create_contact(
    p_validate                 		=>  p_validate -- l_validate_mode
   ,p_start_date               		=>  p_start_date --p_start_date
   ,p_business_group_id        		=>  p_business_group_id
   ,p_person_id                		=>  p_person_id
   ,p_contact_person_id        		=>  p_contact_person_id
   ,p_contact_type             		=>  'EMRG'
   ,p_ctr_comments             		=>  p_ctr_comments
   ,p_primary_contact_flag     		=>  p_primary_contact_flag
   ,p_date_start               		=>  p_date_start
   ,p_start_life_reason_id     		=>  p_start_life_reason_id
   ,p_date_end                 		=>  p_date_end
   ,p_end_life_reason_id       		=>  p_end_life_reason_id
   ,p_rltd_per_rsds_w_dsgntr_flag     	=>  p_rltd_per_rsds_w_dsgntr_flag
   ,p_personal_flag                   	=>  p_personal_flag
   ,p_sequence_number                 	=>  p_sequence_number
   ,p_cont_attribute_category     	=>  p_cont_attribute_category
   ,p_cont_attribute1                 	=>  p_cont_attribute1
   ,p_cont_attribute2                 	=>  p_cont_attribute2
   ,p_cont_attribute3                 	=>  p_cont_attribute3
   ,p_cont_attribute4                 	=>  p_cont_attribute4
   ,p_cont_attribute5     		=>  p_cont_attribute5
   ,p_cont_attribute6     		=>  p_cont_attribute6
   ,p_cont_attribute7     		=>  p_cont_attribute7
   ,p_cont_attribute8     		=>  p_cont_attribute8
   ,p_cont_attribute9     		=>  p_cont_attribute9
   ,p_cont_attribute10     		=>  p_cont_attribute10
   ,p_cont_attribute11     		=>  p_cont_attribute11
   ,p_cont_attribute12     		=>  p_cont_attribute12
   ,p_cont_attribute13     		=>  p_cont_attribute13
   ,p_cont_attribute14     		=>  p_cont_attribute14
   ,p_cont_attribute15     		=>  p_cont_attribute15
   ,p_cont_attribute16     		=>  p_cont_attribute16
   ,p_cont_attribute17     		=>  p_cont_attribute17
   ,p_cont_attribute18     		=>  p_cont_attribute18
   ,p_cont_attribute19     		=>  p_cont_attribute19
   ,p_cont_attribute20    		=>  p_cont_attribute20
   ,p_cont_information_category         =>  p_cont_information_category
   ,p_cont_information1                 =>  p_cont_information1
   ,p_cont_information2                 =>  p_cont_information2
   ,p_cont_information3                 =>  p_cont_information3
   ,p_cont_information4                 =>  p_cont_information4
   ,p_cont_information5                 =>  p_cont_information5
   ,p_cont_information6                 =>  p_cont_information6
   ,p_cont_information7                 =>  p_cont_information7
   ,p_cont_information8                 =>  p_cont_information8
   ,p_cont_information9                 =>  p_cont_information9
   ,p_cont_information10                =>  p_cont_information10
   ,p_cont_information11                =>  p_cont_information11
   ,p_cont_information12                =>  p_cont_information12
   ,p_cont_information13                =>  p_cont_information13
   ,p_cont_information14                =>  p_cont_information14
   ,p_cont_information15                =>  p_cont_information15
   ,p_cont_information16                =>  p_cont_information16
   ,p_cont_information17                =>  p_cont_information17
   ,p_cont_information18                =>  p_cont_information18
   ,p_cont_information19                =>  p_cont_information19
   ,p_cont_information20                =>  p_cont_information20
   ,p_third_party_pay_flag     		=>  p_third_party_pay_flag
   ,p_bondholder_flag     		=>  p_bondholder_flag
   ,p_dependent_flag     		=>  p_dependent_flag
   ,p_beneficiary_flag     		=>  p_beneficiary_flag
   ,p_last_name     			=>  p_last_name
   ,p_sex     				=>  p_sex
   ,p_person_type_id     		=>  p_person_type_id
   ,p_per_comments     			=>  p_per_comments
   ,p_date_of_birth     		=>  p_date_of_birth
   ,p_email_address     		=>  p_email_address
   ,p_first_name     			=>  p_first_name
   ,p_known_as     			=>  p_known_as
   ,p_marital_status     		=>  p_marital_status
   ,p_middle_names     			=>  p_middle_names
   ,p_nationality     			=>  p_nationality
   ,p_national_identifier     		=>  p_national_identifier
   ,p_previous_last_name     		=>  p_previous_last_name
   ,p_registered_disabled_flag     	=>  p_registered_disabled_flag
   ,p_title     			=>  p_title
   ,p_work_telephone     		=>  p_work_telephone
   ,p_attribute_category     		=>  p_attribute_category
   ,p_attribute1     			=>  p_attribute1
   ,p_attribute2     			=>  p_attribute2
   ,p_attribute3     			=>  p_attribute3
   ,p_attribute4     			=>  p_attribute4
   ,p_attribute5     			=>  p_attribute5
   ,p_attribute6     			=>  p_attribute6
   ,p_attribute7     			=>  p_attribute7
   ,p_attribute8     			=>  p_attribute8
   ,p_attribute9     			=>  p_attribute9
   ,p_attribute10     			=>  p_attribute10
   ,p_attribute11     			=>  p_attribute11
   ,p_attribute12     			=>  p_attribute12
   ,p_attribute13     			=>  p_attribute13
   ,p_attribute14     			=>  p_attribute14
   ,p_attribute15     			=>  p_attribute15
   ,p_attribute16     			=>  p_attribute16
   ,p_attribute17     			=>  p_attribute17
   ,p_attribute18     			=>  p_attribute18
   ,p_attribute19     			=>  p_attribute19
   ,p_attribute20     			=>  p_attribute20
   ,p_attribute21     			=>  p_attribute21
   ,p_attribute22     			=>  p_attribute22
   ,p_attribute23     			=>  p_attribute23
   ,p_attribute24     			=>  p_attribute24
   ,p_attribute25     			=>  p_attribute25
   ,p_attribute26     			=>  p_attribute26
   ,p_attribute27     			=>  p_attribute27
   ,p_attribute28     			=>  p_attribute28
   ,p_attribute29     			=>  p_attribute29
   ,p_attribute30     			=>  p_attribute30
   ,p_per_information_category     	=>  p_per_information_category
   ,p_per_information1      =>  p_per_information1
   ,p_per_information2      =>  p_per_information2
   ,p_per_information3      =>  p_per_information3
   ,p_per_information4      =>  p_per_information4
   ,p_per_information5      =>  p_per_information5
   ,p_per_information6      =>  p_per_information6
   ,p_per_information7      =>  p_per_information7
   ,p_per_information8      =>  p_per_information8
   ,p_per_information9      =>  p_per_information9
   ,p_per_information10     =>  p_per_information10
   ,p_per_information11     =>  p_per_information11
   ,p_per_information12     =>  p_per_information12
   ,p_per_information13     =>  p_per_information13
   ,p_per_information14     =>  p_per_information14
   ,p_per_information15     =>  p_per_information15
   ,p_per_information16     =>  p_per_information16
   ,p_per_information17     =>  p_per_information17
   ,p_per_information18     =>  p_per_information18
   ,p_per_information19     =>  p_per_information19
   ,p_per_information20     =>  p_per_information20
   ,p_per_information21     =>  p_per_information21
   ,p_per_information22     =>  p_per_information22
   ,p_per_information23     =>  p_per_information23
   ,p_per_information24     =>  p_per_information24
   ,p_per_information25     =>  p_per_information25
   ,p_per_information26     =>  p_per_information26
   ,p_per_information27     =>  p_per_information27
   ,p_per_information28     =>  p_per_information28
   ,p_per_information29     =>  p_per_information29
   ,p_per_information30     =>  p_per_information30
   ,p_correspondence_language   =>  p_correspondence_language
   ,p_honors     		=>  p_honors
   ,p_pre_name_adjunct     	=>  p_pre_name_adjunct
   ,p_suffix     		=>  p_suffix
   ,p_create_mirror_flag     	=>  p_create_mirror_flag
   ,p_mirror_type     		=>  p_mirror_type
   ,p_mirror_cont_attribute_cat   =>  p_mirror_cont_attribute_cat
   ,p_mirror_cont_attribute1      =>  p_mirror_cont_attribute1
   ,p_mirror_cont_attribute2      =>  p_mirror_cont_attribute2
   ,p_mirror_cont_attribute3      =>  p_mirror_cont_attribute3
   ,p_mirror_cont_attribute4      =>  p_mirror_cont_attribute4
   ,p_mirror_cont_attribute5      =>  p_mirror_cont_attribute5
   ,p_mirror_cont_attribute6      =>  p_mirror_cont_attribute6
   ,p_mirror_cont_attribute7      =>  p_mirror_cont_attribute7
   ,p_mirror_cont_attribute8      =>  p_mirror_cont_attribute8
   ,p_mirror_cont_attribute9      =>  p_mirror_cont_attribute9
   ,p_mirror_cont_attribute10     =>  p_mirror_cont_attribute10
   ,p_mirror_cont_attribute11     =>  p_mirror_cont_attribute11
   ,p_mirror_cont_attribute12     =>  p_mirror_cont_attribute12
   ,p_mirror_cont_attribute13     =>  p_mirror_cont_attribute13
   ,p_mirror_cont_attribute14     =>  p_mirror_cont_attribute14
   ,p_mirror_cont_attribute15     =>  p_mirror_cont_attribute15
   ,p_mirror_cont_attribute16     =>  p_mirror_cont_attribute16
   ,p_mirror_cont_attribute17     =>  p_mirror_cont_attribute17
   ,p_mirror_cont_attribute18     =>  p_mirror_cont_attribute18
   ,p_mirror_cont_attribute19     =>  p_mirror_cont_attribute19
   ,p_mirror_cont_attribute20     =>  p_mirror_cont_attribute20
   ,P_MIRROR_CONT_INFORMATION_CAT => P_MIRROR_CONT_INFORMATION_CAT
   ,P_MIRROR_CONT_INFORMATION1    => P_MIRROR_CONT_INFORMATION1
   ,P_MIRROR_CONT_INFORMATION2    => P_MIRROR_CONT_INFORMATION2
   ,P_MIRROR_CONT_INFORMATION3    => P_MIRROR_CONT_INFORMATION3
   ,P_MIRROR_CONT_INFORMATION4    => P_MIRROR_CONT_INFORMATION4
   ,P_MIRROR_CONT_INFORMATION5    => P_MIRROR_CONT_INFORMATION5
   ,P_MIRROR_CONT_INFORMATION6    => P_MIRROR_CONT_INFORMATION6
   ,P_MIRROR_CONT_INFORMATION7    => P_MIRROR_CONT_INFORMATION7
   ,P_MIRROR_CONT_INFORMATION8    => P_MIRROR_CONT_INFORMATION8
   ,P_MIRROR_CONT_INFORMATION9    => P_MIRROR_CONT_INFORMATION9
   ,P_MIRROR_CONT_INFORMATION10    => P_MIRROR_CONT_INFORMATION10
   ,P_MIRROR_CONT_INFORMATION11    => P_MIRROR_CONT_INFORMATION11
   ,P_MIRROR_CONT_INFORMATION12    => P_MIRROR_CONT_INFORMATION12
   ,P_MIRROR_CONT_INFORMATION13    => P_MIRROR_CONT_INFORMATION13
   ,P_MIRROR_CONT_INFORMATION14    => P_MIRROR_CONT_INFORMATION14
   ,P_MIRROR_CONT_INFORMATION15    => P_MIRROR_CONT_INFORMATION15
   ,P_MIRROR_CONT_INFORMATION16    => P_MIRROR_CONT_INFORMATION16
   ,P_MIRROR_CONT_INFORMATION17    => P_MIRROR_CONT_INFORMATION17
   ,P_MIRROR_CONT_INFORMATION18    => P_MIRROR_CONT_INFORMATION18
   ,P_MIRROR_CONT_INFORMATION19    => P_MIRROR_CONT_INFORMATION19
   ,P_MIRROR_CONT_INFORMATION20    => P_MIRROR_CONT_INFORMATION20
   ,p_contact_relationship_id     => p_contact_relationship_id
   ,p_ctr_object_version_number   => p_ctr_object_version_number
   ,p_per_person_id               => p_per_person_id
   ,p_per_object_version_number   => p_per_object_version_number
   ,p_per_effective_start_date    => p_per_effective_start_date
   ,p_per_effective_end_date      => p_per_effective_end_date
   ,p_full_name                   => p_full_name
   ,p_per_comment_id              => p_per_comment_id
   ,p_name_combination_warning    => p_name_combination_warning
   ,p_orig_hire_warning           => p_orig_hire_warning
   );
  end if;
  hr_utility.set_location('Exiting:'||l_proc, 20);
 end call_contact_api;
--

procedure get_emrg_rel_id (
   p_contact_relationship_id          in number
  ,p_contact_person_id                in number
  ,p_emrg_rel_id                      out nocopy varchar2
  ,p_no_of_non_emrg_rel               out nocopy varchar2
  ,p_other_rel_type                   out nocopy varchar2
  ,p_emrg_rel_type                    out nocopy varchar2)
is
   l_person_id                                     number;
   cursor no_of_non_emrg_rel(p_contact_relationship_id  number
                            ,p_contact_person_id        number )
   is
   select count(pcr.contact_relationship_id)
   from PER_CONTACT_RELATIONSHIPS pcr
   where person_id = (select person_id
                      from PER_CONTACT_RELATIONSHIPS
                      where contact_person_id = p_contact_person_id
                      and contact_relationship_id = P_contact_relationship_id
                      and trunc(sysdate) >= decode(date_start,null,trunc(sysdate),trunc(date_start))
                      and trunc(sysdate) <  decode(date_end,null,trunc(sysdate)+1,trunc(date_end)))
   and exists  (select 1
                from per_contact_relationships con
                where con.contact_type =  'EMRG'
                and con.contact_person_id = p_contact_person_id
                and con.person_id = pcr.person_id
                and trunc(sysdate) >= decode(con.date_start,null,trunc(sysdate),trunc(con.date_start))
                and trunc(sysdate) <  decode(con.date_end,null,trunc(sysdate)+1,trunc(con.date_end)))
   and pcr.contact_person_id = p_contact_person_id
   and pcr.contact_type <> 'EMRG'
   and pcr.personal_flag = 'Y'
   and trunc(sysdate) >= decode(pcr.date_start,null,trunc(sysdate),trunc(pcr.date_start))
   and trunc(sysdate) <  decode(pcr.date_end,null,trunc(sysdate)+1,trunc(pcr.date_end));

   cursor emrg_rel_id(p_contact_relationship_id     number
                     ,p_contact_person_id           number )
   is
   select contact_relationship_id,
         HR_GENERAL.DECODE_LOOKUP('CONTACT', contact_type) relationship
   from PER_CONTACT_RELATIONSHIPS
   where person_id = (select person_id
                      from PER_CONTACT_RELATIONSHIPS
                      where contact_person_id = p_contact_person_id
                      and contact_relationship_id = P_contact_relationship_id
                      and trunc(sysdate) >= decode(date_start,null,trunc(sysdate),trunc(date_start))
                      and trunc(sysdate) <  decode(date_end,null,trunc(sysdate)+1,trunc(date_end)))
   and contact_person_id = p_contact_person_id
   and contact_type = 'EMRG'
   and trunc(sysdate) >= decode(date_start,null,trunc(sysdate),trunc(date_start))
   and trunc(sysdate) <  decode(date_end,null,trunc(sysdate)+1,trunc(date_end));

   cursor other_rel_type(p_contact_relationship_id     number
                     ,p_contact_person_id           number )
   is
   select HR_GENERAL.DECODE_LOOKUP('CONTACT', pcr.contact_type) relationship
   from PER_CONTACT_RELATIONSHIPS pcr
   where pcr.contact_person_id = p_contact_person_id
   and pcr.contact_relationship_id = p_contact_relationship_id
   and trunc(sysdate) >= decode(pcr.date_start,null,trunc(sysdate),trunc(pcr.date_start))
   and trunc(sysdate) <  decode(pcr.date_end,null,trunc(sysdate)+1,trunc(pcr.date_end));

   l_emrg_rel_id          varchar2(20);
   l_no_of_non_emrg_rel   varchar2(20);
   l_other_rel_type       varchar2(200);
   l_emrg_rel_type       varchar2(200);
   l_proc   varchar2(72)  := g_package||'get_emrg_rel_id';

begin

   hr_utility.set_location('Entering:'||l_proc, 5);
   hr_utility.set_location('Before Fetching no_of_non_emrg_rel:'||l_proc, 10);
   open no_of_non_emrg_rel(p_contact_relationship_id,p_contact_person_id);
   fetch no_of_non_emrg_rel
   into l_no_of_non_emrg_rel;
   IF no_of_non_emrg_rel%NOTFOUND THEN
   l_no_of_non_emrg_rel := '0';
   end if;
   close no_of_non_emrg_rel;

   open emrg_rel_id(p_contact_relationship_id,p_contact_person_id);
   fetch emrg_rel_id
   into l_emrg_rel_id, l_emrg_rel_type;
   IF emrg_rel_id%NOTFOUND THEN
   l_emrg_rel_id := '-1';
   l_emrg_rel_type := '';
   end if;

   close emrg_rel_id;


   open other_rel_type(p_contact_relationship_id,p_contact_person_id);
   fetch other_rel_type into l_other_rel_type;
   IF other_rel_type%NOTFOUND THEN
     l_other_rel_type := '';
   end if;

   close other_rel_type;

   p_emrg_rel_id := l_emrg_rel_id;
   p_no_of_non_emrg_rel := l_no_of_non_emrg_rel;
   p_other_rel_type := l_other_rel_type;
   p_emrg_rel_type :=  l_emrg_rel_type;
   hr_utility.set_location('Exiting:'||l_proc, 25);
end get_emrg_rel_id;

--
procedure validate_rel_start_date (
   p_person_id                        in number
  ,p_item_key                         in varchar2
  ,p_save_mode                        in varchar2
  ,p_date_start                       in out nocopy date
  ,p_date_of_birth                    in date)
is
 /*
--  bug # 2168275
   requirement : If relation_ship_start_date < (DOB of Employee) or (DOB of Contact), then
                 raise error message PER_50386_CON_SDT_LES_EMP_BDT.

    1. Get emplyee record start date

        if employee id is available, then
            get  Employee_DOB from per_people_f
        else
            get Employee_DOB from transaction_step

    1. if l_main_per_date_of_birth is not null and l_main_per_date_of_birth > p_date_start then
        raise error;
        set errormessage .....
    elsif p_date_of_birth is not null and p_date_of_birth > p_date_start then
        raise error;
        set errormessage .....

    2. Compare the DOBs with  p_date_start
        If  Employee_DOB > p_date_start then
            raise error.
        Else
            If  p_date_of_birth > p_date_start then
            raise error.

--  end bug # 2168275
*/

  --bug # 2168275,2123868
 l_validate_g_per_step_id            number;
 l_main_per_eff_start_date           date;
 l_main_per_date_of_birth            date;
 l_proc   varchar2(72)  := g_package||'validate_rel_start_date';
begin

    hr_utility.set_location('Entering:'||l_proc, 5);
    if p_person_id is not null then
        hr_utility.set_location('if p_person_id is not null then:'||l_proc, 10);
        select  min(p.date_of_birth) , min(p.effective_start_date)
        into    l_main_per_date_of_birth , l_main_per_eff_start_date
        from    per_people_f p
        where   p.person_id = p_person_id;
    else
        begin
            hr_utility.set_location('if p_person_id is not null then:'||l_proc, 15);
            select nvl(max(hats1.transaction_step_id),0)
            into   l_validate_g_per_step_id
            from   hr_api_transaction_steps hats1
            where  hats1.item_type = 'HRSSA'
            and    hats1.item_key  = p_item_key
            and    hats1.api_name  in( 'HR_PROCESS_PERSON_SS.PROCESS_API', 'BEN_PROCESS_COBRA_PERSON_SS.PROCESS_API');

            l_main_per_date_of_birth := hr_transaction_api.get_date_value
                                (p_transaction_step_id => l_validate_g_per_step_id
                                ,p_name => 'P_DATE_OF_BIRTH') ;

            l_main_per_eff_start_date := hr_transaction_api.get_date_value
                                (p_transaction_step_id => l_validate_g_per_step_id
                                ,p_name => 'P_EFFECTIVE_DATE');

        exception
            when others then
            hr_utility.set_location('Exception:Others'||l_proc,555);
            null;
        end;

    end if; --l_person_id is/not null

    -- raise error if relationship start date is earlier tahn date of birth
-- fix for bug # 2221040
    if  nvl(p_save_mode, 'NVL') <> 'SAVE_FOR_LATER'
      then
       if l_main_per_date_of_birth is not null and l_main_per_date_of_birth > p_date_start then
          hr_utility.set_message(800, 'PER_50386_CON_SDT_LES_EMP_BDT');
          hr_utility.raise_error;
       elsif p_date_of_birth is not null and p_date_of_birth > p_date_start then
          hr_utility.set_message(800, 'PER_50386_CON_SDT_LES_EMP_BDT');
          hr_utility.raise_error;
       end if;
    end if;
-- l_main_per_eff_start_date will be used in Create_Contact_tt , so we need to return it.
p_date_start := l_main_per_eff_start_date;
hr_utility.set_location('Exiting:'||l_proc, 15);
end validate_rel_start_date;

--

Procedure validate_primary_cont_flag(
   p_contact_relationship_id          in number
  ,p_primary_contact_flag             in varchar2
  ,p_date_start                       in date
  ,p_contact_person_id                in number
  ,p_object_version_number             in out nocopy    number)

is

l_emerg_cont_rel_id            number;

l_emrg_rel_id                  varchar2(50);
l_no_of_non_emrg_rel           varchar2(50);
l_other_rel_type               varchar2(50);
l_emrg_rel_type                varchar2(50);
l_proc   varchar2(72)  := g_package||'validate_primary_cont_flag';

CURSOR gc_get_emerg_contact_data
         (p_contact_relationship_id      in number
         ,p_eff_date                     in date default trunc(sysdate)
          )
  IS
  SELECT
  primary_contact_flag,
  pcr.object_version_number ovn
  FROM
      per_contact_relationships pcr
     ,per_all_people_f pap
     ,hr_comments        hc
  WHERE  pcr.contact_relationship_id = p_contact_relationship_id
    AND  pcr.contact_person_id = pap.person_id
    AND  p_eff_date BETWEEN pap.effective_start_date and pap.effective_end_date
    AND  hc.comment_id (+) = pap.comment_id;

l_emerg_contact_data               gc_get_emerg_contact_data%rowtype;

begin


   hr_utility.set_location('Entering:'||l_proc, 5);
   get_emrg_rel_id ( P_contact_relationship_id => p_contact_relationship_id
                    ,p_contact_person_id       => p_contact_person_id
                    ,p_emrg_rel_id             => l_emrg_rel_id
                    ,p_no_of_non_emrg_rel      => l_no_of_non_emrg_rel
                    ,p_other_rel_type          => l_other_rel_type
                    ,p_emrg_rel_type           => l_emrg_rel_type);
   l_emerg_cont_rel_id := to_number(l_emrg_rel_id);

   hr_utility.set_location('Before fetching gc_get_emerg_contact_data:'||l_proc,10 );
   OPEN gc_get_emerg_contact_data(p_contact_relationship_id => l_emerg_cont_rel_id);

   FETCH gc_get_emerg_contact_data into l_emerg_contact_data;
   IF gc_get_emerg_contact_data%NOTFOUND THEN
     CLOSE gc_get_emerg_contact_data;
     raise g_data_error;
   ELSE
     CLOSE gc_get_emerg_contact_data;
   END IF;
-- Bug 3504216 : passing date_start as sysdate.
      hr_contact_rel_api.update_contact_relationship(
         p_validate                => false
        ,P_EFFECTIVE_DATE          => sysdate
        ,p_object_version_number   => l_emerg_contact_data.ovn
        ,P_CONTACT_RELATIONSHIP_ID => l_emerg_cont_rel_id
        ,p_date_start              => sysdate
        ,P_PRIMARY_CONTACT_FLAG     => p_primary_contact_flag
     );

   if p_contact_relationship_id = l_emerg_cont_rel_id then
      p_object_version_number := l_emerg_contact_data.ovn;
   end if;

hr_utility.set_location('Exiting:'||l_proc, 15);
end validate_primary_cont_flag;

--

END HR_PROCESS_CONTACT_SS;

/
