--------------------------------------------------------
--  DDL for Package Body HR_KR_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_KR_UTILITY" as
/* $Header: hrkrutil.pkb 115.1 2003/04/15 08:16:22 agore noship $ */
FUNCTION per_kr_full_name(
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
       ) return varchar2 as
  l_full_name       VARCHAR2(240);
begin
    --
    if p_per_information1 is not null and p_per_information2 is not null then
	l_full_name:= p_last_name || p_first_name || '.' ||
		      p_per_information1 || ' ' || p_per_information2;
    elsif p_per_information1 is not null then
	l_full_name:= p_last_name || p_first_name || '.' ||
		      p_per_information1;
    elsif p_per_information2 is not null then
	l_full_name:= p_last_name || p_first_name || '.' ||
		      p_per_information2;
    else
	l_full_name:= p_last_name || p_first_name;
    end if;
    --
    RETURN (l_full_name);
END per_kr_full_name;
end hr_kr_utility;

/
