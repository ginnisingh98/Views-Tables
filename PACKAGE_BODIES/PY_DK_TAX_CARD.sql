--------------------------------------------------------
--  DDL for Package Body PY_DK_TAX_CARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PY_DK_TAX_CARD" AS
/* $Header: pydktaxc.pkb 120.5.12010000.2 2008/08/06 07:06:00 ubhat ship $ */
--
-- Package Variables
--
g_package  CONSTANT varchar2(33) := '  hr_dk_taxcard_api.';
g_debug BOOLEAN := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_taxcard >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--	This API will insert a tax card entry for a Norway Assignment.
--	This API delegates to the create_element_entry procedure of the
--	pay_element_entry_api package.
--
-- Prerequisites:
--	The element entry (of element type 'Tax Card') and the corresponding
--	element link should exist for the given assignment and business group.
--
-- In Parameters:
--  Name                Reqd    Type     Description
--  p_legislation_code  Yes     VARCHAR2 Legislation code.
--  p_effective_date    Yes     DATE     The effective date of the
--                                       change.
--  p_assignment_id     Yes     VARCHAR2 Id of the assignment.
--  p_person_id         Yes     VARCHAR2 Id of the person.
--  p_business_group_id Yes     VARCHAR2 Id of the business group.
--  p_tax_free_threshold        NUMBER   Element entry value.
--  p_weekly_td                 NUMBER   Element entry value.
--  p_daily_td                  DATE     Element entry value.
--  p_registration_date         DATE     Element entry value.
--  p_method_of_receipt         VARCHAR2 Element entry value.
--  p_tax_card_type             VARCHAR2 Element entry value.
--  p_tax_percentage            VARCHAR2 Element entry value.
--  p_monthly_td                VARCHAR2 Element entry value.
--  p_biweekly_td               VARCHAR2 Element entry value.
--  p_date_returned             DATE     Element entry value.
--  p_element_entry_id          VARCHAR2 Id of the element entry.
--  p_element_link_id           VARCHAR2 Id of the element link.
--
--
-- Post Success:
--
--	The API successfully updates the tax card entry.
--
-- Post Failure:
--   The API will raise an error.
--
-- Access Status:
--   Private. For Internal Development Use only.
--
-- {End Of Comments}
--
   PROCEDURE insert_taxcard (
    p_legislation_code      IN  VARCHAR2
    ,p_effective_date       IN  DATE
    ,p_assignment_id        IN  VARCHAR2
    ,p_person_id            IN  VARCHAR2
    ,p_business_group_id    IN  VARCHAR2
    ,p_tax_free_threshold   IN  NUMBER      DEFAULT NULL
    ,p_weekly_td            IN  NUMBER      DEFAULT NULL
    ,p_daily_td             IN  NUMBER      DEFAULT NULL
    ,p_registration_date    IN  DATE        DEFAULT NULL
    ,p_method_of_receipt    IN  VARCHAR2    DEFAULT NULL
    ,p_tax_card_type        IN  VARCHAR2    DEFAULT NULL
    ,p_tax_percentage       IN  NUMBER      DEFAULT NULL
    ,p_monthly_td           IN  NUMBER      DEFAULT NULL
    ,p_biweekly_td          IN  NUMBER      DEFAULT NULL
    ,p_date_returned        IN  DATE        DEFAULT NULL)
    IS
	-- Declarations here
	l_start_date		DATE;
	l_end_date		    DATE;
	l_warning		    BOOLEAN;
	l_element_entry_id	NUMBER(15);
	l_tax_percentage    pay_element_entry_values_f.screen_entry_value%TYPE;
	l_ovn			    NUMBER(9);
	l_element_link_id	pay_element_links_f.element_link_id%TYPE;
	l_element_type_id	pay_element_types_f.element_type_id%TYPE;
	l_input_value_id1	pay_input_values_f.input_value_id%TYPE;
	l_input_value_id2	pay_input_values_f.input_value_id%TYPE;
	l_input_value_id3	pay_input_values_f.input_value_id%TYPE;
	l_input_value_id4	pay_input_values_f.input_value_id%TYPE;
	l_input_value_id5	pay_input_values_f.input_value_id%TYPE;
	l_input_value_id6	pay_input_values_f.input_value_id%TYPE;
	l_input_value_id7	pay_input_values_f.input_value_id%TYPE;
	l_input_value_id8	pay_input_values_f.input_value_id%TYPE;
	l_input_value_id9	pay_input_values_f.input_value_id%TYPE;
	l_input_value_id10	pay_input_values_f.input_value_id%TYPE;
	l_input_value_id11      pay_input_values_f.input_value_id%TYPE;
       -- Added for Flugger fix
        l_element_name_tl             PAY_ELEMENT_TYPES_F_TL.element_name%TYPE;


	CURSOR input_values_csr IS
		SELECT
		et.element_type_id,
		MIN(DECODE(iv.name, 'Method of Receipt', iv.input_value_id, null)) iv1,
		MIN(DECODE(iv.name, 'Tax Card Type', iv.input_value_id, null)) iv2,
		MIN(DECODE(iv.name, 'Tax Percentage', iv.input_value_id, null)) iv3,
		MIN(DECODE(iv.name, 'Tax Free Threshold', iv.input_value_id, null)) iv4,
		MIN(DECODE(iv.name, 'Monthly Tax Deduction', iv.input_value_id, null)) iv5,
		MIN(DECODE(iv.name, 'Bi Weekly Tax Deduction', iv.input_value_id, null)) iv6,
		MIN(DECODE(iv.name, 'Weekly Tax Deduction', iv.input_value_id, null)) iv7,
		MIN(DECODE(iv.name, 'Daily Tax Deduction', iv.input_value_id, null)) iv8,
		MIN(DECODE(iv.name, 'Registration Date', iv.input_value_id, null)) iv9,
		MIN(DECODE(iv.name, 'Date Returned', iv.input_value_id, null)) iv10,
		MIN(DECODE(iv.name, 'Tax Card Requisition Status', iv.input_value_id, null)) iv11
		FROM
		pay_element_types_f et,
		pay_input_values_f iv
		WHERE et.element_name = 'Tax Card'
		AND et.legislation_code = 'DK'
		AND et.business_group_id is null
		AND fnd_date.canonical_to_date(p_effective_date) BETWEEN
			et.effective_start_date AND et.effective_end_date
		AND iv.element_type_id = et.element_type_id
		AND fnd_date.canonical_to_date(p_effective_date)
			BETWEEN iv.effective_start_date AND iv.effective_end_date
		GROUP BY
			et.element_type_id;
	l_proc    varchar2(72) := g_package||'insert_taxcard';

	/* Modified for unique constraint (APPLSYS.FND_SESSIONS_U1) violated. */

        CURSOR CSR_CHECK_FND_SESSION
	is
	select session_id
	from fnd_sessions
	where session_id = userenv('sessionid')
	and effective_date = p_effective_date;

	LCSR_CHECK_FND_SESSION CSR_CHECK_FND_SESSION%ROWTYPE;

	BEGIN

		if g_debug then
			hr_utility.set_location('Entering:'|| l_proc, 1);
		end if;
		--Insert row into fnd_Sessions table.

		OPEN  CSR_CHECK_FND_SESSION;
	        FETCH CSR_CHECK_FND_SESSION INTO LCSR_CHECK_FND_SESSION;

		/* Modified for unique constraint (APPLSYS.FND_SESSIONS_U1) violated. */

		IF CSR_CHECK_FND_SESSION%notfound THEN
			INSERT INTO fnd_sessions(session_id,effective_date) VALUES(userenv('sessionid'), p_effective_date);
	        END IF;
    		CLOSE CSR_CHECK_FND_SESSION;

		/* Fix for bug 6004991, ref bug fix 5951490  */
		-- fetch element link id

		   --Added for Flugger fix
	           select ELEMENTTL.element_name
		   into l_element_name_tl
		   from PAY_ELEMENT_TYPES_F_TL ELEMENTTL, PAY_ELEMENT_TYPES_F ELEMENT
		   where ELEMENT.ELEMENT_TYPE_ID = ELEMENTTL.ELEMENT_TYPE_ID
		   and ELEMENT.LEGISLATION_CODE ='DK'
		   and ELEMENT.ELEMENT_NAME = 'Tax Card'
		   AND ELEMENTTL.LANGUAGE = USERENV('LANG');

		l_element_link_id := pay_dk_tc_dp_upload.get_element_link_id(
						p_assignment_id, p_business_group_id,
						(p_effective_date),
						l_element_name_tl);

		if g_debug then
			hr_utility.set_location('Entering:'|| l_proc, 3);
		end if;

		-- fetch all input value id's
		OPEN input_values_csr;
		FETCH input_values_csr INTO l_element_type_id, l_input_value_id1, l_input_value_id2,
			l_input_value_id3, l_input_value_id4, l_input_value_id5, l_input_value_id6,
			l_input_value_id7, l_input_value_id8, l_input_value_id9,l_input_value_id10,l_input_value_id11;
		CLOSE input_values_csr;


		if g_debug then
			hr_utility.set_location('Entering:'|| l_proc, 6);
		end if;
		--If taxcard type is "NTC", then the tax percentage need not be stored.
		IF  p_tax_card_type = 'NTC' then
			l_tax_percentage := null;
		ELSE
			l_tax_percentage := p_tax_percentage;
		END IF;

		if g_debug then
			hr_utility.set_location('Entering:'|| l_proc, 7);
		end if;


		-- insert records into pay_element_entries_f and pay_element_entry_values_f
		pay_element_entry_api.create_element_entry
		(p_effective_date		=> p_effective_date
		,p_business_group_id	=> p_business_group_id
		,p_assignment_id		=> p_assignment_id
		,p_element_link_id		=> l_element_link_id
		,p_entry_type 			=> 'E'
		,p_input_value_id1		=> l_input_value_id1
		,p_input_value_id2		=> l_input_value_id2
		,p_input_value_id3		=> l_input_value_id3
		,p_input_value_id4		=> l_input_value_id4
		,p_input_value_id5		=> l_input_value_id5
		,p_input_value_id6		=> l_input_value_id6
		,p_input_value_id7		=> l_input_value_id7
		,p_input_value_id8		=> l_input_value_id8
		,p_input_value_id9		=> l_input_value_id9
                ,p_input_value_id10		=> l_input_value_id10
                ,p_input_value_id11		=> l_input_value_id11
		,p_entry_value1			=> p_method_of_receipt
		,p_entry_value2			=> p_tax_card_type
		,p_entry_value3			=> p_tax_percentage
		,p_entry_value4			=> p_tax_free_threshold
		,p_entry_value5			=> p_monthly_td
		,p_entry_value6			=> p_biweekly_td
		,p_entry_value7			=> p_weekly_td
                ,p_entry_value8			=> p_daily_td
		/* Modified for bug fix 4604457 */
		/*fnd_date_to_canonical removed */
		,p_entry_value9			=> (p_registration_date)
		,p_entry_value10    	        => (p_date_returned)
		,p_entry_value11    	        => 'UPLOAD COMPLETE'  /*Added for the tax card requisition enhacement*/
		,p_effective_start_date		=> l_start_date
		,p_effective_end_date		=> l_end_date
		,p_element_entry_id		=> l_element_entry_id
		,p_object_version_number	=> l_ovn
		,p_create_warning		=> l_warning
		);


		if g_debug then
			hr_utility.set_location('Entering:'|| l_proc, 10);
		end if;

		-- Do not COMMIT here. COMMIT should be done thru the OAF Application only.
	EXCEPTION
	WHEN OTHERS THEN
		 hr_utility.set_location('Error message : '||SQLERRM, 11);
		 RAISE;
	END insert_taxcard;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_taxcard >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--	This API will update the tax card entry for a Norway Assignment.
--	This API delegates to the update_element_entry procedure of the
--	pay_element_entry_api package.
--
-- Prerequisites:
--	The element entry (of element type 'Tax Card') and the corresponding
--	element link should exist for the given assignment and business group.
--
-- In Parameters:
--  Name            Reqd    Type     Description
--  p_legislation_code      Yes     VARCHAR2 Legislation code.
--  p_effective_date        Yes     DATE     The effective date of the
--                                       change.
--  p_assignment_id         Yes     VARCHAR2 Id of the assignment.
--  p_person_id             Yes     VARCHAR2 Id of the person.
--  p_business_group_id     Yes     VARCHAR2 Id of the business group.
--  p_tax_free_threshold            NUMBER   Element entry value.
--  p_weekly_td                     NUMBER   Element entry value.
--  p_daily_td                      DATE     Element entry value.
--  p_registration_date             DATE     Element entry value.
--  p_method_of_receipt             VARCHAR2 Element entry value.
--  p_tax_card_type                 VARCHAR2 Element entry value.
--  p_tax_percentage                VARCHAR2 Element entry value.
--  p_monthly_td                    VARCHAR2 Element entry value.
--  p_biweekly_td                   VARCHAR2 Element entry value.
--  p_date_returned                 DATE     Element entry value.
--  p_element_entry_id              VARCHAR2 Id of the element entry.
--  p_element_link_id               VARCHAR2 Id of the element link.
--  p_object_version_number Yes     VARCHAR2 Version number of the element
--                                           entry record.
--  p_input_value_id1               VARCHAR2 Id of the input value 1 for the
--                                              element.
--  p_input_value_id2               VARCHAR2 Id of the input value 2 for the
--                                               element.
--  p_input_value_id3               VARCHAR2 Id of the input value 3 for the
--                                              element.
--  p_input_value_id4               VARCHAR2 Id of the input value 4 for the
--                                              element.
--  p_input_value_id5               VARCHAR2 Id of the input value 5 for the
--                                              element.
--  p_input_value_id6               VARCHAR2 Id of the input value 6 for the
--                                              element.
--  p_input_value_id7               VARCHAR2 Id of the input value 7 for the
--                                               element.
--  p_input_value_id8               VARCHAR2 Id of the input value 8 for the
--                                               element.
--  p_input_value_id9               VARCHAR2 Id of the input value 9 for the
--                                               element.
--  p_datetrack_update_mode         VARCHAR2 The date track update mode for
--                                              the record
--
-- Post Success:
--
--	The API successfully updates the tax card entry.
--
-- Post Failure:
--   The API will raise an error.
--
-- Access Status:
--   Private. For Internal Development Use only.
--
-- {End Of Comments}
--
PROCEDURE update_taxcard (
    p_legislation_code      IN  VARCHAR2
    ,p_effective_date       IN  DATE
    ,p_assignment_id        IN  VARCHAR2
    ,p_person_id            IN  VARCHAR2
    ,p_business_group_id    IN  VARCHAR2
    ,p_tax_free_threshold   IN  NUMBER      DEFAULT NULL
    ,p_weekly_td            IN  NUMBER      DEFAULT NULL
    ,p_daily_td             IN  NUMBER      DEFAULT NULL
    ,p_registration_date    IN  DATE        DEFAULT NULL
    ,p_method_of_receipt    IN  VARCHAR2    DEFAULT NULL
    ,p_tax_card_type        IN  VARCHAR2    DEFAULT NULL
    ,p_tax_percentage       IN  NUMBER      DEFAULT NULL
    ,p_monthly_td           IN  NUMBER      DEFAULT NULL
    ,p_biweekly_td          IN  NUMBER      DEFAULT NULL
    ,p_date_returned        IN  DATE        DEFAULT NULL
    ,p_element_entry_id     IN  VARCHAR2
    ,p_element_link_id      IN  VARCHAR2
    ,p_object_version_number IN  VARCHAR2
    ,p_input_value_id1      IN  VARCHAR2    DEFAULT NULL
    ,p_input_value_id2      IN  VARCHAR2    DEFAULT NULL
    ,p_input_value_id3      IN  VARCHAR2    DEFAULT NULL
    ,p_input_value_id4      IN  VARCHAR2    DEFAULT NULL
    ,p_input_value_id5      IN  VARCHAR2    DEFAULT NULL
    ,p_input_value_id6      IN  VARCHAR2    DEFAULT NULL
    ,p_input_value_id7      IN  VARCHAR2    DEFAULT NULL
    ,p_input_value_id8      IN  VARCHAR2    DEFAULT NULL
    ,p_input_value_id9      IN  VARCHAR2    DEFAULT NULL
    ,p_input_value_id10     IN  VARCHAR2    DEFAULT NULL
    ,p_datetrack_update_mode    IN  VARCHAR2    DEFAULT NULL
	) IS

	l_start_date		    DATE;
	l_end_date		        DATE;
	l_warning		        BOOLEAN;
	l_element_entry_id	    NUMBER(15);
	l_ovn			        NUMBER(9);
	l_tax_percentage		pay_element_entry_values_f.screen_entry_value%TYPE;

	l_proc    varchar2(72) := g_package||'update_taxcard';
	BEGIN
	if g_debug then
		hr_utility.set_location('Entering:'|| l_proc, 1);
	end if;

	--l_start_date := sysdate;
	l_element_entry_id :=  to_number(p_element_entry_id);
	l_ovn := to_number(p_object_version_number);


	--If taxcard type is "NTC" , then the tax percentage need not be stored.
	if  p_tax_card_type = 'NTC' then
		l_tax_percentage :=  null;
	else
		l_tax_percentage := p_tax_percentage;
	end if;

	if g_debug then
		hr_utility.set_location('Entering:'|| l_proc, 2);
	end if;

	-- insert records into pay_element_entries_f and pay_element_entry_values_f
        /* Modified for to_number to fnd_number.canonical_to_number */
	pay_element_entry_api.update_element_entry
	     (p_validate			=>  FALSE
	     ,p_object_version_number	=>  l_ovn
	     ,p_update_warning			=>  l_warning
	     ,p_datetrack_update_mode	=>  p_datetrack_update_mode
	     ,p_effective_date			=>  p_effective_date
	     ,p_business_group_id		=> p_business_group_id
	     ,p_input_value_id1			=> p_input_value_id1
	     ,p_input_value_id2			=> p_input_value_id2
	     ,p_input_value_id3			=> p_input_value_id3
	     ,p_input_value_id4			=> p_input_value_id4
	     ,p_input_value_id5			=> p_input_value_id5
	     ,p_input_value_id6			=> p_input_value_id6
	     ,p_input_value_id7			=> p_input_value_id7
	     ,p_input_value_id8			=> p_input_value_id8
	     ,p_input_value_id9			=> p_input_value_id9
         ,p_input_value_id10		=> p_input_value_id10
		 ,p_entry_value1			=> p_method_of_receipt
		 ,p_entry_value2			=> p_tax_card_type
		 ,p_entry_value3			=> fnd_number.canonical_to_number(l_tax_percentage)
		 ,p_entry_value4			=> fnd_number.canonical_to_number(p_tax_free_threshold)
		 ,p_entry_value5			=> fnd_number.canonical_to_number(p_monthly_td)
		 ,p_entry_value6			=> fnd_number.canonical_to_number(p_biweekly_td)
		 ,p_entry_value7			=> fnd_number.canonical_to_number(p_weekly_td)
         ,p_entry_value8			=> fnd_number.canonical_to_number(p_daily_td)
		 ,p_entry_value9			=> (p_registration_date)
		 ,p_entry_value10    	    => (p_date_returned)
	     ,p_effective_start_date	=> l_start_date
	     ,p_effective_end_date		=> l_end_date
	     ,p_element_entry_id		=> l_element_entry_id
	     ,p_cost_allocation_keyflex_id	=> hr_api.g_number
	     ,p_updating_action_id		=> hr_api.g_number
	     ,p_original_entry_id		=> hr_api.g_number
	     ,p_creator_type			=> hr_api.g_varchar2
	     ,p_comment_id			    => hr_api.g_number
	     ,p_creator_id			    => hr_api.g_number
	     ,p_reason			    	=> hr_api.g_varchar2
	     ,p_subpriority			    => hr_api.g_number
	     ,p_date_earned			    => hr_api.g_date
	     ,p_personal_payment_method_id	=> hr_api.g_number
	     ,p_attribute_category		=> hr_api.g_varchar2
	     ,p_attribute1			    => hr_api.g_varchar2
	     ,p_attribute2			    => hr_api.g_varchar2
	     ,p_attribute3			    => hr_api.g_varchar2
	     ,p_attribute4			    => hr_api.g_varchar2
	     ,p_attribute5			    => hr_api.g_varchar2
	     ,p_attribute6			    => hr_api.g_varchar2
	     ,p_attribute7			    => hr_api.g_varchar2
	     ,p_attribute8			    => hr_api.g_varchar2
	     ,p_attribute9			    => hr_api.g_varchar2
	     ,p_attribute10			    => hr_api.g_varchar2
	     ,p_attribute11			    => hr_api.g_varchar2
	     ,p_attribute12			    => hr_api.g_varchar2
	     ,p_attribute13			    => hr_api.g_varchar2
	     ,p_attribute14			    => hr_api.g_varchar2
	     ,p_attribute15			    => hr_api.g_varchar2
	     ,p_attribute16			    => hr_api.g_varchar2
	     ,p_attribute17			    => hr_api.g_varchar2
	     ,p_attribute18			    => hr_api.g_varchar2
	     ,p_attribute19			    => hr_api.g_varchar2
	     ,p_attribute20			    => hr_api.g_varchar2
	     ,p_updating_action_type		=> hr_api.g_varchar2
	     ,p_entry_information_category	=> hr_api.g_varchar2
	     ,p_entry_information1		=> hr_api.g_varchar2
	     ,p_entry_information2		=> hr_api.g_varchar2
	     ,p_entry_information3		=> hr_api.g_varchar2
	     ,p_entry_information4		=> hr_api.g_varchar2
	     ,p_entry_information5		=> hr_api.g_varchar2
	     ,p_entry_information6		=> hr_api.g_varchar2
	     ,p_entry_information7		=> hr_api.g_varchar2
	     ,p_entry_information8		=> hr_api.g_varchar2
	     ,p_entry_information9		=> hr_api.g_varchar2
	     ,p_entry_information10		=> hr_api.g_varchar2
	     ,p_entry_information11		=> hr_api.g_varchar2
	     ,p_entry_information12		=> hr_api.g_varchar2
	     ,p_entry_information13		=> hr_api.g_varchar2
	     ,p_entry_information14		=> hr_api.g_varchar2
	     ,p_entry_information15		=> hr_api.g_varchar2
	     ,p_entry_information16		=> hr_api.g_varchar2
	     ,p_entry_information17		=> hr_api.g_varchar2
	     ,p_entry_information18		=> hr_api.g_varchar2
	     ,p_entry_information19		=> hr_api.g_varchar2
	     ,p_entry_information20		=> hr_api.g_varchar2
	     ,p_entry_information21		=> hr_api.g_varchar2
	     ,p_entry_information22		=> hr_api.g_varchar2
	     ,p_entry_information23		=> hr_api.g_varchar2
	     ,p_entry_information24		=> hr_api.g_varchar2
	     ,p_entry_information25		=> hr_api.g_varchar2
	     ,p_entry_information26		=> hr_api.g_varchar2
	     ,p_entry_information27		=> hr_api.g_varchar2
	     ,p_entry_information28		=> hr_api.g_varchar2
	     ,p_entry_information29		=> hr_api.g_varchar2
	     ,p_entry_information30		=> hr_api.g_varchar2);

	if g_debug then
		hr_utility.set_location('Entering:'|| l_proc, 3);
	end if;
	-- Do not COMMIT here. COMMIT should be done from the OAF Application Only.
	EXCEPTION
	WHEN OTHERS THEN
		 hr_utility.set_location('Error message : '||SQLERRM, 12);
		 RAISE;
	END update_taxcard;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< find_dt_upd_modes >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API returns the DT modes for pay_element_entries_f for a given
--	element_entry_id (base key value) on a specified date
--
-- Prerequisites:
--   The element_entry (p_base_key_value) must exist as of the effective date
--   of the change (p_effective_date).
--
-- In Parameters:
--	Name			Reqd	Type	Description
--	p_effective_date	Yes	DATE    The effective date of the
--                                             	change.
--	p_base_key_value	Yes 	NUMBER	ID of the element entry.
--
--
-- Post Success:
--
--   The API sets the following out parameters:
--
--	Name			Type	Description
--	p_correction		BOOLEAN	True if correction mode is valid.
--	p_update		BOOLEAN	True if update mode is valid.
--	p_update_override	BOOLEAN	True if update override mode is valid.
--	p_update_change_insert	BOOLEAN	True if update change insert mode is
--					valid.
--	p_update_start_date	DATE	Start date for Update record.
--	p_update_end_date	DATE	End date for Update record.
--	p_override_start_date	DATE	Start date for Override.
--	p_override_end_date	DATE	End date for Overrride.
--	p_upd_chg_start_date	DATE	Start date for Update Change.
--	p_upd_chg_end_date	DATE	End date for Update Change.

-- Post Failure:
--   The API will raise an error.
--
-- Access Status:
--   Private. For Internal Development Use only.
--
-- {End Of Comments}
--
	PROCEDURE find_dt_upd_modes
		(p_effective_date		IN  DATE
		 ,p_base_key_value		IN  NUMBER
		 ,p_correction			OUT NOCOPY BOOLEAN
		 ,p_update			OUT NOCOPY BOOLEAN
		 ,p_update_override		OUT NOCOPY BOOLEAN
		 ,p_update_change_insert	OUT NOCOPY BOOLEAN
		 ,p_correction_start_date	OUT NOCOPY DATE
		 ,p_correction_end_date		OUT NOCOPY DATE
		 ,p_update_start_date		OUT NOCOPY DATE
		 ,p_update_end_date		OUT NOCOPY DATE
		 ,p_override_start_date		OUT NOCOPY DATE
		 ,p_override_end_date		OUT NOCOPY DATE
		 ,p_upd_chg_start_date		OUT NOCOPY DATE
		 ,p_upd_chg_end_date		OUT NOCOPY DATE
		 ) IS

	l_proc 	varchar2(72) := g_package||'find_dt_upd_modes';

	BEGIN
	if g_debug then
		hr_utility.set_location('Entering:'|| l_proc, 1);
	end if;
	  --
	  -- Call the corresponding datetrack api
	  --
	  dt_api.find_dt_upd_modes_and_dates(
		p_effective_date		=> p_effective_date
		,p_base_table_name		=> 'pay_element_entries_f'
		,p_base_key_column		=> 'ELEMENT_ENTRY_ID'
		,p_base_key_value		=> p_base_key_value
		,p_correction			=> p_correction
		,p_update			=> p_update
		,p_update_override		=> p_update_override
		,p_update_change_insert		=> p_update_change_insert
		,p_correction_start_date	=> p_correction_start_date
		,p_correction_end_date		=> p_correction_end_date
		,p_update_start_date		=> p_update_start_date
		,p_update_end_date		=> p_update_end_date
		,p_override_start_date		=> p_override_start_date
		,p_override_end_date		=> p_override_end_date
		,p_upd_chg_start_date		=> p_upd_chg_start_date
		,p_upd_chg_end_date		=> p_upd_chg_end_date);
	if g_debug then
		hr_utility.set_location('Entering:'|| l_proc, 2);
	end if;
	  --
	  --hr_utility.set_location(' Leaving:'||l_proc, 10);
	EXCEPTION
		WHEN OTHERS THEN
	RAISE;
	END find_dt_upd_modes;
--
-- -----------------------------------------------------------------------------
-- |--------------------------< get_global_value >-----------------------------|
-- -----------------------------------------------------------------------------
--
-- {Start of Comments}
--
-- Description:
--   Returns the value for the global on a given date.
--
-- Prerequisites:
--   None
--
-- In Parameters
--	Name			Reqd	Type		Description
--	p_global_name		Yes	VARCHAR2	Assignment id
--	p_legislation_code	Yes	VARCHAR2	Legislation Code
--	p_effective_date	Yes	DATE     	Effective date
--
-- Post Success:
--	 The value of the global of type FF_GLOBALS_F.GLOBAL_VALUE is returned
--
-- Post Failure:
--   An error is raised
--
-- Access Status:
--   Internal Development Use Only
--
-- {End of Comments}
--
	FUNCTION get_global_value(
		p_global_name 		VARCHAR2,
		p_legislation_code 	VARCHAR2,
		p_effective_date 	DATE)
		RETURN ff_globals_f.global_value%TYPE IS

	CURSOR csr_globals IS
		SELECT global_value
		FROM ff_globals_f
		WHERE global_name = p_global_name
		AND legislation_code = p_legislation_code
		AND business_group_id  IS NULL
		AND p_effective_date BETWEEN effective_start_date AND effective_end_date;

	l_global_value ff_globals_f.global_value%TYPE;
	l_proc    varchar2(72) := g_package||'get_global_value';

	BEGIN
		if g_debug then
			hr_utility.set_location('Entering:'|| l_proc, 1);
		end if;

		OPEN csr_globals;
			FETCH csr_globals INTO l_global_value;
		CLOSE csr_globals;

		if g_debug then
			hr_utility.set_location('Entering:'|| l_proc, 2);
		end if;

		RETURN l_global_value;
	END get_global_value;

END py_dk_tax_card;

/
