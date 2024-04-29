--------------------------------------------------------
--  DDL for Package Body HR_ENTRY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ENTRY_API" as
/* $Header: pyentapi.pkb 120.7.12010000.8 2010/02/18 06:49:08 sivanara ship $ */
 --
 -- Record defined to hold information about a entry element that is being
 -- updated.
 --
 g_debug boolean := hr_utility.debug_enabled;
 g_counter number;
 --
 type t_update_entry_rec is record
   (cost_allocation_keyflex_id number,
    updating_action_id         number,
    updating_action_type       varchar2(30),
    original_entry_id          number,
    creator_type               varchar2(30),
    comment_id                 number,
    creator_id                 number,
    reason                     varchar2(30),
    subpriority                number,
    date_earned                 date,
    personal_payment_method_id  number,
    attribute_category         varchar2(60),
    attribute1                 varchar2(150),
    attribute2                 varchar2(150),
    attribute3                 varchar2(150),
    attribute4                 varchar2(150),
    attribute5                 varchar2(150),
    attribute6                 varchar2(150),
    attribute7                 varchar2(150),
    attribute8                 varchar2(150),
    attribute9                 varchar2(150),
    attribute10                varchar2(150),
    attribute11                varchar2(150),
    attribute12                varchar2(150),
    attribute13                varchar2(150),
    attribute14                varchar2(150),
    attribute15                varchar2(150),
    attribute16                varchar2(150),
    attribute17                varchar2(150),
    attribute18                varchar2(150),
    attribute19                varchar2(150),
    attribute20                varchar2(150),
    effective_start_date       date,
    effective_end_date         date,
    target_entry_id            number,
    entry_type                 varchar2(30),
    element_link_id            number,
    assignment_id              number,
    element_type_id            number,
    processing_type            varchar2(30),
    input_currency_code        varchar2(30),
    output_currency_code       varchar2(30),
    entry_information_category varchar2(30),
    entry_information1         varchar2(150),
    entry_information2         varchar2(150),
    entry_information3         varchar2(150),
    entry_information4         varchar2(150),
    entry_information5         varchar2(150),
    entry_information6         varchar2(150),
    entry_information7         varchar2(150),
    entry_information8         varchar2(150),
    entry_information9         varchar2(150),
    entry_information10        varchar2(150),
    entry_information11        varchar2(150),
    entry_information12        varchar2(150),
    entry_information13        varchar2(150),
    entry_information14        varchar2(150),
    entry_information15        varchar2(150),
    entry_information16        varchar2(150),
    entry_information17        varchar2(150),
    entry_information18        varchar2(150),
    entry_information19        varchar2(150),
    entry_information20        varchar2(150),
    entry_information21        varchar2(150),
    entry_information22        varchar2(150),
    entry_information23        varchar2(150),
    entry_information24        varchar2(150),
    entry_information25        varchar2(150),
    entry_information26        varchar2(150),
    entry_information27        varchar2(150),
    entry_information28        varchar2(150),
    entry_information29        varchar2(150),
    entry_information30        varchar2(150)
);
 --
 -- Record defined to hold information about a entry element that is being
 -- removed.
 --
 type t_delete_entry_rec is record
   (original_entry_id    number,
    effective_start_date date,
    effective_end_date   date,
    assignment_id        number,
    element_link_id      number,
    entry_type           varchar2(30),
    creator_type         varchar2(30),
    creator_id           number,
    target_entry_id      number,
    element_type_id      number,
    processing_type      varchar2(30),
    non_payments_flag    varchar2(30),
    personal_payment_method_id  number);
 --
 g_package      constant varchar2 (32) := 'hr_entry_api.';
 g_override_user_ent_chk varchar2(1);

 -- Hold context variables for formula validation.  (Fix 1123084).
 -- We do not need to hold the DATE_EARNED context as a variable
 -- because it is available directly within the appropriate routine.
 -- Also hold some other useful information.
 type asg_info_r is record
 (
   assignment_id     number,
   business_group_id number,
   adj_ee_source     varchar2(30)
 );
 g_asg_info asg_info_r;
 --
 ------------------------------------------------------------------------------
 -- Dave Harris, 01-Feb-1994, G590                                           --
 --                                                                          --
 -- NAME                                                                     --
 -- hr_entry_api.element_entry_changed                      PRIVATE FUNCTION --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Determines if the entry to be updated will cause a change on either      --
 -- the PAY_ELEMENT_ENTRIES_F or PAY_ELEMENT_ENTRY_VALUES_F tables.          --
 -- If the entry is going to cause an update against either the              --
 -- PAY_ELEMENT_ENTRIES_F or PAY_ELEMENT_ENTRY_VALUES_F attributes then the  --
 -- return code will be true.                                                --
 ------------------------------------------------------------------------------
--
 function element_entry_changed
 (
  p_driving_date               in date,
  p_element_entry_id           in number,
  p_cost_allocation_keyflex_id in number,
  p_updating_action_id         in number,
  p_updating_action_type       in varchar2,
  p_original_entry_id          in number,
  p_creator_type               in varchar2,
  p_comment_id                 in number,
  p_creator_id                 in number,
  p_reason                     in varchar2,
  p_subpriority                in number,
  p_date_earned                in date,
  p_personal_payment_method_id in number,
  p_attribute_category         in varchar2,
  p_attribute1                 in varchar2,
  p_attribute2                 in varchar2,
  p_attribute3                 in varchar2,
  p_attribute4                 in varchar2,
  p_attribute5                 in varchar2,
  p_attribute6                 in varchar2,
  p_attribute7                 in varchar2,
  p_attribute8                 in varchar2,
  p_attribute9                 in varchar2,
  p_attribute10                in varchar2,
  p_attribute11                in varchar2,
  p_attribute12                in varchar2,
  p_attribute13                in varchar2,
  p_attribute14                in varchar2,
  p_attribute15                in varchar2,
  p_attribute16                in varchar2,
  p_attribute17                in varchar2,
  p_attribute18                in varchar2,
  p_attribute19                in varchar2,
  p_attribute20                in varchar2,
  p_num_entry_values           in number,
  p_input_value_id_tbl         in hr_entry.number_table,
  p_entry_value_tbl            in hr_entry.varchar2_table,
-- --
  p_entry_information_category in varchar2,
  p_entry_information1         in varchar2,
  p_entry_information2         in varchar2,
  p_entry_information3         in varchar2,
  p_entry_information4         in varchar2,
  p_entry_information5         in varchar2,
  p_entry_information6         in varchar2,
  p_entry_information7         in varchar2,
  p_entry_information8         in varchar2,
  p_entry_information9         in varchar2,
  p_entry_information10        in varchar2,
  p_entry_information11        in varchar2,
  p_entry_information12        in varchar2,
  p_entry_information13        in varchar2,
  p_entry_information14        in varchar2,
  p_entry_information15        in varchar2,
  p_entry_information16        in varchar2,
  p_entry_information17        in varchar2,
  p_entry_information18        in varchar2,
  p_entry_information19        in varchar2,
  p_entry_information20        in varchar2,
  p_entry_information21        in varchar2,
  p_entry_information22        in varchar2,
  p_entry_information23        in varchar2,
  p_entry_information24        in varchar2,
  p_entry_information25        in varchar2,
  p_entry_information26        in varchar2,
  p_entry_information27        in varchar2,
  p_entry_information28        in varchar2,
  p_entry_information29        in varchar2,
  p_entry_information30        in varchar2
 ) return boolean is
--
  Cursor select_entry_value is
    select  peev.input_value_id,
            peev.screen_entry_value
    from    pay_element_entry_values_f peev
    where   peev.element_entry_id   = p_element_entry_id
    and     p_driving_date
    between peev.effective_start_date
    and     peev.effective_end_date;
   --
   -- Local Variables
   --
   l_entry_changed      boolean         := false;
   l_check_entry_values varchar2(10)    := 'N';
   l_loop_counter       number          := 1;
   --
   -- Cursor returning variables
   --
   l_input_value_id     pay_element_entry_values_f.input_value_id%TYPE;
   l_screen_entry_value pay_element_entry_values_f.screen_entry_value%TYPE;
   --
   -- Function error variables
   --
   l_appid              number          := 801;
   l_proc_func_name     varchar2(60)    := 'hr_entry_api.element_entry_changed';
   l_proc_func_error    varchar2(30)    := 'HR_6153_ALL_PROCEDURE_FAIL';
   --
 begin
   --
   -- Need to determine if the PAY_ELEMENT_ENTRIES_F table is being
   -- updated with any new values.
   -- If No change is being made against PAY_ELEMENT_ENTRIES_F we
   -- then need to determine if any PAY_ELEMENT_ENTRY_VALUES_F are
   -- being updated.
   -- However, if a change is going to place against the PAY_ELEMENT_ENTRIES_F
   -- table then we don't need to check against a change to the
   -- PAY_ELEMENT_ENTRY_VALUES_F table.
   --
   if g_debug then
      hr_utility.set_location(l_proc_func_name, 5);
   end if;
   begin
     select  'Y'
     into    l_check_entry_values
     from    sys.dual
     where   exists
      (select  1
       from    pay_element_entries_f pee
       where   pee.element_entry_id     = p_element_entry_id
       and     p_driving_date
       between pee.effective_start_date
       and     pee.effective_end_date
       and     nvl(pee.cost_allocation_keyflex_id,hr_api.g_number) =
               decode(p_cost_allocation_keyflex_id,
                      hr_api.g_number, nvl(pee.cost_allocation_keyflex_id,hr_api.g_number),
                         p_cost_allocation_keyflex_id)
       and     nvl(pee.updating_action_id,hr_api.g_number) =
               decode(p_updating_action_id,
                      hr_api.g_number, nvl(pee.updating_action_id,hr_api.g_number), p_updating_action_id)
       and     nvl(pee.updating_action_type,hr_api.g_varchar2) =
               decode(p_updating_action_type,
                      hr_api.g_varchar2, nvl(pee.updating_action_type,hr_api.g_varchar2), p_updating_action_type)
       and     nvl(pee.original_entry_id,hr_api.g_number) =
               decode(p_original_entry_id, hr_api.g_number, nvl(pee.original_entry_id,hr_api.g_number),
                      p_original_entry_id)
       and     pee.creator_type =
               decode(p_creator_type, hr_api.g_varchar2, pee.creator_type, p_creator_type)
       and     nvl(pee.comment_id,hr_api.g_number) =
               decode(p_comment_id, hr_api.g_number, nvl(pee.comment_id,hr_api.g_number), p_comment_id)
       and     nvl(pee.creator_id,hr_api.g_number) =
               decode(p_creator_id, hr_api.g_number, nvl(pee.creator_id,hr_api.g_number), p_creator_id)
       and     nvl(pee.reason,hr_api.g_varchar2) =
               decode(p_reason, hr_api.g_varchar2, nvl(pee.reason,hr_api.g_varchar2), p_reason)
       and     nvl(pee.subpriority,hr_api.g_number) =
               decode(p_subpriority,
                      hr_api.g_number, nvl(pee.subpriority,hr_api.g_number), p_subpriority)
       and     nvl(pee.date_earned,hr_api.g_date) =
               decode(p_date_earned,
                      hr_api.g_date, nvl(pee.date_earned,hr_api.g_date), p_date_earned)
       and     nvl(pee.personal_payment_method_id,hr_api.g_number) =
               decode(p_personal_payment_method_id,
                      hr_api.g_number, nvl(pee.personal_payment_method_id,hr_api.g_number), p_personal_payment_method_id)
       and     nvl(pee.attribute_category, hr_api.g_varchar2) =
               decode(p_attribute_category, hr_api.g_varchar2,
                      nvl(pee.attribute_category,hr_api.g_varchar2),
                      p_attribute_category)
       and     nvl(pee.attribute1,hr_api.g_varchar2) =
               decode(p_attribute1, hr_api.g_varchar2, nvl(pee.attribute1,hr_api.g_varchar2),
                      p_attribute1)
       and     nvl(pee.attribute2,hr_api.g_varchar2) =
               decode(p_attribute2, hr_api.g_varchar2, nvl(pee.attribute2,hr_api.g_varchar2),
                      p_attribute2)
       and     nvl(pee.attribute3,hr_api.g_varchar2) =
               decode(p_attribute3, hr_api.g_varchar2, nvl(pee.attribute3,hr_api.g_varchar2),
                      p_attribute3)
       and     nvl(pee.attribute4,hr_api.g_varchar2) =
               decode(p_attribute4, hr_api.g_varchar2, nvl(pee.attribute4,hr_api.g_varchar2),
                      p_attribute4)
       and     nvl(pee.attribute5,hr_api.g_varchar2) =
               decode(p_attribute5, hr_api.g_varchar2, nvl(pee.attribute5,hr_api.g_varchar2),
                      p_attribute5)
       and     nvl(pee.attribute6,hr_api.g_varchar2) =
               decode(p_attribute6, hr_api.g_varchar2, nvl(pee.attribute6,hr_api.g_varchar2),
                      p_attribute6)
       and     nvl(pee.attribute7,hr_api.g_varchar2) =
               decode(p_attribute7, hr_api.g_varchar2, nvl(pee.attribute7,hr_api.g_varchar2),
                      p_attribute7)
       and     nvl(pee.attribute8,hr_api.g_varchar2) =
               decode(p_attribute8, hr_api.g_varchar2, nvl(pee.attribute8,hr_api.g_varchar2),
                      p_attribute8)
       and     nvl(pee.attribute9,hr_api.g_varchar2) =
               decode(p_attribute9, hr_api.g_varchar2, nvl(pee.attribute9,hr_api.g_varchar2),
                      p_attribute9)
       and     nvl(pee.attribute10,hr_api.g_varchar2) =
               decode(p_attribute10, hr_api.g_varchar2, nvl(pee.attribute10,hr_api.g_varchar2),
                      p_attribute10)
       and     nvl(pee.attribute11,hr_api.g_varchar2) =
               decode(p_attribute11, hr_api.g_varchar2, nvl(pee.attribute11,hr_api.g_varchar2),
                      p_attribute11)
       and     nvl(pee.attribute12,hr_api.g_varchar2) =
               decode(p_attribute12, hr_api.g_varchar2, nvl(pee.attribute12,hr_api.g_varchar2),
                      p_attribute12)
       and     nvl(pee.attribute13,hr_api.g_varchar2) =
               decode(p_attribute13, hr_api.g_varchar2, nvl(pee.attribute13,hr_api.g_varchar2),
                      p_attribute13)
       and     nvl(pee.attribute14,hr_api.g_varchar2) =
               decode(p_attribute14, hr_api.g_varchar2, nvl(pee.attribute14,hr_api.g_varchar2),
                      p_attribute14)
       and     nvl(pee.attribute15,hr_api.g_varchar2) =
               decode(p_attribute15, hr_api.g_varchar2, nvl(pee.attribute15,hr_api.g_varchar2),
                      p_attribute15)
       and     nvl(pee.attribute16,hr_api.g_varchar2) =
               decode(p_attribute16, hr_api.g_varchar2, nvl(pee.attribute16,hr_api.g_varchar2),
                      p_attribute16)
       and     nvl(pee.attribute17,hr_api.g_varchar2) =
               decode(p_attribute17, hr_api.g_varchar2, nvl(pee.attribute17,hr_api.g_varchar2),
                      p_attribute17)
       and     nvl(pee.attribute18,hr_api.g_varchar2) =
               decode(p_attribute18, hr_api.g_varchar2, nvl(pee.attribute18,hr_api.g_varchar2),
                      p_attribute18)
       and     nvl(pee.attribute19,hr_api.g_varchar2) =
               decode(p_attribute19, hr_api.g_varchar2, nvl(pee.attribute19,hr_api.g_varchar2),
                      p_attribute19)
       and     nvl(pee.attribute20,hr_api.g_varchar2) =
               decode(p_attribute20, hr_api.g_varchar2, nvl(pee.attribute20,hr_api.g_varchar2),
                      p_attribute20)
-- --
       and     nvl(pee.entry_information_category, hr_api.g_varchar2) =
               decode(p_entry_information_category, hr_api.g_varchar2,
                      nvl(pee.entry_information_category,hr_api.g_varchar2),
                      p_entry_information_category)
       and     nvl(pee.entry_information1,hr_api.g_varchar2) =
               decode(p_entry_information1, hr_api.g_varchar2, nvl(pee.entry_information1,hr_api.g_varchar2),
                      p_entry_information1)
       and     nvl(pee.entry_information2,hr_api.g_varchar2) =
               decode(p_entry_information2, hr_api.g_varchar2, nvl(pee.entry_information2,hr_api.g_varchar2),
                      p_entry_information2)
       and     nvl(pee.entry_information3,hr_api.g_varchar2) =
               decode(p_entry_information3, hr_api.g_varchar2, nvl(pee.entry_information3,hr_api.g_varchar2),
                      p_entry_information3)
       and     nvl(pee.entry_information4,hr_api.g_varchar2) =
               decode(p_entry_information4, hr_api.g_varchar2, nvl(pee.entry_information4,hr_api.g_varchar2),
                      p_entry_information4)
       and     nvl(pee.entry_information5,hr_api.g_varchar2) =
               decode(p_entry_information5, hr_api.g_varchar2, nvl(pee.entry_information5,hr_api.g_varchar2),
                      p_entry_information5)
       and     nvl(pee.entry_information6,hr_api.g_varchar2) =
               decode(p_entry_information6, hr_api.g_varchar2, nvl(pee.entry_information6,hr_api.g_varchar2),
                      p_entry_information6)
       and     nvl(pee.entry_information7,hr_api.g_varchar2) =
               decode(p_entry_information7, hr_api.g_varchar2, nvl(pee.entry_information7,hr_api.g_varchar2),
                      p_entry_information7)
       and     nvl(pee.entry_information8,hr_api.g_varchar2) =
               decode(p_entry_information8, hr_api.g_varchar2, nvl(pee.entry_information8,hr_api.g_varchar2),
                      p_entry_information8)
       and     nvl(pee.entry_information9,hr_api.g_varchar2) =
               decode(p_entry_information9, hr_api.g_varchar2, nvl(pee.entry_information9,hr_api.g_varchar2),
                      p_entry_information9)
       and     nvl(pee.entry_information10,hr_api.g_varchar2) =
               decode(p_entry_information10, hr_api.g_varchar2, nvl(pee.entry_information10,hr_api.g_varchar2),
                      p_entry_information10)
       and     nvl(pee.entry_information11,hr_api.g_varchar2) =
               decode(p_entry_information11, hr_api.g_varchar2, nvl(pee.entry_information11,hr_api.g_varchar2),
                      p_entry_information11)
       and     nvl(pee.entry_information12,hr_api.g_varchar2) =
               decode(p_entry_information12, hr_api.g_varchar2, nvl(pee.entry_information12,hr_api.g_varchar2),
                      p_entry_information12)
       and     nvl(pee.entry_information13,hr_api.g_varchar2) =
               decode(p_entry_information13, hr_api.g_varchar2, nvl(pee.entry_information13,hr_api.g_varchar2),
                      p_entry_information13)
       and     nvl(pee.entry_information14,hr_api.g_varchar2) =
               decode(p_entry_information14, hr_api.g_varchar2, nvl(pee.entry_information14,hr_api.g_varchar2),
                      p_entry_information14)
       and     nvl(pee.entry_information15,hr_api.g_varchar2) =
               decode(p_entry_information15, hr_api.g_varchar2, nvl(pee.entry_information15,hr_api.g_varchar2),
                      p_entry_information15)
       and     nvl(pee.entry_information16,hr_api.g_varchar2) =
               decode(p_entry_information16, hr_api.g_varchar2, nvl(pee.entry_information16,hr_api.g_varchar2),
                      p_entry_information16)
       and     nvl(pee.entry_information17,hr_api.g_varchar2) =
               decode(p_entry_information17, hr_api.g_varchar2, nvl(pee.entry_information17,hr_api.g_varchar2),
                      p_entry_information17)
       and     nvl(pee.entry_information18,hr_api.g_varchar2) =
               decode(p_entry_information18, hr_api.g_varchar2, nvl(pee.entry_information18,hr_api.g_varchar2),
                      p_entry_information18)
       and     nvl(pee.entry_information19,hr_api.g_varchar2) =
               decode(p_entry_information19, hr_api.g_varchar2, nvl(pee.entry_information19,hr_api.g_varchar2),
                      p_entry_information19)
       and     nvl(pee.entry_information20,hr_api.g_varchar2) =
               decode(p_entry_information20, hr_api.g_varchar2, nvl(pee.entry_information20,hr_api.g_varchar2),
                      p_entry_information20)
       and     nvl(pee.entry_information21,hr_api.g_varchar2) =
               decode(p_entry_information21, hr_api.g_varchar2, nvl(pee.entry_information21,hr_api.g_varchar2),
                      p_entry_information21)
       and     nvl(pee.entry_information22,hr_api.g_varchar2) =
               decode(p_entry_information22, hr_api.g_varchar2, nvl(pee.entry_information22,hr_api.g_varchar2),
                      p_entry_information22)
       and     nvl(pee.entry_information23,hr_api.g_varchar2) =
               decode(p_entry_information23, hr_api.g_varchar2, nvl(pee.entry_information23,hr_api.g_varchar2),
                      p_entry_information23)
       and     nvl(pee.entry_information24,hr_api.g_varchar2) =
               decode(p_entry_information24, hr_api.g_varchar2, nvl(pee.entry_information24,hr_api.g_varchar2),
                      p_entry_information24)
       and     nvl(pee.entry_information25,hr_api.g_varchar2) =
               decode(p_entry_information25, hr_api.g_varchar2, nvl(pee.entry_information25,hr_api.g_varchar2),
                      p_entry_information25)
       and     nvl(pee.entry_information26,hr_api.g_varchar2) =
               decode(p_entry_information26, hr_api.g_varchar2, nvl(pee.entry_information26,hr_api.g_varchar2),
                      p_entry_information26)
       and     nvl(pee.entry_information27,hr_api.g_varchar2) =
               decode(p_entry_information27, hr_api.g_varchar2, nvl(pee.entry_information27,hr_api.g_varchar2),
                      p_entry_information27)
       and     nvl(pee.entry_information28,hr_api.g_varchar2) =
               decode(p_entry_information28, hr_api.g_varchar2, nvl(pee.entry_information28,hr_api.g_varchar2),
                      p_entry_information28)
       and     nvl(pee.entry_information29,hr_api.g_varchar2) =
               decode(p_entry_information29, hr_api.g_varchar2, nvl(pee.entry_information29,hr_api.g_varchar2),
                      p_entry_information29)
       and     nvl(pee.entry_information30,hr_api.g_varchar2) =
               decode(p_entry_information30, hr_api.g_varchar2, nvl(pee.entry_information30,hr_api.g_varchar2),
                      p_entry_information30)
);
   exception
     When NO_DATA_FOUND then
       null;
   end;
   --
   -- If the entry record to be updated is not updating any of
   -- the PAY_ELEMENT_ENTRIES_F attributes then we must check to
   -- see if any of the PAY_ELEMENT_ENTRY_VALUES_F are to be
   -- updated.
   --
   if (l_check_entry_values = 'Y') then
     --
     -- for each entry value ensure that the input_value_id and
     -- screen_entry_value from the respective pl/sql tables
     -- match the PAY_ELEMENT_ENTRY_VALUES_F.
     --
     open select_entry_value;
     while (NOT l_entry_changed) loop
       --
       if g_debug then
          hr_utility.set_location(l_proc_func_name, 10);
       end if;
       --
       -- fetch a row from the select_entry_value cursor returning the
       -- input_value_id and screen_entry_value
       --
       fetch select_entry_value into l_input_value_id, l_screen_entry_value;
       exit when select_entry_value%NOTFOUND;
       --
       -- Having returned the l_input_value_id and l_screen_entry_value
       -- from the select_entry_value cursor we must iterate through the
       -- p_input_value_id_tbl until a match has occurred with the
       -- l_input_value_id. Having the match, we must ensure that the
       -- p_entry_value_tbl screen_entry_value matches the l_screen_entry_value.
       -- If the match does NOT occur then an update must be taking place and
       -- the loop must be terminated.
       -- NOTE: The use if the nvl() function is used to ensure that the
       --       entry_value match does not fail if either the pl/sql table
       --       entry_value or l_screen_entry_value is null.
       --       The nvl() function is NOT used on the input_value_id as this
       --       is always mandatory.
       --
       <<inner_loop>>
       for l_loop_counter in 1..p_num_entry_values loop
         if ((p_input_value_id_tbl(l_loop_counter) = l_input_value_id)    and
             (nvl(p_entry_value_tbl(l_loop_counter),hr_api.g_varchar2) <>
              nvl(l_screen_entry_value,hr_api.g_varchar2))) then
           --
           -- As the screen_entry_value attribute of PAY_ELEMENT_ENTRY_VALUES_F
           -- is going to be updated set the returning function code to true.
           --
           l_entry_changed := true;
           exit inner_loop;
         end if;
       end loop;
     end loop;
     close select_entry_value;
   else
     --
     -- The entry is being updated on the PAY_ELEMENT_ENTRIES_F table
     -- therefore set the returning function code to true.
     --
     l_entry_changed := true;
   end if;
   --
   return(l_entry_changed);
   --
 end element_entry_changed;
 --
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry_api.set_formula_contexts                       PRIVATE FUNCTION --
 --                                                                          --
 -- DESCRIPTION                                                              --
 --
 -- Called to cache some (global) information about the assignment passed.   --
 -- Originally meant to support input value validation formula, it is now    --
 -- used more widely.  Search for uses of g_asg_info to see more.            --
 -- The now somewhat misleading name name has been retained because          --
 -- this procedure is called from hr_dynsql and changing this would          --
 -- require C chain dependencies that we would rather avoid.                 --
 ------------------------------------------------------------------------------
--
 procedure set_formula_contexts
 (
  p_assignment_id  number,
  p_effective_date date
 ) is
   begin
   g_debug := hr_utility.debug_enabled;
   -- Check whether the business_group_id has been set and
   -- re-fetch if necessary.
   if(g_asg_info.business_group_id is null or
      g_asg_info.assignment_id is null or
      p_assignment_id <> g_asg_info.assignment_id)
   then
      if g_debug then
         hr_utility.trace('Cache assignment info');
      end if;

      g_asg_info.assignment_id := p_assignment_id;

      select ASG.business_group_id
      into   g_asg_info.business_group_id
      from   per_all_assignments_f ASG
      where  ASG.assignment_id = p_assignment_id
        and  p_effective_date between
             ASG.effective_start_date and ASG.effective_end_date;

      if(g_asg_info.adj_ee_source is null) then
         -- Obtain ADJUSTMENT_EE_SOURCE legislation rule.  This
         -- needed in a couple of places.
         -- Realise that this is not strictly an assignment
         -- level value, but convenient to get it here.
         begin
         select plr.rule_mode
         into   g_asg_info.adj_ee_source
         from   pay_legislation_rules plr,
                per_business_groups   pbg
         where pbg.business_group_id = g_asg_info.business_group_id
         and   pbg.legislation_code  = plr.legislation_code
         and   plr.rule_type         = 'ADJUSTMENT_EE_SOURCE';
         exception
            when no_data_found then g_asg_info.adj_ee_source := 'A';
         end;

         if g_debug then
            hr_utility.trace('ADJUSTMENT_EE_SOURCE ' || g_asg_info.adj_ee_source);
         end if;
      end if;

   end if;
 end set_formula_contexts;
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry_api.run_validation_formula                     PRIVATE FUNCTION --
 --                                                                          --
 -- DESCRIPTION                                                              --
 --
 -- Calls input validation formula to check entry value.
 ------------------------------------------------------------------------------
--
 procedure run_validation_formula
 (
  p_formula_id       number,
  p_session_date     date,
  p_entry_value      varchar2,
  p_warning_or_error varchar2
 ) is
   v_inputs           ff_exec.inputs_t;
   v_outputs          ff_exec.outputs_t;
   v_formula_message  varchar2(2000);
   v_formula_status   varchar2(10);
 begin
   -- We need to call a formula to validate the entry value.
   ff_exec.init_formula(p_formula_id, p_session_date, v_inputs, v_outputs);
   --
   -- Bug 2142799 : although it would not be very useful,
   -- it's possible that someone might write a validation
   -- formula without inputs or needing contexts.
   -- Rather than fail, we check the input count before
   -- attempting to set the input and context values.
   if(v_inputs.count >= 1) then
      if g_debug then
         hr_utility.trace('Inputs / contexts : ' || v_inputs.count);
      end if;
      --
      -- Set up the inputs and contexts to formula.
      for i in v_inputs.first..v_inputs.last loop
         if v_inputs(i).name = 'ASSIGNMENT_ID' then
            -- Set the assignment_id context.
            v_inputs(i).value := to_char(g_asg_info.assignment_id);
         elsif v_inputs(i).name = 'BUSINESS_GROUP_ID' then
            -- Set the business_group_id context.
            v_inputs(i).value := to_char(g_asg_info.business_group_id);
         elsif v_inputs(i).name = 'DATE_EARNED' then
            -- Set the business_group_id context.
            v_inputs(i).value := fnd_date.date_to_canonical(p_session_date);
         elsif v_inputs(i).name = 'ENTRY_VALUE' then
            -- Set the input to the entry value to be validated.
            -- Note - need to pass database format to formula.
            v_inputs(i).value := p_entry_value;
         else
            -- No context recognised.
            hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE',
                                         'hr_entry_api.run_validation_formula');
            hr_utility.set_message_token('STEP','10');
            hr_utility.raise_error;
         end if;
      end loop;
   end if;
   --
   ff_exec.run_formula(v_inputs, v_outputs);
   --
   -- Now obtain the return values.  There should be
   -- exactly two outputs.
   if v_outputs.count <> 2 then
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE',
                                   'hr_entry_api.run_validation_formula');
      hr_utility.set_message_token('STEP','20');
      hr_utility.raise_error;
   end if;
   --
   for i in v_outputs.first..v_outputs.last loop
      if v_outputs(i).name = 'FORMULA_MESSAGE' then
         --
         v_formula_message := v_outputs(i).value;
      elsif v_outputs(i).name = 'FORMULA_STATUS' then
         --
         v_formula_status := upper(v_outputs(i).value);
      else
         hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
         hr_utility.set_message_token('PROCEDURE',
                                      'hr_entry_api.run_validation_formula');
         hr_utility.set_message_token('STEP','30');
         hr_utility.raise_error;
      end if;
   end loop;
   --
   -- Check whether we have raised an error and act appropriately.
   if v_formula_status <> 'S' and p_warning_or_error = 'E' then
      -- I.e. the formula validation failed and we need to raise an error.
      if v_formula_message is null then
         -- User not defined an error message.
         fnd_message.set_name ('PAY', 'HR_6648_ELE_ENTRY_FORMULA_ERR');
         hr_utility.raise_error;
      else
         -- User has defined message and so we can raise it.
         fnd_message.set_name ('PAY','HR_ELE_ENTRY_FORMULA_HINT');
         fnd_message.set_token ('FORMULA_TEXT', v_formula_message, false);
         hr_utility.raise_error;
      end if;
   elsif v_formula_status <> 'S' and p_warning_or_error = 'W' then
      -- We have failed validation, but only want to warn.
      if v_formula_message is null then
         -- User not defined an error message.
         fnd_message.set_name ('PAY', 'HR_6648_ELE_ENTRY_FORMULA_ERR');
         hr_utility.set_warning;
      else
         -- User has defined message and so we can raise it.
         fnd_message.set_name ('PAY','HR_ELE_ENTRY_FORMULA_HINT');
         fnd_message.set_token ('FORMULA_TEXT', v_formula_message, false);
         hr_utility.set_warning;
      end if;
   end if;
 end run_validation_formula;
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry.validate_entry_value                                            --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Validates and converts an entry value to DB format.                      --
 --                                                                          --
 -- Note: for benefit entries p_session_date needs to be passed to this      --
 --       procedure or row has to exists in fnd_sessions.                    --
 --       Otherwise sysdate will be used for coverage level validation.      --
 ------------------------------------------------------------------------------
--
 procedure validate_entry_value
 (
  p_element_link_id     number,
  p_input_value_id      number,
  p_session_date        date,
  p_screen_format       in out nocopy varchar2,
  p_db_format           in out nocopy varchar2,
  p_lookup_type         varchar2,
  p_uom                 varchar2,
  p_input_currency_code varchar2,
  p_value_set_id        number default null
 ) is
   --
   -- Make sure that the value is valid for the lookup type.
   --
   cursor csr_valid_lookup
          (
           p_lookup_type varchar2,
           p_meaning     varchar2
          ) is
       select HL.lookup_code
       from   hr_lookups HL
       where  HL.lookup_type = p_lookup_type
         and  HL.meaning     = p_meaning;
   --
   -- Cursor that checks to make sure that the coverage level for a benefit
   -- element entry is valid for the benefit type.
   --
   cursor csr_valid_coverage_level
          (
           p_input_value_id number,
           p_lookup_code    varchar2,
           v_session_date   date
          ) is
     select IV.input_value_id
     from   pay_element_types_f         ET,
            pay_input_values_f          IV,
            ben_benefit_classifications BCL
     where  IV.input_value_id             = p_input_value_id
       and  IV.name                       = 'Coverage'
       and  ET.element_type_id            = IV.element_type_id
       and  BCL.benefit_classification_id = ET.benefit_classification_id
       and  BCL.contributions_used        = 'Y'
       and  not exists (select null
                        from   ben_benefit_contributions_f BCO
                        where  BCO.element_type_id = ET.element_type_id
                          and  BCO.coverage_type   = p_lookup_code
                          and  v_session_date between BCO.effective_start_date
                                                  and BCO.effective_end_date);
   --
   -- bug 372339, 604543 and 651458 mlisieck/09.01.1998/07.04.1998
   --
   cursor csr_benefit_entry is
     select input_value_id
     from pay_input_values_f
     where input_value_id = p_input_value_id and
           name = 'Coverage';
   --
   cursor csr_session_date is
     select effective_date
     from fnd_sessions
     where session_id = userenv('sessionid');
   --
   cursor csr_val_fmla is
     select piv.formula_id
     from pay_input_values_f piv
     where piv.input_value_id = p_input_value_id
       and p_session_date between piv.effective_start_date
                              and piv.effective_end_date;
   --
   -- Local Variables
   --
   v_lookup_code      varchar2(30);
   v_value_set_value  varchar2(60);
   v_min_max_failure  varchar2(1);
   v_warning_or_error varchar2(30);
   v_minimum_value    varchar2(60);
   v_maximum_value    varchar2(60);
   --v_db_format      varchar2(60);
   v_db_format        varchar2(80);
   -- v_screen_format varchar2(60);
   -- Enhancement 2793978
   -- size of v_screen_format increased to deal with screen format of
   -- value set validated entry values.
   v_screen_format    varchar2(240);
   v_hot_defaulted    boolean := false;
   v_dummy            number;
   -- bug 604543
   v_session_date     date;
   --
   v_formula_id       number;
   v_formula_profile  varchar2(30);   -- User profile value.
   --
 begin
   g_debug := hr_utility.debug_enabled;
   --
   -- Need to determine the defaulted value of the entry value.
   --
   hr_entry.derive_default_value
     (p_element_link_id,
      p_input_value_id,
      p_session_date,
      p_input_currency_code,
      'DEF',
      v_screen_format,
      v_db_format);
   --
   -- If the screen format value is defaulted then set the p_db_format
   -- value to the return v_db_format value.
   --
   if ((p_screen_format = v_screen_format) and
       (v_db_format is null)) then
     p_db_format := v_db_format;
     v_hot_defaulted := true;
   end if;
   --
   -- Value is not validated using lookups so make sure that the value is in a
   -- correct format for its data type ie. 'ABCDE' would not be valid for an
   -- integer entry value, etc...
   --
   if (p_lookup_type is null and
       p_value_set_id is null and
       NOT v_hot_defaulted) then
     --
     hr_entry.check_format
       (p_element_link_id,
        p_input_value_id,
        p_session_date,
        p_screen_format,
        p_db_format,
        'Y',
        v_min_max_failure,
        v_warning_or_error,
        v_minimum_value,
        v_maximum_value);
     --
     -- if the warning_or_error flag has been set to 'Error' then Error
     -- and stop procesing
     --
     if v_min_max_failure = 'F' and v_warning_or_error = 'E' then
       hr_utility.set_message(801, 'PAY_6303_INPUT_VALUE_OUT_RANGE');
       hr_utility.raise_error;
     end if;
     --
     -- ******* Added this to fix bug 421842 **********
     -- if the warning_or_error flag has been set to 'Error' then only Warn
     -- but let the processing continue
     --
      if v_min_max_failure = 'F' and v_warning_or_error = 'W' then
        hr_utility.set_message(801, 'PAY_6303_INPUT_VALUE_OUT_RANGE');
        hr_utility.set_warning;
      end if;
     --
     -- Check whether we need to perform formula validation.
     open csr_val_fmla;
     fetch csr_val_fmla into v_formula_id;
     close csr_val_fmla;
     --
     -- Allow a user to switch off in emergency.
     fnd_profile.get('PAY_NO_IV_FMLA_VALIDATION', v_formula_profile);
     if (v_formula_profile is null and p_db_format is not null and
         v_formula_id is not null) then
        run_validation_formula (v_formula_id, p_session_date,
                                p_db_format, v_warning_or_error);
     end if;
   --
   --
   -- Value is validated using lookups.
   --
   elsif (p_lookup_type   is not null and
          p_screen_format is not null and
          NOT v_hot_defaulted) then
     --
     -- Make sure value is valid according to the lookup type NB. the meaning
     -- is being checked.
     --
     open csr_valid_lookup(p_lookup_type,p_screen_format);
     fetch csr_valid_lookup into v_lookup_code;
     if csr_valid_lookup%notfound then
       close csr_valid_lookup;
       hr_utility.set_message(801, 'HR_7033_ELE_ENTRY_LKUP_INVLD');
       hr_utility.set_message_token('LOOKUP_TYPE',p_lookup_type);
       hr_utility.raise_error;
     end if;
     close csr_valid_lookup;
     --
     -- If the element entry is used for benefit processing and the input
     -- value being checked is 'Coverage' then the value must be one of the
     -- valid coverage types for the particular benefit type ie. each benefit
     -- type uses a subset of all the valid coverage types.
     --
     -- added if statement below to limit number of checks, especialy after the bug fix below.
     --
     open csr_benefit_entry;
     fetch csr_benefit_entry into v_dummy;
     --
     if csr_benefit_entry%found then
       --
       -- bug 372339, 604543 and 651458
       --
       if g_debug then
          hr_utility.trace('p_lookup_code: ' || v_lookup_code);
       end if;

       v_session_date := p_session_date;

       -- bugfix 1273798
       --if v_session_date = null then
       if v_session_date is null then
         open csr_session_date;
         fetch csr_session_date into v_session_date;
         close csr_session_date;
       end if;

       if g_debug then
          hr_utility.trace('v_session_date: ' || fnd_date.date_to_canonical(v_session_date));
       end if;

       -- bugfix 1273798
       --if v_session_date = null then
       if v_session_date is null then

         close csr_benefit_entry;
         hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
         hr_utility.set_message_token('PROCEDURE','hr_entry_api.validate_entry_value');
         hr_utility.set_message_token('STEP','10');
         hr_utility.raise_error;

       end if;

       open csr_valid_coverage_level(p_input_value_id,v_lookup_code,TRUNC(v_session_date));
       fetch csr_valid_coverage_level into v_dummy;
       if csr_valid_coverage_level%found then
         close csr_valid_coverage_level;
         hr_utility.set_message(801, 'HR_7437_BEN_COVERAGE_INVLD');
         hr_utility.raise_error;
       end if;
       if g_debug then
          hr_utility.trace('valid_coverage_level_found ' || v_dummy);
       end if;
       close csr_valid_coverage_level;

     end if;
     --
     close csr_benefit_entry;
     --
     p_db_format := v_lookup_code;
     --
   elsif (p_value_set_id is not null and p_screen_format is not null and
     not v_hot_defaulted) then
     --
     -- Enhancement 2793978
     -- Value is validated using value sets.
     -- Derive the database format.
     --
     v_value_set_value := pay_input_values_pkg.decode_vset_meaning(
       p_value_set_id, p_screen_format);
     --
     if v_value_set_value is null then
       --
       -- The screen format was invalid, raise an error
       --
       hr_utility.set_message(800, 'HR_34927_ELE_ENTRY_VSET_INVLD');
       hr_utility.raise_error;
       --
     end if;
     --
     p_db_format := v_value_set_value;
     --
   end if;
   --
 end validate_entry_value;
--
 ------------------------------------------------------------------------------
 -- NAME
 --   hr_entry_api.chk_user_enterable
 --
 -- DESCRIPTION
 --   additional validation on User Enterable IV_IDs and associated EVs,
 --   preconditions, only called if creator type in forms or MIX and the
 --   IV_ID being processed is User Enterable and its associated EV is
 --   not null
 ------------------------------------------------------------------------------
--
PROCEDURE chk_user_enterable(
  p_el_id               IN NUMBER,
  p_lookup_type         IN VARCHAR2,
  p_value_set_id        IN NUMBER,
  p_uom                 IN VARCHAR2,
  p_default_value       IN VARCHAR2,
  p_input_currency_code IN VARCHAR2,
  p_session_date        IN DATE,
  p_iv_id               IN NUMBER,
  p_ev                  IN OUT NOCOPY VARCHAR2,
  p_creator_type        IN VARCHAR2,
  p_mode                IN VARCHAR2 default 'I',
  p_hot_flag            IN VARCHAR2)
  IS
  --
  --
  l_default             VARCHAR2(80);
  l_screen_fmt_value    VARCHAR2(80);
  l_db_fmt_value        VARCHAR2(80);
  --
  --
BEGIN
  if g_debug then
     hr_utility.trace('> hr_entry_api.chk_user_enterable');
     hr_utility.trace('| p_el_id>'               || p_el_id || '<');
     hr_utility.trace('| p_lookup_type>'         || p_lookup_type || '<');
     hr_utility.trace('| p_value_set_id>'        || p_value_set_id || '<');
     hr_utility.trace('| p_default_value>'       || p_default_value || '<');
     hr_utility.trace('| p_input_currency_code>' || p_input_currency_code || '<');
     hr_utility.trace('| p_session_date>'        || p_session_date || '<');
     hr_utility.trace('| p_iv_id>'               || p_iv_id || '<');
     hr_utility.trace('| p_ev>'                  || p_ev || '<');
  end if;
  --
  -- Only convert the format if it is an Insert call.
  --
  IF p_mode = 'I' THEN
    --
    -- if IV_ID has an associated lookup then find the
    -- associated meaning,
    -- else just return the default from the PLIV
    --
    -- Bugfix 2288865:
    -- Ensure both p_lookup_type AND p_default_value are not null
    -- before attempting to retrieve the corresponding meaning
    --
    IF p_lookup_type IS NOT NULL AND p_default_value IS NOT NULL THEN
      BEGIN
      SELECT h.meaning
        INTO   l_default
        FROM   HR_LOOKUPS h
        WHERE  h.lookup_type = p_lookup_type
        and    h.lookup_code = p_default_value
        ;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
        hr_utility.set_message_token('PROCEDURE',
                                      'hr_entry_api.chk_user_enterable');
        hr_utility.set_message_token('STEP','1');
        hr_utility.raise_error;
      END;
      --
    ELSE
      --
      -- need to convert the default stored on the db into
      -- screen format,
      -- return default screen and database formatted values in either a cold
      -- or hot format for the specified EL and IV
      --
      hr_entry.derive_default_value(
        p_element_link_id       => p_el_id,
        p_input_value_id        => p_iv_id,
        p_session_date          => p_session_date,
        p_input_currency_code   => p_input_currency_code,
        v_screen_format_value   => l_screen_fmt_value,
        v_database_format_value => l_db_fmt_value);
      --
      --
      if g_debug then
         hr_utility.trace('| l_screen_fmt_value>' || l_screen_fmt_value || '<');
         hr_utility.trace('| l_db_fmt_value>' || l_db_fmt_value || '<');
      end if;
      --
      l_default := l_screen_fmt_value;
    END IF;
    --
    IF p_hot_flag = 'Y' AND p_ev is null THEN
       l_default := NULL;
    END IF;
    --
    --
  ELSE
    -- The passed value is in the db format.
    -- Now format the required valued to the display value required.
    -- If the value is a lookup then we must select the meaning from the
    -- lookup table.
    --
       if (p_lookup_type is not null      and
           p_default_value is not null) then
         begin
           select h.meaning
           into   l_default
           from   hr_lookups h
           where  h.lookup_type = p_lookup_type
           and    h.lookup_code = p_default_value;
         exception
           when NO_DATA_FOUND then
             hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
             hr_utility.set_message_token('PROCEDURE',
                                           'hr_entry_api.chk_user_enterable');
             hr_utility.set_message_token('STEP','2');
             hr_utility.raise_error;
         end;
    --
    -- Bugfix 5555289
    -- If the input value uses a value set for validation then derive the
    -- default value accordingly...
    --
       elsif (p_value_set_id is not null and
              p_default_value is not null) then
         --
         l_default := pay_input_values_pkg.decode_vset_value ( p_value_set_id, p_default_value );
         --
         if l_default is null then
           --
           -- The p_default_value was invalid, raise an error
           --
           hr_utility.set_message(800, 'HR_34927_ELE_ENTRY_VSET_INVLD');
           hr_utility.raise_error;
           --
         end if;
         --
       else
         l_default := hr_chkfmt.changeformat(p_default_value, p_uom, p_input_currency_code);
       end if;
    --
    --
  END IF;

  if g_debug then
     hr_utility.trace('| l_default>' || l_default || '<');
  end if;
  --

  IF g_override_user_ent_chk = 'Y' THEN
     -- p_ev:=l_default;
     NULL;
  ELSE
     --
     -- Check non-user enterable will no longer raise error, instead it will
     -- use the default value (for insert) or existing value (for update).
     --

     IF (l_default IS NOT NULL AND p_ev IS NOT NULL AND p_ev = l_default) OR (l_default IS NULL AND p_ev IS NULL) THEN

       if g_debug then
          hr_utility.trace('| EV specified matches value on EL, ok');
       end if;

     ELSIF l_default IS NOT NULL AND p_ev IS NOT NULL AND p_ev <> l_default THEN
       --
       -- API can 'update' a default as specified on EL,
       -- therefore default is not null, forms cannot do this
       --
       if g_debug then
          hr_utility.trace('| EV does not match the default value stored on PLIV');
       end if;
       -- hr_utility.set_message (800, 'PAY_50380_INPVAL_NOT_UPDATABLE');
       -- hr_utility.raise_error;

     ELSE
       --
       -- if there is no default value to compare against (an EV
       -- value has been specified), then raise error as it is invalid
       -- for the API to 'set' a value for a non User Enterable IV,
       -- forms cannot do this
       --
       if g_debug then
          hr_utility.trace('| EV specified');
       end if;
       -- hr_utility.set_message (800, 'PAY_50381_INPVAL_NOT_ENTERABLE');
       -- hr_utility.raise_error;
     END IF;

	p_ev := l_default;
     --
     --
  END IF;
  --
  if g_debug then
     hr_utility.trace('< hr_entry_api.chk_user_enterable');
  end if;
END chk_user_enterable;
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry_api.conv_entry_values_to_table                                  --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Converts a set of predefined parameters containing the INPUT_VALUE_IDs   --
 -- and SCREEN_ENTRY_VALUEs for an element entry to a pair of PLSQL tables   --
 -- containing the same information. It also returns the number of entry     --
 -- values.                                                                  --
 ------------------------------------------------------------------------------
--
 procedure conv_entry_values_to_table
 (
  p_iv_format          varchar2,
  p_element_entry_id   number,
  p_element_link_id    number,
  p_session_date       date,
  p_creator_type       varchar2,
  p_entry_type         varchar2,
  p_input_value_id1    number,
  p_input_value_id2    number,
  p_input_value_id3    number,
  p_input_value_id4    number,
  p_input_value_id5    number,
  p_input_value_id6    number,
  p_input_value_id7    number,
  p_input_value_id8    number,
  p_input_value_id9    number,
  p_input_value_id10   number,
  p_input_value_id11   number,
  p_input_value_id12   number,
  p_input_value_id13   number,
  p_input_value_id14   number,
  p_input_value_id15   number,
  p_entry_value1       varchar2,
  p_entry_value2       varchar2,
  p_entry_value3       varchar2,
  p_entry_value4       varchar2,
  p_entry_value5       varchar2,
  p_entry_value6       varchar2,
  p_entry_value7       varchar2,
  p_entry_value8       varchar2,
  p_entry_value9       varchar2,
  p_entry_value10      varchar2,
  p_entry_value11      varchar2,
  p_entry_value12      varchar2,
  p_entry_value13      varchar2,
  p_entry_value14      varchar2,
  p_entry_value15      varchar2,
  p_num_entry_values   out nocopy number,
  p_input_value_id_tbl out nocopy hr_entry.number_table,
  p_entry_value_tbl    out nocopy hr_entry.varchar2_table
 ) is
   --
   -- Local variables
   --
   --v_screen_format     varchar2(60);
   v_screen_format       varchar2(240);
   --v_db_format         varchar2(60);
   v_db_format           varchar2(240);
   v_range_flag          varchar2(1);
   v_count               number := 0;
   v_input_value_id      number;
   v_input_currency_code varchar2(30);
   v_entry_value         varchar2(30);
   v_input_value_id_tbl  hr_entry.number_table;
   v_entry_value_tbl     hr_entry.varchar2_table;
   --
   -- Selects all the link input values for a specified element link. Each one
   -- retrieved is compared with the entry values specified by the user. If it
   -- has been specified by the user then the value for the entry value is
   -- set to the users value and a flag is set to indicate this has happened.
   -- If the user has not set a value for it then the entry value is set to
   -- null.
   --
   cursor csr_link_input_value
          (
           p_element_link_id number,
           p_session_date    date
          ) is
     select /*+ ORDERED
                INDEX(pliv PAY_LINK_INPUT_VALUES_F_N1)
                INDEX(piv PAY_INPUT_VALUES_F_PK)
                INDEX(et PAY_ELEMENT_TYPES_F_PK)
                USE_NL(PLIV ET PIV) */
            pliv.input_value_id,
            pliv.default_value      pliv_default_value,
            piv.hot_default_flag,
            piv.lookup_type,
            piv.value_set_id,
            piv.uom,
            piv.mandatory_flag,
            piv.default_value       piv_default_value,
            et.input_currency_code,
            decode(pliv.input_value_id,
                     p_input_value_id1,p_entry_value1,
                     p_input_value_id2,p_entry_value2,
                     p_input_value_id3,p_entry_value3,
                     p_input_value_id4,p_entry_value4,
                     p_input_value_id5,p_entry_value5,
                     p_input_value_id6,p_entry_value6,
                     p_input_value_id7,p_entry_value7,
                     p_input_value_id8,p_entry_value8,
                     p_input_value_id9,p_entry_value9,
                     p_input_value_id10,p_entry_value10,
                     p_input_value_id11,p_entry_value11,
                     p_input_value_id12,p_entry_value12,
                     p_input_value_id13,p_entry_value13,
                     p_input_value_id14,p_entry_value14,
                     p_input_value_id15,p_entry_value15,
                     null) entry_value,
            decode(pliv.input_value_id,
                     p_input_value_id1,'SET',
                     p_input_value_id2,'SET',
                     p_input_value_id3,'SET',
                     p_input_value_id4,'SET',
                     p_input_value_id5,'SET',
                     p_input_value_id6,'SET',
                     p_input_value_id7,'SET',
                     p_input_value_id8,'SET',
                     p_input_value_id9,'SET',
                     p_input_value_id10,'SET',
                     p_input_value_id11,'SET',
                     p_input_value_id12,'SET',
                     p_input_value_id13,'SET',
                     p_input_value_id14,'SET',
                     p_input_value_id15,'SET',
                     'NOT_SET') entry_specified
     from  pay_link_input_values_f pliv,
           pay_input_values_f piv,
           pay_element_types_f et
     where pliv.element_link_id = p_element_link_id
       and piv.input_value_id = pliv.input_value_id
       and et.element_type_id = piv.element_type_id
       and p_session_date between pliv.effective_start_date
                              and pliv.effective_end_date
       and p_session_date between piv.effective_start_date
                              and piv.effective_end_date
       and p_session_date between et.effective_start_date
                              and et.effective_end_date;
   --
   -- Selects all the element entry values for a specified entry. Each one
   -- retrieved is compared with the entry values specified by the user. If it
   -- has been specified by the user then the value for the entry value is
   -- set to the users value and a flag is set to indicate this has happened.
   -- If the user has not set a value for it then the value is set to the
   -- existing value of the entry value.
   --
   cursor csr_entry_input_value
          (
           p_element_entry_id number,
           p_session_date     date
          ) is
     select /*+ LEADING(ee) */ ee.element_link_id,
            eev.input_value_id,
            piv.lookup_type,
            piv.value_set_id,
            piv.uom,
            piv.hot_default_flag,
            et.input_currency_code,
            piv.mandatory_flag,
            eev.screen_entry_value       peev_default_value,
            decode(eev.input_value_id,
                     p_input_value_id1,p_entry_value1,
                     p_input_value_id2,p_entry_value2,
                     p_input_value_id3,p_entry_value3,
                     p_input_value_id4,p_entry_value4,
                     p_input_value_id5,p_entry_value5,
                     p_input_value_id6,p_entry_value6,
                     p_input_value_id7,p_entry_value7,
                     p_input_value_id8,p_entry_value8,
                     p_input_value_id9,p_entry_value9,
                     p_input_value_id10,p_entry_value10,
                     p_input_value_id11,p_entry_value11,
                     p_input_value_id12,p_entry_value12,
                     p_input_value_id13,p_entry_value13,
                     p_input_value_id14,p_entry_value14,
                     p_input_value_id15,p_entry_value15,
                     eev.screen_entry_value) entry_value,
            decode(eev.input_value_id,
                     p_input_value_id1,'SET',
                     p_input_value_id2,'SET',
                     p_input_value_id3,'SET',
                     p_input_value_id4,'SET',
                     p_input_value_id5,'SET',
                     p_input_value_id6,'SET',
                     p_input_value_id7,'SET',
                     p_input_value_id8,'SET',
                     p_input_value_id9,'SET',
                     p_input_value_id10,'SET',
                     p_input_value_id11,'SET',
                     p_input_value_id12,'SET',
                     p_input_value_id13,'SET',
                     p_input_value_id14,'SET',
                     p_input_value_id15,'SET',
                     'NOT_SET') entry_specified
     from  pay_element_entry_values_f eev,
           pay_element_entries_f ee,
           pay_input_values_f piv,
           pay_element_types_f et
     where ee.element_entry_id = p_element_entry_id
       and eev.element_entry_id = ee.element_entry_id
       and piv.input_value_id = eev.input_value_id
       and et.element_type_id = piv.element_type_id
       and p_session_date between ee.effective_start_date
                              and ee.effective_end_date
       and p_session_date between eev.effective_start_date
                              and eev.effective_end_date
       and p_session_date between piv.effective_start_date
                              and piv.effective_end_date
       and p_session_date between et.effective_start_date
                              and et.effective_end_date;
   --
--
   cursor csr_creator_type
       (
        l_element_entry_id number,
        l_session_date     date
       ) is
       select ee.creator_type
         from pay_element_entries_f ee
        where ee.element_entry_id = l_element_entry_id
          and l_session_date between ee.effective_start_date and ee.effective_end_date;
   --
   v_creator_type varchar2(30);
   --
 begin
   g_debug := hr_utility.debug_enabled;
   --
   if g_debug then
      hr_utility.set_location('hr_entry.conv_entry_values_to_table',5);
   end if;
   --
   if p_creator_type = hr_api.g_varchar2 then
      open csr_creator_type(p_element_entry_id,p_session_date);
      fetch csr_creator_type into v_creator_type;
      close csr_creator_type;
   else
      v_creator_type := p_creator_type;
   end if;
   --
   if g_debug then
      hr_utility.trace('p_entry_value1: ' || p_entry_value1);
   end if;
   --
   -- User is inserting a new element entry.
   --
   if p_element_link_id is not null then
     --
     if g_debug then
        hr_utility.set_location('hr_entry.conv_entry_values_to_table',10);
     end if;
     --
     -- Find all the entry values for the specified element entry NB. it is a
     -- new element entry so have to get the details of the entry values from
     -- the element link.
     --
     for v_link_value in csr_link_input_value(p_element_link_id,
                                              p_session_date) loop
       --
       if g_debug then
          hr_utility.set_location('hr_entry.conv_entry_values_to_table',15);
       end if;
       --
       -- Keep a count of the number of entry values and put input_value_id of
       -- entry value into table.
       --
       v_count := v_count + 1;
       v_input_value_id_tbl(v_count) := v_link_value.input_value_id;
       --
       -- User has set a value and it is is in screen format so need to
       -- cobert it to DB format.
       --
       if p_iv_format = 'SCREEN' and v_link_value.entry_specified = 'SET' then
         if g_debug then
            hr_utility.trace('| Begin conv_entry_values_to_table()');
         end if;
         --
         -- v_link_value.entry_specified really indicates that the IV_ID
         -- has been specified
         --
         -- nb. all IV_IDs for an ET are passed in through forms,
         --     via the API, the user can explicitly specify IV_IDs
         --
         -- bug 546670, extra validation
         --
         -- this does not apply to adjustment EEs,
         -- chk type of EE
         --
         -- D Additional Entry
         -- A Additive Adjustment
         -- B Balance Adjustment
         -- E Element Entry
         -- S Override
         -- R Replacement Adjustment
         --
         if g_debug then
            hr_utility.trace('| p_entry_type>' || p_entry_type || '<');
         end if;
         --
         -- Bugfix 3187829
         -- Do not call chk_user_enterable for entry type 'R' (replacement
         -- adjustment), i.e. we allow a replacement adjustment to be created
         -- for non-user enterable Pay Values. This is consistent with entry
         -- type 'A' (additive adjustment) behaviour.
         --
         IF v_creator_type IN ('F','H') AND p_entry_type NOT IN ('A','R') THEN
           if g_debug then
              hr_utility.trace('| creator type in F or H and not A EE');
           end if;
           --
           IF v_link_value.mandatory_flag = 'X'
             -- Following commented out because user can entre null value too.
             -- AND v_link_value.entry_value IS NOT NULL
             THEN
             if g_debug then
                hr_utility.trace('| flag set to X and EV specified');
             end if;
             --
             -- only raise the error if the EV does not match the
             -- default value stored on PLIV
             --
             hr_entry_api.chk_user_enterable(
               p_el_id               => p_element_link_id,
               p_lookup_type         => v_link_value.lookup_type,
               p_value_set_id        => v_link_value.value_set_id,
               p_uom                 => v_link_value.uom,
               p_default_value       => v_link_value.pliv_default_value,
               p_input_currency_code => v_link_value.input_currency_code,
               p_session_date        => p_session_date,
               p_iv_id               => v_link_value.input_value_id,
               p_ev                  => v_link_value.entry_value,
               p_creator_type        => v_creator_type,
               p_hot_flag            => v_link_value.hot_default_flag);
           END IF;
           --
         END IF;
         --
         if g_debug then
            hr_utility.trace('| End conv_entry_values_to_table()');
         end if;
         --
         --
         v_screen_format := v_link_value.entry_value;
         v_db_format := v_screen_format;
         --
         hr_entry_api.validate_entry_value
           (p_element_link_id,
            v_link_value.input_value_id,
            p_session_date,
            v_screen_format,
            v_db_format,
            v_link_value.lookup_type,
            v_link_value.uom,
            v_link_value.input_currency_code,
            v_link_value.value_set_id);
         --
         -- Put entry value into table.
         --
         v_entry_value_tbl(v_count) := v_db_format;
       --
       -- User has not set a value and entry value is not hot defaulted.
       --
       elsif v_link_value.entry_specified = 'NOT_SET' and
             v_link_value.hot_default_flag = 'N' then
         --
         -- Get any default if it has been set up.
         --
         hr_entry.derive_default_value
           (p_element_link_id,
            v_input_value_id_tbl(v_count),
            p_session_date,
            v_link_value.input_currency_code,
            'DEF',
            v_screen_format,
            v_db_format);
         --
         -- Put entry value into table.
         --
         v_entry_value_tbl(v_count) := v_db_format;
         if g_debug then
            hr_utility.trace('v_db_format: ' || v_db_format);
         end if;
         --
       else
         --
         -- Put entry value into table.
         --
         v_entry_value_tbl(v_count) := v_link_value.entry_value;
         if g_debug then
            hr_utility.trace('v_link_value.entry_value: ' ||
                              v_link_value.entry_value);
         end if;
         --
       end if;
       --
     end loop;
   --
   -- User is updating an existing element entry.
   --
   elsif p_element_entry_id is not null then
     --
     if g_debug then
        hr_utility.set_location('hr_entry.conv_entry_values_to_table',20);
     end if;
     --
     -- Find all the entry values for the specified element entry.
     --
     for v_entry_value in csr_entry_input_value(p_element_entry_id,
                                                p_session_date) loop
       --
       if g_debug then
          hr_utility.set_location('hr_entry.conv_entry_values_to_table',25);
          hr_utility.trace('v_entry_value.element_link_id: '||to_char(v_entry_value.element_link_id) );
          hr_utility.trace('v_entry_value.input_value_id: '||to_char(v_entry_value.input_value_id) );
          hr_utility.trace('v_entry_value.lookup_type: '||v_entry_value.lookup_type) ;
          hr_utility.trace('v_entry_value.value_set_id: '||to_char(v_entry_value.value_set_id) );
          hr_utility.trace('v_entry_value.uom: '||v_entry_value.uom) ;
          hr_utility.trace('v_entry_value.hot_default_flag: '||v_entry_value.hot_default_flag) ;
          hr_utility.trace('v_entry_value.input_currency_code: '||v_entry_value.input_currency_code) ;
          hr_utility.trace('v_entry_value.mandatory_flag: '||v_entry_value.mandatory_flag) ;
          hr_utility.trace('v_entry_value.peev_default_value: '||v_entry_value.peev_default_value) ;
          hr_utility.trace('v_entry_value.entry_value: '|| v_entry_value.entry_value) ;
          hr_utility.trace('v_entry_value.entry_specified: '||v_entry_value.entry_specified) ;
       end if;
       --
       -- Keep a count of the number of entry values and put input_value_id of
       -- entry value into table.
       --
       v_count := v_count + 1;
       v_input_value_id_tbl(v_count) := v_entry_value.input_value_id;
       --
       -- User has set a value and it is is in screen format so need to
       -- cobert it to DB format.
       --
       if p_iv_format = 'SCREEN' and v_entry_value.entry_specified = 'SET' then
         --
         --IF v_creator_type IN ('F', 'H') AND p_entry_type <> 'A' THEN -- Commented for bug 8307482
	   IF v_creator_type IN ('F', 'H') AND p_entry_type NOT IN ('A','R') THEN
           if g_debug then
              hr_utility.trace('| creator type in F or H and not A EE');
           end if;
           --
           IF v_entry_value.mandatory_flag = 'X'
             -- Following commented out because user can entre null value too.
             -- AND v_entry_value.entry_value IS NOT NULL
             THEN
             if g_debug then
                hr_utility.trace('| flag set to X and EV specified');
             end if;
             --
             -- only raise the error if the EV does not match the
             -- existing value.
             --
             hr_entry_api.chk_user_enterable(
               p_el_id               => v_entry_value.element_link_id,
               p_lookup_type         => v_entry_value.lookup_type,
               p_value_set_id        => v_entry_value.value_set_id,
               p_uom                 => v_entry_value.uom,
               p_default_value       => v_entry_value.peev_default_value,
               p_input_currency_code => v_entry_value.input_currency_code,
               p_session_date        => p_session_date,
               p_iv_id               => v_entry_value.input_value_id,
               p_ev                  => v_entry_value.entry_value,
               p_mode                => 'U',
               p_creator_type        => v_creator_type,
               p_hot_flag            => v_entry_value.hot_default_flag);
           END IF;
           --
         END IF;
         --
         --
         v_screen_format := v_entry_value.entry_value;
         v_db_format := v_screen_format;
         --
         if g_debug then
           hr_utility.set_location('hr_entry.conv_entry_values_to_table',27);
         end if;
         --
         hr_entry_api.validate_entry_value
           (v_entry_value.element_link_id,
            v_entry_value.input_value_id,
            p_session_date,
            v_screen_format,
            v_db_format,
            v_entry_value.lookup_type,
            v_entry_value.uom,
            v_entry_value.input_currency_code,
            v_entry_value.value_set_id);
         --
         -- Put entry value into table.
         --
         v_entry_value_tbl(v_count) := v_db_format;
         --
       else
         --
         -- Put entry value into table.
         --
         v_entry_value_tbl(v_count) := v_entry_value.entry_value;
         --
       end if;
       --
     end loop;
     --
   end if;
   --
   if g_debug then
      hr_utility.set_location('hr_entry.conv_entry_values_to_table',30);
   end if;
   --
   -- Return tables containing the entry values in DB format.
   --
   p_num_entry_values   := v_count;
   p_input_value_id_tbl := v_input_value_id_tbl;
   p_entry_value_tbl    := v_entry_value_tbl;
   --
 end conv_entry_values_to_table;
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry.conv_table_to_table                                             --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Given a table of entry values it converts to DB format if required. Any  --
 -- entry values that are not specified are derived NB. when inserting the   --
 -- values are defaulted, when updating the existing entry values are used.  --
 ------------------------------------------------------------------------------
--
 procedure conv_table_to_table
 (
  p_iv_format          varchar2,
  p_session_date       date,
  p_element_entry_id   number,
  p_element_link_id    number,
  p_num_entry_values   in out nocopy number,
  p_creator_type       varchar2,
  p_entry_type         varchar2,
  p_input_value_id_tbl in out nocopy hr_entry.number_table,
  p_entry_value_tbl    in out nocopy hr_entry.varchar2_table
 ) is
   --
   -- Selects all the link input values for a specified element link.
   --
   cursor csr_link_input_value
          (
           p_element_link_id number,
           p_session_date    date
          ) is
     select /*+ ORDERED
                INDEX(pliv PAY_LINK_INPUT_VALUES_F_N1)
                INDEX(piv PAY_INPUT_VALUES_F_PK)
                INDEX(et PAY_ELEMENT_TYPES_F_PK)
                USE_NL(PLIV ET PIV) */
            pliv.input_value_id,
            pliv.default_value      pliv_default_value,
            piv.hot_default_flag,
            piv.lookup_type,
            piv.value_set_id,
            piv.uom,
            piv.mandatory_flag,
            piv.default_value       piv_default_value,
            et.input_currency_code
     from   pay_link_input_values_f pliv,
            pay_input_values_f piv,
            pay_element_types_f et
     where  pliv.element_link_id = p_element_link_id
       and  piv.input_value_id   = pliv.input_value_id
       and  et.element_type_id  = piv.element_type_id
       and  p_session_date between pliv.effective_start_date
                               and pliv.effective_end_date
       and  p_session_date between piv.effective_start_date
                               and piv.effective_end_date
       and  p_session_date between et.effective_start_date
                               and et.effective_end_date;
   --
   -- Selects all the entry values for a specified element entry.
   --
   cursor csr_entry_input_value
          (
           p_element_entry_id number,
           p_session_date     date
          ) is
     select ee.element_link_id,
            eev.input_value_id,
            piv.lookup_type,
            piv.value_set_id,
            piv.uom,
            piv.hot_default_flag,
            et.input_currency_code,
            piv.mandatory_flag,
            eev.screen_entry_value       peev_default_value,
            eev.screen_entry_value
     from   pay_element_entry_values_f eev,
            pay_element_entries_f ee,
            pay_input_values_f piv,
            pay_element_types_f et
     where  ee.element_entry_id = p_element_entry_id
       and  eev.element_entry_id = ee.element_entry_id
       and  piv.input_value_id = eev.input_value_id
       and  et.element_type_id = piv.element_type_id
       and  p_session_date between ee.effective_start_date
                               and ee.effective_end_date
       and  p_session_date between eev.effective_start_date
                               and eev.effective_end_date
       and  p_session_date between piv.effective_start_date
                               and piv.effective_end_date
       and  p_session_date between et.effective_start_date
                               and et.effective_end_date;
   --
--
   cursor csr_creator_type
       (
        l_element_entry_id number,
        l_session_date     date
       ) is
       select ee.creator_type
         from pay_element_entries_f ee
        where ee.element_entry_id = l_element_entry_id
          and l_session_date between ee.effective_start_date and ee.effective_end_date;
   --
   -- Local Variables
   --
   v_creator_type        varchar2(30);
   v_num_entry_values    number := 0;
   v_input_value_id_tbl  hr_entry.number_table;
   v_entry_value_tbl     hr_entry.varchar2_table;
   --v_screen_format       varchar2(60);
   v_screen_format       varchar2(240);
   --v_db_format           varchar2(60);
   v_db_format           varchar2(240);
   v_element_link_id     number;
   v_entry_value_found   boolean := false;
   --
 begin
   g_debug := hr_utility.debug_enabled;
   --
   if g_debug then
      hr_utility.set_location('hr_entry.conv_to_table',5);
   end if;
   --
   --
   if p_creator_type = hr_api.g_varchar2 then
      open csr_creator_type(p_element_entry_id,p_session_date);
      fetch csr_creator_type into v_creator_type;
      close csr_creator_type;
   else
      v_creator_type := p_creator_type;
   end if;
   --
   -- User is inserting a new element entry.
   --
   if p_element_link_id is not null then
     --
     -- Find all the entry values for the specified element entry NB. it is a
     -- new element entry so have to get the details of the entry values from
     -- the element link.
     --
     for v_link_value in csr_link_input_value(p_element_link_id,
                                              p_session_date) loop
       --
       -- Keep a count of the number of entry values and put input_value_id of
       -- entry value into table.
       --
       v_entry_value_found                      := false;
       v_num_entry_values                       := v_num_entry_values + 1;
       v_input_value_id_tbl(v_num_entry_values) := v_link_value.input_value_id;
       --
       -- Has the user specified any entry values.
       --
       if p_num_entry_values > 0 then
         --
         -- Loop around the list of entry values set up by the user.
         --
         for v_loop in 1..p_num_entry_values loop
           --
           -- See if user has set a value for the entry value.
           --
           if p_input_value_id_tbl(v_loop) = v_link_value.input_value_id then
             --
             -- The entry value set by the user is in screen format so need to
             -- convert it to DB format.
             --
             if p_iv_format = 'SCREEN' then
               if g_debug then
                  hr_utility.trace('| Begin conv_table_to_table()');
               end if;
               --
               -- match found,
               -- one of the IV_IDs passed in matches the current IV_ID
               -- selected by the cursor
               --
               -- nb. all IV_IDs for an ET are passed in through forms,
               --     via the API, the user can explicitly specify IV_IDs
               --
               -- bug 546670, repeat validation as exists in
               -- conv_entry_values_to_table(),
               --
               if g_debug then
                  hr_utility.trace('| p_entry_type>' || p_entry_type || '<');
               end if;
               --
               IF v_creator_type IN ('F', 'H') AND p_entry_type <> 'A' THEN
                 if g_debug then
                    hr_utility.trace('| creator type in F or H and not A EE');
                 end if;

                 IF v_link_value.mandatory_flag = 'X'
                   -- Following commented out because user can entre null value too.
                   -- AND p_entry_value_tbl(v_loop) IS NOT NULL
                   THEN
                   if g_debug then
                      hr_utility.trace('| flag set to X and EV specified');
                   end if;
                   --
                   -- only raise the error if the EV does not match the
                   -- default value stored on PLIV
                   --
                   hr_entry_api.chk_user_enterable(
                     p_el_id               => p_element_link_id,
                     p_lookup_type         => v_link_value.lookup_type,
                     p_value_set_id        => v_link_value.value_set_id,
                     p_uom                 => v_link_value.uom,
                     p_default_value       => v_link_value.pliv_default_value,
                     p_input_currency_code => v_link_value.input_currency_code,
                     p_session_date        => p_session_date,
                     p_iv_id               => v_link_value.input_value_id,
                     p_ev                  => p_entry_value_tbl(v_loop),
                     p_creator_type        => v_creator_type,
                     p_hot_flag            => v_link_value.hot_default_flag);
                 END IF;

               END IF;
               --
               if g_debug then
                  hr_utility.trace('| End conv_table_to_table()');
               end if;
               --
               --
               v_screen_format := p_entry_value_tbl(v_loop);
               --
               -- bug 900288. Set v_db_format for each entry value.
               -- This is needed in cases where v_db_format is not set
               -- in validate_entry_value (such as lookups with a null
               -- screen_format) as otherwise v_db_format will be set to
               -- the value of the PREVIOUS input value
               v_db_format := v_screen_format;
               -- end bug 900288
               --
               hr_entry_api.validate_entry_value
                 (p_element_link_id,
                  v_link_value.input_value_id,
                  p_session_date,
                  v_screen_format,
                  v_db_format,
                  v_link_value.lookup_type,
                  v_link_value.uom,
                  v_link_value.input_currency_code,
                  v_link_value.value_set_id);
               --
               -- Put entry value into table.
               --
               v_entry_value_tbl(v_num_entry_values) := v_db_format;
               --
             else
               --
               -- Put entry value into table.
               --
               v_entry_value_tbl(v_num_entry_values) :=
                                             p_entry_value_tbl(v_loop);
               --
             end if;
             --
             -- Entry value has been found so stop searching through list of
             -- entry values set up by the user.
             --
             v_entry_value_found := true;
             exit;
             --
           end if;
           --
         end loop;
         --
       end if;
       --
       -- User has not set a value and entry value is not hot defaulted.
       --
       if not v_entry_value_found then
         --
         if v_link_value.hot_default_flag = 'N' then
           --
           -- Get any default if it has been set up.
           --
           hr_entry.derive_default_value
             (p_element_link_id,
              v_input_value_id_tbl(v_num_entry_values),
              p_session_date,
              v_link_value.input_currency_code,
              'DEF',
              v_screen_format,
              v_db_format);
           --
           -- Put entry value into table.
           --
           v_entry_value_tbl(v_num_entry_values) := v_db_format;
           --
         else
           --
           -- Put entry value into table.
           --
           v_entry_value_tbl(v_num_entry_values) := null;
           --
         end if;
       --
       end if;
       --
     end loop;
   --
   -- User is updating an existing element entry.
   --
   elsif p_element_entry_id is not null then
     --
     -- Find all the entry values for the specified element entry.
     --
     for v_entry_value in csr_entry_input_value(p_element_entry_id,
                                                p_session_date) loop
       --
       -- Keep a count of the number of entry values and put input_value_id of
       -- entry value into table.
       --
       v_entry_value_found := false;
       v_num_entry_values := v_num_entry_values + 1;
       v_input_value_id_tbl(v_num_entry_values) := v_entry_value.input_value_id;
       --
       -- Has the user specified any entry values.
       --
       if p_num_entry_values > 0 then
         --
         -- Loop around the list of entry values set up by the user.
         --
         for v_loop in 1..p_num_entry_values loop
           --
           -- See if user has set a value for the entry value.
           --
           if p_input_value_id_tbl(v_loop) = v_entry_value.input_value_id then
             --
             -- The entry value set by the user is in screen format so need to
             -- convert it to DB format.
             --
             if p_iv_format = 'SCREEN' then
               --
               IF v_creator_type IN ('F', 'H') AND p_entry_type <> 'A' THEN
                 if g_debug then
                    hr_utility.trace('| creator type in F or H and not A EE');
                 end if;
                 --
                 IF v_entry_value.mandatory_flag = 'X'
                   -- Following commented out because user can entre null value too.
                   -- AND p_entry_value_tbl(v_loop) IS NOT NULL
                   THEN
                   if g_debug then
                      hr_utility.trace('| flag set to X and EV specified');
                   end if;
                   --
                   -- only raise the error if the EV does not match the
                   -- existing value.
                   --
                   hr_entry_api.chk_user_enterable(
                     p_el_id               => v_entry_value.element_link_id,
                     p_lookup_type         => v_entry_value.lookup_type,
                     p_value_set_id        => v_entry_value.value_set_id,
                     p_uom                 => v_entry_value.uom,
                     p_default_value       => v_entry_value.peev_default_value,
                     p_input_currency_code => v_entry_value.input_currency_code,
                     p_session_date        => p_session_date,
                     p_iv_id               => v_entry_value.input_value_id,
                     p_ev                  => p_entry_value_tbl(v_loop),
                     p_mode                => 'U',
                     p_creator_type        => v_creator_type,
                     p_hot_flag            => v_entry_value.hot_default_flag);
                 END IF;

               END IF;
               --
               --
               v_screen_format := p_entry_value_tbl(v_loop);
               -- bug 900288
               v_db_format := v_screen_format;
               -- end bug 900288
               hr_entry_api.validate_entry_value
                 (v_entry_value.element_link_id,
                  v_entry_value.input_value_id,
                  p_session_date,
                  v_screen_format,
                  v_db_format,
                  v_entry_value.lookup_type,
                  v_entry_value.uom,
                  v_entry_value.input_currency_code,
                  v_entry_value.value_set_id);
               --
               -- Put entry value into table.
               --
               v_entry_value_tbl(v_num_entry_values) := v_db_format;
               --
             else
               --
               -- Put entry value into table.
               --
               v_entry_value_tbl(v_num_entry_values) :=
                                                  p_entry_value_tbl(v_loop);
               --
             end if;
             --
             -- Entry value has been found so stop searching through list of
             -- entry values set up by the user.
             --
             v_entry_value_found := true;
             exit;
           --
           end if;
         --
         end loop;
         --
       end if;
       --
       -- User has not set a value.
       --
       if not v_entry_value_found then
         --
         -- Use the existing value of the element entry.
         --
         v_entry_value_tbl(v_num_entry_values) :=
                                            v_entry_value.screen_entry_value;
       --
       end if;
     --
     end loop;
     --
   end if;
   --
   if g_debug then
      hr_utility.set_location('hr_entry.conv_table_to_table',10);
   end if;
   --
   -- Return tables containing the entry values in DB format.
   --
   p_num_entry_values   := v_num_entry_values;
   p_input_value_id_tbl := v_input_value_id_tbl;
   p_entry_value_tbl    := v_entry_value_tbl;
   --
 end conv_table_to_table;
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry_api.get_link                                                    --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Returns for the element link that represents the assignments eligibility --
 -- for a particular element type on a given date.                           --
 ------------------------------------------------------------------------------
--
 function get_link
 (
  p_assignment_id     number,
  p_element_type_id   number,
  p_session_date      date
 ) return number is
   --
   -- Local Variables
   --
   v_element_link_id number;
   --
 begin
   g_debug := hr_utility.debug_enabled;
   --
   begin
     select el.element_link_id
     into   v_element_link_id
     from   per_assignments_f asg,
            pay_element_links_f el
     where  asg.assignment_id = p_assignment_id
       and  el.business_group_id + 0 = asg.business_group_id + 0
       and  el.element_type_id = p_element_type_id
       and  p_session_date between asg.effective_start_date
                               and asg.effective_end_date
       and  p_session_date between el.effective_start_date
                               and el.effective_end_date
       and  ((el.payroll_id is not null and
              el.payroll_id = asg.payroll_id)
        or   (el.link_to_all_payrolls_flag = 'Y' and
              asg.payroll_id is not null)
        or   (el.payroll_id is null and
              el.link_to_all_payrolls_flag = 'N'))
       and  (el.job_id is null or
             el.job_id = asg.job_id)
       and  (el.grade_id is null or
             el.grade_id = asg.grade_id)
       and  (el.position_id is null or
             el.position_id = asg.position_id)
       and  (el.organization_id is null or
             el.organization_id = asg.organization_id)
       and  (el.location_id is null or
             el.location_id = asg.location_id)
       and  (el.pay_basis_id is null or
             el.pay_basis_id = asg.pay_basis_id)
       and  (el.employment_category is null or
             el.employment_category = asg.employment_category)
       and  (el.people_group_id is null or exists
               (select null
                from   pay_assignment_link_usages_f alu
                where  alu.assignment_id = asg.assignment_id
                  and  alu.element_link_id = el.element_link_id
                  and  p_session_date between alu.effective_start_date
                                          and alu.effective_end_date));
   exception
     when no_data_found then null;
   end;
   --
   return v_element_link_id;
   --
 end get_link;
--
 ------------------------------------------------------------------------------
 -- NAME
 -- hr_entry_api.validate_ppm_id
 --
 -- DESCRIPTION
 -- Make sure personal_payment_method_id exists
 ------------------------------------------------------------------------------
 --
 procedure validate_ppm_id (
 --
 p_personal_payment_method_id   number,
 p_assignment_id                number,
 p_element_link_id              number,
 p_effective_start_date         date,
 p_effective_end_date           date,
 p_entry_type                   varchar2) is
 --
 cursor personal_payment_method is
        select  min (ppm1.effective_start_date),
                max (ppm2.effective_end_date)
        from    pay_personal_payment_methods_f  PPM1,
                pay_personal_payment_methods_f  PPM2
        where   ppm1.personal_payment_method_id = p_personal_payment_method_id
        and     ppm2.personal_payment_method_id = p_personal_payment_method_id
        and     ppm1.assignment_id = p_assignment_id;
        --
 cursor third_party_element is
        select  1
        from    pay_element_types_f elt,
                pay_element_links_f eli
        where   eli.element_link_id = p_element_link_id
        and     eli.element_type_id = elt.element_type_id
        and     p_effective_start_date <= eli.effective_end_date
        and     p_effective_end_date >= eli.effective_start_date
        and     p_effective_start_date <= elt.effective_end_date
        and     p_effective_end_date >= elt.effective_start_date
        and     elt.third_party_pay_only_flag = 'Y';
        --
 l_ppm_start    date := null;
 l_ppm_end      date := null;
 l_dummy        integer (1);
 --
 begin
 --
 if p_personal_payment_method_id is null then
   --
   open third_party_element;
   fetch third_party_element into l_dummy;
   if third_party_element%found then
     --
     close third_party_element;
     --
     -- Special case exclusion for the Balance Adjustment entries.
     --
     if (p_entry_type <> 'B') then
       hr_utility.set_message (801, 'HR_7796_ENTRY_INVALID_PPM');
       hr_utility.raise_error;
     end if;
     --
     --
   else
     close third_party_element;
     return; -- Abort check.
   end if;
   --
 else
   --
   open third_party_element;
   fetch third_party_element into l_dummy;
   if third_party_element%notfound then
     --
     close third_party_element;
     hr_utility.set_message (801, 'HR_7795_ENTRY_NOT_3RD_PARTY');
     hr_utility.raise_error;
     --
   end if;
   --
   close third_party_element;
   open personal_payment_method;
   fetch personal_payment_method into l_ppm_start, l_ppm_end;
   --
   if personal_payment_method%notfound then
     --
     -- There was no personal_payment_method for the ID passed in
     --
     close personal_payment_method;
     hr_utility.set_message (801, 'HR_7796_ENTRY_INVALID_PPM');
     hr_utility.raise_error;
     --
   else
     --
     close personal_payment_method;
     --
     -- Check the dates of the entry and payment method
     --
     if (p_effective_start_date < l_ppm_start)
        or (p_effective_end_date > l_ppm_end) then
       --
       -- The payment method does not exist for the whole life of the entry
       --
       hr_utility.set_message (801, 'HR_7797_ENTRY_PPM_DATES');
       hr_utility.raise_error;
       --
     end if;
     --
   end if;
   --
 end if;
 --
 end validate_ppm_id;
 ------------------------------------------------------------------------------
 -- NAME
 -- hr_entry_api.validate_date_earned
 --
 -- DESCRIPTION
 -- Validate the date_earned column
 ------------------------------------------------------------------------------
 --
 procedure validate_date_earned (
 --
 p_date_earned          date,
 p_effective_start_date date,
 p_effective_end_date   date,
 p_element_link_id      number,
 p_entry_type           varchar2) is
 --
 cursor processing_type is
        select  1
        from    pay_element_types_f     ELT,
                pay_element_links_f     ELI
        where   eli.element_link_id = p_element_link_id
        and     eli.element_type_id = elt.element_type_id
        and     p_effective_start_date <= eli.effective_end_date
        and     p_effective_end_date >= eli.effective_start_date
        and     p_effective_start_date <= elt.effective_end_date
        and     p_effective_end_date >= elt.effective_start_date
        and     elt.processing_type = 'N';
        --
 l_dummy        integer (1);
 --
 begin
 --
 if g_debug then
    hr_utility.trace ('p_date_earned = '||p_date_earned);
    hr_utility.trace ('p_effective_start_date = '||p_effective_start_date);
    hr_utility.trace ('p_effective_end_date = '||p_effective_end_date);
    hr_utility.trace ('p_element_link_id = '||p_element_link_id);
    hr_utility.trace ('p_entry_type = '||p_entry_type);
 end if;
 --
 if p_date_earned is null then
   return; -- Abort check.
 else
   --
   if p_date_earned not between p_effective_start_date
                                and p_effective_end_date then
     --
     -- The date_earned must lie within the effective dates
     --
     hr_utility.set_message (801,'HR_7793_ENTRY_DATE_EARNED');
     hr_utility.raise_error;
     --
   else
     --
     -- Only nonrecurring entries may have date earned
     --
     if p_entry_type not in ('A','D','S','R') then
       --
       open processing_type;
       fetch processing_type into l_dummy;
       --
       if processing_type%notfound then
         --
         close processing_type;
         hr_utility.set_message (801, 'HR_7794_ENTRY_DATE_EARNED_NULL');
         hr_utility.raise_error;
         --
       end if;
       --
       close processing_type;
       --
     end if;
   end if;
 end if;
 --
 end validate_date_earned;
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry_api.val_assignment                                              ==
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Make sure assignment exists.                                             --
 ------------------------------------------------------------------------------
--
 procedure val_assignment
 (
  p_assignment_id         number,
  p_validation_start_date date
 ) is
--
   -- Local Variables
   v_number_variable number;
--
 begin
--
   -- Check assignment exists.
   begin
--
     select asg.assignment_id
     into   v_number_variable
     from   per_assignments_f asg
     where  asg.assignment_id = p_assignment_id
       and  p_validation_start_date between asg.effective_start_date
                                        and asg.effective_end_date;
--
   exception
     when no_data_found then
       hr_utility.set_message(801, 'HR_7026_ELE_ENTRY_ASS_NOT_EXST');
       hr_utility.set_message_token('DATE',fnd_date.date_to_canonical(p_validation_start_date));
       hr_utility.raise_error;
   end;
--
 end val_assignment;
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry_api.val_element_link                                            --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Make sure element link exists.                                           --
 ------------------------------------------------------------------------------
--
 procedure val_element_link
 (
  p_element_link_id       number,
  p_validation_start_date date
 ) is
--
   -- Local Variables
   v_number_variable number;
--
 begin
--
   -- Check element link exists.
   begin
--
     select el.element_link_id
     into   v_number_variable
     from   pay_element_links_f el
     where  el.element_link_id = p_element_link_id
       and  p_validation_start_date between el.effective_start_date
                                        and el.effective_end_date;
--
   exception
     when no_data_found then
       hr_utility.set_message(801, 'HR_7027_ELE_ENTRY_EL_NOT_EXST');
       hr_utility.set_message_token('DATE',fnd_date.date_to_canonical(p_validation_start_date));
       hr_utility.raise_error;
   end;
--
 end val_element_link;
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry_api.val_cost_allocation                                         --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Make sure cost allocation exists.                                        --
 ------------------------------------------------------------------------------
--
 procedure val_cost_allocation
 (
  p_cost_allocation_keyflex_id number
 ) is
--
   -- Local Variables
   v_number_variable number;
   v_exists varchar2(1);
   --
   -- Bugfix 2667184
   -- Ensure p_cost_allocation_keyflex_id belongs to cost_allocation_structure
   -- used by business group
   --
   cursor csr_valid_id_flex_num
   ( p_cost_allocation_keyflex_id number
   , p_business_group_id number) is
   select null
   from   per_business_groups_perf bg
        , pay_cost_allocation_keyflex cak
   where  cak.cost_allocation_keyflex_id = p_cost_allocation_keyflex_id
   and    bg.business_group_id = p_business_group_id
   and    to_char(cak.id_flex_num) = bg.cost_allocation_structure;
   --
--
 begin
--
   begin
--
     select cst.cost_allocation_keyflex_id
     into   v_number_variable
     from   pay_cost_allocation_keyflex cst
     where  cst.cost_allocation_keyflex_id = p_cost_allocation_keyflex_id;
--
   exception
     when no_data_found then
       hr_utility.set_message(801, 'HR_7028_ELE_ENTRY_CA_NOT_EXST');
       hr_utility.raise_error;
   end;
--
-- Bugfix 2667184
-- Ensure p_cost_allocation_keyflex_id belongs to cost_allocation_structure
-- used by business group
--
   open csr_valid_id_flex_num( p_cost_allocation_keyflex_id
                             , g_asg_info.business_group_id);
   fetch csr_valid_id_flex_num into v_exists;
   if csr_valid_id_flex_num%notfound then
      close csr_valid_id_flex_num;
      hr_utility.set_message(801,'HR_33130_INV_COST_ALLOC_KF');
      hr_utility.raise_error;
   else
      close csr_valid_id_flex_num;
   end if;
--
 end val_cost_allocation;
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry_api.val_comment                                                 --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Make sure comment exists.                                                --
 ------------------------------------------------------------------------------
--
 procedure val_comment
 (
  p_comment_id number
 ) is
--
   -- Local Variables
   v_number_variable number;
--
 begin
--
   begin
--
     select com.comment_id
     into   v_number_variable
     from   hr_comments com
     where  com.comment_id = p_comment_id;
--
   exception
     when no_data_found then
       hr_utility.set_message(801, 'HR_7029_ELE_ENTRY_CMT_NOT_EXST');
       hr_utility.raise_error;
   end;
--
 end val_comment;
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry_api.val_adjustment                                              --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Make sure adjustment is valid.                                           --
 ------------------------------------------------------------------------------
--
 procedure val_adjustment
 (
  p_assignment_id         number,
  p_element_link_id       number,
  p_target_entry_id       number,
  p_entry_type            varchar2,
  p_validation_start_date date
 ) is
--
   -- Local Variables
   v_number_variable number;
--
 begin
--
   begin
--
     select ee.element_entry_id
     into   v_number_variable
     from   pay_element_entries_f ee
     where  p_entry_type in ('R','A')
       and  ee.element_entry_id = p_target_entry_id
       and  ee.assignment_id = p_assignment_id
       and  ee.element_link_id = p_element_link_id
       and  ee.entry_type = 'E'
       and  exists
              (select null
               from   pay_element_links_f el,
                      pay_element_types_f et
               where  el.element_link_id = p_element_link_id
                 and  et.element_type_id = el.element_type_id
                 and  et.processing_type = 'R')
       and  p_validation_start_date between ee.effective_start_date
                                        and ee.effective_end_date;
--
   exception
     when no_data_found then
       hr_utility.set_message(801, 'HR_7030_ELE_ENTRY_INV_ADJ');
       hr_utility.raise_error;
   end;
--
 end val_adjustment;
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry_api.val_original_entry                                          --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Make sure original entry is valid.                                       --
 ------------------------------------------------------------------------------
--
 procedure val_original_entry
 (
  p_original_entry_id number,
  p_assignment_id     number,
  p_element_link_id   number,
  p_entry_type        varchar2,
  p_effective_date    date
 ) is
--
   -- Local Variables
   v_number_variable number;
--
   --
   -- Support for original entry adjustment. #3482270
   --
   -- When original_entry_id is specified on the adjustment entry,
   -- the original entry must exist with the following conditions.
   --
   -- 1. The entry is for the same assignment.
   -- 2. The entry is a recurring entry.
   -- 3. The entry type is 'E'.
   -- 4. The parent/original entry exists on the effective date.
   -- 5. The entry is not a retro entry.
   --
   -- Note: The link can be different between the original entry and
   --       the adjustment entry, hence p_element_link_id should not
   --       be used in this cursor.
   --
   cursor csr_adj_orig_entry
   is
     select 1
     from   pay_element_entries_f ee
           ,pay_element_links_f   el
           ,pay_element_types_f   et
     where  ee.assignment_id    = p_assignment_id
       and  nvl(ee.original_entry_id, ee.element_entry_id)
                                = p_original_entry_id
       and  ee.entry_type       = 'E'
       and  ee.creator_type not in ('R','EE','RR','PR','NR')
       and  p_effective_date between ee.effective_start_date
                                 and ee.effective_end_date
       and  el.element_link_id  = ee.element_link_id
       and  p_effective_date between el.effective_start_date
                                 and el.effective_end_date
       and  et.element_type_id  = el.element_type_id
       and  et.processing_type  = 'R'
       and  p_effective_date between et.effective_start_date
                                 and et.effective_end_date
       ;
   --
   l_proc     varchar2(80):= 'hr_entry_api.val_original_entry';
   --
 begin
--
   if g_debug then
      hr_utility.set_location('Entering: '||l_proc, 5);
   end if;

   begin
--
     if p_original_entry_id is null then
       --
       -- do nothing.
       --
       null;

     elsif p_entry_type = 'E' then

       if g_debug then
          hr_utility.set_location(l_proc, 20);
       end if;

       select 1
       into   v_number_variable
       from   sys.dual
       where  exists
              (select null
               from   pay_element_entries_f ee
                     ,pay_element_links_f el
                     ,pay_element_types_f et
               where  ee.assignment_id = p_assignment_id
                 and  ee.element_link_id = p_element_link_id
                 and  ee.element_entry_id = p_original_entry_id
                 and  ee.entry_type = 'E'
                 and  el.element_link_id = ee.element_link_id
                 and  ee.effective_start_date between el.effective_start_date
                                                  and el.effective_end_date
                 and  et.element_type_id = el.element_type_id
                 and  ee.effective_start_date between et.effective_start_date
                                                  and et.effective_end_date
                 and  et.processing_type = 'R');

     elsif p_entry_type = 'B' then

       if g_debug then
          hr_utility.set_location(l_proc, 30);
       end if;

       open csr_adj_orig_entry;
       fetch csr_adj_orig_entry into v_number_variable;
       if csr_adj_orig_entry%notfound then
         close csr_adj_orig_entry;
         raise no_data_found;
       end if;
       close csr_adj_orig_entry;

     else
       if g_debug then
          hr_utility.set_location(l_proc, 40);
       end if;

       raise no_data_found;
     end if;

--
   exception
     when no_data_found then
       hr_utility.set_message(801, 'HR_7031_ELE_ENTRY_OE_INVLD');
       hr_utility.raise_error;
   end;

   if g_debug then
      hr_utility.set_location('Leaving: '||l_proc, 80);
   end if;
--
 end val_original_entry;
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry_api.val_reason                                                  --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Make sure reason is valid.                                               --
 ------------------------------------------------------------------------------
--
 procedure val_reason
 (
  p_reason varchar2,
  p_effective_date date
 ) is
--
   -- Local Variables
   v_varchar_variable varchar2(30);
--
 begin
--
   begin
--
     select hl.lookup_code
     into   v_varchar_variable
     from   hr_lookups hl
     where  hl.lookup_type = 'ELE_ENTRY_REASON'
       and  hl.lookup_code = p_reason
       and  hl.enabled_flag = 'Y'
       and  p_effective_date between
            nvl(hl.start_date_active,p_effective_date) and nvl(hl.end_date_active,p_effective_date);
--
   exception
     when no_data_found then
       hr_utility.set_message(801, 'HR_7032_ELE_ENTRY_INV_REASON');
       hr_utility.raise_error;
   end;
--
 end val_reason;
--
-------------------------------------------------------------------------------
-- NAME                                                                      --
-- hr_entry_api.derive_element_type_id                                       --
--                                                                           --
-- DESCRIPTION                                                               --
-- Derives the element_type_id from the previously validated element_link_id --
-- The resulting element_type_id will populate the denormalised column,      --
-- element_type_id on pay_element_entries_f.                                 --
--                                                                           --
-------------------------------------------------------------------------------
FUNCTION derive_element_type_id (p_element_link_id in number
                                ,p_effective_date  in date)
RETURN number IS
--
l_ele_type_id pay_element_types_f.element_type_id%type;
--
BEGIN
  select element_type_id
  into   l_ele_type_id
  from   pay_element_links_f
  where  element_link_id = p_element_link_id
  and    p_effective_date between effective_start_date
                              and effective_end_date;
--
return l_ele_type_id;
--
END derive_element_type_id;
--
-------------------------------------------------------------------------------
-- NAME                                                                      --
-- hr_entry_api.derive_all_entry_values_null                                 --
--                                                                           --
-- DESCRIPTION                                                               --
-- If one or more Element Entry Values exist for the current Element Entry   --
-- and the SCREEN_ENTRY_VALUE for all those Entry Values is NULL, this       --
-- function returns 'Y', otherwise it returns NULL.                          --
--                                                                           --
-------------------------------------------------------------------------------
FUNCTION derive_all_entry_values_null (
  p_entry_value_tbl in hr_entry.varchar2_table
  ) RETURN varchar2
IS
  --
  l_all_entry_values_null varchar2(30);
  l_counter               number;
  --
BEGIN
  --
  g_debug := hr_utility.debug_enabled;
  --
  if g_debug then
      hr_utility.set_location(
        'Entering hr_entry_api.derive_all_entry_values_null', 5
        );
  end if;
  --
  -- First, check to see if there are any entry values...
  --
  if p_entry_value_tbl.COUNT > 0 then
    --
    if g_debug then
        hr_utility.set_location('derive_all_entry_values_null', 10);
    end if;
    --
    l_counter := 1;
    --
    -- Now, loop through and examine each entry value until either
    -- a non-null entry value is found or the last entry value is
    -- reached...
    --
    while l_counter <= p_entry_value_tbl.COUNT loop
      --
      -- We are not interested in further entry values if this one is not
      -- null...
      --
      exit when p_entry_value_tbl(l_counter) is not null;
      --
      if g_debug then
          hr_utility.set_location('derive_all_entry_values_null', 15);
          hr_utility.trace('| Entry value '||to_char(l_counter)||' is null.');
      end if;
      --
      if l_counter = p_entry_value_tbl.COUNT then
        --
        -- This is the last entry value, and it is null.
        -- Therefore all the previous entry values must be
        -- null too (otherwise we would have exited the loop).
        --
        if g_debug then
            hr_utility.set_location('derive_all_entry_values_null', 20);
            hr_utility.trace('| All entry values are null');
        end if;
        --
        l_all_entry_values_null := 'Y';
        --
      end if;
      --
      l_counter := l_counter + 1;
      --
    end loop;
    --
  else
    --
    -- There are no entry values for this element entry.
    --
    if g_debug then
        hr_utility.set_location('derive_all_entry_values_null', 25);
        hr_utility.trace('| No entry values exist');
    end if;
    --
    l_all_entry_values_null := null;
    --
  end if;
  --
  if g_debug then
      hr_utility.set_location('Leaving: derive_all_entry_values_null', 900);
      hr_utility.trace('| Returning l_all_entry_values_null: '||nvl(l_all_entry_values_null,'NULL'));
  end if;
  --
  return l_all_entry_values_null;
  --
END derive_all_entry_values_null;
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry_api.ins_ele_entry_param_val                                     --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Validates the parameters passed to hr_entry.insert_element_entry. See    --
 -- below for a list of the validation steps :                               --
 --                                                                          --
 -- 1. Check assignment exists.                                              --
 -- 2. Check element link exists.                                            --
 -- 3. Check costing exists if applicable.                                   --
 -- 4. Check comment exists if applicable.                                   --
 -- 5. Updating action cannot be set when creating an entry.                 --
 -- 6. For an adjustment a target entry should be set and the target entry   --
 --    should be recurring.                                                  --
 --                                                                          --
 -- NB. p_creator_type is validated by constraint                            --
 --     PAY_EL_ENTRY_CREATOR_TYPE_CHK                                        --
 --     p_entry_type is validated by constraint PAY_EL_ENTRY_ENTRY_TYPE_CHK. --
 ------------------------------------------------------------------------------
 procedure ins_ele_entry_param_val
 (
  p_effective_start_date       date,
  p_assignment_id              number,
  p_element_link_id            number,
  p_creator_type               varchar2,
  p_entry_type                 varchar2,
  p_cost_allocation_keyflex_id number,
  p_updating_action_id         number,
  p_updating_action_type       varchar2,
  p_comment_id                 number,
  p_original_entry_id          number,
  p_reason                     varchar2,
  p_target_entry_id            number
 ) is
   --
   -- Local variables
   --
   v_number_variable number;
   --
 begin
   --
   -- Make sure assignment exists
   --
   hr_entry_api.val_assignment
     (p_assignment_id,
      p_effective_start_date);
   --
   -- Make sure element link exists
   --
   hr_entry_api.val_element_link
     (p_element_link_id,
      p_effective_start_date);
   --
   -- If specified make sure cost allocation exists
   --
   if p_cost_allocation_keyflex_id is not null then
     --
     hr_entry_api.val_cost_allocation
       (p_cost_allocation_keyflex_id);
     --
   end if;
   --
   -- If specified make sure reason is a valid lookup
   --
   if p_reason is not null then
     --
     hr_entry_api.val_reason
       (p_reason,
        p_effective_start_date);
     --
   end if;
   --
   -- If specified make sure comment exists
   --
   if p_comment_id is not null then
     --
     hr_entry_api.val_comment
       (p_comment_id);
     --
   end if;
   --
   -- If specified make sure original entry is for the same assignment and
   -- element link as the element entry being created
   --
   if p_original_entry_id is not null then
     --
     hr_entry_api.val_original_entry
       (p_original_entry_id,
        p_assignment_id,
        p_element_link_id,
        p_entry_type,
        p_effective_start_date);
     --
   end if;
   --
   -- If element entry is an adjustment make sure that the target entry exists
   -- and that it is a normal entry for a recurring element
   --
   if p_entry_type in ('R','A') then
     --
     hr_entry_api.val_adjustment
       (p_assignment_id,
        p_element_link_id,
        p_target_entry_id,
        p_entry_type,
        p_effective_start_date);
     --
   end if;
   --
 end ins_ele_entry_param_val;
--
-- --
--
-- -----------------------------------------------------------------------
-- |-----------------------< ddf_insert_validate >-----------------------|
-- -----------------------------------------------------------------------
--
-- Description:
--   Validates the all Developer Descriptive Flexfield values prior
--   to insert.
--
-- Pre-conditions:
--   All other columns have been validated. Must be called as the
--   last step before ins_element_entry.
--
-- Post Success:
--   If the Developer Descriptive Flexfield structure column and data
--   values are all valid this procedure will end normally and processing
--   will continue.
--
-- Post Failure:
--   If the DDF structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
procedure ddf_insert_validate
  (
  p_entry_information_category varchar2  default null,
  p_entry_information1         varchar2  default null,
  p_entry_information2         varchar2  default null,
  p_entry_information3         varchar2  default null,
  p_entry_information4         varchar2  default null,
  p_entry_information5         varchar2  default null,
  p_entry_information6         varchar2  default null,
  p_entry_information7         varchar2  default null,
  p_entry_information8         varchar2  default null,
  p_entry_information9         varchar2  default null,
  p_entry_information10        varchar2  default null,
  p_entry_information11        varchar2  default null,
  p_entry_information12        varchar2  default null,
  p_entry_information13        varchar2  default null,
  p_entry_information14        varchar2  default null,
  p_entry_information15        varchar2  default null,
  p_entry_information16        varchar2  default null,
  p_entry_information17        varchar2  default null,
  p_entry_information18        varchar2  default null,
  p_entry_information19        varchar2  default null,
  p_entry_information20        varchar2  default null,
  p_entry_information21        varchar2  default null,
  p_entry_information22        varchar2  default null,
  p_entry_information23        varchar2  default null,
  p_entry_information24        varchar2  default null,
  p_entry_information25        varchar2  default null,
  p_entry_information26        varchar2  default null,
  p_entry_information27        varchar2  default null,
  p_entry_information28        varchar2  default null,
  p_entry_information29        varchar2  default null,
  p_entry_information30        varchar2  default null
  ) is
--
  l_proc    varchar2(72) := g_package||'ddf_insert_validate';
--
begin
  --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'PAY'
      ,p_descflex_name      => 'Element Entry Developer DF'
      ,p_attribute_category => p_entry_information_category
      ,p_attribute1_name    => 'ENTRY_INFORMATION1'
      ,p_attribute1_value   => p_entry_information1
      ,p_attribute2_name    => 'ENTRY_INFORMATION2'
      ,p_attribute2_value   => p_entry_information2
      ,p_attribute3_name    => 'ENTRY_INFORMATION3'
      ,p_attribute3_value   => p_entry_information3
      ,p_attribute4_name    => 'ENTRY_INFORMATION4'
      ,p_attribute4_value   => p_entry_information4
      ,p_attribute5_name    => 'ENTRY_INFORMATION5'
      ,p_attribute5_value   => p_entry_information5
      ,p_attribute6_name    => 'ENTRY_INFORMATION6'
      ,p_attribute6_value   => p_entry_information6
      ,p_attribute7_name    => 'ENTRY_INFORMATION7'
      ,p_attribute7_value   => p_entry_information7
      ,p_attribute8_name    => 'ENTRY_INFORMATION8'
      ,p_attribute8_value   => p_entry_information8
      ,p_attribute9_name    => 'ENTRY_INFORMATION9'
      ,p_attribute9_value   => p_entry_information9
      ,p_attribute10_name    => 'ENTRY_INFORMATION10'
      ,p_attribute10_value   => p_entry_information10
      ,p_attribute11_name    => 'ENTRY_INFORMATION11'
      ,p_attribute11_value   => p_entry_information11
      ,p_attribute12_name    => 'ENTRY_INFORMATION12'
      ,p_attribute12_value   => p_entry_information12
      ,p_attribute13_name    => 'ENTRY_INFORMATION13'
      ,p_attribute13_value   => p_entry_information13
      ,p_attribute14_name    => 'ENTRY_INFORMATION14'
      ,p_attribute14_value   => p_entry_information14
      ,p_attribute15_name    => 'ENTRY_INFORMATION15'
      ,p_attribute15_value   => p_entry_information15
      ,p_attribute16_name    => 'ENTRY_INFORMATION16'
      ,p_attribute16_value   => p_entry_information16
      ,p_attribute17_name    => 'ENTRY_INFORMATION17'
      ,p_attribute17_value   => p_entry_information17
      ,p_attribute18_name    => 'ENTRY_INFORMATION18'
      ,p_attribute18_value   => p_entry_information18
      ,p_attribute19_name    => 'ENTRY_INFORMATION19'
      ,p_attribute19_value   => p_entry_information19
      ,p_attribute20_name    => 'ENTRY_INFORMATION20'
      ,p_attribute20_value   => p_entry_information20
      ,p_attribute21_name    => 'ENTRY_INFORMATION21'
      ,p_attribute21_value   => p_entry_information21
      ,p_attribute22_name    => 'ENTRY_INFORMATION22'
      ,p_attribute22_value   => p_entry_information22
      ,p_attribute23_name    => 'ENTRY_INFORMATION23'
      ,p_attribute23_value   => p_entry_information23
      ,p_attribute24_name    => 'ENTRY_INFORMATION24'
      ,p_attribute24_value   => p_entry_information24
      ,p_attribute25_name    => 'ENTRY_INFORMATION25'
      ,p_attribute25_value   => p_entry_information25
      ,p_attribute26_name    => 'ENTRY_INFORMATION26'
      ,p_attribute26_value   => p_entry_information26
      ,p_attribute27_name    => 'ENTRY_INFORMATION27'
      ,p_attribute27_value   => p_entry_information27
      ,p_attribute28_name    => 'ENTRY_INFORMATION28'
      ,p_attribute28_value   => p_entry_information28
      ,p_attribute29_name    => 'ENTRY_INFORMATION29'
      ,p_attribute29_value   => p_entry_information29
      ,p_attribute30_name    => 'ENTRY_INFORMATION30'
      ,p_attribute30_value   => p_entry_information30
      );
end ddf_insert_validate;
--
-- --
--
-- -----------------------------------------------------------------------
-- |----------------------< ddf_update_validate >------------------------|
-- -----------------------------------------------------------------------
--
-- Description:
--   Validates the all Developer Descriptive Flexfield values prior
--   to update.
--
-- Pre-conditions:
--   All other columns have been validated. Must be called as the
--   last step before upd_element_entry.
--
-- Post Success:
--   If the Developer Descriptive Flexfield structure column and data
--   values are all valid this procedure will end normally and processing
--   will continue.
--
-- Post Failure:
--   If the DDF structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
procedure ddf_update_validate
  (
  p_entry_information_category varchar2  default null,
  p_entry_information1         varchar2  default null,
  p_entry_information2         varchar2  default null,
  p_entry_information3         varchar2  default null,
  p_entry_information4         varchar2  default null,
  p_entry_information5         varchar2  default null,
  p_entry_information6         varchar2  default null,
  p_entry_information7         varchar2  default null,
  p_entry_information8         varchar2  default null,
  p_entry_information9         varchar2  default null,
  p_entry_information10        varchar2  default null,
  p_entry_information11        varchar2  default null,
  p_entry_information12        varchar2  default null,
  p_entry_information13        varchar2  default null,
  p_entry_information14        varchar2  default null,
  p_entry_information15        varchar2  default null,
  p_entry_information16        varchar2  default null,
  p_entry_information17        varchar2  default null,
  p_entry_information18        varchar2  default null,
  p_entry_information19        varchar2  default null,
  p_entry_information20        varchar2  default null,
  p_entry_information21        varchar2  default null,
  p_entry_information22        varchar2  default null,
  p_entry_information23        varchar2  default null,
  p_entry_information24        varchar2  default null,
  p_entry_information25        varchar2  default null,
  p_entry_information26        varchar2  default null,
  p_entry_information27        varchar2  default null,
  p_entry_information28        varchar2  default null,
  p_entry_information29        varchar2  default null,
  p_entry_information30        varchar2  default null,
  p_entry_information_category_o varchar2  default null,
  p_entry_information1_o         varchar2  default null,
  p_entry_information2_o         varchar2  default null,
  p_entry_information3_o         varchar2  default null,
  p_entry_information4_o         varchar2  default null,
  p_entry_information5_o         varchar2  default null,
  p_entry_information6_o         varchar2  default null,
  p_entry_information7_o         varchar2  default null,
  p_entry_information8_o         varchar2  default null,
  p_entry_information9_o         varchar2  default null,
  p_entry_information10_o        varchar2  default null,
  p_entry_information11_o        varchar2  default null,
  p_entry_information12_o        varchar2  default null,
  p_entry_information13_o        varchar2  default null,
  p_entry_information14_o        varchar2  default null,
  p_entry_information15_o        varchar2  default null,
  p_entry_information16_o        varchar2  default null,
  p_entry_information17_o        varchar2  default null,
  p_entry_information18_o        varchar2  default null,
  p_entry_information19_o        varchar2  default null,
  p_entry_information20_o        varchar2  default null,
  p_entry_information21_o        varchar2  default null,
  p_entry_information22_o        varchar2  default null,
  p_entry_information23_o        varchar2  default null,
  p_entry_information24_o        varchar2  default null,
  p_entry_information25_o        varchar2  default null,
  p_entry_information26_o        varchar2  default null,
  p_entry_information27_o        varchar2  default null,
  p_entry_information28_o        varchar2  default null,
  p_entry_information29_o        varchar2  default null,
  p_entry_information30_o        varchar2  default null
  ) is
--
  l_proc    varchar2(72) := g_package||'ddf_update_validate';
  -- local attribute values
  l_attribute1_value    varchar2(150);
  l_attribute2_value    varchar2(150);
  l_attribute3_value    varchar2(150);
  l_attribute4_value    varchar2(150);
  l_attribute5_value    varchar2(150);
  l_attribute6_value    varchar2(150);
  l_attribute7_value    varchar2(150);
  l_attribute8_value    varchar2(150);
  l_attribute9_value    varchar2(150);
  l_attribute10_value   varchar2(150);
  l_attribute11_value   varchar2(150);
  l_attribute12_value   varchar2(150);
  l_attribute13_value   varchar2(150);
  l_attribute14_value   varchar2(150);
  l_attribute15_value   varchar2(150);
  l_attribute16_value   varchar2(150);
  l_attribute17_value   varchar2(150);
  l_attribute18_value   varchar2(150);
  l_attribute19_value   varchar2(150);
  l_attribute20_value   varchar2(150);
  l_attribute21_value   varchar2(150);
  l_attribute22_value   varchar2(150);
  l_attribute23_value   varchar2(150);
  l_attribute24_value   varchar2(150);
  l_attribute25_value   varchar2(150);
  l_attribute26_value   varchar2(150);
  l_attribute27_value   varchar2(150);
  l_attribute28_value   varchar2(150);
  l_attribute29_value   varchar2(150);
  l_attribute30_value   varchar2(150);
--
begin
  --
  if nvl(p_entry_information_category,hr_api.g_varchar2) <>
     nvl(p_entry_information_category_o,hr_api.g_varchar2) or
     nvl(p_entry_information1,hr_api.g_varchar2) <>
     nvl(p_entry_information1_o,hr_api.g_varchar2) or
     nvl(p_entry_information2,hr_api.g_varchar2) <>
     nvl(p_entry_information2_o,hr_api.g_varchar2) or
     nvl(p_entry_information3,hr_api.g_varchar2) <>
     nvl(p_entry_information3_o,hr_api.g_varchar2) or
     nvl(p_entry_information4,hr_api.g_varchar2) <>
     nvl(p_entry_information4_o,hr_api.g_varchar2) or
     nvl(p_entry_information5,hr_api.g_varchar2) <>
     nvl(p_entry_information5_o,hr_api.g_varchar2) or
     nvl(p_entry_information6,hr_api.g_varchar2) <>
     nvl(p_entry_information6_o,hr_api.g_varchar2) or
     nvl(p_entry_information7,hr_api.g_varchar2) <>
     nvl(p_entry_information7_o,hr_api.g_varchar2) or
     nvl(p_entry_information8,hr_api.g_varchar2) <>
     nvl(p_entry_information8_o,hr_api.g_varchar2) or
     nvl(p_entry_information9,hr_api.g_varchar2) <>
     nvl(p_entry_information9_o,hr_api.g_varchar2) or
     nvl(p_entry_information10,hr_api.g_varchar2) <>
     nvl(p_entry_information10_o,hr_api.g_varchar2) or
     nvl(p_entry_information11,hr_api.g_varchar2) <>
     nvl(p_entry_information11_o,hr_api.g_varchar2) or
     nvl(p_entry_information12,hr_api.g_varchar2) <>
     nvl(p_entry_information12_o,hr_api.g_varchar2) or
     nvl(p_entry_information13,hr_api.g_varchar2) <>
     nvl(p_entry_information13_o,hr_api.g_varchar2) or
     nvl(p_entry_information14,hr_api.g_varchar2) <>
     nvl(p_entry_information14_o,hr_api.g_varchar2) or
     nvl(p_entry_information15,hr_api.g_varchar2) <>
     nvl(p_entry_information15_o,hr_api.g_varchar2) or
     nvl(p_entry_information16,hr_api.g_varchar2) <>
     nvl(p_entry_information16_o,hr_api.g_varchar2) or
     nvl(p_entry_information17,hr_api.g_varchar2) <>
     nvl(p_entry_information17_o,hr_api.g_varchar2) or
     nvl(p_entry_information18,hr_api.g_varchar2) <>
     nvl(p_entry_information18_o,hr_api.g_varchar2) or
     nvl(p_entry_information19,hr_api.g_varchar2) <>
     nvl(p_entry_information19_o,hr_api.g_varchar2) or
     nvl(p_entry_information20,hr_api.g_varchar2) <>
     nvl(p_entry_information20_o,hr_api.g_varchar2) or
     nvl(p_entry_information21,hr_api.g_varchar2) <>
     nvl(p_entry_information21_o,hr_api.g_varchar2) or
     nvl(p_entry_information22,hr_api.g_varchar2) <>
     nvl(p_entry_information22_o,hr_api.g_varchar2) or
     nvl(p_entry_information23,hr_api.g_varchar2) <>
     nvl(p_entry_information23_o,hr_api.g_varchar2) or
     nvl(p_entry_information24,hr_api.g_varchar2) <>
     nvl(p_entry_information24_o,hr_api.g_varchar2) or
     nvl(p_entry_information25,hr_api.g_varchar2) <>
     nvl(p_entry_information25_o,hr_api.g_varchar2) or
     nvl(p_entry_information26,hr_api.g_varchar2) <>
     nvl(p_entry_information26_o,hr_api.g_varchar2) or
     nvl(p_entry_information27,hr_api.g_varchar2) <>
     nvl(p_entry_information27_o,hr_api.g_varchar2) or
     nvl(p_entry_information28,hr_api.g_varchar2) <>
     nvl(p_entry_information28_o,hr_api.g_varchar2) or
     nvl(p_entry_information29,hr_api.g_varchar2) <>
     nvl(p_entry_information29_o,hr_api.g_varchar2) or
     nvl(p_entry_information30,hr_api.g_varchar2) <>
     nvl(p_entry_information30_o,hr_api.g_varchar2)
  then
    --
    -- For validation purposes only, we use null instead of
    -- hr_api.g_varchar2
    --
    if p_entry_information1 = hr_api.g_varchar2 then
      l_attribute1_value := null;
    else
      l_attribute1_value := p_entry_information1;
    end if;
    --
    if p_entry_information2 = hr_api.g_varchar2 then
      l_attribute2_value := null;
    else
      l_attribute2_value := p_entry_information2;
    end if;
    --
    if p_entry_information3 = hr_api.g_varchar2 then
      l_attribute3_value := null;
    else
      l_attribute3_value := p_entry_information3;
    end if;
    --
    if p_entry_information4 = hr_api.g_varchar2 then
      l_attribute4_value := null;
    else
      l_attribute4_value := p_entry_information4;
    end if;
    --
    if p_entry_information5 = hr_api.g_varchar2 then
      l_attribute5_value := null;
    else
      l_attribute5_value := p_entry_information5;
    end if;
    --
    if p_entry_information6 = hr_api.g_varchar2 then
      l_attribute6_value := null;
    else
      l_attribute6_value := p_entry_information6;
    end if;
    --
    if p_entry_information7 = hr_api.g_varchar2 then
      l_attribute7_value := null;
    else
      l_attribute7_value := p_entry_information7;
    end if;
    --
    if p_entry_information8 = hr_api.g_varchar2 then
      l_attribute8_value := null;
    else
      l_attribute8_value := p_entry_information8;
    end if;
    --
    if p_entry_information9 = hr_api.g_varchar2 then
      l_attribute9_value := null;
    else
      l_attribute9_value := p_entry_information9;
    end if;
    --
    if p_entry_information10 = hr_api.g_varchar2 then
      l_attribute10_value := null;
    else
      l_attribute10_value := p_entry_information10;
    end if;
    --
    if p_entry_information11 = hr_api.g_varchar2 then
      l_attribute11_value := null;
    else
      l_attribute11_value := p_entry_information11;
    end if;
    --
    if p_entry_information12 = hr_api.g_varchar2 then
      l_attribute12_value := null;
    else
      l_attribute12_value := p_entry_information12;
    end if;
    --
    if p_entry_information13 = hr_api.g_varchar2 then
      l_attribute13_value := null;
    else
      l_attribute13_value := p_entry_information13;
    end if;
    --
    if p_entry_information14 = hr_api.g_varchar2 then
      l_attribute14_value := null;
    else
      l_attribute14_value := p_entry_information14;
    end if;
    --
    if p_entry_information15 = hr_api.g_varchar2 then
      l_attribute15_value := null;
    else
      l_attribute15_value := p_entry_information15;
    end if;
    --
    if p_entry_information16 = hr_api.g_varchar2 then
      l_attribute16_value := null;
    else
      l_attribute16_value := p_entry_information16;
    end if;
    --
    if p_entry_information17 = hr_api.g_varchar2 then
      l_attribute17_value := null;
    else
      l_attribute17_value := p_entry_information17;
    end if;
    --
    if p_entry_information18 = hr_api.g_varchar2 then
      l_attribute18_value := null;
    else
      l_attribute18_value := p_entry_information18;
    end if;
    --
    if p_entry_information19 = hr_api.g_varchar2 then
      l_attribute19_value := null;
    else
      l_attribute19_value := p_entry_information19;
    end if;
    --
    if p_entry_information20 = hr_api.g_varchar2 then
      l_attribute20_value := null;
    else
      l_attribute20_value := p_entry_information20;
    end if;
    --
    if p_entry_information21 = hr_api.g_varchar2 then
      l_attribute21_value := null;
    else
      l_attribute21_value := p_entry_information21;
    end if;
    --
    if p_entry_information22 = hr_api.g_varchar2 then
      l_attribute22_value := null;
    else
      l_attribute22_value := p_entry_information22;
   end if;
    --
    if p_entry_information23 = hr_api.g_varchar2 then
      l_attribute23_value := null;
    else
      l_attribute23_value := p_entry_information23;
    end if;
    --
    if p_entry_information24 = hr_api.g_varchar2 then
      l_attribute24_value := null;
    else
      l_attribute24_value := p_entry_information24;
    end if;
    --
    if p_entry_information25 = hr_api.g_varchar2 then
      l_attribute25_value := null;
    else
      l_attribute25_value := p_entry_information25;
    end if;
    --
    if p_entry_information26 = hr_api.g_varchar2 then
      l_attribute26_value := null;
    else
      l_attribute26_value := p_entry_information26;
    end if;
    --
    if p_entry_information27 = hr_api.g_varchar2 then
      l_attribute27_value := null;
    else
      l_attribute27_value := p_entry_information27;
    end if;
    --
    if p_entry_information28 = hr_api.g_varchar2 then
      l_attribute28_value := null;
    else
      l_attribute28_value := p_entry_information28;
    end if;
    --
    if p_entry_information29 = hr_api.g_varchar2 then
      l_attribute29_value := null;
    else
      l_attribute29_value := p_entry_information29;
    end if;
    --
    if p_entry_information30 = hr_api.g_varchar2 then
      l_attribute30_value := null;
    else
      l_attribute30_value := p_entry_information30;
    end if;
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'PAY'
      ,p_descflex_name      => 'Element Entry Developer DF'
      ,p_attribute_category => p_entry_information_category
      ,p_attribute1_name    => 'ENTRY_INFORMATION1'
      ,p_attribute1_value   => l_attribute1_value
      ,p_attribute2_name    => 'ENTRY_INFORMATION2'
      ,p_attribute2_value   => l_attribute2_value
      ,p_attribute3_name    => 'ENTRY_INFORMATION3'
      ,p_attribute3_value   => l_attribute3_value
      ,p_attribute4_name    => 'ENTRY_INFORMATION4'
      ,p_attribute4_value   => l_attribute4_value
      ,p_attribute5_name    => 'ENTRY_INFORMATION5'
      ,p_attribute5_value   => l_attribute5_value
      ,p_attribute6_name    => 'ENTRY_INFORMATION6'
      ,p_attribute6_value   => l_attribute6_value
      ,p_attribute7_name    => 'ENTRY_INFORMATION7'
      ,p_attribute7_value   => l_attribute7_value
      ,p_attribute8_name    => 'ENTRY_INFORMATION8'
      ,p_attribute8_value   => l_attribute8_value
      ,p_attribute9_name    => 'ENTRY_INFORMATION9'
      ,p_attribute9_value   => l_attribute9_value
      ,p_attribute10_name    => 'ENTRY_INFORMATION10'
      ,p_attribute10_value   => l_attribute10_value
      ,p_attribute11_name    => 'ENTRY_INFORMATION11'
      ,p_attribute11_value   => l_attribute11_value
      ,p_attribute12_name    => 'ENTRY_INFORMATION12'
      ,p_attribute12_value   => l_attribute12_value
      ,p_attribute13_name    => 'ENTRY_INFORMATION13'
      ,p_attribute13_value   => l_attribute13_value
      ,p_attribute14_name    => 'ENTRY_INFORMATION14'
      ,p_attribute14_value   => l_attribute14_value
      ,p_attribute15_name    => 'ENTRY_INFORMATION15'
      ,p_attribute15_value   => l_attribute15_value
      ,p_attribute16_name    => 'ENTRY_INFORMATION16'
      ,p_attribute16_value   => l_attribute16_value
      ,p_attribute17_name    => 'ENTRY_INFORMATION17'
      ,p_attribute17_value   => l_attribute17_value
      ,p_attribute18_name    => 'ENTRY_INFORMATION18'
      ,p_attribute18_value   => l_attribute18_value
      ,p_attribute19_name    => 'ENTRY_INFORMATION19'
      ,p_attribute19_value   => l_attribute19_value
      ,p_attribute20_name    => 'ENTRY_INFORMATION20'
      ,p_attribute20_value   => l_attribute20_value
      ,p_attribute21_name    => 'ENTRY_INFORMATION21'
      ,p_attribute21_value   => l_attribute21_value
      ,p_attribute22_name    => 'ENTRY_INFORMATION22'
      ,p_attribute22_value   => l_attribute22_value
      ,p_attribute23_name    => 'ENTRY_INFORMATION23'
      ,p_attribute23_value   => l_attribute23_value
      ,p_attribute24_name    => 'ENTRY_INFORMATION24'
      ,p_attribute24_value   => l_attribute24_value
      ,p_attribute25_name    => 'ENTRY_INFORMATION25'
      ,p_attribute25_value   => l_attribute25_value
      ,p_attribute26_name    => 'ENTRY_INFORMATION26'
      ,p_attribute26_value   => l_attribute26_value
      ,p_attribute27_name    => 'ENTRY_INFORMATION27'
      ,p_attribute27_value   => l_attribute27_value
      ,p_attribute28_name    => 'ENTRY_INFORMATION28'
      ,p_attribute28_value   => l_attribute28_value
      ,p_attribute29_name    => 'ENTRY_INFORMATION29'
      ,p_attribute29_value   => l_attribute29_value
      ,p_attribute30_name    => 'ENTRY_INFORMATION30'
      ,p_attribute30_value   => l_attribute30_value
      );
  --
  end if;
  --
end ddf_update_validate;
--
-- --
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry_api.ins_element_entry                                           --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Inserts an element entry providing full validation and also making sure  --
 -- the end date is set correctly ie. taking into account future entries,    --
 -- chnages in eligibility etc ...                                           --
 ------------------------------------------------------------------------------
--
 procedure ins_element_entry
 (
  --
  -- Common Parameters
  --
  p_effective_start_date       in out nocopy date,
  p_effective_end_date         in out nocopy date,
  --
  -- Element Entry Table
  --
  p_element_entry_id           in out nocopy number,
  p_original_entry_id          number,
  p_assignment_id              number,
  p_element_link_id            number,
  p_creator_type               varchar2,
  p_entry_type                 varchar2,
  p_cost_allocation_keyflex_id number,
  p_updating_action_id         number,
  p_updating_action_type       varchar2,
  p_comment_id                 number,
  p_creator_id                 number,
  p_reason                     varchar2,
  p_target_entry_id            number,
  p_subpriority                number,
  p_date_earned                 date,
  p_personal_payment_method_id  number,
  p_attribute_category         varchar2,
  p_attribute1                 varchar2,
  p_attribute2                 varchar2,
  p_attribute3                 varchar2,
  p_attribute4                 varchar2,
  p_attribute5                 varchar2,
  p_attribute6                 varchar2,
  p_attribute7                 varchar2,
  p_attribute8                 varchar2,
  p_attribute9                 varchar2,
  p_attribute10                varchar2,
  p_attribute11                varchar2,
  p_attribute12                varchar2,
  p_attribute13                varchar2,
  p_attribute14                varchar2,
  p_attribute15                varchar2,
  p_attribute16                varchar2,
  p_attribute17                varchar2,
  p_attribute18                varchar2,
  p_attribute19                varchar2,
  p_attribute20                varchar2,
  --
  -- Element Entry Values Table
  --
  p_num_entry_values           number,
  p_input_value_id_tbl         hr_entry.number_table,
  p_entry_value_tbl            hr_entry.varchar2_table,
  --
  -- J.Bailie Element Entries DDF
  --
  p_entry_information_category varchar2,
  p_entry_information1         varchar2,
  p_entry_information2         varchar2,
  p_entry_information3         varchar2,
  p_entry_information4         varchar2,
  p_entry_information5         varchar2,
  p_entry_information6         varchar2,
  p_entry_information7         varchar2,
  p_entry_information8         varchar2,
  p_entry_information9         varchar2,
  p_entry_information10        varchar2,
  p_entry_information11        varchar2,
  p_entry_information12        varchar2,
  p_entry_information13        varchar2,
  p_entry_information14        varchar2,
  p_entry_information15        varchar2,
  p_entry_information16        varchar2,
  p_entry_information17        varchar2,
  p_entry_information18        varchar2,
  p_entry_information19        varchar2,
  p_entry_information20        varchar2,
  p_entry_information21        varchar2,
  p_entry_information22        varchar2,
  p_entry_information23        varchar2,
  p_entry_information24        varchar2,
  p_entry_information25        varchar2,
  p_entry_information26        varchar2,
  p_entry_information27        varchar2,
  p_entry_information28        varchar2,
  p_entry_information29        varchar2,
  p_entry_information30        varchar2,
  p_label_identifier           varchar2
  ) is
   -- bug 666197
   cursor csr_object_version_number
     (p_element_entry_id number, p_effective_date date) is
      select object_version_number
        from pay_element_entries_f
        where element_entry_id = p_element_entry_id
          and p_effective_date between effective_start_date
                                   and effective_end_date;
   --
   -- Local Variables
   --
   v_element_entry_id   number;
   v_dummy_varchar      varchar2(30);
   l_object_version_number number;
   -- bug 666197
   l_effective_date date;
   --
   v_validation_start_date date;
   v_validation_end_date   date;
   --
   l_element_type_id       pay_element_types_f.element_type_id%type;
   --
   l_all_entry_values_null varchar2(30);
   --
 begin
   --
   -- bug 666197
   l_effective_date := p_effective_start_date;
   --
   -- Validate the parameters
   --
   hr_entry_api.ins_ele_entry_param_val
     (p_effective_start_date,
      p_assignment_id,
      p_element_link_id,
      p_creator_type,
      p_entry_type,
      p_cost_allocation_keyflex_id,
      p_updating_action_id,
      p_updating_action_type,
      p_comment_id,
      p_original_entry_id,
      p_reason,
      p_target_entry_id);
   --
   -- Validate the entry that is about to be created and also returns the
   -- valid start and end dates.
   --
   hr_entry.chk_element_entry_main
     (null,
      null,
      p_effective_start_date,
      p_element_link_id,
      p_assignment_id,
      p_entry_type,
      p_effective_start_date,
      p_effective_end_date,
      l_effective_date,
      hr_general.end_of_time,
      null,
      null,
      'INSERT',
      p_target_entry_id,
      p_creator_type);
   --
   -- Validate the date earned and personal_payment_method_id.
   -- NB These must be validated AFTER the effective dates have been
   -- determined.
   --
   validate_ppm_id (p_personal_payment_method_id,
                p_assignment_id,
                p_element_link_id,
                p_effective_start_date,
                p_effective_end_date,
                p_entry_type);
                --
   validate_date_earned (p_date_earned,
                        p_effective_start_date,
                        p_effective_end_date,
                        p_element_link_id,
                        p_entry_type);
                        --
   -- Trigger workload shifting if creation of element entry overlaps with the
   -- latest payroll run for the assignment and workload shifting is enabled.
   --
   hr_entry.trigger_workload_shifting
     ('ELEMENT_ENTRY',
      p_assignment_id,
      p_effective_start_date,
      p_effective_end_date);
   --
   -- J.Bailie 08-NOV-99 ddf_insert_validate needs to go in here
   --
  --
  -- check whether flexfield exists
  --
  if fnd_flex_dsc_api.flexfield_exists(
            appl_short_name => 'PAY',
            flexfield_name  => 'Element Entry Developer DF') then

    if g_debug then
       hr_utility.trace('| element entry DDFF defined');
       hr_utility.trace('| p_entry_information_category' ||
                           p_entry_information_category || '<');
    end if;

    --
    -- check whether the context value in ENTRY.entry_information_category
    -- has been defined/registered,
    -- only do FF validation if the context value has been defined/registered
    --
   if fnd_flex_dsc_api.context_exists(
         p_appl_short_name => 'PAY',
         p_flexfield_name  => 'Element Entry Developer DF',
         p_context_code    => p_entry_information_category) then

      if g_debug then
         hr_utility.trace('| element entry context in use, do validation');
      end if;

      hr_entry_api.ddf_insert_validate(
      p_entry_information_category,
         p_entry_information1,
         p_entry_information2,
         p_entry_information3,
         p_entry_information4,
         p_entry_information5,
         p_entry_information6,
         p_entry_information7,
         p_entry_information8,
         p_entry_information9,
         p_entry_information10,
         p_entry_information11,
         p_entry_information12,
         p_entry_information13,
         p_entry_information14,
         p_entry_information15,
         p_entry_information16,
         p_entry_information17,
         p_entry_information18,
         p_entry_information19,
         p_entry_information20,
         p_entry_information21,
         p_entry_information22,
         p_entry_information23,
         p_entry_information24,
         p_entry_information25,
         p_entry_information26,
         p_entry_information27,
         p_entry_information28,
         p_entry_information29,
         p_entry_information30);

     end if;

   end if;
   --
   -- Element_type_id denormalisation - the element_type_id will be derived
   -- from the element_link_id which has already been validated.
   --
     l_element_type_id := derive_element_type_id
                          (p_element_link_id => p_element_link_id
                          ,p_effective_date  => l_effective_date);
   --
   --
   --
   v_element_entry_id := hr_entry.generate_entry_id;
   --
   -- Bugfix 3110853
   -- Derive the OVN here instead of in the database trigger in order to
   -- avoid the ORA-04091 error
   --
   l_object_version_number := dt_api.get_object_version_number
                              ('PAY_ELEMENT_ENTRIES_F'
                              ,'ELEMENT_ENTRY_ID'
                              ,v_element_entry_id);
   --
   -- Enhancement 3478848
   -- Derive the all_entry_values_null value
   --
   l_all_entry_values_null := derive_all_entry_values_null(p_entry_value_tbl);
   --
   -- Create element entry
   --
   insert into pay_element_entries_f
   (effective_start_date,
    effective_end_date,
    element_entry_id,
    original_entry_id,
    assignment_id,
    element_link_id,
    creator_type,
    entry_type,
    cost_allocation_keyflex_id,
    updating_action_id,
    updating_action_type,
    comment_id,
    creator_id,
    reason,
    target_entry_id,
    subpriority,
    date_earned,
    personal_payment_method_id,
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
    last_update_date,
    last_updated_by,
    last_update_login,
    created_by,
    creation_date,
  --
  -- J.Bailie 08-NOV-99 Element Entries DDF
  --
    entry_information_category,
    entry_information1,
    entry_information2,
    entry_information3,
    entry_information4,
    entry_information5,
    entry_information6,
    entry_information7,
    entry_information8,
    entry_information9,
    entry_information10,
    entry_information11,
    entry_information12,
    entry_information13,
    entry_information14,
    entry_information15,
    entry_information16,
    entry_information17,
    entry_information18,
    entry_information19,
    entry_information20,
    entry_information21,
    entry_information22,
    entry_information23,
    entry_information24,
    entry_information25,
    entry_information26,
    entry_information27,
    entry_information28,
    entry_information29,
    entry_information30,
    element_type_id,
    all_entry_values_null,
    object_version_number,
    label_identifier
   )
   values
   (p_effective_start_date,
    p_effective_end_date,
    v_element_entry_id,
    p_original_entry_id,
    p_assignment_id,
    p_element_link_id,
    p_creator_type,
    p_entry_type,
    p_cost_allocation_keyflex_id,
    p_updating_action_id,
    p_updating_action_type,
    p_comment_id,
    p_creator_id,
    p_reason,
    p_target_entry_id,
    p_subpriority,
    p_date_earned,
    p_personal_payment_method_id,
    p_attribute_category,
    p_attribute1,
    p_attribute2,
    p_attribute3,
    p_attribute4,
    p_attribute5,
    p_attribute6,
    p_attribute7,
    p_attribute8,
    p_attribute9,
    p_attribute10,
    p_attribute11,
    p_attribute12,
    p_attribute13,
    p_attribute14,
    p_attribute15,
    p_attribute16,
    p_attribute17,
    p_attribute18,
    p_attribute19,
    p_attribute20,
    trunc(sysdate),
    0,
    0,
    -- Bug 570156 changed to null so the PAY_ELEMENT_ENTRIES_F_WHO trigger
    -- can set it. These parameters are not needed here at all, as the form
    -- is not passing them and api should not set them. It's always done via
    -- the database trigger.
    null,
    null,
  --
  -- J.Bailie 08-NOV-99 Element Entries DDF
  --
    p_entry_information_category,
    p_entry_information1,
    p_entry_information2,
    p_entry_information3,
    p_entry_information4,
    p_entry_information5,
    p_entry_information6,
    p_entry_information7,
    p_entry_information8,
    p_entry_information9,
    p_entry_information10,
    p_entry_information11,
    p_entry_information12,
    p_entry_information13,
    p_entry_information14,
    p_entry_information15,
    p_entry_information16,
    p_entry_information17,
    p_entry_information18,
    p_entry_information19,
    p_entry_information20,
    p_entry_information21,
    p_entry_information22,
    p_entry_information23,
    p_entry_information24,
    p_entry_information25,
    p_entry_information26,
    p_entry_information27,
    p_entry_information28,
    p_entry_information29,
    p_entry_information30,
    l_element_type_id,
    l_all_entry_values_null,
    l_object_version_number,
    p_label_identifier
   );
   --
   -- Create the entry values
   --
   hr_entry.ins_3p_entry_values
     (p_element_link_id,
      v_element_entry_id,
      p_effective_start_date,
      p_num_entry_values,
      p_input_value_id_tbl,
      p_entry_value_tbl);
   --
   -- Return the element entry id of the entry being created
   --
   p_element_entry_id := v_element_entry_id;
   --
   -- bug 666197, retrieve object version number; call to the user hook procedure
   --
   -- Bugfix 3110853
   -- No longer need to fetch the OVN as it has been derived already
   /*
   open csr_object_version_number(p_element_entry_id, p_effective_start_date);
   fetch csr_object_version_number into l_object_version_number;
   close csr_object_version_number;
   */
   --
   begin
   --
   pay_ele_rki.after_insert
   -- p_validation_start/end_date are not supported until the proper API implementation
     ( p_effective_date                 => l_effective_date
      ,p_validation_start_date          => v_validation_start_date
      ,p_validation_end_date            => v_validation_end_date
      ,p_effective_start_date           => p_effective_start_date
      ,p_effective_end_date             => p_effective_end_date
      ,p_element_entry_id               => p_element_entry_id
      ,p_original_entry_id              => p_original_entry_id
      ,p_assignment_id                  => p_assignment_id
      ,p_element_link_id                => p_element_link_id
      ,p_creator_type                   => p_creator_type
      ,p_entry_type                     => p_entry_type
      ,p_cost_allocation_keyflex_id     => p_cost_allocation_keyflex_id
      ,p_updating_action_id             => p_updating_action_id
      ,p_updating_action_type           => p_updating_action_type
      ,p_comment_id                     => p_comment_id
      ,p_creator_id                     => p_creator_id
      ,p_reason                         => p_reason
      ,p_target_entry_id                => p_target_entry_id
      ,p_source_id                      => null
      ,p_subpriority                    => p_subpriority
      ,p_date_earned                    => p_date_earned
      ,p_personal_payment_method_id     => p_personal_payment_method_id
      ,p_attribute_category             => p_attribute_category
      ,p_attribute1                     => p_attribute1
      ,p_attribute2                     => p_attribute2
      ,p_attribute3                     => p_attribute3
      ,p_attribute4                     => p_attribute4
      ,p_attribute5                     => p_attribute5
      ,p_attribute6                     => p_attribute6
      ,p_attribute7                     => p_attribute7
      ,p_attribute8                     => p_attribute8
      ,p_attribute9                     => p_attribute9
      ,p_attribute10                    => p_attribute10
      ,p_attribute11                    => p_attribute11
      ,p_attribute12                    => p_attribute12
      ,p_attribute13                    => p_attribute13
      ,p_attribute14                    => p_attribute14
      ,p_attribute15                    => p_attribute15
      ,p_attribute16                    => p_attribute16
      ,p_attribute17                    => p_attribute17
      ,p_attribute18                    => p_attribute18
      ,p_attribute19                    => p_attribute19
      ,p_attribute20                    => p_attribute20
      ,p_entry_information_category     => p_entry_information_category
      ,p_entry_information1             => p_entry_information1
      ,p_entry_information2             => p_entry_information2
      ,p_entry_information3             => p_entry_information3
      ,p_entry_information4             => p_entry_information4
      ,p_entry_information5             => p_entry_information5
      ,p_entry_information6             => p_entry_information6
      ,p_entry_information7             => p_entry_information7
      ,p_entry_information8             => p_entry_information8
      ,p_entry_information9             => p_entry_information9
      ,p_entry_information10            => p_entry_information10
      ,p_entry_information11            => p_entry_information11
      ,p_entry_information12            => p_entry_information12
      ,p_entry_information13            => p_entry_information13
      ,p_entry_information14            => p_entry_information14
      ,p_entry_information15            => p_entry_information15
      ,p_entry_information16            => p_entry_information16
      ,p_entry_information17            => p_entry_information17
      ,p_entry_information18            => p_entry_information18
      ,p_entry_information19            => p_entry_information19
      ,p_entry_information20            => p_entry_information20
      ,p_entry_information21            => p_entry_information21
      ,p_entry_information22            => p_entry_information22
      ,p_entry_information23            => p_entry_information23
      ,p_entry_information24            => p_entry_information24
      ,p_entry_information25            => p_entry_information25
      ,p_entry_information26            => p_entry_information26
      ,p_entry_information27            => p_entry_information27
      ,p_entry_information28            => p_entry_information28
      ,p_entry_information29            => p_entry_information29
      ,p_entry_information30            => p_entry_information30
      ,p_object_version_number          => l_object_version_number
      ,p_balance_adj_cost_flag          => null
      ,p_comments                       => null
      ,p_element_type_id                => l_element_type_id
      ,p_all_entry_values_null          => l_all_entry_values_null
     );
     exception
       when hr_api.cannot_find_prog_unit then
         hr_api.cannot_find_prog_unit_error
               (p_module_name => 'PAY_ELEMENT_ENTRIES_F'
               ,p_hook_type   => 'AI'
               );
     end;
    --
  -- jford 20-FEB-03
  -- -----------------
  -- As entry values has no hook, call the CC DYnamic Trigger PacKaGe directly
  -- I.e. instead of   pseudoAPI -> HOOK -> DYT_PKG -> CC_PKG
  -- we do             pseudoAPI ---------> DYT_PKG -> CC_PKG
  -- -----------------
  --loop through all element entry vals for this element entry id
  --
  for new_vals in pay_ele_shd.csr_get_eevals(p_element_entry_id,l_effective_date)  loop
    begin
      --
    if g_debug then
      hr_utility.trace(' Hard call PAY_DYT_ELEMENT_ENTRY_VAL_PKG.after_insert');
      hr_utility.trace(' Ele ent Val ID: '||new_vals.element_entry_value_id);
      hr_utility.trace(' New Screen Val: '||new_vals.screen_entry_value);
    end if;

-- Reason Insert has seemingly irregular parameters is that as
-- element entry values has no hook packages, the generator util of the called
-- pkg, will use an alternate param gen method and defaults lots eg _o
      PAY_DYT_ELEMENT_ENTRY_VAL_PKG.after_insert
      (
        P_EFFECTIVE_END_DATE          => new_vals.effective_end_date
       ,P_EFFECTIVE_START_DATE        => new_vals.effective_start_date
       ,P_ELEMENT_ENTRY_ID            => new_vals.element_entry_id
       ,P_ELEMENT_ENTRY_VALUE_ID      => new_vals.element_entry_value_id
       ,P_INPUT_VALUE_ID              => new_vals.input_value_id
       ,P_SCREEN_ENTRY_VALUE          => new_vals.screen_entry_value
       ,P_EFFECTIVE_END_DATE_O        => new_vals.effective_end_date
       ,P_EFFECTIVE_START_DATE_O      => new_vals.effective_start_date
       ,P_ELEMENT_ENTRY_ID_O          => new_vals.element_entry_id
       ,P_ELEMENT_ENTRY_VALUE_ID_O    => new_vals.element_entry_value_id
       ,P_INPUT_VALUE_ID_O            => new_vals.input_value_id
       ,P_SCREEN_ENTRY_VALUE_O        => new_vals.screen_entry_value
     );
    end;
    --
  end loop;
 end ins_element_entry;
--
























--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry_api.insert_element_entry                                        --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Cover routine for call to hr_entry_api.ins_element_entry that accepts    --
 -- entry values passed as a table. It converts the entry values to DB       --
 -- format and also defaults any entry values that were not specified.       --
 -- NB. all entry values specified are validated !                           --
 ------------------------------------------------------------------------------
--
 procedure insert_element_entry
 (
  --
  -- Common Parameters
  --
  p_effective_start_date       in out nocopy date,
  p_effective_end_date         in out nocopy date,
  --
  -- Element Entry Table
  --
  p_element_entry_id           in out nocopy number,
  p_original_entry_id          number    default null,
  p_assignment_id              number,
  p_element_link_id            number,
  p_creator_type               varchar2,
  p_entry_type                 varchar2,
  p_cost_allocation_keyflex_id number    default null,
  p_updating_action_id         number    default null,
  p_updating_action_type       varchar2  default null,
  p_comment_id                 number    default null,
  p_creator_id                 number    default null,
  p_reason                     varchar2  default null,
  p_target_entry_id            number    default null,
  p_subpriority                number    default null,
  p_date_earned                 date    default null,
  p_personal_payment_method_id  number  default null,
  p_attribute_category         varchar2  default null,
  p_attribute1                 varchar2  default null,
  p_attribute2                 varchar2  default null,
  p_attribute3                 varchar2  default null,
  p_attribute4                 varchar2  default null,
  p_attribute5                 varchar2  default null,
  p_attribute6                 varchar2  default null,
  p_attribute7                 varchar2  default null,
  p_attribute8                 varchar2  default null,
  p_attribute9                 varchar2  default null,
  p_attribute10                varchar2  default null,
  p_attribute11                varchar2  default null,
  p_attribute12                varchar2  default null,
  p_attribute13                varchar2  default null,
  p_attribute14                varchar2  default null,
  p_attribute15                varchar2  default null,
  p_attribute16                varchar2  default null,
  p_attribute17                varchar2  default null,
  p_attribute18                varchar2  default null,
  p_attribute19                varchar2  default null,
  p_attribute20                varchar2  default null,
  p_override_user_ent_chk      varchar2  default 'N',
  p_label_identifier           varchar2  default null,
  --
  -- Element Entry Values Table
  --
  p_num_entry_values           number,
  p_input_value_id_tbl         hr_entry.number_table,
  p_entry_value_tbl            hr_entry.varchar2_table
  ) is
   --
   -- Local Variables
   --
   v_num_entry_values   number;
   v_input_value_id_tbl hr_entry.number_table;
   v_entry_value_tbl    hr_entry.varchar2_table;
   --
 begin
   g_debug := hr_utility.debug_enabled;

   --
   -- Initialise variables
   --
   g_override_user_ent_chk := p_override_user_ent_chk;
   v_num_entry_values   := p_num_entry_values;
   v_input_value_id_tbl := p_input_value_id_tbl;
   v_entry_value_tbl    := p_entry_value_tbl;
   --
   -- Call code to set up values that may be used in
   -- Formula validation of Input Values.
   --
   set_formula_contexts (p_assignment_id, p_effective_start_date);
   --
   -- Make sure PLSQL table contains all the entry values ie. fill in missing
   -- entry values not specified by the user.
   --
   hr_entry_api.conv_table_to_table
     ('SCREEN',
      p_effective_start_date,
      null,
      p_element_link_id,
      v_num_entry_values,
      p_creator_type,
      p_entry_type,
      v_input_value_id_tbl,
      v_entry_value_tbl);
   --
   -- Do real insertion of element entry.
   --
   hr_entry_api.ins_element_entry
     (p_effective_start_date,
      p_effective_end_date,
      p_element_entry_id,
      p_original_entry_id,
      p_assignment_id,
      p_element_link_id,
      p_creator_type,
      p_entry_type,
      p_cost_allocation_keyflex_id,
      p_updating_action_id,
      p_updating_action_type,
      p_comment_id,
      p_creator_id,
      p_reason,
      p_target_entry_id,
      p_subpriority,
      p_date_earned,
      p_personal_payment_method_id,
      p_attribute_category,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      p_attribute16,
      p_attribute17,
      p_attribute18,
      p_attribute19,
      p_attribute20,
      v_num_entry_values,
      v_input_value_id_tbl,
      v_entry_value_tbl,
-- --
    --
    -- J.Bailie 08-NOV-99 31 nulls passed to ins_element_entry
    --
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      p_label_identifier
);
   --
 end insert_element_entry;
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry_api.insert_element_entry                                        --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Cover routine for call to hr_entry_api.ins_element_entry that accepts    --
 -- entry values passed as parameters. It converts the entry values to DB    --
 -- format and also defaults any entry values that were not specified.       --
 -- NB. all entry values specified are validated !                           --
 ------------------------------------------------------------------------------
--
 procedure insert_element_entry
 (
  --
  -- Common Parameters
  --
  p_effective_start_date       in out nocopy date,
  p_effective_end_date         in out nocopy date,
  --
  -- Element Entry Table
  --
  p_element_entry_id           in out nocopy number,
  p_original_entry_id          number    default null,
  p_assignment_id              number,
  p_element_link_id            number,
  p_creator_type               varchar2,
  p_entry_type                 varchar2,
  p_cost_allocation_keyflex_id number    default null,
  p_updating_action_id         number    default null,
  p_updating_action_type       varchar2  default null,
  p_comment_id                 number    default null,
  p_creator_id                 number    default null,
  p_reason                     varchar2  default null,
  p_target_entry_id            number    default null,
  p_subpriority                number    default null,
  p_date_earned                 date    default null,
  p_personal_payment_method_id  number  default null,
  p_attribute_category         varchar2  default null,
  p_attribute1                 varchar2  default null,
  p_attribute2                 varchar2  default null,
  p_attribute3                 varchar2  default null,
  p_attribute4                 varchar2  default null,
  p_attribute5                 varchar2  default null,
  p_attribute6                 varchar2  default null,
  p_attribute7                 varchar2  default null,
  p_attribute8                 varchar2  default null,
  p_attribute9                 varchar2  default null,
  p_attribute10                varchar2  default null,
  p_attribute11                varchar2  default null,
  p_attribute12                varchar2  default null,
  p_attribute13                varchar2  default null,
  p_attribute14                varchar2  default null,
  p_attribute15                varchar2  default null,
  p_attribute16                varchar2  default null,
  p_attribute17                varchar2  default null,
  p_attribute18                varchar2  default null,
  p_attribute19                varchar2  default null,
  p_attribute20                varchar2  default null,
  --
  -- Element Entry Values Table
  --
  p_input_value_id1            number    default null,
  p_input_value_id2            number    default null,
  p_input_value_id3            number    default null,
  p_input_value_id4            number    default null,
  p_input_value_id5            number    default null,
  p_input_value_id6            number    default null,
  p_input_value_id7            number    default null,
  p_input_value_id8            number    default null,
  p_input_value_id9            number    default null,
  p_input_value_id10           number    default null,
  p_input_value_id11           number    default null,
  p_input_value_id12           number    default null,
  p_input_value_id13           number    default null,
  p_input_value_id14           number    default null,
  p_input_value_id15           number    default null,
  p_entry_value1               varchar2  default null,
  p_entry_value2               varchar2  default null,
  p_entry_value3               varchar2  default null,
  p_entry_value4               varchar2  default null,
  p_entry_value5               varchar2  default null,
  p_entry_value6               varchar2  default null,
  p_entry_value7               varchar2  default null,
  p_entry_value8               varchar2  default null,
  p_entry_value9               varchar2  default null,
  p_entry_value10              varchar2  default null,
  p_entry_value11              varchar2  default null,
  p_entry_value12              varchar2  default null,
  p_entry_value13              varchar2  default null,
  p_entry_value14              varchar2  default null,
  p_entry_value15              varchar2  default null,
  p_override_user_ent_chk      varchar2  default 'N',
  p_label_identifier           varchar2  default null
 ) is
   --
   -- Local Variables
   --
   v_num_entry_values   number;
   v_input_value_id_tbl hr_entry.number_table;
   v_entry_value_tbl    hr_entry.varchar2_table;
   --
 begin
   g_debug := hr_utility.debug_enabled;
   --
   -- Call code to set up values that may be used in
   -- Formula validation of Input Values.
   --
   set_formula_contexts (p_assignment_id, p_effective_start_date);
   g_override_user_ent_chk := p_override_user_ent_chk;
   --
   -- Copy entry values into PLSQL table and make sure PLSQL table contains
   -- all the entry values ie. fill in missing entry values not specified by
   -- the user.
   --
   hr_entry_api.conv_entry_values_to_table
     ('SCREEN',
      null,
      p_element_link_id,
      p_effective_start_date,
      p_creator_type,
      p_entry_type,
      p_input_value_id1,
      p_input_value_id2,
      p_input_value_id3,
      p_input_value_id4,
      p_input_value_id5,
      p_input_value_id6,
      p_input_value_id7,
      p_input_value_id8,
      p_input_value_id9,
      p_input_value_id10,
      p_input_value_id11,
      p_input_value_id12,
      p_input_value_id13,
      p_input_value_id14,
      p_input_value_id15,
      p_entry_value1,
      p_entry_value2,
      p_entry_value3,
      p_entry_value4,
      p_entry_value5,
      p_entry_value6,
      p_entry_value7,
      p_entry_value8,
      p_entry_value9,
      p_entry_value10,
      p_entry_value11,
      p_entry_value12,
      p_entry_value13,
      p_entry_value14,
      p_entry_value15,
      v_num_entry_values,
      v_input_value_id_tbl,
      v_entry_value_tbl);
   --
   -- Do real insertion of element entry.
   --
   hr_entry_api.ins_element_entry
     (p_effective_start_date,
      p_effective_end_date,
      p_element_entry_id,
      p_original_entry_id,
      p_assignment_id,
      p_element_link_id,
      p_creator_type,
      p_entry_type,
      p_cost_allocation_keyflex_id,
      p_updating_action_id,
      p_updating_action_type,
      p_comment_id,
      p_creator_id,
      p_reason,
      p_target_entry_id,
      p_subpriority,
      p_date_earned,
      p_personal_payment_method_id,
      p_attribute_category,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      p_attribute16,
      p_attribute17,
      p_attribute18,
      p_attribute19,
      p_attribute20,
      v_num_entry_values,
      v_input_value_id_tbl,
      v_entry_value_tbl,
-- --
    --
    -- J.Bailie 08-NOV-99 31 nulls passed to ins_element_entry
    --
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      p_label_identifier
);
   --
 end insert_element_entry;
--
-- --
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry_api.insert_element_entry                                        --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Cover routine for call to hr_entry_api.ins_element_entry that accepts    --
 -- entry values passed as a table. It converts the entry values to DB       --
 -- format and also defaults any entry values that were not specified.       --
 -- NB. all entry values specified are validated !                           --
 ------------------------------------------------------------------------------
--
 procedure insert_element_entry
 (
  --
  -- Common Parameters
  --
  p_effective_start_date       in out nocopy date,
  p_effective_end_date         in out nocopy date,
  --
  -- Element Entry Table
  --
  p_element_entry_id           in out nocopy number,
  p_original_entry_id          number    default null,
  p_assignment_id              number,
  p_element_link_id            number,
  p_creator_type               varchar2,
  p_entry_type                 varchar2,
  p_cost_allocation_keyflex_id number    default null,
  p_updating_action_id         number    default null,
  p_updating_action_type       varchar2  default null,
  p_comment_id                 number    default null,
  p_creator_id                 number    default null,
  p_reason                     varchar2  default null,
  p_target_entry_id            number    default null,
  p_subpriority                number    default null,
  p_date_earned                 date    default null,
  p_personal_payment_method_id  number  default null,
  p_attribute_category         varchar2  default null,
  p_attribute1                 varchar2  default null,
  p_attribute2                 varchar2  default null,
  p_attribute3                 varchar2  default null,
  p_attribute4                 varchar2  default null,
  p_attribute5                 varchar2  default null,
  p_attribute6                 varchar2  default null,
  p_attribute7                 varchar2  default null,
  p_attribute8                 varchar2  default null,
  p_attribute9                 varchar2  default null,
  p_attribute10                varchar2  default null,
  p_attribute11                varchar2  default null,
  p_attribute12                varchar2  default null,
  p_attribute13                varchar2  default null,
  p_attribute14                varchar2  default null,
  p_attribute15                varchar2  default null,
  p_attribute16                varchar2  default null,
  p_attribute17                varchar2  default null,
  p_attribute18                varchar2  default null,
  p_attribute19                varchar2  default null,
  p_attribute20                varchar2  default null,
  --
  -- Element Entry Values Table
  --
  p_num_entry_values           number,
  p_input_value_id_tbl         hr_entry.number_table,
  p_entry_value_tbl            hr_entry.varchar2_table,
  --
  -- J.Bailie Element Entries DDF
  --
  p_entry_information_category varchar2  ,
  p_entry_information1         varchar2  default null,
  p_entry_information2         varchar2  default null,
  p_entry_information3         varchar2  default null,
  p_entry_information4         varchar2  default null,
  p_entry_information5         varchar2  default null,
  p_entry_information6         varchar2  default null,
  p_entry_information7         varchar2  default null,
  p_entry_information8         varchar2  default null,
  p_entry_information9         varchar2  default null,
  p_entry_information10        varchar2  default null,
  p_entry_information11        varchar2  default null,
  p_entry_information12        varchar2  default null,
  p_entry_information13        varchar2  default null,
  p_entry_information14        varchar2  default null,
  p_entry_information15        varchar2  default null,
  p_entry_information16        varchar2  default null,
  p_entry_information17        varchar2  default null,
  p_entry_information18        varchar2  default null,
  p_entry_information19        varchar2  default null,
  p_entry_information20        varchar2  default null,
  p_entry_information21        varchar2  default null,
  p_entry_information22        varchar2  default null,
  p_entry_information23        varchar2  default null,
  p_entry_information24        varchar2  default null,
  p_entry_information25        varchar2  default null,
  p_entry_information26        varchar2  default null,
  p_entry_information27        varchar2  default null,
  p_entry_information28        varchar2  default null,
  p_entry_information29        varchar2  default null,
  p_entry_information30        varchar2  default null,
  p_override_user_ent_chk      varchar2  default 'N',
  p_label_identifier           varchar2  default null
  ) is
   --
   -- Local Variables
   --
   v_num_entry_values   number;
   v_input_value_id_tbl hr_entry.number_table;
   v_entry_value_tbl    hr_entry.varchar2_table;
   --
 begin
   g_debug := hr_utility.debug_enabled;
   --
   -- Initialise variables
   --
   g_override_user_ent_chk := p_override_user_ent_chk;
   v_num_entry_values   := p_num_entry_values;
   v_input_value_id_tbl := p_input_value_id_tbl;
   v_entry_value_tbl    := p_entry_value_tbl;
   --
   -- Call code to set up values that may be used in
   -- Formula validation of Input Values.
   --
   set_formula_contexts (p_assignment_id, p_effective_start_date);
   --
   -- Make sure PLSQL table contains all the entry values ie. fill in missing
   -- entry values not specified by the user.
   --
   hr_entry_api.conv_table_to_table
     ('SCREEN',
      p_effective_start_date,
      null,
      p_element_link_id,
      v_num_entry_values,
      p_creator_type,
      p_entry_type,
      v_input_value_id_tbl,
      v_entry_value_tbl);
   --
   -- Do real insertion of element entry.
   --
   hr_entry_api.ins_element_entry
     (p_effective_start_date,
      p_effective_end_date,
      p_element_entry_id,
      p_original_entry_id,
      p_assignment_id,
      p_element_link_id,
      p_creator_type,
      p_entry_type,
      p_cost_allocation_keyflex_id,
      p_updating_action_id,
      p_updating_action_type,
      p_comment_id,
      p_creator_id,
      p_reason,
      p_target_entry_id,
      p_subpriority,
      p_date_earned,
      p_personal_payment_method_id,
      p_attribute_category,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      p_attribute16,
      p_attribute17,
      p_attribute18,
      p_attribute19,
      p_attribute20,
      v_num_entry_values,
      v_input_value_id_tbl,
      v_entry_value_tbl,
  --
  -- J.Bailie 08-NOV-99 Element Entries DDF
  --
    p_entry_information_category,
    p_entry_information1,
    p_entry_information2,
    p_entry_information3,
    p_entry_information4,
    p_entry_information5,
    p_entry_information6,
    p_entry_information7,
    p_entry_information8,
    p_entry_information9,
    p_entry_information10,
    p_entry_information11,
    p_entry_information12,
    p_entry_information13,
    p_entry_information14,
    p_entry_information15,
    p_entry_information16,
    p_entry_information17,
    p_entry_information18,
    p_entry_information19,
    p_entry_information20,
    p_entry_information21,
    p_entry_information22,
    p_entry_information23,
    p_entry_information24,
    p_entry_information25,
    p_entry_information26,
    p_entry_information27,
    p_entry_information28,
    p_entry_information29,
    p_entry_information30,
    p_label_identifier
   );
   --
 end insert_element_entry;
--
-- --
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry_api.insert_element_entry                                        --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Cover routine for call to hr_entry_api.ins_element_entry that accepts    --
 -- entry values passed as parameters. It converts the entry values to DB    --
 -- format and also defaults any entry values that were not specified.       --
 -- NB. all entry values specified are validated !                           --
 ------------------------------------------------------------------------------
--
 procedure insert_element_entry
 (
  --
  -- Common Parameters
  --
  p_effective_start_date       in out nocopy date,
  p_effective_end_date         in out nocopy date,
  --
  -- Element Entry Table
  --
  p_element_entry_id           in out nocopy number,
  p_original_entry_id          number    default null,
  p_assignment_id              number,
  p_element_link_id            number,
  p_creator_type               varchar2,
  p_entry_type                 varchar2,
  p_cost_allocation_keyflex_id number    default null,
  p_updating_action_id         number    default null,
  p_updating_action_type       varchar2  default null,
  p_comment_id                 number    default null,
  p_creator_id                 number    default null,
  p_reason                     varchar2  default null,
  p_target_entry_id            number    default null,
  p_subpriority                number    default null,
  p_date_earned                 date    default null,
  p_personal_payment_method_id  number  default null,
  p_attribute_category         varchar2  default null,
  p_attribute1                 varchar2  default null,
  p_attribute2                 varchar2  default null,
  p_attribute3                 varchar2  default null,
  p_attribute4                 varchar2  default null,
  p_attribute5                 varchar2  default null,
  p_attribute6                 varchar2  default null,
  p_attribute7                 varchar2  default null,
  p_attribute8                 varchar2  default null,
  p_attribute9                 varchar2  default null,
  p_attribute10                varchar2  default null,
  p_attribute11                varchar2  default null,
  p_attribute12                varchar2  default null,
  p_attribute13                varchar2  default null,
  p_attribute14                varchar2  default null,
  p_attribute15                varchar2  default null,
  p_attribute16                varchar2  default null,
  p_attribute17                varchar2  default null,
  p_attribute18                varchar2  default null,
  p_attribute19                varchar2  default null,
  p_attribute20                varchar2  default null,
  --
  -- Element Entry Values Table
  --
  p_input_value_id1            number    default null,
  p_input_value_id2            number    default null,
  p_input_value_id3            number    default null,
  p_input_value_id4            number    default null,
  p_input_value_id5            number    default null,
  p_input_value_id6            number    default null,
  p_input_value_id7            number    default null,
  p_input_value_id8            number    default null,
  p_input_value_id9            number    default null,
  p_input_value_id10           number    default null,
  p_input_value_id11           number    default null,
  p_input_value_id12           number    default null,
  p_input_value_id13           number    default null,
  p_input_value_id14           number    default null,
  p_input_value_id15           number    default null,
  p_entry_value1               varchar2  default null,
  p_entry_value2               varchar2  default null,
  p_entry_value3               varchar2  default null,
  p_entry_value4               varchar2  default null,
  p_entry_value5               varchar2  default null,
  p_entry_value6               varchar2  default null,
  p_entry_value7               varchar2  default null,
  p_entry_value8               varchar2  default null,
  p_entry_value9               varchar2  default null,
  p_entry_value10              varchar2  default null,
  p_entry_value11              varchar2  default null,
  p_entry_value12              varchar2  default null,
  p_entry_value13              varchar2  default null,
  p_entry_value14              varchar2  default null,
  p_entry_value15              varchar2  default null,
  --
  -- J.Bailie Element Entries DDF
  --
  p_entry_information_category varchar2  ,
  p_entry_information1         varchar2  default null,
  p_entry_information2         varchar2  default null,
  p_entry_information3         varchar2  default null,
  p_entry_information4         varchar2  default null,
  p_entry_information5         varchar2  default null,
  p_entry_information6         varchar2  default null,
  p_entry_information7         varchar2  default null,
  p_entry_information8         varchar2  default null,
  p_entry_information9         varchar2  default null,
  p_entry_information10        varchar2  default null,
  p_entry_information11        varchar2  default null,
  p_entry_information12        varchar2  default null,
  p_entry_information13        varchar2  default null,
  p_entry_information14        varchar2  default null,
  p_entry_information15        varchar2  default null,
  p_entry_information16        varchar2  default null,
  p_entry_information17        varchar2  default null,
  p_entry_information18        varchar2  default null,
  p_entry_information19        varchar2  default null,
  p_entry_information20        varchar2  default null,
  p_entry_information21        varchar2  default null,
  p_entry_information22        varchar2  default null,
  p_entry_information23        varchar2  default null,
  p_entry_information24        varchar2  default null,
  p_entry_information25        varchar2  default null,
  p_entry_information26        varchar2  default null,
  p_entry_information27        varchar2  default null,
  p_entry_information28        varchar2  default null,
  p_entry_information29        varchar2  default null,
  p_entry_information30        varchar2  default null,
  p_override_user_ent_chk      varchar2  default 'N',
  p_label_identifier           varchar2  default null
 ) is
   --
   -- Local Variables
   --
   v_num_entry_values   number;
   v_input_value_id_tbl hr_entry.number_table;
   v_entry_value_tbl    hr_entry.varchar2_table;
   --
 begin
   g_debug := hr_utility.debug_enabled;
   --
   -- Call code to set up values that may be used in
   -- Formula validation of Input Values.
   --
   set_formula_contexts (p_assignment_id, p_effective_start_date);
   g_override_user_ent_chk := p_override_user_ent_chk;
   --
   -- Copy entry values into PLSQL table and make sure PLSQL table contains
   -- all the entry values ie. fill in missing entry values not specified by
   -- the user.
   --
   hr_entry_api.conv_entry_values_to_table
     ('SCREEN',
      null,
      p_element_link_id,
      p_effective_start_date,
      p_creator_type,
      p_entry_type,
      p_input_value_id1,
      p_input_value_id2,
      p_input_value_id3,
      p_input_value_id4,
      p_input_value_id5,
      p_input_value_id6,
      p_input_value_id7,
      p_input_value_id8,
      p_input_value_id9,
      p_input_value_id10,
      p_input_value_id11,
      p_input_value_id12,
      p_input_value_id13,
      p_input_value_id14,
      p_input_value_id15,
      p_entry_value1,
      p_entry_value2,
      p_entry_value3,
      p_entry_value4,
      p_entry_value5,
      p_entry_value6,
      p_entry_value7,
      p_entry_value8,
      p_entry_value9,
      p_entry_value10,
      p_entry_value11,
      p_entry_value12,
      p_entry_value13,
      p_entry_value14,
      p_entry_value15,
      v_num_entry_values,
      v_input_value_id_tbl,
      v_entry_value_tbl);
   --
   -- Do real insertion of element entry.
   --
   hr_entry_api.ins_element_entry
     (p_effective_start_date,
      p_effective_end_date,
      p_element_entry_id,
      p_original_entry_id,
      p_assignment_id,
      p_element_link_id,
      p_creator_type,
      p_entry_type,
      p_cost_allocation_keyflex_id,
      p_updating_action_id,
      p_updating_action_type,
      p_comment_id,
      p_creator_id,
      p_reason,
      p_target_entry_id,
      p_subpriority,
      p_date_earned,
      p_personal_payment_method_id,
      p_attribute_category,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      p_attribute16,
      p_attribute17,
      p_attribute18,
      p_attribute19,
      p_attribute20,
      v_num_entry_values,
      v_input_value_id_tbl,
      v_entry_value_tbl,
  --
  -- J.Bailie 08-NOV-99 Element Entries DDF
  --
    p_entry_information_category,
    p_entry_information1,
    p_entry_information2,
    p_entry_information3,
    p_entry_information4,
    p_entry_information5,
    p_entry_information6,
    p_entry_information7,
    p_entry_information8,
    p_entry_information9,
    p_entry_information10,
    p_entry_information11,
    p_entry_information12,
    p_entry_information13,
    p_entry_information14,
    p_entry_information15,
    p_entry_information16,
    p_entry_information17,
    p_entry_information18,
    p_entry_information19,
    p_entry_information20,
    p_entry_information21,
    p_entry_information22,
    p_entry_information23,
    p_entry_information24,
    p_entry_information25,
    p_entry_information26,
    p_entry_information27,
    p_entry_information28,
    p_entry_information29,
    p_entry_information30,
    p_label_identifier
    );
   --
 end insert_element_entry;
--
 ------------------------------------------------------------------------------
 -- NAME
 -- hr_entry_api.check_salary_admin_updates
 --
 -- DESCRIPTION
 -- Validates the rules for updating Salary Admin entries
 ------------------------------------------------------------------------------
 procedure check_salary_admin_updates
 (
 p_element_entry_id     number,
 p_new_entry            hr_entry_api.t_update_entry_rec,
 p_effective_date       date,
 p_dt_update_mode       varchar2
 ) is
 --
 cursor csr_old_entry_details is
        --
        -- Get the old values of the entry for comparison with the updated
        -- values
        --
        select  *
        from    pay_element_entries_f
        where   element_entry_id = p_element_entry_id
        and     p_effective_date between effective_start_date
                                and effective_end_date;
        --
 l_proc varchar2 (72);
 old_entry      pay_element_entries_f%rowtype;
 invalid_element_entry_id               exception;
 invalid_dt_update_mode exception;
 --
        procedure check_parameters is
                --
                begin
                --
                hr_utility.trace('check_salary_admin_updates');
                hr_api.mandatory_arg_error (
                        p_api_name      => l_proc,
                        p_argument      => 'p_dt_update_mode',
                        p_argument_value=> p_dt_update_mode);
                        --
                hr_api.mandatory_arg_error (
                        p_api_name      => l_proc,
                        p_argument      => 'p_effective_date',
                        p_argument_value=> p_effective_date);
                        --
                hr_api.mandatory_arg_error (
                        p_api_name      => l_proc,
                        p_argument      => 'p_element_entry_id',
                        p_argument_value=> p_element_entry_id);
                        --
                hr_api.mandatory_arg_error (
                        p_api_name      => l_proc,
                        p_argument      => 'p_new_entry.creator_type',
                        p_argument_value=> p_new_entry.creator_type);
                        --
                end check_parameters;
                --
 begin
 --
 if g_debug then
    l_proc := 'hr_entry_api.check_salary_admin_updates';
    check_parameters;
 end if;
 --
 if
    -- a salary admin entry
    p_new_entry.creator_type = 'SP'
 then
   --
   -- Get the old entry row
   --
   open csr_old_entry_details;
   fetch csr_old_entry_details into old_entry;
   if csr_old_entry_details%notfound then
     close csr_old_entry_details;
     raise invalid_element_entry_id;
   else
     close csr_old_entry_details;
   end if;
   --
   if
       -- if in a datetrack mode which could affect other rows
       p_dt_update_mode not in (        'CORRECTION',
                                        'UPDATE_CHANGE_INSERT'  )
      and
      (
      -- and costing keyflex was updated
      nvl (old_entry.cost_allocation_keyflex_id, 0)
                <> nvl (p_new_entry.cost_allocation_keyflex_id, 0)
      --
      -- or reason was updated
      or nvl (old_entry.reason,'x') <> nvl (p_new_entry.reason,'x')
      --
      -- or date_earned was updated
      or nvl (old_entry.date_earned, hr_general.end_of_time)
        <> nvl (p_new_entry.date_earned, hr_general.end_of_time)
      --
      -- or third party payee details were updated
      or nvl (old_entry.personal_payment_method_id, 0)
        <> nvl (p_new_entry.personal_payment_method_id, 0)
      --
      -- or subpriority was updated
      or nvl (old_entry.subpriority, 0) <> nvl (p_new_entry.subpriority, 0)
      --
      -- or descriptive flex was updated
      or (nvl (old_entry.attribute_category,'x')
                                <> nvl (p_new_entry.attribute_category,'x')
         or nvl (old_entry.attribute1,'x') <> nvl (p_new_entry.attribute1, 'x')
         or nvl (old_entry.attribute2,'x') <> nvl (p_new_entry.attribute2, 'x')
         or nvl (old_entry.attribute3,'x') <> nvl (p_new_entry.attribute3, 'x')
         or nvl (old_entry.attribute4,'x') <> nvl (p_new_entry.attribute4, 'x')
         or nvl (old_entry.attribute5,'x') <> nvl (p_new_entry.attribute5, 'x')
         or nvl (old_entry.attribute6,'x') <> nvl (p_new_entry.attribute6, 'x')
         or nvl (old_entry.attribute7,'x') <> nvl (p_new_entry.attribute7, 'x')
         or nvl (old_entry.attribute8,'x') <> nvl (p_new_entry.attribute8, 'x')
         or nvl (old_entry.attribute9,'x') <> nvl (p_new_entry.attribute9, 'x')
         or nvl(old_entry.attribute10,'x') <> nvl(p_new_entry.attribute10, 'x')
         or nvl(old_entry.attribute11,'x') <> nvl(p_new_entry.attribute11, 'x')
         or nvl(old_entry.attribute12,'x') <> nvl(p_new_entry.attribute12, 'x')
         or nvl(old_entry.attribute13,'x') <> nvl(p_new_entry.attribute13, 'x')
         or nvl(old_entry.attribute14,'x') <> nvl(p_new_entry.attribute14, 'x')
         or nvl(old_entry.attribute15,'x') <> nvl(p_new_entry.attribute15, 'x')
         or nvl(old_entry.attribute16,'x') <> nvl(p_new_entry.attribute16, 'x')
         or nvl(old_entry.attribute17,'x') <> nvl(p_new_entry.attribute17, 'x')
         or nvl(old_entry.attribute18,'x') <> nvl(p_new_entry.attribute18, 'x')
         or nvl(old_entry.attribute19,'x') <> nvl(p_new_entry.attribute19, 'x')
         or nvl(old_entry.attribute20,'x') <> nvl(p_new_entry.attribute20, 'x'))
      )
   then
     --
     raise invalid_dt_update_mode;
     --
   end if;
   --
 end if;
 --
 exception
 --
 when invalid_dt_update_mode then
   --
   -- The entry attributes for salary admin entries may be updated only
   -- in UPDATE_CHANGE_INSERT and CORRECTION datetrack modes.
   --
   hr_utility.set_message (801,'HR_51182_SAL_DT_MODE');
   hr_utility.raise_error;
   --
 when invalid_element_entry_id then
   --
   -- The update is for a non-existent element entry
   --
   hr_utility.set_message (801,'HR_6153_ALL_PROCEDURE_FAIL');
   hr_utility.set_message_token ('PROCEDURE', l_proc);
   hr_utility.set_message_token ('STEP','1');
   hr_utility.raise_error;
   --
 end check_salary_admin_updates;
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry_api.upd_ele_entry_param_val                                     --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Validates the parameters passed to hr_entry_api.update_element_entry.    --
 ------------------------------------------------------------------------------
 procedure upd_ele_entry_param_val
 (
  --
  -- Update Mode
  --
  p_dt_update_mode             in out nocopy varchar2,
  --
  -- Date on which change is taking place
  --
  p_session_date               date,
  --
  -- Element Entry Table
  --
  p_element_entry_id           number,
  p_cost_allocation_keyflex_id number,
  p_updating_action_id         number,
  p_updating_action_type       varchar2,
  p_original_entry_id          number,
  p_creator_type               varchar2,
  p_comment_id                 number,
  p_creator_id                 number,
  p_reason                     varchar2,
  p_subpriority                number,
  p_date_earned                 date,
  p_personal_payment_method_id  number,
  p_attribute_category         varchar2,
  p_attribute1                 varchar2,
  p_attribute2                 varchar2,
  p_attribute3                 varchar2,
  p_attribute4                 varchar2,
  p_attribute5                 varchar2,
  p_attribute6                 varchar2,
  p_attribute7                 varchar2,
  p_attribute8                 varchar2,
  p_attribute9                 varchar2,
  p_attribute10                varchar2,
  p_attribute11                varchar2,
  p_attribute12                varchar2,
  p_attribute13                varchar2,
  p_attribute14                varchar2,
  p_attribute15                varchar2,
  p_attribute16                varchar2,
  p_attribute17                varchar2,
  p_attribute18                varchar2,
  p_attribute19                varchar2,
  p_attribute20                varchar2,
-- --
  --
  -- J.Bailie Element Entries DDF
  --
  p_entry_information_category varchar2,
  p_entry_information1         varchar2,
  p_entry_information2         varchar2,
  p_entry_information3         varchar2,
  p_entry_information4         varchar2,
  p_entry_information5         varchar2,
  p_entry_information6         varchar2,
  p_entry_information7         varchar2,
  p_entry_information8         varchar2,
  p_entry_information9         varchar2,
  p_entry_information10        varchar2,
  p_entry_information11        varchar2,
  p_entry_information12        varchar2,
  p_entry_information13        varchar2,
  p_entry_information14        varchar2,
  p_entry_information15        varchar2,
  p_entry_information16        varchar2,
  p_entry_information17        varchar2,
  p_entry_information18        varchar2,
  p_entry_information19        varchar2,
  p_entry_information20        varchar2,
  p_entry_information21        varchar2,
  p_entry_information22        varchar2,
  p_entry_information23        varchar2,
  p_entry_information24        varchar2,
  p_entry_information25        varchar2,
  p_entry_information26        varchar2,
  p_entry_information27        varchar2,
  p_entry_information28        varchar2,
  p_entry_information29        varchar2,
  p_entry_information30        varchar2,
  p_entry_rec                  out nocopy hr_entry_api.t_update_entry_rec
 ) is
   --
   -- Local Variables
   --
   v_entry_rec hr_entry_api.t_update_entry_rec;
   --
 begin
   --
   -- Cache entry details taking into account if the user has specifed a
   -- change. If no change has been supplied then the old value is used when
   -- updating.
   --
   begin
     select decode(p_cost_allocation_keyflex_id,hr_api.g_number,
                   ee.cost_allocation_keyflex_id,p_cost_allocation_keyflex_id),
            decode(p_updating_action_id,hr_api.g_number,
                   ee.updating_action_id,p_updating_action_id),
            decode(p_updating_action_type,hr_api.g_varchar2,
                   ee.updating_action_type,p_updating_action_type),
            decode(p_original_entry_id,hr_api.g_number,
                   ee.original_entry_id,p_original_entry_id),
            decode(p_creator_type,hr_api.g_varchar2,ee.creator_type,p_creator_type),
            decode(p_comment_id,hr_api.g_number,ee.comment_id,p_comment_id),
            decode(p_creator_id,hr_api.g_number,ee.creator_id,p_creator_id),
            decode(p_reason,hr_api.g_varchar2,ee.reason,p_reason),
            decode(p_subpriority,hr_api.g_number,ee.subpriority,p_subpriority),
            decode(p_date_earned ,hr_api.g_date,ee.date_earned ,p_date_earned),
            decode(p_personal_payment_method_id,hr_api.g_number,ee.personal_payment_method_id ,p_personal_payment_method_id),
            decode(p_attribute_category,hr_api.g_varchar2,
                   ee.attribute_category,p_attribute_category),
            decode(p_attribute1,hr_api.g_varchar2,ee.attribute1,p_attribute1),
            decode(p_attribute2,hr_api.g_varchar2,ee.attribute2,p_attribute2),
            decode(p_attribute3,hr_api.g_varchar2,ee.attribute3,p_attribute3),
            decode(p_attribute4,hr_api.g_varchar2,ee.attribute4,p_attribute4),
            decode(p_attribute5,hr_api.g_varchar2,ee.attribute5,p_attribute5),
            decode(p_attribute6,hr_api.g_varchar2,ee.attribute6,p_attribute6),
            decode(p_attribute7,hr_api.g_varchar2,ee.attribute7,p_attribute7),
            decode(p_attribute8,hr_api.g_varchar2,ee.attribute8,p_attribute8),
            decode(p_attribute9,hr_api.g_varchar2,ee.attribute9,p_attribute9),
            decode(p_attribute10,hr_api.g_varchar2,ee.attribute10,p_attribute10),
            decode(p_attribute11,hr_api.g_varchar2,ee.attribute11,p_attribute11),
            decode(p_attribute12,hr_api.g_varchar2,ee.attribute12,p_attribute12),
            decode(p_attribute13,hr_api.g_varchar2,ee.attribute13,p_attribute13),
            decode(p_attribute14,hr_api.g_varchar2,ee.attribute14,p_attribute14),
            decode(p_attribute15,hr_api.g_varchar2,ee.attribute15,p_attribute15),
            decode(p_attribute16,hr_api.g_varchar2,ee.attribute16,p_attribute16),
            decode(p_attribute17,hr_api.g_varchar2,ee.attribute17,p_attribute17),
            decode(p_attribute18,hr_api.g_varchar2,ee.attribute18,p_attribute18),
            decode(p_attribute19,hr_api.g_varchar2,ee.attribute19,p_attribute19),
            decode(p_attribute20,hr_api.g_varchar2,ee.attribute20,p_attribute20),
            ee.effective_start_date,
            ee.effective_end_date,
            ee.target_entry_id,
            ee.entry_type,
            ee.element_link_id,
            ee.assignment_id,
            et.element_type_id,
            et.processing_type,
            et.input_currency_code,
            et.output_currency_code,
-- --
            decode(p_entry_information_category,hr_api.g_varchar2,
                   ee.entry_information_category,p_entry_information_category),
            decode(p_entry_information1,hr_api.g_varchar2,ee.entry_information1,p_entry_information1),
            decode(p_entry_information2,hr_api.g_varchar2,ee.entry_information2,p_entry_information2),
            decode(p_entry_information3,hr_api.g_varchar2,ee.entry_information3,p_entry_information3),
            decode(p_entry_information4,hr_api.g_varchar2,ee.entry_information4,p_entry_information4),
            decode(p_entry_information5,hr_api.g_varchar2,ee.entry_information5,p_entry_information5),
            decode(p_entry_information6,hr_api.g_varchar2,ee.entry_information6,p_entry_information6),
            decode(p_entry_information7,hr_api.g_varchar2,ee.entry_information7,p_entry_information7),
            decode(p_entry_information8,hr_api.g_varchar2,ee.entry_information8,p_entry_information8),
            decode(p_entry_information9,hr_api.g_varchar2,ee.entry_information9,p_entry_information9),
            decode(p_entry_information10,hr_api.g_varchar2,ee.entry_information10,p_entry_information10),
            decode(p_entry_information11,hr_api.g_varchar2,ee.entry_information11,p_entry_information11),
            decode(p_entry_information12,hr_api.g_varchar2,ee.entry_information12,p_entry_information12),
            decode(p_entry_information13,hr_api.g_varchar2,ee.entry_information13,p_entry_information13),
            decode(p_entry_information14,hr_api.g_varchar2,ee.entry_information14,p_entry_information14),
            decode(p_entry_information15,hr_api.g_varchar2,ee.entry_information15,p_entry_information15),
            decode(p_entry_information16,hr_api.g_varchar2,ee.entry_information16,p_entry_information16),
            decode(p_entry_information17,hr_api.g_varchar2,ee.entry_information17,p_entry_information17),
            decode(p_entry_information18,hr_api.g_varchar2,ee.entry_information18,p_entry_information18),
            decode(p_entry_information19,hr_api.g_varchar2,ee.entry_information19,p_entry_information19),
            decode(p_entry_information20,hr_api.g_varchar2,ee.entry_information20,p_entry_information20),
            decode(p_entry_information21,hr_api.g_varchar2,ee.entry_information21,p_entry_information21),
            decode(p_entry_information22,hr_api.g_varchar2,ee.entry_information22,p_entry_information22),
            decode(p_entry_information23,hr_api.g_varchar2,ee.entry_information23,p_entry_information23),
            decode(p_entry_information24,hr_api.g_varchar2,ee.entry_information24,p_entry_information24),
            decode(p_entry_information25,hr_api.g_varchar2,ee.entry_information25,p_entry_information25),
            decode(p_entry_information26,hr_api.g_varchar2,ee.entry_information26,p_entry_information26),
            decode(p_entry_information27,hr_api.g_varchar2,ee.entry_information27,p_entry_information27),
            decode(p_entry_information28,hr_api.g_varchar2,ee.entry_information28,p_entry_information28),
            decode(p_entry_information29,hr_api.g_varchar2,ee.entry_information29,p_entry_information29),
            decode(p_entry_information30,hr_api.g_varchar2,ee.entry_information30,p_entry_information30)
     into   v_entry_rec
     from   pay_element_entries_f ee,
            pay_element_links_f el,
            pay_element_types_f et
     where  ee.element_entry_id = p_element_entry_id
       and  el.element_link_id = ee.element_link_id
       and  et.element_type_id = el.element_type_id
       and  p_session_date between ee.effective_start_date
                               and ee.effective_end_date
       and  p_session_date between el.effective_start_date
                               and el.effective_end_date
       and  p_session_date between et.effective_start_date
                               and et.effective_end_date;
   exception
     when no_data_found then
       hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE',
                                    'hr_entry_api.upd_ele_entry_param_val');
       hr_utility.set_message_token('STEP','1');
       hr_utility.raise_error;
   end;
   --
   -- If specified make sure cost allocation exists
   --
   if p_cost_allocation_keyflex_id <> hr_api.g_number then
     hr_entry_api.val_cost_allocation
       (p_cost_allocation_keyflex_id);
   end if;
   --
   -- If specified make sure reason is a valid lookup
   --
   if p_reason <> hr_api.g_varchar2 then
     hr_entry_api.val_reason
       (p_reason,
        p_session_date);
   end if;
   --
   -- If specified make sure comment exists
   --
   if p_comment_id <> hr_api.g_number then
     hr_entry_api.val_comment
       (p_comment_id);
   end if;
   --
   -- If specified make sure original entry is for the same assignment and
   -- element link as the element entry being created
   --
   if p_original_entry_id <> hr_api.g_number then
     hr_entry_api.val_original_entry
       (p_original_entry_id,
        v_entry_rec.assignment_id,
        v_entry_rec.element_link_id,
        v_entry_rec.entry_type,
        p_session_date);
   end if;
   --
   -- Nonrecurring entries can only be corrected ie. a nonrecurring entry is
   -- always represented by one row.
   --
   if (v_entry_rec.processing_type = 'N' and v_entry_rec.entry_type = 'E') or
       v_entry_rec.entry_type <> 'E' then
     --
     p_dt_update_mode := 'CORRECTION';
     --
   else
     --
     -- If the p_dt_update_mode is null, then we default to UPDATE mode.
     --
     p_dt_update_mode := nvl(p_dt_update_mode, 'UPDATE');
     --
     -- When an update is being carried out at the start date of an entry then
     -- a CORRECTION is made.
     --
     if v_entry_rec.effective_start_date = p_session_date then
       --
       p_dt_update_mode := 'CORRECTION';
     --
     -- UPDATE mode has been selected but there are future changes. Do a
     -- UPDATE_CHANGE_INSERT instead NB. this is the least destructive option.
     --
     elsif p_dt_update_mode = 'UPDATE' and
           v_entry_rec.effective_end_date <> hr_general.end_of_time then
       --
       p_dt_update_mode := 'UPDATE_CHANGE_INSERT';
     --
     -- UPDATE_CHANGE_INSERT or UPDATE_OVERRIDE mode has been selected but
     -- there are no changes in the future. Do an UPDATE instead.
     --
     elsif p_dt_update_mode in ('UPDATE_CHANGE_INSERT','UPDATE_OVERRIDE') and
           v_entry_rec.effective_end_date = hr_general.end_of_time then
     --
       p_dt_update_mode := 'UPDATE';
     --
     end if;
   --
   end if;
   --
   -- Return entry details for use when updating the element entry.
   --
   p_entry_rec := v_entry_rec;
   --
 end upd_ele_entry_param_val;
--
-- --
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry_api.upd_element_entry                                           --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Updates an element entry providing full validation.                      --
 ------------------------------------------------------------------------------
--
 procedure upd_element_entry
 (
  --
  -- Update Mode
  --
  p_dt_update_mode             varchar2,
  --
  -- Date on which change is taking place
  --
  p_session_date               date,
  --
  -- Check to see if the entry is being updated
  --
  p_check_for_update           varchar2,
  --
  -- Element Entry Table
  --
  p_element_entry_id           number,
  p_cost_allocation_keyflex_id number,
  p_updating_action_id         number,
  p_updating_action_type       varchar2,
  p_original_entry_id          number,
  p_creator_type               varchar2,
  p_comment_id                 number,
  p_creator_id                 number,
  p_reason                     varchar2,
  p_subpriority                number,
  p_date_earned                 date,
  p_personal_payment_method_id  number,
  p_attribute_category         varchar2,
  p_attribute1                 varchar2,
  p_attribute2                 varchar2,
  p_attribute3                 varchar2,
  p_attribute4                 varchar2,
  p_attribute5                 varchar2,
  p_attribute6                 varchar2,
  p_attribute7                 varchar2,
  p_attribute8                 varchar2,
  p_attribute9                 varchar2,
  p_attribute10                varchar2,
  p_attribute11                varchar2,
  p_attribute12                varchar2,
  p_attribute13                varchar2,
  p_attribute14                varchar2,
  p_attribute15                varchar2,
  p_attribute16                varchar2,
  p_attribute17                varchar2,
  p_attribute18                varchar2,
  p_attribute19                varchar2,
  p_attribute20                varchar2,
  --
  -- Element Entry Values Table
  --
  p_num_entry_values           number,
  p_input_value_id_tbl         hr_entry.number_table,
  p_entry_value_tbl            hr_entry.varchar2_table,
  --
  -- J.Bailie Element Entries DDF
  --
  p_entry_information_category varchar2,
  p_entry_information1         varchar2,
  p_entry_information2         varchar2,
  p_entry_information3         varchar2,
  p_entry_information4         varchar2,
  p_entry_information5         varchar2,
  p_entry_information6         varchar2,
  p_entry_information7         varchar2,
  p_entry_information8         varchar2,
  p_entry_information9         varchar2,
  p_entry_information10        varchar2,
  p_entry_information11        varchar2,
  p_entry_information12        varchar2,
  p_entry_information13        varchar2,
  p_entry_information14        varchar2,
  p_entry_information15        varchar2,
  p_entry_information16        varchar2,
  p_entry_information17        varchar2,
  p_entry_information18        varchar2,
  p_entry_information19        varchar2,
  p_entry_information20        varchar2,
  p_entry_information21        varchar2,
  p_entry_information22        varchar2,
  p_entry_information23        varchar2,
  p_entry_information24        varchar2,
  p_entry_information25        varchar2,
  p_entry_information26        varchar2,
  p_entry_information27        varchar2,
  p_entry_information28        varchar2,
  p_entry_information29        varchar2,
  p_entry_information30        varchar2
 ) is
--
   -- Find all accepted pay proposals that use the element entry.
   cursor csr_accepted_pay_proposals
          (
           p_element_entry_id number,
           p_assignment_id    number
          ) is
     select pp.pay_proposal_id
     from   per_pay_proposals pp
     where  pp.assignment_id = p_assignment_id
       and  exists
            (select null
             from   pay_element_entries_f ee
             where  ee.element_entry_id = p_element_entry_id
               and  ee.creator_type = 'SP'
               and  ee.creator_id = pp.pay_proposal_id
               and  ee.effective_start_date = pp.change_date);
   --
   -- bug 666197
   --
   -- OVN of the dml record
   cursor csr_object_version_number
     (p_element_entry_id number, p_effective_date date) is
      select object_version_number, effective_start_date, effective_end_date
        from pay_element_entries_f
        where element_entry_id = p_element_entry_id
          and p_effective_date between effective_start_date
                                   and effective_end_date;

   --
   -- old values of the dml record
   cursor csr_old_entry_values is
     select
       effective_start_date
      ,effective_end_date
      ,cost_allocation_keyflex_id
      ,assignment_id
      ,updating_action_id
      ,updating_action_type
      ,element_link_id
      ,original_entry_id
      ,creator_type
      ,entry_type
      ,comment_id
      ,creator_id
      ,reason
      ,target_entry_id
      ,source_id
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,attribute16
      ,attribute17
      ,attribute18
      ,attribute19
      ,attribute20
      ,subpriority
      ,personal_payment_method_id
      ,date_earned
      ,object_version_number
      ,balance_adj_cost_flag
  --
  -- J.Bailie 08-NOV-99 Element Entries DDF
  --
      ,entry_information_category
      ,entry_information1
      ,entry_information2
      ,entry_information3
      ,entry_information4
      ,entry_information5
      ,entry_information6
      ,entry_information7
      ,entry_information8
      ,entry_information9
      ,entry_information10
      ,entry_information11
      ,entry_information12
      ,entry_information13
      ,entry_information14
      ,entry_information15
      ,entry_information16
      ,entry_information17
      ,entry_information18
      ,entry_information19
      ,entry_information20
      ,entry_information21
      ,entry_information22
      ,entry_information23
      ,entry_information24
      ,entry_information25
      ,entry_information26
      ,entry_information27
      ,entry_information28
      ,entry_information29
      ,entry_information30
      ,element_type_id
      ,all_entry_values_null
    from pay_element_entries_f
    where element_entry_id = p_element_entry_id
      and p_session_date between effective_start_date
                             and effective_end_date;
    --
   -- Local Variables
   v_validation_start_date  date;
   v_validation_end_date    date;
   v_max_effective_end_date date;
   v_dt_update_mode         varchar2(30) := p_dt_update_mode;
   v_entry_rec              hr_entry_api.t_update_entry_rec;
   v_entry_being_changed    boolean      := true;
   v_pay_proposal_id        number;
   l_all_entry_values_null           varchar2(30);
   -- bug 666197
   l_object_version_number           number;
   l_effective_start_date            date;
   l_effective_end_date              date;
   l_effective_start_date_o          date;
   l_effective_end_date_o            date;
   l_cost_allocation_keyflex_id_o    number;
   l_assignment_id_o                 number;
   l_updating_action_id_o            number;
   l_updating_action_type_o          varchar2(30);
   l_element_link_id_o               number;
   l_original_entry_id_o             number;
   l_creator_type_o                  varchar2(10);
   l_entry_type_o                    varchar2(1);
   l_comment_id_o                    number;
   l_creator_id_o                    number;
   l_reason_o                        varchar2(30);
   l_target_entry_id_o               number;
   l_source_id_o                     number;
   l_attribute_category_o            varchar2(30);
   l_attribute1_o                    varchar2(150);
   l_attribute2_o                    varchar2(150);
   l_attribute3_o                    varchar2(150);
   l_attribute4_o                    varchar2(150);
   l_attribute5_o                    varchar2(150);
   l_attribute6_o                    varchar2(150);
   l_attribute7_o                    varchar2(150);
   l_attribute8_o                    varchar2(150);
   l_attribute9_o                    varchar2(150);
   l_attribute10_o                   varchar2(150);
   l_attribute11_o                   varchar2(150);
   l_attribute12_o                   varchar2(150);
   l_attribute13_o                   varchar2(150);
   l_attribute14_o                   varchar2(150);
   l_attribute15_o                   varchar2(150);
   l_attribute16_o                   varchar2(150);
   l_attribute17_o                   varchar2(150);
   l_attribute18_o                   varchar2(150);
   l_attribute19_o                   varchar2(150);
   l_attribute20_o                   varchar2(150);
   l_subpriority_o                   number;
   l_entry_information_category_o    varchar2(30);
   l_entry_information1_o            varchar2(150);
   l_entry_information2_o            varchar2(150);
   l_entry_information3_o            varchar2(150);
   l_entry_information4_o            varchar2(150);
   l_entry_information5_o            varchar2(150);
   l_entry_information6_o            varchar2(150);
   l_entry_information7_o            varchar2(150);
   l_entry_information8_o            varchar2(150);
   l_entry_information9_o            varchar2(150);
   l_entry_information10_o           varchar2(150);
   l_entry_information11_o           varchar2(150);
   l_entry_information12_o           varchar2(150);
   l_entry_information13_o           varchar2(150);
   l_entry_information14_o           varchar2(150);
   l_entry_information15_o           varchar2(150);
   l_entry_information16_o           varchar2(150);
   l_entry_information17_o           varchar2(150);
   l_entry_information18_o           varchar2(150);
   l_entry_information19_o           varchar2(150);
   l_entry_information20_o           varchar2(150);
   l_entry_information21_o           varchar2(150);
   l_entry_information22_o           varchar2(150);
   l_entry_information23_o           varchar2(150);
   l_entry_information24_o           varchar2(150);
   l_entry_information25_o           varchar2(150);
   l_entry_information26_o           varchar2(150);
   l_entry_information27_o           varchar2(150);
   l_entry_information28_o           varchar2(150);
   l_entry_information29_o           varchar2(150);
   l_entry_information30_o           varchar2(150);
   l_personal_payment_method_id_o    number;
   l_date_earned_o                   date;
   l_object_version_number_o         number;
   l_balance_adj_cost_flag_o         varchar2(1);
   l_element_type_id_o               number;
   l_all_entry_values_null_o         varchar2(30);
--

   l_old_val_tab                     pay_ele_shd.g_old_val_tab_type; --Local store of eev_old details
--

 begin
   --
   g_debug := hr_utility.debug_enabled;
   --
   -- bug 666197, retrieve and store old values for the entry row
   --
   begin
   --
   open csr_old_entry_values;
   fetch csr_old_entry_values into
       l_effective_start_date_o
      ,l_effective_end_date_o
      ,l_cost_allocation_keyflex_id_o
      ,l_assignment_id_o
      ,l_updating_action_id_o
      ,l_updating_action_type_o
      ,l_element_link_id_o
      ,l_original_entry_id_o
      ,l_creator_type_o
      ,l_entry_type_o
      ,l_comment_id_o
      ,l_creator_id_o
      ,l_reason_o
      ,l_target_entry_id_o
      ,l_source_id_o
      ,l_attribute_category_o
      ,l_attribute1_o
      ,l_attribute2_o
      ,l_attribute3_o
      ,l_attribute4_o
      ,l_attribute5_o
      ,l_attribute6_o
      ,l_attribute7_o
      ,l_attribute8_o
      ,l_attribute9_o
      ,l_attribute10_o
      ,l_attribute11_o
      ,l_attribute12_o
      ,l_attribute13_o
      ,l_attribute14_o
      ,l_attribute15_o
      ,l_attribute16_o
      ,l_attribute17_o
      ,l_attribute18_o
      ,l_attribute19_o
      ,l_attribute20_o
      ,l_subpriority_o
      ,l_personal_payment_method_id_o
      ,l_date_earned_o
      ,l_object_version_number_o
      ,l_balance_adj_cost_flag_o
      ,l_entry_information_category_o
      ,l_entry_information1_o
      ,l_entry_information2_o
      ,l_entry_information3_o
      ,l_entry_information4_o
      ,l_entry_information5_o
      ,l_entry_information6_o
      ,l_entry_information7_o
      ,l_entry_information8_o
      ,l_entry_information9_o
      ,l_entry_information10_o
      ,l_entry_information11_o
      ,l_entry_information12_o
      ,l_entry_information13_o
      ,l_entry_information14_o
      ,l_entry_information15_o
      ,l_entry_information16_o
      ,l_entry_information17_o
      ,l_entry_information18_o
      ,l_entry_information19_o
      ,l_entry_information20_o
      ,l_entry_information21_o
      ,l_entry_information22_o
      ,l_entry_information23_o
      ,l_entry_information24_o
      ,l_entry_information25_o
      ,l_entry_information26_o
      ,l_entry_information27_o
      ,l_entry_information28_o
      ,l_entry_information29_o
      ,l_entry_information30_o
      ,l_element_type_id_o
      ,l_all_entry_values_null_o;
   close csr_old_entry_values;
   exception
   when no_data_found then
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE','hr_entry_api.upd_element_entry');
     hr_utility.set_message_token('STEP','10');
     hr_utility.raise_error;
   end;
   -- If the entry row is to be checked for a changed attribute then
   -- check to see if the entry row is being changed.
   --
   if (p_check_for_update = 'Y') then
     v_entry_being_changed :=
       hr_entry_api.element_entry_changed
       (p_session_date,
        p_element_entry_id,
        p_cost_allocation_keyflex_id,
        p_updating_action_id,
        p_updating_action_type,
        p_original_entry_id,
        p_creator_type,
        p_comment_id,
        p_creator_id,
        p_reason,
        p_subpriority,
        p_date_earned,
        p_personal_payment_method_id,
        p_attribute_category,
        p_attribute1,
        p_attribute2,
        p_attribute3,
        p_attribute4,
        p_attribute5,
        p_attribute6,
        p_attribute7,
        p_attribute8,
        p_attribute9,
        p_attribute10,
        p_attribute11,
        p_attribute12,
        p_attribute13,
        p_attribute14,
        p_attribute15,
        p_attribute16,
        p_attribute17,
        p_attribute18,
        p_attribute19,
        p_attribute20,
        p_num_entry_values,
        p_input_value_id_tbl,
        p_entry_value_tbl,
        p_entry_information_category,
        p_entry_information1,
        p_entry_information2,
        p_entry_information3,
        p_entry_information4,
        p_entry_information5,
        p_entry_information6,
        p_entry_information7,
        p_entry_information8,
        p_entry_information9,
        p_entry_information10,
        p_entry_information11,
        p_entry_information12,
        p_entry_information13,
        p_entry_information14,
        p_entry_information15,
        p_entry_information16,
        p_entry_information17,
        p_entry_information18,
        p_entry_information19,
        p_entry_information20,
        p_entry_information21,
        p_entry_information22,
        p_entry_information23,
        p_entry_information24,
        p_entry_information25,
        p_entry_information26,
        p_entry_information27,
        p_entry_information28,
        p_entry_information29,
        p_entry_information30
       );
   end if;
--
   if v_entry_being_changed then
     -- Validate the parameters and return details of the current element entry.
     hr_entry_api.upd_ele_entry_param_val
       (v_dt_update_mode,
        p_session_date,
        p_element_entry_id,
        p_cost_allocation_keyflex_id,
        p_updating_action_id,
        p_updating_action_type,
        p_original_entry_id,
        p_creator_type,
        p_comment_id,
        p_creator_id,
        p_reason,
        p_subpriority,
        p_date_earned,
        p_personal_payment_method_id,
        p_attribute_category,
        p_attribute1,
        p_attribute2,
        p_attribute3,
        p_attribute4,
        p_attribute5,
        p_attribute6,
        p_attribute7,
        p_attribute8,
        p_attribute9,
        p_attribute10,
        p_attribute11,
        p_attribute12,
        p_attribute13,
        p_attribute14,
        p_attribute15,
        p_attribute16,
        p_attribute17,
        p_attribute18,
        p_attribute19,
        p_attribute20,
        p_entry_information_category,
        p_entry_information1,
        p_entry_information2,
        p_entry_information3,
        p_entry_information4,
        p_entry_information5,
        p_entry_information6,
        p_entry_information7,
        p_entry_information8,
        p_entry_information9,
        p_entry_information10,
        p_entry_information11,
        p_entry_information12,
        p_entry_information13,
        p_entry_information14,
        p_entry_information15,
        p_entry_information16,
        p_entry_information17,
        p_entry_information18,
        p_entry_information19,
        p_entry_information20,
        p_entry_information21,
        p_entry_information22,
        p_entry_information23,
        p_entry_information24,
        p_entry_information25,
        p_entry_information26,
        p_entry_information27,
        p_entry_information28,
        p_entry_information29,
        p_entry_information30,
        v_entry_rec
     );
--
     -- Set the validation start and end dates according to the update mode
     -- selected.
     if v_dt_update_mode = 'UPDATE' or
        v_dt_update_mode = 'UPDATE_CHANGE_INSERT' then
--
       v_validation_start_date := p_session_date;
       v_validation_end_date   := v_entry_rec.effective_end_date;
--
     elsif v_dt_update_mode = 'UPDATE_OVERRIDE' then
--
       begin
         select max(ee.effective_end_date)
         into   v_max_effective_end_date
         from   pay_element_entries_f ee
         where  ee.element_entry_id = p_element_entry_id;
       exception
         when no_data_found then null;
       end;
--
       v_validation_start_date := p_session_date;
       v_validation_end_date   := v_max_effective_end_date;
--
     elsif v_dt_update_mode = 'CORRECTION' then
--
       v_validation_start_date := v_entry_rec.effective_start_date;
       v_validation_end_date   := v_entry_rec.effective_end_date;
--
     end if;
--
--
     validate_ppm_id (v_entry_rec.personal_payment_method_id,
                      v_entry_rec.assignment_id,
                      v_entry_rec.element_link_id,
                      v_validation_start_date,
                      v_validation_end_date,
                      l_entry_type_o);
                      --
--
     -- Make sure the update is valid.
     hr_entry.chk_element_entry_main
       (p_element_entry_id,
        v_entry_rec.original_entry_id,
        p_session_date,
        v_entry_rec.element_link_id,
        v_entry_rec.assignment_id,
        v_entry_rec.entry_type,
        v_entry_rec.effective_start_date,
        v_entry_rec.effective_end_date,
        v_validation_start_date,
        v_validation_end_date,
        v_dt_update_mode,
        null,
        'UPDATE',  -- p_usage
        v_entry_rec.target_entry_id,
        p_creator_type);
--
     -- Validate salary admin updates to user-enterable fields
     --
     hr_entry_api.check_salary_admin_updates (
        --
        p_element_entry_id      => p_element_entry_id,
        p_new_entry             => v_entry_rec,
        p_effective_date        => p_session_date,
        p_dt_update_mode        => p_dt_update_mode);
        --
     -- Make a copy of all pay proposals for the assignment which have been
     -- accepted. This is used later to see if any have had the element entry
     -- changed ie. creator type changed, removed etc... If so the pay proposal
     -- has to be removed.
     open csr_accepted_pay_proposals(p_element_entry_id,
                                     v_entry_rec.assignment_id);
--
     -- Trigger workload shifting if change to element entry overlaps with the
     -- latest payroll run for the assignment and workload shifting is enabled.
     hr_entry.trigger_workload_shifting
       ('ELEMENT_ENTRY',
        v_entry_rec.assignment_id,
        v_validation_start_date,
        v_validation_end_date);
--
     -- Bugfix 2768375
     -- Perform validation of Element Entry Developer DF segments
     if fnd_flex_dsc_api.flexfield_exists(
            appl_short_name => 'PAY',
            flexfield_name  => 'Element Entry Developer DF') then

       if g_debug then
          hr_utility.trace('| element entry DDFF defined');
          hr_utility.trace('| p_entry_information_category' ||
                              p_entry_information_category || '<');
       end if;

       --
       -- only do FF validation if the context exists
       --
       if fnd_flex_dsc_api.context_exists(
            p_appl_short_name => 'PAY',
            p_flexfield_name  => 'Element Entry Developer DF',
            p_context_code    => p_entry_information_category) then

         if g_debug then
           hr_utility.trace('| element entry context in use, do validation');
         end if;

         hr_entry_api.ddf_update_validate(
           p_entry_information_category   => p_entry_information_category
         , p_entry_information1           => p_entry_information1
         , p_entry_information2           => p_entry_information2
         , p_entry_information3           => p_entry_information3
         , p_entry_information4           => p_entry_information4
         , p_entry_information5           => p_entry_information5
         , p_entry_information6           => p_entry_information6
         , p_entry_information7           => p_entry_information7
         , p_entry_information8           => p_entry_information8
         , p_entry_information9           => p_entry_information9
         , p_entry_information10          => p_entry_information10
         , p_entry_information11          => p_entry_information11
         , p_entry_information12          => p_entry_information12
         , p_entry_information13          => p_entry_information13
         , p_entry_information14          => p_entry_information14
         , p_entry_information15          => p_entry_information15
         , p_entry_information16          => p_entry_information16
         , p_entry_information17          => p_entry_information17
         , p_entry_information18          => p_entry_information18
         , p_entry_information19          => p_entry_information19
         , p_entry_information20          => p_entry_information20
         , p_entry_information21          => p_entry_information21
         , p_entry_information22          => p_entry_information22
         , p_entry_information23          => p_entry_information23
         , p_entry_information24          => p_entry_information24
         , p_entry_information25          => p_entry_information25
         , p_entry_information26          => p_entry_information26
         , p_entry_information27          => p_entry_information27
         , p_entry_information28          => p_entry_information28
         , p_entry_information29          => p_entry_information29
         , p_entry_information30          => p_entry_information30
         , p_entry_information_category_o => l_entry_information_category_o
         , p_entry_information1_o         => l_entry_information1_o
         , p_entry_information2_o         => l_entry_information2_o
         , p_entry_information3_o         => l_entry_information3_o
         , p_entry_information4_o         => l_entry_information4_o
         , p_entry_information5_o         => l_entry_information5_o
         , p_entry_information6_o         => l_entry_information6_o
         , p_entry_information7_o         => l_entry_information7_o
         , p_entry_information8_o         => l_entry_information8_o
         , p_entry_information9_o         => l_entry_information9_o
         , p_entry_information10_o        => l_entry_information10_o
         , p_entry_information11_o        => l_entry_information11_o
         , p_entry_information12_o        => l_entry_information12_o
         , p_entry_information13_o        => l_entry_information13_o
         , p_entry_information14_o        => l_entry_information14_o
         , p_entry_information15_o        => l_entry_information15_o
         , p_entry_information16_o        => l_entry_information16_o
         , p_entry_information17_o        => l_entry_information17_o
         , p_entry_information18_o        => l_entry_information18_o
         , p_entry_information19_o        => l_entry_information19_o
         , p_entry_information20_o        => l_entry_information20_o
         , p_entry_information21_o        => l_entry_information21_o
         , p_entry_information22_o        => l_entry_information22_o
         , p_entry_information23_o        => l_entry_information23_o
         , p_entry_information24_o        => l_entry_information24_o
         , p_entry_information25_o        => l_entry_information25_o
         , p_entry_information26_o        => l_entry_information26_o
         , p_entry_information27_o        => l_entry_information27_o
         , p_entry_information28_o        => l_entry_information28_o
         , p_entry_information29_o        => l_entry_information29_o
         , p_entry_information30_o        => l_entry_information30_o);

       end if;

     end if;
     -- End Bugfix 2768375
--
     --
     -- Enhancement 3478848
     -- Derive all_entry_values_null
     --
     l_all_entry_values_null := derive_all_entry_values_null(p_entry_value_tbl);
--
     -- Do date effective operation on element entry.
     if v_dt_update_mode in ('UPDATE','UPDATE_CHANGE_INSERT',
                             'UPDATE_OVERRIDE')  then
--
       -- Clear out future records (if any).
       if v_dt_update_mode = 'UPDATE_OVERRIDE' then
--
         delete from pay_element_entries_f ee
         where  ee.element_entry_id = p_element_entry_id
           and  ee.effective_start_date > v_entry_rec.effective_start_date;
--
       end if;
--

       --
       -- Bug 3674811 : updating_action_id
       --      null on first half for Stop
       --      null on second half for Update Recurring
       --

       update pay_element_entries_f ee
       set    ee.effective_end_date = p_session_date - 1,
              ee.updating_action_id = decode(ee.updating_action_type, 'U', ee.updating_action_id,
                                                                      null),
              ee.updating_action_type = decode(ee.updating_action_type, 'U', 'U', null)
       where  ee.element_entry_id = p_element_entry_id
         and  ee.effective_start_date = v_entry_rec.effective_start_date;

       --
       -- Bugfix 3110853
       -- Derive the OVN here instead of in the database trigger in order to
       -- avoid the ORA-04091 error
       --
       l_object_version_number := dt_api.get_object_version_number
                                  ('PAY_ELEMENT_ENTRIES_F'
                                  ,'ELEMENT_ENTRY_ID'
                                  ,p_element_entry_id);

       insert into pay_element_entries_f
       (element_entry_id,
        effective_start_date,
        effective_end_date,
        cost_allocation_keyflex_id,
        assignment_id,
        updating_action_id,
        updating_action_type,
        element_link_id,
        original_entry_id,
        creator_type,
        entry_type,
        comment_id,
        creator_id,
        reason,
        target_entry_id,
        subpriority,
        date_earned,
        personal_payment_method_id,
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
        --
        -- J.Bailie 08-NOV-99 Element Entries DDF
        --
        entry_information_category,
        entry_information1,
        entry_information2,
        entry_information3,
        entry_information4,
        entry_information5,
        entry_information6,
        entry_information7,
        entry_information8,
        entry_information9,
        entry_information10,
        entry_information11,
        entry_information12,
        entry_information13,
        entry_information14,
        entry_information15,
        entry_information16,
        entry_information17,
        entry_information18,
        entry_information19,
        entry_information20,
        entry_information21,
        entry_information22,
        entry_information23,
        entry_information24,
        entry_information25,
        entry_information26,
        entry_information27,
        entry_information28,
        entry_information29,
        entry_information30,
        element_type_id,
        all_entry_values_null,
        object_version_number,
        last_update_date,
        last_updated_by,
        last_update_login,
        created_by,
        creation_date)
       select
        ee.element_entry_id,
        v_validation_start_date,
        v_validation_end_date,
        v_entry_rec.cost_allocation_keyflex_id,
        ee.assignment_id,
        decode(ee.updating_action_type, 'S', ee.updating_action_id, null),
        decode(ee.updating_action_type, 'S', 'S', null),
        ee.element_link_id,
        v_entry_rec.original_entry_id,
        v_entry_rec.creator_type,
        ee.entry_type,
        v_entry_rec.comment_id,
        v_entry_rec.creator_id,
        v_entry_rec.reason,
        ee.target_entry_id,
        v_entry_rec.subpriority,
        v_entry_rec.date_earned,
        v_entry_rec.personal_payment_method_id,
        v_entry_rec.attribute_category,
        v_entry_rec.attribute1,
        v_entry_rec.attribute2,
        v_entry_rec.attribute3,
        v_entry_rec.attribute4,
        v_entry_rec.attribute5,
        v_entry_rec.attribute6,
        v_entry_rec.attribute7,
        v_entry_rec.attribute8,
        v_entry_rec.attribute9,
        v_entry_rec.attribute10,
        v_entry_rec.attribute11,
        v_entry_rec.attribute12,
        v_entry_rec.attribute13,
        v_entry_rec.attribute14,
        v_entry_rec.attribute15,
        v_entry_rec.attribute16,
        v_entry_rec.attribute17,
        v_entry_rec.attribute18,
        v_entry_rec.attribute19,
        v_entry_rec.attribute20,
        --
        -- J.Bailie 08-NOV-99 Element Entries DDF
        --
        v_entry_rec.entry_information_category,
        v_entry_rec.entry_information1,
        v_entry_rec.entry_information2,
        v_entry_rec.entry_information3,
        v_entry_rec.entry_information4,
        v_entry_rec.entry_information5,
        v_entry_rec.entry_information6,
        v_entry_rec.entry_information7,
        v_entry_rec.entry_information8,
        v_entry_rec.entry_information9,
        v_entry_rec.entry_information10,
        v_entry_rec.entry_information11,
        v_entry_rec.entry_information12,
        v_entry_rec.entry_information13,
        v_entry_rec.entry_information14,
        v_entry_rec.entry_information15,
        v_entry_rec.entry_information16,
        v_entry_rec.entry_information17,
        v_entry_rec.entry_information18,
        v_entry_rec.entry_information19,
        v_entry_rec.entry_information20,
        v_entry_rec.entry_information21,
        v_entry_rec.entry_information22,
        v_entry_rec.entry_information23,
        v_entry_rec.entry_information24,
        v_entry_rec.entry_information25,
        v_entry_rec.entry_information26,
        v_entry_rec.entry_information27,
        v_entry_rec.entry_information28,
        v_entry_rec.entry_information29,
        v_entry_rec.entry_information30,
        v_entry_rec.element_type_id,
        l_all_entry_values_null,
        l_object_version_number,
        trunc(sysdate),
        0,
        0,
        ee.created_by,
        ee.creation_date
       from  pay_element_entries_f ee
       where ee.element_entry_id = p_element_entry_id
         and ee.effective_start_date = v_entry_rec.effective_start_date;
--
     elsif v_dt_update_mode = 'CORRECTION' then
       update pay_element_entries_f ee
       set    ee.cost_allocation_keyflex_id =
              v_entry_rec.cost_allocation_keyflex_id,
              ee.updating_action_id = v_entry_rec.updating_action_id,
              ee.updating_action_type = v_entry_rec.updating_action_type,
              ee.original_entry_id = v_entry_rec.original_entry_id,
              ee.creator_type = v_entry_rec.creator_type,
              ee.comment_id = v_entry_rec.comment_id,
              ee.creator_id = v_entry_rec.creator_id,
              ee.reason = v_entry_rec.reason,
              ee.subpriority = v_entry_rec.subpriority,
              ee.date_earned = v_entry_rec.date_earned,
              ee.personal_payment_method_id = v_entry_rec.personal_payment_method_id,
              ee.all_entry_values_null = l_all_entry_values_null,
              ee.attribute_category = v_entry_rec.attribute_category,
              ee.attribute1  = v_entry_rec.attribute1,
              ee.attribute2  = v_entry_rec.attribute2,
              ee.attribute3  = v_entry_rec.attribute3,
              ee.attribute4  = v_entry_rec.attribute4,
              ee.attribute5  = v_entry_rec.attribute5,
              ee.attribute6  = v_entry_rec.attribute6,
              ee.attribute7  = v_entry_rec.attribute7,
              ee.attribute8  = v_entry_rec.attribute8,
              ee.attribute9  = v_entry_rec.attribute9,
              ee.attribute10 = v_entry_rec.attribute10,
              ee.attribute11 = v_entry_rec.attribute11,
              ee.attribute12 = v_entry_rec.attribute12,
              ee.attribute13 = v_entry_rec.attribute13,
              ee.attribute14 = v_entry_rec.attribute14,
              ee.attribute15 = v_entry_rec.attribute15,
              ee.attribute16 = v_entry_rec.attribute16,
              ee.attribute17 = v_entry_rec.attribute17,
              ee.attribute18 = v_entry_rec.attribute18,
              ee.attribute19 = v_entry_rec.attribute19,
              ee.attribute20 = v_entry_rec.attribute20,
              ee.entry_information_category = v_entry_rec.entry_information_category,
              ee.entry_information1  = v_entry_rec.entry_information1,
              ee.entry_information2  = v_entry_rec.entry_information2,
              ee.entry_information3  = v_entry_rec.entry_information3,
              ee.entry_information4  = v_entry_rec.entry_information4,
              ee.entry_information5  = v_entry_rec.entry_information5,
              ee.entry_information6  = v_entry_rec.entry_information6,
              ee.entry_information7  = v_entry_rec.entry_information7,
              ee.entry_information8  = v_entry_rec.entry_information8,
              ee.entry_information9  = v_entry_rec.entry_information9,
              ee.entry_information10  = v_entry_rec.entry_information10,
              ee.entry_information11  = v_entry_rec.entry_information11,
              ee.entry_information12  = v_entry_rec.entry_information12,
              ee.entry_information13  = v_entry_rec.entry_information13,
              ee.entry_information14  = v_entry_rec.entry_information14,
              ee.entry_information15  = v_entry_rec.entry_information15,
              ee.entry_information16  = v_entry_rec.entry_information16,
              ee.entry_information17  = v_entry_rec.entry_information17,
              ee.entry_information18  = v_entry_rec.entry_information18,
              ee.entry_information19  = v_entry_rec.entry_information19,
              ee.entry_information20  = v_entry_rec.entry_information20,
              ee.entry_information21  = v_entry_rec.entry_information21,
              ee.entry_information22  = v_entry_rec.entry_information22,
              ee.entry_information23  = v_entry_rec.entry_information23,
              ee.entry_information24  = v_entry_rec.entry_information24,
              ee.entry_information25  = v_entry_rec.entry_information25,
              ee.entry_information26  = v_entry_rec.entry_information26,
              ee.entry_information27  = v_entry_rec.entry_information27,
              ee.entry_information28  = v_entry_rec.entry_information28,
              ee.entry_information29  = v_entry_rec.entry_information29,
              ee.entry_information30  = v_entry_rec.entry_information30,
              ee.last_update_date  = trunc(sysdate),
              ee.last_updated_by   = 0,
              ee.last_update_login = 0
       where  ee.element_entry_id = p_element_entry_id
         and  ee.effective_start_date = v_validation_start_date;

     end if;
--
    -- 21-FEB-03
    -- Before we change the element entry values for this entry, we need to store
    -- the old element_entry_values for our hardcoded call to the CC DYT_PKG
    l_old_val_tab.delete;
    g_counter := 0;

    For vals_rec in pay_ele_shd.csr_get_eevals(p_element_entry_id,p_session_date) loop
      g_counter := g_counter + 1;
        l_old_val_tab(g_counter).element_entry_value_id
              := vals_rec.element_entry_value_id;
        l_old_val_tab(g_counter).effective_start_date
              := vals_rec.effective_start_date;
        l_old_val_tab(g_counter).effective_end_date
              := vals_rec.effective_end_date;
        l_old_val_tab(g_counter).input_value_id
             := vals_rec.input_value_id;
        l_old_val_tab(g_counter).element_entry_id
              := vals_rec.element_entry_id;
        l_old_val_tab(g_counter).screen_entry_value
              := vals_rec.screen_entry_value;

    End Loop;

--
     -- Update element entry values.
     hr_entry.upd_3p_entry_values
       (p_element_entry_id,
        v_entry_rec.element_type_id,
        v_entry_rec.element_link_id,
        v_entry_rec.cost_allocation_keyflex_id,
        v_entry_rec.entry_type,
        v_entry_rec.processing_type,
        v_entry_rec.creator_type,
        v_entry_rec.creator_id,
        v_entry_rec.assignment_id,
        v_entry_rec.input_currency_code,
        v_entry_rec.output_currency_code,
        v_validation_start_date,
        v_validation_end_date,
        p_session_date,
        v_dt_update_mode,
        p_num_entry_values,
        p_input_value_id_tbl,
        p_entry_value_tbl);
--
     -- Go through list of accepted pay proposals for the assignment /
     -- element entry to see if any of the pay proosals have lost the element
     -- entry they had (the existence of an element entry signifies an accepted
     -- pay proposal) ie. crerator type changed, removed etc... Any accepted
     -- pay proposals that have lost their element entry should be removed.
     loop
--
       fetch csr_accepted_pay_proposals into v_pay_proposal_id;
       exit when csr_accepted_pay_proposals%notfound;
--
       delete from per_pay_proposals pp
       where  pp.pay_proposal_id = v_pay_proposal_id
         and  not exists
              (select null
               from   pay_element_entries_f ee
               where  ee.element_entry_id = p_element_entry_id
                 and  ee.creator_type = 'SP'
                 and  ee.creator_id = pp.pay_proposal_id
                 and  ee.effective_start_date = pp.change_date);
--
     end loop;
--
   end if;
   --
   -- bug 666197, retrieve object version number; call to the user hook procedure
   --
   open csr_object_version_number(p_element_entry_id, p_session_date);
   fetch csr_object_version_number into l_object_version_number, l_effective_start_date,
                                                                 l_effective_end_date;
   close csr_object_version_number;
   --
   begin
   --
   -- Bugfix 2993625
   -- Pass actual values to the after update hook instead of the defaulted
   -- values, i.e. pass null instead of hr_api.g_number, etc.
   -- This is to avoid unnecessary rows being created in PAY_PROCESS_EVENTS
   -- during the continuous calc process.
   --
   pay_ele_rku.after_update
   -- p_validation_start/end_date are not supported until the proper API implementation
     (
       p_effective_date                 => p_session_date
      ,p_validation_start_date          => v_validation_start_date
      ,p_validation_end_date            => v_validation_end_date
      ,p_datetrack_mode                 => v_dt_update_mode             --6144913
      -- new values set
      ,p_element_entry_id               => p_element_entry_id
      ,p_effective_start_date           => l_effective_start_date
      ,p_effective_end_date             => l_effective_end_date
      ,p_original_entry_id              => v_entry_rec.original_entry_id
      ,p_creator_type                   => v_entry_rec.creator_type
      ,p_cost_allocation_keyflex_id   => v_entry_rec.cost_allocation_keyflex_id
      -- Needed for row handler
      ,p_target_entry_id                => null
      ,p_source_id                      => null
      ,p_balance_adj_cost_flag          => null
      ,p_entry_type                     => null
      --
      ,p_updating_action_id             => v_entry_rec.updating_action_id
      ,p_updating_action_type           => v_entry_rec.updating_action_type
      ,p_comment_id                     => v_entry_rec.comment_id
      ,p_creator_id                     => v_entry_rec.creator_id
      ,p_reason                         => v_entry_rec.reason
      ,p_subpriority                    => v_entry_rec.subpriority
      ,p_date_earned                    => v_entry_rec.date_earned
      ,p_personal_payment_method_id   => v_entry_rec.personal_payment_method_id
      ,p_attribute_category             => v_entry_rec.attribute_category
      ,p_attribute1                     => v_entry_rec.attribute1
      ,p_attribute2                     => v_entry_rec.attribute2
      ,p_attribute3                     => v_entry_rec.attribute3
      ,p_attribute4                     => v_entry_rec.attribute4
      ,p_attribute5                     => v_entry_rec.attribute5
      ,p_attribute6                     => v_entry_rec.attribute6
      ,p_attribute7                     => v_entry_rec.attribute7
      ,p_attribute8                     => v_entry_rec.attribute8
      ,p_attribute9                     => v_entry_rec.attribute9
      ,p_attribute10                    => v_entry_rec.attribute10
      ,p_attribute11                    => v_entry_rec.attribute11
      ,p_attribute12                    => v_entry_rec.attribute12
      ,p_attribute13                    => v_entry_rec.attribute13
      ,p_attribute14                    => v_entry_rec.attribute14
      ,p_attribute15                    => v_entry_rec.attribute15
      ,p_attribute16                    => v_entry_rec.attribute16
      ,p_attribute17                    => v_entry_rec.attribute17
      ,p_attribute18                    => v_entry_rec.attribute18
      ,p_attribute19                    => v_entry_rec.attribute19
      ,p_attribute20                    => v_entry_rec.attribute20
      ,p_entry_information_category   => v_entry_rec.entry_information_category
      ,p_entry_information1             => v_entry_rec.entry_information1
      ,p_entry_information2             => v_entry_rec.entry_information2
      ,p_entry_information3             => v_entry_rec.entry_information3
      ,p_entry_information4             => v_entry_rec.entry_information4
      ,p_entry_information5             => v_entry_rec.entry_information5
      ,p_entry_information6             => v_entry_rec.entry_information6
      ,p_entry_information7             => v_entry_rec.entry_information7
      ,p_entry_information8             => v_entry_rec.entry_information8
      ,p_entry_information9             => v_entry_rec.entry_information9
      ,p_entry_information10            => v_entry_rec.entry_information10
      ,p_entry_information11            => v_entry_rec.entry_information11
      ,p_entry_information12            => v_entry_rec.entry_information12
      ,p_entry_information13            => v_entry_rec.entry_information13
      ,p_entry_information14            => v_entry_rec.entry_information14
      ,p_entry_information15            => v_entry_rec.entry_information15
      ,p_entry_information16            => v_entry_rec.entry_information16
      ,p_entry_information17            => v_entry_rec.entry_information17
      ,p_entry_information18            => v_entry_rec.entry_information18
      ,p_entry_information19            => v_entry_rec.entry_information19
      ,p_entry_information20            => v_entry_rec.entry_information20
      ,p_entry_information21            => v_entry_rec.entry_information21
      ,p_entry_information22            => v_entry_rec.entry_information22
      ,p_entry_information23            => v_entry_rec.entry_information23
      ,p_entry_information24            => v_entry_rec.entry_information24
      ,p_entry_information25            => v_entry_rec.entry_information25
      ,p_entry_information26            => v_entry_rec.entry_information26
      ,p_entry_information27            => v_entry_rec.entry_information27
      ,p_entry_information28            => v_entry_rec.entry_information28
      ,p_entry_information29            => v_entry_rec.entry_information29
      ,p_entry_information30            => v_entry_rec.entry_information30
      ,p_object_version_number          => l_object_version_number
      ,p_comments                       => null
      ,p_all_entry_values_null          => l_all_entry_values_null
      -- old values set
      ,p_effective_start_date_o         => l_effective_start_date_o
      ,p_effective_end_date_o           => l_effective_end_date_o
      ,p_cost_allocation_keyflex_id_o   => l_cost_allocation_keyflex_id_o
      ,p_assignment_id_o                => l_assignment_id_o
      ,p_updating_action_id_o         => l_updating_action_id_o
      ,p_updating_action_type_o         => l_updating_action_type_o
      ,p_element_link_id_o              => l_element_link_id_o
      ,p_original_entry_id_o            => l_original_entry_id_o
      ,p_creator_type_o                 => l_creator_type_o
      ,p_entry_type_o                   => l_entry_type_o
      ,p_comment_id_o                   => l_comment_id_o
      ,p_creator_id_o                   => l_creator_id_o
      ,p_reason_o                       => l_reason_o
      ,p_target_entry_id_o              => l_target_entry_id_o
      ,p_source_id_o                    => l_source_id_o
      ,p_attribute_category_o           => l_attribute_category_o
      ,p_attribute1_o                   => l_attribute1_o
      ,p_attribute2_o                   => l_attribute2_o
      ,p_attribute3_o                   => l_attribute3_o
      ,p_attribute4_o                   => l_attribute4_o
      ,p_attribute5_o                   => l_attribute5_o
      ,p_attribute6_o                   => l_attribute6_o
      ,p_attribute7_o                   => l_attribute7_o
      ,p_attribute8_o                   => l_attribute8_o
      ,p_attribute9_o                   => l_attribute9_o
      ,p_attribute10_o                  => l_attribute10_o
      ,p_attribute11_o                  => l_attribute11_o
      ,p_attribute12_o                  => l_attribute12_o
      ,p_attribute13_o                  => l_attribute13_o
      ,p_attribute14_o                  => l_attribute14_o
      ,p_attribute15_o                  => l_attribute15_o
      ,p_attribute16_o                  => l_attribute16_o
      ,p_attribute17_o                  => l_attribute17_o
      ,p_attribute18_o                  => l_attribute18_o
      ,p_attribute19_o                  => l_attribute19_o
      ,p_attribute20_o                  => l_attribute20_o
      ,p_entry_information_category_o   => l_entry_information_category_o
      ,p_entry_information1_o           => l_entry_information1_o
      ,p_entry_information2_o           => l_entry_information2_o
      ,p_entry_information3_o           => l_entry_information3_o
      ,p_entry_information4_o           => l_entry_information4_o
      ,p_entry_information5_o           => l_entry_information5_o
      ,p_entry_information6_o           => l_entry_information6_o
      ,p_entry_information7_o           => l_entry_information7_o
      ,p_entry_information8_o           => l_entry_information8_o
      ,p_entry_information9_o           => l_entry_information9_o
      ,p_entry_information10_o          => l_entry_information10_o
      ,p_entry_information11_o          => l_entry_information11_o
      ,p_entry_information12_o          => l_entry_information12_o
      ,p_entry_information13_o          => l_entry_information13_o
      ,p_entry_information14_o          => l_entry_information14_o
      ,p_entry_information15_o          => l_entry_information15_o
      ,p_entry_information16_o          => l_entry_information16_o
      ,p_entry_information17_o          => l_entry_information17_o
      ,p_entry_information18_o          => l_entry_information18_o
      ,p_entry_information19_o          => l_entry_information19_o
      ,p_entry_information20_o          => l_entry_information20_o
      ,p_entry_information21_o          => l_entry_information21_o
      ,p_entry_information22_o          => l_entry_information22_o
      ,p_entry_information23_o          => l_entry_information23_o
      ,p_entry_information24_o          => l_entry_information24_o
      ,p_entry_information25_o          => l_entry_information25_o
      ,p_entry_information26_o          => l_entry_information26_o
      ,p_entry_information27_o          => l_entry_information27_o
      ,p_entry_information28_o          => l_entry_information28_o
      ,p_entry_information29_o          => l_entry_information29_o
      ,p_entry_information30_o          => l_entry_information30_o
      ,p_subpriority_o                  => l_subpriority_o
      ,p_personal_payment_method_id_o   => l_personal_payment_method_id_o
      ,p_date_earned_o                  => l_date_earned_o
      ,p_object_version_number_o        => l_object_version_number_o
      ,p_balance_adj_cost_flag_o        => l_balance_adj_cost_flag_o
      ,p_comments_o                     => null
      ,p_element_type_id_o              => l_element_type_id_o
      ,p_all_entry_values_null_o        => l_all_entry_values_null_o
     );
     exception
       when hr_api.cannot_find_prog_unit then
         hr_api.cannot_find_prog_unit_error
               (p_module_name => 'PAY_ELEMENT_ENTRIES_F'
               ,p_hook_type   => 'AU'
               );
     end;
    --

  --
  -- 21-FEB-03
  -- -----------------
  -- As entry values has no hook, call the CC DYnamic Trigger PacKaGe directly
  -- I.e. instead of         API -> HOOK -> DYT_PKG -> CC_PKG
  -- we do             pseudoAPI ---------> DYT_PKG -> CC_PKG
  -- -----------------
  --loop through all new element entry vals for this element entry id
  --(usually just the one val)
  --
  -- Only make call if data has possibly changed, and => old vals are cached
  --
  if v_entry_being_changed then

    g_counter := 0;

    for new_vals in pay_ele_shd.csr_get_eevals(p_element_entry_id,p_session_date)  loop
      begin
        g_counter := g_counter + 1;
        --
      if g_debug then
        hr_utility.trace(' Hard call PAY_DYT_ELEMENT_ENTRY_VAL_PKG.after_update');
        hr_utility.trace(' Ele ent Val ID: '||new_vals.element_entry_value_id);
        hr_utility.trace(' New Screen Val: '||new_vals.screen_entry_value);
        hr_utility.trace(' Old Screen Val: '||l_old_val_tab(g_counter).screen_entry_value);
      end if;

        PAY_DYT_ELEMENT_ENTRY_VAL_PKG.after_update
        (
          P_EFFECTIVE_END_DATE          => new_vals.effective_end_date
         ,P_EFFECTIVE_START_DATE        => new_vals.effective_start_date
         ,P_ELEMENT_ENTRY_ID            => new_vals.element_entry_id
         ,P_ELEMENT_ENTRY_VALUE_ID      => new_vals.element_entry_value_id
         ,P_INPUT_VALUE_ID              => new_vals.input_value_id
         ,P_SCREEN_ENTRY_VALUE          => new_vals.screen_entry_value
         ,P_EFFECTIVE_END_DATE_O
           => l_old_val_tab(g_counter).effective_end_date
         ,P_EFFECTIVE_START_DATE_O
           => l_old_val_tab(g_counter).effective_start_date
         ,P_ELEMENT_ENTRY_ID_O
           => l_old_val_tab(g_counter).element_entry_id
         ,P_ELEMENT_ENTRY_VALUE_ID_O
           => l_old_val_tab(g_counter).element_entry_value_id
         ,P_INPUT_VALUE_ID_O
           => l_old_val_tab(g_counter).input_value_id
         ,P_SCREEN_ENTRY_VALUE_O
           => l_old_val_tab(g_counter).screen_entry_value
         ,p_datetrack_mode              => v_dt_update_mode       --6144913
       );

      end;
      --
    end loop;
  end if;
  hr_utility.set_location('Leaving: upd_element_entry', 900);

 end upd_element_entry;
--







 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry_api.update_element_entry                                        --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Cover routine for call to hr_entry_api.upd_element_entry that accepts    --
 -- entry values passed as a table. It converts the entry values to DB       --
 -- format. Any entry values that were not specified are copied from the     --
 -- element entry being updated.                                             --
 -- NB. all entry values specified are validated !                           --
 ------------------------------------------------------------------------------
--
 procedure update_element_entry
 (
  --
  -- Update Mode
  --
  p_dt_update_mode             varchar2 default null,
  --
  -- Date on which change is taking place
  --
  p_session_date               date,
  --
  -- Check to see if the entry is being updated
  --
  p_check_for_update           varchar2  default 'N',
  --
  -- Element Entry Table
  --
  p_element_entry_id           number,
  p_cost_allocation_keyflex_id number    default hr_api.g_number,
  p_updating_action_id         number    default hr_api.g_number,
  p_updating_action_type       varchar2  default hr_api.g_varchar2,
  p_original_entry_id          number    default hr_api.g_number,
  p_creator_type               varchar2  default hr_api.g_varchar2,
  p_comment_id                 number    default hr_api.g_number,
  p_creator_id                 number    default hr_api.g_number,
  p_reason                     varchar2  default hr_api.g_varchar2,
  p_subpriority                number    default hr_api.g_number,
  p_date_earned                 date    default hr_api.g_date,
  p_personal_payment_method_id  number  default hr_api.g_number,
  p_attribute_category         varchar2  default hr_api.g_varchar2,
  p_attribute1                 varchar2  default hr_api.g_varchar2,
  p_attribute2                 varchar2  default hr_api.g_varchar2,
  p_attribute3                 varchar2  default hr_api.g_varchar2,
  p_attribute4                 varchar2  default hr_api.g_varchar2,
  p_attribute5                 varchar2  default hr_api.g_varchar2,
  p_attribute6                 varchar2  default hr_api.g_varchar2,
  p_attribute7                 varchar2  default hr_api.g_varchar2,
  p_attribute8                 varchar2  default hr_api.g_varchar2,
  p_attribute9                 varchar2  default hr_api.g_varchar2,
  p_attribute10                varchar2  default hr_api.g_varchar2,
  p_attribute11                varchar2  default hr_api.g_varchar2,
  p_attribute12                varchar2  default hr_api.g_varchar2,
  p_attribute13                varchar2  default hr_api.g_varchar2,
  p_attribute14                varchar2  default hr_api.g_varchar2,
  p_attribute15                varchar2  default hr_api.g_varchar2,
  p_attribute16                varchar2  default hr_api.g_varchar2,
  p_attribute17                varchar2  default hr_api.g_varchar2,
  p_attribute18                varchar2  default hr_api.g_varchar2,
  p_attribute19                varchar2  default hr_api.g_varchar2,
  p_attribute20                varchar2  default hr_api.g_varchar2,
  p_override_user_ent_chk      varchar2  default 'N',
  --
  -- Element Entry Values Table
  --
  p_num_entry_values           number,
  p_input_value_id_tbl         hr_entry.number_table,
  p_entry_value_tbl            hr_entry.varchar2_table
 ) is
--
   -- Local Variables
   v_num_entry_values   number;
   v_input_value_id_tbl hr_entry.number_table;
   v_entry_value_tbl    hr_entry.varchar2_table;
   l_entry_type         VARCHAR2(1);
   v_assignment_id      number;
   --
   -- Local Cursors
   --
   --
   -- bug 546670
   --
   CURSOR csr_entry_type(p_element_entry_id NUMBER,
                         p_effective_date   DATE)
   IS
     SELECT pee.entry_type,
            pee.assignment_id
     FROM   PAY_ELEMENT_ENTRIES_F pee
     WHERE  pee.element_entry_id = p_element_entry_id
     and    p_effective_date BETWEEN
                pee.effective_start_date and pee.effective_end_date
     ;
--
 begin
   g_debug := hr_utility.debug_enabled;
--
   g_override_user_ent_chk := p_override_user_ent_chk;
   v_num_entry_values   := p_num_entry_values;
   v_input_value_id_tbl := p_input_value_id_tbl;
   v_entry_value_tbl    := p_entry_value_tbl;
--
   OPEN  csr_entry_type(p_element_entry_id, p_session_date);
   FETCH csr_entry_type INTO l_entry_type, v_assignment_id;
   CLOSE csr_entry_type;
   --
   -- Call code to set up values that may be used in
   -- Formula validation of Input Values.
   --
   set_formula_contexts (v_assignment_id, p_session_date);
--
   hr_entry_api.conv_table_to_table
     ('SCREEN',
      p_session_date,
      p_element_entry_id,
      null,
      v_num_entry_values,
      p_creator_type,
      l_entry_type,
      v_input_value_id_tbl,
      v_entry_value_tbl);
--
   hr_entry_api.upd_element_entry
     (p_dt_update_mode,
      p_session_date,
      p_check_for_update,
      p_element_entry_id,
      p_cost_allocation_keyflex_id,
      p_updating_action_id,
      p_updating_action_type,
      p_original_entry_id,
      p_creator_type,
      p_comment_id,
      p_creator_id,
      p_reason,
      p_subpriority,
      p_date_earned,
      p_personal_payment_method_id,
      p_attribute_category,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      p_attribute16,
      p_attribute17,
      p_attribute18,
      p_attribute19,
      p_attribute20,
      v_num_entry_values,
      v_input_value_id_tbl,
      v_entry_value_tbl,
-- --
    --
    -- J.Bailie 08-NOV-99 31 nulls passed to ins_element_entry
    --
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null
);
--
 end update_element_entry;
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry_api.update_element_entry                                        --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Cover routine for call to hr_entry_api.upd_element_entry that accepts    --
 -- entry values passed as parameters. It converts the entry values to DB    --
 -- format. Any entry values that were not specified are copied from the     --
 -- element entry being updated.                                             --
 -- NB. all entry values specified are validated !                           --
 ------------------------------------------------------------------------------
--
 procedure update_element_entry
 (
  --
  -- Update Mode
  --
  p_dt_update_mode             varchar2 default null,
  --
  -- Date on which change is taking place
  --
  p_session_date               date,
  --
  -- Check to see if the entry is being updated
  --
  p_check_for_update           varchar2  default 'N',
  --
  -- Element Entry Table
  --
  p_element_entry_id           number,
  p_cost_allocation_keyflex_id number    default hr_api.g_number,
  p_updating_action_id         number    default hr_api.g_number,
  p_updating_action_type       varchar2  default hr_api.g_varchar2,
  p_original_entry_id          number    default hr_api.g_number,
  p_creator_type               varchar2  default hr_api.g_varchar2,
  p_comment_id                 number    default hr_api.g_number,
  p_creator_id                 number    default hr_api.g_number,
  p_reason                     varchar2  default hr_api.g_varchar2,
  p_subpriority                number    default hr_api.g_number,
  p_date_earned                date      default hr_api.g_date,
  p_personal_payment_method_id number    default hr_api.g_number,
  p_attribute_category         varchar2  default hr_api.g_varchar2,
  p_attribute1                 varchar2  default hr_api.g_varchar2,
  p_attribute2                 varchar2  default hr_api.g_varchar2,
  p_attribute3                 varchar2  default hr_api.g_varchar2,
  p_attribute4                 varchar2  default hr_api.g_varchar2,
  p_attribute5                 varchar2  default hr_api.g_varchar2,
  p_attribute6                 varchar2  default hr_api.g_varchar2,
  p_attribute7                 varchar2  default hr_api.g_varchar2,
  p_attribute8                 varchar2  default hr_api.g_varchar2,
  p_attribute9                 varchar2  default hr_api.g_varchar2,
  p_attribute10                varchar2  default hr_api.g_varchar2,
  p_attribute11                varchar2  default hr_api.g_varchar2,
  p_attribute12                varchar2  default hr_api.g_varchar2,
  p_attribute13                varchar2  default hr_api.g_varchar2,
  p_attribute14                varchar2  default hr_api.g_varchar2,
  p_attribute15                varchar2  default hr_api.g_varchar2,
  p_attribute16                varchar2  default hr_api.g_varchar2,
  p_attribute17                varchar2  default hr_api.g_varchar2,
  p_attribute18                varchar2  default hr_api.g_varchar2,
  p_attribute19                varchar2  default hr_api.g_varchar2,
  p_attribute20                varchar2  default hr_api.g_varchar2,
  --
  -- Element Entry Values Table
  --
  p_input_value_id1            number   default null,
  p_input_value_id2            number   default null,
  p_input_value_id3            number   default null,
  p_input_value_id4            number   default null,
  p_input_value_id5            number   default null,
  p_input_value_id6            number   default null,
  p_input_value_id7            number   default null,
  p_input_value_id8            number   default null,
  p_input_value_id9            number   default null,
  p_input_value_id10           number   default null,
  p_input_value_id11           number   default null,
  p_input_value_id12           number   default null,
  p_input_value_id13           number   default null,
  p_input_value_id14           number   default null,
  p_input_value_id15           number   default null,
  p_entry_value1               varchar2 default null,
  p_entry_value2               varchar2 default null,
  p_entry_value3               varchar2 default null,
  p_entry_value4               varchar2 default null,
  p_entry_value5               varchar2 default null,
  p_entry_value6               varchar2 default null,
  p_entry_value7               varchar2 default null,
  p_entry_value8               varchar2 default null,
  p_entry_value9               varchar2 default null,
  p_entry_value10              varchar2 default null,
  p_entry_value11              varchar2 default null,
  p_entry_value12              varchar2 default null,
  p_entry_value13              varchar2 default null,
  p_entry_value14              varchar2 default null,
  p_entry_value15              varchar2 default null,
  p_override_user_ent_chk      varchar2  default 'N'
 ) is
--
   -- Local Variables
   v_num_entry_values   number;
   v_input_value_id_tbl hr_entry.number_table;
   v_entry_value_tbl    hr_entry.varchar2_table;
   l_entry_type         VARCHAR2(1);
   v_assignment_id      number;
   --
   -- Local Cursors
   --
   --
   -- bug 546670
   --
   CURSOR csr_entry_type(p_element_entry_id NUMBER,
                         p_effective_date   DATE)
   IS
     SELECT pee.entry_type,
            pee.assignment_id
     FROM   PAY_ELEMENT_ENTRIES_F pee
     WHERE  pee.element_entry_id = p_element_entry_id
     and    p_effective_date BETWEEN
                pee.effective_start_date and pee.effective_end_date
     ;
--
 begin
   g_debug := hr_utility.debug_enabled;
--
   OPEN  csr_entry_type(p_element_entry_id, p_session_date);
   FETCH csr_entry_type INTO l_entry_type, v_assignment_id;
   CLOSE csr_entry_type;
   g_override_user_ent_chk := p_override_user_ent_chk;
   --
   -- Call code to set up values that may be used in
   -- Formula validation of Input Values.
   --
   set_formula_contexts (v_assignment_id, p_session_date);
   --
   -- Convert entry value details ie. INPUT_VALUE_ID and SCREEN_ENTRY_VALUE
   -- into two tables to be passed into the overloaded version of
   -- update_element_entry. The overloaded version is capable of handling
   -- unlimited numbers of entry values.
   hr_entry_api.conv_entry_values_to_table
     ('SCREEN',
      p_element_entry_id,
      null,
      p_session_date,
      p_creator_type,
      l_entry_type,
      p_input_value_id1,
      p_input_value_id2,
      p_input_value_id3,
      p_input_value_id4,
      p_input_value_id5,
      p_input_value_id6,
      p_input_value_id7,
      p_input_value_id8,
      p_input_value_id9,
      p_input_value_id10,
      p_input_value_id11,
      p_input_value_id12,
      p_input_value_id13,
      p_input_value_id14,
      p_input_value_id15,
      p_entry_value1,
      p_entry_value2,
      p_entry_value3,
      p_entry_value4,
      p_entry_value5,
      p_entry_value6,
      p_entry_value7,
      p_entry_value8,
      p_entry_value9,
      p_entry_value10,
      p_entry_value11,
      p_entry_value12,
      p_entry_value13,
      p_entry_value14,
      p_entry_value15,
      v_num_entry_values,
      v_input_value_id_tbl,
      v_entry_value_tbl);
--
   hr_entry_api.upd_element_entry
     (p_dt_update_mode,
      p_session_date,
      p_check_for_update,
      p_element_entry_id,
      p_cost_allocation_keyflex_id,
      p_updating_action_id,
      p_updating_action_type,
      p_original_entry_id,
      p_creator_type,
      p_comment_id,
      p_creator_id,
      p_reason,
      p_subpriority,
      p_date_earned,
      p_personal_payment_method_id,
      p_attribute_category,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      p_attribute16,
      p_attribute17,
      p_attribute18,
      p_attribute19,
      p_attribute20,
      v_num_entry_values,
      v_input_value_id_tbl,
      v_entry_value_tbl,
-- --
    --
    -- J.Bailie 08-NOV-99 31 nulls passed to ins_element_entry
    --
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null
);
--
 end update_element_entry;
--
-- --
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry_api.update_element_entry                                        --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Cover routine for call to hr_entry_api.upd_element_entry that accepts    --
 -- entry values passed as a table. It converts the entry values to DB       --
 -- format. Any entry values that were not specified are copied from the     --
 -- element entry being updated.                                             --
 -- NB. all entry values specified are validated !                           --
 ------------------------------------------------------------------------------
--
 procedure update_element_entry
 (
  --
  -- Update Mode
  --
  p_dt_update_mode             varchar2 default null,
  --
  -- Date on which change is taking place
  --
  p_session_date               date,
  --
  -- Check to see if the entry is being updated
  --
  p_check_for_update           varchar2  default 'N',
  --
  -- Element Entry Table
  --
  p_element_entry_id           number,
  p_cost_allocation_keyflex_id number    default hr_api.g_number,
  p_updating_action_id         number    default hr_api.g_number,
  p_updating_action_type       varchar2  default hr_api.g_varchar2,
  p_original_entry_id          number    default hr_api.g_number,
  p_creator_type               varchar2  default hr_api.g_varchar2,
  p_comment_id                 number    default hr_api.g_number,
  p_creator_id                 number    default hr_api.g_number,
  p_reason                     varchar2  default hr_api.g_varchar2,
  p_subpriority                number    default hr_api.g_number,
  p_date_earned                 date    default hr_api.g_date,
  p_personal_payment_method_id  number  default hr_api.g_number,
  p_attribute_category         varchar2  default hr_api.g_varchar2,
  p_attribute1                 varchar2  default hr_api.g_varchar2,
  p_attribute2                 varchar2  default hr_api.g_varchar2,
  p_attribute3                 varchar2  default hr_api.g_varchar2,
  p_attribute4                 varchar2  default hr_api.g_varchar2,
  p_attribute5                 varchar2  default hr_api.g_varchar2,
  p_attribute6                 varchar2  default hr_api.g_varchar2,
  p_attribute7                 varchar2  default hr_api.g_varchar2,
  p_attribute8                 varchar2  default hr_api.g_varchar2,
  p_attribute9                 varchar2  default hr_api.g_varchar2,
  p_attribute10                varchar2  default hr_api.g_varchar2,
  p_attribute11                varchar2  default hr_api.g_varchar2,
  p_attribute12                varchar2  default hr_api.g_varchar2,
  p_attribute13                varchar2  default hr_api.g_varchar2,
  p_attribute14                varchar2  default hr_api.g_varchar2,
  p_attribute15                varchar2  default hr_api.g_varchar2,
  p_attribute16                varchar2  default hr_api.g_varchar2,
  p_attribute17                varchar2  default hr_api.g_varchar2,
  p_attribute18                varchar2  default hr_api.g_varchar2,
  p_attribute19                varchar2  default hr_api.g_varchar2,
  p_attribute20                varchar2  default hr_api.g_varchar2,
  --
  -- Element Entry Values Table
  --
  p_num_entry_values           number,
  p_input_value_id_tbl         hr_entry.number_table,
  p_entry_value_tbl            hr_entry.varchar2_table,
  p_entry_information_category varchar2  ,
  p_entry_information1         varchar2  default hr_api.g_varchar2,
  p_entry_information2         varchar2  default hr_api.g_varchar2,
  p_entry_information3         varchar2  default hr_api.g_varchar2,
  p_entry_information4         varchar2  default hr_api.g_varchar2,
  p_entry_information5         varchar2  default hr_api.g_varchar2,
  p_entry_information6         varchar2  default hr_api.g_varchar2,
  p_entry_information7         varchar2  default hr_api.g_varchar2,
  p_entry_information8         varchar2  default hr_api.g_varchar2,
  p_entry_information9         varchar2  default hr_api.g_varchar2,
  p_entry_information10        varchar2  default hr_api.g_varchar2,
  p_entry_information11        varchar2  default hr_api.g_varchar2,
  p_entry_information12        varchar2  default hr_api.g_varchar2,
  p_entry_information13        varchar2  default hr_api.g_varchar2,
  p_entry_information14        varchar2  default hr_api.g_varchar2,
  p_entry_information15        varchar2  default hr_api.g_varchar2,
  p_entry_information16        varchar2  default hr_api.g_varchar2,
  p_entry_information17        varchar2  default hr_api.g_varchar2,
  p_entry_information18        varchar2  default hr_api.g_varchar2,
  p_entry_information19        varchar2  default hr_api.g_varchar2,
  p_entry_information20        varchar2  default hr_api.g_varchar2,
  p_entry_information21        varchar2  default hr_api.g_varchar2,
  p_entry_information22        varchar2  default hr_api.g_varchar2,
  p_entry_information23        varchar2  default hr_api.g_varchar2,
  p_entry_information24        varchar2  default hr_api.g_varchar2,
  p_entry_information25        varchar2  default hr_api.g_varchar2,
  p_entry_information26        varchar2  default hr_api.g_varchar2,
  p_entry_information27        varchar2  default hr_api.g_varchar2,
  p_entry_information28        varchar2  default hr_api.g_varchar2,
  p_entry_information29        varchar2  default hr_api.g_varchar2,
  p_entry_information30        varchar2  default hr_api.g_varchar2,
  p_override_user_ent_chk      varchar2  default 'N'
 ) is
--
   -- Local Variables
   v_num_entry_values   number;
   v_input_value_id_tbl hr_entry.number_table;
   v_entry_value_tbl    hr_entry.varchar2_table;
   l_entry_type         VARCHAR2(1);
   v_assignment_id      number;
   --
   -- Local Cursors
   --
   --
   -- bug 546670
   --
   CURSOR csr_entry_type(p_element_entry_id NUMBER,
                         p_effective_date   DATE)
   IS
     SELECT pee.entry_type,
            pee.assignment_id
     FROM   PAY_ELEMENT_ENTRIES_F pee
     WHERE  pee.element_entry_id = p_element_entry_id
     and    p_effective_date BETWEEN
                pee.effective_start_date and pee.effective_end_date
     ;
--
 begin
   g_debug := hr_utility.debug_enabled;
--
   g_override_user_ent_chk := p_override_user_ent_chk;
   v_num_entry_values   := p_num_entry_values;
   v_input_value_id_tbl := p_input_value_id_tbl;
   v_entry_value_tbl    := p_entry_value_tbl;
--
   OPEN  csr_entry_type(p_element_entry_id, p_session_date);
   FETCH csr_entry_type INTO l_entry_type, v_assignment_id;
   CLOSE csr_entry_type;
   --
   -- Call code to set up values that may be used in
   -- Formula validation of Input Values.
   --
   set_formula_contexts (v_assignment_id, p_session_date);
--
   hr_entry_api.conv_table_to_table
     ('SCREEN',
      p_session_date,
      p_element_entry_id,
      null,
      v_num_entry_values,
      p_creator_type,
      l_entry_type,
      v_input_value_id_tbl,
      v_entry_value_tbl);
--
   hr_entry_api.upd_element_entry
     (p_dt_update_mode,
      p_session_date,
      p_check_for_update,
      p_element_entry_id,
      p_cost_allocation_keyflex_id,
      p_updating_action_id,
      p_updating_action_type,
      p_original_entry_id,
      p_creator_type,
      p_comment_id,
      p_creator_id,
      p_reason,
      p_subpriority,
      p_date_earned,
      p_personal_payment_method_id,
      p_attribute_category,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      p_attribute16,
      p_attribute17,
      p_attribute18,
      p_attribute19,
      p_attribute20,
      v_num_entry_values,
      v_input_value_id_tbl,
      v_entry_value_tbl,
  --
  -- J.Bailie 08-NOV-99 Element Entries DDF
  --
    p_entry_information_category,
    p_entry_information1,
    p_entry_information2,
    p_entry_information3,
    p_entry_information4,
    p_entry_information5,
    p_entry_information6,
    p_entry_information7,
    p_entry_information8,
    p_entry_information9,
    p_entry_information10,
    p_entry_information11,
    p_entry_information12,
    p_entry_information13,
    p_entry_information14,
    p_entry_information15,
    p_entry_information16,
    p_entry_information17,
    p_entry_information18,
    p_entry_information19,
    p_entry_information20,
    p_entry_information21,
    p_entry_information22,
    p_entry_information23,
    p_entry_information24,
    p_entry_information25,
    p_entry_information26,
    p_entry_information27,
    p_entry_information28,
    p_entry_information29,
    p_entry_information30
   );
--
 end update_element_entry;
--
-- --
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry_api.update_element_entry                                        --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Cover routine for call to hr_entry_api.upd_element_entry that accepts    --
 -- entry values passed as parameters. It converts the entry values to DB    --
 -- format. Any entry values that were not specified are copied from the     --
 -- element entry being updated.                                             --
 -- NB. all entry values specified are validated !                           --
 ------------------------------------------------------------------------------
--
 procedure update_element_entry
 (
  --
  -- Update Mode
  --
  p_dt_update_mode             varchar2 default null,
  --
  -- Date on which change is taking place
  --
  p_session_date               date,
  --
  -- Check to see if the entry is being updated
  --
  p_check_for_update           varchar2  default 'N',
  --
  -- Element Entry Table
  --
  p_element_entry_id           number,
  p_cost_allocation_keyflex_id number    default hr_api.g_number,
  p_updating_action_id         number    default hr_api.g_number,
  p_updating_action_type       varchar2  default hr_api.g_varchar2,
  p_original_entry_id          number    default hr_api.g_number,
  p_creator_type               varchar2  default hr_api.g_varchar2,
  p_comment_id                 number    default hr_api.g_number,
  p_creator_id                 number    default hr_api.g_number,
  p_reason                     varchar2  default hr_api.g_varchar2,
  p_subpriority                number    default hr_api.g_number,
  p_date_earned                date      default hr_api.g_date,
  p_personal_payment_method_id number    default hr_api.g_number,
  p_attribute_category         varchar2  default hr_api.g_varchar2,
  p_attribute1                 varchar2  default hr_api.g_varchar2,
  p_attribute2                 varchar2  default hr_api.g_varchar2,
  p_attribute3                 varchar2  default hr_api.g_varchar2,
  p_attribute4                 varchar2  default hr_api.g_varchar2,
  p_attribute5                 varchar2  default hr_api.g_varchar2,
  p_attribute6                 varchar2  default hr_api.g_varchar2,
  p_attribute7                 varchar2  default hr_api.g_varchar2,
  p_attribute8                 varchar2  default hr_api.g_varchar2,
  p_attribute9                 varchar2  default hr_api.g_varchar2,
  p_attribute10                varchar2  default hr_api.g_varchar2,
  p_attribute11                varchar2  default hr_api.g_varchar2,
  p_attribute12                varchar2  default hr_api.g_varchar2,
  p_attribute13                varchar2  default hr_api.g_varchar2,
  p_attribute14                varchar2  default hr_api.g_varchar2,
  p_attribute15                varchar2  default hr_api.g_varchar2,
  p_attribute16                varchar2  default hr_api.g_varchar2,
  p_attribute17                varchar2  default hr_api.g_varchar2,
  p_attribute18                varchar2  default hr_api.g_varchar2,
  p_attribute19                varchar2  default hr_api.g_varchar2,
  p_attribute20                varchar2  default hr_api.g_varchar2,
  --
  -- Element Entry Values Table
  --
  p_input_value_id1            number   default null,
  p_input_value_id2            number   default null,
  p_input_value_id3            number   default null,
  p_input_value_id4            number   default null,
  p_input_value_id5            number   default null,
  p_input_value_id6            number   default null,
  p_input_value_id7            number   default null,
  p_input_value_id8            number   default null,
  p_input_value_id9            number   default null,
  p_input_value_id10           number   default null,
  p_input_value_id11           number   default null,
  p_input_value_id12           number   default null,
  p_input_value_id13           number   default null,
  p_input_value_id14           number   default null,
  p_input_value_id15           number   default null,
  p_entry_value1               varchar2 default null,
  p_entry_value2               varchar2 default null,
  p_entry_value3               varchar2 default null,
  p_entry_value4               varchar2 default null,
  p_entry_value5               varchar2 default null,
  p_entry_value6               varchar2 default null,
  p_entry_value7               varchar2 default null,
  p_entry_value8               varchar2 default null,
  p_entry_value9               varchar2 default null,
  p_entry_value10              varchar2 default null,
  p_entry_value11              varchar2 default null,
  p_entry_value12              varchar2 default null,
  p_entry_value13              varchar2 default null,
  p_entry_value14              varchar2 default null,
  p_entry_value15              varchar2 default null,
  p_entry_information_category varchar2  ,
  p_entry_information1         varchar2  default hr_api.g_varchar2,
  p_entry_information2         varchar2  default hr_api.g_varchar2,
  p_entry_information3         varchar2  default hr_api.g_varchar2,
  p_entry_information4         varchar2  default hr_api.g_varchar2,
  p_entry_information5         varchar2  default hr_api.g_varchar2,
  p_entry_information6         varchar2  default hr_api.g_varchar2,
  p_entry_information7         varchar2  default hr_api.g_varchar2,
  p_entry_information8         varchar2  default hr_api.g_varchar2,
  p_entry_information9         varchar2  default hr_api.g_varchar2,
  p_entry_information10        varchar2  default hr_api.g_varchar2,
  p_entry_information11        varchar2  default hr_api.g_varchar2,
  p_entry_information12        varchar2  default hr_api.g_varchar2,
  p_entry_information13        varchar2  default hr_api.g_varchar2,
  p_entry_information14        varchar2  default hr_api.g_varchar2,
  p_entry_information15        varchar2  default hr_api.g_varchar2,
  p_entry_information16        varchar2  default hr_api.g_varchar2,
  p_entry_information17        varchar2  default hr_api.g_varchar2,
  p_entry_information18        varchar2  default hr_api.g_varchar2,
  p_entry_information19        varchar2  default hr_api.g_varchar2,
  p_entry_information20        varchar2  default hr_api.g_varchar2,
  p_entry_information21        varchar2  default hr_api.g_varchar2,
  p_entry_information22        varchar2  default hr_api.g_varchar2,
  p_entry_information23        varchar2  default hr_api.g_varchar2,
  p_entry_information24        varchar2  default hr_api.g_varchar2,
  p_entry_information25        varchar2  default hr_api.g_varchar2,
  p_entry_information26        varchar2  default hr_api.g_varchar2,
  p_entry_information27        varchar2  default hr_api.g_varchar2,
  p_entry_information28        varchar2  default hr_api.g_varchar2,
  p_entry_information29        varchar2  default hr_api.g_varchar2,
  p_entry_information30        varchar2  default hr_api.g_varchar2,
  p_override_user_ent_chk      varchar2  default 'N'
 ) is
--
   -- Local Variables
   v_num_entry_values   number;
   v_input_value_id_tbl hr_entry.number_table;
   v_entry_value_tbl    hr_entry.varchar2_table;
   l_entry_type         VARCHAR2(1);
   v_assignment_id      number;
   --
   -- Local Cursors
   --
   --
   -- bug 546670
   --
   CURSOR csr_entry_type(p_element_entry_id NUMBER,
                         p_effective_date   DATE)
   IS
     SELECT pee.entry_type,
            pee.assignment_id
     FROM   PAY_ELEMENT_ENTRIES_F pee
     WHERE  pee.element_entry_id = p_element_entry_id
     and    p_effective_date BETWEEN
                pee.effective_start_date and pee.effective_end_date
     ;
--
 begin
   g_debug := hr_utility.debug_enabled;
--
   OPEN  csr_entry_type(p_element_entry_id, p_session_date);
   FETCH csr_entry_type INTO l_entry_type, v_assignment_id;
   CLOSE csr_entry_type;
   g_override_user_ent_chk := p_override_user_ent_chk;
   --
   -- Call code to set up values that may be used in
   -- Formula validation of Input Values.
   --
   set_formula_contexts (v_assignment_id, p_session_date);
   --
   -- Convert entry value details ie. INPUT_VALUE_ID and SCREEN_ENTRY_VALUE
   -- into two tables to be passed into the overloaded version of
   -- update_element_entry. The overloaded version is capable of handling
   -- unlimited numbers of entry values.
   hr_entry_api.conv_entry_values_to_table
     ('SCREEN',
      p_element_entry_id,
      null,
      p_session_date,
      p_creator_type,
      l_entry_type,
      p_input_value_id1,
      p_input_value_id2,
      p_input_value_id3,
      p_input_value_id4,
      p_input_value_id5,
      p_input_value_id6,
      p_input_value_id7,
      p_input_value_id8,
      p_input_value_id9,
      p_input_value_id10,
      p_input_value_id11,
      p_input_value_id12,
      p_input_value_id13,
      p_input_value_id14,
      p_input_value_id15,
      p_entry_value1,
      p_entry_value2,
      p_entry_value3,
      p_entry_value4,
      p_entry_value5,
      p_entry_value6,
      p_entry_value7,
      p_entry_value8,
      p_entry_value9,
      p_entry_value10,
      p_entry_value11,
      p_entry_value12,
      p_entry_value13,
      p_entry_value14,
      p_entry_value15,
      v_num_entry_values,
      v_input_value_id_tbl,
      v_entry_value_tbl);
--
   hr_entry_api.upd_element_entry
     (p_dt_update_mode,
      p_session_date,
      p_check_for_update,
      p_element_entry_id,
      p_cost_allocation_keyflex_id,
      p_updating_action_id,
      p_updating_action_type,
      p_original_entry_id,
      p_creator_type,
      p_comment_id,
      p_creator_id,
      p_reason,
      p_subpriority,
      p_date_earned,
      p_personal_payment_method_id,
      p_attribute_category,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      p_attribute16,
      p_attribute17,
      p_attribute18,
      p_attribute19,
      p_attribute20,
      v_num_entry_values,
      v_input_value_id_tbl,
      v_entry_value_tbl,
  --
  -- J.Bailie 08-NOV-99 Element Entries DDF
  --
    p_entry_information_category,
    p_entry_information1,
    p_entry_information2,
    p_entry_information3,
    p_entry_information4,
    p_entry_information5,
    p_entry_information6,
    p_entry_information7,
    p_entry_information8,
    p_entry_information9,
    p_entry_information10,
    p_entry_information11,
    p_entry_information12,
    p_entry_information13,
    p_entry_information14,
    p_entry_information15,
    p_entry_information16,
    p_entry_information17,
    p_entry_information18,
    p_entry_information19,
    p_entry_information20,
    p_entry_information21,
    p_entry_information22,
    p_entry_information23,
    p_entry_information24,
    p_entry_information25,
    p_entry_information26,
    p_entry_information27,
    p_entry_information28,
    p_entry_information29,
    p_entry_information30
   );
--
 end update_element_entry;
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry_api.del_ele_entry_param_val                                     --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Validates the parameters passed to hr_entry_api.delete_element_entry.    --
 ------------------------------------------------------------------------------
 function del_ele_entry_param_val
 (
  p_dt_delete_mode   in out nocopy varchar2,
  p_session_date     date,
  p_element_entry_id number,
  p_assignment_id    number,
  p_entry_rec        out nocopy hr_entry_api.t_delete_entry_rec
 ) return boolean is
   --
   -- Local Variables
   --
   l_processed   varchar2(1) := 'N';
   v_entry_rec hr_entry_api.t_delete_entry_rec;

   --Added for bug:6809717
   l_assign_exist number:=0;
   l_before_ovm number;
   l_after_ovm number;
   --
   -- Bugfix 4308892
   -- Function to return the final process date for an assignment
   function final_process_date
   (
    p_assignment_id number,
    p_session_date date
   ) return date
   is
     --
     cursor csr_final_process_date (p_assignment_id number, p_session_date date) is
     select pos.final_process_date
     from per_periods_of_service pos,
          per_all_assignments_f asg
     where asg.assignment_id = p_assignment_id
     /* Added one more condition(PERIOD_OF_SERVICE_ID) for bug no: 6739960*/
     and   pos.PERIOD_OF_SERVICE_ID=asg.PERIOD_OF_SERVICE_ID
     and   asg.person_id = pos.person_id
     and   p_session_date between asg.effective_start_date
                          and asg.effective_end_date;
     --
     l_final_process_date date;
     --
   begin
     --
     open csr_final_process_date (p_assignment_id, p_session_date);
     fetch csr_final_process_date into l_final_process_date;
     close csr_final_process_date;
     --
     return l_final_process_date;
     --
   end final_process_date;
   --
 begin
   --
   -- Retrieve details about element entry being deleted.
   --
   begin
     select ee.original_entry_id,
            ee.effective_start_date,
            ee.effective_end_date,
            ee.assignment_id,
            ee.element_link_id,
            ee.entry_type,
            ee.creator_type,
            ee.creator_id,
            ee.target_entry_id,
            et.element_type_id,
            et.processing_type,
            nvl(ec.non_payments_flag, 'N'),
            ee.personal_payment_method_id
     into   v_entry_rec
     from   pay_element_entries_f ee,
            pay_element_links_f el,
            pay_element_types_f et,
            pay_element_classifications ec
     where  ee.element_entry_id = p_element_entry_id
       and  el.element_link_id = ee.element_link_id
       and  et.element_type_id = el.element_type_id
       and  ec.classification_id = et.classification_id
       and  p_session_date between ee.effective_start_date
                               and ee.effective_end_date
       and  p_session_date between el.effective_start_date
                               and el.effective_end_date
       and  p_session_date between et.effective_start_date
                               and et.effective_end_date;
   exception
     when no_data_found then
       hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE',
                                    'hr_entry_api.delete_element_entry');
       hr_utility.set_message_token('STEP','1');
       hr_utility.raise_error;
     when too_many_rows then
       hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE',
                                    'hr_entry_api.delete_element_entry');
       hr_utility.set_message_token('STEP','2');
       hr_utility.raise_error;
   end;
   --
   p_entry_rec := v_entry_rec;
   --
   -- Nonrecurring entries can only be deleted ie. a nonrecurring entry is
   -- always represented by one row.
   --
   if (v_entry_rec.processing_type = 'N' and v_entry_rec.entry_type = 'E') or
       v_entry_rec.entry_type <> 'E' then
     --
--
     declare
        adjust_ee_source varchar2(1);
     begin
       -- Set the value for ADJUSTMENT_EE_SOURCE.
       -- NOTE: this assumes that the set_formula_contexts procedure has
       -- been called previously.
       adjust_ee_source := g_asg_info.adj_ee_source;
--
       begin
/*
         select  'Y'
         into l_processed
         from    pay_run_results
         where   source_id       = p_element_entry_id
         and     source_type    in ('E', 'I')
         and     status          <> 'U';
*/
-- start of change 115.21 --
        SELECT  'Y'
        INTO    l_processed
        FROM    DUAL
        WHERE EXISTS
            (SELECT null
             FROM   PAY_RUN_RESULTS
             WHERE  source_id =  decode(v_entry_rec.entry_type,
                                          'A', decode (adjust_ee_source,
                                                       'T', v_entry_rec.target_entry_id,
                                                       p_element_entry_id),
                                          'R', decode (adjust_ee_source,
                                                       'T', v_entry_rec.target_entry_id,
                                                       p_element_entry_id),
                                          p_element_entry_id)
             and    entry_type = v_entry_rec.entry_type
             and    source_type in ('E', 'I')
             and    status <> 'U'
            )
        ;
  -- end of change 115.21 --
       exception
        when no_data_found then
            null;
       end;
     end;
--Bug 6809717
--Added to stop deletion of non recurring element entries in case of assignment status change.
 select nvl(count(*),0) into l_assign_exist
 from per_all_assignments_f paaf,per_assignment_status_types past
 where paaf.ASSIGNMENT_ID=p_assignment_id
 and p_session_date+1 between paaf.EFFECTIVE_START_DATE and paaf.EFFECTIVE_END_DATE
 and paaf.ASSIGNMENT_STATUS_TYPE_ID=past.ASSIGNMENT_STATUS_TYPE_ID
 and past.per_system_status='ACTIVE_ASSIGN';

if l_assign_exist>0 then
	select nvl(count(*),0) into l_before_ovm
	from per_all_assignments_f
	where ASSIGNMENT_ID=p_assignment_id and
	p_session_date between EFFECTIVE_START_DATE and EFFECTIVE_END_DATE;

	select nvl(count(*),0) into l_after_ovm
	from per_all_assignments_f
	where ASSIGNMENT_ID=p_assignment_id and
	p_session_date+1 between EFFECTIVE_START_DATE and EFFECTIVE_END_DATE;

	if l_before_ovm<>l_after_ovm then
	l_assign_exist:=0;
	end if;
end if;


     if l_processed <> 'Y' then
        --
        if p_dt_delete_mode in ('DELETE_NEXT_CHANGE','FUTURE_CHANGE') then
           --
           -- Bugfix 2085631
           -- return false as we do not wish to remove these entries
           --
           return (false);
           --
        elsif p_dt_delete_mode = 'DELETE'
          and p_session_date = v_entry_rec.effective_end_date then
          --
          -- Bugfix 4015749
          -- return false, the non-recurring entry need not be zapped if it
          -- currently ends on the same day that the link being deleted will
          -- end, i.e.:
          --
          -- Before:
          -- EL  |----------------------------->
          -- PAY |-----|-----|-----|-----|----->
          -- EE        |-----|
          --                 ^
          --              p_session_date
          -- After:
          -- EL  |-----------|
          -- PAY |-----|-----|-----|-----|----->
          -- EE        |-----|
          --
          return (false);
          --
        -- Bugfix 4308892
        -- Need a new check here for employee termination code
        elsif p_dt_delete_mode = 'DELETE'
          and final_process_date(p_assignment_id, p_session_date) = p_session_date then
          --
          -- We do not wish to Zap this entry, it should be end-dated on
          -- the final process date so proceed with the Delete...
          return (true);
          --Added for Bug 6809717
	elsif l_assign_exist=0 then
        -- We do not required to zap if its just assignment status change to end.
        return (true);

        ELSIF p_dt_delete_mode <> 'ZAP' THEN   -- bug 8225278
           --
            p_dt_delete_mode := 'DELETE';
           --
        end if;
        --
     end if;
     return (true);
     --
   elsif p_dt_delete_mode in ('DELETE_NEXT_CHANGE','FUTURE_CHANGE') and
         v_entry_rec.effective_end_date = hr_general.end_of_time then
     --
     return (false);
     --
   else
     --
     return (true);
     --
   end if;
   --
 end del_ele_entry_param_val;
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry_api.delete_element_entry                                        --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Deletes an element entry providing full validation.                      --
 ------------------------------------------------------------------------------
--
 procedure delete_element_entry
 (
  --
  -- Delete Mode
  --
  p_dt_delete_mode             varchar2,
  --
  -- Date on which change is taking place
  --
  p_session_date               date,
  --
  -- Element Entry Table
  --
  p_element_entry_id           number
 ) is
   --
   -- Find all accepted pay proposals that use the element entry.
   --
   cursor csr_accepted_pay_proposals
          (
           p_element_entry_id number,
           p_assignment_id    number
          ) is
     select pp.pay_proposal_id
     from   per_pay_proposals pp
     where  pp.assignment_id = p_assignment_id
       and  exists
            (select null
             from   pay_element_entries_f ee
             where  ee.element_entry_id = p_element_entry_id
               and  ee.creator_type = 'SP'
               and  ee.creator_id = pp.pay_proposal_id
               and  ee.effective_start_date = pp.change_date);

   -- bug 666197
   cursor csr_ovn_and_dates
     (p_element_entry_id number, p_effective_date date) is
      select object_version_number, effective_start_date, effective_end_date
        from pay_element_entries_f
        where element_entry_id = p_element_entry_id
          and p_effective_date between effective_start_date
                                   and effective_end_date;
   --
   -- old values of the dml record
   cursor csr_old_entry_values is
     select
       effective_start_date
      ,effective_end_date
      ,cost_allocation_keyflex_id
      ,assignment_id
      ,updating_action_id
      ,updating_action_type
      ,element_link_id
      ,original_entry_id
      ,creator_type
      ,entry_type
      ,comment_id
      ,creator_id
      ,reason
      ,target_entry_id
      ,source_id
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,attribute16
      ,attribute17
      ,attribute18
      ,attribute19
      ,attribute20
      ,subpriority
      ,personal_payment_method_id
      ,date_earned
      ,object_version_number
      ,balance_adj_cost_flag
      ,element_type_id
      ,all_entry_values_null
    from pay_element_entries_f
    where element_entry_id = p_element_entry_id
      and p_session_date between effective_start_date
                             and effective_end_date;
   --
   --
   -- Local Variables
   --
   l_prof_value              varchar2(30);
   v_validation_start_date   date;
   v_validation_end_date     date;
   v_next_effective_end_date date;
   v_dt_delete_mode          varchar2(30) := p_dt_delete_mode;
   v_entry_rec               hr_entry_api.t_delete_entry_rec;
   v_pay_proposal_id         number;
   -- bug 666197
   l_effective_start_date            date;
   l_effective_end_date              date;
   l_object_version_number           number;
   l_effective_start_date_o          date;
   l_effective_end_date_o            date;
   l_cost_allocation_keyflex_id_o    number;
   l_assignment_id_o                 number;
   l_updating_action_id_o            number;
   l_updating_action_type_o          varchar2(30);
   l_element_link_id_o               number;
   l_original_entry_id_o             number;
   l_creator_type_o                  varchar2(10);
   l_entry_type_o                    varchar2(1);
   l_comment_id_o                    number;
   l_creator_id_o                    number;
   l_reason_o                        varchar2(30);
   l_target_entry_id_o               number;
   l_source_id_o                     number;
   l_attribute_category_o            varchar2(30);
   l_attribute1_o                    varchar2(150);
   l_attribute2_o                    varchar2(150);
   l_attribute3_o                    varchar2(150);
   l_attribute4_o                    varchar2(150);
   l_attribute5_o                    varchar2(150);
   l_attribute6_o                    varchar2(150);
   l_attribute7_o                    varchar2(150);
   l_attribute8_o                    varchar2(150);
   l_attribute9_o                    varchar2(150);
   l_attribute10_o                   varchar2(150);
   l_attribute11_o                   varchar2(150);
   l_attribute12_o                   varchar2(150);
   l_attribute13_o                   varchar2(150);
   l_attribute14_o                   varchar2(150);
   l_attribute15_o                   varchar2(150);
   l_attribute16_o                   varchar2(150);
   l_attribute17_o                   varchar2(150);
   l_attribute18_o                   varchar2(150);
   l_attribute19_o                   varchar2(150);
   l_attribute20_o                   varchar2(150);
-- --
   l_entry_information_category_o    varchar2(30);
   l_entry_information1_o            varchar2(150);
   l_entry_information2_o            varchar2(150);
   l_entry_information3_o            varchar2(150);
   l_entry_information4_o            varchar2(150);
   l_entry_information5_o            varchar2(150);
   l_entry_information6_o            varchar2(150);
   l_entry_information7_o            varchar2(150);
   l_entry_information8_o            varchar2(150);
   l_entry_information9_o            varchar2(150);
   l_entry_information10_o           varchar2(150);
   l_entry_information11_o           varchar2(150);
   l_entry_information12_o           varchar2(150);
   l_entry_information13_o           varchar2(150);
   l_entry_information14_o           varchar2(150);
   l_entry_information15_o           varchar2(150);
   l_entry_information16_o           varchar2(150);
   l_entry_information17_o           varchar2(150);
   l_entry_information18_o           varchar2(150);
   l_entry_information19_o           varchar2(150);
   l_entry_information20_o           varchar2(150);
   l_entry_information21_o           varchar2(150);
   l_entry_information22_o           varchar2(150);
   l_entry_information23_o           varchar2(150);
   l_entry_information24_o           varchar2(150);
   l_entry_information25_o           varchar2(150);
   l_entry_information26_o           varchar2(150);
   l_entry_information27_o           varchar2(150);
   l_entry_information28_o           varchar2(150);
   l_entry_information29_o           varchar2(150);
   l_entry_information30_o           varchar2(150);
-- --
   l_subpriority_o                   number;
   l_personal_payment_method_id_o    number;
   l_date_earned_o                   date;
   l_object_version_number_o         number;
   l_balance_adj_cost_flag_o         varchar2(1);
   l_element_type_id_o               number;
   l_all_entry_values_null_o         varchar2(30);
   --
   l_eev_need_null_call              boolean;
   i                                 number;
   l_session_date_cur                date;
   --
   --
        function PROCESSED (
        --
        -- Returns true if the element entry has already been processed in a run
        --
        p_element_entry_id      number,
        p_original_entry_id     number,
        p_processing_type       varchar2,
        p_entry_type            varchar2,
        p_validation_start_date date,
        p_assignment_id         number) return boolean is
        --
        processed       varchar2(1) := 'N';
        --
        -- Define how to determine if the entry is processed
        --
        cursor nonrecurring_entries (adjust_ee_source in varchar2) is
        select  'Y'
        from    pay_run_results       prr,
                pay_element_entries_f pee
        where   pee.element_entry_id = p_element_entry_id
	/* Added the following condition for bug: 7344563 */
	and     pee.element_entry_id = prr.element_entry_id
        and     p_validation_start_date between pee.effective_start_date
                                     and pee.effective_end_date
        and     prr.source_id   = decode(pee.entry_type,
                                          'A', decode (adjust_ee_source,
                                                       'T', pee.target_entry_id,
                                                       pee.element_entry_id),
                                          'R', decode (adjust_ee_source,
                                                       'T', pee.target_entry_id,
                                                       pee.element_entry_id),
                                          pee.element_entry_id)
        and     prr.entry_type  = pee.entry_type
        and     prr.source_type    in ('E', 'I')
        and     prr.status          <> 'U';
                --
        cursor recurring_entries is
                --
                select  'Y'
                from    pay_run_results         RESULT,
                        pay_assignment_actions  ASGT_ACTION,
                        pay_payroll_actions     PAY_ACTION,
                        per_time_periods        PERIOD
                where   result.source_id        = nvl (p_original_entry_id,
                                                        p_element_entry_id)
                and result.source_type    in ('E', 'I')
                and result.status               <> 'U'
                and result.assignment_action_id=asgt_action.assignment_action_id
                and asgt_action.payroll_action_id=pay_action.payroll_action_id
                and pay_action.time_period_id   = period.time_period_id
                and p_validation_start_date <= period.start_date;
        --
        adjust_ee_source varchar2(1);
        begin
        --
        if (p_entry_type in ('S','D','A','R') or p_processing_type = 'N') then
          --
          -- Ensure that we have loaded relevant informaion
          -- that includes value for leg rule 'ADJUSTMENT_EE_SOURCE'
          set_formula_contexts(p_assignment_id, p_validation_start_date);
--
          adjust_ee_source := g_asg_info.adj_ee_source;
--
          open nonrecurring_entries(adjust_ee_source);
          fetch nonrecurring_entries into processed;
          close nonrecurring_entries;
          --
        else
          --
          open recurring_entries;
          fetch recurring_entries into processed;
          close recurring_entries;
          --
        end if;
        --
        return (processed='Y');
        --
        end processed;
        --
 begin
   g_debug := hr_utility.debug_enabled;
   --
   if g_debug then
      hr_utility.set_location('hr_entry_api.delete_element_entry', 5);
   end if;
   --
   -- bug 666197, retrieve and store old values for the entry row
   --
   begin
   --
   open csr_old_entry_values;
   fetch csr_old_entry_values into
          l_effective_start_date_o
         ,l_effective_end_date_o
         ,l_cost_allocation_keyflex_id_o
         ,l_assignment_id_o
         ,l_updating_action_id_o
         ,l_updating_action_type_o
         ,l_element_link_id_o
         ,l_original_entry_id_o
         ,l_creator_type_o
         ,l_entry_type_o
         ,l_comment_id_o
         ,l_creator_id_o
         ,l_reason_o
         ,l_target_entry_id_o
         ,l_source_id_o
         ,l_attribute_category_o
         ,l_attribute1_o
         ,l_attribute2_o
         ,l_attribute3_o
         ,l_attribute4_o
         ,l_attribute5_o
         ,l_attribute6_o
         ,l_attribute7_o
         ,l_attribute8_o
         ,l_attribute9_o
         ,l_attribute10_o
         ,l_attribute11_o
         ,l_attribute12_o
         ,l_attribute13_o
         ,l_attribute14_o
         ,l_attribute15_o
         ,l_attribute16_o
         ,l_attribute17_o
         ,l_attribute18_o
         ,l_attribute19_o
         ,l_attribute20_o
         ,l_subpriority_o
         ,l_personal_payment_method_id_o
         ,l_date_earned_o
         ,l_object_version_number_o
         ,l_balance_adj_cost_flag_o
         ,l_element_type_id_o
         ,l_all_entry_values_null_o;
      close csr_old_entry_values;
      exception
      when no_data_found then
        hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
        hr_utility.set_message_token('PROCEDURE','hr_entry_api.upd_element_entry');
        hr_utility.set_message_token('STEP','10');
        hr_utility.raise_error;
     end;
      --
      --
      -- Validate the parameter and return element entry details.
      --
      -- Bug 9013257, gets minimum assignment effective_start_date
      select min(ASG.effective_start_date)
      into l_session_date_cur
      from per_all_assignments_f ASG
      where ASG.assignment_id = l_assignment_id_o;
      --
      -- Bug 9013257, use min(effective_start_date) as the session_date
      -- if it is later than session_date and ZAP mode
      --
      if v_dt_delete_mode='ZAP' and l_session_date_cur > p_session_date then
        set_formula_contexts(l_assignment_id_o, l_session_date_cur);
      else
        set_formula_contexts(l_assignment_id_o, p_session_date);
      end if;
      --
      if hr_entry_api.del_ele_entry_param_val
        (v_dt_delete_mode,
         p_session_date,
         p_element_entry_id,
         l_assignment_id_o,
         v_entry_rec) then
     --
     -- Set the validation start and end dates according to the delete mode
     -- selected.
     --
     if v_dt_delete_mode = 'DELETE_NEXT_CHANGE' then
       --
       if g_debug then
          hr_utility.set_location('hr_entry_api.delete_element_entry', 15);
       end if;
       --
       begin
         select min(ee.effective_end_date)
         into   v_next_effective_end_date
         from   pay_element_entries_f ee
         where  ee.element_entry_id = p_element_entry_id
           and  ee.effective_start_date > v_entry_rec.effective_end_date;
       exception
         when no_data_found then null;
       end;
       --
       v_validation_start_date := v_entry_rec.effective_end_date + 1;
       --
       if v_next_effective_end_date is null then
         v_validation_end_date := hr_general.end_of_time;
       else
         v_validation_end_date := v_next_effective_end_date;
       end if;
       --
     elsif v_dt_delete_mode = 'FUTURE_CHANGE' then
       --
       v_validation_start_date := v_entry_rec.effective_end_date + 1;
       v_validation_end_date   := hr_general.end_of_time;
       --
     elsif v_dt_delete_mode = 'DELETE' then
       --
       v_validation_start_date := p_session_date + 1;
       v_validation_end_date   := hr_general.end_of_time;
       --
     elsif v_dt_delete_mode = 'ZAP' then
       --
       -- It may be illegal for users to purge entries, depending on
       -- the setting of a profile and what sort of entry is specified
       -- for purge.  We check this here because the v_dt_delete_mode
       -- can be changed by the previous call.
       --
       if g_debug then
          hr_utility.set_location('hr_entry_api.delete_element_entry', 18);
       end if;
       -- Start by reading the value.
       fnd_profile.get('HR_ELE_ENTRY_PURGE_CONTROL', l_prof_value);
       --
       -- Check if the profile is set appropriately and we are
       -- restricted.
       if l_prof_value is not null and
         (l_prof_value = 'N' or
          (l_prof_value = 'I' and v_entry_rec.non_payments_flag = 'N'))
       then
         -- We need to raise error that are attempting to purge.
         hr_utility.set_message (800,'HR_33000_ENTRY_CANT_PURGE');
         hr_utility.raise_error;
       end if;
       --
       -- Choose the extend of the entry to supply
       -- the validation start and end dates.
       -- This was added as a fix for bug 1862422
       -- to bring the validation into line with the
       -- usual api standards.
       select min(pee.effective_start_date),
              max(pee.effective_end_date)
       into   v_validation_start_date,
              v_validation_end_date
       from   pay_element_entries_f pee
       where  pee.element_entry_id = p_element_entry_id;
       --
     end if;
     --
     if g_debug then
        hr_utility.set_location('hr_entry_api.delete_element_entry', 20);
     end if;
     --
     -- Make sure the delete is valid.
     --
     if v_entry_rec.personal_payment_method_id is not null
     and processed (
                --
                p_element_entry_id,
                v_entry_rec.original_entry_id,
                v_entry_rec.processing_type,
                v_entry_rec.entry_type,
                v_validation_start_date,
                v_entry_rec.assignment_id)
                --
     then
       hr_utility.set_message (801,'HR_7798_ENTRY_PPM_RUN_RESULT');
       hr_utility.raise_error;
       --
     end if;
     --

     -- Bug 9013257, use min(effective_start_date) as the session_date
     -- if it is later than session_date and ZAP mode
     --
     if v_dt_delete_mode='ZAP' and l_session_date_cur > p_session_date then
       hr_entry.chk_element_entry_main
       (p_element_entry_id,
        v_entry_rec.original_entry_id,
        l_session_date_cur,
        v_entry_rec.element_link_id,
        v_entry_rec.assignment_id,
        v_entry_rec.entry_type,
        v_entry_rec.effective_start_date,
        v_entry_rec.effective_end_date,
        v_validation_start_date,
        v_validation_end_date,
        null,
        v_dt_delete_mode,
        'DELETE',  -- p_usage
        v_entry_rec.target_entry_id,
        v_entry_rec.creator_type);
     else
       hr_entry.chk_element_entry_main
       (p_element_entry_id,
        v_entry_rec.original_entry_id,
        p_session_date,
        v_entry_rec.element_link_id,
        v_entry_rec.assignment_id,
        v_entry_rec.entry_type,
        v_entry_rec.effective_start_date,
        v_entry_rec.effective_end_date,
        v_validation_start_date,
        v_validation_end_date,
        null,
        v_dt_delete_mode,
        'DELETE',  -- p_usage
        v_entry_rec.target_entry_id,
        v_entry_rec.creator_type);
     end if;
     --
     -- Make a copy of all pay proposals for the assignment which have been
     -- accepted. This is used later to see if any have had the element entry
     -- changed ie. creator type changed, removed etc... If so the pay proposal
     -- has to be removed.
     --
     open csr_accepted_pay_proposals(p_element_entry_id,
                                     v_entry_rec.assignment_id);
     --
     if g_debug then
        hr_utility.set_location('hr_entry_api.delete_element_entry', 25);
     end if;
     --
     -- Trigger workload shifting if change to element entry overlaps with the
     -- latest payroll run for the assignment and workload shifting is enabled.
     --
     hr_entry.trigger_workload_shifting
       ('ELEMENT_ENTRY',
        v_entry_rec.assignment_id,
        v_validation_start_date,
        v_validation_end_date);
     --
     -- If entry is being removed then
     --
     --   remove any explict quickpay inclusions for the element entry
     --   where the inclusion overlaps with the removed part of the element
     --   entry.
     --
     if v_dt_delete_mode = 'DELETE' or p_dt_delete_mode = 'ZAP' then
       --
       if g_debug then
          hr_utility.set_location('hr_entry_api.delete_element_entry', 30);
       end if;
       --
       -- Enhancement 3368211
       --
       -- Delete from both PAY_QUICKPAY_INCLUSIONS and PAY_QUICKPAY_EXCLUSIONS.
       --
       -- There is a chance the element entry id exists in both tables if
       -- any QuickPay assignment actions were created before the QuickPay
       -- Exclusions data model was in use.
       --
       delete from pay_quickpay_exclusions pqe
       where  pqe.element_entry_id = p_element_entry_id
         and  exists
                (select null
                 from   pay_assignment_actions paa,
                        pay_payroll_actions    ppa
                 where  paa.assignment_action_id = pqe.assignment_action_id
                   and  ppa.payroll_action_id    = paa.payroll_action_id
                   and  ppa.date_earned between v_validation_start_date
                                            and v_validation_end_date);
       --
       delete from pay_quickpay_inclusions pqi
       where  pqi.element_entry_id = p_element_entry_id
         and  exists
                (select null
                 from   pay_assignment_actions paa,
                        pay_payroll_actions    ppa
                 where  paa.assignment_action_id = pqi.assignment_action_id
                   and  ppa.payroll_action_id    = paa.payroll_action_id
                   and  ppa.date_earned between v_validation_start_date
                                            and v_validation_end_date);

     end if;
     --
     -- Do date effective operation on element entry.
     --
     if v_dt_delete_mode = 'DELETE_NEXT_CHANGE' then
       --
       if g_debug then
          hr_utility.set_location('hr_entry_api.delete_element_entry', 40);
       end if;
       --
       delete from pay_element_entries_f ee
       where  ee.element_entry_id = p_element_entry_id
         and  ee.effective_start_date = v_validation_start_date;
       --
       update pay_element_entries_f ee
       set    ee.effective_end_date = decode(v_validation_end_date,
                                             hr_general.end_of_time,
                                             v_entry_rec.effective_end_date,
                                             v_validation_end_date),
              ee.updating_action_id = decode(ee.updating_action_type, 'U', ee.updating_action_id,
                                                                      null),
              ee.updating_action_type = decode(ee.updating_action_type, 'U', 'U', null)
       where  ee.element_entry_id = p_element_entry_id
         and  ee.effective_start_date = v_entry_rec.effective_start_date;
       --
     elsif v_dt_delete_mode = 'FUTURE_CHANGE' then
       --
       if g_debug then
          hr_utility.set_location('hr_entry_api.delete_element_entry', 45);
       end if;
       --
       delete from pay_element_entries_f ee
       where  ee.element_entry_id = p_element_entry_id
         and  ee.effective_start_date > v_entry_rec.effective_start_date;
       --
       update pay_element_entries_f ee
       set    ee.effective_end_date = v_entry_rec.effective_end_date,
              ee.updating_action_id = decode(ee.updating_action_type, 'U', ee.updating_action_id,
                                                                      null),
              ee.updating_action_type = decode(ee.updating_action_type, 'U', 'U', null)
       where  ee.element_entry_id = p_element_entry_id
         and  ee.effective_start_date = v_entry_rec.effective_start_date;
       --
     elsif v_dt_delete_mode = 'DELETE' then
       --
       if g_debug then
          hr_utility.set_location('hr_entry_api.delete_element_entry', 50);
       end if;
       --
       delete from pay_element_entries_f ee
       where  ee.element_entry_id = p_element_entry_id
         and  ee.effective_start_date > p_session_date;
       --
       update pay_element_entries_f ee
       set    ee.effective_end_date = p_session_date,
              ee.updating_action_id = decode(ee.updating_action_type, 'U', ee.updating_action_id,
                                                                      null),
              ee.updating_action_type = decode(ee.updating_action_type, 'U', 'U', null)
       where  ee.element_entry_id = p_element_entry_id
         and  ee.effective_start_date = v_entry_rec.effective_start_date;
       --
     elsif v_dt_delete_mode = 'ZAP' then
       --
       if g_debug then
          hr_utility.set_location('hr_entry_api.delete_element_entry', 55);
       end if;
       --
       -- For Zap mode, delete any balance exclusions rows for the entry
       --
       delete from pay_grossup_bal_exclusions excl
       where  excl.source_id =  p_element_entry_id
       and    excl.source_type = 'EE';
       --
       delete from pay_element_entries_f ee
       where  ee.element_entry_id = p_element_entry_id;
       --
     end if;
     --
     if g_debug then
        hr_utility.set_location('hr_entry_api.delete_element_entry', 60);
     end if;
     --
     -- Delete element entry values
     --
     hr_entry.del_3p_entry_values
       (v_entry_rec.assignment_id,
        p_element_entry_id,
        v_entry_rec.element_type_id,
        v_entry_rec.element_link_id,
        v_entry_rec.entry_type,
        v_entry_rec.processing_type,
        v_entry_rec.creator_type,
        v_entry_rec.creator_id,
        v_dt_delete_mode,
        p_session_date,
        v_validation_start_date,
        v_validation_end_date);
     --
     if g_debug then
        hr_utility.set_location('hr_entry_api.delete_element_entry', 65);
     end if;
     --
     -- Go through list of accepted pay proposals for the assignment /
     -- element entry to see if any of the pay proosals have lost the element
     -- entry they had (the existence of an element entry signifies an accepted
     -- pay proposal) ie. creator type changed, removed etc... Any accepted
     -- pay proposals that have lost their element entry should be removed.
     --
     loop
       --
       fetch csr_accepted_pay_proposals into v_pay_proposal_id;
       exit when csr_accepted_pay_proposals%notfound;
       --
       delete from per_pay_proposals pp
       where  pp.pay_proposal_id = v_pay_proposal_id
         and  not exists
              (select null
               from   pay_element_entries_f ee
               where  ee.element_entry_id = p_element_entry_id
                 and  ee.creator_type = 'SP'
                 and  ee.creator_id = pp.pay_proposal_id
                 and  ee.effective_start_date = pp.change_date);
       --
     end loop;
     --
   else -- hr_entry_api.del_ele_entry_param_val returned 'FALSE'
   --
      if v_entry_rec.processing_type = 'N' and
       --v_dt_delete_mode in ('DELETE_NEXT_CHANGE','FUTURE_CHANGE') then
         v_dt_delete_mode in ('DELETE_NEXT_CHANGE','FUTURE_CHANGE','DELETE') then
         --
         if g_debug then
            hr_utility.set_location('hr_entry_api.delete_element_entry', 67);
         end if;
         --
         -- We do not wish to continue processing
         --
         return;
         --
      end if;
   --
   end if;
   --
   -- bug 666197, retrieve object version number; effective start/end dates;
   -- call to the user hook procedure
   --
   open csr_ovn_and_dates(p_element_entry_id, p_session_date);
   fetch csr_ovn_and_dates into l_object_version_number, l_effective_start_date,
                                        l_effective_end_date;
   close csr_ovn_and_dates;


   --
   begin
   --
   -- NB bug 3057670 has highlighted the fact that the orig delete_mode can be altered
   -- in the earlier call to hr_entry_api.del_ele_entry_param_val
   -- Therefore the passed value can be p_dt_delete_mode or v_dt_delete_mode.
   -- From JUL FP 03 this has been made the latter, ie if we handle a DELETE as a ZAP
   -- as in the bug above, then tell the hook (and DYT's etc) that we have just
   -- performed a ZAP
   --
   pay_ele_rkd.after_delete
     ( p_effective_date                 => p_session_date
      ,p_validation_start_date          => v_validation_start_date
      ,p_validation_end_date            => v_validation_end_date
      ,p_datetrack_mode                 => v_dt_delete_mode
      ,p_element_entry_id               => p_element_entry_id
      ,p_effective_start_date           => l_effective_start_date
      ,p_effective_end_date             => l_effective_end_date
      --,p_object_version_number          => l_object_version_number
      -- old values set
      ,p_effective_start_date_o         => l_effective_start_date_o
      ,p_effective_end_date_o           => l_effective_end_date_o
      ,p_cost_allocation_keyflex_id_o   => l_cost_allocation_keyflex_id_o
      ,p_assignment_id_o                => l_assignment_id_o
      ,p_updating_action_id_o           => l_updating_action_id_o
      ,p_updating_action_type_o         => l_updating_action_type_o
      ,p_element_link_id_o              => l_element_link_id_o
      ,p_original_entry_id_o            => l_original_entry_id_o
      ,p_creator_type_o                 => l_creator_type_o
      ,p_entry_type_o                   => l_entry_type_o
      ,p_comment_id_o                   => l_comment_id_o
      ,p_creator_id_o                   => l_creator_id_o
      ,p_reason_o                       => l_reason_o
      ,p_target_entry_id_o              => l_target_entry_id_o
      ,p_source_id_o                    => l_source_id_o
      ,p_attribute_category_o           => l_attribute_category_o
      ,p_attribute1_o                   => l_attribute1_o
      ,p_attribute2_o                   => l_attribute2_o
      ,p_attribute3_o                   => l_attribute3_o
      ,p_attribute4_o                   => l_attribute4_o
      ,p_attribute5_o                   => l_attribute5_o
      ,p_attribute6_o                   => l_attribute6_o
      ,p_attribute7_o                   => l_attribute7_o
      ,p_attribute8_o                   => l_attribute8_o
      ,p_attribute9_o                   => l_attribute9_o
      ,p_attribute10_o                  => l_attribute10_o
      ,p_attribute11_o                  => l_attribute11_o
      ,p_attribute12_o                  => l_attribute12_o
      ,p_attribute13_o                  => l_attribute13_o
      ,p_attribute14_o                  => l_attribute14_o
      ,p_attribute15_o                  => l_attribute15_o
      ,p_attribute16_o                  => l_attribute16_o
      ,p_attribute17_o                  => l_attribute17_o
      ,p_attribute18_o                  => l_attribute18_o
      ,p_attribute19_o                  => l_attribute19_o
      ,p_attribute20_o                  => l_attribute20_o
-- --
      ,p_entry_information_category_o   => l_entry_information_category_o
      ,p_entry_information1_o           => l_entry_information1_o
      ,p_entry_information2_o           => l_entry_information2_o
      ,p_entry_information3_o           => l_entry_information3_o
      ,p_entry_information4_o           => l_entry_information4_o
      ,p_entry_information5_o           => l_entry_information5_o
      ,p_entry_information6_o           => l_entry_information6_o
      ,p_entry_information7_o           => l_entry_information7_o
      ,p_entry_information8_o           => l_entry_information8_o
      ,p_entry_information9_o           => l_entry_information9_o
      ,p_entry_information10_o          => l_entry_information10_o
      ,p_entry_information11_o          => l_entry_information11_o
      ,p_entry_information12_o          => l_entry_information12_o
      ,p_entry_information13_o          => l_entry_information13_o
      ,p_entry_information14_o          => l_entry_information14_o
      ,p_entry_information15_o          => l_entry_information15_o
      ,p_entry_information16_o          => l_entry_information16_o
      ,p_entry_information17_o          => l_entry_information17_o
      ,p_entry_information18_o          => l_entry_information18_o
      ,p_entry_information19_o          => l_entry_information19_o
      ,p_entry_information20_o          => l_entry_information20_o
      ,p_entry_information21_o          => l_entry_information21_o
      ,p_entry_information22_o          => l_entry_information22_o
      ,p_entry_information23_o          => l_entry_information23_o
      ,p_entry_information24_o          => l_entry_information24_o
      ,p_entry_information25_o          => l_entry_information25_o
      ,p_entry_information26_o          => l_entry_information26_o
      ,p_entry_information27_o          => l_entry_information27_o
      ,p_entry_information28_o          => l_entry_information28_o
      ,p_entry_information29_o          => l_entry_information29_o
      ,p_entry_information30_o          => l_entry_information30_o
      ,p_subpriority_o                  => l_subpriority_o
      ,p_personal_payment_method_id_o   => l_personal_payment_method_id_o
      ,p_date_earned_o                  => l_date_earned_o
      ,p_object_version_number_o        => l_object_version_number_o
      ,p_balance_adj_cost_flag_o        => l_balance_adj_cost_flag_o
      ,p_comments_o                     => null
      ,p_element_type_id_o              => l_element_type_id_o
      ,p_all_entry_values_null_o        => l_all_entry_values_null_o
     );
     --
     exception
       when hr_api.cannot_find_prog_unit then
         hr_api.cannot_find_prog_unit_error
               (p_module_name => 'PAY_ELEMENT_ENTRIES_F'
               ,p_hook_type   => 'AD'
               );
     end;
    --
   --
   if g_debug then
      hr_utility.set_location('hr_entry_api.delete_element_entry', 70);
   end if;
   --

  --
  -- 21-FEB-03
  -- -----------------
  -- Currently the hard-coded calls to the after_delete dynamic trigger package
  -- for element entries vals have been made for after insert and after update.  At this
  -- time after delete will not be made as CC does not require it.  At a future
  -- juncture this can be added, methodology....
  -- 1) Before delete of eev above, create cache of values
  -- 2) Now make a call to PAY_DYT_ELEMENT_ENTRY_VAL_PKG.after_delete
  --    -use current values if end dated or nulls if row has been blown away
  --
  if g_debug then
     hr_utility.trace(' NO Hard call PAY_DYT_ELEMENT_ENTRY_VAL_PKG.after_delete');
     hr_utility.set_location('Leaving: delete_element_entry', 900);
  end if;

 end delete_element_entry;
 --
end hr_entry_api;

/
