--------------------------------------------------------
--  DDL for Package Body PAY_TAXABILITY_RULES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_TAXABILITY_RULES_API" as
/* $Header: paytxabltyrulapi.pkb 120.0 2005/05/29 11:51 appldev noship $ */

-- Package Variables
g_package            VARCHAR2(33) := '  create_taxability_rules_api.';
--

  FUNCTION check_taxability_rule_exists
                  (p_jurisdiction         IN VARCHAR2
                  ,p_legislation_code     IN VARCHAR2
                  ,p_classification_id    IN NUMBER default null
                  ,p_tax_category         IN VARCHAR2 default null
                  ,p_tax_type             IN VARCHAR2 default null
                  ,p_secondary_classification_id IN NUMBER default null
                  )
  RETURN VARCHAR2
  IS

    cursor c_check_taxability_rule(cp_jurisdiction      in varchar2
                                  ,cp_legislation_code  in varchar2
                                  ,cp_tax_type          in varchar2
                                  ,cp_category          in varchar2
                                  ,cp_classification_id in number
                                  ,cp_secondary_classification_id in number) is
         select nvl(status, 'V'),last_updated_by
           from pay_taxability_rules
          where jurisdiction_code = cp_jurisdiction
            and nvl(tax_type,'X') = nvl(cp_tax_type,'X')
            and nvl(tax_category,'X') = nvl(cp_category,'X')
            and nvl(classification_id,0) = nvl(cp_classification_id,0)
            and nvl(secondary_classification_id,0) =
                           nvl(cp_secondary_classification_id,0)
            and legislation_code = cp_legislation_code;

    lv_status VARCHAR2(1);
    lv_last_updated_by NUMBER(15);
    lv_seed_last_updated_by NUMBER(15);

  BEGIN

    hr_utility.trace('In check_taxability_rule_exists');
    open c_check_taxability_rule
             (p_jurisdiction
             ,p_legislation_code
             ,p_tax_type
             ,p_tax_category
             ,p_classification_id
             ,p_secondary_classification_id);
    fetch c_check_taxability_rule into lv_status,lv_last_updated_by;
    if c_check_taxability_rule%notfound then
       lv_status := 'N';
    end if;
    close c_check_taxability_rule;

    lv_seed_last_updated_by:=  fnd_load_util.owner_id('ORACLE');
    hr_utility.trace('lv_seed_last_updated_by = '||to_char(lv_seed_last_updated_by));
    hr_utility.trace('lv_last_updated_by = '||to_char(lv_last_updated_by));

    /* Check if its a seeded row. If so, set the return status to 'S' seed. */

    if lv_last_updated_by = lv_seed_last_updated_by  Then

         lv_status := 'S';

    end if;

    hr_utility.trace('lv_status = '||lv_status);

    return (lv_status);

  END check_taxability_rule_exists;




  PROCEDURE create_taxability_rules
                (p_validate                 IN BOOLEAN
                ,p_jurisdiction             IN VARCHAR2
                ,p_tax_type                 IN VARCHAR2 default null
                ,p_tax_category             IN VARCHAR2 default null
                ,p_classification_id        IN  NUMBER default null
                ,p_taxability_rules_date_id IN NUMBER
                ,p_legislation_code         IN  VARCHAR2
                ,p_status                   IN  VARCHAR2
                ,p_secondary_classification_id IN  NUMBER default null)
IS

 l_proc            VARCHAR2(72) := g_package||'create_taxability_rules';
BEGIN

  hr_utility.trace('In paytxabltyrulapi package');

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_taxability_rules;

  hr_utility.trace('Before calling pay_txr_ins.ins');

  pay_txr_ins.ins(p_effective_date           => sysdate
                 ,p_legislation_code         => p_legislation_code
                 ,p_jurisdiction_code        => p_jurisdiction
                 ,p_tax_type                 => p_tax_type
                 ,p_tax_category             => p_tax_category
                 ,p_classification_id        => p_classification_id
                 ,p_taxability_rules_date_id => p_taxability_rules_date_id
                 ,p_status                   => p_status
                 ,p_secondary_classification_id => p_secondary_classification_id
                );

  hr_utility.trace('After calling pay_txr_ins.ins');

  IF p_validate THEN
     hr_utility.set_location('Entering:'|| l_proc, 30);
     RAISE hr_api.validate_enabled;
  END IF;

EXCEPTION

   WHEN hr_api.validate_enabled THEN
     ROLLBACK TO create_taxability_rules;
     hr_utility.set_location(' Leaving:'||l_proc, 80);

  WHEN OTHERS THEN
     ROLLBACK TO create_taxability_rules;
     hr_utility.set_location(' Leaving:'||l_proc, 80);
     RAISE;

  hr_utility.trace('End create_taxability_rules');

END create_taxability_rules;


PROCEDURE update_taxability_rules
                (p_validate                 IN BOOLEAN
                ,p_jurisdiction             IN VARCHAR2
                ,p_tax_type                 IN VARCHAR2 default null
                ,p_tax_category             IN VARCHAR2 default null
                ,p_classification_id        IN  NUMBER default null
                ,p_taxability_rules_date_id IN NUMBER
                ,p_legislation_code         IN  VARCHAR2
                ,p_status                   IN  VARCHAR2
                ,p_secondary_classification_id IN  NUMBER default null)
IS

  l_proc            VARCHAR2(72) := g_package||'update_taxability_rules';

BEGIN

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint.
  --
  savepoint update_taxability_rules;
  --
  --
  pay_txr_upd.upd(p_effective_date           => sysdate
                 ,p_legislation_code         => p_legislation_code
                 ,p_jurisdiction_code        => p_jurisdiction
                 ,p_tax_type                 => p_tax_type
                 ,p_tax_category             => p_tax_category
                 ,p_classification_id        => p_classification_id
                 ,p_taxability_rules_date_id => p_taxability_rules_date_id
                 ,p_status                   => p_status
                 ,p_secondary_classification_id => p_secondary_classification_id);


  hr_utility.set_location('Entering:'|| l_proc, 20);

  IF p_validate THEN
     hr_utility.set_location('Entering:'|| l_proc, 30);
     RAISE hr_api.validate_enabled;
  END IF;

EXCEPTION

  WHEN  hr_api.validate_enabled THEN
    ROLLBACK TO update_taxability_rules;
    hr_utility.set_location(' Leaving:'||l_proc, 80);

  WHEN OTHERS THEN
    ROLLBACK TO update_taxability_rules;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
         RAISE;

end update_taxability_rules;



/***********************************************************
** We will never be deleting the data in pay_taxability_rules
** table. We will be updating the status to 'D' if the value
** already exists.
**
** Commenting out the delete becasue of the reason mentioned
** above.
************************************************************
PROCEDURE delete_taxability_rules
                ( p_validate                IN BOOLEAN
                ,p_jurisdiction             IN VARCHAR2
                ,p_tax_type                 IN VARCHAR2 default null
                ,p_tax_category             IN VARCHAR2 default null
                ,p_classification_id        IN  NUMBER default null
                ,p_taxability_rules_date_id IN NUMBER
                ,p_legislation_code         IN  VARCHAR2
                ,p_status                   IN  VARCHAR2,
                ,p_secondary_classification_id IN  NUMBER default null)
IS

BEGIN
  null;
END delete_taxability_rules;
***********************************************************/

end pay_taxability_rules_api;

/
