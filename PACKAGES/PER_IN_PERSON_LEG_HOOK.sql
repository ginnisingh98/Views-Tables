--------------------------------------------------------
--  DDL for Package PER_IN_PERSON_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_IN_PERSON_LEG_HOOK" AUTHID CURRENT_USER AS
/* $Header: peinlhpe.pkh 120.3 2007/09/14 15:56:57 sivanara ship $ */


--------------------------------------------------------------------------
--                                                                      --
-- Name           : VALIDATE_PAN_FORMAT                                 --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Checks for the validity of the format of the PAN    --
--                                                                      --
--                                                                      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_per_information4          VARCHAR2                --
--                : p_per_information_category  VARCHAR2                --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   05-Apr-04  abhjain     Created this procedure                  --
-- 1.1   16-May-05  sukukuma    updated this procedure                  --
--------------------------------------------------------------------------

PROCEDURE validate_pan_format(
                             p_per_information_category IN VARCHAR2
                            ,p_per_information4         IN VARCHAR2
                             );

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_PAN_AND_PAN_AF                                --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Checks that either the PAN field or the PAN Applied --
--                  For field is null.                                  --
--                                                                      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_per_information_category  VARCHAR2                --
--                  p_per_information4          VARCHAR2                --
--                : p_per_information5          VARCHAR2                --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   05-Apr-04  abhjain     Created this procedure                  --
-- 1.1   16-May-05  sukukuma    updated this procedure                  --
--------------------------------------------------------------------------

PROCEDURE check_pan_and_pan_af(
         p_per_information_category IN VARCHAR2
        ,p_per_information4         IN VARCHAR2 DEFAULT NULL
        ,p_per_information5         IN VARCHAR2 DEFAULT NULL
        );


--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_UNIQUE_NUMBER_INSERT                          --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Checks for the uniqueness of the PAN, PF Number,    --
--                  ESI Number, Superannuation Number, Group Insurance  --
--                  Number, Gratuity Number and Pension Fund Number in  --
--                  the create_employee user hook.                      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_per_information_category       VARCHAR2           --
--                : p_business_group_id              NUMBER             --
--                : p_per_information4               VARCHAR2           --
--                : p_per_information8               VARCHAR2           --
--                : p_per_information9               VARCHAR2           --
--                : p_per_information10              VARCHAR2           --
--                : p_per_information11              VARCHAR2           --
--                : p_per_information12              VARCHAR2           --
--                : p_per_information13              VARCHAR2           --
--                                                                      --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   05-Apr-04  abhjain     Created this procedure                  --
-- 1.1   16-May-05  sukukuma    updated this procedure                  --
--------------------------------------------------------------------------


 PROCEDURE check_unique_number_insert(
          p_per_information_category IN VARCHAR2
         ,p_business_group_id        IN NUMBER
         ,p_per_information4         IN VARCHAR2 DEFAULT NULL
         ,p_per_information8         IN VARCHAR2 DEFAULT NULL
         ,p_per_information9         IN VARCHAR2 DEFAULT NULL
         ,p_per_information10        IN VARCHAR2 DEFAULT NULL
         ,p_per_information11        IN VARCHAR2 DEFAULT NULL
         ,p_per_information12        IN VARCHAR2 DEFAULT NULL
         ,p_per_information13        IN VARCHAR2 DEFAULT NULL
        );

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_UNIQUE_NUMBER_UPDATE                          --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Checks for the uniqueness of the PAN, PF Number,    --
--                  ESI Number, Superannuation Number, Group Insurance  --
--                  Number, Gratuity Number and Pension Fund Number in  --
--                  the update_person user hook.                        --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_effective_date                 DATE               --
--                : p_per_information_category       VARCHAR2           --
--                : p_person_id                      NUMBER             --
--                : p_per_information4               VARCHAR2           --
--                : p_per_information8               VARCHAR2           --
--                : p_per_information9               VARCHAR2           --
--                : p_per_information10              VARCHAR2           --
--                : p_per_information11              VARCHAR2           --
--                : p_per_information12              VARCHAR2           --
--                : p_per_information13              VARCHAR2           --
--                                                                      --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   05-Apr-04  abhjain     Created this procedure                  --
-- 1.1   16-May-05  sukukuma    updated this procedure                  --
--------------------------------------------------------------------------

PROCEDURE check_unique_number_update(
         p_effective_date           IN DATE
        ,p_per_information_category IN VARCHAR2
        ,p_person_id                IN NUMBER
        ,p_per_information4         IN VARCHAR2 DEFAULT NULL
        ,p_per_information8         IN VARCHAR2 DEFAULT NULL
        ,p_per_information9         IN VARCHAR2 DEFAULT NULL
        ,p_per_information10        IN VARCHAR2 DEFAULT NULL
        ,p_per_information11        IN VARCHAR2 DEFAULT NULL
        ,p_per_information12        IN VARCHAR2 DEFAULT NULL
        ,p_per_information13        IN VARCHAR2 DEFAULT NULL
        );



--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_EMPLOYEE                                      --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Checks for
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_person_type_id                 NUMBER             --
--                : p_per_information_category       VARCHAR2           --
--                : p_per_information7               VARCHAR2           --
--                : p_hire_date                      DATE               --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   04-Feb-05  lnagaraj    Created this procedure                  --
-- 1.1   16-May-05  sukukuma    updated this procedure                  --
--------------------------------------------------------------------------
PROCEDURE check_employee(p_person_type_id           IN NUMBER
                        ,p_per_information_category IN VARCHAR2
                        ,p_per_information7         IN VARCHAR2
                        ,p_hire_date                IN DATE
                         ) ;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_PERSON                                        --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Checks for
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_person_type_id                 NUMBER             --
--                  p_person_id                      NUMBER             --
--                : p_per_information_category       VARCHAR2           --
--                : p_per_information7               VARCHAR2           --
--                : p_effective_date                 DATE               --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   04-Feb-05  lnagaraj    Created this procedure                  --
-- 1.1   16-May-05  sukukuma    updated this procedure                  --
--------------------------------------------------------------------------
PROCEDURE check_person(p_person_id                IN NUMBER
                      ,p_person_type_id           IN NUMBER
                      ,p_per_information_category IN VARCHAR2
                      ,p_per_information7         IN VARCHAR2
                      ,p_effective_date           IN DATE
                      ) ;




--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_PAN_FORMAT                                    --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Checks for the validity of the format of the PAN    --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_pan                                   VARCHAR2    --
--                : p_pan_af                                VARCHAR2    --
--                : p_panref_number                         VARCHAR2    --
--            OUT : p_message_name                          VARCHAR2    --
--                : p_token_name                            VARCHAR2    --
--                : p_token_value                           VARCHAR2    --
--            OUT : 3                                                   --
--         RETURN : N/A                                                 --
--
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   16/05/05   sukukuma   Created this procedure                   --
-- 1.1   19/01/06   abhjain    Added p_panref_number                    --
--------------------------------------------------------------------------

PROCEDURE check_pan_format( p_pan           IN VARCHAR2
                           ,p_pan_af        IN VARCHAR2
                           ,p_panref_number IN VARCHAR2
                           ,p_message_name  OUT NOCOPY VARCHAR2
                           ,p_token_name    OUT NOCOPY pay_in_utils.char_tab_type
                           ,p_token_value   OUT NOCOPY pay_in_utils.char_tab_type
                            );


--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_IN_PERSON_INSERT                              --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Checks for the uniqueness of the PAN, PF Number,    --
--                  ESI Number, Superannuation Number, Group Insurance  --
--                  Number, Gratuity Number and Pension Fund Number in  --
--                  the create_employee user hook.                      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_per_information_category       VARCHAR2           --
--                : p_business_group_id              NUMBER             --
--                : p_person_type_id                 NUMBER             --
--                : p_per_information4               VARCHAR2           --
--                : p_per_information5               VARCHAR2           --
--                : p_per_information7               VARCHAR2           --
--                : p_per_information8               VARCHAR2           --
--                : p_per_information9               VARCHAR2           --
--                : p_per_information10              VARCHAR2           --
--                : p_per_information11              VARCHAR2           --
--                : p_per_information12              VARCHAR2           --
--                : p_per_information13              VARCHAR2           --
--                : p_per_information14              VARCHAR2           --
--                : p_per_information15              VARCHAR2           --
--                : p_hire_date                      DATE               --
--                : p_effective_date                 DATE               --
--                                                                      --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   16/05/05   sukukuma   Created this procedure                   --
-- 1.1   19/01/06   abhjain    Added p_per_information14. Bug 4863466   --
-- 1.2   10/07/07   sivanara   Added parameter p_per_information15 for  --
--                             NSSN(PF Monthly Retunrs).                --
--------------------------------------------------------------------------

PROCEDURE check_in_person_insert(
         p_per_information_category IN VARCHAR2
        ,p_business_group_id        IN NUMBER
        ,p_person_type_id           IN NUMBER
        ,p_hire_date                IN DATE
        ,p_per_information4         IN VARCHAR2
        ,p_per_information5         IN VARCHAR2
        ,p_per_information6         IN VARCHAR2
        ,p_per_information7         IN VARCHAR2
        ,p_per_information8         IN VARCHAR2
        ,p_per_information9         IN VARCHAR2
        ,p_per_information10        IN VARCHAR2
        ,p_per_information11        IN VARCHAR2
        ,p_per_information12        IN VARCHAR2
        ,p_per_information13        IN VARCHAR2
        ,p_per_information14        IN VARCHAR2
        ,p_per_information15        IN VARCHAR2
        );




 --------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_IN_PERSON_UPDATE                              --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Checks for the uniqueness of the PAN, PF Number,    --
--                  ESI Number, Superannuation Number, Group Insurance  --
--                  Number, Gratuity Number and Pension Fund Number in  --
--                  the create_employee user hook.                      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_per_information_category       VARCHAR2           --
--                : p_person_type_id                 NUMBER             --
--                : p_person_id                      NUMBER             --
--                : p_per_information4               VARCHAR2           --
--                : p_per_information5               VARCHAR2           --
--                : p_per_information7               VARCHAR2           --
--                : p_per_information8               VARCHAR2           --
--                : p_per_information9               VARCHAR2           --
--                : p_per_information10              VARCHAR2           --
--                : p_per_information11              VARCHAR2           --
--                : p_per_information12              VARCHAR2           --
--                : p_per_information13              VARCHAR2           --
--                : p_per_information14              VARCHAR2           --
--                : p_per_information15              VARCHAR2           --
--                : p_effective_date                 DATE               --
--                                                                      --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   16/05/05   sukukuma   Created this procedure                   --
-- 1.1   19/01/06   abhjain    Added p_per_information14. Bug 4863466   --
-- 1.2   10/07/07   sivanara   Added parameter p_per_information15 for  --
--                             NSSN(PF Monthly Retunrs).                --
--------------------------------------------------------------------------

PROCEDURE check_in_person_update (
         p_per_information_category IN VARCHAR2
        ,p_person_type_id           IN NUMBER
        ,p_person_id                IN NUMBER
        ,p_effective_date           IN DATE
        ,p_per_information4         IN VARCHAR2
        ,p_per_information5         IN VARCHAR2
        ,p_per_information6         IN VARCHAR2
        ,p_per_information7         IN VARCHAR2
        ,p_per_information8         IN VARCHAR2
        ,p_per_information9         IN VARCHAR2
        ,p_per_information10        IN VARCHAR2
        ,p_per_information11        IN VARCHAR2
        ,p_per_information12        IN VARCHAR2
        ,p_per_information13        IN VARCHAR2
        ,p_per_information14        IN VARCHAR2
        ,p_per_information15        IN VARCHAR2
        );

END  per_in_person_leg_hook;

/
