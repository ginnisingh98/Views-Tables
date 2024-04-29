--------------------------------------------------------
--  DDL for Package Body PER_AU_ADD_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_AU_ADD_LEG_HOOK" AS
/* $Header: peaulhpa.pkb 115.0 2004/01/19 22:29 vgsriniv noship $ */

/*--------------------------------------------------------------------------
-- Name           : CHECK_ADDRESS                                       --
-- Type           : Procedure                                           --
-- Access         : Private                                             --
-- Description    : Procedure is the driver procedure for the validation--
--                  of the address.                                     --
--                  This procedure is the hook procedure for the        --
--                  address.                                            --
-- Parameters     :                                                     --
--             IN :       p_style               IN VARCHAR2             --
--                        p_region_1            IN VARCHAR2             --
--                        p_country             IN VARCHAR2             --
--------------------------------------------------------------------------*/

PROCEDURE check_address(p_style              IN VARCHAR2
                       ,p_region_1           IN VARCHAR2
                       ,p_country            IN VARCHAR2) AS

     l_proc             VARCHAR2(72) := g_package||'check_address';

  BEGIN

  IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'AU') THEN
       hr_utility.trace ('AU Legislation not installed. Not performing the validations');
       RETURN;
  END IF;

 IF p_style = 'AU_GLB' and p_country = 'AU' THEN
--
-- Check for the mandatory values
--
  if p_region_1 is null then
     hr_utility.set_message(800, 'HR_AU_INVALID_STATE');
     hr_utility.raise_error;
  end if;

 END IF;

END check_address;

/*------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_ADDRESS_INS                                   --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure is the driver procedure for the validation--
--                  of the address.                                     --
--                  This procedure is the hook procedure for the        --
--                  address when address is inserted.                   --
-- Parameters     :                                                     --
--             IN :       p_style               IN VARCHAR2             --
--                        p_region_1            IN VARCHAR2             --
--                        p_country             IN VARCHAR2             --
-------------------------------------------------------------------------*/

PROCEDURE check_address_ins(p_style              IN VARCHAR2
                           ,p_region_1           IN VARCHAR2
                           ,p_country            IN VARCHAR2) AS
BEGIN

     check_address(p_style  =>   p_style
                  ,p_region_1 => p_region_1
                  ,p_country => p_country);

END check_address_ins;



/*------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_ADDRESS_UPD                                   --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure is the driver procedure for the validation--
--                  of the Address.                                     --
--                  This procedure is the hook procedure for the        --
--                  address when address is updated.                    --
-- Parameters     :                                                     --
--             IN :       p_address_id          IN NUMBER               --
--                        p_region_1            IN VARCHAR2             --
--                        p_country             IN VARCHAR2             --
------------------------------------------------------------------------*/

PROCEDURE check_address_upd(p_address_id         IN NUMBER
                           ,p_region_1           IN VARCHAR2
                           ,p_country            IN VARCHAR2) AS

  CURSOR get_style(p_address_id number) is
    SELECT style
    FROM   per_addresses
    WHERE  address_id=p_address_id;
    --
    l_style     per_addresses.style%TYPE;


BEGIN

   OPEN get_style(p_address_id);
   FETCH get_style INTO l_style;
   CLOSE get_style;

   check_address(p_style  =>   l_style
                ,p_region_1 => p_region_1
                ,p_country => p_country);

END check_address_upd;

END per_au_add_leg_hook;

/
