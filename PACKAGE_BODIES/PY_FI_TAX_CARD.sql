--------------------------------------------------------
--  DDL for Package Body PY_FI_TAX_CARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PY_FI_TAX_CARD" AS
/* $Header: pyfitaxc.pkb 120.2.12000000.3 2007/02/27 06:16:49 dbehera noship $ */

g_package  CONSTANT varchar2(33) := 'hr_fi_taxcard_api.';
g_debug BOOLEAN := hr_utility.debug_enabled;

--
-- ----------------------------------------------------------------------------
-- |--------------------------------< ins >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--      This API will insert a tax and tax card entry for a Finland Assignment.
--      This API delegates to the create_element_entry procedure of the
--      pay_element_entry_api package.
--
-- Prerequisites:
--      The element link should exist for the given assignment
--      and business group.
--
-- In Parameters:
--      Name                            Reqd            Type                    Description
--      p_legislation_code              Yes             VARCHAR2                The Legislation Code.
--      p_effective_date                Yes             DATE                    The current effective date
--      p_assignment_id                 Yes             VARCHAR2                Assignment ID of the record.
--      p_person_id                     Yes             VARCHAR2                Person ID for the record.
--      p_business_group_id             Yes             VARCHAR2                Current Business Group Id.
--      p_element_entry_id_tc           Yes             VARCHAR2                Element entry Id for Tax Card Element.
--      p_element_entry_id_t            Yes             VARCHAR2                Element entry Id for Tax Element.
--      p_taxcard_type                                  VARCHAR2                Tax Card Type.
--      p_method_of_receipt                             VARCHAR2                Method of Receipt.
--      p_base_rate                                     NUMBER                  Base Rate.
--      p_tax_municipality                              VARCHAR2                Tax Municipality
--      p_additional_rate                               NUMBER                  Additional Rate.
--      p_override_manual_upd                           VARCHAR2                Override Manual Update Flag.
--      p_previous_income                               NUMBER                  Previous Income.
--      p_yearly_income_limit                           NUMBER                  Yearly Income Limit.
--      p_date_returned                                 DATE                    Date Returned.
--      p_registration_date                             DATE                    Registration Date.
--      p_lower_income_percentage          Number                Lower Income Percentage
--      p_primary_employment                            VARCHAR2                Primary Employment Flag.
--      p_extra_income_rate                             NUMBER                  Extra Income Rate.
--      p_extra_income_add_rate                         NUMBER                  Extra Income Additional Rate.
--      p_extra_income_limit                            NUMBER                  Extra Income Limit.
--      p_prev_extra_income                             NUMBER                  Previous Extra Income.
--
-- Post Success:
--      The API successfully inserts a tax card and/or tax entry.
--
-- Post Failure:
--      The API will raise an error.
--
-- Access Status:
--      Private. For Internal Development Use only.
--
-- {End Of Comments}
--
        PROCEDURE ins (
        p_legislation_code          IN 	VARCHAR2
        ,p_effective_date           IN  DATE
        ,p_assignment_id            IN	VARCHAR2
        ,p_person_id                IN	VARCHAR2
        ,p_business_group_id        IN	VARCHAR2
        ,p_element_entry_id_tc      IN  VARCHAR2
        ,p_element_entry_id_t       IN  VARCHAR2
        ,p_taxcard_type             IN	VARCHAR2   	DEFAULT NULL
        ,p_method_of_receipt        IN	VARCHAR2	DEFAULT NULL
        ,p_base_rate                IN	NUMBER		DEFAULT NULL
        ,p_tax_municipality         IN	VARCHAR2	DEFAULT NULL
        ,p_additional_rate          IN	NUMBER		DEFAULT NULL
        ,p_override_manual_upd      IN	VARCHAR2	DEFAULT NULL
        ,p_previous_income          IN	NUMBER		DEFAULT NULL
        ,p_yearly_income_limit      IN	NUMBER		DEFAULT NULL
        ,p_date_returned            IN	DATE		DEFAULT NULL
        ,p_registration_date        IN	DATE		DEFAULT NULL
	,p_lower_income_percentage          IN      NUMBER          DEFAULT NULL
        ,p_primary_employment       IN	VARCHAR2	DEFAULT NULL
        ,p_extra_income_rate        IN	NUMBER   	DEFAULT NULL
        ,p_extra_income_add_rate    IN	NUMBER		DEFAULT NULL
        ,p_extra_income_limit       IN	NUMBER   	DEFAULT NULL
        ,p_prev_extra_income        IN	NUMBER		DEFAULT NULL
        ) IS
        -- declarations here
        l_proc    varchar2(72) := g_package||'ins.';
        l_primary_asg_id per_all_assignments_f.assignment_id%TYPE;

        CURSOR cPrimaryAsg(asgid IN per_all_assignments_f.assignment_id%TYPE,
        effective_date IN DATE) IS
        SELECT
                pasg.assignment_id
        FROM
                per_all_assignments_f pasg,
                per_all_assignments_f asg
        WHERE asg.assignment_id = asgid
                AND fnd_date.canonical_to_date(effective_date) BETWEEN asg.effective_start_date AND asg.effective_end_date
                AND pasg.person_id = asg.person_id
                AND pasg.primary_flag = 'Y'
                AND fnd_date.canonical_to_date(effective_date) BETWEEN pasg.effective_start_date AND pasg.effective_end_date;
        BEGIN

        if g_debug then
                hr_utility.set_location('Entering:'|| l_proc, 1);
        end if;
        -- Check if the assignment is a primary Assignment.
        -- If 'Yes' then call insert_taxcard and then insert_tax
        -- If 'No' then call only insert_tax.
        IF is_primary_asg(p_assignment_id , p_effective_date) = true THEN
                if g_debug then
                        hr_utility.set_location('Entering:'|| l_proc, 2);
                end if;
                -- Get Primary Assignment Id for the given asg id.
                -- and pass it to the insert_taxcard procedure
                OPEN cPrimaryAsg(p_assignment_id , p_effective_date);
                FETCH cPrimaryAsg INTO l_primary_asg_id;
                CLOSE cPrimaryAsg;
                -- Call insert_taxcard procedure
                insert_taxcard (
                        p_legislation_code		=> p_legislation_code
                        ,p_effective_date		=> p_effective_date
                        ,p_assignment_id		=> p_assignment_id
                        ,p_person_id			=> p_person_id
                        ,p_business_group_id	=> p_business_group_id
                        ,p_element_entry_id_tc  => p_element_entry_id_tc
                        ,p_taxcard_type			=> p_taxcard_type
                        ,p_method_of_receipt	=> p_method_of_receipt
                        ,p_base_rate			=> p_base_rate
                        ,p_tax_municipality		=> p_tax_municipality
                        ,p_additional_rate		=> p_additional_rate
                        ,p_override_manual_upd	=> p_override_manual_upd
                        ,p_previous_income		=> p_previous_income
                        ,p_yearly_income_limit	=> p_yearly_income_limit
                        ,p_date_returned		=> fnd_date.canonical_to_date(p_date_returned)
                        ,p_registration_date	=> fnd_date.canonical_to_date(p_registration_date)
			,p_lower_income_percentage	=> p_lower_income_percentage);
                if g_debug then
                        hr_utility.set_location('Leaving:'|| l_proc, 2);
                end if;

                if g_debug then
                        hr_utility.set_location('Entering:'|| l_proc, 3);
                end if;
                -- Now call insert_tax procedure
                insert_tax (
                        p_legislation_code		=> p_legislation_code
                        ,p_effective_date		=> p_effective_date
                        ,p_assignment_id		=> p_assignment_id
                        ,p_person_id			=> p_person_id
                        ,p_business_group_id	=> p_business_group_id
                        ,p_element_entry_id_t   => p_element_entry_id_t
                        ,p_primary_employment	=> p_primary_employment
                        ,p_extra_income_rate	=> p_extra_income_rate
                        ,p_extra_income_add_rate => p_extra_income_add_rate
                        ,p_extra_income_limit	=> p_extra_income_limit
                        ,p_prev_extra_income	=> p_prev_extra_income);
                if g_debug then
                        hr_utility.set_location('Leaving:'|| l_proc, 3);
                end if;
        ELSIF is_primary_asg(p_assignment_id , p_effective_date) = false THEN
                if g_debug then
                        hr_utility.set_location('Entering:'|| l_proc, 4);
                end if;
                insert_tax (
                        p_legislation_code		=> p_legislation_code
                        ,p_effective_date		=> p_effective_date
                        ,p_assignment_id		=> p_assignment_id
                        ,p_person_id			=> p_person_id
                        ,p_business_group_id	=> p_business_group_id
                        ,p_element_entry_id_t   => p_element_entry_id_t
                        ,p_primary_employment	=> p_primary_employment
                        ,p_extra_income_rate	=> p_extra_income_rate
                        ,p_extra_income_add_rate => p_extra_income_add_rate
                        ,p_extra_income_limit	=> p_extra_income_limit
                        ,p_prev_extra_income	=> p_prev_extra_income);
                if g_debug then
                        hr_utility.set_location('Leaving:'|| l_proc, 4);
                end if;
        END IF;
        if g_debug then
                hr_utility.set_location('Leaving:'|| l_proc, 1);
        end if;
         -- Do not COMMIT here. COMMIT should be done thru the OAF Application only.

        EXCEPTION
        WHEN OTHERS THEN
        RAISE;
        END ins;
--
-- ----------------------------------------------------------------------------
-- |----------------------< insert_taxcard >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--      This API will insert a tax card entry for a Finland Assignment.
--      This API delegates to the create_element_entry procedure of the
--      pay_element_entry_api package.
--
-- Prerequisites:
--      The element link should exist for the given assignment
--      and business group.
--
-- In Parameters:
--      Name                            Reqd            Type                    Description
--      p_legislation_code              Yes             VARCHAR2                The Legislation Code.
--      p_effective_date                Yes             DATE                    The current effective date
--      p_assignment_id                 Yes             VARCHAR2                Assignment ID of the record.
--      p_person_id                     Yes             VARCHAR2                Person ID for the record.
--      p_business_group_id             Yes             VARCHAR2                Current Business Group Id.
--      p_element_entry_id_tc           Yes             VARCHAR2                Element entry Id for Tax Card Element.
--      p_element_entry_id_t            Yes             VARCHAR2                Element entry Id for Tax Element.
--      p_taxcard_type                                  VARCHAR2                Tax Card Type.
--      p_method_of_receipt                             VARCHAR2                Method of Receipt.
--      p_base_rate                                     NUMBER                  Base Rate.
--      p_tax_municipality                              VARCHAR2                Tax Municipality
--      p_additional_rate                               NUMBER                  Additional Rate.
--      p_override_manual_upd                           VARCHAR2                Override Manual Update Flag.
--      p_previous_income                               NUMBER                  Previous Income.
--      p_yearly_income_limit                           NUMBER                  Yearly Income Limit.
--      p_date_returned                                 DATE                    Date Returned.
--      p_registration_date                             DATE                    Registration Date.
--      p_lower_income_percentage          Number                Lower Income Percentage

--
-- Post Success:
--      The API successfully inserts the tax card entry.
--
-- Post Failure:
--      The API will raise an error.
--
-- Access Status:
--      Private. For Internal Development Use only.
--
-- {End Of Comments}
--
 PROCEDURE insert_taxcard (
        p_legislation_code      IN 	VARCHAR2
        ,p_effective_date       IN	DATE
        ,p_assignment_id        IN	VARCHAR2
        ,p_person_id            IN	VARCHAR2
        ,p_business_group_id    IN	VARCHAR2
        ,p_element_entry_id_tc  IN  VARCHAR2
        ,p_taxcard_type         IN	VARCHAR2   	DEFAULT NULL
        ,p_method_of_receipt    IN	VARCHAR2	DEFAULT NULL
        ,p_base_rate            IN	NUMBER		DEFAULT NULL
        ,p_tax_municipality     IN	VARCHAR2	DEFAULT NULL
        ,p_additional_rate      IN	NUMBER		DEFAULT NULL
        ,p_override_manual_upd  IN	VARCHAR2	DEFAULT NULL
        ,p_previous_income      IN	NUMBER		DEFAULT NULL
        ,p_yearly_income_limit  IN	NUMBER		DEFAULT NULL
        ,p_date_returned        IN	DATE		DEFAULT NULL
        ,p_registration_date    IN	DATE		DEFAULT NULL
	,p_lower_income_percentage  IN	NUMBER		DEFAULT NULL
        ) IS

        -- Declarations here
        l_start_date	DATE;
        l_end_date		DATE;
        l_warning		BOOLEAN;
        l_element_entry_id	NUMBER(15);
        l_ovn			NUMBER(9);
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
	l_input_value_id11	pay_input_values_f.input_value_id%TYPE;
        l_proc    varchar2(72) := g_package||'insert_taxcard.';

        CURSOR input_values_csr IS
                SELECT
                        et.element_type_id,
                        MIN(DECODE(iv.name, 'Tax Card Type', iv.input_value_id, null)) iv1,
                        MIN(DECODE(iv.name, 'Method of Receipt', iv.input_value_id, null)) iv2,
                        MIN(DECODE(iv.name, 'Base Rate', iv.input_value_id, null)) iv3,
                        MIN(DECODE(iv.name, 'Tax Municipality', iv.input_value_id, null)) iv4,
                        MIN(DECODE(iv.name, 'Additional Rate', iv.input_value_id, null)) iv5,
                        MIN(DECODE(iv.name, 'Override Manual Update', iv.input_value_id, null)) iv6,
                        MIN(DECODE(iv.name, 'Previous Income', iv.input_value_id, null)) iv7,
                        MIN(DECODE(iv.name, 'Yearly Income Limit', iv.input_value_id, null)) iv8,
                        MIN(DECODE(iv.name, 'Date Returned', iv.input_value_id, null)) iv9,
                        MIN(DECODE(iv.name, 'Registration Date', iv.input_value_id, null)) iv10,
			MIN(DECODE(iv.name, 'Lower Income Percentage', iv.input_value_id, null)) iv11
                FROM
                        pay_element_types_f et,
                        pay_input_values_f iv
                WHERE et.element_name = 'Tax Card'
                        AND et.legislation_code = 'FI'
                        AND et.business_group_id is null
                        AND fnd_date.canonical_to_date(p_effective_date) BETWEEN
                                et.effective_start_date AND et.effective_end_date
                        AND iv.element_type_id = et.element_type_id
                        AND fnd_date.canonical_to_date(p_effective_date)
                                BETWEEN iv.effective_start_date AND iv.effective_end_date
                        GROUP BY
                                et.element_type_id;

CURSOR CSR_CHECK_FND_SESSION
is
select session_id
from fnd_sessions
where session_id = userenv('sessionid')
and effective_date = p_effective_date;
LR_CHECK_FND_SESSION CSR_CHECK_FND_SESSION%ROWTYPE;

        BEGIN

                if g_debug then
                        hr_utility.set_location('Entering:'|| l_proc, 1);
                end if;

                --Insert row into fnd_Sessions table.
            OPEN  CSR_CHECK_FND_SESSION;
			        FETCH CSR_CHECK_FND_SESSION INTO LR_CHECK_FND_SESSION;
       		IF CSR_CHECK_FND_SESSION%notfound
            THEN
                INSERT INTO fnd_sessions(session_id, effective_date) VALUES(userenv('sessionid'), p_effective_date);
            END IF;

    		CLOSE CSR_CHECK_FND_SESSION;




                if g_debug then
                        hr_utility.set_location('Entering:'|| l_proc, 2);
                end if;
                -- fetch element link id
                l_element_link_id := pay_fi_tc_dp_upload.get_element_link_id(
                                                p_assignment_id, p_business_group_id,
                                                fnd_date.date_to_canonical(p_effective_date),
                                                'Tax Card');
                l_element_entry_id := p_element_entry_id_tc;
                if g_debug then
                        hr_utility.set_location('Leaving:'|| l_proc, 2);
                end if;

                if g_debug then
                        hr_utility.set_location('Entering:'|| l_proc, 3);
                end if;
                -- fetch all input value id's
                OPEN input_values_csr;
                FETCH input_values_csr INTO l_element_type_id, l_input_value_id1, l_input_value_id2,
                        l_input_value_id3, l_input_value_id4, l_input_value_id5, l_input_value_id6,
                        l_input_value_id7, l_input_value_id8,l_input_value_id9,l_input_value_id10,l_input_value_id11;
                CLOSE input_values_csr;

                if g_debug then
                        hr_utility.set_location('Leaving:'|| l_proc, 3);
                end if;
                if g_debug then
                        hr_utility.set_location('Entering:'|| l_proc, 4);
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
                ,p_entry_value1			=> p_taxcard_type
                ,p_entry_value2			=> p_method_of_receipt
                ,p_entry_value3			=> p_base_rate
                ,p_entry_value4			=> p_tax_municipality
                ,p_entry_value5			=> p_additional_rate
                ,p_entry_value6			=> p_override_manual_upd
                ,p_entry_value7			=> p_previous_income
                ,p_entry_value8			=> p_yearly_income_limit
                ,p_entry_value9			=> fnd_date.canonical_to_date(p_date_returned)
                ,p_entry_value10		=> fnd_date.canonical_to_date(p_registration_date)
                ,p_entry_value11		=> p_lower_income_percentage
                ,p_effective_start_date	=> l_start_date
                ,p_effective_end_date	=> l_end_date
                ,p_element_entry_id		=> l_element_entry_id
                ,p_object_version_number => l_ovn
                ,p_create_warning		=> l_warning
                );

                if g_debug then
                        hr_utility.set_location('Leaving:'|| l_proc, 4);
                end if;

                if g_debug then
                        hr_utility.set_location('Leaving:'|| l_proc, 1);
                end if;
                 -- Do not COMMIT here. COMMIT should be done thru the OAF Application only.
        EXCEPTION
        WHEN OTHERS THEN
                RAISE;
        END insert_taxcard;
--
-- ----------------------------------------------------------------------------
-- |------------------------< insert_tax >-------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--      This API will insert a tax  entry for a Finland Assignment.
--      This API delegates to the create_element_entry procedure of the
--      pay_element_entry_api package.
--
-- Prerequisites:
--      The element link should exist for the given assignment
--      and business group.
--
-- In Parameters:
--      Name                            Reqd            Type                    Description
--      p_legislation_code              Yes             VARCHAR2                The Legislation Code.
--      p_effective_date                Yes             DATE                    The current effective date
--      p_assignment_id                 Yes             VARCHAR2                Assignment ID of the record.
--      p_person_id                     Yes             VARCHAR2                Person ID for the record.
--      p_business_group_id             Yes             VARCHAR2                Current Business Group Id.
--      p_element_entry_id_tc           Yes             VARCHAR2                Element entry Id for Tax Card Element.
--      p_element_entry_id_t            Yes             VARCHAR2                Element entry Id for Tax Element.
--      p_primary_employment                            VARCHAR2                Primary Employment Flag.
--      p_extra_income_rate                             NUMBER                  Extra Income Rate.
--      p_extra_income_add_rate                         NUMBER                  Extra Income Additional Rate.
--      p_extra_income_limit                            NUMBER                  Extra Income Limit.
--      p_prev_extra_income                             NUMBER                  Previous Extra Income.
--
-- Post Success:
--      The API successfully inserts the tax card entry.
--
-- Post Failure:
--      The API will raise an error.
--
-- Access Status:
--      Private. For Internal Development Use only.
--
-- {End Of Comments}
--
        PROCEDURE insert_tax (
        p_legislation_code		IN 	VARCHAR2
        ,p_effective_date		IN	DATE
        ,p_assignment_id		IN	VARCHAR2
        ,p_person_id			IN	VARCHAR2
        ,p_business_group_id	IN	VARCHAR2
        ,p_element_entry_id_t   IN  VARCHAR2
        ,p_primary_employment	IN	VARCHAR2	DEFAULT NULL
        ,p_extra_income_rate	IN	NUMBER   	DEFAULT NULL
        ,p_extra_income_add_rate IN	NUMBER		DEFAULT NULL
        ,p_extra_income_limit	IN	NUMBER   	DEFAULT NULL
        ,p_prev_extra_income	IN	NUMBER		DEFAULT NULL
        ) IS

        -- Declarations here
        l_start_date	DATE;
        l_end_date		DATE;
        l_warning		BOOLEAN;
        l_element_entry_id	NUMBER(15);
        l_ovn			NUMBER(9);
        l_element_link_id	pay_element_links_f.element_link_id%TYPE;
        l_element_type_id	pay_element_types_f.element_type_id%TYPE;
        l_input_value_id1	pay_input_values_f.input_value_id%TYPE;
        l_input_value_id2	pay_input_values_f.input_value_id%TYPE;
        l_input_value_id3	pay_input_values_f.input_value_id%TYPE;
        l_input_value_id4	pay_input_values_f.input_value_id%TYPE;
        l_input_value_id5	pay_input_values_f.input_value_id%TYPE;

        CURSOR input_values_csr IS
                SELECT
                        et.element_type_id,
                        MIN(DECODE(iv.name, 'Primary Employment', iv.input_value_id, null)) iv1,
                        MIN(DECODE(iv.name, 'Extra Income Rate', iv.input_value_id, null)) iv2,
                        MIN(DECODE(iv.name, 'Extra Income Additional Rate', iv.input_value_id, null)) iv3,
                        MIN(DECODE(iv.name, 'Extra Income Limit', iv.input_value_id, null)) iv4,
                        MIN(DECODE(iv.name, 'Previous Extra Income', iv.input_value_id, null)) iv5
                FROM
                        pay_element_types_f et,
                        pay_input_values_f iv
                WHERE et.element_name = 'Tax'
                        AND et.legislation_code = 'FI'
                        AND et.business_group_id is null
                        AND fnd_date.canonical_to_date(p_effective_date)
                                BETWEEN et.effective_start_date AND et.effective_end_date
                        AND iv.element_type_id = et.element_type_id
                        AND fnd_date.canonical_to_date(p_effective_date)
                                BETWEEN iv.effective_start_date AND iv.effective_end_date
                GROUP BY
                        et.element_type_id;

                        CURSOR CSR_CHECK_FND_SESSION
is
select session_id
from fnd_sessions
where session_id = userenv('sessionid')
and effective_date = p_effective_date;
LR_CHECK_FND_SESSION CSR_CHECK_FND_SESSION%ROWTYPE;

CURSOR cIsElementAttached(l_asgid IN pay_element_entries_f.assignment_id%TYPE,
                l_business_grp_id IN pay_element_links_f.business_group_id%TYPE,
                l_element_name IN pay_element_types_f.element_name%TYPE,
                l_effective_date IN VARCHAR2) IS
                SELECT pee.element_entry_id,pee.OBJECT_VERSION_NUMBER EE_OVN
                FROM pay_element_types_f pet ,
                pay_element_links_f pel ,
                pay_element_entries_f pee
                WHERE pet.element_name = l_element_name
                AND pet.legislation_code = 'FI'
                AND pet.business_group_id IS NULL
                AND fnd_date.chardate_to_date(l_effective_date)
                        BETWEEN pet.effective_start_date AND pet.effective_end_date
                AND pel.element_type_id = pet.element_type_id
                AND pel.business_group_id = l_business_grp_id
                AND fnd_date.chardate_to_date(l_effective_date)
                        BETWEEN pel.effective_start_date AND pel.effective_end_date
                AND pee.element_link_id = pel.element_link_id
                AND fnd_date.chardate_to_date(l_effective_date)
                        BETWEEN pee.effective_start_date AND pee.effective_end_date
                AND pee.assignment_id = l_asgid;
lrIsElementAttached cIsElementAttached%ROWTYPE;
        l_proc    varchar2(72) := g_package||'insert_tax.';
               l_datetrack_update_mode VARCHAR2(255);
        l_record_started_today BOOLEAN;
        BEGIN
         --hr_utility.trace_on(NULL,'TELL');
                if g_debug then
                        hr_utility.set_location('Entering:'|| l_proc, 1);
                end if;
                --Insert row into fnd_Sessions table.
 OPEN  CSR_CHECK_FND_SESSION;
			        FETCH CSR_CHECK_FND_SESSION INTO LR_CHECK_FND_SESSION;
       		IF CSR_CHECK_FND_SESSION%notfound
            THEN
                INSERT INTO fnd_sessions(session_id, effective_date) VALUES(userenv('sessionid'), p_effective_date);
            END IF;

    		CLOSE CSR_CHECK_FND_SESSION;

                if g_debug then
                        hr_utility.set_location('Entering:'|| l_proc, 2);
                end if;
                -- fetch element link id
                l_element_link_id := pay_fi_tc_dp_upload.get_element_link_id(
                                                p_assignment_id, p_business_group_id,
                                                fnd_date.date_to_canonical(p_effective_date),
                                                'Tax');
                l_element_entry_id := p_element_entry_id_t;
                if g_debug then
                        hr_utility.set_location('Leaving:'|| l_proc, 2);
                end if;

                if g_debug then
                        hr_utility.set_location('Entering:'|| l_proc, 3);
                end if;
                -- fetch all input value id's
                OPEN input_values_csr;
                FETCH input_values_csr INTO l_element_type_id, l_input_value_id1, l_input_value_id2,
                        l_input_value_id3, l_input_value_id4, l_input_value_id5;
                        hr_utility.set_location('Entering:'|| l_element_type_id, 1);
                        hr_utility.set_location('Entering:'|| l_input_value_id1, 1);
                        hr_utility.set_location('Entering:'|| l_input_value_id2, 1);
                        hr_utility.set_location('Entering:'|| l_input_value_id3, 1);
                        hr_utility.set_location('Entering:'|| l_input_value_id4, 1);
                        hr_utility.set_location('Entering:'|| l_input_value_id5, 1);

                CLOSE input_values_csr;

                if g_debug then
                        hr_utility.set_location('Leaving:'|| l_proc, 3);
                end if;

                if g_debug then
                        hr_utility.set_location('Entering:'|| l_proc, 4);
                end if;
                -- insert records into pay_element_entries_f and pay_element_entry_values_f
                 OPEN cIsElementAttached(p_assignment_id , p_business_group_id , 'Tax' , p_effective_date);
				                FETCH cIsElementAttached INTO lrIsElementAttached;
				                IF cIsElementAttached%NOTFOUND THEN

			   					pay_element_entry_api.create_element_entry
									(p_effective_date		=> p_effective_date
									,p_business_group_id		=> p_business_group_id
									,p_assignment_id		=> p_assignment_id
									,p_element_link_id		=> l_element_link_id
									,p_entry_type 			=> 'E'
									,p_input_value_id1		=> l_input_value_id1
									,p_input_value_id2		=> l_input_value_id2
									,p_input_value_id3		=> l_input_value_id3
									,p_input_value_id4		=> l_input_value_id4
									,p_input_value_id5		=> l_input_value_id5
									,p_entry_value1			=> p_primary_employment
									,p_entry_value2			=> p_extra_income_rate
									,p_entry_value3			=> p_extra_income_add_rate
									,p_entry_value4			=> p_extra_income_limit
									,p_entry_value5			=> p_prev_extra_income
									,p_effective_start_date		=> l_start_date
									,p_effective_end_date		=> l_end_date
									,p_element_entry_id		=> l_element_entry_id
									,p_object_version_number	=> l_ovn
									,p_create_warning		=> l_warning);
				                ELSE
				                        hr_utility.set_location('is element attached true:', 3);

				                -- Check if the record started today. If yes then
				                -- Change the datetrack mode to correction.
				                l_record_started_today := is_element_started_today(p_assignment_id, 'Tax', p_effective_date);
				                l_datetrack_update_mode := 'CORRECTION'; -- doing this bcoz the user specified mode is to be given prio.
				                if l_record_started_today = true then
				                        l_datetrack_update_mode := 'CORRECTION';
				                end if;

				                -- update Tax Element
				               pay_element_entry_api.update_element_entry
							                (p_validate			=>  FALSE
							                ,p_object_version_number		=> lrIsElementAttached.EE_OVN
							                ,p_update_warning			=> l_warning
							                ,p_datetrack_update_mode		=> l_datetrack_update_mode
							                ,p_effective_date			=> p_effective_date
							                ,p_business_group_id		=> p_business_group_id
							                ,p_input_value_id1			=> l_input_value_id1
							                ,p_input_value_id2			=> l_input_value_id2
							                ,p_input_value_id3			=> l_input_value_id3
							                ,p_input_value_id4			=> l_input_value_id4
							                ,p_input_value_id5			=> l_input_value_id5
							                ,p_entry_value1			=> p_primary_employment
							                ,p_entry_value2			=> p_extra_income_rate
							                ,p_entry_value3			=> p_extra_income_add_rate
							                ,p_entry_value4			=> p_extra_income_limit
							                ,p_entry_value5			=> p_prev_extra_income
							                ,p_effective_start_date		=> l_start_date
							                ,p_effective_end_date		=> l_end_date
							                ,p_element_entry_id		=> lrIsElementAttached.element_entry_id
							                ,p_cost_allocation_keyflex_id	=> hr_api.g_number
							                ,p_updating_action_id		=> hr_api.g_number
							                ,p_original_entry_id		=> hr_api.g_number
							                ,p_creator_type			=> hr_api.g_varchar2
							                ,p_comment_id			=> hr_api.g_number
							                ,p_creator_id			=> hr_api.g_number
							                ,p_reason				=> hr_api.g_varchar2
							                ,p_subpriority			=> hr_api.g_number
							                ,p_date_earned			=> hr_api.g_date
							                ,p_personal_payment_method_id	=> hr_api.g_number
							                ,p_attribute_category		=> hr_api.g_varchar2
							                ,p_attribute1			=> hr_api.g_varchar2
							                ,p_attribute2			=> hr_api.g_varchar2
							                ,p_attribute3			=> hr_api.g_varchar2
							                ,p_attribute4			=> hr_api.g_varchar2
							                ,p_attribute5			=> hr_api.g_varchar2
							                ,p_attribute6			=> hr_api.g_varchar2
							                ,p_attribute7			=> hr_api.g_varchar2
							                ,p_attribute8			=> hr_api.g_varchar2
							                ,p_attribute9			=> hr_api.g_varchar2
							                ,p_attribute10			=> hr_api.g_varchar2
							                ,p_attribute11			=> hr_api.g_varchar2
							                ,p_attribute12			=> hr_api.g_varchar2
							                ,p_attribute13			=> hr_api.g_varchar2
							                ,p_attribute14			=> hr_api.g_varchar2
							                ,p_attribute15			=> hr_api.g_varchar2
							                ,p_attribute16			=> hr_api.g_varchar2
							                ,p_attribute17			=> hr_api.g_varchar2
							                ,p_attribute18			=> hr_api.g_varchar2
							                ,p_attribute19			=> hr_api.g_varchar2
							                ,p_attribute20			=> hr_api.g_varchar2
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
---------------------------------------------
hr_utility.set_location('EE    a :'|| lrIsElementAttached.element_entry_id, 1);
				                END IF;
				  CLOSE cIsElementAttached;

                if g_debug then
                        hr_utility.set_location('Leaving:'|| l_proc, 4);
                end if;

                if g_debug then
                        hr_utility.set_location('Leaving:'|| l_proc, 1);
                end if;
                 -- Do not COMMIT here. COMMIT should be done thru the OAF Application only.
        EXCEPTION
        WHEN OTHERS THEN
                RAISE;
        END insert_tax;
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< upd >-----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--      This API will update a tax and tax card entry for a Finland Assignment.
--      This API delegates to the update_element_entry procedure of the
--      pay_element_entry_api package.
--
-- Prerequisites:
--      The element entry (of element type 'Tax Card' and 'Tax) and the
--      corresponding element link should exist for the given assignment
--      and business group.
--
-- In Parameters:
--      Name                            Reqd            Type                    Description
--      p_legislation_code              Yes             VARCHAR2                The Legislation Code.
--      p_effective_date                Yes             DATE                    The current effective date
--      p_assignment_id                 Yes             VARCHAR2                Assignment ID of the record.
--      p_person_id                     Yes             VARCHAR2                Person ID for the record.
--      p_business_group_id             Yes             VARCHAR2                Current Business Group Id.
--      p_element_entry_id_tc           Yes             VARCHAR2                Element entry Id for Tax Card Element.
--      p_element_entry_id_t            Yes             VARCHAR2                Element entry Id for Tax Element.
--      p_taxcard_type                                  VARCHAR2                Tax Card Type.
--      p_method_of_receipt                             VARCHAR2                Method of Receipt.
--      p_base_rate                                     NUMBER                  Base Rate.
--      p_tax_municipality                              VARCHAR2                Tax Municipality
--      p_additional_rate                               NUMBER                  Additional Rate.
--      p_override_manual_upd                           VARCHAR2                Override Manual Update Flag.
--      p_previous_income                               NUMBER                  Previous Income.
--      p_yearly_income_limit                           NUMBER                  Yearly Income Limit.
--      p_date_returned                                 DATE                    Date Returned.
--      p_registration_date                             DATE                    Registration Date.
--	 p_lower_income_percentage      NUMBER          Lower Income Percentage
--      p_primary_employment                            VARCHAR2                Primary Employment Flag.
--      p_extra_income_rate                             NUMBER                  Extra Income Rate.
--      p_extra_income_add_rate                         NUMBER                  Extra Income Additional Rate.
--      p_extra_income_limit                            NUMBER                  Extra Income Limit.
--      p_prev_extra_income                             NUMBER                  Previous Extra Income.
--      p_input_value_id1                               VARCHAR2                Input Value Id for Entry 1
--      p_input_value_id2                               VARCHAR2                Input Value Id for Entry 2
--      p_input_value_id3                               VARCHAR2                Input Value Id for Entry 3
--      p_input_value_id4                               VARCHAR2                Input Value Id for Entry 4
--      p_input_value_id5                               VARCHAR2                Input Value Id for Entry 5
--      p_input_value_id6                               VARCHAR2                Input Value Id for Entry 6
--      p_input_value_id7                               VARCHAR2                Input Value Id for Entry 7
--      p_input_value_id8                               VARCHAR2                Input Value Id for Entry 8
--      p_input_value_id9                               VARCHAR2                Input Value Id for Entry 9
--      p_input_value_id10                              VARCHAR2                Input Value Id for Entry 10
--      p_input_value_id11                              VARCHAR2                Input Value Id for Entry 11
--      p_input_value_id12                              VARCHAR2                Input Value Id for Entry 12
--      p_input_value_id13                              VARCHAR2                Input Value Id for Entry 13
--      p_input_value_id14                              VARCHAR2                Input Value Id for Entry 14
--      p_input_value_id15                              VARCHAR2                Input Value Id for Entry 15
--      p_input_value_id16                              VARCHAR2                Input Value Id for Entry 16
--      p_datetrack_update_mode                         VARCHAR2                The date track mode.
--      p_object_version_number_tc                      VARCHAR2                Object Version Number for Tax Card.
--      p_object_version_number_t                       VARCHAR2                Object Version Number for Tax.
--
-- Post Success:
--      The API successfully updates the tax card and/or tax entry.
--
-- Post Failure:
--      The API will raise an error.
--
-- Access Status:
--      Private. For Internal Development Use only.
--
-- {End Of Comments}
--
        PROCEDURE upd (
        p_legislation_code		IN 	VARCHAR2
        ,p_effective_date		IN	DATE
        ,p_assignment_id		IN	VARCHAR2
        ,p_person_id			IN	VARCHAR2
        ,p_business_group_id	IN	VARCHAR2
        ,p_element_entry_id_tc  IN  VARCHAR2
        ,p_element_entry_id_t   IN  VARCHAR2
        ,p_taxcard_type			IN	VARCHAR2   	DEFAULT NULL
        ,p_method_of_receipt	IN	VARCHAR2	DEFAULT NULL
        ,p_base_rate			IN	NUMBER		DEFAULT NULL
        ,p_tax_municipality		IN	VARCHAR2	DEFAULT NULL
        ,p_additional_rate		IN	NUMBER		DEFAULT NULL
        ,p_override_manual_upd	IN	VARCHAR2	DEFAULT NULL
        ,p_previous_income		IN	NUMBER		DEFAULT NULL
        ,p_yearly_income_limit	IN	NUMBER		DEFAULT NULL
        ,p_date_returned		IN	DATE		DEFAULT NULL
        ,p_registration_date	IN	DATE		DEFAULT NULL
	,p_lower_income_percentage  IN      NUMBER          DEFAULT NULL
        ,p_primary_employment	IN	VARCHAR2	DEFAULT NULL
        ,p_extra_income_rate	IN	NUMBER   	DEFAULT NULL
        ,p_extra_income_add_rate IN	NUMBER		DEFAULT NULL
        ,p_extra_income_limit	IN	NUMBER   	DEFAULT NULL
        ,p_prev_extra_income	IN	NUMBER		DEFAULT NULL
        ,p_input_value_id1		IN	VARCHAR2	DEFAULT NULL
        ,p_input_value_id2		IN	VARCHAR2	DEFAULT NULL
        ,p_input_value_id3		IN	VARCHAR2	DEFAULT NULL
        ,p_input_value_id4		IN	VARCHAR2	DEFAULT NULL
        ,p_input_value_id5		IN	VARCHAR2	DEFAULT NULL
        ,p_input_value_id6		IN	VARCHAR2	DEFAULT NULL
        ,p_input_value_id7		IN	VARCHAR2	DEFAULT NULL
        ,p_input_value_id8		IN	VARCHAR2	DEFAULT NULL
        ,p_input_value_id9		IN	VARCHAR2	DEFAULT NULL
        ,p_input_value_id10		IN	VARCHAR2	DEFAULT NULL
        ,p_input_value_id11		IN	VARCHAR2	DEFAULT NULL
        ,p_input_value_id12		IN	VARCHAR2	DEFAULT NULL
        ,p_input_value_id13		IN	VARCHAR2	DEFAULT NULL
        ,p_input_value_id14		IN	VARCHAR2	DEFAULT NULL
        ,p_input_value_id15		IN	VARCHAR2	DEFAULT NULL
	,p_input_value_id16		IN	VARCHAR2	DEFAULT NULL
        ,p_datetrack_update_mode	IN	VARCHAR2 DEFAULT NULL
        ,p_object_version_number_tc	IN	VARCHAR2
        ,p_object_version_number_t	IN	VARCHAR2 DEFAULT NULL
        ) IS
        --declarations here
        l_proc    varchar2(72) := g_package||'upd.';
        l_primary_asg_id per_all_assignments_f.assignment_id%TYPE;

        CURSOR cPrimaryAsg(asgid IN per_all_assignments_f.assignment_id%TYPE,
        effective_date IN VARCHAR2) IS
        SELECT
                pasg.assignment_id
        FROM
                per_all_assignments_f pasg,
                per_all_assignments_f asg
        WHERE asg.assignment_id = asgid
                AND fnd_date.canonical_to_date(effective_date) BETWEEN asg.effective_start_date AND asg.effective_end_date
                AND pasg.person_id = asg.person_id
                AND pasg.primary_flag = 'Y'
                AND fnd_date.canonical_to_date(effective_date) BETWEEN pasg.effective_start_date AND pasg.effective_end_date;
        l_datetrack_update_mode VARCHAR2(255);
        l_record_started_today BOOLEAN;
        BEGIN
        l_datetrack_update_mode := p_datetrack_update_mode;
        -- hr_utility.trace_on(null,'T123');
        if g_debug then
                hr_utility.set_location('Entering:'|| l_proc, 1);
        end if;
        -- Check if the assignment is a primary Assignment.
        -- If 'Yes' then call update_taxcard and then update_tax
        -- If 'No' then call only update_tax.
        IF is_primary_asg(p_assignment_id , p_effective_date) = true THEN
                if g_debug then
                        hr_utility.set_location('Entering:'|| l_proc, 2);
                end if;
                -- Get Primary Assignment Id for the given asg id.
                -- and pass it to the update_taxcard procedure
                OPEN cPrimaryAsg(p_assignment_id , p_effective_date);
                FETCH cPrimaryAsg INTO l_primary_asg_id;
                CLOSE cPrimaryAsg;

                -- Check if the record started today. If yes then
                -- Change the datetrack mode to correction.
                l_record_started_today := is_element_started_today(p_assignment_id, 'Tax Card', p_effective_date);
                l_datetrack_update_mode := p_datetrack_update_mode; -- doing this bcoz the user specified mode is to be given prio.
                if l_record_started_today = true then
                        l_datetrack_update_mode := 'CORRECTION';
                end if;

                -- Call update_taxcard procedure
 			IF is_element_attached(p_assignment_id, p_business_group_id, 'Tax Card', p_effective_date) = true THEN
                update_taxcard (
                        p_legislation_code		=> p_legislation_code
                        ,p_effective_date		=> p_effective_date
                        ,p_assignment_id		=> p_assignment_id
                        ,p_person_id			=> p_person_id
                        ,p_business_group_id	=> p_business_group_id
                        ,p_element_entry_id_tc  => p_element_entry_id_tc
                        ,p_taxcard_type			=> p_taxcard_type
                        ,p_method_of_receipt	=> p_method_of_receipt
                        ,p_base_rate			=> p_base_rate
                        ,p_tax_municipality		=> p_tax_municipality
                        ,p_additional_rate		=> p_additional_rate
                        ,p_override_manual_upd	=> p_override_manual_upd
                        ,p_previous_income		=> p_previous_income
                        ,p_yearly_income_limit	=> p_yearly_income_limit
                        ,p_date_returned		=> p_date_returned
                        ,p_registration_date	=> p_registration_date
			,p_lower_income_percentage => p_lower_income_percentage
                        ,p_input_value_id1      => p_input_value_id1
                        ,p_input_value_id2      => p_input_value_id2
                        ,p_input_value_id3      => p_input_value_id3
                        ,p_input_value_id4      => p_input_value_id4
                        ,p_input_value_id5      => p_input_value_id5
                        ,p_input_value_id6      => p_input_value_id6
                        ,p_input_value_id7      => p_input_value_id7
                        ,p_input_value_id8      => p_input_value_id8
                        ,p_input_value_id9      => p_input_value_id9
                        ,p_input_value_id10     => p_input_value_id10
			,p_input_value_id11     => p_input_value_id11
                        ,p_datetrack_update_mode => l_datetrack_update_mode
                        ,p_object_version_number => p_object_version_number_tc);
                ELSE
                insert_taxcard (         p_legislation_code		=> p_legislation_code
				                        ,p_effective_date		=> p_effective_date
				                        ,p_assignment_id		=> p_assignment_id
				                        ,p_person_id			=> p_person_id
				                        ,p_business_group_id	=> p_business_group_id
				                        ,p_element_entry_id_tc  => p_element_entry_id_tc
				                        ,p_taxcard_type			=> p_taxcard_type
				                        ,p_method_of_receipt	=> p_method_of_receipt
				                        ,p_base_rate			=> p_base_rate
				                        ,p_tax_municipality		=> p_tax_municipality
				                        ,p_additional_rate		=> p_additional_rate
				                        ,p_override_manual_upd	=> p_override_manual_upd
				                        ,p_previous_income		=> p_previous_income
				                        ,p_yearly_income_limit	=> p_yearly_income_limit
				                        ,p_date_returned		=> fnd_date.canonical_to_date(p_date_returned)
				                        ,p_registration_date	=> fnd_date.canonical_to_date(p_registration_date)
							,p_lower_income_percentage => p_lower_income_percentage);


                END IF;
                if g_debug then
                        hr_utility.set_location('Leaving:'|| l_proc, 2);
                end if;
        END IF;

        -- Update Tax Element if tax element already present. Otherwise insert
        -- the Tax Element.
        if g_debug then
                hr_utility.set_location('Entering:'|| l_proc, 3);
        end if;
        IF is_element_attached(p_assignment_id, p_business_group_id, 'Tax', p_effective_date) = true THEN
                hr_utility.set_location('is element attached true:', 3);

                -- Check if the record started today. If yes then
                -- Change the datetrack mode to correction.
                l_record_started_today := is_element_started_today(p_assignment_id, 'Tax', p_effective_date);
                l_datetrack_update_mode := p_datetrack_update_mode; -- doing this bcoz the user specified mode is to be given prio.
                if l_record_started_today = true then
                        l_datetrack_update_mode := 'CORRECTION';
                end if;

                -- update Tax Element
                update_tax (
                        p_legislation_code		=> p_legislation_code
                        ,p_effective_date		=> p_effective_date
                        ,p_assignment_id		=> p_assignment_id
                        ,p_person_id			=> p_person_id
                        ,p_business_group_id	=> p_business_group_id
                        ,p_element_entry_id_t   => p_element_entry_id_t
                        ,p_primary_employment	=> p_primary_employment
                        ,p_extra_income_rate	=> p_extra_income_rate
                        ,p_extra_income_add_rate => p_extra_income_add_rate
                        ,p_extra_income_limit	=> p_extra_income_limit
                        ,p_prev_extra_income	=> p_prev_extra_income
                        ,p_input_value_id1      => p_input_value_id12
                        ,p_input_value_id2      => p_input_value_id13
                        ,p_input_value_id3      => p_input_value_id14
                        ,p_input_value_id4      => p_input_value_id15
                        ,p_input_value_id5      => p_input_value_id16
                        ,p_datetrack_update_mode => p_datetrack_update_mode
                        ,p_object_version_number => p_object_version_number_t);
        ELSIF is_element_attached(p_assignment_id, p_business_group_id, 'Tax', p_effective_date) = false THEN
        -- insert Tax Element.
                hr_utility.set_location('is element attached false:', 3);
                insert_tax (
                        p_legislation_code		=> p_legislation_code
                        ,p_effective_date		=> p_effective_date
                        ,p_assignment_id		=> p_assignment_id
                        ,p_person_id			=> p_person_id
                        ,p_business_group_id	=> p_business_group_id
                        ,p_element_entry_id_t   => p_element_entry_id_t
                        ,p_primary_employment	=> p_primary_employment
                        ,p_extra_income_rate	=> p_extra_income_rate
                        ,p_extra_income_add_rate => p_extra_income_add_rate
                        ,p_extra_income_limit	=> p_extra_income_limit
                        ,p_prev_extra_income	=> p_prev_extra_income);
        END IF;
        if g_debug then
                hr_utility.set_location('Leaving:'|| l_proc, 3);
        end if;

        if g_debug then
                hr_utility.set_location('Leaving:'|| l_proc, 1);
        end if;
         -- Do not COMMIT here. COMMIT should be done thru the OAF Application only.

        EXCEPTION
        WHEN OTHERS THEN
        RAISE;
        END upd;
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_taxcard >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--      This API will update a tax card entry for a Finland Assignment.
--      This API delegates to the update_element_entry procedure of the
--      pay_element_entry_api package.
--
-- Prerequisites:
--      The element entry (of element type 'Tax Card' ) and the
--      corresponding element link should exist for the given assignment
--      and business group.
--
-- In Parameters:
--      Name                            Reqd            Type                    Description
--      p_legislation_code              Yes             VARCHAR2                The Legislation Code.
--      p_effective_date                Yes             DATE                    The current effective date
--      p_assignment_id                 Yes             VARCHAR2                Assignment ID of the record.
--      p_person_id                     Yes             VARCHAR2                Person ID for the record.
--      p_business_group_id             Yes             VARCHAR2                Current Business Group Id.
--      p_element_entry_id_tc           Yes             VARCHAR2                Element entry Id for Tax Card Element.
--      p_taxcard_type                                  VARCHAR2                Tax Card Type.
--      p_method_of_receipt                             VARCHAR2                Method of Receipt.
--      p_base_rate                                     NUMBER                  Base Rate.
--      p_tax_municipality                              VARCHAR2                Tax Municipality
--      p_additional_rate                               NUMBER                  Additional Rate.
--      p_override_manual_upd                           VARCHAR2                Override Manual Update Flag.
--      p_previous_income                               NUMBER                  Previous Income.
--      p_yearly_income_limit                           NUMBER                  Yearly Income Limit.
--      p_date_returned                                 DATE                    Date Returned.
--      p_registration_date                             DATE                    Registration Date.
--      p_lower_income_percentage          Number                Lower Income Percentage
--      p_input_value_id1                               VARCHAR2                Input Value Id for Entry 1
--      p_input_value_id2                               VARCHAR2                Input Value Id for Entry 2
--      p_input_value_id3                               VARCHAR2                Input Value Id for Entry 3
--      p_input_value_id4                               VARCHAR2                Input Value Id for Entry 4
--      p_input_value_id5                               VARCHAR2                Input Value Id for Entry 5
--      p_input_value_id6                               VARCHAR2                Input Value Id for Entry 6
--      p_input_value_id7                               VARCHAR2                Input Value Id for Entry 7
--      p_input_value_id8                               VARCHAR2                Input Value Id for Entry 8
--      p_input_value_id9                               VARCHAR2                Input Value Id for Entry 9
--      p_input_value_id10                              VARCHAR2                Input Value Id for Entry 10
--      p_input_value_id11                              VARCHAR2                Input Value Id for Entry 11
--      p_datetrack_update_mode                         VARCHAR2                The date track mode.
--      p_object_version_number                         VARCHAR2                Object Version Number for Tax Card.
--
-- Post Success:
--      The API successfully updates the tax card and/or tax entry.
--
-- Post Failure:
--      The API will raise an error.
--
-- Access Status:
--      Private. For Internal Development Use only.
--
-- {End Of Comments}
--
        PROCEDURE update_taxcard (
        p_legislation_code      IN	VARCHAR2
        ,p_effective_date       IN	DATE
        ,p_assignment_id        IN	VARCHAR2
        ,p_person_id            IN	VARCHAR2
        ,p_business_group_id    IN	VARCHAR2
        ,p_element_entry_id_tc  IN      VARCHAR2
        ,p_taxcard_type         IN	VARCHAR2   	DEFAULT NULL
        ,p_method_of_receipt	IN	VARCHAR2	DEFAULT NULL
        ,p_base_rate            IN	NUMBER		DEFAULT NULL
        ,p_tax_municipality     IN	VARCHAR2	DEFAULT NULL
        ,p_additional_rate      IN	NUMBER		DEFAULT NULL
        ,p_override_manual_upd  IN	VARCHAR2	DEFAULT NULL
        ,p_previous_income      IN	NUMBER		DEFAULT NULL
        ,p_yearly_income_limit  IN	NUMBER		DEFAULT NULL
        ,p_date_returned		IN	DATE		DEFAULT NULL
        ,p_registration_date	IN	DATE		DEFAULT NULL
	,p_lower_income_percentage	IN	NUMBER		DEFAULT NULL
        ,p_input_value_id1		IN	VARCHAR2	DEFAULT NULL
        ,p_input_value_id2		IN	VARCHAR2	DEFAULT NULL
        ,p_input_value_id3		IN	VARCHAR2	DEFAULT NULL
        ,p_input_value_id4		IN	VARCHAR2	DEFAULT NULL
        ,p_input_value_id5		IN	VARCHAR2	DEFAULT NULL
        ,p_input_value_id6		IN	VARCHAR2	DEFAULT NULL
        ,p_input_value_id7		IN	VARCHAR2	DEFAULT NULL
        ,p_input_value_id8		IN	VARCHAR2	DEFAULT NULL
        ,p_input_value_id9		IN	VARCHAR2	DEFAULT NULL
        ,p_input_value_id10		IN	VARCHAR2	DEFAULT NULL
	,p_input_value_id11		IN	VARCHAR2	DEFAULT NULL
        ,p_datetrack_update_mode IN	VARCHAR2	DEFAULT NULL
        ,p_object_version_number IN VARCHAR2) IS
        --declarations here
        l_start_date		DATE;
        l_end_date		DATE;
        l_warning		BOOLEAN;
        l_element_entry_id	pay_element_entries_f.element_entry_id%TYPE;
        l_ovn			pay_element_entries_f.object_version_number%TYPE;

        l_proc    varchar2(72) := g_package||'update_taxcard';
        BEGIN
        if g_debug then
                hr_utility.set_location('Entering:'|| l_proc, 1);
        end if;

        l_ovn := to_number(p_object_version_number);

        --l_element_entry_id := find_element_entry_id(p_assignment_id, p_business_group_id,
        --'Tax Card',p_effective_date);

        l_element_entry_id := p_element_entry_id_tc;

        -- insert records into pay_element_entries_f and pay_element_entry_values_f
        pay_element_entry_api.update_element_entry
             (p_validate			=>  FALSE
             ,p_object_version_number		=> l_ovn
             ,p_update_warning			=> l_warning
             ,p_datetrack_update_mode		=> p_datetrack_update_mode
             ,p_effective_date			=> p_effective_date
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
             ,p_input_value_id11		=> p_input_value_id11
             ,p_entry_value1			=> p_taxcard_type
             ,p_entry_value2			=> p_method_of_receipt
             ,p_entry_value3			=> p_base_rate
             ,p_entry_value4			=> p_tax_municipality
             ,p_entry_value5			=> p_additional_rate
             ,p_entry_value6			=> p_override_manual_upd
             ,p_entry_value7			=> p_previous_income
             ,p_entry_value8			=> p_yearly_income_limit
             ,p_entry_value9			=> p_date_returned
             ,p_entry_value10			=> p_registration_date
             ,p_entry_value11			=> p_lower_income_percentage
             ,p_effective_start_date		=> l_start_date
             ,p_effective_end_date		=> l_end_date
             ,p_element_entry_id		=> l_element_entry_id
             ,p_cost_allocation_keyflex_id	=> hr_api.g_number
             ,p_updating_action_id		=> hr_api.g_number
             ,p_original_entry_id		=> hr_api.g_number
             ,p_creator_type			=> hr_api.g_varchar2
             ,p_comment_id			=> hr_api.g_number
             ,p_creator_id			=> hr_api.g_number
             ,p_reason				=> hr_api.g_varchar2
             ,p_subpriority			=> hr_api.g_number
             ,p_date_earned			=> hr_api.g_date
             ,p_personal_payment_method_id	=> hr_api.g_number
             ,p_attribute_category		=> hr_api.g_varchar2
             ,p_attribute1			=> hr_api.g_varchar2
             ,p_attribute2			=> hr_api.g_varchar2
             ,p_attribute3			=> hr_api.g_varchar2
             ,p_attribute4			=> hr_api.g_varchar2
             ,p_attribute5			=> hr_api.g_varchar2
             ,p_attribute6			=> hr_api.g_varchar2
             ,p_attribute7			=> hr_api.g_varchar2
             ,p_attribute8			=> hr_api.g_varchar2
             ,p_attribute9			=> hr_api.g_varchar2
             ,p_attribute10			=> hr_api.g_varchar2
             ,p_attribute11			=> hr_api.g_varchar2
             ,p_attribute12			=> hr_api.g_varchar2
             ,p_attribute13			=> hr_api.g_varchar2
             ,p_attribute14			=> hr_api.g_varchar2
             ,p_attribute15			=> hr_api.g_varchar2
             ,p_attribute16			=> hr_api.g_varchar2
             ,p_attribute17			=> hr_api.g_varchar2
             ,p_attribute18			=> hr_api.g_varchar2
             ,p_attribute19			=> hr_api.g_varchar2
             ,p_attribute20			=> hr_api.g_varchar2
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
                hr_utility.set_location('Entering:'|| l_proc, 1);
        end if;
        -- Do not COMMIT here. COMMIT should be done from the OAF Application Only.
        EXCEPTION
        WHEN OTHERS THEN
                RAISE;
        END update_taxcard;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_tax >-----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--      This API will update a tax entry for a Finland Assignment.
--      This API delegates to the update_element_entry procedure of the
--      pay_element_entry_api package.
--
-- Prerequisites:
--      The element entry (of element type  'Tax) and the
--      corresponding element link should exist for the given assignment
--      and business group.
--
-- In Parameters:
--      Name                            Reqd            Type                    Description
--      p_legislation_code              Yes             VARCHAR2                The Legislation Code.
--      p_effective_date                Yes             DATE                    The current effective date
--      p_assignment_id                 Yes             VARCHAR2                Assignment ID of the record.
--      p_person_id                     Yes             VARCHAR2                Person ID for the record.
--      p_business_group_id             Yes             VARCHAR2                Current Business Group Id.
--      p_element_entry_id_t            Yes             VARCHAR2                Element entry Id for Tax Element.
--      p_primary_employment                            VARCHAR2                Primary Employment Flag.
--      p_extra_income_rate                             NUMBER                  Extra Income Rate.
--      p_extra_income_add_rate                         NUMBER                  Extra Income Additional Rate.
--      p_extra_income_limit                            NUMBER                  Extra Income Limit.
--      p_prev_extra_income                             NUMBER                  Previous Extra Income.
--      p_input_value_id1                               VARCHAR2                Input Value Id for Entry 1
--      p_input_value_id2                               VARCHAR2                Input Value Id for Entry 2
--      p_input_value_id3                               VARCHAR2                Input Value Id for Entry 3
--      p_input_value_id4                               VARCHAR2                Input Value Id for Entry 4
--      p_input_value_id5                               VARCHAR2                Input Value Id for Entry 5
--      p_datetrack_update_mode                         VARCHAR2                The date track mode.
--      p_object_version_number                         VARCHAR2                Object Version Number for Tax.
--
-- Post Success:
--      The API successfully updates the tax card and/or tax entry.
--
-- Post Failure:
--      The API will raise an error.
--
-- Access Status:
--      Private. For Internal Development Use only.
--
-- {End Of Comments}
--
      PROCEDURE update_tax (
        p_legislation_code		IN	VARCHAR2
        ,p_effective_date		IN	DATE
        ,p_assignment_id		IN	VARCHAR2
        ,p_person_id			IN	VARCHAR2
        ,p_business_group_id	IN	VARCHAR2
        ,p_element_entry_id_t   IN  VARCHAR2
        ,p_primary_employment	IN	VARCHAR2	DEFAULT NULL
        ,p_extra_income_rate	IN	NUMBER   	DEFAULT NULL
        ,p_extra_income_add_rate IN	NUMBER		DEFAULT NULL
        ,p_extra_income_limit	IN	NUMBER   	DEFAULT NULL
        ,p_prev_extra_income	IN	NUMBER		DEFAULT NULL
        ,p_input_value_id1		IN	VARCHAR2	DEFAULT NULL
        ,p_input_value_id2		IN	VARCHAR2	DEFAULT NULL
        ,p_input_value_id3		IN	VARCHAR2	DEFAULT NULL
        ,p_input_value_id4		IN	VARCHAR2	DEFAULT NULL
        ,p_input_value_id5		IN	VARCHAR2	DEFAULT NULL
        ,p_datetrack_update_mode IN	VARCHAR2	DEFAULT NULL
        ,p_object_version_number IN	VARCHAR2) IS

        --declarations here
        l_start_date		DATE;
        l_end_date		DATE;
        l_warning		BOOLEAN;
        l_element_entry_id	pay_element_entries_f.element_entry_id%TYPE;
        l_ovn			pay_element_entries_f.object_version_number%TYPE;

        l_proc    varchar2(72) := g_package||'update_tax';
        BEGIN
        if g_debug then
                hr_utility.set_location('Entering:'|| l_proc, 1);
        end if;

        l_ovn := to_number(p_object_version_number);
        --l_element_entry_id := find_element_entry_id(p_assignment_id, p_business_group_id,
        --        'Tax',p_effective_date);
        l_element_entry_id := p_element_entry_id_t;

        -- insert records into pay_element_entries_f and pay_element_entry_values_f
        pay_element_entry_api.update_element_entry
             (p_validate			=>  FALSE
             ,p_object_version_number		=> l_ovn
             ,p_update_warning			=> l_warning
             ,p_datetrack_update_mode		=> p_datetrack_update_mode
             ,p_effective_date			=> p_effective_date
             ,p_business_group_id		=> p_business_group_id
             ,p_input_value_id1			=> p_input_value_id1
             ,p_input_value_id2			=> p_input_value_id2
             ,p_input_value_id3			=> p_input_value_id3
             ,p_input_value_id4			=> p_input_value_id4
             ,p_input_value_id5			=> p_input_value_id5
             ,p_entry_value1			=> p_primary_employment
             ,p_entry_value2			=> p_extra_income_rate
             ,p_entry_value3			=> p_extra_income_add_rate
             ,p_entry_value4			=> p_extra_income_limit
             ,p_entry_value5			=> p_prev_extra_income
             ,p_effective_start_date		=> l_start_date
             ,p_effective_end_date		=> l_end_date
             ,p_element_entry_id		=> l_element_entry_id
             ,p_cost_allocation_keyflex_id	=> hr_api.g_number
             ,p_updating_action_id		=> hr_api.g_number
             ,p_original_entry_id		=> hr_api.g_number
             ,p_creator_type			=> hr_api.g_varchar2
             ,p_comment_id			=> hr_api.g_number
             ,p_creator_id			=> hr_api.g_number
             ,p_reason				=> hr_api.g_varchar2
             ,p_subpriority			=> hr_api.g_number
             ,p_date_earned			=> hr_api.g_date
             ,p_personal_payment_method_id	=> hr_api.g_number
             ,p_attribute_category		=> hr_api.g_varchar2
             ,p_attribute1			=> hr_api.g_varchar2
             ,p_attribute2			=> hr_api.g_varchar2
             ,p_attribute3			=> hr_api.g_varchar2
             ,p_attribute4			=> hr_api.g_varchar2
             ,p_attribute5			=> hr_api.g_varchar2
             ,p_attribute6			=> hr_api.g_varchar2
             ,p_attribute7			=> hr_api.g_varchar2
             ,p_attribute8			=> hr_api.g_varchar2
             ,p_attribute9			=> hr_api.g_varchar2
             ,p_attribute10			=> hr_api.g_varchar2
             ,p_attribute11			=> hr_api.g_varchar2
             ,p_attribute12			=> hr_api.g_varchar2
             ,p_attribute13			=> hr_api.g_varchar2
             ,p_attribute14			=> hr_api.g_varchar2
             ,p_attribute15			=> hr_api.g_varchar2
             ,p_attribute16			=> hr_api.g_varchar2
             ,p_attribute17			=> hr_api.g_varchar2
             ,p_attribute18			=> hr_api.g_varchar2
             ,p_attribute19			=> hr_api.g_varchar2
             ,p_attribute20			=> hr_api.g_varchar2
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
                hr_utility.set_location('Entering:'|| l_proc, 1);
        end if;
        -- Do not COMMIT here. COMMIT should be done from the OAF Application Only.
        EXCEPTION
        WHEN OTHERS THEN
                RAISE;
        END update_tax;
--
-- ----------------------------------------------------------------------------
-- |------------------< find_element_entry_id >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API returns the element entry id of the element whose name is specified , that is attached to
--       the assignment on the given effective date
--
-- Prerequisites:
--   The assignment and the element entry should exist as of the effective date specified.
--
-- In Parameters:
--      Name                            Reqd            Type                                            Description
--      p_effective_date                Yes             VARCHAR2                                        The effective date of the change.
--      p_assignment_id                 Yes             per_all_assignments_f.assignment_id%TYPE        ID of the assignment
--      p_business_group_id             Yes             pay_element_links_f.business_group_id%TYPE      Business Group Id.
--      p_element_name                  Yes             pay_element_types_f.element_name%TYPE           Name of the Element to be checked.
--
--
-- Post Success:
--      The function returns  the id of the element entry.
--
-- Access Status:
--   Private. For Internal Development Use only.
--
-- {End Of Comments}
        FUNCTION find_element_entry_id (
        p_assignment_id			IN	pay_element_entries_f.assignment_id%TYPE,
        p_business_group_id 	IN	pay_element_links_f.business_group_id%TYPE,
        p_element_name			IN	pay_element_types_f.element_name%TYPE,
        p_effective_date		IN	VARCHAR2) RETURN pay_element_entries_f.element_entry_id%TYPE IS

        --declarations here
        l_attached_flag BOOLEAN;
        l_csr_result pay_element_entries_f.element_entry_id%TYPE;
        CURSOR cGetElementEntryId(l_asgid IN pay_element_entries_f.assignment_id%TYPE,
                l_business_grp_id IN pay_element_links_f.business_group_id%TYPE,
                l_element_name IN pay_element_types_f.element_name%TYPE,
                l_effective_date IN VARCHAR2) IS
                SELECT pee.element_entry_id
                FROM pay_element_types_f pet ,
                pay_element_links_f pel ,
                pay_element_entries_f pee
                WHERE pet.element_name = l_element_name
                AND pet.legislation_code = 'FI'
                AND pet.business_group_id IS NULL
                AND fnd_date.canonical_to_date(l_effective_date)
                        BETWEEN pet.effective_start_date AND pet.effective_end_date
                AND pel.element_type_id = pet.element_type_id
                AND pel.business_group_id = l_business_grp_id
                AND fnd_date.canonical_to_date(l_effective_date)
                        BETWEEN pel.effective_start_date AND pel.effective_end_date
                AND pee.element_link_id = pel.element_link_id
                AND fnd_date.canonical_to_date(l_effective_date)
                        BETWEEN pee.effective_start_date AND pee.effective_end_date
                AND pee.assignment_id = l_asgid;

        BEGIN
                OPEN cGetElementEntryId(p_assignment_id , p_business_group_id , p_element_name , p_effective_date);
                FETCH cGetElementEntryId INTO l_csr_result;
                CLOSE cGetElementEntryId;
                return l_csr_result;
        END find_element_entry_id;
--
-- ----------------------------------------------------------------------------
-- |---------------< is_element_started_today >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API returns true / false based on whether the given
--      elements start date is the effective date.
--
-- Prerequisites:
--   The assignment and the element entry should exist as of the effective date specified.
--
-- In Parameters:
--      Name                            Reqd            Type                                            Description
--      p_effective_date                Yes             VARCHAR2                                        The effective date of the change.
--      p_assignment_id                 Yes             per_all_assignments_f.assignment_id%TYPE        ID of the assignment
--      p_element_name  Yes                             pay_element_types_f.element_name%TYPE           Name of the Element to be checked.
--
--
-- Post Success:
--      The function returns true if the start date of the element is equals the effectived date
--
-- Access Status:
--   Private. For Internal Development Use only.
--
-- {End Of Comments}
        FUNCTION is_element_started_today (
        p_assignment_id			IN	pay_element_entries_f.assignment_id%TYPE,
        p_element_name			IN	pay_element_types_f.element_name%TYPE,
        p_effective_date		IN	VARCHAR2) RETURN BOOLEAN IS

        --declarations here
        Cursor cElementStartedToday(c_effective_date VARCHAR2, c_element_name pay_element_types_f.element_name%TYPE , c_asg_id per_all_assignments_f.assignment_id%TYPE) IS
                select pee.element_entry_id
                from pay_element_entries_f pee,
                pay_element_types_f pet
                where pee.element_type_id = pet.element_type_id
                and pet.element_name = c_element_name
                and c_effective_date between pet.effective_start_date and pet.effective_end_date
                and pee.assignment_id = c_asg_id
                and c_effective_date between pee.effective_start_date and pee.effective_end_date
                and pee.effective_start_date = c_effective_date;
        l_element_entry_id pay_element_entries_f.element_entry_id%TYPE;
        BEGIN
         open cElementStartedToday(p_effective_date,p_element_name,p_assignment_id);
         fetch cElementStartedToday into l_element_entry_id;
         IF cElementStartedToday%NOTFOUND THEN
                CLOSE cElementStartedToday;
                return false;
         ELSE
                CLOSE cElementStartedToday;
                return true;
          END IF;
        END;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< is_primary_asg >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API returns true / false based on whether the given
--      assignment Id is a Primary Assignment or not.
--
-- Prerequisites:
--   The assignment Id should exist as of the effective date specified.
--
-- In Parameters:
--      Name                    Reqd            Type                                            Description
--      p_effective_date        Yes             VARCHAR2                                        The effective date of the change.
--      p_assignment_id         Yes             per_all_assignments_f.assignment_id%TYPE        ID of the assignment
--
--
-- Post Success:
--      The function returns true if the assignment is Primary and false otherwise
--
-- Access Status:
--   Private. For Internal Development Use only.
--
-- {End Of Comments}
        FUNCTION is_primary_asg (
        p_assignment_id			IN	per_all_assignments_f.assignment_id%TYPE,
        p_effective_date		IN	VARCHAR2) RETURN BOOLEAN IS

        --declarations here
        l_primary_flag BOOLEAN;
        l_csr_result per_all_assignments_f.primary_flag%TYPE;
        CURSOR cIsPrimaryAsg(asgid IN per_all_assignments_f.assignment_id%TYPE,
                effective_date IN VARCHAR2) IS
                SELECT asg.primary_flag
                FROM per_all_assignments_f asg
                WHERE asg.assignment_id = asgid
                AND fnd_date.chardate_to_date(effective_date) BETWEEN
                asg.effective_start_date AND asg.effective_end_date;
        BEGIN
                OPEN cIsPrimaryAsg(p_assignment_id , p_effective_date);
                FETCH cIsPrimaryAsg INTO l_csr_result;
                CLOSE cIsPrimaryAsg;

                IF l_csr_result = 'Y' THEN
                        l_primary_flag := true;
                ELSIF l_csr_result = 'N' THEN
                        l_primary_flag := false;
                END IF;

                return l_primary_flag;
        END is_primary_asg;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< is_element_attached >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API returns true / false based on whether the given
--      element is attached to the assignment Id on the given effective date
--
-- Prerequisites:
--   The assignment and the element entry should exist as of the effective date specified.
--
-- In Parameters:
--      Name                    Reqd            Type                                            Description
--      p_effective_date        Yes             VARCHAR2                                        The effective date of the change.
--      p_assignment_id         Yes             per_all_assignments_f.assignment_id%TYPE        ID of the assignment
--      p_business_group_id     Yes             pay_element_links_f.business_group_id%TYPE      Business Group Id.
--      p_element_name  Yes                     pay_element_types_f.element_name%TYPE           Name of the Element to be checked.
--
--
-- Post Success:
--      The function returns true if the element is attached to the assignment and false otherwise.
--
-- Access Status:
--   Private. For Internal Development Use only.
--
-- {End Of Comments}
        FUNCTION is_element_attached (
        p_assignment_id			IN	pay_element_entries_f.assignment_id%TYPE,
        p_business_group_id 	IN	pay_element_links_f.business_group_id%TYPE,
        p_element_name			IN	pay_element_types_f.element_name%TYPE,
        p_effective_date		IN	VARCHAR2) RETURN BOOLEAN IS

        --declarations here
        l_attached_flag BOOLEAN;
        l_csr_result pay_element_entries_f.element_entry_id%TYPE;
        CURSOR cIsElementAttached(l_asgid IN pay_element_entries_f.assignment_id%TYPE,
                l_business_grp_id IN pay_element_links_f.business_group_id%TYPE,
                l_element_name IN pay_element_types_f.element_name%TYPE,
                l_effective_date IN VARCHAR2) IS
                SELECT pee.element_entry_id
                FROM pay_element_types_f pet ,
                pay_element_links_f pel ,
                pay_element_entries_f pee
                WHERE pet.element_name = l_element_name
                AND pet.legislation_code = 'FI'
                AND pet.business_group_id IS NULL
                AND fnd_date.chardate_to_date(l_effective_date)
                        BETWEEN pet.effective_start_date AND pet.effective_end_date
                AND pel.element_type_id = pet.element_type_id
                AND pel.business_group_id = l_business_grp_id
                AND fnd_date.chardate_to_date(l_effective_date)
                        BETWEEN pel.effective_start_date AND pel.effective_end_date
                AND pee.element_link_id = pel.element_link_id
                AND fnd_date.chardate_to_date(l_effective_date)
                        BETWEEN pee.effective_start_date AND pee.effective_end_date
                AND pee.assignment_id = l_asgid;

        BEGIN
                OPEN cIsElementAttached(p_assignment_id , p_business_group_id , p_element_name , p_effective_date);
                FETCH cIsElementAttached INTO l_csr_result;
                IF cIsElementAttached%NOTFOUND THEN
                        CLOSE cIsElementAttached;
                        return false;
                ELSE
                        CLOSE cIsElementAttached;
                        return true;
                END IF;
        END is_element_attached;
--
-- ----------------------------------------------------------------------------
-- |------------------------< find_dt_upd_modes >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API returns the DT modes for pay_element_entries_f for a given
--      element_entry_id (base key value) on a specified date
--
-- Prerequisites:
--   The element_entry (p_base_key_value) must exist as of the effective date
--   of the change (p_effective_date).
--
-- In Parameters:
--      Name                            Reqd            Type            Description
--      p_effective_date                Yes             DATE            The effective date of the change.
--      p_base_key_value                Yes             NUMBER          ID of the element entry.
--
--
-- Post Success:
--
--   The API sets the following out parameters:
--
--      Name                            Type            Description
--      p_correction                    BOOLEAN         True if  correction mode is valid.
--      p_update                        BOOLEAN         True if update mode is valid.
--      p_update_override               BOOLEAN         True if update override mode is valid.
--      p_update_change_insert          BOOLEAN         True if update change insert mode is valid.
--      p_update_start_date             DATE            Start date for Update record.
--      p_update_end_date               DATE            End date for Update record.
--      p_override_start_date           DATE            Start date for Override.
--      p_override_end_date             DATE            End date for Overrride.
--      p_upd_chg_start_date            DATE            Start date for Update Change.
--      p_upd_chg_end_date              DATE            End date for Update Change.

-- Post Failure:
--   The API will raise an error.
--
-- Access Status:
--   Private. For Internal Development Use only.
--
-- {End Of Comments}
--
        PROCEDURE find_dt_upd_modes
                (p_effective_date           IN  DATE
                 ,p_base_key_value          IN  NUMBER
                 ,p_correction              OUT NOCOPY BOOLEAN
                 ,p_update			        OUT NOCOPY BOOLEAN
                 ,p_update_override         OUT NOCOPY BOOLEAN
                 ,p_update_change_insert	OUT NOCOPY BOOLEAN
                 ,p_correction_start_date	OUT NOCOPY DATE
                 ,p_correction_end_date		OUT NOCOPY DATE
                 ,p_update_start_date		OUT NOCOPY DATE
                 ,p_update_end_date         OUT NOCOPY DATE
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
                ,p_update			    => p_update
                ,p_update_override		=> p_update_override
                ,p_update_change_insert	=> p_update_change_insert
                ,p_correction_start_date => p_correction_start_date
                ,p_correction_end_date	=> p_correction_end_date
                ,p_update_start_date	=> p_update_start_date
                ,p_update_end_date		=> p_update_end_date
                ,p_override_start_date	=> p_override_start_date
                ,p_override_end_date	=> p_override_end_date
                ,p_upd_chg_start_date	=> p_upd_chg_start_date
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

END py_fi_tax_card;


/
