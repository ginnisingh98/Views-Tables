--------------------------------------------------------
--  DDL for Package Body PER_EMPDIR_LEG_OVERRIDE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_EMPDIR_LEG_OVERRIDE" AS
/* $Header: peredlor.pkb 115.2 2003/08/23 03:07 smallina noship $ */

-- ---------------------------------------------------------------------------
-- ---------------------------- < isOverrideEnabled > ------------------------
-- ---------------------------------------------------------------------------

FUNCTION isOverrideEnabled(
        p_entity VARCHAR2
    ) RETURN BOOLEAN IS
BEGIN
    IF p_entity = 'PEOPLE' THEN
        RETURN (g_people_override_flg
          OR per_empdir_people_override.isOverrideEnabled);
    ELSIF p_entity = 'ASSIGNMENTS' THEN
        RETURN (g_asg_override_flg
          OR per_empdir_asg_override.isOverrideEnabled);
    ELSIF p_entity = 'JOBS' THEN
        RETURN (g_jobs_override_flg
          OR per_empdir_jobs_override.isOverrideEnabled);
    ELSIF p_entity = 'ORGANIZATIONS' THEN
        RETURN (g_orgs_override_flg
          OR per_empdir_orgs_override.isOverrideEnabled);
    ELSIF p_entity = 'LOCATIONS' THEN
        RETURN (g_locations_override_flg
          OR per_empdir_locations_override.isOverrideEnabled);
    ELSIF p_entity = 'POSITIONS' THEN
        RETURN (g_positions_override_flg
          OR per_empdir_positions_override.isOverrideEnabled);
    ELSE
        RETURN FALSE;
    END IF;
    EXCEPTION WHEN OTHERS THEN
        RETURN FALSE;
END isOverrideEnabled;

-- ---------------------------------------------------------------------------
-- ---------------------------- < positions > --------------------------------
-- ---------------------------------------------------------------------------

PROCEDURE positions(
        errbuf  OUT NOCOPY VARCHAR2
       ,retcode OUT NOCOPY VARCHAR2
       ,p_eff_date IN DATE
       ,p_cnt IN NUMBER
       ,p_srcSystem IN VARCHAR2) IS
l_flg BOOLEAN:= FALSE;

BEGIN

        l_flg := per_empdir_positions_override.isOverrideEnabled;
        FOR I IN 1 .. p_cnt LOOP

         -- Begin Legislation specific overried code

         -- End Legislation specific overried code

         IF l_flg THEN

         -- Invoking customer override call

            per_empdir_positions_override.before_dml(
                errbuf
               ,retcode
               ,p_eff_date
               ,p_cnt
               ,I
               ,p_srcSystem);

         END IF;
        END LOOP;

    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        per_empdir_ss.write_log(1,
                   'Error in pkg: '||g_package||' proc: positions: '||SQLCODE);
        per_empdir_ss.write_log(1,
                   'Error Msg: '||substr(SQLERRM,1,700));
END positions;

-- ---------------------------------------------------------------------------
-- ---------------------------- < orgs > -------------------------------------
-- ---------------------------------------------------------------------------

PROCEDURE orgs(
        errbuf  OUT NOCOPY VARCHAR2
       ,retcode OUT NOCOPY VARCHAR2
       ,p_eff_date IN DATE
       ,p_cnt IN NUMBER
       ,p_srcSystem IN VARCHAR2) IS
l_flg BOOLEAN:= FALSE;

BEGIN

        l_flg := per_empdir_orgs_override.isOverrideEnabled;
        FOR I IN 1 .. p_cnt LOOP

         -- Begin Legislation specific overried code

         -- End Legislation specific overried code

         IF l_flg THEN

         -- Invoking customer override call

            per_empdir_orgs_override.before_dml(
                errbuf
               ,retcode
               ,p_eff_date
               ,p_cnt
               ,I
               ,p_srcSystem);

         END IF;
        END LOOP;

    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        per_empdir_ss.write_log(1,
              'Error in pkg: '||g_package||' proc: orgs: '||SQLCODE);
        per_empdir_ss.write_log(1,
              'Error Msg: '||substr(SQLERRM,1,700));
END orgs;

-- ---------------------------------------------------------------------------
-- ---------------------------- < jobs > -------------------------------------
-- ---------------------------------------------------------------------------

PROCEDURE jobs(
        errbuf  OUT NOCOPY VARCHAR2
       ,retcode OUT NOCOPY VARCHAR2
       ,p_eff_date IN DATE
       ,p_cnt IN NUMBER
       ,p_srcSystem IN VARCHAR2) IS
l_flg BOOLEAN:= FALSE;

BEGIN

        l_flg := per_empdir_jobs_override.isOverrideEnabled;
        FOR I IN 1 .. p_cnt LOOP

         -- Begin Legislation specific overried code

         -- End Legislation specific overried code

         IF l_flg THEN

         -- Invoking customer override call

            per_empdir_jobs_override.before_dml(
                errbuf
               ,retcode
               ,p_eff_date
               ,p_cnt
               ,I
               ,p_srcSystem);

         END IF;
        END LOOP;

    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        per_empdir_ss.write_log(1,
             'Error in pkg: '||g_package||' proc: jobs: '||SQLCODE);
        per_empdir_ss.write_log(1,
             'Error Msg: '||substr(SQLERRM,1,700));
END jobs;

-- ---------------------------------------------------------------------------
-- ---------------------------- < people > -----------------------------------
-- ---------------------------------------------------------------------------

PROCEDURE people(
        errbuf  OUT NOCOPY VARCHAR2
       ,retcode OUT NOCOPY VARCHAR2
       ,p_eff_date IN DATE
       ,p_cnt IN NUMBER
       ,p_srcSystem IN VARCHAR2) IS
l_flg BOOLEAN:= FALSE;

BEGIN

        l_flg := per_empdir_people_override.isOverrideEnabled;
        FOR I IN 1 .. p_cnt LOOP

         -- Begin Legislation specific overried code

         -- End Legislation specific overried code

         IF l_flg THEN

         -- Invoking customer override call

            per_empdir_people_override.before_dml(
                errbuf
               ,retcode
               ,p_eff_date
               ,p_cnt
               ,I
               ,p_srcSystem);

         END IF;
        END LOOP;

    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        per_empdir_ss.write_log(1,
                'Error in pkg: '||g_package||' proc: people: '||SQLCODE);
        per_empdir_ss.write_log(1,
                'Error Msg: '||substr(SQLERRM,1,700));
END people;

-- ---------------------------------------------------------------------------
-- ---------------------------- < asg > --------------------------------------
-- ---------------------------------------------------------------------------

PROCEDURE asg(
        errbuf  OUT NOCOPY VARCHAR2
       ,retcode OUT NOCOPY VARCHAR2
       ,p_eff_date IN DATE
       ,p_cnt IN NUMBER
       ,p_srcSystem IN VARCHAR2) IS
l_flg BOOLEAN:= FALSE;

BEGIN

        l_flg := per_empdir_asg_override.isOverrideEnabled;
        FOR I IN 1 .. p_cnt LOOP

         -- Begin Legislation specific overried code

         -- End Legislation specific overried code

         IF l_flg THEN

         -- Invoking customer override call

            per_empdir_asg_override.before_dml(
                errbuf
               ,retcode
               ,p_eff_date
               ,p_cnt
               ,I
               ,p_srcSystem);
         END IF;
        END LOOP;

    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        per_empdir_ss.write_log(1,
            'Error in pkg: '||g_package||' proc: asg: '||SQLCODE);
        per_empdir_ss.write_log(1,
            'Error Msg: '||substr(SQLERRM,1,700));
END asg;

-- ---------------------------------------------------------------------------
-- ---------------------------- < locations > --------------------------------
-- ---------------------------------------------------------------------------

PROCEDURE locations(
        errbuf  OUT NOCOPY VARCHAR2
       ,retcode OUT NOCOPY VARCHAR2
       ,p_eff_date IN DATE
       ,p_cnt IN NUMBER
       ,p_srcSystem IN VARCHAR2) IS

-- Local Variables
l_flg BOOLEAN:= FALSE;
l_address   VARCHAR2(2000);
l_style     VARCHAR2(30);

BEGIN

    l_flg := per_empdir_locations_override.isOverrideEnabled;
    FOR I IN 1 .. p_cnt LOOP

         -- Begin Legislation specific overried code

     	IF p_srcSystem = 'PER' THEN

        	l_style := nvl(per_empdir_ss.locationTbl.country(I)
                        ,per_empdir_ss.locationTbl.style(I));

        	IF  (l_style = 'JP') THEN
         		l_address := per_empdir_ss.locationTbl.postal_code(I)||
           		  '<br>'||per_empdir_ss.locationTbl.address_line_1(I)||'<br>';
                        IF per_empdir_ss.locationTbl.address_line_2(I) IS NOT NULL THEN
           		  l_address := l_address||per_empdir_ss.locationTbl.address_line_2(I)||'<br>';
                        END IF;
                        IF per_empdir_ss.locationTbl.address_line_3(I) IS NOT NULL THEN
           		  l_address := l_address||per_empdir_ss.locationTbl.address_line_3(I)||'<br>';
                        END IF;
                        l_address := l_address||per_empdir_ss.locationTbl.town_or_city(I);

        	ELSE -- Applying gloabl address format.

         		l_address :=  per_empdir_ss.locationTbl.address_line_1(I)||'<br>';
                        IF per_empdir_ss.locationTbl.address_line_2(I) IS NOT NULL THEN
           		  l_address := l_address||per_empdir_ss.locationTbl.address_line_2(I)||'<br>';
                        END IF;
           		l_address :=  l_address||per_empdir_ss.locationTbl.town_or_city(I)||
           		  	      ', '||per_empdir_ss.locationTbl.region_2(I)||
           		              ' '||per_empdir_ss.locationTbl.postal_code(I);
                END IF;

         -- End Legislation specific overried code

        per_empdir_ss.locationTbl.address(I) := '<span class="OraDataText"> '||l_address||' </span>';

        IF l_flg THEN

         -- Invoking customer override call

            per_empdir_locations_override.before_dml(
                errbuf
               ,retcode
               ,p_eff_date
               ,p_cnt
               ,I
               ,p_srcSystem);
        END IF;

     END IF;
    END LOOP;

    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        per_empdir_ss.write_log(1,
             'Error in pkg: '||g_package||' proc: locations: '||SQLCODE);
        per_empdir_ss.write_log(1,
             'Error Msg: '||substr(SQLERRM,1,700));
END locations;

END PER_EMPDIR_LEG_OVERRIDE;

/
