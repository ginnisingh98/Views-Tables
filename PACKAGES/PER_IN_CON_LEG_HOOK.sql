--------------------------------------------------------
--  DDL for Package PER_IN_CON_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_IN_CON_LEG_HOOK" AUTHID CURRENT_USER AS
/* $Header: peinlhco.pkh 120.4.12010000.1 2008/07/28 04:52:18 appldev ship $ */



-- -----------------------------------------------------------------------+
-- Name           : nominee_age_check                                   --+
-- Type           : Procedure                                           --+
-- Access         : Public                                              --+
-- Description    : This procedure does the age validation i.e          --+
--                  checks if the guardian details are entered if the   --+
--                  nominee's age is below 18                           --+
-- Parameters     :                                                     --+
--             IN : p_contact_relationship_id   NUMBER                  --+
--            OUT : N/A                                                  --+
--         RETURN : N/A                                                 --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   31-Mar-2004    gaugupta        Created this procedure          --+
-- 1.1   31-Mar-2004    gaugupta        Bug 3590036 fixed.              --+
-- 1.2   16-May-2005    sukukuma        updated this procedure          --+
--------------------------------------------------------------------------+
--vbanner, commenting out for bug 4674384.
--sukukuma, uncommented out for bug 4674384
  PROCEDURE nominee_age_check
  ( p_contact_relationship_id  IN
  PER_CONTACT_EXTRA_INFO_F.contact_relationship_id%TYPE);

-- -----------------------------------------------------------------------+
-- Name           : nomination_share_insert_check                       --+
-- Type           : Procedure                                           --+
-- Access         : Public                                              --+
-- Description    : This procedure checks if the sum of nomination share--+
--                  for a particular benifit of employee is under 100   --+
--                  or not.                                             --+
-- Parameters     :                                                     --+
--             IN : p_CEI_INFORMATION2         NUMBER                   --+
--                  p_CEI_INFORMATION3         NUMBER                   --+
--                  p_effective_date           DATE                     --+
--                  p_contact_relationship_id  NUMBER                   --+
--            OUT : N/A                                                 --+
--         RETURN : N/A                                                 --+
--                                                                      --+
--                                                                      --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   31-Mar-2004    gaugupta        Created this procedure          --+
-- 1.1   16-May-2005    sukukuma        Updated this procedure          --+
--------------------------------------------------------------------------+

PROCEDURE nomination_share_insert_check
        (p_CEI_INFORMATION2        IN PER_CONTACT_EXTRA_INFO_F.CEI_INFORMATION2%TYPE
        ,p_CEI_INFORMATION3        IN PER_CONTACT_EXTRA_INFO_F.CEI_INFORMATION3%TYPE
        ,p_effective_date          IN DATE
        ,p_contact_relationship_id IN PER_CONTACT_EXTRA_INFO_F.contact_relationship_id%TYPE
        );


-- -----------------------------------------------------------------------+
-- Name           : nomination_share_update_check                       --+
-- Type           : Procedure                                           --+
-- Access         : Public                                              --+
-- Description    : This procedure checks if the sum of nomination share--+
--                  for a particular benifit of employee is under 100   --+
--                  or not.                                             --+
-- Parameters     :                                                     --+
--             IN : p_CEI_INFORMATION2         NUMBER                   --+
--                  p_CEI_INFORMATION3         NUMBER                   --+
--                  p_effective_date           DATE                     --+
--                  p_contact_relationship_id  NUMBER                   --+
--                  p_contact_extra_info_id    NUMBER                   --+
--            OUT : N/A                                                 --+
--         RETURN : N/A                                                 --+
--                                                                      --+
--                                                                      --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   31-Mar-2004    gaugupta        Created this procedure          --+
-- 1.1   16-May-2005    sukukuma        Updated this procedure          --+
--------------------------------------------------------------------------+

PROCEDURE nomination_share_update_check
        (p_CEI_INFORMATION2        IN PER_CONTACT_EXTRA_INFO_F.CEI_INFORMATION2%TYPE
        ,p_CEI_INFORMATION3        IN PER_CONTACT_EXTRA_INFO_F.CEI_INFORMATION3%TYPE
        ,p_effective_date          IN DATE
        ,p_contact_relationship_id IN PER_CONTACT_EXTRA_INFO_F.contact_relationship_id%TYPE
        ,p_contact_extra_info_id    IN  PER_CONTACT_EXTRA_INFO_F.contact_extra_info_id%TYPE);


-- -----------------------------------------------------------------------+
-- Name           : check_nominee_age                                   --+
-- Type           : Procedure                                           --+
-- Access         : Public                                              --+
-- Description    : This procedure does the age validation i.e          --+
--                  checks if the guardian details are entered if the   --+
--                  nominee's age is below 18                           --+
-- Parameters     :                                                     --+
--             IN : p_contact_relationship_id   NUMBER                  --+
--                  p_message_name              VARCHAR2                --+
--                  p_token_name                VARCHAR2                --+
--                  p_toen_value                VARCHAR2                --+
--            OUT : 3                                                   --+
--         RETURN : N/A                                                 --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   31-Mar-2004    gaugupta        Created this procedure          --+
-- 1.1   31-Mar-2004    gaugupta        Bug 3590036 fixed.              --+
-- 1.2   16-May-2005    sukukuma        updated this procedure          --+
--------------------------------------------------------------------------+
--sukukuma, changed the name of this procedure from nominee_age_check
-- to check_nominee_age
PROCEDURE check_nominee_age
( p_contact_relationship_id  IN  PER_CONTACT_EXTRA_INFO_F.contact_relationship_id%TYPE
 ,p_message_name             OUT NOCOPY VARCHAR2
 ,p_token_name               OUT NOCOPY pay_in_utils.char_tab_type
 ,p_token_value              OUT NOCOPY pay_in_utils.char_tab_type);


-- -----------------------------------------------------------------------+
-- Name           : get_essential_insert_value                          --+
-- Type           : Procedure                                           --+
-- Access         : Private                                             --+
-- Description    : This procedure checks if the sum of nomination share--+
--                  for a particular benifit of employee is under 100   --+
--                  or not.                                             --+
-- Parameters     :                                                     --+
--             IN : p_CEI_INFORMATION2         NUMBER                   --+
--                : p_CEI_INFORMATION3         NUMBER                   --+
--                : p_effective_date           DATE                     --+
--                : p_contact_relationship_id  NUMBER                   --+
--                  p_message_name             VARCHAR2                 --+
--                  p_token_name               VARCHAR2                 --+
--                  p_toen_value               VARCHAR2                 --+
--            OUT : 3                                                   --+
--         RETURN : N/A                                                 --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   12-Jan-2006    rpalli        Added this procedure spec         --+
--------------------------------------------------------------------------+0

PROCEDURE get_essential_insert_value
        (p_CEI_INFORMATION2        IN PER_CONTACT_EXTRA_INFO_F.CEI_INFORMATION2%TYPE
        ,p_CEI_INFORMATION3        IN PER_CONTACT_EXTRA_INFO_F.CEI_INFORMATION3%TYPE
        ,p_effective_date          IN DATE
        ,p_contact_relationship_id IN PER_CONTACT_EXTRA_INFO_F.contact_relationship_id%TYPE
        ,p_message_name            OUT NOCOPY VARCHAR2
        ,p_token_name              OUT NOCOPY pay_in_utils.char_tab_type
        ,p_token_value             OUT NOCOPY pay_in_utils.char_tab_type);


-- -----------------------------------------------------------------------+
-- Name           : get_essential_update_value                          --+
-- Type           : Procedure                                           --+
-- Access         : Private                                             --+
-- Description    : This procedure checks if the sum of nomination share--+
--                  for a particular benifit of employee is under 100   --+
--                  or not.                                             --+
-- Parameters     :                                                     --+
--             IN : p_CEI_INFORMATION2         NUMBER                   --+
--                  p_CEI_INFORMATION3         NUMBER                   --+
--                  p_effective_date           DATE                     --+
--                  p_contact_relationship_id  NUMBER                   --+
--                  p_contact_extra_info_id    NUMBER                   --+
--                  p_message_name             VARCHAR2                 --+
--                  p_token_name               VARCHAR2                 --+
--                  p_toen_value               VARCHAR2                 --+
--            OUT : 3                                                   --+
--         RETURN : N/A                                                 --+
--                                                                      --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   12-Jan-2006    rpalli        Added this procedure spec         --+
--------------------------------------------------------------------------+0

PROCEDURE get_essential_update_value
        (p_CEI_INFORMATION2        IN PER_CONTACT_EXTRA_INFO_F.CEI_INFORMATION2%TYPE
        ,p_CEI_INFORMATION3        IN PER_CONTACT_EXTRA_INFO_F.CEI_INFORMATION3%TYPE
        ,p_effective_date          IN DATE
        ,p_contact_relationship_id IN PER_CONTACT_EXTRA_INFO_F.contact_relationship_id%TYPE
        ,p_contact_extra_info_id   IN  PER_CONTACT_EXTRA_INFO_F.contact_extra_info_id%TYPE
        ,p_message_name            OUT NOCOPY VARCHAR2
        ,p_token_name              OUT NOCOPY pay_in_utils.char_tab_type
        ,p_token_value             OUT NOCOPY pay_in_utils.char_tab_type);

-- -----------------------------------------------------------------------+
-- Name           : check_in_con_insert                                 --+
-- Type           : Procedure                                           --+
-- Access         : Public                                              --+
-- Description    : This procedure checks if the sum of nomination share--+
--                  for a particular benifit of employee is under 100   --+
--                  or not.                                             --+
-- Parameters     :                                                     --+
--             IN : p_CEI_INFORMATION2         NUMBER                   --+
--                  p_CEI_INFORMATION3         NUMBER                   --+
--                  p_effective_date           DATE                     --+
--                  p_contact_relationship_id  NUMBER                   --+
--            OUT : N/A                                                 --+
--         RETURN : N/A                                                 --+
--                                                                      --+
--                                                                      --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   31-Mar-2004    gaugupta        Created this procedure          --+
-- 1.1   16-May-2005    sukukuma        Updated this procedure          --+
--------------------------------------------------------------------------+

PROCEDURE check_in_con_insert (p_CEI_INFORMATION2         IN PER_CONTACT_EXTRA_INFO_F.CEI_INFORMATION2%TYPE
                              ,p_CEI_INFORMATION3         IN PER_CONTACT_EXTRA_INFO_F.CEI_INFORMATION3%TYPE
                              ,p_effective_date           IN DATE
                              ,p_contact_relationship_id  IN PER_CONTACT_EXTRA_INFO_F.contact_relationship_id%TYPE);



-- -----------------------------------------------------------------------+
-- Name           : check_in_con_update                                 --+
-- Type           : Procedure                                           --+
-- Access         : Public                                              --+
-- Description    : This procedure checks if the sum of nomination share--+
--                  for a particular benifit of employee is under 100   --+
--                  or not.                                             --+
-- Parameters     :                                                     --+
--             IN : p_CEI_INFORMATION2         NUMBER                   --+
--                  p_CEI_INFORMATION3         NUMBER                   --+
--                  p_effective_date           DATE                     --+
--                  p_contact_relationship_id  NUMBER                   --+
--                  p_contact_extra_info_id    NUMBER                   --+
--            OUT : N/A                                                 --+
--         RETURN : N/A                                                 --+
--                                                                      --+
--                                                                      --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   31-Mar-2004    gaugupta        Created this procedure          --+
-- 1.1   16-May-2005    sukukuma        Updated this procedure          --+
--------------------------------------------------------------------------+
PROCEDURE check_in_con_update
        (p_CEI_INFORMATION2        IN PER_CONTACT_EXTRA_INFO_F.CEI_INFORMATION2%TYPE
        ,p_CEI_INFORMATION3        IN PER_CONTACT_EXTRA_INFO_F.CEI_INFORMATION3%TYPE
        ,p_effective_date          IN DATE
        ,p_contact_relationship_id IN PER_CONTACT_EXTRA_INFO_F.contact_relationship_id%TYPE
        ,p_contact_extra_info_id    IN  PER_CONTACT_EXTRA_INFO_F.contact_extra_info_id%TYPE);



-- -----------------------------------------------------------------------+
-- Name           : get_nomination_share                                --+
-- Type           : Function                                            --+
-- Access         : Public                                              --+
-- Description    : This function returns the nomination share for a    --+
--                  particular combination of contact relationship id   --+
--                  effecttive date and benefit type.                   --+
-- Parameters     :                                                     --+
--             IN : p_contact_relationship_id  NUMBER                   --+
--                  p_CEI_INFORMATION3         NUMBER                   --+
--                  p_effective_date           DATE                     --+
--            OUT : 3                                                   --+
--         RETURN : N/A                                                 --+
--                                                                      --+
--                                                                      --+
--                                                                      --+
-- Change History :                                                     --+
--------------------------------------------------------------------------+
-- Rev#  Date           Userid           Description                    --+
--------------------------------------------------------------------------+
-- 1.0   31-Mar-2004    gaugupta        Created this procedure          --+
-- 1.1   24-Jun-2004    vgsriniv        Modified the logic.(Bug:3683622)--+
--------------------------------------------------------------------------+
FUNCTION get_nomination_share(p_contact_relationship_id IN PER_CONTACT_EXTRA_INFO_F.contact_relationship_id%TYPE
                             ,p_CEI_INFORMATION3        IN PER_CONTACT_EXTRA_INFO_F.CEI_INFORMATION3%TYPE
                             ,p_effective_date          IN  DATE) RETURN NUMBER ;
END per_in_con_leg_hook;

/
