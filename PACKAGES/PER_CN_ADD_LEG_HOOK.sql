--------------------------------------------------------
--  DDL for Package PER_CN_ADD_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CN_ADD_LEG_HOOK" AUTHID CURRENT_USER AS
/* $Header: pecnlhpa.pkh 120.0 2005/05/31 06:54:07 appldev noship $ */
--
  g_package  VARCHAR2(33) := 'per_cn_add_leg_hook.';

 --------------------------------------------------------------------------
-- Name           : CHECK_ADDRESS                                       --
-- Type           : Procedure                                           --
-- Access         : Public                                             --
-- Description    : Procedure is the driver procedure for the validation--
--                  of the address.                                     --
--                  This procedure is the hook procedure for the        --
--                  address.                                            --
-- Parameters     :                                                     --
--             IN :       p_address_line1       IN VARCHAR2             --
--                        p_town_or_city        IN VARCHAR2             --
--                        p_country             IN VARCHAR2             --
--                        p_postal_code         IN VARCHAR2             --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   29/11/02   saikrish  Created this procedure                    --
-- 1.1   10/04/03   statkar   Nulled out this procedure - 2893334       --
--------------------------------------------------------------------------
PROCEDURE check_address(p_address_line1      IN VARCHAR2
                       ,p_town_or_city       IN VARCHAR2
                       ,p_country            IN VARCHAR2
                       ,p_postal_code        IN VARCHAR2);

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_ADDRESS_INS                                   --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure is the driver procedure for the validation--
--                  of the applicant.                                   --
--                  This procedure is the hook procedure for the        --
--                  address when address in inserted.                   --
-- Parameters     :                                                     --
--             IN :       p_style               IN VARCHAR2             --
--                        p_address_line1       IN VARCHAR2             --
--                        p_town_or_city        IN VARCHAR2             --
--                        p_country             IN VARCHAR2             --
--                        p_postal_code         IN VARCHAR2             --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   29/11/02   saikrish  Created this procedure                    --
-- 1.1   9/4/2003   bramajey  Changed name from CHECK_ADDRESS to        --
--                            CHECK_ADDRESS_INS and included 1 more     --
--                            parameter p_style                         --
--------------------------------------------------------------------------
  PROCEDURE check_address_ins(p_style               IN VARCHAR2
                             ,p_address_line1       IN VARCHAR2
                             ,p_town_or_city        IN VARCHAR2
                             ,p_country             IN VARCHAR2
                             ,p_postal_code         IN VARCHAR2);

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_ADDRESS_UPD                                   --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure is the driver procedure for the validation--
--                  of the applicant.                                   --
--                  This procedure is the hook procedure for the        --
--                  address when address in updated.                    --
-- Parameters     :                                                     --
--             IN :       p_address_id          IN NUMBER               --
--                        p_address_line1       IN VARCHAR2             --
--                        p_town_or_city        IN VARCHAR2             --
--                        p_country             IN VARCHAR2             --
--                        p_postal_code         IN VARCHAR2             --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   9/4/2003   bramajey  Created this procedure                    --
-- 1.1   14/01/04   sshankar  Added parameter 'address_id'.(Bug 3371417)--
--------------------------------------------------------------------------
  PROCEDURE check_address_upd
                         (p_address_id          IN NUMBER
                         ,p_address_line1       IN VARCHAR2
                         ,p_town_or_city        IN VARCHAR2
                         ,p_country             IN VARCHAR2
                         ,p_postal_code         IN VARCHAR2);

END per_cn_add_leg_hook;

 

/
