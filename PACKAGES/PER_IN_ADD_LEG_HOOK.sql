--------------------------------------------------------
--  DDL for Package PER_IN_ADD_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_IN_ADD_LEG_HOOK" AUTHID CURRENT_USER as
/* $Header: peinlhad.pkh 120.1.12010000.1 2008/07/28 04:52:04 appldev ship $ */
--

--
-- declare types needed globally
--


TYPE r_pin_code IS RECORD(state_code hr_lookups.lookup_code%TYPE,
                          pin_code   hr_lookups.meaning%TYPE);
TYPE t_pin_code IS TABLE OF r_pin_code INDEX BY BINARY_INTEGER;
tab_pin_code t_pin_code;





 --------------------------------------------------------------------------
 --                                                                      --
 -- Name           : CHECK_PER_ADDRESS_INS                               --
 -- Type           : Procedure                                           --
 -- Access         : Public                                              --
 -- Description    : Procedure is the driver procedure for the validation--
 --                  of the address of a person.                         --
 --                  This is the hook procedure for the                  --
 --                  address when personal address is inserted.          --
 -- Parameters     :                                                     --
 --             IN :       p_style               IN VARCHAR2             --
 --                        p_address_id          IN VARCHAR2             --
 --                        p_add_information14   IN VARCHAR2             --
 --                        p_add_information15   IN VARCHAR2             --
 --                        p_postal_code         IN VARCHAR2             --
 ---------------------------------------------------------------------------

 PROCEDURE check_per_address_ins(p_style              IN VARCHAR2
				,p_address_id         IN NUMBER
				,p_add_information14  IN VARCHAR2
                                ,p_add_information15  IN VARCHAR2 -- State
                                ,p_postal_code        IN VARCHAR2);

---------------------------------------------------------------------------
 --                                                                      --
 -- Name           : CHECK_LOC_ADDRESS_INS                               --
 -- Type           : Procedure                                           --
 -- Access         : Public                                              --
 -- Description    : Procedure is the driver procedure for the validation--
 --                  of the address of a location.                       --
 --                  This  is the hook procedure for the  address        --
 --                   when a location address is inserted.               --
 -- Parameters     :                                                     --
 --             IN :       p_style               IN VARCHAR2             --
 --                        p_loc_information16   IN VARCHAR2             --
 --                        p_postal_code         IN VARCHAR2             --
---------------------------------------------------------------------------

 PROCEDURE check_loc_address_ins(p_style              IN VARCHAR2
                                ,p_loc_information16  IN VARCHAR2 -- State
                                ,p_postal_code        IN VARCHAR2);


--------------------------------------------------------------------------
 --                                                                      --
 -- Name           : CHECK_PER_ADDRESS_UPD                               --
 -- Type           : Procedure                                           --
 -- Access         : Public                                              --
 -- Description    : Procedure is the driver procedure for the validation--
 --                  of the address of a location.                       --
 --                  This  is the hook procedure for the address when    --
 --                  personal address is updated.                        --
 -- Parameters     :                                                     --
 --             IN :       p_address_id          IN NUMBER               --
 --                        p_add_information14   IN VARCHAR2             --
 --                        p_add_information15   IN VARCHAR2             --
 --                        p_postal_code         IN VARCHAR2             --
 --                                                                      --
 ----------------------------------------------------------------------------

 PROCEDURE check_per_address_upd(p_address_id          IN NUMBER
				,p_add_information14   IN VARCHAR2
                                ,p_add_information15   IN VARCHAR2
				,p_postal_code         IN VARCHAR2);
---------------------------------------------------------------------------
  --                                                                      --
  -- Name           : CHECK_LOC_ADDRESS_UPD                               --
  -- Type           : Procedure                                           --
  -- Access         : Public                                              --
  -- Description    : Procedure is the driver procedure for the validation--
  --                  of address of a location.                           --
  --                  This procedure is the hook procedure for the address--
  --                  when location address is updated.                   --
  -- Parameters     :                                                     --
  --             IN :       p_location_id         IN NUMBER               --
  --                        p_loc_information16   IN VARCHAR2             --
  --                        p_postal_code         IN VARCHAR2             --
  --                                                                      --

  --------------------------------------------------------------------------
  PROCEDURE check_loc_address_upd(p_location_id         IN NUMBER
                                 ,p_loc_information16   IN VARCHAR2 -- State
                                 ,p_postal_code         IN VARCHAR2);

END   per_in_add_leg_hook;

/
