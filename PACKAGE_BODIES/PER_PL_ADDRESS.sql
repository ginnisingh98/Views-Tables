--------------------------------------------------------
--  DDL for Package Body PER_PL_ADDRESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PL_ADDRESS" AS
/* $Header: pepllhpa.pkb 120.1 2006/09/13 12:34:12 mseshadr noship $ */
  g_package  VARCHAR2(33) := 'per_pl_address.';
--
PROCEDURE check_address_unique
( p_address_ID              NUMBER ,
  p_address_type            VARCHAR2,
  p_date_from               DATE,
  p_date_to                 DATE,
  p_person_id               NUMBER,
  p_pradd_ovlapval_override       in     boolean default FALSE)   --Added for Bug 4210646
  is
--
  l_status            VARCHAR2(1);
  g_last_date         DATE ;
  local_warning       EXCEPTION;
  p_override          VARCHAR2(8) := 'FALSE';
BEGIN
   g_last_date         := to_date('31-12-4712','DD-MM-YYYY');

--Added If clause for Bug 4210646

    If p_pradd_ovlapval_override Then
       p_override := 'TRUE';
    End if;

   --
     SELECT 'Y'
     INTO   l_status
     FROM   sys.dual
     WHERE  exists(SELECT '1'
		    FROM   per_addresses pp
        	    WHERE (p_address_id IS NULL
		       OR  p_address_id <> pp.address_id)
		    AND    p_person_id = pp.person_id
                    AND    p_address_type = pp.address_type
            AND    (
                   p_date_from  between pp.date_from and nvl(pp.date_to,g_last_date )
                   OR
                   nvl(p_date_to,g_last_date)  between pp.date_from and nvl(pp.date_to,g_last_date)
                   OR
                   pp.date_from  between p_date_from and nvl(p_date_to,g_last_date )
                   )
            AND p_override = 'FALSE'
            );
     --
          hr_utility.set_message(800,'HR_PL_DUPLICATE_ADDRESS');
          hr_utility.raise_error;
 --
  EXCEPTION
   WHEN NO_DATA_FOUND THEN NULL;
END check_address_unique;




PROCEDURE check_pl_address (
                            p_address_ID              NUMBER ,
                            p_address_type            VARCHAR2,
                            p_date_from               DATE,
                            p_date_to                 DATE,
                            p_person_id               NUMBER,
                            p_address_line1       IN VARCHAR2,
                            p_address_line2       IN VARCHAR2,
					p_pradd_ovlapval_override       in     boolean  --Added for Bug 4210646
                           ) IS
    --
    l_return            Varchar2(30);
    --
BEGIN


    --
    -- Check that Address type is entered
    --
    IF ( p_address_type IS NULL ) THEN
          hr_utility.set_message(800,'HR_PL_ADDRESS_TYPE_NULL');
          hr_utility.raise_error;
    END IF;

    --
    -- Check that Street Name is entered when street type is entered
    --
    IF ( p_address_line1 IS NOT NULL ) THEN
       IF ( p_address_line2 IS NULL ) THEN
          hr_utility.set_message(800,'HR_PL_ST_NAME_NOT_SPEC');
          hr_utility.raise_error;
       END IF;
    END IF;
    --

       check_address_unique
                  ( p_address_ID              ,
                    p_address_type            ,
                    p_date_from               ,
                    p_date_to                 ,
                    p_person_id               ,
			p_pradd_ovlapval_override );               --Added for Bug 4210646
    --
    --
END check_pl_address;
--
--
--
PROCEDURE create_pl_address (p_style        IN VARCHAR2,
                            p_address_type            VARCHAR2,
                            p_date_from               DATE,
                            p_date_to                 DATE,
                            p_person_id               NUMBER,
                            p_address_line1       IN VARCHAR2,
                            p_address_line2       IN VARCHAR2,
				    p_pradd_ovlapval_override       in     boolean        --Added for Bug 4210646
                           )
IS
BEGIN
    --
  /* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'PL') THEN
   hr_utility.trace('PL not installed.Leaving create_pl_address');
   return;
END IF;
    IF  p_style = 'PL' THEN
            per_pl_address.check_pl_address(
                            p_address_ID              => NULL ,
                            p_address_type            => p_address_type,
                            p_date_from               => p_date_from ,
                            p_date_to                 => p_date_to ,
                            p_person_id               => p_person_id,
                            p_address_line1           => p_address_line1,
                            p_address_line2           => p_address_line2,
					p_pradd_ovlapval_override => p_pradd_ovlapval_override);    --Added for Bug 4210646
    END IF;
    --
END create_pl_address;
--
--
PROCEDURE update_pl_address (p_address_id   IN NUMBER,
                            p_address_type            VARCHAR2,
                            p_date_from               DATE,
                            p_date_to                 DATE,
                            p_address_line1       IN VARCHAR2,
                            p_address_line2       IN VARCHAR2)
IS
    --
    CURSOR get_style(p_address_id number) is
    SELECT style,person_id
    FROM   per_addresses
    WHERE  address_id=p_address_id;
    --
    l_style     per_addresses.style%TYPE;
    l_person_id    per_addresses.person_id%TYPE;
    --
BEGIN
    --
  /* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'PL') THEN
   hr_utility.trace('PL not installed.Leaving update_pl_address');
   return;
END IF;
		OPEN get_style(p_address_id);
		FETCH get_style INTO l_style,l_person_id;
		CLOSE get_style;
		IF  l_style='PL' THEN
            per_pl_address.check_pl_address(
                            p_address_ID              => p_address_id ,
                            p_address_type            => p_address_type,
                            p_date_from               => p_date_from ,
                            p_date_to                 => p_date_to ,
                            p_person_id               => l_person_id ,
                            p_address_line1           => p_address_line1,
                            p_address_line2           => p_address_line2,
					p_pradd_ovlapval_override => null);     --Added for Bug 4210646
		END IF;

    --
END update_pl_address;
--

PROCEDURE update_pl_address_style(p_address_id   IN NUMBER,
                            p_style             IN VARCHAR2,
                            p_address_type            VARCHAR2,
                            p_date_from               DATE,
                            p_date_to                 DATE,
                            p_address_line1       IN VARCHAR2,
                            p_address_line2       IN VARCHAR2)
IS
    --
    l_person_id    per_addresses.person_id%TYPE;
    --
BEGIN
    --
  /* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'PL') THEN
   hr_utility.trace('PL not installed.Leaving update_pl_address_style');
   return;
END IF;
          IF  p_style='PL' THEN
            per_pl_address.check_pl_address(
                            p_address_ID              => p_address_id ,
                            p_address_type            => p_address_type,
                            p_date_from               => p_date_from ,
                            p_date_to                 => p_date_to ,
                            p_person_id               => l_person_id ,
                            p_address_line1           => p_address_line1,
                            p_address_line2           => p_address_line2,
					p_pradd_ovlapval_override => null);             --Added for Bug 4210646
          END IF;
    --
END update_pl_address_style;
--

END per_pl_address;

/
