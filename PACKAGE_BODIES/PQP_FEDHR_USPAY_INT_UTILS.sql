--------------------------------------------------------
--  DDL for Package Body PQP_FEDHR_USPAY_INT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_FEDHR_USPAY_INT_UTILS" AS
/* $Header: pqpfhexr.pkb 120.1 2006/01/16 03:36:26 asubrahm noship $ */

TYPE element_cross_rec IS RECORD
(
    element_new_name    pay_element_types_f.element_name%TYPE    ,
    element_type_id     pay_element_types_f.element_type_id%TYPE ,
    element_old_name    pay_element_types_f.element_name%TYPE    ,
    pay_basis           VARCHAR2(50)
);

TYPE element_cross_tab IS TABLE OF element_cross_rec
                       INDEX BY BINARY_INTEGER;
t_element_cross element_cross_tab;

TYPE paybasis_to_salbasis IS RECORD
(
    Pay_Basis           VARCHAR2(3),
    Sal_Basis           VARCHAR2(80)
);

TYPE pay_to_sal IS TABLE OF paybasis_to_salbasis
                       INDEX BY BINARY_INTEGER;
t_pb_to_sb  pay_to_sal;


g_package_name VARCHAR2(50) := 'pqp_fedhr_uspay_int_utils.';
-- ***************************************************************************
--
-- ----------------------------------------------------------------------------
-- |---------------------< return_new_element_name >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--    This function returns a new element name if an entry is present in
--    pqp_configuration_values table. Otherwise this function returns the
--    same element name as passed to it as input parameter.
-- Prerequisites:
--   None.
--
-- In Parameters:
--
-- Post Success:
--  This function will return an element name.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION return_new_element_name
(
  p_fedhr_element_name IN VARCHAR2,
  p_business_group_id  IN NUMBER,
  p_effective_date     IN DATE,
  p_pay_basis          IN VARCHAR2
) RETURN VARCHAR2 IS

 CURSOR chk_pqp_config_tab(p_business_group_id
                               per_business_groups.business_group_id%TYPE,
                           p_pay_basis VARCHAR2) IS
        SELECT ghr_general.return_NUMBER(pcv.pcv_information2)    element_type_id,
               pcv.pcv_information1               element_old_name,
               NVL(pcv.pcv_information3,'NULL')   pay_basis
        FROM   pqp_configuration_values pcv
        WHERE  pcv.pcv_information_category = 'PQP_FEDHR_ELEMENT'
        AND    pcv.business_group_id        = p_business_group_id
        AND    NVL(pcv_information3,'NULL') = NVL(p_pay_basis,'NULL')
        -- picking Ele name based on Sal Basis esp BSR
        ORDER BY pcv.pcv_information1;

 CURSOR element_type_cursor(p_element_type_id
                                     pay_element_types_f.element_type_id%TYPE,
                            p_business_group_id
                                     per_business_groups.business_group_id%TYPE,
                            p_effective_date DATE)  IS
        SELECT pet.element_name             element_new_name
        FROM   pay_element_types_f          pet
        WHERE  pet.business_group_id        = p_business_group_id
        AND    pet.element_type_id          = p_element_type_id
        AND    pet.business_group_id        = p_business_group_id
        AND    p_effective_date BETWEEN pet.effective_start_date AND
                                 pet.effective_end_date;

    l_element_id    NUMBER;

    l_element_name  pay_element_types_f.element_name%TYPE;

    l_counter       NUMBER;
    l_tab_count     NUMBER;
    l_proc_name     VARCHAR2(50) := 'return_new_element_name';
    l_pay_basis     VARCHAR2(10) :='NULL';
BEGIN
    hr_utility.set_location('Entering ' || g_package_name || l_proc_name, 10);

-- is_script_run function will return TRUE, if GHR and Payroll were already
-- installed. Because this is the only way pqp_configuration_values table
-- will have any row of cv_information_category = 'PQP_FEDHR_ELEMENT'
-- We are checking for only one element(Federal Awards) and not for all
-- the elements for the performance reasons. We assume that if one element is
-- present then all the elements will be automatically present.

    IF (p_fedhr_element_name = 'Basic Salary Rate') THEN
    l_pay_basis     := p_pay_basis;
    ELSE
    l_pay_basis     := 'NULL';
    END IF;

    IF (pqp_fedhr_uspay_int_utils.is_script_run
                      (p_business_group_id  => p_business_group_id,
                       p_fedhr_element_name => 'Basic Salary Rate') = TRUE)
    THEN
 -- {
        l_counter    := 0;
        l_element_id := NULL;
        l_tab_count  := t_element_cross.COUNT;

        IF (l_tab_count > 0) THEN  -- Hit in the cache table.
     -- {

-- This portion will be executed second time and onwards  employee re-runs the
-- RPA process.

          hr_utility.trace('In If - cache ');
          FOR l_counter IN 1..l_tab_count LOOP
-- To make this search faster a Binary Search can be used, instead of liner
-- search. But linear search should be okay, as there will not be more than
-- 35 rows.

              hr_utility.trace(t_element_cross(l_counter).element_old_name);
              IF (t_element_cross(l_counter).element_old_name =
                                               p_fedhr_element_name AND
                  t_element_cross(l_counter).pay_basis =
                                                  NVL(l_pay_basis, 'NULL'))
	      THEN
                  hr_utility.trace('Element Name Hit');

                  -- Fill in the variables with the details present in PL/SQL
                  -- table.

                  l_element_id  := t_element_cross(l_counter).element_type_id;
                  l_element_name:=t_element_cross(l_counter).element_new_name;
              END IF;
          END LOOP;
      --}
        END IF;

	IF (l_element_name IS NULL)
	THEN
-- This condition will be true in either of the following cases
-- 1. For the first time, If user did not run an RPA and no caching has occured.
-- 2. The previous IF condition did not return a result. This can happen in
-- a case, where user ran an RPA process and t_element_cross gets filled. But
-- 5 minutes later user creates a mapping for a new element. Then l_element_name
-- will be null, even if t_element_cross has some rows, then this IF portion
-- will be executed, and the new element mapping will be found out.
      --{
            -- This portion will be executed for the first time when employee
            -- runs the RPA process to fill in the cache.

           hr_utility.trace('In Else - Cursor');
            -- modified the cursor to pick the elements (BSR esp) based on
            -- Sal_Basis

            FOR c_pqp_config IN chk_pqp_config_tab (p_business_group_id =>
                                                         p_business_group_id ,
                                                    p_pay_basis => l_pay_basis)
            LOOP
                l_counter := l_counter + 1;
                t_element_cross(l_counter).element_type_id :=
                                             c_pqp_config.element_type_id;

                t_element_cross(l_counter).element_old_name :=
                                             c_pqp_config.element_old_name ;
                t_element_cross(l_counter).pay_basis :=
                                             c_pqp_config.pay_basis ;
                -- Filling the pl/sql table.
                FOR c_pet IN element_type_cursor(p_element_type_id =>
                                    t_element_cross(l_counter).element_type_id,
                                                 p_business_group_id =>
                                                      p_business_group_id,
                                                 p_effective_date =>
                                                      p_effective_date)
                LOOP
                    t_element_cross(l_counter).element_new_name :=
                                             c_pet.element_new_name ;
                END LOOP;

                hr_utility.trace (t_element_cross(l_counter).element_old_name);

                IF(t_element_cross(l_counter).element_old_name =
                                              p_fedhr_element_name AND
                   t_element_cross(l_counter).pay_basis =
                                              NVL(l_pay_basis, 'NULL'))
                THEN
                    hr_utility.trace ('Element name found');
                    l_element_id  :=t_element_cross(l_counter).element_type_id;
                    l_element_name:=t_element_cross(l_counter).element_new_name;
                    hr_utility.set_location('Element name is :'||l_element_name,15);
                END IF;
            END LOOP;
        --}
        END IF;
        IF l_element_name IS NULL
	THEN
            hr_utility.set_message(800, 'HR_7465_PLK_NOT_ELGBLE_ELE_NME');
            hr_utility.set_message_token('ELEMENT_NAME', p_fedhr_element_name);
            hr_utility.raise_error;
--          RETURN(p_fedhr_element_name);
        ELSE
            RETURN l_element_name;
        END IF;
 -- }
    ELSE -- is_script_run returns FALSE. Just return the passed element name.
 -- {
        RETURN  p_fedhr_element_name;
 -- }
    END IF;
    hr_utility.set_location ('Leaving ' || g_package_name || l_proc_name, 100);
END;
-- ***************************************************************************
--
-- ----------------------------------------------------------------------------
-- |---------------------< return_new_element_name >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--    This function returns a new element name if an entry is present in
--    pqp_configuration_values table. Otherwise this function returns the
--    same element name as passed to it as input parameter.
-- Prerequisites:
--   None.
--
-- In Parameters:
--
-- Post Success:
--  This function will return an element name.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION return_new_element_name
(
  p_salary_basis      IN VARCHAR2 ,
  p_business_group_id IN NUMBER   ,
  p_effective_date    IN DATE
) RETURN VARCHAR2 IS

 CURSOR chk_per_pay_bases(p_business_group_id
                                 per_business_groups.business_group_id%TYPE,
                          p_salary_basis    VARCHAR2,
                          p_effective_date  DATE) IS
        SELECT element_name
        FROM   per_pay_bases       ppb,
               pay_element_types_f pet,
               pay_input_values_f  piv
        WHERE  ppb.business_group_id = p_business_group_id
        AND    ppb.business_group_id = pet.business_group_id
        AND    ppb.business_group_id = piv.business_group_id
        AND    ppb.name              = p_salary_basis
        AND    ppb.input_value_id    = piv.input_value_id
        AND    piv.element_type_id    = pet.element_type_id
        AND    p_effective_date BETWEEN piv.effective_start_date AND
                                            piv.effective_end_date
        AND    p_effective_date BETWEEN pet.effective_start_date AND
                                            pet.effective_end_date;

    l_element_name  pay_element_types_f.element_name%TYPE;
    l_proc_name     VARCHAR2(50) := 'return_new_element_name';
BEGIN
    hr_utility.set_location('Entering ' || g_package_name || l_proc_name, 10);

    IF (pqp_fedhr_uspay_int_utils.is_script_run
                      (p_business_group_id  => p_business_group_id,
                       p_fedhr_element_name => 'Basic Salary Rate') = TRUE)
    THEN
 -- {
        FOR c_ppb IN chk_per_pay_bases (p_business_group_id =>
                                                         p_business_group_id ,
                                        p_salary_basis => p_salary_basis,
                                        p_effective_date => p_effective_date)
        LOOP
            l_element_name := c_ppb.element_name;
        END LOOP;
        RETURN l_element_name;
 -- }
    ELSE -- is_script_run returns FALSE. Just return the passed element name.
 -- {
        RETURN  NULL;
 -- }
    END IF;
    hr_utility.set_location ('Leaving ' || g_package_name || l_proc_name, 100);
END;
-- ***************************************************************************
--
-- ----------------------------------------------------------------------------
-- |---------------------< return_new_element_name >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--    This function returns a new element name if an entry is present in
--    pqp_configuration_values table. Otherwise this function returns the
--    same element name as passed to it as input parameter.
-- Prerequisites:
--   None.
--
-- In Parameters:
--
-- Post Success:
--  This function will return an element name.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION return_new_element_name
(
  p_assignment_id     IN VARCHAR2 ,
  p_business_group_id IN NUMBER   ,
  p_effective_date    IN DATE
) RETURN VARCHAR2 IS
 CURSOR chk_per_pay_bases(p_business_group_id
                                 per_business_groups.business_group_id%TYPE,
                          p_salary_basis_id    NUMBER,
                          p_effective_date  DATE) IS
        SELECT element_name
        FROM   per_pay_bases       ppb,
               pay_element_types_f pet,
               pay_input_values_f  piv
        WHERE  ppb.business_group_id = p_business_group_id
        AND    ppb.business_group_id = pet.business_group_id
        AND    ppb.business_group_id = piv.business_group_id
        AND    ppb.pay_basis_id      = p_salary_basis_id
        AND    ppb.input_value_id    = piv.input_value_id
        AND    piv.element_type_id   = pet.element_type_id
        AND    p_effective_date BETWEEN piv.effective_start_date AND
                                            piv.effective_end_date
        AND    p_effective_date BETWEEN pet.effective_start_date AND
                                            pet.effective_end_date;

CURSOR get_sal_basis_id(p_assignment_id    NUMBER ,
                        p_business_group_id
                               per_business_groups.business_group_id%TYPE,
                        p_effective_date DATE) IS
  SELECT pay_basis_id
  FROM   per_all_assignments_f
  WHERE  assignment_id     = p_assignment_id
  AND    business_group_id = p_business_group_id
  AND    p_effective_date BETWEEN effective_start_date
                                        AND effective_end_date;

    l_element_name  pay_element_types_f.element_name%TYPE;
    l_proc_name     VARCHAR2(50) := 'return_new_element_name';
    l_sal_basis_id  NUMBER;
BEGIN
    hr_utility.set_location('Entering ' || g_package_name || l_proc_name, 10);

    IF (pqp_fedhr_uspay_int_utils.is_script_run
                      (p_business_group_id  => p_business_group_id,
                       p_fedhr_element_name => 'Basic Salary Rate') = TRUE)
    THEN
 -- {
        FOR c_assgn IN get_sal_basis_id(p_assignment_id => p_assignment_id,
                                        p_business_group_id =>
                                                       p_business_group_id,
                                        p_effective_date => p_effective_date)
        LOOP
            l_sal_basis_id := c_assgn.pay_basis_id;
        END LOOP;
        FOR c_ppb IN chk_per_pay_bases (p_business_group_id =>
                                                         p_business_group_id ,
                                        p_salary_basis_id => l_sal_basis_id,
                                        p_effective_date => p_effective_date)
        LOOP
            l_element_name := c_ppb.element_name;
        END LOOP;
        RETURN l_element_name;
 -- }
    ELSE -- is_script_run returns FALSE. Just return the passed element name.
 -- {
        RETURN  NULL;
 -- }
    END IF;
    hr_utility.set_location ('Leaving ' || g_package_name || l_proc_name, 100);
END;
-- ***************************************************************************
--
-- ----------------------------------------------------------------------------
-- |---------------------------< is_script_run >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function return a TRUE if rows are present in pqp_configuration_values
--   table. Otherwise this function returns false.
-- Prerequisites:
--   None.
--
-- In Parameters:
--
-- Post Success:
--  This function will return a TRUE or FALSE.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION is_script_run
(
  p_fedhr_element_name  IN VARCHAR2,
  p_business_group_id   IN NUMBER
)  RETURN BOOLEAN IS

CURSOR chk_pqp_config_tab
IS
    SELECT pcv_information_category
    FROM   pqp_configuration_values
    WHERE  pcv_information_category = 'PQP_FEDHR_ELEMENT'
    AND    business_group_id        = p_business_group_id
    AND    pcv_information1         = p_fedhr_element_name
    AND    ROWNUM < 2;

    l_info_category pqp_configuration_values.pcv_information_category%TYPE;
    l_proc_name  VARCHAR2(50) := 'is_script_run';

BEGIN
    hr_utility.set_location ('Entering ' || g_package_name || l_proc_name, 10);

-- The following loop gets the count of rows present in pqp_configuration_values
-- table.
    l_info_category := NULL;
    FOR c_pqp_config IN chk_pqp_config_tab
    LOOP
        l_info_category := c_pqp_config.pcv_information_category;
        hr_utility.trace('In cursor loop');
    END LOOP;

-- If count > 0, that means some rows were present in pqp_configuration_Values
-- table. Therefore this function returns TRUE.

    IF l_info_category IS NOT NULL
    THEN
        hr_utility.trace('True');
        RETURN TRUE;
    ELSE
        hr_utility.trace('False');
        RETURN FALSE;
    END IF;
    hr_utility.set_location ('Leaving ' || g_package_name || l_proc_name, 100);
END;

-- ***************************************************************************
--
-- ----------------------------------------------------------------------------
-- |---------------------------is_ele_link_exists >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function return a TRUE if the element link exists.
--   Otherwise this function returns false.
-- Prerequisites:
--   None.
--
-- In Parameters:
--
-- Post Success:
--  This function will return a TRUE or FALSE.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

FUNCTION is_ele_link_exists
(
  p_ele_name         IN VARCHAR2,
  p_legislation_code IN VARCHAR2 DEFAULT NULL,
  p_bg_id            IN NUMBER   DEFAULT NULL
)
RETURN BOOLEAN IS

l_ele_type_id        NUMBER;
l_eli_flag           BOOLEAN;

CURSOR cur_ele_link_in_biz(p_ele_name VARCHAR2, p_business_group_id IN NUMBER)
IS
    SELECT DISTINCT eli.element_link_id link_id
    FROM   pay_element_types_f elt,
           pay_element_links_f eli
    WHERE  elt.element_type_id     = eli.element_type_id
    AND    UPPER(elt.element_name) = UPPER(p_ele_name)
    AND    eli.business_group_id   = p_business_group_id
    AND    elt.business_group_id   = p_business_group_id;

CURSOR cur_ele_link_in_leg(p_ele_name          IN VARCHAR2,
                           p_legislation_code  IN VARCHAR2,
                           p_business_group_id IN NUMBER)
IS
    SELECT DISTINCT eli.element_link_id link_id
    FROM   pay_element_types_f elt,
           pay_element_links_f eli
    WHERE  elt.element_type_id     = eli.element_type_id
    AND    UPPER(elt.element_name) = UPPER(p_ele_name)
    AND    elt.business_group_id   IS NULL
    AND    elt.legislation_code    = p_legislation_code
    AND    eli.business_group_id   = p_business_group_id;

-- eli.business_group can be added if we want to check for the link only in that business group;
--
BEGIN
--
    IF (p_legislation_code IS NOT NULL) THEN
        FOR ele_link_rec IN cur_ele_link_in_leg(p_ele_name, 'US', p_bg_id)
        LOOP
            IF ele_link_rec.link_id IS NOT NULL
            THEN
                l_eli_flag := TRUE;
            ELSE
                l_eli_flag := FALSE;
            END IF;
        END LOOP;
    ELSE
        FOR ele_link_rec IN cur_ele_link_in_biz(p_ele_name,p_bg_id)
        LOOP
            IF ele_link_rec.link_id IS NOT NULL
            THEN
                l_eli_flag := TRUE;
            ELSE
                l_eli_flag := FALSE;
            END IF;
        END LOOP;
    END IF;

    RETURN(l_eli_flag);

END;

-- ***************************************************************************
--
-- ----------------------------------------------------------------------------
-- |-------------------------<pay_basis_to_sal_basis >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function provides the mapping of Pay basisd to Salary Basis.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--
-- Post Success:
--  This function will return Salary Basis for the given Pay Basis.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

FUNCTION pay_basis_to_sal_basis
(
  p_pay_basis IN         VARCHAR2,
  p_sal_basis OUT NOCOPY VARCHAR2
) RETURN VARCHAR2 IS

l_pay_basis             VARCHAR2(80);
l_sal_basis             VARCHAR2(80);
l_info_cat              VARCHAR2(80);

CURSOR cur_pb_to_sb
IS
     SELECT pcv_information1 pb,
            pcv_information2 sb
     FROM   pqp_configuration_values pcv
     WHERE  pcv_information_category='PQP_PAY_SALARY_BASIS_MAPPING';

l_index    NUMBER:=0;

--
BEGIN
--

FOR pb_to_sb IN cur_pb_to_sb
LOOP
    l_index:=l_index+1;
    t_pb_to_sb(l_index).pay_basis:=pb_to_sb.pb;
    t_pb_to_sb(l_index).sal_basis:=pb_to_sb.sb;
END LOOP;

FOR l_index IN 1..t_pb_to_sb.COUNT
LOOP
    IF (t_pb_to_sb(l_index).pay_basis = p_pay_basis)
    THEN
       l_sal_basis:=t_pb_to_sb(l_index).sal_basis;
    END IF;
END LOOP;

RETURN(l_sal_basis);
--
END; -- End of pay basis mapping
--

-- ----------------------------------------------------------------------------
-- |---------------------< return_old_element_name >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--    This function returns a federal element name if an entry is present in
--    pqp_configuration_values table. Otherwise this function returns the
--    same element name as passed to it as input parameter.
-- Prerequisites:
--   None.
--
-- In Parameters:
--
-- Post Success:
--  This function will return federal element name.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

FUNCTION return_old_element_name
(
  p_agency_element_name IN VARCHAR2,
  p_business_group_id   IN NUMBER,
  p_effective_date      IN DATE
) RETURN VARCHAR2 IS

l_element_type_id    pay_element_types_f.element_type_id%type;

 CURSOR chk_element_type_id  IS
        SELECT ele.element_type_id element_type_id
        FROM   pay_element_types_f ele
        WHERE  ele.element_name  = p_agency_element_name
        AND    business_group_id = p_business_group_id
        AND    p_effective_date BETWEEN ele.effective_start_date
                                AND     ele.effective_end_date;

 CURSOR chk_pqp_config_tab(p_business_group_id per_business_groups.business_group_id%TYPE) IS
        SELECT ghr_general.return_NUMBER(pcv.pcv_information2)    element_type_id,
               pcv.pcv_information1               element_old_name,
               NVL(pcv.pcv_information3,'NULL')   pay_basis
        FROM   pqp_configuration_values pcv
        WHERE  pcv.pcv_information_category = 'PQP_FEDHR_ELEMENT'
        AND    pcv.business_group_id        = p_business_group_id
        AND    ghr_general.return_number(pcv.pcv_information2) = l_element_type_id
        ORDER BY pcv.pcv_information1;

/****
 CURSOR element_type_cursor(p_element_type_id
                                     pay_element_types_f.element_type_id%TYPE,
                            p_business_group_id
                                     per_business_groups.business_group_id%TYPE,
                            p_effective_date DATE)  IS
        SELECT pet.element_name             element_new_name
        FROM   pay_element_types_f          pet
        WHERE  pet.business_group_id        = p_business_group_id
        AND    pet.element_type_id          = p_element_type_id
        AND    pet.business_group_id        = p_business_group_id
        AND    p_effective_date BETWEEN pet.effective_start_date AND
                                 pet.effective_end_date;
****/
    l_element_id    NUMBER;

    l_element_name  pay_element_types_f.element_name%TYPE;

    l_counter       NUMBER;
    l_tab_count     NUMBER;
    l_proc_name     VARCHAR2(50) := 'return_old_element_name';
    l_pay_basis     VARCHAR2(10) := 'NULL';
BEGIN
    hr_utility.set_location('Entering ' || g_package_name || l_proc_name, 10);

    FOR chk_element_type_rec IN chk_element_type_id
    LOOP
        l_element_type_id := chk_element_type_rec.element_type_id;
    END LOOP;

-- is_script_run function will return TRUE, if GHR and Payroll were already
-- installed. Because this is the only way pqp_configuration_values table
-- will have any row of cv_information_category = 'PQP_FEDHR_ELEMENT'
-- We are checking for only one element(Federal Awards) and not for all
-- the elements for the performance reasons. We assume that if one element is
-- present then all the elements will be automatically present.

    IF (pqp_fedhr_uspay_int_utils.is_script_run
                      (p_business_group_id  => p_business_group_id,
                       p_fedhr_element_name => 'Basic Salary Rate') = TRUE)
    THEN
 -- {
        l_counter      := 0;
        l_element_id   := NULL;
        l_element_name := NULL;
        l_tab_count    := t_element_cross.COUNT;

        IF (l_tab_count > 0) THEN  -- Hit in the cache table.
     -- {

-- This portion will be executed second time and onwards  employee re-runs the
-- RPA process.

          hr_utility.trace('In If - cache ');
          FOR l_counter IN 1..l_tab_count LOOP
-- To make this search faster a Binary Search can be used, instead of liner
-- search. But linear search should be okay, as there will not be more than
-- 35 rows.

              hr_utility.trace(t_element_cross(l_counter).element_new_name);
              IF (t_element_cross(l_counter).element_new_name =
                                               p_agency_element_name )
	      THEN
                  hr_utility.trace('New Element Name Hit');

                  -- Fill in the variables with the details present in PL/SQL
                  -- table.

                  l_element_id   := t_element_cross(l_counter).element_type_id;
                  l_element_name := t_element_cross(l_counter).element_old_name;
              END IF;
          END LOOP;
      --}
        END IF;

	IF (l_element_name IS NULL)
	THEN
-- This condition will be true in either of the following cases
-- 1. For the first time, If user did not run an RPA and no caching has occured.
-- 2. The previous IF condition did not return a result. This can happen in
-- a case, where user ran an RPA process and t_element_cross gets filled. But
-- 5 minutes later user creates a mapping for a new element. Then l_element_name
-- will be null, even if t_element_cross has some rows, then this IF portion
-- will be executed, and the new element mapping will be found out.
      --{
            -- This portion will be executed for the first time when employee
            -- runs the RPA process to fill in the cache.

           hr_utility.trace('In Else - Cursor');
            -- modified the cursor to pick the elements (BSR esp) based on
            -- Sal_Basis

            FOR c_pqp_config IN chk_pqp_config_tab (p_business_group_id => p_business_group_id )
            LOOP
                l_counter := l_counter + 1;
                t_element_cross(l_counter).element_type_id :=
                                             c_pqp_config.element_type_id;

                t_element_cross(l_counter).element_old_name :=
                                             c_pqp_config.element_old_name ;
                t_element_cross(l_counter).pay_basis :=
                                             c_pqp_config.pay_basis ;
                -- Filling the pl/sql table.
                t_element_cross(l_counter).element_new_name :=
                                             p_agency_element_name ;

                hr_utility.trace (t_element_cross(l_counter).element_old_name);

                IF (t_element_cross(l_counter).element_new_name =
                                              p_agency_element_name )
                THEN
                    hr_utility.trace ('Element name found');
                    l_element_id  :=t_element_cross(l_counter).element_type_id;
                    l_element_name:=t_element_cross(l_counter).element_old_name;
                    hr_utility.set_location('Element name is :'||l_element_name,15);
                END IF;
            END LOOP;
        --}
        END IF;
        IF l_element_name IS NULL
	THEN
            RETURN(p_agency_element_name);
        ELSE
            RETURN l_element_name;
        END IF;
 -- }
    ELSE -- is_script_run returns FALSE. Just return the passed element name.
 -- {
        RETURN  p_agency_element_name;
 -- }
    END IF;
    hr_utility.set_location ('Leaving ' || g_package_name || l_proc_name, 100);
END return_old_element_name;
END pqp_fedhr_uspay_int_utils;

/
