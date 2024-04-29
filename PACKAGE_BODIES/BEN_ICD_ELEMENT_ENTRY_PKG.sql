--------------------------------------------------------
--  DDL for Package Body BEN_ICD_ELEMENT_ENTRY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ICD_ELEMENT_ENTRY_PKG" AS
/* $Header: beicdeleent.pkb 120.12 2008/04/17 10:18:20 schowdhu noship $ */

-- Global variables
  g_package               constant varchar2(80):='ben_icd_element_entry_pkg.';



function get_datetrack_mode
(p_element_entry_id in number
,p_effective_start_date in date
,p_effective_date in date
,p_datetrack_mode in varchar2) return varchar2 is

cursor dt_row_exists is select 'Y' from pay_element_entries_f a, pay_element_entries_f b
              where a.element_entry_id = p_element_entry_id
              and a.effective_start_date = p_effective_start_Date
			  and b.element_entry_id = a.element_entry_id
              and b.effective_start_date = a.effective_end_Date+1;
next_row_exists varchar2(1):='N';
l_datetrack_mode varchar2(30);
begin

       open dt_row_exists;
          fetch dt_row_exists into next_row_exists;
       close dt_row_exists;

       if(next_row_exists is null) then
           next_row_exists := 'N';
        end if ;

       if(hr_api.g_update = p_datetrack_mode) then
           if( p_effective_date < p_effective_start_date)then
              -- throw an error.
              --'Please check the effective date as the changes can not become effective before the record started.'
 		            null;
            elsif(p_effective_date = p_effective_start_date)then
               l_datetrack_mode:= hr_api.g_correction;
           elsif(p_effective_date > p_effective_start_date and 'Y' = next_row_exists) then
		       l_datetrack_mode:=hr_api.g_update_change_insert;
		   else
		       l_datetrack_mode:= hr_api.g_update;
		   end if;
		elsif(hr_api.g_delete = p_datetrack_mode) then
		   if( p_effective_date < p_effective_start_date)then
		    null;
              -- throw an error.
              --'Please check the end date as the changes can not end before the record started.'
 		   elsif(p_effective_date = p_effective_start_date) then
              l_datetrack_mode:= hr_api.g_zap;
           elsif(p_effective_date > p_effective_start_date and 'Y' = next_row_exists) then
		       l_datetrack_mode:= hr_api.g_future_change;
		   else
		       l_datetrack_mode:= hr_api.g_delete;
		   end if;
         else
         -- this is insert dml_operation and should not happen.
            l_datetrack_mode:= p_datetrack_mode;
         end if;
       return l_datetrack_mode;
end get_datetrack_mode;

PROCEDURE ICD_UPDATE_ELEMENT_ENTRY
  (p_validate                      in     number   default 0
  ,p_datetrack_update_mode         in     varchar2
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_element_entry_id              in     number
  ,p_object_version_number         in     number
  ,p_cost_allocation_keyflex_id    in     number
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  ,p_input_value_id1               in     number
  ,p_input_value_id2               in     number
  ,p_input_value_id3               in     number
  ,p_input_value_id4               in     number
  ,p_input_value_id5               in     number
  ,p_input_value_id6               in     number
  ,p_input_value_id7               in     number
  ,p_input_value_id8               in     number
  ,p_input_value_id9               in     number
  ,p_input_value_id10              in     number
  ,p_input_value_id11              in     number
  ,p_input_value_id12              in     number
  ,p_input_value_id13              in     number
  ,p_input_value_id14              in     number
  ,p_input_value_id15              in     number
  ,p_entry_value1                  in     varchar2
  ,p_entry_value2                  in     varchar2
  ,p_entry_value3                  in     varchar2
  ,p_entry_value4                  in     varchar2
  ,p_entry_value5                  in     varchar2
  ,p_entry_value6                  in     varchar2
  ,p_entry_value7                  in     varchar2
  ,p_entry_value8                  in     varchar2
  ,p_entry_value9                  in     varchar2
  ,p_entry_value10                 in     varchar2
  ,p_entry_value11                 in     varchar2
  ,p_entry_value12                 in     varchar2
  ,p_entry_value13                 in     varchar2
  ,p_entry_value14                 in     varchar2
  ,p_entry_value15                 in     varchar2
  ,p_entry_information_category    in     varchar2
  ,p_entry_information1            in     varchar2
  ,p_entry_information2            in     varchar2
  ,p_entry_information3            in     varchar2
  ,p_entry_information4            in     varchar2
  ,p_entry_information5            in     varchar2
  ,p_entry_information6            in     varchar2
  ,p_entry_information7            in     varchar2
  ,p_entry_information8            in     varchar2
  ,p_entry_information9            in     varchar2
  ,p_entry_information10           in     varchar2
  ,p_entry_information11           in     varchar2
  ,p_entry_information12           in     varchar2
  ,p_entry_information13           in     varchar2
  ,p_entry_information14           in     varchar2
  ,p_entry_information15           in     varchar2
  ,p_entry_information16           in     varchar2
  ,p_entry_information17           in     varchar2
  ,p_entry_information18           in     varchar2
  ,p_entry_information19           in     varchar2
  ,p_entry_information20           in     varchar2
  ,p_entry_information21           in     varchar2
  ,p_entry_information22           in     varchar2
  ,p_entry_information23           in     varchar2
  ,p_entry_information24           in     varchar2
  ,p_entry_information25           in     varchar2
  ,p_entry_information26           in     varchar2
  ,p_entry_information27           in     varchar2
  ,p_entry_information28           in     varchar2
  ,p_entry_information29           in     varchar2
  ,p_entry_information30           in     varchar2
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
--  ,p_icd_effective_date           in  date
--  ,p_warning                      out  nocopy  number
  ) is

cursor c_input_values is
select * from
pay_input_values_f
where element_type_id = (select element_type_id from pay_element_entries_f where
element_entry_id = p_element_entry_id and p_effective_date between effective_start_date and effective_end_date)
and p_effective_date between effective_start_date and effective_end_date
order by input_value_id asc;

l_effective_start_date date;
l_effective_end_date date;
l_update_warning boolean;
l_validate boolean;
l_object_version_number number;

l_entry_value1 varchar2(60);
l_entry_value2 varchar2(60);
l_entry_value3 varchar2(60);
l_entry_value4 varchar2(60);
l_entry_value5 varchar2(60);
l_entry_value6 varchar2(60);
l_entry_value7 varchar2(60);
l_entry_value8 varchar2(60);
l_entry_value9 varchar2(60);
l_entry_value10 varchar2(60);
l_entry_value11 varchar2(60);
l_entry_value12 varchar2(60);
l_entry_value13 varchar2(60);
l_entry_value14 varchar2(60);
l_entry_value15 varchar2(60);
l_app_name varchar2(50);
l_msg_name varchar2(30);
--changes for ICD number formatting issue
icx_numeric varchar2(20);

begin
  fnd_msg_pub.initialize;
l_object_version_number := P_OBJECT_VERSION_NUMBER;
l_validate := false;
if p_validate = 1 then
	l_validate := true;
end if;

icx_numeric := fnd_profile.value('ICX_NUMERIC_CHARACTERS');

for l_input_value in c_input_values loop
   if(p_input_value_id1 = l_input_value.input_value_id ) then
       -- the format coming in is already canonical but the api is expecting a user format
      if( 'D' = l_input_value.uom) then
        l_entry_value1 := fnd_date.date_to_displaydate(to_date(p_entry_value1,'YYYY/MM/DD HH24:MI:SS'));
      elsif ('M' = l_input_value.uom and icx_numeric <>  '.,')then
      l_entry_value1 := replace(p_entry_value1,'.',',');
      else
        l_entry_value1 := p_entry_value1;
      end if ;
   elsif(p_input_value_id2 = l_input_value.input_value_id ) then
      if( 'D' = l_input_value.uom) then
        l_entry_value2 := fnd_date.date_to_displaydate(to_date(p_entry_value2,'YYYY/MM/DD HH24:MI:SS'));
              elsif ('M' = l_input_value.uom and icx_numeric <>  '.,')then
      l_entry_value2 := replace(p_entry_value2,'.',',');
       else
        l_entry_value2 := p_entry_value2;
     end if ;

   elsif(p_input_value_id3 = l_input_value.input_value_id) then
        if( 'D' = l_input_value.uom) then
        l_entry_value3 := fnd_date.date_to_displaydate(to_date(p_entry_value3,'YYYY/MM/DD HH24:MI:SS'));
              elsif ('M' = l_input_value.uom and icx_numeric <>  '.,')then
      l_entry_value3 := replace(p_entry_value3,'.',',');
        else
        l_entry_value3 := p_entry_value3;
        end if ;

   elsif(p_input_value_id4 = l_input_value.input_value_id) then
        if( 'D' = l_input_value.uom) then
        l_entry_value4 := fnd_date.date_to_displaydate(to_date(p_entry_value4,'YYYY/MM/DD HH24:MI:SS'));
              elsif ('M' = l_input_value.uom and icx_numeric <>  '.,')then
      l_entry_value4 := replace(p_entry_value4,'.',',');
        else
        l_entry_value4 := p_entry_value4;
     end if ;

   elsif(p_input_value_id5 = l_input_value.input_value_id) then
        if( 'D' = l_input_value.uom) then
        l_entry_value5 := fnd_date.date_to_displaydate(to_date(p_entry_value5,'YYYY/MM/DD HH24:MI:SS'));
              elsif ('M' = l_input_value.uom and icx_numeric <>  '.,')then
      l_entry_value5 := replace(p_entry_value5,'.',',');
       else
        l_entry_value5 := p_entry_value5;
       end if ;

   elsif(p_input_value_id6 = l_input_value.input_value_id) then
        if( 'D' = l_input_value.uom) then
        l_entry_value6 := fnd_date.date_to_displaydate(to_date(p_entry_value6,'YYYY/MM/DD HH24:MI:SS'));
              elsif ('M' = l_input_value.uom and icx_numeric <>  '.,')then
      l_entry_value6 := replace(p_entry_value6,'.',',');
        else
        l_entry_value6 := p_entry_value6;
       end if ;

   elsif(p_input_value_id7 = l_input_value.input_value_id ) then
       if( 'D' = l_input_value.uom) then
        l_entry_value7 := fnd_date.date_to_displaydate(to_date(p_entry_value7,'YYYY/MM/DD HH24:MI:SS'));
              elsif ('M' = l_input_value.uom and icx_numeric <>  '.,')then
      l_entry_value7 := replace(p_entry_value7,'.',',');
             else
        l_entry_value7 := p_entry_value7;
     end if ;

   elsif(p_input_value_id8 = l_input_value.input_value_id) then
        if( 'D' = l_input_value.uom) then
        l_entry_value8 := fnd_date.date_to_displaydate(to_date(p_entry_value8,'YYYY/MM/DD HH24:MI:SS'));
              elsif ('M' = l_input_value.uom and icx_numeric <>  '.,')then
      l_entry_value8 := replace(p_entry_value8,'.',',');
        else
        l_entry_value8 := p_entry_value8;
        end if ;

   elsif(p_input_value_id9 = l_input_value.input_value_id) then
       if( 'D' = l_input_value.uom) then
        l_entry_value9 := fnd_date.date_to_displaydate(to_date(p_entry_value9,'YYYY/MM/DD HH24:MI:SS'));
              elsif ('M' = l_input_value.uom and icx_numeric <>  '.,')then
      l_entry_value9 := replace(p_entry_value9,'.',',');
       else
        l_entry_value9 := p_entry_value9;
       end if ;
   elsif(p_input_value_id10 = l_input_value.input_value_id) then
       if( 'D' = l_input_value.uom) then
        l_entry_value10 := fnd_date.date_to_displaydate(to_date(p_entry_value10,'YYYY/MM/DD HH24:MI:SS'));
              elsif ('M' = l_input_value.uom and icx_numeric <>  '.,')then
      l_entry_value10 := replace(p_entry_value10,'.',',');
       else
        l_entry_value10 := p_entry_value10;
       end if ;
   elsif(p_input_value_id11 = l_input_value.input_value_id) then
       if( 'D' = l_input_value.uom) then
        l_entry_value11 := fnd_date.date_to_displaydate(to_date(p_entry_value11,'YYYY/MM/DD HH24:MI:SS'));
              elsif ('M' = l_input_value.uom and icx_numeric <>  '.,')then
      l_entry_value11 := replace(p_entry_value11,'.',',');
        else
        l_entry_value11 := p_entry_value11;
        end if ;
   elsif(p_input_value_id12 = l_input_value.input_value_id) then
       if( 'D' = l_input_value.uom) then
        l_entry_value12 := fnd_date.date_to_displaydate(to_date(p_entry_value12,'YYYY/MM/DD HH24:MI:SS'));
              elsif ('M' = l_input_value.uom and icx_numeric <>  '.,')then
      l_entry_value12 := replace(p_entry_value12,'.',',');
       else
        l_entry_value12 := p_entry_value12;
       end if ;
    elsif(p_input_value_id13 = l_input_value.input_value_id) then
       if( 'D' = l_input_value.uom) then
        l_entry_value13 := fnd_date.date_to_displaydate(to_date(p_entry_value13,'YYYY/MM/DD HH24:MI:SS'));
              elsif ('M' = l_input_value.uom and icx_numeric <>  '.,')then
      l_entry_value13 := replace(p_entry_value13,'.',',');
       else
        l_entry_value13 := p_entry_value13;
       end if ;
   elsif(p_input_value_id14 = l_input_value.input_value_id ) then
       if( 'D' = l_input_value.uom) then
        l_entry_value14 := fnd_date.date_to_displaydate(to_date(p_entry_value14,'YYYY/MM/DD HH24:MI:SS'));
              elsif ('M' = l_input_value.uom and icx_numeric <>  '.,')then
      l_entry_value14 := replace(p_entry_value14,'.',',');
        else
        l_entry_value14 := p_entry_value14;
     end if ;

   elsif(p_input_value_id15 = l_input_value.input_value_id) then
       if( 'D' = l_input_value.uom) then
        l_entry_value15 := fnd_date.date_to_displaydate(to_date(p_entry_value15,'YYYY/MM/DD HH24:MI:SS'));
              elsif ('M' = l_input_value.uom and icx_numeric <>  '.,')then
      l_entry_value15 := replace(p_entry_value15,'.',',');
       else
        l_entry_value15 := p_entry_value15;
       end if ;
   end if;
   end loop;
pay_element_entry_api.update_element_entry
  (p_validate                      => l_validate
  ,p_datetrack_update_mode         => get_datetrack_mode(p_element_entry_id,p_effective_start_date,p_effective_date,p_datetrack_update_mode)
  ,p_effective_date                => p_effective_date
  ,p_business_group_id             => p_business_group_id
  ,p_element_entry_id              => p_element_entry_id
  ,p_object_version_number         => l_object_version_number
  ,p_cost_allocation_keyflex_id    => p_cost_allocation_keyflex_id
  ,p_attribute_category            => p_attribute_category
  ,p_attribute1                    => p_attribute1
  ,p_attribute2                    => p_attribute2
  ,p_attribute3                    => p_attribute3
  ,p_attribute4                    => p_attribute4
  ,p_attribute5                    => p_attribute5
  ,p_attribute6                    => p_attribute6
  ,p_attribute7                    => p_attribute7
  ,p_attribute8                    => p_attribute8
  ,p_attribute9                    => p_attribute9
  ,p_attribute10                   => p_attribute10
  ,p_attribute11                   => p_attribute11
  ,p_attribute12                   => p_attribute12
  ,p_attribute13                   => p_attribute13
  ,p_attribute14                   => p_attribute14
  ,p_attribute15                   => p_attribute15
  ,p_attribute16                   => p_attribute16
  ,p_attribute17                   => p_attribute17
  ,p_attribute18                   => p_attribute18
  ,p_attribute19                   => p_attribute19
  ,p_attribute20                   => p_attribute20
  ,p_input_value_id1               => p_input_value_id1
  ,p_input_value_id2               => p_input_value_id2
  ,p_input_value_id3               => p_input_value_id3
  ,p_input_value_id4               => p_input_value_id4
  ,p_input_value_id5               => p_input_value_id5
  ,p_input_value_id6               => p_input_value_id6
  ,p_input_value_id7               => p_input_value_id7
  ,p_input_value_id8               => p_input_value_id8
  ,p_input_value_id9               => p_input_value_id9
  ,p_input_value_id10              => p_input_value_id10
  ,p_input_value_id11              => p_input_value_id11
  ,p_input_value_id12              => p_input_value_id12
  ,p_input_value_id13              => p_input_value_id13
  ,p_input_value_id14              => p_input_value_id14
  ,p_input_value_id15              => p_input_value_id15
  ,p_entry_value1                  => l_entry_value1
  ,p_entry_value2                  => l_entry_value2
  ,p_entry_value3                  => l_entry_value3
  ,p_entry_value4                  => l_entry_value4
  ,p_entry_value5                  => l_entry_value5
  ,p_entry_value6                  => l_entry_value6
  ,p_entry_value7                  => l_entry_value7
  ,p_entry_value8                  => l_entry_value8
  ,p_entry_value9                  => l_entry_value9
  ,p_entry_value10                 => l_entry_value10
  ,p_entry_value11                 => l_entry_value11
  ,p_entry_value12                 => l_entry_value12
  ,p_entry_value13                 => l_entry_value13
  ,p_entry_value14                 => l_entry_value14
  ,p_entry_value15                 => l_entry_value15
  ,p_entry_information_category    => p_entry_information_category
  ,p_entry_information1            => p_entry_information1
  ,p_entry_information2            => p_entry_information2
  ,p_entry_information3            => p_entry_information3
  ,p_entry_information4            => p_entry_information4
  ,p_entry_information5            => p_entry_information5
  ,p_entry_information6            => p_entry_information6
  ,p_entry_information7            => p_entry_information7
  ,p_entry_information8            => p_entry_information8
  ,p_entry_information9            => p_entry_information9
  ,p_entry_information10           => p_entry_information10
  ,p_entry_information11           => p_entry_information11
  ,p_entry_information12           => p_entry_information12
  ,p_entry_information13           => p_entry_information13
  ,p_entry_information14           => p_entry_information14
  ,p_entry_information15           => p_entry_information15
  ,p_entry_information16           => p_entry_information16
  ,p_entry_information17           => p_entry_information17
  ,p_entry_information18           => p_entry_information18
  ,p_entry_information19           => p_entry_information19
  ,p_entry_information20           => p_entry_information20
  ,p_entry_information21           => p_entry_information21
  ,p_entry_information22           => p_entry_information22
  ,p_entry_information23           => p_entry_information23
  ,p_entry_information24           => p_entry_information24
  ,p_entry_information25           => p_entry_information25
  ,p_entry_information26           => p_entry_information26
  ,p_entry_information27           => p_entry_information27
  ,p_entry_information28           => p_entry_information28
  ,p_entry_information29           => p_entry_information29
  ,p_entry_information30           => p_entry_information30
  ,p_effective_start_date          => l_effective_start_date
  ,p_effective_end_date            => l_effective_end_date
  ,p_update_warning                => l_update_warning
  );

  exception

  when  app_exception.application_exception then
  if(p_validate = 1) then
    fnd_msg_pub.add;
    /*
      fnd_message.parse_encoded(fnd_message.get_encoded,l_app_name,l_msg_name);
       if('HR_34927_ELE_ENTRY_VSET_INVLD'= l_msg_name) then
       fnd_message.set_name('PER', 'HR_34927_ELE_ENTRY_VSET_INVLD');
       fnd_msg_pub.add;
       else
       fnd_message.set_name(l_app_name, l_msg_name);
       fnd_msg_pub.add;
       end if;
     */
  else
    raise;
  end if ;

  when OTHERS THEN
        raise;

end ICD_UPDATE_ELEMENT_ENTRY;


PROCEDURE ICD_CREATE_ELEMENT_ENTRY
  (p_validate                      in     number  default 0
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_assignment_id                 in     number
  ,p_element_link_id               in     number
  ,p_entry_type                    in     varchar2
  ,p_cost_allocation_keyflex_id    in     number
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  ,p_input_value_id1               in     number
  ,p_input_value_id2               in     number
  ,p_input_value_id3               in     number
  ,p_input_value_id4               in     number
  ,p_input_value_id5               in     number
  ,p_input_value_id6               in     number
  ,p_input_value_id7               in     number
  ,p_input_value_id8               in     number
  ,p_input_value_id9               in     number
  ,p_input_value_id10              in     number
  ,p_input_value_id11              in     number
  ,p_input_value_id12              in     number
  ,p_input_value_id13              in     number
  ,p_input_value_id14              in     number
  ,p_input_value_id15              in     number
  ,p_entry_value1                  in     varchar2
  ,p_entry_value2                  in     varchar2
  ,p_entry_value3                  in     varchar2
  ,p_entry_value4                  in     varchar2
  ,p_entry_value5                  in     varchar2
  ,p_entry_value6                  in     varchar2
  ,p_entry_value7                  in     varchar2
  ,p_entry_value8                  in     varchar2
  ,p_entry_value9                  in     varchar2
  ,p_entry_value10                 in     varchar2
  ,p_entry_value11                 in     varchar2
  ,p_entry_value12                 in     varchar2
  ,p_entry_value13                 in     varchar2
  ,p_entry_value14                 in     varchar2
  ,p_entry_value15                 in     varchar2
  ,p_entry_information_category    in     varchar2
  ,p_entry_information1            in     varchar2
  ,p_entry_information2            in     varchar2
  ,p_entry_information3            in     varchar2
  ,p_entry_information4            in     varchar2
  ,p_entry_information5            in     varchar2
  ,p_entry_information6            in     varchar2
  ,p_entry_information7            in     varchar2
  ,p_entry_information8            in     varchar2
  ,p_entry_information9            in     varchar2
  ,p_entry_information10           in     varchar2
  ,p_entry_information11           in     varchar2
  ,p_entry_information12           in     varchar2
  ,p_entry_information13           in     varchar2
  ,p_entry_information14           in     varchar2
  ,p_entry_information15           in     varchar2
  ,p_entry_information16           in     varchar2
  ,p_entry_information17           in     varchar2
  ,p_entry_information18           in     varchar2
  ,p_entry_information19           in     varchar2
  ,p_entry_information20           in     varchar2
  ,p_entry_information21           in     varchar2
  ,p_entry_information22           in     varchar2
  ,p_entry_information23           in     varchar2
  ,p_entry_information24           in     varchar2
  ,p_entry_information25           in     varchar2
  ,p_entry_information26           in     varchar2
  ,p_entry_information27           in     varchar2
  ,p_entry_information28           in     varchar2
  ,p_entry_information29           in     varchar2
  ,p_entry_information30           in     varchar2
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
--   ,p_icd_effective_date           in     date
--   ,p_warning                      out  nocopy  number
  ) is

cursor c_input_values is
select * from
pay_input_values_f
where element_type_id = (select element_type_id from pay_element_links_f where
element_link_id = p_element_link_id and p_effective_date between effective_start_date and effective_end_date)
and p_effective_date between effective_start_date and effective_end_date
order by input_value_id asc;

l_effective_start_date date;
l_effective_end_date date;
l_create_warning boolean;
l_object_version_number number;
l_element_entry_id number;
l_validate boolean;
l_entry_value1 varchar2(60);
l_entry_value2 varchar2(60);
l_entry_value3 varchar2(60);
l_entry_value4 varchar2(60);
l_entry_value5 varchar2(60);
l_entry_value6 varchar2(60);
l_entry_value7 varchar2(60);
l_entry_value8 varchar2(60);
l_entry_value9 varchar2(60);
l_entry_value10 varchar2(60);
l_entry_value11 varchar2(60);
l_entry_value12 varchar2(60);
l_entry_value13 varchar2(60);
l_entry_value14 varchar2(60);
l_entry_value15 varchar2(60);
l_delete_warning	boolean;
--changes for ICD number formatting issue
icx_numeric varchar2(20);

  l_app_name varchar2(50);
   l_msg_name varchar2(30);

begin
  fnd_msg_pub.initialize;
l_validate := false;
if p_validate = 1 then
	l_validate := true;
end if;

icx_numeric := fnd_profile.value('ICX_NUMERIC_CHARACTERS');

savepoint create_entry;
for l_input_value in c_input_values loop
   if(p_input_value_id1 = l_input_value.input_value_id ) then
       -- the format coming in is already canonical but the api is expecting a user format
      if( 'D' = l_input_value.uom) then
        l_entry_value1 := fnd_date.date_to_displaydate(to_date(p_entry_value1,'YYYY/MM/DD HH24:MI:SS'));
      elsif ('M' = l_input_value.uom and icx_numeric <>  '.,')then
      l_entry_value1 := replace(p_entry_value1,'.',',');
      else
        l_entry_value1 := p_entry_value1;
      end if ;
   elsif(p_input_value_id2 = l_input_value.input_value_id ) then
      if( 'D' = l_input_value.uom) then
        l_entry_value2 := fnd_date.date_to_displaydate(to_date(p_entry_value2,'YYYY/MM/DD HH24:MI:SS'));
              elsif ('M' = l_input_value.uom and icx_numeric <>  '.,')then
      l_entry_value2 := replace(p_entry_value2,'.',',');
       else
        l_entry_value2 := p_entry_value2;
     end if ;

   elsif(p_input_value_id3 = l_input_value.input_value_id) then
        if( 'D' = l_input_value.uom) then
        l_entry_value3 := fnd_date.date_to_displaydate(to_date(p_entry_value3,'YYYY/MM/DD HH24:MI:SS'));
              elsif ('M' = l_input_value.uom and icx_numeric <>  '.,')then
      l_entry_value3 := replace(p_entry_value3,'.',',');
        else
        l_entry_value3 := p_entry_value3;
        end if ;

   elsif(p_input_value_id4 = l_input_value.input_value_id) then
        if( 'D' = l_input_value.uom) then
        l_entry_value4 := fnd_date.date_to_displaydate(to_date(p_entry_value4,'YYYY/MM/DD HH24:MI:SS'));
              elsif ('M' = l_input_value.uom and icx_numeric <>  '.,')then
      l_entry_value4 := replace(p_entry_value4,'.',',');
        else
        l_entry_value4 := p_entry_value4;
     end if ;

   elsif(p_input_value_id5 = l_input_value.input_value_id) then
        if( 'D' = l_input_value.uom) then
        l_entry_value5 := fnd_date.date_to_displaydate(to_date(p_entry_value5,'YYYY/MM/DD HH24:MI:SS'));
              elsif ('M' = l_input_value.uom and icx_numeric <>  '.,')then
      l_entry_value5 := replace(p_entry_value5,'.',',');
       else
        l_entry_value5 := p_entry_value5;
       end if ;

   elsif(p_input_value_id6 = l_input_value.input_value_id) then
        if( 'D' = l_input_value.uom) then
        l_entry_value6 := fnd_date.date_to_displaydate(to_date(p_entry_value6,'YYYY/MM/DD HH24:MI:SS'));
              elsif ('M' = l_input_value.uom and icx_numeric <>  '.,')then
      l_entry_value6 := replace(p_entry_value6,'.',',');
        else
        l_entry_value6 := p_entry_value6;
       end if ;

   elsif(p_input_value_id7 = l_input_value.input_value_id ) then
       if( 'D' = l_input_value.uom) then
        l_entry_value7 := fnd_date.date_to_displaydate(to_date(p_entry_value7,'YYYY/MM/DD HH24:MI:SS'));
              elsif ('M' = l_input_value.uom and icx_numeric <>  '.,')then
      l_entry_value7 := replace(p_entry_value7,'.',',');
             else
        l_entry_value7 := p_entry_value7;
     end if ;

   elsif(p_input_value_id8 = l_input_value.input_value_id) then
        if( 'D' = l_input_value.uom) then
        l_entry_value8 := fnd_date.date_to_displaydate(to_date(p_entry_value8,'YYYY/MM/DD HH24:MI:SS'));
              elsif ('M' = l_input_value.uom and icx_numeric <>  '.,')then
      l_entry_value8 := replace(p_entry_value8,'.',',');
        else
        l_entry_value8 := p_entry_value8;
        end if ;

   elsif(p_input_value_id9 = l_input_value.input_value_id) then
       if( 'D' = l_input_value.uom) then
        l_entry_value9 := fnd_date.date_to_displaydate(to_date(p_entry_value9,'YYYY/MM/DD HH24:MI:SS'));
              elsif ('M' = l_input_value.uom and icx_numeric <>  '.,')then
      l_entry_value9 := replace(p_entry_value9,'.',',');
       else
        l_entry_value9 := p_entry_value9;
       end if ;
   elsif(p_input_value_id10 = l_input_value.input_value_id) then
       if( 'D' = l_input_value.uom) then
        l_entry_value10 := fnd_date.date_to_displaydate(to_date(p_entry_value10,'YYYY/MM/DD HH24:MI:SS'));
              elsif ('M' = l_input_value.uom and icx_numeric <>  '.,')then
      l_entry_value10 := replace(p_entry_value10,'.',',');
       else
        l_entry_value10 := p_entry_value10;
       end if ;
   elsif(p_input_value_id11 = l_input_value.input_value_id) then
       if( 'D' = l_input_value.uom) then
        l_entry_value11 := fnd_date.date_to_displaydate(to_date(p_entry_value11,'YYYY/MM/DD HH24:MI:SS'));
              elsif ('M' = l_input_value.uom and icx_numeric <>  '.,')then
      l_entry_value11 := replace(p_entry_value11,'.',',');
        else
        l_entry_value11 := p_entry_value11;
        end if ;
   elsif(p_input_value_id12 = l_input_value.input_value_id) then
       if( 'D' = l_input_value.uom) then
        l_entry_value12 := fnd_date.date_to_displaydate(to_date(p_entry_value12,'YYYY/MM/DD HH24:MI:SS'));
              elsif ('M' = l_input_value.uom and icx_numeric <>  '.,')then
      l_entry_value12 := replace(p_entry_value12,'.',',');
       else
        l_entry_value12 := p_entry_value12;
       end if ;
    elsif(p_input_value_id13 = l_input_value.input_value_id) then
       if( 'D' = l_input_value.uom) then
        l_entry_value13 := fnd_date.date_to_displaydate(to_date(p_entry_value13,'YYYY/MM/DD HH24:MI:SS'));
              elsif ('M' = l_input_value.uom and icx_numeric <>  '.,')then
      l_entry_value13 := replace(p_entry_value13,'.',',');
       else
        l_entry_value13 := p_entry_value13;
       end if ;
   elsif(p_input_value_id14 = l_input_value.input_value_id ) then
       if( 'D' = l_input_value.uom) then
        l_entry_value14 := fnd_date.date_to_displaydate(to_date(p_entry_value14,'YYYY/MM/DD HH24:MI:SS'));
              elsif ('M' = l_input_value.uom and icx_numeric <>  '.,')then
      l_entry_value14 := replace(p_entry_value14,'.',',');
        else
        l_entry_value14 := p_entry_value14;
     end if ;

   elsif(p_input_value_id15 = l_input_value.input_value_id) then
       if( 'D' = l_input_value.uom) then
        l_entry_value15 := fnd_date.date_to_displaydate(to_date(p_entry_value15,'YYYY/MM/DD HH24:MI:SS'));
              elsif ('M' = l_input_value.uom and icx_numeric <>  '.,')then
      l_entry_value15 := replace(p_entry_value15,'.',',');
       else
        l_entry_value15 := p_entry_value15;
       end if ;
   end if;
   end loop;
pay_element_entry_api.create_element_entry
  (p_validate                      => false
  ,p_effective_date                => p_effective_date
  ,p_business_group_id             => p_business_group_id
  ,p_assignment_id                 => p_assignment_id
  ,p_element_link_id               => p_element_link_id
  ,p_entry_type                    => p_entry_type
  ,p_cost_allocation_keyflex_id    => p_cost_allocation_keyflex_id
  ,p_attribute_category            => p_attribute_category
  ,p_attribute1                    => p_attribute1
  ,p_attribute2                    => p_attribute2
  ,p_attribute3                    => p_attribute3
  ,p_attribute4                    => p_attribute4
  ,p_attribute5                    => p_attribute5
  ,p_attribute6                    => p_attribute6
  ,p_attribute7                    => p_attribute7
  ,p_attribute8                    => p_attribute8
  ,p_attribute9                    => p_attribute9
  ,p_attribute10                   => p_attribute10
  ,p_attribute11                   => p_attribute11
  ,p_attribute12                   => p_attribute12
  ,p_attribute13                   => p_attribute13
  ,p_attribute14                   => p_attribute14
  ,p_attribute15                   => p_attribute15
  ,p_attribute16                   => p_attribute16
  ,p_attribute17                   => p_attribute17
  ,p_attribute18                   => p_attribute18
  ,p_attribute19                   => p_attribute19
  ,p_attribute20                   => p_attribute20
  ,p_input_value_id1               => p_input_value_id1
  ,p_input_value_id2               => p_input_value_id2
  ,p_input_value_id3               => p_input_value_id3
  ,p_input_value_id4               => p_input_value_id4
  ,p_input_value_id5               => p_input_value_id5
  ,p_input_value_id6               => p_input_value_id6
  ,p_input_value_id7               => p_input_value_id7
  ,p_input_value_id8               => p_input_value_id8
  ,p_input_value_id9               => p_input_value_id9
  ,p_input_value_id10              => p_input_value_id10
  ,p_input_value_id11              => p_input_value_id11
  ,p_input_value_id12              => p_input_value_id12
  ,p_input_value_id13              => p_input_value_id13
  ,p_input_value_id14              => p_input_value_id14
  ,p_input_value_id15              => p_input_value_id15
  ,p_entry_value1                  => l_entry_value1
  ,p_entry_value2                  => l_entry_value2
  ,p_entry_value3                  => l_entry_value3
  ,p_entry_value4                  => l_entry_value4
  ,p_entry_value5                  => l_entry_value5
  ,p_entry_value6                  => l_entry_value6
  ,p_entry_value7                  => l_entry_value7
  ,p_entry_value8                  => l_entry_value8
  ,p_entry_value9                  => l_entry_value9
  ,p_entry_value10                 => l_entry_value10
  ,p_entry_value11                 => l_entry_value11
  ,p_entry_value12                 => l_entry_value12
  ,p_entry_value13                 => l_entry_value13
  ,p_entry_value14                 => l_entry_value14
  ,p_entry_value15                 => l_entry_value15
  ,p_entry_information_category    => p_entry_information_category
  ,p_entry_information1            => p_entry_information1
  ,p_entry_information2            => p_entry_information2
  ,p_entry_information3            => p_entry_information3
  ,p_entry_information4            => p_entry_information4
  ,p_entry_information5            => p_entry_information5
  ,p_entry_information6            => p_entry_information6
  ,p_entry_information7            => p_entry_information7
  ,p_entry_information8            => p_entry_information8
  ,p_entry_information9            => p_entry_information9
  ,p_entry_information10           => p_entry_information10
  ,p_entry_information11           => p_entry_information11
  ,p_entry_information12           => p_entry_information12
  ,p_entry_information13           => p_entry_information13
  ,p_entry_information14           => p_entry_information14
  ,p_entry_information15           => p_entry_information15
  ,p_entry_information16           => p_entry_information16
  ,p_entry_information17           => p_entry_information17
  ,p_entry_information18           => p_entry_information18
  ,p_entry_information19           => p_entry_information19
  ,p_entry_information20           => p_entry_information20
  ,p_entry_information21           => p_entry_information21
  ,p_entry_information22           => p_entry_information22
  ,p_entry_information23           => p_entry_information23
  ,p_entry_information24           => p_entry_information24
  ,p_entry_information25           => p_entry_information25
  ,p_entry_information26           => p_entry_information26
  ,p_entry_information27           => p_entry_information27
  ,p_entry_information28           => p_entry_information28
  ,p_entry_information29           => p_entry_information29
  ,p_entry_information30           => p_entry_information30
  ,p_effective_start_date          => l_effective_start_date
  ,p_effective_end_date            => l_effective_end_date
  ,p_element_entry_id              => l_element_entry_id
  ,p_object_version_number         => l_object_version_number
  ,p_create_warning                => l_create_warning
  );

  -- try to end date the entry if it was entered on the page.
  if(p_effective_end_date is not null and p_effective_end_date <> hr_api.g_eot) then
    -- we need to call the delete for this record.
    -- if this is a non recurring entry then the end date might be after the effective_end_date
    -- of the record, we need not delete in that case.
    if( p_effective_end_date < l_effective_end_date) then
     pay_element_entry_api.delete_element_entry
    (p_validate                      => false
    ,p_datetrack_delete_mode         => hr_api.g_delete
     ,p_effective_date               => p_effective_end_date
     ,p_element_entry_id             => l_element_entry_id
     ,p_object_version_number        => l_object_version_number
     ,p_effective_start_date         => l_effective_start_date
     ,p_effective_end_date           => l_effective_end_date
     ,p_delete_warning               => l_delete_warning
     );
     end if;
   end if;

 if(l_validate) then
   rollback to create_entry;
 end if;
exception

   when  app_exception.application_exception then
     rollback to create_entry;
  if(p_validate = 1) then
       fnd_msg_pub.add;
   /*
   -- this is when we look for the multiple entries allowed exception
	   fnd_message.parse_encoded(fnd_message.get_encoded,l_app_name,l_msg_name);
   	   if('HR_7455_PLK_ELE_ENTRY_EXISTS'= l_msg_name) then
       fnd_message.set_name('BEN', 'BEN_ICD_ELE_EXISTS');
       fnd_msg_pub.add;
       elsif('HR_34927_ELE_ENTRY_VSET_INVLD'= l_msg_name) then
       fnd_message.set_name('PER', 'HR_34927_ELE_ENTRY_VSET_INVLD');
       fnd_msg_pub.add;
       else
       fnd_message.set_name(l_app_name, l_msg_name);
       fnd_msg_pub.add;
       end if;
    */
  else
      -- this is when its being called from the final process api after approval
      raise;
  end if ;
    when OTHERS THEN
       rollback to create_entry;
       raise;

end ICD_CREATE_ELEMENT_ENTRY;

PROCEDURE ICD_DELETE_ELEMENT_ENTRY(
   p_validate			in number default 0
   ,p_datetrack_delete_mode	in varchar2
   ,p_effective_date		in date
   ,p_element_entry_id		in number
   ,p_object_version_number	in number
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
--   ,p_icd_effective_date    in date
--   ,p_warning                      out  nocopy  number
	) is
l_object_version_number number;
l_effective_start_date	date;
l_effective_end_date	date;
l_delete_warning	boolean;
l_validate		boolean;
  l_app_name varchar2(50);
   l_msg_name varchar2(30);

begin
  fnd_msg_pub.initialize;
	l_object_version_number := p_object_version_number;
	l_validate := false;
	if p_validate = 1 then
		l_validate := true;
	end if;

pay_element_entry_api.delete_element_entry
  (p_validate                      => l_validate
  ,p_datetrack_delete_mode         => get_datetrack_mode(p_element_entry_id,p_effective_start_date,p_effective_date,p_datetrack_delete_mode)
  ,p_effective_date                => p_effective_date
  ,p_element_entry_id              => p_element_entry_id
  ,p_object_version_number         => l_object_version_number
  ,p_effective_start_date          => l_effective_start_date
  ,p_effective_end_date            => l_effective_end_date
  ,p_delete_warning                => l_delete_warning
  );

  exception

  when  app_exception.application_exception then
   if(p_validate = 1) then
     fnd_msg_pub.add;
   /*
       fnd_message.parse_encoded(fnd_message.get_encoded,l_app_name,l_msg_name);
       if('HR_33000_ENTRY_CANT_PURGE'= l_msg_name) then
       fnd_message.set_name('PER', 'HR_33000_ENTRY_CANT_PURGE');
       fnd_msg_pub.add;
       else
       fnd_message.set_name(l_app_name, l_msg_name);
       fnd_msg_pub.add;
       end if;
    */
   else
     raise;
   end if ;

  when others then
   raise;
end  ICD_DELETE_ELEMENT_ENTRY;

-----------------------------Get Hr Transaction Api----------------------

procedure GET_HR_TRANSACTION_ID
	(
	p_item_type                     in varchar2
	,p_item_key                     in varchar2
	,p_activity_id                   in number
	,p_login_person_id              in number
	,p_person_id			in number
	,p_transaction_id		out nocopy number
	,p_transaction_step_id		out nocopy number
	) is
--
cursor c_txn_step(p_transaction_id number) is
  select hats.transaction_step_id
   from    hr_api_transaction_steps   hats
   where   hats.transaction_id = p_transaction_id
   and     hats.api_name    = upper(g_package || 'process_api')
   order by hats.transaction_step_id;
--
  l_transaction_id                number := null;
  l_transaction_step_id           number := null;
  l_result                        varchar2(100);
  l_trans_obj_vers_num            number;
  l_processing_order              number := 1;
--
begin
	l_transaction_id := hr_transaction_ss.get_transaction_id
                     (p_item_type   => p_item_type
                     ,p_item_key    => p_item_key);

	if l_transaction_id is null then
		hr_transaction_ss.start_transaction
		(itemtype   => p_item_type
		,itemkey    => p_item_key
		,actid      => p_activity_id
		,funmode    => 'RUN'
		,p_login_person_id => p_login_person_id
		,result     => l_result);

		l_transaction_id := hr_transaction_ss.get_transaction_id
		       (p_item_type   => p_item_type
		       ,p_item_key    => p_item_key);
	end if;

  --
  -- get the transaction_step_id
  --
  Open c_txn_step(l_transaction_id);
  Fetch c_txn_step into l_transaction_step_id;
  Close c_txn_step;

  -- if it is not available, create it.
  if l_transaction_step_id is null then
     --
     hr_transaction_api.create_transaction_step
     (p_validate              => false
     ,p_creator_person_id     => p_login_person_id
     ,p_transaction_id        => l_transaction_id
     ,p_api_name              => upper(g_package || 'process_api')
     ,p_item_type             => p_item_type
     ,p_item_key              => p_item_key
     ,p_activity_id           => p_activity_id
     ,p_transaction_step_id   => l_transaction_step_id
     ,p_object_version_number => l_trans_obj_vers_num);
     --
     -- insert a row in the transaction values table.
     hr_transaction_api.set_varchar2_value
     (p_transaction_step_id => l_transaction_step_id
     ,p_person_id           => p_login_person_id
     ,p_name                => 'P_REVIEW_PROC_CALL'
     ,p_value               => 'BenAdvancedCompensation');

     hr_transaction_api.set_varchar2_value
     (p_transaction_step_id => l_transaction_step_id
     ,p_person_id           => p_login_person_id
     ,p_name                => 'P_REVIEW_ACTID'
     ,p_value               => to_char(p_activity_id));


   end if;
   p_transaction_id := l_transaction_id;
   p_transaction_step_id := l_transaction_step_id;

end GET_HR_TRANSACTION_ID;

procedure process_transaction_row
(p_transaction_row in ben_icd_transaction%rowtype
,p_validate in number
,p_icd_effective_date in date)
is
l_warning  number;
effectiveDate Date ;
begin

 IF 'UPDATE' = p_transaction_row.dml_operation then
    if(p_transaction_row.effective_date is null )then
	    if(p_transaction_row.effective_start_date > trunc(sysdate) ) then
	       effectiveDate := p_transaction_row.effective_start_date;
	    else
		    effectiveDate := trunc(sysdate);
		end if;
	else
	     	effectiveDate := p_transaction_row.effective_date;
	end if;
    ICD_UPDATE_ELEMENT_ENTRY
	  (p_validate                     => p_validate
	  ,p_datetrack_update_mode        => p_transaction_row.datetrack_mode
	  ,p_effective_date               => effectiveDate
	  ,p_business_group_id            => p_transaction_row.business_group_id
	  ,p_element_entry_id             => p_transaction_row.element_entry_id
	  ,p_object_version_number        => p_transaction_row.e_object_version_number
	  ,p_cost_allocation_keyflex_id   => p_transaction_row.cost_allocation_keyflex_id
	  ,p_attribute_category           => p_transaction_row.attribute_category
	  ,p_attribute1                   => p_transaction_row.attribute1
	  ,p_attribute2                   => p_transaction_row.attribute2
	  ,p_attribute3                   => p_transaction_row.attribute3
	  ,p_attribute4                   => p_transaction_row.attribute4
	  ,p_attribute5                   => p_transaction_row.attribute5
	  ,p_attribute6                   => p_transaction_row.attribute6
	  ,p_attribute7                   => p_transaction_row.attribute7
	  ,p_attribute8                   => p_transaction_row.attribute8
	  ,p_attribute9                   => p_transaction_row.attribute9
	  ,p_attribute10                  => p_transaction_row.attribute10
	  ,p_attribute11                  => p_transaction_row.attribute11
	  ,p_attribute12                  => p_transaction_row.attribute12
	  ,p_attribute13                  => p_transaction_row.attribute13
	  ,p_attribute14                  => p_transaction_row.attribute14
	  ,p_attribute15                  => p_transaction_row.attribute15
	  ,p_attribute16                  => p_transaction_row.attribute16
	  ,p_attribute17                  => p_transaction_row.attribute17
	  ,p_attribute18                  => p_transaction_row.attribute18
	  ,p_attribute19                  => p_transaction_row.attribute19
	  ,p_attribute20                  => p_transaction_row.attribute20
	  ,p_input_value_id1              => p_transaction_row.input_value_id1
	  ,p_input_value_id2              => p_transaction_row.input_value_id2
	  ,p_input_value_id3              => p_transaction_row.input_value_id3
	  ,p_input_value_id4              => p_transaction_row.input_value_id4
	  ,p_input_value_id5              => p_transaction_row.input_value_id5
	  ,p_input_value_id6              => p_transaction_row.input_value_id6
	  ,p_input_value_id7              => p_transaction_row.input_value_id7
	  ,p_input_value_id8              => p_transaction_row.input_value_id8
	  ,p_input_value_id9              => p_transaction_row.input_value_id9
	  ,p_input_value_id10             => p_transaction_row.input_value_id10
	  ,p_input_value_id11             => p_transaction_row.input_value_id11
	  ,p_input_value_id12             => p_transaction_row.input_value_id12
	  ,p_input_value_id13             => p_transaction_row.input_value_id13
	  ,p_input_value_id14             => p_transaction_row.input_value_id14
	  ,p_input_value_id15             => p_transaction_row.input_value_id15
	  ,p_entry_value1                 => p_transaction_row.input_value1
	  ,p_entry_value2                 => p_transaction_row.input_value2
	  ,p_entry_value3                 => p_transaction_row.input_value3
	  ,p_entry_value4                 => p_transaction_row.input_value4
	  ,p_entry_value5                 => p_transaction_row.input_value5
	  ,p_entry_value6                 => p_transaction_row.input_value6
	  ,p_entry_value7                 => p_transaction_row.input_value7
	  ,p_entry_value8                 => p_transaction_row.input_value8
	  ,p_entry_value9                 => p_transaction_row.input_value9
	  ,p_entry_value10                => p_transaction_row.input_value10
	  ,p_entry_value11                => p_transaction_row.input_value11
	  ,p_entry_value12                => p_transaction_row.input_value12
	  ,p_entry_value13                => p_transaction_row.input_value13
	  ,p_entry_value14                => p_transaction_row.input_value14
	  ,p_entry_value15                => p_transaction_row.input_value15
	  ,p_entry_information_category   => p_transaction_row.entry_information_category
	  ,p_entry_information1           => p_transaction_row.entry_information1
	  ,p_entry_information2           => p_transaction_row.entry_information2
	  ,p_entry_information3           => p_transaction_row.entry_information3
	  ,p_entry_information4           => p_transaction_row.entry_information4
	  ,p_entry_information5           => p_transaction_row.entry_information5
	  ,p_entry_information6           => p_transaction_row.entry_information6
	  ,p_entry_information7           => p_transaction_row.entry_information7
	  ,p_entry_information8           => p_transaction_row.entry_information8
	  ,p_entry_information9           => p_transaction_row.entry_information9
	  ,p_entry_information10          => p_transaction_row.entry_information10
	  ,p_entry_information11          => p_transaction_row.entry_information11
	  ,p_entry_information12          => p_transaction_row.entry_information12
	  ,p_entry_information13          => p_transaction_row.entry_information13
	  ,p_entry_information14          => p_transaction_row.entry_information14
	  ,p_entry_information15          => p_transaction_row.entry_information15
	  ,p_entry_information16          => p_transaction_row.entry_information16
	  ,p_entry_information17          => p_transaction_row.entry_information17
	  ,p_entry_information18          => p_transaction_row.entry_information18
	  ,p_entry_information19          => p_transaction_row.entry_information19
	  ,p_entry_information20          => p_transaction_row.entry_information20
	  ,p_entry_information21          => p_transaction_row.entry_information21
	  ,p_entry_information22          => p_transaction_row.entry_information22
	  ,p_entry_information23          => p_transaction_row.entry_information23
	  ,p_entry_information24          => p_transaction_row.entry_information24
	  ,p_entry_information25          => p_transaction_row.entry_information25
	  ,p_entry_information26          => p_transaction_row.entry_information26
	  ,p_entry_information27          => p_transaction_row.entry_information27
	  ,p_entry_information28          => p_transaction_row.entry_information28
	  ,p_entry_information29          => p_transaction_row.entry_information29
	  ,p_entry_information30          => p_transaction_row.entry_information30
      ,p_effective_start_date         => p_transaction_row.effective_start_Date
      ,p_effective_end_date           => p_transaction_row.effective_end_date
	  --,p_icd_effective_date           => p_icd_effective_date
  	  --,p_warning                      => l_warning
	  );
   elsif ('INSERT' = p_transaction_row.dml_operation) then
	ICD_CREATE_ELEMENT_ENTRY
	  (p_validate                     => p_validate
	  ,p_effective_date               => nvl(p_transaction_row.effective_date,TRUNC(SYSDATE))
	  ,p_business_group_id            => p_transaction_row.business_group_id
  	  ,p_assignment_id                => p_transaction_row.assignment_id
      ,p_element_link_id              => p_transaction_row.element_link_id
      ,p_entry_type                   => 'E'
	  ,p_cost_allocation_keyflex_id   => p_transaction_row.cost_allocation_keyflex_id
	  ,p_attribute_category           => p_transaction_row.attribute_category
	  ,p_attribute1                   => p_transaction_row.attribute1
	  ,p_attribute2                   => p_transaction_row.attribute2
	  ,p_attribute3                   => p_transaction_row.attribute3
	  ,p_attribute4                   => p_transaction_row.attribute4
	  ,p_attribute5                   => p_transaction_row.attribute5
	  ,p_attribute6                   => p_transaction_row.attribute6
	  ,p_attribute7                   => p_transaction_row.attribute7
	  ,p_attribute8                   => p_transaction_row.attribute8
	  ,p_attribute9                   => p_transaction_row.attribute9
	  ,p_attribute10                  => p_transaction_row.attribute10
	  ,p_attribute11                  => p_transaction_row.attribute11
	  ,p_attribute12                  => p_transaction_row.attribute12
	  ,p_attribute13                  => p_transaction_row.attribute13
	  ,p_attribute14                  => p_transaction_row.attribute14
	  ,p_attribute15                  => p_transaction_row.attribute15
	  ,p_attribute16                  => p_transaction_row.attribute16
	  ,p_attribute17                  => p_transaction_row.attribute17
	  ,p_attribute18                  => p_transaction_row.attribute18
	  ,p_attribute19                  => p_transaction_row.attribute19
	  ,p_attribute20                  => p_transaction_row.attribute20
	  ,p_input_value_id1              => p_transaction_row.input_value_id1
	  ,p_input_value_id2              => p_transaction_row.input_value_id2
	  ,p_input_value_id3              => p_transaction_row.input_value_id3
	  ,p_input_value_id4              => p_transaction_row.input_value_id4
	  ,p_input_value_id5              => p_transaction_row.input_value_id5
	  ,p_input_value_id6              => p_transaction_row.input_value_id6
	  ,p_input_value_id7              => p_transaction_row.input_value_id7
	  ,p_input_value_id8              => p_transaction_row.input_value_id8
	  ,p_input_value_id9              => p_transaction_row.input_value_id9
	  ,p_input_value_id10             => p_transaction_row.input_value_id10
	  ,p_input_value_id11             => p_transaction_row.input_value_id11
	  ,p_input_value_id12             => p_transaction_row.input_value_id12
	  ,p_input_value_id13             => p_transaction_row.input_value_id13
	  ,p_input_value_id14             => p_transaction_row.input_value_id14
	  ,p_input_value_id15             => p_transaction_row.input_value_id15
	  ,p_entry_value1                 => p_transaction_row.input_value1
	  ,p_entry_value2                 => p_transaction_row.input_value2
	  ,p_entry_value3                 => p_transaction_row.input_value3
	  ,p_entry_value4                 => p_transaction_row.input_value4
	  ,p_entry_value5                 => p_transaction_row.input_value5
	  ,p_entry_value6                 => p_transaction_row.input_value6
	  ,p_entry_value7                 => p_transaction_row.input_value7
	  ,p_entry_value8                 => p_transaction_row.input_value8
	  ,p_entry_value9                 => p_transaction_row.input_value9
	  ,p_entry_value10                => p_transaction_row.input_value10
	  ,p_entry_value11                => p_transaction_row.input_value11
	  ,p_entry_value12                => p_transaction_row.input_value12
	  ,p_entry_value13                => p_transaction_row.input_value13
	  ,p_entry_value14                => p_transaction_row.input_value14
	  ,p_entry_value15                => p_transaction_row.input_value15
	  ,p_entry_information_category   => p_transaction_row.entry_information_category
	  ,p_entry_information1           => p_transaction_row.entry_information1
	  ,p_entry_information2           => p_transaction_row.entry_information2
	  ,p_entry_information3           => p_transaction_row.entry_information3
	  ,p_entry_information4           => p_transaction_row.entry_information4
	  ,p_entry_information5           => p_transaction_row.entry_information5
	  ,p_entry_information6           => p_transaction_row.entry_information6
	  ,p_entry_information7           => p_transaction_row.entry_information7
	  ,p_entry_information8           => p_transaction_row.entry_information8
	  ,p_entry_information9           => p_transaction_row.entry_information9
	  ,p_entry_information10          => p_transaction_row.entry_information10
	  ,p_entry_information11          => p_transaction_row.entry_information11
	  ,p_entry_information12          => p_transaction_row.entry_information12
	  ,p_entry_information13          => p_transaction_row.entry_information13
	  ,p_entry_information14          => p_transaction_row.entry_information14
	  ,p_entry_information15          => p_transaction_row.entry_information15
	  ,p_entry_information16          => p_transaction_row.entry_information16
	  ,p_entry_information17          => p_transaction_row.entry_information17
	  ,p_entry_information18          => p_transaction_row.entry_information18
	  ,p_entry_information19          => p_transaction_row.entry_information19
	  ,p_entry_information20          => p_transaction_row.entry_information20
	  ,p_entry_information21          => p_transaction_row.entry_information21
	  ,p_entry_information22          => p_transaction_row.entry_information22
	  ,p_entry_information23          => p_transaction_row.entry_information23
	  ,p_entry_information24          => p_transaction_row.entry_information24
	  ,p_entry_information25          => p_transaction_row.entry_information25
	  ,p_entry_information26          => p_transaction_row.entry_information26
	  ,p_entry_information27          => p_transaction_row.entry_information27
	  ,p_entry_information28          => p_transaction_row.entry_information28
	  ,p_entry_information29          => p_transaction_row.entry_information29
	  ,p_entry_information30          => p_transaction_row.entry_information30
      ,p_effective_start_date         => p_transaction_row.effective_start_Date
      ,p_effective_end_date           => p_transaction_row.effective_end_date
	--  ,p_icd_effective_date           => p_icd_effective_date
  	--  ,p_warning                      => l_warning
	  );
   elsif ('DELETE' = p_transaction_row.dml_operation) then
	  ICD_DELETE_ELEMENT_ENTRY(
	    p_validate			=> p_validate
	   ,p_datetrack_delete_mode	=> p_transaction_row.datetrack_mode
	   ,p_effective_date		=> p_transaction_row.effective_date
	   ,p_element_entry_id		=> p_transaction_row.element_entry_id
	   ,p_object_version_number	=> p_transaction_row.e_object_version_number
       ,p_effective_start_date  => p_transaction_row.effective_start_Date
       ,p_effective_end_date    => p_transaction_row.effective_end_date
	--   ,p_icd_effective_date  => p_icd_effective_date
   	--  ,p_warning              => l_warning
  	);
   end if;
end process_transaction_row;

procedure create_person_action_items
 (p_person_id in number
 ,p_assignment_id in number
 ,p_pl_id in number
 ,p_icd_transaction_id in number
 ,p_effective_date in date
 ,p_mandatory_action_item out nocopy varchar2
 ) is
 cursor c_action_items is
 select actn.actn_typ_id,popl.pl_id,popl.mandatory,popl.actn_typ_due_dt_cd
 from
 ben_popl_actn_typ_f popl,ben_actn_typ_tl actn
 where popl.pl_id = p_pl_id
 and p_effective_Date between popl.effective_start_Date and popl.effective_end_date
 and actn.language = userenv('LANG')
 and popl.actn_typ_id = actn.actn_typ_id
 and not exists
(select 'Y'
  from ben_person_action_items per
  where per.person_id = p_person_id
  and per.complete_date is not null
  and per.actn_typ_id = actn.actn_typ_id
  and popl.once_or_always <> 'ALW'
  and ((popl.once_or_always = 'ONCE') or
 (popl.once_or_always = 'PLAN' and per.pl_id = popl.pl_id)));
l_returned_date date;
 begin
   p_mandatory_action_item := 'N';
   for l_action_items in c_action_items loop
    l_returned_date:=null;
    if(l_action_items.actn_typ_due_dt_cd is not null) then
	 ben_determine_date.main
     (p_date_cd=>l_action_items.actn_typ_due_dt_cd
     ,p_person_id=>p_person_id
     ,p_effective_date=>p_effective_date
     ,p_returned_date=>l_returned_date);
    end if;

     insert into ben_person_action_items
     (PERSON_ACTION_ITEM_ID
      ,ACTN_TYP_ID
      ,TRANSACTION_TYPE
      ,PERSON_ID
      ,ASSIGNMENT_ID
      ,EFFECTIVE_DATE
      ,PL_ID
      ,STATUS
      ,DUE_DATE
      ,OBJECT_VERSION_NUMBER
      ,COMPLETE_DATE
      ,VOID_DATE
      ,TRANSACTION_ID
      )
     values
     (ben_person_action_items_s.nextval
     ,l_action_items.actn_typ_id
     ,'ICD'
     ,p_person_id
     ,p_assignment_id
     ,p_effective_date
     ,p_pl_id
     ,'OPEN'
     ,l_returned_date
     ,1
     ,null
     ,null
     ,p_icd_transaction_id
      );

      if('N' = p_mandatory_action_item) then
         p_mandatory_action_item:= l_action_items.mandatory;
      end if ;
   end loop;

end create_person_action_items;


--This procedure will delete the row from ben_icd_transaction table
procedure delete_transaction_row(p_icd_transaction_id number)
is
begin
delete from ben_icd_transaction where icd_transaction_id = p_icd_transaction_id ;
end delete_transaction_row;

procedure suspend_enrollment(p_icd_transaction_id number)
is
begin
update ben_icd_transaction
 set status = 'SP'
where icd_transaction_id = p_icd_transaction_id;
end suspend_enrollment;



-----------------------------Process API----------------------
Procedure PROCESS_API(
  p_validate                    in boolean default false,
  p_transaction_step_id         in number,
  p_effective_date              in varchar2 default null) is
--
cursor c_icd_transaction is
select *
from ben_icd_transaction
where transaction_id  = (select transaction_id from hr_api_transaction_steps where transaction_step_id = p_transaction_step_id)
order by dml_operation;

  l_proc varchar2(61) := 'process_api' ;
  l_validate number;
  l_effective_date date;
  l_mandatory_action_item varchar2(1);
--
Begin
 hr_utility.set_location('Entering '||l_proc,10);
 if(p_validate) then
   l_validate := 1;
 else
   l_validate := 0;
 end if;

 l_effective_date := to_date(nvl(p_effective_date,to_char(sysdate,'YYYY/MM/DD')), 'YYYY/MM/DD');

 for l_transaction_row in c_icd_transaction loop

 -- create the action items for this award. and if it is mandatory then suspend it.
 -- For action items the effective Date will remain same as passed data.
 -- for element entries effective date will change based on rate codes and other factors.
 --create action items for create and update but not for delete
  if(l_transaction_row.dml_operation <> 'DELETE') then
   create_person_action_items
   (p_person_id => l_transaction_row.person_id
    ,p_assignment_id => l_transaction_row.assignment_id
    ,p_pl_id  => l_transaction_row.pl_id
    ,p_icd_transaction_id =>l_transaction_row.icd_transaction_id
    ,p_effective_date => l_effective_date
    ,p_mandatory_action_item =>l_mandatory_action_item
	);

    if ('Y'= l_mandatory_action_item) then
       suspend_enrollment(l_transaction_row.icd_transaction_id);
      else
       process_transaction_row(l_transaction_row,l_validate,l_effective_date);
    end if;
  else
        process_transaction_row(l_transaction_row,l_validate,l_effective_date);
  end if;
 end loop;

end process_api;



procedure unsuspend_enrollment(p_icd_transaction_id in number, p_effective_Date in date)
is
cursor c_transaction_row is select * from ben_icd_transaction where
icd_transaction_id = p_icd_transaction_id
order by dml_operation,element_entry_id,effective_start_date desc;
l_validate number := 0;
begin
 -- call relevant apis here.
  for l_transaction_row in c_transaction_row loop
     process_transaction_row(l_transaction_row,l_validate,p_effective_date);
     delete_transaction_row(l_transaction_row.icd_transaction_id );
  end loop ;
end unsuspend_enrollment;

END BEN_ICD_ELEMENT_ENTRY_PKG;

/
