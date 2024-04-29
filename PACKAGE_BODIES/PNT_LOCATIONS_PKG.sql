--------------------------------------------------------
--  DDL for Package Body PNT_LOCATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PNT_LOCATIONS_PKG" AS
  -- $Header: PNTLOCNB.pls 120.8.12010000.3 2008/11/27 04:42:30 rthumma ship $

  TYPE loc_info_rec IS
   RECORD (active_start_date               pn_locations.active_start_date%TYPE,
           active_end_date                 pn_locations.active_end_date%TYPE,
           area                            pn_locations.assignable_area%TYPE);

  TYPE loc_info_type IS
   TABLE OF loc_info_rec
   INDEX BY BINARY_INTEGER;

  loc_info_tbl loc_info_type;

   ---------------------------------------------------------------------------------------------
   --  CURSOR     : For_Insert_Cur, For_Update_St_Cur, For_Update_End_Cur
   --  DESCRIPTION: Moved similar cursors from procedures check_location_overlap and
   --               check_location_gaps.
   --  15-NOV-2004  Satish Tripathi o Moved from check_location_overlap and check_location_gaps.
   ---------------------------------------------------------------------------------------------

   CURSOR For_Insert_Cur (p_loc_cd VARCHAR2, p_loc_type_cd VARCHAR2, p_org_id NUMBER)
   IS
      SELECT MIN(active_start_date), MAX(active_end_date)
      FROM   pn_locations_all
      WHERE  location_code = p_loc_cd
      AND    location_type_lookup_code = p_loc_type_cd
      AND    org_id = p_org_id;

   CURSOR For_Update_St_Cur (p_loc_id NUMBER, p_str_dt DATE, p_str_dt_old DATE)
   IS
      SELECT TO_NUMBER(MIN(p_str_dt - active_end_date)) start_date_diff
      FROM   pn_locations_all
      WHERE  location_id = p_loc_id
      AND    ROWID <> g_pn_locations_rowid
      AND    active_end_date < p_str_dt_old;

   CURSOR For_Update_End_Cur (p_loc_id NUMBER, p_end_dt DATE, p_end_dt_old DATE)
   IS
      SELECT TO_NUMBER(MAX(p_end_dt - active_start_date)) end_date_diff
      FROM   pn_locations_all
      WHERE  location_id = p_loc_id
      AND    ROWID <> g_pn_locations_rowid
      AND    active_start_date > p_end_dt_old;


PROCEDURE Put_Log(p_String VarChar2) IS

BEGIN

  Fnd_File.Put_Line(Fnd_File.Log,    p_String);

EXCEPTION

  When Others Then Raise;

END Put_Log;

--------------------------------------------------------------------
-- FUNCTION get_max_rent_area
--------------------------------------------------------------------
FUNCTION Get_Max_Rent_Area(
                         p_loc_id      IN NUMBER
                        ,p_lkp_code    IN VARCHAR2
                        ,p_act_str_dt  IN DATE
                        ,p_act_end_dt  IN DATE
                        )
RETURN NUMBER
IS

   CURSOR csr_loc_info(p_loc_id      IN NUMBER,
                       p_lkp_code    IN VARCHAR2,
                       p_act_str_dt  IN DATE,
                       p_act_end_dt  IN DATE) IS
      SELECT location_id, active_start_date, active_end_date, NVL(rentable_area,0) rentable_area
      FROM   pn_locations_all
      WHERE  location_type_lookup_code =  p_lkp_code
      AND    active_start_date <= NVL(p_act_end_dt, TO_DATE('12/31/4712','MM/DD/YYYY'))
      AND    active_end_date   >= p_act_str_dt
      START WITH       location_id = p_loc_id
      CONNECT BY PRIOR location_id = parent_location_id
      AND p_act_str_dt between prior active_start_date and
      NVL(prior active_end_date,TO_DATE('12/31/4712','MM/DD/YYYY'));

   i                 NUMBER := 0;
   l_num_table       pn_recovery_extract_pkg.number_table_TYPE;
   l_date_table      pn_recovery_extract_pkg.date_table_TYPE;
   l_max_area        NUMBER := 0;

  BEGIN
   loc_info_tbl.delete;
   FOR rec_loc_info IN csr_loc_info(p_loc_id, p_lkp_code, p_act_str_dt, p_act_end_dt)
   LOOP

      loc_info_tbl(i).active_start_date := rec_loc_info.active_start_date;
      loc_info_tbl(i).active_end_date := rec_loc_info.active_end_date;
      loc_info_tbl(i).area := rec_loc_info.rentable_area;
      i := i + 1;
   END LOOP;

   FOR i IN 0 .. loc_info_tbl.count-1
   LOOP
      pn_recovery_extract_pkg.process_vacancy(
                 p_start_date   => loc_info_tbl(i).active_start_date,
                 p_end_date     => loc_info_tbl(i).active_end_date,
                 p_area         => loc_info_tbl(i).area,
                 p_date_table   => l_date_table,
                 p_number_table => l_num_table,
                 p_add          => TRUE);
   END LOOP;

   FOR i IN 0 .. l_num_table.count-1
   LOOP
      IF l_num_table(i) > l_max_area THEN
         l_max_area := l_num_table(i);
      END IF;
   END LOOP;

   RETURN l_max_area;

  END Get_Max_Rent_Area;

-------------------------------------------------------
-- Validates that the same location does not lie between
-- overlapping time periods
-------------------------------------------------------
PROCEDURE check_location_overlap  (
   p_org_id                    IN NUMBER,
   p_location_id               IN NUMBER ,
   p_location_code             IN VARCHAR2,
   p_location_type_lookup_code IN VARCHAR2,
   p_active_start_date         IN DATE,
   p_active_end_date           IN DATE,
   p_active_start_date_old     IN DATE,
   p_active_end_date_old       IN DATE,
   x_return_status             OUT NOCOPY VARCHAR2,
   x_return_message            OUT NOCOPY VARCHAR2)
IS

   l_min_start_date DATE;
   l_max_end_date   DATE;

BEGIN

   pnp_debug_pkg.debug('PNT_LOCATIONS_PKG.check_location_overlap(+)');
   pnp_debug_pkg.debug('  ChkLocOlap=> In Parameters :: p_location_id: '||p_location_id||', LocCd: '||p_location_code
                       ||', Type: '||p_location_type_lookup_code||' OrgId: '||p_org_id);
   pnp_debug_pkg.debug('  ChkLocOlap=>   p_active_start_date    : '||TO_CHAR(p_active_start_date, 'MM/DD/YYYY')
                       ||', p_active_end_date    : '||TO_CHAR(p_active_end_date, 'MM/DD/YYYY'));
   pnp_debug_pkg.debug('  ChkLocOlap=>   p_active_start_date_old: '||TO_CHAR(p_active_start_date_old, 'MM/DD/YYYY')
                       ||', p_active_end_date_old: '||TO_CHAR(p_active_end_date_old, 'MM/DD/YYYY'));

    IF p_location_id IS NULL THEN

       -- Check for overlaps during create record
       OPEN for_insert_cur(p_loc_cd => p_location_code, p_loc_type_cd => p_location_type_lookup_code, p_org_id => p_org_id);
          FETCH for_insert_cur
          INTO  l_min_start_date,
                l_max_end_date;
       CLOSE for_insert_cur;

      pnp_debug_pkg.debug('    ChkLocOlap> MinStrDt: '||TO_CHAR(l_min_start_date, 'MM/DD/YYYY')
                          ||', MaxEndDt: '||TO_CHAR(l_max_end_date, 'MM/DD/YYYY'));
       -- Validate for start date
       IF p_active_start_date IS NOT NULL THEN
          IF p_active_start_date BETWEEN l_min_start_date AND l_max_end_date THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             fnd_message.set_name('PN','PN_INVALID_EFFECTIVE_DATES');
             return;
          END IF;
       END IF;

       -- Validate for start date
       IF p_active_end_date IS NULL THEN
          IF p_active_start_date BETWEEN l_min_start_date AND l_max_end_date THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             fnd_message.set_name('PN','PN_INVALID_EFFECTIVE_DATES');
             return;
          END IF;

       -- Validate for end date
       ELSE
          IF (p_active_end_date BETWEEN l_min_start_date AND l_max_end_date)
          OR (p_active_end_date = g_end_of_time and p_active_start_date < l_min_start_date) THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             fnd_message.set_name('PN','PN_INVALID_EFFECTIVE_DATES');
             return;
          END IF;
       END IF;

    ELSE

       IF p_active_start_date IS NOT NULL THEN
          FOR update_rec in for_update_st_cur(p_loc_id => p_location_id, p_str_dt => p_active_start_date, p_str_dt_old => p_active_start_date_old)
          LOOP
             pnp_debug_pkg.debug('    ChkLocOlap> Start date diff = '|| update_rec.start_date_diff);
             IF update_rec.start_date_diff <  1 then
                x_return_status := FND_API.G_RET_STS_ERROR;
                fnd_message.set_name('PN','PN_INVALID_EFFECTIVE_DATES');
                return;
             END IF;
          END LOOP;
       END IF;

       IF p_active_end_date IS NOT NULL THEN
          FOR update_rec in for_update_end_cur(p_loc_id => p_location_id, p_end_dt => p_active_end_date, p_end_dt_old => p_active_end_date_old)
          LOOP
             pnp_debug_pkg.debug('    ChkLocOlap> End date diff = '||  update_rec.end_date_diff);
             IF update_rec.end_date_diff >  -1 then
                x_return_status := FND_API.G_RET_STS_ERROR;
                fnd_message.set_name('PN','PN_INVALID_EFFECTIVE_DATES');
                return;
             END IF;
          END LOOP;
       END IF;
    END IF;

    pnp_debug_pkg.debug('PNT_LOCATIONS_PKG.check_location_overlap(-) ReturnStatus: '||x_return_status);
EXCEPTION

   WHEN OTHERS THEN
     fnd_message.set_name('PN','PN_OTHERS_EXCEPTION');
     fnd_message.set_token('ERR_MSG',sqlerrm);

END check_location_overlap;

------------------------------------------------------
-- Procedure to validate that there cannot be any gaps
-- at building and floor level
--  13-JAN-2005 Satish Tripathi o Fixed for BUG# 4104674. Sub/Add 1 from l_min/max_start_date.
----------------------------------------------------
PROCEDURE check_location_gaps (
                          p_org_id                        IN  NUMBER
                         ,p_location_id                   IN  NUMBER
                         ,p_location_code                 IN  VARCHAR2
                         ,p_location_type_lookup_code     IN  VARCHAR2
                         ,p_active_start_date             IN  DATE
                         ,p_active_end_date               IN  DATE
                         ,p_active_start_date_old         IN  DATE
                         ,p_active_end_date_old           IN  DATE
                         ,x_return_status                 OUT NOCOPY VARCHAR2
                         ,x_return_message                OUT NOCOPY VARCHAR2
                         )
IS

   l_min_start_date     DATE;
   l_max_end_date       DATE;

BEGIN

   pnp_debug_pkg.debug('PNT_LOCATIONS_PKG.check_location_gaps(+)');
   pnp_debug_pkg.debug('  ChkLocGap=> In Parameters :: p_location_id: '||p_location_id
                       ||', LocCd: '||p_location_code||', OrgId: '||p_org_id);
   pnp_debug_pkg.debug('  ChkLocGap=>   p_active_start_date    : '||TO_CHAR(p_active_start_date, 'MM/DD/YYYY')
                       ||', p_active_end_date    : '||TO_CHAR(p_active_end_date, 'MM/DD/YYYY'));
   pnp_debug_pkg.debug('  ChkLocGap=>   p_active_start_date_old: '||TO_CHAR(p_active_start_date_old, 'MM/DD/YYYY')
                       ||', p_active_end_date_old: '||TO_CHAR(p_active_end_date_old, 'MM/DD/YYYY'));

   IF p_location_id IS NULL THEN
   -- Check for gaps during create record

      OPEN for_insert_cur(p_loc_cd => p_location_code, p_loc_type_cd => p_location_type_lookup_code, p_org_id => p_org_id);
         FETCH for_insert_cur
         INTO  l_min_start_date,
               l_max_end_date;
      CLOSE for_insert_cur;

      l_min_start_date := l_min_start_date - 1;
      l_max_end_date   := l_max_end_date + 1;

      pnp_debug_pkg.debug('    ChkLocGap> MinStrDt: '||TO_CHAR(l_min_start_date, 'MM/DD/YYYY')
                          ||', MaxEndDt: '||TO_CHAR(l_max_end_date, 'MM/DD/YYYY'));
      IF p_active_start_date IS NOT NULL THEN
         IF NOT ((p_active_start_date <= l_min_start_date AND
                  NVL(p_active_end_date, TO_DATE('12/31/4712','MM/DD/YYYY')) = l_min_start_date) OR
            (p_active_start_date >= l_max_end_date and p_active_start_date = l_max_end_date))
         THEN
            pnp_debug_pkg.debug('    ChkLocGap> StrDt<MinStrDt OR StrDt>MaxEndDt');
            x_return_status := FND_API.G_RET_STS_ERROR;
            fnd_message.set_name('PN','PN_LOC_GAPS_MSG');
            fnd_message.set_token('GAP_START_DATE',l_max_end_date);
            fnd_message.set_token('GAP_END_DATE',p_active_start_date - 1);
            RETURN;
         END IF;
      ELSIF p_active_end_date IS NOT NULL THEN
         IF p_active_end_date < l_min_start_date THEN
            pnp_debug_pkg.debug('    ChkLocGap> EndDt<MinStrDt');
            x_return_status := FND_API.G_RET_STS_ERROR;
            fnd_message.set_name('PN','PN_LOC_GAPS_MSG');
            fnd_message.set_token('GAP_START_DATE',p_active_end_date + 1);
            fnd_message.set_token('GAP_END_DATE',l_min_start_date);
            RETURN;
         END IF;
      END IF;

   ELSE

   -- Check for gaps during update record

      IF p_active_start_date IS NOT NULL THEN
         FOR update_rec in for_update_st_cur(p_loc_id => p_location_id, p_str_dt => p_active_start_date, p_str_dt_old => p_active_start_date_old)
         LOOP
            pnp_debug_pkg.debug('    ChkLocGap> Start date diff = '|| update_rec.start_date_diff);
            IF update_rec.start_date_diff <>  1 THEN
               pnp_debug_pkg.debug('    ChkLocGap> StrDt not Null, Diff <> 1');
               x_return_status := FND_API.G_RET_STS_ERROR;
               fnd_message.set_name('PN','PN_LOC_GAPS_MSG');
               fnd_message.set_token('GAP_START_DATE',p_active_start_date_old);
               fnd_message.set_token('GAP_END_DATE',p_active_start_date - 1);
               RETURN;
            END IF;
         END LOOP;
      END IF;

      IF p_active_end_date IS NOT NULL THEN
         FOR update_rec in for_update_end_cur(p_loc_id => p_location_id, p_end_dt => p_active_end_date, p_end_dt_old => p_active_end_date_old)
         LOOP
            pnp_debug_pkg.debug('    ChkLocGap> End date diff = '||  update_rec.end_date_diff);
            IF update_rec.end_date_diff <>  -1 then
               pnp_debug_pkg.debug('    ChkLocGap> EndDt not Null, Diff <> 1');
               x_return_status := FND_API.G_RET_STS_ERROR;
               fnd_message.set_name('PN','PN_LOC_GAPS_MSG');
               fnd_message.set_token('GAP_START_DATE',p_active_end_date + 1);
               fnd_message.set_token('GAP_END_DATE',p_active_end_date_old);
               RETURN;
            END IF;
         END LOOP;
      END IF;
   END IF;

   pnp_debug_pkg.debug('PNT_LOCATIONS_PKG.check_location_gaps(-) ReturnStatus: '||x_return_status);
EXCEPTION

   WHEN OTHERS THEN
     fnd_message.set_name('PN','PN_OTHERS_EXCEPTION');
     fnd_message.set_token('ERR_MSG',sqlerrm);

END check_location_gaps;

----------------------------------------------------------------------
-- PROCEDURE SET_ROWID
----------------------------------------------------------------------
PROCEDURE SET_ROWID
         ( p_location_id   IN NUMBER,
           p_active_start_date IN DATE,
           p_active_end_date IN DATE,
           x_return_status OUT NOCOPY VARCHAR2,
           x_return_message OUT NOCOPY VARCHAR2)

IS

   l_rowid ROWID;

BEGIN

   pnp_debug_pkg.debug('      PntLocnPkg.SetRowid (+) LocId: '||p_location_id
                       ||', ActStrDt: '||TO_CHAR(p_active_start_date, 'MM/DD/YYYY')
                       ||', ActEndDt: '||TO_CHAR(p_active_end_date, 'MM/DD/YYYY'));

     -- Location ID, Active Start Date, Active End Date are the old values retrived by the query

     SELECT ROWID
     INTO   l_rowid
     FROM   pn_locations_all
     WHERE  location_id = p_location_id
     AND    active_start_date = p_active_start_date
     AND    active_end_date = NVL(p_active_end_date,g_end_of_time);

     g_pn_locations_rowid := l_rowid;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

   pnp_debug_pkg.debug('      PntLocnPkg.SetRowid (-) ReturnStatus: '||x_return_status);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN TOO_MANY_ROWS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

END SET_ROWID;

-------------------------------------------------------------------------------
-- PROCEDURE : Set_Cascade
-- PURPOSE   : This procedure sets the occupancy_status_code and
--             assignable_emp/cc/cust
--             of g_loc_recinfo_tmp depending on the value of p_cascade.
-- IN PARAM  :
-- History   :
--  01-DEC-04 Satish Tripathi o Created for Portfolio Status Enh BUG# 4030816.
--  22-DEC-04 Satish Tripathi o Added cursor parent_location_cursor to retain
--                                not assignable of parent.
--  21-FEB-06 Hareesha        o Bug # 4918666 Copy values into g_loc_recinfo_tmp
--                              only when l_cascade_emp AND l_cascade_cc AND
--                              l_cascade_cust are not null.
--  30-MAY-06 Hareesha        o Bug #5222847 Cascade the value of occupancy status
--                              to the child locations if made non-occupiable.
-------------------------------------------------------------------------------
PROCEDURE Set_Cascade (
                          p_cascade                       IN  VARCHAR2
                        )
IS
   l_cascade_occ                   VARCHAR2(30) := SUBSTR(p_cascade, 1, 1);
   l_cascade_emp                   VARCHAR2(30) := SUBSTR(p_cascade, 2, 1);
   l_cascade_cc                    VARCHAR2(30) := SUBSTR(p_cascade, 3, 1);
   l_cascade_cust                  VARCHAR2(30) := SUBSTR(p_cascade, 4, 1);

   CURSOR parent_location_cursor IS
      SELECT *
      FROM   pn_locations_all
      WHERE  location_id = g_loc_recinfo_tmp.parent_location_id
      AND    active_start_date <= g_loc_recinfo_tmp.active_end_date
      AND    active_end_date >= g_loc_recinfo_tmp.active_start_date;

BEGIN

  pnp_debug_pkg.debug('   Set_Cascade (+) '||p_cascade
                      ||', Occ/Asgn:|'||g_loc_recinfo_tmp.Occupancy_status_code
                      ||'|'||g_loc_recinfo_tmp.Assignable_emp
                      ||'|'||g_loc_recinfo_tmp.Assignable_cc
                      ||'|'||g_loc_recinfo_tmp.Assignable_cust
                      ||'|'
                      ||', LocId: '||g_loc_recinfo_tmp.location_id
                      ||', LocCd: '||g_loc_recinfo_tmp.location_code
                      ||', Type: '||g_loc_recinfo_tmp.location_type_lookup_code
                      ||', StrDt: '||TO_CHAR(g_loc_recinfo_tmp.active_start_date, 'MM/DD/YYYY')
                      ||', EndDt: '||TO_CHAR(g_loc_recinfo_tmp.active_end_date, 'MM/DD/YYYY'));

   IF l_cascade_occ IN ('Y', 'N') THEN
      FOR parent_locn IN parent_location_cursor
      LOOP
         IF l_cascade_occ = 'N' THEN
            g_loc_recinfo_tmp.occupancy_status_code := 'N';
         END IF;
         IF l_cascade_emp IN ('Y','N') THEN
            IF NVL(parent_locn.assignable_emp, 'Y') = 'N' THEN
              g_loc_recinfo_tmp.assignable_emp  := 'N';
            END IF;
         END IF;
         IF l_cascade_cc IN ('Y','N') THEN
            IF NVL(parent_locn.assignable_cc, 'Y') = 'N' THEN
              g_loc_recinfo_tmp.assignable_cc  := 'N';
            END IF;
         END IF;
         IF l_cascade_cust IN ('Y','N') THEN
            IF NVL(parent_locn.assignable_cust, 'Y') = 'N' THEN
              g_loc_recinfo_tmp.assignable_cust  := 'N';
            END IF;
         END IF;
      END LOOP;

   ELSE
      IF l_cascade_emp IN ('Y', 'N') THEN
         g_loc_recinfo_tmp.assignable_emp  := l_cascade_emp;
      END IF;

      IF l_cascade_cc IN ('Y', 'N') THEN
         g_loc_recinfo_tmp.assignable_cc   := l_cascade_cc;
      END IF;

      IF l_cascade_cust IN ('Y', 'N') THEN
         g_loc_recinfo_tmp.assignable_cust := l_cascade_cust;
      END IF;
   END IF;

  pnp_debug_pkg.debug('   Set_Cascade (-) '||p_cascade
                      ||', Occ/Asgn:|'||g_loc_recinfo_tmp.Occupancy_status_code
                      ||'|'||g_loc_recinfo_tmp.Assignable_emp
                      ||'|'||g_loc_recinfo_tmp.Assignable_cc
                      ||'|'||g_loc_recinfo_tmp.Assignable_cust
                      ||'|');

END Set_Cascade;


-----------------------------------------------------------------------
-- PROCEDURE : Set_Null_Request_Program_Id
-- PURPOSE   : This procedure sets request_id, program_id, program_update_date
--             and program_application_id to NULL of g_loc_recinfo_tmp.
-- IN PARAM  :
-- History   :
--  01-DEC-2004 Satish Tripathi o Created for Portfolio Status Enh BUG# 4030816.
-----------------------------------------------------------------------
PROCEDURE Set_Null_Request_Program_Id
IS
BEGIN
   g_loc_recinfo_tmp.request_id             := NULL;
   g_loc_recinfo_tmp.program_id             := NULL;
   g_loc_recinfo_tmp.program_update_date    := NULL;
   g_loc_recinfo_tmp.program_application_id := NULL;
END Set_Null_Request_Program_Id;


-------------------------------------------------------------------------------
-- PROCEDURE CORRECT_UPDATE_ROW
-- HISTORY:
--  14-JAN-2002   Mrinal Misra  o Did conditional assignment of dates to
--                                Validate_date_assignable_area for
--                                CORRECT/UPDATE.
--  14-OCT-2003   Anand Tuppad  o Added code to consider the new column
--                                bookable_flag.
--  06-FEB-2004   Kiran Hegde   o indented code
--                              o changed the way l_end_date is populated
--                              o changed the condition for populating
--                                G_LOC_RECINFO
--  01-DEC-2004 Satish Tripathi o Modified for Portfolio Status Enh BUG# 4030816.
--                                Added parameter p_cascade to cascade the changes in
--                                occupancy_status_code, assignable_emp/cc/cust to
--                                Child locations by calling Cascade_Child_Locn.
--                                Populate g_loc_recinfo_tmp to call Insert/Update_Locn_Row.
-- 21-JAN-2008  acprakas        o Bug#6755579: Commented code which sets g_loc_recinfo_tmp.common_area_flag
--                                to NULL.
-------------------------------------------------------------------------------
PROCEDURE Correct_Update_Row(
                          p_pn_locations_rec          IN  pn_locations_all%ROWTYPE
                         ,p_pn_addresses_rec          IN  pn_addresses_all%ROWTYPE
                         ,p_change_mode               IN  VARCHAR2
                         ,p_as_of_date                IN  DATE
                         ,p_active_start_date_old     IN  DATE
                         ,p_active_end_date_old       IN  DATE
                         ,p_assgn_area_chgd_flag      IN  VARCHAR2
                         ,p_validate                  IN  BOOLEAN
                         ,p_cascade                   IN  VARCHAR2
                         ,x_return_status             OUT NOCOPY VARCHAR2
                         ,x_return_message            OUT NOCOPY VARCHAR2
                         )
IS

   l_rowid rowid;
   l_location_id           NUMBER  := NULL;
   l_str_dt                DATE := NULL;
   l_str_dt_old            DATE := NULL;
   l_end_dt                DATE := NULL;
   l_active_start_date_new DATE := NULL;
   l_active_end_date_new   DATE := NULL;
   l_as_of_date            DATE := NULL;

   CURSOR  location_cursor_old is
      SELECT *
      FROM   pn_locations_all
      WHERE  location_id = p_pn_locations_rec.location_id
      AND    active_start_date = NVL(p_active_start_date_old, g_start_of_time)
      AND    active_end_date = NVL(p_active_end_date_old, g_end_of_time);

  BEGIN


  pnp_debug_pkg.debug('PNT_LOCATIONS_PKG.Correct_Update_Row (+) Mode: '||p_change_mode||', Cascade: '||p_cascade
                      ||', AsofDt: '||p_as_of_date);
  pnp_debug_pkg.debug('  CorUpdRow=> LocId: '||p_pn_locations_rec.location_id||', LocCd: '||p_pn_locations_rec.location_code
                      ||', Type: '||p_pn_locations_rec.location_type_lookup_code
                      ||', StrDt: '||TO_CHAR(p_pn_locations_rec.active_start_date, 'MM/DD/YYYY')
                      ||', EndDt: '||TO_CHAR(p_pn_locations_rec.active_end_date, 'MM/DD/YYYY'));

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  PNT_LOCATIONS_PKG.SET_ROWID(
      p_location_id       => p_pn_locations_rec.location_id,
      p_active_start_date => p_active_start_date_old,
      p_active_end_date   => p_active_end_date_old,
      x_return_status     => x_return_status,
      x_return_message    => x_return_message);

  IF ( p_validate) THEN
    pnp_debug_pkg.put_log_msg('Calling validate_assignable_area');

    IF p_change_mode = 'CORRECT' THEN
       l_str_dt := p_pn_locations_rec.active_start_date;
       l_end_dt := p_pn_locations_rec.active_end_date;
    ELSIF p_change_mode = 'UPDATE' THEN
       l_str_dt := p_as_of_date;
       l_end_dt := p_pn_locations_rec.active_end_date;
    END IF;

    PNP_UTIL_FUNC.Validate_date_assignable_area
       (p_location_id           => p_pn_locations_rec.location_id,
        p_location_type         => p_pn_locations_rec.location_type_lookup_code,
        p_start_date            => l_str_dt,
        p_end_date              => l_end_dt,
        p_active_start_date_old => p_active_start_date_old,
        p_active_end_date_old   => p_active_end_date_old,
        p_change_mode           => p_change_mode,
        p_assignable_area       => p_pn_locations_rec.assignable_area,
        x_return_status         => x_return_status,
        x_return_message        => x_return_message
        );

    IF not(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       APP_EXCEPTION.Raise_Exception;
    END IF;

    -- Added redwin Fix for Bug 2722698

    PNT_LOCATIONS_PKG.update_assignments (
            p_location_id           => p_pn_locations_rec.location_id,
            p_active_start_date     => p_pn_locations_Rec.active_start_date,
            p_active_end_date       => p_pn_locations_rec.active_end_date,
            p_active_start_date_old => p_active_start_date_old,
            p_active_end_date_old   => p_active_end_date_old,
            x_return_status         => x_return_status,
            x_return_message        => x_return_message);

    IF NOT ( x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             APP_EXCEPTION.Raise_Exception;
    END IF;

  END IF; -- if p_validate

  IF G_LOC_RECINFO.location_id IS NULL OR
     G_LOC_RECINFO.location_id <> p_pn_locations_rec.location_id OR
     NVL(G_LOC_RECINFO.active_start_date, G_START_OF_TIME)
         <> NVL(p_active_start_date_old, G_START_OF_TIME) OR
     NVL(G_LOC_RECINFO.active_end_date, G_END_OF_TIME)
         <> NVL(p_active_end_date_old, G_END_OF_TIME) THEN

     OPEN LOCATION_CURSOR_OLD;
     FETCH location_cursor_old INTO G_LOC_RECINFO;
     IF (location_cursor_old%NOTFOUND) THEN
       CLOSE location_cursor_old;
       APP_EXCEPTION.Raise_Exception;
     END IF;
     CLOSE LOCATION_CURSOR_OLD;

  END IF;

  -- The following is called if dates are brought in, then we need to update the children

  IF G_LOC_RECINFO.active_end_date >
     nvl(p_pn_locations_rec.active_end_date,G_END_OF_TIME) OR
     G_LOC_RECINFO.active_start_date
     < nvl(p_pn_locations_rec.active_start_date,G_START_OF_TIME) THEN

    PNT_LOCATIONS_PKG.Update_child_for_dates (
        p_location_id               => p_pn_locations_rec.location_id,
        p_active_start_date         => p_pn_locations_Rec.active_start_date,
        p_active_end_date           => p_pn_locations_rec.active_end_date,
        p_active_start_date_old     => p_active_start_date_old,
        p_active_end_date_old       => p_active_end_date_old,
        p_location_type_lookup_code => p_pn_locations_rec.location_type_lookup_code,
        x_return_status             => x_return_status,
        x_return_message            => x_return_message);

    IF NOT ( x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       APP_EXCEPTION.Raise_Exception;
    END IF;

  END IF;

  IF p_change_mode = 'CORRECT' THEN

    -- The following is to check if gaps are there in location records
    IF ( p_validate) then

       ----------------------------------------------
       -- Call check_location_overlap
       --  This procedure checks that there is no overlap
       --  of dates for the same location
       ------------------------------------------------
       pnp_debug_pkg.put_log_msg('Calling check_location_overlap');
       PNT_LOCATIONS_PKG.check_location_overlap (
          p_org_id                    => p_pn_locations_rec.org_id,
          p_location_id               => p_pn_locations_rec.location_id,
          p_location_code             => p_pn_locations_rec.location_code,
          p_location_type_lookup_code => p_pn_locations_rec.location_type_lookup_code,
          p_active_start_date         => p_pn_locations_rec.active_start_date,
          p_active_end_date           => p_pn_locations_rec.active_end_date,
          p_active_start_date_old     => p_active_start_date_old,
          p_active_end_date_old       => p_active_end_date_old,
          x_return_status             => x_return_status,
          x_return_message            => x_return_message);

       IF NOT ( x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         pnp_debug_pkg.debug('    CorUpdRow> Error in check_location_overlap');
         pnp_debug_pkg.put_log_msg('    CorUpdRow> Error :Calling check_location_overlap');
         x_return_status := FND_API.G_RET_STS_ERROR;
         APP_EXCEPTION.Raise_Exception;
       END IF;

       IF p_pn_locations_rec.location_type_lookup_code NOT IN ('OFFICE', 'SECTION') THEN
          pnp_debug_pkg.put_log_msg('Calling check_location_gaps');
          PNT_LOCATIONS_PKG.check_location_gaps  (
             p_org_id                => p_pn_locations_rec.org_id,
             p_location_id           => p_pn_locations_rec.location_id,
             p_location_code         => p_pn_locations_rec.location_code,
             p_location_type_lookup_code => p_pn_locations_rec.location_type_lookup_code,
             p_active_start_date     => p_pn_locations_rec.active_start_date,
             p_active_end_date       => p_pn_locations_rec.active_end_date,
             p_active_start_date_old => p_active_start_date_old,
             p_active_end_date_old   => p_active_end_date_old,
             x_return_status         => x_return_status,
             x_return_message        => x_return_message);

          IF NOT ( x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
             pnp_debug_pkg.put_log_msg('Error Calling check_location_gaps');
             x_return_status := FND_API.G_RET_STS_ERROR;
             APP_EXCEPTION.Raise_Exception;
          END IF;

      END IF;

    END IF; -- endif for p_validate

    PNP_DEBUG_PKG.put_log_msg('call update row ');

    g_loc_recinfo_tmp                        := p_pn_locations_rec;
    g_loc_adrinfo_tmp                        := p_pn_addresses_rec;
    pnt_locations_pkg.Set_Cascade(p_cascade);
    pnt_locations_pkg.Update_Locn_Row(
                          p_loc_recinfo          => g_loc_recinfo_tmp
                         ,p_adr_recinfo          => g_loc_adrinfo_tmp
                         ,p_assgn_area_chgd_flag => p_change_mode
                         ,x_return_status        => x_return_status
                         ,x_return_message       => x_return_message
                         );

    IF NOT ( x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      APP_EXCEPTION.Raise_Exception;
    END IF;

    IF p_pn_locations_rec.location_type_lookup_code NOT IN ('OFFICE', 'SECTION') AND
       LTRIM(RTRIM(p_cascade)) IS NOT NULL THEN
       pnt_locations_pkg.cascade_child_locn(
                          p_location_id      => p_pn_locations_rec.location_id
                         ,p_start_date       => p_pn_locations_rec.active_start_date
                         ,p_end_date         => p_pn_locations_rec.active_end_date
                         ,p_cascade          => p_cascade
                         ,p_change_mode      => p_change_mode
                         ,x_return_status    => x_return_status
                         ,x_return_message   => x_return_message
                         );

    END IF;

    -- 'CORRECT' MODE ENDS

  ELSIF p_change_mode = 'UPDATE' THEN

    l_active_start_date_new := G_LOC_RECINFO.active_start_date;
    l_active_end_date_new := G_LOC_RECINFO.active_end_date;

    IF p_pn_locations_rec.active_start_date <> G_LOC_RECINFO.active_start_date THEN
      -- this means user had changed the start date with update option.
      l_active_start_date_new :=  p_pn_locations_rec.active_start_date;
    END IF;
    IF p_pn_locations_rec.active_end_date <> G_LOC_RECINFO.active_end_date THEN
      -- this means user had changed the start date with update option.
      l_active_end_date_new :=  p_pn_locations_rec.active_end_date;
    END IF;

    g_loc_recinfo_tmp                        := p_pn_locations_rec;
    g_loc_adrinfo_tmp                        := p_pn_addresses_rec;
    g_loc_recinfo_tmp.active_start_date      := p_as_of_date;
    g_loc_recinfo_tmp.active_end_date        := l_active_end_date_new;
    pnt_locations_pkg.Set_Cascade(p_cascade);
    pnt_locations_pkg.Update_Locn_Row(
                          p_loc_recinfo          => g_loc_recinfo_tmp
                         ,p_adr_recinfo          => g_loc_adrinfo_tmp
                         ,p_assgn_area_chgd_flag => p_change_mode
                         ,x_return_status        => x_return_status
                         ,x_return_message       => x_return_message
                         );

    IF NOT ( x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       APP_EXCEPTION.Raise_Exception;
    END IF;

    pnp_debug_pkg.put_log_msg('Calling UPDATE ROW.');

    pnp_debug_pkg.put_log_msg('Calling INSERT ROW address = ' || G_LOC_RECINFO.ADDRESS_ID);

    g_loc_recinfo_tmp                        := g_loc_recinfo;
    g_loc_adrinfo_tmp                        := p_pn_addresses_rec;
--Bug#6755579    g_loc_recinfo_tmp.common_area_flag       := NULL;
    g_loc_recinfo_tmp.active_start_date      := l_active_start_date_new;
    g_loc_recinfo_tmp.active_end_date        := p_as_of_date - 1;
    pnt_locations_pkg.Set_Null_Request_Program_Id;
    pnt_locations_pkg.Insert_Locn_Row(
                          p_loc_recinfo      => g_loc_recinfo_tmp
                         ,p_adr_recinfo      => g_loc_adrinfo_tmp
                         ,p_change_mode      => p_change_mode
                         ,x_return_status    => x_return_status
                         ,x_return_message   => x_return_message
                         );

    IF NOT ( x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       APP_EXCEPTION.Raise_Exception;
    END IF;

    IF p_pn_locations_rec.location_type_lookup_code NOT IN ('OFFICE', 'SECTION') AND
       LTRIM(RTRIM(p_cascade)) IS NOT NULL THEN
       pnt_locations_pkg.cascade_child_locn(
                          p_location_id      => p_pn_locations_rec.location_id
                         ,p_start_date       => p_as_of_date
                         ,p_end_date         => l_active_end_date_new
                         ,p_cascade          => p_cascade
                         ,p_change_mode      => p_change_mode
                         ,x_return_status    => x_return_status
                         ,x_return_message   => x_return_message
                         );
    END IF;

  END IF;
  -- End if of correct or update

  pnp_debug_pkg.debug('PNT_LOCATIONS_PKG.Correct_Update_Row (-) ReturnStatus: '||x_return_status);

EXCEPTION
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_ERROR;

END Correct_Update_Row;


-------------------------------------------------------------------------------
-- PROCEDURE : Cascade_Child_Locn
-- PURPOSE   : This procedure cascades changes of occupancy_status_code
--             and assignable_emp/cc/cust to the child location depending
--             on the value of p_cascade. Called from Correct_Update_Row.
-- IN PARAM  :
-- History   :
--  01-DEC-04 Satish Tripathi o Created for Portfolio Status Enh BUG# 4030816.
--  18-JAN-05 Satish Tripathi o For splitting a loc, 1st call Set_RowId. Check for
--                              x_return_status = 'S' before calling
--                              Insert/Update_Locn_Row.
--  11-JUL-06 Hareesha        o Bug #5351698 Modified location_cursor
--                              to remove duplicate records.
-------------------------------------------------------------------------------
PROCEDURE Cascade_Child_Locn (
                          p_location_id                   IN  NUMBER
                         ,p_start_date                    IN  DATE
                         ,p_end_date                      IN  DATE
                         ,p_cascade                       IN  VARCHAR2
                         ,p_change_mode                   IN  VARCHAR2
                         ,x_return_status                 OUT NOCOPY VARCHAR2
                         ,x_return_message                OUT NOCOPY VARCHAR2
                        )
IS
   l_loc_type                      VARCHAR2(30) := 'BUILDING';
   l_split                         VARCHAR2(30) := 'N';
   l_cascade_occ                   VARCHAR2(30) := SUBSTR(p_cascade, 1, 1);
   l_cascade_emp                   VARCHAR2(30) := SUBSTR(p_cascade, 2, 1);
   l_cascade_cc                    VARCHAR2(30) := SUBSTR(p_cascade, 3, 1);
   l_cascade_cust                  VARCHAR2(30) := SUBSTR(p_cascade, 4, 1);

   CURSOR location_cursor IS
      SELECT *
      FROM   pn_locations_all
      START WITH ( parent_location_id = p_location_id
                   AND active_start_date <= NVL(p_end_date, TO_DATE('12/31/4712','MM/DD/YYYY'))
                   AND active_end_date >= p_start_date
                  )
      CONNECT BY ( PRIOR location_id = parent_location_id
                   AND active_end_date >= prior active_start_date
                   AND active_start_date <= prior active_end_date
                 )
      ORDER BY location_type_lookup_code, active_start_date;

BEGIN

   pnp_debug_pkg.debug('PNT_LOCATIONS_PKG.Cascade_Child_Locn (+)');
   pnp_debug_pkg.debug('  CacCldLoc=> In Parameters :: p_location_id: '||p_location_id||', Cascade: '||p_cascade
                       ||', Mode: '||p_change_mode);
   pnp_debug_pkg.debug('  CacCldLoc=>   StrDt: '||TO_CHAR(p_start_date, 'MM/DD/YYYY')
                       ||', EndDt: '||TO_CHAR(p_end_date, 'MM/DD/YYYY'));

   FOR locn_rec IN location_cursor
   LOOP
      g_loc_recinfo_tmp := NULL;
      g_pn_locations_rowid := NULL;
      l_split := 'N';
      IF l_cascade_occ IN ('Y', 'N') THEN
         IF locn_rec.occupancy_status_code  <> l_cascade_occ OR
            locn_rec.assignable_emp         <> l_cascade_occ OR
            locn_rec.assignable_cc          <> l_cascade_occ OR
            locn_rec.assignable_cust        <> l_cascade_occ
         THEN
            l_split := 'Y';
         END IF;
      ELSE
         IF l_cascade_emp IN ('Y', 'N') AND
            locn_rec.assignable_emp <> l_cascade_emp
         THEN
            l_split := 'Y';
         END IF;

         IF l_cascade_cc IN ('Y', 'N') AND
            locn_rec.assignable_cc <> l_cascade_cc
         THEN
            l_split := 'Y';
         END IF;

         IF l_cascade_cust IN ('Y', 'N') AND
            locn_rec.assignable_cust <> l_cascade_cust
         THEN
            l_split := 'Y';
         END IF;
      END IF;

      pnp_debug_pkg.debug('    CacCldLoc> Row#: '||location_cursor%ROWCOUNT||', LocId: '||locn_rec.location_id
                          ||', LocCd: '||locn_rec.location_code
                          ||', Type: '||locn_rec.location_type_lookup_code
                          ||', Split: '||l_split);
      pnp_debug_pkg.debug('    CacCldLoc>   ActStrDate    : '||TO_CHAR(locn_rec.active_start_date, 'MM/DD/YYYY')
                          ||', ActEndDate    : '||TO_CHAR(locn_rec.active_end_date, 'MM/DD/YYYY'));

      IF l_split = 'Y' THEN
         pnt_locations_pkg.Set_RowId(locn_rec.location_id, locn_rec.active_start_date, locn_rec.active_end_date,
                                     x_return_status, x_return_message);

         IF locn_rec.active_start_date < p_start_date AND
            locn_rec.active_end_date > p_end_date THEN

            pnp_debug_pkg.debug('    CacCldLoc>   ... Case# 1: ActStrDt < pStrDt AND ActEndDt > pEndDt');
            IF x_return_status = 'S' THEN
               g_loc_recinfo_tmp := locn_rec;
               g_loc_recinfo_tmp.active_end_date := p_start_date-1;
               pnt_locations_pkg.Update_Locn_Row(g_loc_recinfo_tmp, NULL, p_change_mode, x_return_status, x_return_message);
            END IF;

            IF x_return_status = 'S' THEN
               g_loc_recinfo_tmp := locn_rec;
               g_loc_recinfo_tmp.active_start_date := p_start_date;
               g_loc_recinfo_tmp.active_end_date   := p_end_date;
               pnt_locations_pkg.Set_Null_Request_Program_Id;
               pnt_locations_pkg.Set_Cascade(p_cascade);
               pnt_locations_pkg.Insert_Locn_Row(g_loc_recinfo_tmp, NULL, p_change_mode, x_return_status, x_return_message);
            END IF;

            IF x_return_status = 'S' THEN
               g_loc_recinfo_tmp := locn_rec;
               g_loc_recinfo_tmp.active_start_date := p_end_date+1;
               pnt_locations_pkg.Set_Null_Request_Program_Id;
               pnt_locations_pkg.Insert_Locn_Row(g_loc_recinfo_tmp, NULL, p_change_mode, x_return_status, x_return_message);
            END IF;

         ELSIF locn_rec.active_start_date < p_start_date THEN

            pnp_debug_pkg.debug('    CacCldLoc>   ... Case# 2: ActStrDt < pStrDt');
            IF x_return_status = 'S' THEN
               g_loc_recinfo_tmp := locn_rec;
               g_loc_recinfo_tmp.active_end_date := p_start_date-1;
               pnt_locations_pkg.Update_Locn_Row(g_loc_recinfo_tmp, NULL, p_change_mode, x_return_status, x_return_message);
            END IF;

            IF x_return_status = 'S' THEN
               g_loc_recinfo_tmp := locn_rec;
               g_loc_recinfo_tmp.active_start_date := p_start_date;
               pnt_locations_pkg.Set_Null_Request_Program_Id;
               pnt_locations_pkg.Set_Cascade(p_cascade);
               pnt_locations_pkg.Insert_Locn_Row(g_loc_recinfo_tmp, NULL, p_change_mode, x_return_status, x_return_message);
            END IF;

         ELSIF locn_rec.active_end_date > p_end_date THEN

            pnp_debug_pkg.debug('    CacCldLoc>   ... Case# 3: ActEndDt > pEndDt');
            IF x_return_status = 'S' THEN
               g_loc_recinfo_tmp := locn_rec;
               g_loc_recinfo_tmp.active_end_date := p_end_date;
               pnt_locations_pkg.Set_Cascade(p_cascade);
               pnt_locations_pkg.Update_Locn_Row(g_loc_recinfo_tmp, NULL, p_change_mode, x_return_status, x_return_message);
            END IF;

            IF x_return_status = 'S' THEN
               g_loc_recinfo_tmp := locn_rec;
               g_loc_recinfo_tmp.active_start_date :=  p_end_date+1;
               pnt_locations_pkg.Set_Null_Request_Program_Id;
               pnt_locations_pkg.Insert_Locn_Row(g_loc_recinfo_tmp, NULL, p_change_mode, x_return_status, x_return_message);
            END IF;

         ELSE

            pnp_debug_pkg.debug('    CacCldLoc>   ... Case# 4: ActStrDt >= pStrDt AND ActEndDt <= pEndDt');
            IF x_return_status = 'S' THEN
               g_loc_recinfo_tmp := locn_rec;
               pnt_locations_pkg.Set_Cascade(p_cascade);
               pnt_locations_pkg.Update_Locn_Row(g_loc_recinfo_tmp, NULL, p_change_mode, x_return_status, x_return_message);
            END IF;

         END IF;
      END IF;

   END LOOP;

   IF x_return_status IS NULL THEN
      x_return_status := fnd_api.g_ret_sts_success;
   END IF;

   pnp_debug_pkg.debug('PNT_LOCATIONS_PKG.Cascade_Child_Locn (-) ReturnStatus: '||x_return_status);

END Cascade_Child_Locn;


-----------------------------------------------------------------------
-- PROCEDURE : Check_Locn_Assgn
-- PURPOSE   : This Function returns TRUE when there exists either of any
--             of employee, cost center, customer assignments of location
--             depending on the parameter Assignable Mode (p_asgn_mode).
-- IN PARAM  :
-- History   :
--  01-DEC-2004 Satish Tripathi o Created for Portfolio Status Enh BUG# 4030816.
-----------------------------------------------------------------------
FUNCTION Check_Locn_Assgn (
                          p_location_id                   IN  NUMBER
                         ,p_location_type                 IN  VARCHAR2
                         ,p_str_date                      IN  DATE
                         ,p_end_date                      IN  DATE
                         ,p_asgn_mode                     IN  VARCHAR2
                         )
RETURN BOOLEAN
IS
   l_exists                        BOOLEAN;
   l_asgn_exists                   VARCHAR2(30) := 'FALSE';
   l_str_date                      DATE;
   l_end_date                      DATE;

   --Modified the cursor for Bug 6827603
   CURSOR check_assign_csr IS
      SELECT 'TRUE'
      FROM   DUAL
      WHERE  EXISTS (SELECT NULL
                     FROM   pn_space_assign_cust_all, (SELECT location_id loc_id
                                                       FROM   pn_locations_all
                                                       WHERE  active_start_date <= l_end_date
                                                       AND    active_end_date >= l_str_date
                                                       START WITH location_id = p_location_id
                                                       CONNECT BY PRIOR location_id = parent_location_id
                                                       UNION
                                                       SELECT -1 loc_id
                                                       FROM   DUAL) loc
                     WHERE  p_asgn_mode IN ('ALL', 'CUST')
                     AND    ((p_location_type IN ('OFFICE', 'SECTION') AND
                              location_id = p_location_id AND
                              loc.loc_id=-1) OR
                             (p_location_type NOT IN ('OFFICE', 'SECTION') AND
                              location_id =loc.loc_id))
                     AND    cust_assign_start_date <= l_end_date
                     AND    NVL(cust_assign_end_date, TO_DATE('12/31/4712','MM/DD/YYYY')) >= l_str_date)
      OR     EXISTS (SELECT NULL
                     FROM   pn_space_assign_emp_all, (SELECT location_id loc_id
                                                       FROM   pn_locations_all
                                                       WHERE  active_start_date <= l_end_date
                                                       AND    active_end_date >= l_str_date
                                                       START WITH location_id = p_location_id
                                                       CONNECT BY PRIOR location_id = parent_location_id
                                                       UNION
                                                       SELECT -1 loc_id
                                                       FROM   DUAL) loc
                     WHERE  p_asgn_mode IN ('ALL', 'EMP', 'CC')
                     AND    ((p_location_type IN ('OFFICE', 'SECTION') AND
                              location_id = p_location_id AND
                              loc.loc_id=-1) OR
                             (p_location_type NOT IN ('OFFICE', 'SECTION') AND
                              location_id =loc.loc_id))
                     AND    ((p_asgn_mode = 'ALL') OR
                             (p_asgn_mode = 'EMP' AND person_id IS NOT NULL) OR
                             (p_asgn_mode = 'CC' AND cost_center_code IS NOT NULL))
                     AND    emp_assign_start_date <= l_end_date
                     AND    NVL(emp_assign_end_date, TO_DATE('12/31/4712','MM/DD/YYYY')) >= l_str_date);

BEGIN

   pnp_debug_pkg.debug('PNT_LOCATIONS_PKG.Check_Locn_Assgn (+)');
   l_str_date := p_str_date;
   l_end_date := NVL(p_end_date, TO_DATE('12/31/4712','MM/DD/YYYY'));

   OPEN check_assign_csr;
   FETCH check_assign_csr INTO l_asgn_exists;
   CLOSE check_assign_csr;

   IF l_asgn_exists = 'TRUE' THEN
      l_exists := TRUE;
   ELSE
      l_exists := FALSE;
   END IF;

   pnp_debug_pkg.debug('PNT_LOCATIONS_PKG.Check_Locn_Assgn (-) l_exists: '||l_asgn_exists);

   RETURN l_exists;

END Check_Locn_Assgn;

-----------------------------------------------------------------------
-- PROCEDURE : Parent_Not_Occpble_Asgnble
-- PURPOSE   : This Function returns TRUE when Parent location is
--             not Occupiable or Emp/CC/Cust assignable depending on the
--             parameter Status Mode (p_status_mode).
-- IN PARAM  :
-- History   :
--  22-DEC-2004 Satish Tripathi o Created for Portfolio Status Enh BUG# 4030816.
-----------------------------------------------------------------------
FUNCTION Parent_Not_Occpble_Asgnble (
                          p_parent_location_id            IN  NUMBER
                         ,p_str_date                      IN  DATE
                         ,p_end_date                      IN  DATE
                         ,p_status_mode                   IN  VARCHAR2
                         )
RETURN BOOLEAN
IS
   l_exists                        BOOLEAN;
   l_loc_status                    VARCHAR2(30) := 'FALSE';
   l_str_date                      DATE;
   l_end_date                      DATE;

   CURSOR check_loc_status_csr IS
      SELECT 'TRUE'
      FROM   DUAL
      WHERE  EXISTS (SELECT NULL
                     FROM   pn_locations_all
                     WHERE  location_id = p_parent_location_id
                     AND    active_start_date <= l_end_date
                     AND    active_end_date >= l_str_date
                     AND    ((p_status_mode IN ('OCC') AND NVL(occupancy_status_code, 'Y') = 'N')
                             OR (p_status_mode IN ('EMP') AND NVL(assignable_emp, 'Y') = 'N')
                             OR (p_status_mode IN ('CC') AND NVL(assignable_cc, 'Y') = 'N')
                             OR (p_status_mode IN ('CUST') AND NVL(assignable_cust, 'Y') = 'N')));

BEGIN

   pnp_debug_pkg.debug('PNT_LOCATIONS_PKG.Parent_Not_Occpble_Asgnble (+) LocId:'||p_parent_location_id
                       ||', Mode: '||p_status_mode
                       ||', StrDt: '||TO_CHAR(p_str_date, 'MM/DD/YYYY')
                       ||', EndDt: '||TO_CHAR(p_end_date, 'MM/DD/YYYY'));
   l_str_date := p_str_date;
   l_end_date := NVL(p_end_date, TO_DATE('12/31/4712','MM/DD/YYYY'));

   IF p_status_mode IN ('OCC', 'EMP', 'CC', 'CUST') THEN
      OPEN check_loc_status_csr;
      FETCH check_loc_status_csr INTO l_loc_status;
      CLOSE check_loc_status_csr;

      IF l_loc_status = 'TRUE' THEN
         l_exists := TRUE;
      ELSE
         l_exists := FALSE;
      END IF;
   END IF;

   pnp_debug_pkg.debug('PNT_LOCATIONS_PKG.Parent_Not_Occpble_Asgnble (-) l_exists: '||l_loc_status);

   RETURN l_exists;

END Parent_Not_Occpble_Asgnble;


-------------------------------------------------------------------------------
-- PROCEDURE insert_row
-- DESCRIPTION  : inserts a row in pn_addresses_all
-- SCOPE        : PUBLIC
-- INVOKED FROM :
-- RETURNS      : NONE
-- HISTORY      :
-- 14-Feb-04 Kiran     o validate_gross_area will now be called for both
--                       Offices and Sections
-- 01-DEC-04 STripathi o Modified for Portfolio Status Enh BUG# 4030816.
--                       Added parameters occupancy_status_code,
--                       assignable_emp, assignable_cc, assignable_cust,
--                       disposition, acc_treatment.
-- 28-APR-05  piagrawa o Modified the select statements to retrieve values
--                       from pn_locations_all instead of pn_locations
--                       Also passed org_id as parameter to
--                       PNT_ADDR_PKG.insert_row
-- 19-JUL-05 SatyaDeep o Added argument x_source to insert the source
--                       product from pn_locations_itf for bug#4468893
-- 28-NOV-05  pikhar   o fetched org_id using cursor
-- 21-AUG-08  rthumma  o Bug 7273859 : Modified call to pnt_addr_pkg.insert_row
--                       to pass NULL for ATTRIBUTE_CATEGORY,attribute1..15
-------------------------------------------------------------------------------
PROCEDURE insert_row (
                         x_rowid                   IN OUT NOCOPY rowid
                         ,x_org_id                  IN     NUMBER
                         ,x_LOCATION_ID             IN OUT NOCOPY NUMBER
                         ,x_LAST_UPDATE_DATE                DATE
                         ,x_LAST_UPDATED_BY                 NUMBER
                         ,x_CREATION_DATE                   DATE
                         ,x_CREATED_BY                      NUMBER
                         ,x_LAST_UPDATE_LOGIN               NUMBER
                         ,x_LOCATION_PARK_ID                NUMBER
                         ,x_LOCATION_TYPE_LOOKUP_CODE       VARCHAR2
                         ,x_SPACE_TYPE_LOOKUP_CODE          VARCHAR2
                         ,x_FUNCTION_TYPE_LOOKUP_CODE       VARCHAR2
                         ,x_STANDARD_TYPE_LOOKUP_CODE       VARCHAR2
                         ,x_LOCATION_ALIAS                  VARCHAR2
                         ,x_LOCATION_CODE                   VARCHAR2
                         ,x_BUILDING                        VARCHAR2
                         ,x_LEASE_OR_OWNED                  VARCHAR2
                         ,x_CLASS                           VARCHAR2
                         ,x_STATUS_TYPE                     VARCHAR2
                         ,x_FLOOR                           VARCHAR2
                         ,x_OFFICE                          VARCHAR2
                         ,x_ADDRESS_ID            IN OUT NOCOPY    NUMBER
                         ,x_MAX_CAPACITY                    NUMBER
                         ,x_OPTIMUM_CAPACITY                NUMBER
                         ,x_GROSS_AREA                      NUMBER
                         ,x_RENTABLE_AREA                   NUMBER
                         ,x_USABLE_AREA                     NUMBER
                         ,x_ASSIGNABLE_AREA                 NUMBER
                         ,x_COMMON_AREA                     NUMBER
                         ,x_SUITE                           VARCHAR2
                         ,x_ALLOCATE_COST_CENTER_CODE       VARCHAR2
                         ,x_UOM_CODE                        VARCHAR2
                         ,x_DESCRIPTION                     VARCHAR2
                         ,x_PARENT_LOCATION_ID              NUMBER
                         ,x_INTERFACE_FLAG                  VARCHAR2
                         ,x_REQUEST_ID                      NUMBER
                         ,x_PROGRAM_APPLICATION_ID          NUMBER
                         ,x_PROGRAM_ID                      NUMBER
                         ,x_PROGRAM_UPDATE_DATE             DATE
                         ,x_STATUS                          VARCHAR2
                         ,x_PROPERTY_ID                     NUMBER
                         ,x_ATTRIBUTE_CATEGORY              VARCHAR2
                         ,x_ATTRIBUTE1                      VARCHAR2
                         ,x_ATTRIBUTE2                      VARCHAR2
                         ,x_ATTRIBUTE3                      VARCHAR2
                         ,x_ATTRIBUTE4                      VARCHAR2
                         ,x_ATTRIBUTE5                      VARCHAR2
                         ,x_ATTRIBUTE6                      VARCHAR2
                         ,x_ATTRIBUTE7                      VARCHAR2
                         ,x_ATTRIBUTE8                      VARCHAR2
                         ,x_ATTRIBUTE9                      VARCHAR2
                         ,x_ATTRIBUTE10                     VARCHAR2
                         ,x_ATTRIBUTE11                     VARCHAR2
                         ,x_ATTRIBUTE12                     VARCHAR2
                         ,x_ATTRIBUTE13                     VARCHAR2
                         ,x_ATTRIBUTE14                     VARCHAR2
                         ,x_ATTRIBUTE15                     VARCHAR2
                         ,x_address_line1                  VARCHAR2
                         ,x_address_line2                  VARCHAR2
                         ,x_address_line3                  VARCHAR2
                         ,x_address_line4                  VARCHAR2
                         ,x_county                         VARCHAR2
                         ,x_city                           VARCHAR2
                         ,x_state                          VARCHAR2
                         ,x_province                       VARCHAR2
                         ,x_zip_code                       VARCHAR2
                         ,x_country                        VARCHAR2
                         ,x_territory_id                   NUMBER
                         ,x_addr_last_update_date          DATE
                         ,x_addr_last_updated_by           NUMBER
                         ,x_addr_creation_date             DATE
                         ,x_addr_created_by                NUMBER
                         ,x_addr_last_update_login         NUMBER
                         ,x_addr_attribute_category        VARCHAR2
                         ,x_addr_attribute1                VARCHAR2
                         ,x_addr_attribute2                VARCHAR2
                         ,x_addr_attribute3                VARCHAR2
                         ,x_addr_attribute4                VARCHAR2
                         ,x_addr_attribute5                VARCHAR2
                         ,x_addr_attribute6                VARCHAR2
                         ,x_addr_attribute7                VARCHAR2
                         ,x_addr_attribute8                VARCHAR2
                         ,x_addr_attribute9                VARCHAR2
                         ,x_addr_attribute10               VARCHAR2
                         ,x_addr_attribute11               VARCHAR2
                         ,x_addr_attribute12               VARCHAR2
                         ,x_addr_attribute13               VARCHAR2
                         ,x_addr_attribute14               VARCHAR2
                         ,x_addr_attribute15               VARCHAR2
                         ,x_common_area_flag               VARCHAR2
                         ,x_active_start_date              DATE
                         ,x_active_end_date                DATE
                         ,x_return_status                  OUT NOCOPY VARCHAR2
                         ,x_return_message                 OUT NOCOPY VARCHAR2
                         ,x_bookable_flag                  VARCHAR2
                         ,x_change_mode                    VARCHAR2
                         ,x_occupancy_status_code          VARCHAR2
                         ,x_assignable_emp                 VARCHAR2
                         ,x_assignable_cc                  VARCHAR2
                         ,x_assignable_cust                VARCHAR2
                         ,x_disposition_code               VARCHAR2
                         ,x_acc_treatment_code             VARCHAR2
                         ,x_source                         VARCHAR2
                        )
IS

   CURSOR c IS
      SELECT ROWID
      FROM   pn_locations_all
      WHERE  location_id = x_location_id
      AND    active_start_date = NVL(x_active_start_date, g_start_of_time)
      AND    active_end_date = NVL(x_active_end_date, g_end_of_time);

   l_return_status      VARCHAR2(2000) := NULL;
   l_return_message     VARCHAR2(32767) := NULL;
   l_sqlerrm            VARCHAR2(2000);

BEGIN
   pnp_debug_pkg.debug('PNT_LOCATIONS_PKG.insert_row (+) LocId: '||x_location_id||', LocCd: '||x_location_code
                       ||', Type: '||x_location_type_lookup_code
                       ||', ActStrDt: '||TO_CHAR(x_active_start_date, 'MM/DD/YYYY')
                       ||', ActEndDt: '||TO_CHAR(x_active_end_date, 'MM/DD/YYYY'));
   x_return_status := fnd_api.g_ret_sts_success;

   -----------------------------------------------------------------
   -- Call CHECK_UNIQUE_LOCATION_ALIAS to check if the location alias
   -- is unique.
   -----------------------------------------------------------------
   l_return_status        := NULL;
   PNT_LOCATIONS_PKG.check_unique_location_alias ( l_return_status,
                                                   x_location_id,
                                                   x_parent_location_id,
                                                   x_location_type_lookup_code,
                                                   x_location_alias,
                                                   x_active_start_date,
                                                   x_active_end_date,
                                                   x_org_id);
   IF (l_return_status IS NOT NULL) THEN
     pnp_debug_pkg.put_log_msg('Error in unique_location_alias');
     APP_EXCEPTION.Raise_Exception;
   END IF;

   -----------------------------------------------------------------
   -- Call CHECK_UNIQUE_LOCATION_CODE to check if the location code
   -- is unique.
   -----------------------------------------------------------------
   l_return_status        := NULL;
   check_unique_location_code (
                             l_return_status
                            ,x_location_id
                            ,x_location_code
                            ,x_active_start_date
                            ,x_active_end_date
                            ,x_org_id);
   IF (l_return_status IS NOT NULL) THEN
     pnp_debug_pkg.put_log_msg('Error in unique_location_code');
     APP_EXCEPTION.Raise_Exception;
   END IF;

   IF x_location_type_lookup_code IN ('OFFICE', 'SECTION') AND
   x_rentable_area IS NOT NULL THEN

     IF NOT pnt_locations_pkg.validate_gross_area(x_parent_location_id,
                                                x_rentable_area,
                                                x_location_type_lookup_code,
                                                x_active_start_date,
                                                x_active_end_date) THEN

      fnd_message.set_name('PN', 'PN_GROSS_RENTABLE');
      app_exception.raise_Exception;
     END IF;
   END IF;

   -- Check for location overlap in insert row

   l_return_status        := NULL;

   IF NVL(x_change_mode,'X') not in ('UPDATE') THEN
       PNT_LOCATIONS_PKG.check_location_overlap (
                     p_org_id                    => x_org_id,
                     p_location_id               => NULL,
                     p_location_code             => x_location_code,
                     p_location_type_lookup_code => x_location_type_lookup_code,
                     p_active_start_date         => x_active_start_date,
                     p_active_end_date           => NVL(x_active_end_date,G_END_OF_TIME),
                     p_active_start_date_old     => null,
                     p_active_end_date_old       => null,
                     x_return_status             => l_return_status,
                     x_return_message            => l_return_message);

       IF NOT ( l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         pnp_debug_pkg.debug('    InsRow> Error in check_location_overlap ');
         APP_EXCEPTION.Raise_Exception;
       END IF;

   END IF; -- x_change_mode

   l_return_status        := NULL;

   IF NOT (NVL(x_LOCATION_TYPE_LOOKUP_CODE, ' ') IN ('OFFICE', 'SECTION'))
      and NVL(x_change_mode,'X') not in ('UPDATE') THEN

         PNT_LOCATIONS_PKG.check_location_gaps  (
             p_org_id                => x_org_id,
             p_location_id           => null,
             p_location_code         => x_location_code,
             p_location_type_lookup_code => x_location_type_lookup_code,
             p_active_start_date     => x_active_start_date,
             p_active_end_date       => x_active_end_date,
             p_active_start_date_old => null,
             p_active_end_date_old   => null,
             x_return_status         => l_return_status,
             x_return_message        => l_return_message);

          IF NOT ( l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
             APP_EXCEPTION.Raise_Exception;
          END IF;

   END IF; -- x_LOCATION_TYPE_LOOKUP_CODE

   -----------------------------------------------------------------
   -- Call the PN_ADDRESSES insert table handler to create an address
   -- row and also return the address_id (OUT parameter) for
   -- PN_LOCATIONS table.  This will only be called when we insert the
   -- building record.
   -----------------------------------------------------------------

  pnp_debug_pkg.put_log_msg('Calling address insert address =' || x_address_id);
   IF (NVL(x_LOCATION_TYPE_LOOKUP_CODE, ' ') IN ('BUILDING','LAND'))
      AND x_address_id is null THEN
      PNT_ADDR_PKG.insert_row (
                                    x_address_id,
                                    x_address_line1,
                                    x_address_line2,
                                    x_address_line3,
                                    x_address_line4,
                                    x_county,
                                    x_city,
                                    x_state,
                                    x_province,
                                    x_zip_code,
                                    x_country,
                                    x_territory_id,
                                    x_last_update_date,
                                    x_last_updated_by,
                                    x_creation_date,
                                    x_created_by,
                                    x_last_update_login,
                                    null,
                                    null,
                                    null,
                                    null,
                                    null,
                                    null,
                                    null,
                                    null,
                                    null,
                                    null,
                                    null,
                                    null,
                                    null,
                                    null,
                                    null,
                                    null,
                                    x_addr_attribute_category,
                                    x_addr_attribute1,
                                    x_addr_attribute2,
                                    x_addr_attribute3,
                                    x_addr_attribute4,
                                    x_addr_attribute5,
                                    x_addr_attribute6,
                                    x_addr_attribute7,
                                    x_addr_attribute8,
                                    x_addr_attribute9,
                                    x_addr_attribute10,
                                    x_addr_attribute11,
                                    x_addr_attribute12,
                                    x_addr_attribute13,
                                    x_addr_attribute14,
                                    x_addr_attribute15,
                                    x_org_id
                                    );
   END IF;

   -----------------------------------------------------------------
   -- Allocate the sequence to the primary key loction_id
   -- Do not get a new location_id in case of UPDATE
   -----------------------------------------------------------------
   IF x_change_mode IS NULL and x_location_id is null THEN
      SELECT pn_locations_s.NEXTVAL
      INTO   x_location_id
      FROM   DUAL;
   END IF;

   pnp_debug_pkg.debug('    InsRow> before insert' || x_change_mode);
   BEGIN
      INSERT INTO pn_locations_all (
             LOCATION_ID
            ,LAST_UPDATE_DATE
            ,LAST_UPDATED_BY
            ,CREATION_DATE
            ,CREATED_BY
            ,LAST_UPDATE_LOGIN
            ,LOCATION_PARK_ID
            ,LOCATION_TYPE_LOOKUP_CODE
            ,SPACE_TYPE_LOOKUP_CODE
            ,FUNCTION_TYPE_LOOKUP_CODE
            ,STANDARD_TYPE_LOOKUP_CODE
            ,LOCATION_ALIAS
            ,LOCATION_CODE
            ,BUILDING
            ,LEASE_OR_OWNED
            ,CLASS
            ,STATUS_TYPE
            ,FLOOR
            ,OFFICE
            ,ADDRESS_ID
            ,MAX_CAPACITY
            ,OPTIMUM_CAPACITY
            ,GROSS_AREA
            ,RENTABLE_AREA
            ,USABLE_AREA
            ,ASSIGNABLE_AREA
            ,COMMON_AREA
            ,SUITE
            ,ALLOCATE_COST_CENTER_CODE
            ,UOM_CODE
            ,DESCRIPTION
            ,PARENT_LOCATION_ID
            ,INTERFACE_FLAG
            ,REQUEST_ID
            ,PROGRAM_APPLICATION_ID
            ,PROGRAM_ID
            ,PROGRAM_UPDATE_DATE
            ,STATUS
            ,PROPERTY_ID
            ,ATTRIBUTE_CATEGORY
            ,ATTRIBUTE1
            ,ATTRIBUTE2
            ,ATTRIBUTE3
            ,ATTRIBUTE4
            ,ATTRIBUTE5
            ,ATTRIBUTE6
            ,ATTRIBUTE7
            ,ATTRIBUTE8
            ,ATTRIBUTE9
            ,ATTRIBUTE10
            ,ATTRIBUTE11
            ,ATTRIBUTE12
            ,ATTRIBUTE13
            ,ATTRIBUTE14
            ,ATTRIBUTE15
            ,COMMON_AREA_FLAG
            ,ORG_ID
            ,ACTIVE_START_DATE
            ,ACTIVE_END_DATE
            ,BOOKABLE_FLAG
            ,occupancy_status_code
            ,assignable_emp
            ,assignable_cc
            ,assignable_cust
            ,disposition_code
            ,acc_treatment_code
            ,source
            )
      VALUES
            (
             x_LOCATION_ID
            ,x_LAST_UPDATE_DATE
            ,x_LAST_UPDATED_BY
            ,x_CREATION_DATE
            ,x_CREATED_BY
            ,x_LAST_UPDATE_LOGIN
            ,x_LOCATION_PARK_ID
            ,x_LOCATION_TYPE_LOOKUP_CODE
            ,x_SPACE_TYPE_LOOKUP_CODE
            ,x_FUNCTION_TYPE_LOOKUP_CODE
            ,x_STANDARD_TYPE_LOOKUP_CODE
            ,x_LOCATION_ALIAS
            ,x_LOCATION_CODE
            ,x_BUILDING
            ,x_LEASE_OR_OWNED
            ,x_CLASS
            ,x_STATUS_TYPE
            ,x_FLOOR
            ,x_OFFICE
            ,x_ADDRESS_ID
            ,x_MAX_CAPACITY
            ,x_OPTIMUM_CAPACITY
            ,x_GROSS_AREA
            ,x_RENTABLE_AREA
            ,x_USABLE_AREA
            ,x_ASSIGNABLE_AREA
            ,x_COMMON_AREA
            ,x_SUITE
            ,x_ALLOCATE_COST_CENTER_CODE
            ,x_UOM_CODE
            ,x_DESCRIPTION
            ,x_PARENT_LOCATION_ID
            ,x_INTERFACE_FLAG
            ,x_REQUEST_ID
            ,x_PROGRAM_APPLICATION_ID
            ,x_PROGRAM_ID
            ,x_PROGRAM_UPDATE_DATE
            ,x_STATUS
            ,x_PROPERTY_ID
            ,x_ATTRIBUTE_CATEGORY
            ,x_ATTRIBUTE1
            ,x_ATTRIBUTE2
            ,x_ATTRIBUTE3
            ,x_ATTRIBUTE4
            ,x_ATTRIBUTE5
            ,x_ATTRIBUTE6
            ,x_ATTRIBUTE7
            ,x_ATTRIBUTE8
            ,x_ATTRIBUTE9
            ,x_ATTRIBUTE10
            ,x_ATTRIBUTE11
            ,x_ATTRIBUTE12
            ,x_ATTRIBUTE13
            ,x_ATTRIBUTE14
            ,x_ATTRIBUTE15
            ,x_COMMON_AREA_FLAG
            ,x_org_id
            ,x_ACTIVE_START_DATE
            ,NVL(x_ACTIVE_END_DATE,G_END_OF_TIME)
            ,x_bookable_flag
            ,x_occupancy_status_code
            ,x_assignable_emp
            ,x_assignable_cc
            ,x_assignable_cust
            ,x_disposition_code
            ,x_acc_treatment_code
            ,x_source
            );

      OPEN C;
         FETCH C INTO x_rowid;
         IF (C%NOTFOUND) THEN
            CLOSE C;
            pnp_debug_pkg.debug('    InsRow> Error in insert');
            RAISE NO_DATA_FOUND;
         END IF;
      CLOSE C;

   EXCEPTION
    WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       fnd_message.set_name('PN','PN_OTHERS_EXCEPTION');
       fnd_message.set_token('ERR_MSG',sqlerrm);
       pnp_debug_pkg.debug('    InsRow> Other errors');
       pnp_debug_pkg.debug(sqlerrm);
   END;

   pnp_debug_pkg.debug('PNT_LOCATIONS_PKG.insert_row (-) ReturnStatus: '||x_return_status);

END insert_row;

-------------------------------------------------------------------------------
-- PROCEDURE update_row
--
-- 14-Feb-04  Kiran     o validate_gross_area will now be called for both
--                        Offices and Sections
-- 01-DEC-04 STripathi  o Modified for Portfolio Status Enh BUG# 4030816.
--                        Added parameters occupancy_status_code,
--                        assignable_emp,assignable_cc, assignable_cust,
--                        disposition, acc_treatment.
-- 19-JUL-05 SatyaDeep  o Added argument x_source to update the source
--                        product from pn_locations_itf for bug#4468893
-- 12-SEP-05 Hareesha   o Modified update statement to include row_id
--                        in Where clause.
-- 27-feb-06 piagrawa   o Bug#5015429 - Modified to make a call to
--                        loctn_assgn_area_update when  x_assgn_area_chgd_flag
--                        is equal to 'CORRECT' or 'UPDATE'
-- 21-AUG-08  rthumma   o Bug 7273859 : Modified call to pnt_addr_pkg.update_row
--                        to pass NULL for ATTRIBUTE_CATEGORY,attribute1..15
-------------------------------------------------------------------------------
PROCEDURE UPDATE_ROW (
                          x_LOCATION_ID                     NUMBER
                         ,x_LAST_UPDATE_DATE                DATE
                         ,x_LAST_UPDATED_BY                 NUMBER
                         ,x_LAST_UPDATE_LOGIN               NUMBER
                         ,x_LOCATION_PARK_ID                NUMBER
                         ,x_LOCATION_TYPE_LOOKUP_CODE       VARCHAR2
                         ,x_SPACE_TYPE_LOOKUP_CODE          VARCHAR2
                         ,x_FUNCTION_TYPE_LOOKUP_CODE       VARCHAR2
                         ,x_STANDARD_TYPE_LOOKUP_CODE       VARCHAR2
                         ,x_BUILDING                        VARCHAR2
                         ,x_LEASE_OR_OWNED                  VARCHAR2
                         ,x_CLASS                           VARCHAR2
                         ,x_STATUS_TYPE                     VARCHAR2
                         ,x_FLOOR                           VARCHAR2
                         ,x_OFFICE                          VARCHAR2
                         ,x_ADDRESS_ID                      NUMBER
                         ,x_MAX_CAPACITY                    NUMBER
                         ,x_OPTIMUM_CAPACITY                NUMBER
                         ,x_GROSS_AREA                      NUMBER
                         ,x_RENTABLE_AREA                   NUMBER
                         ,x_USABLE_AREA                     NUMBER
                         ,x_ASSIGNABLE_AREA                 NUMBER
                         ,x_COMMON_AREA                     NUMBER
                         ,x_SUITE                           VARCHAR2
                         ,x_ALLOCATE_COST_CENTER_CODE       VARCHAR2
                         ,x_UOM_CODE                        VARCHAR2
                         ,x_DESCRIPTION                     VARCHAR2
                         ,x_PARENT_LOCATION_ID              NUMBER
                         ,x_INTERFACE_FLAG                  VARCHAR2
                         ,x_STATUS                          VARCHAR2
                         ,x_PROPERTY_ID                     NUMBER
                         ,x_ATTRIBUTE_CATEGORY              VARCHAR2
                         ,x_ATTRIBUTE1                      VARCHAR2
                         ,x_ATTRIBUTE2                      VARCHAR2
                         ,x_ATTRIBUTE3                      VARCHAR2
                         ,x_ATTRIBUTE4                      VARCHAR2
                         ,x_ATTRIBUTE5                      VARCHAR2
                         ,x_ATTRIBUTE6                      VARCHAR2
                         ,x_ATTRIBUTE7                      VARCHAR2
                         ,x_ATTRIBUTE8                      VARCHAR2
                         ,x_ATTRIBUTE9                      VARCHAR2
                         ,x_ATTRIBUTE10                     VARCHAR2
                         ,x_ATTRIBUTE11                     VARCHAR2
                         ,x_ATTRIBUTE12                     VARCHAR2
                         ,x_ATTRIBUTE13                     VARCHAR2
                         ,x_ATTRIBUTE14                     VARCHAR2
                         ,x_ATTRIBUTE15                     VARCHAR2
                         ,x_address_line1                  VARCHAR2
                         ,x_address_line2                  VARCHAR2
                         ,x_address_line3                  VARCHAR2
                         ,x_address_line4                  VARCHAR2
                         ,x_county                         VARCHAR2
                         ,x_city                           VARCHAR2
                         ,x_state                          VARCHAR2
                         ,x_province                       VARCHAR2
                         ,x_zip_code                       VARCHAR2
                         ,x_country                        VARCHAR2
                         ,x_territory_id                   NUMBER
                         ,x_addr_last_update_date          DATE
                         ,x_addr_last_updated_by           NUMBER
                         ,x_addr_last_update_login         NUMBER
                         ,x_addr_attribute_category        VARCHAR2
                         ,x_addr_attribute1                VARCHAR2
                         ,x_addr_attribute2                VARCHAR2
                         ,x_addr_attribute3                VARCHAR2
                         ,x_addr_attribute4                VARCHAR2
                         ,x_addr_attribute5                VARCHAR2
                         ,x_addr_attribute6                VARCHAR2
                         ,x_addr_attribute7                VARCHAR2
                         ,x_addr_attribute8                VARCHAR2
                         ,x_addr_attribute9                VARCHAR2
                         ,x_addr_attribute10               VARCHAR2
                         ,x_addr_attribute11               VARCHAR2
                         ,x_addr_attribute12               VARCHAR2
                         ,x_addr_attribute13               VARCHAR2
                         ,x_addr_attribute14               VARCHAR2
                         ,x_addr_attribute15               VARCHAR2
                         ,x_common_area_flag               VARCHAR2
                         ,x_assgn_area_chgd_flag           VARCHAR2
                         ,x_active_start_date              DATE
                         ,x_active_end_date                DATE
                         ,x_return_status             OUT NOCOPY  varchar2
                         ,x_return_message            OUT NOCOPY  varchar2
                         ,x_bookable_flag                  VARCHAR2
                         ,x_occupancy_status_code          VARCHAR2
                         ,x_assignable_emp                 VARCHAR2
                         ,x_assignable_cc                  VARCHAR2
                         ,x_assignable_cust                VARCHAR2
                         ,x_disposition_code               VARCHAR2
                         ,x_acc_treatment_code             VARCHAR2
                         ,x_source                         VARCHAR2
                     )
IS

    l_return_status      VARCHAR2(2000) := NULL;

BEGIN

   pnp_debug_pkg.debug('PNT_LOCATIONS_PKG.update_row (+) LocId: '||x_location_id||', Type: '||x_location_type_lookup_code
                       ||', ActStrDt: '||TO_CHAR(x_active_start_date, 'MM/DD/YYYY')
                       ||', ActEndDt: '||TO_CHAR(x_active_end_date, 'MM/DD/YYYY'));
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF x_location_type_lookup_code IN ('OFFICE', 'SECTION') AND
   x_rentable_area IS NOT NULL THEN
     IF NOT pnt_locations_pkg.validate_gross_area(x_location_id,
                                                x_rentable_area,
                                                x_location_type_lookup_code,
                                                x_active_start_date,
                                                x_active_end_date,
                                                'UPDATE') THEN

      fnd_message.set_name('PN', 'PN_GROSS_RENTABLE');
      app_exception.raise_Exception;
     END IF;
  END IF;

   IF x_assgn_area_chgd_flag IN ('CORRECT', 'UPDATE') THEN

      pnp_util_func.loctn_assgn_area_update(p_loc_id     => x_location_id
                                           ,p_assgn_area => x_assignable_area
                                           ,p_str_dt     => x_active_start_date
                                           ,p_end_dt     => x_active_end_date
                                           );
   END IF;

   pnp_debug_pkg.put_log_msg('update locations');

   UPDATE PN_LOCATIONS_ALL
   SET
             LAST_UPDATE_DATE                = x_LAST_UPDATE_DATE
            ,LAST_UPDATED_BY                 = x_LAST_UPDATED_BY
            ,LAST_UPDATE_LOGIN               = x_LAST_UPDATE_LOGIN
            ,LOCATION_PARK_ID                = x_LOCATION_PARK_ID
            ,LOCATION_TYPE_LOOKUP_CODE       = x_LOCATION_TYPE_LOOKUP_CODE
            ,SPACE_TYPE_LOOKUP_CODE          = x_SPACE_TYPE_LOOKUP_CODE
            ,FUNCTION_TYPE_LOOKUP_CODE       = x_FUNCTION_TYPE_LOOKUP_CODE
            ,STANDARD_TYPE_LOOKUP_CODE       = x_STANDARD_TYPE_LOOKUP_CODE
            ,BUILDING                        = x_BUILDING
            ,LEASE_OR_OWNED                  = x_LEASE_OR_OWNED
            ,CLASS                           = x_CLASS                     -- Added redwin
            ,STATUS_TYPE                     = x_STATUS_TYPE
            ,FLOOR                           = x_FLOOR
            ,OFFICE                          = x_OFFICE
            ,ADDRESS_ID                      = x_ADDRESS_ID
            ,MAX_CAPACITY                    = x_MAX_CAPACITY
            ,OPTIMUM_CAPACITY                = x_OPTIMUM_CAPACITY
            ,GROSS_AREA                      = x_GROSS_AREA
            ,RENTABLE_AREA                   = x_RENTABLE_AREA
            ,USABLE_AREA                     = x_USABLE_AREA
            ,ASSIGNABLE_AREA                 = x_ASSIGNABLE_AREA
            ,COMMON_AREA                     = x_COMMON_AREA
            ,SUITE                           = x_SUITE
            ,ALLOCATE_COST_CENTER_CODE       = x_ALLOCATE_COST_CENTER_CODE
            ,UOM_CODE                        = x_UOM_CODE
            ,DESCRIPTION                     = x_DESCRIPTION
            ,PARENT_LOCATION_ID              = x_PARENT_LOCATION_ID
            ,INTERFACE_FLAG                  = x_INTERFACE_FLAG
            ,STATUS                          = x_STATUS
            ,PROPERTY_ID                     = x_PROPERTY_ID
            ,ATTRIBUTE_CATEGORY              = x_ATTRIBUTE_CATEGORY
            ,ATTRIBUTE1                      = x_ATTRIBUTE1
            ,ATTRIBUTE2                      = x_ATTRIBUTE2
            ,ATTRIBUTE3                      = x_ATTRIBUTE3
            ,ATTRIBUTE4                      = x_ATTRIBUTE4
            ,ATTRIBUTE5                      = x_ATTRIBUTE5
            ,ATTRIBUTE6                      = x_ATTRIBUTE6
            ,ATTRIBUTE7                      = x_ATTRIBUTE7
            ,ATTRIBUTE8                      = x_ATTRIBUTE8
            ,ATTRIBUTE9                      = x_ATTRIBUTE9
            ,ATTRIBUTE10                     = x_ATTRIBUTE10
            ,ATTRIBUTE11                     = x_ATTRIBUTE11
            ,ATTRIBUTE12                     = x_ATTRIBUTE12
            ,ATTRIBUTE13                     = x_ATTRIBUTE13
            ,ATTRIBUTE14                     = x_ATTRIBUTE14
            ,ATTRIBUTE15                     = x_ATTRIBUTE15
            ,COMMON_AREA_FLAG                = x_COMMON_AREA_FLAG
            ,ACTIVE_START_DATE               = x_active_start_date
            ,ACTIVE_END_DATE                 = NVL(x_active_end_date,g_end_of_time)
            ,BOOKABLE_FLAG                   = x_bookable_flag
            ,occupancy_status_code           = x_occupancy_status_code
            ,assignable_emp                  = x_assignable_emp
            ,assignable_cc                   = x_assignable_cc
            ,assignable_cust                 = x_assignable_cust
            ,disposition_code                = x_disposition_code
            ,acc_treatment_code              = x_acc_treatment_code
            ,source                          = x_source
   WHERE ROWID = g_pn_locations_rowid;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   -----------------------------------------------------------------
   -- Call the PN_ADDRESSES update table handler to update address
   -- elements. This will only be called when we update the
   -- building record.
   -----------------------------------------------------------------
   IF NVL(x_LOCATION_TYPE_LOOKUP_CODE, ' ') IN ('BUILDING','LAND') THEN
      PNT_ADDR_PKG.update_row (
             x_address_id,
             x_address_line1,
             x_address_line2,
             x_address_line3,
             x_address_line4,
             x_county,
             x_city,
             x_state,
             x_province,
             x_zip_code,
             x_country,
             x_territory_id,
             x_last_update_date,
             x_last_updated_by,
             x_last_update_login,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             x_addr_attribute_category,
             x_addr_attribute1,
             x_addr_attribute2,
             x_addr_attribute3,
             x_addr_attribute4,
             x_addr_attribute5,
             x_addr_attribute6,
             x_addr_attribute7,
             x_addr_attribute8,
             x_addr_attribute9,
             x_addr_attribute10,
             x_addr_attribute11,
             x_addr_attribute12,
             x_addr_attribute13,
             x_addr_attribute14,
             x_addr_attribute15
             );
   END IF;

   pnp_debug_pkg.debug('PNT_LOCATIONS_PKG.update_row (-) ReturnStatus: '||x_return_status);

  EXCEPTION
  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     fnd_message.set_name('PN','PN_OTHERS_EXCEPTION');
     fnd_message.set_token('ERR_MSG',sqlerrm);
     pnp_debug_pkg.put_log_msg('OTHER ERRORS'|| sqlerrm);
END UPDATE_ROW;

------------------------------------------------------------------------
-- PROCEDURE :  lock_row
--  01-DEC-2004 Satish Tripathi o Modified for Portfolio Status Enh BUG# 4030816.
--                                Added parameters occupancy_status_code, assignable_emp,
--                                assignable_cc, assignable_cust, disposition, acc_treatment.
--  21-AUG-2008 rthumma         o Bug 7273859 : Modified call to pnt_addr_pkg.lock_row
--                                to pass NULL for ATTRIBUTE_CATEGORY,attribute1..15
------------------------------------------------------------------------
PROCEDURE lock_row (
                          x_LOCATION_ID                     NUMBER
                         ,x_LOCATION_PARK_ID                NUMBER
                         ,x_LOCATION_TYPE_LOOKUP_CODE       VARCHAR2
                         ,x_SPACE_TYPE_LOOKUP_CODE          VARCHAR2
                         ,x_FUNCTION_TYPE_LOOKUP_CODE       VARCHAR2
                         ,x_STANDARD_TYPE_LOOKUP_CODE       VARCHAR2
                         ,x_LOCATION_ALIAS                  VARCHAR2
                         ,x_LOCATION_CODE                   VARCHAR2
                         ,x_BUILDING                        VARCHAR2
                         ,x_LEASE_OR_OWNED                  VARCHAR2
                         ,x_CLASS                           VARCHAR2
                         ,x_STATUS_TYPE                     VARCHAR2
                         ,x_FLOOR                           VARCHAR2
                         ,x_OFFICE                          VARCHAR2
                         ,x_ADDRESS_ID                      NUMBER
                         ,x_MAX_CAPACITY                    NUMBER
                         ,x_OPTIMUM_CAPACITY                NUMBER
                         ,x_GROSS_AREA                      NUMBER
                         ,x_RENTABLE_AREA                   NUMBER
                         ,x_USABLE_AREA                     NUMBER
                         ,x_ASSIGNABLE_AREA                 NUMBER
                         ,x_COMMON_AREA                     NUMBER
                         ,x_SUITE                           VARCHAR2
                         ,x_ALLOCATE_COST_CENTER_CODE       VARCHAR2
                         ,x_UOM_CODE                        VARCHAR2
                         ,x_DESCRIPTION                     VARCHAR2
                         ,x_PARENT_LOCATION_ID              NUMBER
                         ,x_INTERFACE_FLAG                  VARCHAR2
                         ,x_STATUS                          VARCHAR2
                         ,x_PROPERTY_ID                     NUMBER
                         ,x_ATTRIBUTE_CATEGORY              VARCHAR2
                         ,x_ATTRIBUTE1                      VARCHAR2
                         ,x_ATTRIBUTE2                      VARCHAR2
                         ,x_ATTRIBUTE3                      VARCHAR2
                         ,x_ATTRIBUTE4                      VARCHAR2
                         ,x_ATTRIBUTE5                      VARCHAR2
                         ,x_ATTRIBUTE6                      VARCHAR2
                         ,x_ATTRIBUTE7                      VARCHAR2
                         ,x_ATTRIBUTE8                      VARCHAR2
                         ,x_ATTRIBUTE9                      VARCHAR2
                         ,x_ATTRIBUTE10                     VARCHAR2
                         ,x_ATTRIBUTE11                     VARCHAR2
                         ,x_ATTRIBUTE12                     VARCHAR2
                         ,x_ATTRIBUTE13                     VARCHAR2
                         ,x_ATTRIBUTE14                     VARCHAR2
                         ,x_ATTRIBUTE15                     VARCHAR2
                         ,x_address_line1                  VARCHAR2
                         ,x_address_line2                  VARCHAR2
                         ,x_address_line3                  VARCHAR2
                         ,x_address_line4                  VARCHAR2
                         ,x_county                         VARCHAR2
                         ,x_city                           VARCHAR2
                         ,x_state                          VARCHAR2
                         ,x_province                       VARCHAR2
                         ,x_zip_code                       VARCHAR2
                         ,x_country                        VARCHAR2
                         ,x_territory_id                   NUMBER
                         ,x_addr_attribute_category        VARCHAR2
                         ,x_addr_attribute1                VARCHAR2
                         ,x_addr_attribute2                VARCHAR2
                         ,x_addr_attribute3                VARCHAR2
                         ,x_addr_attribute4                VARCHAR2
                         ,x_addr_attribute5                VARCHAR2
                         ,x_addr_attribute6                VARCHAR2
                         ,x_addr_attribute7                VARCHAR2
                         ,x_addr_attribute8                VARCHAR2
                         ,x_addr_attribute9                VARCHAR2
                         ,x_addr_attribute10               VARCHAR2
                         ,x_addr_attribute11               VARCHAR2
                         ,x_addr_attribute12               VARCHAR2
                         ,x_addr_attribute13               VARCHAR2
                         ,x_addr_attribute14               VARCHAR2
                         ,x_addr_attribute15               VARCHAR2
                         ,x_common_area_flag               VARCHAR2
                         ,x_active_start_date              DATE
                         ,x_active_end_date                DATE
                         ,x_active_start_date_old          DATE
                         ,x_active_end_date_old            DATE
                         ,x_bookable_flag                  VARCHAR2
                         ,x_occupancy_status_code          VARCHAR2
                         ,x_assignable_emp                 VARCHAR2
                         ,x_assignable_cc                  VARCHAR2
                         ,x_assignable_cust                VARCHAR2
                         ,x_disposition_code               VARCHAR2
                         ,x_acc_treatment_code             VARCHAR2
                                        )
IS

   l_return_status varchar2(30);
   l_return_message varchar2(2000);


   CURSOR c IS
      SELECT *
      FROM   pn_locations_all
      WHERE  location_id = x_location_id
      AND    active_start_date = NVL(x_active_start_date_old, g_start_of_time)
      AND    active_end_date = NVL(x_active_end_date_old, g_end_of_time)
      FOR    UPDATE OF location_id NOWAIT;

BEGIN
   pnp_debug_pkg.debug('PNT_LOCATIONS_PKG.lock_row (+)');

   pnp_debug_pkg.debug('  LockRow=> In Parameters :: LocId: '||x_location_id
                       ||', Type: '||x_location_type_lookup_code);
   pnp_debug_pkg.debug('  LockRow=>   ActStrDate   : '||TO_CHAR(x_active_start_date, 'MM/DD/YYYY')
                       ||', ActEndDate   : '||TO_CHAR(x_active_end_date, 'MM/DD/YYYY'));
   pnp_debug_pkg.debug('  LockRow=>   ActStrDateOld: '||TO_CHAR(x_active_start_date_old, 'MM/DD/YYYY')
                       ||', ActEndDateOld: '||TO_CHAR(x_active_end_date_old, 'MM/DD/YYYY'));

   OPEN C;
      FETCH C INTO G_LOC_RECINFO;
      IF (C%NOTFOUND) THEN
         CLOSE C;
         FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
         APP_EXCEPTION.Raise_Exception;
      ELSE
         PNT_LOCATIONS_PKG.SET_ROWID(
            p_location_id => x_location_id,
            p_active_start_date => x_active_start_date_old,
            p_active_end_date => x_active_end_date_old,
            x_return_status    => l_return_status,
            x_return_message   => l_return_message);
      END IF;
   CLOSE C;

   IF NOT ((G_LOC_RECINFO.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
        OR ((G_LOC_RECINFO.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null))) THEN
        pn_var_rent_pkg.lock_row_exception('ATTRIBUTE_CATEGORY',G_LOC_RECINFO.ATTRIBUTE_CATEGORY);
   END IF;

   IF NOT ((G_LOC_RECINFO.ATTRIBUTE1 = X_ATTRIBUTE1)
        OR ((G_LOC_RECINFO.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null))) THEN
         pn_var_rent_pkg.lock_row_exception('ATTRIBUTE1', G_LOC_RECINFO.attribute1);
   END IF;

   IF NOT ((G_LOC_RECINFO.ATTRIBUTE2 = X_ATTRIBUTE2)
        OR ((G_LOC_RECINFO.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null))) THEN
         pn_var_rent_pkg.lock_row_exception('ATTRIBUTE2', G_LOC_RECINFO.attribute2);
   END IF;

   IF NOT ((G_LOC_RECINFO.ATTRIBUTE3 = X_ATTRIBUTE3)
        OR ((G_LOC_RECINFO.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null))) THEN
         pn_var_rent_pkg.lock_row_exception('ATTRIBUTE3', G_LOC_RECINFO.attribute3);
   END IF;

   IF NOT ((G_LOC_RECINFO.ATTRIBUTE4 = X_ATTRIBUTE4)
        OR ((G_LOC_RECINFO.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null))) THEN
         pn_var_rent_pkg.lock_row_exception('ATTRIBUTE4', G_LOC_RECINFO.attribute4);
   END IF;

   IF NOT ((G_LOC_RECINFO.ATTRIBUTE5 = X_ATTRIBUTE5)
        OR ((G_LOC_RECINFO.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null))) THEN
         pn_var_rent_pkg.lock_row_exception('ATTRIBUTE5', G_LOC_RECINFO.attribute5);
   END IF;

   IF NOT ((G_LOC_RECINFO.ATTRIBUTE6 = X_ATTRIBUTE6)
        OR ((G_LOC_RECINFO.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null))) THEN
         pn_var_rent_pkg.lock_row_exception('ATTRIBUTE6', G_LOC_RECINFO.attribute6);
   END IF;

   IF NOT ((G_LOC_RECINFO.ATTRIBUTE7 = X_ATTRIBUTE7)
        OR ((G_LOC_RECINFO.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null))) THEN
         pn_var_rent_pkg.lock_row_exception('ATTRIBUTE7', G_LOC_RECINFO.attribute7);
   END IF;

   IF NOT ((G_LOC_RECINFO.ATTRIBUTE8 = X_ATTRIBUTE8)
        OR ((G_LOC_RECINFO.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null))) THEN
         pn_var_rent_pkg.lock_row_exception('ATTRIBUTE8', G_LOC_RECINFO.attribute8);
   END IF;

   IF NOT ((G_LOC_RECINFO.ATTRIBUTE9 = X_ATTRIBUTE9)
        OR ((G_LOC_RECINFO.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null))) THEN
         pn_var_rent_pkg.lock_row_exception('ATTRIBUTE9', G_LOC_RECINFO.attribute9);
   END IF;

   IF NOT ((G_LOC_RECINFO.ATTRIBUTE10 = X_ATTRIBUTE10)
        OR ((G_LOC_RECINFO.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null))) THEN
         pn_var_rent_pkg.lock_row_exception('ATTRIBUTE10', G_LOC_RECINFO.attribute10);
   END IF;

   IF NOT ((G_LOC_RECINFO.ATTRIBUTE11 = X_ATTRIBUTE11)
        OR ((G_LOC_RECINFO.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null))) THEN
         pn_var_rent_pkg.lock_row_exception('ATTRIBUTE11', G_LOC_RECINFO.attribute11);
   END IF;

   IF NOT ((G_LOC_RECINFO.ATTRIBUTE12 = X_ATTRIBUTE12)
        OR ((G_LOC_RECINFO.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null))) THEN
         pn_var_rent_pkg.lock_row_exception('ATTRIBUTE12', G_LOC_RECINFO.attribute12);
   END IF;

   IF NOT ((G_LOC_RECINFO.ATTRIBUTE13 = X_ATTRIBUTE13)
        OR ((G_LOC_RECINFO.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null))) THEN
         pn_var_rent_pkg.lock_row_exception('ATTRIBUTE13', G_LOC_RECINFO.attribute13);
   END IF;

   IF NOT ((G_LOC_RECINFO.ATTRIBUTE14 = X_ATTRIBUTE14)
        OR ((G_LOC_RECINFO.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null))) THEN
         pn_var_rent_pkg.lock_row_exception('ATTRIBUTE14', G_LOC_RECINFO.attribute14);
   END IF;

   IF NOT ((G_LOC_RECINFO.ATTRIBUTE15 = X_ATTRIBUTE15)
        OR ((G_LOC_RECINFO.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null))) THEN
         pn_var_rent_pkg.lock_row_exception('ATTRIBUTE15', G_LOC_RECINFO.attribute15);
   END IF;

   IF NOT ((G_LOC_RECINFO.COMMON_AREA_FLAG = X_COMMON_AREA_FLAG)
        OR ((G_LOC_RECINFO.COMMON_AREA_FLAG is null) AND (X_COMMON_AREA_FLAG is null))) THEN
         pn_var_rent_pkg.lock_row_exception('COMMON_AREA_FLAG',G_LOC_RECINFO.COMMON_AREA_FLAG);
   END IF;

   IF NOT (G_LOC_RECINFO.LOCATION_TYPE_LOOKUP_CODE = X_LOCATION_TYPE_LOOKUP_CODE) THEN
         pn_var_rent_pkg.lock_row_exception('LOCATION_TYPE_LOOKUP_CODE',G_LOC_RECINFO.LOCATION_TYPE_LOOKUP_CODE);
   END IF;

   IF NOT ((G_LOC_RECINFO.FUNCTION_TYPE_LOOKUP_CODE = X_FUNCTION_TYPE_LOOKUP_CODE)
        OR ((G_LOC_RECINFO.FUNCTION_TYPE_LOOKUP_CODE is null) AND (X_FUNCTION_TYPE_LOOKUP_CODE is null))) THEN
         pn_var_rent_pkg.lock_row_exception('FUNCTION_TYPE_LOOKUP_CODE',G_LOC_RECINFO.FUNCTION_TYPE_LOOKUP_CODE);
   END IF;


   IF NOT ((G_LOC_RECINFO.SPACE_TYPE_LOOKUP_CODE = X_SPACE_TYPE_LOOKUP_CODE)
        OR ((G_LOC_RECINFO.SPACE_TYPE_LOOKUP_CODE is null) AND (X_SPACE_TYPE_LOOKUP_CODE is null))) THEN
          pn_var_rent_pkg.lock_row_exception('SPACE_TYPE_LOOKUP_CODE',G_LOC_RECINFO.SPACE_TYPE_LOOKUP_CODE);
   END IF;


   IF NOT ((G_LOC_RECINFO.STANDARD_TYPE_LOOKUP_CODE = X_STANDARD_TYPE_LOOKUP_CODE)
       OR ((G_LOC_RECINFO.STANDARD_TYPE_LOOKUP_CODE is null) AND (X_STANDARD_TYPE_LOOKUP_CODE is null))) THEN
          pn_var_rent_pkg.lock_row_exception('STANDARD_TYPE_LOOKUP_CODE',G_LOC_RECINFO.STANDARD_TYPE_LOOKUP_CODE);
   END IF;

   IF NOT (G_LOC_RECINFO.LOCATION_CODE = X_LOCATION_CODE) THEN
         pn_var_rent_pkg.lock_row_exception('LOCATION_CODE',G_LOC_RECINFO.LOCATION_CODE);
   END IF;

   IF NOT ((G_LOC_RECINFO.BUILDING = X_BUILDING)
        OR ((G_LOC_RECINFO.BUILDING is null) AND (X_BUILDING is null))) THEN
         pn_var_rent_pkg.lock_row_exception('BUILDING',G_LOC_RECINFO.BUILDING);
   END IF;

   IF NOT ((G_LOC_RECINFO.FLOOR = X_FLOOR)
        OR ((G_LOC_RECINFO.FLOOR is null) AND (X_FLOOR is null))) THEN
         pn_var_rent_pkg.lock_row_exception('FLOOR',G_LOC_RECINFO.FLOOR);
   END IF;

   IF NOT ((G_LOC_RECINFO.LOCATION_ALIAS = X_LOCATION_ALIAS)
        OR ((G_LOC_RECINFO.LOCATION_ALIAS is null) AND (X_LOCATION_ALIAS is null))) THEN
         pn_var_rent_pkg.lock_row_exception('LOCATION_ALIAS',G_LOC_RECINFO.LOCATION_ALIAS);
   END IF;

   IF NOT ((G_LOC_RECINFO.PROPERTY_ID = X_PROPERTY_ID)
        OR ((G_LOC_RECINFO.PROPERTY_ID is null) AND (X_PROPERTY_ID is null))) THEN
         pn_var_rent_pkg.lock_row_exception('PROPERTY_ID',G_LOC_RECINFO.PROPERTY_ID);
   END IF;

   IF NOT ((G_LOC_RECINFO.PARENT_LOCATION_ID = X_PARENT_LOCATION_ID)
        OR ((G_LOC_RECINFO.PARENT_LOCATION_ID is null) AND (X_PARENT_LOCATION_ID is null))) THEN
         pn_var_rent_pkg.lock_row_exception('PARENT_LOCATION_ID',G_LOC_RECINFO.PARENT_LOCATION_ID);
   END IF;

   IF NOT ((G_LOC_RECINFO.INTERFACE_FLAG = X_INTERFACE_FLAG)
        OR ((G_LOC_RECINFO.INTERFACE_FLAG is null) AND (X_INTERFACE_FLAG is null))) THEN
         pn_var_rent_pkg.lock_row_exception('INTERFACE_FLAG',G_LOC_RECINFO.INTERFACE_FLAG);
   END IF;

   IF NOT ((G_LOC_RECINFO.STATUS = X_STATUS)
        OR ((G_LOC_RECINFO.STATUS is null) AND (X_STATUS is null))) THEN
         pn_var_rent_pkg.lock_row_exception('STATUS',G_LOC_RECINFO.STATUS);
   END IF;


   IF NOT ((G_LOC_RECINFO.ACTIVE_START_DATE = x_ACTIVE_START_DATE)
        OR ((G_LOC_RECINFO.ACTIVE_START_DATE is null) AND (x_ACTIVE_START_DATE is null))) THEN
         pn_var_rent_pkg.lock_row_exception('ACTIVE_START_DATE',G_LOC_RECINFO.ACTIVE_START_DATE);
   END IF;

   IF NOT ((G_LOC_RECINFO.ACTIVE_END_DATE = x_ACTIVE_END_DATE)
        OR ((G_LOC_RECINFO.ACTIVE_END_DATE is null) AND (x_ACTIVE_END_DATE is null))) THEN
         pn_var_rent_pkg.lock_row_exception('ACTIVE_END_DATE',G_LOC_RECINFO.ACTIVE_END_DATE);
   END IF;

   -- DO SPECIAL CHECKS FOR PARTICULAR KINDS

   IF (NVL(x_LOCATION_TYPE_LOOKUP_CODE, ' ') IN ('BUILDING','LAND')) THEN
      IF NOT ((G_LOC_RECINFO.LOCATION_PARK_ID = X_LOCATION_PARK_ID)
           OR ((G_LOC_RECINFO.LOCATION_PARK_ID is null) AND (X_LOCATION_PARK_ID is null))) THEN
            pn_var_rent_pkg.lock_row_exception('LOCATION_PARK_ID',G_LOC_RECINFO.LOCATION_PARK_ID);
      END IF;

      IF NOT ((G_LOC_RECINFO.LEASE_OR_OWNED = X_LEASE_OR_OWNED)
           OR ((G_LOC_RECINFO.LEASE_OR_OWNED is null) AND (X_LEASE_OR_OWNED is null))) THEN
            pn_var_rent_pkg.lock_row_exception('LEASE_OR_OWNED',G_LOC_RECINFO.LEASE_OR_OWNED);
      END IF;

      IF NOT ((G_LOC_RECINFO.CLASS = X_CLASS)
           OR ((G_LOC_RECINFO.CLASS is null) AND (X_CLASS is null))) THEN
            pn_var_rent_pkg.lock_row_exception('CLASS',G_LOC_RECINFO.CLASS);
      END IF;

      IF NOT ((G_LOC_RECINFO.STATUS_TYPE = X_STATUS_TYPE)
           OR ((G_LOC_RECINFO.STATUS_TYPE is null) AND (X_STATUS_TYPE is null))) THEN
            pn_var_rent_pkg.lock_row_exception('STATUS_TYPE',G_LOC_RECINFO.STATUS_TYPE);
      END IF;

      IF NOT ((G_LOC_RECINFO.OFFICE = X_OFFICE)
           OR ((G_LOC_RECINFO.OFFICE is null) AND (X_OFFICE is null))) THEN
            pn_var_rent_pkg.lock_row_exception('OFFICE',G_LOC_RECINFO.OFFICE);
      END IF;

      IF NOT ((G_LOC_RECINFO.ADDRESS_ID = X_ADDRESS_ID)
           OR ((G_LOC_RECINFO.ADDRESS_ID is null) AND (X_ADDRESS_ID is null))) THEN
            pn_var_rent_pkg.lock_row_exception('ADDRESS_ID',G_LOC_RECINFO.ADDRESS_ID);
      END IF;

      IF NOT ((G_LOC_RECINFO.GROSS_AREA = X_GROSS_AREA)
           OR ((G_LOC_RECINFO.GROSS_AREA is null) AND (X_GROSS_AREA is null))) THEN
            pn_var_rent_pkg.lock_row_exception('GROSS_AREA',G_LOC_RECINFO.GROSS_AREA);
      END IF;

      IF NOT ((G_LOC_RECINFO.SUITE = X_SUITE)
           OR ((G_LOC_RECINFO.SUITE is null) AND (X_SUITE is null))) THEN
            pn_var_rent_pkg.lock_row_exception('SUITE',G_LOC_RECINFO.SUITE);
      END IF;

      IF NOT ((G_LOC_RECINFO.ALLOCATE_COST_CENTER_CODE = X_ALLOCATE_COST_CENTER_CODE)
           OR ((G_LOC_RECINFO.ALLOCATE_COST_CENTER_CODE is null) AND (X_ALLOCATE_COST_CENTER_CODE is null))) THEN
            pn_var_rent_pkg.lock_row_exception('ALLOCATE_COST_CENTER_CODE',G_LOC_RECINFO.ALLOCATE_COST_CENTER_CODE);
      END IF;

      IF NOT ((G_LOC_RECINFO.UOM_CODE = X_UOM_CODE)
           OR ((G_LOC_RECINFO.UOM_CODE is null) AND (X_UOM_CODE is null))) THEN
            pn_var_rent_pkg.lock_row_exception('UOM_CODE',G_LOC_RECINFO.UOM_CODE);
      END IF;

      IF NOT ((G_LOC_RECINFO.DESCRIPTION = X_DESCRIPTION)
           OR ((G_LOC_RECINFO.DESCRIPTION is null) AND (X_DESCRIPTION is null))) THEN
            pn_var_rent_pkg.lock_row_exception('DESCRIPTION',G_LOC_RECINFO.DESCRIPTION);
      END IF;

   ELSIF (NVL(x_LOCATION_TYPE_LOOKUP_CODE, ' ') IN ('OFFICE','SECTION')) THEN

      IF NOT ((G_LOC_RECINFO.OFFICE = X_OFFICE)
           OR ((G_LOC_RECINFO.OFFICE is null) AND (X_OFFICE is null))) THEN
            pn_var_rent_pkg.lock_row_exception('OFFICE',G_LOC_RECINFO.OFFICE);
      END IF;

      IF NOT ((G_LOC_RECINFO.MAX_CAPACITY = X_MAX_CAPACITY)
           OR ((G_LOC_RECINFO.MAX_CAPACITY is null) AND (X_MAX_CAPACITY is null))) THEN
            pn_var_rent_pkg.lock_row_exception('MAX_CAPACITY',G_LOC_RECINFO.MAX_CAPACITY);
      END IF;

      IF NOT ((G_LOC_RECINFO.OPTIMUM_CAPACITY = X_OPTIMUM_CAPACITY)
           OR ((G_LOC_RECINFO.OPTIMUM_CAPACITY is null) AND (X_OPTIMUM_CAPACITY is null))) THEN
            pn_var_rent_pkg.lock_row_exception('OPTIMUM_CAPACITY',G_LOC_RECINFO.OPTIMUM_CAPACITY);
      END IF;

      IF NOT ((G_LOC_RECINFO.RENTABLE_AREA = X_RENTABLE_AREA)
           OR ((G_LOC_RECINFO.RENTABLE_AREA is null) AND (X_RENTABLE_AREA is null))) THEN
            pn_var_rent_pkg.lock_row_exception('RENTABLE_AREA',G_LOC_RECINFO.RENTABLE_AREA);
      END IF;

      IF NOT ((G_LOC_RECINFO.USABLE_AREA = X_USABLE_AREA)
           OR ((G_LOC_RECINFO.USABLE_AREA is null) AND (X_USABLE_AREA is null))) THEN
            pn_var_rent_pkg.lock_row_exception('USABLE_AREA',G_LOC_RECINFO.USABLE_AREA);
      END IF;

      IF NOT ((G_LOC_RECINFO.ASSIGNABLE_AREA = X_ASSIGNABLE_AREA)
           OR ((G_LOC_RECINFO.ASSIGNABLE_AREA is null) AND (X_ASSIGNABLE_AREA is null))) THEN
            pn_var_rent_pkg.lock_row_exception('ASSIGNABLE_AREA',G_LOC_RECINFO.ASSIGNABLE_AREA);
      END IF;

      IF NOT ((G_LOC_RECINFO.COMMON_AREA = X_COMMON_AREA)
           OR ((G_LOC_RECINFO.COMMON_AREA is null) AND (X_COMMON_AREA is null))) THEN
            pn_var_rent_pkg.lock_row_exception('COMMON_AREA',G_LOC_RECINFO.COMMON_AREA);
      END IF;

      IF NOT ((G_LOC_RECINFO.SUITE = X_SUITE)
           OR ((G_LOC_RECINFO.SUITE is null) AND (X_SUITE is null))) THEN
            pn_var_rent_pkg.lock_row_exception('SUITE',G_LOC_RECINFO.SUITE);
      END IF;

      IF NOT ((G_LOC_RECINFO.BOOKABLE_FLAG = X_BOOKABLE_FLAG)
        OR ((G_LOC_RECINFO.BOOKABLE_FLAG is null) AND (X_BOOKABLE_FLAG is null))) THEN
         pn_var_rent_pkg.lock_row_exception('BOOKABLE_FLAG', G_LOC_RECINFO.BOOKABLE_FLAG);
      END IF;

      IF NOT ((g_loc_recinfo.occupancy_status_code = x_occupancy_status_code)
        OR ((g_loc_recinfo.occupancy_status_code IS NULL) AND (x_occupancy_status_code IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('OCCUPANCY_STATUS_CODE', g_loc_recinfo.occupancy_status_code);
      END IF;

      IF NOT ((g_loc_recinfo.assignable_emp = x_assignable_emp)
        OR ((g_loc_recinfo.assignable_emp IS NULL) AND (x_assignable_emp IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('ASSIGNABLE_EMP', g_loc_recinfo.assignable_emp);
      END IF;

      IF NOT ((g_loc_recinfo.assignable_cc = x_assignable_cc)
        OR ((g_loc_recinfo.assignable_cc IS NULL) AND (x_assignable_cc IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('ASSIGNABLE_CC', g_loc_recinfo.assignable_cc);
      END IF;

      IF NOT ((g_loc_recinfo.assignable_cust = x_assignable_cust)
        OR ((g_loc_recinfo.assignable_cust IS NULL) AND (x_assignable_cust IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('ASSIGNABLE_CUST', g_loc_recinfo.assignable_cust);
      END IF;

      IF NOT ((g_loc_recinfo.disposition_code = x_disposition_code)
        OR ((g_loc_recinfo.disposition_code IS NULL) AND (x_disposition_code IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('DISPOSITION_CODE', g_loc_recinfo.disposition_code);
      END IF;

      IF NOT ((g_loc_recinfo.acc_treatment_code = x_acc_treatment_code)
        OR ((g_loc_recinfo.acc_treatment_code IS NULL) AND (x_acc_treatment_code IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('ACC_TREATMENT_CODE', g_loc_recinfo.acc_treatment_code);
      END IF;

   END IF;

   -- NO SPECIAL CHECKS FOR TYPE 'LAND' AND 'PARCEL'

   -----------------------------------------------------------------
   -- Call the PN_ADDRESSES lock table handler to lock the address
   -- row for update. This will only be called when we lock the
   -- building record.
   -----------------------------------------------------------------
   IF (NVL(x_LOCATION_TYPE_LOOKUP_CODE, ' ') IN ('BUILDING','LAND')) THEN
      PNT_ADDR_PKG.LOCK_ROW(
                                                                x_address_id,
                                                                x_address_line1,
                                                                x_address_line2,
                                                                x_address_line3,
                                                                x_address_line4,
                                                                x_county,
                                                                x_city,
                                                                x_state,
                                                                x_province,
                                                                x_zip_code,
                                                                x_country,
                                                                x_territory_id,
                                                                null,
                                                                null,
                                                                null,
                                                                null,
                                                                null,
                                                                null,
                                                                null,
                                                                null,
                                                                null,
                                                                null,
                                                                null,
                                                                null,
                                                                null,
                                                                null,
                                                                null,
                                                                null,
                                                                x_addr_attribute_category,
                                                                x_addr_attribute1,
                                                                x_addr_attribute2,
                                                                x_addr_attribute3,
                                                                x_addr_attribute4,
                                                                x_addr_attribute5,
                                                                x_addr_attribute6,
                                                                x_addr_attribute7,
                                                                x_addr_attribute8,
                                                                x_addr_attribute9,
                                                                x_addr_attribute10,
                                                                x_addr_attribute11,
                                                                x_addr_attribute12,
                                                                x_addr_attribute13,
                                                                x_addr_attribute14,
                                                                x_addr_attribute15
                                                                );

   END IF;

   pnp_debug_pkg.debug('PNT_LOCATIONS_PKG.lock_row (-)');

END lock_row;

-------------------------------------------------------------------------------
-- PROCEDURE : update_child_for_dates
-- PURPOSE   : This procedure updates or deletes children locations during
--             bring in process.
-- IN PARAMS : Location Id, Active Start Date, Active End Date,
--             Active Start Date Old, Active End Date Old, Location Type
--             Lookup Code.
-- HISTORY :
--
-- 11-NOV-02 Ganesh  o Created.
-- 18-FEB-03 MMisra  o Added p_location_type_lookup_code new IN parameter.
--                     Changed the procedure to check for tenancy defined
--                     at lease.
-- 13-JUL-05  hrodda o Bug 4284035 - Replaced pn_space_assign_emp,
--                     pn_space_assign_cust with _ALL  table.
-------------------------------------------------------------------------------
PROCEDURE Update_Child_for_Dates (
                                p_location_id                   IN NUMBER
                               ,p_active_start_date             IN DATE
                               ,p_active_end_date               IN DATE
                               ,p_active_start_date_old         IN DATE
                               ,p_active_end_date_old           IN DATE
                               ,p_location_type_lookup_code     IN VARCHAR2
                               ,x_return_status                 OUT NOCOPY VARCHAR2
                               ,x_return_message                OUT NOCOPY VARCHAR2
                               )
IS

   CURSOR check_tenancy IS
      SELECT 'Y'
      FROM   pn_tenancies_all pt
      WHERE  location_id IN (SELECT location_id
                             FROM   pn_locations_all
                             WHERE  active_start_date > p_active_end_date
                             START WITH location_id = p_location_id
                             CONNECT BY PRIOR location_id = parent_location_id)
      AND NOT EXISTS (SELECT '1'
                      FROM   pn_locations_all pl1
                      where  pl1.location_id = pt.location_id
                      AND    active_start_date <= p_active_end_date)
      AND ROWNUM < 2;

   CURSOR check_start_tenancy IS
      SELECT 'Y'
      FROM   pn_tenancies_all pt
      WHERE  location_id IN (SELECT location_id
                             FROM   pn_locations_all
                             WHERE active_end_date < p_active_start_date
                             START WITH location_id = p_location_id
                             CONNECT BY PRIOR location_id = parent_location_id)
      AND NOT EXISTS (SELECT '1'
                      FROM   pn_locations_all pl1
                      WHERE  pl1.location_id = pt.location_id
                      AND    active_end_date >= p_active_start_date)
      AND ROWNUM < 2;

   l_exists    VARCHAR2(1) := 'N';

BEGIN

   pnp_debug_pkg.debug('PNT_LOCATIONS_PKG.update_child_for_dates (+)');
   pnp_debug_pkg.debug('  UpdChiDt=> In Parameters :: p_location_id: '||p_location_id);
   pnp_debug_pkg.debug('  UpdChiDt=>   p_active_start_date    : '||TO_CHAR(p_active_start_date, 'MM/DD/YYYY')
                       ||', p_active_end_date    : '||TO_CHAR(p_active_end_date, 'MM/DD/YYYY'));
   pnp_debug_pkg.debug('  UpdChiDt=>   p_active_start_date_old: '||TO_CHAR(p_active_start_date_old, 'MM/DD/YYYY')
                       ||', p_active_end_date_old: '||TO_CHAR(p_active_end_date_old, 'MM/DD/YYYY'));

   IF p_active_end_date < p_active_end_date_old AND
      p_location_type_lookup_code NOT IN ('OFFICE','SECTION')THEN

      l_exists := 'N';

      OPEN check_tenancy;
      FETCH check_tenancy into l_exists;
      CLOSE check_tenancy;

      IF l_exists = 'Y' THEN
         fnd_message.set_name ('PN','PN_LOCTN_TENANCY_CHK_MSG');
         x_return_status := 'E';
         RETURN;
      END IF;

      DELETE FROM pn_locations_all
      WHERE  (location_id, active_start_date,active_end_date) IN
             (SELECT location_id, active_start_date,active_end_date
              FROM   pn_locations_all pl
              WHERE  active_start_date > p_active_end_date
              AND NOT EXISTS (SELECT '1'
                              FROM   pn_space_assign_emp_all
                              WHERE  location_id = pl.location_id
                              AND    p_active_end_date BETWEEN emp_assign_start_date
                                                           AND emp_assign_end_date)
              AND NOT EXISTS (SELECT '1'
                              FROM   pn_space_assign_cust_all
                              WHERE  location_id = pl.location_id
                              AND    p_active_end_date BETWEEN cust_assign_start_date
                                                           AND cust_assign_end_date)
              START WITH location_id = p_location_id
              CONNECT BY PRIOR location_id = parent_location_id);


      UPDATE pn_locations_all
      SET    active_end_date = p_active_end_date
      WHERE  active_start_date <= p_active_end_date
      AND    active_end_date > p_active_end_date
      AND    location_id IN (SELECT location_id
                             FROM   pn_locations_all
                             START WITH location_id = p_location_id
                             CONNECT BY PRIOR location_id = parent_location_id);

   END IF;

   IF p_active_start_date > p_active_start_date_old AND
      p_location_type_lookup_code NOT IN ('OFFICE','SECTION')THEN

      l_exists := 'N';

      OPEN check_start_tenancy;
      FETCH check_start_tenancy into l_exists;
      CLOSE check_start_tenancy;

      IF l_exists = 'Y' THEN
         fnd_message.set_name ('PN','PN_LOCTN_TENANCY_CHK_MSG');
         x_return_status := 'E';
         RETURN;
      END IF;

      DELETE FROM pn_locations_all
      WHERE  (location_id, active_start_date,active_end_date) IN
             (SELECT location_id, active_start_date,active_end_date
              FROM   pn_locations_all pl
              WHERE  active_end_date < p_active_start_date
              AND NOT EXISTS (SELECT '1'
                              FROM   pn_space_assign_emp_all
                              WHERE  location_id = pl.location_id
                              AND    p_active_start_date BETWEEN emp_assign_start_date
                                                             AND emp_assign_end_date)
              AND NOT EXISTS (SELECT '1'
                              FROM   pn_space_assign_cust_all
                              WHERE  location_id = pl.location_id
                              AND    p_active_start_date BETWEEN cust_assign_start_date
                                                             AND cust_assign_end_date)
              START WITH location_id = p_location_id
              CONNECT BY PRIOR location_id = parent_location_id);

      UPDATE pn_locations_all
      SET    active_start_date = p_active_start_date
      WHERE  active_start_date < p_active_start_date
      AND    active_end_date >= p_active_start_date
      AND    location_id IN (SELECT location_id
                             FROM   pn_locations_all
                             START WITH location_id = p_location_id
                             CONNECT BY PRIOR location_id = parent_location_id);

   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   pnp_debug_pkg.debug('PNT_LOCATIONS_PKG.update_child_for_dates (-) ReturnStatus: '||x_return_status);

EXCEPTION
   WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   fnd_message.set_name ('PN','PN_OTHERS_EXCEPTION');
   fnd_message.set_token('ERR_MSG',sqlerrm);

END update_child_for_dates;

-------------------------------------------------------------------------------
-- check_for_popup : This procedure compares the form field values
-- with the locked row and returns 'Y', if the value has changed
-- HISTORY:
-- 14-OCT-03 Anand  o Added code to consider the new column bookable_flag.
--  01-DEC-2004 Satish Tripathi o Modified for Portfolio Status Enh BUG# 4030816.
--                                Added code to condider columns occupancy_status_code, assignable_emp,
--                                assignable_cc, assignable_cust.
-------------------------------------------------------------------------------
PROCEDURE check_for_popup (p_pn_locations_rec pn_locations_all%rowtype,
                           p_start_date_old IN DATE,
                           p_end_date_old   IN DATE,
                           x_flag           OUT NOCOPY VARCHAR2,
                           x_return_status  OUT NOCOPY VARCHAR2,
                           x_return_message OUT NOCOPY VARCHAR2) IS

BEGIN

   pnp_debug_pkg.debug('PNT_LOCATIONS_PKG.check_for_popup (+) LocId: '||p_pn_locations_rec.location_id
                       ||', LocCd: '||p_pn_locations_rec.location_code
                       ||', Type: '||p_pn_locations_rec.location_type_lookup_code);
   x_flag := 'N';

   -- Compare the form field values in p_pn_locations_rec with
   -- the row locked by the lock_row procedure
   -- and return 'Y' if the values are different

   IF ((G_LOC_RECINFO.ATTRIBUTE_CATEGORY <> p_pn_locations_rec.attribute_category)
      OR ((G_LOC_RECINFO.ATTRIBUTE_CATEGORY is NULL) AND (p_pn_locations_rec.attribute_category is NOT NULL))
      OR ((G_LOC_RECINFO.ATTRIBUTE_CATEGORY is NOT NULL) AND (p_pn_locations_rec.attribute_category is NULL))) THEN
      x_flag := 'Y';
      return;
   END IF;

   IF ((G_LOC_RECINFO.ATTRIBUTE1 <> p_pn_locations_rec.attribute1)
      OR ((G_LOC_RECINFO.ATTRIBUTE1 is NULL) AND (p_pn_locations_rec.attribute1 is NOT NULL))
      OR ((G_LOC_RECINFO.ATTRIBUTE1 is NOT NULL) AND (p_pn_locations_rec.attribute1 is NULL))) THEN
      x_flag := 'Y';
      return;
   END IF;

   IF ((G_LOC_RECINFO.ATTRIBUTE2 <> p_pn_locations_rec.attribute2)
      OR ((G_LOC_RECINFO.ATTRIBUTE2 is NULL) AND (p_pn_locations_rec.attribute2 is NOT NULL))
      OR ((G_LOC_RECINFO.ATTRIBUTE2 is NOT NULL) AND (p_pn_locations_rec.attribute2 is NULL))) THEN
      x_flag := 'Y';
      return;
   END IF;

   IF ((G_LOC_RECINFO.ATTRIBUTE3 <> p_pn_locations_rec.attribute3)
      OR ((G_LOC_RECINFO.ATTRIBUTE3 is NULL) AND (p_pn_locations_rec.attribute3 is NOT NULL))
      OR ((G_LOC_RECINFO.ATTRIBUTE3 is NOT NULL) AND (p_pn_locations_rec.attribute3 is NULL))) THEN
      x_flag := 'Y';
      return;
   END IF;
   IF ((G_LOC_RECINFO.ATTRIBUTE4 <> p_pn_locations_rec.attribute4)
      OR ((G_LOC_RECINFO.ATTRIBUTE4 is NULL) AND (p_pn_locations_rec.attribute4 is NOT NULL))
      OR ((G_LOC_RECINFO.ATTRIBUTE4 is NOT NULL) AND (p_pn_locations_rec.attribute4 is NULL))) THEN
      x_flag := 'Y';
      return;
   END IF;
   IF ((G_LOC_RECINFO.ATTRIBUTE5 <> p_pn_locations_rec.attribute5)
      OR ((G_LOC_RECINFO.ATTRIBUTE5 is NULL) AND (p_pn_locations_rec.attribute5 is NOT NULL))
      OR ((G_LOC_RECINFO.ATTRIBUTE5 is NOT NULL) AND (p_pn_locations_rec.attribute5 is NULL))) THEN
      x_flag := 'Y';
      return;
   END IF;
   IF ((G_LOC_RECINFO.ATTRIBUTE6 <> p_pn_locations_rec.attribute6)
      OR ((G_LOC_RECINFO.ATTRIBUTE6 is NULL) AND (p_pn_locations_rec.attribute6 is NOT NULL))
      OR ((G_LOC_RECINFO.ATTRIBUTE6 is NOT NULL) AND (p_pn_locations_rec.attribute6 is NULL))) THEN
      x_flag := 'Y';
      return;
   END IF;
   IF ((G_LOC_RECINFO.ATTRIBUTE7 <> p_pn_locations_rec.attribute7)
      OR ((G_LOC_RECINFO.ATTRIBUTE7 is NULL) AND (p_pn_locations_rec.attribute7 is NOT NULL))
      OR ((G_LOC_RECINFO.ATTRIBUTE7 is NOT NULL) AND (p_pn_locations_rec.attribute7 is NULL))) THEN
      x_flag := 'Y';
      return;
   END IF;
   IF ((G_LOC_RECINFO.ATTRIBUTE8 <> p_pn_locations_rec.attribute8)
      OR ((G_LOC_RECINFO.ATTRIBUTE8 is NULL) AND (p_pn_locations_rec.attribute8 is NOT NULL))
      OR ((G_LOC_RECINFO.ATTRIBUTE8 is NOT NULL) AND (p_pn_locations_rec.attribute8 is NULL))) THEN
      x_flag := 'Y';
      return;
   END IF;
   IF ((G_LOC_RECINFO.ATTRIBUTE9 <> p_pn_locations_rec.attribute9)
      OR ((G_LOC_RECINFO.ATTRIBUTE9 is NULL) AND (p_pn_locations_rec.attribute9 is NOT NULL))
      OR ((G_LOC_RECINFO.ATTRIBUTE9 is NOT NULL) AND (p_pn_locations_rec.attribute9 is NULL))) THEN
      x_flag := 'Y';
      return;
   END IF;
   IF ((G_LOC_RECINFO.ATTRIBUTE10 <> p_pn_locations_rec.attribute10)
      OR ((G_LOC_RECINFO.ATTRIBUTE10 is NULL) AND (p_pn_locations_rec.attribute10 is NOT NULL))
      OR ((G_LOC_RECINFO.ATTRIBUTE10 is NOT NULL) AND (p_pn_locations_rec.attribute10 is NULL))) THEN
      x_flag := 'Y';
      return;
   END IF;
   IF ((G_LOC_RECINFO.ATTRIBUTE11 <> p_pn_locations_rec.attribute11)
      OR ((G_LOC_RECINFO.ATTRIBUTE11 is NULL) AND (p_pn_locations_rec.attribute11 is NOT NULL))
      OR ((G_LOC_RECINFO.ATTRIBUTE11 is NOT NULL) AND (p_pn_locations_rec.attribute11 is NULL))) THEN
      x_flag := 'Y';
      return;
   END IF;
   IF ((G_LOC_RECINFO.ATTRIBUTE12 <> p_pn_locations_rec.attribute12)
      OR ((G_LOC_RECINFO.ATTRIBUTE12 is NULL) AND (p_pn_locations_rec.attribute12 is NOT NULL))
      OR ((G_LOC_RECINFO.ATTRIBUTE12 is NOT NULL) AND (p_pn_locations_rec.attribute12 is NULL))) THEN
      x_flag := 'Y';
      return;
   END IF;
   IF ((G_LOC_RECINFO.ATTRIBUTE13 <> p_pn_locations_rec.attribute13)
      OR ((G_LOC_RECINFO.ATTRIBUTE13 is NULL) AND (p_pn_locations_rec.attribute13 is NOT NULL))
      OR ((G_LOC_RECINFO.ATTRIBUTE13 is NOT NULL) AND (p_pn_locations_rec.attribute13 is NULL))) THEN
      x_flag := 'Y';
      return;
   END IF;
   IF ((G_LOC_RECINFO.ATTRIBUTE14 <> p_pn_locations_rec.attribute14)
      OR ((G_LOC_RECINFO.ATTRIBUTE14 is NULL) AND (p_pn_locations_rec.attribute14 is NOT NULL))
      OR ((G_LOC_RECINFO.ATTRIBUTE14 is NOT NULL) AND (p_pn_locations_rec.attribute14 is NULL))) THEN
      x_flag := 'Y';
      return;
   END IF;
   IF ((G_LOC_RECINFO.ATTRIBUTE15 <> p_pn_locations_rec.attribute15)
      OR ((G_LOC_RECINFO.ATTRIBUTE15 is NULL) AND (p_pn_locations_rec.attribute15 is NOT NULL))
      OR ((G_LOC_RECINFO.ATTRIBUTE15 is NOT NULL) AND (p_pn_locations_rec.attribute15 is NULL))) THEN
      x_flag := 'Y';
      return;
   END IF;

   IF NOT ((nvl(G_LOC_RECINFO.COMMON_AREA_FLAG,'x') = p_pn_locations_rec.COMMON_AREA_FLAG)
        OR ((G_LOC_RECINFO.COMMON_AREA_FLAG is null) AND (p_pn_locations_rec.COMMON_AREA_FLAG is null))) THEN
        x_flag := 'Y';
        return;
   END IF;

   IF NOT (nvl(G_LOC_RECINFO.LOCATION_TYPE_LOOKUP_CODE,'x') = p_pn_locations_rec.LOCATION_TYPE_LOOKUP_CODE) THEN
        x_flag := 'Y';
        return;
   END IF;

   IF ((G_LOC_RECINFO.FUNCTION_TYPE_LOOKUP_CODE <> p_pn_locations_rec.FUNCTION_TYPE_LOOKUP_CODE)
      OR ((G_LOC_RECINFO.FUNCTION_TYPE_LOOKUP_CODE is NULL) AND (p_pn_locations_rec.FUNCTION_TYPE_LOOKUP_CODE is NOT NULL))
      OR ((G_LOC_RECINFO.FUNCTION_TYPE_LOOKUP_CODE is NOT NULL) AND (p_pn_locations_rec.FUNCTION_TYPE_LOOKUP_CODE is NULL))) THEN
      x_flag := 'Y';
      return;
   END IF;

   IF ((G_LOC_RECINFO.STANDARD_TYPE_LOOKUP_CODE <> p_pn_locations_rec.STANDARD_TYPE_LOOKUP_CODE)
      OR ((G_LOC_RECINFO.STANDARD_TYPE_LOOKUP_CODE is NULL) AND (p_pn_locations_rec.STANDARD_TYPE_LOOKUP_CODE is NOT NULL))
      OR ((G_LOC_RECINFO.STANDARD_TYPE_LOOKUP_CODE is NOT NULL) AND (p_pn_locations_rec.STANDARD_TYPE_LOOKUP_CODE is NULL))) THEN
      x_flag := 'Y';
      return;
   END IF;

   IF ((G_LOC_RECINFO.SPACE_TYPE_LOOKUP_CODE <> p_pn_locations_rec.SPACE_TYPE_LOOKUP_CODE)
      OR ((G_LOC_RECINFO.SPACE_TYPE_LOOKUP_CODE is NULL) AND (p_pn_locations_rec.SPACE_TYPE_LOOKUP_CODE is NOT NULL))
      OR ((G_LOC_RECINFO.SPACE_TYPE_LOOKUP_CODE is NOT NULL) AND (p_pn_locations_rec.SPACE_TYPE_LOOKUP_CODE is NULL))) THEN
      x_flag := 'Y';
      return;
   END IF;

   IF NOT (nvl(G_LOC_RECINFO.LOCATION_CODE,'x') = p_pn_locations_rec.LOCATION_CODE) THEN
        x_flag := 'Y';
        return;
   END IF;

   IF NOT ((nvl(G_LOC_RECINFO.BUILDING,'x') = p_pn_locations_rec.BUILDING)
        OR ((G_LOC_RECINFO.BUILDING is null) AND (p_pn_locations_rec.BUILDING is null))) THEN
        x_flag := 'Y';
        return;
   END IF;

   IF NOT ((nvl(G_LOC_RECINFO.FLOOR,'x') = p_pn_locations_rec.FLOOR)
        OR ((G_LOC_RECINFO.FLOOR is null) AND (p_pn_locations_rec.FLOOR is null))) THEN
        x_flag := 'Y';
        return;
   END IF;

   IF NOT ((nvl(G_LOC_RECINFO.LOCATION_ALIAS,'x') = p_pn_locations_rec.LOCATION_ALIAS)
        OR ((G_LOC_RECINFO.LOCATION_ALIAS is null) AND (p_pn_locations_rec.LOCATION_ALIAS is null))) THEN
        x_flag := 'Y';
        return;
   END IF;

   IF NOT ((nvl(G_LOC_RECINFO.PROPERTY_ID,-9.99) = nvl(p_pn_locations_rec.PROPERTY_ID,-9.99))) THEN
        x_flag := 'Y';
        return;
   END IF;

   IF NOT ((nvl(G_LOC_RECINFO.PARENT_LOCATION_ID,9.99) = p_pn_locations_rec.PARENT_LOCATION_ID)
        OR ((G_LOC_RECINFO.PARENT_LOCATION_ID is null) AND (p_pn_locations_rec.PARENT_LOCATION_ID is null))) THEN
        x_flag := 'Y';
        return;
   END IF;

   IF NOT ((nvl(G_LOC_RECINFO.INTERFACE_FLAG,'x') = p_pn_locations_rec.INTERFACE_FLAG)
        OR ((G_LOC_RECINFO.INTERFACE_FLAG is null) AND (p_pn_locations_rec.INTERFACE_FLAG is null))) THEN
        x_flag := 'Y';
        return;
   END IF;

   IF NOT ((nvl(G_LOC_RECINFO.STATUS,'x') = p_pn_locations_rec.STATUS)
        OR ((G_LOC_RECINFO.STATUS is null) AND (p_pn_locations_rec.STATUS is null))) THEN
        x_flag := 'Y';
        return;
   END IF;

   IF ((g_loc_recinfo.occupancy_status_code <> p_pn_locations_rec.occupancy_status_code) OR
       ((g_loc_recinfo.occupancy_status_code IS NULL) AND (p_pn_locations_rec.occupancy_status_code IS NOT NULL)) OR
       ((g_loc_recinfo.occupancy_status_code IS NOT NULL) AND (p_pn_locations_rec.occupancy_status_code IS NULL)))
   THEN
      x_flag := 'Y';
      RETURN;
   END IF;

   IF ((g_loc_recinfo.assignable_emp <> p_pn_locations_rec.assignable_emp) OR
       ((g_loc_recinfo.assignable_emp IS NULL) AND (p_pn_locations_rec.assignable_emp IS NOT NULL)) OR
       ((g_loc_recinfo.assignable_emp IS NOT NULL) AND (p_pn_locations_rec.assignable_emp IS NULL)))
   THEN
      x_flag := 'Y';
      RETURN;
   END IF;

   IF ((g_loc_recinfo.assignable_cc <> p_pn_locations_rec.assignable_cc) OR
       ((g_loc_recinfo.assignable_cc IS NULL) AND (p_pn_locations_rec.assignable_cc IS NOT NULL)) OR
       ((g_loc_recinfo.assignable_cc IS NOT NULL) AND (p_pn_locations_rec.assignable_cc IS NULL)))
   THEN
      x_flag := 'Y';
      RETURN;
   END IF;

   IF ((g_loc_recinfo.assignable_cust <> p_pn_locations_rec.assignable_cust) OR
       ((g_loc_recinfo.assignable_cust IS NULL) AND (p_pn_locations_rec.assignable_cust IS NOT NULL)) OR
       ((g_loc_recinfo.assignable_cust IS NOT NULL) AND (p_pn_locations_rec.assignable_cust IS NULL)))
   THEN
      x_flag := 'Y';
      RETURN;
   END IF;


   -- DO SPECIAL CHECKS FOR PARTICULAR KINDS

   IF (NVL(G_LOC_RECINFO.LOCATION_TYPE_LOOKUP_CODE, ' ') IN ('BUILDING','LAND')) THEN
      IF NOT ((nvl(G_LOC_RECINFO.LOCATION_PARK_ID,9.99) = p_pn_locations_rec.LOCATION_PARK_ID)
           OR ((G_LOC_RECINFO.LOCATION_PARK_ID is null) AND (p_pn_locations_rec.LOCATION_PARK_ID is null))) THEN
        x_flag := 'Y';
        return;
      END IF;

      IF NOT ((nvl(G_LOC_RECINFO.LEASE_OR_OWNED,'x') = p_pn_locations_rec.LEASE_OR_OWNED)
           OR ((G_LOC_RECINFO.LEASE_OR_OWNED is null) AND (p_pn_locations_rec.LEASE_OR_OWNED is null))) THEN
           x_flag := 'Y';
           return;
      END IF;

      IF ((G_LOC_RECINFO.CLASS <> p_pn_locations_rec.CLASS)
        OR ((G_LOC_RECINFO.CLASS is NULL) AND (p_pn_locations_rec.CLASS is NOT NULL))
        OR ((G_LOC_RECINFO.CLASS is NOT NULL) AND (p_pn_locations_rec.CLASS is NULL))) THEN
          x_flag := 'Y';
          return;
      END IF;

      IF NOT ((nvl(G_LOC_RECINFO.STATUS_TYPE,'x') = p_pn_locations_rec.STATUS_TYPE)
           OR ((G_LOC_RECINFO.STATUS_TYPE is null) AND (p_pn_locations_rec.STATUS_TYPE is null))) THEN
        x_flag := 'Y';
        return;
      END IF;

      IF NOT ((nvl(G_LOC_RECINFO.OFFICE,'x') = p_pn_locations_rec.OFFICE)
           OR ((G_LOC_RECINFO.OFFICE is null) AND (p_pn_locations_rec.OFFICE is null))) THEN
        x_flag := 'Y';
        return;
      END IF;

      IF NOT ((nvl(G_LOC_RECINFO.ADDRESS_ID,9.99) = p_pn_locations_rec.ADDRESS_ID)
           OR ((G_LOC_RECINFO.ADDRESS_ID is null) AND (p_pn_locations_rec.ADDRESS_ID is null))) THEN
        x_flag := 'Y';
        return;
      END IF;

      IF NOT ((nvl(G_LOC_RECINFO.GROSS_AREA,-9.99) = nvl(p_pn_locations_rec.GROSS_AREA,-9.99))) THEN
        x_flag := 'Y';
        return;
      END IF;

      IF NOT ((nvl(G_LOC_RECINFO.SUITE,'x') = p_pn_locations_rec.SUITE)
           OR ((G_LOC_RECINFO.SUITE is null) AND (p_pn_locations_rec.SUITE is null))) THEN
        x_flag := 'Y';
        return;
      END IF;

      IF NOT ((nvl(G_LOC_RECINFO.ALLOCATE_COST_CENTER_CODE,'x') = p_pn_locations_rec.ALLOCATE_COST_CENTER_CODE)
           OR ((G_LOC_RECINFO.ALLOCATE_COST_CENTER_CODE is null) AND (p_pn_locations_rec.ALLOCATE_COST_CENTER_CODE is null))) THEN
        x_flag := 'Y';
        return;
      END IF;

      IF NOT ((G_LOC_RECINFO.UOM_CODE = p_pn_locations_rec.UOM_CODE)
           OR ((G_LOC_RECINFO.UOM_CODE is null) AND (p_pn_locations_rec.UOM_CODE is null))) THEN
        x_flag := 'Y';
        return;
      END IF;

      IF NOT ((nvl(G_LOC_RECINFO.DESCRIPTION,'x') = p_pn_locations_rec.DESCRIPTION)
           OR ((G_LOC_RECINFO.DESCRIPTION is null) AND (p_pn_locations_rec.DESCRIPTION is null))) THEN
        x_flag := 'Y';
        return;
      END IF;

   ELSIF (NVL(G_LOC_RECINFO.LOCATION_TYPE_LOOKUP_CODE, ' ') IN ('OFFICE','SECTION')) THEN

      IF NOT ((nvl(G_LOC_RECINFO.OFFICE,'x') = p_pn_locations_rec.OFFICE)
           OR ((G_LOC_RECINFO.OFFICE is null) AND (p_pn_locations_rec.OFFICE is null))) THEN
        x_flag := 'Y';
        return;
      END IF;

      IF NOT ((nvl(G_LOC_RECINFO.MAX_CAPACITY,-9.99) = nvl(p_pn_locations_rec.MAX_CAPACITY,-9.99))) THEN
        x_flag := 'Y';
        return;
      END IF;

      IF NOT ((nvl(G_LOC_RECINFO.OPTIMUM_CAPACITY,-9.99) = nvl(p_pn_locations_rec.OPTIMUM_CAPACITY,-9.99))) THEN
        x_flag := 'Y';
        return;
      END IF;

      IF NOT ((nvl(G_LOC_RECINFO.RENTABLE_AREA,-9.99) = nvl(p_pn_locations_rec.RENTABLE_AREA,-9.99))) THEN
        x_flag := 'Y';
        return;
      END IF;

      IF NOT ((nvl(G_LOC_RECINFO.USABLE_AREA,-9.99) = nvl(p_pn_locations_rec.USABLE_AREA,-9.99))) THEN
        x_flag := 'Y';
        return;
      END IF;

      IF NOT ((nvl(G_LOC_RECINFO.ASSIGNABLE_AREA,9.99) = p_pn_locations_rec.ASSIGNABLE_AREA)
           OR ((G_LOC_RECINFO.ASSIGNABLE_AREA is null) AND (p_pn_locations_rec.ASSIGNABLE_AREA is null))) THEN
        x_flag := 'Y';
        return;
      END IF;

      IF NOT ((nvl(G_LOC_RECINFO.COMMON_AREA,9.99) = p_pn_locations_rec.COMMON_AREA)
           OR ((G_LOC_RECINFO.COMMON_AREA is null) AND (p_pn_locations_rec.COMMON_AREA is null))) THEN
        x_flag := 'Y';
        return;
      END IF;

     IF ((G_LOC_RECINFO.SUITE <> p_pn_locations_rec.SUITE)
        OR ((G_LOC_RECINFO.SUITE is NULL) AND (p_pn_locations_rec.SUITE is NOT NULL))
        OR ((G_LOC_RECINFO.SUITE is NOT NULL) AND (p_pn_locations_rec.SUITE is NULL))) THEN
          x_flag := 'Y';
          return;
     END IF;

     IF NOT ((nvl(G_LOC_RECINFO.BOOKABLE_FLAG,'x') = p_pn_locations_rec.BOOKABLE_FLAG)
        OR ((G_LOC_RECINFO.BOOKABLE_FLAG is null) AND (p_pn_locations_rec.BOOKABLE_FLAG is null))) THEN
        x_flag := 'Y';
        return;
     END IF;

   END IF;

   pnp_debug_pkg.debug('PNT_LOCATIONS_PKG.check_for_popup (-) Flag: '||x_flag||', ReturnStatus: '||x_return_status);

END check_for_popup;

-------------------------------------------------------------------------------
-- PROCDURE     : Update_Status
-- INVOKED FROM :
-- PURPOSE      : Updates the status.
-- HISTORY      :
-- xx-xxx-xx         o Fix for bug 707274
-- 13-JUL-05  hrodda o Bug 4284035 - Replaced PN_LOCATION_ with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE Update_Status (p_Location_Id  Number) IS

BEGIN

   UPDATE pn_locations_all
   SET    Status = 'I'
   WHERE  Location_Id IN (SELECT Location_Id
                          FROM   pn_locations_all
                          START WITH Location_Id = p_Location_Id
                          CONNECT BY PRIOR Location_Id = Parent_Location_id);

End Update_Status ;

---------------------------------------------------------------------------------------
-- Procedure update_assignments ( Fix for bug 2722698 )
---------------------------------------------------------------------------------------
PROCEDURE update_assignments (
                          p_location_id                   IN  NUMBER
                         ,p_active_start_date             IN  DATE
                         ,p_active_end_date               IN  DATE
                         ,p_active_start_date_old         IN  DATE
                         ,p_active_end_date_old           IN  DATE
                         ,x_return_status                 OUT NOCOPY VARCHAR2
                         ,x_return_message                OUT NOCOPY VARCHAR2
                         )
IS

     CURSOR location_cursor IS
     SELECT *
     FROM   pn_locations_all
     START  WITH location_id = p_location_id
     CONNECT BY PRIOR location_id = parent_location_id;

BEGIN

   pnp_debug_pkg.debug('PNT_LOCATIONS_PKG.update_assignments (+)');
   pnp_debug_pkg.debug('  UpdAsgn=> In Parameters :: p_location_id: '||p_location_id);
   pnp_debug_pkg.debug('  UpdAsgn=>   p_active_start_date    : '||TO_CHAR(p_active_start_date, 'MM/DD/YYYY')
                       ||', p_active_end_date    : '||TO_CHAR(p_active_end_date, 'MM/DD/YYYY'));
   pnp_debug_pkg.debug('  UpdAsgn=>   p_active_start_date_old: '||TO_CHAR(p_active_start_date_old, 'MM/DD/YYYY')
                       ||', p_active_end_date_old: '||TO_CHAR(p_active_end_date_old, 'MM/DD/YYYY'));

   FOR l_location_rec in location_cursor LOOP

   pnp_debug_pkg.debug('    UpdAsgn> Row#: '||location_cursor%ROWCOUNT||', Inside FOR loop LocId: '||l_location_rec.location_id||', LocCd: '||l_location_rec.location_code);

      IF l_location_rec.active_end_date > p_active_end_date
         and p_active_end_date <> p_active_end_date_old THEN

         pnp_debug_pkg.debug('    UpdAsgn> Inside end date updation');

         DELETE FROM pn_space_assign_emp_all
         WHERE  location_id         = l_location_rec.location_id
         AND    emp_assign_start_date > p_active_end_date
         AND    allocated_area = 0;

         UPDATE pn_space_assign_emp_all
         SET    emp_assign_end_date = p_active_end_date
         WHERE  location_id         = l_location_rec.location_id
         AND    emp_assign_end_date > p_active_end_date;

         DELETE FROM pn_space_assign_cust_all
         WHERE  location_id         = l_location_rec.location_id
         AND    cust_assign_start_date > p_active_end_date
         AND    allocated_area = 0;

         UPDATE pn_space_assign_cust_all
         SET    cust_assign_end_date = p_active_end_date
         WHERE  location_id          = l_location_rec.location_id
         AND    cust_assign_end_date > p_active_end_date;

      END IF;

      IF l_location_rec.active_start_date < p_active_start_date
         and p_active_start_date <> p_active_start_date_old THEN

         pnp_debug_pkg.debug('    UpdAsgn> Inside start date updation');

         DELETE FROM pn_space_assign_emp_all
         WHERE  location_id         = l_location_rec.location_id
         AND    emp_assign_end_date < p_active_start_date
         AND    allocated_area = 0;

         UPDATE pn_space_assign_emp_all
         SET    emp_assign_start_date = p_active_start_date
         WHERE  location_id           = l_location_rec.location_id
         AND    emp_assign_start_date < p_active_start_date;

         DELETE FROM pn_space_assign_cust_all
         WHERE  location_id         = l_location_rec.location_id
         AND    cust_assign_end_date < p_active_start_date
         AND    allocated_area = 0;

         UPDATE pn_space_assign_cust_all
         SET    cust_assign_start_date = p_active_start_date
         WHERE  location_id            = l_location_rec.location_id
         AND    cust_assign_start_date < p_active_start_date;

      END IF;

   END LOOP;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   pnp_debug_pkg.debug('PNT_LOCATIONS_PKG.update_assignments (-) ReturnStatus: '||x_return_status);

EXCEPTION
   WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   fnd_message.set_name ('PN','PN_OTHERS_EXCEPTION');
   fnd_message.set_token('ERR_MSG',sqlerrm);
   pnp_debug_pkg.log('Other error update_assignments' || sqlerrm);

END update_assignments;

-----------------------------------------------------------------------
-- FUNCTION : validate_gross_area
-- PURPOSE  : The function validates that sum off rentable area for all
--            offices/sections under building/land must be less than the
--            gross area of building/land.
-- IN PARAM : Location Id, Rentable Area, Location Type Lookup Code,
--            Active Start Date, Active End Date.
-- History  :
--            22-JAN-2003   Mrinal Misra   o Created.
--            28-JAN-2003   Kiran          o Modified
--                                         o Changed i/p param p_rent_area to p_area
--                                         o Changed the function to validate for both
--                                           'OFFICE' and 'BUILDING'.
--            28-JAN-2003   Mrinal Misra   o Added p_change_mode parameter and related
--                                           logic in function.
--            14-DEC-2004   Vikas Mehta    o Changes to call function Get_Max_Rent_Area
--  18-JAN-2005 Satish Tripathi o Modified for debug messages. Set l_return appropriately
--                                and log it in debug before RETURN.
-----------------------------------------------------------------------
FUNCTION validate_gross_area(p_loc_id      IN NUMBER,
                             p_area        IN NUMBER,
                             p_lkp_code    IN VARCHAR2,
                             p_act_str_dt  IN DATE,
                             p_act_end_dt  IN DATE,
                             p_change_mode IN VARCHAR2
                            )
RETURN BOOLEAN IS

   l_min_gross_area   NUMBER;
   l_loc_id           NUMBER;
   l_sum_rent_area    NUMBER;
   l_old_rent_area    NUMBER;
   l_act_end_dt       DATE := NVL(p_act_end_dt, pnt_locations_pkg.g_end_of_time);
   l_off_lkp_code     VARCHAR2(30);
   l_return           VARCHAR2(30);

   CURSOR get_min_gross_area IS
      SELECT MIN(gross_area) min_gross_area,
             location_id     location_id
      FROM   pn_locations_all
      WHERE  parent_location_id IS NULL
      AND    active_start_date <= l_act_end_dt
      AND    active_end_date   >= p_act_str_dt
      START WITH location_id = p_loc_id
      CONNECT BY PRIOR parent_location_id = location_id
      GROUP BY location_id;

   CURSOR get_old_rent_area IS
      SELECT rentable_area
      FROM   pn_locations_all
      WHERE  location_id = p_loc_id
      AND    location_type_lookup_code = p_lkp_code
      AND    active_start_date <= NVL(p_act_end_dt, TO_DATE('12/31/4712','MM/DD/YYYY'))
      AND    active_end_date   >= p_act_str_dt;
BEGIN

   pnp_debug_pkg.debug('      PntLocnPkg.Validate_Gross_Area (+) LocId: '||p_loc_id||', Area: '||p_area
                       ||', ActStrDt: '||TO_CHAR(p_act_str_dt, 'MM/DD/YYYY')
                       ||', ActEndDt: '||TO_CHAR(p_act_end_dt, 'MM/DD/YYYY'));
   IF p_lkp_code in ('OFFICE', 'SECTION') THEN

      OPEN get_min_gross_area;
      FETCH get_min_gross_area INTO l_min_gross_area, l_loc_id;
      CLOSE get_min_gross_area;

      IF l_min_gross_area is null THEN
         l_return := 'Y';
      ELSE
         l_sum_rent_area := Get_Max_Rent_Area(l_loc_id, p_lkp_code, p_act_str_dt, l_act_end_dt);

         IF p_change_mode = 'UPDATE' THEN
            OPEN get_old_rent_area;
            FETCH get_old_rent_area INTO l_old_rent_area;
            CLOSE get_old_rent_area;

            l_sum_rent_area := l_sum_rent_area - l_old_rent_area;
         END IF;

         IF NVL(l_min_gross_area,0) < NVL(l_sum_rent_area, 0) + NVL(p_area,0) THEN
            l_return := 'N';
         ELSE
            l_return := 'Y';
         END IF;
      END IF;

   ELSIF p_lkp_code in ('BUILDING', 'LAND') THEN

      IF p_lkp_code = 'BUILDING' THEN
         l_off_lkp_code := 'OFFICE';
      ELSIF p_lkp_code = 'LAND' THEN
         l_off_lkp_code := 'SECTION';
      END IF;

      IF p_area IS NULL THEN
         l_return := 'Y';
      ELSE

         l_sum_rent_area := Get_Max_Rent_Area(l_loc_id, l_off_lkp_code, p_act_str_dt, l_act_end_dt);

         IF NVL(p_area,0) < NVL(l_sum_rent_area, 0) THEN
            l_return := 'N';
         ELSE
            l_return := 'Y';
         END IF;
      END IF;

   END IF;

   pnp_debug_pkg.debug('      PntLocnPkg.Validate_Gross_Area (+) LocId: '||p_loc_id||', Return: '||l_return);

   IF l_return = 'Y' THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
   END IF;

END validate_gross_area;

-------------------------------------------------------------------------------
-- PROCEDURE : check_location_gaps
-- PURPOSE   : This procedure is being called from INSERT_ROW, UPDATE_ROW
--             of employee_fdr_blk, customer_fdr_blk of PNTSPACE form.
--             It checks for the gaps between office definition and stops
--             the user from assinging an office during that gap interval.
-- IN PARAM  : Location Id, Actice_start_date, Active_end_date.
-- History   :
--  27-DEC-02 MMisra    o Mrinal Misra
--  10-JAN-03 MMisra    o Modified to run FOR LOOP one lesser
--                        count by 1..loctn_tab.count-1.
--  05-JUN-03 STripathi o Added parameter p_err_msg for Recovery (CAM)
--                        impact on Leases.
--  01-DEC-04 STripathi o Modified for Portfolio Status Enh BUG# 4030816.
--                        Take occupancy status, assignable_emp, assignable_cc and
--                        assignable_cust into account depending on new parameter
--                        Assignmane Mode (p_asgn_mode).
--  13-JUL-05 hrodda    o Bug 4284035 - Replaced PN_LOCATION with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE Check_Location_Gaps (
                          p_loc_id                        IN         NUMBER
                         ,p_str_dt                        IN         DATE
                         ,p_end_dt                        IN         DATE
                         ,p_asgn_mode                     IN         VARCHAR2
                         ,p_err_msg                       OUT NOCOPY VARCHAR2
                         )
IS

   TYPE loctn_rec IS RECORD(
      location_id          pn_locations.location_id%TYPE,
      active_start_date    DATE,
      active_end_date      DATE);

   TYPE loc_type IS
      TABLE OF loctn_rec
      INDEX BY BINARY_INTEGER;

   loctn_tab                 loc_type;
   l_rec_num                 NUMBER;
   l_diff                    NUMBER;
   l_date                    DATE;
   l_err_flag                VARCHAR2(1);
   l_err_msg                 VARCHAR2(1) := NULL;

   CURSOR get_loctn_dates IS
      SELECT location_id,
             active_start_date,
             active_end_date
      FROM   pn_locations_all
      WHERE  active_end_date   >= p_str_dt
      AND    active_start_date <= p_end_dt
      AND    location_id        = p_loc_id
      AND    ((p_asgn_mode = 'NONE') OR
               (p_asgn_mode = 'EMP' AND NVL(assignable_emp, 'Y') = 'Y' AND NVL(assignable_cc, 'Y') = 'Y') OR
               (p_asgn_mode = 'CC' AND NVL(assignable_cc, 'Y') = 'Y') OR
               (p_asgn_mode = 'CUST' AND NVL(assignable_cust, 'Y') = 'Y')
             )
      ORDER BY active_start_date;

   CURSOR check_loctn_gap(l_date IN DATE) IS
      SELECT 'Y'
      FROM   DUAL
      WHERE NOT EXISTS (SELECT NULL
                    FROM   pn_locations_all
                    WHERE  l_date BETWEEN active_start_date AND active_end_date
                    AND    location_id =  p_loc_id
                    AND    ((p_asgn_mode = 'NONE') OR
                             (p_asgn_mode = 'EMP' AND NVL(assignable_emp, 'Y') = 'Y' AND NVL(assignable_cc, 'Y') = 'Y') OR
                             (p_asgn_mode = 'CC' AND NVL(assignable_cc, 'Y') = 'Y') OR
                             (p_asgn_mode = 'CUST' AND NVL(assignable_cust, 'Y') = 'Y')
                           ));

BEGIN

   pnp_debug_pkg.debug('PNT_LOCATIONS_PKG.Check_Location_Gaps(+) LocId: '||p_loc_id||', Mode: '||p_asgn_mode
                       ||', StrDt: '||TO_CHAR(p_str_dt, 'MM/DD/YYYY')||', EndDt: '||TO_CHAR(p_end_dt, 'MM/DD/YYYY'));

   loctn_tab.delete;
   l_rec_num := 0;
   l_err_flag := 'N';

   IF p_str_dt IS NOT NULL THEN
      OPEN check_loctn_gap(p_str_dt);
      FETCH check_loctn_gap INTO l_err_flag;
      CLOSE check_loctn_gap;

      IF l_err_flag = 'Y' THEN --Invalid Locn
         l_err_msg := 'I';
      END IF;
   END IF;

   IF p_end_dt IS NOT NULL AND
      l_err_flag = 'N'
   THEN
      OPEN check_loctn_gap(p_end_dt);
      FETCH check_loctn_gap INTO l_err_flag;
      CLOSE check_loctn_gap;

      IF l_err_flag = 'Y' THEN --Invalid Locn
         l_err_msg := 'I';
      END IF;
   END IF;

   IF p_end_dt IS NOT NULL AND p_str_dt IS NOT NULL AND
      l_err_flag = 'N'
   THEN
      FOR loc_rec IN get_loctn_dates LOOP
         l_rec_num :=  NVL(loctn_tab.count,0) + 1;
         loctn_tab(l_rec_num) := loc_rec;
      END LOOP;

      IF NVL(l_rec_num,0) > 1 THEN
         FOR i in 1..loctn_tab.count-1 LOOP

            l_diff := loctn_tab(i+1).active_start_date - loctn_tab(i).active_end_date;

            IF l_diff > 1 THEN
               l_err_flag := 'Y';
               EXIT;
            END IF;
         END LOOP;

      ELSIF NVL(l_rec_num,0) = 0 THEN
         l_err_flag := 'Y';
      END IF;

      IF l_err_flag = 'Y' THEN --Gap Exists
         l_err_msg := 'G';
      END IF;
   END IF;

   p_err_msg := l_err_msg;

   pnp_debug_pkg.debug('PNT_LOCATIONS_PKG.Check_Location_Gaps(-) ErrMsg: '||p_err_msg);

END Check_Location_Gaps;


-----------------------------------------------------------------------
-- PROCEDURE : Get_Location_Span
-- PURPOSE   : This procedure returns Min start date and Max end date
--             of a location taking occupancy status and assignable group
--             into account depending on Assignmane Mode (p_asgn_mode).
-- IN PARAM  :
-- History   :
--  01-DEC-2004 Satish Tripathi o Created for Portfolio Status Enh BUG# 4030816.
-----------------------------------------------------------------------
PROCEDURE Get_Location_Span (
                          p_loc_id                        IN         NUMBER
                         ,p_asgn_mode                     IN         VARCHAR2
                         ,p_min_str_dt                    OUT NOCOPY DATE
                         ,p_max_end_dt                    OUT NOCOPY DATE
                              )
IS

   CURSOR get_loctn_span IS
      SELECT MIN(active_start_date)
            ,MAX(active_end_date)
      FROM   pn_locations_all
      WHERE  location_id = p_loc_id
      AND    ((p_asgn_mode = 'NONE') OR
               (p_asgn_mode = 'EMP' AND NVL(assignable_emp, 'Y') = 'Y' AND NVL(assignable_cc, 'Y') = 'Y') OR
               (p_asgn_mode = 'CC' AND NVL(assignable_cc, 'Y') = 'Y') OR
               (p_asgn_mode = 'CUST' AND NVL(assignable_cust, 'Y') = 'Y'));

BEGIN

   pnp_debug_pkg.debug('PNT_LOCATIONS_PKG.Get_Location_Span(+) LocId: '||p_loc_id||', Mode: '||p_asgn_mode);

   OPEN get_loctn_span;
   FETCH get_loctn_span INTO p_min_str_dt, p_max_end_dt;
   CLOSE get_loctn_span;

   pnp_debug_pkg.debug('PNT_LOCATIONS_PKG.Get_Location_Span(-) MinStrDt: '
                       ||TO_CHAR(p_min_str_dt, 'MM/DD/YYYY')||', MaxEndDt: '||TO_CHAR(p_max_end_dt, 'MM/DD/YYYY'));

END Get_Location_Span;


-----------------------------------------------------------------------
-- PROCEDURE : Update_Locn_Row
-- PURPOSE   : This procedure calls pnt_locations_pkg.Update_Row for the
--             pn_locations_all%ROWTYPE passed to it. Called from
--             Correct_Update_Row and Cascade_Child_Locn
-- IN PARAM  :
-- History   :
--  01-DEC-2004 Satish Tripathi o Created for Portfolio Status Enh BUG# 4030816.
--  02-AUG-2005 Satya Deep      o Added X_SOURCE in the call to
--                                pnt_locations_pkg.Update_Row
-----------------------------------------------------------------------
PROCEDURE Update_Locn_Row (
                          p_loc_recinfo                   IN pn_locations_all%ROWTYPE
                         ,p_adr_recinfo                   IN pn_addresses_all%ROWTYPE
                         ,p_assgn_area_chgd_flag          IN VARCHAR2
                         ,x_return_status                 IN OUT NOCOPY VARCHAR2
                         ,x_return_message                IN OUT NOCOPY VARCHAR2
                         )
IS
   l_rowid                         ROWID;
   l_location_id                   pn_locations_all.location_id%TYPE;
   l_address_id                    pn_locations_all.address_id%TYPE;
BEGIN

   pnp_debug_pkg.debug('PNT_LOCATIONS_PKG.Update_Locn_Row (+)  LocId: '||p_loc_recinfo.location_id
                       ||', LocCd: '||p_loc_recinfo.location_code
                       ||', Type: '||p_loc_recinfo.location_type_lookup_code);
   l_location_id  := p_loc_recinfo.location_id;
   l_address_id   := p_loc_recinfo.address_id;

   IF g_pn_locations_rowid IS NULL THEN
      pnt_locations_pkg.Set_ROWID(
                         p_location_id       => p_loc_recinfo.location_id
                        ,p_active_start_date => p_loc_recinfo.active_start_date
                        ,p_active_end_date   => p_loc_recinfo.active_end_date
                        ,x_return_status     => x_return_status
                        ,x_return_message    => x_return_message
                        );
   END IF;

   IF NVL(x_return_status, 'S') = 'S' THEN

      pnt_locations_pkg.Update_Row
         (
          x_location_id                    => l_location_id
         ,x_last_update_date               => SYSDATE
         ,x_last_updated_by                => fnd_global.user_id
         ,x_last_update_login              => fnd_global.login_id
         ,x_location_park_id               => p_loc_recinfo.location_park_id
         ,x_location_type_lookup_code      => p_loc_recinfo.location_type_lookup_code
         ,x_space_type_lookup_code         => p_loc_recinfo.space_type_lookup_code
         ,x_function_type_lookup_code      => p_loc_recinfo.function_type_lookup_code
         ,x_standard_type_lookup_code      => p_loc_recinfo.standard_type_lookup_code
         ,x_building                       => p_loc_recinfo.building
         ,x_lease_or_owned                 => p_loc_recinfo.lease_or_owned
         ,x_class                          => p_loc_recinfo.class
         ,x_status_type                    => p_loc_recinfo.status_type
         ,x_floor                          => p_loc_recinfo.floor
         ,x_office                         => p_loc_recinfo.office
         ,x_max_capacity                   => p_loc_recinfo.max_capacity
         ,x_optimum_capacity               => p_loc_recinfo.optimum_capacity
         ,x_gross_area                     => p_loc_recinfo.gross_area
         ,x_rentable_area                  => p_loc_recinfo.rentable_area
         ,x_usable_area                    => p_loc_recinfo.usable_area
         ,x_assignable_area                => p_loc_recinfo.assignable_area
         ,x_common_area                    => p_loc_recinfo.common_area
         ,x_suite                          => p_loc_recinfo.suite
         ,x_allocate_cost_center_code      => p_loc_recinfo.allocate_cost_center_code
         ,x_uom_code                       => p_loc_recinfo.uom_code
         ,x_description                    => p_loc_recinfo.description
         ,x_parent_location_id             => p_loc_recinfo.parent_location_id
         ,x_interface_flag                 => p_loc_recinfo.interface_flag
         ,x_status                         => p_loc_recinfo.status
         ,x_property_id                    => p_loc_recinfo.property_id
         ,x_common_area_flag               => p_loc_recinfo.common_area_flag
         ,x_active_start_date              => p_loc_recinfo.active_start_date
         ,x_active_end_date                => p_loc_recinfo.active_end_date
         ,x_bookable_flag                  => p_loc_recinfo.bookable_flag
         ,x_occupancy_status_code          => p_loc_recinfo.occupancy_status_code
         ,x_assignable_emp                 => p_loc_recinfo.assignable_emp
         ,x_assignable_cc                  => p_loc_recinfo.assignable_cc
         ,x_assignable_cust                => p_loc_recinfo.assignable_cust
         ,x_disposition_code               => p_loc_recinfo.disposition_code
         ,x_acc_treatment_code             => p_loc_recinfo.acc_treatment_code
         ,x_attribute_category             => p_loc_recinfo.attribute_category
         ,x_attribute1                     => p_loc_recinfo.attribute1
         ,x_attribute2                     => p_loc_recinfo.attribute2
         ,x_attribute3                     => p_loc_recinfo.attribute3
         ,x_attribute4                     => p_loc_recinfo.attribute4
         ,x_attribute5                     => p_loc_recinfo.attribute5
         ,x_attribute6                     => p_loc_recinfo.attribute6
         ,x_attribute7                     => p_loc_recinfo.attribute7
         ,x_attribute8                     => p_loc_recinfo.attribute8
         ,x_attribute9                     => p_loc_recinfo.attribute9
         ,x_attribute10                    => p_loc_recinfo.attribute10
         ,x_attribute11                    => p_loc_recinfo.attribute11
         ,x_attribute12                    => p_loc_recinfo.attribute12
         ,x_attribute13                    => p_loc_recinfo.attribute13
         ,x_attribute14                    => p_loc_recinfo.attribute14
         ,x_attribute15                    => p_loc_recinfo.attribute15
         ,x_address_id                     => l_address_id
         ,x_addr_last_update_date          => SYSDATE
         ,x_addr_last_updated_by           => fnd_globaL.user_id
         ,x_addr_last_update_login         => fnd_global.login_id
         ,x_address_line1                  => p_adr_recinfo.address_line1
         ,x_address_line2                  => p_adr_recinfo.address_line2
         ,x_address_line3                  => p_adr_recinfo.address_line3
         ,x_address_line4                  => p_adr_recinfo.address_line4
         ,x_county                         => p_adr_recinfo.county
         ,x_city                           => p_adr_recinfo.city
         ,x_state                          => p_adr_recinfo.state
         ,x_province                       => p_adr_recinfo.province
         ,x_zip_code                       => p_adr_recinfo.zip_code
         ,x_country                        => p_adr_recinfo.country
         ,x_territory_id                   => p_adr_recinfo.territory_id
         ,x_addr_attribute_category        => p_adr_recinfo.addr_attribute_category
         ,x_addr_attribute1                => p_adr_recinfo.addr_attribute1
         ,x_addr_attribute2                => p_adr_recinfo.addr_attribute2
         ,x_addr_attribute3                => p_adr_recinfo.addr_attribute3
         ,x_addr_attribute4                => p_adr_recinfo.addr_attribute4
         ,x_addr_attribute5                => p_adr_recinfo.addr_attribute5
         ,x_addr_attribute6                => p_adr_recinfo.addr_attribute6
         ,x_addr_attribute7                => p_adr_recinfo.addr_attribute7
         ,x_addr_attribute8                => p_adr_recinfo.addr_attribute8
         ,x_addr_attribute9                => p_adr_recinfo.addr_attribute9
         ,x_addr_attribute10               => p_adr_recinfo.addr_attribute10
         ,x_addr_attribute11               => p_adr_recinfo.addr_attribute11
         ,x_addr_attribute12               => p_adr_recinfo.addr_attribute12
         ,x_addr_attribute13               => p_adr_recinfo.addr_attribute13
         ,x_addr_attribute14               => p_adr_recinfo.addr_attribute14
         ,x_addr_attribute15               => p_adr_recinfo.addr_attribute15
         ,x_assgn_area_chgd_flag           => p_assgn_area_chgd_flag
         ,x_return_status                  => x_return_status
         ,x_return_message                 => x_return_message
         ,x_source                         => p_loc_recinfo.source
         );

   END IF;

   pnp_debug_pkg.debug('PNT_LOCATIONS_PKG.Update_Locn_Row (-) ReturnStatus: '||x_return_status);
END Update_Locn_Row;


-----------------------------------------------------------------------
-- PROCEDURE : Insert_Locn_Row
-- PURPOSE   : This procedure calls pnt_locations_pkg.Insert_Row for the
--             pn_locations_all%ROWTYPE passed to it. Called from
--             Correct_Update_Row and Cascade_Child_Locn
-- IN PARAM  :
-- History   :
--  01-DEC-2004 Satish Tripathi o Created for Portfolio Status Enh BUG# 4030816.
--  02-AUG-2005 Satya Deep      o Added X_SOURCE in the call to
--                                pnt_locations_pkg.Insert_Row
-----------------------------------------------------------------------
PROCEDURE Insert_Locn_Row (
                          p_loc_recinfo                   IN pn_locations_all%ROWTYPE
                         ,p_adr_recinfo                   IN pn_addresses_all%ROWTYPE
                         ,p_change_mode                   IN VARCHAR2
                         ,x_return_status                 IN OUT NOCOPY VARCHAR2
                         ,x_return_message                IN OUT NOCOPY VARCHAR2
                         )
IS
   l_rowid                         ROWID;
   l_location_id                   pn_locations_all.location_id%TYPE;
   l_address_id                    pn_locations_all.address_id%TYPE;
BEGIN
   pnp_debug_pkg.debug('PNT_LOCATIONS_PKG.Insert_Locn_Row (+)  LocId: '||p_loc_recinfo.location_id
                       ||', LocCd: '||p_loc_recinfo.location_code
                       ||', Type: '||p_loc_recinfo.location_type_lookup_code);

   l_location_id  := p_loc_recinfo.location_id;
   l_address_id   := p_loc_recinfo.address_id;

   pnt_locations_pkg.Insert_Row
      (
          x_rowid                          => l_rowid
         ,x_last_update_date               => SYSDATE
         ,x_last_updated_by                => fnd_global.user_id
         ,x_creation_date                  => SYSDATE
         ,x_created_by                     => fnd_global.user_id
         ,x_last_update_login              => fnd_global.login_id
         ,x_location_id                    => l_location_id
         ,x_org_id                         => p_loc_recinfo.org_id
         ,x_location_park_id               => p_loc_recinfo.location_park_id
         ,x_location_type_lookup_code      => p_loc_recinfo.location_type_lookup_code
         ,x_space_type_lookup_code         => p_loc_recinfo.space_type_lookup_code
         ,x_function_type_lookup_code      => p_loc_recinfo.function_type_lookup_code
         ,x_standard_type_lookup_code      => p_loc_recinfo.standard_type_lookup_code
         ,x_location_alias                 => p_loc_recinfo.location_alias
         ,x_location_code                  => p_loc_recinfo.location_code
         ,x_building                       => p_loc_recinfo.building
         ,x_lease_or_owned                 => p_loc_recinfo.lease_or_owned
         ,x_class                          => p_loc_recinfo.class
         ,x_status_type                    => p_loc_recinfo.status_type
         ,x_floor                          => p_loc_recinfo.floor
         ,x_office                         => p_loc_recinfo.office
         ,x_max_capacity                   => p_loc_recinfo.max_capacity
         ,x_optimum_capacity               => p_loc_recinfo.optimum_capacity
         ,x_gross_area                     => p_loc_recinfo.gross_area
         ,x_rentable_area                  => p_loc_recinfo.rentable_area
         ,x_usable_area                    => p_loc_recinfo.usable_area
         ,x_assignable_area                => p_loc_recinfo.assignable_area
         ,x_common_area                    => p_loc_recinfo.common_area
         ,x_suite                          => p_loc_recinfo.suite
         ,x_allocate_cost_center_code      => p_loc_recinfo.allocate_cost_center_code
         ,x_uom_code                       => p_loc_recinfo.uom_code
         ,x_description                    => p_loc_recinfo.description
         ,x_parent_location_id             => p_loc_recinfo.parent_location_id
         ,x_interface_flag                 => p_loc_recinfo.interface_flag
         ,x_request_id                     => p_loc_recinfo.request_id
         ,x_program_id                     => p_loc_recinfo.program_id
         ,x_program_application_id         => p_loc_recinfo.program_application_id
         ,x_program_update_date            => p_loc_recinfo.program_update_date
         ,x_status                         => p_loc_recinfo.status
         ,x_property_id                    => p_loc_recinfo.property_id
         ,x_common_area_flag               => p_loc_recinfo.common_area_flag
         ,x_active_start_date              => p_loc_recinfo.active_start_date
         ,x_active_end_date                => p_loc_recinfo.active_end_date
         ,x_bookable_flag                  => p_loc_recinfo.bookable_flag
         ,x_occupancy_status_code          => p_loc_recinfo.occupancy_status_code
         ,x_assignable_emp                 => p_loc_recinfo.assignable_emp
         ,x_assignable_cc                  => p_loc_recinfo.assignable_cc
         ,x_assignable_cust                => p_loc_recinfo.assignable_cust
         ,x_disposition_code               => p_loc_recinfo.disposition_code
         ,x_acc_treatment_code             => p_loc_recinfo.acc_treatment_code
         ,x_attribute_category             => p_loc_recinfo.attribute_category
         ,x_attribute1                     => p_loc_recinfo.attribute1
         ,x_attribute2                     => p_loc_recinfo.attribute2
         ,x_attribute3                     => p_loc_recinfo.attribute3
         ,x_attribute4                     => p_loc_recinfo.attribute4
         ,x_attribute5                     => p_loc_recinfo.attribute5
         ,x_attribute6                     => p_loc_recinfo.attribute6
         ,x_attribute7                     => p_loc_recinfo.attribute7
         ,x_attribute8                     => p_loc_recinfo.attribute8
         ,x_attribute9                     => p_loc_recinfo.attribute9
         ,x_attribute10                    => p_loc_recinfo.attribute10
         ,x_attribute11                    => p_loc_recinfo.attribute11
         ,x_attribute12                    => p_loc_recinfo.attribute12
         ,x_attribute13                    => p_loc_recinfo.attribute13
         ,x_attribute14                    => p_loc_recinfo.attribute14
         ,x_attribute15                    => p_loc_recinfo.attribute15
         ,x_address_id                     => l_address_id
         ,x_address_line1                  => p_adr_recinfo.address_line1
         ,x_address_line2                  => p_adr_recinfo.address_line2
         ,x_address_line3                  => p_adr_recinfo.address_line3
         ,x_address_line4                  => p_adr_recinfo.address_line4
         ,x_county                         => p_adr_recinfo.county
         ,x_city                           => p_adr_recinfo.city
         ,x_state                          => p_adr_recinfo.state
         ,x_province                       => p_adr_recinfo.province
         ,x_zip_code                       => p_adr_recinfo.zip_code
         ,x_country                        => p_adr_recinfo.country
         ,x_territory_id                   => p_adr_recinfo.territory_id
         ,x_addr_last_update_date          => SYSDATE
         ,x_addr_last_updated_by           => fnd_globaL.user_id
         ,x_addr_creation_date             => SYSDATE
         ,x_addr_created_by                => fnd_global.user_id
         ,x_addr_last_update_login         => fnd_global.login_id
         ,x_addr_attribute_category        => p_adr_recinfo.addr_attribute_category
         ,x_addr_attribute1                => p_adr_recinfo.addr_attribute1
         ,x_addr_attribute2                => p_adr_recinfo.addr_attribute2
         ,x_addr_attribute3                => p_adr_recinfo.addr_attribute3
         ,x_addr_attribute4                => p_adr_recinfo.addr_attribute4
         ,x_addr_attribute5                => p_adr_recinfo.addr_attribute5
         ,x_addr_attribute6                => p_adr_recinfo.addr_attribute6
         ,x_addr_attribute7                => p_adr_recinfo.addr_attribute7
         ,x_addr_attribute8                => p_adr_recinfo.addr_attribute8
         ,x_addr_attribute9                => p_adr_recinfo.addr_attribute9
         ,x_addr_attribute10               => p_adr_recinfo.addr_attribute10
         ,x_addr_attribute11               => p_adr_recinfo.addr_attribute11
         ,x_addr_attribute12               => p_adr_recinfo.addr_attribute12
         ,x_addr_attribute13               => p_adr_recinfo.addr_attribute13
         ,x_addr_attribute14               => p_adr_recinfo.addr_attribute14
         ,x_addr_attribute15               => p_adr_recinfo.addr_attribute15
         ,x_change_mode                    => p_change_mode
         ,x_return_status                  => x_return_status
         ,x_return_message                 => x_return_message
         ,x_source                         => p_loc_recinfo.source
         );

    IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       APP_EXCEPTION.Raise_Exception;
    END IF;

   pnp_debug_pkg.debug('PNT_LOCATIONS_PKG.Insert_Locn_Row (-) ReturnStatus: '||x_return_status);
END Insert_Locn_Row;

/* --- CHANGED functions and procedures for MOAC START --- */
/*============================================================================+
--  NAME         : get_location_id
--  DESCRIPTION  : This FUNCTION RETURNs Location id for given location code
--                 and location type look up code.
--  SCOPE        : PUBLIC
--  INVOKED FROM : forms libraries
--  ARGUMENTS    : IN : p_location_code, p_loctn_type_lookup_code
--  RETURNS      : Location id
--  HISTORY      :
--  24-Jun-05  piagrawa         o Created
--  IMPORTANT - Use this function once MOAC is enabled. All form libraries
--              must call this.
+============================================================================*/
FUNCTION get_location_id (
                          p_location_code IN VARCHAR2,
                          p_loctn_type_lookup_code IN VARCHAR2,
                          p_org_id IN NUMBER
                          ) RETURN number
IS

l_location_id      NUMBER := NULL;

BEGIN


   SELECT location_id
   INTO   l_location_id
   FROM   pn_locations_all
   WHERE  location_code = p_location_code
   AND    location_type_lookup_code = p_loctn_type_lookup_code
   AND    org_id = p_org_id
   AND    ROWNUM = 1;

   RETURN l_location_id;

EXCEPTION
   when no_data_found then
      return l_location_id;
   when others then
      return l_location_id;

END get_location_id ;


/*============================================================================+
--  NAME         : check_unique_location_code
--  DESCRIPTION  : This procedure checks if location code is unique.
--  INVOKED FROM : forms libraries
--  ARGUMENTS    : IN : x_return_status, x_location_id, x_location_code,
--                      x_active_start_date, x_active_end_date
--  RETURNS      : NONE
--  HISTORY      :
--  24-Jun-05  piagrawa         o Created
--  IMPORTANT - Use this function once MOAC is enabled. All form libraries
--              must call this.
+============================================================================*/
PROCEDURE check_unique_location_code (
                            x_return_status            IN OUT NOCOPY VARCHAR2,
                            x_location_id                     NUMBER,
                            x_location_code                   VARCHAR2,
                            x_active_start_date               DATE,
                            x_active_end_date                 DATE,
                            x_org_id                          NUMBER
                            ) IS
   l_dummy        NUMBER;

   CURSOR loc_code_cur IS
      SELECT 1
      FROM   DUAL
      WHERE  EXISTS (SELECT 1
                     FROM   pn_locations_all pnl
                     WHERE  pnl.location_code = x_location_code
                     AND    pnl.active_start_date = x_active_start_date
                     AND    pnl.active_end_date = NVL(x_active_end_date,g_end_of_time)
                     AND    ((x_location_id IS NULL) OR (pnl.location_id <> x_location_id))
                     AND    pnl.org_id = x_org_id
                    );

BEGIN

   pnp_debug_pkg.debug('PNT_LOCATIONS_PKG.check_unique_location_code (+)');

   OPEN loc_code_cur;
      FETCH loc_code_cur INTO l_dummy;
   CLOSE loc_code_cur;

   IF l_dummy = 1 THEN
      fnd_message.set_name ('PN','PN_DUP_LOCATION_CODE');
      fnd_message.set_token('LOCATION_CODE', x_location_code);
      x_return_status := 'E';
   END IF;

   pnp_debug_pkg.debug('PNT_LOCATIONS_PKG.check_unique_location_code (-) ReturnStatus: '||x_return_status);
END check_unique_location_code;


/*============================================================================+
--  NAME         : check_unique_building
--  DESCRIPTION  : This procedure checks if building is unique.
--  INVOKED FROM : forms libraries
--  ARGUMENTS    : IN : x_return_status, x_location_id, x_building,
--                      x_active_start_date, x_active_end_date
--  RETURNS      : NONE
--  HISTORY      :
--  24-Jun-05  piagrawa         o Created
--  IMPORTANT - Use this function once MOAC is enabled. All form libraries
--              must call this.
+============================================================================*/
PROCEDURE check_unique_building (
                            x_return_status            IN OUT NOCOPY VARCHAR2,
                            x_location_id                     NUMBER,
                            x_building                        VARCHAR2,
                            x_active_start_date               DATE,
                            x_active_end_date                 DATE,
                            x_org_id                          NUMBER
                            ) IS
   l_dummy NUMBER;
   CURSOR building_cur IS
      SELECT 1
      FROM   DUAL
      WHERE  EXISTS (SELECT 1
                     FROM   pn_locations_all pnl
                     WHERE  UPPER(pnl.building) = UPPER(x_building)
                     AND    ((x_location_id IS NULL) OR (pnl.location_id <> x_location_id))
                     AND    pnl.active_start_date <= x_active_start_date
                     AND    pnl.active_end_date   >= x_active_end_date
                     AND    pnl.org_id  = x_org_id
                    );

BEGIN

   pnp_debug_pkg.debug('PNT_LOCATIONS_PKG.check_unique_building (+)');

   OPEN building_cur;
      FETCH building_cur INTO l_dummy;
   CLOSE building_cur;

   IF l_dummy = 1 THEN
      fnd_message.set_name ('PN','PN_DUP_BUILDING');
      fnd_message.set_token('BUILDING', x_building);
      x_return_status := 'E';
   END IF;

   pnp_debug_pkg.debug('PNT_LOCATIONS_PKG.check_unique_building (-) ReturnStatus: '||x_return_status);
END check_unique_building;


-------------------------------------------------------------------------------
-- PROCEDURE : check_unique_building_alias
-- PURPOSE   : The function validates that the alias and hence the code
--             of a building/land is unique.
-- IN PARAM  : Location alias, Location Type Lookup Code, Location ID
-- History   :
--  24-Jun-05  piagrawa         o Created
--  IMPORTANT - Use this function once MOAC is enabled. All form libraries
--              must call this.
-------------------------------------------------------------------------------
FUNCTION check_unique_building_alias
  ( p_location_id               NUMBER,
    p_location_alias            VARCHAR2,
    p_location_type_lookup_code VARCHAR2,
    p_org_id                    NUMBER)
RETURN BOOLEAN IS

l_dup_alias NUMBER;
l_msg_name  VARCHAR2(30);
l_token     VARCHAR2(30);

CURSOR dupAlias IS
   SELECT loc.location_id AS location_id
   FROM   pn_locations_all loc
   WHERE  loc.LOCATION_TYPE_LOOKUP_CODE = p_location_type_lookup_code
   AND    loc.location_alias = p_location_alias
   AND    loc.location_id <> NVL(p_location_id,-1)
   AND    loc.org_id = p_org_id;

BEGIN

IF p_location_type_lookup_code IN ('BUILDING', 'LAND') THEN
  FOR i IN dupAlias LOOP
    l_dup_alias := i.location_id;
  END LOOP;
END IF;

IF l_dup_alias IS NOT NULL THEN
  l_msg_name := 'PN_DUP_'||p_location_type_lookup_code||'_ALIAS';
  l_token := p_location_type_lookup_code||'_ALIAS';
  fnd_message.set_name('PN', l_msg_name);
  fnd_message.set_token(l_token, p_location_alias);
  RETURN FALSE;
ELSE
   RETURN TRUE;
END IF;

END check_unique_building_alias;

-------------------------------------------------------------------------------
-- PROCDURE     : check_unique_location_alias
-- INVOKED FROM :
-- PURPOSE      : checks unique location alias
-- HISTORY      :
-- 13-JUL-05  hrodda o Bug 4284035 - Replaced PN_LOCATION with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE check_unique_location_alias (
                            x_return_status            IN OUT NOCOPY VARCHAR2,
                            x_location_id                     NUMBER,
                            x_parent_location_id              NUMBER,
                            x_location_type_lookup_code       VARCHAR2,
                            x_location_alias                  VARCHAR2,
                            x_active_start_date               DATE,
                            x_active_end_date                 DATE,
                            x_org_id                          NUMBER
                            )
IS

   l_dummy                        NUMBER;
   l_set_name                     VARCHAR2(30);
   l_set_token                    VARCHAR2(30);

   CURSOR loc_alias_cur IS
      SELECT 1
      FROM   DUAL
      WHERE  EXISTS (SELECT 1
                     FROM   pn_locations_all pnl
                     WHERE  pnl.location_alias = x_location_alias
                     AND    location_type_lookup_code = x_location_type_lookup_code
                     AND    ((x_location_id IS NULL) OR (pnl.location_id <> x_location_id))
                     AND    pnl.parent_location_id = x_parent_location_id
                     AND    pnl.active_start_date = x_active_start_date
                     AND    pnl.active_end_date = NVL(x_active_end_date,g_end_of_time)
                     AND    pnl.org_id = x_org_id
                    );

BEGIN

   pnp_debug_pkg.debug('PNT_LOCATIONS_PKG.check_unique_location_alias (+)');
   pnp_debug_pkg.debug('  ChkUniAlis=> In Parameters :: LocAlias: '||x_location_alias||', LocId: '||x_location_id
                       ||', Type: '||x_location_type_lookup_code);
   pnp_debug_pkg.debug('  ChkUniAlis=>   ActStrDate    : '||TO_CHAR(x_active_start_date, 'MM/DD/YYYY')
                       ||', ActEndDate    : '||TO_CHAR(x_active_end_date, 'MM/DD/YYYY'));

   -- If the location alias is null then we don't need to check
   -- This will happen only for data created by the external system.

   IF (x_location_alias IS NULL) THEN
      RETURN;
   END IF;

   IF x_location_type_lookup_code IN ('BUILDING', 'LAND', 'FLOOR', 'PARCEL', 'OFFICE', 'SECTION') THEN
      l_set_name  := 'PN_DUP_'||x_location_type_lookup_code||'_ALIAS';
      l_set_token := x_location_type_lookup_code||'_ALIAS';
      pnp_debug_pkg.debug('    ChkUniAlis> Duplicate');
   ELSE
      -- we should never reach this place
      x_return_status := 'E';
   END IF;

   OPEN loc_alias_cur;
      FETCH loc_alias_cur INTO l_dummy;
   CLOSE loc_alias_cur;

   IF l_dummy = 1 THEN
      fnd_message.set_name ('PN',l_set_name);
      fnd_message.set_token(l_set_token, x_location_alias);
      x_return_status := 'E';
      pnp_debug_pkg.debug('    ChkUniAlis> Error');
   END IF;

   pnp_debug_pkg.debug('PNT_LOCATIONS_PKG.check_unique_location_alias (-) ReturnStatus: '||x_return_status);

END check_unique_location_alias;

/* --- CHANGED functions and procedures for MOAC END --- */

---------------------------------------------------------------------------------------
-- End of Pkg
---------------------------------------------------------------------------------------
END PNT_LOCATIONS_PKG ;

/
