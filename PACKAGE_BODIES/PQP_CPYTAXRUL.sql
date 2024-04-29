--------------------------------------------------------
--  DDL for Package Body PQP_CPYTAXRUL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_CPYTAXRUL" AS
/* $Header: pqtrulcp.pkb 115.2 2004/05/14 14:11:24 tmehra noship $ */

PROCEDURE COPY_TAX_RULES (
 errbuf                OUT NOCOPY VARCHAR2,
 retcode               OUT NOCOPY NUMBER,
 p_classification_name IN  pay_element_classifications.classification_name%type,
 p_source_category     IN  pay_taxability_rules.tax_category%type,
 p_target_category     IN  pay_taxability_rules.tax_category%type,
 p_source_state_code   IN  pay_us_states.state_code%type,
 p_target_state_code   IN  pay_us_states.state_code%type
  )
IS

l_classification_id  pay_element_classifications.classification_id%type;
l_tax_rules_date_id  pay_taxability_rules_dates.taxability_rules_date_id%type;
l_lookup_type        fnd_lookup_values.lookup_code%type ;
l_temp               number(1) ;
l_jsd_code  pay_taxability_rules.jurisdiction_code%type;

-- Cursor to get Classification Id. Assuming that the Script is
-- used only for US legislation and taxability and the wage attachment
-- rules are defined for the 3 classifications

cursor c_classification_id is
select classification_id
from   pay_element_classifications pec
where  pec.classification_name = p_classification_name
  and  pec.legislation_code    = 'US'
  and  p_classification_name in
       ('Supplemental Earnings','Imputed Earnings','Pre-Tax Deductions');

-- Cursor to get Taxability Rule id based on current date

cursor c_taxability_rules_date_id is
select taxability_rules_date_id
from   pay_taxability_rules_dates trd
where  sysdate between trd.valid_date_from
       and trd.valid_date_to
  and  trd.legislation_code = 'US' ;

--cursor to get Taxability Rules

cursor c_pay_taxability_rules is
select jurisdiction_code,
       tax_type,
       status
from   pay_taxability_rules ptr
where  ptr.classification_id = l_classification_id
  and  ptr.legislation_code  = 'US'
  and  ptr.tax_category      = p_source_category
  and  (ptr.jurisdiction_code like p_source_state_code||'%' or
        p_source_state_code is null) ;


BEGIN

-- Get Classification Id.

  open c_classification_id ;
  fetch c_classification_id into l_classification_id ;
  close c_classification_id ;


-- Based on the Classification fix the Lookup Types.

  if p_classification_name = 'Supplemental Earnings' then
     l_lookup_type := 'US_SUPPLEMENTAL_EARNINGS' ;
  elsif p_classification_name = 'Imputed Earnings' then
     l_lookup_type := 'US_IMPUTED_EARNINGS' ;
  elsif p_classification_name = 'Pre-Tax Deductions' then
     l_lookup_type := 'US_PRE_TAX_DEDUCTIONS' ;
  end if;


-- Get Taxability Rule id

  open c_taxability_rules_date_id ;
  fetch c_taxability_rules_date_id into l_tax_rules_date_id ;
  close c_taxability_rules_date_id ;

-- If both source category and target category, source state
-- and target state are choosen same then there should not be any effect.

  if p_source_category = p_target_category and
     nvl(p_source_state_code,'XX') = nvl(p_target_state_code,'XX') then

     null ;

  else

-- Delete the Taxability Rules if any for Target Category Code.

    Delete pay_taxability_rules
    where  classification_id = l_classification_id
      and  legislation_code  = 'US'
      and  tax_category      = p_target_category
      and  jurisdiction_code like p_target_state_code||'%' ;

--Get Taxability Rules

    for tax_rul in c_pay_taxability_rules loop

-- If the rules are to be copied from one state to other then
-- the jurisdiction code can be changed accordingly.

      if p_target_state_code is null then
        l_jsd_code := tax_rul.jurisdiction_code ;
      else
        l_jsd_code := p_target_state_code||substr(tax_rul.jurisdiction_code,3,9);
      end if;

      insert into pay_taxability_rules (jurisdiction_code,
					tax_type,
					tax_category,
					classification_id,
					taxability_rules_date_id,
					legislation_code,
					last_update_date,
					last_updated_by,
					last_update_login,
					created_by,
					creation_date,
                                        status )
                              values  ( l_jsd_code,
                                        tax_rul.tax_type,
                                        p_target_category,
                                        l_classification_id,
                                        l_tax_rules_date_id,
                                        'US',
                                        sysdate,
                                        -1,
                                        -1,
                                        -1,
                                        sysdate,
                                        tax_rul.status );

    end loop;
  end if;

EXCEPTION
    WHEN OTHERS THEN

     errbuf   := SQLERRM;
     retcode  := SQLCODE;

     raise;


END COPY_TAX_RULES ;

END PQP_CPYTAXRUL;

/
