--------------------------------------------------------
--  DDL for Package Body PER_JP_CONTACT_EXTRA_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_JP_CONTACT_EXTRA_INFO" AS
/* $Header: pejpreih.pkb 115.10 2003/10/07 19:04:04 ttagawa noship $ */
--
-- Constants
--
c_package	constant varchar2(31) := 'per_jp_contact_extra_info.';
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_information_type >------------------------|
-- ----------------------------------------------------------------------------
procedure chk_information_type(
	p_contact_extra_info_id		in number,
	p_information_type		in varchar2,
	p_contact_relationship_id	in number,
	p_validation_start_date		in date,
	p_validation_end_date		in date)
is
	c_proc			constant varchar2(61) := c_package || 'chk_information_type';
	l_duplicate		varchar2(1);
	--
	cursor csr_itax is
		select	'Y'
		from	per_contact_extra_info_f
		where	contact_relationship_id = p_contact_relationship_id
		and	contact_extra_info_id <> p_contact_extra_info_id
		and	information_type in ('JP_ITAX_DEPENDENT', 'JP_ITAX_DEPENDENT_ON_OTHER_EMP', 'JP_ITAX_DEPENDENT_ON_OTHER_PAY')
		and	information_type <> p_information_type
		and	effective_end_date >= p_validation_start_date
		and	effective_start_date <= p_validation_end_date;
	--
	cursor csr_si is
		select	'Y'
		from	per_contact_extra_info_f
		where	contact_relationship_id = p_contact_relationship_id
		and	contact_extra_info_id <> p_contact_extra_info_id
		and	information_type in ('JP_HI_SPOUSE', 'JP_HI_DEPENDENT')
		and	information_type <> p_information_type
		and	effective_end_date >= p_validation_start_date
		and	effective_start_date <= p_validation_end_date;
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	--
	-- No need to lock contact_relationship_id which is already locked in lck and ins_lck.
	--
	if p_information_type in ('JP_ITAX_DEPENDENT', 'JP_ITAX_DEPENDENT_ON_OTHER_EMP', 'JP_ITAX_DEPENDENT_ON_OTHER_PAY') then
		open csr_itax;
		fetch csr_itax into l_duplicate;
		if csr_itax%found then
			close csr_itax;
			fnd_message.set_name('PER', 'PER_JP_CON_ITAX_INFO_EXISTS');
			fnd_message.raise_error;
		end if;
		close csr_itax;
	elsif p_information_type in ('JP_HI_SPOUSE', 'JP_HI_DEPENDENT') then
		open csr_si;
		fetch csr_si into l_duplicate;
		if csr_si%found then
			close csr_si;
			fnd_message.set_name('PER', 'PER_JP_CON_HI_INFO_EXISTS');
			fnd_message.raise_error;
		end if;
		close csr_si;
	end if;
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end chk_information_type;
-- ----------------------------------------------------------------------------
-- |------------------------< chk_information_type_rkd >----------------------|
-- ----------------------------------------------------------------------------
procedure chk_information_type_rkd(
	p_datetrack_mode		in varchar2,
	p_contact_extra_info_id		in number,
	p_information_type_o		in varchar2,
	p_contact_relationship_id_o	in number,
	p_validation_start_date		in date,
	p_validation_end_date		in date)
is
	c_proc			constant varchar2(61) := c_package || 'chk_information_type_rkd';
begin
	hr_utility.set_location('Entering : ' || c_proc, 10);
	--
	if p_datetrack_mode in (hr_api.g_future_change, hr_api.g_delete_next_change) then
		chk_information_type(
			p_contact_extra_info_id		=> p_contact_extra_info_id,
			p_information_type		=> p_information_type_o,
			p_contact_relationship_id	=> p_contact_relationship_id_o,
			p_validation_start_date		=> p_validation_start_date,
			p_validation_end_date		=> p_validation_end_date);
	end if;
	--
	hr_utility.set_location('Leaving : ' || c_proc, 20);
end chk_information_type_rkd;
/*
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_information_type >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure verifies information types that stores the same kind of
--   information are mutually exclusive on arbitrary date.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_effective_date               Yes  DATE     Date the insert is effectively
--                                                made on.  Used for validation
--                                                purpose.
--   p_contact_relationship_id      Yes  NUMBER   Contact relationship for which
--                                                the extra info applies.
--   p_information_type             Yes  VARCHAR2 Information type the extra info
--                                                applies to.
--
-- Post Success:
--   Process continues.
--
-- Post Failure:
--   An application error will be raised and process is terminated.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
--
 PROCEDURE chk_information_type(
  p_effective_date              DATE,
  p_contact_relationship_id     NUMBER,
  p_information_type            VARCHAR2) IS
  --
  CURSOR cel_itax_info_exists(
   p_effective_date		DATE,
   p_contact_relationship_id	NUMBER,
   p_information_type           VARCHAR2) IS
   --
   SELECT 'Y' FROM per_contact_extra_info_f
   WHERE contact_relationship_id = p_contact_relationship_id
   AND information_type LIKE 'JP_ITAX%'
   AND information_type <> p_information_type
   AND p_effective_date BETWEEN effective_start_date AND effective_end_date;
   --
  CURSOR cel_hi_info_exists(
   p_effective_date		DATE,
   p_contact_relationship_id	NUMBER,
   p_information_type           VARCHAR2) IS
   --
   SELECT 'Y' FROM per_contact_extra_info_f
   WHERE contact_relationship_id = p_contact_relationship_id
   AND information_type LIKE 'JP_HI%'
   AND information_type <> p_information_type
   AND p_effective_date BETWEEN effective_start_date AND effective_end_date;
   --
  l_dummy			VARCHAR2(1);
  --
 BEGIN
  --
  IF p_information_type LIKE 'JP_ITAX%' THEN
   --
   OPEN cel_itax_info_exists(p_effective_date, p_contact_relationship_id, p_information_type);
   FETCH cel_itax_info_exists INTO l_dummy;
   --
   IF cel_itax_info_exists%FOUND THEN
    --
    CLOSE cel_itax_info_exists;
    --
    fnd_message.set_name(
     application => 'PER',
     name        => 'PER_JP_CON_ITAX_INFO_EXISTS');
    --
    fnd_message.raise_error;
    --
   END IF;
   --
   CLOSE cel_itax_info_exists;
   --
  ELSIF p_information_type LIKE 'JP_HI%' THEN
   --
   OPEN cel_hi_info_exists(p_effective_date, p_contact_relationship_id, p_information_type);
   FETCH cel_hi_info_exists INTO l_dummy;
   --
   IF cel_hi_info_exists%FOUND THEN
    --
    CLOSE cel_hi_info_exists;
    --
    fnd_message.set_name(
     application => 'PER',
     name        => 'PER_JP_CON_HI_INFO_EXISTS');
    --
    fnd_message.raise_error;
    --
   END IF;
   --
   CLOSE cel_hi_info_exists;
   --
  END IF;
  --
 END chk_information_type;
 --
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_future_record >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure verifies information types that stores the same kind of
--   information are mutually exclusive on arbitrary date.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_effective_date               Yes  DATE     Date the insert is effectively
--                                                made on.  Used for validation
--                                                purpose.
--   p_contact_relationship_id      Yes  NUMBER   Contact relationship for which
--                                                the extra info applies.
--   p_information_type             Yes  VARCHAR2 Information type the extra info
--                                                applies to.
--
-- Post Success:
--   Process continues.
--
-- Post Failure:
--   An application error will be raised and process is terminated.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
--
 PROCEDURE chk_future_record(
  p_effective_date              DATE,
  p_contact_relationship_id     NUMBER,
  p_information_type            VARCHAR2) IS
  --
  CURSOR cel_itax_future_exists(
   p_effective_date		DATE,
   p_contact_relationship_id	NUMBER,
   p_information_type           VARCHAR2) IS
   --
   SELECT 'Y' FROM per_contact_extra_info_f
   WHERE contact_relationship_id = p_contact_relationship_id
   AND information_type LIKE 'JP_ITAX%'
   AND information_type <> p_information_type
   AND p_effective_date < effective_start_date;
   --
  CURSOR cel_hi_future_exists(
   p_effective_date		DATE,
   p_contact_relationship_id	NUMBER,
   p_information_type           VARCHAR2) IS
   --
   SELECT 'Y' FROM per_contact_extra_info_f
   WHERE contact_relationship_id = p_contact_relationship_id
   AND information_type LIKE 'JP_HI%'
   AND information_type <> p_information_type
   AND p_effective_date < effective_start_date;
   --
  l_dummy			VARCHAR2(1);
  --
 BEGIN
  --
  IF p_information_type LIKE 'JP_ITAX%' THEN
   --
   OPEN cel_itax_future_exists(p_effective_date, p_contact_relationship_id, p_information_type);
   FETCH cel_itax_future_exists INTO l_dummy;
   --
   IF cel_itax_future_exists%FOUND THEN
    --
    CLOSE cel_itax_future_exists;
    --
    fnd_message.set_name(
     application => 'PER',
     name        => 'PER_JP_CON_ITAX_FUTURE_EXISTS');
    --
    fnd_message.raise_error;
    --
   END IF;
   --
   CLOSE cel_itax_future_exists;
  --
  ELSIF p_information_type LIKE 'JP_HI%' THEN
   --
   OPEN cel_hi_future_exists(p_effective_date, p_contact_relationship_id, p_information_type);
   FETCH cel_hi_future_exists INTO l_dummy;
   --
   IF cel_hi_future_exists%FOUND THEN
    --
    CLOSE cel_hi_future_exists;
    --
    fnd_message.set_name(
     application => 'PER',
     name        => 'PER_JP_CON_HI_FUTURE_EXISTS');
    --
    fnd_message.raise_error;
    --
   END IF;
   --
   CLOSE cel_hi_future_exists;
  --
  END IF;
  --
 END chk_future_record;
 --
-- ----------------------------------------------------------------------------
-- |--------------------< chk_future_record_before_del >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure verifies information types that stores the same kind of
--   information are mutually exclusive on arbitorary date.  This procedure
--   should be called before delete.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_effective_date               Yes  DATE     Date the delete is effectively
--                                                made on.  Used for validation
--                                                purpose.
--   p_contact_extra_info_id        Yes  NUMBER   Contact extra info ID.
--   p_datetrack_delete_mode        Yes  VARCHAR2 DateTrack mode the delete uses.
--
-- Post Success:
--   Process continues.
--
-- Post Failure:
--   An application error will be raised and process is terminated.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
--
 PROCEDURE chk_future_record_before_del(
  p_effective_date              DATE,
  p_contact_extra_info_id       NUMBER,
  p_datetrack_delete_mode       VARCHAR2) IS
  --
  CURSOR cel_information_type IS
   SELECT contact_relationship_id, information_type FROM per_contact_extra_info_f
   WHERE contact_extra_info_id = p_contact_extra_info_id
   AND p_effective_date BETWEEN effective_start_date AND effective_end_date;
  --
  CURSOR cel_itax_future_exists(
   p_contact_relationship_id	NUMBER,
   p_information_type		VARCHAR2) IS
   --
   SELECT 'Y' FROM per_contact_extra_info_f
   WHERE information_type LIKE 'JP_ITAX%'
   AND information_type <> p_information_type
   AND contact_relationship_id = p_contact_relationship_id
   AND p_effective_date < effective_start_date;
  --
  CURSOR cel_hi_future_exists(
   p_contact_relationship_id	NUMBER,
   p_information_type		VARCHAR2) IS
   --
   SELECT 'Y' FROM per_contact_extra_info_f
   WHERE information_type LIKE 'JP_HI%'
   AND information_type <> p_information_type
   AND contact_relationship_id = p_contact_relationship_id
   AND p_effective_date < effective_start_date;
  --
  l_contact_relationship_id	per_contact_extra_info_f.contact_relationship_id%TYPE;
  l_information_type		per_contact_extra_info_f.information_type%TYPE;
  l_dummy			VARCHAR2(1);
  --
 BEGIN
  --
  IF p_datetrack_delete_mode IN (hr_api.g_future_change, hr_api.g_delete_next_change) THEN
   --
   OPEN cel_information_type;
   FETCH cel_information_type INTO l_contact_relationship_id, l_information_type;
   --
   IF l_information_type LIKE 'JP_ITAX%' THEN
    --
    OPEN cel_itax_future_exists(l_contact_relationship_id, l_information_type);
    FETCH cel_itax_future_exists INTO l_dummy;
    --
    IF cel_itax_future_exists%FOUND THEN
     --
     CLOSE cel_itax_future_exists;
     --
     fnd_message.set_name(
      application => 'PER',
      name        => 'PER_JP_CON_ITAX_FUTURE_EXISTS');
     --
     fnd_message.raise_error;
     --
    END IF;
    --
    CLOSE cel_itax_future_exists;
    --
   ELSIF l_information_type LIKE 'JP_HI%' THEN
    --
    OPEN cel_hi_future_exists(l_contact_relationship_id, l_information_type);
    FETCH cel_hi_future_exists INTO l_dummy;
    --
    IF cel_hi_future_exists%FOUND THEN
     --
     CLOSE cel_hi_future_exists;
     --
     fnd_message.set_name(
      application => 'PER',
      name        => 'PER_JP_CON_HI_FUTURE_EXISTS');
     --
     fnd_message.raise_error;
     --
    END IF;
    --
    CLOSE cel_hi_future_exists;
   --
   END IF;
   --
   CLOSE cel_information_type;
   --
  END IF;
  --
 END chk_future_record_before_del;
 --
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_si_itax_flag >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure verifies si_itax_flag of the parent relationship is set to
--   'Y'.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_effective_date               Yes  DATE     Date the insert is effectively
--                                                made on.  Used for validation
--                                                purpose.
--   p_contact_relationship_id      Yes  NUMBER   Contact relationship for which
--                                                the extra info applies.
--
-- Post Success:
--   Process continues.
--
-- Post Failure:
--   An application error will be raised and process is terminated.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
--
 PROCEDURE chk_si_itax_flag(
  p_contact_relationship_id     NUMBER) IS
 --
  CURSOR cel_legislation_code(
   p_contact_relationship_id	NUMBER) IS
   --
   SELECT pbg.legislation_code
   FROM per_business_groups pbg, per_contact_relationships pcr
   WHERE pcr.contact_relationship_id = p_contact_relationship_id
   AND pcr.business_group_id = pbg.business_group_id;
   --
  CURSOR cel_parent_row(
   p_contact_relationship_id    NUMBER) IS
   --
   SELECT 'Y' FROM per_contact_relationships
   WHERE contact_relationship_id = p_contact_relationship_id
   AND cont_information_category = 'JP'
   AND cont_information1 <> 'Y';
   --
  l_legislation_code		per_business_groups.legislation_code%TYPE;
  l_dummy			VARCHAR2(1);
  --
 BEGIN
  --
  OPEN cel_legislation_code(p_contact_relationship_id);
  FETCH cel_legislation_code INTO l_legislation_code;
  --
  IF l_legislation_code = 'JP' THEN
   --
   OPEN cel_parent_row(p_contact_relationship_id);
   FETCH cel_parent_row INTO l_dummy;
   --
   IF cel_parent_row%FOUND THEN
    --
    CLOSE cel_parent_row;
    --
    fnd_message.set_name(
     application => 'PER',
     name        => 'PER_JP_CON_INVALID_REL');
    --
    fnd_message.raise_error;
    --
   END IF;
   --
   CLOSE cel_parent_row;
   --
  END IF;
  --
  CLOSE cel_legislation_code;
  --
 END chk_si_itax_flag;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_aged_parent >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure verifies aged parent living with employee is over 70 years
--   old and contact type is not spouse.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_effective_date               Yes  DATE     Date the insert is
--                                                effectively made on.  Used
--                                                for age culculation and
--                                                validation purpose.
--   p_contact_relationship_id      Yes  NUMBER   Contact relationship for
--                                                which the extra info applies.
--   p_information_type             Yes  VARCHAR2 Information type the extra
--                                                info applies to.
--   p_cei_information1             Yes  VARCHAR2 Entry value for aged parent
--                                                living with employee.
--
-- Post Success:
--   Process continues.
--
-- Post Failure:
--   An application error will be raised and process is terminated.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
--
 PROCEDURE chk_aged_parent(
  p_effective_date		DATE,
  p_contact_relationship_id     NUMBER,
  p_information_type		VARCHAR2,
  p_cei_information1		VARCHAR2) IS
  --
  l_soy		DATE := TRUNC(p_effective_date, 'YYYY');
  l_eoy 	DATE := ADD_MONTHS(l_soy, 12) - 1;
  --
  CURSOR cel_dependent IS SELECT
    TRUNC(MONTHS_BETWEEN(NVL(papf.date_of_death, l_eoy) + 1, papf.date_of_birth) / 12) age,
    pcr.contact_type
   FROM
    per_all_people_f papf,
    per_contact_relationships pcr
   WHERE pcr.contact_relationship_id = p_contact_relationship_id
   AND pcr.contact_person_id = papf.person_id
   AND p_effective_date BETWEEN papf.effective_start_date AND papf.effective_end_date;
  --
  l_age			NUMBER;
  l_contact_type	per_contact_relationships.contact_type%TYPE;
 BEGIN
  --
  IF p_information_type = 'JP_ITAX_DEPENDENT' THEN
   --
   IF p_cei_information1 = '10' THEN
    --
    OPEN cel_dependent;
    FETCH cel_dependent INTO l_age, l_contact_type;
    CLOSE cel_dependent;
    --
    IF l_age < 70 THEN
     --
     fnd_message.set_name(
      application => 'PER',
      name        => 'PER_JP_AGED_PARENT_UNDER_70');
     --
     fnd_message.raise_error;
     --
    END IF;
    --
    IF l_contact_type = 'S' THEN
     --
     fnd_message.set_name(
      application => 'PER',
      name        => 'PER_JP_AGED_PARENT_SPOUSE');
     --
     fnd_message.raise_error;
     --
    END IF;
    --
   END IF;
   --
  END IF;
  --
 END chk_aged_parent;
 --
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_aged_parent_before_upd >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure verifies aged parent living with employee is over 70 years
--   old and contact type is not spouse before update.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_effective_date               Yes  DATE     Date the update is
--                                                effectively made on.  Used
--                                                for age culculation and
--                                                validation purpose.
--   p_datetrack_update_mode	    Yes  VARCHAR2 Datetrack update mode.
--   p_contact_relationship_id      Yes  NUMBER   Contact relationship for
--                                                which the extra info applies.
--   p_information_type             Yes  VARCHAR2 Information type the extra
--                                                info applies to.
--   p_cei_information1             Yes  VARCHAR2 Entry value for aged parent
--                                                living with employee.
--
-- Post Success:
--   Process continues.
--
-- Post Failure:
--   An application error will be raised and process is terminated.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
--
 PROCEDURE chk_aged_parent_before_upd(
  p_effective_date              DATE,
  p_datetrack_update_mode	VARCHAR2,
  p_contact_relationship_id     NUMBER,
  p_information_type            VARCHAR2,
  p_cei_information1            VARCHAR2) IS
  --
  l_soy         DATE := TRUNC(p_effective_date, 'YYYY');
  l_eoy         DATE := ADD_MONTHS(l_soy, 12) - 1;
  --
  CURSOR cel_dependent IS SELECT
    TRUNC(MONTHS_BETWEEN(NVL(papf.date_of_death, DECODE(p_datetrack_update_mode, 'CORRECTION', ADD_MONTHS(TRUNC(pceif.effective_start_date, 'YYYY'), 12) - 1, l_eoy)) + 1, papf.date_of_birth) / 12) age,
    pcr.contact_type
   FROM
    per_all_people_f papf,
    per_contact_relationships pcr,
    per_contact_extra_info_f pceif
   WHERE pcr.contact_relationship_id = p_contact_relationship_id
   AND pcr.contact_person_id = papf.person_id
   AND p_effective_date BETWEEN papf.effective_start_date AND papf.effective_end_date
   AND pcr.contact_relationship_id = pceif.contact_relationship_id
   AND pceif.information_type = p_information_type
   AND p_effective_date BETWEEN pceif.effective_start_date AND pceif.effective_end_date;
  --
  l_age                 NUMBER;
  l_contact_type        per_contact_relationships.contact_type%TYPE;
 BEGIN
  --
  IF p_information_type = 'JP_ITAX_DEPENDENT' THEN
   --
   IF p_cei_information1 = '10' THEN
    --
    OPEN cel_dependent;
    FETCH cel_dependent INTO l_age, l_contact_type;
    CLOSE cel_dependent;
    --
    IF l_age < 70 THEN
     --
     fnd_message.set_name(
      application => 'PER',
      name        => 'PER_JP_AGED_PARENT_UNDER_70');
     --
     fnd_message.raise_error;
     --
    END IF;
    --
    IF l_contact_type = 'S' THEN
     --
     fnd_message.set_name(
      application => 'PER',
      name        => 'PER_JP_AGED_PARENT_SPOUSE');
     --
     fnd_message.raise_error;
     --
    END IF;
    --
   END IF;
   --
  END IF;
  --
 END chk_aged_parent_before_upd;
 --
*/
END per_jp_contact_extra_info;

/
