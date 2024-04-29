--------------------------------------------------------
--  DDL for Package Body HR_JP_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_JP_UTILITY" as
/* $Header: hrjputil.pkb 120.2 2005/09/07 01:44:55 hikubo noship $ */
--
FUNCTION per_jp_full_name
(
	p_first_name        in varchar2,
	p_middle_names      in varchar2,
	p_last_name         in varchar2,
	p_known_as          in varchar2,
	p_title             in varchar2,
	p_suffix            in varchar2,
	p_pre_name_adjunct  in varchar2,
	p_per_information1  in varchar2,
	p_per_information2  in varchar2,
	p_per_information3  in varchar2,
	p_per_information4  in varchar2,
	p_per_information5  in varchar2,
	p_per_information6  in varchar2,
	p_per_information7  in varchar2,
	p_per_information8  in varchar2,
	p_per_information9  in varchar2,
	p_per_information10 in varchar2,
	p_per_information11 in varchar2,
	p_per_information12 in varchar2,
	p_per_information13 in varchar2,
	p_per_information14 in varchar2,
	p_per_information15 in varchar2,
	p_per_information16 in varchar2,
	p_per_information17 in varchar2,
	p_per_information18 in varchar2,
	p_per_information19 in varchar2,
	p_per_information20 in varchar2,
	p_per_information21 in varchar2,
	p_per_information22 in varchar2,
	p_per_information23 in varchar2,
	p_per_information24 in varchar2,
	p_per_information25 in varchar2,
	p_per_information26 in varchar2,
	p_per_information27 in varchar2,
	p_per_information28 in varchar2,
	p_per_information29 in varchar2,
	p_per_information30 in varchar2
) return varchar2 is
	--
	l_full_name            varchar2(240);
	l_kana_name_delimiter  varchar2(10);
	l_kanji_name_delimiter varchar2(10);
	l_name_type_delimiter  varchar2(10);
	--
begin
	--
	l_kana_name_delimiter  := ' ';
	l_kanji_name_delimiter := ' ';
	l_name_type_delimiter  := ' / ';
	--
	-- Bug Fix 3604541
	--
	-- Remove delimiter slash in only case when Kanji entry is null.
	-- (There is no business case when Kana entry is null because of mandatory column)
	-- This solution is based on precondition that hr_jp_utiltiy.per_jp_full_name funciton
	-- exists for only PER_ALL_PEOPLE_F_NAME trigger, built by hr_build_name_trg_pkg.
	--
	-- Note: There is no issue for update existing format
	--       because trigger just set new full name except for any format validation.
	--
	-- Case of Kanji entry is null
	if (p_per_information18 is null or p_per_information19 is null) then
		--
		l_kanji_name_delimiter := '';
		--
		if (p_per_information18 is null and p_per_information19 is null) then
			l_name_type_delimiter := '';
		end if;
		--
	end if;
	--
	-- Bug Fix 4576110
	-- Remove delimiter between last_name and first_name when first_name is null
	--
	if p_first_name is null then
		l_kana_name_delimiter := '';
	end if;
	--
	l_full_name:=
		p_last_name || l_kana_name_delimiter || p_first_name || l_name_type_delimiter ||
		p_per_information18 || l_kanji_name_delimiter || p_per_information19;
	--
	return (l_full_name);
	--
end per_jp_full_name;

-- Bug 3680631: The function per_jp_order_name was added to the package
-- Code addition for bug 3680631 starts

-----------------------------per_jp_order_name------------------------------
FUNCTION per_jp_order_name(
        p_first_name        in varchar2
       ,p_middle_names      in varchar2
       ,p_last_name         in varchar2
       ,p_known_as          in varchar2
       ,p_title             in varchar2
       ,p_suffix            in varchar2
       ,p_pre_name_adjunct  in varchar2
       ,p_per_information1  in varchar2
       ,p_per_information2  in varchar2
       ,p_per_information3  in varchar2
       ,p_per_information4  in varchar2
       ,p_per_information5  in varchar2
       ,p_per_information6  in varchar2
       ,p_per_information7  in varchar2
       ,p_per_information8  in varchar2
       ,p_per_information9  in varchar2
       ,p_per_information10 in varchar2
       ,p_per_information11 in varchar2
       ,p_per_information12 in varchar2
       ,p_per_information13 in varchar2
       ,p_per_information14 in varchar2
       ,p_per_information15 in varchar2
       ,p_per_information16 in varchar2
       ,p_per_information17 in varchar2
       ,p_per_information18 in varchar2
       ,p_per_information19 in varchar2
       ,p_per_information20 in varchar2
       ,p_per_information21 in varchar2
       ,p_per_information22 in varchar2
       ,p_per_information23 in varchar2
       ,p_per_information24 in varchar2
       ,p_per_information25 in varchar2
       ,p_per_information26 in varchar2
       ,p_per_information27 in varchar2
       ,p_per_information28 in varchar2
       ,p_per_information29 in varchar2
       ,p_per_information30 in varchar2
       ) return varchar2 is
  l_order_name       VARCHAR2(240);
  l_full_name varchar2(240);
  l_kana_name_delimiter varchar2(10);
  l_kanji_name_delimiter varchar2(10);
  l_name_type_delimiter varchar2(10);

BEGIN
  l_kana_name_delimiter := ' ';
  l_kanji_name_delimiter := ' ';
  l_name_type_delimiter := ' / ';
  l_order_name:= p_last_name||l_kanji_name_delimiter||p_first_name;
  return(l_order_name);
END per_jp_order_name;

-- Code addition for bug 3680631 ends.


------------------------------ get_parameter -------------------------------
 /* Name    : get_parameter
  Purpose   : This simply returns the value of a specified parameter in
              a parameter list based of the parameter name.
  Arguments :
  Notes     :
 */
function get_parameter(name in varchar2,
                       parameter_list varchar2) return varchar2
is
  start_ptr number;
  end_ptr   number;
  token_val pay_payroll_actions.legislative_parameters%type;
  par_value pay_payroll_actions.legislative_parameters%type;
begin
--
     token_val := name||'=';
--
     start_ptr := instr(parameter_list, token_val) + length(token_val);
     end_ptr := instr(parameter_list, ' ', start_ptr);
--
     /* if there is no spaces use then length of the string */
     if end_ptr = 0 then
        end_ptr := length(parameter_list)+1;
     end if;
--
     /* Did we find the token */
     if instr(parameter_list, token_val) = 0 then
       par_value := NULL;
     else
       par_value := substr(parameter_list, start_ptr, end_ptr - start_ptr);
     end if;
--
     return par_value;
--
end get_parameter;
-------------------------- DERIVE_HR_LOC_ADDRESS ---------------------------
procedure DERIVE_HR_LOC_ADDRESS
                       (p_tax_name                  in varchar2,
                        p_style                     in varchar2,
                        p_address_line_1            in varchar2,
                        p_address_line_2            in varchar2,
                        p_address_line_3            in varchar2,
                        p_town_or_city              in varchar2,
                        p_country                   in varchar2,
                        p_postal_code               in varchar2,
                        p_region_1                  in varchar2,
                        p_region_2                  in varchar2,
                        p_region_3                  in varchar2,
                        p_telephone_number_1        in varchar2,
                        p_telephone_number_2        in varchar2,
                        p_telephone_number_3        in varchar2,
                        p_loc_information13         in varchar2,
                        p_loc_information14         in varchar2,
                        p_loc_information15         in varchar2,
                        p_loc_information16         in varchar2,
                        p_loc_information17         in varchar2,
                        p_attribute_category        in varchar2,
                        p_attribute1                in varchar2,
                        p_attribute2                in varchar2,
                        p_attribute3                in varchar2,
                        p_attribute4                in varchar2,
                        p_attribute5                in varchar2,
                        p_attribute6                in varchar2,
                        p_attribute7                in varchar2,
                        p_attribute8                in varchar2,
                        p_attribute9                in varchar2,
                        p_attribute10               in varchar2,
                        p_attribute11               in varchar2,
                        p_attribute12               in varchar2,
                        p_attribute13               in varchar2,
                        p_attribute14               in varchar2,
                        p_attribute15               in varchar2,
                        p_attribute16               in varchar2,
                        p_attribute17               in varchar2,
                        p_attribute18               in varchar2,
                        p_attribute19               in varchar2,
                        p_attribute20               in varchar2,
                        p_global_attribute_category in varchar2,
                        p_global_attribute1         in varchar2,
                        p_global_attribute2         in varchar2,
                        p_global_attribute3         in varchar2,
                        p_global_attribute4         in varchar2,
                        p_global_attribute5         in varchar2,
                        p_global_attribute6         in varchar2,
                        p_global_attribute7         in varchar2,
                        p_global_attribute8         in varchar2,
                        p_global_attribute9         in varchar2,
                        p_global_attribute10        in varchar2,
                        p_global_attribute11        in varchar2,
                        p_global_attribute12        in varchar2,
                        p_global_attribute13        in varchar2,
                        p_global_attribute14        in varchar2,
                        p_global_attribute15        in varchar2,
                        p_global_attribute16        in varchar2,
                        p_global_attribute17        in varchar2,
                        p_global_attribute18        in varchar2,
                        p_global_attribute19        in varchar2,
                        p_global_attribute20        in varchar2,
                        p_loc_information18         in varchar2,
                        p_loc_information19         in varchar2,
                        p_loc_information20         in varchar2,
                        p_derived_locale           out nocopy varchar2
                       ) is
begin
  p_derived_locale := p_address_line_1 || ', ' || p_country;
end;
--
------------------------- DERIVE_PER_ADD_ADDRESS ---------------------------
procedure DERIVE_PER_ADD_ADDRESS
                       (p_style                     in varchar2,
                        p_address_line1             in varchar2,
                        p_address_line2             in varchar2,
                        p_address_line3             in varchar2,
                        p_country                   in varchar2,
                        p_date_to                   in date,
                        p_postal_code               in varchar2,
                        p_region_1                  in varchar2,
                        p_region_2                  in varchar2,
                        p_region_3                  in varchar2,
                        p_telephone_number_1        in varchar2,
                        p_telephone_number_2        in varchar2,
                        p_telephone_number_3        in varchar2,
                        p_town_or_city              in varchar2,
                        p_addr_attribute_category   in varchar2,
                        p_addr_attribute1           in varchar2,
                        p_addr_attribute2           in varchar2,
                        p_addr_attribute3           in varchar2,
                        p_addr_attribute4           in varchar2,
                        p_addr_attribute5           in varchar2,
                        p_addr_attribute6           in varchar2,
                        p_addr_attribute7           in varchar2,
                        p_addr_attribute8           in varchar2,
                        p_addr_attribute9           in varchar2,
                        p_addr_attribute10          in varchar2,
                        p_addr_attribute11          in varchar2,
                        p_addr_attribute12          in varchar2,
                        p_addr_attribute13          in varchar2,
                        p_addr_attribute14          in varchar2,
                        p_addr_attribute15          in varchar2,
                        p_addr_attribute16          in varchar2,
                        p_addr_attribute17          in varchar2,
                        p_addr_attribute18          in varchar2,
                        p_addr_attribute19          in varchar2,
                        p_addr_attribute20          in varchar2,
                        p_add_information13         in varchar2,
                        p_add_information14         in varchar2,
                        p_add_information15         in varchar2,
                        p_add_information16         in varchar2,
                        p_add_information17         in varchar2,
                        p_add_information18         in varchar2,
                        p_add_information19         in varchar2,
                        p_add_information20         in varchar2,
                        p_derived_locale           out nocopy varchar2
                       ) is
begin
  p_derived_locale := p_address_line1 || ', ' || p_country;
end;
--
end hr_jp_utility;

/
