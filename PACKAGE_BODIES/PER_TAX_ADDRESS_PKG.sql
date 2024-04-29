--------------------------------------------------------
--  DDL for Package Body PER_TAX_ADDRESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_TAX_ADDRESS_PKG" AS
/* $Header: peaddovr.pkb 120.2 2006/04/13 11:27:04 saikrish noship $ */

	PROCEDURE address_overide(p_person_id 		IN NUMBER,
				p_date_from 		IN DATE,
				p_overide_city 	 OUT NOCOPY VARCHAR2,
				p_overide_county  OUT NOCOPY VARCHAR2,
				p_overide_state	  OUT NOCOPY VARCHAR2,
				p_overide_zip	  OUT NOCOPY VARCHAR2)
  	IS
            	l_date 		DATE;
		l_last_date 	DATE;
		l_city		VARCHAR2(30);
		l_county	VARCHAR2(30);
		l_state		VARCHAR2(30);
		l_zip		VARCHAR2(30);
--
	BEGIN
hr_utility.set_location(' per_tax_address_pkg.address_overide',10);
-- 		Get overide date and last input date.
		----------------------------------------
		l_date := TO_DATE('01/01/' || (TO_CHAR(p_date_from, 'YYYY')),'DD/MM/YYYY');
		SELECT 	MAX(date_from) INTO l_last_date
		FROM per_addresses_v
		WHERE person_id = p_person_id AND
                      primary_flag = 'Y' AND
                      date_from <= p_date_from;
		      --l_last_date := to_date('01-APR-2006','DD-MON-YYYY');
hr_utility.set_location(' l_last_date -> '||l_last_date,20);
hr_utility.set_location(' p_person_id -> '||p_person_id,30);
hr_utility.set_location(' p_date_from -> '||p_date_from,40);
hr_utility.set_location(' l_date -> '||l_date,50);
--		 Get overide data
		-------------------------
		--l_last_date IS NOT NULL AND
	IF  l_date < l_last_date THEN -- WWBUG#2441642
hr_utility.set_location(' l_city -> '|| l_city, 45);
		SELECT
			NVL(add_information18,''),
			NVL(add_information19,''),
			NVL(add_information17,''),
			NVL(add_information20,'')
		INTO 	l_city, l_county, l_state, l_zip
		FROM per_addresses_v
		WHERE  person_id = p_person_id AND
                       primary_flag = 'Y' AND
		       date_from = (SELECT max(date_from)
				FROM per_addresses_v
				WHERE date_from BETWEEN l_date AND p_date_from AND
					person_id = p_person_id AND
                                        primary_flag = 'Y');
hr_utility.set_location(' l_city -> '|| l_city, 60);
hr_utility.set_location(' l_county -> '|| l_county, 70);
hr_utility.set_location(' l_state -> '|| l_state, 80);
        ELSE
hr_utility.set_location(' l_state -> '|| l_state, 85);
		SELECT
			town_or_city,
			region_1,
			region_2,
			postal_code
		INTO 	l_city, l_county, l_state, l_zip
		FROM 	per_addresses_v
		WHERE  	person_id = p_person_id AND
                        primary_flag = 'Y' AND
			l_date BETWEEN date_from AND
			NVL(date_to, TO_DATE('31/12/4712', 'DD/MM/YYYY'));

hr_utility.set_location(' l_city -> '|| l_city, 90);
hr_utility.set_location(' l_county -> '|| l_county, 100);
hr_utility.set_location(' l_state -> '|| l_state, 110);

 	END IF;
        IF l_state <> 'IN' THEN
		p_overide_city 		:=	'';
		p_overide_county 	:=	'';
		p_overide_state	 	:=	'';
		p_overide_zip	 	:=	'';
        ELSE
		p_overide_city 		:=	l_city;
		p_overide_county 	:=	l_county;
		p_overide_state	 	:=	l_state;
		p_overide_zip	 	:=	l_zip;
        END IF;
--
        EXCEPTION

          WHEN NO_DATA_FOUND THEN
		p_overide_city 		:=	'NO DATA';
		p_overide_county 	:=	'NO DATA';
		p_overide_state	 	:=	'NO DATA';
		p_overide_zip	 	:=	'NO DATA';
hr_utility.set_location('exception l_state -> '|| l_state, 130);
    END address_overide;
--
      FUNCTION    overide_tax_state(p_person_id NUMBER, p_date_from DATE)
			RETURN VARCHAR2
	IS
          l_chk_date            VARCHAR2(30);
	  l_date 		DATE;
	  l_state		VARCHAR2(30);
          CURSOR c_new_entry IS
            SELECT 'N' FROM per_addresses_v
            WHERE person_id = p_person_id AND
                  date_from IS NOT NULL;

           CURSOR c_state(p_person_id IN NUMBER,p_date IN DATE) IS
        	SELECT  region_2
                FROM    per_addresses_v
                WHERE   person_id = p_person_id
                 AND    primary_flag = 'Y'
                 AND    p_date BETWEEN date_from
                 AND    NVL(date_to, TO_DATE('31/12/4712', 'DD/MM/YYYY'));

	BEGIN
          hr_utility.set_location('per_tax_address_pkg.overide_tax_state',10);
          hr_utility.set_location('per_tax_address_pkg,p_date_from ->'|| p_date_from,11);
--              Check if the entry is new
                -------------------------
          OPEN c_new_entry;
          FETCH c_new_entry INTO l_chk_date;
          IF c_new_entry%NOTFOUND THEN
            l_state := 'NEW ENTRY';
            CLOSE c_new_entry;
            hr_utility.set_location(' NEW ENTRY ',20);
          ELSE
            CLOSE c_new_entry;
-- 		Get overide date
		-------------------------
	      	l_date := TO_DATE('01/01/' || (TO_CHAR(p_date_from , 'YYYY')),
				'DD/MM/YYYY');
-- 		Get overide data
		-------------------------
		OPEN c_state(p_person_id,l_date);
		FETCH c_state INTO l_state;
		IF c_state%NOTFOUND THEN

                 SELECT region_2
  		  INTO 	l_state
		  FROM 	per_addresses_v
		  WHERE person_id = p_person_id AND
                        primary_flag = 'Y' AND
                        date_from = (SELECT max(date_from)
                                FROM per_addresses_v
                                WHERE date_from >= l_date
				  AND date_from < p_date_from AND
                                        person_id = p_person_id AND
                                        primary_flag = 'Y');

		END IF;
		CLOSE c_state;
           hr_utility.set_location('per_tax_address_pkg.overide_tax_state,l_date ->'||l_date,20);
           hr_utility.set_location('per_tax_address_pkg.overide_tax_stat,l_state ->  '||l_state,30);
           END IF;
           hr_utility.set_location('per_tax_address_pkg.overide_tax_stat,l_state ->  '||l_state,35);
	RETURN l_state;
	EXCEPTION
        WHEN NO_DATA_FOUND THEN
        hr_utility.set_location('per_tax_address_pkg.overide_tax_stat,l_state ->  '||l_state,40);
	RETURN ('NO DATA');
      END overide_tax_state;
END per_tax_address_pkg;

/
