--------------------------------------------------------
--  DDL for Package Body GHR_LEI_FLEX_DDF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_LEI_FLEX_DDF" as
/* $Header: ghleiddf.pkb 115.4 2001/12/10 13:21:20 pkm ship      $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= 'ghr_lei_flex_ddf.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |--------------------------< val_info_type_y >------------------------------|
-- ----------------------------------------------------------------------------
--  {Start of Comments}
--
--  Description:
--    This procedure performs the descriptive flexfield validation for the
--    reference field - Information Type where the value is 'Y'.
--
--  Pre Conditions:
--    None
--
--  In Arguments:
--    p_rec
--
--  Post Success:
--    Processing of ghr_lei_flex_ddf continues.
--
--  Post failure:
--    Processing will be suspended if the descriptive flexfield validation
--    fails.
--
--  Developer Implementation Notes:
--    Customer defined.
--
--  Access Status:
--    From df procedure only.
--
--  {End of Comments}
-- ----------------------------------------------------------------------------
Procedure val_info_type_y
             (p_rec   in per_asg_shd.g_rec_type) is
--
  l_proc    varchar2(72) := g_package||'val_info_type_y';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Enter procedure code here
  --
  hr_utility.set_location(' Leaving:'||l_proc, 2);
end val_info_type_y;
-- ----------------------------------------------------------------------------
-- |--------------------------< val_info_type_x >------------------------------|
-- ----------------------------------------------------------------------------
--  {Start of Comments}
--
--  Description:
--    This procedure performs the descriptive flexfield validation for the
--    reference field - Information Type where the value is 'X'.
--
--  Pre Conditions:
--    None
--
--  In Arguments:
--    p_rec
--
--  Post Success:
--    Processing of hr_lei_flex_ddf continues.
--
--  Post failure:
--    Processing will be suspended if the descriptive flexfield validation
--    fails.
--
--  Developer Implementation Notes:
--    Customer defined.
--
--  Access Status:
--    From df procedure only.
--
--  {End of Comments}
-- ----------------------------------------------------------------------------
Procedure val_info_type_x
             (p_rec   in per_asg_shd.g_rec_type) is
--
  l_proc    varchar2(72) := g_package||'val_info_type_x';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Enter procedure code here
  --
  hr_utility.set_location(' Leaving:'||l_proc, 2);
end val_info_type_x;
-- ----------------------------------------------------------------------------
-- |-------------------------------< ddf >-------------------------------------|
-- ----------------------------------------------------------------------------
procedure ddf
	(
		p_location_extra_info_id	in	number	,
		p_information_type		in	varchar2	,
		p_location_id			in	number	,
		p_request_id			in	number	,
		p_program_application_id	in	number	,
		p_program_id			in	number	,
		p_program_update_date		in	date		,
		p_lei_attribute_category	in	varchar2	,
		p_lei_attribute1			in	varchar2	,
		p_lei_attribute2			in	varchar2	,
		p_lei_attribute3			in	varchar2	,
		p_lei_attribute4			in	varchar2	,
		p_lei_attribute5			in	varchar2	,
		p_lei_attribute6			in	varchar2	,
		p_lei_attribute7			in	varchar2	,
		p_lei_attribute8			in	varchar2	,
		p_lei_attribute9			in	varchar2	,
		p_lei_attribute10			in	varchar2	,
		p_lei_attribute11			in	varchar2	,
		p_lei_attribute12			in	varchar2	,
		p_lei_attribute13			in	varchar2	,
		p_lei_attribute14			in	varchar2	,
		p_lei_attribute15			in	varchar2	,
		p_lei_attribute16			in	varchar2	,
		p_lei_attribute17			in	varchar2	,
		p_lei_attribute18			in	varchar2	,
		p_lei_attribute19			in	varchar2	,
		p_lei_attribute20			in	varchar2	,
		p_lei_information_category	in	varchar2	,
		p_lei_information1		in	varchar2	,
		p_lei_information2		in	varchar2	,
		p_lei_information3		in	varchar2	,
		p_lei_information4		in	varchar2	,
		p_lei_information5		in	varchar2	,
		p_lei_information6		in	varchar2	,
		p_lei_information7		in	varchar2	,
		p_lei_information8		in	varchar2	,
		p_lei_information9		in	varchar2	,
		p_lei_information10		in	varchar2	,
		p_lei_information11		in	varchar2	,
		p_lei_information12		in	varchar2	,
		p_lei_information13		in	varchar2	,
		p_lei_information14		in	varchar2	,
		p_lei_information15		in	varchar2	,
		p_lei_information16		in	varchar2	,
		p_lei_information17		in	varchar2	,
		p_lei_information18		in	varchar2	,
		p_lei_information19		in	varchar2	,
		p_lei_information20		in	varchar2	,
		p_lei_information21		in	varchar2	,
		p_lei_information22		in	varchar2	,
		p_lei_information23		in	varchar2	,
		p_lei_information24		in	varchar2	,
		p_lei_information25		in	varchar2	,
		p_lei_information26		in	varchar2	,
		p_lei_information27		in	varchar2	,
		p_lei_information28		in	varchar2	,
		p_lei_information29		in	varchar2	,
		p_lei_information30		in	varchar2
	)
is
--
  l_proc		varchar2(72) := g_package||'ddf';
  l_error		exception;
  l_duty_station	char;
  l_effective_date      date;

  cursor c1 is
         SELECT effective_date
         FROM   fnd_sessions
         WHERE  session_id = USERENV('SESSIONID');

  cursor c2 (p_effective_date  date) is
         select 'X'
         from   ghr_duty_stations_f
	 where  duty_station_id = to_number(p_lei_information3)
           and  trunc(p_effective_date) between(effective_start_date) and
                                            nvl(effective_end_date,p_effective_date);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
if ghr_utility.is_ghr = 'TRUE' then
/*
  -- Check for value of reference field an then
  -- call relevant validation procedure.
  --
  if <reference field value> is not null then
    --
    -- Reference field       => Information type
    -- Reference field value => 'X'
    --
    if <reference field value> is <value> then
      val_info_type_x(p_rec => p_rec);
    --
    -- Reference field       => Information type
    -- Reference field value => 'Y'
    --
    elsif <reference field value> is <value> then
      val_info_type_x(p_rec => p_rec);
    else
      --
      -- Reference field values is not supported
      --
      hr_utility.set_message(801, 'HR_7438_FLEX_INV_REF_FIELD_VAL');
      hr_utility.raise_error;
    end if;
  else
    --
    -- When the reference field is null, check
    -- that none of the attribute fields have
    -- been set
    --
*/
    if p_information_type = 'GHR_US_LOC_INFORMATION' and
       p_lei_Information3 is not null then
       open c1;
       fetch c1 into l_effective_date;
       close c1;

       open c2(nvl(l_effective_date,sysdate));
       fetch c2 into l_duty_station;
	 if c2%NOTFOUND then
          close c2;
          hr_utility.set_message(8301, 'GHR_38277_DUTY_STATION_NOT_FND');
          hr_utility.raise_error;
       else
          close c2;
       end if;
    elsif p_lei_information1 is not null then
      raise l_error;
    elsif p_lei_information2 is not null then
      raise l_error;
    elsif p_lei_information3 is not null then
      raise l_error;
    elsif p_lei_information4 is not null then
      raise l_error;
    elsif p_lei_information5 is not null then
      raise l_error;
    elsif p_lei_information6 is not null then
      raise l_error;
    elsif p_lei_information7 is not null then
      raise l_error;
    elsif p_lei_information8 is not null then
      raise l_error;
    elsif p_lei_information9 is not null then
      raise l_error;
    elsif p_lei_information10 is not null then
      raise l_error;
    elsif p_lei_information11 is not null then
      raise l_error;
    elsif p_lei_information12 is not null then
      raise l_error;
    elsif p_lei_information13 is not null then
      raise l_error;
    elsif p_lei_information14 is not null then
      raise l_error;
    elsif p_lei_information15 is not null then
      raise l_error;
    elsif p_lei_information16 is not null then
      raise l_error;
    elsif p_lei_information17 is not null then
      raise l_error;
    elsif p_lei_information18 is not null then
      raise l_error;
    elsif p_lei_information19 is not null then
      raise l_error;
    elsif p_lei_information20 is not null then
      raise l_error;
    elsif p_lei_information21 is not null then
      raise l_error;
    elsif p_lei_information22 is not null then
      raise l_error;
    elsif p_lei_information23 is not null then
      raise l_error;
    elsif p_lei_information24 is not null then
      raise l_error;
    elsif p_lei_information25 is not null then
      raise l_error;
    elsif p_lei_information26 is not null then
      raise l_error;
    elsif p_lei_information27 is not null then
      raise l_error;
    elsif p_lei_information28 is not null then
      raise l_error;
    elsif p_lei_information29 is not null then
      raise l_error;
    elsif p_lei_information30 is not null then
      raise l_error;
    end if;
  --
  /*
  endif;
  */
  hr_utility.set_location(' Leaving:'||l_proc, 10);

end if; -- ghr_utility.is_ghr
exception
  when l_error then
    hr_utility.set_message(801, 'HR_7439_FLEX_INV_ATTRIBUTE_ARG');
    hr_utility.raise_error;
    hr_utility.set_location(' Leaving:'||l_proc, 10);

end ddf;
--
end ghr_lei_flex_ddf;

/
