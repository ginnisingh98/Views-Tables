--------------------------------------------------------
--  DDL for Package Body PAY_US_DEF_COMP_457
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_DEF_COMP_457" as
/* $Header: py457rol.pkb 115.7 2002/12/31 22:33:21 tmehra ship $ */
--
-- ----------------------------------------------------------------------------+
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------+
--
g_contr_type    varchar2(1)  := 'G'         ; -- Global Contr Type for 457
g_get_bal_flag  varchar2(7)  := 'CORRECT'             ;
g_package       varchar2(33) := 'pay_us_def_comp_457.'; -- Global Package Name
--
-- ----------------------------------------------------------------------------+
-- |                     Private Function called by Rollover_process
-- ----------------------------------------------------------------------------+
-- ----------------------------------------------------------------------------+
-- |------< Business_Rule_Proc >------|
-- ----------------------------------------------------------------------------+
-- Description
--   This procedure is used to report the records present in the
--   PAY_US_CONTRIBUTION_HISTORY table that are deviating the business
--   rules.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_person_id       Person Id for whom the data  has to be transferred.
--                     If person Id is null, then the program proceeds for
--                     for the whole GRE (Tax Unit)
--   p_year            Year (YYYY) for which the rollover has to run
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure Business_Rule_Proc(p_year      IN NUMBER ,
                             p_person_id IN NUMBER ,
                             p_gre_id    IN NUMBER )
IS
    l_proc               VARCHAR2(72) := g_package || 'Business_Rule_Proc';
    l_full_name          per_people_f.full_name%TYPE;
    l_person_id          NUMBER;
    l_business_group_id  NUMBER;
    l_max_contr_allowed  NUMBER;
    l_amt_contr          NUMBER;
    l_includable_comp    NUMBER;
    TYPE l_rec_type IS RECORD
    (
        person_id           per_all_assignments_f.person_id%TYPE ,
        business_group_id   NUMBER,
        max_contr_allowed   NUMBER,
        amt_contr           NUMBER,
        includable_comp     NUMBER
    );

    TYPE c_cursor_type1 IS REF CURSOR
        RETURN l_rec_type;
    Business_Rule_Proc_cur c_cursor_type1;
BEGIN
    hr_utility.set_location('Entering:'||l_proc, 5);

/* In the SQLs belwo the MAX(NVL(max_contr_allowed, 0)) = 0  OR
   SUM(NVL(includable_comp, 0)) = 0) have been used, these are because it is a
   kind of an exception. Includable comp should not be zero and as well
   max contr allowed should not be 0. It indicates that function that
   calculates these two values returned 0 */

    IF (p_person_id IS NULL AND p_gre_id IS NOT NULL) THEN

        OPEN Business_Rule_Proc_cur FOR
            SELECT person_id                     ,
                   business_group_id             ,
                   MAX(NVL(max_contr_allowed, 0)),
                   SUM(NVL(amt_contr, 0))        ,
                   SUM(NVL(includable_comp, 0))
            FROM   PAY_US_CONTRIBUTION_HISTORY
            WHERE  TO_NUMBER(TO_CHAR(date_from, 'YYYY')) = p_year
            AND    TO_NUMBER(TO_CHAR(date_to  , 'YYYY')) = p_year
            AND    tax_unit_id                           = p_gre_id
            GROUP BY person_id        ,
                     business_group_id
            HAVING (MAX(NVL(max_contr_allowed, 0)) < SUM(NVL(amt_contr, 0)) OR
                    MAX(NVL(max_contr_allowed, 0)) = 0  OR
                    SUM(NVL(includable_comp, 0))   = 0)      ;

    hr_utility.set_location('Opened cursor Business_Rule_Proc_cur' , 10);

    ELSIF (p_person_id IS NOT NULL AND p_gre_id IS NULL) THEN

        OPEN Business_Rule_Proc_cur FOR
            SELECT person_id                     ,
                   business_group_id             ,
                   MAX(NVL(max_contr_allowed, 0)),
                   SUM(NVL(amt_contr, 0))        ,
                   SUM(NVL(includable_comp, 0))
            FROM   PAY_US_CONTRIBUTION_HISTORY
            WHERE  TO_NUMBER(TO_CHAR(date_from, 'YYYY')) = p_year
            AND    TO_NUMBER(TO_CHAR(date_to  , 'YYYY')) = p_year
            AND    person_id = p_person_id
            GROUP BY person_id        ,
                     business_group_id
            HAVING (MAX(NVL(max_contr_allowed, 0)) < SUM(NVL(amt_contr, 0)) OR
                    MAX(NVL(max_contr_allowed, 0)) = 0  OR
                    SUM(NVL(includable_comp, 0))   = 0)                 ;

    hr_utility.set_location('Opened cursor Business_Rule_Proc_cur' , 11);

    ELSIF (p_person_id IS NOT NULL AND p_gre_id IS NOT NULL) THEN

        OPEN Business_Rule_Proc_cur FOR
            SELECT person_id                     ,
                   business_group_id             ,
                   MAX(NVL(max_contr_allowed, 0)),
                   SUM(NVL(amt_contr, 0))        ,
                   SUM(NVL(includable_comp, 0))
            FROM   PAY_US_CONTRIBUTION_HISTORY
            WHERE  TO_NUMBER(TO_CHAR(date_from, 'YYYY')) = p_year
            AND    TO_NUMBER(TO_CHAR(date_to  , 'YYYY')) = p_year
            AND    person_id     = p_person_id
            AND    tax_unit_id   = p_gre_id
            GROUP BY person_id        ,
                     business_group_id
            HAVING (MAX(NVL(max_contr_allowed, 0)) < SUM(NVL(amt_contr, 0)) OR
                    MAX(NVL(max_contr_allowed, 0)) = 0  OR
                    SUM(NVL(includable_comp, 0))   = 0)                 ;

    hr_utility.set_location('Opened cursor Business_Rule_Proc_cur' , 12);

    END IF;

    LOOP
    BEGIN
        FETCH Business_Rule_Proc_cur INTO l_person_id        ,
                                          l_business_group_id,
                                          l_max_contr_allowed,
                                          l_amt_contr        ,
                                          l_includable_comp  ;
        EXIT WHEN Business_Rule_Proc_cur%NOTFOUND;
-- EE
        SELECT full_name
        INTO   l_full_name
        FROM   per_people_f      ppf,
               per_person_types  ppt
        WHERE  ppf.person_id = l_person_id
        AND    ppf.effective_start_date =
                       (SELECT MAX(a.effective_start_date)
                        FROM   per_people_f     a,
                               per_person_types b
                        WHERE  TO_NUMBER(TO_CHAR(a.effective_start_date,'YYYY'))
                                          <= p_year
                        AND    TO_NUMBER(TO_CHAR(a.effective_end_date,'YYYY'))
                                         >= p_year
                        AND    a.person_id          = ppf.person_id
                        AND    a.person_type_id     = b.person_type_id
                        AND    a.business_group_id  = l_business_group_id
                        AND    b.system_person_type = 'EMP' )
        AND    ppf.business_group_id = l_business_group_id
        AND    ppf.person_type_id      = ppt.person_type_id
        AND    ppt.system_person_type  = 'EMP' ;

        IF (FND_GLOBAL.CONC_REQUEST_ID <> -1 ) THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Person Id = ' ||
            TO_CHAR(l_person_id) || ', Name = ' || l_full_name || ' has '
            || 'contribution of ' || TO_CHAR(l_amt_contr) ||
            ' Maximum contribution allowed for ' || ' for the Year = '
           || TO_CHAR(p_year) || ' is ' || TO_CHAR(l_max_contr_allowed) ||
           ' Includable Comp is ' || TO_CHAR(l_includable_comp) || ' in Business Group Id = ' || TO_CHAR(l_business_group_id));
        ELSE
            hr_utility.set_location('Person Id = ' ||
            TO_CHAR(l_person_id) || ', Name = ' || l_full_name || ' has '
            || 'contribution of ' || TO_CHAR(l_amt_contr) ||
            ' Maximum contribution allowed for ' || ' for the Year = '
           || TO_CHAR(p_year) || ' is ' || TO_CHAR(l_max_contr_allowed) ||
           ' Includable Comp is ' || TO_CHAR(l_includable_comp) || ' in Business Group Id = ' || TO_CHAR(l_business_group_id), 15);
        END IF;
    EXCEPTION
    WHEN OTHERS THEN
        IF (FND_GLOBAL.CONC_REQUEST_ID <> -1 ) THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occured in ' || l_proc
           || SUBSTR(SQLERRM, 1, 128) || ' ' || TO_CHAR(SQLCODE));
        ELSE
            hr_utility.set_location('Error occured ' || l_proc
           || SUBSTR(SQLERRM, 1, 128) || ' ' || TO_CHAR(SQLCODE) , 15);
        END IF;
    END;
    END LOOP;
    CLOSE  Business_Rule_Proc_cur;
    hr_utility.set_location('Leaving:'||l_proc, 999);

EXCEPTION
    WHEN OTHERS THEN
        IF (FND_GLOBAL.CONC_REQUEST_ID <> -1 ) THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occured in ' || l_proc
           || SUBSTR(SQLERRM, 1, 128) || ' ' || TO_CHAR(SQLCODE));
        ELSE
            hr_utility.set_location('Error occured ' || l_proc
           || SUBSTR(SQLERRM, 1, 128) || ' ' || TO_CHAR(SQLCODE) , 15);
        END IF;
END Business_Rule_Proc;

-- ----------------------------------------------------------------------------+
-- |------< PAY_CONTRB_INS >------|
-- ----------------------------------------------------------------------------+
-- Description
--   This procedure is used to call the API that inserts data into the
--   PAY_US_CONTRIBUTION_HISTORY table
--+
-- Pre Conditions
--   None.
--+
-- In Parameters
--  l_business_group_id  Business Group Id
--  l_amt_contr          Amount contributed by the person
--  l_max_contr_allowed  Maximum contribution allowed for this person
--  l_includable_comp    Includable compensation for this person
--  l_tax_unit_id        Respective Government Reporting entity
--  l_person_id          Person Id for whom the data  has to be transferred.
--                       If person Id is null, then the program proceeds for
--                       for the whole GRE (Tax Unit)
--  l_year               Year (YYYY) for which the rollover has to run
-- Out Parameters
--  l_contr_history_id   The primary key value generated in
--                       PAY_US_CONTRIBUTION _HISTORY table
--  l_object_version_number The object_version_number generated in
--                       PAY_US_CONTRIBUTION _HISTORY table
--+
-- Post Success
--   Processing continues
--+
-- Post Failure
--   Errors handled by the procedure
--+
-- Access Status
--   Internal table handler use only.
--+
Procedure Pay_Contrb_Ins
(
     l_business_group_id      IN  NUMBER  ,
     l_amt_contr              IN  NUMBER  ,
     l_max_contr_allowed      IN  NUMBER  ,
     l_includable_comp        IN  NUMBER  ,
     l_tax_unit_id            IN  NUMBER  ,
     l_person_id              IN  NUMBER  ,
     l_year                   IN  NUMBER  ,
     l_contr_history_id       OUT NOCOPY NUMBER  ,
     l_object_version_number  OUT NOCOPY NUMBER
) IS
    l_proc               VARCHAR2(72) := g_package || 'Pay_Contrb_Ins';
BEGIN
    hr_utility.set_location('Entering:'||l_proc, 5);

    pay_contribution_history_api.create_contribution_history
    (
        p_validate                   => false                       ,
        p_contr_history_id           => l_contr_history_id          ,
        p_person_id                  => l_person_id                 ,
        p_date_from                  => TO_DATE('01/01/' || to_char(l_year),
                                         'DD/MM/YYYY'),
        p_date_to                    => TO_DATE('31/12/' || to_char(l_year),
                                         'DD/MM/YYYY'),
        p_contr_type                 => g_contr_type                ,
        p_business_group_id          => l_business_group_id         ,
        p_legislation_code           => 'US'                        ,
        p_amt_contr                  => l_amt_contr                 ,
        p_max_contr_allowed          => l_max_contr_allowed         ,
        p_includable_comp            => l_Includable_comp           ,
        p_tax_unit_id                => l_tax_unit_id               ,
        p_source_system              => 'PAY'                       ,
        p_object_version_number      => l_object_version_number
    );

    hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
    WHEN OTHERS THEN

     l_contr_history_id       := 0;
     l_object_version_number  := 0;

        IF (FND_GLOBAL.CONC_REQUEST_ID <> -1 ) THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occured while inserting in' ||
            ' PAY_US_CONTRIBUTION_HISTORY table for Person id = ' ||
            TO_CHAR(l_person_id) || ' GRE = ' || TO_CHAR(l_tax_unit_id)
           || SUBSTR(SQLERRM, 1, 128) || ' ' || TO_CHAR(SQLCODE) ||
              ' in ' || l_proc);
        ELSE
            hr_utility.set_location('Error occured while inserting in ' ||
            ' PAY_US_CONTRIBUTION_HISTORY table for Person id = ' ||
            TO_CHAR(l_person_id) || ' GRE = ' || TO_CHAR(l_tax_unit_id)
           || SUBSTR(SQLERRM, 1, 128) || ' ' || TO_CHAR(SQLCODE) ||
              ' in ' || l_proc, 15);
        END IF;
END Pay_Contrb_Ins;

-- ----------------------------------------------------------------------------+
-- |------< Pay_Contrb_Upd >------|
-- ----------------------------------------------------------------------------+
-- Description
--   This procedure is used to call the API that updates data into the
--   PAY_US_CONTRIBUTION_HISTORY table
--+
-- Pre Conditions
--   None.
--+
-- In Parameters
--  l_contr_history_id   The primary key value generated in
--                      PAY_US_CONTRIBUTION _HISTORY table
--  l_object_version_number The object_version_number generated in
--                      PAY_US_CONTRIBUTION _HISTORY table
--  l_amt_contr          Amount contributed by the person
--  l_max_contr_allowed  Maximum contribution allowed for this person
--  l_includable_comp    Includable compensation for this person
--+
-- Post Success
--   Processing continues
--+
-- Post Failure
--   Errors handled by the procedure
--+
-- Access Status
--   Internal table handler use only.
--+
Procedure Pay_Contrb_Upd
(
     l_contr_history_id      IN  OUT NOCOPY NUMBER  ,
     l_object_version_number IN  OUT NOCOPY NUMBER  ,
     l_amt_contr             IN  NUMBER      ,
     l_max_contr_allowed     IN  NUMBER      ,
     l_includable_comp       IN  NUMBER
) IS
    l_proc               VARCHAR2(72) := g_package || 'Pay_Contrb_Upd';
    l_history_id         NUMBER;
    l_ovn                NUMBER;
BEGIN
    hr_utility.set_location('Entering:'||l_proc, 5);

    l_history_id := l_contr_history_id;
    l_ovn        := l_object_version_number;

    pay_contribution_history_api.update_contribution_history
    (
        p_validate              => false                   ,
        p_contr_history_id      => l_contr_history_id      ,
        p_amt_contr             => l_amt_contr             ,
        p_max_contr_allowed     => l_max_contr_allowed     ,
        p_includable_comp       => l_includable_comp       ,
        p_object_version_number => l_object_version_number
     );

    hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
    WHEN OTHERS THEN

    l_contr_history_id := l_history_id;
    l_object_version_number := l_ovn;

        IF (FND_GLOBAL.CONC_REQUEST_ID <> -1 ) THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occured while Updating in' ||
            ' PAY_US_CONTRIBUTION_HISTORY table for Contr_history_id = ' ||
            TO_CHAR(l_contr_history_id) || ' Object Version Number = ' ||
            TO_CHAR(l_object_version_number)
           || SUBSTR(SQLERRM, 1, 128) || ' ' || TO_CHAR(SQLCODE) ||
              ' in ' || l_proc);
        ELSE
            hr_utility.set_location('Error occured while Updating in ' ||
            ' PAY_US_CONTRIBUTION_HISTORY table for Contr_history_id = ' ||
            TO_CHAR(l_contr_history_id) || ' Object Version Number = ' ||
            TO_CHAR(l_object_version_number)
           || SUBSTR(SQLERRM, 1, 128) || ' ' || TO_CHAR(SQLCODE) ||
              ' in ' || l_proc, 15);
        END IF;
END Pay_Contrb_Upd;

-- ----------------------------------------------------------------------------+
-- |------< Get_bal >------|
-- ----------------------------------------------------------------------------+
-- Description
-- This procedure calulates the value of the respective balance for a
-- given assignment, dimension and date
-- Pre Conditions
--   None.
--+
-- In Parameters
--  p_effective_date The date for which balance amount has to be calculated
--  p_assignment_id  The assignment Id for which balance amount has to be
--+                  calculated
--  p_tax_unit_id    Respective Government Reporting entity
--  p_balance_name   Balance Name
--  p_dimension_name Dimension Name
--  p_business_group_id Business Group Id
--+
-- Post Success
--   Processing continues
--+
-- Post Failure
--   Errors handled by the procedure
--+
-- Access Status
--   Internal table handler use only.
--+
Function Get_bal
(
     p_effective_date    IN DATE    ,
     p_assignment_id     IN NUMBER  ,
     p_tax_unit_id       IN NUMBER  ,
     p_balance_name      IN VARCHAR ,
     p_dimension_name    IN VARCHAR ,
     p_business_group_id IN NUMBER
) RETURN NUMBER IS
    l_defined_balance_id NUMBER ;
    l_balance            NUMBER ;
    l_proc               VARCHAR2(72) := g_package || 'Get_bal';
BEGIN

    hr_utility.set_location('Entering:'||l_proc, 5);

    g_get_bal_flag := 'CORRECT';
    pay_balance_pkg.set_context('tax_unit_id', p_tax_unit_id   );
    pay_balance_pkg.set_context('date_earned', p_effective_date);

    IF (p_balance_name <> 'Def Comp 457'
          AND p_balance_name <> 'Calc 457 Limit') THEN
        SELECT  /*+ USE_NL (pbd) */
               pdb.defined_balance_id
        INTO   l_defined_balance_id
        FROM   pay_balance_types      pbt ,
               pay_defined_balances   pdb ,
               pay_balance_dimensions pbd
        WHERE  pbt.balance_name           = p_balance_name
        AND    pbt.balance_type_id        = pdb.balance_type_id
        AND    pbd.balance_dimension_id   = pdb.balance_dimension_id
        AND    pbd.dimension_name         = p_dimension_name
        AND    pdb.business_group_id      = p_business_group_id;
    ELSE
        SELECT  /*+ USE_NL (pbd) */
               pdb.defined_balance_id
        INTO   l_defined_balance_id
        FROM   pay_balance_types      pbt ,
               pay_defined_balances   pdb ,
               pay_balance_dimensions pbd
        WHERE  pbt.balance_name           = p_balance_name
        AND    pbt.balance_type_id        = pdb.balance_type_id
        AND    pbd.balance_dimension_id   = pdb.balance_dimension_id
        AND    pbd.dimension_name         = p_dimension_name;
    END IF;

    hr_utility.set_location('Balance = ' || p_balance_name || ' ' ||
TO_CHAR(l_defined_balance_id) || ' ' || TO_CHAR(p_assignment_id), 15);

    l_balance := NVL(pay_balance_pkg.get_value(l_defined_balance_id,
                                               p_assignment_id    ,
                                               p_effective_date ), 0);
    hr_utility.set_location('Leaving:'||l_proc, 1000);

    RETURN l_balance;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        IF (FND_GLOBAL.CONC_REQUEST_ID <> -1 ) THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,p_balance_name ||
               ' not found for Assignment Id ' || TO_CHAR(p_assignment_id) ||
              ' in ' || TO_CHAR(p_business_group_id) || ' ' || l_proc);
        ELSE
            hr_utility.set_location(p_balance_name ||
               ' not found for Assignment Id ' || TO_CHAR(p_assignment_id) ||
              ' in ' || l_proc, 10);
        END IF;
        g_get_bal_flag := 'ERROR';
        RETURN 0;
    WHEN OTHERS THEN
        IF (FND_GLOBAL.CONC_REQUEST_ID <> -1 ) THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occured while calculating ' ||
           p_balance_name || ' for Assignment Id ' || TO_CHAR(p_assignment_id)
           || SUBSTR(SQLERRM, 1, 128) || ' ' || TO_CHAR(SQLCODE) ||
              ' in ' || l_proc);
        ELSE
            hr_utility.set_location('Error occured while calculating ' ||
           p_balance_name || ' for Assignment Id ' || TO_CHAR(p_assignment_id)||
            SUBSTR(SQLERRM, 1, 128) || ' ' || TO_CHAR(SQLCODE) || ' in '
           || l_proc, 15);
        END IF;
        g_get_bal_flag := 'ERROR';
        RETURN 0;
END Get_bal;
-- ----------------------------------------------------------------------------+
-- |------< person_exists >------|
-- ----------------------------------------------------------------------------+
--+
-- Description
--  This procedure is used to return contr_history_id and object_version_number
--  for a particular person and a tax unit Id in a particular year in
--  PAY_US_CONTRIBUTION_HISTORY table. If no record is present then the
--  contr_history_id and object_version_number are 0.
--+
-- Pre Conditions
--   None.
--+
-- In Parameters
--   p_person_id       Person Id for whom the data  has to be transferred.
--   p_tax_unit_id     Respective Tax Unit Id
--   p_year            Year (YYYY) for which the rollover has to run
--+
-- Out Parameters
--   p_contr_history_id  The contr_history_id in
--+                      PAY_US_CONTRIBUITON_HISTORY table
--   p_ovn_number        The object_version_number in
--                       PAY_US_CONTRIBUITON_HISTORY table
--+
-- Post Success
--   Processing continues
--+
-- Post Failure
--   Errors handled by the procedure
--+
-- Access Status
--   Internal table handler use only.
--+
PROCEDURE person_exists(p_person_id         IN NUMBER,
                        p_tax_unit_id       IN NUMBER,
                        p_year              IN NUMBER,
                        p_contr_history_id OUT NOCOPY NUMBER,
                        p_ovn_number       OUT NOCOPY NUMBER,
                        p_business_group_id IN NUMBER ) IS
    l_contr_history_id NUMBER       := 0;
    l_proc             VARCHAR2(72) := g_package || 'person_exists';
BEGIN
    hr_utility.set_location('Entering:'||l_proc, 5);

    SELECT contr_history_id ,
           object_version_number
    INTO   p_contr_history_id,
           p_ovn_number
    FROM   PAY_US_CONTRIBUTION_HISTORY
    WHERE  CONTR_TYPE                            = g_contr_type
    AND    TO_NUMBER(TO_CHAR(DATE_FROM, 'YYYY')) = p_year
    AND    TO_NUMBER(TO_CHAR(DATE_TO, 'YYYY'))   = p_year
    AND    tax_unit_id                           = p_tax_unit_id
    AND    person_id                             = p_person_id
    AND    business_group_id                     = p_business_group_id;

    hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_contr_history_id := 0;
        p_ovn_number       := 0;
    WHEN OTHERS THEN
        p_contr_history_id := 0;
        p_ovn_number       := 0;
        IF (FND_GLOBAL.CONC_REQUEST_ID <> -1 ) THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error occured in WHEN OTHER for
Person Id ' || TO_CHAR(p_person_id) || ' for Year = ' || TO_CHAR(p_year) ||
' in ' || l_proc || SUBSTR(SQLERRM, 1, 128) || TO_CHAR(SQLCODE));
        ELSE
            hr_utility.set_location('Error occured in WHEN OTHER for Person Id '||
TO_CHAR(p_person_id) || ' for Year = ' || TO_CHAR(p_year) || ' in ' || l_proc ||
SUBSTR(SQLERRM, 1, 128) || TO_CHAR(SQLCODE), 10);
        END IF;
END person_exists;
--
-- ----------------------------------------------------------------------------+
-- |                     Public Procedure                     |
-- ----------------------------------------------------------------------------+
--
-- ----------------------------------------------------------------------------+
-- |------< Rollover_process >------|
-- ----------------------------------------------------------------------------+
--+
-- Description
--   This procedure is used to find all the employees that have 457 element
--   associated with them. For all the employees that have 457 element
--   with them, this procedure, then called the function to calculate
--   the respective balances.
--+
-- Pre Conditions
--   None.
--+
-- In Parameters
--   p_gre_id          Respective Government Reporting entity
--   p_year            Year (YYYY) for which the rollover has to run
--   p_person_id       Person Id for whom the data  has to be transferred.
--                     If person Id is null, then the program proceeds for
--                     for the whole GRE (Tax Unit)
--   p_override_mode   If the mode is YES, then program updates the
--                     existing recs in PAY_US_CONTRIBUTION_HISTORY table, If it
--                     is NO, then it just inserts the new records
-- Out Parameters
--    errbuf           Returns the error buffer
--    retcode          Returns the error code
--+
-- Post Success
--   Processing continues
--+
-- Post Failure
--   Errors handled by the procedure
--+
-- Access Status
--   Internal table handler use only.

Procedure rollover_process
(
    errbuf            OUT  NOCOPY VARCHAR2               ,
    retcode           OUT  NOCOPY NUMBER                 ,
    p_year            IN   NUMBER                 ,
    p_gre_id          IN   NUMBER    DEFAULT NULL ,
    p_person_id       IN   NUMBER    DEFAULT NULL ,
    p_override_mode   IN   VARCHAR2  DEFAULT 'NO'
) IS
    l_id                           NUMBER               ;
    l_ovn                          NUMBER               ;
    l_temp_person_id               NUMBER               ;
    l_business_group_id            NUMBER               ;
    l_contr_history_id             NUMBER       := 0    ;
    l_ovn_number                   NUMBER       := 0    ;
    l_tax_unit_id                  NUMBER       := 0    ;
    l_Includable_comp              NUMBER       := 0    ;
    l_Def_457_Contribution_balance NUMBER       := 0    ;
    l_max_457_contrb_allowed       NUMBER       := 0    ;
    l_person_id                    NUMBER       := 0    ;
    l_assignment_id                NUMBER       := 0    ;

    l_element_name                 VARCHAR2(80) := ''   ;
    l_element_information1         VARCHAR2(80) := ''   ;
    l_full_name                    VARCHAR2(80) := ''   ;
    l_statement                    VARCHAR2(3000) := '' ;
    l_dimension                    VARCHAR2(80) := ''   ;
    l_balance_name                 VARCHAR2(80) := ''   ;
    l_override_mode                VARCHAR2(5)  := 'NO' ;
    l_proc                         VARCHAR2(72) :=
                                       g_package || 'rollover_process';
    l_effective_date               DATE                 ;
    l_old_effective_date           DATE                 ;

    l_first_time                   BOOLEAN      := TRUE ;
    l_multiple_rec_flag            BOOLEAN      := FALSE;


    TYPE t_get_bal_flag IS TABLE OF VARCHAR2(7) INDEX BY BINARY_INTEGER;
    l_get_bal_flag t_get_bal_flag;

-- The size of the table is chosen to be 7 as it will contain 'CORRECT' or
-- 'ERROR' or null

    TYPE c_cursor_type IS REF CURSOR
        RETURN g_rec_type;
    C_All_Emp c_cursor_type;

BEGIN
    hr_utility.set_location(' Entering:'||l_proc, 5);
    l_get_bal_flag(1) := 'CORRECT';
    l_get_bal_flag(2) := 'CORRECT';
    l_get_bal_flag(3) := 'CORRECT';

    hr_api.mandatory_arg_error
    (p_api_name       => l_proc   ,
     p_argument       => 'p_year' ,
     p_argument_value => p_year
    );

-- The call to proc above checks if p_year has been passed or not

    IF (p_person_id IS NULL) THEN
    -- Check mandatory parameters have been set
    -- This ensures that if person_id passed is null, then GRE has to be present
        hr_api.mandatory_arg_error
        (p_api_name       => l_proc     ,
         p_argument       => 'p_gre_id' ,
         p_argument_value => p_gre_id
        );
    END IF;

    hr_utility.set_location(' Deciding the cursor to be used', 10);

    IF (p_person_id IS NULL) THEN

        OPEN C_All_Emp FOR
        SELECT   /*+ INDEX (pet  pay_element_types_f_pk)
                     INDEX (pel  pay_element_links_f_n7)
                     INDEX (ppt  per_person_types_pk)
                     INDEX (hsck HR_SOFT_CODING_KEYFLEX_PK)
                     USE_NL(hsck)  */
               DISTINCT paa.person_id               ,
                        TO_NUMBER(hsck.segment1)    ,
                        pap.full_name               ,
                        paa.assignment_id           ,
                        pee.element_link_id         ,
                        pet.element_name            ,
                        paa.business_group_id       ,
                        pet.element_information1    ,
                        TO_CHAR(MAX(paa.effective_end_date), 'DD/MM/YYYY')
        FROM            per_assignments_f           paa,
                        per_all_people_f            pap,
                        pay_element_entries_f       pee,
                        pay_element_links_f         pel,
                        pay_element_types_f         pet,
                        per_person_types            ppt,
                        hr_soft_coding_keyflex      hsck
        WHERE paa.assignment_Type              = 'E'
        AND   pap.person_id                    = paa.person_id
        AND   pap.person_type_id               = ppt.person_Type_id
        AND   ppt.system_person_type           = 'EMP'
        AND   pee.assignment_id                = paa.assignment_id
        AND   pee.element_link_id              = pel.element_link_id
        AND   pet.element_information_Category = 'US_PRE-TAX DEDUCTIONS'
        AND   pet.element_information1         = g_contr_type
        AND   pet.element_type_id              = pel.element_type_id
        AND   (TO_NUMBER(TO_CHAR(pap.effective_start_date,'YYYY')) <= p_year AND
              TO_NUMBER(TO_CHAR(pap.effective_end_date,'YYYY'))   >= p_year    )
        AND   (TO_NUMBER(TO_CHAR(paa.effective_start_date,'YYYY')) <= p_year AND
              TO_NUMBER(TO_CHAR(paa.effective_end_date,'YYYY'))   >= p_year    )
        AND   (TO_NUMBER(TO_CHAR(pee.effective_start_date,'YYYY')) <= p_year AND
              TO_NUMBER(TO_CHAR(pee.effective_end_date,'YYYY'))   >= p_year    )
        AND   (TO_NUMBER(TO_CHAR(pel.effective_start_date,'YYYY')) <= p_year AND
              TO_NUMBER(TO_CHAR(pel.effective_end_date,'YYYY'))   >= p_year    )
        AND   (TO_NUMBER(TO_CHAR(pet.effective_start_date,'YYYY')) <= p_year AND
              TO_NUMBER(TO_CHAR(pet.effective_end_date,'YYYY'))   >= p_year    )
        AND    pet.element_name NOT LIKE '%Special%'
        AND    paa.soft_coding_keyflex_id   = hsck.soft_coding_keyflex_id
        AND    TO_NUMBER(hsck.segment1)     = p_gre_id
        AND    pap.effective_start_date     =
                     (SELECT MAX(effective_start_date)
                      FROM   per_all_people_f a,
                             per_person_types b
                      WHERE  a.person_type_id    = b.person_type_id
                      AND    a.person_id         = pap.person_id
                      AND    a.business_group_id = pap.business_group_id
                      AND   (TO_NUMBER(TO_CHAR(pap.effective_start_date,'YYYY'))
                                       <= p_year
                      AND    TO_NUMBER(TO_CHAR(pap.effective_end_date,'YYYY'))
                                       >= p_year    )
                      AND    b.system_person_type = 'EMP')
        GROUP BY paa.person_id               ,
                 TO_NUMBER(hsck.segment1)    ,
                 pap.full_name               ,
                 paa.assignment_id           ,
                 pee.element_link_id         ,
                 pet.element_name            ,
                 paa.business_group_id       ,
                 pet.element_information1
        ORDER  BY paa.person_id          ,
                  paa.assignment_id      ,
                  UPPER(pet.element_name) ;

    hr_utility.set_location(' Opened the cursor', 15);

    ELSIF (p_person_id IS NOT NULL AND p_gre_id IS NULL) THEN
        OPEN  C_All_Emp FOR
        SELECT DISTINCT paa.person_id               ,
                        TO_NUMBER(hsck.segment1)    ,
                        pap.full_name               ,
                        paa.assignment_id           ,
                        pee.element_link_id         ,
                        pet.element_name            ,
                        paa.business_group_id       ,
                        pet.element_information1    ,
                        TO_CHAR(MAX(paa.effective_end_date), 'DD/MM/YYYY')
        FROM            per_assignments_f       paa,
                        per_all_people_f            pap,
                        pay_element_entries_f       pee,
                        pay_element_links_f         pel,
                        pay_element_types_f         pet,
                        per_person_types            ppt,
                        hr_soft_coding_keyflex      hsck
        WHERE  paa.assignment_Type              = 'E'
        AND    pap.person_id                    = paa.person_id
        AND    pap.person_type_id               = ppt.person_Type_id
        AND    ppt.system_person_type           = 'EMP'
        AND    pee.assignment_id                = paa.assignment_id
        AND    pel.element_type_id              = pet.element_type_id
        AND    pee.element_link_id              = pel.element_link_id
        AND    pet.element_information_Category = 'US_PRE-TAX DEDUCTIONS'
        AND    pet.element_information1         = g_contr_Type
        AND   (TO_NUMBER(TO_CHAR(pap.effective_start_date,'YYYY')) <= p_year AND
              TO_NUMBER(TO_CHAR(pap.effective_end_date,'YYYY'))   >= p_year    )
        AND   (TO_NUMBER(TO_CHAR(paa.effective_start_date,'YYYY')) <= p_year AND
              TO_NUMBER(TO_CHAR(paa.effective_end_date,'YYYY'))   >= p_year    )
        AND   (TO_NUMBER(TO_CHAR(pee.effective_start_date,'YYYY')) <= p_year AND
              TO_NUMBER(TO_CHAR(pee.effective_end_date,'YYYY'))   >= p_year    )
        AND   (TO_NUMBER(TO_CHAR(pel.effective_start_date,'YYYY')) <= p_year AND
              TO_NUMBER(TO_CHAR(pel.effective_end_date,'YYYY'))   >= p_year    )
        AND   (TO_NUMBER(TO_CHAR(pet.effective_start_date,'YYYY')) <= p_year AND
              TO_NUMBER(TO_CHAR(pet.effective_end_date,'YYYY'))   >= p_year    )
        AND    pet.element_name NOT LIKE '%Special%'
        AND    pap.person_id                    = p_person_id
        AND    paa.soft_coding_keyflex_id       = hsck.soft_coding_keyflex_id
        AND    pap.effective_start_date         =
                     (SELECT MAX(effective_start_date)
                      FROM   per_all_people_f a,
                             per_person_types b
                      WHERE  a.person_type_id    = b.person_type_id
                      AND    a.person_id         = pap.person_id
                      AND    a.business_group_id = pap.business_group_id
                      AND   (TO_NUMBER(TO_CHAR(pap.effective_start_date,'YYYY'))
                                       <= p_year
                      AND    TO_NUMBER(TO_CHAR(pap.effective_end_date,'YYYY'))
                                       >= p_year    )
                      AND    b.system_person_type = 'EMP')
        GROUP BY paa.person_id               ,
                 TO_NUMBER(hsck.segment1)    ,
                 pap.full_name               ,
                 paa.assignment_id           ,
                 pee.element_link_id         ,
                 pet.element_name            ,
                 paa.business_group_id       ,
                 pet.element_information1
        ORDER  BY TO_NUMBER(hsck.segment1),
                  paa.person_id           ,
                  paa.assignment_id       ,
                  UPPER(pet.element_name) ;

    hr_utility.set_location(' Opened the cursor', 15);

    ELSIF (p_person_id IS NOT NULL AND p_gre_id IS NOT NULL) THEN
        OPEN C_ALL_Emp FOR
        SELECT DISTINCT paa.person_id               ,
                        TO_NUMBER(hsck.segment1)    ,
                        pap.full_name               ,
                        paa.assignment_id           ,
                        pee.element_link_id         ,
                        pet.element_name            ,
                        paa.business_group_id       ,
                        pet.element_information1    ,
                        TO_CHAR(MAX(paa.effective_end_date), 'DD/MM/YYYY')
        FROM            per_assignments_f       paa,
                        per_all_people_f            pap,
                        pay_element_entries_f       pee,
                        pay_element_links_f         pel,
                        pay_element_types_f         pet,
                        per_person_types            ppt,
                        hr_soft_coding_keyflex      hsck
        WHERE paa.assignment_Type              = 'E'
        AND   pap.person_id                    = paa.person_id
        AND   pap.person_type_id               = ppt.person_Type_id
        AND   ppt.system_person_type           = 'EMP'
        AND   pee.assignment_id                = paa.assignment_id
        AND   pel.element_type_id              = pet.element_type_id
        AND   pee.element_link_id              = pel.element_link_id
        AND   pet.element_information_Category = 'US_PRE-TAX DEDUCTIONS'
        AND   pet.element_information1         = g_contr_Type
        AND   (TO_NUMBER(TO_CHAR(pap.effective_start_date,'YYYY')) <= p_year AND
              TO_NUMBER(TO_CHAR(pap.effective_end_date,'YYYY'))   >= p_year    )
        AND   (TO_NUMBER(TO_CHAR(paa.effective_start_date,'YYYY')) <= p_year AND
              TO_NUMBER(TO_CHAR(paa.effective_end_date,'YYYY'))   >= p_year    )
        AND   (TO_NUMBER(TO_CHAR(pee.effective_start_date,'YYYY')) <= p_year AND
              TO_NUMBER(TO_CHAR(pee.effective_end_date,'YYYY'))   >= p_year    )
        AND   (TO_NUMBER(TO_CHAR(pel.effective_start_date,'YYYY')) <= p_year AND
              TO_NUMBER(TO_CHAR(pel.effective_end_date,'YYYY'))   >= p_year    )
        AND   (TO_NUMBER(TO_CHAR(pet.effective_start_date,'YYYY')) <= p_year AND
              TO_NUMBER(TO_CHAR(pet.effective_end_date,'YYYY'))   >= p_year    )
        AND    pet.element_name NOT LIKE '%Special%'
        AND    pap.person_id                    = p_person_id
        AND    paa.soft_coding_keyflex_id       = hsck.soft_coding_keyflex_id
        AND    TO_NUMBER(hsck.segment1)         = p_gre_id
        AND    pap.effective_start_date         =
                     (SELECT MAX(effective_start_date)
                      FROM   per_all_people_f a,
                             per_person_types b
                      WHERE  a.person_type_id    = b.person_type_id
                      AND    a.person_id         = pap.person_id
                      AND    a.business_group_id = pap.business_group_id
                      AND   (TO_NUMBER(TO_CHAR(pap.effective_start_date,'YYYY'))
                                       <= p_year
                      AND    TO_NUMBER(TO_CHAR(pap.effective_end_date,'YYYY'))
                                       >= p_year    )
                      AND    b.system_person_type = 'EMP')
        GROUP BY paa.person_id               ,
                 TO_NUMBER(hsck.segment1)    ,
                 pap.full_name               ,
                 paa.assignment_id           ,
                 pee.element_link_id         ,
                 pet.element_name            ,
                 paa.business_group_id       ,
                 pet.element_information1
        ORDER  BY TO_NUMBER(hsck.segment1),
                  paa.person_id           ,
                  paa.assignment_id       ,
                  UPPER(pet.element_name) ;

    hr_utility.set_location(' Opened the cursor', 15);

    END IF;

    l_override_mode := UPPER(p_override_mode);
    IF (l_override_mode = 'Y') THEN
        l_override_mode := 'YES';
    ELSE
        l_override_mode := 'NO';
    END IF;

-- Defaults the override mode to 'NO'

 IF (FND_GLOBAL.CONC_REQUEST_ID <> -1 ) THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Parameters received ---->     ' );
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Person Id     : ' || TO_CHAR(p_person_id));
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Year          : ' || TO_CHAR(p_year));
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'GRE           : ' || TO_CHAR(p_gre_id ));
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Override Mode : ' || p_override_mode);
  ELSE
    hr_utility.set_location('Parameters received ---->     ' , 20);
    hr_utility.set_location('Person Id     : ' || TO_CHAR(p_person_id), 25);
    hr_utility.set_location('Year          : ' || TO_CHAR(p_year), 30);
    hr_utility.set_location('GRE           : ' || TO_CHAR(p_gre_id ), 35);
    hr_utility.set_location('Override Mode : ' || p_override_mode, 40);
  END IF;


    hr_utility.set_location('Fetching from C_All_Emp cursor ', 45);

    LOOP
    BEGIN
        FETCH C_All_Emp INTO g_old_rec;
        l_get_bal_flag(1) := 'CORRECT';
        l_get_bal_flag(2) := 'CORRECT';
        l_get_bal_flag(3) := 'CORRECT';

        IF (TO_CHAR(l_old_effective_date,'DD/MM/YYYY') = '31/12/4712') THEN
            l_effective_date := TO_DATE('31/12/' || p_year, 'DD/MM/YYYY');
        ELSE
            l_effective_date := l_old_effective_date;
        END IF;

-- The above IF statement takes care if the employee was terminated. Otherwise
-- if the emp is terminated and 31-DEC-YYYY is passed, then
-- pay_balance_pkg.get_value returns unhandled exception

        IF ((g_old_rec.person_id       = l_person_id      ) AND
            (g_old_rec.tax_unit_id     = l_tax_unit_id    ) AND
            (UPPER(g_old_rec.element_information1) =
                           UPPER(l_element_information1)  ) AND
            C_All_Emp%FOUND = TRUE                        )
        THEN
            hr_utility.set_location('Multiple Element IF', 50);

            IF (l_multiple_rec_flag = FALSE) THEN
                IF (FND_GLOBAL.CONC_REQUEST_ID <> -1 ) THEN
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'Person Id = ' ||
                        to_char(g_old_rec.person_id) || ', Name ' ||
                        g_old_rec.full_name   ||
             ' not selected as this person has multiple elements of same type');
                ELSE
                    hr_utility.set_location('Person Id = ' ||
                    TO_CHAR(g_old_rec.person_id) || ', Name ' ||
                    g_old_rec.full_name   ||
         ' not selected as this person has multiple elements of same type', 55);
                END IF;
                l_multiple_rec_flag := TRUE;
-- l_multiple_rec_flag = TRUE makes sure i the person has more than two 457
-- elements attached. The message above does not get printed more than once.
            END IF;
        ELSE

            hr_utility.set_location('Multiple Element ELSE ', 60);

            IF (l_multiple_rec_flag = FALSE AND l_first_time = FALSE) THEN

                l_balance_name   :=  l_element_name || ' Eligible Comp';
                l_dimension      :=
                     'Person within Government Reporting Entity Year to Date';

                hr_utility.set_location('Calling Get_bal for ' ||
                    l_balance_name, 65);

                l_Includable_comp := NVL(Get_bal(
                                        l_effective_date   ,
                                        l_assignment_id    ,
                                        l_tax_unit_id      ,
                                        l_balance_name     ,
                                        l_dimension        ,
                                        l_business_group_id), 0);
                l_get_bal_flag(1)  := g_get_bal_flag;
                l_balance_name     :=  'Def Comp 457';
                l_dimension        :=
                    'Person within Government Reporting Entity Year to Date';

                hr_utility.set_location('Calling Get_bal for ' ||
                   l_balance_name, 70);

                l_Def_457_Contribution_balance := NVL(Get_bal(
                                                         l_effective_date ,
                                                         l_assignment_id  ,
                                                         l_tax_unit_id    ,
                                                         l_balance_name   ,
                                                         l_dimension      ,
                                                       l_business_group_id), 0);
                l_get_bal_flag(2)  := g_get_bal_flag;
                l_balance_name     := 'Calc 457 Limit';
                l_dimension        :=
                    'Person within Government Reporting Entity Year to Date';

                hr_utility.set_location('Calling Get_bal for ' ||
                    l_balance_name, 75);

                l_max_457_contrb_allowed := NVL(Get_bal( l_effective_date ,
                                                         l_assignment_id  ,
                                                         l_tax_unit_id    ,
                                                         l_balance_name   ,
                                                         l_dimension      ,
                                                       l_business_group_id), 0);
                l_get_bal_flag(3)  := g_get_bal_flag;

                hr_utility.set_location('Calling person_Exists '
                      || TO_CHAR(l_person_id), 80);

                person_exists(l_person_id        ,
                              l_tax_unit_id      ,
                              p_year             ,
                              l_contr_history_id ,
                              l_ovn_number       ,
                              l_business_group_id);

                IF (l_contr_history_id = 0
                    AND (l_get_bal_flag(1) = 'CORRECT'   AND
                         l_get_bal_flag(2) = 'CORRECT'   AND
                         l_get_bal_flag(3) = 'CORRECT')) THEN

-- l_get_bal_flag stores if the calls to Get_Bal proc were successful or not
-- l_contr_history_id = 0 ensures that this person_id is not having a record
-- for the partucular year

                    hr_utility.set_location('Inserting into PAY_US_CONTRIBUTION_HISTORY', 85);
                    Pay_Contrb_Ins(
                        l_business_group_id => l_business_group_id            ,
                        l_amt_contr         => l_Def_457_Contribution_balance ,
                        l_max_contr_allowed => l_max_457_contrb_allowed       ,
                        l_includable_comp   => l_Includable_comp              ,
                        l_tax_unit_id       => l_tax_unit_id                  ,
                        l_year              => p_year                         ,
                        l_person_id         => l_person_id                    ,
                        l_contr_history_id      => l_contr_history_id         ,
                        l_object_version_number => l_ovn_number              ) ;


                ELSIF (l_contr_history_id <> 0        AND
                       l_contr_history_id IS NOT NULL AND
                       l_override_mode   = 'YES'      AND
                       l_get_bal_flag(1) = 'CORRECT'  AND
                       l_get_bal_flag(2) = 'CORRECT'  AND
                       l_get_bal_flag(3) = 'CORRECT') THEN

                    hr_utility.set_location('Updating PAY_US_CONTRIBUTION_HISTORY', 90);
                   Pay_contrb_Upd(
                      l_contr_history_id      => l_contr_history_id,
                      l_object_version_number => l_ovn_number      ,
                      l_amt_contr             => l_Def_457_Contribution_balance,
                      l_max_contr_allowed     => l_max_457_contrb_allowed     ,
                      l_includable_comp       => l_Includable_comp);

                END IF;
            END IF;
            l_multiple_rec_flag := FALSE;
        END IF;

        hr_utility.set_location('Assigning g_old_rec values to the local variables ' , 95);

        l_person_id             := g_old_rec.person_id            ;
        l_assignment_id         := g_old_rec.assignment_id        ;
        l_element_name          := g_old_rec.element_name         ;
        l_element_information1  := g_old_rec.element_information1 ;
        l_tax_unit_id           := g_old_rec.tax_unit_id          ;
        l_full_name             := g_old_rec.full_name            ;
        l_business_group_id     := g_old_rec.business_group_id    ;
        l_old_effective_date    :=
                   TO_DATE(g_old_rec.effective_end_date, 'DD/MM/YYYY');
        l_first_time            := FALSE                          ;

        IF (p_person_id IS NULL) THEN
            IF (l_person_id IS NULL) THEN
                IF (FND_GLOBAL.CONC_REQUEST_ID <> -1 ) THEN
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'No record found for Year = '
                        || TO_CHAR(p_year) ||' GRE =  ' || TO_CHAR(p_gre_id) ||
                     ' Business Group Id = ' || TO_CHAR(l_business_group_id));
                ELSE
                    hr_utility.set_location('No record found for Year = ' ||
                        TO_CHAR(p_year) ||' GRE =  ' || TO_CHAR(p_gre_id) ||
                   ' Business Group Id = ' || TO_CHAR(l_business_group_id), 80);
                END IF;
            END IF;
            EXIT WHEN C_All_Emp%NOTFOUND;
        ELSE
            IF (l_person_id IS NULL) THEN
                IF (FND_GLOBAL.CONC_REQUEST_ID <> -1 ) THEN
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'No record found for ' ||
                    'person Id = ' || TO_CHAR(p_person_id) || ' Year = ' ||
                    TO_CHAR(p_year) || ' Tax Unit Id = ' || TO_CHAR(p_gre_id) ||
                    ' Business Group Id = ' || TO_CHAR(l_business_group_id));
                ELSE
                    hr_utility.set_location('No record found for person Id = ' ||
                    TO_CHAR(p_person_id) || ' Year = ' || TO_CHAR(p_year) ||
                    ' Tax Unit Id = ' || TO_CHAR(p_gre_id) || ' Business Group Id
                    = ' || TO_CHAR(l_business_group_id), 85);
                END IF;
            END IF;
            EXIT WHEN C_All_Emp%NOTFOUND;
        END IF;
    EXCEPTION

    WHEN OTHERS THEN
        IF (FND_GLOBAL.CONC_REQUEST_ID <> -1 ) THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,substr(SQLERRM, 1, 255) || ' in ' ||
           l_proc || ' ' || TO_CHAR(SQLCODE) || ' in cursor for Person id = ' ||
           TO_CHAR(g_old_rec.person_id) || ' ' || g_old_rec.full_name);
        ELSE
            hr_utility.set_location(substr(SQLERRM, 1, 255) || ' in ' ||
           l_proc || ' ' || TO_CHAR(SQLCODE) || ' in cursor for Person id = ' ||
            TO_CHAR(g_old_rec.person_id) || ' ' || g_old_rec.full_name, 1000);
       END IF;
    END;
    END LOOP;
    hr_utility.set_location('Closing the cursor ', 100);
    Close C_All_Emp;
    hr_utility.set_location('Calling Business_rule_proc ', 150);

-- The proc takes care of the case when p_person_id is null. Then it finds
-- out all the persons.

    Business_rule_proc(p_year,
                       p_person_id,
                       p_gre_id);
    hr_utility.set_location(' Leaving:'||l_proc, 1500);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        IF (FND_GLOBAL.CONC_REQUEST_ID <> -1 ) THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,'No records found ');
        ELSE
            hr_utility.set_location('No records found ', 95);
        END IF;
    WHEN OTHERS THEN
        IF (FND_GLOBAL.CONC_REQUEST_ID <> -1 ) THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,substr(SQLERRM, 1, 128) || ' in ' ||
l_proc || ' ' || TO_CHAR(SQLCODE));
        ELSE
            hr_utility.set_location(substr(SQLERRM, 1, 128) || ' in ' ||
l_proc || ' ' || TO_CHAR(SQLCODE), 100);
       END IF;
END rollover_process;
END pay_us_def_comp_457;

/
