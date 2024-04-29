--------------------------------------------------------
--  DDL for Package PER_IN_ORG_INFO_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_IN_ORG_INFO_LEG_HOOK" AUTHID CURRENT_USER AS
/* $Header: peinlhoi.pkh 120.4.12010000.1 2008/07/28 04:52:37 appldev ship $*/


-- Legislative Procedures related to Oranization Classification
--
--------------------------------------------------------------------------
-- Name           : CHECK_UNIQUE_NUM_INS                                --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure is the driver procedure for the validation--
--                  of the Organizaition Information data for the       --
--                  context IN_CONTRACTOR_INFO.                         --
--                  This procedure is the hook procedure for            --
--                  for org information when org info is updated        --
-- Parameters     :                                                     --
--             IN : p_org_info_type_code    VARCHAR2                    --
--                  p_org_information1      VARCHAR2                    --
--                  p_org_information2      VARCHAR2                    --
--                  p_org_information3      VARCHAR2                    --
--                  p_org_information4      VARCHAR2                    --
--                  p_org_information5      VARCHAR2                    --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid           Description                    --
--------------------------------------------------------------------------
-- 1.0   16-May-2005    sukukuma       created this procedure           --
--------------------------------------------------------------------------
PROCEDURE check_unique_num_ins (p_org_info_type_code   IN VARCHAR2
                               ,p_org_information1     IN VARCHAR2
                               ,p_org_information2     IN VARCHAR2
                               ,p_org_information3     IN VARCHAR2
                               ,p_org_information4     IN VARCHAR2
                               ,p_org_information5     IN VARCHAR2);

--------------------------------------------------------------------------
-- Name           : CHECK_UNIQUE_NUM_UPD                                --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure is the driver procedure for the validation--
--                  of the Organizaition Information data for the       --
--                  context IN_CONTRACTOR_INFO.                         --
--                  This procedure is the hook procedure for            --
--                  for org information when org info is updated        --
-- Parameters     :                                                     --
--             IN : p_org_information_id    NUMBER                      --
--                  p_org_info_type_code    VARCHAR2                    --
--                  p_org_information1      VARCHAR2                    --
--                  p_org_information2      VARCHAR2                    --
--                  p_org_information3      VARCHAR2                    --
--                  p_org_information4      VARCHAR2                    --
--                  p_org_information5      VARCHAR2                    --
--            OUT : 3                                                   --
--         RETURN : N/A                                                 --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid           Description                    --
--------------------------------------------------------------------------
-- 1.0   16-May-2005    sukukuma        Modified this procedure         --
--------------------------------------------------------------------------

PROCEDURE check_unique_num_upd (p_org_information_id   IN  NUMBER
                               ,p_org_info_type_code   IN VARCHAR2
                               ,p_org_information1     IN VARCHAR2
                               ,p_org_information2     IN VARCHAR2
                               ,p_org_information3     IN VARCHAR2
                               ,p_org_information4     IN VARCHAR2
                               ,p_org_information5     IN VARCHAR2);

---------------------------------------------------------------------------
 --                                                                      --
 -- Name           : check_rep_ins                                       --
 -- Type           : Procedure                                           --
 -- Access         : Public                                              --
 -- Description    : Procedure is the driver procedure for the validation--
 --                  of the dates,so that they do not overlap.This also  --
 --                  performs PAN Validation and uniqueness checking of  --
 --                  TAN ,IF applicable.This is the hook procedure for   --
 --                  organization information when representative details--
 --                  are inserted.                                       --
 -- Parameters     :                                                     --
 --             IN : p_org_information1      VARCHAR2                    --
 --                  p_org_information2      VARCHAR2                    --
 --                  p_org_information3      VARCHAR2                    --
 --                  p_organization_id       NUMBER                      --
 --                  p_org_info_type_code    VARCHAR2                    --
 --                                                                      --
 --            OUT : N/A                                                 --
 --         RETURN : N/A                                                 --
-- Change History :                                                      --
---------------------------------------------------------------------------
-- Rev#  Date           Userid           Description                     --
---------------------------------------------------------------------------
-- 1.0   16-May-2005    sukukuma        Modified this procedure          --
---------------------------------------------------------------------------

PROCEDURE check_rep_ins(p_org_information1   IN VARCHAR2
                       ,p_org_information2   IN VARCHAR2
                       ,p_org_information3   IN VARCHAR2
                       ,p_organization_id    IN NUMBER
                       ,p_org_info_type_code IN VARCHAR2);


 --------------------------------------------------------------------------
 --                                                                      --
 -- Name           : check_rep_upd                                       --
 -- Type           : Procedure                                           --
 -- Access         : Public                                              --
 -- Description    : Procedure is the driver procedure for the validation--
 --                  of the dates,so that they do not overlap.           --
 --                  This is the hook procedure for the                  --
 --                  organization information type when representative   --
 --                  details is updated.                                 --
 -- Parameters     :                                                     --
 --             IN : p_org_information1      VARCHAR2                    --
 --                  p_org_information2      VARCHAR2                    --
 --                  p_org_information3      VARCHAR2                    --
 --                  p_org_information_id  NUMBER                        --
 --                  p_org_info_type_code  VARCHAR2                      --
 --                                                                      --
 --            OUT : N/A                                                 --
 --         RETURN : N/A                                                 --
-- Change History :                                                      --
---------------------------------------------------------------------------
-- Rev#  Date           Userid           Description                     --
---------------------------------------------------------------------------
-- 1.0   16-May-2005    sukukuma        Modified this procedure          --

---------------------------------------------------------------------------

PROCEDURE check_rep_upd(p_org_information1   IN VARCHAR2
                       ,p_org_information2   IN VARCHAR2
                       ,p_org_information3   IN VARCHAR2
                       ,p_org_information_id IN NUMBER
                       ,p_org_info_type_code IN VARCHAR2);



--------------------------------------------------------------------------
-- Name           : check_pf_challan_accounts                           --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Dummy procedure                                     --
-- Parameters     :                                                     --
--             IN : p_org_info_type_code      VARCHAR2                  --
--		    p_org_information3        VARCHAR2                  --
--                  p_org_information4        VARCHAR2                  --
--                  p_org_information5        VARCHAR2                  --
--                  p_org_information6        VARCHAR2                  --
--                  p_org_information7        VARCHAR2                  --
--                  p_org_information8        VARCHAR2                  --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid           Description                    --
--------------------------------------------------------------------------
-- 1.0   16-May-2005    sukukuma         Modified this procedure        --
-- 1.1   17-sep-2007    sivanara         Added message parameters and   --
--                                       removed fnd_message code       --
-- 1.2   22-Apr-2008    mdubasi          Removed above fix to resolve   --
--                                       P1 6967621                     --

--------------------------------------------------------------------------
PROCEDURE check_pf_challan_accounts (p_org_info_type_code   IN VARCHAR2
                                    ,p_org_information3     IN VARCHAR2
                                    ,p_org_information4     IN VARCHAR2
                                    ,p_org_information5     IN VARCHAR2
                                    ,p_org_information6     IN VARCHAR2
                                    ,p_org_information7     IN VARCHAR2
                                    ,p_org_information8     IN VARCHAR2
                                    );

--------------------------------------------------------------------------
-- Name           : check_organization_update                           --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Main Procedure to be called from the Org Hook       --
-- Parameters     :                                                     --
--             IN : p_effective_date                DATE                --
--                  p_organization_id               NUMBER              --
--                  p_name                          VARCHAR2            --
--                  p_date_from                     DATE                --
--                  p_date_to                       DATE                --
--                  p_location_id                   NUMBER              --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid           Description                    --
--------------------------------------------------------------------------
-- 1.0   16-May-2005    sukukuma         Modified this procedure        --
--------------------------------------------------------------------------


PROCEDURE check_organization_update
                (p_effective_date     IN  DATE,
                 p_organization_id    IN NUMBER,
                 p_name               IN VARCHAR2,
                 p_date_from          IN DATE,
                 p_date_to            IN DATE,
                 p_location_id        IN NUMBER);

--------------------------------------------------------------------------
-- Name           : check_org_class_create                              --
-- Type           : Procedure                                           --
-- Access         : Private                                             --
-- Description    : Internal Proc  to be called from the Org Class Hook --
-- Parameters     :                                                     --
--             IN : p_effective_date            DATE                    --
--                  p_organization_id           NUMBER                  --
--                  p_org_classif_code          VARCHAR2                --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid           Description                    --
--------------------------------------------------------------------------
-- 1.0   16-May-2005    sukukuma         Modified this procedure        --
--------------------------------------------------------------------------

PROCEDURE check_org_class_create
               (p_effective_date     IN  DATE
               ,p_organization_id    IN NUMBER
               ,p_org_classif_code   IN VARCHAR2
                );


--------------------------------------------------------------------------
-- Name           : check_org_class_internal                            --
-- Type           : Procedure                                           --
-- Access         : Private                                             --
-- Description    : Internal Proc  to be called from the Org Class Hook --
-- Parameters     :                                                     --
--             IN : p_effective_date        DATE                        --
--                : p_organization_id       NUMBER                      --
--                : p_org_classif_code      VARCHAR2                    --
--            OUT : p_message_name          VARCHAR2                    --
--                : p_token_name            VARCHAR2                    --
--                : p_token_value           VARCHAR2                    --
--                                                                      --
--            OUT : 3                                                   --
--         RETURN : N/A                                                 --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid           Description                    --
--------------------------------------------------------------------------
-- 1.0   16-May-2005    sukukuma         Modified this procedure        --
--------------------------------------------------------------------------


 PROCEDURE check_org_class_internal
               (p_effective_date     IN  DATE,
                p_organization_id    IN NUMBER,
                p_org_classif_code   IN VARCHAR2,
                p_calling_procedure  IN VARCHAR2,
                p_message_name       OUT NOCOPY VARCHAR2,
                p_token_name         OUT NOCOPY pay_in_utils.char_tab_type,
                p_token_value        OUT NOCOPY pay_in_utils.char_tab_type);
--
-- Legislative Procedures related to Oranization Information


--------------------------------------------------------------------------
-- Name           : check_org_info_create                               --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Main Procedure to be called from the Org Info Hook  --
-- Parameters     :                                                     --
--             IN : p_effective_date     IN  DATE                       --
--                : p_organization_id    IN  NUMBER                     --
--                : p_org_info_type_code IN VARCHAR2                    --
--                : p_org_information1   IN VARCHAR2                    --
--                : p_org_information2   IN VARCHAR2                    --
--                : p_org_information3   IN VARCHAR2                    --
--                : p_org_information4   IN VARCHAR2                    --
--                : p_org_information5   IN VARCHAR2                    --
--                : p_org_information6   IN VARCHAR2                    --
--                : p_org_information8   IN VARCHAR2                    --
--                : p_org_information9   IN VARCHAR2                    --
--                : p_org_information10  IN VARCHAR2                    --
--                : p_org_information11  IN VARCHAR2                    --
--                : p_org_information12  IN VARCHAR2                    --
--                : p_org_information13  IN VARCHAR2                    --
--                : p_org_information14  IN VARCHAR2                    --
--                : p_org_information15  IN VARCHAR2                    --
--                : p_org_information16  IN VARCHAR2                    --
--                : p_org_information17  IN VARCHAR2                    --
--                : p_org_information18  IN VARCHAR2                    --
--                : p_org_information19  IN VARCHAR2                    --
--                : p_org_information20  IN VARCHAR2                    --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid           Description                    --
--------------------------------------------------------------------------
-- 1.0   16-May-2005    sukukuma         Modified this procedure        --
--------------------------------------------------------------------------

 PROCEDURE check_org_info_create
                (p_effective_date     IN  DATE,
                 p_organization_id    IN NUMBER,
                 p_org_info_type_code IN VARCHAR2,
                 p_org_information1   IN VARCHAR2,
                 p_org_information2   IN VARCHAR2,
                 p_org_information3   IN VARCHAR2,
                 p_org_information4   IN VARCHAR2,
                 p_org_information5   IN VARCHAR2,
                 p_org_information6   IN VARCHAR2,
                 p_org_information7   IN VARCHAR2,
                 p_org_information8   IN VARCHAR2,
                 p_org_information9   IN VARCHAR2,
                 p_org_information10  IN VARCHAR2,
                 p_org_information11  IN VARCHAR2,
                 p_org_information12  IN VARCHAR2,
                 p_org_information13  IN VARCHAR2,
                 p_org_information14  IN VARCHAR2,
                 p_org_information15  IN VARCHAR2,
                 p_org_information16  IN VARCHAR2,
                 p_org_information17  IN VARCHAR2,
                 p_org_information18  IN VARCHAR2,
                 p_org_information19  IN VARCHAR2,
                 p_org_information20  IN VARCHAR2);



--------------------------------------------------------------------------
-- Name           : check_org_info_update                               --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Main Procedure to be called from the Org Info Hook  --
-- Parameters     :                                                     --
--             IN : p_effective_date     IN  DATE                       --
--                : p_org_information_id IN  NUMBER                     --
--                : p_org_info_type_code IN VARCHAR2                    --
--                : p_org_information1   IN VARCHAR2                    --
--                : p_org_information2   IN VARCHAR2                    --
--                : p_org_information3   IN VARCHAR2                    --
--                : p_org_information4   IN VARCHAR2                    --
--                : p_org_information5   IN VARCHAR2                    --
--                : p_org_information6   IN VARCHAR2                    --
--                : p_org_information8   IN VARCHAR2                    --
--                : p_org_information9   IN VARCHAR2                    --
--                : p_org_information10  IN VARCHAR2                    --
--                : p_org_information11  IN VARCHAR2                    --
--                : p_org_information12  IN VARCHAR2                    --
--                : p_org_information13  IN VARCHAR2                    --
--                : p_org_information14  IN VARCHAR2                    --
--                : p_org_information15  IN VARCHAR2                    --
--                : p_org_information16  IN VARCHAR2                    --
--                : p_org_information17  IN VARCHAR2                    --
--                : p_org_information18  IN VARCHAR2                    --
--                : p_org_information19  IN VARCHAR2                    --
--                : p_org_information20  IN VARCHAR2                    --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid           Description                    --
--------------------------------------------------------------------------
-- 1.0   16-May-2005    sukukuma         Modified this procedure        --
--------------------------------------------------------------------------


PROCEDURE check_org_info_update
                (p_effective_date     IN  DATE,
                 p_org_information_id IN  NUMBER,
                 p_org_info_type_code IN VARCHAR2,
                 p_org_information1   IN VARCHAR2,
                 p_org_information2   IN VARCHAR2,
                 p_org_information3   IN VARCHAR2,
                 p_org_information4   IN VARCHAR2,
                 p_org_information5   IN VARCHAR2,
                 p_org_information6   IN VARCHAR2,
                 p_org_information7   IN VARCHAR2,
                 p_org_information8   IN VARCHAR2,
                 p_org_information9   IN VARCHAR2,
                 p_org_information10  IN VARCHAR2,
                 p_org_information11  IN VARCHAR2,
                 p_org_information12  IN VARCHAR2,
                 p_org_information13  IN VARCHAR2,
                 p_org_information14  IN VARCHAR2,
                 p_org_information15  IN VARCHAR2,
                 p_org_information16  IN VARCHAR2,
                 p_org_information17  IN VARCHAR2,
                 p_org_information18  IN VARCHAR2,
                 p_org_information19  IN VARCHAR2,
                 p_org_information20  IN VARCHAR2);

END per_in_org_info_leg_hook;

/
