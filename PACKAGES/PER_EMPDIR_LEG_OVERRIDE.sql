--------------------------------------------------------
--  DDL for Package PER_EMPDIR_LEG_OVERRIDE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_EMPDIR_LEG_OVERRIDE" AUTHID CURRENT_USER AS
/* $Header: peredlor.pkh 115.0 2003/08/03 01:17 smallina noship $ */


-- Global Variables
g_package       CONSTANT Varchar2(30):='PER_EMPDIR_LEG_OVERRIDE';
g_people_override_flg BOOLEAN:= FALSE;
g_asg_override_flg BOOLEAN:= FALSE;
g_jobs_override_flg BOOLEAN:= FALSE;
g_orgs_override_flg BOOLEAN:= FALSE;
g_locations_override_flg BOOLEAN:= TRUE;
g_positions_override_flg BOOLEAN:= FALSE;

-- ---------------------------------------------------------------------------
-- ---------------------------- < isOverrideEnabled > ------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This function is used for determining if override is enabled at
--          either legislation or customer level for the given p_entity
-- p_entity: {PEOPLE, ASSIGNMENTS, JOBS, ORGANIZATIONS, LOCATIONS, POSITIONS}
-- returns: TRUE if either leg or customer level orride is being enabled.
-- ---------------------------------------------------------------------------

    FUNCTION isOverrideEnabled(
        p_entity VARCHAR2
    ) RETURN BOOLEAN;

-- ---------------------------------------------------------------------------
-- ---------------------------- < people > -----------------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure  holds the legislation specific ovveride code
--          for people and branches to customer override if enabled.
-- errbuf, retcode are used for concurrent prg. logging
-- p_eff_date: Effective date of processing
-- p_cnt: Holds the # of rows in the collection at the point
-- p_srcSystem: Refrences the source system being processed.
-- ---------------------------------------------------------------------------

    PROCEDURE people(
        errbuf  OUT NOCOPY VARCHAR2
       ,retcode OUT NOCOPY VARCHAR2
       ,p_eff_date IN DATE
       ,p_cnt IN NUMBER
       ,p_srcSystem IN VARCHAR2);

-- ---------------------------------------------------------------------------
-- ---------------------------- < asg > --------------------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure  holds the legislation specific ovveride code
--          for assignments and branches to customer override if enabled.
-- errbuf, retcode are used for concurrent prg. logging
-- p_eff_date: Effective date of processing
-- p_cnt: Holds the # of rows in the collection at the point
-- p_srcSystem: Refrences the source system being processed.
-- ---------------------------------------------------------------------------

    PROCEDURE asg(
        errbuf  OUT NOCOPY VARCHAR2
       ,retcode OUT NOCOPY VARCHAR2
       ,p_eff_date IN DATE
       ,p_cnt IN NUMBER
       ,p_srcSystem IN VARCHAR2);

-- ---------------------------------------------------------------------------
-- ---------------------------- < jobs > -------------------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure  holds the legislation specific ovveride code
--          for jobs and branches to customer override if enabled.
-- errbuf, retcode are used for concurrent prg. logging
-- p_eff_date: Effective date of processing
-- p_cnt: Holds the # of rows in the collection at the point
-- p_srcSystem: Refrences the source system being processed.
-- ---------------------------------------------------------------------------

    PROCEDURE jobs(
        errbuf  OUT NOCOPY VARCHAR2
       ,retcode OUT NOCOPY VARCHAR2
       ,p_eff_date IN DATE
       ,p_cnt IN NUMBER
       ,p_srcSystem IN VARCHAR2);

-- ---------------------------------------------------------------------------
-- ---------------------------- < orgs > -------------------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure  holds the legislation specific ovveride code
--          for orgs and branches to customer override if enabled.
-- errbuf, retcode are used for concurrent prg. logging
-- p_eff_date: Effective date of processing
-- p_cnt: Holds the # of rows in the collection at the point
-- p_srcSystem: Refrences the source system being processed.
-- ---------------------------------------------------------------------------

    PROCEDURE orgs(
        errbuf  OUT NOCOPY VARCHAR2
       ,retcode OUT NOCOPY VARCHAR2
       ,p_eff_date IN DATE
       ,p_cnt IN NUMBER
       ,p_srcSystem IN VARCHAR2);

-- ---------------------------------------------------------------------------
-- ---------------------------- < locations > --------------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure  holds the legislation specific ovveride code
--          for locations and branches to customer override if enabled.
-- errbuf, retcode are used for concurrent prg. logging
-- p_eff_date: Effective date of processing
-- p_cnt: Holds the # of rows in the collection at the point
-- p_srcSystem: Refrences the source system being processed.
-- ---------------------------------------------------------------------------

    PROCEDURE locations(
        errbuf  OUT NOCOPY VARCHAR2
       ,retcode OUT NOCOPY VARCHAR2
       ,p_eff_date IN DATE
       ,p_cnt IN NUMBER
       ,p_srcSystem IN VARCHAR2);

-- ---------------------------------------------------------------------------
-- ---------------------------- < positions > --------------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure  holds the legislation specific ovveride code
--          for positions and branches to customer override if enabled.
-- errbuf, retcode are used for concurrent prg. logging
-- p_eff_date: Effective date of processing
-- p_cnt: Holds the # of rows in the collection at the point
-- p_srcSystem: Refrences the source system being processed.
-- ---------------------------------------------------------------------------

    PROCEDURE positions(
        errbuf  OUT NOCOPY VARCHAR2
       ,retcode OUT NOCOPY VARCHAR2
       ,p_eff_date IN DATE
       ,p_cnt IN NUMBER
       ,p_srcSystem IN VARCHAR2);

END per_empdir_leg_override;

 

/
