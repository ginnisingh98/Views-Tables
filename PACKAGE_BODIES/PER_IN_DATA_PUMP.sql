--------------------------------------------------------
--  DDL for Package Body PER_IN_DATA_PUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_IN_DATA_PUMP" AS
/* $Header: hrindpmf.pkb 120.0 2005/05/31 00:51 appldev noship $ */

-- -----------------------------------------------------------------------+
-- Name           : user_key_to_id                                      --+
-- Type           : Function                                            --+
-- Access         : Public                                              --+
-- Description    : Returns the id corresponding to the user key        --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   15-APR-2004    gaugupta        Created this function           --+
--------------------------------------------------------------------------+
FUNCTION user_key_to_id( p_user_key_value IN VARCHAR2)
RETURN NUMBER IS
   l_id NUMBER;
BEGIN
   SELECT unique_key_id
     INTO   l_id
     FROM   hr_pump_batch_line_user_keys
    WHERE  user_key_value = p_user_key_value;

   RETURN(l_id);
END user_key_to_id;


-- -----------------------------------------------------------------------+
-- Name           : get_opm_ovn                                         --+
-- Type           : Function                                            --+
-- Access         : Public                                              --+
-- Description    : Returns the organization payment method ovn         --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   15-APR-2004    gaugupta        Created this function           --+
--------------------------------------------------------------------------+
FUNCTION get_opm_ovn
(
   p_org_payment_method_user_key  IN VARCHAR2,
   p_effective_date               IN DATE
) RETURN NUMBER IS
   l_ovn NUMBER;
BEGIN
   SELECT opm.object_version_number
   INTO   l_ovn
   FROM   PAY_ORG_PAYMENT_METHODS_F opm
          ,hr_pump_batch_line_user_keys key
   WHERE  key.user_key_value = p_org_payment_method_user_key
   AND    opm.ORG_PAYMENT_METHOD_ID = key.unique_key_id
   AND    p_effective_date between
          opm.effective_start_date and opm.effective_end_date;
   RETURN(l_ovn);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_opm_ovn', sqlerrm,
                     p_org_payment_method_user_key ,p_effective_date);
   RAISE;
END get_opm_ovn;

-- -----------------------------------------------------------------------+
-- Name           : get_payment_type_id                                 --+
-- Type           : Function                                            --+
-- Access         : Public                                              --+
-- Description    : Returns the payment method type id                  --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   15-APR-2004    gaugupta        Created this function           --+
--------------------------------------------------------------------------+

FUNCTION  get_payment_type_id
(
   payment_type_id  IN NUMBER
) RETURN NUMBER IS
BEGIN
  RETURN  payment_type_id;
END get_payment_type_id;

-- -----------------------------------------------------------------------+
-- Name           : get_contact_relationship_ovn                        --+
-- Type           : Function                                            --+
-- Access         : Public                                              --+
-- Description    : Returns the extra contact relationship ovn          --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   15-APR-2004    gaugupta        Created this function           --+
--------------------------------------------------------------------------+
FUNCTION get_contact_relationship_ovn(p_contact_rel_user_key IN VARCHAR2)
 RETURN NUMBER IS
 l_contact_relationship_ovn NUMBER;
BEGIN
 SELECT ctk_rel.object_version_number
   INTO   l_contact_relationship_ovn
   FROM   per_contact_relationships    ctk_rel,
          hr_pump_batch_line_user_keys key
  WHERE   key.user_key_value = p_contact_rel_user_key
    AND   ctk_rel.contact_relationship_id  = key.unique_key_id;

 RETURN l_contact_relationship_ovn;

 EXCEPTION
    WHEN OTHERS THEN
    hr_data_pump.fail('get_contact_relationship_ovn',
                       sqlerrm,
                       p_contact_rel_user_key);
    RAISE;
END get_contact_relationship_ovn;


-- -----------------------------------------------------------------------+
-- Name           : get_contact_extra_info_ovn                          --+
-- Type           : Function                                            --+
-- Access         : Public                                              --+
-- Description    : Returns the contact extra info ovn                  --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid    Bug       Description                 --+
--------------------------------------------------------------------------+
-- 1.0   15-APR-2004    gaugupta        Created this function           --+
-- 1.1   23-Jul-2004    lnagaraj 3762728 Modified the cursor to take    --+
--                                      p_contact_extra_info_user_key   --+
--                                      and not p_person_extra_info_user--+
--                                      key                             --+
--------------------------------------------------------------------------+
FUNCTION get_contact_extra_info_ovn
(
   p_contact_extra_info_user_key IN VARCHAR2,
   p_effective_date      IN DATE
) RETURN NUMBER IS
   l_ovn NUMBER;
BEGIN
   SELECT  contact_info.object_version_number
     INTO  l_ovn
     FROM  per_contact_extra_info_f contact_info,
           hr_pump_batch_line_user_keys key
    WHERE  key.user_key_value = p_contact_extra_info_user_key
      AND  contact_info.contact_extra_info_id  = key.unique_key_id
      AND  p_effective_date BETWEEN
          contact_info.effective_start_date AND contact_info.effective_end_date;
   RETURN(l_ovn);

EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_contact_extra_info_ovn', sqlerrm, p_contact_extra_info_user_key ,
                     p_effective_date);
   RAISE;
END get_contact_extra_info_ovn;

-- -----------------------------------------------------------------------+
-- Name           : get_person_extra_info_ovn                           --+
-- Type           : Function                                            --+
-- Access         : Public                                              --+
-- Description    : Returns the extra person information ovn            --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   15-APR-2004    gaugupta        Created this function           --+
--------------------------------------------------------------------------+
FUNCTION get_person_extra_info_ovn(p_person_extra_info_user_key IN VARCHAR2)
 RETURN NUMBER IS
 l_person_extra_info_ovn NUMBER;
BEGIN
 SELECT  people_extra_info.object_version_number
   INTO  l_person_extra_info_ovn
   FROM  per_people_extra_info   people_extra_info,
         hr_pump_batch_line_user_keys key
  WHERE  key.user_key_value = p_person_extra_info_user_key
    AND  people_extra_info.PERSON_EXTRA_INFO_ID  = key.unique_key_id;

  RETURN l_person_extra_info_ovn;
  EXCEPTION
    WHEN OTHERS THEN
    hr_data_pump.fail('get_person_extra_info_ovn',
                       sqlerrm,
                       p_person_extra_info_user_key );
    RAISE;
END get_person_extra_info_ovn;

-- -----------------------------------------------------------------------+
-- Name           : get_person_extra_info_id                            --+
-- Type           : Function                                            --+
-- Access         : Public                                              --+
-- Description    : Returns the extra person information id             --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   15-APR-2004    gaugupta        Created this function           --+
--------------------------------------------------------------------------+
FUNCTION get_person_extra_info_id(p_person_extra_info_user_key IN VARCHAR2)
  RETURN NUMBER IS
  l_person_extra_info_id NUMBER;
BEGIN
  l_person_extra_info_id := user_key_to_id(p_person_extra_info_user_key);

  RETURN(l_person_extra_info_id);
EXCEPTION
  WHEN OTHERS THEN
    hr_data_pump.fail('get_person_extra_info_id', sqlerrm, p_person_extra_info_user_key);
    RAISE;
END get_person_extra_info_id;





-- -----------------------------------------------------------------------+
-- Name           : get_passport_country                                --+
-- Type           : Function                                            --+
-- Access         : Public                                              --+
-- Description    : Returns the country code                            --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   26-May-2004    gaugupta        Created this function           --+
--------------------------------------------------------------------------+
FUNCTION get_passport_country(p_issuing_country IN VARCHAR2)
 RETURN VARCHAR2 IS
 l_territory_code VARCHAR2(2);
BEGIN
  SELECT ttl.territory_code into l_territory_code
    FROM FND_TERRITORIES_TL ttl , FND_TERRITORIES t
   WHERE ttl.TERRITORY_SHORT_NAME = p_issuing_country
     AND ttl.TERRITORY_CODE = t.TERRITORY_CODE;

  RETURN l_territory_code;
  EXCEPTION
    WHEN OTHERS THEN
    hr_data_pump.fail('get_passport_country',
                       sqlerrm,
                       p_issuing_country );
    RAISE;
END get_passport_country;


-- -----------------------------------------------------------------------+
-- Name           : get_contact_extra_info_id                           --+
-- Type           : Function                                            --+
-- Access         : Public                                              --+
-- Description    : Returns the extra contact relationship id           --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   15-APR-2004    gaugupta        Created this function           --+
--------------------------------------------------------------------------+
FUNCTION get_contact_extra_info_id(p_contact_extra_info_user_key IN VARCHAR2)
  RETURN NUMBER IS
  l_contact_extra_info_id NUMBER;
BEGIN
   l_contact_extra_info_id := user_key_to_id(p_contact_extra_info_user_key);

   RETURN(l_contact_extra_info_id);
EXCEPTION
  WHEN OTHERS THEN
    hr_data_pump.fail('get_contact_extra_info_id', sqlerrm,p_contact_extra_info_user_key);
    RAISE;
END get_contact_extra_info_id;

-- -----------------------------------------------------------------------+
-- Name           : get_sets_of_book_id                                 --+
-- Type           : Function                                            --+
-- Access         : Public                                              --+
-- Description    : Returns the Sets Of Book id                         --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   15-APR-2004    gaugupta        Created this function           --+
--------------------------------------------------------------------------+

FUNCTION get_sets_of_book_id
(
   p_sets_of_book_name  IN VARCHAR2
) RETURN NUMBER IS
BEGIN
  RETURN(hr_pump_get.get_set_of_books_id(p_sets_of_book_name)) ;
END get_sets_of_book_id;

-- -----------------------------------------------------------------------+
-- Name           : get_id                                              --+
-- Type           : Function                                            --+
-- Access         : Public                                              --+
-- Description    : Returns the id of a given organization name.        --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid    Bug       Description                 --+
--------------------------------------------------------------------------+
-- 1.0   15-APR-2004    gaugupta        Created this function           --+
-- 1.1   19-Jul-2004    lnagaraj3762728  changed select stmt to get     --+
--                                      organization id
--------------------------------------------------------------------------+
FUNCTION get_id( p_org_name   IN VARCHAR2)
RETURN NUMBER IS
l_organization_id  HR_ALL_ORGANIZATION_UNITS.ORGANIZATION_ID%TYPE;
BEGIN

  SELECT organization_id INTO l_organization_id
    FROM HR_ALL_ORGANIZATION_UNITS
   WHERE name = p_org_name;

  RETURN (l_organization_id);
END get_id;

-- -----------------------------------------------------------------------+
-- Name           : get_gre_id                                          --+
-- Type           : Function                                            --+
-- Access         : Public                                              --+
-- Description    : Returns the id of the GRE/LEGAL entity              --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   15-APR-2004    gaugupta        Created this function           --+
--------------------------------------------------------------------------+
FUNCTION get_gre_id(p_gre_legal_entity  IN VARCHAR2)
RETURN NUMBER IS
BEGIN
  RETURN get_id(p_gre_legal_entity );

EXCEPTION
  WHEN OTHERS THEN
    hr_data_pump.fail('get_gre_id', sqlerrm,p_gre_legal_entity);
    RAISE;
END get_gre_id;


-- -----------------------------------------------------------------------+
-- Name           : get_pf_org_id                                       --+
-- Type           : Function                                            --+
-- Access         : Public                                              --+
-- Description    : Returns the id of the PF organization               --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   15-APR-2004    gaugupta        Created this function           --+
--------------------------------------------------------------------------+

FUNCTION get_pf_org_id(p_pf_organization   IN VARCHAR2)
RETURN NUMBER IS
BEGIN
  RETURN get_id( p_pf_organization);

EXCEPTION
  WHEN OTHERS THEN
    hr_data_pump.fail('get_pf_org_id', sqlerrm,p_pf_organization);
    RAISE;
END  get_pf_org_id;

-- -----------------------------------------------------------------------+
-- Name           : get_prof_tax_org_id                                 --+
-- Type           : Function                                            --+
-- Access         : Public                                              --+
-- Description    : Returns the id of the Proff Tax organization        --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   15-APR-2004    gaugupta        Created this function           --+
--------------------------------------------------------------------------+
FUNCTION get_prof_tax_org_id(p_prof_tax_organization IN VARCHAR2)
RETURN NUMBER IS
BEGIN
  RETURN get_id( p_prof_tax_organization);

EXCEPTION
  WHEN OTHERS THEN
    hr_data_pump.fail('get_prof_tax_org_id', sqlerrm,p_prof_tax_organization);
    RAISE;
END get_prof_tax_org_id;

-- -----------------------------------------------------------------------+
-- Name           : get_esi_id                                          --+
-- Type           : Function                                            --+
-- Access         : Public                                              --+
-- Description    : Returns the id of the esi organization              --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   15-APR-2004    gaugupta        Created this function           --+
--------------------------------------------------------------------------+
FUNCTION get_esi_id(p_esi_organization   IN VARCHAR2)
RETURN NUMBER IS
BEGIN
  RETURN get_id( p_esi_organization);

EXCEPTION
  WHEN OTHERS THEN
    hr_data_pump.fail('get_esi_id', sqlerrm,p_esi_organization);
    RAISE;

END  get_esi_id;

-- -----------------------------------------------------------------------+
-- Name           : get_factory_id                                      --+
-- Type           : Function                                            --+
-- Access         : Public                                              --+
-- Description    : Returns the id of the factory organization          --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   15-APR-2004    gaugupta        Created this function           --+
--------------------------------------------------------------------------+
FUNCTION get_factory_id(p_factory   IN VARCHAR2)
RETURN NUMBER IS
BEGIN
  RETURN get_id( p_factory);

EXCEPTION
  WHEN OTHERS THEN
    hr_data_pump.fail('get_factory_id', sqlerrm,p_factory);
    RAISE;

END  get_factory_id;

-- -----------------------------------------------------------------------+
-- Name           : get_est_id                                          --+
-- Type           : Function                                            --+
-- Access         : Public                                              --+
-- Description    : Returns the id of the Establishment                 --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   15-APR-2004    gaugupta        Created this function           --+
--------------------------------------------------------------------------+
FUNCTION get_est_id(p_establishment   IN VARCHAR2)
RETURN NUMBER IS
BEGIN
  RETURN get_id( p_establishment);

EXCEPTION
  WHEN OTHERS THEN
    hr_data_pump.fail('get_est_id', sqlerrm,p_establishment);
    RAISE;

END  get_est_id;




-- -----------------------------------------------------------------------+
-- Name           : get_tp_header_id                                    --+
-- Type           : Function                                            --+
-- Access         : Public                                              --+
-- Description    :                                                     --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   15-APR-2004    gaugupta        Created this function           --+
--------------------------------------------------------------------------+
FUNCTION  get_tp_header_id
RETURN NUMBER IS
BEGIN
  RETURN null;
END get_tp_header_id;

-- -----------------------------------------------------------------------+
-- Name           : get_designated_receiver_id                          --+
-- Type           : Function                                            --+
-- Access         : Public                                              --+
-- Description    :                                                     --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   15-APR-2004    gaugupta        Created this function           --+
--------------------------------------------------------------------------+
FUNCTION  get_designated_receiver_id
RETURN NUMBER IS
BEGIN
  RETURN null;
END get_designated_receiver_id;


-- -----------------------------------------------------------------------+
-- Name           : get_operating_unit_id                               --+
-- Type           : Function                                            --+
-- Access         : Public                                              --+
-- Description    :                                                     --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   15-APR-2004    gaugupta        Created this function           --+
--------------------------------------------------------------------------+
FUNCTION  get_operating_unit_id
RETURN NUMBER IS
BEGIN
  RETURN null;
END get_operating_unit_id;

-- -----------------------------------------------------------------------+
-- Name           : get_inventory_organization_id                       --+
-- Type           : Function                                            --+
-- Access         : Public                                              --+
-- Description    :                                                     --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   15-APR-2004    gaugupta        Created this function           --+
--------------------------------------------------------------------------+
FUNCTION  get_inventory_organization_id
RETURN NUMBER IS
BEGIN
  RETURN null;
END get_inventory_organization_id;

-- -----------------------------------------------------------------------+
-- Name           : get_ship_to_location_id                             --+
-- Type           : Function                                            --+
-- Access         : Public                                              --+
-- Description    :                                                     --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   15-APR-2004    gaugupta        Created this function           --+
--------------------------------------------------------------------------+
FUNCTION  get_ship_to_location_id(p_ship_to_location_id IN NUMBER)
RETURN NUMBER IS
BEGIN
  RETURN p_ship_to_location_id;
END get_ship_to_location_id;

-- -----------------------------------------------------------------------+
-- Name           : get_vendor_site_id                                  --+
-- Type           : Function                                            --+
-- Access         : Public                                              --+
-- Description    :                                                     --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   15-APR-2004    gaugupta        Created this function           --+
--------------------------------------------------------------------------+
FUNCTION  get_vendor_site_id (p_vendor_site_id  IN NUMBER)
RETURN NUMBER  IS
BEGIN
  RETURN p_vendor_site_id;
END get_vendor_site_id;


-- -----------------------------------------------------------------------+
-- Name           : get_po_header_id                                    --+
-- Type           : Function                                            --+
-- Access         : Public                                              --+
-- Description    :                                                     --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   15-APR-2004    gaugupta        Created this function           --+
--------------------------------------------------------------------------+
FUNCTION  get_po_header_id(p_po_header_id IN NUMBER)
RETURN NUMBER  IS
BEGIN
  RETURN p_po_header_id;
END get_po_header_id;

-- -----------------------------------------------------------------------+
-- Name           : get_po_line_id                                      --+
-- Type           : Function                                            --+
-- Access         : Public                                              --+
-- Description    :                                                     --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   15-APR-2004    gaugupta        Created this function           --+
--------------------------------------------------------------------------+
FUNCTION  get_po_line_id (p_po_line_id  IN NUMBER)
RETURN NUMBER  IS
BEGIN
  RETURN p_po_line_id;
END get_po_line_id;

-- -----------------------------------------------------------------------+
-- Name           : get_issue_date                                      --+
-- Type           : Function                                            --+
-- Access         : Public                                              --+
-- Description    :                                                     --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid     Bug      Description                 --+
--------------------------------------------------------------------------+
-- 1.0   22-Jul-2004    LNAGARAJ   3762728  Created this function       --+
--------------------------------------------------------------------------+
FUNCTION  get_issue_date(p_issue_date VARCHAR2)
RETURN varchar2  IS
BEGIN
  RETURN fnd_date.date_to_canonical(fnd_date.chardt_to_date(p_issue_date));
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_issue_date', sqlerrm, p_issue_date);
   RAISE;
END get_issue_date;

-- -----------------------------------------------------------------------+
-- Name           : get_birth_date                                      --+
-- Type           : Function                                            --+
-- Access         : Public                                              --+
-- Description    :                                                     --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid    Bug        Description                --+
--------------------------------------------------------------------------+
-- 1.0   22-Jul-2004    LNAGARAJ  3762728   Created this function       --+
--------------------------------------------------------------------------+

FUNCTION  get_birth_date(p_guardian_birth_date VARCHAR2)
RETURN varchar2  IS
BEGIN
  RETURN fnd_date.date_to_canonical(fnd_date.chardt_to_date(p_guardian_birth_date));
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_birth_date', sqlerrm, p_guardian_birth_date);
   RAISE;
END get_birth_date;

-- -----------------------------------------------------------------------+
-- Name           : get_expiry_date                                     --+
-- Type           : Function                                            --+
-- Access         : Public                                              --+
-- Description    :                                                     --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid   Bug       Description                  --+
--------------------------------------------------------------------------+
-- 1.0   22-Jul-2004    LNAGARAJ 3762728      Created this function    --+
--------------------------------------------------------------------------+
FUNCTION  get_expiry_date(p_expiry_date VARCHAR2)
RETURN varchar2  IS
BEGIN
  RETURN  fnd_date.date_to_canonical(fnd_date.chardt_to_date(p_expiry_date));
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_expiry_date', sqlerrm, p_expiry_date);
   RAISE;
END get_expiry_date;

-- -----------------------------------------------------------------------+
-- Name           : get_height                                          --+
-- Type           : Function                                            --+
-- Access         : Public                                              --+
-- Description    :                                                     --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid    Bug       Description                 --+
--------------------------------------------------------------------------+
-- 1.0   22-Jul-2004    LNAGARAJ  3762728   Created this function       --+
--------------------------------------------------------------------------+
FUNCTION get_height(p_height IN VARCHAR2)
  RETURN VARCHAR2 IS
  l_height NUMBER;
  E_INVALID_DATA_ERR EXCEPTION;
BEGIN
  l_height := to_number(p_height);
  IF l_height >=1.00 AND L_HEIGHT<=3.00 THEN
    RETURN(p_height);
  ELSE
   RAISE E_INVALID_DATA_ERR;
  END IF;
EXCEPTION
    WHEN E_INVALID_DATA_ERR THEN
    hr_data_pump.fail('get_height', sqlerrm, p_height);
    RAISE;
    WHEN OTHERS THEN
    hr_data_pump.fail('get_height', sqlerrm, p_height);
    RAISE;
END get_height;
-- -----------------------------------------------------------------------+
-- Name           : get_weight                                          --+
-- Type           : Function                                            --+
-- Access         : Public                                              --+
-- Description    :                                                     --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid    Bug        Description                --+
--------------------------------------------------------------------------+
-- 1.0   22-Jul-2004    LNAGARAJ  3762728      Created this function    --+
--------------------------------------------------------------------------+
FUNCTION get_weight(p_weight IN VARCHAR2)
  RETURN VARCHAR2 IS
  l_weight NUMBER;
  E_INVALID_DATA_ERR EXCEPTION;
BEGIN
  l_weight := to_number(p_weight);
  IF l_weight >=0.00 AND l_weight<=999.99 THEN
    RETURN(p_weight);
  ELSE
   RAISE E_INVALID_DATA_ERR;
  END IF;
EXCEPTION
    WHEN E_INVALID_DATA_ERR THEN
    hr_data_pump.fail('get_weight', sqlerrm, p_weight);
    RAISE;
    WHEN OTHERS THEN
    hr_data_pump.fail('get_weight', sqlerrm, p_weight);
    RAISE;
END get_weight;

-- -----------------------------------------------------------------------+
-- Name           : get_scl_contractor_id                               --+
-- Type           : Function                                            --+
-- Access         : Public                                              --+
-- Description    : Returns the id of the Contractor                    --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid   Bug        Description                 --+
--------------------------------------------------------------------------+
-- 1.0   19-Jul-2004    lnagaraj 3762728   Created this function        --+
--------------------------------------------------------------------------+
FUNCTION get_scl_contractor_id(p_scl_contractor_name   IN VARCHAR2)
RETURN NUMBER IS
BEGIN
  RETURN get_id( p_scl_contractor_name);

EXCEPTION
  WHEN OTHERS THEN
    hr_data_pump.fail('get_scl_contractor_id', sqlerrm,p_scl_contractor_name);
    RAISE;

END  get_scl_contractor_id;

END per_in_data_pump ;

/
