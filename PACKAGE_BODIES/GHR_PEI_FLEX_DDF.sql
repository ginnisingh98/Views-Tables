--------------------------------------------------------
--  DDL for Package Body GHR_PEI_FLEX_DDF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PEI_FLEX_DDF" as
/* $Header: ghpeiddf.pkb 120.4.12010000.3 2009/04/07 10:02:03 utokachi ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '   ghr_pei_flex_ddf.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< ddf >------------------------------------|
-- ----------------------------------------------------------------------------
--
/*
procedure ddf
  (p_rec   in pe_pei_shd.g_rec_type) is
*/
PROCEDURE chk_race_ethnic_info(
		 p_person_id        number
		 ,p_pei_information3 varchar2
	     ,p_pei_information4 varchar2
	     ,p_pei_information5 varchar2
	     ,p_pei_information6 varchar2
	     ,p_pei_information7 varchar2
	     ,p_pei_information8 varchar2);
procedure ddf
(
		p_person_extra_info_id		in	number	,
		p_person_id				in	number	,
		p_information_type		in	varchar2	,
		p_request_id			in	number	,
		p_program_application_id	in	number	,
		p_program_id			in	number	,
		p_program_update_date		in	date		,
		p_pei_attribute_category	in	varchar2	,
		p_pei_attribute1			in	varchar2	,
		p_pei_attribute2			in	varchar2	,
		p_pei_attribute3			in	varchar2	,
		p_pei_attribute4			in	varchar2	,
		p_pei_attribute5			in	varchar2	,
		p_pei_attribute6			in	varchar2	,
		p_pei_attribute7			in	varchar2	,
		p_pei_attribute8			in	varchar2	,
		p_pei_attribute9			in	varchar2	,
		p_pei_attribute10			in	varchar2	,
		p_pei_attribute11			in	varchar2	,
		p_pei_attribute12			in	varchar2	,
		p_pei_attribute13			in	varchar2	,
		p_pei_attribute14			in	varchar2	,
		p_pei_attribute15			in	varchar2	,
		p_pei_attribute16			in	varchar2	,
		p_pei_attribute17			in	varchar2	,
		p_pei_attribute18			in	varchar2	,
		p_pei_attribute19			in	varchar2	,
		p_pei_attribute20			in	varchar2	,
		p_pei_information_category	in	varchar2	,
		p_pei_information1		in	varchar2	,
		p_pei_information2		in	varchar2	,
		p_pei_information3		in	varchar2	,
		p_pei_information4		in	varchar2	,
		p_pei_information5		in	varchar2	,
		p_pei_information6		in	varchar2	,
		p_pei_information7		in	varchar2	,
		p_pei_information8		in	varchar2	,
		p_pei_information9		in	varchar2	,
		p_pei_information10		in	varchar2	,
		p_pei_information11		in	varchar2	,
		p_pei_information12		in	varchar2	,
		p_pei_information13		in	varchar2	,
		p_pei_information14		in	varchar2	,
		p_pei_information15		in	varchar2	,
		p_pei_information16		in	varchar2	,
		p_pei_information17		in	varchar2	,
		p_pei_information18		in	varchar2	,
		p_pei_information19		in	varchar2	,
		p_pei_information20		in	varchar2	,
		p_pei_information21		in	varchar2	,
		p_pei_information22		in	varchar2	,
		p_pei_information23		in	varchar2	,
		p_pei_information24		in	varchar2	,
		p_pei_information25		in	varchar2	,
		p_pei_information26		in	varchar2	,
		p_pei_information27		in	varchar2	,
		p_pei_information28		in	varchar2	,
		p_pei_information29		in	varchar2	,
		p_pei_information30		in	varchar2
	) is

--
  l_proc       varchar2(72) := g_package||'ddf';
  l_error      exception;
  l_date_from   date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

if ghr_utility.is_ghr = 'TRUE' then
  -- Check GHR Workflow Routing Groups information ???
  --
  if p_information_type Is Not Null then
    if p_information_type = 'GHR_US_PER_WF_ROUTING_GROUPS' then
		      ghr_pei_flex_ddf.chk_routing_group_info
			    (p_person_extra_info_id => p_person_extra_info_id
			    ,p_information_type => p_information_type
			    ,p_person_id        => p_person_id
			    ,p_pei_information3 => p_pei_information3
			    ,p_pei_information4 => p_pei_information4
			    ,p_pei_information5 => p_pei_information5
			    ,p_pei_information6 => p_pei_information6
			    ,p_pei_information7 => p_pei_information7
			    ,p_pei_information8 => p_pei_information8
			    ,p_pei_information9 => p_pei_information9
			    ,p_pei_information10 => p_pei_information10
			   );
			  --  Validate OGHR roles (INSERT)
			  ghr_pei_flex_ddf.chk_oghr_roles
			    (p_person_extra_info_id => p_person_extra_info_id
			    ,p_information_type => p_information_type
			    ,p_person_id        => p_person_id
			    ,p_pei_information3 => p_pei_information3
			    ,p_pei_information4 => p_pei_information4
			    ,p_pei_information5 => p_pei_information5
			    ,p_pei_information6 => p_pei_information6
			    ,p_pei_information7 => p_pei_information7
			    ,p_pei_information8 => p_pei_information8
			    ,p_pei_information9 => p_pei_information9
			    ,p_pei_information10 => p_pei_information10
			   );
	elsif p_information_type  IN ('GHR_US_PER_BENEFIT_INFO','GHR_US_PER_SCD_INFORMATION') THEN
		 ghr_ben_validation.validate_create_personei(
			p_person_extra_info_id => p_person_extra_info_id ,
			p_information_type => p_information_type,
			p_person_id        => p_person_id
			) ;
	elsif p_information_type = 'GHR_US_PER_ETHNICITY_RACE' AND ghr_ghrws52l.g_bypass_cpdf <> TRUE THEN --Bug# 8259201
		 chk_race_ethnic_info(
		  p_person_id        => p_person_id
		 ,p_pei_information3 => p_pei_information3
	     ,p_pei_information4 => p_pei_information4
	     ,p_pei_information5 => p_pei_information5
	     ,p_pei_information6 => p_pei_information6
	     ,p_pei_information7 => p_pei_information7
	     ,p_pei_information8 => p_pei_information8);
	end if;
  end if;
  --
end if; -- ghr_utility.is_ghr
  hr_utility.set_location(' Leaving:'||l_proc, 10);
exception
  when l_error then
    hr_utility.set_message(999, 'HR_9999_FLEX_INV_INFO_ARG');
    hr_utility.raise_error;
    hr_utility.set_location(' Leaving:'||l_proc, 10);
end ddf;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_routing_group_info >--------------------------|
-- ----------------------------------------------------------------------------
--
--  Desciption:
--    This procedures validates that the if the person is :
--       Already assigned to this routing group.
--       If he the Reviewer/ Requestor/ Authorizer/ Approver combination is valid.
--	   If the Person is already assigned a Defualt routing group.
--  Pre-conditions :
--    p_person_id is valid
--
--  In Parameters :
--    p_information_type
--    p_person_id
--	p_pei_information3
--	p_pei_information4
--	p_pei_information5
--	p_pei_information6
--	p_pei_information7
--	p_pei_information8
--	p_pei_information9
--	p_pei_information10
--
--  Post Success :
--    Processing continues if the Person is not already a member of the routing
--    group.
--    If his roles of Reviewer/ Requestor/ Authorizer/ Approver/ Personnelist combination is valid.
--    If his Default Routing group is valid
--
--
--  Post Failure :
--    An application error will be raised and processing is terminated if the
--    Person has a duplicate Routing group.
--    An application error will also be raised and processing is terminated if
--    his roles of Reviewer/ Requestor/ Authorizer/ Approver/ Personnelist combination is invalid.
--    If he is already a Defaulted to a routing group.
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
Procedure chk_routing_group_info
 (p_person_extra_info_id in per_people_extra_info.person_extra_info_id%TYPE
 ,p_information_type in  per_people_extra_info.information_type%TYPE
 ,p_person_id        in  per_people_extra_info.person_id%TYPE
 ,p_pei_information3 in per_people_extra_info.pei_information3%TYPE
 ,p_pei_information4 in per_people_extra_info.pei_information4%TYPE
 ,p_pei_information5 in per_people_extra_info.pei_information5%TYPE
 ,p_pei_information6 in per_people_extra_info.pei_information6%TYPE
 ,p_pei_information7 in per_people_extra_info.pei_information7%TYPE
 ,p_pei_information8 in per_people_extra_info.pei_information8%TYPE
 ,p_pei_information9 in per_people_extra_info.pei_information9%TYPE
 ,p_pei_information10 in per_people_extra_info.pei_information10%TYPE
 ) is
  --
  -- Declare local variables
  --
  l_proc                   varchar2(72) := g_package||'chk_routing_group_info';
  l_count			   Number(15);
--
Begin
  --
    SELECT count(*)
    INTO  l_count
    FROM   per_people_extra_info
    WHERE  information_type = p_information_type
    AND    person_id = p_person_id
    AND    pei_information3 = p_pei_information3
    AND    person_extra_info_id <> nvl(p_person_extra_info_id,-9999);
--
--
  hr_utility.set_location('Entering:'||l_proc, 5);
    --
    -- Check to see the Routing group is not duplicate
    --
    if l_count > 0 then
      --
      hr_utility.set_location(l_proc, 35);
      --
      hr_utility.set_message(8301, 'GHR_38047_DUP_ROUTING_GRP_DDF');
      hr_utility.raise_error;
    end if;
    --
  --
  --
    if p_pei_information10 in ('Y','y') then
	    SELECT count(*)
	    INTO  l_count
	    FROM   per_people_extra_info
	    WHERE  information_type = p_information_type
	    AND    person_id = p_person_id
	    AND    pei_information10 = p_pei_information10
       AND    person_extra_info_id <> nvl(p_person_extra_info_id,-9999);
	    --
	    -- Check to see the Default Routing group is not duplicate
	    --
	    if l_count > 0 then
      	--
	      hr_utility.set_location(l_proc, 40);
      	--
	      hr_utility.set_message(8301, 'GHR_38096_DUP_PRIM_LIST_DDF');
      	hr_utility.raise_error;
	    end if;
    end if;
--
--
--
  hr_utility.set_location(' Leaving:'||l_proc, 45);
  --
End chk_routing_group_info;

Procedure chk_oghr_roles
 (p_person_extra_info_id in per_people_extra_info.person_extra_info_id%TYPE
 ,p_information_type in  per_people_extra_info.information_type%TYPE
 ,p_person_id        in  per_people_extra_info.person_id%TYPE
 ,p_pei_information3 in per_people_extra_info.pei_information3%TYPE
 ,p_pei_information4 in per_people_extra_info.pei_information4%TYPE
 ,p_pei_information5 in per_people_extra_info.pei_information5%TYPE
 ,p_pei_information6 in per_people_extra_info.pei_information6%TYPE
 ,p_pei_information7 in per_people_extra_info.pei_information7%TYPE
 ,p_pei_information8 in per_people_extra_info.pei_information8%TYPE
 ,p_pei_information9 in per_people_extra_info.pei_information9%TYPE
 ,p_pei_information10 in per_people_extra_info.pei_information10%TYPE
 ) is
  --
  -- Declare local variables
  --
  l_proc                   varchar2(72) := g_package||'chk_oghr_roles';
  l_count			   Number(15);
--
Begin
  --
	if p_pei_information9 in ('Y','y') then
		if p_pei_information5 in ('Y','y') then
		      hr_utility.set_message(8301, 'GHR_38041_INV_COMB_REV_REQ');
      		hr_utility.raise_error;
		end if;
		if p_pei_information6 in ('Y','y') then
		      hr_utility.set_message(8301, 'GHR_38042_INV_COMB_REV_AUTH');
      		hr_utility.raise_error;
		end if;
		if p_pei_information7 in ('Y','y') then
		      hr_utility.set_message(8301, 'GHR_38043_INV_COMB_REV_APP');
      		hr_utility.raise_error;
		end if;
	end if;
--	You cannot be approver without being a Personnelist
	if p_pei_information8 in ('Y','y') then
		if p_pei_information7 in ('N','n') then
		      hr_utility.set_message(8301, 'GHR_INV_COMB_APP_PERL');
      		hr_utility.raise_error;
		end if;
	end if;
--
  hr_utility.set_location('Entering:'||l_proc, 5);
--
End chk_oghr_roles;

-- -- Bug 4724337 Race or National Origin changes
PROCEDURE chk_race_ethnic_info(
		  p_person_id number
		 ,p_pei_information3 varchar2
	     ,p_pei_information4 varchar2
	     ,p_pei_information5 varchar2
	     ,p_pei_information6 varchar2
	     ,p_pei_information7 varchar2
	     ,p_pei_information8 varchar2) IS
	CURSOR c_rno(c_person_id per_all_people_f.person_id%type) IS
		SELECT pei_information5	race
		FROM per_people_extra_info
		WHERE person_id = c_person_id
		AND information_type = 'GHR_US_PER_GROUP1';
	l_race 	per_people_extra_info.pei_information5%type;
	l_ethnicity varchar2(250);

BEGIN
	l_ethnicity := NULL;
	IF p_pei_information3 IS NOT NULL OR
		p_pei_information4 IS NOT NULL OR
		p_pei_information5 IS NOT NULL OR
		p_pei_information6 IS NOT NULL OR
		p_pei_information7 IS NOT NULL OR
		p_pei_information8 IS NOT NULL THEN
			l_ethnicity := 	NVL(p_pei_information3,' ') || NVL(p_pei_information4,' ') ||
							NVL(p_pei_information5,' ') || NVL(p_pei_information6,' ') ||
							NVL(p_pei_information7,' ') || NVL(p_pei_information8,' ');
	END IF;
	-- 165.00.3
	IF l_ethnicity IS NOT NULL AND INSTR(l_ethnicity,'1') < 1 THEN
		    -- Throw error message
		    hr_utility.set_message(8301, 'GHR_38988_ALL_PROCEDURE_FAIL');
      		hr_utility.raise_error;
	END IF;

	IF l_ethnicity IS NOT NULL AND INSTR(l_ethnicity,' ') > 1 THEN
		    -- Throw error message
		    hr_utility.set_message(8301, 'GHR_38988_ALL_PROCEDURE_FAIL');
      		hr_utility.raise_error;
	END IF;

	FOR l_cur_rno IN c_rno(p_person_id) LOOP
		l_race := l_cur_rno.race;
	END LOOP;

	-- 165.05.3
	IF l_race IS NULL AND l_ethnicity IS NULL THEN
		hr_utility.set_message(8301, 'GHR_38989_ALL_PROCEDURE_FAIL');
      	hr_utility.raise_error;
	END IF;
END chk_race_ethnic_info;
---- Bug 4724337 Race or National Origin changes
--
--
--
end ghr_pei_flex_ddf;

/
