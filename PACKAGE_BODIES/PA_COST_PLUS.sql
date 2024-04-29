--------------------------------------------------------
--  DDL for Package Body PA_COST_PLUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_COST_PLUS" as
-- $Header: PAXCCPEB.pls 120.18.12010000.6 2010/01/20 11:00:02 atshukla ship $
--  Package constants
NO_DATA_FOUND_ERR   number          :=  100;
INDIRECT_COST_CODE  varchar2(30)  :=  'INDIRECT COST';
G_MODULE                varchar2(10)  := 'XXX';                      /*3005625*/
/*3005625 : Added variable G_MODULE -this is set to value 'NEW_ORG' whenver
process Added New organization is run i.e new_organization is called.
This is to generate compiled multipliers for the new organization in
all the burden schedule revisions (even when nothing has changed in the
revision i.e ready_to_compile_flag is <>'Y'/'X')*/

/* Start : Add a variable (G_GMS_ENABLED) to hold the value of GMS implemented status
**         for Operating  Unit  with a default value of NULL
**         2981752 - PA.L:BURDENING ENHANCEMENTS : TRACKING BUG
*/

/*Added these variables for the bug 4527736*/
G_RATE_SCH_REVISION_ID           PA_IND_RATE_SCH_REVISIONS.IND_RATE_SCH_REVISION_ID%TYPE ;
G_CP_STRUCTURE                   PA_COST_PLUS_STRUCTURES.COST_PLUS_STRUCTURE%TYPE;
G_ORG_STRUC_VER_ID               PA_IND_RATE_SCH_REVISIONS.ORG_STRUCTURE_VERSION_ID%TYPE;
G_START_ORGANIZATION_ID          PA_IND_RATE_SCH_REVISIONS.START_ORGANIZATION_ID%TYPE;

G_IMPACTED_COST_BASES_TAB        PA_PLSQL_DATATYPES.Char30TabTyp;
G_EXPENDITURE_ITEM_ID_TAB        PA_PLSQL_DATATYPES.IDTABTYP;
G_ADJ_TYPE_TAB                   PA_PLSQL_DATATYPES.Char30TabTyp;

/*
 * Private Procedure.
 */
PROCEDURE Cache_Impacted_Cost_Bases ( P_Ind_Rate_Sch_Revision_Id IN PA_IND_RATE_SCH_REVISIONS.IND_RATE_SCH_REVISION_ID%TYPE
                                  ,P_Cp_Structure             IN PA_COST_PLUS_STRUCTURES.COST_PLUS_STRUCTURE%TYPE
                           );
/* End Bug# 4527736 */

G_gms_enabled varchar2(1):= gms_pa_api3.grants_enabled ;


/*   End : Add a variable (G_GMS_ENABLED) to hold the value of GMS implemented status
**         for Operating  Unit  with a default value of NULL.
**         2981752 - PA.L:BURDENING ENHANCEMENTS : TRACKING BUG
*/


-- Package type
   TYPE precedence_tab_type IS TABLE OF pa_compiled_multipliers.precedence%TYPE
        INDEX BY BINARY_INTEGER;
   TYPE ind_cost_code_tab_type IS TABLE OF
        pa_compiled_multipliers.ind_cost_code%TYPE INDEX BY BINARY_INTEGER;
   TYPE multiplier_tab_type IS TABLE OF pa_ind_cost_multipliers.multiplier%TYPE
        INDEX BY BINARY_INTEGER;

/***Bug# 2933915:Cursor for selecting impacted cost bases for which :
****the organization/cost code has ready_to_compile_flag as 'Y' or 'X' i.e the multiplier is modified or deleted respectively in
    pa_ind_cost_multipliers
    OR
****G_MODULE ='NEW_ORG' i.e when we need to generate new compiled set ids in all the revisions for a new organization even when there
    is no change to the burden schedule******************************/

CURSOR impacted_cost_bases(rate_sch_rev_id NUMBER)
IS
  SELECT pcb.COST_BASE
    FROM PA_COST_BASES pcb
   WHERE pcb.COST_BASE_TYPE = INDIRECT_COST_CODE
     AND EXISTS
     (
      SELECT 1            /* Bug# 4527736 */
        FROM PA_COST_BASE_COST_CODES CBICC,
             PA_IND_COST_MULTIPLIERS ICM,
             PA_IND_RATE_SCH_REVISIONS IRSR
       WHERE IRSR.IND_RATE_SCH_REVISION_ID = ICM.IND_RATE_SCH_REVISION_ID
         AND IRSR.IND_RATE_SCH_REVISION_ID = rate_sch_rev_id
         AND (NVL(ICM.READY_TO_COMPILE_FLAG,'N') IN ('Y','X')
               OR NVL(G_MODULE ,'XXX') = 'NEW_ORG')
         AND IRSR.COST_PLUS_STRUCTURE = CBICC.COST_PLUS_STRUCTURE
         AND CBICC.IND_COST_CODE = ICM.IND_COST_CODE
         AND CBICC.COST_BASE = PCB.COST_BASE
         AND CBICC.COST_BASE_TYPE = PCB.COST_BASE_TYPE );

/*End of change 2933915*/
--
--  PROCEDURE
--             compile_org_rates
--
--  PURPOSE
--             The objective of this procedure is to compile the rates of
--              indirect costs.  An expenditure item may associate with a
--              couple of indirect costs.  The amount of these indirect costs
--              is the product of the raw cost of expenditure item and the
--              indirect cost rate.  The indirect cost rate is based on
--              rate schedule, cost base, and organization.  This procedure
--              will compile indirect cost rates for a specific rate schedule,
--              cost base, and organization.  Moreover, the indirect cost
--              rates of all descendant organizations are compiled as well.
--
--  CONSTRAINTS
--    The mulipliers of the top organization MUST be specified.
--
--
--  HISTORY
--   07-JUN-94      S Lee          Added status and stage
--   29-MAR-94      S Lee          Modified for using new database schema and
--                  application standards
--   18-NOV-93      S Lee          Revamped
--   28-SEP-93      S Lee          Created
--


procedure compile_org_rates (rate_sch_rev_id IN number,
                  org_id            IN     number,
                  org_struc_ver_id  IN     number,
                  start_org        IN     number,
                  status      IN OUT NOCOPY number,
                  stage       IN OUT NOCOPY number)
IS

   --
   --  CONSTANT definition
   --

   --
   --  VARIABLE definition
   --

   base pa_compiled_multipliers.compiled_multiplier%TYPE;
   defined_org_id hr_organization_units.organization_id%TYPE;
   ind_cost_multiplier pa_ind_cost_multipliers.multiplier%TYPE;
   old_cost_base pa_cost_bases.cost_base%TYPE DEFAULT NULL;
   old_precedence pa_cost_base_cost_codes.precedence%TYPE DEFAULT NULL;
   ind_cost_multiplier_sum pa_ind_cost_multipliers.multiplier%TYPE;
   compiled_set_id pa_ind_compiled_sets.ind_compiled_set_id%TYPE;
   org_override NUMBER(15) DEFAULT 0;
   l_start_date DATE;
   l_end_date DATE;
   l_org_override NUMBER(15) DEFAULT 0;                                  /*2933915*/

   -- Standard who
   x_last_updated_by          NUMBER(15);
   x_created_by          NUMBER(15);
   x_last_update_login        NUMBER(15);
   x_request_id               NUMBER(15);
   x_program_application_id   NUMBER(15);
   x_program_id               NUMBER(15);

   --
   --  CURSOR definition
   --
   /*2933915 :Modified the existing ind_cost_code_cursor to select for impacted cost bases ONLY and not for all the
     cost bases as was earlier*/

/* Replaced this cursor with the below defined cursor for the bug 4527736
  CURSOR ind_cost_code_cursor(x_base VARCHAR2) IS                                            -- 2933915
      SELECT
       cbicc.cost_base_cost_code_id,
       cbicc.cost_base,
       cbicc.ind_cost_code,
       cbicc.precedence
          FROM  pa_cost_base_cost_codes cbicc,
                pa_ind_rate_sch_revisions irsr
          WHERE irsr.ind_rate_sch_revision_id = rate_sch_rev_id
                AND irsr.cost_plus_structure =  cbicc.cost_plus_structure
                AND cbicc.cost_base =  x_base                                            -- 2933915
                        AND cbicc.cost_base_type = INDIRECT_COST_CODE
          ORDER BY
                cbicc.cost_base, cbicc.precedence;
*/

  CURSOR ind_cost_code_cursor(x_base VARCHAR2) IS
      SELECT
       cbicc.cost_base_cost_code_id,
       cbicc.cost_base,
       cbicc.ind_cost_code,
       cbicc.precedence
          FROM  pa_cost_base_cost_codes cbicc
          WHERE cbicc.cost_plus_structure = G_CP_STRUCTURE
                AND cbicc.cost_base =  x_base
                        AND cbicc.cost_base_type = INDIRECT_COST_CODE
          ORDER BY
                cbicc.cost_base, cbicc.precedence;
--
--   Procedure body
--


BEGIN

   status := 0;
   stage := 100;

   --
   -- Get the standard who information
   --
   x_created_by               := FND_GLOBAL.USER_ID;
   x_last_updated_by          := FND_GLOBAL.USER_ID;
   x_last_update_login        := FND_GLOBAL.LOGIN_ID;
   x_request_id               := FND_GLOBAL.CONC_REQUEST_ID;
   x_program_application_id   := FND_GLOBAL.PROG_APPL_ID;
   x_program_id               := FND_GLOBAL.CONC_PROGRAM_ID;


   -- Get the standard who information
   --
   -- Compile the indirect cost rates for this organization.
   -- First check if there is an override on this organization.
   -- If so, compile rates for this organization, and create a new set.
   -- If not, use the compiled set of its parent organization.
   --

 /*2933915 :Whatever org is passed here -we are ensuring this in the calling procedure that it has proper value of
   ready to compile flag i.e 'N','Y','X' respectively depending on whether the multiplier is deleted ,changed or not changed
   for that ORG .  BUT we also need to ensure that if  EXPLICIT multipliers are defined for an org for ALL
   cost codes belonging to AFFECTED cost bases then new CSID should not be generated for that ie it should not be recompiled
   If multipliers are not found for ANY of the cost code then we should go ahead with compiling new one*/


   BEGIN
      SELECT /*+ FIRST_ROWS */
        1
      INTO org_override
      FROM sys.dual WHERE EXISTS
       (SELECT /*+ FIRST_ROWS */
               1
        FROM   pa_ind_cost_multipliers
        WHERE  ind_rate_sch_revision_id = rate_sch_rev_id
        AND    organization_id = org_id
           AND     nvl(ready_to_compile_flag,'N') <> 'X') ;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
      org_override := 0;                           /**Multipliers are not found for any of the cost code for this org**/
      WHEN OTHERS THEN
         status := SQLCODE;
      return;
   END;

 IF check_for_explicit_multiplier(rate_sch_rev_id, org_id) = 0 THEN /*Bug 4739218 */

   IF org_override = 0 THEN
      --
      --  This organization does not have cost override.  Therefore, its
      --  compiled rate is as same as its parent organization.
      --  Bug# 2933915 : Adding loop for doing this only for impacted cost bases
--    4527736
--    FOR cost_base_rec in impacted_cost_bases(rate_sch_rev_id)                                      /*2933915*/
IF G_IMPACTED_COST_BASES_TAB.COUNT <> 0 THEN /*4590268*/

     FOR i IN G_IMPACTED_COST_BASES_TAB.FIRST .. G_IMPACTED_COST_BASES_TAB.LAST
     LOOP

      BEGIN

      --
      --  Get the set id information from its parent organization
      --

         SELECT /*+ ORDERED
                    INDEX(ose PER_ORG_STRUCTURE_ELEMENTS_FK4)
                    INDEX(ics PA_IND_COMPILED_SETS_N1) */
                 ics.ind_compiled_set_id
         INTO compiled_set_id
            FROM per_org_structure_elements ose,
              pa_ind_compiled_sets ics
               WHERE ose.organization_id_child = org_id
              AND ose.org_structure_version_id = org_struc_ver_id
              AND ose.organization_id_parent = ics.organization_id
              AND ics.ind_rate_sch_revision_id = rate_sch_rev_id
                 --4527736
           -- AND ics.cost_base  = cost_base_rec.cost_base                                   /*2933915*/
              AND ics.cost_base  = G_IMPACTED_COST_BASES_TAB(i)
              AND ics.status = 'A';

      --
      --  Add the set id information to this organization
      --
/*S.O. 4888548
      INSERT INTO pa_ind_compiled_sets
            (ind_compiled_set_id,
          ind_rate_sch_revision_id,
          organization_id,
          cost_base,                                                                        /*2933915*
          last_update_date,
          last_updated_by,
          created_by,
          creation_date,
          last_update_login,
          request_id,
          program_application_id,
          program_id,
          program_update_date,
          status)
      VALUES(compiled_set_id,
             rate_sch_rev_id,
          org_id,
             --4527736
          -- cost_base_rec.cost_base,                                                         /*2933915
          G_IMPACTED_COST_BASES_TAB(i),
          SYSDATE,
             x_last_updated_by,
             x_created_by,
             SYSDATE,
          x_last_update_login,
          x_request_id,
          x_program_application_id,
          x_program_id,
          SYSDATE,
          'A');
E.O. 4888548 */

/*S.N. 4888548 */
      INSERT INTO pa_ind_compiled_sets
            (ind_compiled_set_id,
          ind_rate_sch_revision_id,
          organization_id,
          cost_base,
          last_update_date,
          last_updated_by,
          created_by,
          creation_date,
          last_update_login,
          request_id,
          program_application_id,
          program_id,
          program_update_date,
          status)
      SELECT compiled_set_id,
             rate_sch_rev_id,
             org_id,
             --4527736
             -- cost_base_rec.cost_base,
              G_IMPACTED_COST_BASES_TAB(i),
             SYSDATE,
             x_last_updated_by,
             x_created_by,
             SYSDATE,
             x_last_update_login,
             x_request_id,
             x_program_application_id,
             x_program_id,
             SYSDATE,
             'A'
      FROM DUAL
      WHERE NOT EXISTS
      ( SELECT 1 from pa_ind_compiled_sets ics
        WHERE  ics.ind_rate_sch_revision_id =rate_sch_rev_id
        AND    ics.organization_id = org_id
        AND    ics.cost_base = G_IMPACTED_COST_BASES_TAB(i)
        AND    ics.status='A'
      ) ;
 /*E.N. 4888548 */


     EXCEPTION
         WHEN NO_DATA_FOUND THEN
             --
          --  The parent organization has not been compiled yet.
          --  or this organization does not have a parent organization.
          --  We will compile a new set for this organization.
          --
           l_org_override := -1 ;

         WHEN OTHERS THEN
          --
          --  This rate schedule for this organization has been compiled
          --  previously.  The compiled set must be deleted before
          --  adding the new set id.
          --
          status := SQLCODE;
          RETURN;

    END;

   END LOOP;  /*End of impacted_cost_bases loop :2933915*/

END IF; /*4590268*/

     IF l_org_override = 0 THEN              /*2933915 :Compiled set id found for all the impacted cost bases for the parent org*/
        COMMIT;
        RETURN ;
     END IF ;

   END IF; /*End if org_override =0*/
END IF; /* Bug 4739218 */
/**2933915 :
If EXPLICIT multipliers are defined for ALL the cost codes in that structure for this org then any change in parent orgs would not
impact the child org and hence recompilation is not required so return to the calling procedure to get the next org *******/

 IF (org_override = 1 OR l_org_override =-1) THEN
    --4527736
    --FOR cost_base_rec in impacted_cost_bases(rate_sch_rev_id)
   IF G_IMPACTED_COST_BASES_TAB.COUNT <> 0 THEN /*4590268*/

     FOR i IN G_IMPACTED_COST_BASES_TAB.FIRST .. G_IMPACTED_COST_BASES_TAB.LAST
     LOOP
      --4527736
      --FOR cost_code_rec in ind_cost_code_cursor(cost_base_rec.cost_base)     **2933915 :Cost codes of impacted cost bases**
      FOR cost_code_rec in ind_cost_code_cursor(G_IMPACTED_COST_BASES_TAB(i))
        LOOP
           BEGIN
            SELECT /*+ FIRST_ROWS */
             1
             INTO l_org_override
             FROM sys.dual WHERE EXISTS
             (SELECT /*+ FIRST_ROWS */
               1
              FROM   pa_ind_cost_multipliers icm,
                  pa_ind_compiled_sets ics
           WHERE  icm.ind_rate_sch_revision_id =ics.ind_rate_sch_revision_id
             AND  icm.ind_rate_sch_revision_id = rate_sch_rev_id
             AND  icm.organization_id =ics.organization_id
             AND  icm.organization_id = org_id
             --AND  ics.cost_base = cost_base_rec.cost_base   --4527736
             AND  ics.cost_base = G_IMPACTED_COST_BASES_TAB(i)
             AND  ics.status ='A'
             AND  icm.ind_cost_code =cost_code_rec.ind_cost_code
             AND  nvl(icm.ready_to_compile_flag,'N') <>'X');        /*Should not consider 'X' records as they are actually
                                                                     deleted records */

           EXCEPTION
             WHEN NO_DATA_FOUND THEN
           l_org_override := 0;
             WHEN OTHERS THEN
              status := SQLCODE;
           return;
              END;
        END LOOP;  /*End loop ind_cost_code_cursor*/

        IF l_org_override =0 THEN
          EXIT;
           END IF;
      END LOOP;    /*End loop impacted_cost_bases*/
   END IF; /*4590268*/

   IF l_org_override =1 THEN   /***Bug 2933915 :Explicit multipliers found for all the cost codes in impacted cost bases*/
    RETURN ;
    END IF ;
 END IF;     /*End if of org_overrride OR l_orgoverride... */

 /****End of changes for bug# 2933915******/

   --
   --  Okay, there is override for this organization.  We need to compile a
   --  new set of multipliers.  First pick up a number for set id.
   --

   stage := 200;

   SELECT pa_ind_compiled_sets_s.NEXTVAL into compiled_set_id FROM sys.dual;


   SAVEPOINT before_adding_multipliers;

   BEGIN

   <<process_ind_cost_codes>>
 --FOR cost_base_rec in impacted_cost_bases(rate_sch_rev_id) --4527736
IF G_IMPACTED_COST_BASES_TAB.COUNT <> 0 THEN /*4590268*/

 FOR i IN G_IMPACTED_COST_BASES_TAB.FIRST .. G_IMPACTED_COST_BASES_TAB.LAST --4527736
 LOOP

    --FOR icc_row IN ind_cost_code_cursor(cost_base_rec.cost_base) LOOP --4527736
    FOR icc_row IN ind_cost_code_cursor(G_IMPACTED_COST_BASES_TAB(i)) LOOP --4527736

      --
      --  We want to get the multiplier for this organization.
      --  First set the current organization as the starting point.
      --  If the multiplier is not found, we will go one level higher.
      --
      defined_org_id := org_id;

      <<find_multiplier>>
      LOOP
      --
      -- Retrieve the value of multiplier from the pre-defined table
      --
      BEGIN
           --
           --  Find out whether the ICM of this organization is defined or not.
        --  If so, retrieve the ICM and exit the loop.
           --  If not, trace upward to see whether its parent organization is
        --  defined or not.
           --

           SELECT multiplier
            INTO ind_cost_multiplier
               FROM
                    pa_ind_cost_multipliers
               WHERE
                    organization_id = defined_org_id
                    AND ind_cost_code = icc_row.ind_cost_code
                    AND ind_rate_sch_revision_id = rate_sch_rev_id
                    AND nvl(ready_to_compile_flag,'N') <> 'X' ;     /*3005954 :Multipliers of deleted(i.e marked for deletion
                                                                     internally) record for org should not be considered*/

        --
        --  If NO_DATA_FOUND exception is not raised, the multiplier is
        --  defined.  Exit this loop.
        --

        EXIT;


         EXCEPTION
         WHEN NO_DATA_FOUND THEN
            --
            --  Verify whether we have reached the top of organization
            --
            IF defined_org_id = start_org THEN
              --
              -- The multiplier is still not found at the top of the
              -- organization structure.  Set the ICM to 0.
              --
               ind_cost_multiplier := 0;
               EXIT;
            END IF;

            --
            --  Multiplier is not defined in this level.  Go up one level
            --  further.
            --

            SELECT organization_id_parent
             INTO defined_org_id
                FROM per_org_structure_elements
                 WHERE
                    organization_id_child = defined_org_id
                    AND org_structure_version_id = org_struc_ver_id;

         WHEN OTHERS THEN
          status := SQLCODE;
          RETURN;

      END;

      END LOOP find_multiplier;

      stage := 300;

      --
      --  Check whether this is a new cost base.  If yes, change
      --  the base of calculation.
      --

      IF (old_cost_base IS NULL) OR
      (icc_row.cost_base <> old_cost_base) THEN
      --
      --  Base is used to compile the multipier.
      --  Base is set to 1 when using a new cost base.
      --

      base := 1;

      --
      --  ind_cost_multiplier_sum is used to store the summation of
      --  compiled multipliers which have the same precedence.
      --  Set to 0 at for the first indirect cost code.
      --

      ind_cost_multiplier_sum := 0;

      ELSE
      --
      --  The cost base of this indirect cost code is as same as the
      --  previous one.
      --

       IF old_precedence <> icc_row.precedence THEN
             --
             --  The calculation base will grow when the compiled rate
             --  of previous indirect cost code is added into the base.
             --  The current indirect cost code has a higher precedence,
             --  hence change the base of calculation.
             --

              base := base * (1 + ind_cost_multiplier_sum);

             --
             --  Reset the sum whenever the precedence is changed.
             --

              ind_cost_multiplier_sum := 0;

         END IF;
      END IF;

      --
      --  Enter the compiled rate into table
      --

       INSERT INTO pa_compiled_multipliers
          (ind_compiled_set_id,
           cost_base_cost_code_id,
           cost_base,
           ind_cost_code,
           precedence,
           compiled_multiplier,
           multiplier,
           last_update_date,
           last_updated_by,
           created_by,
           creation_date,
           last_update_login,
           request_id,
           program_application_id,
           program_id,
           program_update_date)
          VALUES
          (compiled_set_id,
           icc_row.cost_base_cost_code_id,
           icc_row.cost_base,
           icc_row.ind_cost_code,
           icc_row.precedence,
           base * ind_cost_multiplier,
           ind_cost_multiplier,
           SYSDATE,
           x_last_updated_by,
           x_created_by,
           SYSDATE,
           x_last_update_login,
           x_request_id,
           x_program_application_id,
           x_program_id,
           SYSDATE
          );


      --
      --  1. Get the summation of indirect cost multipliers that have
      --  the same precedence.
      --  2. Keep the old precedence in order to know when to change
      --  base.
      --  3. Memorize the current cost base.
      --
      ind_cost_multiplier_sum := ind_cost_multiplier_sum + ind_cost_multiplier;
      old_precedence := icc_row.precedence;

      /*Bug# 2933915 : Insert Compiled sets ids for organization_id/Cost_base combination .
        Earlier CSID was inserted for organization.Now it has to be inserted for organization_id/Cost_base combination */

    IF (old_cost_base is NULL) OR (icc_row.cost_base <> old_cost_base) THEN                 /*Bug 2933915*/

/*S.N. 4888548
    INSERT INTO pa_ind_compiled_sets
        (ind_compiled_set_id,
         ind_rate_sch_revision_id,
         organization_id,
         cost_base,                                                                     /*Bug# 2933915
              last_update_date,
              last_updated_by,
              created_by,
              creation_date,
              last_update_login,
              request_id,
              program_application_id,
              program_id,
              program_update_date,
         status)
      VALUES
        (compiled_set_id,
         rate_sch_rev_id,
         org_id,
         icc_row.cost_base,                                                            /*Bug# 2933915
              SYSDATE,
         x_last_updated_by,
              x_created_by,
              SYSDATE,
              x_last_update_login,
              x_request_id,
              x_program_application_id,
              x_program_id,
              SYSDATE,
         'A'
         );
E.O. 4888548 */

/*S.N. 4888548 */
    INSERT INTO pa_ind_compiled_sets
        (ind_compiled_set_id,
         ind_rate_sch_revision_id,
         organization_id,
         cost_base,
              last_update_date,
              last_updated_by,
              created_by,
              creation_date,
              last_update_login,
              request_id,
              program_application_id,
              program_id,
              program_update_date,
         status)
      SELECT
         compiled_set_id,
         rate_sch_rev_id,
         org_id,
         icc_row.cost_base,
         SYSDATE,
         x_last_updated_by,
         x_created_by,
         SYSDATE,
         x_last_update_login,
         x_request_id,
         x_program_application_id,
         x_program_id,
         SYSDATE,
         'A'
      FROM DUAL
      WHERE NOT EXISTS
      ( SELECT 1 from pa_ind_compiled_sets ics
        WHERE  ics.ind_rate_sch_revision_id =rate_sch_rev_id
        AND    ics.organization_id = org_id
        AND    ics.cost_base =icc_row.cost_base
        AND    ics.status='A'
      ) ;
 /*E.N. 4888548 */

   END IF ;
    old_cost_base := icc_row.cost_base;                                                  /*2933915*/

    END LOOP process_ind_cost_codes;                                                     /*2933915*/
END LOOP ;  /*impacted_cost_base_cur*/                                                   /*2933915*/

END IF; /*4590268*/

 EXCEPTION
      WHEN OTHERS THEN
         --
         --  remove the multipliers which are defined previously
         --
         ROLLBACK TO before_adding_multipliers;
         status := SQLCODE;
         RETURN;

   END;
   --
   --  Commit the whole transaction now.
   --
   COMMIT;
   RETURN;

EXCEPTION
   WHEN OTHERS THEN
      status := SQLCODE;
      RETURN;

END compile_org_rates;


--
--  PROCEDURE
--             compile_org_hierarchy_rates
--
--  PURPOSE
--           The objective of this procedure is to create compiled rates for
--        the whole organization hierarchy using a specific rate schedule.
--
--  HISTORY
--
--   08-JUN-94      S Lee       Created
--


PROCEDURE compile_org_hierarchy_rates(rate_sch_rev_id IN number,
                                   org_id IN number,
                             comp_type IN varchar2,
                             status    IN OUT NOCOPY number,
                                   stage  IN OUT NOCOPY number)
IS
   CURSOR org_cursor(ver_id NUMBER)          /*Bug# 2933915 :removed bg_id for business_group_id from cursor as it is not reqd*/
   IS
      SELECT organization_id_child
      FROM   per_org_structure_elements
      CONNECT BY PRIOR organization_id_child = organization_id_parent
              AND  org_structure_version_id = ver_id
      START WITH organization_id_parent = org_id
              AND  org_structure_version_id = ver_id;

   /*business_gid Number;            Bug# 29399915*/
   org_struc_ver_id Number;
   start_org Number;


BEGIN

   status := 0;

org_struc_ver_id := G_ORG_STRUC_VER_ID;
start_org        := G_START_ORGANIZATION_ID ;
   /*
    * Commented for bug 4527736
    *
   pa_cost_plus.get_hierarchy_from_revision(rate_sch_rev_id,
                              org_struc_ver_id,
                              start_org,
                              status,
                              stage);


   IF status <> 0 THEN
      stage := 50;
      RETURN;
   END IF;
*/
   --
   -- First compile the current organization
   --

   if (comp_type = 'INCREMENTAL') then

       pa_cost_plus.disable_sch_rev_org(rate_sch_rev_id,
                           org_id,
                           status,
                           stage);

   end if;

   pa_cost_plus.compile_org_rates(rate_sch_rev_id,
                         org_id,
                      org_struc_ver_id,
                      start_org,
                      status,
                      stage);

   IF status <> 0 THEN
      RETURN;
   END IF;

   --
   --  Compile all the organizations under this organization
   --  Ues the for loop cursor to fetch one qualified row at a time
   --

   <<process_org>>
   FOR org_row IN org_cursor(org_struc_ver_id)            /*29399915 -Removed business_gid as it is not required */
   LOOP

      --
      -- Create the compiled multipliers for the every organization.
      --

      if (comp_type = 'INCREMENTAL') then

      pa_cost_plus.disable_sch_rev_org(rate_sch_rev_id,
                           org_row.organization_id_child,
                           status,
                           stage);

      end if;

      pa_cost_plus.compile_org_rates(rate_sch_rev_id,
                     org_row.organization_id_child,
                     org_struc_ver_id,
                     start_org,
                     status,
                     stage);

      IF status <> 0 THEN
         RETURN;
      END IF;

   END LOOP process_org;


   --
   --  Set the compilation time in the rate schedule revision
   --

   UPDATE pa_ind_rate_sch_revisions
   SET
     compiled_flag    = 'Y',
     compiled_date    = SYSDATE
   WHERE
     ind_rate_sch_revision_id    = rate_sch_rev_id;


END compile_org_hierarchy_rates;


--
--  PROCEDURE
--             new_organization
--
--  PURPOSE
--           The objective of this procedure is to create compiled rates for
--        a new organization and its sub-organizations
--
--  HISTORY
--
--   19-AUG-94      S Lee       Created
--


PROCEDURE new_organization(errbuf IN OUT NOCOPY varchar2,
                     retcode IN OUT NOCOPY varchar2,
                  organization_id IN varchar2)
IS
   -- Local variables
   l_org_id number;
   status number;
   stage number;
   l_org_exists        BOOLEAN;
  /* l_business_gid      NUMBER;  commented as it is not used :Bug 2933915*/
   l_org_struc_ver_id  NUMBER;
   l_start_org               NUMBER;
   l_compiled_set_id   NUMBER;

   -- Cursor definition

/*   CURSOR rev_cursor IS
      SELECT irsr.ind_rate_sch_revision_id
      FROM   pa_ind_rate_sch_revisions irsr
      WHERE  irsr.compiled_flag = 'Y'   -- revision has been compiled before
      AND    irsr.ready_to_compile_flag = 'Y';  -- compilation is not on hold
*** cusor commented for bug 3033195 */

   /*
    * Bug#1163654
    * cursor added to check the existence of compiled set information
    * for a given revision and organization.
    */

   CURSOR rev_org_cursor(p_rev_id IN NUMBER, p_org_id IN NUMBER) IS  /* p_org_id added for 3033195 */
     SELECT '1'
     FROM   pa_ind_compiled_sets cmp
     WHERE  cmp.organization_id = p_org_id
     AND    cmp.ind_rate_sch_revision_id = p_rev_id
     AND    status = 'A';

       -- Standard who
       x_last_updated_by            NUMBER(15);
       x_last_update_login          NUMBER(15);
       x_request_id                 NUMBER(15);
       x_program_application_id     NUMBER(15);
       x_program_id                 NUMBER(15);
       x_created_by                 NUMBER(15);

/* Two cursors added below for bug 3033195 */

Cursor rev_struct_cursor is
     SELECT ind_rate_sch_revision_id, org_structure_version_id,cost_plus_structure,start_organization_id /*4590268*/
     FROM pa_ind_rate_sch_revisions
     WHERE compiled_flag = 'Y'
     AND ready_to_compile_flag = 'Y'
     AND org_structure_version_id in
          (select org_structure_version_id
          from per_org_structure_elements
          where organization_id_child = l_org_id
     or organization_id_parent = l_org_id);

Cursor orgn_cursor(ver_id in NUMBER) is
     SELECT level, organization_id_child organization_id
     FROM   per_org_structure_elements
     CONNECT BY PRIOR organization_id_child = organization_id_parent
     AND  org_structure_version_id = ver_id
     START WITH organization_id_parent = l_org_id
     AND  org_structure_version_id = ver_id
     UNION ALL
     SELECT 0,l_org_id organization_id FROM dual
     ORDER BY 1;

BEGIN

       l_org_id := to_number(organization_id);
       G_MODULE := 'NEW_ORG';                                   /*3005625*/
       /*3005625 :G_MODULE is set to value 'NEW_ORG' whenver process Add New organization is
       run i.e new_organization is called.
       This is to generate compiled multipliers for the new organization in all the burden
       schedule revisions (even when nothing has changed in the revisions
       i.e ready_to_compile_flag is <>'Y'/'X')*/
       --
       -- Get the standard who information
       --
       x_last_updated_by            := FND_GLOBAL.USER_ID;
       x_last_update_login          := FND_GLOBAL.LOGIN_ID;
       x_request_id                 := FND_GLOBAL.CONC_REQUEST_ID;
       x_program_application_id     := FND_GLOBAL.PROG_APPL_ID;
       x_program_id                 := FND_GLOBAL.CONC_PROGRAM_ID;
       x_created_by                 := FND_GLOBAL.USER_ID;

       /* 3033195 */

       /*S.N. 4590268*/
       FOR rev_struct_row in rev_struct_cursor LOOP
           --###
             IF (nvl(G_RATE_SCH_REVISION_ID,-999)=rev_struct_row.ind_rate_sch_revision_id
                 AND nvl(G_CP_STRUCTURE,-999)= rev_struct_row.cost_plus_structure
                 AND G_IMPACTED_COST_BASES_TAB.count <> 0 ) THEN

                 NULL;

             ELSE
                 G_RATE_SCH_REVISION_ID  := rev_struct_row.ind_rate_sch_revision_id;
                 G_CP_STRUCTURE          := rev_struct_row.cost_plus_structure;

                 pa_cost_plus.Cache_Impacted_Cost_Bases( G_RATE_SCH_REVISION_ID
                                                        ,G_CP_STRUCTURE);
            END IF;

           G_ORG_STRUC_VER_ID      := rev_struct_row.org_structure_version_id;
           G_START_ORGANIZATION_ID := rev_struct_row.start_organization_id;
           /*E.N. 4590268*/

       FOR orgn_row in orgn_cursor(rev_struct_row.org_structure_version_id) LOOP

          l_org_exists := FALSE;

          FOR rev_org_row in rev_org_cursor(rev_struct_row.ind_rate_sch_revision_id,orgn_row.organization_id)
          LOOP
            l_org_exists := TRUE;
          END LOOP;

          IF l_org_exists THEN
            NULL;
          ELSE

          UPDATE pa_ind_rate_sch_revisions
          SET
            last_update_date = SYSDATE,
            last_updated_by = x_last_updated_by,
            last_update_login = x_last_update_login,
            request_id = x_request_id,
            program_application_id = x_program_application_id,
            program_id = x_program_id,
            program_update_date = SYSDATE
          WHERE
            ind_rate_sch_revision_id = rev_struct_row.ind_rate_sch_revision_id;

          COMMIT;

       pa_cost_plus.compile_org_hierarchy_rates(
                                     rev_struct_row.ind_rate_sch_revision_id,
                                     orgn_row.organization_id,
                         'INCREMENTAL',
                                     status,
                                     stage);

          if (status < 0) then
             errbuf := sqlerrm(status);
             retcode := 2;
             return;
          end if;

       END IF;  -- l_org_exists

       END LOOP;  -- orgn_cursor

       END LOOP;  -- rev_struct_cursor

EXCEPTION
  WHEN OTHERS THEN
    errbuf := sqlerrm(status);
    retcode := 2;
    RAISE;

END new_organization;

       /* Code Changes End for 3033195 . The old code below has been commented for better readability. */

       --
       -- compile all rate schedules
       --

--       FOR rev_row IN rev_cursor
--       LOOP
--
--
--         /*
--           * Bug#1163654
--           *
--           * If compiled set exists for a given Organization and revision, then
--           * no action is necessary. Else enter a record in the compiled set table
--           * for the given revision and organization with the compiled set id same as
--           * that of its parent
--           */
--
--          l_org_exists := FALSE;
--
--          FOR rev_org_row in rev_org_cursor(rev_row.ind_rate_sch_revision_id)
--          LOOP
--            l_org_exists := TRUE;
--          END LOOP;
--
--          /*Bug# 1851731:If compiled set information exists for a given organization and
--          revision then no action but instead of exiting from the procedure ,continue for
--          other revisions fetched by rev_cursor */
--
--          IF l_org_exists THEN
--            /*RETURN; Commented for bug# 1851731*/
--            NULL;                                        /*Bug# 1851731*/
--          ELSE
--
          --
          -- Set the compilation time in the rate schedule revision
          --

--          UPDATE pa_ind_rate_sch_revisions
--          SET
--          last_update_date = SYSDATE,
--          last_updated_by = x_last_updated_by,
--          last_update_login = x_last_update_login,
--          request_id = x_request_id,
--          program_application_id = x_program_application_id,
--          program_id = x_program_id,
--          program_update_date = SYSDATE
--          WHERE
--          ind_rate_sch_revision_id = rev_row.ind_rate_sch_revision_id;
--
--          COMMIT;
--
--          pa_cost_plus.compile_org_hierarchy_rates(
--                                     rev_row.ind_rate_sch_revision_id,
--                                     l_org_id,
--                       'INCREMENTAL',
--                                     status,
--                                     stage);
--
--          if (status < 0) then
--             errbuf := sqlerrm(status);
--             retcode := 2;
--             return;
--          end if;
--
--
--
/*Bug# 1851731:Commented the SELECT and INSERT below as they are redundant.*/
/*The code in SELECT and INSERT was carried over from R11.0 and introduced in*/
/*this procedure as part of code fix for bug# 1163654. But it is not required*/
/*here as code in R11i is restructured.*/

            /*
             * Get compiled set id of the parent.
             */
/*Bug# 1851731:
            SELECT + ORDERED
                       INDEX(ose PER_ORG_STRUCTURE_ELEMENTS_FK4)
                       INDEX(ics PA_IND_COMPILED_SETS_N1)
                    ics.ind_compiled_set_id
              INTO   l_compiled_set_id
              FROM   per_org_structure_elements ose,
                    pa_ind_compiled_sets ics
              WHERE  ose.organization_id_child = l_org_id
                AND    ose.org_structure_version_id = l_org_struc_ver_id
                AND    ose.organization_id_parent = ics.organization_id
                AND    ics.ind_rate_sch_revision_id = rev_row.ind_rate_sch_revision_id
                AND    ics.status = 'A';  Commented for bug# 1851731*/

            /*
             * Insert compiled set information
             */

/* Bug# 1851731 :  INSERT INTO pa_ind_compiled_sets
                    (ind_compiled_set_id,
                       ind_rate_sch_revision_id,
                       organization_id,
                       last_update_date,
                       last_updated_by,
                       created_by,
                       creation_date,
                       last_update_login,
                       request_id,
                       program_application_id,
                       program_id,
                       program_update_date,
                       status)
              VALUES(l_compiled_set_id,
                     rev_row.ind_rate_sch_revision_id,
                       l_org_id,
                     SYSDATE,
                     x_last_updated_by,
                     x_created_by,
                     SYSDATE,
                       x_last_update_login,
                       x_request_id,
                       x_program_application_id,
                       x_program_id,
                       SYSDATE,
                       'A');            Commented for bug# 1851731 */
--          END IF;
--       END LOOP;
--EXCEPTION
--  WHEN OTHERS THEN
--    errbuf := sqlerrm(status);
--    retcode := 2;
--    RAISE;
--
--END new_organization;


--
--  PROCEDURE
--             compile_schedule
--
--  PURPOSE
--                The objective of this procedure is to create compiled rates
--              using a specific rate schedule.
--
--  HISTORY
--
--   08-JUN-94      S Lee       Created
--


PROCEDURE compile_schedule(errbuf IN OUT NOCOPY varchar2,
                 retcode IN OUT NOCOPY varchar2,
                 sch_rev_id IN varchar2)

IS
   -- Local variables
  /* business_gid Number;   commented as it is not used :Bug 2933915*/
   org_struc_ver_id Number;
   start_org Number;

   status number;
   stage number;
   rate_sch_rev_id number;
   org_tab org_tab_type;        /*2933915*/        /*To store top impacted orgs*/
   lstatus number ;            /*2933915*/
   l_check number ;            /*3055700*/
   l_cp_structure              pa_cost_plus_structures.cost_plus_structure%TYPE ;  /*3055700*/
   -- Standard who
   x_last_updated_by            NUMBER(15);
   x_last_update_login          NUMBER(15);
   x_request_id                 NUMBER(15);
   x_program_application_id     NUMBER(15);
   x_program_id                 NUMBER(15);
   l_created_by                 NUMBER(15);                                       /*3055700*/

/*3055700 :cursor to select all the cost bases */
   CURSOR all_cost_bases
   IS
    SELECT
           distinct cost_base
      FROM  pa_cost_base_cost_codes
      WHERE  cost_plus_structure =l_cp_structure
       AND   cost_base_type = INDIRECT_COST_CODE ;

BEGIN
   lstatus :=0;  /*2933915*/
   status := 0;
   rate_sch_rev_id := sch_rev_id;
   G_RATE_SCH_REVISION_ID := rate_sch_rev_id;
   --
   -- Get the standard who information
   --
   x_last_updated_by            := FND_GLOBAL.USER_ID;
   x_last_update_login          := FND_GLOBAL.LOGIN_ID;
   x_request_id                 := FND_GLOBAL.CONC_REQUEST_ID;
   x_program_application_id     := FND_GLOBAL.PROG_APPL_ID;
   x_program_id                 := FND_GLOBAL.CONC_PROGRAM_ID;
   l_created_by                 := -999999;
   --
   --  Set the compilation time in the rate schedule revision
   --

   UPDATE pa_ind_rate_sch_revisions
   SET
     last_update_date = SYSDATE,
     last_updated_by = x_last_updated_by,
     last_update_login = x_last_update_login,
     request_id = x_request_id,
     program_application_id = x_program_application_id,
     program_id = x_program_id,
     program_update_date = SYSDATE
   WHERE
     --ind_rate_sch_revision_id = rate_sch_rev_id; 4527736
     ind_rate_sch_revision_id = G_RATE_SCH_REVISION_ID;
   COMMIT;

   --
   -- Get the current org_structure_version_id.
   -- Join can not be used in a CONNECT BY statement
   --


  pa_cost_plus.get_hierarchy_from_revision(G_RATE_SCH_REVISION_ID, /* 4527736 */
                              org_struc_ver_id,
                              start_org,
                              status,
                              stage);

   if (status < 0) then
      errbuf := sqlerrm (status);
      retcode := 2;
      return;
   end if;
   G_ORG_STRUC_VER_ID      := org_struc_ver_id;
   G_START_ORGANIZATION_ID := start_org;

/*Changes for Bug# 3055700:
Inserting dummy enteries of 0 in pa_ind_cost_multipliers for Start Org and all the cost
bases when the version is compiled .
This has to be done when there exists no compiled set ids for ALL the cost bases with
status 'A' for start_org .
This will ensure that the compiled set ids are generated for all the orgs in hierarchy
and all the cost bases .
Subsequently any changes in multiplies will affect only impacted org and
impacted cost base as per enhancement .
*********************************************************************************************/

pa_cost_plus.get_cost_plus_structure(rate_sch_rev_id,
                            l_cp_structure,
                         status,
                         stage);

  IF (status <> 0) THEN
    errbuf := sqlerrm (status);
    return;
  END IF;
  G_CP_STRUCTURE := l_cp_structure;

  /* 4527736
   * Call Cache_Impacted_Cost_Bases.
   */
/*  pa_cost_plus.Cache_Impacted_Cost_Bases( G_RATE_SCH_REVISION_ID
                                      ,G_CP_STRUCTURE); Commented for Bug 5181688 */

 Begin
 /*If for start_org there are compiled set ids present with status 'A' for ALL the cost bases then
   l_check = 1 else 0*/
 FOR base_rec in all_cost_bases
 LOOP
   select 1
    into l_check
    from sys.dual
   where exists(select 1
                 from pa_ind_compiled_sets
                where ind_rate_sch_revision_id =G_RATE_SCH_REVISION_ID /* 4527736 */
                 and organization_id =start_org
           and cost_base = base_rec.cost_base
                 and status ='A');
 END LOOP;
 Exception
 WHEN NO_DATA_FOUND THEN
 l_check :=0 ;
 End;

 IF (l_check =0) THEN
 /*If explicit multipliers are not defined for start org for ALL cost codes then only insert*/

  IF pa_cost_plus.check_for_explicit_multiplier(G_RATE_SCH_REVISION_ID ,start_org) =0 THEN  /* 0 means not present*/

 Begin

  INSERT into pa_ind_cost_multipliers (ind_rate_sch_revision_id,
                                         organization_id,
                                         ind_cost_code,
                                         multiplier,
                                         last_update_date,
                                         last_updated_by,
                                         created_by,
                                         creation_date,
                                         last_update_login,
                                         ready_to_compile_flag)
    select G_RATE_SCH_REVISION_ID,
           start_org,
           cbicc.ind_cost_code,
           0,
           SYSDATE,
           x_last_updated_by,
           l_created_by,
           SYSDATE,
           x_last_update_login,
           'Y'
    from   pa_cost_base_cost_codes cbicc
    where  cbicc.cost_plus_structure      = G_CP_STRUCTURE /* 4527736 */
    and    cbicc.cost_base_type           = INDIRECT_COST_CODE
    and    cbicc.ind_cost_code not in (select m.ind_cost_code
                                        from pa_ind_cost_multipliers m
                                        where m.ind_rate_sch_revision_id = G_RATE_SCH_REVISION_ID /* 4527736 */
                                         and  m.organization_id =start_org)
    group by cbicc.ind_cost_code;

 Exception
 WHEN OTHERS THEN
     status := SQLCODE;
 End ;
 End if ;
End if ;  /*l_check =0*/

/*End of changes for 3055700 */

/*Bug 5181688 */
pa_cost_plus.Cache_Impacted_Cost_Bases( G_RATE_SCH_REVISION_ID
                                      ,G_CP_STRUCTURE);


   /*2933915 :Added call to procedure find_impacted_top_org() that should return the PL/SQL table of
    AFFECTED TOP organization org_list*/
  /*Basically for this the hierarchy attached to the revision is traversed and we find the top most
    organizations out of the complete set of organizations for which the multipliers have changed.
   This is to avoid compiling ALL the organizations in the hierarchy as was happening earlier and hence
   to start compiling from the top most impacted orgs */

  /* 4527736 */
  pa_cost_plus.find_impacted_top_org(G_RATE_SCH_REVISION_ID,G_ORG_STRUC_VER_ID,start_org,org_tab,status);   /*2933915*/

    if (status < 0) then                                                                           /*2933915*/

      errbuf := sqlerrm (status);
      retcode := 2;
      return;
   end if;
   --
   --  Verify whether there is any costed expenditure item
   --

   -- 4527736
   pa_cost_plus.check_revision_used(G_RATE_SCH_REVISION_ID, lstatus, stage);                                /*2933915*/

   /*2933915 : FOR SELECTIVE DELETION AND OBSOLETION */
   /***Added a LOOP for the processing to go for each TOP IMPACTED organization returned by the above procedure in org_tab
   We are going to process for all the children of the top affected org **********/


 IF org_tab.exists(1) THEN
  FOR i in org_tab.first..org_tab.last
  LOOP

/*4642011   if (lstatus = 0) then    /*2933915*/


/*4642011  delete_rate_sch_revision(G_RATE_SCH_REVISION_ID,G_ORG_STRUC_VER_ID,org_tab(i),status,stage);        --2933915

       if (status < 0) then
         errbuf := sqlerrm (status);
         retcode := 2;
         return;
       end if; */

 /************************MOVED  ALL THIS to new procedure delete_rate_sch_revision()
      -

   if (status = 0) then

      --
      --  Remove redundant compiled sets and multipiers.
      --
      DELETE pa_compiled_multipliers
      WHERE  ind_compiled_set_id IN
          (SELECT ind_compiled_set_id
           FROM   pa_ind_compiled_sets
           WHERE  ind_rate_sch_revision_id = rate_sch_rev_id);

      DELETE pa_ind_compiled_sets
      WHERE  ind_rate_sch_revision_id = rate_sch_rev_id;
 ***************************************************************************************/
    /*4642011
   else
    /*4642011*/
      --
      --  Disable the current rate schedule if any
      --
      -- 4527736
      pa_cost_plus.disable_rate_sch_revision(G_RATE_SCH_REVISION_ID,G_ORG_STRUC_VER_ID,org_tab(i),status, stage );
      /*2933915 :ADDED org_struc_ver_id and org_id as parameter *****/
      if (status < 0) then
        errbuf := sqlerrm (status);
        retcode := 2;
        return;
      end if;

/*4642011
   end if;
/*4642011*/

   --
   -- Compile rates for all organizations starting from the top impacted organization
   --

   pa_cost_plus.compile_org_hierarchy_rates(G_RATE_SCH_REVISION_ID,
                                   org_tab(i),                /*2933915 : Replaced start_org by org_tab(i)*/
                             'ALL',
                                status,
                                stage);

   if (status < 0) then
      errbuf := sqlerrm (status);
      retcode := 2;
      return;
   end if;

  END LOOP ;                                 /*2933915*/
END IF ;                                     /*If org_tab.exists*/

   -- Mark impacted expenditure items for re-costing

   pa_cost_plus.mark_impacted_exp_items(G_RATE_SCH_REVISION_ID,status, stage);

   if (status < 0) then
      errbuf := sqlerrm (status);
      retcode := 2;
      return;
   end if;

/*2933915  :After compilation is over we need to reset the ready_to_compile_flag back to 'N' for this revision_id and also
  delete the records having ready_to_compile_flag as 'X' .
For reference :Ready_to_compile_flag 'X' records are actually deleted records but they were retained till this point of time for
processing and treating them as impacted records***/

/*3055700 :Deleting the dummy entries inserted earlier since by now processing is done*/
DELETE pa_ind_cost_multipliers
 where ind_rate_sch_revision_id    = G_RATE_SCH_REVISION_ID
 and   organization_id             = start_org
 and   created_by                  = l_created_by ;
/*3055700*/

DELETE pa_ind_cost_multipliers
where ind_rate_sch_revision_id    = G_RATE_SCH_REVISION_ID
and   nvl(ready_to_compile_flag,'N') ='X';

UPDATE pa_ind_cost_multipliers
set ready_to_compile_flag ='N'
where ind_rate_sch_revision_id    = G_RATE_SCH_REVISION_ID
and   nvl(ready_to_compile_flag,'N') ='Y';

COMMIT;

/*End of changes for bug 2933915*/

END compile_schedule;



--
--  PROCEDURE
--             compile_all
--
--  PURPOSE
--           The objective of this procedure is to create compiled rates
--           for all rate schedules which have been marked as 'ready to
--        compile'.
--
--  HISTORY
--
--   22-JUN-94      S Lee       Created
--


PROCEDURE compile_all(errbuf IN OUT NOCOPY varchar2,
                retcode IN OUT NOCOPY varchar2)

IS
   --
   -- Cursor definition
   --

  /*Bug 2933915 :We need to compile only the schedules wherein some multiplier has changed .Hence modified the cursor for the same.*/

   CURSOR sch_cursor
   IS
      SELECT ind_rate_sch_revision_id
          FROM pa_ind_rate_sch_revisions irsr
                  WHERE irsr.compiled_flag = 'N'
            AND     nvl(irsr.ready_to_compile_flag,'N') = 'Y'
            AND EXISTS (Select 1
                        from pa_ind_cost_multipliers icm
                               WHERE  icm.ind_rate_sch_revision_id = irsr.ind_rate_sch_revision_id
                                AND     nvl(icm.ready_to_compile_flag,'N') in ('Y','X'));

   -- Local variables

   sch_rev_id      varchar2(30);

BEGIN

   <<process_sch>>
   FOR sch_row IN sch_cursor
   LOOP

       BEGIN
          sch_rev_id := sch_row.ind_rate_sch_revision_id;

          pa_cost_plus.compile_schedule(errbuf,
                                        retcode,
                                        sch_rev_id);

       END;

   END LOOP process_sch;

END compile_all;



--
--  PROCEDURE
--             get_exp_item_indirect_cost
--
--  PURPOSE
--             The objective of this procedure is to retrieve the total
--        indirect cost for an expenditure item.  User can specify the
--        expenditure item information and the type of indirect rate
--        schedule, and get the total amount of indirect cost associated
--        with the expenditure item.
--
--  Note:       This procedure gets called from both the project and expenditure
--              oriented process. Hence should always refer to the base tables
--              and not the Morg view.
--
--  HISTORY
--
--   10-JUN-94      S Lee          Created
--


/*
  Multi-Currency Related Changes:
  Two new parameters added
                           indirect_cost_acct
                           indirect_cost_denom
 */
procedure get_exp_item_indirect_cost(exp_item_id         IN     Number,
                                     schedule_type       IN     Varchar2,
                                     indirect_cost       IN OUT NOCOPY Number,
                                     indirect_cost_acct  IN OUT NOCOPY Number,
                                     indirect_cost_denom IN OUT NOCOPY Number,
                                     indirect_cost_project IN OUT NOCOPY Number, /* EPP */
                                     rate_sch_rev_id     IN OUT NOCOPY Number,
                                     compiled_set_id     IN OUT NOCOPY Number,
                                     status              IN OUT NOCOPY Number,
                                     stage               IN OUT NOCOPY Number)

IS

--
--  Local variables
--

/*
  Multi-Currency Related Changes: New Local variables added
        direct_cost_denom, direct_cost_acct
        burden_cost_denom, burden_cost_acct
        compiled_multiplier
 */
exp_type                       Varchar2(30);
cp_structure                Varchar2(30);
c_base                         Varchar2(30);
org_id                         Number(15);
direct_cost                    Number(22,5);
direct_cost_denom             Number;
direct_cost_acct              Number;
direct_cost_project           Number;  /* ProjCurr Changes */
l_denom_currency_code                   VARCHAR2(15);
l_acct_currency_code                    VARCHAR2(15);
l_project_currency_code                 VARCHAR2(15);
l_projfunc_currency_code                VARCHAR2(15);
quantity                pa_expenditure_items_all.quantity%TYPE;
burden_cost             pa_expenditure_items_all.burden_cost%TYPE;
burden_cost_denom       pa_expenditure_items_all.denom_burdened_cost%TYPE;
burden_cost_acct        pa_expenditure_items_all.acct_burdened_cost%TYPE;
burden_cost_project        pa_expenditure_items_all.project_burdened_cost%TYPE; /* ProjCurr Changes */
system_linkage          pa_expenditure_items_all.system_linkage_function%TYPE;
compiled_multiplier     pa_compiled_multipliers.compiled_multiplier%TYPE;

BEGIN

   --  Initialize output parameters
   status := 0;
   stage := 100;
   indirect_cost := NULL;
   rate_sch_rev_id := NULL;
   compiled_set_id := NULL;

   --
   --  Retrieve the information of the expenditure item
   --  As this procedure can be called from project Oriented or Expenditure
   --  oriented process, hence the uderlying select uses base table.
   --

   /*
     Multi-Currency Related Changes:
     Select additional columns
         denom_raw_cost, Acct_raw_cost
         denom_burdened_cost,Acct_burdened_cost
    */
   SELECT expenditure_type,
       raw_cost,
     denom_raw_cost,
     acct_raw_cost,
     project_raw_cost,
       quantity,
       burden_cost,
     denom_burdened_cost,
     acct_burdened_cost,
     project_burdened_cost,  /* ProjCurr Changes */
     projfunc_currency_code, /* ProjCurr Changes */
     acct_currency_code,
     denom_currency_code,
     project_currency_code,
     system_linkage_function
   INTO   exp_type,
       direct_cost,
       direct_cost_denom,
       direct_cost_acct,
       direct_cost_project,
       quantity,
       burden_cost,
       burden_cost_denom,
       burden_cost_acct,
       burden_cost_project,    /* ProjCurr Changes */
     l_projfunc_currency_code,    /* ProjCurr Changes */
     l_acct_currency_code,
     l_denom_currency_code,
     l_project_currency_code,
     system_linkage
   FROM   pa_expenditure_items_all
   WHERE  expenditure_item_id = exp_item_id;

-- For Project Manufacturing, specifically BURDEN_TRANSACTIONS, raw_cost,
--  quantity will be zero but burden_cost will not be zero
--  For Billing purpose (Revenue and Invoicing) we will take burden_cost and
--  apply burden multipliers on burden_cost.
--
--  Except Burden Transactions, there will not be any items with raw_cost and
--  quantity=0 with burden_cost <> 0
--  Following query will be modified in R11 for getting system_linkage from
--  new intersection entity
--
   /*
     Multi-Currency Related Changes:
     Set direct_cost_denom and direct_cost_acct also.
    */
   IF (direct_cost = 0 AND quantity = 0 AND burden_cost <> 0)
      AND ( schedule_type='R' OR schedule_type='I')  THEN
        IF  ( system_linkage='BTC') THEN
           direct_cost       := burden_cost;
           direct_cost_denom := burden_cost_denom;
           direct_cost_acct  := burden_cost_acct;
           direct_cost_project  := burden_cost_project; /* epp */
        END IF;
   END IF;
   --
   --  Get the rate schedule revision id
   --

   pa_cost_plus.get_rate_sch_rev_id(exp_item_id,
                           schedule_type,
                        rate_sch_rev_id,
                        status,
                        stage);

  IF (status <> 0) THEN
      stage := 200;
      return;
  END IF;

  --
  -- Get the cost plus structure
  --

  pa_cost_plus.get_cost_plus_structure(rate_sch_rev_id,
                              cp_structure,
                           status,
                           stage);

  IF (status <> 0) THEN
      stage := 300;
      return;
  END IF;


  --
  -- Get the cost base
  --

  pa_cost_plus.get_cost_base(exp_type,
                    cp_structure,
                    c_base,
                    status,
                    stage);

  IF (status <> 0) THEN
     stage := 400;
     return;
  END IF;


  --
  -- Get the organization
  --

  pa_cost_plus.get_organization_id(exp_item_id,
                            org_id,
                              status,
                              stage);

  IF (status <> 0) THEN
     stage := 500;
     return;
  END IF;

   /*
     Multi-Currency Related Changes:
     The Call to Get_indirect_cost_sum is removed
    */
  --
  -- Get the indirect cost
  --

/*
  pa_cost_plus.get_indirect_cost_sum(org_id,
                            c_base,
                         rate_sch_rev_id,
                         direct_cost,
                         2,                     -- FOR US CURRENCY
                         indirect_cost,
                              status,
                              stage);

*/

   /*
     Multi-Currency Related Changes:
     Get_compiled_multiplier is called to get the sum of the compiled multipliers.
     Use that multiplier to get the indirect costs in all the currencies.
    */
  --
  -- Get the sum of the compiled Multipliers
  --

  /*
   * Bug#2110452
   * Commented to implement the same logic for burden cost calculation
   * as is used in R10.7/R11.0.
   *
   * pa_cost_plus.get_compiled_multiplier(org_id,
   *                                      c_base,
   *                                      rate_sch_rev_id,
   *                                      compiled_multiplier,
   *                                      status,
   *                                      stage);
   */

  /*
   * Bug#2110452
   * To implement the same logic as is used in R10.7/R11.0 for
   * burden cost calculation.
   */

   pa_cost_plus.get_indirect_cost_sum1 ( org_id                    => org_id
                                        ,c_base                    => c_base
                                        ,rate_sch_rev_id           => rate_sch_rev_id
                                        ,direct_cost               => direct_cost
                                        ,direct_cost_denom         => direct_cost_denom
                                        ,direct_cost_acct          => direct_cost_acct
                                        ,direct_cost_project       => direct_cost_project
                                        ,precision                 => 2                     -- FOR US CURRENCY
                                        ,indirect_cost_sum         => indirect_cost
                                        ,indirect_cost_denom_sum   => indirect_cost_denom
                                        ,indirect_cost_acct_sum    => indirect_cost_acct
                                        ,indirect_cost_project_sum => indirect_cost_project
                                        ,l_projfunc_currency_code  => l_projfunc_currency_code
                                        ,l_project_currency_code   => l_project_currency_code
                                        ,l_acct_currency_code      => l_acct_currency_code
                                        ,l_denom_currency_code     => l_denom_currency_code
                                        ,status                    => status
                                        ,stage                     => stage
                                      );

  IF (status <> 0) THEN
     stage := 600;
     return;
  END IF;

  /*
   * Bug#2110452
   *
   *  indirect_cost         := PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(direct_cost*compiled_multiplier,
   *                                                          l_project_currency_code);
   *  indirect_cost_denom   := PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(direct_cost_denom*compiled_multiplier,
   *                                                          l_denom_currency_code);
   *  indirect_cost_acct    := PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(direct_cost_acct*compiled_multiplier,
   *                                                          l_acct_currency_code);
   *  indirect_cost_project := PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(direct_cost_project*compiled_multiplier,
   *                                                          l_project_currency_code);
   */

  stage := 700;

  --
  --  Get the compiled set id
  --

  SELECT ind_compiled_set_id
  INTO   compiled_set_id
  FROM   pa_ind_compiled_sets
  WHERE  ind_rate_sch_revision_id = rate_sch_rev_id
  AND        organization_id = org_id
  AND      cost_base       = c_base                   /*Bug# 2933915*/
  AND    STATUS = 'A';


EXCEPTION

   WHEN OTHERS THEN
     status := SQLCODE;

END get_exp_item_indirect_cost;


--
--  PROCEDURE
--             get_exp_item_burden_amount
--
--  PURPOSE
--             This is a pseudo procedure that provides a shell of
--        get_exp_item_indirect_cost.  This procedure is introduced
--        due to terminology change.
--
--  HISTORY
--
--   30-DEC-94      S Lee          Created
--


procedure get_exp_item_burden_amount(exp_item_id      IN     Number,
                                     schedule_type    IN     Varchar2,
                                     burden_amount    IN OUT NOCOPY Number,
                                     rate_sch_rev_id  IN OUT NOCOPY Number,
                                     compiled_set_id  IN OUT NOCOPY Number,
                                     status           IN OUT NOCOPY Number,
                                     stage            IN OUT NOCOPY Number)

IS
   /*
     Multi-Currency Related Changes:
     Interface of the procedure get_exp_item_indirect_cost is changed.
     Two additional parameters are passed but not used within this procedure.
    */
   /*
    * EPP.
    * Project Currency related Changes.
    * Passing new parameter burden_amount_project.
    */
   burden_amount_denom     PA_EXPENDITURE_ITEMS.Denom_Burdened_cost%TYPE;
   burden_amount_Acct      PA_EXPENDITURE_ITEMS.Acct_Burdened_cost%TYPE;
   burden_amount_Project   PA_EXPENDITURE_ITEMS.Project_Burdened_cost%TYPE; /* epp */
BEGIN
     pa_cost_plus.get_exp_item_indirect_cost(exp_item_id,
                                     schedule_type,
                                     burden_amount,
                                     burden_amount_denom,
                                     burden_amount_acct,
                                     burden_amount_project, /* epp */
                                     rate_sch_rev_id,
                                     compiled_set_id,
                                     status,
                                     stage);


END get_exp_item_burden_amount;

--
--  PROCEDURE
--             populate_indirect_cost
--
--  PURPOSE
--             The objective of this procedure is to populate the total
--        indirect cost for an expenditure item.
--
--  HISTORY
--
--   09-AUG-94      S Lee          Created
--

PROCEDURE populate_indirect_cost(update_count IN OUT NOCOPY NUMBER)
IS

  -- Cursor definition
  /*
     Multi-Currency Related Changes:
     Acct_Raw_Cost and Denom_Raw_Cost picked up; also the check is done on the basis
     of Denom Costs. (previously the checks were done on the basis of raw_cost)
   */
  /*
     Burdening related changes:
     record is picked up for burdening if either of three buckets is null
   */
  /*
   * Bug# 855461
   * Denom_burdened_cost and transaction_source also picked up.
   */
  /*
   * Bug# 913273
   * BTC Items are not processed here. It is done within
   * Costing process.
   *
   * Bug#1002399
   * 'OT' items are not processed .   Removed this condition for Bug #1946968
   */
  CURSOR Exp_Item_Cursor IS
     SELECT ITEM.Expenditure_Item_ID,
                ITEM.Raw_Cost,
            ITEM.Acct_Raw_Cost,
            ITEM.Project_Raw_Cost, /* ProjCurr Changes */
            ITEM.Denom_Raw_Cost,
            ITEM.Denom_Burdened_Cost,
            ITEM.Burden_Cost,
            ITEM.Acct_burdened_Cost,
            ITEM.Project_burdened_Cost,
            ITEM.Transaction_Source,
            ITEM.Quantity,
                ITEM.Raw_Cost_Rate,
                ITEM.System_Linkage_Function,
                ITEM.cost_ind_compiled_set_id,
                nvl(ITEM.net_zero_adjustment_flag,'N') net_zero_adjustment_flag,
            TYPE.burden_amt_display_method,
         ITEM.adjusted_expenditure_item_id, -- Bug 3893837
         ITEM.project_id   -- added bug 8248419
     FROM   PA_Expenditure_Items ITEM,
            --PA_TASKS TASK, /* Bug 3458139 */
            PA_PROJECTS_ALL PROJ,
            PA_PROJECT_TYPES_ALL TYPE
     WHERE  ITEM.Cost_Distributed_Flag    = 'S'
     AND    ITEM.Denom_Raw_Cost           IS NOT NULL
     AND    (ITEM.Denom_Burdened_Cost        IS NULL
             OR
             ITEM.Acct_Burdened_Cost         IS NULL
             OR
             ITEM.Burden_Cost                IS NULL
             OR
             ITEM.Transferred_from_exp_item_id IS NOT NULL     /*2217540*/
             OR                                               /* 2328366 */
             EXISTS  (SELECT 1
                      FROM   PA_TRANSACTION_SOURCES PTS
                      WHERE  PTS.Transaction_source = ITEM.Transaction_source
                      AND    PTS.Allow_Burden_Flag = 'Y')
             OR ITEM.cost_ind_compiled_set_id is null)           /* 3008365 */
     AND    ITEM.Cost_Dist_Rejection_Code IS NULL
     --AND    ITEM.Task_ID                  = TASK.Task_ID /* Bug 3458139 */
     --AND    TASK.Project_ID               = PROJ.Project_ID /* Bug 3458139 */
     AND    ITEM.Project_Id                 = PROJ.Project_Id /* Bug 3458139 */
     AND    PROJ.Project_Type             = TYPE.Project_Type
     /* AND    nvl(TYPE.Org_Id, -99)      = nvl(PROJ.Org_Id, -99) bug 5374745 */
     AND    TYPE.Org_id                   = PROJ.Org_id -- bug 5374745
     AND    TYPE.burden_cost_flag         = 'Y'
     -- AND    ITEM.System_Linkage_Function  NOT IN ('BTC','OT'); /* Commented for Bug#1946968 */
     AND    ITEM.System_Linkage_Function <> 'BTC'
     ORDER BY ITEM.Expenditure_Item_ID;     /*for bug 6066796*/
  /*
     Multi-Currency Related Changes:
     New Variables defined : indirect_cost_denom, indirect_cost_acct
                             total_burden_cost_denom, total_burden_cost_acct
   */
  indirect_cost           PA_Expenditure_Items.Burden_Cost%TYPE;
  indirect_cost_denom     PA_Expenditure_Items.Denom_Burdened_Cost%TYPE;
  indirect_cost_acct      PA_Expenditure_Items.Acct_Burdened_Cost%TYPE;
  indirect_cost_project   PA_Expenditure_Items.Project_Burdened_Cost%TYPE; /* ProjCurr Changes */
  burdened_cost           PA_Expenditure_Items.Burden_Cost%TYPE;
  burdened_cost_denom     PA_Expenditure_Items.Denom_Burdened_Cost%TYPE;
  burdened_cost_acct      PA_Expenditure_Items.Acct_Burdened_Cost%TYPE;
  burdened_cost_project      PA_Expenditure_Items.Project_Burdened_Cost%TYPE; /* ProjCurr Changes */
  x_Burden_Cost_Rate      PA_Expenditure_Items.Burden_Cost_Rate%TYPE;
  total_burden_cost       PA_Expenditure_Items.Burden_Cost%TYPE;
  total_burden_cost_denom PA_Expenditure_Items.Denom_Burdened_Cost%TYPE;
  total_burden_cost_acct  PA_Expenditure_Items.Acct_Burdened_Cost%TYPE;
  total_burden_cost_project  PA_Expenditure_Items.Project_Burdened_Cost%TYPE; /* ProjCurr Changes */
  qty                     PA_Expenditure_Items.Quantity%TYPE;
  compiled_set_id         PA_Expenditure_Items.Cost_Ind_Compiled_Set_ID%TYPE;
  reason                PA_Expenditure_Items.Ind_Cost_Dist_Rejection_Code%TYPE;
  rate_sch_rev_id         PA_Ind_Rate_Sch_Revisions.Ind_Rate_Sch_Revision_ID%TYPE;
  status                  number(15);
  stage                   number(15);
  /*
   * Bug# 855461
   * New Variables defined
   *
   * the variable l_api_call_reqd is used to save the
   * call to general API for the imported trnasction with
   * transaction source. allow burden = 'Y'
   *
   */
  l_allow_burden_flag     PA_TRANSACTION_SOURCES.Allow_Burden_Flag%TYPE;
  l_api_call_reqd         VARCHAR2(1) ;

    -- Bug 3893837 : Introduced cursor to fetch burden cost for adjusted expenditure
  --                 items from the original expenditure item which is already costed.

  CURSOR Adj_Exp_Item_Cursor (p_exp_item_id NUMBER ,p_denom_raw_cost NUMBER ) IS
  SELECT cost_ind_compiled_set_id,
         -1 * Burden_Cost ,
         -1 * Denom_Burdened_Cost,
      -1 * Acct_Burdened_Cost ,
         -1 * Project_burdened_Cost,
      Burden_Cost_Rate
    FROM pa_expenditure_items_all
   WHERE expenditure_item_id = p_exp_item_id
     AND Denom_Raw_Cost             = -1 * p_denom_raw_cost
     AND Denom_Burdened_Cost        IS NOT NULL
     AND Acct_Burdened_Cost         IS NOT NULL
     AND Burden_Cost                IS NOT NULL ;
    /*
    ** Bug: 5155112
    ** BURDEN SEPARATE LINE - AMOUNT NOT EQUAL TO BURDENED_COST
    ** Issue was with the check " AND cost_ind_compiled_set_id IS NOT NULL"  in   CURSOR Adj_Exp_Item_Cursor
    ** This failed for trxns not attached to any burden cost base thereby populating the burden cost column with cached
    ** values(incorrectly).
    **  AND cost_ind_compiled_set_id   IS NOT NULL ;
    */

  l_adjusted_item_flag  VARCHAR2(1);

  -- added bug 8248419 start
    CURSOR Cost_Burden_Flag_Cursor (p_project_id  Number) IS
     SELECT NVL(burden_cost_flag,'N'),
            NVL(total_burden_flag,'N')
      FROM pa_projects prj, pa_project_types prj_type
      WHERE prj.project_id = p_project_id
      AND prj.project_TYPE = prj_type.project_TYPE;

     l_burden_cost_flag  pa_project_types.BURDEN_COST_FLAG%TYPE;
     l_total_burden_flag pa_project_types.TOTAL_BURDEN_FLAG%TYPE;
     l_cost_burden_distributed_flag pa_Expenditure_Items.cost_burden_distributed_flag%TYPE;
  -- bug 8248419 end

BEGIN

    update_count := 0;
    FOR Exp_Item_Row IN Exp_Item_Cursor LOOP

        compiled_set_id := NULL;  -- Bug 3365476 : Nullify the compiled_set_id, so that it is not
                                  -- populated for already burdened expenditures.

        --
        -- Get the indirect cost and other information
        --

        /*
         * Bug# 855461
         * For imported transactions with allow_burden_flag = 'Y'
         * take the ratio of transaction burdened cost to tranaction raw cost
         * to get the burden multiplier and use it to calculate
         * acct burdened and project burdened cost
         */
        l_api_call_reqd := 'Y';
     l_adjusted_item_flag := 'N'; -- Bug 3893837
        IF  Exp_Item_Row.transaction_source IS NOT NULL THEN
           SELECT  Allow_Burden_Flag
           INTO    l_allow_burden_flag
           FROM    PA_TRANSACTION_SOURCES
           WHERE   Transaction_Source = Exp_Item_Row.transaction_source;
           /* Bug 902578: Fist we calculate the burdened cost using the ratio calculation.
              Then we derive the burden cost by subtracting raw cost from burdened cost.
              The burden cost (indirect cost) will later be used to calculate total burden cost
              which is equivalent to our burdened cost
              Example
              Raw Cost           Burdened Cost        Indirect Cost
                20                   30                   10
              Acct Raw Cost
                60
              Burdened_cost_acct = 60 * (30/20) = 90
              Indirect_cost_acct = 90 - 60 = 30
           */

           IF l_allow_burden_flag = 'Y' THEN
              /* Bug 4375749 - Divide-by-zero error when Denom_Raw_Cost = 0 */
              IF Exp_item_Row.Denom_Raw_Cost <> 0 THEN
                 burdened_cost := (Exp_Item_Row.Denom_Burdened_Cost/Exp_item_Row.Denom_Raw_Cost)
                                        * Exp_Item_Row.Raw_Cost;
                 indirect_cost := burdened_cost - Exp_item_Row.Raw_Cost;

                 burdened_cost_acct := (Exp_Item_Row.Denom_Burdened_Cost/Exp_item_Row.Denom_Raw_Cost)
                                        * Exp_Item_Row.Acct_Raw_Cost;
                 indirect_cost_acct := burdened_cost_acct - Exp_item_Row.Acct_Raw_Cost;

              /*
               * Bug 4063390
               * burdened_cost_denom := Exp_Item_Row.Denom_Burdened_Cost -
               *                           Exp_Item_Row.Denom_Raw_Cost;
               */
                 burdened_cost_denom := Exp_Item_Row.Denom_Burdened_Cost;
                 indirect_cost_denom := burdened_cost_denom - Exp_Item_Row.Denom_Raw_Cost;

                 burdened_cost_project := (Exp_Item_Row.Denom_Burdened_Cost/Exp_item_Row.Denom_Raw_Cost)
                                          * Exp_Item_Row.Project_Raw_Cost;
                 indirect_cost_project := burdened_cost_project - Exp_item_Row.Project_Raw_Cost;

              ELSE
                 burdened_cost := 0;
                 indirect_cost := 0;
                 burdened_cost_acct := 0;
                 indirect_cost_acct := 0;
                 burdened_cost_denom:= 0;
                 indirect_cost_denom:= 0;
                 burdened_cost_project:= 0;
                 indirect_cost_project:= 0;
              END IF;
              /* Bug 4375749 */
                 status := 0;
                 l_api_call_reqd := 'N';
           END IF;
        END IF;
        /*
           Multi-Currency Related Changes:
           Additional Parameters passed (indirect_cost_acct, indirect_cost_denom)
         */
        IF  l_api_call_reqd = 'Y' THEN

        -- Bug 3893837 : Calculate the burden cost for adjusted expenditure items
           -- by taking the original expenditure items cost.If the original item has NULL
           -- burden costs/ compiled set id  then both the costs of the orginal
           -- and adjusting items will be processed in this program as if they were
        -- 'normal' (non-adjusted) expenditure items ,and both will have same compiled set id as
        -- they are derived at same time.

          IF Exp_Item_Row.net_zero_adjustment_flag = 'Y' AND Exp_Item_Row.adjusted_expenditure_item_id IS NOT NULL THEN

               OPEN  Adj_Exp_Item_Cursor(Exp_Item_Row.adjusted_expenditure_item_id,Exp_Item_Row.Denom_Raw_Cost);
            FETCH  Adj_Exp_Item_Cursor INTO compiled_set_id,total_burden_cost,total_burden_cost_denom,
                                        total_burden_cost_Acct,total_burden_cost_Project,x_Burden_Cost_Rate;
               CLOSE  Adj_Exp_Item_Cursor;

            l_adjusted_item_flag := 'Y';
               status := 0;

          ELSE

               pa_cost_plus.get_exp_item_indirect_cost(
                          Exp_Item_Row.Expenditure_Item_ID,
                          'C',
                          indirect_cost,
                          indirect_cost_acct,
                          indirect_cost_denom,
                          indirect_cost_project, /* ProjCurr Changes */
                          rate_sch_rev_id,
                          compiled_set_id,
                          status,
                          stage);
          END IF;
        END IF;

      -- added Bug 8248419 start
       OPEN  Cost_Burden_Flag_Cursor (Exp_Item_Row.project_id);
       FETCH Cost_Burden_Flag_CURSOR INTO l_burden_cost_flag, l_total_burden_flag;
       CLOSE Cost_Burden_Flag_Cursor;

       IF (l_burden_cost_flag = 'Y' OR l_total_burden_flag = 'Y')
         THEN  l_cost_burden_distributed_flag := 'Z';
       END IF;
      -- Bug 8248419 end


        IF (status = 0) THEN
         --
         --  The indirect cost is retrieved successfully.
         --  Update the expenditure item.
         --
         qty := Exp_Item_Row.Quantity;
        --
          -- If Burden amount is going to be displayed on same transaction
        -- then do the calculation else burden_cost=raw_cost
        --
        /*
           Multi-Currency Related Changes:
           Set total_burden_cost_denom and total_burden_cost_acct
         */
        IF (Exp_Item_Row.System_Linkage_Function <> 'BTC') AND l_adjusted_item_flag ='N' THEN -- Bug
          IF (Exp_Item_Row.Burden_Amt_Display_Method = 'S') THEN
              total_burden_cost       := Exp_Item_Row.Raw_Cost + indirect_cost;
            total_burden_cost_denom := Exp_Item_Row.Denom_Raw_Cost + indirect_cost_denom;
            total_burden_cost_acct  := Exp_Item_Row.Acct_Raw_Cost  + indirect_cost_acct;
            total_burden_cost_project  := Exp_Item_Row.Project_Raw_Cost  + indirect_cost_project;  /* ProjCurr Changes */
            IF (qty <> 0) THEN
                x_Burden_Cost_Rate := (total_burden_cost_denom /nvl(qty,1));
                 ELSE
                x_Burden_Cost_Rate := total_burden_cost_denom;
                 END IF;
            ELSE   -- Burden amount to be displayed as separate EI
                total_burden_cost        := Exp_Item_Row.Raw_Cost;
                total_burden_cost_denom  := Exp_Item_Row.Denom_Raw_Cost;
                total_burden_cost_acct   := Exp_Item_Row.Acct_Raw_Cost;
                total_burden_cost_project   := Exp_Item_Row.Project_Raw_Cost; /* ProjCurr Changes */
                x_Burden_Cost_Rate       := Exp_Item_Row.Raw_Cost_Rate;
            END IF;-- end if of Burden Amount_display_method
         END IF;  -- end if of Expenditure_type BTC

       /*
          Multi-Currency Related Changes:
          Update Denom_burdened_cost and Acct_burdened_cost
        */
       /*
          Burdening related changes:
          Set the value of that bucket which is null.
        */

     -- Bug 3893837 : Moved the logic of deriving rates for net zero items in the starting.
     -- Bug fixes 3617506 and 3834184 are obsoleted as its incorrect to
     -- copy the same burden costs in case compiled_set_id is same or net zero is yes.
     -- Reason : As per main query ,this code gets fired only if any of the burden costs are NULL/
     -- compiled set is NULL.So in case burden costs are null ,compiled set is NOT NULL and
     -- net zero is Yes then the burden costs should be copied from original item if
     -- already costed else rederive .
     -- Note : Please test all scenarios mentioned in bug 3893837 if this logic is modified in future.

         UPDATE PA_Expenditure_Items
         SET    Burden_Cost_Rate             = x_Burden_Cost_Rate,
            Burden_Cost                  = total_burden_cost,
              Denom_burdened_Cost          = total_burden_cost_denom,
              Acct_burdened_Cost           = total_burden_cost_Acct,
              Project_burdened_Cost           = total_burden_cost_Project,  /* ProjCurr Changes */
            Cost_Ind_Compiled_Set_Id     = compiled_set_id,
            Ind_Cost_Dist_Rejection_Code = NULL,
            cost_burden_distributed_flag  = decode(l_cost_burden_distributed_flag,'Z','Z',
                                            decode(l_api_call_reqd,'N','Z',cost_burden_distributed_flag)) /*2450423  changed bug 8248419*/
         WHERE  Expenditure_Item_ID          = Exp_Item_Row.Expenditure_Item_ID;

         update_count := update_count + 1;

        ELSE
         --
         --  Error handling.  Explain the rejection reason.
         --
         IF ((status = 100) and (stage = 400)) THEN
                  --
               --  Can not find cost base.  The total burdened cost
               --  equals raw cost.
               --
         /*
            Multi-Currency Related Changes:
            Update Denom_burdened_cost and Acct_burdened_cost
          */
         /*
            Bug# 805725
            Set cost_burden_distributed_flag to some impossible value ('Z')
          */
         /*
            Burdening related changes:
            Set the value of that bucket which is null.
          */
               UPDATE PA_Expenditure_Items
               SET    Burden_Cost_Rate             = Raw_Cost_Rate,
                Burden_Cost                  = NVL(Burden_Cost,Raw_Cost),
                Denom_Burdened_Cost          = NVL(Denom_Burdened_Cost,Denom_Raw_Cost),
                Acct_Burdened_Cost           = NVL(Acct_Burdened_Cost,Acct_Raw_Cost),
                Project_Burdened_Cost        = NVL(Project_Burdened_Cost,Project_Raw_Cost), /* epp */
            --  Cost_Burden_Distributed_Flag = 'Z',  -- commented bug 8715545
                Cost_Burden_Distributed_Flag =  decode(l_cost_burden_distributed_flag,'Z','Z','X'),  -- added bug 8248419
            --  Cost_Burden_Distributed_Flag = 'X',  -- added bug 8715545
                Cost_Ind_Compiled_Set_Id     = NULL
               WHERE  Expenditure_Item_ID      = Exp_Item_Row.Expenditure_Item_ID;

           update_count := update_count + 1;
            ELSE
                IF (status = 100) THEN
                   IF (stage = 200) THEN
                      reason := 'NO_IND_RATE_SCH_REVISION';
                   ELSIF (stage = 300) THEN
                      reason := 'NO_COST_PLUS_STRUCTURE';
                   ELSIF (stage = 500) THEN
                      reason := 'NO_ORGANIZATION';
                   ELSIF (stage = 600) THEN
                      reason := 'NO_COMPILED_MULTIPLIER';/* Bug 5884742 */
                   ELSIF (stage = 700) THEN
                      reason := 'NO_ACTIVE_COMPILED_SET';
                   ELSE
                      reason := 'GET_INDIRECT_COST_FAIL';
                   END IF;
                ELSE
                      reason := 'GET_INDIRECT_COST_FAIL';
                END IF;

                /*
                   Multi-Currency Related Changes:
                   Update Denom_burdened_cost and Acct_burdened_cost
                 */
                /*
                   Burdening related changes:
                   Dont reset burdened cost.
                 */
                UPDATE PA_Expenditure_Items
                SET    Cost_Dist_Rejection_Code = reason
/*****************************
*****                  Burden_Cost_Rate         = NULL,
*****                  Burden_Cost              = NULL,
*****                  Denom_Burdened_Cost      = NULL,
*****                  Acct_Burdened_Cost       = NULL,
*****                  Cost_Ind_Compiled_Set_Id = NULL
******************************/
                WHERE  Expenditure_Item_ID      = Exp_Item_Row.Expenditure_Item_ID;

            END IF;

        END IF;

    END LOOP;


END populate_indirect_cost;


--
--  PROCEDURE
--             get_indirect_cost_sum
--
--  PURPOSE
--           The objective of this function is to retrieve the sum of
--              indirect cost.  The amount of indirect cost is the procudt
--        of direct cost and the indirect cost multiplier.  This
--        procedure calculates the indirect cost for each indirect cost
--        code with a specified precision, then sum up the total
--        indirect cost.
--
--  HISTORY
--
--   16-MAY-94      S Lee          Created
--


procedure get_indirect_cost_sum(org_id           IN     number,
                                      c_base             IN     varchar2,
                                rate_sch_rev_id    IN     number,
                                direct_cost        IN     number,
                                precision          IN     number,
                                     indirect_cost_sum  IN OUT NOCOPY number,
                                     status              IN OUT NOCOPY number,
                                     stage               IN OUT NOCOPY number)
IS

BEGIN

   status := 0;
   stage := 100;

  /* No longer precision argument is used; PA_CURRENCY.ROUND_CURRENCY_AMT
     is going to take care that. */

   --
   -- Here the occurrence of ROUND_CURRENCY_AMT was not changed to ROUND_TRANS_CURRENCY_AMT
   -- because this is used in View Burden Costs for which displays the amount fields in
   -- functional currency
   --
   SELECT SUM(PA_CURRENCY.ROUND_CURRENCY_AMT((direct_cost * icpm.compiled_multiplier)))
     into indirect_cost_sum
          FROM pa_ind_compiled_sets ics,
               pa_compiled_multipliers icpm
               WHERE
                     ics.ind_rate_sch_revision_id = rate_sch_rev_id
                     AND ics.organization_id = org_id
                     AND ics.status = 'A'
                     AND ics.ind_compiled_set_id =
                              icpm.ind_compiled_set_id
                              AND ics.cost_base =icpm.cost_base               /*Bug# 2933915*/
                     AND icpm.cost_base = c_base;

   if (indirect_cost_sum is null) then
      status := NO_DATA_FOUND_ERR;
   end if;

EXCEPTION

   WHEN OTHERS THEN
     status := SQLCODE;

END get_indirect_cost_sum;



--  PROCEDURE
--              get_indirect_cost_sum1
--
--  PURPOSE
--              The objective of this function is to retrieve the sum of
--              indirect costs(separately for indirect cost ,indirect cost acct and direct cost denom).
--              The amount of indirect cost is the product
--              of direct cost and the indirect cost multiplier.  This
--              procedure calculates the indirect cost for each indirect cost
--              code rounds it , then sum up the total indirect cost (each component separately ).
--
--  HISTORY
--
--   22-NOV-01       Seema       Created /*Bug# 2110452*/

procedure get_indirect_cost_sum1(org_id                    IN     number,
                                 c_base                    IN     varchar2,
                                 rate_sch_rev_id           IN     number,
                                 direct_cost               IN     number,
                                 direct_cost_denom         IN     number,
                                 direct_cost_acct          IN     number,
                                 direct_cost_project       IN     number,
                                 precision                 IN     number,
                                 indirect_cost_sum         IN OUT NOCOPY number,
                                 indirect_cost_denom_sum   IN OUT NOCOPY number,
                                 indirect_cost_acct_sum    IN OUT NOCOPY number,
                                 indirect_cost_project_sum IN OUT NOCOPY number,
                                 l_projfunc_currency_code  IN     varchar2,
                                 l_project_currency_code   IN     varchar2,
                                 l_acct_currency_code      IN     varchar2,
                                 l_denom_currency_code     IN     varchar2,
                                 status                    IN OUT NOCOPY number,
                                 stage                     IN OUT NOCOPY number)
IS

BEGIN

   status := 0;
   stage := 100;
   /* Begin bug 5391496 */
   -- SELECT SUM(PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT((direct_cost * icpm.compiled_multiplier),
   --                                                  l_projfunc_currency_code)),
   --        SUM(PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT((direct_cost_denom * icpm.compiled_multiplier),
   --                                                  l_denom_currency_code)),
   --        SUM(PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT((direct_cost_acct * icpm.compiled_multiplier),
   --                                                  l_acct_currency_code)),
   --        SUM(PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT((direct_cost_project * icpm.compiled_multiplier),
   --                                                  l_project_currency_code))
   -- into indirect_cost_sum,
   --      indirect_cost_denom_sum,
   --      indirect_cost_acct_sum,
   --      indirect_cost_project_sum
   -- FROM pa_ind_compiled_sets ics,
   --      pa_compiled_multipliers icpm
   -- WHERE
   --      ics.ind_rate_sch_revision_id = rate_sch_rev_id
   -- AND  ics.organization_id = org_id
   -- AND  ics.status = 'A'
   -- AND  ics.ind_compiled_set_id = icpm.ind_compiled_set_id
   -- AND  ics.cost_base =icpm.cost_base                /*Bug# 2933915*/
   -- AND  icpm.cost_base = c_base;

   SELECT SUM(PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT1((direct_cost * icpm.compiled_multiplier),
                                                    l_projfunc_currency_code)),
          SUM(PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT1((direct_cost_denom * icpm.compiled_multiplier),
                                                    l_denom_currency_code)),
          SUM(PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT1((direct_cost_acct * icpm.compiled_multiplier),
                                                    l_acct_currency_code)),
          SUM(PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT1((direct_cost_project * icpm.compiled_multiplier),
                                                    l_project_currency_code))
   into indirect_cost_sum,
        indirect_cost_denom_sum,
        indirect_cost_acct_sum,
        indirect_cost_project_sum
   FROM pa_ind_compiled_sets ics,
        pa_compiled_multipliers icpm
   WHERE
        ics.ind_rate_sch_revision_id = rate_sch_rev_id
   AND  ics.organization_id = org_id
   AND  ics.status = 'A'
   AND  ics.ind_compiled_set_id = icpm.ind_compiled_set_id
   AND  ics.cost_base =icpm.cost_base                /*Bug# 2933915*/
   AND  icpm.cost_base = c_base;
   /* End bug 5391496 */

   if (indirect_cost_sum is null) then
      status := NO_DATA_FOUND_ERR;
   end if;

EXCEPTION

   WHEN OTHERS THEN
        status := SQLCODE;

END get_indirect_cost_sum1;

--
--  PROCEDURE
--             view_indirect_cost
--
--  PURPOSE
--           The objective of this procedure is to retrieve the total
--        indirect cost based on a set of qualifications.  User can
--        specify the qualifications and the type of indirect rate
--        schedule, then get the total amount of indirect cost.
--
--  HISTORY
--
--   10-JUN-94      S Lee     Created
--

procedure view_indirect_cost(transaction_id   IN     Number,
                             transaction_type IN     Varchar2,
                             task_id          IN     Number,
                             effective_date   IN     Date,
                             expenditure_type IN     Varchar2,
                             organization_id  IN     Number,
                             schedule_type    IN     Varchar2,
                             direct_cost      IN     Number,
                             indirect_cost    IN OUT NOCOPY Number,
                             status           IN OUT NOCOPY Number,
                             stage            IN OUT NOCOPY Number)

IS

 -- Bug Fix for 886868, Burden amount is showing twice for projects that allow
 -- burden amount to be shown as a separate expenditure items on same project
 --
 -- NOTE : This  procedure is called from 2 different programs
 --        PABCMTB.pls (commitments)
 --        PAAPIMPB.pls (Web Expense) integration
 --        This aPi is also called from GET_INDIRECT_COST_AMOUNTS procedure
 --        for which I couldn't find any references in 11.0 source stream
 --        By adding this change, we will be sending the indirect_cost as
 --        0 if the burden amount to be displayed on same project as separate
 --        expenditure items
 --        Will make appropriate modifications to PA_COST_PLUS1 package to call
 --        PA_COST_PLUS1.view_indirect_cost instead of
 --        PA_COST_PLUS.view_indirect_cost
 --
  /*
   * Bug#1065740
   * parameter added to this cursor to avoid conflict
   * between local variable name and the column name in database.
   */
  CURSOR Burden_Method_Cursor(l_task_id in number) IS
     SELECT TYPE.burden_amt_display_method
     FROM   PA_TASKS TASK,
            PA_PROJECTS_ALL PROJ,
            PA_PROJECT_TYPES_ALL TYPE
     WHERE
            TASK.Task_ID = l_task_id
     AND    TASK.Project_ID = PROJ.Project_ID
     AND    PROJ.Project_Type = TYPE.Project_Type
     /* AND    nvl(TYPE.Org_Id, -99) = nvl(PROJ.Org_Id, -99) bug 5374745 */
     AND    TYPE.Org_Id = PROJ.Org_id -- bug 5374745
     AND    TYPE.burden_cost_flag = 'Y';

--
--  Local variables
--

rate_sch_rev_id          Number(15);
sch_id              Number(15);
sch_fixed_date      Date;
cp_structure        Varchar2(30);
c_base              Varchar2(30);

BEGIN

   status := 0;

   --
   --  Get the rate schedule revision id
   --
   -- Bug Fix for 886868, Burden amount is showing twice for projects that allow
   -- burden amount to be shown as a separate expenditure items on same project
   --
   -- Opening the cursor before calling other APIs to avoid performance
   -- problem. If burden summarization method is D (i.e. burden amount on
   -- different expenditure items on same project/task, then we will need to
   -- set indirect_cost to 0.
   -- NOTE : Objective of this API is only to calculate the indirect cost and
   --        not to return compiled_set_id and hence we are calling cursor
   --        before deriving the other attributes

   /* Bug 2989775: Added the condition to check for the value returned by the client
      extension function Same_Line_Burden_Cmt If the value returned is TRUE, then
      indirect cost should not be set to 0 even if burdening is set up on separate
      line at the project type level so that burdening will be on the same line for
      commitment transactions when viewed from the PSI screen */

   IF PA_CLIENT_EXTN_BURDEN_SUMMARY.Same_Line_Burden_Cmt
   then
   null;
   ELSE
   FOR Burden_Method_Row IN Burden_Method_Cursor(task_id) LOOP
          -- If Burden amount is NOT going to be displayed on same transaction
        -- then set indirect_cost to 0 and return
        --
          IF (Burden_Method_Row.Burden_Amt_Display_Method <> 'S') THEN
              indirect_cost := 0;
              stage := 75;
              return;
        END IF;
   END LOOP;
   END IF;


   pa_cost_plus.find_rate_sch_rev_id(
                                    transaction_id,
                                    transaction_type,
                                    task_id,
                           schedule_type,
                        effective_date,
                        sch_id,
                        rate_sch_rev_id,
                        sch_fixed_date,
                        status,
                        stage);

  stage := 100;

  IF (status <> 0) THEN
      return;
  END IF;

  --
  -- Get the cost plus structure
  --

  pa_cost_plus.get_cost_plus_structure(rate_sch_rev_id,
                              cp_structure,
                           status,
                           stage);

  IF (status <> 0) THEN
      stage := 200;
      return;
  END IF;


  --
  -- Get the cost base
  --

  pa_cost_plus.get_cost_base(expenditure_type,
                    cp_structure,
                    c_base,
                    status,
                    stage);

  /* Bug 925488: If expenditure type is not defined with a cost base,
     get_cost_base return with status = 100. This means this expenditure
     type should not be burdened.  Thus, indirect cost should be 0. */
  IF (status <> 0) THEN
   IF (status = 100) THEN
      indirect_cost := 0;
      status := 0;
      return;
   ELSE
      stage := 300;
      return;
   END IF;
  END IF;

  --
  -- Get the indirect cost
  --

  pa_cost_plus.get_indirect_cost_sum(organization_id,
                            c_base,
                         rate_sch_rev_id,
                         direct_cost,
                         2,                     -- FOR US CURRENCY
                         indirect_cost,
                              status,
                              stage);

  IF (status <> 0) THEN
     stage := 400;
     return;
  END IF;


EXCEPTION

   WHEN OTHERS THEN
     status := SQLCODE;

END view_indirect_cost;


--
--  PROCEDURE
--             get_burden_amount
--
--  PURPOSE
--           The objective of this procedure is to retrieve the
--        burden amount based on a set of qualifications.
--
--  HISTORY
--
--   05-JAN-95      S Lee     Created
--

procedure get_burden_amount(burden_schedule_id   IN     Number,
                                effective_date       IN     Date,
                                expenditure_type     IN     Varchar2,
                                organization_id      IN     Number,
                                raw_amount           IN     Number,
                                burden_amount        IN OUT NOCOPY Number,
                                burden_sch_rev_id    IN OUT NOCOPY Number,
                                compiled_set_id      IN OUT NOCOPY Number,
                                status               IN OUT NOCOPY Number,
                                stage                IN OUT NOCOPY Number)

IS

--
--  Local variables
--

cp_structure        Varchar2(30);
c_base              Varchar2(30);

BEGIN

   status := 0;

   --
   --  Get the rate schedule revision id
   --

   pa_cost_plus.get_revision_by_date(burden_schedule_id,
                         effective_date,
                         effective_date,
                         burden_sch_rev_id,
                         status,
                         stage);

  stage := 100;

  IF (status <> 0) THEN
      return;
  END IF;

  --
  -- Get the cost plus structure
  --

  pa_cost_plus.get_cost_plus_structure(burden_sch_rev_id,
                              cp_structure,
                           status,
                           stage);

  IF (status <> 0) THEN
      stage := 200;
      return;
  END IF;


  --
  -- Get the cost base
  --

  pa_cost_plus.get_cost_base(expenditure_type,
                    cp_structure,
                    c_base,
                    status,
                    stage);

  IF (status <> 0) THEN
     stage := 300;
     return;
  END IF;


  --
  -- Get the compiled set id
  --

  pa_cost_plus.get_compiled_set_id(burden_sch_rev_id,
                       organization_id,
                       c_base,                                          /*Bug# 2933915*/
                       compiled_set_id,
                       status,
                       stage);

  IF (status <> 0) THEN
     stage := 400;
     return;
  END IF;

  --
  -- Get the indirect cost
  --

  pa_cost_plus.get_indirect_cost_sum(organization_id,
                            c_base,
                         burden_sch_rev_id,
                         raw_amount,
                         2,                     -- FOR US CURRENCY
                         burden_amount,
                              status,
                              stage);

  IF (status <> 0) THEN
     stage := 500;
     return;
  END IF;


EXCEPTION

   WHEN OTHERS THEN
     status := SQLCODE;

END get_burden_amount;

/* added for bug#3117191 */
procedure get_burden_amount1(--burden_schedule_id   IN     Number,
                             -- effective_date       IN     Date,
                                expenditure_type     IN     Varchar2,
                                organization_id      IN     Number,
                                raw_amount           IN     Number,
                                burden_amount        IN OUT NOCOPY Number,
                                burden_sch_rev_id    IN OUT NOCOPY Number,
                                compiled_set_id      IN OUT NOCOPY Number,
                                status               IN OUT NOCOPY Number,
                                stage                IN OUT NOCOPY Number)

IS

--
--  Local variables
--

cp_structure            Varchar2(30);
c_base                  Varchar2(30);

BEGIN

   status := 0;

   --
   --  Get the rate schedule revision id
   --

/*
   pa_cost_plus.get_revision_by_date(burden_schedule_id,
                                     effective_date,
                                     effective_date,
                                     burden_sch_rev_id,
                                     status,
                                     stage);

  stage := 100;

  IF (status <> 0) THEN
      return;
  END IF;
*/


  --
  -- Get the cost plus structure
  --

  pa_cost_plus.get_cost_plus_structure(burden_sch_rev_id,
                                       cp_structure,
                                       status,
                                       stage);

  IF (status <> 0) THEN
      stage := 200;
      return;
  END IF;


  --
  -- Get the cost base
  --

  pa_cost_plus.get_cost_base(expenditure_type,
                             cp_structure,
                             c_base,
                             status,
                             stage);

  IF (status <> 0) THEN
        stage := 300;
        return;
  END IF;


  --
  -- Get the compiled set id
  --

  pa_cost_plus.get_compiled_set_id(burden_sch_rev_id,
                                   organization_id,
                                   c_base,                                          /*Bug# 2933915*/
                                   compiled_set_id,
                                   status,
                                   stage);

  IF (status <> 0) THEN
        stage := 400;
        return;
  END IF;

  --
  -- Get the indirect cost
  --

  pa_cost_plus.get_indirect_cost_sum(organization_id,
                                     c_base,
                                     burden_sch_rev_id,
                                     raw_amount,
                                     2,                     -- FOR US CURRENCY
                                     burden_amount,
                                     status,
                                     stage);

  IF (status <> 0) THEN
        stage := 500;
        return;
  END IF;


EXCEPTION

   WHEN OTHERS THEN
        status := SQLCODE;

END get_burden_amount1;
/* end for bug#3117191 */

--
--  PROCEDURE
--             get_hierarchy_from_revision
--
--  PURPOSE
--
--
--  HISTORY
--
--   10-APR-2000     C.Yuvaraj     Created
--

procedure get_hierarchy_from_revision(p_sch_rev_id IN  number,
                     x_org_struc_ver_id OUT NOCOPY number,
                     x_start_org        OUT NOCOPY number,
                     x_status           OUT NOCOPY number,
                     x_stage            OUT NOCOPY number)
IS
BEGIN

   x_status := 0;
   x_stage := 100;


  select org_structure_version_id,start_organization_id
  into   x_org_struc_ver_id,x_start_org
  from   pa_ind_rate_sch_revisions
  where  ind_rate_sch_revision_id = p_sch_rev_id;


EXCEPTION
   when NO_DATA_FOUND then
      x_status := NO_DATA_FOUND_ERR;
   when OTHERS then
      x_status := SQLCODE;

end get_hierarchy_from_revision;



--
--  PROCEDURE
--             find_rate_sch_rev_id
--
--  PURPOSE
--           The objective of this procedure is to retrieve the rate schedule
--           revision id assigned for a task.  The sequence to find the
--              rate schedule revision is
--           (1) task level schedule override
--        (2) project level schedule override
--           (3) lowest level task schedule.
--
--  Note:       This procedure gets called from both the project and expenditure
--              oriented process. Hence should always refer to the base tables
--              and not the Morg view.
--
--
--  HISTORY
--
--   10-JUN-94      S Lee     Created
--

procedure find_rate_sch_rev_id(
                        transaction_id  IN Number,
                        transaction_type IN Varchar2,
                        t_id            IN Number,
                        schedule_type   IN Varchar2,
                        exp_item_date   IN  Date,
                        sch_id          IN OUT NOCOPY Number,
                        rate_sch_rev_id IN OUT NOCOPY Number,
                        sch_fixed_date  IN OUT NOCOPY Date,
                        status          IN OUT NOCOPY Number,
                        stage           IN OUT NOCOPY Number)
IS

-- Local variables

   t_rate_sch_rev_id number;
   t_sch_fixed_date date;

BEGIN

  --
  --  Find the rate schedule according to the sequence
  --  (1) task level schedule override
  --  (2) project level schedule override
  --  (3) lowest level task schedule
  --

  status := 0;
  stage := 100;
  sch_id := NULL;
  rate_sch_rev_id := NULL;
  sch_fixed_date := NULL;
  t_rate_sch_rev_id := NULL;
  t_sch_fixed_date := NULL;

  --
  --  Find the override rate schedule at task level
  --

  BEGIN

     if (schedule_type = 'C') then

        SELECT irs.ind_rate_sch_id,
            t.cost_ind_sch_fixed_date
        INTO   sch_id,
            sch_fixed_date
        FROM   pa_tasks t,
            pa_ind_rate_schedules irs
        WHERE  t.task_id = t_id
        AND    t.task_id = irs.task_id
        AND    irs.cost_ovr_sch_flag = 'Y';

     elsif (schedule_type = 'R') then

        SELECT irs.ind_rate_sch_id,
            t.rev_ind_sch_fixed_date
        INTO   sch_id,
            sch_fixed_date
        FROM   pa_tasks t,
            pa_ind_rate_schedules irs
        WHERE  t.task_id = t_id
        AND    t.task_id = irs.task_id
        AND    irs.rev_ovr_sch_flag = 'Y';

     else

        SELECT irs.ind_rate_sch_id,
            t.inv_ind_sch_fixed_date
        INTO   sch_id,
            sch_fixed_date
        FROM   pa_tasks t,
            pa_ind_rate_schedules irs
        WHERE  t.task_id = t_id
        AND    t.task_id = irs.task_id
        AND    irs.inv_ovr_sch_flag = 'Y';

     end if;

  EXCEPTION

     when NO_DATA_FOUND then
        sch_id := NULL;
        sch_fixed_date := NULL;

     when OTHERS then
        status := SQLCODE;
        return;
  END;

  --
  --  Get revision id if schedule is not null
  --

  IF (sch_id IS NOT NULL) THEN
     pa_cost_plus.get_revision_by_date(sch_id,
                               sch_fixed_date,
                               exp_item_date,
                               rate_sch_rev_id,
                               status,
                               stage);
  END IF;

 --
 -- Calling client extension to override rate_sch_rev_id
 --
    PA_CLIENT_EXTN_BURDEN.Override_Rate_Rev_Id(
            'ACTUAL',
            transaction_id,                            -- Transaction Item Id
            transaction_type,                          -- Transaction Type
            t_id,                                      -- Task Id
            schedule_type,                             -- Schedule Type
            exp_item_date,                             -- EI Date
            t_sch_fixed_date,                          -- Sch_fixed_date (Out)
            t_rate_sch_rev_id,                         -- Rate_sch_rev_id (Out)
            status);                                   -- Status   (Out)

    /* Begin bug 5169080 */
    If (nvl(status , 0) <> 0) Then
         Return;
    End If;
    /* End bug 5169080 */

    IF (t_rate_sch_rev_id IS NOT NULL) THEN
         rate_sch_rev_id := t_rate_sch_rev_id;
         IF (t_sch_fixed_date IS NOT NULL) THEN
            sch_fixed_date := t_sch_fixed_date;
         END IF;
    END IF;

    /*   Start : GMS code hook to override rate_sch_rev_id.
    **           2981752 - PA.L:BURDENING ENHANCEMENTS : TRACKING BUG
    */

    IF ( NVL(g_gms_enabled,'N')  = 'Y' )  THEN

       IF (t_rate_sch_rev_id is NULL ) THEN

          t_sch_fixed_date := sch_fixed_date ;

          GMS_PA_API3.Override_Rate_Rev_Id( transaction_id,        -- Transaction Item Id
                                            transaction_type,      -- Transaction Type
                                            t_id,                  -- Task Id
                                            schedule_type,         -- Schedule Type
                                            exp_item_date,         -- EI Date
                                            t_sch_fixed_date,      -- Sch_fixed_date ( IN Out)
                                            t_rate_sch_rev_id,     -- Rate_sch_rev_id (Out)
                                            status);               -- Status   (Out)

          /* Start : The status controls to override rate_sch_rev_id
          **         Or not. The possible values are :
          **         0 : Override  ( award specific and sponsored  project. )
          **         1 : Don't override ( Non sponsored project continue with Default PA logic. )
          */

          IF ( status = 0 ) THEN

             rate_sch_rev_id := t_rate_sch_rev_id;
             sch_fixed_date  := t_sch_fixed_date ;
             return ;

          END IF ;   -- ( status = 0 )

       END IF ;      -- (t_rate_sch_rev_id is NULL )

    END IF ;         -- ( NVL(g_gms_enabled,'N')  = 'Y' )

    /*   End : End of GMS code hook to override rate_sch_rev_id .
    **         2981752 - PA.L:BURDENING ENHANCEMENTS : TRACKING BUG
    */


  IF (rate_sch_rev_id IS NOT NULL) THEN
     return;

  ELSE
     --
     -- There is no override rate schedule id found at the task level
     -- Find the override rate schedule at project level
     --
     stage := 200;
     status := 0;
     sch_id := NULL;
     sch_fixed_date := NULL;

     BEGIN
        if (schedule_type = 'C') then

           SELECT irs.ind_rate_sch_id,
               p.cost_ind_sch_fixed_date
           INTO   sch_id,
               sch_fixed_date
           FROM   pa_tasks t,
            pa_projects_all p,
               pa_ind_rate_schedules irs
           WHERE  t.task_id = t_id
        AND    t.project_id = p.project_id
           AND    t.project_id = irs.project_id
           AND    irs.cost_ovr_sch_flag = 'Y'
        AND    irs.task_id is null;

        elsif (schedule_type = 'R') then

           SELECT irs.ind_rate_sch_id,
               p.rev_ind_sch_fixed_date
           INTO   sch_id,
               sch_fixed_date
           FROM   pa_tasks t,
            pa_projects_all p,
               pa_ind_rate_schedules irs
           WHERE  t.task_id = t_id
        AND    t.project_id = p.project_id
           AND    t.project_id = irs.project_id
           AND    irs.rev_ovr_sch_flag = 'Y'
        AND    irs.task_id is null;

        else

           SELECT irs.ind_rate_sch_id,
               p.inv_ind_sch_fixed_date
           INTO   sch_id,
               sch_fixed_date
           FROM   pa_tasks t,
            pa_projects_all p,
               pa_ind_rate_schedules irs
           WHERE  t.task_id = t_id
        AND    t.project_id = p.project_id
           AND    t.project_id = irs.project_id
           AND    irs.inv_ovr_sch_flag = 'Y'
        AND    irs.task_id is null;

        end if;

     EXCEPTION

        when NO_DATA_FOUND then
           sch_id := NULL;
           sch_fixed_date := NULL;

        when OTHERS then
           status := SQLCODE;
           return;
     END;

     --
     --  Get the project override schedule id and fixed date
     --

  END IF;


  if (sch_id IS NOT NULL) then
     pa_cost_plus.get_revision_by_date(sch_id,
                               sch_fixed_date,
                               exp_item_date,
                               rate_sch_rev_id,
                               status,
                               stage);
  end if;


  IF (rate_sch_rev_id IS NOT NULL) then
     return;

  ELSE
     --
     -- Override rate schedule does not exist at task or project level
     --
     stage := 300;
     status := 0;
     sch_id := NULL;
     sch_fixed_date := NULL;

     IF (schedule_type = 'C') THEN

        SELECT cost_ind_rate_sch_id,
            cost_ind_sch_fixed_date
        INTO   sch_id,
            sch_fixed_date
        FROM   pa_tasks
        WHERE  task_id = t_id;

     ELSIF (schedule_type = 'R') THEN

        SELECT rev_ind_rate_sch_id,
            rev_ind_sch_fixed_date
        INTO   sch_id,
            sch_fixed_date
        FROM   pa_tasks
        WHERE  task_id = t_id;

     ELSE

        SELECT inv_ind_rate_sch_id,
            inv_ind_sch_fixed_date
        INTO   sch_id,
            sch_fixed_date
        FROM   pa_tasks
        WHERE  task_id = t_id;

     END IF;

  END IF;

  if (sch_id IS NOT NULL) then
     pa_cost_plus.get_revision_by_date(sch_id,
                               sch_fixed_date,
                               exp_item_date,
                               rate_sch_rev_id,
                               status,
                               stage);
  else
     status := 100;
  END IF;


EXCEPTION
   when NO_DATA_FOUND then
      status := NO_DATA_FOUND_ERR;
   when OTHERS then
      status := SQLCODE;

END find_rate_sch_rev_id;


--
--  PROCEDURE
--             get_rate_sch_rev_id
--
--  PURPOSE
--           The objective of this procedure is to retrieve revision ID for a
--           particular type of indirect rate schedule.  A rate schedule may
--           have many revisions divided by periods.  This procedure uses
--           an effective date locate the correct revision.
--
--  Note:       This procedure gets called from both the project and expenditure
--              oriented process. Hence should always refer to the base tables
--              and not the Morg view.
--
--  HISTORY
--
--   09-JUN-94      S Lee     Created
--

procedure get_rate_sch_rev_id(exp_item_id      IN Number,
                        schedule_type   IN     Varchar2,
                        rate_sch_rev_id IN OUT NOCOPY Number,
                        status          IN OUT NOCOPY Number,
                        stage           IN OUT NOCOPY Number)
IS

-- Local variables

  t_id                      NUMBER(15);
  exp_item_date             DATE;
  sch_id          NUMBER(15);
  sch_fixed_date       DATE;
  effective_date       DATE;

BEGIN


  status := 0;

  --
  --  Get the task id and expenditure item date
  --  As this procedure can be called from project Oriented or Expenditure
  --  oriented process, hence the uderlying select uses base table.
  --

  SELECT task_id,
      expenditure_item_date
  INTO   t_id,
      exp_item_date
  FROM   pa_expenditure_items_all
  WHERE  expenditure_item_id = exp_item_id;

  --
  --  Get the indirect rate schedule
  --

  pa_cost_plus.find_rate_sch_rev_id(
                        exp_item_id,
                        'PA',
                        t_id,
                        schedule_type,
                  exp_item_date,
                        sch_id,
               rate_sch_rev_id,
                        sch_fixed_date,
                        status,
                        stage);

  IF (status <> 0) THEN
      stage := 100;
      return;
  END IF;


EXCEPTION
   when NO_DATA_FOUND then
      status := NO_DATA_FOUND_ERR;
   when OTHERS then
      status := SQLCODE;

END get_rate_sch_rev_id;



--
--  PROCEDURE
--             get_cost_base
--
--  PURPOSE
--           The objective of this procedure is to retrieve the current
--              cost base information for a particular expenditure item.
--              We may get the indirect cost rates through cost base.
--
--  HISTORY
--
--   08-JUN-94     S Lee Changed the input parameter
--   18-APR-94     S Lee Added error handler
--   29-MAR-94    S Lee  Modified for the new database schema and
--                  application standard
--   20-NOV-93     S Lee           Created
--

procedure get_cost_base (exp_type         IN       varchar2,
                cp_structure     IN      varchar2,
                c_base           IN OUT NOCOPY varchar2,
                status          IN OUT NOCOPY number,
                stage           IN OUT NOCOPY number)
IS

BEGIN

   status := 0;
   stage := 100;

   SELECT
      cbet.cost_base
     INTO c_base
              FROM
              pa_cost_base_exp_types cbet
                WHERE
                cbet.cost_plus_structure = cp_structure
                AND cbet.expenditure_type = exp_type
                AND cbet.cost_base_type = INDIRECT_COST_CODE;

EXCEPTION

   WHEN NO_DATA_FOUND THEN
      status := NO_DATA_FOUND_ERR;
   WHEN OTHERS THEN
      status := SQLCODE;

END get_cost_base;


--
--  PROCEDURE
--             get_cost_plus_structure
--
--  PURPOSE
--              The objective of this procedure is to retrieve the cost plus
--        structure used by a rate schedule revision.
--
--  HISTORY
--
--   08-JUN-94     S Lee Created
--

procedure get_cost_plus_structure (rate_sch_rev_id IN     Number,
                cp_structure     IN OUT NOCOPY varchar2,
                status          IN OUT NOCOPY number,
                stage           IN OUT NOCOPY number)
IS

BEGIN

   status := 0;
   stage := 100;

   SELECT
      cost_plus_structure
     INTO cp_structure
              FROM
              pa_ind_rate_sch_revisions
                WHERE
                ind_rate_sch_revision_id = rate_sch_rev_id;

EXCEPTION

   WHEN NO_DATA_FOUND THEN
      status := NO_DATA_FOUND_ERR;
   WHEN OTHERS THEN
      status := SQLCODE;

END get_cost_plus_structure;



--  PROCEDURE
--             get_organization_id
--
--  PURPOSE
--           The objective of this procedure is to retrieve the ID of the
--           organization which the expenditure item is charged against.
--
--  Note:       This procedure gets called from both the project and expenditure
--              oriented process. Hence should always refer to the base tables
--              and not the Morg view.
--
--  HISTORY
--
--   08-JUN-94     S Lee Created
--

procedure get_organization_id (exp_item_id IN     number,
                organization_id   IN OUT NOCOPY number,
                status           IN OUT NOCOPY number,
                stage            IN OUT NOCOPY number)
IS

BEGIN

   status := 0;
   stage := 100;

  --  As this procedure can be called from project Oriented or Expenditure
  --  oriented process, hence the uderlying select uses base table.

   SELECT override_to_organization_id
   INTO   organization_id
   FROM   pa_expenditure_items_all
   WHERE  expenditure_item_id = exp_item_id;

   IF organization_id IS NULL THEN
       --
       -- the organization is at expenditures level
       --
       stage := 200;

       SELECT incurred_by_organization_id
       INTO   organization_id
       FROM   pa_expenditures_all exp,
           pa_expenditure_items_all exp_item
       WHERE  exp_item.expenditure_item_id = exp_item_id
       AND    exp_item.expenditure_id = exp.expenditure_id
       AND    ( (exp_item.org_id is null) or (exp_item.org_id = exp.org_id));

   END IF;

EXCEPTION

      WHEN NO_DATA_FOUND THEN
      status := NO_DATA_FOUND_ERR;
      WHEN OTHERS THEN
      status := SQLCODE;

END get_organization_id;



--  PROCEDURE
--             get_compiled_set_id
--
--  PURPOSE
--           The objective of this procedure is to retrieve the ID of the
--           compiled set id by rate schedule revision id and organization
--        id.
--
--  HISTORY
--
--   05-JAN-94     S Lee Created
--

procedure get_compiled_set_id(rate_sch_rev_id        IN     Number,
                                  org_id             IN     Number,
                      c_base             IN     Varchar2,                   /*2933915*/
                                  compiled_set_id    IN OUT NOCOPY Number,
                                  status             IN OUT NOCOPY Number,
                                  stage              IN OUT NOCOPY Number)

IS

BEGIN

   status := 0;
   stage := 100;

   SELECT ics.ind_compiled_set_id
   INTO   compiled_set_id
   FROM   pa_ind_compiled_sets ics
   WHERE  ics.ind_rate_sch_revision_id = rate_sch_rev_id
   AND    ics.organization_id = org_id
   AND    cost_base  =c_base                                                              /*2933915*/
   AND    ics.status = 'A';

EXCEPTION

      WHEN NO_DATA_FOUND THEN
      status := NO_DATA_FOUND_ERR;
      WHEN OTHERS THEN
      status := SQLCODE;

END get_compiled_set_id;



--  PROCEDURE
--             get_revision_by_date
--
--  PURPOSE
--           The objective of this procedure is to retrieve the ID of the
--           rate schedule revision according to the provided date
--
--  HISTORY
--
--   05-JAN-94     S Lee Created
--

procedure get_revision_by_date(sch_id            IN     Number,
                               sch_fixed_date    IN     Date,
                               exp_item_date     IN     Date,
                               rate_sch_rev_id   IN OUT NOCOPY Number,
                               status            IN OUT NOCOPY Number,
                               stage             IN OUT NOCOPY Number)


IS

  x_ind_rate_schedule_type VARCHAR2(1);
  base_date            DATE;

BEGIN

  status := 0;
  rate_sch_rev_id := NULL;

  --
  --  Retrieve the type of the schedule
  --

  /* Bug 3786374 : Introduced Caching Logic for ind_rate_schedule_type */

  If g_sch_id = sch_id Then

     x_ind_rate_schedule_type := g_ind_rate_schedule_type ;

  Else

     SELECT ind_rate_schedule_type
       INTO     x_ind_rate_schedule_type
       FROM     pa_ind_rate_schedules
       WHERE  ind_rate_sch_id = sch_id;

     g_ind_rate_schedule_type := x_ind_rate_schedule_type;
     g_sch_id := sch_id;

  End If;


  IF (x_ind_rate_schedule_type = 'F') THEN
     --
     --  Firm rate schedule type.   Use expenditure item date except if
     --  schedule fixed date is defined.

     IF (sch_fixed_date IS NOT NULL) THEN
          base_date := sch_fixed_date;
     ELSE
        base_date := exp_item_date;
     END IF;

  ELSE

     --
     --  Find out the effective gl period
     --
/* Commented out for Bug 1277815 as this check is done in PAXCOIRS.fmb
     SELECT  PERIOD.end_date
     INTO    base_date
     FROM    GL_Period_Statuses PERIOD,
             PA_Implementations IMP
     WHERE   PERIOD.Application_ID = 101
     AND     PERIOD.Set_Of_Books_ID = IMP.Set_Of_Books_ID
     AND     PERIOD.ADJUSTMENT_PERIOD_FLAG = 'N'
     AND     TRUNC(exp_item_date) BETWEEN
                  TRUNC(PERIOD.start_date) and TRUNC(PERIOD.end_date);*/

    base_date := exp_item_date; /* Added for bug 1277815*/

  END IF;

  BEGIN

     --
     -- Get the actual revision if there is one
     --
     SELECT irsr.ind_rate_sch_revision_id
     INTO   rate_sch_rev_id
     FROM   pa_ind_rate_sch_revisions irsr
     WHERE  irsr.ind_rate_sch_id = sch_id
     AND    TRUNC(base_date) BETWEEN
                TRUNC(irsr.start_date_active) AND
              TRUNC(NVL(irsr.end_date_active, base_date))
     AND    irsr.ind_rate_sch_revision_type = 'A';

  EXCEPTION
     when NO_DATA_FOUND then
        --
        -- Actual revision is not available
        --
        SELECT irsr.ind_rate_sch_revision_id
        INTO   rate_sch_rev_id
        FROM   pa_ind_rate_sch_revisions irsr
        WHERE  irsr.ind_rate_sch_id = sch_id
        AND    TRUNC(base_date) BETWEEN
                   TRUNC(irsr.start_date_active) AND
               TRUNC(NVL(irsr.end_date_active, base_date));
  END;

EXCEPTION

      WHEN NO_DATA_FOUND THEN
      status := NO_DATA_FOUND_ERR;
      WHEN OTHERS THEN
      status := SQLCODE;

END get_revision_by_date;



--
--  PROCEDURE
--             check_revision_used
--
--  PURPOSE
--        The objective of this procedure is to check whether the
--        rate schedule revision has been used.  'Used' is defined as
--              there are costed expenditure items with this rate schedule
--        revision.
--
--  HISTORY
--
--   06-JUL-94      S Lee     Changed FK of expenditure item
--   07-MAY-94      S Lee     Created
--

procedure check_revision_used(rate_sch_rev_id IN number,
                     status IN OUT NOCOPY number,
                     stage  IN OUT NOCOPY number)
is
dummy number;
begin

   status := 0;

   /*
    * IC related change:
    * this procedure will return 0 in case of TP schedule
    * also.
    */

--S.O. /*Bug 4527736 */
--   SELECT 1 INTO dummy FROM sys.dual WHERE NOT EXISTS
--     (SELECT  1 FROM pa_ind_compiled_sets ICS, /* Removed Hint NO_INDEX(ITEM PA_EXPENDITURE_ITEMS_N13) */
--               pa_expenditure_items_all ITEM
--          WHERE
--           ICS.ind_rate_sch_revision_id = rate_sch_rev_id
--     AND   (   (ICS.ind_compiled_set_id = ITEM.cost_ind_compiled_set_id)
--         OR (ICS.ind_compiled_set_id = ITEM.rev_ind_compiled_set_id)
--       OR (ICS.ind_compiled_set_id = ITEM.tp_ind_compiled_set_id)
--         OR (ICS.ind_compiled_set_id = ITEM.inv_ind_compiled_set_id)));
--E.O. /*Bug 4527736 */
--S.N. /*Bug 4527736 */
SELECT 1 INTO dummy FROM SYS.DUAL
        WHERE NOT EXISTS
         (SELECT 1
            FROM PA_IND_COMPILED_SETS ICS
           WHERE ICS.IND_RATE_SCH_REVISION_ID = rate_sch_rev_id
             AND EXISTS
           (SELECT ITEM.COST_IND_COMPILED_SET_ID
              FROM PA_EXPENDITURE_ITEMS_ALL ITEM
             WHERE ICS.IND_COMPILED_SET_ID = ITEM.COST_IND_COMPILED_SET_ID
             UNION ALL
            SELECT ITEM.REV_IND_COMPILED_SET_ID
              FROM PA_EXPENDITURE_ITEMS_ALL ITEM
             WHERE ICS.IND_COMPILED_SET_ID = ITEM.REV_IND_COMPILED_SET_ID
             UNION ALL
            SELECT ITEM.TP_IND_COMPILED_SET_ID
              FROM PA_EXPENDITURE_ITEMS_ALL ITEM
             WHERE ICS.IND_COMPILED_SET_ID = ITEM.TP_IND_COMPILED_SET_ID
             UNION ALL
            SELECT ITEM.INV_IND_COMPILED_SET_ID
              FROM PA_EXPENDITURE_ITEMS_ALL ITEM
             WHERE ICS.IND_COMPILED_SET_ID = ITEM.INV_IND_COMPILED_SET_ID
           )
         );
--E.N. /*Bug 4527736 */

exception
   when NO_DATA_FOUND then
      status := 100;
   when OTHERS then
      status := SQLCODE;

end check_revision_used;


--
--  PROCEDURE
--             check_structure_used
--
--  PURPOSE
--        The objective of this procedure is to check whether the
--        cost plus structure has been used.  'Used' is defined as
--              there are costed expenditure items in this cost plus structure.
--
--  HISTORY
--
--   07-MAY-94      S Lee     Created
--

procedure check_structure_used(structure IN varchar2,
                      status IN OUT NOCOPY number,
                      stage  IN OUT NOCOPY number)
is
-- cursor definition

   CURSOR rev_cursor
   IS
      SELECT ind_rate_sch_revision_id
      FROM pa_ind_rate_sch_revisions
      WHERE cost_plus_structure = structure;

BEGIN

  status := 0;

  FOR rev_row IN rev_cursor LOOP

      pa_cost_plus.check_revision_used(rev_row.ind_rate_sch_revision_id,
                           status,
                           stage);

      if (status <> 0) then
       stage := 100;
       EXIT;
      end if;

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
  stage := 100;

END check_structure_used;


--
--  PROCEDURE
--             copy_structure
--
--  PURPOSE
--        The objective of this procedure is to check whether the
--        cost plus structure has been used.  'Used' is defined as
--              there are costed expenditure items in this cost plus structure.
--
--  HISTORY
--
--   07-MAY-94      S Lee     Created
--

procedure copy_structure(source      IN varchar2,
                   destination IN varchar2,
                status IN OUT NOCOPY number,
                stage  IN OUT NOCOPY number)
is

-- cursor definition
   CURSOR icc_cursor
   IS
      SELECT cost_base,
          cost_base_type,
          ind_cost_code,
          precedence
      FROM pa_cost_base_cost_codes
      WHERE cost_plus_structure = source;

   CURSOR et_cursor
   IS
      SELECT cost_base,
          cost_base_type,
          expenditure_type
      FROM pa_cost_base_exp_types
      WHERE cost_plus_structure = source;

   -- Local variables
   cbicc_id        number;
   structure_type  varchar2(30);
   icc_precedence  number;

   -- Standard who
   x_last_updated_by            NUMBER(15);
   x_created_by                 NUMBER(15);
   x_last_update_login          NUMBER(15);


begin

   stage := 100;
   status := 0;

   --
   --  Standard who
   --

   x_created_by               := FND_GLOBAL.USER_ID;
   x_last_updated_by            := FND_GLOBAL.USER_ID;
   x_last_update_login          := FND_GLOBAL.LOGIN_ID;

   SELECT cost_plus_structure_type
   INTO   structure_type
   FROM   pa_cost_plus_structures
   WHERE  cost_plus_structure = destination;

   if (structure_type = 'A') then
       icc_precedence := 1 ;
   else
       icc_precedence := NULL;
   end if;


   for icc_row in icc_cursor loop
       SELECT pa_cost_base_cost_codes_s.nextval into cbicc_id FROM sys.dual;

       INSERT INTO pa_cost_base_cost_codes
      (cost_base_cost_code_id,
       cost_plus_structure,
       cost_base,
       cost_base_type,
       ind_cost_code,
       precedence,
       last_update_date,
       last_updated_by,
       creation_date,
       created_by,
       last_update_login
      )
       VALUES
      (cbicc_id,
       destination,
       icc_row.cost_base,
       icc_row.cost_base_type,
       icc_row.ind_cost_code,
       NVL(icc_precedence,icc_row.precedence),
       SYSDATE,
       x_last_updated_by,
       SYSDATE,
       x_created_by,
       x_last_update_login);

   end loop;

   stage := 200;

   for et_row in et_cursor loop

       INSERT INTO pa_cost_base_exp_types
         (cost_plus_structure,
          cost_base,
          cost_base_type,
          expenditure_type,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login
         )
       VALUES
      (destination,
       et_row.cost_base,
       et_row.cost_base_type,
       et_row.expenditure_type,
       SYSDATE,
       x_last_updated_by,
       SYSDATE,
       x_created_by,
       x_last_update_login);

   end loop;

   COMMIT;

exception
   WHEN OTHERS THEN
     status := SQLCODE;
end copy_structure;


--
--  PROCEDURE
--             mark_impacted_exp_items
--
--  PURPOSE
--           The objective of this procedure is to mark expenditure items for
--           adjustments.  For example, if the multipliers of a rate
--        schedule are changed, then the expenditure items that were
--        costed by the original schedule must be identified.
--
--  HISTORY
--
--   30-JAN-95      S Lee     Added adjustment activities
--   22-AUG-94      S Lee     Revised due to suggestions in design review
--   19-AUG-94      S Lee     Modified to handle adjustments
--   10-JUN-94      S Lee     Created
--
/****PA L Enhancement :Modified this procedure to mark the eis selectively on the
                       basis of impacted cost bases ****************************/

procedure mark_impacted_exp_items(rate_sch_rev_id       IN     number,
                                   status               IN OUT NOCOPY number,
                                   stage                IN OUT NOCOPY number)

is
--
-- Local variables
--
   sch_id number;
   l_start_date date;
   l_end_date date;
   rev_type varchar2(1);
   rev_done number;
   l_gms_enabled     VARCHAR2(2) :='N';                                            /*3059344*/
   l_cp_structure       pa_ind_rate_sch_revisions.cost_plus_structure%TYPE ;          /*3054111*/

    l_this_fetch        number:= 0;
    l_this_commit_cycle number:= 0;
    l_totally_fetched   number:= 0;
    l_fetch_size   number:= 1000;
    l_commit_size   number:= 10000;
    adj_module       constant  varchar2(10) := 'PACOCRSR';
    err_buf  varchar2(4000);--Bug 5726575
    ret_code varchar2(250);--Bug 5726575
    GMS_INSERT_ENC_ITEM_ERROR exception; --Bug 5726575

l_eiid_tbl pa_plsql_datatypes.IdTabTyp;
l_csid_tbl pa_plsql_datatypes.IdTabTyp;
l_rowid_tbl pa_plsql_datatypes.RowidTabTyp;
l_rev_inv_flag_tbl pa_plsql_datatypes.Char1TabTyp;

/* Commented for the bug 4527736
CURSOR mark_impacted_cost_bases                                                      --3054111
IS
    SELECT
           DISTINCT cbicc.cost_base ,cbicc.cost_plus_structure
      FROM  pa_cost_base_cost_codes cbicc,
            pa_ind_cost_multipliers icm
    WHERE icm.ind_rate_sch_revision_id = rate_sch_rev_id                             --3054111
          AND (nvl(icm.ready_to_compile_flag,'N') in ('Y','X') OR nvl(G_MODULE,'XXX') ='NEW_ORG')
          AND cbicc.cost_plus_structure = l_cp_structure                            --3054111
          AND cbicc.ind_cost_code =  icm.ind_cost_code
          AND cbicc.cost_base_type = INDIRECT_COST_CODE ;
*/

/****2933915 :Modified this cursor
   CURSOR cs1_cursor
   IS
      SELECT DISTINCT ind_compiled_set_id
      FROM   pa_ind_compiled_sets
      WHERE  ind_rate_sch_revision_id = rate_sch_rev_id
      AND    status = 'H';
*************************************************/

   CURSOR cs1_cursor(c_base VARCHAR2)
   IS
     SELECT DISTINCT ICS.ind_compiled_set_id
     FROM pa_ind_compiled_sets    ICS
     WHERE ICS.ind_rate_sch_revision_id  = rate_sch_rev_id
       AND ICS.cost_base                 = c_base
       AND ICS.status = 'H';

   /*2933915 :No change reqd in cs2/cs3 as they should pick up all 'A' records for the earlier revisions irrespective
  of cost base */

   CURSOR cs2_cursor
   IS
      SELECT /*+ ORDERED
           INDEX(irsr PA_IND_RATE_SCH_REVISIONS_N1) */
             DISTINCT ics.ind_compiled_set_id
      FROM   pa_ind_rate_sch_revisions irsr,
             pa_ind_compiled_sets ics
      WHERE  ics.status = 'A'
      AND    ics.ind_rate_sch_revision_id = irsr.ind_rate_sch_revision_id
      AND    irsr.ind_rate_sch_id = sch_id
      AND    irsr.start_date_active < l_start_date
      AND    irsr.ind_rate_sch_revision_type <> 'A';

   CURSOR cs3_cursor
   IS
      SELECT /*+ ORDERED */
             DISTINCT ics.ind_compiled_set_id
      FROM   pa_ind_rate_sch_revisions irsr,
          pa_ind_compiled_sets ics
      WHERE  ics.status = 'A'
      AND    ics.ind_rate_sch_revision_id = irsr.ind_rate_sch_revision_id
      AND    irsr.actual_sch_revision_id = rate_sch_rev_id;



   -- Standard who
   x_last_updated_by            NUMBER(15);
   x_last_update_login          NUMBER(15);
   x_request_id                 NUMBER(15);
   x_program_application_id     NUMBER(15);
   x_program_id                 NUMBER(15);
   l_burden_profile             VARCHAR2(2);                         /*2933915*/
   l_row_count                  NUMBER(15);

BEGIN

   -- Initialize output parameters
   status := 0;
   l_row_count := 0;

   gl_mc_currency_pkg.G_PA_UPGRADE_MODE := TRUE; /*Bug 4527736 */

   --
   -- Get the standard who information
   --
   x_last_updated_by            := FND_GLOBAL.USER_ID;
   x_last_update_login          := FND_GLOBAL.LOGIN_ID;
   x_request_id                 := FND_GLOBAL.CONC_REQUEST_ID;
   x_program_application_id     := FND_GLOBAL.PROG_APPL_ID;
   x_program_id                 := FND_GLOBAL.CONC_PROGRAM_ID;

--  l_burden_profile := nvl(fnd_profile.value('PA_ENHANCED_BURDENING'),'N');                 /*2933915 */
  l_burden_profile := pa_utils2.IsEnhancedBurdeningEnabled;

  IF gms_install.enabled THEN                                /*3059344 :To check if grants is installed */
    l_gms_enabled := 'Y' ;
  END IF ;

   --
   -- Case 1: The indirect rate scheudle is modified.
   --         Mark expenditure items whose compiled_set_id is associated with
   --           the rate schedule revision.
   --
 BEGIN
   SELECT ind_rate_sch_id, start_date_active, end_date_active,
          ind_rate_sch_revision_type,cost_plus_structure
   INTO   sch_id, l_start_date, l_end_date, rev_type,l_cp_structure
   FROM   pa_ind_rate_sch_revisions irsr
   WHERE  ind_rate_sch_revision_id = rate_sch_rev_id;
 EXCEPTION
 WHEN OTHERS THEN
  gl_mc_currency_pkg.G_PA_UPGRADE_MODE := FALSE; /*Bug 4456789 */
  RAISE;
 END;

BEGIN


   --FOR cost_base_rec in mark_impacted_cost_bases
IF G_IMPACTED_COST_BASES_TAB.COUNT <> 0 THEN /*4590268*/

   FOR i IN G_IMPACTED_COST_BASES_TAB.FIRST .. G_IMPACTED_COST_BASES_TAB.LAST
   LOOP

   --FOR cs1_row IN cs1_cursor(cost_base_rec.cost_base)
   FOR cs1_row IN cs1_cursor(G_IMPACTED_COST_BASES_TAB(i))
   LOOP

         /*======================================================================================+
          | This update handles the following cases.                                             |
          | o [Cost/TP] Same and Separate line burdening transactions - when enhanced burdening  |
          |   profile option is not enabled.                                                     |
          | o [Cost/TP] Same line burdening transactions when enahanced burdening profile option |
          |   is enabled.                                                                        |
          | o [Revenue] Capital Projects with revenue based on burdened cost - for same line     |
          |    burdening transactions.                                                           |
          +======================================================================================*/

         G_EXPENDITURE_ITEM_ID_TAB.DELETE; /*4456789*/
         G_ADJ_TYPE_TAB.DELETE;            /*4456789*/

      stage := 100;
         UPDATE pa_expenditure_items_all ITEM
            SET    ITEM.cost_distributed_flag =
                        DECODE(ITEM.cost_distributed_flag, 'Y',
                              decode(ITEM.cost_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                                 'N',ITEM.cost_distributed_flag), ITEM.cost_distributed_flag),
                   ITEM.revenue_distributed_flag =
                        decode(ITEM.cost_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                            decode(pa_utils2.get_capital_cost_type_code(ITEM.project_id),'B', 'N',ITEM.revenue_distributed_flag)
                                           ,ITEM.revenue_distributed_flag),
             ITEM.adjustment_type =
                        DECODE(ITEM.cost_distributed_flag, 'Y',
                           decode(ITEM.cost_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                                  'BURDEN_RECOMPILE',ITEM.adjustment_type),ITEM.adjustment_type),
          ITEM.cost_burden_distributed_flag =
                        DECODE(ITEM.cost_distributed_flag, 'Y',
                              decode(ITEM.cost_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                                  'N',ITEM.cost_burden_distributed_flag),ITEM.cost_burden_distributed_flag),
             ITEM.last_update_date = SYSDATE,
             ITEM.last_updated_by = x_last_updated_by,
             ITEM.last_update_login = x_last_update_login,
             ITEM.request_id = x_request_id,
             ITEM.program_application_id = x_program_application_id,
             ITEM.program_id = x_program_id,
             ITEM.program_update_date = SYSDATE,
             ITEM.project_burdened_cost =
                        DECODE(ITEM.cost_distributed_flag, 'Y',
                decode(ITEM.cost_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                       NULL, ITEM.project_burdened_cost), ITEM.project_burdened_cost),
             ITEM.denom_burdened_cost =
                        DECODE(ITEM.cost_distributed_flag, 'Y',
                decode(ITEM.cost_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                       NULL, ITEM.denom_burdened_cost), ITEM.denom_burdened_cost),
             ITEM.acct_burdened_cost =
                        DECODE(ITEM.cost_distributed_flag, 'Y',
                decode(ITEM.cost_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                       NULL, ITEM.acct_burdened_cost), ITEM.acct_burdened_cost),
             ITEM.burden_cost =
                        DECODE(ITEM.cost_distributed_flag, 'Y',
                decode(ITEM.cost_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                       NULL, ITEM.burden_cost), ITEM.burden_cost),
             ITEM.cc_bl_distributed_code =
                decode(ITEM.tp_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                  decode(ITEM.cc_cross_charge_code,'B',
                    'N',
                    ITEM.cc_bl_distributed_code),
                  ITEM.cc_bl_distributed_code),
             ITEM.cc_ic_processed_code =
                decode(ITEM.tp_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                  decode(ITEM.cc_cross_charge_code,'I',
                    'N',
                    ITEM.cc_ic_processed_code),
                  ITEM.cc_ic_processed_code),
             ITEM.Denom_Tp_Currency_Code =
                decode(ITEM.tp_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                       NULL, ITEM.denom_tp_currency_code),
             ITEM.Denom_Transfer_Price =
                decode(ITEM.tp_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                       NULL, ITEM.denom_transfer_price),
             ITEM.Acct_Tp_Rate_Type =
                decode(ITEM.tp_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                       NULL, ITEM.acct_tp_rate_type),
             ITEM.Acct_Tp_Rate_Date =
                decode(ITEM.tp_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                       NULL, ITEM.acct_tp_rate_date),
             ITEM.Acct_Tp_Exchange_Rate =
                decode(ITEM.tp_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                       NULL, ITEM.acct_tp_exchange_rate),
             ITEM.Acct_Transfer_Price =
                decode(ITEM.tp_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                       NULL, ITEM.acct_transfer_price),
             ITEM.Projacct_Transfer_Price =
                decode(ITEM.tp_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                       NULL, ITEM.projacct_transfer_price),
             ITEM.Cc_Markup_Base_Code =
                decode(ITEM.tp_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                       NULL, ITEM.cc_markup_base_code),
             ITEM.Tp_Base_Amount =
                decode(ITEM.tp_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                       NULL, ITEM.tp_base_amount),
             ITEM.Tp_Bill_Rate =
                decode(ITEM.tp_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                       NULL, ITEM.tp_bill_rate),
             ITEM.Tp_Bill_Markup_Percentage =
                decode(ITEM.tp_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                       NULL, ITEM.tp_bill_markup_percentage),
             ITEM.Tp_Schedule_line_Percentage =
                decode(ITEM.tp_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                       NULL, ITEM.tp_schedule_line_percentage),
             ITEM.Tp_Rule_percentage =
                decode(ITEM.tp_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                      NULL, ITEM.tp_rule_percentage)
       WHERE   ((ITEM.cost_ind_compiled_set_id = cs1_row.ind_compiled_set_id AND ITEM.cost_distributed_flag = 'Y')
                  OR       ITEM.tp_ind_compiled_set_id = cs1_row.ind_compiled_set_id)
       AND NVL(ITEM.net_zero_adjustment_flag,'N') <> 'Y'
       AND pa_project_stus_utils.Is_Project_Closed(ITEM.project_id) <>'Y'
       AND decode(l_gms_enabled,'Y',gms_pa_api2.is_award_closed(ITEM.expenditure_item_id,ITEM.task_id),'N') = 'N'
       AND exists (select /*+ NO_UNNEST */ null
                    from pa_cost_base_exp_types cbet
                  --where cbet.cost_base = cost_base_rec.cost_base
                  where cbet.cost_base = G_IMPACTED_COST_BASES_TAB(i)
                     AND cbet.cost_plus_structure = G_CP_STRUCTURE
                     AND cbet.cost_base_type   = INDIRECT_COST_CODE
                     AND cbet.expenditure_type = ITEM.expenditure_type
                  )
/*3055700 :Added this exist clause for bug# 3016281 :to mark selectively if explicit multipliers
 are defined for an org for all the cost codes */
       /* 4527736
       AND exists (SELECT NULL
                    FROM   pa_expenditures_all exp
                          ,pa_ind_compiled_sets ics
                    WHERE  exp.expenditure_id = ITEM.expenditure_id
                     AND   ((ics.ind_compiled_set_id = ITEM.cost_ind_compiled_set_id)
                             or (ics.ind_compiled_set_id = ITEM.tp_ind_compiled_set_id))
                     AND nvl(ITEM.override_to_organization_id,exp.incurred_by_organization_id) =ics.organization_id
                     AND   ics.status = 'H'
                    * AND pa_cost_plus.check_for_explicit_multiplier(rate_sch_rev_id,ics.organization_id ) =0   -- Bug# 3134445
               AND decode(rate_sch_rev_id,g_rate_sch_rev_id,decode(ics.organization_id,g_org_id,g_org_override,pa_cost_plus.check_for_explicit_multiplier(rate_sch_rev_id,ics.organization_id))
               ,pa_cost_plus.check_for_explicit_multiplier(rate_sch_rev_id,ics.organization_id ))=0  -- Bug# 3134445 and Bug 3938479
                  ) */
  AND EXISTS ((SELECT NULL
                 FROM PA_EXPENDITURES_ALL EXP
                     ,PA_IND_COMPILED_SETS ICS
                WHERE EXP.EXPENDITURE_ID = ITEM.EXPENDITURE_ID
                  AND (ICS.IND_COMPILED_SET_ID = ITEM.COST_IND_COMPILED_SET_ID)
                  AND NVL(ITEM.OVERRIDE_TO_ORGANIZATION_ID,  EXP.INCURRED_BY_ORGANIZATION_ID) =ICS.ORGANIZATION_ID
                  AND ICS.IND_RATE_SCH_REVISION_ID = rate_sch_rev_id  /* Added for Bug 5683523 */
                  AND ICS.STATUS = 'H'
                  AND DECODE(rate_sch_rev_id ,g_rate_sch_rev_id ,DECODE(ICS.ORGANIZATION_ID,g_org_id ,g_org_override
                                  , PA_COST_PLUS.CHECK_FOR_EXPLICIT_MULTIPLIER(rate_sch_rev_id ,ICS.ORGANIZATION_ID))
                                  , PA_COST_PLUS.CHECK_FOR_EXPLICIT_MULTIPLIER(rate_sch_rev_id ,ICS.ORGANIZATION_ID ))=0
              )
              UNION ALL (SELECT NULL
                       FROM PA_EXPENDITURES_ALL EXP
                           ,PA_IND_COMPILED_SETS ICS
                      WHERE EXP.EXPENDITURE_ID = ITEM.EXPENDITURE_ID
                        AND (ICS.IND_COMPILED_SET_ID = ITEM.TP_IND_COMPILED_SET_ID)
                        AND NVL(ITEM.OVERRIDE_TO_ORGANIZATION_ID,  EXP.INCURRED_BY_ORGANIZATION_ID) =ICS.ORGANIZATION_ID
                        AND ICS.IND_RATE_SCH_REVISION_ID = rate_sch_rev_id   /* Added for Bug 5683523 */
                        AND ICS.STATUS = 'H'
                        AND DECODE(rate_sch_rev_id ,g_rate_sch_rev_id ,DECODE(ICS.ORGANIZATION_ID,g_org_id ,g_org_override
                                  , PA_COST_PLUS.CHECK_FOR_EXPLICIT_MULTIPLIER(rate_sch_rev_id ,ICS.ORGANIZATION_ID))
                                  , PA_COST_PLUS.CHECK_FOR_EXPLICIT_MULTIPLIER(rate_sch_rev_id ,ICS.ORGANIZATION_ID ))=0
                    )
             )
    AND ((pa_utils2.Proj_Type_Burden_Disp_Method(ITEM.project_id) IN ('S','s','D','d') AND l_burden_profile ='N')
           OR (pa_utils2.Proj_Type_Burden_Disp_Method(ITEM.project_id) IN ('S','s') AND l_burden_profile ='Y'))
     RETURNING expenditure_item_id, decode(cs1_row.ind_compiled_set_id,ITEM.tp_ind_compiled_set_id,'UPDATE TP SCHEDULE REVISION','UPDATE COST SCHEDULE REVISION')
     BULK COLLECT INTO G_EXPENDITURE_ITEM_ID_TAB,G_ADJ_TYPE_TAB;

     stage := 290 ;
     pa_cost_plus.add_adjustment_activity(G_EXPENDITURE_ITEM_ID_TAB
                                         ,G_ADJ_TYPE_TAB
                                         ,status
                                         ,stage
                          );
     IF (status <> 0) THEN
      return;
     END IF;

        --Bug 5726575
        if l_gms_enabled = 'Y' then
          gms_pa_api3.mark_impacted_enc_items(errbuf => err_buf,
                                              retcode => ret_code,
                                              p_ind_compiled_set_id => cs1_row.ind_compiled_set_id,
                                              p_g_impacted_cost_bases => G_IMPACTED_COST_BASES_TAB(i),
                                              p_g_cp_structure => G_CP_STRUCTURE,
                                              p_indirect_cost_code => INDIRECT_COST_CODE,
                                              p_rate_sch_rev_id => rate_sch_rev_id,
                                              p_g_rate_sch_rev_id => g_rate_sch_rev_id,
                                              p_g_org_id => g_org_id,
                                              p_g_org_override => g_org_override);
          if err_buf is not null then
            raise GMS_INSERT_ENC_ITEM_ERROR;
          end if;
        end if;

         /*======================================================================================+
          | This update handles the following cases.                                             |
          | o [Cost/TP] Separate line burdening transactions when enahanced burdening profile    |
          |   option is enabled.                                                                 |
          | o [Revenue] Capital Projects with revenue based on burdened cost - for separate line |
          |    burdening transactions.                                                           |
          +======================================================================================*/
 IF l_burden_profile ='Y' THEN

         /*===============================================================+
          | M - All pre-cost distributed transactions with separate line  |
          |     burdening are set for BURDEN_RESUMMARIZE - if             |
          |     Enhanced Burdening is SET.                                |
          |     Cost Distributed Flag is left untouched.                  |
          |     Earlier, supplier invoice transactions with budgetory     |
          |     control were being routed via the distribution process.   |
          +===============================================================*/
      l_row_count :=0;
      stage := 200;

      G_EXPENDITURE_ITEM_ID_TAB.DELETE; /*4527736*/
      G_ADJ_TYPE_TAB.DELETE; /*4527736*/

      UPDATE pa_expenditure_items_all ITEM
      SET    ITEM.last_update_date = SYSDATE,
             ITEM.last_updated_by = x_last_updated_by,
             ITEM.last_update_login = x_last_update_login,
             ITEM.request_id = x_request_id,
             ITEM.program_application_id = x_program_application_id,
             ITEM.program_id = x_program_id,
             ITEM.program_update_date = SYSDATE,
/*************************
             ITEM.cost_distributed_flag = DECODE(ITEM.cost_ind_compiled_set_id, cs1_row.ind_compiled_set_id
                                            , DECODE(ITEM.cost_distributed_flag , 'Y'

                                              , DECODE(ITEM.system_linkage_function, 'VI'
                                                , DECODE(Pa_Funds_Control_Utils.Get_Fnd_Reqd_Flag(ITEM.project_id, 'STD'), 'Y', 'N'
                                                    ,ITEM.cost_distributed_flag)
                                                    ,ITEM.cost_distributed_flag)

                                                    ,ITEM.cost_distributed_flag)
                                                    ,ITEM.cost_distributed_flag),
******************/
             ITEM.revenue_distributed_flag =
                        decode(ITEM.cost_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                            decode(pa_utils2.get_capital_cost_type_code(ITEM.project_id),'B', 'N',ITEM.revenue_distributed_flag)
                                           ,ITEM.revenue_distributed_flag),
             ITEM.cc_bl_distributed_code =
                decode(ITEM.tp_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                  decode(ITEM.cc_cross_charge_code,'B',
                    'N',
                    ITEM.cc_bl_distributed_code),
                  ITEM.cc_bl_distributed_code),
             ITEM.cc_ic_processed_code =
                decode(ITEM.tp_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                  decode(ITEM.cc_cross_charge_code,'I',
                    'N',
                    ITEM.cc_ic_processed_code),
                  ITEM.cc_ic_processed_code),
             ITEM.Denom_Tp_Currency_Code =
                decode(ITEM.tp_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                       NULL, ITEM.denom_tp_currency_code),
             ITEM.Denom_Transfer_Price =
                decode(ITEM.tp_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                       NULL, ITEM.denom_transfer_price),
             ITEM.Acct_Tp_Rate_Type =
                decode(ITEM.tp_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                       NULL, ITEM.acct_tp_rate_type),
             ITEM.Acct_Tp_Rate_Date =
                decode(ITEM.tp_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                       NULL, ITEM.acct_tp_rate_date),
             ITEM.Acct_Tp_Exchange_Rate =
                decode(ITEM.tp_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                       NULL, ITEM.acct_tp_exchange_rate),
             ITEM.Acct_Transfer_Price =
                decode(ITEM.tp_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                       NULL, ITEM.acct_transfer_price),
             ITEM.Projacct_Transfer_Price =
                decode(ITEM.tp_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                       NULL, ITEM.projacct_transfer_price),
             ITEM.Cc_Markup_Base_Code =
                decode(ITEM.tp_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                       NULL, ITEM.cc_markup_base_code),
             ITEM.Tp_Base_Amount =
                decode(ITEM.tp_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                       NULL, ITEM.tp_base_amount),
             ITEM.Tp_Bill_Rate =
                decode(ITEM.tp_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                       NULL, ITEM.tp_bill_rate),
             ITEM.Tp_Bill_Markup_Percentage =
                decode(ITEM.tp_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                       NULL, ITEM.tp_bill_markup_percentage),
             ITEM.Tp_Schedule_line_Percentage =
                decode(ITEM.tp_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                       NULL, ITEM.tp_schedule_line_percentage),
             ITEM.Tp_Rule_percentage =
                decode(ITEM.tp_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                      NULL, ITEM.tp_rule_percentage),
             ITEM.adjustment_type = DECODE(ITEM.cost_distributed_flag, 'Y', 'BURDEN_RESUMMARIZE', ITEM.adjustment_type)
/********************
            ,ITEM.denom_burdened_cost =
                decode(ITEM.cost_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                                   decode(ITEM.cost_distributed_flag ,'Y'
                                   ,decode(ITEM.system_linkage_function, 'VI'
                                   ,decode(Pa_Funds_Control_Utils.Get_Fnd_Reqd_Flag(ITEM.project_id, 'STD'), 'Y', NULL,
                                          ITEM.denom_burdened_cost), ITEM.denom_burdened_cost), ITEM.denom_burdened_cost),
                       ITEM.denom_burdened_cost)
            ,ITEM.acct_burdened_cost =
                decode(ITEM.cost_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                                   decode(ITEM.cost_distributed_flag ,'Y'
                                   ,decode(ITEM.system_linkage_function, 'VI'
                                   ,decode(Pa_Funds_Control_Utils.Get_Fnd_Reqd_Flag(ITEM.project_id, 'STD'), 'Y', NULL,
                                          ITEM.acct_burdened_cost), ITEM.acct_burdened_cost), ITEM.acct_burdened_cost),
                       ITEM.acct_burdened_cost)
            ,ITEM.project_burdened_cost =
                decode(ITEM.cost_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                                   decode(ITEM.cost_distributed_flag ,'Y'
                                   ,decode(ITEM.system_linkage_function, 'VI'
                                   ,decode(Pa_Funds_Control_Utils.Get_Fnd_Reqd_Flag(ITEM.project_id, 'STD'), 'Y', NULL,
                                          ITEM.project_burdened_cost), ITEM.project_burdened_cost), ITEM.project_burdened_cost),
                       ITEM.project_burdened_cost)
            ,ITEM.burden_cost =
                decode(ITEM.cost_ind_compiled_set_id, cs1_row.ind_compiled_set_id,
                                   decode(ITEM.cost_distributed_flag ,'Y'
                                   ,decode(ITEM.system_linkage_function, 'VI'
                                   ,decode(Pa_Funds_Control_Utils.Get_Fnd_Reqd_Flag(ITEM.project_id, 'STD'), 'Y', NULL,
                                          ITEM.burden_cost), ITEM.burden_cost), ITEM.burden_cost),
                       ITEM.burden_cost)
***************************/
      WHERE   (ITEM.tp_ind_compiled_set_id = cs1_row.ind_compiled_set_id OR
               ITEM.cost_ind_compiled_set_id = cs1_row.ind_compiled_set_id )
       AND pa_project_stus_utils.Is_Project_Closed(ITEM.project_id) <>'Y'
       AND decode(l_gms_enabled,'Y',gms_pa_api2.is_award_closed(ITEM.expenditure_item_id,ITEM.task_id),'N') = 'N'
       AND NVL(ITEM.net_zero_adjustment_flag,'N') <> 'Y'
       AND exists (select /*+ NO_UNNEST */ null
                    from pa_cost_base_exp_types cbet
                  -- where cbet.cost_base = cost_base_rec.cost_base -- 4527736
                  where cbet.cost_base = G_IMPACTED_COST_BASES_TAB(i)
               AND cbet.cost_plus_structure = l_cp_structure
                     AND cbet.cost_base_type   = INDIRECT_COST_CODE
                     AND cbet.expenditure_type = ITEM.expenditure_type
              )
/*Bug# 3055700 ::Added this exist clause back for bug# 3016281*/
       AND exists (SELECT NULL
                     FROM pa_expenditures_all exp
                         ,pa_ind_compiled_sets ics
                    WHERE  exp.expenditure_id = ITEM.expenditure_id
                     AND   ((ics.ind_compiled_set_id = ITEM.cost_ind_compiled_set_id)
                             or (ics.ind_compiled_set_id = ITEM.tp_ind_compiled_set_id))
                     AND nvl(ITEM.override_to_organization_id,exp.incurred_by_organization_id) =ics.organization_id
                     AND   ics.status = 'H'
                     /*AND pa_cost_plus.check_for_explicit_multiplier(rate_sch_rev_id,ics.organization_id ) =0   /*3134445*/
               AND decode(rate_sch_rev_id,g_rate_sch_rev_id,decode(ics.organization_id,g_org_id,g_org_override,pa_cost_plus.check_for_explicit_multiplier(rate_sch_rev_id,ics.organization_id))
               ,pa_cost_plus.check_for_explicit_multiplier(rate_sch_rev_id,ics.organization_id ))=0  /*Bug# 3134445 and Bug 3938479*/
                  )

/*****************************************************************
      AND exists (select 1
                   from pa_project_types_all pt,
                        pa_projects_all      pp
                  where pp.project_id =ITEM.project_id
                    AND pp.project_type =pt.project_type
                    AND pt.burden_amt_display_method in ('D','d')
                    AND nvl(pt.org_id,-99) =nvl(pp.org_id,-99) )
*************************************************************/
     AND pa_utils2.Proj_Type_Burden_Disp_Method(ITEM.project_id) IN ('D','d')
     RETURNING expenditure_item_id, decode(cs1_row.ind_compiled_set_id,ITEM.tp_ind_compiled_set_id,'UPDATE TP SCHEDULE REVISION','UPDATE COST SCHEDULE REVISION')
     BULK COLLECT INTO G_EXPENDITURE_ITEM_ID_TAB,G_ADJ_TYPE_TAB;

     stage := 300 ;
/*
      pa_cost_plus.add_adjustment_activity(cs1_row.ind_compiled_set_id
                                           --,cost_base_rec.cost_base
                                           ,G_IMPACTED_COST_BASES_TAB(i)
                                           ,l_cp_structure
                            ,'UPDATE COST SCHEDULE REVISION'
                            ,NULL
                            ,NULL
                            ,'UPDATE TP SCHEDULE REVISION'
                            ,status
                            ,stage
                            ,G_EXPENDITURE_ITEM_ID_TAB
                            ,G_ADJ_TYPE_TAB);
*/
      pa_cost_plus.add_adjustment_activity(G_EXPENDITURE_ITEM_ID_TAB
                                          ,G_ADJ_TYPE_TAB
                                          ,status
                              ,stage
                           );
      IF (status <> 0) THEN
      return;
      END IF;

      END IF; -- profile option

      COMMIT;


         /*======================================================================================+
          | This update handles the following cases.                                             |
          | o [Rev/Inv] Same and Separate line burdening transactions - irrespective of profile  |
          |   option.                                                                            |
          +======================================================================================*/

      stage := 400;
      l_row_count :=0;

      G_EXPENDITURE_ITEM_ID_TAB.DELETE; /*4527736*/
      G_ADJ_TYPE_TAB.DELETE; /*4527736*/

      UPDATE pa_expenditure_items_all ITEM
      SET    ITEM.revenue_distributed_flag = 'N',
             ITEM.last_update_date = SYSDATE,
             ITEM.last_updated_by = x_last_updated_by,
             ITEM.last_update_login = x_last_update_login,
             ITEM.request_id = x_request_id,
             ITEM.program_application_id = x_program_application_id,
             ITEM.program_id = x_program_id,
             ITEM.program_update_date = SYSDATE
      WHERE  (ITEM.rev_ind_compiled_set_id = cs1_row.ind_compiled_set_id
               OR     ITEM.inv_ind_compiled_set_id = cs1_row.ind_compiled_set_id)
        AND  pa_project_stus_utils.Is_Project_Closed(ITEM.project_id) <>'Y'
        AND  decode(l_gms_enabled,'Y',gms_pa_api2.is_award_closed(ITEM.expenditure_item_id,ITEM.task_id),'N') = 'N'
        AND NVL(ITEM.net_zero_adjustment_flag,'N') <> 'Y'    /* missing condition added for bug 4574721 */
        AND  EXISTS (select /*+ NO_UNNEST */ 1
                      from pa_cost_base_exp_types cbet
                     --where cbet.cost_base = cost_base_rec.cost_base
                     where cbet.cost_base = G_IMPACTED_COST_BASES_TAB(i)
                       and cbet.cost_plus_structure = l_cp_structure
                       and cbet.cost_base_type   = INDIRECT_COST_CODE
                       and cbet.expenditure_type = ITEM.expenditure_type
                    )
/*Bug# 3055700 : Added this exist clause back for bug# 3016281*/
        AND  EXISTS (SELECT /*+ index(ics PA_IND_COMPILED_SETS_N6) */ NULL /*Added index hint for Bug 5683523 */
                       FROM pa_expenditures_all exp
                           ,pa_ind_compiled_sets ics
                      WHERE exp.expenditure_id = ITEM.expenditure_id
                      AND   ((ics.ind_compiled_set_id = ITEM.rev_ind_compiled_set_id)
                             or (ics.ind_compiled_set_id = ITEM.inv_ind_compiled_set_id))
                      AND nvl(ITEM.override_to_organization_id,exp.incurred_by_organization_id) =ics.organization_id
                      AND ics.ind_rate_sch_revision_id = rate_sch_rev_id /* Added for Bug 5683523 */
                      AND   ics.status = 'H'
                      /*AND pa_cost_plus.check_for_explicit_multiplier(rate_sch_rev_id,ics.organization_id ) =0   /*Bug# 3134445*/
               AND decode(rate_sch_rev_id,g_rate_sch_rev_id,decode(ics.organization_id,g_org_id,g_org_override,pa_cost_plus.check_for_explicit_multiplier(rate_sch_rev_id,ics.organization_id))
               ,pa_cost_plus.check_for_explicit_multiplier(rate_sch_rev_id,ics.organization_id ))=0  /*Bug# 3134445 and Bug 3938479*/
               )
               RETURNING expenditure_item_id, decode(cs1_row.ind_compiled_set_id,ITEM.rev_ind_compiled_set_id,'UPDATE REV SCHEDULE REVISION','UPDATE INV SCHEDULE REVISION')
               BULK COLLECT INTO G_EXPENDITURE_ITEM_ID_TAB,G_ADJ_TYPE_TAB;

      stage := 450 ;
/*      pa_cost_plus.add_adjustment_activity(cs1_row.ind_compiled_set_id
                                           --,cost_base_rec.cost_base
                                           ,G_IMPACTED_COST_BASES_TAB(i)
                                           ,l_cp_structure
                            ,NULL
                            ,'UPDATE REV SCHEDULE REVISION'
                            ,'UPDATE INV SCHEDULE REVISION'
                            ,NULL
                            ,status
                            ,stage
                            ,G_EXPENDITURE_ITEM_ID_TAB
                            ,G_ADJ_TYPE_TAB);
*/

      pa_cost_plus.add_adjustment_activity(G_EXPENDITURE_ITEM_ID_TAB
                                          ,G_ADJ_TYPE_TAB
                                          ,status
                              ,stage
                           );
      IF (status <> 0) THEN
      return;
      END IF;

      -- consider volume of expenditure items having the same compiled set id
      COMMIT;

end loop; -- cs1_cursor
end loop; --G_IMPACTED_COST_BASES_TAB
END IF; --G_IMPACTED_COST_BASES_TAB.COUNT <> 0 THEN /*4590268*/

 EXCEPTION                          /*2933915*/
  when OTHERS then
  status := SQLCODE;
  gl_mc_currency_pkg.G_PA_UPGRADE_MODE := FALSE; /*Bug 4456789 */
END;

   --
   -- Case 2: Change the end date of an existing indirect rate schedule from
   --           NULL to a new date.
   --           The expenditure items that have the same rate schedule and their
   --           incurred date are in the date range of new rate schedule are
   --           marked for recosting.
/****
   stage := 400;

 *** merged with a pervious select
   SELECT ind_rate_sch_id, start_date_active, end_date_active,
       ind_rate_sch_revision_type
   INTO   sch_id, l_start_date, l_end_date, rev_type
   FROM   pa_ind_rate_sch_revisions irsr
   WHERE  ind_rate_sch_revision_id = rate_sch_rev_id;
****/


   BEGIN
      FOR cs2_row IN cs2_cursor LOOP

         stage := 500;

      pa_cost_plus.mark_prev_rev_exp_items(cs2_row.ind_compiled_set_id,
                               rev_type,
                               'NEW REVISION',
                               l_start_date,
                               l_end_date,
                               status,
                               stage);
         if (status <> 0) then
         return;
      end if;

      END LOOP;

   EXCEPTION
      when NO_DATA_FOUND then
      return;
      when OTHERS then
      status := SQLCODE;
      gl_mc_currency_pkg.G_PA_UPGRADE_MODE := FALSE; /*Bug 4456789 */
   END;

   --
   -- Case 3: Apply actual rates
   -- mark those  expenditure items that use the same rate schedule and
   -- their incurred date are in the date range of actual rate schedule

   BEGIN
      FOR cs3_row IN cs3_cursor LOOP

         stage := 600;

      pa_cost_plus.mark_prev_rev_exp_items(cs3_row.ind_compiled_set_id,
                               rev_type,
                               'APPLY ACTUAL',
                               l_start_date,
                               l_end_date,
                               status,
                               stage);

         if (status <> 0) then
         return;
      end if;


      END LOOP;

   EXCEPTION
      when NO_DATA_FOUND then
      return;
      when OTHERS then
      status := SQLCODE;
      gl_mc_currency_pkg.G_PA_UPGRADE_MODE := FALSE; /*Bug 4456789 */
   END;

   COMMIT;
   gl_mc_currency_pkg.G_PA_UPGRADE_MODE := FALSE; /*Bug 4456789 */

EXCEPTION
  when GMS_INSERT_ENC_ITEM_ERROR then --Bug 5726575
    stage := 110;
    status := ret_code;
  WHEN OTHERS THEN
    status := SQLCODE;
    gl_mc_currency_pkg.G_PA_UPGRADE_MODE := FALSE; /*Bug 4456789 */
END mark_impacted_exp_items;


--
--  PROCEDURE
--             mark_prev_rev_exp_items
--
--  PURPOSE
--           The objective of this procedure is to mark the impacted
--        expenditure items of previous revisions.  When the actual
--        rate schedule revision is applied, or an end date is assigned
--        to an open-end revision, then the expenditure items need
--        to be marked for recosting.
--
--  HISTORY
--
--   23-AUG-94      S Lee     Created
--

procedure mark_prev_rev_exp_items(compiled_set_id IN number,
                         rev_type IN varchar2,
                      reason   IN varchar2,
                      l_start_date IN date,
                      l_end_date IN date,
                      status IN OUT NOCOPY number,
                      stage  IN OUT NOCOPY number)
is
   -- Local variable
   ei_count  number;
   adj_module       constant  varchar2(10) := 'PACOCRSR';
   cost_adj_reason  varchar2(30);
   rev_adj_reason   varchar2(30);
   inv_adj_reason   varchar2(30);
   tp_adj_reason    varchar2(30);
   l_gms_enabled    VARCHAR2(2) :='N';                                /*3059344*/
   err_buf          varchar2(4000);--Bug 5726575
   ret_code         varchar2(250);--Bug 5726575
   GMS_INSERT_ENC_ITEM_ERROR exception; --Bug 5726575
   INSERT_ADJ_ACTIVITY_ERROR exception;

   -- Cursor definition

   -- The following cursor definitions were changed to select from
   -- PA_EXPENDITURE_ITEMS_ALL instead of PA_EXPENDITURE_ITEMS to support
   -- a multi-org implementation where expenditure items may span across
   -- operating units.

      -- Modifying the statement to exclude closed project items as well as
      -- net zero items (Bug # 730849)
      -- (09/17/98)
      --
      --  Added Nvl for net_zero_adjustment_flag (896190)
      --
   CURSOR ei1_cursor
   IS
   SELECT expenditure_item_id
   FROM   pa_expenditure_items_all ei
   WHERE  cost_ind_compiled_set_id = compiled_set_id
   AND    EXISTS
           (SELECT task_id
              FROM   pa_tasks task
              WHERE  task.task_id = ei.task_id
                    AND      task.cost_ind_sch_fixed_date BETWEEN --Bug 5917245 Removed TRUNC
                    l_start_date    AND
                          NVL(l_end_date, cost_ind_sch_fixed_date))
   AND nvl(ei.net_zero_adjustment_flag,'N') <>'Y'
  /******** AND ei.task_id NOT IN
           (select t.task_id
             FROM pa_projects_all p, pa_tasks t
             WHERE t.project_id=p.project_id     AND
                   ei.task_id = t.task_id        AND
                  pa_project_stus_utils.Is_Project_Status_Closed(p.project_status_code)='Y')    Commented for Bug# 2933915*/
   AND   pa_project_stus_utils.Is_Project_Closed(ei.project_id) <>'Y'                           /*Added for bug# 2933915*/
   AND   decode(l_gms_enabled,'Y',gms_pa_api2.is_award_closed(ei.expenditure_item_id,ei.task_id),'N') = 'N';   /*3059344*/

   CURSOR ei2_cursor
   IS
   SELECT expenditure_item_id
   FROM   pa_expenditure_items_all ei
   WHERE  rev_ind_compiled_set_id = compiled_set_id
   AND    EXISTS
           (SELECT task_id
              FROM   pa_tasks task
              WHERE  task.task_id = ei.task_id
                  AND    (task.rev_ind_sch_fixed_date BETWEEN --Bug 5917245 Removed TRUNC
                       l_start_date    AND
                             NVL(l_end_date, rev_ind_sch_fixed_date)))
   AND nvl(ei.net_zero_adjustment_flag ,'N')<>'Y'
   /********AND ei.task_id NOT IN
           (select t.task_id
             FROM pa_projects_all p, pa_tasks t
             WHERE t.project_id=p.project_id     AND
                   ei.task_id = t.task_id        AND
                   pa_project_stus_utils.Is_Project_Status_Closed(p.project_status_code)='Y') Commented for Bug# 2933915*/
   AND   pa_project_stus_utils.Is_Project_Closed(ei.project_id) <>'Y'                           /*Added for bug# 2933915*/
   AND  ( decode(l_gms_enabled,'Y',gms_pa_api2.is_award_closed(ei.expenditure_item_id,ei.task_id),'N') = 'N' );  /*3059344*/

   CURSOR ei3_cursor
   IS
   SELECT expenditure_item_id
   FROM   pa_expenditure_items_all ei
   WHERE  inv_ind_compiled_set_id = compiled_set_id
   AND    EXISTS
           (SELECT task_id
              FROM   pa_tasks task
              WHERE  task.task_id = ei.task_id
                  AND    (task.inv_ind_sch_fixed_date BETWEEN --Bug 5917245Removed TRUNC
                      l_start_date    AND
                            NVL(l_end_date, inv_ind_sch_fixed_date)))
   AND nvl(ei.net_zero_adjustment_flag, 'N') <>'Y'
  /***** AND ei.task_id NOT IN
           (select t.task_id
             FROM pa_projects_all p, pa_tasks t
             WHERE t.project_id=p.project_id     AND
                   ei.task_id = t.task_id        AND
                   pa_project_stus_utils.Is_Project_Status_Closed(p.project_status_code)='Y')  Commented for Bug# 2933915*/
   AND   pa_project_stus_utils.Is_Project_Closed(ei.project_id) <>'Y'                           /*Added for bug# 2933915*/
   AND  ( decode(l_gms_enabled,'Y',gms_pa_api2.is_award_closed(ei.expenditure_item_id,ei.task_id),'N') = 'N' ); /*3059344*/


   CURSOR ei4_cursor
   IS
   SELECT expenditure_item_id
   FROM   pa_expenditure_items_all ei
   WHERE  cost_ind_compiled_set_id = compiled_set_id
  AND    expenditure_item_date BETWEEN --Bug 5917245 Removed TRUNC
           l_start_date AND
              NVL(l_end_date, expenditure_item_date)
   AND    EXISTS
           (SELECT task_id
              FROM   pa_tasks task
              WHERE  task.task_id = ei.task_id
              AND      task.cost_ind_sch_fixed_date IS NULL)
   AND nvl(ei.net_zero_adjustment_flag, 'N') <>'Y'
  /****** AND ei.task_id NOT IN
           (select t.task_id
             FROM pa_projects_all p, pa_tasks t
             WHERE t.project_id=p.project_id     AND
                   ei.task_id = t.task_id        AND
                   pa_project_stus_utils.Is_Project_Status_Closed(p.project_status_code)='Y') Commented for Bug# 2933915*/
   AND   pa_project_stus_utils.Is_Project_Closed(ei.project_id) <>'Y'                           /*Added for bug# 2933915*/
   AND  ( decode(l_gms_enabled,'Y',gms_pa_api2.is_award_closed(ei.expenditure_item_id,ei.task_id),'N') = 'N' );   /*3059344*/


   CURSOR ei5_cursor
   IS
   SELECT expenditure_item_id
   FROM   pa_expenditure_items_all ei
   WHERE  rev_ind_compiled_set_id = compiled_set_id
  AND    expenditure_item_date BETWEEN --Bug 5917245 Removed TRUNC
           l_start_date AND
              NVL(l_end_date, expenditure_item_date)
   AND    EXISTS
           (SELECT task_id
              FROM   pa_tasks task
              WHERE  task.task_id = ei.task_id
              AND    task.rev_ind_sch_fixed_date IS NULL)
   AND nvl(ei.net_zero_adjustment_flag, 'N') <>'Y'
 /******  AND ei.task_id NOT IN
           (select t.task_id
             FROM pa_projects_all p, pa_tasks t
             WHERE t.project_id=p.project_id     AND
                   ei.task_id = t.task_id        AND
                   pa_project_stus_utils.Is_Project_Status_Closed(p.project_status_code)='Y') Commented for Bug# 2933915*/
   AND   pa_project_stus_utils.Is_Project_Closed(ei.project_id) <>'Y'                           /*Added for bug# 2933915*/
   AND  ( decode(l_gms_enabled,'Y',gms_pa_api2.is_award_closed(ei.expenditure_item_id,ei.task_id),'N') = 'N' ); /*3059344*/


   CURSOR ei6_cursor
   IS
   SELECT expenditure_item_id
   FROM   pa_expenditure_items_all ei
   WHERE  inv_ind_compiled_set_id = compiled_set_id
   AND    expenditure_item_date BETWEEN --Bug 5917245 Removed TRUNC
           l_start_date AND
              NVL(l_end_date, expenditure_item_date)
   AND    EXISTS
           (SELECT task_id
              FROM   pa_tasks task
              WHERE  task.task_id = ei.task_id
              AND      task.inv_ind_sch_fixed_date IS NULL)
   AND nvl(ei.net_zero_adjustment_flag, 'N') <>'Y'
/******   AND ei.task_id NOT IN
           (select t.task_id
             FROM pa_projects_all p, pa_tasks t
             WHERE t.project_id=p.project_id     AND
                   ei.task_id = t.task_id        AND
                   pa_project_stus_utils.Is_Project_Status_Closed(p.project_status_code)='Y') Commented for bug2933915*/
   AND   pa_project_stus_utils.Is_Project_Closed(ei.project_id) <>'Y'                           /*Added for bug# 2933915*/
   AND  ( decode(l_gms_enabled,'Y',gms_pa_api2.is_award_closed(ei.expenditure_item_id,ei.task_id),'N') = 'N' ); /*3059344*/


   CURSOR ei7_cursor
   IS
   SELECT expenditure_item_id
   FROM   pa_expenditure_items_all ei
   WHERE  cost_ind_compiled_set_id = compiled_set_id
   AND    expenditure_item_date BETWEEN  --Bug 5917245 removed TRUNC
          l_start_date AND NVL(l_end_date, expenditure_item_date)
   AND nvl(ei.net_zero_adjustment_flag, 'N') <>'Y'
/******   AND ei.task_id NOT IN
           (select t.task_id
             FROM pa_projects_all p, pa_tasks t
             WHERE t.project_id=p.project_id     AND
                   ei.task_id = t.task_id        AND
                   pa_project_stus_utils.Is_Project_Status_Closed(p.project_status_code)='Y')  Commented for bug# 2933915*/
   AND   pa_project_stus_utils.Is_Project_Closed(ei.project_id) <>'Y'                           /*Added for bug# 2933915*/
   AND  (decode(l_gms_enabled,'Y',gms_pa_api2.is_award_closed(ei.expenditure_item_id,ei.task_id),'N') = 'N' ); /*3059344*/

   CURSOR ei8_cursor
   IS
   SELECT expenditure_item_id
   FROM   pa_expenditure_items_all ei
   WHERE  rev_ind_compiled_set_id = compiled_set_id
  AND    expenditure_item_date BETWEEN --Bug 5917245 Removed TRUNC
           l_start_date AND
              NVL(l_end_date, expenditure_item_date)
   AND nvl(ei.net_zero_adjustment_flag, 'N') <>'Y'
   /*****AND ei.task_id NOT IN
           (select t.task_id
             FROM pa_projects_all p, pa_tasks t
             WHERE t.project_id=p.project_id     AND
                   ei.task_id = t.task_id        AND
                   pa_project_stus_utils.Is_Project_Status_Closed(p.project_status_code)='Y') Commented for bug 2933915*/
   AND   pa_project_stus_utils.Is_Project_Closed(ei.project_id) <>'Y'                           /*Added for bug# 2933915*/
   AND  ( decode(l_gms_enabled,'Y',gms_pa_api2.is_award_closed(ei.expenditure_item_id,ei.task_id),'N') = 'N' ); /*3059344*/

   CURSOR ei9_cursor
   IS
   SELECT expenditure_item_id
   FROM   pa_expenditure_items_all ei
   WHERE  inv_ind_compiled_set_id = compiled_set_id
 AND    expenditure_item_date BETWEEN --Bug 5917245 Removed TRUNC
           l_start_date AND
              NVL(l_end_date, expenditure_item_date)
   AND nvl(ei.net_zero_adjustment_flag, 'N') <>'Y'
  /***** AND ei.task_id NOT IN
           (select t.task_id
             FROM pa_projects_all p, pa_tasks t
             WHERE t.project_id=p.project_id     AND
                   ei.task_id = t.task_id        AND
                   pa_project_stus_utils.Is_Project_Status_Closed(p.project_status_code)='Y') Commented for Bug 2933915 */
    AND   pa_project_stus_utils.Is_Project_Closed(ei.project_id) <>'Y'                           /*Added for bug# 2933915*/
   AND  ( decode(l_gms_enabled,'Y',gms_pa_api2.is_award_closed(ei.expenditure_item_id,ei.task_id),'N') = 'N' ); /*3059344*/

   CURSOR ei10_cursor
   IS
   SELECT expenditure_item_id
   FROM   pa_expenditure_items_all ei
   WHERE  cost_ind_compiled_set_id = compiled_set_id
   AND    EXISTS
              (SELECT t1.task_id
                 FROM pa_project_types_all pt,
                      pa_projects_all p,
                      pa_tasks t1
                WHERE pt.project_type = p.project_type
                  /* AND nvl(pt.org_id, -99) = nvl(p.org_id, -99) Bug 5374745 */
                  AND pt.org_id = p.org_id -- bug 5374745
                  AND p.project_id = t1.project_id
                  AND    t1.cost_ind_sch_fixed_date BETWEEN --Bug 5917245 Removed TRUNC
                               l_start_date    AND
                               NVL(l_end_date, t1.rev_ind_sch_fixed_date)
                  AND t1.task_id = ei.task_id
                  AND pt.project_type_class_code = 'CAPITAL'
                  AND pt.capital_cost_type_code = 'B')
   AND nvl(ei.net_zero_adjustment_flag,'N') <>'Y'
/****   AND ei.task_id NOT IN
           (select t.task_id
             FROM pa_projects_all p, pa_tasks t
             WHERE t.project_id=p.project_id     AND
                   ei.task_id = t.task_id        AND
                   pa_project_stus_utils.Is_Project_Status_Closed(p.project_status_code)='Y') Commented for Bug 2933915*/
    AND   pa_project_stus_utils.Is_Project_Closed(ei.project_id) <>'Y'                           /*Added for bug# 2933915*/
   AND  ( decode(l_gms_enabled,'Y',gms_pa_api2.is_award_closed(ei.expenditure_item_id,ei.task_id),'N') = 'N' ); /*3059344*/

   CURSOR ei11_cursor
   IS
   SELECT expenditure_item_id
   FROM   pa_expenditure_items_all ei
   WHERE  cost_ind_compiled_set_id = compiled_set_id
   AND    expenditure_item_date BETWEEN --Bug 5917245 Removed TRUNC
           l_start_date AND
              NVL(l_end_date, expenditure_item_date)
   AND    EXISTS
              (SELECT t1.task_id
                 FROM pa_project_types_all pt,
                      pa_projects_all p,
                      pa_tasks t1
                WHERE pt.project_type = p.project_type
                  /* AND nvl(pt.org_id, -99) = nvl(p.org_id, -99) bug 5374745 */
                  AND pt.org_id = p.org_id -- bug 5374745
                  AND p.project_id = t1.project_id
                  AND t1.cost_ind_sch_fixed_date is NULL
                  AND t1.task_id = ei.task_id
                  AND pt.project_type_class_code = 'CAPITAL'
                  AND pt.capital_cost_type_code = 'B')
   AND nvl(ei.net_zero_adjustment_flag, 'N') <>'Y'
 /*****  AND ei.task_id NOT IN
           (select t.task_id
             FROM pa_projects_all p, pa_tasks t
             WHERE t.project_id=p.project_id     AND
                   ei.task_id = t.task_id        AND
                   pa_project_stus_utils.Is_Project_Status_Closed(p.project_status_code)='Y') Commented for Bug 2933915*/
    AND   pa_project_stus_utils.Is_Project_Closed(ei.project_id) <>'Y'                           /*Added for bug# 2933915*/
   AND  ( decode(l_gms_enabled,'Y',gms_pa_api2.is_award_closed(ei.expenditure_item_id,ei.task_id),'N') = 'N' ); /*3059344*/

   CURSOR ei12_cursor
   IS
   SELECT expenditure_item_id
   FROM   pa_expenditure_items_all ei
   WHERE  cost_ind_compiled_set_id = compiled_set_id
  AND    expenditure_item_date BETWEEN --Bug 5917245 Removed TRUNC
           l_start_date AND
              NVL(l_end_date, expenditure_item_date)
 AND    EXISTS
              (SELECT t1.task_id
                 FROM pa_project_types_all pt,
                      pa_projects_all p,
                      pa_tasks t1
                WHERE pt.project_type = p.project_type
                  /* AND nvl(pt.org_id, -99) = nvl(p.org_id, -99) Bug 5374745 */
                  AND pt.org_id = p.org_id -- bug 5374745
                  AND p.project_id = t1.project_id
                  AND t1.task_id = ei.task_id
                  AND pt.project_type_class_code = 'CAPITAL'
                  AND pt.capital_cost_type_code = 'B')
   AND nvl(ei.net_zero_adjustment_flag, 'N') <>'Y'
  /****** AND ei.task_id NOT IN
           (select t.task_id
             FROM pa_projects_all p, pa_tasks t
             WHERE t.project_id=p.project_id     AND
                   ei.task_id = t.task_id        AND
                   pa_project_stus_utils.Is_Project_Status_Closed(p.project_status_code)='Y')  Commented for bug# 2933915*/
   AND   pa_project_stus_utils.Is_Project_Closed(ei.project_id) <>'Y'                           /*Added for bug# 2933915*/
   AND  ( decode(l_gms_enabled,'Y',gms_pa_api2.is_award_closed(ei.expenditure_item_id,ei.task_id),'N') = 'N' ); /*3059344*/


   /*
    * IC related change:
    * cursors defined for TP schedule related changes.
    * ei13 is for FIRM schedule where as ei14 is for PROVISIONAL schedule.
    * Note: explain plan is fine in RBO, cant test it in CBO because of
    *       non-availability of volume data.
    */
/*Bug# 2164590:Commenting this query and tuned it below*/
/*
CURSOR ei13_cursor
   IS
   SELECT expenditure_item_id
   FROM   pa_expenditure_items_all ei,
          pa_system_linkages       syslink,
          pa_tasks                 task,
          pa_projects_all          proj
   WHERE  ei.tp_ind_compiled_set_id  = compiled_set_id
   AND    ei.system_linkage_function = syslink.function
   AND    task.task_id               = ei.task_id
     AND    (
           ( TRUNC(NVL(task.labor_tp_fixed_date, ei.expenditure_item_date)) BETWEEN
                 TRUNC(l_start_date)    AND
                 TRUNC(NVL(l_end_date, NVL(task.labor_tp_fixed_date,ei.expenditure_item_date)))
             AND
             syslink.labor_non_labor_flag = 'Y')
           OR
           ( TRUNC(NVL(task.nl_tp_fixed_date, ei.expenditure_item_date)) BETWEEN
                 TRUNC(l_start_date)    AND
                 TRUNC(NVL(l_end_date, NVL(task.nl_tp_fixed_date,ei.expenditure_item_date)))
             AND
             syslink.labor_non_labor_flag = 'N')
           )
   AND nvl(ei.net_zero_adjustment_flag, 'N') <> 'Y'
   AND proj.project_id = task.project_id
   AND pa_project_stus_utils.Is_Project_Status_Closed(proj.project_status_code) <> 'Y';*/

/*Bug# 2164590:Changed ei13_cursor for performance*/
  CURSOR ei13_cursor
     IS
     SELECT EXPENDITURE_ITEM_ID
     FROM   PA_EXPENDITURE_ITEMS_ALL EI
     WHERE  tp_ind_compiled_set_id = compiled_set_id
     AND  EXISTS
          (SELECT task_id
             FROM pa_tasks task, pa_system_linkages syslink  /*2933915 : ,pa_projects_all proj :Join with pa_projects is not required here */
            WHERE task.task_id = ei.task_id
              AND ei.system_linkage_function = syslink.function
            /*AND task.project_id = proj.project_id                                                 2933915*/
              AND task.project_id = ei.project_id                                                  /*2933915*/
              AND pa_project_stus_utils.Is_Project_Closed(ei.project_id) <> 'Y'                    /*2933915*/
              AND ( decode(l_gms_enabled,'Y',gms_pa_api2.is_award_closed(ei.expenditure_item_id,ei.task_id),'N') = 'N' ) /*3059344*/
              AND nvl(ei.net_zero_adjustment_flag, 'N') <>'Y'
               AND ((NVL(task.labor_tp_fixed_date, ei.expenditure_item_date) BETWEEN --Bug 5917245 Removed TRUNC
                     l_start_date
              AND NVL(l_end_date, NVL(task.labor_tp_fixed_date,ei.expenditure_item_date))
              AND syslink.labor_non_labor_flag = 'Y')
               OR (NVL(task.nl_tp_fixed_date, ei.expenditure_item_date) BETWEEN --Bug 5917245 Removed TRUNC
                   l_start_date    AND
                   NVL(l_end_date, NVL(task.nl_tp_fixed_date,ei.expenditure_item_date))
              AND syslink.labor_non_labor_flag = 'N')
              ));

   CURSOR ei14_cursor
   IS
   SELECT expenditure_item_id
   FROM   pa_expenditure_items_all ei
        /*  pa_tasks                 task   -- Commented for Bug#3585192 */
        /*  pa_projects_all          proj                          :2933915 :Redundant join and hence can be removed */
   WHERE  tp_ind_compiled_set_id = compiled_set_id
   AND    ei.expenditure_item_date BETWEEN --Bug 5917245 Removed TRUNC
           l_start_date AND
              NVL(l_end_date, ei.expenditure_item_date)
   AND nvl(ei.net_zero_adjustment_flag, 'N') <>'Y'
 /****  AND ei.task_id = task.task_id
   AND proj.project_id = task.project_id
   AND pa_project_stus_utils.Is_Project_Status_Closed(proj.project_status_code) <> 'Y'                 ****2933915*/
   AND pa_project_stus_utils.Is_Project_Closed(ei.project_id) <> 'Y'                                  /*2933915*/
   AND  ( decode(l_gms_enabled,'Y',gms_pa_api2.is_award_closed(ei.expenditure_item_id,ei.task_id),'N') = 'N' ); /*3059344*/



   -- Standard who
   x_last_updated_by            NUMBER(15);
   x_last_update_login          NUMBER(15);
   x_request_id                 NUMBER(15);
   x_program_application_id     NUMBER(15);
   x_program_id                 NUMBER(15);

    l_burden_profile              VARCHAR2(2);                                    /*2933915*/

BEGIN

     --
     -- Get the standard who information
     --
     x_last_updated_by            := FND_GLOBAL.USER_ID;
     x_last_update_login          := FND_GLOBAL.LOGIN_ID;
     x_request_id                 := FND_GLOBAL.CONC_REQUEST_ID;
     x_program_application_id     := FND_GLOBAL.PROG_APPL_ID;
     x_program_id                 := FND_GLOBAL.CONC_PROGRAM_ID;

--     l_burden_profile := nvl(fnd_profile.value('PA_ENHANCED_BURDENING'),'N');                 /*2933915*/
     l_burden_profile := pa_utils2.IsEnhancedBurdeningEnabled;

      IF gms_install.enabled THEN                                /*3059344 :To check if grants is installed */
       l_gms_enabled := 'Y' ;
      END IF ;

     /*
      * IC related change:
      * New reason added for TP schedule changes.
      */
     if (reason = 'APPLY ACTUAL') then

        cost_adj_reason := 'APPLY ACTUAL COST SCH REV';
        rev_adj_reason  := 'APPLY ACTUAL REV SCH REV';
        inv_adj_reason  := 'APPLY ACTUAL INV SCH REV';
        tp_adj_reason   := 'APPLY_ACTUAL_TP_SCH_REV';

     else

        cost_adj_reason := 'NEW COST SCHEDULE REVISION';
        rev_adj_reason  := 'NEW REV SCHEDULE REVISION';
        inv_adj_reason  := 'NEW INV SCHEDULE REVISION';
        tp_adj_reason   := 'NEW_TP_SCHEDULE_REVISION';

     end if;

     --
     --  Mark expenditure items for previous revisions
     --

     if (rev_type = 'F') then

       --
       --  Check if schedule fixed date is within the range.
       --  Costing with schedule fixed date
       --

      /*
         Burdening related changes
         Reset burdened_costs to null so that costing program recalculates them.
       */
      -- Modifying the statement to exclude closed project items as well as
      -- net zero items (Bug # 730849)
      -- (09/17/98)
      --
      --  Added Nvl for net_zero_adjustment_flag (896190)
      -- ---------------------------------------------------------------------
     /* Updating Project_Burdened_Cost also for Bug 2736773 */

/***Bug 2933915 : Added the exists clause in this update to indicate that except profile ='Y' and display_method ='D' -for all
   cases we will be marking ei for cost reprocessing */
   /*If Burdening is on same ei then update adjustment_type as BURDEN_COMPILE else update it as BURDEN_RESUMMARIZE .*/

       UPDATE pa_expenditure_items_all ei
       SET    cost_distributed_flag =  'N',
              adjustment_type ='BURDEN_RECOMPILE',              /*2933915*/
           cost_burden_distributed_flag = 'N',
              last_update_date = SYSDATE,
              last_updated_by = x_last_updated_by,
              last_update_login = x_last_update_login,
              request_id = x_request_id,
              program_application_id = x_program_application_id,
              program_id = x_program_id,
              program_update_date = SYSDATE,
              denom_burdened_cost = NULL,
              project_burdened_cost = NULL,
              acct_burdened_cost = NULL,
              burden_cost = NULL
       WHERE  cost_ind_compiled_set_id = compiled_set_id
       AND    EXISTS
           (SELECT task_id
              FROM   pa_tasks task
              WHERE  task.task_id = ei.task_id
                   AND      task.cost_ind_sch_fixed_date BETWEEN
                    l_start_date    AND
                          NVL(l_end_date, cost_ind_sch_fixed_date))
               AND nvl(ei.net_zero_adjustment_flag, 'N') <>'Y'
   /******     AND ei.task_id NOT IN
                    (select t.task_id
                     FROM pa_projects_all p, pa_tasks t
                     WHERE t.project_id=p.project_id     AND
                          ei.task_id = t.task_id        AND
                          pa_project_stus_utils.Is_Project_Status_Closed(p.project_status_code)='Y') Commented for Bug 2933915*/
       AND  pa_project_stus_utils.Is_Project_Closed(ei.project_id) <>'Y'                             /*2933915*/
       AND ((pa_utils2.Proj_Type_Burden_Disp_Method(ei.project_id) IN ('S','s','D','d') AND l_burden_profile ='N') /*Added for 2933915*/
           OR (pa_utils2.Proj_Type_Burden_Disp_Method(ei.project_id) IN ('S','s') AND l_burden_profile ='Y'))
       AND  ( gms_pa_api2.is_award_closed(ei.expenditure_item_id,ei.task_id) = 'N' );


       -- consider volume of expenditure items having the same compiled set id
       COMMIT;

       if l_gms_enabled = 'Y' then  --Bug 5693864
         gms_pa_api3.mark_prev_rev_enc_items (errbuf => err_buf,
                                              retcode => ret_code,
                                              p_compiled_set_id => compiled_set_id,
                                              p_start_date => l_start_date,
                                              p_end_date => l_end_date,
                                              p_mode => 'T');
         if err_buf is not null then
           raise GMS_INSERT_ENC_ITEM_ERROR;
         end if;
         commit;
       end if;

       ei_count := 0;

       FOR ei1_row IN ei1_cursor LOOP

       PA_Adjustments.InsAuditRec(ei1_row.expenditure_item_id,
                         cost_adj_reason,
                         adj_module,
                         x_last_updated_by,
                         x_last_update_login,
                         status,
                              x_request_id,
                              x_program_id,
                              x_program_application_id,
                         SYSDATE);

       IF (status <> 0) THEN
          raise INSERT_ADJ_ACTIVITY_ERROR;
       END IF;

       ei_count := ei_count + 1;

       IF (ei_count >= 500) THEN
           COMMIT;
           ei_count := 0;
       END IF;

       END LOOP;

       COMMIT;


       --
       -- Revenue and invoice with schedule fixed date
       --

      -- Modifying the statement to exclude closed project items as well as
      -- net zero items (Bug # 730849)
      -- (09/17/98)
      --
      --  Added Nvl for net_zero_adjustment_flag (896190)
      --
       UPDATE pa_expenditure_items_all ei
       SET    revenue_distributed_flag = 'N',
              last_update_date = SYSDATE,
              last_updated_by = x_last_updated_by,
              last_update_login = x_last_update_login,
              request_id = x_request_id,
              program_application_id = x_program_application_id,
              program_id = x_program_id,
              program_update_date = SYSDATE
       WHERE  rev_ind_compiled_set_id = compiled_set_id
       AND    EXISTS
           (SELECT task_id
              FROM   pa_tasks task
              WHERE  task.task_id = ei.task_id
                  AND    task.rev_ind_sch_fixed_date BETWEEN --Bug#5917245 Removed TRUNC
                      l_start_date    AND
                            NVL(l_end_date, rev_ind_sch_fixed_date))
               AND nvl(ei.net_zero_adjustment_flag, 'N') <>'Y'
/****2933915   AND ei.task_id NOT IN
                    (select t.task_id
                     FROM pa_projects_all p, pa_tasks t
                     WHERE t.project_id=p.project_id     AND
                          ei.task_id = t.task_id        AND
                          pa_project_stus_utils.Is_Project_Status_Closed(p.project_status_code)='Y')  Commenteed for bug# 2933915*/
       AND pa_project_stus_utils.Is_Project_Closed(ei.project_id)<>'Y'                  /*2933915*/
      AND  ( gms_pa_api2.is_award_closed(ei.expenditure_item_id,ei.task_id) = 'N' );


       -- consider volume of expenditure items having the same compiled set id
       COMMIT;

       ei_count := 0;

       FOR ei2_row IN ei2_cursor LOOP

       PA_Adjustments.InsAuditRec(ei2_row.expenditure_item_id,
                         rev_adj_reason,
                         adj_module,
                         x_last_updated_by,
                         x_last_update_login,
                         status,
                              x_request_id,
                              x_program_id,
                              x_program_application_id,
                         SYSDATE);

       IF (status <> 0) THEN
          raise INSERT_ADJ_ACTIVITY_ERROR;
       END IF;

       ei_count := ei_count + 1;

       IF (ei_count >= 500) THEN
           COMMIT;
           ei_count := 0;
       END IF;

       END LOOP;

       COMMIT;

      -- Modifying the statement to exclude closed project items as well as
      -- net zero items (Bug # 730849)
      -- (09/17/98)
      --
      --  Added Nvl for net_zero_adjustment_flag (896190)
      --

       UPDATE pa_expenditure_items_all ei
       SET    revenue_distributed_flag = 'N',
              last_update_date = SYSDATE,
              last_updated_by = x_last_updated_by,
              last_update_login = x_last_update_login,
              request_id = x_request_id,
              program_application_id = x_program_application_id,
              program_id = x_program_id,
              program_update_date = SYSDATE
       WHERE  inv_ind_compiled_set_id = compiled_set_id
       AND    EXISTS
           (SELECT task_id
              FROM   pa_tasks task
              WHERE  task.task_id = ei.task_id
                 AND    task.inv_ind_sch_fixed_date BETWEEN --Bug#5917245 Removed TRUNC
                      l_start_date    AND
                            NVL(l_end_date, inv_ind_sch_fixed_date))
               AND nvl(ei.net_zero_adjustment_flag, 'N') <>'Y'
/*****         AND ei.task_id NOT IN
                    (select t.task_id
                     FROM pa_projects_all p, pa_tasks t
                     WHERE t.project_id=p.project_id     AND
                          ei.task_id = t.task_id        AND
                          pa_project_stus_utils.Is_Project_Status_Closed(p.project_status_code)='Y') Commented for bug# 2933915*/
      AND pa_project_stus_utils.Is_Project_Closed(ei.project_id)<>'Y'                                                /*2933915*/
      AND  ( gms_pa_api2.is_award_closed(ei.expenditure_item_id,ei.task_id) = 'N' );


       -- consider volume of expenditure items having the same compiled set id
       COMMIT;

       ei_count := 0;

       FOR ei3_row IN ei3_cursor LOOP

       PA_Adjustments.InsAuditRec(ei3_row.expenditure_item_id,
                         inv_adj_reason,
                         adj_module,
                         x_last_updated_by,
                         x_last_update_login,
                         status,
                              x_request_id,
                              x_program_id,
                              x_program_application_id,
                         SYSDATE);

       IF (status <> 0) THEN
          raise INSERT_ADJ_ACTIVITY_ERROR;
       END IF;

       ei_count := ei_count + 1;

       IF (ei_count >= 500) THEN
           COMMIT;
           ei_count := 0;
       END IF;

       END LOOP;

       COMMIT;

      --
      -- Section For Capital Projects
      --
      -- This section is added as a part of fix for bug 897479.
      --
       UPDATE pa_expenditure_items_all ei
       SET    revenue_distributed_flag = 'N',
              last_update_date = SYSDATE,
              last_updated_by = x_last_updated_by,
              last_update_login = x_last_update_login,
              request_id = x_request_id,
              program_application_id = x_program_application_id,
              program_id = x_program_id,
              program_update_date = SYSDATE
       WHERE  cost_ind_compiled_set_id = compiled_set_id
         AND    EXISTS
                    (SELECT t1.task_id
                       FROM pa_project_types_all pt,
                            pa_projects_all p,
                            pa_tasks t1
                      WHERE pt.project_type = p.project_type
                        AND nvl(pt.org_id, -99) = nvl(p.org_id, -99)
                        AND p.project_id = t1.project_id
                        AND    TRUNC(t1.cost_ind_sch_fixed_date) BETWEEN
                                     TRUNC(l_start_date)    AND
                                     TRUNC(NVL(l_end_date, t1.rev_ind_sch_fixed_date))
                        AND t1.task_id = ei.task_id
                        AND pt.project_type_class_code = 'CAPITAL'
                        AND pt.capital_cost_type_code = 'B')
         AND nvl(ei.net_zero_adjustment_flag,'N') <>'Y'
 /****   AND ei.task_id NOT IN
                 (select t.task_id
                   FROM pa_projects_all p, pa_tasks t
                   WHERE t.project_id=p.project_id     AND
                         ei.task_id = t.task_id        AND
                         pa_project_stus_utils.Is_Project_Status_Closed(p.project_status_code)='Y')    Commented for 2933915*/
       AND pa_project_stus_utils.Is_Project_Closed(ei.project_id)<>'Y'                                 /*2933915*/
      AND  ( gms_pa_api2.is_award_closed(ei.expenditure_item_id,ei.task_id) = 'N' );

       -- consider volume of expenditure items having the same compiled set id
       COMMIT;

       ei_count := 0;

       FOR ei10_row IN ei10_cursor LOOP

       PA_Adjustments.InsAuditRec(ei10_row.expenditure_item_id,
                         cost_adj_reason,
                         adj_module,
                         x_last_updated_by,
                         x_last_update_login,
                         status,
                              x_request_id,
                              x_program_id,
                              x_program_application_id,
                         SYSDATE);

       IF (status <> 0) THEN
          raise INSERT_ADJ_ACTIVITY_ERROR;
       END IF;

       ei_count := ei_count + 1;

       IF (ei_count >= 500) THEN
           COMMIT;
           ei_count := 0;
       END IF;

       END LOOP;

       COMMIT;

      --
      -- End Section For Capital Projects
      --

       --
       -- Costing without schedule fixed date.  Use expenditure item date.
       --

      /*
         Burdening related changes
         Reset burdened_costs to null so that costing program recalculates them.
       */
      -- Modifying the statement to exclude closed project items as well as
      -- net zero items (Bug # 730849)
      -- (09/17/98)
      --
      --  Added Nvl for net_zero_adjustment_flag (896190)
      -- ---------------------------------------------------------------------
     /* Updating Project_Burdened_Cost also for Bug 2736773 */
       UPDATE pa_expenditure_items_all ei
       SET    cost_distributed_flag =  'N' ,
              adjustment_type ='BURDEN_RECOMPILE',          /*2933915*/
           cost_burden_distributed_flag = 'N',
              last_update_date = SYSDATE,
              last_updated_by = x_last_updated_by,
              last_update_login = x_last_update_login,
              request_id = x_request_id,
              program_application_id = x_program_application_id,
              program_id = x_program_id,
              program_update_date = SYSDATE,
              denom_burdened_cost = NULL,
              project_burdened_cost = NULL,
              acct_burdened_cost = NULL,
              burden_cost = NULL
       WHERE  cost_ind_compiled_set_id = compiled_set_id
       AND    ei.expenditure_item_date BETWEEN  --Bug 5917245 Removed TRUNC
              l_start_date AND NVL(l_end_date, ei.expenditure_item_date)
       AND    EXISTS
           (SELECT task_id
              FROM   pa_tasks task
              WHERE  task.task_id = ei.task_id
              AND      task.cost_ind_sch_fixed_date IS NULL)
          AND nvl(ei.net_zero_adjustment_flag, 'N') <>'Y'
/*****          AND ei.task_id NOT IN
              (select t.task_id
                FROM pa_projects_all p, pa_tasks t
                WHERE t.project_id=p.project_id     AND
                      ei.task_id = t.task_id        AND
                      pa_project_stus_utils.Is_Project_Status_Closed(p.project_status_code)='Y') Commented for bug 2933915*/
      AND pa_project_stus_utils.Is_Project_Closed(ei.project_id)<>'Y'                            /*2933915*/
      AND  ( gms_pa_api2.is_award_closed(ei.expenditure_item_id,ei.task_id) = 'N' )
      AND ((pa_utils2.Proj_Type_Burden_Disp_Method(ei.project_id) IN ('S','s','D','d') AND l_burden_profile ='N') /*Added for 2933915*/
        OR (pa_utils2.Proj_Type_Burden_Disp_Method(ei.project_id) IN ('S','s') AND l_burden_profile ='Y')) ;

       COMMIT;

       if l_gms_enabled = 'Y' then  --Bug 5726575
         gms_pa_api3.mark_prev_rev_enc_items (errbuf => err_buf,
                                              retcode => ret_code,
                                              p_compiled_set_id => compiled_set_id,
                                              p_start_date => l_start_date,
                                              p_end_date => l_end_date,
                                              p_mode => 'N');
         if err_buf is not null then
           raise GMS_INSERT_ENC_ITEM_ERROR;
         end if;
         commit;
       end if;

       ei_count := 0;

       FOR ei4_row IN ei4_cursor LOOP

       PA_Adjustments.InsAuditRec(ei4_row.expenditure_item_id,
                         cost_adj_reason,
                         adj_module,
                         x_last_updated_by,
                         x_last_update_login,
                         status,
                              x_request_id,
                              x_program_id,
                              x_program_application_id,
                         SYSDATE);

       IF (status <> 0) THEN
          raise INSERT_ADJ_ACTIVITY_ERROR;
       END IF;

       ei_count := ei_count + 1;

       IF (ei_count >= 500) THEN
           COMMIT;
           ei_count := 0;
       END IF;

       END LOOP;

       COMMIT;

       --
       -- Revenue and invoice without schedule fixed date.  Use expenditure
       -- item date.
       --
      -- Modifying the statement to exclude closed project items as well as
      -- net zero items (Bug # 730849)
      -- (09/17/98)
      --
      --  Added Nvl for net_zero_adjustment_flag (896190)
      --

       UPDATE pa_expenditure_items_all ei
       SET    revenue_distributed_flag = 'N',
              last_update_date = SYSDATE,
              last_updated_by = x_last_updated_by,
              last_update_login = x_last_update_login,
              request_id = x_request_id,
              program_application_id = x_program_application_id,
              program_id = x_program_id,
              program_update_date = SYSDATE
       WHERE  rev_ind_compiled_set_id = compiled_set_id
       AND    expenditure_item_date BETWEEN --Bug 5917245 Removed TRUNC
              l_start_date AND
              NVL(l_end_date, expenditure_item_date)
       AND    EXISTS
           (SELECT task_id
              FROM   pa_tasks task
              WHERE  task.task_id = ei.task_id
              AND    task.rev_ind_sch_fixed_date IS NULL)
          AND nvl(ei.net_zero_adjustment_flag, 'N') <>'Y'
/***          AND ei.task_id NOT IN
              (select t.task_id
               FROM pa_projects_all p, pa_tasks t
               WHERE t.project_id=p.project_id     AND
                     ei.task_id = t.task_id        AND
                     pa_project_stus_utils.Is_Project_Status_Closed(p.project_status_code)='Y') Commented for bug2933915*/
       AND pa_project_stus_utils.Is_Project_Closed(ei.project_id)<>'Y'                         /*2933915*/
      AND  ( gms_pa_api2.is_award_closed(ei.expenditure_item_id,ei.task_id) = 'N' );


       -- consider volume of expenditure items having the same compiled set id
       COMMIT;

       ei_count := 0;

       FOR ei5_row IN ei5_cursor LOOP

       PA_Adjustments.InsAuditRec(ei5_row.expenditure_item_id,
                         rev_adj_reason,
                         adj_module,
                         x_last_updated_by,
                         x_last_update_login,
                         status,
                              x_request_id,
                              x_program_id,
                              x_program_application_id,
                         SYSDATE);

       IF (status <> 0) THEN
          raise INSERT_ADJ_ACTIVITY_ERROR;
       END IF;

       ei_count := ei_count + 1;

       IF (ei_count >= 500) THEN
           COMMIT;
           ei_count := 0;
       END IF;

       END LOOP;

       COMMIT;

      -- Modifying the statement to exclude closed project items as well as
      -- net zero items (Bug # 730849)
      -- (09/17/98)
      --
      --  Added Nvl for net_zero_adjustment_flag (896190)
      --
       UPDATE pa_expenditure_items_all ei
       SET    revenue_distributed_flag = 'N',
              last_update_date = SYSDATE,
              last_updated_by = x_last_updated_by,
              last_update_login = x_last_update_login,
              request_id = x_request_id,
              program_application_id = x_program_application_id,
              program_id = x_program_id,
              program_update_date = SYSDATE
       WHERE  inv_ind_compiled_set_id = compiled_set_id
        AND    expenditure_item_date BETWEEN --Bug 5917245 Removed TRUNC
              l_start_date AND
              NVL(l_end_date, expenditure_item_date)
       AND    EXISTS
           (SELECT task_id
              FROM   pa_tasks task
              WHERE  task.task_id = ei.task_id
              AND    task.inv_ind_sch_fixed_date IS NULL)
          AND nvl(ei.net_zero_adjustment_flag, 'N') <>'Y'
    /***      AND ei.task_id NOT IN
              (select t.task_id
               FROM pa_projects_all p, pa_tasks t
               WHERE t.project_id=p.project_id     AND
                     ei.task_id = t.task_id        AND
                     pa_project_stus_utils.Is_Project_Status_Closed(p.project_status_code)='Y')   Commented for bug# 2933915*/
       AND pa_project_stus_utils.Is_Project_Closed(ei.project_id)<>'Y'                  /*2933915*/
      AND  ( gms_pa_api2.is_award_closed(ei.expenditure_item_id,ei.task_id) = 'N' );


       -- consider volume of expenditure items having the same compiled set id
       COMMIT;

       ei_count := 0;

       FOR ei6_row IN ei6_cursor LOOP

       PA_Adjustments.InsAuditRec(ei6_row.expenditure_item_id,
                         inv_adj_reason,
                         adj_module,
                         x_last_updated_by,
                         x_last_update_login,
                         status,
                              x_request_id,
                              x_program_id,
                              x_program_application_id,
                         SYSDATE);

       IF (status <> 0) THEN
          raise INSERT_ADJ_ACTIVITY_ERROR;
       END IF;

       ei_count := ei_count + 1;

       IF (ei_count >= 500) THEN
           COMMIT;
           ei_count := 0;
       END IF;

       END LOOP;

       COMMIT;

      --
      -- Section for Capital projects
      --
      --
      -- This section has been added as a part of bug 897479.
      --
      --

     IF l_end_date IS NOT NULL THEN

       UPDATE pa_expenditure_items_all ei
       SET    revenue_distributed_flag = 'N',
              last_update_date = SYSDATE,
              last_updated_by = x_last_updated_by,
              last_update_login = x_last_update_login,
              request_id = x_request_id,
              program_application_id = x_program_application_id,
              program_id = x_program_id,
              program_update_date = SYSDATE
       WHERE  cost_ind_compiled_set_id = compiled_set_id
       AND    expenditure_item_date BETWEEN --Bug5917245 Removed TRUNC
                     l_start_date AND l_end_date
                    /* NVL(l_end_date, expenditure_item_date) bug 8668217 */
       AND    EXISTS
                  (SELECT t1.task_id
                     FROM pa_project_types_all pt,
                          pa_projects_all p,
                          pa_tasks t1
                    WHERE pt.project_type = p.project_type
                      AND nvl(pt.org_id, -99) = nvl(p.org_id, -99)
                      AND p.project_id = t1.project_id
                      AND t1.cost_ind_sch_fixed_date is NULL
                      AND t1.task_id = ei.task_id
                      AND pt.project_type_class_code = 'CAPITAL'
                      AND pt.capital_cost_type_code = 'B')
       AND nvl(ei.net_zero_adjustment_flag, 'N') <>'Y'
/*       AND ei.task_id NOT IN
               (select t.task_id
                 FROM pa_projects_all p, pa_tasks t
                 WHERE t.project_id=p.project_id     AND
                       ei.task_id = t.task_id        AND
                       pa_project_stus_utils.Is_Project_Status_Closed(p.project_status_code)='Y')  Commented for bug# 2933915*/
        AND pa_project_stus_utils.Is_Project_Closed(ei.project_id)<>'Y'                            /*2933915*/
       AND  ( gms_pa_api2.is_award_closed(ei.expenditure_item_id,ei.task_id) = 'N' );

      ELSE
         UPDATE pa_expenditure_items_all ei
       SET    revenue_distributed_flag = 'N',
              last_update_date = SYSDATE,
              last_updated_by = x_last_updated_by,
              last_update_login = x_last_update_login,
              request_id = x_request_id,
              program_application_id = x_program_application_id,
              program_id = x_program_id,
              program_update_date = SYSDATE
       WHERE  cost_ind_compiled_set_id = compiled_set_id
       AND    expenditure_item_date >= l_start_date /*BETWEEN --Bug5917245 Removed TRUNC
                     l_start_date AND  bug 8668217
                     NVL(l_end_date, expenditure_item_date)*/
       AND    EXISTS
                  (SELECT t1.task_id
                     FROM pa_project_types_all pt,
                          pa_projects_all p,
                          pa_tasks t1
                    WHERE pt.project_type = p.project_type
                      AND nvl(pt.org_id, -99) = nvl(p.org_id, -99)
                      AND p.project_id = t1.project_id
                      AND t1.cost_ind_sch_fixed_date is NULL
                      AND t1.task_id = ei.task_id
                      AND pt.project_type_class_code = 'CAPITAL'
                      AND pt.capital_cost_type_code = 'B')
       AND nvl(ei.net_zero_adjustment_flag, 'N') <>'Y'
/*       AND ei.task_id NOT IN
               (select t.task_id
                 FROM pa_projects_all p, pa_tasks t
                 WHERE t.project_id=p.project_id     AND
                       ei.task_id = t.task_id        AND
                       pa_project_stus_utils.Is_Project_Status_Closed(p.project_status_code)='Y')  Commented for bug# 2933915*/
        AND pa_project_stus_utils.Is_Project_Closed(ei.project_id)<>'Y'                            /*2933915*/
       AND  ( gms_pa_api2.is_award_closed(ei.expenditure_item_id,ei.task_id) = 'N' );

      END IF;

       COMMIT;

       ei_count := 0;

       FOR ei11_row IN ei11_cursor LOOP

       PA_Adjustments.InsAuditRec(ei11_row.expenditure_item_id,
                         cost_adj_reason,
                         adj_module,
                         x_last_updated_by,
                         x_last_update_login,
                         status,
                              x_request_id,
                              x_program_id,
                              x_program_application_id,
                         SYSDATE);

       IF (status <> 0) THEN
          raise INSERT_ADJ_ACTIVITY_ERROR;
       END IF;

       ei_count := ei_count + 1;

       IF (ei_count >= 500) THEN
           COMMIT;
           ei_count := 0;
       END IF;

       END LOOP;

       COMMIT;

      --
      -- Section for Capital projects
      --


       /*
        * IC related change:
        * updates and activity logging done for TP schedule change.
        * Note: explain plan is fine in RBO, cant test it in CBO because of
        *       non-availability of volume data.
        */
       /*
        * Bug 4885396 : Moved 3 EI based checks from Exists subquery to the
        * main query.
        */
       UPDATE pa_expenditure_items_all ei
       SET    cc_bl_distributed_code =
                decode( cc_cross_charge_code,'B',
                  'N',
                  cc_bl_distributed_code),
             cc_ic_processed_code =
                decode( cc_cross_charge_code,'I',
                  'N',
                  cc_ic_processed_code),
             Denom_Tp_Currency_Code = NULL,
             Denom_Transfer_Price = NULL,
             Acct_Tp_Rate_Type = NULL,
             Acct_Tp_Rate_Date = NULL,
             Acct_Tp_Exchange_Rate = NULL,
             Acct_Transfer_Price = NULL,
             Projacct_Transfer_Price = NULL,
             Cc_Markup_Base_Code = NULL,
             Tp_Base_Amount = NULL,
             Tp_Bill_Rate = NULL,
             Tp_Bill_Markup_Percentage = NULL,
             Tp_Schedule_line_Percentage = NULL,
             Tp_Rule_percentage = NULL,
             last_update_date = SYSDATE,
             last_updated_by = x_last_updated_by,
             last_update_login = x_last_update_login,
             request_id = x_request_id,
             program_application_id = x_program_application_id,
             program_id = x_program_id,
             program_update_date = SYSDATE
       WHERE  tp_ind_compiled_set_id = compiled_set_id
         AND pa_project_stus_utils.Is_Project_Closed(ei.project_id) <> 'Y'
         AND ( gms_pa_api2.is_award_closed(ei.expenditure_item_id,ei.task_id) = 'N' )
         AND nvl(ei.net_zero_adjustment_flag, 'N') <>'Y'
       AND    EXISTS
           (SELECT task_id
              FROM   pa_tasks task, pa_system_linkages syslink               /*, pa_projects_all proj :Redundant :2933915*/
              WHERE  task.task_id = ei.task_id
          AND    ei.system_linkage_function = syslink.function
     /*   AND    task.project_id = proj.project_id     Commented for 2933915*/
          AND    task.project_id = ei.project_id                                        /*2933915*/
             AND    (
           ( NVL(task.labor_tp_fixed_date, ei.expenditure_item_date) BETWEEN --Bug 5917245 Removed TRUNC
                 l_start_date    AND
                 NVL(l_end_date, NVL(task.labor_tp_fixed_date,ei.expenditure_item_date))
             AND
             syslink.labor_non_labor_flag = 'Y')
           OR
           ( NVL(task.nl_tp_fixed_date, ei.expenditure_item_date) BETWEEN --Bug 5917245 Removed TRUNC
                 l_start_date    AND
                 NVL(l_end_date, NVL(task.nl_tp_fixed_date,ei.expenditure_item_date))
             AND
             syslink.labor_non_labor_flag = 'N')
           ));

       COMMIT;

       ei_count := 0;

       FOR ei13_row IN ei13_cursor LOOP

       PA_Adjustments.InsAuditRec(ei13_row.expenditure_item_id,
                         tp_adj_reason,
                         adj_module,
                         x_last_updated_by,
                         x_last_update_login,
                         status,
                           x_request_id,
                           x_program_id,
                           x_program_application_id,
                         SYSDATE);

       IF (status <> 0) THEN
          raise INSERT_ADJ_ACTIVITY_ERROR;
       END IF;

       ei_count := ei_count + 1;

       IF (ei_count >= 500) THEN
           COMMIT;
           ei_count := 0;
       END IF;

       END LOOP;

       COMMIT;

      /* Changes for bug 8282545 start here */

        /* When fixed date is NULL */
       UPDATE pa_expenditure_items_all ITEM
           SET ITEM.adjustment_type = decode(ITEM.cost_ind_compiled_set_id, compiled_set_id, 'BURDEN_RESUMMARIZE' ,ITEM.adjustment_type)
         WHERE ITEM.cost_distributed_flag ='Y'
         AND   ITEM.adjustment_type IS NULL
         AND   exists ( select 1 from pa_cost_distribution_lines_all cdl
                      where cdl.burden_sum_source_run_id >0
                 AND  cdl.expenditure_item_id =ITEM.expenditure_item_id
                 AND  cdl.line_type ='R'
                 AND  nvl(cdl.reversed_flag,'N') ='N'
                 AND  cdl.line_num_reversed is NULL)
        AND  ITEM.cost_ind_compiled_set_id = compiled_set_id
        /*S.N. Bug4560630*/
        AND  (ITEM.expenditure_item_date BETWEEN   --Bug 5861858 Removed TRUNC
		    l_start_date AND
	         NVL(l_end_date, ITEM.expenditure_item_date))
	     AND    EXISTS
           (SELECT task_id
              FROM   pa_tasks task
              WHERE  task.task_id = ITEM.task_id
              AND      task.cost_ind_sch_fixed_date IS NULL)
          /*E.N. Bug4560630*/
        AND  l_burden_profile ='Y'
        AND  pa_utils2.Proj_Type_Burden_Disp_Method(ITEM.project_id) IN ('D','d');

        COMMIT;

        /*  When fixed date is NOT NULL */

        UPDATE pa_expenditure_items_all ITEM
           SET ITEM.adjustment_type = decode(ITEM.cost_ind_compiled_set_id, compiled_set_id, 'BURDEN_RESUMMARIZE' ,ITEM.adjustment_type)
         WHERE ITEM.cost_distributed_flag ='Y'
         AND   ITEM.adjustment_type IS NULL
         AND   exists ( select 1 from pa_cost_distribution_lines_all cdl
                      where cdl.burden_sum_source_run_id >0
                 AND  cdl.expenditure_item_id =ITEM.expenditure_item_id
                 AND  cdl.line_type ='R'
                 AND  nvl(cdl.reversed_flag,'N') ='N'
                 AND  cdl.line_num_reversed is NULL)
        AND  ITEM.cost_ind_compiled_set_id = compiled_set_id
        /*S.N. Bug4560630*/
	    AND    EXISTS
           (SELECT task_id
              FROM   pa_tasks task
              WHERE  task.task_id = ITEM.task_id
                   AND      task.cost_ind_sch_fixed_date BETWEEN
                    l_start_date    AND
                          NVL(l_end_date, cost_ind_sch_fixed_date))
        /*E.N. Bug4560630*/
        AND  l_burden_profile ='Y'
        AND  pa_utils2.Proj_Type_Burden_Disp_Method(ITEM.project_id) IN ('D','d');

        COMMIT;

     /* Changes for bug 8282545 end here */

    else

       --
       -- Provisional types
       --

      /*
         Burdening related changes
         Reset burdened_costs to null so that costing program recalculates them.
       */
      -- Modifying the statement to exclude closed project items as well as
      -- net zero items (Bug # 730849)
      -- (09/17/98)
      --
      --  Added Nvl for net_zero_adjustment_flag (896190)
      -- ---------------------------------------------------------------------
     /* Updating Project_Burdened_Cost also for Bug 2736773 */

     if l_end_date is NOT NULL THEN

       UPDATE pa_expenditure_items_all ei
       SET    cost_distributed_flag =  'N' ,
              adjustment_type ='BURDEN_RECOMPILE',
           cost_burden_distributed_flag = 'N',
              last_update_date = SYSDATE,
              last_updated_by = x_last_updated_by,
              last_update_login = x_last_update_login,
              request_id = x_request_id,
              program_application_id = x_program_application_id,
              program_id = x_program_id,
              program_update_date = SYSDATE,
              denom_burdened_cost = NULL,
              project_burdened_cost = NULL,
              acct_burdened_cost = NULL,
              burden_cost = NULL
       WHERE  ei.cost_ind_compiled_set_id = compiled_set_id
        AND    ei.expenditure_item_date BETWEEN  --Bug 5917245 Removed TRUNC
           l_start_date AND l_end_date
           -- bug 8668217 NVL(l_end_date, ei.expenditure_item_date)
               AND nvl(ei.net_zero_adjustment_flag, 'N') <>'Y'
      /*       AND ei.task_id NOT IN
                    (select t.task_id
                     FROM pa_projects_all p, pa_tasks t
                     WHERE t.project_id=p.project_id     AND
                          ei.task_id = t.task_id        AND
                          pa_project_stus_utils.Is_Project_Status_Closed(p.project_status_code)='Y')  Commented for 2933915*/
       AND   pa_project_stus_utils.Is_Project_Closed(ei.project_id)<>'Y'                              /*2933915*/
       AND ((pa_utils2.Proj_Type_Burden_Disp_Method(ei.project_id) IN ('S','s','D','d') AND l_burden_profile ='N') /*Added for 2933915*/
            OR (pa_utils2.Proj_Type_Burden_Disp_Method(ei.project_id) IN ('S','s') AND l_burden_profile ='Y'))
      AND  ( l_gms_enabled = 'N'  OR gms_pa_api2.is_award_closed(ei.expenditure_item_id,ei.task_id) = 'N' ) ;

      else
                UPDATE pa_expenditure_items_all ei
       SET    cost_distributed_flag =  'N' ,
              adjustment_type ='BURDEN_RECOMPILE',
           cost_burden_distributed_flag = 'N',
              last_update_date = SYSDATE,
              last_updated_by = x_last_updated_by,
              last_update_login = x_last_update_login,
              request_id = x_request_id,
              program_application_id = x_program_application_id,
              program_id = x_program_id,
              program_update_date = SYSDATE,
              denom_burdened_cost = NULL,
              project_burdened_cost = NULL,
              acct_burdened_cost = NULL,
              burden_cost = NULL
       WHERE  ei.cost_ind_compiled_set_id = compiled_set_id
        AND    ei.expenditure_item_date >= l_start_date --BETWEEN  --Bug 5917245 Removed TRUNC
           -- bug 8668217 AND NVL(l_end_date, ei.expenditure_item_date)
               AND nvl(ei.net_zero_adjustment_flag, 'N') <>'Y'
      /*       AND ei.task_id NOT IN
                    (select t.task_id
                     FROM pa_projects_all p, pa_tasks t
                     WHERE t.project_id=p.project_id     AND
                          ei.task_id = t.task_id        AND
                          pa_project_stus_utils.Is_Project_Status_Closed(p.project_status_code)='Y')  Commented for 2933915*/
       AND   pa_project_stus_utils.Is_Project_Closed(ei.project_id)<>'Y'                              /*2933915*/
       AND ((pa_utils2.Proj_Type_Burden_Disp_Method(ei.project_id) IN ('S','s','D','d') AND l_burden_profile ='N') /*Added for 2933915*/
            OR (pa_utils2.Proj_Type_Burden_Disp_Method(ei.project_id) IN ('S','s') AND l_burden_profile ='Y'))
      AND  ( l_gms_enabled = 'N'  OR gms_pa_api2.is_award_closed(ei.expenditure_item_id,ei.task_id) = 'N' ) ;

      end if;


/*2933915 :Added the exists clause in above update to indicate that except profile ='Y' and display_method ='D' -for all cases we will
  be marking ei for cost reprocessing */

       -- consider volume of expenditure items having the same compiled set id
       COMMIT;

       if l_gms_enabled = 'Y' then  --Bug 5726575
         gms_pa_api3.mark_prev_rev_enc_items (errbuf => err_buf,
                                              retcode => ret_code,
                                              p_compiled_set_id => compiled_set_id,
                                              p_start_date => l_start_date,
                                              p_end_date => l_end_date,
                                              p_mode => 'O');
         if err_buf is not null then
           raise GMS_INSERT_ENC_ITEM_ERROR;
         end if;
         commit;
       end if;

       FOR ei7_row IN ei7_cursor LOOP

       PA_Adjustments.InsAuditRec(ei7_row.expenditure_item_id,
                         cost_adj_reason,
                         adj_module,
                         x_last_updated_by,
                         x_last_update_login,
                         status,
                              x_request_id,
                              x_program_id,
                              x_program_application_id,
                         SYSDATE);

       IF (status <> 0) THEN
          raise INSERT_ADJ_ACTIVITY_ERROR;
       END IF;

       ei_count := ei_count + 1;

       IF (ei_count >= 500) THEN
           COMMIT;
           ei_count := 0;
       END IF;

       END LOOP;

       COMMIT;

      -- Modifying the statement to exclude closed project items as well as
      -- net zero items (Bug # 730849)
      -- (09/17/98)
      --
      --  Added Nvl for net_zero_adjustment_flag (896190)
      --
      -- Split the update into 2 seperate statements and added l_gms_enabled check for perf issue 9266246
        /* 9266246 - Start */
       UPDATE pa_expenditure_items_all ei
       SET    revenue_distributed_flag = 'N',
              last_update_date = SYSDATE,
              last_updated_by = x_last_updated_by,
              last_update_login = x_last_update_login,
              request_id = x_request_id,
              program_application_id = x_program_application_id,
              program_id = x_program_id,
              program_update_date = SYSDATE
       WHERE  rev_ind_compiled_set_id = compiled_set_id
       AND    expenditure_item_date BETWEEN  --Bug 5917245 Removed TRUNC
            l_start_date AND
              NVL(l_end_date, expenditure_item_date)
               AND nvl(ei.net_zero_adjustment_flag, 'N') <>'Y'
    /*****           AND ei.task_id NOT IN
                    (select t.task_id
                     FROM pa_projects_all p, pa_tasks t
                     WHERE t.project_id=p.project_id     AND
                          ei.task_id = t.task_id        AND
                          pa_project_stus_utils.Is_Project_Status_Closed(p.project_status_code)='Y') Commented for 2933915*/
        AND   pa_project_stus_utils.Is_Project_Closed(ei.project_id) <> 'Y'                                     /*2933915*/
       AND  (l_gms_enabled = 'N' OR gms_pa_api2.is_award_closed(ei.expenditure_item_id,ei.task_id) = 'N' ) ;


	   UPDATE pa_expenditure_items_all ei
       SET    revenue_distributed_flag = 'N',
              last_update_date = SYSDATE,
              last_updated_by = x_last_updated_by,
              last_update_login = x_last_update_login,
              request_id = x_request_id,
              program_application_id = x_program_application_id,
              program_id = x_program_id,
              program_update_date = SYSDATE
       WHERE  inv_ind_compiled_set_id = compiled_set_id
       AND    expenditure_item_date BETWEEN  --Bug 5917245 Removed TRUNC
            l_start_date AND
              NVL(l_end_date, expenditure_item_date)
               AND nvl(ei.net_zero_adjustment_flag, 'N') <>'Y'
    /*****           AND ei.task_id NOT IN
                    (select t.task_id
                     FROM pa_projects_all p, pa_tasks t
                     WHERE t.project_id=p.project_id     AND
                          ei.task_id = t.task_id        AND
                          pa_project_stus_utils.Is_Project_Status_Closed(p.project_status_code)='Y') Commented for 2933915*/
        AND   pa_project_stus_utils.Is_Project_Closed(ei.project_id) <> 'Y'                                     /*2933915*/
       AND  (l_gms_enabled = 'N' OR gms_pa_api2.is_award_closed(ei.expenditure_item_id,ei.task_id) = 'N' ) ;

       /* 9266246 - End */

       FOR ei8_row IN ei8_cursor LOOP

       PA_Adjustments.InsAuditRec(ei8_row.expenditure_item_id,
                         rev_adj_reason,
                         adj_module,
                         x_last_updated_by,
                         x_last_update_login,
                         status,
                              x_request_id,
                              x_program_id,
                              x_program_application_id,
                         SYSDATE);

       IF (status <> 0) THEN
          raise INSERT_ADJ_ACTIVITY_ERROR;
       END IF;

       ei_count := ei_count + 1;

       IF (ei_count >= 500) THEN
           COMMIT;
           ei_count := 0;
       END IF;

       END LOOP;

       COMMIT;

       FOR ei9_row IN ei9_cursor LOOP

       PA_Adjustments.InsAuditRec(ei9_row.expenditure_item_id,
                         inv_adj_reason,
                         adj_module,
                         x_last_updated_by,
                         x_last_update_login,
                         status,
                              x_request_id,
                              x_program_id,
                              x_program_application_id,
                         SYSDATE);

       IF (status <> 0) THEN
          raise INSERT_ADJ_ACTIVITY_ERROR;
       END IF;

       ei_count := ei_count + 1;

       IF (ei_count >= 500) THEN
           COMMIT;
           ei_count := 0;
       END IF;

       END LOOP;

       COMMIT;

      --
      -- Section for Capital Projects
      --
      -- This section is created as a part of fix for bug 897479 .
      --
      --

    IF  l_end_date IS NOT NULL THEN
       UPDATE pa_expenditure_items_all ei
       SET    revenue_distributed_flag = 'N',
              last_update_date = SYSDATE,
              last_updated_by = x_last_updated_by,
              last_update_login = x_last_update_login,
              request_id = x_request_id,
              program_application_id = x_program_application_id,
              program_id = x_program_id,
              program_update_date = SYSDATE
       WHERE  cost_ind_compiled_set_id = compiled_set_id
     AND    expenditure_item_date BETWEEN --Bug 5917245 Removed TRUNC
                     l_start_date AND l_end_date
                    -- bug 8668217 NVL(l_end_date, expenditure_item_date)
       AND    EXISTS
                  (SELECT 1
                     FROM pa_project_types_all pt,
                          pa_projects_all p
                    WHERE pt.project_type = p.project_type
                      AND nvl(pt.org_id, -99) = nvl(p.org_id, -99)
                      AND p.project_id = ei.project_id
                      AND pt.project_type_class_code = 'CAPITAL'
                      AND pt.capital_cost_type_code = 'B')
       AND nvl(ei.net_zero_adjustment_flag, 'N') <>'Y'
 /****  AND ei.task_id NOT IN
               (select t.task_id
                 FROM pa_projects_all p, pa_tasks t
                 WHERE t.project_id=p.project_id     AND
                       ei.task_id = t.task_id        AND
                       pa_project_stus_utils.Is_Project_Status_Closed(p.project_status_code)='Y')    Commented for 2933915*/
        AND   pa_project_stus_utils.Is_Project_Closed(ei.project_id) <> 'Y'                             /*2933915*/
       AND  ( gms_pa_api2.is_award_closed(ei.expenditure_item_id,ei.task_id) = 'N' ) ;

       -- consider volume of expenditure items having the same compiled set id
       COMMIT;

     ELSE
               UPDATE pa_expenditure_items_all ei
       SET    revenue_distributed_flag = 'N',
              last_update_date = SYSDATE,
              last_updated_by = x_last_updated_by,
              last_update_login = x_last_update_login,
              request_id = x_request_id,
              program_application_id = x_program_application_id,
              program_id = x_program_id,
              program_update_date = SYSDATE
       WHERE  cost_ind_compiled_set_id = compiled_set_id
     AND    expenditure_item_date >= l_start_date /* bug 8668217BETWEEN --Bug 5917245 Removed TRUNC
                     l_start_date AND
                     NVL(l_end_date, expenditure_item_date)*/
       AND    EXISTS
                  (SELECT 1
                     FROM pa_project_types_all pt,
                          pa_projects_all p
                    WHERE pt.project_type = p.project_type
                      AND nvl(pt.org_id, -99) = nvl(p.org_id, -99)
                      AND p.project_id = ei.project_id
                      AND pt.project_type_class_code = 'CAPITAL'
                      AND pt.capital_cost_type_code = 'B')
       AND nvl(ei.net_zero_adjustment_flag, 'N') <>'Y'
 /****  AND ei.task_id NOT IN
               (select t.task_id
                 FROM pa_projects_all p, pa_tasks t
                 WHERE t.project_id=p.project_id     AND
                       ei.task_id = t.task_id        AND
                       pa_project_stus_utils.Is_Project_Status_Closed(p.project_status_code)='Y')    Commented for 2933915*/
        AND   pa_project_stus_utils.Is_Project_Closed(ei.project_id) <> 'Y'                             /*2933915*/
       AND  ( gms_pa_api2.is_award_closed(ei.expenditure_item_id,ei.task_id) = 'N' ) ;

     END IF;

       FOR ei12_row IN ei12_cursor LOOP

       PA_Adjustments.InsAuditRec(ei12_row.expenditure_item_id,
                         cost_adj_reason,
                         adj_module,
                         x_last_updated_by,
                         x_last_update_login,
                         status,
                              x_request_id,
                              x_program_id,
                              x_program_application_id,
                         SYSDATE);

       IF (status <> 0) THEN
          raise INSERT_ADJ_ACTIVITY_ERROR;
       END IF;

       ei_count := ei_count + 1;

       IF (ei_count >= 500) THEN
           COMMIT;
           ei_count := 0;
       END IF;

       END LOOP;

       COMMIT;

      --
      -- End section for Capital projects
      --


       /*
        * IC related change:
        * updates and activity logging done for TP schedule change.
        * Note: explain plan is fine in RBO, cant test it in CBO because of
        *       non-availability of volume data.
        */
       UPDATE pa_expenditure_items_all ei
       SET  cc_bl_distributed_code =
                decode( cc_cross_charge_code,'B',
                  'N',
                  cc_bl_distributed_code),
             cc_ic_processed_code =
                decode( cc_cross_charge_code,'I',
                  'N',
                  cc_ic_processed_code),
             Denom_Tp_Currency_Code = NULL,
             Denom_Transfer_Price = NULL,
             Acct_Tp_Rate_Type = NULL,
             Acct_Tp_Rate_Date = NULL,
             Acct_Tp_Exchange_Rate = NULL,
             Acct_Transfer_Price = NULL,
             Projacct_Transfer_Price = NULL,
             Cc_Markup_Base_Code = NULL,
             Tp_Base_Amount = NULL,
             Tp_Bill_Rate = NULL,
             Tp_Bill_Markup_Percentage = NULL,
             Tp_Schedule_line_Percentage = NULL,
             Tp_Rule_percentage = NULL,
             last_update_date = SYSDATE,
             last_updated_by = x_last_updated_by,
             last_update_login = x_last_update_login,
             request_id = x_request_id,
             program_application_id = x_program_application_id,
             program_id = x_program_id,
             program_update_date = SYSDATE
       WHERE  ei.tp_ind_compiled_set_id = compiled_set_id
       AND    ei.expenditure_item_date BETWEEN --Bug 5917245 Removed TRUNC
              l_start_date AND
              NVL(l_end_date, ei.expenditure_item_date)
               AND nvl(ei.net_zero_adjustment_flag, 'N') <>'Y'
/***               AND ei.task_id NOT IN
                    (select t.task_id
                     FROM pa_projects_all p, pa_tasks t
                     WHERE t.project_id=p.project_id     AND
                          ei.task_id = t.task_id        AND
                          pa_project_stus_utils.Is_Project_Status_Closed(p.project_status_code)='Y') Commented for 2933915*/
        AND   pa_project_stus_utils.Is_Project_Closed(ei.project_id) <> 'Y'                             /*2933915*/
       AND  ( gms_pa_api2.is_award_closed(ei.expenditure_item_id,ei.task_id) = 'N' ) ;


       /***2933915:UPDATE eis for 'BURDEN_RESUMMARIZE' ONLY if cost_distributed_flag ='Y' and profile option is enabled and burdening is
        on separate ei  */

        /*====================================================================+
         | M - If Enhanced Burdening is SET, for Separate line burdening      |
         |     transactions the adjustment_type is set to BURDEN_RESUMMARIZE  |
         |     - if cost_distributed_flag is Y.                               |
         +====================================================================*/
     UPDATE pa_expenditure_items_all ITEM
           SET ITEM.adjustment_type = decode(ITEM.cost_ind_compiled_set_id, compiled_set_id, 'BURDEN_RESUMMARIZE' ,ITEM.adjustment_type)
         WHERE ITEM.cost_distributed_flag ='Y'
         AND   ITEM.adjustment_type IS NULL
         AND   exists ( select 1 from pa_cost_distribution_lines_all cdl
                      where cdl.burden_sum_source_run_id >0
                 AND  cdl.expenditure_item_id =ITEM.expenditure_item_id
                 AND  cdl.line_type ='R'
                 AND  nvl(cdl.reversed_flag,'N') ='N'
                 AND  cdl.line_num_reversed is NULL)
        AND  ITEM.cost_ind_compiled_set_id = compiled_set_id
        /*S.N. Bug4560630*/
       AND  (ITEM.expenditure_item_date BETWEEN --Bug 5917245 Removed TRUNC
		    l_start_date AND
	         NVL(l_end_date, ITEM.expenditure_item_date))
        /*E.N. Bug4560630*/
        AND  l_burden_profile ='Y'
        AND  pa_utils2.Proj_Type_Burden_Disp_Method(ITEM.project_id) IN ('D','d');

       COMMIT;

       FOR ei14_row IN ei14_cursor LOOP

       PA_Adjustments.InsAuditRec(ei14_row.expenditure_item_id,
                         tp_adj_reason,
                         adj_module,
                         x_last_updated_by,
                         x_last_update_login,
                         status,
                           x_request_id,
                           x_program_id,
                           x_program_application_id,
                         SYSDATE);

       IF (status <> 0) THEN
          raise INSERT_ADJ_ACTIVITY_ERROR;
       END IF;

       ei_count := ei_count + 1;

       IF (ei_count >= 500) THEN
           COMMIT;
           ei_count := 0;
       END IF;

       END LOOP;

       COMMIT;

    end if;

EXCEPTION
    when INSERT_ADJ_ACTIVITY_ERROR then
      return;

    when GMS_INSERT_ENC_ITEM_ERROR then --Bug 5726575
      stage := 120;
      status := ret_code;

    when OTHERS then
      stage := 100;
      status := sqlcode;

END mark_prev_rev_exp_items;


--
--  PROCEDURE
--             add_adjustment_activity
--
--  PURPOSE
--           The objective of this procedure is to add adjustment
--        activity of affected expenditure items for auditing purpose
--
--  HISTORY
--
--   30-JAN-95      S Lee     Created
--

/*
procedure add_adjustment_activity(compiled_set_id IN number,
                                  p_cost_base           IN pa_cost_bases.cost_base%TYPE
                                 ,p_cost_plus_structure IN pa_cost_plus_structures.cost_plus_structure%TYPE,
                      cost_adj_reason IN varchar2,
                      rev_adj_reason  IN varchar2,
                      inv_adj_reason  IN varchar2,
                      tp_adj_reason  IN varchar2,
                      status          IN OUT NOCOPY number,
                      stage          IN OUT NOCOPY number,
                      l_expenditure_item_id_tab IN PA_PLSQL_DATATYPES.IDTABTYP,
                      l_adj_tyep_tab IN PA_PLSQL_DATATYPES.Char30TabTyp)
*/
procedure add_adjustment_activity( l_expenditure_item_id_tab IN PA_PLSQL_DATATYPES.IDTABTYP
                                  ,l_adj_type_tab            IN PA_PLSQL_DATATYPES.Char30TabTyp
                                  ,status                    IN OUT NOCOPY number
                                  ,stage                     IN OUT NOCOPY number
                     )
IS

   -- Local variable
   ei_count  number;
   adj_module       constant  varchar2(10) := 'PACOCRSR';

   -- Standard who
   x_request_id                 NUMBER(15);

   -- Exception
   INSERT_ADJ_ACTIVITY_ERROR exception;

  /* -- Commented for bug4527736
   -- Cursor definition

   CURSOR ei_cost_cursor
   IS
      SELECT expenditure_item_id
      FROM   pa_expenditure_items_all ITEM
      WHERE  cost_ind_compiled_set_id = compiled_set_id
      AND    adjustment_type in ('BURDEN_RECOMPILE','BURDEN_RESUMMARIZE','RECALC_BURDEN')
      AND    request_id = x_request_id
      AND EXISTS (SELECT NULL
                    FROM pa_cost_base_exp_types cbet
                WHERE cbet.cost_base = p_cost_base
                     AND cbet.cost_plus_structure = p_cost_plus_structure
                     AND cbet.cost_base_type   = INDIRECT_COST_CODE
                     AND cbet.expenditure_type = ITEM.expenditure_type
              )
      ;

   CURSOR ei_rev_cursor
   IS
      SELECT expenditure_item_id
      FROM   pa_expenditure_items_all ITEM
      WHERE  rev_ind_compiled_set_id = compiled_set_id
      AND    request_id = x_request_id
      AND EXISTS (SELECT NULL
                    FROM pa_cost_base_exp_types cbet
                WHERE cbet.cost_base = p_cost_base
                     AND cbet.cost_plus_structure = p_cost_plus_structure
                     AND cbet.cost_base_type   = INDIRECT_COST_CODE
                     AND cbet.expenditure_type = ITEM.expenditure_type
              )
      ;

   CURSOR ei_inv_cursor
   IS
      SELECT expenditure_item_id
      FROM   pa_expenditure_items_all ITEM
      WHERE  inv_ind_compiled_set_id = compiled_set_id
      AND    request_id = x_request_id
      AND EXISTS (SELECT NULL
                    FROM pa_cost_base_exp_types cbet
                WHERE cbet.cost_base = p_cost_base
                     AND cbet.cost_plus_structure = p_cost_plus_structure
                     AND cbet.cost_base_type   = INDIRECT_COST_CODE
                     AND cbet.expenditure_type = ITEM.expenditure_type
              )
      ; End Comment bug4527736 */
   /*
    * IC related change:
    * New cursor added for TP schedule.
    */
/* Commented for bug 4527736
   CURSOR ei_tp_cursor
   IS
      SELECT expenditure_item_id
      FROM   pa_expenditure_items_all ITEM
      WHERE  tp_ind_compiled_set_id = compiled_set_id
      AND    request_id = x_request_id
      AND EXISTS (SELECT NULL
                    FROM pa_cost_base_exp_types cbet
                WHERE cbet.cost_base = p_cost_base
                     AND cbet.cost_plus_structure = p_cost_plus_structure
                     AND cbet.cost_base_type   = INDIRECT_COST_CODE
                     AND cbet.expenditure_type = ITEM.expenditure_type
              )
      ;*/

   -- Standard who
   x_last_updated_by            NUMBER(15);
   x_last_update_login          NUMBER(15);
   x_program_application_id     NUMBER(15);
   x_program_id                 NUMBER(15);
   -- l_eid_tbl                    PA_PLSQL_DATATYPES.IdTabTyp;                  /*3040724*/
   l_limit_size                 NUMBER :=500 ;                                /*3040724*/

BEGIN

      -- Initialize output parameters
      status := 0;
      stage := 100;

      --
      -- Get the standard who information
      --
      x_last_updated_by            := FND_GLOBAL.USER_ID;
      x_last_update_login          := FND_GLOBAL.LOGIN_ID;
      x_request_id                 := FND_GLOBAL.CONC_REQUEST_ID;
      x_program_id                 := FND_GLOBAL.CONC_PROGRAM_ID;
      x_program_application_id     := FND_GLOBAL.PROG_APPL_ID;

      ei_count := 0;
/*
IF (cost_adj_reason IS NOT NULL)
THEN
   begin

   OPEN ei_cost_cursor;
    LOOP

      l_eid_tbl.DELETE;
      FETCH ei_cost_cursor BULK COLLECT INTO l_eid_tbl
       LIMIT l_limit_size ;

      IF l_eid_tbl.count = 0
      THEN
         EXIT;
      END IF;

     FORALL i in 1..l_eid_tbl.count
      INSERT INTO pa_expend_item_adj_activities (
          expenditure_item_id
       ,  last_update_date
       ,  last_updated_by
       ,  creation_date
       ,  created_by
       ,  last_update_login
       ,  activity_date
       ,  exception_activity_code
       ,  module_code
       ,  request_id
       ,  program_application_id
       ,  program_id
       ,  program_update_date )
    VALUES (
          l_eid_tbl(i)                                 -- expenditure_item_id
       ,  sysdate                                      -- last_update_date
       ,  x_last_updated_by                    -- last_updated_by
       ,  sysdate                         -- creation_date
       ,  x_last_updated_by                            -- created_by
       ,  x_last_update_login                          -- last_update_login
       ,  sysdate                                      -- activity_date
       ,  cost_adj_reason                              -- exception_activity_code
       ,  adj_module                                   -- module_code
       ,  x_request_id                                 -- request_id
       ,  x_program_application_id                     -- program_application_id
       ,  x_program_id                                 -- program_id
       ,  sysdate     );                               -- program_update_date

      EXIT WHEN ei_cost_cursor%NOTFOUND;

  END LOOP;
  CLOSE ei_cost_cursor;
  EXCEPTION
  WHEN OTHERS THEN
    raise INSERT_ADJ_ACTIVITY_ERROR;
  end ;
END IF ; ------ cost_adj_reason

IF (rev_adj_reason IS NOT NULL)
THEN
   begin

   OPEN ei_rev_cursor;
    LOOP

      l_eid_tbl.DELETE;
      FETCH ei_rev_cursor BULK COLLECT INTO l_eid_tbl
       LIMIT l_limit_size ;

      IF l_eid_tbl.count = 0
      THEN
         EXIT;
      END IF;

     FORALL i in 1..l_eid_tbl.count
      INSERT INTO pa_expend_item_adj_activities (
          expenditure_item_id
       ,  last_update_date
       ,  last_updated_by
       ,  creation_date
       ,  created_by
       ,  last_update_login
       ,  activity_date
       ,  exception_activity_code
       ,  module_code
       ,  request_id
       ,  program_application_id
       ,  program_id
       ,  program_update_date )
    VALUES (
          l_eid_tbl(i)                                 -- expenditure_item_id
       ,  sysdate                                      -- last_update_date
       ,  x_last_updated_by                    -- last_updated_by
       ,  sysdate                         -- creation_date
       ,  x_last_updated_by                            -- created_by
       ,  x_last_update_login                          -- last_update_login
       ,  sysdate                                      -- activity_date
       ,  rev_adj_reason                              -- exception_activity_code
       ,  adj_module                                   -- module_code
       ,  x_request_id                                 -- request_id
       ,  x_program_application_id                     -- program_application_id
       ,  x_program_id                                 -- program_id
       ,  sysdate     );                               -- program_update_date

      EXIT WHEN ei_rev_cursor%NOTFOUND;
  END LOOP;
 Close ei_rev_cursor;
  EXCEPTION
  WHEN OTHERS THEN
    raise INSERT_ADJ_ACTIVITY_ERROR;
  end ;
END IF ; ------ rev_adj_reason

IF (inv_adj_reason IS NOT NULL)
THEN
   begin

   OPEN ei_inv_cursor;
    LOOP

      l_eid_tbl.DELETE;
      FETCH ei_inv_cursor BULK COLLECT INTO l_eid_tbl
       LIMIT l_limit_size ;

      IF l_eid_tbl.count = 0
      THEN
         EXIT;
      END IF;

     FORALL i in 1..l_eid_tbl.count
      INSERT INTO pa_expend_item_adj_activities (
          expenditure_item_id
       ,  last_update_date
       ,  last_updated_by
       ,  creation_date
       ,  created_by
       ,  last_update_login
       ,  activity_date
       ,  exception_activity_code
       ,  module_code
       ,  request_id
       ,  program_application_id
       ,  program_id
       ,  program_update_date )
    VALUES (
          l_eid_tbl(i)                                 -- expenditure_item_id
       ,  sysdate                                      -- last_update_date
       ,  x_last_updated_by                    -- last_updated_by
       ,  sysdate                         -- creation_date
       ,  x_last_updated_by                            -- created_by
       ,  x_last_update_login                          -- last_update_login
       ,  sysdate                                      -- activity_date
       ,  inv_adj_reason                              -- exception_activity_code
       ,  adj_module                                   -- module_code
       ,  x_request_id                                 -- request_id
       ,  x_program_application_id                     -- program_application_id
       ,  x_program_id                                 -- program_id
       ,  sysdate     );                               -- program_update_date

      EXIT WHEN ei_inv_cursor%NOTFOUND;
  END LOOP;
 Close ei_inv_cursor;
  EXCEPTION
  WHEN OTHERS THEN
    raise INSERT_ADJ_ACTIVITY_ERROR;
  end ;
END IF ; ------ inv_adj_reason

IF (tp_adj_reason IS NOT NULL)
THEN
   begin

   OPEN ei_tp_cursor;
    LOOP

      l_eid_tbl.DELETE;
      FETCH ei_tp_cursor BULK COLLECT INTO l_eid_tbl
       LIMIT l_limit_size ;

      IF l_eid_tbl.count = 0
      THEN
         EXIT;
      END IF;

     FORALL i in 1..l_eid_tbl.count
      INSERT INTO pa_expend_item_adj_activities (
          expenditure_item_id
       ,  last_update_date
       ,  last_updated_by
       ,  creation_date
       ,  created_by
       ,  last_update_login
       ,  activity_date
       ,  exception_activity_code
       ,  module_code
       ,  request_id
       ,  program_application_id
       ,  program_id
       ,  program_update_date )
    VALUES (
          l_eid_tbl(i)                                 -- expenditure_item_id
       ,  sysdate                                      -- last_update_date
       ,  x_last_updated_by                    -- last_updated_by
       ,  sysdate                         -- creation_date
       ,  x_last_updated_by                            -- created_by
       ,  x_last_update_login                          -- last_update_login
       ,  sysdate                                      -- activity_date
       ,  tp_adj_reason                              -- exception_activity_code
       ,  adj_module                                   -- module_code
       ,  x_request_id                                 -- request_id
       ,  x_program_application_id                     -- program_application_id
       ,  x_program_id                                 -- program_id
       ,  sysdate     );                               -- program_update_date

      EXIT WHEN ei_tp_cursor%NOTFOUND;
  END LOOP;
 Close ei_tp_cursor;
  EXCEPTION
  WHEN OTHERS THEN
    raise INSERT_ADJ_ACTIVITY_ERROR;
  end ;
END IF ; ------ tp_adj_reason
*/
if l_expenditure_item_id_tab.count > 0 then
     FORALL i in 1..l_expenditure_item_id_tab.count
      INSERT INTO pa_expend_item_adj_activities (
          expenditure_item_id
       ,  last_update_date
       ,  last_updated_by
       ,  creation_date
       ,  created_by
       ,  last_update_login
       ,  activity_date
       ,  exception_activity_code
       ,  module_code
       ,  request_id
       ,  program_application_id
       ,  program_id
       ,  program_update_date )
    VALUES (
          l_expenditure_item_id_tab(i)                 -- expenditure_item_id
       ,  sysdate                                      -- last_update_date
       ,  x_last_updated_by                    -- last_updated_by
       ,  sysdate                         -- creation_date
       ,  x_last_updated_by                            -- created_by
       ,  x_last_update_login                          -- last_update_login
       ,  sysdate                                      -- activity_date
       ,  l_adj_type_tab(i)                            -- exception_activity_code
       ,  adj_module                                   -- module_code
       ,  x_request_id                                 -- request_id
       ,  x_program_application_id                     -- program_application_id
       ,  x_program_id                                 -- program_id
       ,  sysdate     );                               -- program_update_date
end if;

EXCEPTION
      when OTHERS then
        status := SQLCODE;

END add_adjustment_activity;


--
--  PROCEDURE
--             disable_rate_sch_revision
--
--  PURPOSE
--           The objective of this procedure is to mark the compiled sets
--        as history for an out-of-date rate schedule revision.
--        When the indirect cost multipliers are updated, the original
--        compiled sets are out of date, and should be marked as history.
--
--  HISTORY
--
--   10-JUN-94      S Lee     Created
--
/****2933915    : Restructured this procedure to do Selective Obsoletion .
 Selective obsoletion implies that only those compiled set ids will be obsoleted
 for which the cost base is impacted i.e if any of the cost code is modified/deleted
 for any org . in a particular revision .
 If multipliers are present explicitly for any org for ALL the cost codes -that have
 not changed then we should not be obsoleting the compiled set id for this org/cost base .
 ************************************************************************************/
procedure disable_rate_sch_revision(rate_sch_rev_id  IN    number,
                        ver_id           IN    number,            /*2933915**/
                                    org_id           IN    number,           /**2933915**/
                                    status      IN OUT NOCOPY number,
                                    stage       IN OUT NOCOPY number)

is

CURSOR org_cursor
   IS
      SELECT organization_id_child org_id_child
      FROM   per_org_structure_elements
      CONNECT BY PRIOR organization_id_child = organization_id_parent
              AND  org_structure_version_id = ver_id
      START WITH organization_id_parent = org_id
              AND  org_structure_version_id = ver_id
           UNION
      select org_id from dual ;

  -- Standard who
   x_last_updated_by            NUMBER(15);
   x_last_update_login          NUMBER(15);
   x_request_id                 NUMBER(15);
   x_program_application_id     NUMBER(15);
   x_program_id                 NUMBER(15);
   org_override                 NUMBER :=0;
BEGIN

   --
   -- Get the standard who information
   --
   x_last_updated_by            := FND_GLOBAL.USER_ID;
   x_last_update_login          := FND_GLOBAL.LOGIN_ID;
   x_request_id                 := FND_GLOBAL.CONC_REQUEST_ID;
   x_program_application_id     := FND_GLOBAL.PROG_APPL_ID;
   x_program_id                 := FND_GLOBAL.CONC_PROGRAM_ID;

FOR org_id_rec in org_cursor                    /*Loop for all the children (including impacted org) of the impacted org*/
 LOOP

  /*3016281 :If explicit multipliers are defined for all the cost codes in impacted cost bases for an org then we should not obsolete
    compiled set ids for that.
    This is in view of the enhancement that new compiled set ids will not be generated for an org if explicit multipliers are defined
    for all the cost codes in impacted cost bases for that org*/

   IF pa_cost_plus.check_for_explicit_multiplier(rate_sch_rev_id ,org_id_rec.org_id_child) =0 THEN                /*3016281*/
     --FOR cost_base_rec in impacted_cost_bases(rate_sch_rev_id)
     IF G_IMPACTED_COST_BASES_TAB.COUNT <> 0 THEN /*4590268*/

       FOR i IN G_IMPACTED_COST_BASES_TAB.FIRST .. G_IMPACTED_COST_BASES_TAB.LAST
       LOOP
            UPDATE pa_ind_compiled_sets
             SET status = 'H',
                 last_update_date = SYSDATE,
                 last_updated_by = x_last_updated_by,
                 last_update_login = x_last_update_login,
                 request_id = x_request_id,
                 program_application_id = x_program_application_id,
                 program_id = x_program_id,
                 program_update_date = SYSDATE
             WHERE  ind_rate_sch_revision_id = rate_sch_rev_id
             AND   organization_id = org_id_rec.org_id_child
             --AND   cost_base =  cost_base_rec.cost_base
             AND   cost_base =  G_IMPACTED_COST_BASES_TAB(i)
             AND status = 'A' ;
       END LOOP ; /*End of LOOP for impacted_cost_bases*/
    END IF; /*4590268*/
   END IF;                                                                                       /*3016281*/
 END LOOP;    /*End of LOOP for Org_cursor*/
EXCEPTION
  WHEN OTHERS THEN
  stage := 100;
  status := SQLCODE;
END disable_rate_sch_revision;

--
--  PROCEDURE
--             disable_sch_rev_org
--
--  PURPOSE
--           The objective of this procedure is to mark the compiled sets
--        as history for the specified rate schedule revision and
--        organization .
--
--  HISTORY
--
--   25-AUG-94      S Lee     Created
--

procedure disable_sch_rev_org(rate_sch_rev_id  IN    number,
                     org_id     IN number,
                              status      IN OUT NOCOPY number,
                              stage       IN OUT NOCOPY number)

is

   -- Standard who
   x_last_updated_by            NUMBER(15);
   x_last_update_login          NUMBER(15);
   x_request_id                 NUMBER(15);
   x_program_application_id     NUMBER(15);
   x_program_id                 NUMBER(15);

BEGIN

   --
   -- Get the standard who information
   --
   x_last_updated_by            := FND_GLOBAL.USER_ID;
   x_last_update_login          := FND_GLOBAL.LOGIN_ID;
   x_request_id                 := FND_GLOBAL.CONC_REQUEST_ID;
   x_program_application_id     := FND_GLOBAL.PROG_APPL_ID;
   x_program_id                 := FND_GLOBAL.CONC_PROGRAM_ID;

   --
   --  Set the compiled set to history
   --
/*FOR cost_base_rec in impacted_cost_bases(rate_sch_rev_id)        **2933915*/
IF G_IMPACTED_COST_BASES_TAB.COUNT <> 0 THEN /*4590268*/

   FOR i IN G_IMPACTED_COST_BASES_TAB.FIRST .. G_IMPACTED_COST_BASES_TAB.LAST
   LOOP

   --
   --  Set the compiled set to history
   --

   UPDATE pa_ind_compiled_sets
   SET      status = 'H',
          last_update_date = SYSDATE,
          last_updated_by = x_last_updated_by,
          last_update_login = x_last_update_login,
          request_id = x_request_id,
          program_application_id = x_program_application_id,
          program_id = x_program_id,
          program_update_date = SYSDATE
   WHERE  ind_rate_sch_revision_id = rate_sch_rev_id
   AND    organization_id = org_id
   --AND    cost_base = cost_base_rec.cost_base
   AND    cost_base = G_IMPACTED_COST_BASES_TAB(i)
   AND    status = 'A' ;                 /*2933915*/

END LOOP;

END IF; /*4590268*/

EXCEPTION
  WHEN OTHERS THEN
  stage := 100;
  status := SQLCODE;

END disable_sch_rev_org;


procedure get_indirect_cost_amounts (x_indirect_cost_costing IN OUT NOCOPY number,
                                     x_indirect_cost_revenue IN OUT NOCOPY number,
                                     x_indirect_cost_invoice IN OUT NOCOPY number,
                                     x_task_id               IN     number,
                                     x_gl_date               IN     date,
                                     x_expenditure_type      IN     varchar2,
                                     x_organization_id       IN     number,
                                     x_direct_cost           IN     number,
                         x_return_status          IN OUT NOCOPY number,
                         x_stage             IN OUT NOCOPY number)
is
begin

  --
  -- Get the costing indirect cost
  --
  pa_cost_plus.view_indirect_cost(
                                  NULL,
                                  'PA',
                                  x_task_id,
                                  x_gl_date,
                                  x_expenditure_type,
                                  x_organization_id,
                                  'C',
                                  x_direct_cost,
                      x_indirect_cost_costing,
                                  x_return_status,
                                  x_stage);

/*
  if (x_return_status <> 0) then
     x_stage := x_stage + 1000;
  end if;
*/

  if (x_return_status <> 0) then
     x_indirect_cost_costing := 0;
  end if;

  --
  -- Get the revenue indirect cost
  --
  pa_cost_plus.view_indirect_cost(
                                  NULL,
                                  'PA',
                                  x_task_id,
                                  x_gl_date,
                                  x_expenditure_type,
                                  x_organization_id,
                                  'R',
                                  x_direct_cost,
                      x_indirect_cost_revenue,
                                  x_return_status,
                                  x_stage);

/*
  if (x_return_status = NO_RATE_SCH_ID) then
     -- Acceptable. Reset the status
     x_indirect_cost_revenue := 0;
     x_return_status := 0;
  elsif (x_return_status <> 0) then
     x_stage := x_stage + 2000;
     return;
  end if;
*/

  if (x_return_status <> 0) then
     x_indirect_cost_revenue := 0;
  end if;

  --
  -- Get the invoice indirect cost
  --
  pa_cost_plus.view_indirect_cost(
                                  NULL,
                                  'PA',
                                  x_task_id,
                                  x_gl_date,
                                  x_expenditure_type,
                                  x_organization_id,
                                  'I',
                                  x_direct_cost,
                      x_indirect_cost_invoice,
                                  x_return_status,
                                  x_stage);

/*
  if (x_return_status = NO_RATE_SCH_ID) then
     -- Acceptable. Reset the status
     x_indirect_cost_invoice := 0;
     x_return_status := 0;
  elsif (x_return_status <> 0) then
     x_stage := x_stage + 3000;
     return;
  end if;
*/

  if (x_return_status <> 0) then
     x_indirect_cost_invoice := 0;
  end if;


end get_indirect_cost_amounts;



procedure get_ind_rate_sch_rev(x_ind_rate_sch_name          IN OUT NOCOPY varchar2,
                               x_ind_rate_sch_revision      IN OUT NOCOPY varchar2,
                               x_ind_rate_sch_revision_type IN OUT NOCOPY varchar2,
                               x_start_date_active          IN OUT NOCOPY date,
                               x_end_date_active            IN OUT NOCOPY date,
                               x_task_id                    IN     number,
                               x_gl_date                    IN     date,
                               x_detail_type_flag           IN     varchar2,
                               x_expenditure_type           IN     varchar2,
                               x_cost_base                  IN OUT NOCOPY varchar2,
                               x_ind_compiled_set_id        IN OUT NOCOPY number,
                               x_organization_id            IN     number,
                      x_return_status                 IN OUT NOCOPY number,
                      x_stage                    IN OUT NOCOPY number)
is
  x_rate_sch_rev_id number;
  x_sch_id number;
  x_sch_fixed_date date;
  x_cp_structure varchar2(30);

begin

  x_return_status := 0;
  x_stage := 0;

  pa_cost_plus.find_rate_sch_rev_id (NULL,
                                     'PA',
                                     x_task_id,
                         x_detail_type_flag,
                                     x_gl_date,
                                     x_sch_id,
                                     x_rate_sch_rev_id,
                                     x_sch_fixed_date,
                                     x_return_status,
                                     x_stage);
  if (x_return_status > 0) then
    begin
      x_stage := 1;
      return;
    end;
  elsif (x_return_status < 0) then
    begin
      return;
    end;
  end if;


  begin

    pa_cost_plus.get_cost_plus_structure(x_rate_sch_rev_id,
                       x_cp_structure,
                       x_return_status,
                       x_stage);

    pa_cost_plus.get_cost_base (x_expenditure_type,
                                x_cp_structure,
                                x_cost_base,
                                x_return_status,
                                x_stage);
    if (x_return_status > 0) then
      begin
        x_stage := 2;
        return;
      end;
    elsif (x_return_status < 0) then
      begin
        return;
      end;
    end if;

    begin
      select ind_compiled_set_id
      into   x_ind_compiled_set_id
      from   pa_ind_compiled_sets
      where  ind_rate_sch_revision_id = x_rate_sch_rev_id
      and    organization_id = x_organization_id
      and    status = 'A';

      EXCEPTION
     WHEN NO_DATA_FOUND then
     x_stage := 3;
     x_return_status := 1;
    end;

    begin
      select s.ind_rate_sch_name,
             sr.ind_rate_sch_revision,
          pl.meaning,
             sr.start_date_active,
             sr.end_date_active
      into   x_ind_rate_sch_name,
             x_ind_rate_sch_revision,
             x_ind_rate_sch_revision_type,
             x_start_date_active,
             x_end_date_active
      from   pa_ind_rate_schedules s,
             pa_ind_rate_sch_revisions sr,
          pa_lookups pl
      where  s.ind_rate_sch_id = sr.ind_rate_sch_id
      and    sr.ind_rate_sch_revision_type = pl.lookup_code
      and    pl.lookup_type = 'IND RATE SCHEDULE REV TYPE'
      and    sr.ind_rate_sch_revision_id = x_rate_sch_rev_id;

      EXCEPTION
     WHEN NO_DATA_FOUND then
     if x_stage = 3 then
       x_stage := 3;
     else
          x_stage := 4;
     end if;
     x_return_status := 1;
    end;


    EXCEPTION
      WHEN NO_DATA_FOUND then
        x_return_status := 1;

      WHEN OTHERS then
        x_return_status := SQLCODE;
  end;

end get_ind_rate_sch_rev;

/*
   Multi-Currency Related Changes:
   New procedure added to get the sum of the compiled multiplier.
   This multiplier is used to calculate the burden cost in all the currencies.
  */

  PROCEDURE get_compiled_multiplier(P_Org_id                IN     NUMBER,
                                      P_C_base              IN     VARCHAR2,
                                       P_Rate_sch_rev_id     IN     NUMBER,
                                     P_Compiled_multiplier IN OUT NOCOPY NUMBER,
                                         P_Status              IN OUT NOCOPY NUMBER,
                                         P_Stage               IN OUT NOCOPY NUMBER)

  IS

  BEGIN

     P_status := 0;
     P_stage  := 100;

     SELECT SUM(icpm.compiled_multiplier)
     INTO   P_Compiled_multiplier
     FROM   pa_ind_compiled_sets ics,
            pa_compiled_multipliers icpm
     WHERE  ics.ind_rate_sch_revision_id = P_Rate_sch_rev_id
            AND ics.organization_id      = P_Org_id
            AND ics.status               = 'A'
            AND ics.ind_compiled_set_id  = icpm.ind_compiled_set_id
         AND icpm.cost_base =ics.cost_base               /*2933915*/
            AND icpm.cost_base           = P_C_base;

     if (P_compiled_multiplier is null) then
        P_Status := NO_DATA_FOUND_ERR;
     end if;

  EXCEPTION

     WHEN OTHERS THEN
       P_Status := SQLCODE;

  END get_compiled_multiplier;

  FUNCTION Get_Mltplr_For_Compiled_Set( P_Ind_Compiled_Set_Id IN NUMBER) RETURN NUMBER
  IS
    l_Compiled_Multiplier  NUMBER;
  BEGIN
     /*
      * Here we sum up all the compiled multipliers against a compiled set, across
      * all cost-base/cost-code combinations to get the final multiplier
      * which can be applied on the raw-cost to get the burden cost.
      */
     SELECT SUM(icpm.compiled_multiplier)
     INTO   l_Compiled_multiplier
     FROM   pa_compiled_multipliers icpm
     WHERE  icpm.ind_compiled_set_id = P_Ind_Compiled_Set_Id;
     /*
      * No Compiled Multipliers available for the compiled set, passed.
      * Raise no_data_found exception explicitly.
      */
     IF (l_Compiled_Multiplier IS NULL) THEN
       RAISE NO_DATA_FOUND;
     END IF;
     /*
      * Return compiled multiplier
      */
     RETURN(l_Compiled_Multiplier);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END Get_Mltplr_For_Compiled_Set;

 /************2933915 :New procedure to do Selective Deletion now *****************************************************/
/*
  PROCEDURE
               delete_rate_sch_revision

  PURPOSE
              The objective of this procedure is to delete only the
              impacted compiled sets i.e for impacted organizations and impacted cost bases ,
              for which no ei exists .                                                                                  */
/***********************************************************************************************************************/
procedure delete_rate_sch_revision(rate_sch_rev_id   IN    number,
                                    ver_id           IN    number,
                                    org_id           IN    number,
                                    status           IN OUT NOCOPY number,
                                    stage            IN OUT NOCOPY number)

is
CURSOR org_cursor
   IS
      SELECT organization_id_child org_id_child
      FROM   per_org_structure_elements
      CONNECT BY PRIOR organization_id_child = organization_id_parent
              AND  org_structure_version_id = ver_id
      START WITH organization_id_parent = org_id
              AND  org_structure_version_id = ver_id
       UNION
      select org_id from dual ;

BEGIN
--
      --  Remove redundant compiled sets and multipiers.
      --
      FOR ORG_REC in ORG_CURSOR
      LOOP
        FOR cost_base_rec in impacted_cost_bases(rate_sch_rev_id)
     LOOP

/* S.N. Bug 3946409

        DELETE pa_compiled_multipliers
            WHERE  ind_compiled_set_id IN
          (SELECT ind_compiled_set_id
           FROM   pa_ind_compiled_sets
           WHERE  ind_rate_sch_revision_id = rate_sch_rev_id
           and    organization_id          = ORG_REC.org_id_child
           and    cost_base                = cost_base_rec.cost_base) ;

   E.N. Bug 3946409 */

/* Bug# 4527736
           DELETE pa_ind_compiled_sets
           WHERE  ind_rate_sch_revision_id = rate_sch_rev_id
           and organization_id =ORG_REC.org_id_child
           and cost_base       =G_IMPACTED_COST_BASES_TAB(i)
   Bug# 4527736 */
        NULL;

       END LOOP ;
    END LOOP ;
EXCEPTION
  WHEN OTHERS THEN
  stage := 100;
  status := SQLCODE;

END delete_rate_sch_revision;


/*****************2933915 :New procedure to find the impacted top orgs******************************************

  PROCEDURE
               find_impacted_top_org

  PURPOSE
             The objective of this procedure is to find the highest
          organizations with ready_to_compile_flag as 'Y'
                in pa_ind_cost_multipliers .
                This is to  ensure that compilation starts from highest impacted orgs rather than from Start_org
***************************************************************************************************************/

procedure find_impacted_top_org(rate_sch_rev_id  IN    number,
                                ver_id           IN    number ,
                    start_org        IN    number ,
                                org_tab          OUT   NOCOPY org_tab_type,
                    status           IN OUT NOCOPY number)

is

/*Cursor to select distinct organizations having ready_to_compile_flag as 'Y' */
Cursor ready_to_compile_orgs is
select DISTINCT organization_id
from pa_ind_cost_multipliers
where ind_rate_sch_revision_id = rate_sch_rev_id
and   nvl(ready_to_compile_flag,'N') in ('Y','X') ;

l_count NUMBER ;
l_parent NUMBER ;
i NUMBER :=1 ;

BEGIN

FOR org in ready_to_compile_orgs LOOP
BEGIN

           SELECT count(a.organization_id_parent)
      into l_count FROM
         ( SELECT organization_id_parent
               FROM per_org_structure_elements
               CONNECT BY PRIOR organization_id_parent = organization_id_child
              AND  org_structure_version_id = ver_id
              START WITH organization_id_child = org.organization_id
             AND  org_structure_version_id = ver_id) a
           WHERE a.organization_id_parent in (select DISTINCT organization_id
                                           from pa_ind_cost_multipliers
                                              where ind_rate_sch_revision_id = rate_sch_rev_id
                                              and   nvl(ready_to_compile_flag,'N') in ('Y','X') );


      if (l_count =0 ) then

        l_parent := org.organization_id ;

    /*There will not be many records in this table since we are storing only the top impacted org in this after
    full traversal of one branch(starting from start org till last child i.e leaf node) -so looping through the
    table should be OK */

               org_tab(i) := l_parent;



        /* If at any point of finding top org we come across any org that is same as start org then no need to
        process remaining orgs in cursor ready_to_compile_orgs since we have reached start org so that means
        compilation has to start from stat org itself. */

        If l_parent = start_org then
         status :=0 ;
         EXIT ;
           End if ;
      i:=i +1 ;
    elsif (l_count =1 ) then

         SELECT b.organization_id_parent
               into l_parent
          FROM (SELECT organization_id_parent
              FROM per_org_structure_elements
                    CONNECT BY PRIOR organization_id_parent = organization_id_child
                    AND  org_structure_version_id = ver_id
               START WITH organization_id_child = org.organization_id
               AND  org_structure_version_id = ver_id) b
                    WHERE  b.organization_id_parent in (select DISTINCT organization_id
                                                             from pa_ind_cost_multipliers
                                                         where ind_rate_sch_revision_id = rate_sch_rev_id
                                                         and  nvl(ready_to_compile_flag,'N') in ('Y','X'));

  /*There will not be many records in this table since we are storing only the top impacted org in this after full traversal of one
    branch (starting from start org till last child i.e leaf node) -so looping through the table should be OK */


       org_tab(i) := l_parent;


      /* If at any point of finding top org we come across any org that is same as start org then no need to process
      remaining orgs in cursor ready_to_compile_orgs since we have reached start org so that means compilation has to start
      from stat org itself. */

        If l_parent = start_org then
         status :=0 ;
            EXIT ;
           End if ;

        i:=i+1 ;
      End if ;


EXCEPTION
 WHEN OTHERS THEN
  status := SQLCODE;
END ;
END LOOP ;
END find_impacted_top_org ;

/*3016281 :Added this new function to check (and return 1 else 0 ) if explicit multipliers are defined for all the
cost codes in impacted cost bases for an org .
This is to implement the functionality that in the above mentioned case compiled set ids should neither be obsoleted
nor generated for an org. */

FUNCTION check_for_explicit_multiplier(rate_sch_rev_id IN NUMBER,org_id IN NUMBER) RETURN NUMBER
IS
org_override NUMBER :=0;
l_org_id_parent NUMBER(15) DEFAULT 0; /* Bug 4739218 */

/*
 * Repalced with the below sql. Hari 19-JUL-05.
CURSOR impacted_cost_code_cur(x_base VARCHAR2)     **Cursor for all the cost codes of impacted cost bases**
IS
     SELECT distinct cbicc.ind_cost_code
      FROM    pa_cost_base_cost_codes cbicc,
              pa_ind_rate_sch_revisions irsr
     WHERE irsr.ind_rate_sch_revision_id = rate_sch_rev_id
        AND irsr.cost_plus_structure =  cbicc.cost_plus_structure
        AND cbicc.cost_base = x_base
        AND cbicc.cost_base_type = INDIRECT_COST_CODE ;
        */
CURSOR impacted_cost_code_cur(x_base VARCHAR2)     /*Cursor for all the cost codes of impacted cost bases*/
IS
     SELECT distinct cbicc.ind_cost_code
      FROM    pa_cost_base_cost_codes cbicc
     WHERE cbicc.cost_plus_structure  = G_CP_STRUCTURE
        AND cbicc.cost_base = x_base
        AND cbicc.cost_base_type = INDIRECT_COST_CODE ;

BEGIN

/* S.N. Bug 3938479 */
IF  rate_sch_rev_id = g_rate_sch_rev_id AND org_id = g_org_id Then

    org_override := g_org_override;
    RETURN org_override;

ELSE

g_rate_sch_rev_id := rate_sch_rev_id;
g_org_id          := org_id ;

/* E.N. Bug 3938479 */


/*FOR cost_base_rec in impacted_cost_bases(rate_sch_rev_id)   **Loop for impacted cost bases*/
IF G_IMPACTED_COST_BASES_TAB.COUNT <> 0 THEN /*4590268*/

  FOR i in G_IMPACTED_COST_BASES_TAB.FIRST .. G_IMPACTED_COST_BASES_TAB.LAST
   LOOP
     --FOR cost_code_rec in impacted_cost_code_cur(cost_base_rec.cost_base)
     FOR cost_code_rec in impacted_cost_code_cur(G_IMPACTED_COST_BASES_TAB(i))

       LOOP
        BEGIN
            select 1 into org_override
             from sys.dual
             where exists(select 1
                          from  pa_ind_cost_multipliers icm ,
                       pa_ind_compiled_sets ics
                          where icm.ind_rate_sch_revision_id =ics.ind_rate_sch_revision_id
                 and   icm.ind_rate_sch_revision_id = rate_sch_rev_id
                 AND   icm.organization_id =ics.organization_id
                          and   icm.organization_id = org_id
                 --AND   ics.cost_base = cost_base_rec.cost_base
                 AND   ics.cost_base = G_IMPACTED_COST_BASES_TAB(i)
                    AND   ics.status ='A'
                          and   icm.ind_cost_code  = cost_code_rec.ind_cost_code
                          and  nvl(icm.ready_to_compile_flag,'N') ='N');
                          /*Ready_to_compile_flag 'N' means unchanged so will check for this only*/
         EXCEPTION
          WHEN NO_DATA_FOUND THEN
              BEGIN /* Code change for Bug 4739218 Starts */
                 select 0 into org_override
                 from sys.dual
                 where exists
                 (
                     select 1
                     from  pa_ind_cost_multipliers icm ,
                           pa_ind_compiled_sets ics
                     where icm.ind_rate_sch_revision_id =ics.ind_rate_sch_revision_id
                     and   icm.ind_rate_sch_revision_id = rate_sch_rev_id
                     and   icm.organization_id =ics.organization_id
                     and   icm.organization_id = org_id
                      and  nvl(icm.ready_to_compile_flag,'N')  <> 'N'
                 );
                 /*If explicit multipliers exists and got changed then org_overrride = 0 */
                 EXIT;
            EXCEPTION
             WHEN NO_DATA_FOUND THEN
                   BEGIN
                     SELECT organization_id_parent into l_org_id_parent
                     FROM per_org_structure_elements
                     WHERE organization_id_child = org_id
                     AND org_structure_version_id = G_ORG_STRUC_VER_ID;
                     org_override := check_for_explicit_multiplier(rate_sch_rev_id, l_org_id_parent);
                     return org_override;
                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                      org_override := 1 ;/* This is the start_org and explicit multiplier are not defined */
                      return org_override;
                    WHEN OTHERS THEN
                       RAISE;
                   END;
            END; /*Code change for Bug 4739218 Ends */
          END;
        END LOOP;

      If org_override =0 THEN
      EXIT;
      END IF;
   END LOOP;
END IF; -- G_IMPACTED_COST_BASES_TAB.COUNT <> 0 THEN /*4590268*/

END IF ;/* Bug 3938479 */

g_org_override := org_override; /* Bug 3938479 */
RETURN org_override;

EXCEPTION
  WHEN OTHERS THEN
   RAISE;
END check_for_explicit_multiplier ;                                                                      /*3012681*/

PROCEDURE Cache_Impacted_Cost_Bases ( P_Ind_Rate_Sch_Revision_Id IN PA_IND_RATE_SCH_REVISIONS.IND_RATE_SCH_REVISION_ID%TYPE
                                  ,P_Cp_Structure             IN PA_COST_PLUS_STRUCTURES.COST_PLUS_STRUCTURE%TYPE
                        )
IS
  CURSOR impacted_cost_bases_cur( P_Ind_Rate_Sch_Revision_Id PA_IND_RATE_SCH_REVISIONS.IND_RATE_SCH_REVISION_ID%TYPE
                        ,P_Cp_Structure             PA_COST_PLUS_STRUCTURES.COST_PLUS_STRUCTURE%TYPE
                 )
  IS
  SELECT pcb.COST_BASE
    FROM PA_COST_BASES pcb
   WHERE pcb.COST_BASE_TYPE = INDIRECT_COST_CODE
     AND nvl(G_MODULE ,'XXX') <>  'NEW_ORG'   /*4870539*/
     AND EXISTS
     (
      SELECT 1
        FROM PA_COST_BASE_COST_CODES CBICC,
             PA_IND_COST_MULTIPLIERS ICM
       WHERE ICM.IND_RATE_SCH_REVISION_ID = P_Ind_Rate_Sch_Revision_Id
         AND (NVL(ICM.READY_TO_COMPILE_FLAG,'N') IN ('Y','X') AND NVL(G_MODULE ,'XXX') <> 'NEW_ORG')/*4870539*/
         AND CBICC.COST_PLUS_STRUCTURE = P_Cp_Structure
         AND CBICC.IND_COST_CODE = ICM.IND_COST_CODE
         AND CBICC.COST_BASE = PCB.COST_BASE
         AND CBICC.COST_BASE_TYPE = PCB.COST_BASE_TYPE )
    UNION  /*4870539 :Added union*/
     SELECT pcb.COST_BASE
      FROM PA_COST_BASES pcb
     WHERE pcb.COST_BASE_TYPE = INDIRECT_COST_CODE
     AND nvl(G_MODULE ,'XXX') = 'NEW_ORG'
     AND EXISTS
     (
      SELECT 1
        FROM PA_COST_BASE_COST_CODES CBICC,
             PA_IND_rate_sch_revisions IRSR
       WHERE IRSR.IND_RATE_SCH_REVISION_ID = P_Ind_Rate_Sch_Revision_Id
         AND nvl(G_MODULE ,'XXX') = 'NEW_ORG'
         AND IRSR.COST_PLUS_STRUCTURE= CBICC.COST_PLUS_STRUCTURE
         AND CBICC.COST_PLUS_STRUCTURE = P_Cp_Structure
         AND CBICC.COST_BASE = PCB.COST_BASE
         AND CBICC.COST_BASE_TYPE = PCB.COST_BASE_TYPE ); /*End of changes for 4870539*/
BEGIN

    G_IMPACTED_COST_BASES_TAB.DELETE;
    OPEN impacted_cost_bases_cur (P_Ind_Rate_Sch_Revision_Id,P_Cp_Structure);
    FETCH impacted_cost_bases_cur BULK COLLECT INTO G_IMPACTED_COST_BASES_TAB;
    CLOSE impacted_cost_bases_cur;

END Cache_Impacted_Cost_Bases;

end PA_COST_PLUS ;

/
