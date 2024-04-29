--------------------------------------------------------
--  DDL for Package Body PER_PL_LOCATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PL_LOCATION" AS
/* $Header: pepllhla.pkb 120.2 2006/09/18 04:58:35 mseshadr noship $ */
  g_package  VARCHAR2(33) := 'per_pl_location.';
--
PROCEDURE check_pl_location (
                            p_address_line_1       IN VARCHAR2
                           ,p_address_line_2       IN VARCHAR2
                           ) IS
    --
    l_return            Varchar2(30);
    --
BEGIN


    --
    -- Check that Street Name is entered when street type is entered
    --
    IF ( p_address_line_1 IS NOT NULL ) THEN
       IF ( p_address_line_2 IS NULL ) THEN
          hr_utility.set_message(800,'HR_PL_ST_NAME_NOT_SPEC');
          hr_utility.raise_error;
       END IF;
    END IF;

    --
END check_pl_location;
--
--
--
PROCEDURE create_pl_location (p_style        IN VARCHAR2
                            ,p_address_line_1       IN VARCHAR2
                            ,p_address_line_2       IN VARCHAR2)
IS
BEGIN
    --
  /* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'PL') THEN
   hr_utility.trace('PL not installed.Leaving create_pl_location');
   return;
END IF;
    IF  p_style = 'PL' THEN
            per_pl_location.check_pl_location( p_address_line_1 => p_address_line_1
                                            ,p_address_line_2 => p_address_line_2);
    END IF;
    --
END create_pl_location;
--
--
PROCEDURE update_pl_location (p_style              IN VARCHAR2
                            ,p_address_line_1       IN VARCHAR2
                            ,p_address_line_2       IN VARCHAR2)
IS
    --
    --
BEGIN
    --
  /* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'PL') THEN
   hr_utility.trace('PL not installed.Leaving update_pl_location');
   return;
END IF;
       IF  p_style='PL' THEN
            per_pl_location.check_pl_location( p_address_line_1 => p_address_line_1
                                            ,p_address_line_2 => p_address_line_2);
       END IF;

    --
END update_pl_location;
--
END per_pl_location;

/
