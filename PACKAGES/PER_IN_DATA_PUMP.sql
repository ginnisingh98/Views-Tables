--------------------------------------------------------
--  DDL for Package PER_IN_DATA_PUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_IN_DATA_PUMP" AUTHID CURRENT_USER AS
/* $Header: hrindpmf.pkh 120.0 2005/05/31 00:51 appldev noship $ */

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
FUNCTION get_contact_relationship_ovn(p_contact_rel_user_key in varchar2)
 RETURN NUMBER ;


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
) RETURN NUMBER;



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

FUNCTION  get_payment_type_id(payment_type_id  IN NUMBER)
RETURN NUMBER;

-- -----------------------------------------------------------------------+
-- Name           : get_contact_extra_info_ovn                          --+
-- Type           : Function                                            --+
-- Access         : Public                                              --+
-- Description    : Returns the contact extra info ovn                  --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   15-APR-2004    gaugupta        Created this function           --+
-- 1.1   23-Jul-2004    lnagaraj        Modified the input parameter    --+
--------------------------------------------------------------------------+
FUNCTION get_contact_extra_info_ovn
(
   p_contact_extra_info_user_key IN VARCHAR2,
   p_effective_date      in date
) return number ;

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
RETURN NUMBER;

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
FUNCTION get_person_extra_info_id(p_person_extra_info_user_key IN varchar2)
RETURN NUMBER ;

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
RETURN NUMBER ;


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
FUNCTION get_sets_of_book_id(p_sets_of_book_name IN VARCHAR2)
RETURN NUMBER ;

-- -----------------------------------------------------------------------+
-- Name           : get_id                                              --+
-- Type           : Function                                            --+
-- Access         : Public                                              --+
-- Description    : Returns the id of a given organization name.        --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   15-APR-2004    gaugupta        Created this function           --+
--------------------------------------------------------------------------+

FUNCTION get_id(p_org_name  IN VARCHAR2)
RETURN NUMBER;

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

FUNCTION get_gre_id(p_gre_legal_entity   IN VARCHAR2)
RETURN NUMBER;

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
RETURN NUMBER;

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
RETURN NUMBER;


-- -----------------------------------------------------------------------+
-- Name           : get_esi_id                                          --+
-- Type           : Function                                            --+
-- Access         : Public                                              --+
-- Description    : Returns the id of the ESI  organization             --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   15-APR-2004    gaugupta        Created this function           --+
--------------------------------------------------------------------------+
FUNCTION get_esi_id(p_esi_organization   IN VARCHAR2)
RETURN NUMBER;

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
RETURN NUMBER;

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
RETURN NUMBER;

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
RETURN NUMBER;


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
RETURN NUMBER ;


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
RETURN NUMBER ;


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
RETURN NUMBER ;


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
RETURN NUMBER ;

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
RETURN NUMBER ;

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
RETURN NUMBER ;

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
RETURN NUMBER ;

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
 RETURN VARCHAR2 ;

-- -----------------------------------------------------------------------+
-- Name           : get_issue_date                                      --+
-- Type           : Function                                            --+
-- Access         : Public                                              --+
-- Description    : Returns the value in canonical format               --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid   Bug        Description                 --+
--------------------------------------------------------------------------+
-- 1.0   19-Jul-2004    lnagaraj 3762728       Created this function    --+
--------------------------------------------------------------------------+
FUNCTION  get_issue_date(p_issue_date VARCHAR2)
RETURN VARCHAR2 ;

-- -----------------------------------------------------------------------+
-- Name           : get_birth_date                                      --+
-- Type           : Function                                            --+
-- Access         : Public                                              --+
-- Description    : Returns the value in canonical format               --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid    Bug       Description                 --+
--------------------------------------------------------------------------+
-- 1.0   19-Jul-2004    lnagaraj  3762728     Created this function     --+
--------------------------------------------------------------------------+

FUNCTION  get_birth_date(p_guardian_birth_date VARCHAR2)
RETURN VARCHAR2 ;

-- -----------------------------------------------------------------------+
-- Name           : get_expiry_date                                     --+
-- Type           : Function                                            --+
-- Access         : Public                                              --+
-- Description    : Returns the value in canonical format               --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid    Bug       Description                 --+
--------------------------------------------------------------------------+
-- 1.0   19-Jul-2004    lnagaraj  3762728      Created this function    --+
--------------------------------------------------------------------------+

FUNCTION  get_expiry_date(p_expiry_date VARCHAR2)
RETURN VARCHAR2;

-- -----------------------------------------------------------------------+
-- Name           : get_height                                          --+
-- Type           : Function                                            --+
-- Access         : Public                                              --+
-- Description    : validates that height is between 1.00 and 3.00      --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   19-Jul-2004    lnagaraj        Created this function           --+
--------------------------------------------------------------------------+
FUNCTION get_height
(
   p_height  IN VARCHAR2
) RETURN VARCHAR2;

-- -----------------------------------------------------------------------+
-- Name           : get_weight                                          --+
-- Type           : Function                                            --+
-- Access         : Public                                              --+
-- Description    : validates that weight is between 0.00 and 999.99    --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   19-Jul-2004    lnagaraj        Created this function           --+
--------------------------------------------------------------------------+

FUNCTION get_weight
(
   p_weight  IN VARCHAR2
) RETURN VARCHAR2;

-- -----------------------------------------------------------------------+
-- Name           : get_scl_contractor_id                               --+
-- Type           : Function                                            --+
-- Access         : Public                                              --+
-- Description    : Returns the id of the Contractor                    --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   19-Jul-2004    lnagaraj        Created this function           --+
--------------------------------------------------------------------------+
FUNCTION get_scl_contractor_id(p_scl_contractor_name   IN VARCHAR2)
RETURN NUMBER;

END per_in_data_pump ;

 

/
