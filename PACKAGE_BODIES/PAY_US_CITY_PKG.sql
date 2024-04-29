--------------------------------------------------------
--  DDL for Package Body PAY_US_CITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_CITY_PKG" as
/* $Header: pyusukno.pkb 120.1 2005/08/17 09:48:12 rmonge noship $ */
 /*===========================================================================+
 |               Copyright (c) 1995 Oracle Corporation                        |
 |                       All rights reserved.                                 |
 +============================================================================+
  Name
   pay_us_city_pkg
  Purpose
	Supports the city block in the form pyusukcy (US CITIES).
  Notes

  History
    25-AUG-95  F. Assadi   40.0         Date created.
    03-Dec-97  K.Mundair   40.4(110.1)  Bug 509120. Added functionality
					to allow zip codes to be entered
					via the form and to allow city names
					and zip ranges existing in one
					county to be entered into another.
    17-Sep-01  ptitoren    115.2        Added explicit list of columns
                                        to insert statements.
    15-Jan-03  ssouresr    115.3        Allow values for the new column disable
                                        to be inserted/updated
    18-mar-03  rmonge     115.4         Modified the chk_city_in_addr procedure
                                        to display a more descriptive error
                                        message. The new message has been
                                       created for this purpose, since the old
                                       or generic message did not explain
                                       what the problem is.
    26-Nov-03  ssattini  115.5         Modified the create_unkn_city procedure
                                       to use initcap when validating the
                                       county_name.  Fix for bug#3262647.
    29-Jan-04  kvsankar    115.8        Modified queries for cursor C1 and
                                        cursor C2 in PROCEDURE 'chk_city_in_addr'
                                        for performance enhancement
                                        (Bug No. 3346024)
    29-Jan-04  kvsankar    115.9        Corrected queries for cursor C1 and
                                        cursor C2 in PROCEDURE 'chk_city_in_addr'
                                        for compilation errors.
                                        (Bug No. 3346024)

   12-Aug-05  rmonge       115.10       City Form enhacement.  As part of the
                                        geocode enhacement project, this
                                        package has been modified to include
                                        a new procedure create_new_geocode.
                                        The new procedure is called from
                                        the cities form allowing the user
                                        to insert a brand new valid geocode
                                        as per Vertex monthly updates.
                                        The procedure create_new_geocode
                                        checks if the geocode does not
                                        exist and inserts it.
                                        If the geocode does not exists, it
                                        first checks for an existing city
                                        name in the same state and county.
                                        And, if there are no other city name
                                        the same, then, it inserts the geocode
                                        If the geocode exist, then, it checks
                                        if the city name exists. If the
                                        geocode exist with a different city
                                        name, the geocode is inserted as
                                        a secondary city.


 ============================================================================*/
--
/*
--
   USAGE
      This is called from a form that allows the user to enter
      information about the unknown city to be created.
--
   DESCRIPTION
      Used to create an unknown city in the table structure set up
      for the state, county, and city geocodes and corresponding
      zip codes.
*/
--

   PROCEDURE local_error(p_error_mesg	varchar2,
			 p_procedure	varchar2,
                         p_step		number) IS
   BEGIN

      hr_utility.set_message(801, p_error_mesg);
      hr_utility.set_message_token('PROCEDURE', 'pyusukno.'||p_procedure);
      hr_utility.set_message_token('STEP', p_step);
      hr_utility.raise_error;

   END local_error;

--------------------------------------------------------------------------
 -- Name                                                                    --
 --   Create_new_geocode
 -- Added by Rmonge
 -- Enhacement to allow a user to insert a new geocode.
 -- Purpose                                                                 --
 --   Procedure that supports the insert of a new geocode via the city form
 -- Notes                                                                   --
 --                                                                         --
 -----------------------------------------------------------------------------
--
 PROCEDURE Create_new_geocode (p_city_code       IN OUT  NOCOPY  VARCHAR2,
		      p_zprowid		IN OUT	NOCOPY  VARCHAR2,
		      p_cirowid		IN OUT	NOCOPY  VARCHAR2,
		      p_gerowid		IN OUT	NOCOPY  VARCHAR2,
		      p_state_code			VARCHAR2,
		      p_county_code			VARCHAR2,
		      p_state_name			VARCHAR2,
		      p_county_name			VARCHAR2,
		      p_city_name			VARCHAR2,
		      p_zip_start			VARCHAR2,
		      p_zip_end				VARCHAR2,
		      p_disable				VARCHAR2
							) is

--  Define Local Variables to hold local information

            l_zip_start       pay_us_zip_codes.zip_start%TYPE;
            l_zip_end         pay_us_zip_codes.zip_end%TYPE;
            l_st_code         pay_us_states.state_code%TYPE;
            l_st_abbrev       pay_us_states.state_abbrev%TYPE;
            l_state_Name      pay_us_states.state_name%TYPE;
            l_county_code     pay_us_counties.county_code%TYPE;
            l_county_Name     pay_us_counties.county_name%TYPE;
            l_city_code       pay_us_city_names.city_code%TYPE;
            l_city_Name       pay_us_city_names.city_name%TYPE;
            lv_city_Name      pay_us_city_names.city_name%TYPE;

            lv_found          varchar2(1);
            lv_new_geo        varchar2(1);



   BEGIN
         -- Add the following to make sure the Names are initcap

         l_state_Name  := initcap(p_state_name);
         l_county_Name := initcap(p_county_name);
         l_city_Name   := initcap(p_city_name);

         lv_new_geo    := 'N';
/* get state, county and city codes. */

         BEGIN
            select state_code, state_abbrev
            into l_st_code, l_st_abbrev
            from pay_us_states
            where state_name = l_state_Name;

         EXCEPTION WHEN no_data_found THEN
            hr_utility.trace ('Error:  Failed to find state codes.');
            local_error ('HR_7952_ADDR_NO_STATE_CODE', 'create_new_geocode', 1);

         END ;

         BEGIN
              select county_code
              into l_county_code
              from pay_us_counties
              where state_code = l_st_code
              and initcap(county_name) = l_county_Name;

         EXCEPTION WHEN no_data_found THEN
              hr_utility.trace ('Error:  Failed to find county codes.');
              local_error ('HR_7953_ADDR_NO_COUNTY_FOUND', 'create_new_geocode', 2);

         END;

         BEGIN
              select city_code
              into   l_city_code
              from   pay_us_city_geocodes
              where  state_code = l_st_code
              and    county_code = l_county_code
              and    city_code = p_city_code;

         EXCEPTION
                  WHEN NO_DATA_FOUND THEN
              lv_found := 'N';

         END ;


         IF SQL%NOTFOUND THEN

             /* City Code does not exist */
             /* Check to see if there is another city name */
             /* exactly the same in the same state and county */
             /* if the same name if found, then, we have to raise */
             /* an error as this will cause a problem with tax  */
             /* records  */
             BEGIN

             lv_new_geo := 'N';


             select city_name
             into lv_city_name
             from pay_us_city_names
             where state_code= l_st_code
             and   county_code = l_county_code
             and   city_name  = l_city_name;

             EXCEPTION WHEN NO_DATA_FOUND THEN
                      lv_new_geo := 'Y' ;
             END ;

             IF lv_new_geo ='Y'  THEN

                  insert into pay_us_city_geocodes
                  (state_code,
                   county_code,
                   city_code)
                  values
                  (l_st_code,
                   l_county_code,
                   p_city_code);

                   insert into pay_us_city_names
                   (city_name,
                    state_code,
                    county_code,
                    city_code,
                    primary_flag,
                    disable)
                   values
                   (l_city_Name,
                    l_st_code,
                    l_county_code,
                    p_city_code,
                    'Y',
                    p_disable);


                    insert into pay_us_zip_codes
                    (zip_start,
                     zip_end,
                     state_code,
                     county_code,
                     city_code)
                    values
                    (p_zip_start,
                     p_zip_end,
                     l_st_code,
                     l_county_code,
                     p_city_code);
             ELSE    /* lv_new_geo = 'N' */
            /* Display a more meaningful error here */
                   hr_utility.trace ('Error:  Given city is already created.');
                  local_error ('PAY_DUPL_CITY_NAME', 'create_new_geocode', 3);
             END IF;

          ELSE
            /* insert it as a secondary city if the city_name does not
               exist already */
            /* We only need to insert into pay_us_city_names */
            /* as the geocode already exist*/
              BEGIN

                  select city_name
                  into   lv_city_name
                  from   pay_us_city_names
                  where  state_code = l_st_code
                  and    county_code = l_county_code
                  and    city_code   = p_city_code
                  and    city_name   = l_city_Name ;

              EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                       lv_found := 'N';
              END;

              IF SQL%NOTFOUND THEN

                   insert into pay_us_city_names
                     (city_name,
                     state_code,
                     county_code,
                     city_code,
                     primary_flag,
                     disable)
                     values
                     (l_city_Name,
                      l_st_code,
                      l_county_code,
                      l_city_code,
                      'N',
                      p_disable);


             ELSE
                  hr_utility.trace ('Error:  Given city is already created.');
                  local_error ('PAY_DUPL_CITY_NAME', 'create_new_geocode', 4);
             END IF; /* SQL NOT FOUND */
        END IF; /* not found  */
  END   create_new_geocode ;



   PROCEDURE create_unkn_city (p_ci_code    IN OUT NOCOPY varchar2,
			       p_st_name 	IN varchar2,
	  	   	       p_co_name 	IN varchar2,
			       p_ci_name 	IN varchar2,
			       p_zi_start   IN OUT NOCOPY varchar2,
                               p_zi_end     IN OUT NOCOPY varchar2,
                               p_disable        IN varchar2) 	IS

      l_n_ci_code	number := 0;
      l_max_ci_code	number := 0;
      l_n_ci_name	number := 0;

      l_zip_start	pay_us_zip_codes.zip_start%TYPE;
      l_zip_end		pay_us_zip_codes.zip_end%TYPE;
      l_st_code		pay_us_states.state_code%TYPE;
      l_st_abbrev	pay_us_states.state_abbrev%TYPE;
      l_stateName	pay_us_states.state_name%TYPE;
      l_co_code		pay_us_counties.county_code%TYPE;
      l_countyName	pay_us_counties.county_name%TYPE;
      l_ci_code		pay_us_city_names.city_code%TYPE;
      l_cityName	pay_us_city_names.city_name%TYPE;

      CURSOR c_city_code IS
         select city_code
            from pay_us_city_geocodes
            where state_code = l_st_code and county_code = l_co_code
            and city_code like 'U%';

      CURSOR zip_exist_c IS
    	SELECT  zc.state_code,
           	zc.county_code,
           	zc.city_code,
           	zc.zip_start,
           	zc.zip_end
    	FROM   pay_us_zip_codes zc
    	WHERE  zc.state_code = l_st_code
	AND    zc.county_code = l_co_code
    	AND    zc.city_code = l_ci_code
    	AND    (l_zip_start BETWEEN zc.zip_start AND zc.zip_end
    	OR     l_zip_end BETWEEN zc.zip_start AND zc.zip_end
	OR     zc.zip_start BETWEEN l_zip_start AND l_zip_end
    	OR     zc.zip_end BETWEEN l_zip_start AND l_zip_end);

  	zip_exist_rec   zip_exist_c%ROWTYPE;

   BEGIN

   /* force case of all passed-in parameters to match that stored in DB. */

      hr_utility.trace ('County Name: '||p_co_name);
      hr_utility.trace ('State Name: '||p_st_name);

      l_stateName  := initcap(p_st_name);
      l_countyName := initcap(p_co_name);
      l_cityName   := initcap(p_ci_name);

      hr_utility.trace ('County name after initcap :'||l_countyName);
      hr_utility.trace ('State name after initcap :'||l_stateName);
   /* get state, county and city codes. */

      BEGIN
         select state_code, state_abbrev
            into l_st_code, l_st_abbrev
            from pay_us_states
            where state_name = l_stateName;

      EXCEPTION WHEN no_data_found THEN
         hr_utility.trace ('Error:  Failed to find state codes.');
         local_error ('HR_7952_ADDR_NO_STATE_CODE', 'create_unkn_city', 1);
      END;

      hr_utility.trace ('selected state code: ' || l_st_code);
      hr_utility.trace ('l_countyName: ' || l_countyName);

      BEGIN
         select county_code
            into l_co_code
            from pay_us_counties
            where state_code = l_st_code
            and initcap(county_name) = l_countyName;

      EXCEPTION WHEN no_data_found THEN
         hr_utility.trace ('Error:  Failed to find county codes.');
         local_error ('HR_7953_ADDR_NO_COUNTY_FOUND', 'create_unkn_city', 2);
      END;

      hr_utility.trace ('selected county code: ' || l_co_code);

   /* see if this city is unknown. */

      if hr_us_ff_udfs.addr_val(l_st_abbrev, l_countyName, l_cityName,
                                p_zi_start,'Y') = '00-000-0000' then
      /*
         check for an existing city whose zip codes are wrong or
         altered, which addr_val would still return '00-000-0000'.
      */
         l_n_ci_name := -1;
	 BEGIN
            select city_code
            into l_ci_code
            from pay_us_city_names
            where city_name = l_cityName and county_code = l_co_code and
            state_code = l_st_code;
         EXCEPTION
	    WHEN no_data_found THEN l_n_ci_name := 0;
	    WHEN others THEN l_n_ci_name := 1;
	 END;

         if l_n_ci_name = 0 then

         /* get number of unknown cities previous entered. */
            select count(city_code)
               into l_n_ci_code
               from pay_us_city_geocodes
               where state_code = l_st_code and county_code = l_co_code
               and city_code like 'U%';

            hr_utility.trace ('Number of unknown cities '||l_n_ci_code);

            if l_n_ci_code <= 0 then
               l_ci_code := 'U000';
               hr_utility.trace ('Initial city code is:'||l_ci_code);
            else
            /*
               use explicit cursor to step through each of the unknown
               city codes to find the latest city code.
            */
               for l_city_rec in c_city_code loop

                  if fnd_number.canonical_to_number(substr(l_city_rec.city_code,2,3)) >
                     l_max_ci_code then

                     l_max_ci_code :=
                        fnd_number.canonical_to_number(substr(l_city_rec.city_code,2,3));
                     hr_utility.trace ('Max city code is:'||
                                       l_city_rec.city_code);

                  end if;
               end loop;

               if l_max_ci_code >= 0 and l_max_ci_code < 9 then
                  l_ci_code := 'U00'||to_char(l_max_ci_code + 1);
               elsif l_max_ci_code >= 9 and l_max_ci_code < 99 then
                  l_ci_code := 'U0'||to_char(l_max_ci_code + 1);
               else
                  l_ci_code := 'U'||to_char(l_max_ci_code + 1);
               end if;

               hr_utility.trace ('Final city code is:'||l_ci_code);
            end if;
	    p_ci_code := l_ci_code;

            insert into pay_us_city_geocodes
                (state_code, county_code, city_code)
              values
                (l_st_code, l_co_code, l_ci_code);
            hr_utility.trace ('Inserted a geocode.');

            insert into pay_us_zip_codes
                (zip_start, zip_end, state_code, county_code, city_code)
              values
                (p_zi_start, p_zi_end, l_st_code, l_co_code, l_ci_code);
            hr_utility.trace ('Inserted a zip code.');

            insert into pay_us_city_names
               (city_name, state_code, county_code, city_code, primary_flag, disable)
              values
               (l_cityName, l_st_code, l_co_code, l_ci_code, 'N', p_disable);
            hr_utility.trace ('Inserted an unknown city.');

         elsif (l_n_ci_name = 1) then
            hr_utility.trace ('Error:  Given city is already created.');
            local_error ('HR_7954_ADDR_NOT_UNKNOWN_CITY',
                         'create_unkn_city', 3);
         else
	    /* a new zip range for an existing city has been entered */
      	    l_zip_end := p_zi_end;
      	    l_zip_start := p_zi_start;

  	    OPEN zip_exist_c;
  	    LOOP
    	    FETCH zip_exist_c INTO zip_exist_rec;
    	    EXIT WHEN zip_exist_c%NOTFOUND;
    	    IF zip_exist_rec.zip_start < l_zip_start THEN
      	      l_zip_start := zip_exist_rec.zip_start;
            END IF;
    	    IF zip_exist_rec.zip_end > l_zip_end THEN
      	      l_zip_end := zip_exist_rec.zip_end;
    	    END IF;

    	    DELETE FROM pay_us_zip_codes
    	    WHERE  zip_start = zip_exist_rec.zip_start
    	    AND    zip_end = zip_exist_rec.zip_end
    	    AND    state_code = zip_exist_rec.state_code
    	    AND    county_code = zip_exist_rec.county_code
    	    AND    city_code = zip_exist_rec.city_code;

  	    END LOOP;
  	    CLOSE zip_exist_c;

    	    INSERT INTO pay_us_zip_codes
     	    (ZIP_START, ZIP_END, STATE_CODE, COUNTY_CODE, CITY_CODE)
     	    VALUES
     	    (l_zip_start,l_zip_end,l_st_code,l_co_code,l_ci_code);
            hr_utility.trace ('Inserted a new zip code for an existing city.');

	    p_ci_code := l_ci_code;
      	    p_zi_end := l_zip_end;
      	    p_zi_start := l_zip_start;

            /* In case the user is also updating the disable flag as well as
               entering a new zip range for an existing city */

            UPDATE pay_us_city_names
            SET disable = p_disable
            WHERE city_name   = l_cityName
            AND   city_code   = l_ci_code
            AND   county_code = l_co_code
            AND   state_code  = l_st_code;

         end if;
      else
         hr_utility.trace ('Error:  Given city is already created.');
         local_error ('HR_7954_ADDR_NOT_UNKNOWN_CITY', 'create_unkn_city', 4);
      end if;

  END create_unkn_city;
--------------------------------------------------------------------------
 -- Name                                                                    --
 --   Insert_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert of a new city via    --
 --   the  city form.                                                 --
 -- Notes                                                                   --
 --                                                                         --
 -----------------------------------------------------------------------------
--
 PROCEDURE Insert_Row(p_city_code       IN OUT  NOCOPY  VARCHAR2,
		      p_zprowid		IN OUT	NOCOPY  VARCHAR2,
		      p_cirowid		IN OUT	NOCOPY  VARCHAR2,
		      p_gerowid		IN OUT	NOCOPY  VARCHAR2,
		      p_state_code			VARCHAR2,
		      p_county_code			VARCHAR2,
		      p_state_name			VARCHAR2,
		      p_county_name			VARCHAR2,
		      p_city_name			VARCHAR2,
		      p_zip_start			VARCHAR2,
		      p_zip_end				VARCHAR2,
		      p_disable				VARCHAR2
							) is

--
--
--
 l_zip_start  pay_us_zip_codes.zip_start%TYPE;
 l_zip_end  pay_us_zip_codes.zip_end%TYPE;

 CURSOR C IS SELECT rowid FROM pay_us_zip_codes
 WHERE state_code = p_state_code
 AND   county_code= p_county_code
 AND   city_code  = p_city_code
 AND   zip_start  = l_zip_start
 AND   zip_end	  = l_zip_end;
--
 CURSOR C2 is SELECT rowid from pay_us_city_names
 WHERE state_code = p_state_code
 AND   county_code= p_county_code
 AND   city_code  = p_city_code
 AND   city_name  = p_city_name;
--
 CURSOR C3 is SELECT rowid from pay_us_city_geocodes
 WHERE state_code = p_state_code
 AND   county_code= p_county_code
 AND   city_code  = p_city_code;

--
 BEGIN
--
/* hr_utility.trace_on('Y','CACITY');*/
 l_zip_start := p_zip_start;
 l_zip_end := p_zip_end;

 create_unkn_city (p_city_code,
 		   p_state_name,
		   p_county_name,
                   p_city_name,
		   l_zip_start,
                   l_zip_end,
                   p_disable);
--
OPEN C;
FETCH C INTO  p_zprowid;
IF (C%NOTFOUND) THEN
     CLOSE C;
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'pay_us_city_pkg.Insert_Row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
END if;

--
OPEN C2;
FETCH C2 INTO  p_cirowid;
IF (C2%NOTFOUND) THEN
     CLOSE C2;
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'pay_us_city_pkg.Insert_Row');
     hr_utility.set_message_token('STEP','2');
     hr_utility.raise_error;
END if;

--
OPEN C3;
FETCH C3 INTO  p_gerowid;
IF (C3%NOTFOUND) THEN
     CLOSE C3;
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'pay_us_city_pkg.Insert_Row');
     hr_utility.set_message_token('STEP','3');
     hr_utility.raise_error;
END if;

/* hr_utility.trace_off; */
END Insert_Row;

 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Lock_Row                                                              --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the update and delete           --
 --   of a city by applying a lock on a city block in City Form.            --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Lock_Row(  p_zprowid                         VARCHAR2,
		      p_cirowid				VARCHAR2,
		      p_gerowid				VARCHAR2,
		      p_state_code		        VARCHAR2,
		      p_county_code		        VARCHAR2,
		      p_city_code			VARCHAR2,
		      p_state_name			VARCHAR2,
		      p_county_name			VARCHAR2,
		      p_city_name			VARCHAR2,
		      p_zip_start			VARCHAR2,
		      p_zip_end				VARCHAR2) IS
--
   CURSOR C IS SELECT * FROM  pay_us_zip_codes
               WHERE  rowid = p_zprowid FOR UPDATE of zip_start NOWAIT ;
--
   CURSOR C2 IS SELECT * FROM pay_us_city_names
	       WHERE rowid = p_cirowid FOR UPDATE OF  city_name NOWAIT;
--
   CURSOR C3 IS SELECT * FROM pay_us_city_geocodes
                WHERE rowid = p_gerowid FOR UPDATE of City_code NOWAIT;
--
   l_recinfo 	C%ROWTYPE;
   l_recinfo2 	C2%ROWTYPE;
   l_recinfo3	C3%ROWTYPE;
--
 BEGIN
--
   OPEN C;
   FETCH C INTO l_recinfo;
   if (C%NOTFOUND) then
     CLOSE C;
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'pay_us_city_pkg.lock_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
--
   OPEN C2;
   FETCH C2 INTO l_recinfo2;
   if (C2%NOTFOUND) then
     CLOSE C2;
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'pay_us_city_pkg.lock_row');
     hr_utility.set_message_token('STEP','2');
     hr_utility.raise_error;
   end if;
--
   OPEN C3;
   FETCH C3 INTO l_recinfo3;
   if (C3%NOTFOUND) then
     CLOSE C3;
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'pay_us_city_pkg.lock_row');
     hr_utility.set_message_token('STEP','3');
     hr_utility.raise_error;
   end if;

--
   -- Remove trailing spaces.
   l_recinfo.state_code		:= rtrim(l_recinfo.state_code);
   l_recinfo.county_code 	:= rtrim(l_recinfo.county_code);
   l_recinfo.city_code 		:= rtrim(l_recinfo.city_code);
   l_recinfo.zip_start 		:= rtrim(l_recinfo.zip_start);
   l_recinfo.zip_end 		:= rtrim(l_recinfo.zip_end);
--
   l_recinfo2.state_code	:= rtrim(l_recinfo2.state_code);
   l_recinfo2.county_code 	:= rtrim(l_recinfo2.county_code);
   l_recinfo2.city_code 	:= rtrim(l_recinfo2.city_code);
   l_recinfo2.city_name		:= rtrim(l_recinfo2.city_name);
--
        IF ( (   (l_recinfo.zip_start = p_zip_start)
            OR (    (l_recinfo.zip_start IS NULL)
                AND (p_zip_start IS NULL)))
       AND (   (l_recinfo.zip_end = p_zip_end)
            OR (    (l_recinfo.zip_end IS NULL)
                AND (p_zip_end IS NULL)))
       AND (   (l_recinfo2.city_name = p_city_name)
            OR (    (l_recinfo2.city_name IS NULL)
                AND (p_city_name IS NULL)))
           ) then
     return;
   else
     FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
     APP_EXCEPTION.RAISE_EXCEPTION;
   end if;
--
 END Lock_Row;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Update_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the update of a city via        --
 --   the  city form.                                                       --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Update_Row(p_zprowid                         VARCHAR2,
		      p_zip_start			VARCHAR2,
		      p_zip_end				VARCHAR2,
                      p_state_code                      VARCHAR2,
                      p_county_code                     VARCHAR2,
                      p_city_code                       VARCHAR2,
                      p_city_name                       VARCHAR2,
                      p_disable                         VARCHAR2) IS
 BEGIN
--
-- The appropriate tables need to be locked during the updating process.
--
--
   UPDATE pay_us_zip_codes
   SET 	zip_start		=    p_zip_start,
	zip_end			=    p_zip_end
   WHERE rowid = p_zprowid;
--
   if (SQL%NOTFOUND) then
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'pay_us_new_cities_pkg.update_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
--
   UPDATE pay_us_city_names
   SET 	disable	    = p_disable
   WHERE state_code  = p_state_code
   AND   county_code = p_county_code
   AND   city_code   = p_city_code
   AND   city_name   = p_city_name;
--
   if (SQL%NOTFOUND) then
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'pay_us_new_cities_pkg.update_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
--
 END Update_Row;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Delete_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the delete of a city via        --
 --   the create city form.                                                 --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -----------------------------------------------------------------------------
--
 PROCEDURE Delete_Row(p_zprowid VARCHAR2,
		      p_cirowid VARCHAR2,
		      p_gerowid VARCHAR2) IS
--

zip_counter NUMBER;

 BEGIN
--
--
--
-- Deleting from the pay_us_zip_codes table.
--
   DELETE FROM pay_us_zip_codes
   WHERE  rowid = p_zprowid;

   SELECT count(a.zip_start)
   INTO zip_counter
   FROM  pay_us_zip_codes a,
	 pay_us_city_names b
   WHERE b.rowid = p_cirowid
   AND   a.city_code = b.city_code
   AND   a.county_code = b.county_code
   AND   a.state_code = b.state_code;

   IF (zip_counter = 0) THEN
--
--   Deleting from the pay_us_city_names
--
     DELETE FROM pay_us_city_names
     WHERE rowid = p_cirowid;
--
--   Deleting from the pay_us_city_geocodes
--
     DELETE FROM pay_us_city_geocodes
     WHERE  rowid = p_gerowid;

   END IF;
--
   if (SQL%NOTFOUND) then
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'pay_us_city_pkg.delete_row');
     hr_utility.set_message_token('STEP','3');
     hr_utility.raise_error;
   end if;
 END Delete_Row;
--
-- The Next procedure is used for checking and validating data
--
------------------------------------------------------------------------------
-- Name
--    chk_city_in_addr
-- Purpose
--    To check a given city exists in the per_addresses table
--    It would not allow the city to be deleted if it is referenced in
--    the per_addresses table. Validation check to prevent deletion
--    if city is referenced.
-- Notes
-- This only confirms the existence of a city in the per_addresses
-- table if and only if the city within an state and county
-- matches to that of the per_addresses table.
------------------------------------------------------------------------------
PROCEDURE chk_city_in_addr(p_state_abbrev	VARCHAR2,
		       	   p_county_name	VARCHAR2,
			   p_city_name		VARCHAR2) IS
--
l_prov_abbrev  varchar2(5);

/*Modified query for performance enhancement Bug No. 3346024 */
CURSOR C1 is SELECT 'x'
FROM dual
where exists(
SELECT  region_1,town_or_city
FROM    per_addresses
WHERE   region_1     = l_prov_abbrev
AND     town_or_city = p_city_name
AND     ROWNUM < 2);

/*Modified query for performance enhancement Bug No. 3346024 */
CURSOR C2 is SELECT 'x'
FROM dual
where exists(
SELECT  region_1,region_2,town_or_city
-- Note that in per_addresses table town_or_city, region 2 and region 1
-- are refered to as
-- city name, state abbreviation and county name respectively.
FROM	per_addresses
WHERE	region_2 = p_state_abbrev
AND	region_1 = p_county_name
AND	town_or_city = p_city_name
AND     ROWNUM < 2);

l_recinfo1     C1%ROWTYPE;
l_recinfo2     C2%ROWTYPE;
--
BEGIN

/* If we are dealing with a Canadian city then region_2 is ignored
   because it is not populated */

  IF p_state_abbrev = 'CN' THEN

       SELECT county_abbrev
       INTO  l_prov_abbrev
       FROM  pay_us_counties
       WHERE county_name = p_county_name
       AND   state_code = '70';

       OPEN C1;
       FETCH C1 INTO l_recinfo1;
       IF (C1%FOUND) THEN
        /* rosie monge 18-mar-03 2844658 */
        /*
         hr_utility.set_message (801,'HR_6153_all_PROCEDURE_FAIL');
         hr_utility.set_message_token ('PROCEDURE',
				  'pay_us_chk_addr_pkg.chk_city_in_addr');
         hr_utility.set_message_token ('STEP', '1');
        */
         hr_utility.set_message(801,'PAY_74153_CITY_CANNOT_DISABLE');
         hr_utility.raise_error;
       END IF;
       CLOSE C1;

  ELSE
       OPEN C2;
       FETCH C2 INTO l_recinfo2;
       IF (C2%FOUND) THEN
/* rmonge  fix for bug 2844658   */
        /*
         hr_utility.set_message (801,'HR_6153_all_PROCEDURE_FAIL');
         hr_utility.set_message_token ('PROCEDURE',
                                  'pay_us_chk_addr_pkg.chk_city_in_addr');
         hr_utility.set_message_token ('STEP', '1');
         */
         hr_utility.set_message(801,'PAY_74153_CITY_CANNOT_DISABLE');
         hr_utility.raise_error;
       END IF;
       CLOSE C2;

  END IF;

  RETURN;

END chk_city_in_addr;

END PAY_US_CITY_PKG;

/
