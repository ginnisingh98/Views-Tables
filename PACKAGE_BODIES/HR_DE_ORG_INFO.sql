--------------------------------------------------------
--  DDL for Package Body HR_DE_ORG_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DE_ORG_INFO" AS
/* $Header: pedeorgi.pkb 115.20 2003/01/24 12:11:00 vgunasek noship $ */

g_chamber_contribution 	   varchar2(1)  := null;
g_employer_Betriebsnummer  varchar2(8)  := null;
g_payroll_Betriebsnummer   varchar2(8)  := null;
g_package 		   varchar2(33) := '  HR_DE_ORG_INFO.';
g_liab_prov		   varchar2(277);
g_assg_id		   number(15);
g_loc			   varchar2(861);
g_super_off		   varchar2(256);
--
--
-- Cursor which fetches Organizations from the named hierarchy - bottom to top
--
CURSOR organization_hierarchy(p_org_id NUMBER, p_org_structure_version_id NUMBER, p_org_exists_in_hierarchy VARCHAR2) IS
          SELECT p_org_id organization_id_parent
                ,0 lev
            FROM dual
           WHERE p_org_exists_in_hierarchy = 'Y'
           UNION
          SELECT organization_id_parent
                ,level lev
            FROM per_org_structure_elements
           WHERE org_structure_version_id = p_org_structure_version_id
      START WITH organization_id_child    = p_org_id
CONNECT BY PRIOR organization_id_parent   = organization_id_child
             AND org_structure_version_id = p_org_structure_version_id
        ORDER BY lev;
--
CURSOR org_hierarchy(p_org_id NUMBER, p_org_structure_version_id NUMBER, p_org_exists_in_hierarchy VARCHAR2) IS
          SELECT p_org_id organization_id_parent
                ,0 lev
            FROM dual
           WHERE p_org_exists_in_hierarchy = 'Y'
           UNION
          SELECT organization_id_parent
                ,level lev
            FROM per_org_structure_elements
           WHERE org_structure_version_id = p_org_structure_version_id
      START WITH organization_id_child    = p_org_id
CONNECT BY PRIOR organization_id_parent   = organization_id_child
             AND org_structure_version_id = p_org_structure_version_id
        ORDER BY lev;
--
--
-- Service function to return the current named hioerarchy.
--
FUNCTION named_hierarchy
(p_organization_id NUMBER) RETURN NUMBER IS
  --
  --
  -- Cursor to return the current named hierarchy.
  --
  CURSOR c_hierarchy(p_organization_id NUMBER) IS
    SELECT TO_NUMBER(inf.org_information1) organization_structure_id
    FROM   hr_organization_information inf
          ,hr_all_organization_units   org
    WHERE  org.organization_id         = p_organization_id
      AND  inf.organization_id         = org.business_group_id
      AND  inf.org_information_context = 'DE_BG_INFO'
      AND  inf.org_information1        IS NOT NULL;
  --
  --
  -- Local Variables.
  --
  l_rec c_hierarchy%ROWTYPE;
BEGIN
  --
  --
  -- Find the current named organization hierarchy.
  --
  OPEN  c_hierarchy(p_organization_id => p_organization_id);
  FETCH c_hierarchy INTO l_rec;
  CLOSE c_hierarchy;
  --
  --
  -- Return ID.
  --
  RETURN l_rec.organization_structure_id;
END named_hierarchy;
--
--
-- Service function to return the current version of the named hioerarchy.
--
FUNCTION latest_named_hierarchy_vers
(p_organization_id NUMBER) RETURN NUMBER IS
  --
  --
  -- Cursor to return the current named hierarchy version.
  --
  CURSOR c_hierarchy_version(p_organization_id NUMBER, p_organization_structure_id NUMBER) IS
    SELECT sv.org_structure_version_id, sv.version_number
    FROM   per_org_structure_versions  sv
          ,fnd_sessions                ses
    WHERE  sv.organization_structure_id = p_organization_structure_id
      AND  ses.session_id               = USERENV('sessionid')
      AND  ses.effective_date BETWEEN sv.date_from AND NVL(sv.date_to, TO_DATE('31/12/4712','DD/MM/YYYY'))
    ORDER BY sv.version_number DESC;
  --
  --
  -- Local Variables.
  --
  l_rec c_hierarchy_version%ROWTYPE;
BEGIN
  --
  --
  -- Find the current primary organization hierarchy.
  --
  OPEN  c_hierarchy_version(p_organization_id           => p_organization_id
                           ,p_organization_structure_id => named_hierarchy(p_organization_id));
  FETCH c_hierarchy_version INTO l_rec;
  CLOSE c_hierarchy_version;
  --
  --
  -- Return ID.
  --
  RETURN l_rec.org_structure_version_id;
END latest_named_hierarchy_vers;
--
--
-- Service function to see if organization belongs to the current named hioerarchy.
--
FUNCTION org_exists_in_hierarchy
(p_organization_id NUMBER) RETURN VARCHAR2 IS
  --
  --
  -- Cursor to see if the organization belongs to the current named hierarchy.
  --
  CURSOR c_org_exists(p_organization_id NUMBER, p_org_structure_version_id NUMBER) IS
    SELECT se.organization_id_child
    FROM   per_org_structure_elements se
    WHERE  se.org_structure_version_id = p_org_structure_version_id
      AND  (se.organization_id_parent  = p_organization_id OR
            se.organization_id_child   = p_organization_id);
  --
  --
  -- Local Variables.
  --
  l_rec c_org_exists%ROWTYPE;
BEGIN
  OPEN  c_org_exists(p_organization_id          => p_organization_id
                    ,p_org_structure_version_id => latest_named_hierarchy_vers(p_organization_id));
  FETCH c_org_exists INTO l_rec;
  IF c_org_exists%FOUND THEN
    CLOSE c_org_exists;
    RETURN 'Y';
  ELSE
    CLOSE c_org_exists;
    RETURN 'N';
  END IF;
END org_exists_in_hierarchy;

/* -- ************************************************************************************* --
The procedure will return the value of the data item (legal information for a particular employee |
  see document DE_FUN_INTERNAL_ORGANIZATIONS.doc) required. The org_id taken as input is the      |
org_id for which the value is required. The procedure will navigate from the org_id supplied up   |
the hierarchy until it finds a value for the data item.						  |
												  |
The following data items are required ;								  |
Data Item 		   Column            Table                        Context        	  |
1. Chamber_contribution    org_information1  hr_organization_information  DE_CHAMBER_CONTRIBUTION |
2. employer_Betriebsnummer org_information1  hr_organization_information  DE_HR_ORG_INFO          |
3. payroll_Betriebsnummer  org_information2  hr_organization_information  DE_HR_ORG_INFO	  |
-------------------------------------------------------------------------------------------------*/

PROCEDURE get_org_data_items
(p_chamber_contribution_out OUT NOCOPY VARCHAR2
,p_employer_Betriebsnummer  OUT NOCOPY VARCHAR2
,p_payroll_Betriebsnummer   OUT NOCOPY VARCHAR2
,p_org_id                    IN NUMBER) IS
  --
  --
  -- Cursor to return organization information relating to chamber contributions and
  -- general HR information.
  --
  CURSOR org_data_items(p_org_id IN NUMBER) IS
    SELECT SUBSTR(org_information1, 1, 30) cc
          ,SUBSTR(org_information1, 1, 30) eb
          ,SUBSTR(org_information2, 1, 30) pb
          ,org_information_context         ctx
    FROM   hr_organization_units       d
          ,hr_organization_information e
    WHERE  d.organization_id = e.organization_id
      AND  d.organization_id = p_org_id
      AND  e.org_information_context IN ('DE_CHAMBER_CONTRIBUTION','DE_HR_ORG_INFO');
  --
  --
  -- Local variables
  --
  l_org_rec         org_data_items%ROWTYPE;
  l_all_items_found BOOLEAN := FALSE;
  l_level 	    NUMBER;
  l_organization_id NUMBER;
  l_cc_save         VARCHAR2(30);
  l_eb_save         VARCHAR2(30);
  l_pb_save         VARCHAR2(30);
BEGIN
  --
  --
  -- Start walking up the organization hierarchy.
  --
  OPEN org_hierarchy(p_org_id, latest_named_hierarchy_vers(p_org_id), org_exists_in_hierarchy(p_org_id));
  FETCH org_hierarchy INTO l_organization_id,l_level;
  --
  --
  -- Walk up the organization hierarchy until all the organizations have been processed or
  -- all the required information has been found.
  --
  WHILE l_all_items_found = FALSE AND org_hierarchy%found LOOP
    --
    --
    -- Get the organization information for the current organization.
    --
    OPEN org_data_items(l_organization_id);
    FETCH org_data_items into l_org_rec;
    --
    --
    -- Loop through all the organization information for the current organization until all the information
    -- has been processed or all the required information has been found.
    --
    WHILE l_all_items_found = FALSE AND org_data_items%found LOOP
      --
      --
      -- See if the organization has the required information and if it does then save it NB. the first
      -- piece of information in each category is the one that is returned.
      --
      --
      IF l_cc_save IS NULL AND l_org_rec.ctx = 'DE_CHAMBER_CONTRIBUTION' AND l_org_rec.cc IS NOT NULL THEN
        l_cc_save := RPAD(l_org_rec.cc, 30, ' ');
      END IF;
      --
      IF l_eb_save IS NULL AND l_org_rec.ctx = 'DE_HR_ORG_INFO' AND l_org_rec.eb IS NOT NULL THEN
        l_eb_save := RPAD(l_org_rec.eb, 30, ' ');
      END IF;
      --
      IF l_pb_save IS NULL AND l_org_rec.ctx = 'DE_HR_ORG_INFO' AND l_org_rec.pb IS NOT NULL THEN
        l_pb_save := RPAD(l_org_rec.pb, 30, ' ');
      END IF;
      --
      --
      -- Check to see if all the required information has been found.
      --
      l_all_items_found := (l_cc_save IS NOT NULL AND l_eb_save IS NOT NULL AND l_pb_save IS NOT NULL);
      --
      --
      -- Get the next set of organization information for the current organization.
      --
      FETCH org_data_items into l_org_rec;
    END LOOP;
    --
    CLOSE org_data_items;
    --
    --
    -- Get the next organization in the hierarchy.
    --
    FETCH org_hierarchy INTO l_organization_id, l_level;
  END lOOP;
  --
  CLOSE org_hierarchy;
  --
  --
  -- Set the OUT parameters.
  --
  p_chamber_contribution_out := l_cc_save;
  p_employer_Betriebsnummer  := l_eb_save;
  p_payroll_Betriebsnummer   := l_pb_save;
END get_org_data_items;

/*---------------------------------------------------------------------------------------------
The table HR_DE_ORGANIZATION_LINKS holds relationships between an internal org and            |
external orgs (insurance providers in this case). One or more insurance companies may provide |
insurance for the orgainization. Get the details and put them in a table that can be returned |
to the caller 									              |
---------------------------------------------------------------------------------------------*/
-- nocopy not used as the table should not be very large.
-- Since nocopy change is made mandatory previous comment is ignored.
PROCEDURE get_insurance_providers (p_org_id in hr_organization_units.organization_id%TYPE
                                 ,p_Insurance_providers_Table out nocopy Insurance_providers_table) IS

l_organization_id hr_organization_units.organization_id%type;
l_record_count  integer  := 0;
--l_record_count2 integer := 0;
l_duplicate 	varchar2(1) := 'N';
l_default       varchar2(1) := 'N';
l_Insurance_providers_Table Insurance_providers_table;
l_proc          varchar2(72) := g_package || 'get_insurance_providers';

cursor c_insurance_providers (c_org_id hr_organization_units.organization_id%type) is
select HL.ORG_LINK_INFORMATION1 status,
       HL.CHILD_ORGANIZATION_ID child_org_id,
       HL.ORG_LINK_INFORMATION2 Class_Of_Risk,
       HL.ORG_LINK_INFORMATION3 Membership_Number,
       HU.NAME Name
from
       HR_DE_ORGANIZATION_LINKS HL,
       HR_ORGANIZATION_UNITS HU
where
       Parent_Organization_id = c_org_id  -- the internal org id
and    Org_link_information_category  = 'DE_LIABILITY_INSURANCE'
and    HL.ORG_LINK_INFORMATION1      <> 'DE_INACTIVE'
and    HL.CHILD_ORGANIZATION_ID       = HU.ORGANIZATION_ID;


BEGIN
 --
 --
 -- Only need to attempt to build a list of insurance providers if the organization belongs
 -- to the named hierarchy.
 --
 if org_exists_in_hierarchy(p_org_id) = 'Y' then
  FOR v_organization in organization_hierarchy(p_org_id
                                              ,latest_named_hierarchy_vers(p_org_id)
                                              ,org_exists_in_hierarchy(p_org_id)) LOOP
    FOR v_provider in c_insurance_providers (v_organization.organization_id_parent) loop
      l_duplicate := 'N';
      FOR l_record_count2 in 1 .. l_record_count LOOP
        IF v_provider.child_org_id=l_Insurance_providers_Table(l_record_count2).child_org_id THEN
           l_duplicate := 'Y';
           EXIT;
        END IF;
      END LOOP;
      IF l_duplicate = 'N' THEN
         l_record_count := l_record_count + 1;
         l_Insurance_providers_Table(l_record_count).child_org_id := v_provider.child_org_id;
         l_Insurance_providers_Table(l_record_count).name := v_provider.name;
         l_Insurance_providers_Table(l_record_count).membership_Number := v_provider.membership_Number;
         l_Insurance_providers_Table(l_record_count).Class_Of_Risk := v_provider.Class_Of_Risk;
         IF l_default = 'N' AND  v_provider.status = 'DE_DEFAULT' THEN
            l_Insurance_providers_Table(l_record_count).status := 'Y';
            l_default := 'Y';
         END IF;
      END IF;
    END LOOP;
  END LOOP;
 end if;

 p_Insurance_providers_Table := l_Insurance_providers_Table;
END get_insurance_providers;

/*------------------------------------------------------------------------------
The following procedure checks if the Organization passed in exists in the Prima
ry Hierarchy. Called in HREMEA.pll to validate the Organization Name on the Assi
gnment form
--------------------------------------------------------------------------------*/
PROCEDURE chk_for_org_in_hierarchy(p_org_id in hr_organization_units.organization_id%TYPE,
                                   p_exists out nocopy varchar2) IS
 l_organization_id      hr_organization_units.organization_id%TYPE;
 l_level 	        number;
BEGIN
  p_exists := org_exists_in_hierarchy(p_org_id);
END chk_for_org_in_hierarchy;

/*----------------------------------------------------------------------------------
The following package is for complex funtions required for the Work Incidents Report
Called in view HR_DE_WORK_INCIDENTS_REPORT.
1) get_liab_prov_details(Assignment_id of employee whose work incident report is to be run)
Parameters :
IN   : Assignment_id of employee whose work incident report is to be run
OUT  : Default Workers Liab Prov id(15 chars)
Global: Default Workers Liab Prov id(15 chars)||'@'||Name(240 chars)||'@'||Membership number with int org(20 chars)

CALLED IN : SQL for view HR_DE_WORK_INCIDENTS_REPORT.
-----------------------------------------------------------------------------------*/

FUNCTION  get_liab_prov_details (p_assignment_id in per_assignments_f.assignment_id%TYPE,
                                 p_incident_date in date)
  RETURN VARCHAR2 IS
l_exempt 	varchar2(5);
l_liab_prov 	hr_organization_units.organization_id%TYPE;
l_org_id	hr_organization_units.organization_id%TYPE;
l_membership_no	varchar2(50);
l_duplicate 	varchar2(1);
l_record_count  integer	    := 0;
l_default 	varchar2(1) := 'N';
l_name 		hr_organization_units.name%TYPE;
l_inc_date	date;

cursor c_ins_providers (c_org_id hr_organization_units.organization_id%type) is
select HL.ORG_LINK_INFORMATION1 status,
       Rpad(HL.CHILD_ORGANIZATION_ID, 15, ' ') child_org_id,
       HL.ORG_LINK_INFORMATION2 Class_Of_Risk,
       HL.ORG_LINK_INFORMATION3 Membership_Number,
       rpad(HU.NAME, 240, ' ') Name
from
       HR_DE_ORGANIZATION_LINKS HL,
       HR_ORGANIZATION_UNITS HU
where
       Parent_Organization_id = c_org_id  -- the internal org id
and    Org_link_information_category = 'DE_LIABILITY_INSURANCE'
and    HL.CHILD_ORGANIZATION_ID = HU.ORGANIZATION_ID;


BEGIN
  -- Querying organization recorded on the assignment
--  dbms_output.put_line('In Function get_liab_prov_details for assg id '||p_assignment_id);
  l_inc_date := p_incident_date;
  SELECT unique(organization_id) INTO l_org_id
  FROM per_assignments_f
  WHERE assignment_id = p_assignment_id
  AND   primary_flag = 'Y'
  AND p_incident_date BETWEEN effective_start_date and effective_end_date;
  -- Querying employee has Workers Liability details recorded against the assignment SCL
  SELECT substr(segment2,1,5), substr(segment3,1,15) INTO l_exempt, l_liab_prov FROM Hr_soft_coding_keyflex
  WHERE soft_coding_keyflex_id =
 (SELECT unique(soft_coding_keyflex_id) FROM per_assignments_f WHERE assignment_id = p_assignment_id and p_incident_date BETWEEN effective_start_date AND effective_end_date);
  IF SQL%FOUND THEN
    IF l_exempt = 'N' THEN
      SELECT org.name, NVL(orl.org_link_information3, 'NULL') INTO l_name, l_membership_no
        FROM hr_de_organization_links orl, hr_organization_units org
       WHERE orl.parent_organization_id = l_org_id
         AND  orl.child_organization_id = l_liab_prov
         AND  org.organization_id       = l_liab_prov;
      -- Copy to Global package variables
      g_assg_id   := p_assignment_id;
      g_liab_prov := rpad(l_liab_prov,15,' ')||'@'||rpad(l_name,240,' ')||'@'||l_membership_no;
      --
      RETURN l_liab_prov;
    END IF;
  END IF;
    RETURN NULL;
EXCEPTION
  -- -----------------------------------------------------------------------------------
  WHEN NO_DATA_FOUND THEN  -- No data in the SCL
--    dbms_output.put_line(' In exception block for NO_DATA_FOUND on SCL');
    --
    -- As employee assignment doesn't have Workers Liability details recorded,
    -- Starting with Organization recorded on the employee assignment, Query WLI details
    -- and walk up the primary org hierarchy to find the 1st default provider
    --
    IF l_default = 'N' THEN
--      dbms_output.put_line( 'Walking up Primary Org hierarchy as no WLI details on assgt org' );
      FOR v_organization in organization_hierarchy(l_org_id
                                                  ,latest_named_hierarchy_vers(l_org_id)
                                                  ,org_exists_in_hierarchy(l_org_id)) LOOP
/*      dbms_output.put_line(' For org '||v_organization.organization_id_parent
                             ||' at level '||v_organization.lev);
*/
        FOR v_provider in c_ins_providers (v_organization.organization_id_parent) LOOP
          IF l_default = 'N' AND  v_provider.status = 'DE_DEFAULT' THEN
            -- Copy to Global package variables
            g_assg_id   := p_assignment_id;
            g_liab_prov := v_provider.child_org_id||'@'||v_provider.name||'@'||v_provider.Membership_number;
            --
            RETURN v_provider.child_org_id;
            l_default := 'Y';
          END IF;
        END LOOP;
        IF c_ins_providers%ISOPEN THEN
          CLOSE c_ins_providers;
        END IF;
      END LOOP;
      IF organization_hierarchy%ISOPEN THEN
        CLOSE organization_hierarchy;
      END IF;
    END IF;
    RETURN NULL;
  -- ------------------------------------------------------------
END get_liab_prov_details;

   -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --
   /* Wrapper Functions returning details
        1)Name of Provider
        2)Membership no from string returned above */
   -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --
     FUNCTION get_liab_prov_name(p_assignment_id in	per_assignments_f.assignment_id%TYPE)
              RETURN VARCHAR2 IS
     org_name	hr_organization_units.name%TYPE;
     BEGIN
       IF g_assg_id = p_assignment_id THEN
         org_name := SUBSTR(g_liab_prov, 17, 240);
         RETURN org_name;
       ELSE
         RETURN NULL;
       END IF;
     END get_liab_prov_name;
     ---
     FUNCTION get_liab_prov_membership_no(p_assignment_id in	per_assignments_f.assignment_id%TYPE)
              RETURN VARCHAR2 IS
     mem_no	varchar2(50);
     BEGIN
       IF g_assg_id = p_assignment_id THEN
         mem_no := SUBSTR(g_liab_prov, 258, 20);
 --        g_liab_prov := NULL;
         RETURN mem_no;
       ELSE
         RETURN NULL;
       END IF;
     END get_liab_prov_membership_no;


/* -------------------------------------------------------------------------------------
  Get Location for organization id returned by above function
   ------------------------------------------------------------------------------------*/

FUNCTION  get_location(p_assignment_id in per_assignments_f.assignment_id%TYPE)
          RETURN VARCHAR2 IS
l_loc_id 	hr_locations.location_id%TYPE;
l_add_1		varchar2(240); --hr_locations.address_line_1%TYPE;
l_add_2		varchar2(240); --hr_locations.address_line_2%TYPE;
l_add_3		varchar2(240); --hr_locations.address_line_3%TYPE;
l_town		hr_locations.town_or_city%TYPE;
l_country	hr_locations.country%TYPE;
l_post		hr_locations.postal_code%TYPE;
l_loc		varchar2(861);
l_org_id	hr_organization_units.organization_id%type;
l_sqlcode	number;
l_mssg		varchar2(100);

CURSOR C_location (c_org_id hr_organization_units.organization_id%type) IS
       SELECT rpad(nvl(LOC.location_id, 999999), 15, ' ') location_id,
              rpad(nvl(LOC.address_line_1, 'XXXXXX'), 240, ' ') address_line_1,
              rpad(nvl(LOC.address_line_2, 'XXXXXX'), 240, ' ') address_line_2,
              rpad(nvl(LOC.address_line_3, 'XXXXXX'), 240, ' ') address_line_3,
              rpad(nvl(LOC.town_or_city, 'XXXXXX'), 30, ' ')    town_or_city,
              rpad(nvl(LOC.country, 'XXXXXX'), 60, ' ')         country,
              rpad(nvl(LOC.postal_code, 'XXXXXX'), 30, ' ')     postal_code
--              INTO l_loc_id, l_add_1, l_add_2, l_add_3, l_town , l_country, l_post
--              INTO location_table
       FROM hr_locations LOC WHERE LOC.location_id =
         (select ORG.location_id
         FROM hr_organization_units ORG WHERE ORG.organization_id = c_org_id);


BEGIN
--  dbms_output.put_line('In Function get_location for assg id '||p_assignment_id);
  IF g_assg_id = p_assignment_id THEN
--    dbms_output.put_line('Org Value exists globally for assgt id '||g_assg_id);
--    dbms_output.put_line('Org Value existing globally '||g_liab_prov);
    l_org_id := substr(g_liab_prov, 1, 15);
--    dbms_output.put_line('Org Value extrcted '||l_org_id);
    IF l_org_id IS NOT NULL THEN
       OPEN C_location(l_org_id);
       FETCH C_location
              INTO l_loc_id, l_add_1, l_add_2, l_add_3, l_town , l_country, l_post;
--         dbms_output.put_line('Org Valueis extracted '||l_org_id);
       CLOSE C_location;
/*         dbms_output.put_line('Loc id is '||l_loc_id);dbms_output.put_line('Loc id is '||l_add_1);
         dbms_output.put_line('Loc id is '||l_add_2);dbms_output.put_line('Loc id is '||l_add_3);
         dbms_output.put_line('Loc id is '||l_town);dbms_output.put_line('Loc id is '||l_country);
         dbms_output.put_line('Loc id is '||l_post);
*/
       l_loc := rpad(to_char(l_loc_id), 15,' ')||'@'||l_add_1||'@'||l_add_2||'@'||l_add_3||'@'||l_town||'@'||l_country||'@'||l_post;
       g_loc := rpad(to_char(l_loc_id), 15,' ')||'@'||l_add_1||'@'||l_add_2||'@'||l_add_3||'@'||l_town||'@'||l_country||'@'||l_post;
/*       dbms_output.put_line('Location is '||substr(l_loc,1,200));
       dbms_output.put_line('Location is '||substr(l_loc,200,200));
*/
       RETURN l_loc;
    END IF;
  END IF;
    RETURN (l_loc);
EXCEPTION
  -- ------------------------------------------------------------
  WHEN NO_DATA_FOUND THEN
--    dbms_output.put_line('NO_DATAFOUND');
    RETURN NULL;
  -- ------------------------------------------------------------
END get_location;

/* Wrapper Functions returning individual components of Location Address */
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --
FUNCTION get_addr_line1 (p_assignment_id   in 	 per_assignments_f.assignment_id%TYPE)
        RETURN VARCHAR2 IS
l_line1 	varchar2(240);

BEGIN
--  dbms_output.put_line('In Function get_addr_line1 for assg id '||p_assignment_id);
  IF g_assg_id = p_assignment_id THEN
    IF g_loc IS NOT NULL THEN
      l_line1 := substr(g_loc, 17, 240);
      RETURN(l_line1);
    ELSE
      RETURN NULL;
    END IF;
  END IF;
  RETURN NULL;
END get_addr_line1;
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --
FUNCTION get_addr_line2 (p_assignment_id   in 	 per_assignments_f.assignment_id%TYPE)
        RETURN VARCHAR2 IS
l_line2 	varchar2(240);

BEGIN
--  dbms_output.put_line('In Function get_addr_line2 for assg id '||p_assignment_id);
  IF g_assg_id = p_assignment_id THEN
    IF g_loc IS NOT NULL THEN
      l_line2 := substr(g_loc, 258, 240);
      RETURN(l_line2);
    ELSE
      RETURN NULL;
    END IF;
  END IF;
  RETURN NULL;
END get_addr_line2;
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --
FUNCTION get_addr_line3 (p_assignment_id   in 	 per_assignments_f.assignment_id%TYPE)
        RETURN VARCHAR2 IS
l_line3 	varchar2(240);

BEGIN
--  dbms_output.put_line('In Function get_addr_line3 for assg id '||p_assignment_id);
  IF g_assg_id = p_assignment_id THEN
    IF g_loc IS NOT NULL THEN
      l_line3 := substr(g_loc, 499, 240);
      RETURN(l_line3);
    ELSE
      RETURN NULL;
    END IF;
  END IF;
  RETURN NULL;
END get_addr_line3;
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --
FUNCTION get_town (p_assignment_id   in 	 per_assignments_f.assignment_id%TYPE)
        RETURN VARCHAR2 IS
l_town 	varchar2(30);

BEGIN
--  dbms_output.put_line('In Function get_town for assg id '||p_assignment_id);
  IF g_assg_id = p_assignment_id THEN
    IF g_loc IS NOT NULL THEN
      l_town := substr(g_loc, 740, 30);
      RETURN(l_town);
    ELSE
      RETURN NULL;
    END IF;
  END IF;
  RETURN NULL;
END get_town;
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --
FUNCTION get_country (p_assignment_id   in 	 per_assignments_f.assignment_id%TYPE)
        RETURN VARCHAR2 IS
l_country 	varchar2(60);

BEGIN
--  dbms_output.put_line('In Function get_country for assg id '||p_assignment_id);
  IF g_assg_id = p_assignment_id THEN
    IF g_loc IS NOT NULL THEN
      l_country := substr(g_loc, 771, 60);
      RETURN(l_country);
    ELSE
      RETURN NULL;
    END IF;
  END IF;
  RETURN NULL;
END get_country;
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --
FUNCTION get_postal_code(p_assignment_id   in 	 per_assignments_f.assignment_id%TYPE)
        RETURN VARCHAR2 IS
l_postal_code 	varchar2(30);

BEGIN
--  dbms_output.put_line('In Function get_postal_code for assg id '||p_assignment_id);
  IF g_assg_id = p_assignment_id THEN
    IF g_loc IS NOT NULL THEN
      l_postal_code := substr(g_loc, 832, 30);
      RETURN(l_postal_code);
    ELSE
      RETURN NULL;
    END IF;
  END IF;
  RETURN NULL;
END get_postal_code;
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --


/*----------------------------------------------------------------------------------

The following function returns the values required for the Work Incidents Report
It basically concatenates the output of above proc get_org_data_items to be used in the SQL
for the view HR_DE_WORK_INCIDENTS_REPORT.
1) get_liab_prov_details(Assignment_id of employee whose work incident report is to be run)
Parameters :
IN   : Assignment_id of employee whose work incident report is to be run
OUT  : Chamber_Contribution(30 chars)||Employer_betriebsnummer(30 chars)||Payroll_betriebsnummer(30 chars)

CALLED IN : SQL for view HR_DE_WORK_INCIDENTS_REPORT.

-----------------------------------------------------------------------------------*/

FUNCTION  get_liab_prov_details2(p_assignment_id in per_assignments_f.assignment_id%TYPE,
                                 p_incident_date in date)
  RETURN VARCHAR2 IS
l_cc    	varchar2(30);
l_e_bet 	varchar2(30);
l_p_bet 	varchar2(30);
l_org_id	hr_organization_units.organization_id%TYPE;
l_all 		varchar2(100);
l_inc_date	date;

BEGIN
  SELECT unique(organization_id) INTO l_org_id
  FROM per_assignments_f
  WHERE assignment_id = p_assignment_id
  AND   primary_flag  = 'Y'
  AND   p_incident_date BETWEEN effective_start_date and effective_end_date;
-- dbms_output.put_line(' Function details2 calling get_org_data_items for '||l_org_id);
-- Calling Procedure defined above as it serves the purpose completely
--
  hr_de_org_info.get_org_data_items(p_chamber_contribution_out => l_cc,
                                    p_employer_Betriebsnummer  => l_e_bet,
                                    p_payroll_Betriebsnummer   => l_p_bet,
                                    p_org_id                   => l_org_id);
  --dbms_output.put_line(' Cover Func: CC '||l_cc||' EB '||l_e_bet||' PB '||l_p_bet);
  -- To handle NULLS
  SELECT nvl(l_cc,'                              ')
        ,nvl(l_e_bet,'                              ')
        ,nvl(l_p_bet,'                              ')
  INTO l_cc, l_e_bet, l_p_bet
  FROM dual;



  l_all := l_cc || l_e_bet|| l_p_bet;
--  dbms_output.put_line('ALL '||l_all);
  RETURN l_all;

  IF org_hierarchy%ISOPEN THEN
    CLOSE org_hierarchy;
  END IF;
END get_liab_prov_details2;



/*----------------------------------------------------------------------------------
The following function is required for the Work Incidents Report
Called in view HR_DE_WORK_INCIDENTS_REPORT.
Parameters :
IN   : Assignment_id of employee whose work incident report is to be run
OUT  : Supervising Office Org id(15 chars)
Global : Supervising Office Org id(15 chars)||'@'||Supervising Off org name(240 chars)

CALLED IN : SQL for view HR_DE_WORK_INCIDENTS_REPORT.
-----------------------------------------------------------------------------------*/

FUNCTION  get_supervising_off (p_assignment_id in per_assignments_f.assignment_id%TYPE,
                               p_incident_date in date)
  RETURN VARCHAR2 IS
l_sup_off       hr_organization_units.organization_id%TYPE;
l_org_id        hr_organization_units.organization_id%TYPE;
l_inc_date      date;
l_record_count  integer     := 0;
l_name          hr_organization_units.name%TYPE;
l_sqlcode       number;
l_mssg          varchar2(100);

cursor c_sup_off (c_org_id hr_organization_units.organization_id%type) IS
  SELECT Rpad(HL.CHILD_ORGANIZATION_ID, 15, ' ') child_org_id,
         Rpad(HU.NAME, 240, ' ') Name
  FROM
       HR_DE_ORGANIZATION_LINKS HL,
       HR_ORGANIZATION_UNITS    HU
  WHERE
       Parent_Organization_id = c_org_id  -- the internal org id
  AND    Org_link_type = 'DE_WRK_INC_SUP_OFF'
  AND    HL.CHILD_ORGANIZATION_ID = HU.ORGANIZATION_ID;

BEGIN
  -- Querying organization recorded on the assignment
--  dbms_output.put_line('In Function get_supervising_off for assg id '||p_assignment_id||' on '||p_incident_date);
  SELECT unique(organization_id) INTO l_org_id
   FROM  per_assignments_f
   WHERE assignment_id = p_assignment_id
     AND primary_flag  = 'Y'
     AND p_incident_date BETWEEN effective_start_date and effective_end_date;

  -- Starting with Organization recorded on the employee assignment, Query Supervising Off details
  -- and if not found then walk UP the primary org hierarchy to find the 1st Supervising Off
  --
--    dbms_output.put_line(' Getting Supervising Offices ');
    IF Organization_hierarchy%ISOPEN THEN
      CLOSE Organization_hierarchy;
    END IF;

    FOR v_organization in Organization_hierarchy(l_org_id
                                                ,latest_named_hierarchy_vers(l_org_id)
                                                ,org_exists_in_hierarchy(l_org_id)) LOOP
/*    dbms_output.put_line(' For org '||v_organization.organization_id_parent
                         ||' at level '||v_organization.lev);
*/
       null;
      IF c_sup_off%ISOPEN THEN
        CLOSE c_sup_off;
      END IF;
      FOR v_sup_off in c_sup_off (v_organization.organization_id_parent) LOOP
--      dbms_output.put_line('  Supervising Off Org is '||v_sup_off.Name||'@'||v_sup_off.child_org_id);
          g_assg_id   := p_assignment_id;
          g_super_off := v_sup_off.child_org_id||'@'||v_sup_off.name;
          RETURN v_sup_off.child_org_id;
      END LOOP;
      IF c_sup_off%ISOPEN THEN
        CLOSE c_sup_off;
      END IF;
    END LOOP;
    IF Organization_hierarchy%ISOPEN THEN
      CLOSE Organization_hierarchy;
    END IF;
    RETURN NULL;
EXCEPTION
  -- ------------------------------------------------------------
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
END get_supervising_off;

   /* Wrapper Functions returning Supervising Off Org Name */
   -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --
     FUNCTION get_supervising_off_name(p_assignment_id in	per_assignments_f.assignment_id%TYPE)
              RETURN VARCHAR2 IS
     org_name	hr_organization_units.name%TYPE;
     BEGIN
       IF g_assg_id = p_assignment_id THEN
         org_name := SUBSTR(g_super_off, 17, 240);
         RETURN org_name;
       ELSE
         RETURN NULL;
       END IF;
     END get_supervising_off_name;
-- ************************************************************************************* --
END HR_DE_ORG_INFO;



/
