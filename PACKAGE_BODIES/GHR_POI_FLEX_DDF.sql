--------------------------------------------------------
--  DDL for Package Body GHR_POI_FLEX_DDF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_POI_FLEX_DDF" as
/* $Header: ghpoiddf.pkb 120.7 2005/06/28 11:24:38 vravikan noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '   ghr_poi_flex_ddf.';  -- Global package name



--
-- ----------------------------------------------------------------------------
-- |-------------------------------< ddf >-------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure ddf
	(
		p_position_extra_info_id	in	number	,
		p_position_id			in	number	,
		p_information_type		in	varchar2	,
		p_request_id			in	number	,
		p_program_application_id	in	number	,
		p_program_id			in	number	,
		p_program_update_date		in	date		,
		p_poei_attribute_category	in	varchar2	,
		p_poei_attribute1		in	varchar2	,
		p_poei_attribute2		in	varchar2	,
		p_poei_attribute3		in	varchar2	,
		p_poei_attribute4		in	varchar2	,
		p_poei_attribute5		in	varchar2	,
		p_poei_attribute6		in	varchar2	,
		p_poei_attribute7		in	varchar2	,
		p_poei_attribute8		in	varchar2	,
		p_poei_attribute9		in	varchar2	,
		p_poei_attribute10		in	varchar2	,
		p_poei_attribute11		in	varchar2	,
		p_poei_attribute12		in	varchar2	,
		p_poei_attribute13		in	varchar2	,
		p_poei_attribute14		in	varchar2	,
		p_poei_attribute15		in	varchar2	,
		p_poei_attribute16		in	varchar2	,
		p_poei_attribute17		in	varchar2	,
		p_poei_attribute18		in	varchar2	,
		p_poei_attribute19		in	varchar2	,
		p_poei_attribute20		in	varchar2	,
		p_poei_information_category	in	varchar2	,
		p_poei_information1		in	varchar2	,
		p_poei_information2		in	varchar2	,
		p_poei_information3		in	varchar2	,
		p_poei_information4		in	varchar2	,
		p_poei_information5		in	varchar2	,
		p_poei_information6		in	varchar2	,
		p_poei_information7		in	varchar2	,
		p_poei_information8		in	varchar2	,
		p_poei_information9		in	varchar2	,
		p_poei_information10		in	varchar2	,
		p_poei_information11		in	varchar2	,
		p_poei_information12		in	varchar2	,
		p_poei_information13		in	varchar2	,
		p_poei_information14		in	varchar2	,
		p_poei_information15		in	varchar2	,
		p_poei_information16		in	varchar2	,
		p_poei_information17		in	varchar2	,
		p_poei_information18		in	varchar2	,
		p_poei_information19		in	varchar2	,
		p_poei_information20		in	varchar2	,
		p_poei_information21		in	varchar2	,
		p_poei_information22		in	varchar2	,
		p_poei_information23		in	varchar2	,
		p_poei_information24		in	varchar2	,
		p_poei_information25		in	varchar2	,
		p_poei_information26		in	varchar2	,
		p_poei_information27		in	varchar2	,
		p_poei_information28		in	varchar2	,
		p_poei_information29		in	varchar2	,
		p_poei_information30		in	varchar2
	)
is
--
  l_proc       varchar2(72) := g_package||'ddf';
  l_error      exception;
  l_date_from   date;
--
cursor c_pos_segments(p_session_date in fnd_sessions.effective_date%type)  is
select information6,segment1,segment2,segment3,segment4,
segment5,segment6,segment7
from per_position_definitions pdf, hr_all_positions_f pos
where
pos.position_definition_id = pdf.position_definition_id
and pos.position_id = p_position_id
and p_session_date between pos.effective_start_date and
pos.effective_end_date;
 cursor c_get_session_date is
    select trunc(effective_date) session_date
      from fnd_sessions
      where session_id = (select userenv('sessionid') from dual);

l_session_date date;
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

if ghr_utility.is_ghr = 'TRUE' then
 -- Added by Dinkar Karumuri
if p_information_type is not null
  then
    if p_information_type = 'GHR_US_POSITION_DESCRIPTION'
    then
      chk_date_from
        (p_position_description_id => p_poei_information3
        ,p_date_from              => p_poei_information1
        );
      chk_pos_desc_id
        (p_position_extra_info_id => p_position_extra_info_id
        ,p_pos_desc_id            => p_poei_information3
        );
      chk_date_to
        (p_position_extra_info_id => p_position_extra_info_id
        ,p_date_to                => p_poei_information2
        ,p_date_from              => p_poei_information1
        );
    end if;
  end if;

  if ghr_utility.is_ghr_nfc = 'TRUE' then
 -- Get Session Date
     l_session_date := trunc(sysdate);
   for ses_rec in c_get_session_date loop
     l_session_date := ses_rec.session_date;
   end loop;
	   -- Fetch the current segments from hr_all_positions_f
	   for c_pos_rec in c_pos_segments(l_session_date) loop
	    -- Do not allow modification of EIT segments which are populated
	    -- from the Position KFF
	    -- GHR_US_POS_GRP1 --> Personnel Officer ID

	    if p_information_type = 'GHR_US_POS_GRP1' then
	      if c_pos_rec.segment4 <> p_poei_information3 then
		hr_utility.set_message(8301, 'GHR_38945_NFC_ERROR1');
		hr_utility.raise_error;
	      end if;
	    end if;
	    -- GHR_US_POS_GRP3 --> NFC Agency Code
	    if p_information_type = 'GHR_US_POS_GRP3' then
	      if c_pos_rec.segment3 <> p_poei_information21 then
		hr_utility.set_message(8301, 'GHR_38947_NFC_ERROR3');
		hr_utility.raise_error;
	      end if;
	    end if;
	    -- GHR_US_POS_VALID_GRADE --> Grade From
	    if p_information_type = 'GHR_US_POS_VALID_GRADE' then
	      if c_pos_rec.segment7 <> p_poei_information3 then
		hr_utility.set_message(8301, 'GHR_38946_NFC_ERROR2');
		hr_utility.raise_error;
	      end if;
	    end if;
	   end loop;

end if;  -- ghr_utility.is_ghr_nfc
end if;  -- ghr_utility.is_ghr
  hr_utility.set_location(' Leaving:'||l_proc, 10);
exception
  when l_error then
    hr_utility.set_message(999, 'HR_9999_FLEX_INV_INFO_ARG');
    hr_utility.raise_error;
    hr_utility.set_location(' Leaving:'||l_proc, 10);

end ddf;


procedure create_ddf
	(
		p_position_id			in	number	,
		p_information_type		in	varchar2	,
		p_poei_attribute_category	in	varchar2	,
		p_poei_attribute1		in	varchar2	,
		p_poei_attribute2		in	varchar2	,
		p_poei_attribute3		in	varchar2	,
		p_poei_attribute4		in	varchar2	,
		p_poei_attribute5		in	varchar2	,
		p_poei_attribute6		in	varchar2	,
		p_poei_attribute7		in	varchar2	,
		p_poei_attribute8		in	varchar2	,
		p_poei_attribute9		in	varchar2	,
		p_poei_attribute10		in	varchar2	,
		p_poei_attribute11		in	varchar2	,
		p_poei_attribute12		in	varchar2	,
		p_poei_attribute13		in	varchar2	,
		p_poei_attribute14		in	varchar2	,
		p_poei_attribute15		in	varchar2	,
		p_poei_attribute16		in	varchar2	,
		p_poei_attribute17		in	varchar2	,
		p_poei_attribute18		in	varchar2	,
		p_poei_attribute19		in	varchar2	,
		p_poei_attribute20		in	varchar2	,
		p_poei_information_category	in	varchar2	,
		p_poei_information1		in	varchar2	,
		p_poei_information2		in	varchar2	,
		p_poei_information3		in	varchar2	,
		p_poei_information4		in	varchar2	,
		p_poei_information5		in	varchar2	,
		p_poei_information6		in	varchar2	,
		p_poei_information7		in	varchar2	,
		p_poei_information8		in	varchar2	,
		p_poei_information9		in	varchar2	,
		p_poei_information10		in	varchar2	,
		p_poei_information11		in	varchar2	,
		p_poei_information12		in	varchar2	,
		p_poei_information13		in	varchar2	,
		p_poei_information14		in	varchar2	,
		p_poei_information15		in	varchar2	,
		p_poei_information16		in	varchar2	,
		p_poei_information17		in	varchar2	,
		p_poei_information18		in	varchar2	,
		p_poei_information19		in	varchar2	,
		p_poei_information20		in	varchar2	,
		p_poei_information21		in	varchar2	,
		p_poei_information22		in	varchar2	,
		p_poei_information23		in	varchar2	,
		p_poei_information24		in	varchar2	,
		p_poei_information25		in	varchar2	,
		p_poei_information26		in	varchar2	,
		p_poei_information27		in	varchar2	,
		p_poei_information28		in	varchar2	,
		p_poei_information29		in	varchar2	,
		p_poei_information30		in	varchar2
	)
is
--
  l_proc       varchar2(72) := g_package||'create_ddf';
  l_error      exception;
  l_date_from   date;
--
cursor c_pos_segments(p_session_date in date) is
select information6,segment1,segment2,segment3,segment4,
segment5,segment6,segment7
from per_position_definitions pdf, hr_all_positions_f pos
where pos.position_definition_id = pdf.position_definition_id
and pos.position_id = p_position_id
and p_session_date between pos.effective_start_date
and pos.effective_end_date;
 cursor c_get_session_date is
    select trunc(effective_date) session_date
      from fnd_sessions
      where session_id = (select userenv('sessionid') from dual);
l_session_date date;
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

if ghr_utility.is_ghr_nfc = 'TRUE' then
 -- Get Session Date
     l_session_date := trunc(sysdate);
   for ses_rec in c_get_session_date loop
     l_session_date := ses_rec.session_date;
   end loop;

    -- Fetch the current segments from hr_all_positions_f
	    for c_pos_rec in c_pos_segments(l_session_date) loop
	    -- Do not allow modification of EIT segments which are populated
	    -- from the Position KFF
	    -- GHR_US_POS_GRP1 --> Personnel Officer ID
	    if p_information_type = 'GHR_US_POS_GRP1' then
	      if c_pos_rec.segment4 <> p_poei_information3 then
		hr_utility.set_message(8301, 'GHR_38945_NFC_ERROR1');
		hr_utility.raise_error;
	      end if;
	    end if;
	    -- GHR_US_POS_GRP3 --> NFC Agency Code
	    if p_information_type = 'GHR_US_POS_GRP3' then
	      if c_pos_rec.segment3 <> p_poei_information21 then
		hr_utility.set_message(8301, 'GHR_38947_NFC_ERROR3');
		hr_utility.raise_error;
	      end if;
	    end if;
	    -- GHR_US_POS_VALID_GRADE --> Grade From
	    if p_information_type = 'GHR_US_POS_VALID_GRADE' then
	      if c_pos_rec.segment7 <> p_poei_information3 then
		hr_utility.set_message(8301, 'GHR_38946_NFC_ERROR2');
		hr_utility.raise_error;
	      end if;
	    end if;
	   end loop;
  end if; -- ghr_utility.is_nfc_ghr
  hr_utility.set_location(' Leaving:'||l_proc, 10);
exception
  when l_error then
    hr_utility.set_message(999, 'HR_9999_FLEX_INV_INFO_ARG');
    hr_utility.raise_error;
    hr_utility.set_location(' Leaving:'||l_proc, 10);

end create_ddf;


-- ---------------------------------------------------------------------------------------------------
-- |------------------------------- < chk_date_from > ------------------------------------------------|
-- ---------------------------------------------------------------------------------------------------
--
procedure chk_date_from
(p_position_description_id    in  ghr_position_descriptions.position_description_id%TYPE
  ,p_date_from                 in  per_position_extra_info.poei_information1%TYPE
  ) is
--
  l_proc          varchar2(72) := 'chk_date_from';
  l_api_updating  boolean;
--
begin
  hr_utility.set_location('Entering: '|| l_proc, 10);
  --
   if p_position_description_id is not null and p_date_from is null
    then
      hr_utility.set_message(8301, 'GHR_DATE_FROM_INVALID');
      hr_utility.raise_error;
    end if;
    hr_utility.set_location('Leaving: '|| l_proc, 20);
end chk_date_from;
--
-- ---------------------------------------------------------------------------------------------------
-- |------------------------------- < chk_pos_desc_id > ---------------------------------------------|
-- ---------------------------------------------------------------------------------------------------
--
procedure chk_pos_desc_id
  (p_position_extra_info_id  in  per_position_extra_info.position_extra_info_id%TYPE
  ,p_pos_desc_id             in  per_position_extra_info.poei_information3%TYPE
  ) is
--
  l_exists        varchar2(1);
  l_proc          varchar2(72) := 'chk_pos_desc_id';
  l_api_updating  boolean;
  cursor csr_pos_desc is
    select null
      from ghr_position_descriptions
    where position_description_id = to_number(p_pos_desc_id);
--
begin
  hr_utility.set_location('Entering: '|| l_proc, 10);
  --
  --  Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name        => l_proc
    ,p_argument        => 'position description id'
    ,p_argument_value  => p_pos_desc_id
    );
  if p_pos_desc_id is null
  then
    hr_utility.set_message(8301, 'GHR_POS_DESC_ID_INVALID');
    hr_utility.raise_error;
  end if;
    open csr_pos_desc;
    fetch csr_pos_desc into l_exists;
    if csr_pos_desc%notfound then
      close csr_pos_desc;
      hr_utility.set_message(8301, 'GHR_PD_FOREIGN_KEY_CONSTRAINT');
      hr_utility.raise_error;
    end if ;
    hr_utility.set_location(' Leaving: '|| l_proc, 20);
end chk_pos_desc_id;
--
-- ---------------------------------------------------------------------------------------------------
-- |------------------------------------ < chk_date_to >---------------------------------------------|
-- ---------------------------------------------------------------------------------------------------
--
procedure chk_date_to
  (p_position_extra_info_id  in  per_position_extra_info.position_extra_info_id%TYPE
  ,p_date_to                 in  per_position_extra_info.poei_information2%TYPE
  ,p_date_from               in  per_position_extra_info.poei_information1%TYPE
  ) is
--
  l_proc          varchar2(72) := 'chk_date_to';
  l_api_updating  boolean;
--
begin
  hr_utility.set_location('Entering: '|| l_proc, 10);
    if p_date_to is not null and p_date_from is not null
    then
      if not(fnd_date.canonical_to_date(p_date_to) > fnd_date.canonical_to_date(p_date_from))
      then
      hr_utility.set_message(8301, 'GHR_DATE_TO_INVALID');
        hr_utility.raise_error;
      end if;
    end if;
  hr_utility.set_location('Leaving: '|| l_proc, 10);
end chk_date_to;
--

--
end ghr_poi_flex_ddf;

/
