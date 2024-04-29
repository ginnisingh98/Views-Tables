--------------------------------------------------------
--  DDL for Package Body INV_ORGHIERARCHY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_ORGHIERARCHY_PVT" AS
/* $Header: INVVORGB.pls 120.2 2006/03/27 01:21:30 amohamme noship $ */
--+=======================================================================+
--|               Copyright (c) 2000 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVVORGB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Spec of INV_ORGHIERARCHY_PVT                                       |
--|                                                                       |
--| HISTORY                                                               |
--|     08/28/00 vjavli          Created                                  |
--|     09/06/00 vjavli          Updated profile for business group id    |
--|                              in the organization version cursor       |
--|     10/13/00 vjavli          updated with include top organization    |
--|                              logic and to obtain the unique top most  |
--|                              parent organization id in the cursor     |
--|     10/29/00 vjavli          updated cursor c_organization_version    |
--|                              with effective date range of the         |
--|                              hierarchy                                |
--|     10/29/00 vjavli          added the logic for organization user    |
--|                              responsibility access                    |
--|                              parent org id check for the user         |
--|                              responsibility access and also for the   |
--|                              child organizations                      |
--|     10/31/00 vjavli          updated with organization end date       |
--|                              validation                               |
--|     11/01/00 vjavli          updated with parent organization end date|
--|                              validation                               |
--|     11/13/00 vjavli          The function Org_Hier_Level_Resp_Access  |
--|                              modified. Removed resp_appl_id parameter |
--|     11/29/00 vjavli          performance tuning - cursor              |
--|                              organization code                        |
--|     12/07/00 vjavli          Overloading procedures with organization |
--|                              hierarchy level id                       |
--|     12/11/00 vjavli          Overloading removed. hierarchy level id  |
--|                              functions retained                       |
--|     05/22/01 vjavli          Created api:Org_exists_in_hierarchy for  |
--|                              usage in the valid query of forms        |
--|     10/19/01 rschaub         Performance Analysis                     |
--|     11/06/01 rschaub         new functions get_organization_list      |
--|                              and validate_property                    |
--|     11/14/01 vjavli          Created new function                     |
--|                              Org_Hier_Origin_Resp_Access as a         |
--|                              performance enhancement of the previous  |
--|                              function Org_Hier_Level_Resp_Access      |
--|     12/11/01 vjavli          Org_exists_in_hierarchy modified         |
--|                              Insert_hierarchy_index_list created      |
--|     05/03/02 vjavli          dbdrv hint added for the version:115.16  |
--|                              Version:115.17 has an issue since this   |
--|                              file got updated with dbdrv hint for the |
--|                              earlier version of the file which does   |
--|                              not have the performance apis            |
--|     09/16/2002 vjavli        Bug#2563291 There are two issues         |
--|                              global hierarchy has to be eliminated    |
--|                              organization list should contain only    |
--|                              inventory organizations                  |
--|                              To eliminate global hierarchy entered    |
--|                              through global hierarchy form in Global  |
--|                              HR responsibility, profile business_group|
--|                              of the responsibility has to be validated|
--|                              For Global Hierarchies,business_group_id |
--|                              is NULL                                  |
--|     09/16/2001 vjavli        Bug#2563291 organization list should     |
--|                              contain only inventory organizations     |
--|     11/22/2002 vma           Added NOCOPY to OUT parameters; Modify   |
--|                              code to print to log only if debug       |
--|                              profile option is enabled.               |
--|     01/09/2003 vjavli        Bug#2553313 fix: to_number problem RDBMS |
--|                              bug fix                                  |
--|     01/28/2004 nkamaraj      Changed the validate_property() logic    |
--|     04/08/2004 nesoni        Bug 3555234. Error/Exceptions should be  |
--|                              logged irrespective of FND Debug Enabled |
--|                              profile option.                          |
--+======================================================================*/


--===================
-- GLOBALS
--===================
G_PKG_NAME 	CONSTANT VARCHAR2(30) := 'INV_ORGHIERARCHY_PVT';

g_log_level NUMBER      := NULL;  -- 0 for manual test
g_log_mode  VARCHAR2(3) := 'OFF'; -- possible values: OFF, SQL, SRS
G_DEBUG     VARCHAR2(1) := NVL(fnd_profile.value('AFLOG_ENABLED'), 'N');

--========================================================================
-- FUNCTION  : get_organization_list   PUBLIC
-- PARAMETERS: p_hierarchy_id          IN  NUMBER
--                                           Organization Hierarchy Id
--             p_origin_org_id         IN  NUMBER
--                                           Hierarchy Origin Organization Id
--             org_id_tbl              OUT NOCOPY OrgID_Tbl_Type
--                                           List of Organization Ids
--             p_include_origin        IN  VARCHAR  DEFAULT 'Y'
--                                           Include the origin in list
--
-- COMMENT   : returns a list containing all organizations from the hierarchy
--             below the origin organization to which the user
--             has access.
--             p_include_origin flag determines whether the origin org id is part
--             of the list or not.
--             Both Inventory Organization Security and HR Security Group
--             are enforced, as well as effective date ranges.
--             This api does not return the organizations in the list in any
--             particular order. The order may change between revisions.
--             origin_id:
--=========================================================================
PROCEDURE get_organization_list
( p_hierarchy_id       IN     NUMBER
, p_origin_org_id      IN     NUMBER
, x_org_id_tbl         OUT    NOCOPY OrgID_Tbl_Type
, p_include_origin     IN     VARCHAR2
)
IS
  l_responsibility_id          NUMBER;
  l_security_profile_id        NUMBER;
  l_business_group_id          NUMBER;
  l_hierarchy_name             VARCHAR2(200);
  l_hierarchy_id               NUMBER;
  l_view_all_flag              VARCHAR2(1);
  l_include_origin_flag        VARCHAR2(1);
  l_hierarchy_version_id       NUMBER;
  l_sec_hierarchy_version_id   NUMBER;
  l_sec_hierarchy_name         VARCHAR2(200);
  l_sec_hierarchy_id           NUMBER;
  l_sec_origin_org_id          NUMBER;


-------------------------------------------------------
-------- List Cursor ----------------------------------


CURSOR  list_sec_csr  IS
SELECT organization_id_child
FROM
(
  (
    SELECT     organization_id_child
    FROM      per_org_structure_elements  arc
    WHERE
     (
       NOT EXISTS( SELECT 1 FROM ORG_ACCESS  acc
                   WHERE acc.organization_id = organization_id_child
                 )
       OR  EXISTS( SELECT 1 FROM ORG_ACCESS  acc
                   WHERE acc.organization_id = organization_id_child
                         AND acc.responsibility_id  =  l_responsibility_id
                 )
     )
    CONNECT BY
          arc.organization_id_parent       =  PRIOR arc.organization_id_child
          AND arc.org_structure_version_id =  PRIOR arc.org_structure_version_id
    START WITH
          arc.organization_id_parent       =  p_origin_org_id
          AND arc.org_structure_version_id =  l_hierarchy_version_id
  )
  INTERSECT
  (
    (
      SELECT        organization_id_child
      FROM        per_org_structure_elements  arc
      WHERE
       (
         NOT EXISTS( SELECT 1 FROM ORG_ACCESS  acc
                     WHERE acc.organization_id = organization_id_child
                   )
         OR  EXISTS( SELECT 1 FROM ORG_ACCESS  acc
                     WHERE acc.organization_id = organization_id_child
                           AND acc.responsibility_id  =  l_responsibility_id
                   )
       )
      CONNECT BY
            arc.organization_id_parent       =  PRIOR arc.organization_id_child
            AND arc.org_structure_version_id =  PRIOR arc.org_structure_version_id
      START WITH
            arc.organization_id_parent       =  l_sec_origin_org_id
            AND arc.org_structure_version_id =  l_sec_hierarchy_version_id
    )
    UNION
    ( SELECT  l_sec_origin_org_id FROM DUAL WHERE  l_include_origin_flag = 'Y')
  )
),
hr_all_organization_units  org,
hr_organization_information hoi,
mtl_parameters mp
WHERE
    org.organization_id  = hoi.organization_id
AND org.organization_id  = mp.organization_id
AND hoi.org_information1 = 'INV'
AND hoi.org_information2 = 'Y'
AND hoi.org_information_context = 'CLASS'
AND org.organization_id  =  organization_id_child
AND  (   org.date_to  >=  SYSDATE OR  org.date_to  IS  NULL )

;




-------------------------------------------------------
-------- Cursor without Security Hierarchy ------------
------ Difference to above: removed intersect clause --



CURSOR  list_no_sec_csr  IS
SELECT organization_id_child
FROM


(
  -- full set of organizations from origin, not including origin
  SELECT
    organization_id_child
  FROM
    per_org_structure_elements  arc
  CONNECT BY
        arc.organization_id_parent   =  PRIOR arc.organization_id_child
    AND arc.org_structure_version_id =  PRIOR arc.org_structure_version_id
  START WITH
        arc.organization_id_parent      =  p_origin_org_id
    AND arc.org_structure_version_id    =  l_hierarchy_version_id
)

, hr_all_organization_units   org
, hr_organization_information hoi
, mtl_parameters mp


WHERE
-- only inventory organizations as part of bug#2563291 fix
    org.organization_id  = hoi.organization_id
AND org.organization_id  = mp.organization_id
AND hoi.org_information1 = 'INV'
AND hoi.org_information2 = 'Y' -- inventory enabled flag
AND hoi.org_information_context = 'CLASS'

-- expiration check
AND org.organization_id  =  organization_id_child
AND  (   org.date_to  >=  SYSDATE
     OR  org.date_to  IS  NULL
     )

-- inv security access check
AND  (  NOT EXISTS( SELECT 1 FROM ORG_ACCESS  acc
                    WHERE acc.organization_id  =  organization_id_child )
     OR     EXISTS( SELECT 1 FROM ORG_ACCESS  acc
                    WHERE acc.organization_id    =  organization_id_child
                    AND   acc.responsibility_id  =  l_responsibility_id
                  )
     )
;




------------------------------------------------------------------
-------- List Cursor with Security Hierarchy but missing Origin --
------ Difference to list_sec_csr: the connect by query for the --
------ Sec. Hier. is replaced with a simple query retrieving    --
------ all orgs inside the Security Hierarchy                   --
------ Note: Forms requires the Origin field to be non-empty    --
------       if the 'include Top Organization' box is checked   --


CURSOR  list_no_sec_origin_csr  IS
SELECT organization_id_child
FROM

(
  (
    -- full set of organizations from origin, not including origin
    SELECT
      organization_id_child
    FROM
      per_org_structure_elements  arc
    CONNECT BY
          arc.organization_id_parent   =  PRIOR arc.organization_id_child
      AND arc.org_structure_version_id =  PRIOR arc.org_structure_version_id
    START WITH
          arc.organization_id_parent      =  p_origin_org_id
      AND arc.org_structure_version_id    =  l_hierarchy_version_id
  )

  INTERSECT

  (
    -- security hierarchy check
    SELECT
      organization_id_child
    FROM
      per_org_structure_elements  arc
    WHERE
      arc.org_structure_version_id  =  l_sec_hierarchy_version_id
  )

)


, hr_all_organization_units  org
, hr_organization_information hoi
, mtl_parameters mp


WHERE
-- only inventory organizations as part of bug#2563291 fix
    org.organization_id  = hoi.organization_id
AND org.organization_id  = mp.organization_id
AND hoi.org_information1 = 'INV'
AND hoi.org_information2 = 'Y' -- inventory enabled flag
AND hoi.org_information_context = 'CLASS'

-- expiration check
AND org.organization_id  =  organization_id_child
AND  (   org.date_to  >=  SYSDATE
     OR  org.date_to  IS  NULL
      )

-- inv security access check
AND  (  NOT EXISTS( SELECT 1 FROM ORG_ACCESS  acc
                    WHERE acc.organization_id  =  organization_id_child )
     OR     EXISTS( SELECT 1 FROM ORG_ACCESS  acc
                    WHERE acc.organization_id    =  organization_id_child
                    AND   acc.responsibility_id  =  l_responsibility_id
                  )
     )
;





BEGIN


  l_responsibility_id   :=
    TO_NUMBER( FND_PROFILE.VALUE( 'RESP_ID' ) );
  l_security_profile_id :=
    TO_NUMBER( FND_PROFILE.value( 'PER_SECURITY_PROFILE_ID' ) );
  l_business_group_id   :=
    TO_NUMBER( FND_PROFILE.VALUE( 'PER_BUSINESS_GROUP_ID' ) );


  -- Note: oe_debug_pub is part of 11i baseline
  oe_debug_pub.add( 'Responsibility Id: '   || l_responsibility_id,   2 );
  oe_debug_pub.add( 'Security Profile Id: ' || l_security_profile_id, 2 );
  oe_debug_pub.add( 'Business Group Id: '   || l_business_group_id,   2 );



  SELECT
    hier.name
  , hier.organization_structure_id
  , prof.view_all_organizations_flag
  , prof.include_top_organization_flag
  , prof.organization_id
  INTO
    l_sec_hierarchy_name
  , l_sec_hierarchy_id
  , l_view_all_flag
  , l_include_origin_flag
  , l_sec_origin_org_id
  FROM
    per_security_profiles         prof
  , per_organization_structures   hier
  WHERE
       prof.security_profile_id  =  l_security_profile_id
  AND  hier.organization_structure_id (+)  =  prof.organization_structure_id
  ;

  oe_debug_pub.add( 'View All:' || l_view_all_flag, 2 );
  oe_debug_pub.add( 'Include Origin:' || l_include_origin_flag, 2 );
  oe_debug_pub.add( 'Security Hieararchy Name:' || l_sec_hierarchy_name, 2 );


  SELECT
    hierv.org_structure_version_id
  INTO
    l_hierarchy_version_id
  FROM
    PER_ORG_STRUCTURE_VERSIONS   hierv
  WHERE
       hierv.organization_structure_id  =  p_hierarchy_id
  AND  (   hierv.date_to   >=  SYSDATE
       OR  hierv.date_to   IS  NULL
       )
  AND      hierv.date_from <= SYSDATE
  ;


  oe_debug_pub.add( 'Hierarchy Version Id:' || l_hierarchy_version_id, 2 );


  BEGIN
  SELECT
    hierv.org_structure_version_id
  INTO
    l_sec_hierarchy_version_id
  FROM
    PER_ORG_STRUCTURE_VERSIONS   hierv
  WHERE
       hierv.organization_structure_id  =  l_sec_hierarchy_id
  AND  (   hierv.date_to   >=  SYSDATE
       OR  hierv.date_to   IS  NULL
       )
  AND      hierv.date_from <= SYSDATE
  ;
  EXCEPTION
    --TODO!: is the buffer cost doubled if no sec hierarchy exists?
    -- if yes create seperate cursor for that case
    WHEN NO_DATA_FOUND THEN
--      l_sec_hierarchy_version_id  := l_hierarchy_version_id;
--      l_sec_origin_org_id         := p_origin_org_id;
      l_include_origin_flag       := 'Y';
  END;

  oe_debug_pub.add( 'Security Hierarchy Version Id:' || l_sec_hierarchy_version_id, 2 );
  oe_debug_pub.add( 'Security Origin Org Id:' || l_sec_origin_org_id, 2 );


  IF    l_sec_hierarchy_version_id  IS NOT NULL
    AND l_sec_origin_org_id         IS NOT NULL
  THEN

    FOR  l_org_id  IN  list_sec_csr  LOOP

      x_org_id_tbl( NVL( x_org_id_tbl.LAST, 0 ) + 1 ) :=
        l_org_id.organization_id_child;

  --    oe_debug_pub.add( '  org id: ' || l_org_id.organization_id_child, 2 );
    END LOOP;

  ELSIF l_sec_hierarchy_version_id  IS NOT NULL
    AND l_sec_origin_org_id         IS NULL
  THEN

    FOR  l_org_id  IN  list_no_sec_origin_csr  LOOP

      x_org_id_tbl( NVL( x_org_id_tbl.LAST, 0 ) + 1 ) :=
        l_org_id.organization_id_child;

    END LOOP;

  ELSIF l_sec_hierarchy_version_id  IS NULL
  THEN

    FOR  l_org_id  IN  list_no_sec_csr  LOOP

      x_org_id_tbl( NVL( x_org_id_tbl.LAST, 0 ) + 1 ) :=
        l_org_id.organization_id_child;

    END LOOP;
  END IF;

  -- origin is always an inventory organization validated through LOV
  IF  p_include_origin  =  'Y'  THEN
    x_org_id_tbl( NVL( x_org_id_tbl.LAST, 0 ) + 1 ) :=
      p_origin_org_id;
  END IF;


END get_organization_list;




--========================================================================
-- FUNCTION  : contained_in_hierarchy  PUBLIC
-- PARAMETERS: p_org_hierarchy_name    IN VARCHAR2     Organization Hierarchy
--                                                     Name
--             p_org_id                IN NUMBER       Organization Id
--
-- COMMENT   : Returns 'Y' if p_org_id is contained in the current version of
--             the named organization hierarchy
--=========================================================================
FUNCTION contained_in_hierarchy
( p_org_hierarchy_name  IN  VARCHAR2
, p_org_id              IN  NUMBER
)
RETURN VARCHAR2
IS

  l_org_structure_version_id      NUMBER;
  l_count                         NUMBER;
  l_contains                      VARCHAR2(1);
-- bug#2563291 fix
  l_business_group_id             NUMBER;


  CURSOR  hierarchy_version_csr  IS
  SELECT
    sv.org_structure_version_id
  FROM
    per_org_structure_versions   sv
  , per_organization_structures  s
  WHERE
       sv.organization_structure_id  =  s.organization_structure_id
  AND  SYSDATE      >=  sv.date_from
  AND  (   SYSDATE  <=  sv.date_to
       OR  sv.date_to  IS NULL
       )
  AND  s.name              =  p_org_hierarchy_name
  AND  s.business_group_id =  l_business_group_id
  ;


  CURSOR  hierarchy_contains_csr  IS
  SELECT
    organization_id_parent
  FROM
    per_org_structure_elements
  WHERE
         (   organization_id_parent      =  p_org_id
         OR  organization_id_child       =  p_org_id
         )
    AND  org_structure_version_id  =  l_org_structure_version_id
  ;



BEGIN
   -- bug#2563291 fix
   -- get profile business group id of the responsibility
   l_business_group_id := TO_NUMBER(FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID'));
   IF l_business_group_id IS NOT NULL THEN
   -- this check ensures that no glboal hierarchy is picked up
     OPEN  hierarchy_version_csr;
     FETCH hierarchy_version_csr  INTO  l_org_structure_version_id;
     CLOSE hierarchy_version_csr;

     OPEN  hierarchy_contains_csr;
     FETCH hierarchy_contains_csr  INTO  l_count;
     IF hierarchy_contains_csr%FOUND THEN
       l_contains  := 'Y';
     ELSE
       l_contains  := 'N';
     END IF;
     CLOSE hierarchy_contains_csr;
   ELSE
     l_contains := 'N';
   END IF;

   RETURN l_contains;

END contained_in_hierarchy;


--========================================================================
-- FUNCTION  : Org_Hierarchy_Access    PUBLIC
-- PARAMETERS: p_org_hierarchy_name    IN VARCHAR2(30) Organization Hierarchy
--                                                     Name
--
-- COMMENT   : This API accepts the name of an hierarchy and returns Y if the
--             user has access to it, N Otherwise  The API checks whether the
--             user has an access or authorization for the organization
--             hierarchy based on the fact that atleast one of the organization
--             in the organization hierarchy belongs to the security profile
--             which has been assigned thru the responsibility to the user.
--=========================================================================
FUNCTION Org_Hierarchy_Access
(p_org_hierarchy_name	IN	VARCHAR2)
RETURN VARCHAR2 IS
l_profile_hierarchy_name	VARCHAR2(30);
l_profile_id			NUMBER;
l_org_hier_profile_id	        hr_all_organization_units.organization_id%TYPE;
l_org_count			NUMBER	:= 0;
l_include_top_org_flag          VARCHAR2(1);
l_top_organization_id           hr_all_organization_units.organization_id%TYPE;
l_org_hier_level_id             NUMBER  := NULL; -- to facilitate overloading

l_security_profile_org_list	OrgID_tbl_type;
l_org_list			OrgID_tbl_type;
l_security_index		BINARY_INTEGER;
l_org_index			BINARY_INTEGER;
l_org_access_flag		VARCHAR2(1);
l_view_all_org_flag		VARCHAR2(1);
l_errorcode			NUMBER;
l_errortext			VARCHAR2(200);

-- cursor to obtain the security profile hierarchy name
CURSOR  c_profile_hierarchy  IS
SELECT  pos.name,
	psp.view_all_organizations_flag,
        psp.include_top_organization_flag,
        psp.organization_id
FROM 	per_security_profiles psp,
	per_organization_structures pos
WHERE   psp.security_profile_id = FND_PROFILE.value('PER_SECURITY_PROFILE_ID')
AND 	pos.organization_structure_id(+) = psp.organization_structure_id;

BEGIN
  IF G_DEBUG = 'Y' THEN
  	INV_ORGHIERARCHY_PVT.Log
    	( INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
  	  , 'Start of Proc:Org Hierarchy Access'
          );
  END IF;

	-- get the profile id of the user
	l_profile_id	:= fnd_profile.value('PER_SECURITY_PROFILE_ID');
	IF l_profile_id is NULL THEN

        /* This executable is used by concurrent program so
           Error/Exception logging should not depend on
           FND Debug Enabled profile otpion. Bug: 3555234
         IF G_DEBUG = 'Y' THEN
        */
    	 INV_ORGHIERARCHY_PVT.Log
  	    ( INV_ORGHIERARCHY_PVT.G_LOG_ERROR
  	     , 'Security Profile Id is not set for the responsibility');

         --END IF;

         RAISE_APPLICATION_ERROR( -20101, 'Security Profile Id is not set for the
                                       responsibility');
	END IF;

	OPEN	c_profile_hierarchy;
	FETCH	c_profile_hierarchy
	INTO	l_profile_hierarchy_name,

        l_view_all_org_flag,
        l_include_top_org_flag,
        l_top_organization_id;

	IF c_profile_hierarchy%NOTFOUND THEN
         RAISE_APPLICATION_ERROR(-20100, 'Security Profile not found');
        /* This executable is used by concurrent program so
           Error/Exception logging should not depend on
           FND Debug Enabled profile otpion. Bug: 3555234
         IF G_DEBUG = 'Y' THEN
        */
	INV_ORGHIERARCHY_PVT.Log
  	    (INV_ORGHIERARCHY_PVT.G_LOG_ERROR
  	     ,'Security Profile not found');
        --END IF;
	END IF;

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
      (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
       ,'Profile Hierarchy Name:' || l_profile_hierarchy_name
      );
    INV_ORGHIERARCHY_PVT.Log
      (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
       ,'View All Organizations Flag:' || l_view_all_org_flag
       || ' Include Top Organization Flag:' ||l_include_top_org_flag
       || ' Top Organization Id:' || to_char(l_top_organization_id)
      );
  END IF;

  l_org_access_flag := 'N';
  IF ((l_profile_hierarchy_name is NOT NULL) AND
      (l_view_all_org_flag = 'N')) THEN

    -- Obtain List of Organizations for the Security profile Org
    -- Hierarchy Name starting from the top organization
	  INV_ORGHIERARCHY_PVT.Org_Hierarchy_List
      ( l_profile_hierarchy_name
       , l_top_organization_id
       , l_security_profile_org_list
      );

    -- Obtain List of Organizations for the Org Hierarchy Name
    -- where hierarchy level id is null
    INV_ORGHIERARCHY_PVT.Org_Hierarchy_List
      ( p_org_hierarchy_name
       , l_org_hier_level_id
       , l_org_list
      );

    -- initialize the security profile org list index
    l_security_index := l_security_profile_org_list.FIRST;

    -- Check for the include top organization flag
    IF (l_include_top_org_flag = 'N') THEN
      -- exclude the top organization from the security profile
      -- organization list
      -- skip the top organization id
      l_security_index := l_security_index + 1;
    END IF;

    -- To check whether the entered Organization Hierarchy has an access
    -- for the user
    WHILE (l_security_index <= l_security_profile_org_list.LAST) LOOP

      l_org_index :=  l_org_list.FIRST;
      WHILE (l_org_index <= l_org_list.LAST) LOOP
        IF (l_security_profile_org_list(l_security_index) =
               l_org_list(l_org_index) ) THEN
          l_org_access_flag := 'Y';
          EXIT;
        END IF;
        l_org_index := l_org_list.NEXT(l_org_index);
      END LOOP;

      l_security_index := l_security_profile_org_list.NEXT(l_security_index);
    END LOOP;

  ELSIF((l_profile_hierarchy_name is NULL) AND
        (l_view_all_org_flag = 'Y')) THEN
    -- User has access to view all the organizations.
    -- Set the org access flag to Y
    l_org_access_flag := 'Y';
  END IF;

	RETURN l_org_access_flag;

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
      (INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
       ,'End of Proc:Org Hierarchy Access'
      );
  END IF;

EXCEPTION
	WHEN OTHERS THEN
	  l_errorcode := SQLCODE;
	  l_errortext := SUBSTR(SQLERRM,1,200);
          /* This executable is used by concurrent program so
             Error/Exception logging should not depend on
             FND Debug Enabled profile otpion. Bug: 3555234
          IF G_DEBUG = 'Y' THEN
          */
         INV_ORGHIERARCHY_PVT.Log
          (INV_ORGHIERARCHY_PVT.G_LOG_EXCEPTION
         ,'Others' || to_char(l_errorcode) || l_errortext
          );
         --END IF;
	 RETURN NULL;

END Org_Hierarchy_Access;



--========================================================================
-- FUNCTION  : Org_Hierarchy_Level_Access    PUBLIC
-- PARAMETERS: p_org_hierarchy_name    IN VARCHAR2(30) Organization Hierarchy
--                                                     Name
--             p_org_hier_level_id     IN NUMBER       Organization Hierarchy
--                                                     Level Id
--
-- COMMENT   : This API accepts the name of an hierarchy,hierarchy level id  and
--             returns Y if the user has access to it N otherwise
--=========================================================================
FUNCTION Org_Hierarchy_Level_Access
(	p_org_hierarchy_name  IN	VARCHAR2,
	p_org_hier_level_id   IN	NUMBER)
RETURN VARCHAR2 IS
l_profile_hierarchy_name	VARCHAR2(30);
l_profile_id			NUMBER;
l_org_hier_profile_id		hr_all_organization_units.organization_id%TYPE;
l_org_count		       	NUMBER	:= 0;
l_include_top_org_flag        VARCHAR2(1);
l_top_organization_id         hr_all_organization_units.organization_id%TYPE;
l_org_hier_level_id           NUMBER    := NULL; -- to facilitate overloading


l_security_profile_org_list	OrgID_tbl_type;
l_org_list			      OrgID_tbl_type;
l_return_status			VARCHAR2(1);
l_security_index		      BINARY_INTEGER;
l_index				BINARY_INTEGER;

l_org_level_validity_flag	VARCHAR2(1);
l_org_level_access_flag		VARCHAR2(1);
l_view_all_org_flag		VARCHAR2(1);
l_errorcode			      NUMBER;
l_errortext		  	      VARCHAR2(200);

-- cursor to obtain the security profile hierarchy name
CURSOR  c_profile_hierarchy  IS
SELECT  pos.name,
	psp.view_all_organizations_flag,
        psp.include_top_organization_flag,
        psp.organization_id
FROM 	  per_security_profiles psp,
	  per_organization_structures pos
WHERE     psp.security_profile_id = FND_PROFILE.value('PER_SECURITY_PROFILE_ID')
AND	  pos.organization_structure_id(+) = psp.organization_structure_id;


BEGIN
  IF G_DEBUG = 'Y' THEN
	  INV_ORGHIERARCHY_PVT.Log
  	  (INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
  	  ,'Start of Proc:Org Hierarchy Level Access'
      );
  END IF;
  -- get the profile id of the user
	l_profile_id  := fnd_profile.value('PER_SECURITY_PROFILE_ID');
	IF l_profile_id is NULL THEN
	  RAISE_APPLICATION_ERROR(-20101, 'Security Profile Id is not set for
                                         the responsibility');
	END IF;

	OPEN	c_profile_hierarchy;
	FETCH	c_profile_hierarchy
	INTO	l_profile_hierarchy_name,
		    l_view_all_org_flag,
        l_include_top_org_flag,
        l_top_organization_id;

	IF c_profile_hierarchy%NOTFOUND THEN
         RAISE_APPLICATION_ERROR(-20100, 'Profile hierarchy name not found');
        /* This executable is used by concurrent program so
           Error/Exception logging should not depend on
           FND Debug Enabled profile otpion. Bug: 3555234
         IF G_DEBUG = 'Y' THEN
         */
         INV_ORGHIERARCHY_PVT.Log
  	    (INV_ORGHIERARCHY_PVT.G_LOG_ERROR
  	     ,'Profile hierarchy name not found'
         );
        --END IF;
	END IF;
	CLOSE c_profile_hierarchy;

	l_org_level_access_flag := 'N'; -- initialize the access flag


        --rschaub: DON'T retrieve all orgs in hierarchy if no security
        --hierarchy exists

        --additional preconditions:  p_org_hier_level_id is a valid
        --  inventory organization. This should be true, otherwise check can be
        --  added here.
        --  Hierarchy business group matches profile business group.
        --  This follows if origin business group matches profile bg.
        --  (All hierarchies are local to a business group)
        --  can add check for origin business group here.
        IF  l_view_all_org_flag  =  'Y'  THEN

          IF contained_in_hierarchy( p_org_hierarchy_name, p_org_hier_level_id )
             = 'Y'
          THEN
            RETURN 'Y';
          ELSE
            RETURN 'N';
          END IF;

        END IF;


        -- Obtain List of Organizations for the Organization Hierarchy Name
        -- where hierarchy level id is null
        INV_ORGHIERARCHY_PVT.Org_Hierarchy_List
          (p_org_hierarchy_name,l_org_hier_level_id,l_org_list);

        -- To check whether the entered Organization Hierarchy Level Id is
        -- within the entered organization hierarchy name
        l_org_level_validity_flag := 'N';
        l_index := l_org_list.FIRST;
        WHILE (l_index <= l_org_list.LAST) LOOP
          IF (p_org_hier_level_id = l_org_list(l_index)) THEN
            -- hierarchy level is valid for the hierarchy name
            l_org_level_validity_flag := 'Y';
            EXIT;
          END IF;
          l_index := l_org_list.NEXT(l_index);
        END LOOP;

        IF G_DEBUG = 'Y' THEN
          INV_ORGHIERARCHY_PVT.Log
          (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
          , 'Organization Level Validity flag' ||
            l_org_level_validity_flag
          );
        END IF;


  IF (l_org_level_validity_flag = 'Y') THEN

    IF ((l_profile_hierarchy_name IS NOT NULL) AND
        (l_view_all_org_flag = 'N')) THEN

      -- Obtain List of Organizations for the Security profile Org
      -- Hierarchy Name
      INV_ORGHIERARCHY_PVT.Org_Hierarchy_List
        (l_profile_hierarchy_name,l_top_organization_id,
         l_security_profile_org_list);

      -- initialize the security profile org list index
      l_security_index := l_security_profile_org_list.FIRST;

      -- Check for the include top organization flag
      IF (l_include_top_org_flag = 'N') THEN
           -- exclude the top organization from the security profile
           -- organization list
           -- skip the top organization id
        l_security_index := l_security_index + 1;
      END IF;

      -- To check whether the entered Organization Hierarchy Level has an
      -- access for the user
      WHILE (l_security_index <= l_security_profile_org_list.LAST) LOOP

        IF (p_org_hier_level_id =
                l_security_profile_org_list(l_security_index)) THEN
          l_org_level_access_flag := 'Y';
          EXIT;
        END IF;

        l_security_index :=
            l_security_profile_org_list.NEXT(l_security_index);
      END LOOP;

    ELSIF ((l_profile_hierarchy_name IS NULL) AND
           (l_view_all_org_flag = 'Y')) THEN
		  -- User has access to all the organizations
			l_org_level_access_flag := 'Y';
    END IF;
  ELSE
    l_org_level_access_flag := 'N';
  END IF;

  RETURN l_org_level_access_flag;

  IF G_DEBUG = 'Y' THEN
   INV_ORGHIERARCHY_PVT.Log
    (INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
     ,'End of Proc:Org Hierarchy Level Access'
     );
  END IF;

EXCEPTION

	WHEN OTHERS THEN
	l_errorcode := SQLCODE;
	l_errortext := SUBSTR(SQLERRM,1,200);
        /*This executable is used by concurrent program so
          Error/Exception logging should not depend on
          FND Debug Enabled profile otpion. Bug: 3555234
          IF G_DEBUG = 'Y' THEN
         */
        INV_ORGHIERARCHY_PVT.Log
  	    (INV_ORGHIERARCHY_PVT.G_LOG_EXCEPTION
         ,to_char(l_errorcode) || l_errortext
        );
        --END IF;
	RETURN NULL;

END Org_Hierarchy_Level_Access;



--========================================================================
-- PROCEDURE : Org_Hierarchy_List      PUBLIC
-- PARAMETERS: p_api_version_number    known api version
--             p_org_hierarchy_name    IN VARCHAR2(30) Organization Hierarchy
--                                                     Name
--             p_org_hier_level_id     IN NUMBER  Organization Hierarchy
--                                                Level Id
--             x_org_code_list         List of Organizations
--
-- COMMENT   : API accepts the name of an hierarchy,hierarchy level id  and
--             returns the list of organizations it contains.
--             p_org_hierarchy_name contains user input organization hierarchy
--             name
--             p_org_hier_level_id contains user input organization id
--             in the hierarchy
--             x_org_code_list contains list of organizations for a given org
--             hierarchy level id
--=========================================================================
PROCEDURE Org_Hierarchy_List
( p_org_hierarchy_name  IN	VARCHAR2
, p_org_hier_level_id   IN 	NUMBER
, x_org_code_list       OUT	NOCOPY OrgID_tbl_type
)
IS

l_structure_version_id	   NUMBER;
list_id	                   NUMBER := 0;
l_orgcode                  hr_all_organization_units.organization_id%TYPE;
l_org_hierarchy_parent_id  hr_all_organization_units.organization_id%TYPE;
l_business_group_id	   hr_all_organization_units.organization_id%TYPE;
l_level			   NUMBER;
l_errorcode		   NUMBER;
l_errortext		   VARCHAR2(200);

l_user_resp_id             NUMBER;

-- cursor to obtain active hierarchy structure version and corresponding
-- business group
CURSOR	c_organization_version( c_hierarchy_name VARCHAR2 ) IS
SELECT
  OSV.org_structure_version_id
, OSV.business_group_id
FROM
  PER_ORG_STRUCTURE_VERSIONS OSV,
  PER_ORGANIZATION_STRUCTURES OS
WHERE
  OSV.ORGANIZATION_STRUCTURE_ID = OS.ORGANIZATION_STRUCTURE_ID

-- rschaub: replaced NVL and date truncation so date index is used
-- otherwise full table scan each time
AND  SYSDATE  >=  OSV.DATE_FROM
AND  (   SYSDATE  <=  OSV.DATE_TO
     OR  OSV.DATE_TO  IS NULL
     )

AND  ltrim(rtrim(OS.NAME)) = ltrim(rtrim(c_hierarchy_name))
AND  OS.BUSINESS_GROUP_ID =
       TO_NUMBER( FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID') );


-- cursor to obtain the parent organization id for the organization structure
-- hierarchy version when p_org_hierarchy_level is null
CURSOR	c_parent_organization( c_org_structure_version_id  NUMBER )  IS
SELECT	organization_id_parent
FROM	PER_ORG_STRUCTURE_ELEMENTS
WHERE   ORG_STRUCTURE_VERSION_ID = c_org_structure_version_id
AND     ORGANIZATION_ID_PARENT NOT IN
                (SELECT ORGANIZATION_ID_CHILD
                 FROM   PER_ORG_STRUCTURE_ELEMENTS
                 WHERE  ORG_STRUCTURE_VERSION_ID = c_org_structure_version_id);

-- cursor to retrieve the inventory organization hierarchy tree for a given
-- structure version id and parent organization id
-- valid organization which is not expired
-- organization has access for the user responsibility
CURSOR	c_organizations
( c_org_structure_version_id  NUMBER
, c_org_id                    NUMBER
, c_business_group_id         NUMBER
)
IS
SELECT
  organization_id_child
, level
FROM
  PER_ORG_STRUCTURE_ELEMENTS POE
CONNECT BY
      POE.ORGANIZATION_ID_PARENT   = PRIOR POE.ORGANIZATION_ID_CHILD
  AND POE.ORG_STRUCTURE_VERSION_ID = PRIOR POE.ORG_STRUCTURE_VERSION_ID
START WITH
      POE.ORGANIZATION_ID_PARENT      = c_org_id
  AND POE.ORG_STRUCTURE_VERSION_ID    = c_org_structure_version_id;
--  rschaub:
--    precondition:
--      that the hierarchy origin already has been
--      security checked against hr profile security. So we
--      don't need sql below to verify that again.
--      Lists of general hierarchies are only retrieved in concunction
--      with an origin. If the origin is null and therefore defaulted
--      to the root of the hierarchy, it must be the profile security
--      hierarchy, which by definition has security profile access.
--      (this was a bug anyway: when the root is not included in the profile,
--       the security hierarchy list is empty because org_organization_def
--       view security excludes the root)
--  speedup: only about twice as fast

--  AND POE.ORGANIZATION_ID_PARENT IN
--      ( SELECT OOD.organization_id
--	FROM   ORG_ORGANIZATION_DEFINITIONS OOD
--      WHERE  OOD.BUSINESS_GROUP_ID = POE.BUSINESS_GROUP_ID );


BEGIN

  IF G_DEBUG = 'Y' THEN
  	INV_ORGHIERARCHY_PVT.Log
    	(INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
  	   ,'Start of Proc:Org Hierarchy List'
      );
  END IF;

  l_business_group_id :=
    TO_NUMBER(FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID'));

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
     ,'Business Group Id:'||to_char(l_business_group_id)
    );
  END IF;

	OPEN 	c_organization_version(p_org_hierarchy_name);
	FETCH	c_organization_version
	INTO  l_structure_version_id,
        l_business_group_id;

	IF c_organization_version%NOTFOUND THEN
    IF G_DEBUG = 'Y' THEN
      INV_ORGHIERARCHY_PVT.Log
  	    (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
  	     ,'Organization Version Id:'||to_char(l_structure_version_id)
        );
    END IF;

    RAISE_APPLICATION_ERROR(-20150,
      'Organization structure version id not found');

	END IF;

	CLOSE	c_organization_version;

  IF G_DEBUG = 'Y' THEN
  	INV_ORGHIERARCHY_PVT.Log
      (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
  	   ,'Organization Version Id:' || to_char(l_structure_version_id)
      );

    INV_ORGHIERARCHY_PVT.Log
      (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
  	   ,'Business Group Id:' || to_char(l_business_group_id)
      );
  END IF;

  -- fetch the parent organization id when hierarchy level id is Null
  IF (p_org_hier_level_id IS NOT NULL) THEN
    l_org_hierarchy_parent_id := p_org_hier_level_id;
  ELSE
    OPEN c_parent_organization(l_structure_version_id);

    FETCH c_parent_organization
      INTO  l_org_hierarchy_parent_id;

    IF c_parent_organization%NOTFOUND THEN
       RAISE_APPLICATION_ERROR(-20250,
                             'Parent organization Id not found when hierarchy
                              level is null');
      /*This executable is used by concurrent program so
        Error/Exception logging should not depend on
        FND Debug Enabled profile otpion. Bug: 3555234
        IF G_DEBUG = 'Y' THEN
        */
        INV_ORGHIERARCHY_PVT.Log
          (INV_ORGHIERARCHY_PVT.G_LOG_ERROR
           ,'Parent Organization Id not found when hierarchy level null'
          );
        -- END IF;
    END IF;

    CLOSE c_parent_organization;

  END IF;

  -- get the responsibility id
  l_user_resp_id := TO_NUMBER(FND_PROFILE.VALUE('RESP_ID'));

  -- check whether the parent organization id is unexpired and
  -- has an access to the current user responsibility
  IF (INV_ORGHIERARCHY_PVT.
        Org_Hier_Level_Resp_Access(l_org_hierarchy_parent_id,
                                       l_business_group_id,
                                       l_user_resp_id) = 'Y') THEN

    -- include the parent organization code in the dynamic table
    list_id := list_id + 1;
    x_org_code_list(list_id) := l_org_hierarchy_parent_id;

    IF G_DEBUG = 'Y' THEN
      INV_ORGHIERARCHY_PVT.Log
        (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
         ,'Parent Organization Hierarchy Code:' ||
           to_char(x_org_code_list(list_id))
        );
    END IF;
	END IF;


	l_orgcode := NULL; /* initialize to verify whether child exist or not */
	FOR	v_organizations IN c_organizations
                               (l_structure_version_id,
                                l_org_hierarchy_parent_id,
                                l_business_group_id) LOOP

	  l_orgcode := v_organizations.organization_id_child;
	  l_level   := v_organizations.level;

    -- check for valid organization and user responsibility access
    IF (INV_ORGHIERARCHY_PVT.Org_Hier_Level_Resp_Access
                                   (l_orgcode,
                                    l_business_group_id,
                                    l_user_resp_id ) = 'Y' ) THEN

      list_id := list_id + 1;
      x_org_code_list( list_id ) := l_orgcode;

      IF G_DEBUG = 'Y' THEN
        INV_ORGHIERARCHY_PVT.Log
          (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
           , 'Organization Hierarchy Code:'||LPAD('  ', 6 * (l_level - 1))||
             to_char(x_org_code_list(list_id))
          );
      END IF;

    END IF; -- valid organization and user access

	END LOOP;

	IF l_orgcode is NULL THEN
    IF G_DEBUG = 'Y' THEN
  	  INV_ORGHIERARCHY_PVT.Log
    	  (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
  	     ,'No Valid Child exist for the parent organization code:' ||
             to_char(l_org_hierarchy_parent_id)
         );
    END IF;
	END IF;

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
      (INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
    	 ,'End of Proc:Org Hierarchy List'
      );
  END IF;

EXCEPTION
	WHEN OTHERS THEN
	 l_errorcode := SQLCODE;
	 l_errortext := SUBSTR(SQLERRM,1,200);
         /*This executable is used by concurrent program so
           Error/Exception logging should not depend on
           FND Debug Enabled profile otpion. Log level has been
           changed from G_LOG_ERROR to G_LOG_EXCEPTION. Bug: 3555234
         IF G_DEBUG = 'Y' THEN
         */
        INV_ORGHIERARCHY_PVT.Log
        (INV_ORGHIERARCHY_PVT.G_LOG_EXCEPTION
        ,to_char(l_errorcode) || l_errortext
        );
        --END IF;

END Org_Hierarchy_List;


--========================================================================
-- FUNCTION  : validate_property  PUBLIC
-- PARAMETERS: p_org_id_tbl       This is a list of organization ids,
--                                typically obtained from a call to
--                                get_organization_list
--             p_property         Returns 'Y' if the property applies to
--                                the list of organizations
--                                p_property can be one of:
--                                'MASTER'
--                                'CALENDAR'
--                                'CHART_OF_ACCOUNTS'
--=========================================================================


FUNCTION validate_property
( p_org_id_tbl   IN   OrgID_Tbl_Type
, p_property     IN   VARCHAR2
)
RETURN VARCHAR2
IS

  l_prev_chart_of_accounts_id     NUMBER;
  l_chart_of_accounts_id          NUMBER;
  l_chart_of_accounts_count       NUMBER;
  l_previous_calendar_name        VARCHAR2(200);
  l_calendar_name                 VARCHAR2(200);
  l_calendar_count                VARCHAR2(200);
  l_previous_master_org_id        NUMBER;
  l_master_org_id                 NUMBER;
  l_master_org_count              NUMBER;
  l_org_id                        NUMBER;

  i                               BINARY_INTEGER;

  l_errorcode                     NUMBER;
  l_errortext                     VARCHAR2(200);

BEGIN

  -- check for unique item master
  IF  p_property  =  'MASTER'  THEN

    l_master_org_count        :=  0;
    l_previous_master_org_id  := -1;
    i  := p_org_id_tbl.FIRST;
    WHILE i IS NOT NULL LOOP

      l_org_id  :=  p_org_id_tbl(i);
      BEGIN
        SELECT  master_organization_id
        INTO    l_master_org_id
        FROM    mtl_parameters
        WHERE   organization_id  =  l_org_id;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          oe_debug_pub.add( 'Organization ' || l_org_id || ' has no Item Master'
                          , 2 );
          RETURN  'N';
        WHEN  OTHERS  THEN
          oe_debug_pub.add( '(SQL EXCEPTION: Item Master for Organization '
                          || l_org_id || ')', 2 );
          RAISE;
      END;

	-- Bug :3296392 : Modified the following logic to exit immedidately after
	--                the first different Calendar found from the Orgs
        --		  under the given hierarchy.
	IF l_previous_master_org_id =  -1
	 THEN
	   l_previous_master_org_id  :=  l_master_org_id;
	 ELSE
	   IF l_previous_master_org_id  <>  l_master_org_id
	   THEN
	     l_master_org_count        :=   1;
	     EXIT;
	   END IF;
	 END IF;

      i  := p_org_id_tbl.NEXT(i);

    END LOOP;

    IF  l_master_org_count  =  0  THEN
      RETURN  'Y';
    ELSE
      oe_debug_pub.add( 'Organizations do not share unique Item Master', 2 );
      RETURN  'N';
    END IF;



  -- check for unique calendar
  ELSIF   p_property  =  'CALENDAR'  THEN

    l_calendar_count          :=  0;
    l_previous_calendar_name  := '-1';
    i  := p_org_id_tbl.FIRST;
    WHILE i IS NOT NULL LOOP

      l_org_id  :=  p_org_id_tbl(i);
      BEGIN
        SELECT
          period_set_name
        INTO
          l_calendar_name
        FROM
          gl_sets_of_books, hr_organization_information
        WHERE UPPER( org_information_context ) = UPPER( 'Accounting Information' )
        AND organization_id                  = l_org_id
        AND set_of_books_id                  = TO_NUMBER(org_information1);

      EXCEPTION
        WHEN  NO_DATA_FOUND  THEN
          oe_debug_pub.add( 'Organization ' || l_org_id || ' has no GL Calendar'
                          , 2 );
          RETURN  'N';
        WHEN  OTHERS  THEN
          oe_debug_pub.add( '(SQL EXCEPTION: period_set_name for organization '
                          || l_org_id || ')', 2 );
          RAISE;
      END;

      -- Bug :3296392 : Modified the following logic to exit immedidately after
      --                the first different Calendar found from the Orgs
      --		under the given hierarchy.

      IF l_previous_calendar_name =  '-1'
      	 THEN
      	   l_previous_calendar_name  :=  l_calendar_name;
      	 ELSE
      	   IF l_previous_calendar_name  <>  l_calendar_name
      	   THEN
      	     l_calendar_count        :=   1;
      	     EXIT;
      	   END IF;
      END IF;

      -- IF  l_previous_calendar_name  <>  l_calendar_name  THEN
      -- 	l_calendar_count          := l_calendar_count + 1;
      -- 	l_previous_calendar_name  := l_calendar_name;
      -- END IF;

      i  := p_org_id_tbl.NEXT(i);

    END LOOP;


    IF  l_calendar_count  =  0  THEN
      RETURN  'Y';
    ELSE
      oe_debug_pub.add( 'Organizations do not share unique GL calendar', 2 );
      RETURN  'N';
    END IF;



  ELSIF  p_property  =  'CHART_OF_ACCOUNTS'  THEN

    l_chart_of_accounts_count        :=  0;
    l_prev_chart_of_accounts_id      := '-1';
    i  := p_org_id_tbl.FIRST;
    WHILE i IS NOT NULL LOOP

      l_org_id  :=  p_org_id_tbl(i);
      BEGIN
        SELECT
          chart_of_accounts_id
        INTO
          l_chart_of_accounts_id
        FROM
          gl_sets_of_books, hr_organization_information
        WHERE UPPER( org_information_context ) = UPPER( 'Accounting Information' )
        AND organization_id                  = l_org_id
        AND set_of_books_id                  = TO_NUMBER(org_information1);

      EXCEPTION
        WHEN  NO_DATA_FOUND  THEN
          oe_debug_pub.add( 'Organization ' || l_org_id || ' has no COA', 2 );
          RETURN  'N';
        WHEN  OTHERS  THEN
          oe_debug_pub.add( '(SQL EXCEPTION: COA for organization ' || l_org_id || ')', 2 );
          RAISE;
      END;

      -- Bug :3296392 : Modified the following logic to exit immedidately after
      --                the first different ChartOfAccounts found from the Orgs
      --		under the given hierarchy.
      IF l_prev_chart_of_accounts_id =  '-1'
      THEN
	   l_prev_chart_of_accounts_id  :=  l_chart_of_accounts_id ;
      ELSE
	IF l_prev_chart_of_accounts_id  <>  l_chart_of_accounts_id
	THEN
	  l_chart_of_accounts_count        :=   1;
	  EXIT;
	END IF;
      END IF;

      -- IF  l_prev_chart_of_accounts_id  <>  l_chart_of_accounts_id  THEN
      --   l_chart_of_accounts_count          := l_chart_of_accounts_count + 1;
      --   l_prev_chart_of_accounts_id        := l_chart_of_accounts_id;
      -- END IF;

      i  := p_org_id_tbl.NEXT(i);

    END LOOP;


    IF  l_chart_of_accounts_count  =  0  THEN
      RETURN  'Y';
    ELSE
      oe_debug_pub.add( 'Organizations do not share unique COA', 2 );
      RETURN  'N';
    END IF;

  END IF;
EXCEPTION
  WHEN OTHERS THEN
    l_errorcode := SQLCODE;
    l_errortext := SUBSTR( SQLERRM, 1, 200 );
    oe_debug_pub.add( to_char( l_errorcode ) || l_errortext, 1 );

    RETURN  'N';

END validate_property;


--========================================================================
-- FUNCTION  : Org_Hier_Level_Property_Access    PUBLIC
-- PARAMETERS: p_api_version_number    known api version
--             p_org_hierarchy_name  IN VARCHAR2(30) Organization Hierarchy
--                                                   Name
--             p_org_hier_level_id   IN NUMBER Hierarchy Level Id
--
--             p_property_type       IN VARCHAR2(25) Property Type
--
-- COMMENT   : API accepts the name of an hierarchy,hierarchy level id,
--             property and returns Y if the property is satisfied, N otherwise.
--             The supported properties are:
--              MASTER: all the organizations share the same item master
--	        CALENDAR: all the organizations share the same calendar
--	        CHART_OF_ACCOUNTS: all the organizations share the same chart of
--              accounts
--=========================================================================
FUNCTION Org_Hier_Level_Property_Access
( p_org_hierarchy_name  IN	VARCHAR2	,
	p_org_hier_level_id   IN	NUMBER	,
	p_property_type       IN	VARCHAR2	)
RETURN VARCHAR2 IS
l_structure_version_id	NUMBER;
list_id	NUMBER := 0;
l_master_orgid			hr_all_organization_units.organization_id%TYPE;
l_old_master_orgid		hr_all_organization_units.organization_id%TYPE;
l_period_set_name		VARCHAR2(15);
l_old_period_set_name		VARCHAR2(15);
l_chart_accounts_id		NUMBER(15);
l_old_chart_accounts_id		NUMBER(15);
l_return_status		VARCHAR2(1);
l_index			BINARY_INTEGER;
l_org_count		NUMBER;
l_inventory_item_id	NUMBER;
l_org_level_property_status VARCHAR2(1) := 'N';
l_property_count	NUMBER;
l_errorcode			NUMBER;
l_errortext			VARCHAR2(200);


l_org_code_list OrgID_tbl_type;

v_more_than_one_master_item	EXCEPTION;
v_more_than_one_calendar	EXCEPTION;
v_one_chart_of_accounts		EXCEPTION;

-- cursor to obtain item master organization id
CURSOR  c_item_master(c_organization_id NUMBER) IS
SELECT  master_organization_id
FROM    MTL_PARAMETERS
WHERE	  ORGANIZATION_ID = c_organization_id;

-- cursor to obtain chart of accounts id for the organization
CURSOR  c_chart_of_accounts(c_organization_id NUMBER) IS
SELECT
  chart_of_accounts_id
FROM
  gl_sets_of_books, hr_organization_information
WHERE upper( org_information_context ) = upper( 'Accounting Information' )
  AND organization_id                  = c_organization_id
  AND set_of_books_id                  = to_number(org_information1);

-- rschaub: org_organization_definitions view too expensive
--SELECT  chart_of_accounts_id
--FROM	  ORG_ORGANIZATION_DEFINITIONS
--WHERE	  ORGANIZATION_ID = c_organization_id;

-- cursor to obtain GL period set name for an organization
CURSOR  c_calendar(c_organization_id NUMBER) IS

SELECT
  period_set_name
FROM
  gl_sets_of_books, hr_organization_information
WHERE upper( org_information_context ) = upper( 'Accounting Information' )
  AND organization_id                  = c_organization_id
  AND set_of_books_id                  = to_number(org_information1);

-- rschaub: too expensive
--SELECT  period_set_name
--FROM	  GL_SETS_OF_BOOKS
--WHERE	  SET_OF_BOOKS_ID IN (SELECT set_of_books_id
--			          FROM   ORG_ORGANIZATION_DEFINITIONS
--			          WHERE  ORGANIZATION_ID = c_organization_id);


BEGIN
  IF G_DEBUG = 'Y' THEN
  	INV_ORGHIERARCHY_PVT.Log
  	(INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
  	 ,'Start of Proc:Org Hierarchy Level Property Access'
    );
  END IF;

	INV_ORGHIERARCHY_PVT.Org_Hierarchy_List(p_org_hierarchy_name,
                           p_org_hier_level_id,l_org_code_list);

	IF (p_property_type = 'MASTER') THEN
	  -- check for unique item master for the organizations
    l_index := l_org_code_list.FIRST;
    l_property_count := 0;
    l_old_master_orgid := NULL;
    WHILE (l_index <= l_org_code_list.LAST) LOOP
      OPEN c_item_master(l_org_code_list(l_index));

      FETCH c_item_master
      INTO  l_master_orgid;

      IF c_item_master%NOTFOUND THEN
        NULL;
      END IF;

      IF l_old_master_orgid IS NULL THEN
        l_old_master_orgid := l_master_orgid;
        l_property_count := 1;
      ELSIF (l_master_orgid <> l_old_master_orgid) THEN
        l_property_count := l_property_count + 1;
        l_old_master_orgid := l_master_orgid;
      END IF;

      CLOSE c_item_master;

      IF (l_property_count > 1) THEN
        RAISE v_more_than_one_master_item;
      END IF;

      l_index := l_org_code_list.NEXT(l_index);
    END LOOP;

    -- ONE Item Master exists for the given organization hierarchy
    l_org_level_property_status := 'Y';
    IF G_DEBUG = 'Y' THEN
      INV_ORGHIERARCHY_PVT.Log
        (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
         ,'Master Org Id: ' || to_char(l_master_orgid)
        );
    END IF;

  ELSIF(p_property_type = 'CALENDAR') THEN
    -- check for unique calendar for the organizations
    l_index := l_org_code_list.FIRST;
    l_property_count := 0;
    l_old_period_set_name := NULL;

    WHILE(l_index <= l_org_code_list.LAST) LOOP
      OPEN c_calendar(l_org_code_list(l_index));

      FETCH c_calendar
      INTO  l_period_set_name;

      IF c_calendar%NOTFOUND THEN
        NULL;
      END IF;

      IF l_old_period_set_name IS NULL THEN
        l_old_period_set_name := l_period_set_name;
        l_property_count := 1;
      ELSIF (l_period_set_name <> l_old_period_set_name) THEN
        l_property_count := l_property_count + 1;
        l_old_period_set_name := l_period_set_name;
      END IF;

      CLOSE c_calendar;

      IF (l_property_count > 1) THEN
        RAISE v_more_than_one_calendar;
      END IF;
      l_index := l_org_code_list.NEXT(l_index);
    END LOOP;
    -- ONE Calendar exist for the given organization hierarchy
    l_org_level_property_status := 'Y';
    IF G_DEBUG = 'Y' THEN
      INV_ORGHIERARCHY_PVT.Log
        (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
         ,'Calendar: ' || l_period_set_name
        );
    END IF;

  ELSIF(p_property_type = 'CHART_OF_ACCOUNTS') THEN
    -- check for unique chart of accounts for the organizations
    l_index := l_org_code_list.FIRST;
    l_property_count := 0;
    l_old_chart_accounts_id := NULL;

    WHILE(l_index <= l_org_code_list.LAST) LOOP
      OPEN c_chart_of_accounts(l_org_code_list(l_index));

      FETCH c_chart_of_accounts
      INTO  l_chart_accounts_id;

      IF c_chart_of_accounts%NOTFOUND THEN
        NULL;
      END IF;

      IF l_old_chart_accounts_id IS NULL THEN
        l_old_chart_accounts_id := l_chart_accounts_id;
        l_property_count := 1;
      ELSIF (l_chart_accounts_id <> l_old_chart_accounts_id) THEN
        l_property_count := l_property_count + 1;
        l_old_chart_accounts_id := l_chart_accounts_id;
      END IF;

      CLOSE c_chart_of_accounts;

      IF l_property_count > 1 THEN
        RAISE	v_one_chart_of_accounts;
      END IF;

      l_index := l_org_code_list.NEXT(l_index);
    END LOOP;
    -- ONE Chart of Accounts exist for the given organization
    --   hierarchy
    l_org_level_property_status := 'Y';
    IF G_DEBUG = 'Y' THEN
      INV_ORGHIERARCHY_PVT.Log
        (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
         ,'Chart of Accounts:' || to_char(l_chart_accounts_id)
        );
    END IF;

  END IF;

  RETURN l_org_level_property_status;

  IF G_DEBUG = 'Y' THEN
  	INV_ORGHIERARCHY_PVT.Log
    	(INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
  	   ,'End of Proc:Org Hierarchy Level Property Access'
        );
  END IF;

EXCEPTION

	WHEN v_more_than_one_master_item THEN
	  l_org_level_property_status := 'N';
         /* This executable is used by concurrent program so
            Error/Exception logging should not depend on
            FND Debug Enabled profile otpion. Bug: 3555234
           IF G_DEBUG = 'Y' THEN
          */
         INV_ORGHIERARCHY_PVT.Log
          (INV_ORGHIERARCHY_PVT.G_LOG_ERROR
          ,'More than one item master exists for the Organization Hierarchy'
          );
         --END IF;
	 RETURN l_org_level_property_status;

	WHEN v_more_than_one_calendar THEN
	  l_org_level_property_status := 'N';
         /*This executable is used by concurrent program so
           Error/Exception logging should not depend on
           FND Debug Enabled profile otpion. Bug: 3555234
           IF G_DEBUG = 'Y' THEN
          */
         INV_ORGHIERARCHY_PVT.Log
          (INV_ORGHIERARCHY_PVT.G_LOG_ERROR
          ,'More than one calendar exists for the Organization Hierarchy'
          );
         --END IF;
	 RETURN l_org_level_property_status;

	WHEN v_one_chart_of_accounts THEN
          l_org_level_property_status := 'N';
          /* This executable is used by concurrent program so
             Error/Exception logging should not depend on
             FND Debug Enabled profile otpion. Bug: 3555234
            IF G_DEBUG = 'Y' THEN
           */
         INV_ORGHIERARCHY_PVT.Log
          (INV_ORGHIERARCHY_PVT.G_LOG_ERROR
          ,'More than one chart of accounts exists for the Organization
            Hierarchy'
          );
         --END IF;
	 RETURN l_org_level_property_status;

	WHEN OTHERS THEN
	  l_errorcode := SQLCODE;
	  l_errortext := SUBSTR(SQLERRM,1,200);

         /*This executable is used by concurrent program so
           Error/Exception logging should not depend on
           FND Debug Enabled profile otpion. Log level has been
           changed from G_LOG_ERROR to G_LOG_EXCEPTION. Bug: 3555234
          IF G_DEBUG = 'Y' THEN
         */
         INV_ORGHIERARCHY_PVT.Log
           (INV_ORGHIERARCHY_PVT.G_LOG_EXCEPTION
           ,to_char(l_errorcode) || l_errortext
            );
         --END IF;
	 RETURN NULL;

END Org_Hier_Level_Property_Access;


--========================================================================
-- FUNCTION  : Org_Hier_Level_Resp_Access    PUBLIC
-- PARAMETERS: p_api_version_number    known api version
--             p_org_id                  IN NUMBER Hierarchy Level Id
--                                           (Organization Id)
--             p_business_group_id       IN NUMBER Business Group Id
--             p_responsibility_id       IN NUMBER Current Responsibility
--                                          Id
-- COMMENT   : API accepts the Organization Id of an organization
--             hierarchy level(organization name), business group id,
--             current responsibility user has signed on and returns Y if
--             the organization is a valid organization (unexpired) and has
--             an access for the responsibility, N otherwise.
--=========================================================================
FUNCTION Org_Hier_Level_Resp_Access
(     p_org_id                   IN   NUMBER,
      p_business_group_id        IN   NUMBER,
      p_responsibility_id        IN   NUMBER
)
RETURN VARCHAR2 IS

-- cursor to check for the unexpired organization
CURSOR c_unxpire_organization(c_org_id NUMBER, c_business_group_id NUMBER) IS
SELECT 'Y'
FROM   HR_ALL_ORGANIZATION_UNITS
WHERE  ORGANIZATION_ID = c_org_id
AND    BUSINESS_GROUP_ID = c_business_group_id
AND    NVL(DATE_TO,TRUNC(SYSDATE)) >= TRUNC(SYSDATE);

CURSOR c_org_access(c_organization_id  NUMBER) IS
SELECT RESPONSIBILITY_ID
FROM   ORG_ACCESS
WHERE  ORGANIZATION_ID = c_organization_id;

l_responsibility_id     NUMBER;
l_org_resp_access_flag 	VARCHAR2(1);
l_org_valid_flag    VARCHAR2(1);

l_errorcode			NUMBER;
l_errortext			VARCHAR2(200);

BEGIN
  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    (INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
     ,'Start of Proc:Org Hierarchy Level Responsibility Access'
    );
  END IF;

  -- initialize the flag
  l_org_resp_access_flag := 'N';

  -- initialize the valid organization flag
  l_org_valid_flag:= 'N';

  -- check whether the organization is expired
  OPEN c_unxpire_organization(p_org_id,p_business_group_id);
  FETCH c_unxpire_organization
  INTO  l_org_valid_flag;

  IF c_unxpire_organization%NOTFOUND THEN
    RAISE_APPLICATION_ERROR(-20255,
          'organization expired');
    /*This executable is used by concurrent program so
      Error/Exception logging should not depend on
      FND Debug Enabled profile otpion. Bug: 3555234
      IF G_DEBUG = 'Y' THEN
      */
      INV_ORGHIERARCHY_PVT.Log
        (INV_ORGHIERARCHY_PVT.G_LOG_ERROR
         ,'Organization Id expired:' || to_char(p_org_id) ||
          'Business Group Id:' || to_char(p_business_group_id)
        );
      --END IF;
  END IF;

  CLOSE c_unxpire_organization;

  -- Check only if the organization is unexpired
  IF (l_org_valid_flag = 'Y') THEN

    -- Open the cursor
    OPEN c_org_access(p_org_id);

    -- Retrieve the first row to setup for the WHILE loop
    FETCH c_org_access INTO l_responsibility_id;

    -- rows not found set the flag to Y
    IF c_org_access%NOTFOUND THEN
      l_org_resp_access_flag := 'Y';
    END IF;

    -- continue looping while there are more rows to fetch
    WHILE c_org_access%FOUND LOOP
      -- check for the matching current user responsibility
      IF(p_responsibility_id = l_responsibility_id) THEN
        l_org_resp_access_flag := 'Y';
        EXIT;
      END IF;
      -- retrieve next user responsbility
      FETCH c_org_access INTO l_responsibility_id;
    END LOOP;

    CLOSE c_org_access;

  END IF; -- for the valid organization

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
       (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
  	   ,'Organization Responsibility Valid Access Flag:'|| l_org_resp_access_flag
       );
  END IF;

  RETURN l_org_resp_access_flag;

  IF G_DEBUG = 'Y' THEN
   INV_ORGHIERARCHY_PVT.Log
  	 (INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
  	  ,'End of Proc:Org Hierarchy Level Responsibility Access'
        );
  END IF;

EXCEPTION

WHEN OTHERS THEN
  l_errorcode := SQLCODE;
  l_errortext := SUBSTR(SQLERRM,1,200);
  /*This executable is used by concurrent program so
    Error/Exception logging should not depend on
    FND Debug Enabled profile otpion. Log leve has b een
    changed from G_LOG_ERROR to G_LOG_EXCEPTION. Bug: 3555234
    IF G_DEBUG = 'Y' THEN
    */
    INV_ORGHIERARCHY_PVT.Log
          (INV_ORGHIERARCHY_PVT.G_LOG_EXCEPTION
  	     ,to_char(l_errorcode) || l_errortext
          );
    --END IF;
    RETURN NULL;

END Org_Hier_Level_Resp_Access;


--========================================================================
-- FUNCTION  : Org_Hier_Origin_Resp_Access   PUBLIC
-- PARAMETERS: p_api_version_number    known api version
--             p_org_id                  IN NUMBER Hierarchy Origin Id
--                                           (Organization Id)
--             p_responsibility_id       IN NUMBER Current Responsibility
--                                          Id
-- COMMENT   : API accepts the Organization Id of an organization
--             hierarchy origin(organization name),
--             current responsibility user has signed on and returns Y if
--             the organization is a valid organization (unexpired) and has
--             an access for the responsibility, N otherwise.
--=========================================================================
FUNCTION Org_Hier_Origin_Resp_Access
(     p_org_id                   IN   NUMBER,
      p_responsibility_id        IN   NUMBER
)
RETURN VARCHAR2 IS


CURSOR c_origin_resp_access(c_org_id NUMBER, c_responsibility_id NUMBER ) IS
SELECT 'Y'
  FROM HR_ALL_ORGANIZATION_UNITS org
WHERE

-- expiration check
  org.organization_id  =  c_org_id
AND  (   org.date_to  >=  SYSDATE
     OR  org.date_to  IS  NULL
     )

-- inv security access check
AND  (  NOT EXISTS( SELECT 1 FROM ORG_ACCESS  acc
                    WHERE acc.organization_id  =  c_org_id )
     OR     EXISTS( SELECT 1 FROM ORG_ACCESS  acc
                    WHERE acc.organization_id    =  c_org_id
                    AND   acc.responsibility_id  =  c_responsibility_id
                  )
     );


l_origin_resp_access_flag VARCHAR2(1);

l_errorcode			NUMBER;
l_errortext			VARCHAR2(200);

BEGIN

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    (INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
     ,'Start of Proc:Org Hierarchy Origin Responsibility Access'
    );
  END IF;

  -- initialize the flag
  l_origin_resp_access_flag := 'N';

  -- check whether the organization is unexpired and has responsibility
  -- access
  OPEN c_origin_resp_access(p_org_id, p_responsibility_id);
  FETCH c_origin_resp_access
  INTO l_origin_resp_access_flag;

  IF c_origin_resp_access%NOTFOUND THEN
    RAISE_APPLICATION_ERROR(-20255,
          'organization has no access');
    /* This executable is used by concurrent program so
       Error/Exception logging should not depend on
       FND Debug Enabled profile otpion. Bug: 3555234
      IF G_DEBUG = 'Y' THEN
      */
      INV_ORGHIERARCHY_PVT.Log
  	     (INV_ORGHIERARCHY_PVT.G_LOG_ERROR
  	    ,'Organization Id has no access:' || to_char(p_org_id)
           );
      --END IF;
  END IF;

  CLOSE c_origin_resp_access;

  IF G_DEBUG = 'Y' THEN
   INV_ORGHIERARCHY_PVT.Log
       (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
  	   ,'Origin responsibility access flag:'|| l_origin_resp_access_flag
       );
  END IF;

  RETURN l_origin_resp_access_flag;

  IF G_DEBUG = 'Y' THEN
   INV_ORGHIERARCHY_PVT.Log
  	 (INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
  	  ,'End of Proc:Org Hierarchy Origin Responsibility Access'
        );
  END IF;

EXCEPTION

WHEN OTHERS THEN
  l_errorcode := SQLCODE;
  l_errortext := SUBSTR(SQLERRM,1,200);
  /*This executable is used by concurrent program so
    Error/Exception logging should not depend on
    FND Debug Enabled profile otpion. Log level has been
    changed from G_LOG_ERROR to G_LOG_EXCEPTION. Bug: 3555234
    IF G_DEBUG = 'Y' THEN
    */
    INV_ORGHIERARCHY_PVT.Log
          (INV_ORGHIERARCHY_PVT.G_LOG_EXCEPTION
  	     ,to_char(l_errorcode) || l_errortext
          );
    --END IF;
    RETURN NULL;

END Org_Hier_Origin_Resp_Access;


--========================================================================
-- FUNCTION  : Org_exists_in_hierarchy PUBLIC
-- PARAMETERS: p_organization_id       IN NUMBER  Inventory Organization Id
--
-- COMMENT   : This API accepts the organization id and returns Y if the
--             organization id exists in the index list
--=========================================================================
FUNCTION Org_exists_in_hierarchy
( p_organization_id             IN  NUMBER)
RETURN VARCHAR2 IS

l_org_index        BINARY_INTEGER;
l_org_exists_flag  VARCHAR2(1);

l_errorcode		NUMBER;
l_errortext		VARCHAR2(200);

BEGIN
  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    (INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
     ,'Start of Proc:Org exists in hierarchy'
    );
  END IF;

  -- initialize org exists flag
  l_org_exists_flag := 'N';

  -- assign the organization_id into binary integer data type
  l_org_index := p_organization_id;

  -- Check organization id exists
  -- note that index contains organization id
  IF g_orgid_index_list.EXISTS(l_org_index) THEN
        l_org_exists_flag := 'Y';
  END IF;

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
     ,'Organization exists flag:'|| l_org_exists_flag
     );
  END IF;

  RETURN l_org_exists_flag;

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    (INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
     ,'End of Proc:Org exists in hierarchy'
    );
  END IF;

EXCEPTION

WHEN OTHERS THEN
  l_errorcode := SQLCODE;
  l_errortext := SUBSTR(SQLERRM,1,200);
  /*This executable is used by concurrent program so
    Error/Exception logging should not depend on
    FND Debug Enabled profile otpion. Log level has been
    changed from G_LOG_ERROR to G_LOG_EXCEPTION. Bug: 3555234
   IF G_DEBUG = 'Y' THEN
   */
   INV_ORGHIERARCHY_PVT.Log
          (INV_ORGHIERARCHY_PVT.G_LOG_EXCEPTION
  	     ,to_char(l_errorcode) || l_errortext
          );
   --END IF;
   RETURN NULL;

END Org_exists_in_hierarchy;



--========================================================================
-- PROCEDURE : Insert_hierarchy_index_list PUBLIC
-- PARAMETERS: p_orgid_tbl_list  IN orgID_tbl_type Orgid list of an
--                                                  hierarchy
-- COMMENT   : This API copies the organization list into the global
--             variable organization id index list.  The table index is
--             the organization_id
--             This api is used in the form: Transaction Open Interface
--========================================================================
PROCEDURE Insert_hierarchy_index_list
 ( p_orgid_tbl_list   IN orgID_tbl_type)
IS

  l_org_index BINARY_INTEGER;
  l_organization_id hr_all_organization_units.organization_id%TYPE;

BEGIN
  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    (INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
     ,'Start of Proc: Insert hierarchy index list'
    );
  END IF;

  FOR v_index IN p_orgid_tbl_list.FIRST .. p_orgid_tbl_list.LAST LOOP
    l_organization_id := p_orgid_tbl_list(v_index);
    l_org_index := l_organization_id;
    g_orgid_index_list(l_org_index) := l_organization_id;
  END LOOP;

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    (INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
     ,'End of Proc: Insert hierarchy index list'
    );
  END IF;

END;



--========================================================================
-- PROCEDURE  : Log_Initialize   PUBLIC
-- COMMENT   : Initializes the log facility. It should be called from
--             the top level procedure of each concurrent program
--=======================================================================--
PROCEDURE Log_Initialize
IS
BEGIN
  g_log_level  := TO_NUMBER(FND_PROFILE.Value('AFLOG_LEVEL'));
  IF g_log_level IS NULL THEN
    g_log_mode := 'OFF';
  ELSE
    IF (TO_NUMBER(FND_PROFILE.Value('CONC_REQUEST_ID')) <> 0) THEN
      g_log_mode := 'SRS';
    ELSE
      g_log_mode := 'SQL';
    END IF;
  END IF;

END Log_Initialize;


--========================================================================
-- PROCEDURE : Log                        PUBLIC
-- PARAMETERS: p_level                IN  priority of the message - from
--                                        highest to lowest:
--                                          -- G_LOG_ERROR
--                                          -- G_LOG_EXCEPTION
--                                          -- G_LOG_EVENT
--                                          -- G_LOG_PROCEDURE
--                                          -- G_LOG_STATEMENT
--             p_msg                  IN  message to be print on the log
--                                        file
-- COMMENT   : Add an entry to the log
--=======================================================================--
PROCEDURE Log
( p_priority                    IN  NUMBER
, p_msg                         IN  VARCHAR2
)
IS
BEGIN
  --Additional IF clause is added to print log message if Priority is
  --Error or Exception. Bug: 3555234
  IF ((p_priority = G_LOG_ERROR) OR
      (p_priority = G_LOG_EXCEPTION) OR
      (p_priority = G_LOG_PRINT) OR
     ((g_log_mode <> 'OFF') AND (p_priority >= g_log_level)))
   THEN
    IF g_log_mode = 'SQL'
    THEN
      -- SQL*Plus session: uncomment the next line during unit test
      -- DBMS_OUTPUT.put_line(p_msg);
      NULL;
    ELSE
      -- Concurrent request
      FND_FILE.put_line
      ( FND_FILE.log
      , p_msg
      );
    END IF;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END Log;


END INV_ORGHIERARCHY_PVT;

/
