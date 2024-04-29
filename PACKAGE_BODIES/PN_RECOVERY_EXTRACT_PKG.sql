--------------------------------------------------------
--  DDL for Package Body PN_RECOVERY_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_RECOVERY_EXTRACT_PKG" AS
/* $Header: PNRCEXTB.pls 120.5.12010000.2 2010/04/26 18:57:26 asahoo ship $ */



------------------------------ DECLARATIONS ----------------------------------+

TYPE exp_cls_line_use_tbl  IS TABLE OF BOOLEAN INDEX BY BINARY_INTEGER;
TYPE exp_cls_line_mst_tbl  IS TABLE OF pn_rec_expcl_dtlln%ROWTYPE INDEX BY BINARY_INTEGER;
TYPE exp_cls_line_dtl_tbl  IS TABLE OF pn_rec_expcl_dtlacc%ROWTYPE INDEX BY BINARY_INTEGER;
TYPE area_cls_line_dtl_tbl IS TABLE OF pn_rec_arcl_dtlln%ROWTYPE INDEX BY BINARY_INTEGER;
TYPE area_cls_line_hdr_tbl IS TABLE OF pn_rec_arcl_dtl%ROWTYPE INDEX BY BINARY_INTEGER;
TYPE area_cls_exc_tbl      IS TABLE OF pn_rec_arcl_exc%ROWTYPE INDEX BY BINARY_INTEGER;

bad_input_exception        EXCEPTION;
uom_exception              EXCEPTION;
currency_exception         EXCEPTION;

g_batch_commit_size        CONSTANT NUMBER := 5000;

----------------------------- AREA CLASS LINE --------------------------------+

------------------------------------------------------------------------------+
-- PROCEDURE : process_vacancy
-- PARAMETERS: p_start_date   => start date
--             p_end_date     => end date
--             p_area         => area associated with the two dates
--             p_date_table   => part of data structure
--             p_number_table => part of data structure
--             p_subtract     => if TRUE, then add, if FALSE, then subtract
--
-- INPUT VALIDATION :
-- o area cannot be null or < 0.
-- o start date OR end date cannot be null, start date <= end date.
--
-- UNDERLYING DATA STRUCTURE:
-- o The data structure consists of a table of dates and a table of numbers.
-- o Combined, they store vacancy information
-- o Example:
-- o 1. Given : date table DT and a number table NT.
-- o 2. Given : from date D1 to D2, vacancy is V1, from D2 to D3, vacancy is V2.
-- o 3. Result: data structure is as follows: DT(0) = D1, DT(1) = D2,
--      DT(2) = D3, NT(0) = V1, NT(1) = V2.
--
-- ASSUMES
-- o p_date_table.count = p_number_table.count + 1 IF both are not null
--
-- DESCRIPTION :
-- o Given a start date, end date, and area, the procedure UPDATES a
--   data structure
-- o the procedure does the following:
-- oo search through the given data structure to isolate the start date and
--    SORTS it into place
-- oo mark where the start date was isolated
-- oo continue the search, this time to isolate for the end date and again
--    SORTS it into place
-- oo mark where the end date was isolated
-- oo copy the rest of the data structure, IF necessary.
--
-- o special cases to watch out for :
-- oo When the start date and end date are BOTH LESS THAN DT(0)
-- oo Or BOTH GREATER THAN DT(DT.count - 1)
--
-- HISTORY:
-- 22-OCT-02 ftanudja created
-- 24-FEB-05 ftanudja o Added 'ELSIF p_date_table(j) <> l_end_date THEN'
--                      before adding '0' in end dt processing. #4194998
-- 15-JUL-05 SatyaDeep o Replaced base views with their _ALL tables
------------------------------------------------------------------------------+

PROCEDURE process_vacancy(p_start_date   DATE,
                          p_end_date     DATE,
                          p_area         NUMBER,
                          p_date_table   IN OUT NOCOPY date_table_type,
                          p_number_table IN OUT NOCOPY number_table_type,
                          p_add          BOOLEAN)
IS
  l_date_table   date_table_type;
  l_number_table number_table_type;
  l_start_date   DATE;
  l_end_date     DATE;
  l_area         NUMBER := p_area;
  l_index        NUMBER;
  l_flag         BOOLEAN := FALSE;
  l_info         VARCHAR2(100);
  l_desc         VARCHAR2(100) := 'pn_recovery_extract_pkg.process_vacancy';

BEGIN

  pnp_debug_pkg.log(l_desc ||' (+)');

  l_info := ' checking validity on inputs';
  pnp_debug_pkg.log(l_info);

  IF p_area IS NULL OR
     p_area < 0 OR
     p_start_date IS NULL OR
     p_end_date IS NULL OR
     p_start_date > p_end_date THEN
      app_exception.raise_exception;
  END IF;

  l_info := ' adjusting input';
  pnp_debug_pkg.log(l_info);

  l_start_date := TRUNC(p_start_date);
  l_end_date := TRUNC(p_end_date) + 1;

  IF NOT p_add THEN
     l_area := -1 * l_area;
  END IF;

  IF p_date_table.count = 0 THEN

     l_info := ' initializing table';
     pnp_debug_pkg.log(l_info);

     p_date_table.delete;
     p_number_table.delete;

     p_date_table(0):= l_start_date;
     p_date_table(1):= l_end_date;
     p_number_table(0) := l_area;

  ELSE

     l_info := ' processing start date ';
     pnp_debug_pkg.log(l_info);

     FOR i IN 0 .. p_date_table.count - 1 LOOP

       IF p_date_table(i) >= l_start_date THEN
          IF (l_number_table.count = 0) THEN
             IF p_date_table(i) <> l_start_date THEN
                 l_number_table(l_number_table.count) := l_area;
             END IF;
          END IF;
          l_date_table(l_date_table.count) := l_start_date;
          l_index := i;
          l_flag := TRUE;
          exit;
       ELSE
          l_date_table(l_date_table.count) := p_date_table(i);
          IF p_number_table.exists(i) THEN
             l_number_table(l_number_table.count) := p_number_table(i);
          END IF;
       END IF;

     END LOOP;

     IF NOT l_flag THEN
        l_date_table(l_date_table.count) := l_start_date;
        l_number_table(l_number_table.count) := 0;
        l_index := l_number_table.count - 1;
     ELSE
        l_flag := FALSE;
     END IF;

     l_info := ' processing end date ';
     pnp_debug_pkg.log(l_info);

     FOR j IN l_index .. p_date_table.count - 1 LOOP

       IF p_date_table(j) >= l_end_date THEN
          l_date_table(l_date_table.count) := l_end_date;
          IF j >= 1 THEN
             l_number_table(l_number_table.count) := p_number_table(j-1) + l_area;
          ELSIF p_date_table(j) <> l_end_date THEN
             l_number_table(l_number_table.count) := 0;
          END IF;

          l_index := j;
          exit;
       ELSE
          IF l_start_date > p_date_table(j) THEN
             l_number_table(l_number_table.count) := l_area;
             l_date_table(l_date_table.count) := l_end_date;
             l_flag := TRUE;
          ELSE
             IF l_start_date <> p_date_table(j) THEN
               l_date_table(l_date_table.count) := p_date_table(j);
               IF j>=1 THEN
                  l_number_table(l_number_table.count) := p_number_table(j-1) + l_area;
               END IF;
               l_index := j;
             END IF;
          END IF;

       END IF;

     END LOOP;

     IF NOT l_flag THEN

        l_info := ' processing the remaining ';
        pnp_debug_pkg.log(l_info);

        IF p_date_table(l_index) < l_end_date THEN
           l_date_table(l_date_table.count) := l_end_date;
           l_number_table(l_number_table.count) := l_area;
        ELSE

           FOR k IN l_index .. p_date_table.count - 1 LOOP
             IF l_end_date <> p_date_table(k) THEN
                l_date_table(l_date_table.count) := p_date_table(k);
             END IF;

             IF k > 0 THEN
                IF l_end_date <> p_date_table(k) THEN
                   l_number_table(l_number_table.count) := p_number_table(k - 1);
                END IF;
             END IF;
           END LOOP;

        END IF;

     END IF;

     p_date_table := l_date_table;
     p_number_table := l_number_table;

  END IF;

  pnp_debug_pkg.log(l_desc ||' (-)');

EXCEPTION
  WHEN OTHERS THEN
     pnp_debug_pkg.log(l_desc || ': Error while ' || l_info);
     raise;
END;

------------------------------------------------------------------------------+
-- PROCEDURE  : find_area_ovr_values
-- DESCRIPTION:
-- 1. Given: data table p_ovr, parameters p_from, p_to, p_loc_id, etc.
-- 2. Search through p_ovr using the parameter criteria.
-- 3. If match found, check if p_keep_override = Y.
-- 4. If true, return override values p_weighted_area_ovr, etc.
-- 5. Otherwise, just return the corresponding item id.
--
-- HISTORY:
-- 19-MAR-03 ftanudja o created
-- 15-MAY-03 ftanudja o adjusted for .._ovr_flag logic.
-- 05-AUG-03 ftanudja o removed from date and to date restriction from
--                      the main if condition. 3077454.
--                    o removed param p_vacant_area_ovr.
--15-JUL-05 SatyaDeep o Replaced base views with their _ALL tables
------------------------------------------------------------------------------+

PROCEDURE find_area_ovr_values(
            p_ovr                   area_cls_line_dtl_tbl,
            p_loc_id                pn_rec_arcl_dtlln.location_id%TYPE,
            p_cust_id               pn_rec_arcl_dtlln.cust_account_id%TYPE,
            p_from                  pn_rec_arcl_dtlln.from_date%TYPE,
            p_to                    pn_rec_arcl_dtlln.to_date%TYPE,
            p_weighted_avg_ovr      OUT NOCOPY pn_rec_arcl_dtlln.weighted_avg_ovr%TYPE,
            p_occupied_area_ovr     OUT NOCOPY pn_rec_arcl_dtlln.occupied_area_ovr%TYPE,
            p_assigned_area_ovr     OUT NOCOPY pn_rec_arcl_dtlln.assigned_area_ovr%TYPE,
            p_exc_area_ovr_flag     OUT NOCOPY pn_rec_arcl_dtlln.exclude_area_ovr_flag%TYPE,
            p_exc_prorata_ovr_flag  OUT NOCOPY pn_rec_arcl_dtlln.exclude_prorata_ovr_flag%TYPE,
            p_area_cls_dtl_line_id  OUT NOCOPY pn_rec_arcl_dtlln.area_class_dtl_line_id%TYPE,
            p_found                 IN OUT NOCOPY BOOLEAN,
            p_keep_override         VARCHAR2
          )
IS
   l_info VARCHAR2(300);
   l_desc VARCHAR2(100) := 'pn_recovery_extract_pkg.find_area_ovr_values' ;
BEGIN

   pnp_debug_pkg.log(l_desc ||' (+)');

   p_weighted_avg_ovr     := null;
   p_occupied_area_ovr    := null;
   p_assigned_area_ovr    := null;
   p_exc_area_ovr_flag    := null;
   p_exc_prorata_ovr_flag := null;
   p_area_cls_dtl_line_id := null;

   FOR i IN 0 .. p_ovr.COUNT - 1 LOOP

      l_info := ' checking overrides for loc id: '|| p_loc_id;
      pnp_debug_pkg.log(l_info);

      IF p_ovr(i).location_id     = p_loc_id  AND
         (p_ovr(i).cust_account_id = p_cust_id OR (p_ovr(i).cust_account_id IS NULL AND p_cust_id IS NULL)) THEN

         IF p_keep_override = 'Y' THEN
            p_weighted_avg_ovr     := p_ovr(i).weighted_avg_ovr;
            p_occupied_area_ovr    := p_ovr(i).occupied_area_ovr;
            p_assigned_area_ovr    := p_ovr(i).assigned_area_ovr;

            -- check if overriden by comparing old value to new value

            IF p_ovr(i).exclude_area_flag <> p_ovr(i).exclude_area_ovr_flag THEN
               p_exc_area_ovr_flag    := p_ovr(i).exclude_area_ovr_flag;
            END IF;

            IF p_ovr(i).exclude_prorata_flag <> p_ovr(i).exclude_prorata_ovr_flag THEN
               p_exc_prorata_ovr_flag := p_ovr(i).exclude_prorata_ovr_flag;
            END IF;
         END IF;

         IF p_found IS NOT NULL THEN
            p_found := TRUE;
            p_area_cls_dtl_line_id := p_ovr(i).area_class_dtl_line_id;
         END IF;

         exit;

      END IF;
   END LOOP;

   pnp_debug_pkg.log(l_desc ||' (-)');

EXCEPTION
  WHEN OTHERS THEN
     pnp_debug_pkg.log(l_desc || ': Error while ' || l_info);
     raise;

END find_area_ovr_values;

------------------------------------------------------------------------------+
-- PROCEDURE : get_asgnbl_area_calc
--
-- DESCRIPTION :
-- o checks and processes input parameters
-- o derives occupancy percentage, weighted average, include flag, and occupied area
--
-- ASSUMES:
-- o p_landlord_from_date <= p_landlord_to_date
--
-- INPUT VALIDATION :
-- o IF p_rec_start_date IS NULL THEN default to landlord from date
-- o IF p_rec_end_date IS NULL THEN default to landlord end date
-- o IF p_rec_start_date < landlord from date THEN make p_rec_start_date = landlord from date
-- o IF p_rec_end_date > landlord to date THEN make p_rec_end_date = landlord to date
-- o IF landlord start date = landlord end date THEN return 0 as occupancy %
-- o start date OR end date cannot be null, and the former cannot be greater than the latter
--
-- HISTORY:
-- 22-OCT-02 ftanudja o created
-- 20-AUG-03 ftanudja o changed occup_pct calc to include st dt. 3107683.
------------------------------------------------------------------------------+

PROCEDURE get_area_cls_dtl_calc(
            p_from_date          DATE,
            p_to_date            DATE,
            p_rec_from_date      IN OUT NOCOPY DATE,
            p_rec_to_date        IN OUT NOCOPY DATE,
            p_as_of_date         DATE,
            p_assigned_area      NUMBER,
            p_exc_type_code      VARCHAR2,
            p_occup_pct          OUT NOCOPY pn_rec_arcl_dtlln.occupancy_pct%TYPE,
            p_weighted_avg       OUT NOCOPY pn_rec_arcl_dtlln.weighted_avg%TYPE,
            p_occup_area         OUT NOCOPY pn_rec_arcl_dtlln.occupied_area%TYPE,
            p_exc_prorata_flag   OUT NOCOPY pn_rec_arcl_dtlln.exclude_prorata_flag%TYPE,
            p_exc_area_flag      OUT NOCOPY pn_rec_arcl_dtlln.exclude_area_flag%TYPE,
            p_include_flag       OUT NOCOPY pn_rec_arcl_dtlln.include_flag%TYPE)
IS
   l_info VARCHAR2(300);
   l_desc VARCHAR2(100) := 'pn_recovery_extract_pkg.get_area_cls_dtl_calc' ;
BEGIN

   pnp_debug_pkg.log(l_desc ||' (+)');

   l_info := ' validating dates ';
   pnp_debug_pkg.log(l_info);

   IF p_rec_from_date IS NULL THEN
      p_rec_from_date := p_from_date;
   END IF;

   IF p_rec_to_date IS NULL THEN
      p_rec_to_date := p_to_date;
   END IF;

   IF p_rec_from_date < p_from_date THEN
      p_rec_from_date := p_from_date;
   END IF;

   IF p_rec_to_date > p_to_date THEN
      p_rec_to_date := p_to_date;
   END IF;

   l_info := ' calculating occupancy and weighted avg';
   pnp_debug_pkg.log(l_info);

   -- handle divide by zero case; make start date inclusive
   p_occup_pct := TO_NUMBER(p_to_date - (p_from_date - 1));
   IF p_occup_pct <> 0 THEN
      p_occup_pct := TO_NUMBER((p_rec_to_date - (p_rec_from_date - 1)) / p_occup_pct) * 100;
      p_occup_pct := ROUND(p_occup_pct, 2);
   END IF;

   IF (p_as_of_date >= p_rec_from_date) AND (p_as_of_date <= p_rec_to_date) THEN
      p_occup_area := p_assigned_area;
   ELSE
      p_occup_area := 0;
   END IF;

   p_weighted_avg := ROUND(p_occup_pct / 100 * p_assigned_area, 2);

   IF ((p_as_of_date >= p_rec_from_date) AND (p_as_of_date <= p_rec_to_date)) THEN
      p_include_flag := 'Y';
   ELSE
      p_include_flag := 'N';
   END IF;

   l_info := ' determining flags ';
   pnp_debug_pkg.log(l_info);

   IF p_exc_type_code = 'AREA' THEN
      p_exc_area_flag := 'Y';
      p_exc_prorata_flag := 'N';
   ELSIF p_exc_type_code = 'PRORATA' THEN
      p_exc_area_flag := 'N';
      p_exc_prorata_flag := 'Y';
   ELSIF p_exc_type_code = 'AREAPRORATA' THEN
      p_exc_area_flag := 'Y';
      p_exc_prorata_flag := 'Y';
   ELSIF p_exc_type_code IS NULL THEN
      p_exc_area_flag := 'N';
      p_exc_prorata_flag := 'N';
   END IF;

   pnp_debug_pkg.log(l_desc ||' (-)');

EXCEPTION
  WHEN OTHERS THEN
     pnp_debug_pkg.log(l_desc || ': Error while ' || l_info);
     raise;
END;

------------------------------------------------------------------------------+
-- FUNCTION   : is_totally_vacant
-- DESCRIPTION:
-- 1. Given :p_from, p_to date, and area p_num.
-- 2. Checks in the data structure whether location is fully occupied during.
--
-- HISTORY:
-- 19-MAR-03 ftanudja o created
------------------------------------------------------------------------------+
FUNCTION is_totally_vacant(
            p_from     DATE,
            p_to       DATE,
            p_num      NUMBER,
            p_date_tbl date_table_type,
            p_num_tbl  number_table_type
         ) RETURN BOOLEAN
IS
   l_result BOOLEAN := FALSE;
   l_desc VARCHAR2(100) := 'pn_recovery_extract_pkg.is_totally_vacant' ;
   l_info VARCHAR2(300);
BEGIN

   pnp_debug_pkg.log(l_desc ||' (+)');

   FOR i IN 0 .. p_date_tbl.count - 2 LOOP
      l_info := ' searching through table ';
      pnp_debug_pkg.log(l_info);
      IF p_from >= p_date_tbl(i) AND
         p_to <= p_date_tbl(i+1) AND
         p_num = p_num_tbl(i) THEN
          l_result := TRUE;
          exit;
      END IF;
   END LOOP;

   RETURN l_result;

   pnp_debug_pkg.log(l_desc ||' (-)');

EXCEPTION
  WHEN OTHERS THEN
     pnp_debug_pkg.log(l_desc || ': Error while ' || l_info);
     raise;
END;

------------------------------------------------------------------------------+
-- PROCEDURE : insert_vacancy_data
--
-- ASSUMES: p_date_table.count = p_number_table.count + 1 IF both are not null
--
-- DESCRIPTION :
-- o given a p_date_table and p_num_table, inserts the values into the
--   area class line details pl/sql table.
-- o while doing so, derive flags and find override values / totals if applies.
--
-- VALIDATION :
-- o IF p_date_table(i) AND p_date_table(i+1) are BOTH OUTSIDE the scope of
--   landlord_from and landlord_to date, DO NOT insert
-- o IF from date < landlord from date THEN from date = landlord from date
-- o IF to date < landlord to date THEN to date = landlord to date
-- o Insert only data with FULL vacancies. Compare data structure with
--   a reference data structure to determine full vacancies.
--
-- HISTORY:
-- 22-OCT-02 ftanudja o created.
-- 06-JUN-03 ftanudja o fix area totals calculation.
-- 05-AUG-03 ftanudja o changed vacant area ovr calculation.
-- 15-AUG-03 ftanudja o changed total asgnbl area calculation. 3099669.
------------------------------------------------------------------------------+

PROCEDURE insert_vacancy_data(
             p_location_id           pn_locations.location_id%TYPE,
             p_property_id           pn_locations.property_id%TYPE,
             p_date_table            date_table_type,
             p_num_table             number_table_type,
             p_ref_date_table        date_table_type,
             p_ref_num_table         number_table_type,
             p_from_date             DATE,
             p_to_date               DATE,
             p_as_of_date            DATE,
             p_assignable_area       NUMBER,
             p_curnt_ovr             area_cls_line_dtl_tbl,
             p_prior_ovr             area_cls_line_dtl_tbl,
             p_data_tbl              IN OUT NOCOPY area_cls_line_dtl_tbl,
             p_total_tbl             IN OUT NOCOPY area_cls_line_hdr_tbl,
             p_keep_override         VARCHAR2,
             p_regenerate            VARCHAR2
           )
IS
   l_counter                 NUMBER;
   l_found                   BOOLEAN;
   l_from                    DATE;
   l_to                      DATE;
   l_num                     NUMBER;
   l_include_flag            VARCHAR2(1);
   l_excl_prorata_flag       VARCHAR2(1);
   l_excl_area_flag          VARCHAR2(1);
   l_area_class_dtl_line_id  NUMBER;
   l_occup_area_ovr          NUMBER;
   l_weighted_avg_ovr        NUMBER;
   l_assigned_area_ovr       NUMBER;
   l_excl_prorata_ovr_flag   VARCHAR2(1);
   l_excl_area_ovr_flag      VARCHAR2(1);
   l_dummy                   NUMBER;
   l_info                    VARCHAR2(300);
   l_desc                    VARCHAR2(100) := 'pn_recovery_extract_pkg.insert_vacancy_data' ;

BEGIN

   pnp_debug_pkg.log(l_desc ||' (+)');

   FOR i IN 0 .. p_date_table.count - 2 LOOP

      l_from := p_date_table(i);
      l_to := p_date_table(i+1) - 1;
      l_num := p_num_table(i);
      l_include_flag := 'N';

      -- IF l_from AND l_to are
      -- BOTH BEFORE landlord_from_dt OR
      -- BOTH AFTER landlord_to_dt
      -- THEN don't insert

      IF l_to > p_from_date AND
         l_from < p_to_date AND
         is_totally_vacant(
            p_from     => l_from,
            p_to       => l_to,
            p_num      => l_num,
            p_date_tbl => p_ref_date_table,
            p_num_tbl  => p_ref_num_table
         ) THEN

          get_area_cls_dtl_calc(
             p_from_date         => p_from_date,
             p_to_date           => p_to_date,
             p_rec_from_date     => l_from,
             p_rec_to_date       => l_to,
             p_as_of_date        => p_as_of_date,
             p_assigned_area     => 0,
             p_exc_type_code     => null,
             p_occup_pct         => l_dummy,
             p_weighted_avg      => l_dummy,
             p_occup_area        => l_dummy,
             p_exc_prorata_flag  => l_excl_prorata_flag,
             p_exc_area_flag     => l_excl_area_flag,
             p_include_flag      => l_include_flag
          );

          l_info := ' finding override values ';
          pnp_debug_pkg.log(l_info);

          l_found := FALSE;

          IF p_regenerate = 'Y' THEN

              find_area_ovr_values(
                 p_ovr                   => p_curnt_ovr,
                 p_loc_id                => p_location_id,
                 p_cust_id               => null,
                 p_from                  => l_from,
                 p_to                    => l_to,
                 p_weighted_avg_ovr      => l_weighted_avg_ovr,
                 p_occupied_area_ovr     => l_occup_area_ovr,
                 p_assigned_area_ovr     => l_assigned_area_ovr,
                 p_exc_area_ovr_flag     => l_excl_area_ovr_flag,
                 p_exc_prorata_ovr_flag  => l_excl_prorata_ovr_flag,
                 p_area_cls_dtl_line_id  => l_area_class_dtl_line_id,
                 p_found                 => l_found,
                 p_keep_override         => p_keep_override
              );

           END IF;

           IF NOT l_found  THEN

              IF p_regenerate = 'N' THEN l_found := null; END IF;

              find_area_ovr_values(
                 p_ovr                   => p_prior_ovr,
                 p_loc_id                => p_location_id,
                 p_cust_id               => null,
                 p_from                  => l_from,
                 p_to                    => l_to,
                 p_weighted_avg_ovr      => l_weighted_avg_ovr,
                 p_occupied_area_ovr     => l_occup_area_ovr,
                 p_assigned_area_ovr     => l_assigned_area_ovr,
                 p_exc_area_ovr_flag     => l_excl_area_ovr_flag,
                 p_exc_prorata_ovr_flag  => l_excl_prorata_ovr_flag,
                 p_area_cls_dtl_line_id  => l_area_class_dtl_line_id,
                 p_found                 => l_found,
                 p_keep_override         => p_keep_override
              );

           END IF;

           l_counter := p_data_tbl.COUNT;
           l_info    := ' determining totals ';
           pnp_debug_pkg.log(l_info);

           -- if there are no overrides, then the value is null, for which we default to be equal the normal

           IF l_excl_prorata_ovr_flag IS NULL THEN l_excl_prorata_ovr_flag := l_excl_prorata_flag; END IF;
           IF l_excl_area_ovr_flag IS NULL THEN l_excl_area_ovr_flag := l_excl_area_flag; END IF;

           IF l_include_flag = 'Y' THEN

              -- occupied area, assigned_area, weighted avg always zero here

              IF nvl(l_excl_area_ovr_flag, l_excl_area_flag) = 'N' THEN

                 p_total_tbl(0).total_assignable_area      := p_total_tbl(0).total_assignable_area + nvl(p_assignable_area, 0);
                 p_total_tbl(0).total_occupied_area_ovr    := p_total_tbl(0).total_occupied_area_ovr +
                                                              nvl(l_occup_area_ovr,0);
                 p_total_tbl(0).total_vacant_area          := p_total_tbl(0).total_vacant_area + nvl(l_num,0);
                 p_total_tbl(0).total_vacant_area_ovr      := p_total_tbl(0).total_vacant_area_ovr +
                                                              nvl(nvl(p_assignable_area - l_occup_area_ovr, l_num),0);
                 p_total_tbl(0).total_weighted_avg_ovr     := p_total_tbl(0).total_weighted_avg_ovr +
                                                              nvl(l_weighted_avg_ovr,0);

              ELSIF nvl(l_excl_area_ovr_flag, l_excl_area_flag) = 'Y' THEN

                 p_total_tbl(0).total_occupied_area_exc    := p_total_tbl(0).total_occupied_area_exc +
                                                              nvl(l_occup_area_ovr,0);
                 p_total_tbl(0).total_vacant_area_exc      := p_total_tbl(0).total_vacant_area_exc +
                                                              nvl(nvl(p_assignable_area - l_occup_area_ovr, l_num),0);
                 p_total_tbl(0).total_weighted_avg_exc     := p_total_tbl(0).total_weighted_avg_exc +
                                                              nvl(l_weighted_avg_ovr,0);
              END IF;

           END IF;

           l_info    := ' populating data into pl/sql table ';
           pnp_debug_pkg.log(l_info);

           p_data_tbl(l_counter).area_class_dtl_line_id   := l_area_class_dtl_line_id;
           p_data_tbl(l_counter).from_date                := l_from;
           p_data_tbl(l_counter).to_date                  := l_to;
           p_data_tbl(l_counter).location_id              := p_location_id;
           p_data_tbl(l_counter).property_id              := p_property_id;
           p_data_tbl(l_counter).cust_space_assign_id     := null;
           p_data_tbl(l_counter).cust_account_id          := null;
           p_data_tbl(l_counter).lease_id                 := null;
           p_data_tbl(l_counter).assignable_area          := p_assignable_area;
           p_data_tbl(l_counter).assigned_area            := 0;
           p_data_tbl(l_counter).assigned_area_ovr        := l_assigned_area_ovr;
           p_data_tbl(l_counter).occupancy_pct            := 0;
           p_data_tbl(l_counter).occupied_area            := 0;
           p_data_tbl(l_counter).occupied_area_ovr        := l_occup_area_ovr;
           p_data_tbl(l_counter).vacant_area              := l_num;
           p_data_tbl(l_counter).vacant_area_ovr          := p_assignable_area - l_occup_area_ovr;
           p_data_tbl(l_counter).weighted_avg             := 0;
           p_data_tbl(l_counter).weighted_avg_ovr         := l_weighted_avg_ovr;
           p_data_tbl(l_counter).exclude_area_flag        := l_excl_area_flag;
           p_data_tbl(l_counter).exclude_prorata_flag     := l_excl_prorata_flag;
           p_data_tbl(l_counter).exclude_area_ovr_flag    := l_excl_area_ovr_flag;
           p_data_tbl(l_counter).exclude_prorata_ovr_flag := l_excl_prorata_ovr_flag;
           p_data_tbl(l_counter).include_flag             := l_include_flag;
           p_data_tbl(l_counter).recovery_space_std_code  := null;
           p_data_tbl(l_counter).recovery_type_code       := null;

       END IF;

   END LOOP;

   pnp_debug_pkg.log(l_desc ||' (-)');

EXCEPTION
  WHEN OTHERS THEN
     pnp_debug_pkg.log(l_desc || ': Error while ' || l_info);
     raise;
END;

------------------------------------------------------------------------------+
-- PROCEDURE  : process_tables
-- DESCRIPTION:
-- 1. Given new and old data, determine which ones to insert, update, delete.
-- 2. The new data table handles insert and update.
-- 2. Tickmark those in the old data that intersects with new data.
-- 3. Those not tickmarked are to be deleted.
-- 4. Note that deletion is only for cases of regeneration.
--
-- HISTORY:
-- 19-MAR-03 ftanudja o created
-- 21-MAY-04 ftanudja o added logic for batch commit.
-- 15-JUL-05 SatyaDeepo Replaced base views with their _ALL tables
------------------------------------------------------------------------------+
PROCEDURE process_area_class_line_data(
            p_old_data  area_cls_line_dtl_tbl,
            p_new_data  area_cls_line_dtl_tbl,
            p_hdr_id    pn_rec_arcl_dtl.area_class_dtl_id%TYPE
          )
IS
   keep_table             number_table_type;
   delete_table           number_table_type;
   l_area_cls_dtl_line_id NUMBER;
   l_is_in                BOOLEAN;
   l_info                 VARCHAR2(300);
   l_desc                 VARCHAR2(100) := 'pn_recovery_extract_pkg.process_area_tables';

BEGIN

   pnp_debug_pkg.log(l_desc ||' (+)');

   l_info := ' looking at new and old data to determine action to be taken';
   pnp_debug_pkg.log(l_info);

   FOR i IN 0 .. p_new_data.COUNT - 1 LOOP

      l_area_cls_dtl_line_id := p_new_data(i).area_class_dtl_line_id;

      IF l_area_cls_dtl_line_id IS NULL THEN

         l_info := ' inserting row into area cls dtl line table ';
         pnp_debug_pkg.log(l_info);

         pn_rec_arcl_dtlln_pkg.insert_row(
            x_org_id                   => pn_mo_cache_utils.get_current_org_id,
            x_area_class_dtl_id        => p_hdr_id,
            x_area_class_dtl_line_id   => l_area_cls_dtl_line_id,
            x_from_date                => p_new_data(i).from_date,
            x_to_date                  => p_new_data(i).to_date,
            x_location_id              => p_new_data(i).location_id,
            x_property_id              => p_new_data(i).property_id,
            x_cust_space_assign_id     => p_new_data(i).cust_space_assign_id,
            x_cust_account_id          => p_new_data(i).cust_account_id,
            x_lease_id                 => p_new_data(i).lease_id,
            x_assignable_area          => p_new_data(i).assignable_area,
            x_assigned_area            => p_new_data(i).assigned_area,
            x_assigned_area_ovr        => p_new_data(i).assigned_area_ovr,
            x_occupancy_pct            => p_new_data(i).occupancy_pct,
            x_occupied_area            => p_new_data(i).occupied_area,
            x_occupied_area_ovr        => p_new_data(i).occupied_area_ovr,
            x_vacant_area              => p_new_data(i).vacant_area,
            x_vacant_area_ovr          => p_new_data(i).vacant_area_ovr,
            x_weighted_avg             => p_new_data(i).weighted_avg,
            x_weighted_avg_ovr         => p_new_data(i).weighted_avg_ovr,
            x_exclude_area_flag        => p_new_data(i).exclude_area_flag,
            x_exclude_area_ovr_flag    => p_new_data(i).exclude_area_ovr_flag,
            x_exclude_prorata_flag     => p_new_data(i).exclude_prorata_flag,
            x_exclude_prorata_ovr_flag => p_new_data(i).exclude_prorata_ovr_flag,
            x_include_flag             => p_new_data(i).include_flag,
            x_recovery_space_std_code  => p_new_data(i).recovery_space_std_code,
            x_recovery_type_code       => p_new_data(i).recovery_type_code,
            x_last_update_date         => SYSDATE,
            x_last_updated_by          => nvl(fnd_profile.value('USER_ID'), -1),
            x_creation_date            => SYSDATE,
            x_created_by               => nvl(fnd_profile.value('USER_ID'), -1),
            x_last_update_login        => nvl(fnd_profile.value('USER_ID'), -1)
         );

      ELSE

         l_info := ' updating row in area cls dtl line table: ' || p_new_data(i).area_class_dtl_line_id ;
         pnp_debug_pkg.log(l_info);

         pn_rec_arcl_dtlln_pkg.update_row(
            x_area_class_dtl_line_id   => l_area_cls_dtl_line_id,
            x_from_date                => p_new_data(i).from_date,
            x_to_date                  => p_new_data(i).to_date,
            x_location_id              => p_new_data(i).location_id,
            x_property_id              => p_new_data(i).property_id,
            x_cust_space_assign_id     => p_new_data(i).cust_space_assign_id,
            x_cust_account_id          => p_new_data(i).cust_account_id,
            x_lease_id                 => p_new_data(i).lease_id,
            x_assignable_area          => p_new_data(i).assignable_area,
            x_assigned_area            => p_new_data(i).assigned_area,
            x_assigned_area_ovr        => p_new_data(i).assigned_area_ovr,
            x_occupancy_pct            => p_new_data(i).occupancy_pct,
            x_occupied_area            => p_new_data(i).occupied_area,
            x_occupied_area_ovr        => p_new_data(i).occupied_area_ovr,
            x_vacant_area              => p_new_data(i).vacant_area,
            x_vacant_area_ovr          => p_new_data(i).vacant_area_ovr,
            x_weighted_avg             => p_new_data(i).weighted_avg,
            x_weighted_avg_ovr         => p_new_data(i).weighted_avg_ovr,
            x_exclude_area_flag        => p_new_data(i).exclude_area_flag,
            x_exclude_area_ovr_flag    => p_new_data(i).exclude_area_ovr_flag,
            x_exclude_prorata_flag     => p_new_data(i).exclude_prorata_flag,
            x_exclude_prorata_ovr_flag => p_new_data(i).exclude_prorata_ovr_flag,
            x_include_flag             => p_new_data(i).include_flag,
            x_recovery_space_std_code  => p_new_data(i).recovery_space_std_code,
            x_recovery_type_code       => p_new_data(i).recovery_type_code,
            x_last_update_date         => SYSDATE,
            x_last_updated_by          => nvl(fnd_profile.value('USER_ID'), -1),
            x_creation_date            => SYSDATE,
            x_created_by               => nvl(fnd_profile.value('USER_ID'), -1),
            x_last_update_login        => nvl(fnd_profile.value('USER_ID'), -1)
         );

      END IF;

      keep_table(keep_table.COUNT) := l_area_cls_dtl_line_id;

      -- do a batch commit if needed
      IF mod (i, g_batch_commit_size) = 0 THEN
         commit;
      END IF;

   END LOOP;

   FOR i IN 0 .. p_old_data.COUNT - 1 LOOP
      l_is_in := FALSE;
      FOR j IN 0 .. keep_table.COUNT - 1 LOOP
         IF keep_table(j) = p_old_data(i).area_class_dtl_line_id THEN l_is_in := TRUE; exit; END IF;
      END LOOP;
      IF NOT l_is_in THEN delete_table(delete_table.COUNT) := p_old_data(i).area_class_dtl_line_id; END IF;
   END LOOP;

   FORALL i IN 0 .. delete_table.COUNT - 1
      DELETE FROM pn_rec_arcl_dtlln_all
      WHERE area_class_dtl_line_id = delete_table(i);

   pnp_debug_pkg.log(l_desc ||' (-)');

EXCEPTION
  WHEN OTHERS THEN
     pnp_debug_pkg.log(l_desc || ': Error while ' || l_info);
     raise;
END;

------------------------------------------------------------------------------+
-- PROCEDURE  : extract_area
-- ASSUMPTION : input validation will be done from UI.
-- DESCRIPTION:
--
--   OVERVIEW:
-- o given an area class id and other parameters, the program should populate
--   the area class line header and details table.
--
--   GETTING DEFAULT:
-- o first look to find default values from a prior extract (if new extract)
--   or current extract (if extract regenerated).
-- o if the header table entry already exists, re-use, otherwise, create a
--   new entry.
--
--   FETCHING INFORMATION:
-- o for a given location code, find its corresponding children of type
--   'OFFICE' and 'SECTION', whose active start date > to date AND active end
--   date < from date.
-- o for each of these children, find the corresponding space assignments.
-- o if the location meets the criteria specified in the area class, then
--   process that location and all associated space assignments.
-- o for children without space assignments, generate the corresponding
--   vacancy details.
-- o once there are no more data for that location, dump data into pl/sql table.
-- o after the last location, exit out of the loop and dump data for that last
--   location into the aforementioned pl/sql table.
-- o while looping through the information, calculate the total headers
--   accordingly.
-- o when taking into account the space assignment start / end date and the
--   location active start / end date, compare with landlord from / to date
--   before inserting into the details table; the lesser of the landlord
--   to date and the end date is to be taken into account; similarly,
--   the greater of the landlord from date and the start date is to be
--   taken into account.
--
--   DUMPING DATA:
-- o a few pl/sql tables are used to keep new data and old data for the
--   details table.
-- o first process the new data, doing inserts and updates as necessary.
-- o then find the difference between new data and old data, and delete
--   the ones no longer used.
--
-- HISTORY:
-- 22-MAR-03 ftanudja  o created.
-- 06-JUN-03 ftanudja  o initialized area class dtl total_exc columns.
--                     o fixed area totals calculation.
-- 10-JUL-03 ftanudja  o added outer join on get_area_class_info cursor.
--                       o/w arcl w/o exc is not picked up. 3046070.
--                     o made prop id and loc id mutex on get_location_info.
-- 05-AUG-03 ftanudja  o major flow change. CURSOR get_area_class_info
--                       should not be main iteration point.
--                     o fixed get_prior_ovr flow. 3077454.
--                     o replaced 'PARCEL' with 'SECTION'. 3082071.
--                     o added order by to date and from date for ovr values.
--                     o changed vacant_area_ovr calculation method.
--                     o optimized get_ovr_from_prior CURSOR (break in 2).
-- 15-AUG-03 ftanudja  o changed total asgnbl area calculation. 3099669.
-- 22-AUG-03 ftanudja  o validate UOM uniqueness for area extr. 3081996.
-- 21-MAY-04 ftanudja  o added log output message to show input parameters.
-- 15-JUL-05 SatyaDeep o Replaced base views with their _ALL tables
-- 27-APR-06 Hareesha  o Bug# 5148839 Modified call to process_vacancy
--                       Added NVL for assignable_area.
-- 26-APR-10 asahoo    o Bug#9579092 Modified the condition to calculate total_assignable_area, total_occupied_area, total_occupied_area_ovr,
--                       total_weighted_avg and total_weighted_avg_ovr
------------------------------------------------------------------------------+

PROCEDURE extract_area(
            errbuf             OUT NOCOPY VARCHAR2,
            retcode            OUT NOCOPY VARCHAR2,
            p_area_class_id    IN pn_rec_arcl.area_class_id%TYPE,
            p_as_of_date       IN VARCHAR2,
            p_from_date        IN VARCHAR2,
            p_to_date          IN VARCHAR2,
            p_keep_override    IN VARCHAR2)
IS
   CURSOR get_area_class_info IS
    SELECT class.area_class_id,
           class.property_id,
           class.location_id,
           excl_dtl.exclusion_type_code,
           excl_dtl.relational_code,
           excl_dtl.area,
           excl_dtl.area_class_exclusion_id,
           excl_dtl.recovery_space_std_code,
           excl_dtl.recovery_type_code
      FROM pn_rec_arcl_all           class,
           pn_rec_arcl_exc_all   excl_dtl
     WHERE class.area_class_id = excl_dtl.area_class_id (+)
       AND class.area_class_id = p_area_class_id;

   CURSOR get_location_info(
            p_location_id      pn_locations.location_id%TYPE,
            p_property_id      pn_locations.property_id%TYPE) IS
    SELECT location_id,
           property_id,
           active_start_date,
           active_end_date,
           assignable_area
    FROM   pn_locations_all
    WHERE  location_type_lookup_code IN ('SECTION','OFFICE')
       AND active_start_date < fnd_date.canonical_to_date(p_to_date)
       AND active_end_date > fnd_date.canonical_to_date(p_from_date)
       AND location_id IN
           (SELECT location_id FROM pn_locations_all
            START WITH (location_id =  p_location_id OR
                        (property_id = p_property_id AND p_location_id IS NULL))
            CONNECT BY PRIOR location_id =  parent_location_id)
    ORDER BY location_id;

   CURSOR get_cust_assignment_info(p_location_id pn_locations.location_id%TYPE) IS
    SELECT cust_space_assign_id,
           cust_account_id,
           allocated_area,
           cust_assign_start_date,
           fin_oblig_end_date,
           lease_id,
           recovery_type_code,
           recovery_space_std_code
      FROM pn_space_assign_cust_all cust
     WHERE cust.location_id = p_location_id
       AND cust.cust_assign_start_date < fnd_date.canonical_to_date(p_to_date)
       AND cust.fin_oblig_end_date > fnd_date.canonical_to_date(p_from_date);

   CURSOR get_uom_info_from_prop(p_property_id pn_locations.property_id%TYPE) IS
    SELECT uom_code
      FROM pn_locations_all
     WHERE property_id = p_property_id
       AND active_start_date < fnd_date.canonical_to_date(p_to_date)
       AND active_end_date > fnd_date.canonical_to_date(p_from_date);

   CURSOR get_uom_info_from_locn(p_location_id pn_locations.location_id%TYPE) IS
    SELECT uom_code
      FROM pn_locations_all
     WHERE location_id IN
           (SELECT location_id FROM pn_locations_all
            START WITH location_id =  p_location_id
            CONNECT BY location_id = PRIOR parent_location_id)
       AND parent_location_id IS NULL
       AND active_start_date < fnd_date.canonical_to_date(p_to_date)
       AND active_end_date > fnd_date.canonical_to_date(p_from_date);

   CURSOR get_ovr_from_curnt IS
    SELECT dtl.location_id,
           dtl.from_date,
           dtl.to_date,
           dtl.cust_account_id,
           dtl.weighted_avg_ovr,
           dtl.occupied_area_ovr,
           dtl.assigned_area_ovr,
           dtl.exclude_prorata_flag,
           dtl.exclude_prorata_ovr_flag,
           dtl.exclude_area_flag,
           dtl.exclude_area_ovr_flag,
           dtl.recovery_space_std_code,
           dtl.recovery_type_code,
           dtl.area_class_dtl_line_id,
           hdr.area_class_dtl_id,
           hdr.status,
           setup.area_class_name
      FROM pn_rec_arcl_dtlln_all     dtl,
           pn_rec_arcl_dtl_all   hdr,
           pn_rec_arcl_all       setup
     WHERE dtl.area_class_dtl_id (+) = hdr.area_class_dtl_id
       AND hdr.area_class_id = p_area_class_id
       AND TRUNC(hdr.as_of_date) = TRUNC(fnd_date.canonical_to_date(p_as_of_date))
       AND TRUNC(hdr.from_date) = TRUNC(fnd_date.canonical_to_date(p_from_date))
       AND TRUNC(hdr.to_date) = TRUNC(fnd_date.canonical_to_date(p_to_date))
       AND setup.area_class_id = hdr.area_class_id;

   CURSOR get_prior_cls_dtl_id IS
    SELECT area_class_dtl_id
      FROM pn_rec_arcl_dtl_all
     WHERE from_date < fnd_date.canonical_to_date(p_to_date)
       AND to_date   <= fnd_date.canonical_to_date(p_to_date)
       AND as_of_date < fnd_date.canonical_to_date(p_as_of_date)
       AND area_class_id = p_area_class_id
  ORDER BY as_of_date DESC, to_date DESC , from_date DESC;

   CURSOR get_ovr_from_prior(p_prior_cls_dtl_id pn_rec_arcl_dtl.area_class_dtl_id%TYPE) IS
    SELECT location_id,
           from_date,
           to_date,
           cust_account_id,
           weighted_avg_ovr,
           occupied_area_ovr,
           assigned_area_ovr,
           exclude_prorata_flag,
           exclude_prorata_ovr_flag,
           exclude_area_flag,
           exclude_area_ovr_flag,
           recovery_space_std_code,
           recovery_type_code
      FROM pn_rec_arcl_dtlln_all
     WHERE area_class_dtl_id = p_prior_cls_dtl_id;

   l_area_class_dtl_id      pn_rec_arcl_dtl.area_class_dtl_id%TYPE;
   l_area_class_dtl_line_id pn_rec_arcl_dtlln.area_class_dtl_line_id%TYPE;
   l_dummy_id               pn_rec_arcl_dtl.area_class_dtl_id%TYPE;
   l_count                  NUMBER;
   l_data_tbl_counter       NUMBER;
   l_regenerate             VARCHAR2(1);
   l_found                  BOOLEAN;
   l_token                  VARCHAR2(100);
   l_is_assigned            BOOLEAN;
   l_meets_criteria         BOOLEAN;
   l_temp_loc_id            pn_rec_arcl.location_id%TYPE           := NULL;
   l_temp_prop_id           pn_rec_arcl.property_id%TYPE           := NULL;
   l_temp_assignable_area   pn_rec_arcl_dtlln.assignable_area%TYPE := NULL;
   l_from_date              pn_rec_arcl_dtlln.from_date%TYPE;
   l_to_date                pn_rec_arcl_dtlln.to_date%TYPE;
   l_occup_pct              pn_rec_arcl_dtlln.occupancy_pct%TYPE;
   l_weighted_avg           pn_rec_arcl_dtlln.weighted_avg%TYPE;
   l_occup_area             pn_rec_arcl_dtlln.occupied_area%TYPE;
   l_excl_type              pn_rec_arcl_exc.exclusion_type_code%TYPE;
   l_excl_prorata_flag      pn_rec_arcl_dtlln.exclude_prorata_flag%TYPE;
   l_excl_area_flag         pn_rec_arcl_dtlln.exclude_area_flag%TYPE;
   l_include_flag           pn_rec_arcl_dtlln.include_flag%TYPE;
   l_occup_area_ovr         pn_rec_arcl_dtlln.occupied_area_ovr%TYPE;
   l_weighted_avg_ovr       pn_rec_arcl_dtlln.weighted_avg_ovr%TYPE;
   l_assigned_area_ovr      pn_rec_arcl_dtlln.assigned_area_ovr%TYPE;
   l_excl_area_ovr_flag     pn_rec_arcl_dtlln.exclude_area_ovr_flag%TYPE;
   l_excl_prorata_ovr_flag  pn_rec_arcl_dtlln.exclude_prorata_ovr_flag%TYPE;
   l_vacancy_num_table      number_table_type;
   l_vacancy_date_table     date_table_type;
   l_ref_vacancy_num_table  number_table_type;
   l_ref_vacancy_date_table date_table_type;
   l_area_cls_ln_data_tbl   area_cls_line_dtl_tbl;
   l_area_cls_ln_curnt_ovr  area_cls_line_dtl_tbl;
   l_area_cls_ln_prior_ovr  area_cls_line_dtl_tbl;
   l_area_total_tbl         area_cls_line_hdr_tbl;
   l_arcl_locid             pn_rec_arcl.location_id%TYPE;
   l_arcl_propid            pn_rec_arcl.property_id%TYPE;
   l_arcl_exc_table         area_cls_exc_tbl;
   l_uom_code               pn_locations_all.uom_code%TYPE;
   l_info VARCHAR2(100);
   l_desc VARCHAR2(100) := 'pn_recovery_extract_pkg.extract_area' ;


BEGIN

   pnp_debug_pkg.log(l_desc ||' (+)');

   fnd_message.set_name('PN','PN_REC_ARCL_DTL_CP_INFO');
   fnd_message.set_token('ARCL' , to_char(p_area_class_id));
   fnd_message.set_token('STR'  , p_from_date);
   fnd_message.set_token('END'  , p_to_date);
   fnd_message.set_token('AOD'  , p_as_of_date);
   fnd_message.set_token('OVR'  , p_keep_override);
   pnp_debug_pkg.put_log_msg('');
   pnp_debug_pkg.put_log_msg(fnd_message.get);
   pnp_debug_pkg.put_log_msg('');

   l_vacancy_date_table.delete;
   l_vacancy_num_table.delete;
   l_ref_vacancy_date_table.delete;
   l_ref_vacancy_num_table.delete;

   l_area_cls_ln_curnt_ovr.delete;
   l_area_cls_ln_prior_ovr.delete;
   l_area_cls_ln_data_tbl.delete;

   l_arcl_exc_table.delete;

   l_area_total_tbl(0).total_assignable_area      := 0;
   l_area_total_tbl(0).total_occupied_area        := 0;
   l_area_total_tbl(0).total_occupied_area_ovr    := 0;
   l_area_total_tbl(0).total_occupied_area_exc    := 0;
   l_area_total_tbl(0).total_vacant_area          := 0;
   l_area_total_tbl(0).total_vacant_area_ovr      := 0;
   l_area_total_tbl(0).total_vacant_area_exc      := 0;
   l_area_total_tbl(0).total_weighted_avg         := 0;
   l_area_total_tbl(0).total_weighted_avg_ovr     := 0;
   l_area_total_tbl(0).total_weighted_avg_exc     := 0;

   l_info:= ' fetching area class information';
   pnp_debug_pkg.log(l_info);

   FOR area_class_rec IN get_area_class_info LOOP
      IF l_arcl_locid IS NULL THEN l_arcl_locid := area_class_rec.location_id;  END IF;
      IF l_arcl_propid IS NULL THEN l_arcl_propid := area_class_rec.property_id;  END IF;

      l_count := l_arcl_exc_table.COUNT;

      l_arcl_exc_table(l_count).recovery_space_std_code := area_class_rec.recovery_space_std_code;
      l_arcl_exc_table(l_count).recovery_type_code      := area_class_rec.recovery_type_code;
      l_arcl_exc_table(l_count).exclusion_type_code     := area_class_rec.exclusion_type_code;
      l_arcl_exc_table(l_count).relational_code         := area_class_rec.relational_code;
      l_arcl_exc_table(l_count).area                    := area_class_rec.area;

   END LOOP;

   l_info := ' validating UOM is unique for location and property';
   pnp_debug_pkg.log(l_info);

   IF l_arcl_propid IS NOT NULL AND l_arcl_locid IS NULL THEN
      FOR validate_rec IN get_uom_info_from_prop(l_arcl_propid) LOOP
         IF l_uom_code IS NULL THEN l_uom_code := validate_rec.uom_code;
         ELSIF l_uom_code <> validate_rec.uom_code THEN
            fnd_message.set_name('PN', 'PN_REC_UOM_MULTIPLE');
            RAISE uom_exception;
         END IF;
      END LOOP;
   ELSIF l_arcl_locid IS NOT NULL THEN
      FOR validate_rec IN get_uom_info_from_locn(l_arcl_locid) LOOP
         IF l_uom_code IS NULL THEN l_uom_code := validate_rec.uom_code;
         ELSIF l_uom_code <> validate_rec.uom_code THEN
            fnd_message.set_name('PN', 'PN_REC_UOM_MULTIPLE');
            RAISE uom_exception;
         END IF;
      END LOOP;
   END IF;

   l_info := ' finding overrides and processing header information ';
   pnp_debug_pkg.log(l_info);

   l_regenerate := 'Y';
   l_count := -1;

   FOR get_ovr_rec IN get_ovr_from_curnt LOOP

      IF get_ovr_rec.status = 'LOCKED' THEN
         fnd_message.set_name('PN','PN_REC_ARCL_DTL');
         l_token := fnd_message.get;
         fnd_message.set_name('PN','PN_REC_NO_REGEN_LOCKED');
         fnd_message.set_token('MODULE',l_token);
         fnd_message.set_token('FDATE', p_from_date);
         fnd_message.set_token('TDATE', p_to_date);
         fnd_message.set_token('AODATE', p_as_of_date);
         fnd_message.set_token('NAME', get_ovr_rec.area_class_name);
         pnp_debug_pkg.log(fnd_message.get);
         RETURN;
      END IF;

      l_count := l_area_cls_ln_curnt_ovr.COUNT;

      l_area_cls_ln_curnt_ovr(l_count).location_id             := get_ovr_rec.location_id;
      l_area_cls_ln_curnt_ovr(l_count).from_date               := get_ovr_rec.from_date;
      l_area_cls_ln_curnt_ovr(l_count).to_date                 := get_ovr_rec.to_date;
      l_area_cls_ln_curnt_ovr(l_count).cust_account_id         := get_ovr_rec.cust_account_id;
      l_area_cls_ln_curnt_ovr(l_count).weighted_avg_ovr        := get_ovr_rec.weighted_avg_ovr;
      l_area_cls_ln_curnt_ovr(l_count).occupied_area_ovr       := get_ovr_rec.occupied_area_ovr;
      l_area_cls_ln_curnt_ovr(l_count).assigned_area_ovr       := get_ovr_rec.assigned_area_ovr;
      l_area_cls_ln_curnt_ovr(l_count).exclude_prorata_flag    := get_ovr_rec.exclude_prorata_flag;
      l_area_cls_ln_curnt_ovr(l_count).exclude_prorata_ovr_flag:= get_ovr_rec.exclude_prorata_ovr_flag;
      l_area_cls_ln_curnt_ovr(l_count).exclude_area_flag       := get_ovr_rec.exclude_area_flag;
      l_area_cls_ln_curnt_ovr(l_count).exclude_area_ovr_flag   := get_ovr_rec.exclude_area_ovr_flag;
      l_area_cls_ln_curnt_ovr(l_count).recovery_space_std_code := get_ovr_rec.recovery_space_std_code;
      l_area_cls_ln_curnt_ovr(l_count).recovery_type_code      := get_ovr_rec.recovery_type_code;
      l_area_cls_ln_curnt_ovr(l_count).area_class_dtl_line_id  := get_ovr_rec.area_class_dtl_line_id;

      l_area_class_dtl_id := get_ovr_rec.area_class_dtl_id;

   END LOOP;

   IF l_area_class_dtl_id IS NULL THEN
      l_regenerate := 'N';

   END IF;

   l_info := ' getting prior cls dtl id for overrides';
   pnp_debug_pkg.log(l_info);

   FOR get_first_id IN get_prior_cls_dtl_id LOOP
      l_dummy_id := get_first_id.area_class_dtl_id;
      exit;
   END LOOP;

   FOR get_ovr_rec IN get_ovr_from_prior(l_dummy_id) LOOP

      l_count := l_area_cls_ln_prior_ovr.COUNT;

      l_area_cls_ln_prior_ovr(l_count).location_id             := get_ovr_rec.location_id;
      l_area_cls_ln_prior_ovr(l_count).from_date               := get_ovr_rec.from_date;
      l_area_cls_ln_prior_ovr(l_count).to_date                 := get_ovr_rec.to_date;
      l_area_cls_ln_prior_ovr(l_count).cust_account_id         := get_ovr_rec.cust_account_id;
      l_area_cls_ln_prior_ovr(l_count).weighted_avg_ovr        := get_ovr_rec.weighted_avg_ovr;
      l_area_cls_ln_prior_ovr(l_count).occupied_area_ovr       := get_ovr_rec.occupied_area_ovr;
      l_area_cls_ln_prior_ovr(l_count).assigned_area_ovr       := get_ovr_rec.assigned_area_ovr;
      l_area_cls_ln_prior_ovr(l_count).exclude_prorata_flag    := get_ovr_rec.exclude_prorata_flag;
      l_area_cls_ln_prior_ovr(l_count).exclude_prorata_ovr_flag:= get_ovr_rec.exclude_prorata_ovr_flag;
      l_area_cls_ln_prior_ovr(l_count).exclude_area_flag       := get_ovr_rec.exclude_area_flag;
      l_area_cls_ln_prior_ovr(l_count).exclude_area_ovr_flag   := get_ovr_rec.exclude_area_ovr_flag;
      l_area_cls_ln_prior_ovr(l_count).recovery_space_std_code := get_ovr_rec.recovery_space_std_code;
      l_area_cls_ln_prior_ovr(l_count).recovery_type_code      := get_ovr_rec.recovery_type_code;

   END LOOP;

   FOR location_rec IN get_location_info(l_arcl_locid, l_arcl_propid) LOOP

      l_info := ' processing location id: '|| location_rec.location_id ||' ';
      pnp_debug_pkg.log(l_info);

      l_is_assigned := FALSE;

      IF l_temp_loc_id IS NULL OR
         l_temp_loc_id <> location_rec.location_id THEN

          IF l_temp_loc_id IS NOT NULL THEN

             -- generate vacancy data for that location id

            l_info := ' inserting vacancy data into details table for location: '||l_temp_loc_id||' ';
            pnp_debug_pkg.log(l_info);

            insert_vacancy_data(p_location_id          => l_temp_loc_id,
                                p_property_id          => l_temp_prop_id,
                                p_date_table           => l_vacancy_date_table,
                                p_num_table            => l_vacancy_num_table,
                                p_ref_date_table       => l_ref_vacancy_date_table,
                                p_ref_num_table        => l_ref_vacancy_num_table,
                                p_from_date            => fnd_date.canonical_to_date(p_from_date),
                                p_to_date              => fnd_date.canonical_to_date(p_to_date),
                                p_as_of_date           => fnd_date.canonical_to_date(p_as_of_date),
                                p_assignable_area      => l_temp_assignable_area,
                                p_curnt_ovr            => l_area_cls_ln_curnt_ovr,
                                p_prior_ovr            => l_area_cls_ln_prior_ovr,
                                p_data_tbl             => l_area_cls_ln_data_tbl,
                                p_total_tbl            => l_area_total_tbl,
                                p_keep_override        => p_keep_override,
                                p_regenerate           => l_regenerate
                               );

            /* reset */

            l_vacancy_num_table.delete;
            l_vacancy_date_table.delete;
            l_ref_vacancy_num_table.delete;
            l_ref_vacancy_date_table.delete;

         END IF;

         l_temp_loc_id          := location_rec.location_id;
         l_temp_prop_id         := location_rec.property_id;
         l_temp_assignable_area := location_rec.assignable_area;

         -- process data for vacancy details purposes

         FOR space_assign_rec IN get_cust_assignment_info(location_rec.location_id) LOOP
            l_is_assigned := TRUE;

            l_info := ' checking whether space assignment: '|| space_assign_rec.cust_space_assign_id ||
                      ' meets exclusion criteria ';
            pnp_debug_pkg.log(l_info);

            l_meets_criteria := FALSE;

            FOR i IN 0 .. l_arcl_exc_table.COUNT - 1 LOOP
               IF l_arcl_exc_table(i).recovery_type_code = space_assign_rec.recovery_type_code AND
                  l_arcl_exc_table(i).recovery_space_std_code = space_assign_rec.recovery_space_std_code THEN

                  IF l_arcl_exc_table(i).relational_code = 'EQ' THEN
                     IF location_rec.assignable_area = l_arcl_exc_table(i).area THEN l_meets_criteria := TRUE; END IF;
                  ELSIF l_arcl_exc_table(i).relational_code = 'GT' THEN
                     IF location_rec.assignable_area > l_arcl_exc_table(i).area THEN l_meets_criteria := TRUE; END IF;
                  ELSIF l_arcl_exc_table(i).relational_code = 'LT' THEN
                     IF location_rec.assignable_area < l_arcl_exc_table(i).area THEN l_meets_criteria := TRUE; END IF;
                  ELSIF l_arcl_exc_table(i).relational_code = 'GE' THEN
                     IF location_rec.assignable_area >= l_arcl_exc_table(i).area THEN l_meets_criteria := TRUE; END IF;
                  ELSIF l_arcl_exc_table(i).relational_code = 'LE' THEN
                     IF location_rec.assignable_area <= l_arcl_exc_table(i).area THEN l_meets_criteria := TRUE; END IF;
                  ELSIF l_arcl_exc_table(i).relational_code IS NULL THEN
                     l_meets_criteria := TRUE;
                  END IF;

                  l_excl_type := l_arcl_exc_table(i).exclusion_type_code;
                  exit;

               END IF;
            END LOOP;

            -- put in assignments for the occupancy details

            l_from_date := space_assign_rec.cust_assign_start_date;
            l_to_date := space_assign_rec.fin_oblig_end_date;
            l_info := ' getting details for cust assignment :'||space_assign_rec.cust_space_assign_id||' ';
            pnp_debug_pkg.log(l_info);

            IF NOT l_meets_criteria THEN l_excl_type := null; END IF;

            get_area_cls_dtl_calc(
               p_from_date         => fnd_date.canonical_to_date(p_from_date),
               p_to_date           => fnd_date.canonical_to_date(p_to_date),
               p_rec_from_date     => l_from_date,
               p_rec_to_date       => l_to_date,
               p_as_of_date        => fnd_date.canonical_to_date(p_as_of_date),
               p_assigned_area     => space_assign_rec.allocated_area,
               p_exc_type_code     => l_excl_type,
               p_occup_pct         => l_occup_pct,
               p_weighted_avg      => l_weighted_avg,
               p_occup_area        => l_occup_area,
               p_exc_prorata_flag  => l_excl_prorata_flag,
               p_exc_area_flag     => l_excl_area_flag,
               p_include_flag      => l_include_flag);

            l_info := ' finding overrides and processing into pl/sql table the details of '||
                      'cust assignment:'||space_assign_rec.cust_space_assign_id||' ';
            pnp_debug_pkg.log(l_info);

            l_found := FALSE;

            IF l_regenerate = 'Y' THEN

               find_area_ovr_values(
                  p_ovr                   => l_area_cls_ln_curnt_ovr,
                  p_loc_id                => location_rec.location_id,
                  p_cust_id               => space_assign_rec.cust_account_id,
                  p_from                  => l_from_date,
                  p_to                    => l_to_date,
                  p_weighted_avg_ovr      => l_weighted_avg_ovr,
                  p_occupied_area_ovr     => l_occup_area_ovr,
                  p_assigned_area_ovr     => l_assigned_area_ovr,
                  p_exc_area_ovr_flag     => l_excl_area_ovr_flag,
                  p_exc_prorata_ovr_flag  => l_excl_prorata_ovr_flag,
                  p_area_cls_dtl_line_id  => l_area_class_dtl_line_id,
                  p_found                 => l_found,
                  p_keep_override         => p_keep_override
               );

            END IF;

            IF NOT l_found  THEN

               IF l_regenerate = 'N' THEN l_found := null; END IF;

               find_area_ovr_values(
                  p_ovr                   => l_area_cls_ln_prior_ovr,
                  p_loc_id                => location_rec.location_id,
                  p_cust_id               => space_assign_rec.cust_account_id,
                  p_from                  => l_from_date,
                  p_to                    => l_to_date,
                  p_weighted_avg_ovr      => l_weighted_avg_ovr,
                  p_occupied_area_ovr     => l_occup_area_ovr,
                  p_assigned_area_ovr     => l_assigned_area_ovr,
                  p_exc_area_ovr_flag     => l_excl_area_ovr_flag,
                  p_exc_prorata_ovr_flag  => l_excl_prorata_ovr_flag,
                  p_area_cls_dtl_line_id  => l_area_class_dtl_line_id,
                  p_found                 => l_found,
                  p_keep_override         => p_keep_override
               );

            END IF;

            l_data_tbl_counter := l_area_cls_ln_data_tbl.COUNT;

            -- if there are no overrides, then the value is null, for which we default to be equal the normal

            IF l_excl_prorata_ovr_flag IS NULL THEN l_excl_prorata_ovr_flag := l_excl_prorata_flag; END IF;
            IF l_excl_area_ovr_flag IS NULL THEN l_excl_area_ovr_flag := l_excl_area_flag; END IF;


           --Fix for bug#9579092
	   IF l_include_flag = 'Y' THEN

	     l_area_total_tbl(0).total_assignable_area      := l_area_total_tbl(0).total_assignable_area +
                                                                 nvl(location_rec.assignable_area,0);
             l_area_total_tbl(0).total_occupied_area        := l_area_total_tbl(0).total_occupied_area + nvl(l_occup_area,0);
             l_area_total_tbl(0).total_occupied_area_ovr    := l_area_total_tbl(0).total_occupied_area_ovr +
                                                                 nvl(nvl(l_occup_area_ovr, l_occup_area),0);
             l_area_total_tbl(0).total_weighted_avg         := l_area_total_tbl(0).total_weighted_avg + nvl(l_weighted_avg, 0);
             l_area_total_tbl(0).total_weighted_avg_ovr     := l_area_total_tbl(0).total_weighted_avg_ovr +
                                                                 nvl(nvl(l_weighted_avg_ovr, l_weighted_avg),0);


	    IF  nvl(l_excl_area_ovr_flag, l_excl_area_flag) = 'N' THEN

               l_info := ' figuring totals ';
               pnp_debug_pkg.log(l_info);


               l_area_total_tbl(0).total_vacant_area          := l_area_total_tbl(0).total_vacant_area +
                                                                 nvl(location_rec.assignable_area,0) - nvl(l_occup_area,0);
               l_area_total_tbl(0).total_vacant_area_ovr      := l_area_total_tbl(0).total_vacant_area_ovr +
                                                                 nvl(location_rec.assignable_area - l_occup_area_ovr,
                                                                    (nvl(location_rec.assignable_area,0) - nvl(l_occup_area,0)));

            ELSIF  nvl(l_excl_area_ovr_flag, l_excl_area_flag) = 'Y' THEN

               l_info := ' figuring excluded totals ';
               pnp_debug_pkg.log(l_info);

               l_area_total_tbl(0).total_occupied_area_exc    := l_area_total_tbl(0).total_occupied_area_exc +
                                                                 nvl(nvl(l_occup_area_ovr, l_occup_area),0);
               l_area_total_tbl(0).total_vacant_area_exc      := l_area_total_tbl(0).total_vacant_area_exc +
                                                                 nvl(location_rec.assignable_area - l_occup_area_ovr,
                                                                    (nvl(location_rec.assignable_area,0) - nvl(l_occup_area,0)));
               l_area_total_tbl(0).total_weighted_avg_exc     := l_area_total_tbl(0).total_weighted_avg_exc +
                                                                 nvl(nvl(l_weighted_avg_ovr, l_weighted_avg),0);

            END IF;

	   END IF;


            l_info := ' processing area cls detail information into pl/sql table ';
            pnp_debug_pkg.log(l_info);

            l_area_cls_ln_data_tbl(l_data_tbl_counter).area_class_dtl_line_id   := l_area_class_dtl_line_id;
            l_area_cls_ln_data_tbl(l_data_tbl_counter).from_date                := l_from_date;
            l_area_cls_ln_data_tbl(l_data_tbl_counter).to_date                  := l_to_date;
            l_area_cls_ln_data_tbl(l_data_tbl_counter).location_id              := location_rec.location_id;
            l_area_cls_ln_data_tbl(l_data_tbl_counter).property_id              := location_rec.property_id;
            l_area_cls_ln_data_tbl(l_data_tbl_counter).cust_space_assign_id     := space_assign_rec.cust_space_assign_id;
            l_area_cls_ln_data_tbl(l_data_tbl_counter).cust_account_id          := space_assign_rec.cust_account_id;
            l_area_cls_ln_data_tbl(l_data_tbl_counter).lease_id                 := space_assign_rec.lease_id;
            l_area_cls_ln_data_tbl(l_data_tbl_counter).assignable_area          := location_rec.assignable_area;
            l_area_cls_ln_data_tbl(l_data_tbl_counter).assigned_area            := space_assign_rec.allocated_area;
            l_area_cls_ln_data_tbl(l_data_tbl_counter).assigned_area_ovr        := l_assigned_area_ovr;
            l_area_cls_ln_data_tbl(l_data_tbl_counter).occupancy_pct            := l_occup_pct;
            l_area_cls_ln_data_tbl(l_data_tbl_counter).occupied_area            := l_occup_area;
            l_area_cls_ln_data_tbl(l_data_tbl_counter).occupied_area_ovr        := l_occup_area_ovr;
            l_area_cls_ln_data_tbl(l_data_tbl_counter).vacant_area              := location_rec.assignable_area - l_occup_area;
            l_area_cls_ln_data_tbl(l_data_tbl_counter).vacant_area_ovr          := location_rec.assignable_area - l_occup_area_ovr;
            l_area_cls_ln_data_tbl(l_data_tbl_counter).weighted_avg             := l_weighted_avg;
            l_area_cls_ln_data_tbl(l_data_tbl_counter).weighted_avg_ovr         := l_weighted_avg_ovr;
            l_area_cls_ln_data_tbl(l_data_tbl_counter).exclude_area_flag        := l_excl_area_flag;
            l_area_cls_ln_data_tbl(l_data_tbl_counter).exclude_area_ovr_flag    := l_excl_area_ovr_flag;
            l_area_cls_ln_data_tbl(l_data_tbl_counter).exclude_prorata_flag     := l_excl_prorata_flag;
            l_area_cls_ln_data_tbl(l_data_tbl_counter).exclude_prorata_ovr_flag := l_excl_prorata_ovr_flag;
            l_area_cls_ln_data_tbl(l_data_tbl_counter).include_flag             := l_include_flag;
            l_area_cls_ln_data_tbl(l_data_tbl_counter).recovery_space_std_code  := space_assign_rec.recovery_space_std_code;
            l_area_cls_ln_data_tbl(l_data_tbl_counter).recovery_type_code       := space_assign_rec.recovery_type_code;

            -- collect data

            l_info := ' processing vacancy for cust assignment:'||space_assign_rec.cust_space_assign_id||' ';
            pnp_debug_pkg.log(l_info);

            process_vacancy(
               p_start_date   => l_from_date,
               p_end_date     => l_to_date,
               p_area         => space_assign_rec.allocated_area,
               p_date_table   => l_vacancy_date_table,
               p_number_table => l_vacancy_num_table,
               p_add          => FALSE);

         END LOOP;

         l_info := ' processing vacancy for location for data table';
         pnp_debug_pkg.log(l_info);

         process_vacancy(
            p_start_date   => location_rec.active_start_date,
            p_end_date     => location_rec.active_end_date,
            p_area         => NVL(location_rec.assignable_area,0),
            p_date_table   => l_vacancy_date_table,
            p_number_table => l_vacancy_num_table,
            p_add          => TRUE);

         l_info := ' processing vacancy for location for reference table';
         pnp_debug_pkg.log(l_info);

         process_vacancy(
            p_start_date   => location_rec.active_start_date,
            p_end_date     => location_rec.active_end_date,
            p_area         => NVL(location_rec.assignable_area,0),
            p_date_table   => l_ref_vacancy_date_table,
            p_number_table => l_ref_vacancy_num_table,
            p_add          => TRUE);

      END IF;

   END LOOP;

   l_info := ' inserting vacancy data for last location id';
   pnp_debug_pkg.log(l_info);

   insert_vacancy_data(
      p_location_id          => l_temp_loc_id,
      p_property_id          => l_temp_prop_id,
      p_date_table           => l_vacancy_date_table,
      p_num_table            => l_vacancy_num_table,
      p_ref_date_table       => l_ref_vacancy_date_table,
      p_ref_num_table        => l_ref_vacancy_num_table,
      p_from_date            => fnd_date.canonical_to_date(p_from_date),
      p_to_date              => fnd_date.canonical_to_date(p_to_date),
      p_as_of_date           => fnd_date.canonical_to_date(p_as_of_date),
      p_assignable_area      => l_temp_assignable_area,
      p_curnt_ovr            => l_area_cls_ln_curnt_ovr,
      p_prior_ovr            => l_area_cls_ln_prior_ovr,
      p_data_tbl             => l_area_cls_ln_data_tbl,
      p_total_tbl            => l_area_total_tbl,
      p_keep_override        => p_keep_override,
      p_regenerate           => l_regenerate
   );

   l_temp_loc_id          := null;
   l_temp_prop_id         := null;
   l_vacancy_date_table.delete;
   l_vacancy_num_table.delete;
   l_ref_vacancy_date_table.delete;
   l_ref_vacancy_num_table.delete;

   l_info := ' processing header data ';
   pnp_debug_pkg.log(l_info);

   IF l_area_class_dtl_id IS NOT NULL THEN

      pn_rec_arcl_dtl_pkg.update_row(
         x_area_class_id          => p_area_class_id,
         x_area_class_dtl_id      => l_area_class_dtl_id,
         x_as_of_date             => fnd_date.canonical_to_date(p_as_of_date),
         x_from_date              => fnd_date.canonical_to_date(p_from_date),
         x_to_date                => fnd_date.canonical_to_date(p_to_date),
         x_status                 => 'OPEN',
         x_ttl_assignable_area    => l_area_total_tbl(0).total_assignable_area,
         x_ttl_occupied_area      => l_area_total_tbl(0).total_occupied_area,
         x_ttl_occupied_area_ovr  => l_area_total_tbl(0).total_occupied_area_ovr,
         x_ttl_occupied_area_exc  => l_area_total_tbl(0).total_occupied_area_exc,
         x_ttl_vacant_area        => l_area_total_tbl(0).total_vacant_area,
         x_ttl_vacant_area_ovr    => l_area_total_tbl(0).total_vacant_area_ovr,
         x_ttl_vacant_area_exc    => l_area_total_tbl(0).total_vacant_area_exc,
         x_ttl_weighted_avg       => l_area_total_tbl(0).total_weighted_avg,
         x_ttl_weighted_avg_ovr   => l_area_total_tbl(0).total_weighted_avg_ovr,
         x_ttl_weighted_avg_exc   => l_area_total_tbl(0).total_weighted_avg_exc,
         x_last_update_date       => SYSDATE,
         x_last_updated_by        => nvl(fnd_profile.value('USER_ID'), -1),
         x_creation_date          => SYSDATE,
         x_created_by             => nvl(fnd_profile.value('USER_ID'), -1),
         x_last_update_login      => nvl(fnd_profile.value('USER_ID'), -1)
      );
   ELSE
      pn_rec_arcl_dtl_pkg.insert_row(
         x_org_id                 => pn_mo_cache_utils.get_current_org_id,
         x_area_class_id          => p_area_class_id,
         x_area_class_dtl_id      => l_area_class_dtl_id,
         x_as_of_date             => fnd_date.canonical_to_date(p_as_of_date),
         x_from_date              => fnd_date.canonical_to_date(p_from_date),
         x_to_date                => fnd_date.canonical_to_date(p_to_date),
         x_status                 => 'OPEN',
         x_ttl_assignable_area    => l_area_total_tbl(0).total_assignable_area,
         x_ttl_occupied_area      => l_area_total_tbl(0).total_occupied_area,
         x_ttl_occupied_area_ovr  => l_area_total_tbl(0).total_occupied_area_ovr,
         x_ttl_occupied_area_exc  => l_area_total_tbl(0).total_occupied_area_exc,
         x_ttl_vacant_area        => l_area_total_tbl(0).total_vacant_area,
         x_ttl_vacant_area_ovr    => l_area_total_tbl(0).total_vacant_area_ovr,
         x_ttl_vacant_area_exc    => l_area_total_tbl(0).total_vacant_area_exc,
         x_ttl_weighted_avg       => l_area_total_tbl(0).total_weighted_avg,
         x_ttl_weighted_avg_ovr   => l_area_total_tbl(0).total_weighted_avg_ovr,
         x_ttl_weighted_avg_exc   => l_area_total_tbl(0).total_weighted_avg_exc,
         x_last_update_date       => SYSDATE,
         x_last_updated_by        => nvl(fnd_profile.value('USER_ID'), -1),
         x_creation_date          => SYSDATE,
         x_created_by             => nvl(fnd_profile.value('USER_ID'), -1),
         x_last_update_login      => nvl(fnd_profile.value('USER_ID'), -1)
      );
   END IF;

   l_info := ' dumping data from pl/sql table ';
   pnp_debug_pkg.log(l_info);

   process_area_class_line_data(
     p_old_data  => l_area_cls_ln_curnt_ovr,
     p_new_data  => l_area_cls_ln_data_tbl,
     p_hdr_id    => l_area_class_dtl_id
   );

   pnp_debug_pkg.log(l_desc ||' (-)');

EXCEPTION
  WHEN uom_exception THEN
     pnp_debug_pkg.log(fnd_message.get);
     raise;
  WHEN OTHERS THEN
     fnd_message.set_name('PN','PN_REC_CP_INCOMPLETE');
     pnp_debug_pkg.put_log_msg(fnd_message.get);
     pnp_debug_pkg.log(l_desc || ': Error while ' || l_info);
     raise;
END extract_area;

---------------------------- EXPENSE VALIDATIONS -----------------------------+

------------------------------------------------------------------------------+
-- FUNCTION   : check_dates
-- DESCRIPTION: checks that from date and to date does not overlap for a given
--              location / prop id extraction.
-- NOTE   : from_date < as_of_date < to_date is NOT checked.
-- HISTORY:
-- 19-MAR-03 ftanudja o created
-- 02-JUL-03 ftanudja o added constraint p_extr code <> null
------------------------------------------------------------------------------+

FUNCTION check_dates(
           p_as_of_date   pn_rec_exp_line.as_of_date%TYPE,
           p_from_date    pn_rec_exp_line.from_date%TYPE,
           p_to_date      pn_rec_exp_line.to_date%TYPE,
           p_property_id  pn_rec_exp_line.property_id%TYPE,
           p_location_id  pn_rec_exp_line.location_id%TYPE,
           p_extract_code pn_rec_exp_line.expense_extract_code%TYPE
         ) RETURN BOOLEAN
IS
   l_result BOOLEAN := TRUE;

   CURSOR line_check_crossing_dates IS
    SELECT 'TRUE' FROM pn_rec_exp_line
    WHERE ((p_from_date BETWEEN from_date AND to_date) OR
           (p_to_date BETWEEN from_date AND to_date))
     AND  (((location_id = p_location_id) OR (location_id IS NULL AND p_location_id IS NULL)) OR
           (((property_id = p_property_id) OR (property_id IS NULL AND p_property_id IS NULL))
           AND location_id IS NULL))
     AND p_extract_code IS NOT NULL
     AND expense_extract_code <> p_extract_code
     AND rownum < 2;

BEGIN
   IF p_from_date > p_to_date THEN
       l_result:= FALSE;
   END IF;

   FOR check_valid IN line_check_crossing_dates LOOP l_result := FALSE; END LOOP;

   RETURN l_result;
END;

------------------------------------------------------------------------------+
-- FUNCTION   : check_loc_n_prop_id
-- DESCRIPTION:
-- 1. checks that location id is valid.
-- 2. checks that property id is valid.
-- 3. checks that location id / property id combination valid
-- HISTORY:
-- 19-MAR-03 ftanudja o created
-- 06-OCT-07 bifernan o Modified cursor prop_loc_combo_check for bug 6461211
------------------------------------------------------------------------------+

FUNCTION check_loc_n_prop_id(
           p_location_id              pn_locations.location_id%TYPE,
           p_property_id              pn_locations.property_id%TYPE
         ) RETURN BOOLEAN
IS
   l_result BOOLEAN:= FALSE;

   CURSOR loc_check IS
      SELECT 'TRUE' FROM pn_locations_all WHERE location_id = p_location_id;

   CURSOR prop_check IS
      SELECT 'TRUE' FROM pn_properties_all WHERE property_id = p_property_id;

   /* Commented and modified for Bug 6461211
   CURSOR prop_loc_combo_check IS
      SELECT 'TRUE' FROM pn_locations_all WHERE location_id = p_location_id AND property_id = p_property_id; */

   CURSOR prop_loc_combo_check IS
      SELECT 'TRUE' FROM pn_locations_all
       WHERE property_id = p_property_id
       START WITH location_id = p_location_id
       CONNECT BY PRIOR parent_location_id = location_id;

BEGIN
   IF p_location_id IS NOT NULL THEN

      FOR loc_rec IN loc_check LOOP l_result := TRUE; exit; END LOOP;

      IF p_property_id IS NOT NULL THEN

         l_result:= FALSE;
         FOR loc_rec IN prop_loc_combo_check LOOP l_result := TRUE; exit;END LOOP;

      END IF;

   ELSIF p_property_id IS NOT NULL THEN

       FOR prop_rec IN prop_check LOOP l_result := TRUE; exit; END LOOP;

   END IF;

   return l_result;
END;

------------------------------------------------------------------------------+
-- FUNCTION   : check_expense_type
-- DESCRIPTION: checks that expense_type is valid
-- HISTORY:
-- 19-MAR-03 ftanudja o created
------------------------------------------------------------------------------+

FUNCTION check_expense_type(p_exp_type_code pn_rec_exp_itf.expense_type_code%TYPE)
RETURN BOOLEAN
IS
   CURSOR type_check IS
      SELECT 'TRUE' FROM fnd_lookups
      WHERE lookup_type = 'PN_PAYMENT_PURPOSE_TYPE' and lookup_code = p_exp_type_code;

   l_result BOOLEAN := FALSE;
BEGIN
   FOR type_rec IN type_check LOOP l_result := TRUE; exit; END LOOP;
   return l_result;
END;

------------------------------------------------------------------------------+
-- FUNCTION   : check_extract_code
-- DESCRIPTION: checks extract_code from user
-- HISTORY:
-- 19-MAR-03 ftanudja o created
------------------------------------------------------------------------------+

FUNCTION check_extract_code(
          p_extract_code pn_rec_exp_line.expense_extract_code%TYPE,
          p_loc_id       pn_rec_exp_line.location_id%TYPE,
          p_prop_id      pn_rec_exp_line.property_id%TYPE,
          p_as_of_date   pn_rec_exp_line.as_of_date%TYPE,
          p_from_date    pn_rec_exp_line.from_date%TYPE,
          p_to_date      pn_rec_exp_line.to_date%TYPE,
          p_currency     pn_rec_exp_line.currency_code%TYPE)
RETURN BOOLEAN
IS
   CURSOR check_exists IS
    SELECT location_id,
           property_id,
           from_date,
           to_date,
           as_of_date,
           currency_code,
           org_id
     FROM  pn_rec_exp_line_all
     WHERE expense_extract_code = p_extract_code;

   l_exist  BOOLEAN := FALSE;
   l_same   BOOLEAN := FALSE;
BEGIN

   IF p_extract_code IS NOT NULL THEN
      FOR extract_rec IN check_exists LOOP
         l_exist := TRUE;
         IF ((extract_rec.location_id = p_loc_id) OR
             (extract_rec.location_id IS NULL AND p_loc_id IS NULL)) AND
            ((extract_rec.property_id = p_prop_id) OR
             (extract_rec.property_id IS NULL AND p_prop_id IS NULL)) AND
            TRUNC(extract_rec.from_date)= TRUNC(p_from_date) AND
            TRUNC(extract_rec.to_date)  = TRUNC(p_to_date)   AND
            extract_rec.currency_code   = p_currency  AND
            extract_rec.org_id          = pn_mo_cache_utils.get_current_org_id THEN
             l_same := TRUE;
         END IF;
      END LOOP;

      IF l_exist AND NOT l_same THEN
         RETURN FALSE;
      ELSE
         RETURN TRUE;
      END IF;
   ELSE
      RETURN FALSE;
   END IF;
END;

------------------------------------------------------------------------------+
-- FUNCTION   : check_account_id
-- DESCRIPTION: checks whetever a given cc_id is valid
-- HISTORY:
-- 19-MAR-03 ftanudja o created
------------------------------------------------------------------------------+

FUNCTION check_account_id(p_cc_id pn_rec_exp_itf.expense_account_id%TYPE)
RETURN BOOLEAN
IS
   l_result BOOLEAN := FALSE;
   CURSOR ccid_check IS
    SELECT 'TRUE' FROM gl_code_combinations where code_combination_id = p_cc_id;

BEGIN
   FOR acct_rec IN ccid_check LOOP l_result:= TRUE; exit; END LOOP;
   RETURN l_result;
END;

------------------------------------------------------------------------------+
-- FUNCTION   : check_ccid_n_type
-- DESCRIPTION:
-- 1. checks for expense type and account id combination.
-- 2. a given combination must exist only once given a certain from and to date
--
-- HISTORY:
-- 19-MAR-03 ftanudja o created
------------------------------------------------------------------------------+

FUNCTION check_ccid_n_type(
            p_exp_type_code pn_rec_exp_line_dtl.expense_type_code%TYPE,
            p_cc_id         pn_rec_exp_line_dtl.expense_account_id%TYPE,
            p_from_date     pn_rec_exp_line.from_date%TYPE,
            p_to_date       pn_rec_exp_line.to_date%TYPE
        ) RETURN BOOLEAN
IS
   l_result BOOLEAN := TRUE;
   CURSOR check_ccid_type IS
      SELECT 'EXISTS'
        FROM pn_rec_exp_line_dtl dtl,
             pn_rec_exp_line hdr
      WHERE  dtl.expense_line_id = hdr.expense_line_id
       AND hdr.from_date = p_from_date
       AND hdr.to_date = p_to_date
       AND dtl.expense_type_code = p_exp_type_code
       AND dtl.expense_account_id = p_cc_id;


BEGIN
   FOR acct_type_rec IN check_ccid_type LOOP l_result:= FALSE; exit; END LOOP;
   RETURN l_result;
END;

----------------------------- EXPENSE LINE -----------------------------------+

------------------------------------------------------------------------------+
-- PROCEDURE  : validate_and_process_lines
-- DESCRIPTION:
-- 1. Given : some expense line data.
-- 2. Check validity of each line and put them into expense lines table.
-- 3. Return status flag.
--
-- HISTORY:
-- 19-MAR-03 ftanudja o created
-- 02-JUL-03 ftanudja o made p_extract_code to IN OUT for auto num gen feat.
-- 15-AUG-03 ftanudja o added flexfield attributes for expclndtl. 3099278.
-- 15-JUL-05 SatyaDeep o Replaced base views with their _ALL tables
------------------------------------------------------------------------------+

PROCEDURE validate_and_process_lines(
            p_transfer_flag            OUT NOCOPY pn_rec_exp_itf.transfer_flag%TYPE,
            p_expense_line_dtl_id      OUT NOCOPY pn_rec_exp_line_dtl.expense_line_dtl_id%TYPE,
            p_expense_line_id          IN OUT NOCOPY pn_rec_exp_line_dtl.expense_line_id%TYPE,
            p_is_header_set            IN OUT NOCOPY BOOLEAN,
            p_expense_type_code        pn_rec_exp_itf.expense_type_code%TYPE,
            p_expense_account_id       pn_rec_exp_itf.expense_account_id%TYPE,
            p_account_description      pn_rec_exp_itf.account_description%TYPE,
            p_actual_amount            pn_rec_exp_itf.actual_amount%TYPE,
            p_budgeted_amount          pn_rec_exp_itf.budgeted_amount%TYPE,
            p_currency_code            pn_rec_exp_itf.currency_code%TYPE,
            p_location_id              pn_rec_exp_itf.location_id%TYPE,
            p_property_id              pn_rec_exp_itf.property_id%TYPE,
            p_as_of_date               pn_rec_exp_line.as_of_date%TYPE,
            p_from_date                pn_rec_exp_line.from_date%TYPE,
            p_to_date                  pn_rec_exp_line.to_date%TYPE,
            p_extract_code             IN OUT NOCOPY pn_rec_exp_line.expense_extract_code%TYPE,
            p_keep_override            VARCHAR2,
            p_reextract                BOOLEAN,
            p_attribute_category       pn_rec_exp_itf.attribute_category%TYPE,
            p_attribute1               pn_rec_exp_itf.attribute1%TYPE,
            p_attribute2               pn_rec_exp_itf.attribute2%TYPE,
            p_attribute3               pn_rec_exp_itf.attribute3%TYPE,
            p_attribute4               pn_rec_exp_itf.attribute4%TYPE,
            p_attribute5               pn_rec_exp_itf.attribute5%TYPE,
            p_attribute6               pn_rec_exp_itf.attribute6%TYPE,
            p_attribute7               pn_rec_exp_itf.attribute7%TYPE,
            p_attribute8               pn_rec_exp_itf.attribute8%TYPE,
            p_attribute9               pn_rec_exp_itf.attribute9%TYPE,
            p_attribute10              pn_rec_exp_itf.attribute10%TYPE,
            p_attribute11              pn_rec_exp_itf.attribute11%TYPE,
            p_attribute12              pn_rec_exp_itf.attribute12%TYPE,
            p_attribute13              pn_rec_exp_itf.attribute13%TYPE,
            p_attribute14              pn_rec_exp_itf.attribute14%TYPE,
            p_attribute15              pn_rec_exp_itf.attribute15%TYPE)
IS
   l_desc        VARCHAR2(100) := 'pn_recovery_extract_pkg.validate_and_process_lines' ;
   l_info        VARCHAR2(300);
   l_is_valid    BOOLEAN;

BEGIN

   pnp_debug_pkg.log(l_desc ||' (+)');

   l_is_valid := check_loc_n_prop_id (p_location_id, p_property_id) AND
                 check_expense_type  (p_expense_type_code)          AND
                 check_account_id    (p_expense_account_id);

   IF p_reextract THEN
       l_is_valid := l_is_valid AND check_ccid_n_type (p_expense_type_code, p_expense_account_id, p_from_date, p_to_date);
   END IF;

   IF l_is_valid THEN

       IF NOT p_is_header_set AND NOT p_reextract THEN

          p_is_header_set := TRUE;

          l_info:= ' inserting expense line header';
          pnp_debug_pkg.log(l_info);

          pn_rec_exp_line_pkg.insert_row(
                x_org_id                 => to_number(pn_mo_cache_utils.get_current_org_id),
                x_expense_line_id        => p_expense_line_id,
                x_expense_extract_code   => p_extract_code,
                x_currency_code          => p_currency_code,
                x_as_of_date             => p_as_of_date,
                x_from_date              => p_from_date,
                x_to_date                => p_to_date,
                x_location_id            => p_location_id,
                x_property_id            => p_property_id,
                x_last_update_date       => SYSDATE,
                x_last_updated_by        => nvl(fnd_profile.value('USER_ID'),-1),
                x_creation_date          => SYSDATE,
                x_created_by             => nvl(fnd_profile.value('USER_ID'),-1),
                x_last_update_login      => nvl(fnd_profile.value('USER_ID'),-1)
          );

       END IF;

       l_info:= ' inserting expense line detail for header id: '||p_expense_line_id;
       pnp_debug_pkg.log(l_info);

       pn_rec_exp_line_dtl_pkg.insert_row(
          x_org_id                   => to_number(pn_mo_cache_utils.get_current_org_id),
          x_expense_line_id          => p_expense_line_id,
          x_expense_line_dtl_id      => p_expense_line_dtl_id,
          x_parent_expense_line_id   => null,
          x_property_id              => p_property_id,
          x_location_id              => p_location_id,
          x_expense_type_code        => p_expense_type_code,
          x_expense_account_id       => p_expense_account_id,
          x_account_description      => p_account_description,
          x_actual_amount            => p_actual_amount,
          x_actual_amount_ovr        => null,
          x_budgeted_amount          => p_budgeted_amount,
          x_budgeted_amount_ovr      => null,
          x_budgeted_pct             => null,
          x_actual_pct               => null,
          x_currency_code            => p_currency_code,
          x_recoverable_flag         => 'Y',
          x_expense_line_indicator   => 'NEUTRAL',
          x_last_update_date         => SYSDATE,
          x_last_updated_by          => nvl(fnd_profile.value('USER_ID'),-1),
          x_creation_date            => SYSDATE,
          x_created_by               => nvl(fnd_profile.value('USER_ID'),-1),
          x_last_update_login        => nvl(fnd_profile.value('USER_ID'),-1),
          x_attribute_category       => p_attribute_category,
          x_attribute1               => p_attribute1,
          x_attribute2               => p_attribute2,
          x_attribute3               => p_attribute3,
          x_attribute4               => p_attribute4,
          x_attribute5               => p_attribute5,
          x_attribute6               => p_attribute6,
          x_attribute7               => p_attribute7,
          x_attribute8               => p_attribute8,
          x_attribute9               => p_attribute9,
          x_attribute10              => p_attribute10,
          x_attribute11              => p_attribute11,
          x_attribute12              => p_attribute12,
          x_attribute13              => p_attribute13,
          x_attribute14              => p_attribute14,
          x_attribute15              => p_attribute15
       );

      p_transfer_flag := 'Y';

   ELSE

      p_transfer_flag := 'E';

   END IF;

   pnp_debug_pkg.log(l_desc ||' (-)');

EXCEPTION
  WHEN OTHERS THEN
     pnp_debug_pkg.log(l_desc || ': Error while ' || l_info);
     raise;
END;

------------------------------------------------------------------------------+
-- PROCEDURE  : extract_expense_lines
-- DESCRIPTION:
-- 1. Get all lines from interface table.
-- 2. Find out whether it is a re-extract or not.
-- 3. Process and validate data
-- 4. Update ITF table transfer flag to 'Y' if transferred, 'E' if erroneous.
-- HISTORY:
-- 19-MAR-03 ftanudja o created
-- 02-JUL-03 ftanudja o added constraint p_extr code <> null in is_reextract.
--                    o made p_extract_code to IN OUT for auto num gen feat.
-- 03-JUL-03 ftanudja o fixed cursor to handle cases when only prop id given.
-- 10-JUL-03 ftanudja o made prop id and loc id mutex on get_itf_lines_info.
-- 15-AUG-03 ftanudja o added flexfield attributes for expclndtl. 3099278.
-- 21-MAY-03 ftanudja o added counters to summarize totals. 3591556.
--                    o added log output message to show input parameters.
--                    o added logic for batch commit.
--                    o added org_id filter.
-- 15-JUL-05 SatyaDeep o Replaced base views with their _ALL tables
------------------------------------------------------------------------------+

PROCEDURE extract_expense_lines(
            p_location_id   pn_rec_exp_line.location_id%TYPE,
            p_property_id   pn_rec_exp_line.property_id%TYPE,
            p_as_of_date    pn_rec_exp_line.as_of_date%TYPE,
            p_from_date     pn_rec_exp_line.from_date%TYPE,
            p_to_date       pn_rec_exp_line.to_date%TYPE,
            p_currency_code pn_rec_exp_line.currency_code%TYPE,
            p_extract_code  IN OUT NOCOPY pn_rec_exp_line.expense_extract_code%TYPE,
            p_keep_override VARCHAR2)
IS
   CURSOR get_itf_lines_info IS
    SELECT expense_type_code,
           expense_account_id,
           account_description,
           actual_amount,
           budgeted_amount,
           currency_code,
           location_id,
           property_id,
           attribute_category,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
           attribute7,
           attribute8,
           attribute9,
           attribute10,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15
      FROM pn_rec_exp_itf
     WHERE transfer_flag = 'N'
       AND from_date = p_from_date
       AND to_date = p_to_date
       AND currency_code = p_currency_code
       AND (location_id IN
            (SELECT location_id FROM pn_locations_all
             WHERE active_start_date < p_to_date
             AND   active_end_date >  p_from_date
             START WITH (location_id =  p_location_id OR
                         (property_id = p_property_id AND p_location_id IS NULL))
             CONNECT BY PRIOR  location_id =  parent_location_id)
            OR
            (property_id = p_property_id AND p_location_id IS NULL))
       AND org_id = pn_mo_cache_utils.get_current_org_id
     FOR UPDATE OF transfer_flag, expense_line_dtl_id NOWAIT;

   CURSOR is_reextract IS
    SELECT expense_line_id
      FROM pn_rec_exp_line_all hdr
     WHERE hdr.expense_extract_code = p_extract_code
       AND p_extract_code IS NOT NULL
       AND rownum < 2;

   l_desc                VARCHAR2(100) := 'pn_recovery_extract_pkg.extract_expense_lines' ;
   l_info                VARCHAR2(300);
   l_is_header_set       BOOLEAN;
   l_reextract           BOOLEAN;
   l_expense_line_dtl_id pn_rec_exp_line_dtl.expense_line_dtl_id%TYPE;
   l_expense_line_id     pn_rec_exp_line_dtl.expense_line_id%TYPE;
   l_transfer_flag       pn_rec_exp_itf.transfer_flag%TYPE;
   l_total               NUMBER := 0;
   l_failed              NUMBER := 0;

BEGIN

   pnp_debug_pkg.log(l_desc ||' (+)');

   fnd_message.set_name('PN','PN_REC_EXP_LN_CP_INFO');
   fnd_message.set_token('LOC'   , to_char(p_location_id));
   fnd_message.set_token('PROP'  , to_char(p_property_id));
   fnd_message.set_token('STR'   , to_char(p_from_date));
   fnd_message.set_token('END'   , to_char(p_to_date));
   fnd_message.set_token('AOD'   , to_char(p_as_of_date));
   fnd_message.set_token('CUR'   , p_currency_code);
   fnd_message.set_token('EXPNUM', p_extract_code);
   fnd_message.set_token('OVR'   , p_keep_override);
   pnp_debug_pkg.put_log_msg('');
   pnp_debug_pkg.put_log_msg(fnd_message.get);
   pnp_debug_pkg.put_log_msg('');

   l_info                := ' initializing values';
   pnp_debug_pkg.log(l_info);

   l_expense_line_id     := null;
   l_is_header_set       := FALSE;
   l_reextract           := FALSE;

   FOR check_reextract IN is_reextract LOOP
      l_reextract := TRUE;
      l_expense_line_id := check_reextract.expense_line_id;
   END LOOP;

   FOR lines_rec IN get_itf_lines_info LOOP

      l_expense_line_dtl_id := null;

      validate_and_process_lines(
         p_transfer_flag            => l_transfer_flag,
         p_expense_line_dtl_id      => l_expense_line_dtl_id,
         p_expense_line_id          => l_expense_line_id,
         p_is_header_set            => l_is_header_set,
         p_expense_type_code        => lines_rec.expense_type_code,
         p_expense_account_id       => lines_rec.expense_account_id,
         p_account_description      => lines_rec.account_description,
         p_actual_amount            => lines_rec.actual_amount,
         p_budgeted_amount          => lines_rec.budgeted_amount,
         p_currency_code            => lines_rec.currency_code,
         p_location_id              => lines_rec.location_id,
         p_property_id              => lines_rec.property_id,
         p_as_of_date               => p_as_of_date,
         p_from_date                => p_from_date,
         p_to_date                  => p_to_date,
         p_extract_code             => p_extract_code,
         p_keep_override            => p_keep_override,
         p_reextract                => l_reextract,
         p_attribute_category       => lines_rec.attribute_category,
         p_attribute1               => lines_rec.attribute1,
         p_attribute2               => lines_rec.attribute2,
         p_attribute3               => lines_rec.attribute3,
         p_attribute4               => lines_rec.attribute4,
         p_attribute5               => lines_rec.attribute5,
         p_attribute6               => lines_rec.attribute6,
         p_attribute7               => lines_rec.attribute7,
         p_attribute8               => lines_rec.attribute8,
         p_attribute9               => lines_rec.attribute9,
         p_attribute10              => lines_rec.attribute10,
         p_attribute11              => lines_rec.attribute11,
         p_attribute12              => lines_rec.attribute12,
         p_attribute13              => lines_rec.attribute13,
         p_attribute14              => lines_rec.attribute14,
         p_attribute15              => lines_rec.attribute15
      );

      l_total := l_total + 1;

      IF l_transfer_flag = 'E' THEN
          l_failed := l_failed + 1;
      END IF;

      -- do a batch commit if needed
      IF mod(l_total, g_batch_commit_size) = 0 THEN
         commit;
      END IF;

      l_info := ' updating interface table ';
      pnp_debug_pkg.log(l_info);

      UPDATE pn_rec_exp_itf
      SET transfer_flag = l_transfer_flag,
          expense_line_dtl_id = l_expense_line_dtl_id
      WHERE CURRENT OF get_itf_lines_info;

   END LOOP;

   fnd_message.set_name('PN','PN_REC_EXP_LN');
   pnp_debug_pkg.put_log_msg('');
   pnp_debug_pkg.put_log_msg(fnd_message.get);

   fnd_message.set_name('PN','PN_CP_RESULT_SUMMARY');
   fnd_message.set_token('TOTAL', TO_CHAR(l_total));
   fnd_message.set_token('PASS', TO_CHAR(l_total - l_failed));
   fnd_message.set_token('FAIL', TO_CHAR(l_failed));
   pnp_debug_pkg.put_log_msg(fnd_message.get);
   pnp_debug_pkg.put_log_msg('');

   pnp_debug_pkg.log(l_desc ||' (-)');

EXCEPTION
  WHEN OTHERS THEN
     pnp_debug_pkg.log(l_desc || ': Error while ' || l_info);
     raise;

END extract_expense_lines;

--------------------------- EXPENSE CLASS LINE -------------------------------+

------------------------------------------------------------------------------+
-- PROCEDURE  : process_exp_cls_dtl_mst_data
--
-- DESCRIPTION:
-- 1. Given : data table p_master_data.
-- 2. Determine whether a matching row can be found.
-- 3. If found, update, otherwise insert new row.
--
-- NOTES:
-- A. Use of override tables p_fee_use_table, p_share_use_table
--  1. The purpose is to keep track whether share pct and fee % bf contr
--     should be used at this level.
--  2. It should only be used to calculate the computed recoverable amount
--     if and only if there aren't any values defined at the account drilldown.
-- B. Use of tables p_ovr_use_data and p_use_prior_ovr
--  1. p_ovr_use_data keeps track whether the current _ovr values are from
--     a regeneration or from a prior extract.
--  2. it's possible to have aregenerate in which values from a prior extract
--     are defaulted... since at run time it's not known which value should
--     be used, this information needs to be kept to populate the correct _ovr
--     values.
--  3. p_use_prior_ovr determines whether _ovr values should be used.
--
-- HISTORY:
-- 19-MAR-03 ftanudja o created
-- 15-JUL-05 SatyaDeepo Replaced base views with their _ALL tables
------------------------------------------------------------------------------+

PROCEDURE process_exp_cls_dtl_mst_data(
           p_master_data               IN OUT NOCOPY exp_cls_line_mst_tbl,
           p_ovr_use_data              IN OUT NOCOPY exp_cls_line_use_tbl,
           p_fee_use_table             IN OUT NOCOPY exp_cls_line_use_tbl,
           p_share_use_table           IN OUT NOCOPY exp_cls_line_use_tbl,
           p_master_data_id            OUT NOCOPY pn_rec_expcl_dtlln.expense_class_line_id%TYPE,
           p_expense_class_line_id     pn_rec_expcl_dtlln.expense_class_line_id%TYPE,
           p_expense_class_dtl_id      pn_rec_expcl_dtlln.expense_class_dtl_id%TYPE,
           p_location_id               pn_space_assign_cust.location_id%TYPE,
           p_cust_space_assign_id      pn_space_assign_cust.cust_space_assign_id%TYPE,
           p_cust_account_id           pn_space_assign_cust.cust_account_id%TYPE,
           p_lease_id                  pn_rec_expcl_dtlln.lease_id%TYPE,
           p_recovery_space_std_code   pn_rec_expcl_dtlln.recovery_space_std_code%TYPE,
           p_recovery_type_code        pn_rec_expcl_dtlln.recovery_type_code%TYPE,
           p_budget_amount             pn_rec_expcl_dtlln.budgeted_amt%TYPE,
           p_expense_amount            pn_rec_expcl_dtlln.expense_amt%TYPE,
           p_recoverable_amount        pn_rec_expcl_dtlln.recoverable_amt%TYPE,
           p_cpt_recoverable_amount    pn_rec_expcl_dtlln.computed_recoverable_amt%TYPE,
           p_cls_line_share_pct        pn_rec_expcl_dtlln.cls_line_share_pct%TYPE,
           p_cls_line_fee_af_contr_ovr pn_rec_expcl_dtlln.cls_line_fee_after_contr_ovr%TYPE,
           p_cls_line_fee_bf_contr_ovr pn_rec_expcl_dtlln.cls_line_fee_before_contr_ovr%TYPE,
           p_use_fee_bf_contr          pn_rec_expcl_inc.cls_incl_fee_before_contr%TYPE,
           p_use_share_pct             pn_rec_expcl_dtlacc.cls_line_dtl_share_pct%TYPE,
           p_use_prior_ovr             BOOLEAN
          )
IS
   l_info    VARCHAR2(300);
   l_desc    VARCHAR2(100) := 'pn_recovery_extract_pkg.process_exp_cls_dtl_mst_data' ;
   temp_rec  pn_rec_expcl_dtlln%ROWTYPE;

BEGIN

   pnp_debug_pkg.log(l_desc ||' (+)');

   p_master_data_id := -1;

   l_info:= ' searching through master table';
   pnp_debug_pkg.log(l_info);

   FOR i IN 0 .. p_master_data.COUNT - 1 LOOP

      IF (p_master_data(i).location_id = p_location_id) AND
         (p_master_data(i).cust_account_id = p_cust_account_id) THEN

         l_info:= ' updating values in master data object for location id '||p_location_id||' and customer acct id'|| p_cust_account_id;
         pnp_debug_pkg.log(l_info);

         p_master_data(i).budgeted_amt    := nvl(p_master_data(i).budgeted_amt, 0) + nvl(p_budget_amount,0);
         p_master_data(i).expense_amt     := nvl(p_master_data(i).expense_amt, 0) + nvl(p_expense_amount,0);
         p_master_data(i).recoverable_amt := nvl(p_master_data(i).recoverable_amt, 0) + nvl(p_recoverable_amount,0);
         p_master_data(i).computed_recoverable_amt := nvl(p_master_data(i).computed_recoverable_amt, 0) + nvl(p_cpt_recoverable_amount,0);
         p_master_data_id := i;

         p_fee_use_table(i)   := p_fee_use_table(i) AND (p_use_fee_bf_contr IS NULL);
         p_share_use_table(i) := p_share_use_table(i) AND (p_use_share_pct IS NULL);

         IF p_ovr_use_data(i) AND NOT p_use_prior_ovr THEN

           p_master_data(i).cls_line_share_pct           := p_cls_line_share_pct;
           p_master_data(i).cls_line_fee_before_contr_ovr:= p_cls_line_fee_bf_contr_ovr;
           p_master_data(i).cls_line_fee_after_contr_ovr := p_cls_line_fee_af_contr_ovr;

         END IF;

         exit;

      END IF;
   END LOOP;

   IF (p_master_data_id = -1) THEN

       p_master_data_id                      := p_master_data.COUNT;

       l_info:= ' creating new entry in master data object';
       pnp_debug_pkg.log(l_info);

       temp_rec.expense_class_dtl_id         := p_expense_class_dtl_id;
       temp_rec.expense_class_line_id        := p_expense_class_line_id;
       temp_rec.location_id                  := p_location_id;
       temp_rec.cust_space_assign_id         := p_cust_space_assign_id;
       temp_rec.cust_account_id              := p_cust_account_id;
       temp_rec.lease_id                     := p_lease_id;
       temp_rec.recovery_space_std_code      := p_recovery_space_std_code;
       temp_rec.recovery_type_code           := p_recovery_type_code;
       temp_rec.cls_line_share_pct           := p_cls_line_share_pct;
       temp_rec.cls_line_fee_before_contr_ovr:= p_cls_line_fee_bf_contr_ovr;
       temp_rec.cls_line_fee_after_contr_ovr := p_cls_line_fee_af_contr_ovr;
       temp_rec.expense_amt                  := p_expense_amount;
       temp_rec.budgeted_amt                 := p_budget_amount;
       temp_rec.recoverable_amt              := p_recoverable_amount;
       temp_rec.computed_recoverable_amt     := p_cpt_recoverable_amount;
       p_master_data(p_master_data_id)       := temp_rec;
       p_fee_use_table(p_master_data_id)     := (p_use_fee_bf_contr IS NULL);
       p_share_use_table(p_master_data_id)   := (p_use_share_pct IS NULL);
       p_ovr_use_data(p_master_data_id)      := p_use_prior_ovr;

   END IF;

   pnp_debug_pkg.log(l_desc ||' (-)');

EXCEPTION
  WHEN OTHERS THEN
     pnp_debug_pkg.log(l_desc || ': Error while ' || l_info);
     raise;
END;

------------------------------------------------------------------------------+
-- PROCEDURE  : process_exp_cls_dtl_dtl_data
-- DESCRIPTION: dumps data in plsql table, given parameters
-- 19-MAR-03 ftanudja o created
-- 15-JUL-05 SatyaDeepo Replaced base views with their _ALL tables
------------------------------------------------------------------------------+

PROCEDURE process_exp_cls_dtl_dtl_data(
           p_detail_data                IN OUT NOCOPY exp_cls_line_dtl_tbl,
           p_master_data_id             pn_rec_expcl_dtlln.expense_class_line_id%TYPE,
           p_expense_class_line_dtl_id  pn_rec_expcl_dtlacc.expense_class_line_dtl_id%TYPE,
           p_expense_line_dtl_id        pn_rec_exp_line_dtl.expense_line_dtl_id%TYPE,
           p_expense_account_id         pn_rec_exp_line_dtl.expense_account_id%TYPE,
           p_expense_type_code          pn_rec_exp_line_dtl.expense_type_code%TYPE,
           p_expense_amount             pn_rec_expcl_dtlln.expense_amt%TYPE,
           p_budget_amount              pn_rec_expcl_dtlln.budgeted_amt%TYPE,
           p_recoverable_amount         pn_rec_expcl_dtlln.recoverable_amt%TYPE,
           p_cpt_recoverable_amount     pn_rec_expcl_dtlln.computed_recoverable_amt%TYPE,
           p_cls_line_shr_pct           pn_rec_expcl_inc.cls_incl_share_pct%TYPE,
           p_cls_line_fee_bf_contr      pn_rec_expcl_inc.cls_incl_fee_before_contr%TYPE,
           p_cls_line_shr_pct_ovr       pn_rec_expcl_dtlacc.cls_line_dtl_share_pct%TYPE,
           p_cls_line_fee_bf_contr_ovr  pn_rec_expcl_dtlacc.cls_line_dtl_fee_bf_contr%TYPE
          )
IS

   l_info VARCHAR2(300);
   l_id   NUMBER;
   l_desc VARCHAR2(100) := 'pn_recovery_extract_pkg.process_exp_cls_dtl_dtl_data' ;

BEGIN

   pnp_debug_pkg.log(l_desc ||' (+)');

   l_info:= ' inserting into details pl/sql table ';
   pnp_debug_pkg.log(l_info);

   l_id := p_detail_data.COUNT;

   p_detail_data(l_id).expense_class_line_dtl_id     := p_expense_class_line_dtl_id;
   p_detail_data(l_id).expense_class_line_id         := p_master_data_id;
   p_detail_data(l_id).expense_line_dtl_id           := p_expense_line_dtl_id;
   p_detail_data(l_id).expense_type_code             := p_expense_type_code;
   p_detail_data(l_id).expense_account_id            := p_expense_account_id;
   p_detail_data(l_id).expense_amt                   := p_expense_amount;
   p_detail_data(l_id).budgeted_amt                  := p_budget_amount;
   p_detail_data(l_id).recoverable_amt               := p_recoverable_amount;
   p_detail_data(l_id).computed_recoverable_amt      := p_cpt_recoverable_amount;
   p_detail_data(l_id).cls_line_dtl_share_pct        := p_cls_line_shr_pct;
   p_detail_data(l_id).cls_line_dtl_fee_bf_contr     := p_cls_line_fee_bf_contr;
   p_detail_data(l_id).cls_line_dtl_share_pct_ovr    := p_cls_line_shr_pct_ovr;
   p_detail_data(l_id).cls_line_dtl_fee_bf_contr_ovr := p_cls_line_fee_bf_contr_ovr;

   pnp_debug_pkg.log(l_desc ||' (-)');

EXCEPTION
  WHEN OTHERS THEN
     pnp_debug_pkg.log(l_desc || ': Error while ' || l_info);
     raise;
END;

------------------------------------------------------------------------------+
-- PROCEDURE  : process_exp_class_line_data
-- DESCRIPTION:
-- 1. Dumps data from pl/sql table into expense class lines table.
-- 2. Determine whether fee % and share % should be used at location level
-- 3. If regeneration, find out which data needs to be deleted.
--
-- 19-MAR-03 ftanudja o created
-- 21-MAY-04 ftanudja o added logic for batch commit.
-- 15-JUL-05 SatyaDeepo Replaced base views with their _ALL tables
------------------------------------------------------------------------------+

PROCEDURE process_exp_class_line_data(
           p_master_data     IN OUT NOCOPY exp_cls_line_mst_tbl,
           p_old_detail_data exp_cls_line_dtl_tbl,
           p_old_master_data exp_cls_line_mst_tbl,
           p_detail_data     exp_cls_line_dtl_tbl,
           p_fee_use_table   exp_cls_line_use_tbl,
           p_share_use_table exp_cls_line_use_tbl,
           p_default_fee_bf  pn_rec_expcl_dtl.cls_line_fee_before_contr%TYPE
          )
IS
   l_expense_class_line_id     pn_rec_expcl_dtlln.expense_class_line_id%TYPE;
   l_expense_class_line_dtl_id pn_rec_expcl_dtlacc.expense_class_line_dtl_id%TYPE;
   l_master_keep_table         number_table_type;
   l_detail_keep_table         number_table_type;
   l_master_delete_table       number_table_type;
   l_detail_delete_table       number_table_type;
   l_is_in                     BOOLEAN;
   l_use_share_pct_flag        VARCHAR2(1);
   l_use_fee_pct_flag          VARCHAR2(1);
   l_info                      VARCHAR2(300);
   l_desc                      VARCHAR2(100) := 'pn_recovery_extract_pkg.process_exp_class_line_data';

BEGIN

   pnp_debug_pkg.log(l_desc ||' (+)');

   FOR i IN 0 .. p_master_data.COUNT - 1 LOOP

      l_info:= ' figuring out whether values should be used ';
      pnp_debug_pkg.log(l_info);

      l_use_share_pct_flag := 'N';
      l_use_fee_pct_flag := 'N';

      IF p_fee_use_table(i) THEN
         l_use_fee_pct_flag := 'Y';
         p_master_data(i).computed_recoverable_amt := p_master_data(i).computed_recoverable_amt *
                                                      (1 + nvl(nvl(p_master_data(i).cls_line_fee_before_contr_ovr, p_default_fee_bf), 0) / 100);
      END IF;

      IF p_share_use_table(i) THEN
         l_use_share_pct_flag := 'Y';
         p_master_data(i).computed_recoverable_amt := p_master_data(i).computed_recoverable_amt *
                                                      nvl(p_master_data(i).cls_line_share_pct, 100) / 100;
      END IF;

      l_expense_class_line_id := p_master_data(i).expense_class_line_id;

      IF l_expense_class_line_id IS NULL THEN

         l_info:= ' inserting data into class lines master table';
         pnp_debug_pkg.log(l_info);

         pn_rec_expcl_dtlln_pkg.insert_row(
            x_org_id                    => to_number(pn_mo_cache_utils.get_current_org_id),
            x_expense_class_dtl_id      => p_master_data(i).expense_class_dtl_id,
            x_expense_class_line_id     => l_expense_class_line_id,
            x_location_id               => p_master_data(i).location_id,
            x_cust_space_assign_id      => p_master_data(i).cust_space_assign_id,
            x_cust_account_id           => p_master_data(i).cust_account_id,
            x_lease_id                  => p_master_data(i).lease_id,
            x_recovery_space_std_code   => p_master_data(i).recovery_space_std_code,
            x_recovery_type_code        => p_master_data(i).recovery_type_code,
            x_budgeted_amt              => p_master_data(i).budgeted_amt,
            x_expense_amt               => p_master_data(i).expense_amt,
            x_recoverable_amt           => p_master_data(i).recoverable_amt,
            x_computed_recoverable_amt  => p_master_data(i).computed_recoverable_amt,
            x_cls_line_share_pct        => p_master_data(i).cls_line_share_pct,
            x_cls_line_fee_bf_ct_ovr    => p_master_data(i).cls_line_fee_before_contr_ovr,
            x_cls_line_fee_af_ct_ovr    => p_master_data(i).cls_line_fee_after_contr_ovr,
            x_use_share_pct_flag        => l_use_share_pct_flag,
            x_use_fee_before_contr_flag => l_use_fee_pct_flag,
            x_last_update_date          => SYSDATE,
            x_last_updated_by           => nvl(fnd_profile.value('USER_ID'),-1),
            x_creation_date             => SYSDATE,
            x_created_by                => nvl(fnd_profile.value('USER_ID'),-1),
            x_last_update_login         => nvl(fnd_profile.value('USER_ID'),-1)
         );

         p_master_data(i).expense_class_line_id := l_expense_class_line_id;

      ELSE

        l_info:= ' updating data into class lines table, id: ' || l_expense_class_line_id;
        pnp_debug_pkg.log(l_info);

        pn_rec_expcl_dtlln_pkg.update_row(
            x_expense_class_line_id     => l_expense_class_line_id,
            x_location_id               => p_master_data(i).location_id,
            x_cust_space_assign_id      => p_master_data(i).cust_space_assign_id,
            x_cust_account_id           => p_master_data(i).cust_account_id,
            x_lease_id                  => p_master_data(i).lease_id,
            x_recovery_space_std_code   => p_master_data(i).recovery_space_std_code,
            x_recovery_type_code        => p_master_data(i).recovery_type_code,
            x_budgeted_amt              => p_master_data(i).budgeted_amt,
            x_expense_amt               => p_master_data(i).expense_amt,
            x_recoverable_amt           => p_master_data(i).recoverable_amt,
            x_computed_recoverable_amt  => p_master_data(i).computed_recoverable_amt,
            x_cls_line_share_pct        => p_master_data(i).cls_line_share_pct,
            x_cls_line_fee_bf_ct_ovr    => p_master_data(i).cls_line_fee_before_contr_ovr,
            x_cls_line_fee_af_ct_ovr    => p_master_data(i).cls_line_fee_after_contr_ovr,
            x_use_share_pct_flag        => l_use_share_pct_flag,
            x_use_fee_before_contr_flag => l_use_fee_pct_flag,
            x_last_update_date          => SYSDATE,
            x_last_updated_by           => nvl(fnd_profile.value('USER_ID'),-1),
            x_creation_date             => SYSDATE,
            x_created_by                => nvl(fnd_profile.value('USER_ID'),-1),
            x_last_update_login         => nvl(fnd_profile.value('USER_ID'),-1)
         );

      END IF;

      l_master_keep_table(l_master_keep_table.COUNT) := l_expense_class_line_id;

      -- do a batch commit if needed
      IF mod (i, g_batch_commit_size) = 0 THEN
         commit;
      END IF;

   END LOOP;

   l_info:= ' processing data for class line details table';
   pnp_debug_pkg.log(l_info);

   FOR i IN 0 .. p_detail_data.COUNT - 1 LOOP

      l_expense_class_line_dtl_id := p_detail_data(i).expense_class_line_dtl_id;

      IF l_expense_class_line_dtl_id IS NULL THEN

         l_info := ' inserting detail data for class line header: '||
                    p_master_data(p_detail_data(i).expense_class_line_id).expense_class_line_id;
         pnp_debug_pkg.log(l_info);

         pn_rec_expcl_dtlacc_pkg.insert_row(
            x_org_id                     => to_number(pn_mo_cache_utils.get_current_org_id),
            x_expense_class_line_id      => p_master_data(p_detail_data(i).expense_class_line_id).expense_class_line_id,
            x_expense_class_line_dtl_id  => l_expense_class_line_dtl_id,
            x_expense_line_dtl_id        => p_detail_data(i).expense_line_dtl_id,
            x_expense_account_id         => p_detail_data(i).expense_account_id,
            x_expense_type_code          => p_detail_data(i).expense_type_code,
            x_cls_line_dtl_share_pct     => p_detail_data(i).cls_line_dtl_share_pct,
            x_cls_line_dtl_share_pct_ovr => p_detail_data(i).cls_line_dtl_share_pct_ovr,
            x_cls_line_dtl_fee_bf_ct     => p_detail_data(i).cls_line_dtl_fee_bf_contr,
            x_cls_line_dtl_fee_bf_ct_ovr => p_detail_data(i).cls_line_dtl_fee_bf_contr_ovr,
            x_expense_amt                => p_detail_data(i).expense_amt,
            x_budgeted_amt               => p_detail_data(i).budgeted_amt,
            x_recoverable_amt            => p_detail_data(i).recoverable_amt,
            x_computed_recoverable_amt   => p_detail_data(i).computed_recoverable_amt,
            x_last_update_date           => SYSDATE,
            x_last_updated_by            => nvl(fnd_profile.value('USER_ID'),-1),
            x_creation_date              => SYSDATE,
            x_created_by                 => nvl(fnd_profile.value('USER_ID'),-1),
            x_last_update_login          => nvl(fnd_profile.value('USER_ID'),-1)
          );
      ELSE
         l_info := ' updating detail data for class line header: '||
                    p_master_data(p_detail_data(i).expense_class_line_id).expense_class_line_id;
         pnp_debug_pkg.log(l_info);

         pn_rec_expcl_dtlacc_pkg.update_row(
            x_expense_class_line_dtl_id  => l_expense_class_line_dtl_id,
            x_expense_line_dtl_id        => p_detail_data(i).expense_line_dtl_id,
            x_expense_account_id         => p_detail_data(i).expense_account_id,
            x_expense_type_code          => p_detail_data(i).expense_type_code,
            x_cls_line_dtl_share_pct     => p_detail_data(i).cls_line_dtl_share_pct,
            x_cls_line_dtl_share_pct_ovr => p_detail_data(i).cls_line_dtl_share_pct_ovr,
            x_cls_line_dtl_fee_bf_ct     => p_detail_data(i).cls_line_dtl_fee_bf_contr,
            x_cls_line_dtl_fee_bf_ct_ovr => p_detail_data(i).cls_line_dtl_fee_bf_contr_ovr,
            x_expense_amt                => p_detail_data(i).expense_amt,
            x_budgeted_amt               => p_detail_data(i).budgeted_amt,
            x_recoverable_amt            => p_detail_data(i).recoverable_amt,
            x_computed_recoverable_amt   => p_detail_data(i).computed_recoverable_amt,
            x_last_update_date           => SYSDATE,
            x_last_updated_by            => nvl(fnd_profile.value('USER_ID'),-1),
            x_creation_date              => SYSDATE,
            x_created_by                 => nvl(fnd_profile.value('USER_ID'),-1),
            x_last_update_login          => nvl(fnd_profile.value('USER_ID'),-1)
         );

      END IF;

      l_detail_keep_table(l_detail_keep_table.COUNT) := l_expense_class_line_dtl_id;

   END LOOP;

   l_info := ' figuring out which data is unused';
   pnp_debug_pkg.log(l_info);

   FOR i IN 0 .. p_old_detail_data.COUNT - 1 LOOP
      l_is_in := FALSE;
      FOR j IN 0 .. l_detail_keep_table.COUNT - 1 LOOP
         IF l_detail_keep_table(j) = p_old_detail_data(i).expense_class_line_dtl_id THEN l_is_in := TRUE; exit; END IF;
      END LOOP;
      IF NOT l_is_in THEN
         l_detail_delete_table(l_detail_delete_table.COUNT) := p_old_detail_data(i).expense_class_line_dtl_id;
      END IF;
   END LOOP;

   FOR i IN 0 .. p_old_master_data.COUNT - 1 LOOP
      l_is_in := FALSE;
      FOR j IN 0 .. l_master_keep_table.COUNT - 1 LOOP
         IF l_master_keep_table(j) = p_old_master_data(i).expense_class_line_id THEN l_is_in := TRUE; exit; END IF;
      END LOOP;
      IF NOT l_is_in THEN
         l_master_delete_table(l_master_delete_table.COUNT) := p_old_master_data(i).expense_class_line_id;
      END IF;
   END LOOP;

   l_info := ' deleting unused data';
   pnp_debug_pkg.log(l_info);

   FORALL i IN 0 .. l_detail_delete_table.COUNT - 1
      DELETE FROM pn_rec_expcl_dtlacc_all
           WHERE expense_class_line_dtl_id = l_detail_delete_table(i);

   FORALL i IN 0 .. l_master_delete_table.COUNT - 1
      DELETE FROM pn_rec_expcl_dtlln_all
           WHERE expense_class_line_id = l_master_delete_table(i);


   pnp_debug_pkg.log(l_desc ||' (-)');

EXCEPTION
  WHEN OTHERS THEN
     pnp_debug_pkg.log(l_desc || ': Error while ' || l_info);
     raise;
END;

------------------------------------------------------------------------------+
-- PROCEDURE  : dismantle_exp_line_from_dtl
-- DESCRIPTION:
-- 1. When an expense is allocated, it needs to be removed from the tables.
-- 2. Determine which expense class line detail and header it impacts
-- 3. Remove appropriate line and recalculate the comp. recoverable amount.
--
-- NOTE:
-- 1. The total can be derived by adding cumulatively. The problem, however,
--    is to determine whether fee% and share% should be used.
-- 2. To accomplish this, we need to hit the database and do a comparison.
-- 3. Might as well do the summation while getting that information.
--
-- HISTORY:
-- 19-MAR-03 ftanudja o created.
-- 06-AUG-03 ftanudja o add deletion mechanism for expcl lines w/ no child.
-- 15-JUL-05 SatyaDeepo Replaced base views with their _ALL tables
------------------------------------------------------------------------------+

PROCEDURE dismantle_exp_line_from_dtl(p_expense_line_dtl_id pn_rec_exp_line_dtl.expense_line_dtl_id%TYPE)
IS
   CURSOR get_affected_lines IS
    SELECT expense_class_line_dtl_id,
           expense_class_line_id
      FROM pn_rec_expcl_dtlacc_all
     WHERE expense_line_dtl_id = p_expense_line_dtl_id;

   CURSOR get_header_info (p_exp_cls_line_id pn_rec_expcl_dtlln.expense_class_line_id%TYPE) IS
    SELECT sum(nvl(computed_recoverable_amt, 0)) computed_recoverable_amount,
           sum(nvl(recoverable_amt, 0)) recoverable_amount,
           sum(nvl(expense_amt, 0)) expense_amount,
           sum(nvl(budgeted_amt, 0)) budgeted_amount,
           min(decode(nvl(cls_line_dtl_share_pct_ovr, cls_line_dtl_share_pct), NULL, NULL, 100)) use_cls_line_share,
           min(decode(nvl(cls_line_dtl_fee_bf_contr_ovr, cls_line_dtl_fee_bf_contr), NULL, NULL, 0)) use_cls_line_fee
      FROM pn_rec_expcl_dtlacc_all
     WHERE expense_class_line_id = p_exp_cls_line_id;

   TYPE num_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   TYPE use_tbl IS TABLE OF BOOLEAN INDEX BY BINARY_INTEGER;

   expense_list                   num_tbl;
   budgeted_list                  num_tbl;
   recoverable_list               num_tbl;
   computed_recoverable_list      num_tbl;
   hdr_id_list                    num_tbl;
   update_list                    num_tbl;
   delete_list                    num_tbl;
   fee_use_tbl                    num_tbl;
   share_use_tbl                  num_tbl;
   l_update                       BOOLEAN;
   l_count                        NUMBER;
   l_info                         VARCHAR2(300);
   l_desc                         VARCHAR2(100) := 'pn_recovery_extract_pkg.dismantle_exp_line_from_dtl' ;

BEGIN

   pnp_debug_pkg.log(l_desc ||' (+)');

   l_info := ' processing affected lines ';
   pnp_debug_pkg.log(l_info);

   FOR class_line_dtl_rec IN get_affected_lines LOOP
      DELETE pn_rec_expcl_dtlacc_all
       WHERE expense_class_line_dtl_id = class_line_dtl_rec.expense_class_line_dtl_id;
      hdr_id_list(hdr_id_list.COUNT) := class_line_dtl_rec.expense_class_line_id;
   END LOOP;

   l_info := ' storing amount information ';
   pnp_debug_pkg.log(l_info);

   FOR i IN 0 .. hdr_id_list.COUNT - 1 LOOP

      l_update := FALSE;

      FOR hdr_rec IN get_header_info(hdr_id_list(i)) LOOP
         l_info := ' getting update information for expclln id: '||hdr_id_list(i);
         pnp_debug_pkg.log(l_info);

         l_update                           := TRUE;
         l_count                            := update_list.COUNT;
         update_list(l_count)               := hdr_id_list(i);
         expense_list(l_count)              := hdr_rec.expense_amount;
         budgeted_list(l_count)             := hdr_rec.budgeted_amount;
         recoverable_list(l_count)          := hdr_rec.recoverable_amount;
         computed_recoverable_list(l_count) := hdr_rec.computed_recoverable_amount;
         fee_use_tbl(l_count)               := hdr_rec.use_cls_line_fee;
         share_use_tbl(l_count)             := hdr_rec.use_cls_line_share;

      END LOOP;

      IF NOT l_update THEN delete_list(delete_list.COUNT) := hdr_id_list(i); END IF;

   END LOOP;

   l_info := ' updating header information ';
   pnp_debug_pkg.log(l_info);

   FORALL i IN 0 .. update_list.COUNT - 1
      UPDATE pn_rec_expcl_dtlln_all
         SET budgeted_amt = budgeted_list(i),
             expense_amt = expense_list(i),
             recoverable_amt = recoverable_list(i),
             computed_recoverable_amt = computed_recoverable_list(i) *
                                        nvl(share_use_tbl(i), cls_line_share_pct) / 100 *
                                        (1 + nvl(fee_use_tbl(i), cls_line_fee_before_contr_ovr) / 100),
             last_update_date = SYSDATE,
             last_updated_by = nvl(fnd_profile.value('USER_ID'), -1),
             last_update_login = nvl(fnd_profile.value('USER_ID'), -1)
       WHERE expense_class_line_id = update_list(i);

   l_info := ' deleting unused header lines';
   pnp_debug_pkg.log(l_info);

   FORALL i IN 0 .. delete_list.COUNT - 1
      DELETE pn_rec_expcl_dtlln_all
       WHERE expense_class_line_id = delete_list(i);

   pnp_debug_pkg.log(l_desc ||' (-)');

EXCEPTION
  WHEN OTHERS THEN
     pnp_debug_pkg.log(l_desc || ': Error while ' || l_info);
     raise;
END;

------------------------------------------------------------------------------+
-- PROCEDURE  : populate_expense_class_details
-- DESCRIPTION:
-- 1. Given: expense extract code
-- 2. Finds corresponding expense lines header id and populates all
--    expense class details pertinent to that location / property.
--
-- IF both location_id and property_id are provided, ignore property_id
-- IF location_id given, look for its parent location id and associated
-- property_id (if applicable) and get associated class details
--
-- HISTORY:
-- 19-MAR-03 ftanudja o created
-- 03-JUL-03 ftanudja o fixed cursor to handle cases when only prop id given.
-- 10-JUL-03 ftanudja o made prop id and loc id mutex on get_relevant_expcl.
--                    o fix logic on getting prop id. 3046470.
-- 08-AUG-03 ftanudja o fix get .. cursor. 3090131.
-- 18-SEP-03 ftanudja o added currency code filter. 3148855.
-- 21-MAY-03 ftanudja o added counters to summarize totals. 3591556.
--                    o restructured and fixed CURSOR logic.
-- 15-JUL-05 SatyaDeepo Replaced base views with their _ALL tables
------------------------------------------------------------------------------+

PROCEDURE populate_expense_class_details(
            p_location_id   pn_rec_exp_line.location_id%TYPE,
            p_property_id   pn_rec_exp_line.property_id%TYPE,
            p_as_of_date    VARCHAR2,
            p_from_date     VARCHAR2,
            p_to_date       VARCHAR2,
            p_extract_code  pn_rec_exp_line.expense_extract_code%TYPE,
            p_keep_override VARCHAR2)
IS

   CURSOR get_exp_line_id IS
    SELECT expense_line_id,
           currency_code
      FROM pn_rec_exp_line_all hdr
     WHERE hdr.expense_extract_code = p_extract_code
       AND rownum < 2;

   CURSOR get_expcl_by_prop (p_propid pn_rec_exp_line.property_id%TYPE,
                             p_currency_code pn_rec_exp_line.currency_code%TYPE) IS
      SELECT expense_class_id
       FROM  pn_rec_expcl_all
      WHERE  property_id = p_propid
        AND  location_id IS NULL
        AND  currency_code = p_currency_code;

   CURSOR get_expcl_by_locn (p_locnid pn_rec_exp_line.location_id%TYPE,
                             p_currency_code pn_rec_exp_line.currency_code%TYPE) IS
      SELECT expense_class_id
       FROM  pn_rec_expcl_all
      WHERE  location_id = p_locnid
        AND  currency_code = p_currency_code;

   CURSOR get_locn_prop_id IS
     SELECT property_id,
            location_id
       FROM pn_locations_all
      WHERE active_start_date <  fnd_date.canonical_to_date(p_to_date)
        AND active_end_date > fnd_date.canonical_to_date(p_from_date)
      START WITH location_id = p_location_id
    CONNECT BY location_id = PRIOR parent_location_id;

   l_propid  pn_rec_exp_line.property_id%TYPE;
   l_dummy   VARCHAR2(300);
   l_info    VARCHAR2(100);
   l_desc    VARCHAR2(100) := 'pn_recovery_extract_pkg.populate_expense_class_details' ;
   l_total   NUMBER := 0;
   l_failed  NUMBER := 0;

BEGIN
   pnp_debug_pkg.log(l_desc ||' (+)');

   FOR id IN get_exp_line_id LOOP

      IF p_location_id IS NOT NULL THEN

         FOR locn_prop_rec IN get_locn_prop_id LOOP

            /*  If the location belongs to a property, take note of that */
            IF l_propid IS NULL THEN l_propid := locn_prop_rec.property_id; END IF;

            FOR expcl_rec IN get_expcl_by_locn(locn_prop_rec.location_id, id.currency_code) LOOP
               l_info := ' extracting for expense class id : '|| expcl_rec.expense_class_id;
               pnp_debug_pkg.log(l_info);

               l_total := l_total + 1;

               BEGIN

                  extract_expense(
                     errbuf                => l_dummy,
                     retcode               => l_dummy,
                     p_expense_class_id    => expcl_rec.expense_class_id,
                     p_as_of_date          => p_as_of_date,
                     p_from_date           => p_from_date,
                     p_to_date             => p_to_date,
                     p_expense_line_id     => id.expense_line_id,
                     p_keep_override       => p_keep_override);

               EXCEPTION
                  WHEN OTHERS THEN
                     l_failed := l_failed + 1;
               END;

            END LOOP;
         END LOOP;
      END IF;

      IF (p_property_id IS NOT NULL AND p_location_id IS NULL) OR
          l_propid IS NOT NULL
      THEN

         FOR expcl_rec IN get_expcl_by_prop(nvl(l_propid, p_property_id), id.currency_code) LOOP
            l_info := ' extracting for expense class id : '|| expcl_rec.expense_class_id;
            pnp_debug_pkg.log(l_info);

            l_total := l_total + 1;

            BEGIN
               extract_expense(
                  errbuf                => l_dummy,
                  retcode               => l_dummy,
                  p_expense_class_id    => expcl_rec.expense_class_id,
                  p_as_of_date          => p_as_of_date,
                  p_from_date           => p_from_date,
                  p_to_date             => p_to_date,
                  p_expense_line_id     => id.expense_line_id,
                  p_keep_override       => p_keep_override);

            EXCEPTION
               WHEN OTHERS THEN
                  l_failed := l_failed + 1;
            END;

         END LOOP;

      END IF;
   END LOOP;

   fnd_message.set_name('PN','PN_REC_EXPCL_DTL');
   pnp_debug_pkg.put_log_msg('');
   pnp_debug_pkg.put_log_msg(fnd_message.get);

   fnd_message.set_name('PN','PN_CP_RESULT_SUMMARY');
   fnd_message.set_token('TOTAL', TO_CHAR(l_total));
   fnd_message.set_token('PASS', TO_CHAR(l_total - l_failed));
   fnd_message.set_token('FAIL', TO_CHAR(l_failed));
   pnp_debug_pkg.put_log_msg(fnd_message.get);
   pnp_debug_pkg.put_log_msg('');

   pnp_debug_pkg.log(l_desc ||' (-)');

EXCEPTION
  WHEN OTHERS THEN
     pnp_debug_pkg.log(l_desc || ': Error while ' || l_info);
     raise;
END populate_expense_class_details;

------------------------------------------------------------------------------+
-- PROCEDURE  : populate_area_class_details
-- DESCRIPTION:
-- 1. Given: location id
-- 2. Finds area class details pertinent to that location / property.
--
-- IF both location_id and property_id are provided, ignore property_id
-- IF location_id given, look for its parent location id and associated
-- property_id (if applicable) and get associated class details
--
-- HISTORY:
-- 19-MAR-03 ftanudja o created
-- 03-JUL-03 ftanudja o fixed cursor to handle cases when only prop id given.
-- 10-JUL-03 ftanudja o made prop id and loc id mutex on get_relevant_arcl.
--                    o fix logic on getting prop id. 3046470.
-- 08-AUG-03 ftanudja o fix get .. cursor. 3090131.
-- 21-MAY-03 ftanudja o added counters to summarize totals. 3591556.
--                    o restructured and fixed CURSOR logic.
-- 15-JUL-05 SatyaDeepo Replaced base views with their _ALL tables
------------------------------------------------------------------------------+

PROCEDURE populate_area_class_details(
            p_location_id   pn_rec_exp_line.location_id%TYPE,
            p_property_id   pn_rec_exp_line.property_id%TYPE,
            p_as_of_date    VARCHAR2,
            p_from_date     VARCHAR2,
            p_to_date       VARCHAR2,
            p_keep_override VARCHAR2)
IS

   CURSOR get_arcl_by_prop (l_propid pn_rec_exp_line.property_id%TYPE) IS
      SELECT area_class_id
       FROM  pn_rec_arcl_all
      WHERE  property_id = l_propid
        AND  location_id IS NULL;

   CURSOR get_arcl_by_locn (l_locnid pn_rec_exp_line.location_id%TYPE) IS
      SELECT area_class_id
       FROM  pn_rec_arcl_all
      WHERE  location_id = l_locnid;

   CURSOR get_locn_prop_id IS
     SELECT property_id,
            location_id
       FROM pn_locations_all
      WHERE active_start_date <  fnd_date.canonical_to_date(p_to_date)
        AND active_end_date > fnd_date.canonical_to_date(p_from_date)
      START WITH location_id = p_location_id
    CONNECT BY location_id = PRIOR parent_location_id;

   l_propid  pn_rec_exp_line.property_id%TYPE;
   l_desc    VARCHAR2(100) := 'pn_recovery_extract_pkg.populate_area_class_details' ;
   l_info    VARCHAR2(100);
   l_dummy   VARCHAR2(300);
   l_total   NUMBER := 0;
   l_failed  NUMBER := 0;

BEGIN

   pnp_debug_pkg.log(l_desc ||' (+)');

   IF p_location_id IS NOT NULL THEN

      FOR locn_prop_rec IN get_locn_prop_id LOOP

         /*  If the location belongs to a property, take note of that */
         IF l_propid IS NULL THEN l_propid := locn_prop_rec.property_id; END IF;

         FOR arcl_rec IN get_arcl_by_locn(locn_prop_rec.location_id) LOOP
            l_info := ' extracting for area class id : '|| arcl_rec.area_class_id;
            pnp_debug_pkg.log(l_info);

            l_total := l_total + 1;

            BEGIN
               extract_area(
                  errbuf             => l_dummy,
                  retcode            => l_dummy,
                  p_area_class_id    => arcl_rec.area_class_id,
                  p_as_of_date       => p_as_of_date,
                  p_from_date        => p_from_date,
                  p_to_date          => p_to_date,
                  p_keep_override    => p_keep_override);

            EXCEPTION
               WHEN OTHERS THEN
                  l_failed := l_failed + 1;
            END;

         END LOOP;
      END LOOP;
   END IF;

   IF (p_property_id IS NOT NULL AND p_location_id IS NULL) OR
       l_propid IS NOT NULL
   THEN

      FOR arcl_rec IN get_arcl_by_prop(nvl(l_propid, p_property_id)) LOOP
         l_info := ' extracting for area class id : '|| arcl_rec.area_class_id;
         pnp_debug_pkg.log(l_info);

         l_total := l_total + 1;

         BEGIN
            extract_area(
               errbuf             => l_dummy,
               retcode            => l_dummy,
               p_area_class_id    => arcl_rec.area_class_id,
               p_as_of_date       => p_as_of_date,
               p_from_date        => p_from_date,
               p_to_date          => p_to_date,
               p_keep_override    => p_keep_override);

         EXCEPTION
            WHEN OTHERS THEN
               l_failed := l_failed + 1;
         END;

      END LOOP;

   END IF;

   fnd_message.set_name('PN','PN_REC_ARCL_DTL');
   pnp_debug_pkg.put_log_msg('');
   pnp_debug_pkg.put_log_msg(fnd_message.get);

   fnd_message.set_name('PN','PN_CP_RESULT_SUMMARY');
   fnd_message.set_token('TOTAL', TO_CHAR(l_total));
   fnd_message.set_token('PASS', TO_CHAR(l_total - l_failed));
   fnd_message.set_token('FAIL', TO_CHAR(l_failed));
   pnp_debug_pkg.put_log_msg(fnd_message.get);
   pnp_debug_pkg.put_log_msg('');

   pnp_debug_pkg.log(l_desc ||' (-)');

EXCEPTION
  WHEN OTHERS THEN
     pnp_debug_pkg.log(l_desc || ': Error while ' || l_info);
     raise;
END populate_area_class_details;

------------------------------------------------------------------------------+
-- PROCEDURE  : find_expense_ovr_values
-- DESCRIPTION:
-- 1. Given: data table p_master_ovr, p_detail_ovr, parameters p_exp_type, etc.
-- 2. Search through data tables using the parameter criteria.
-- 3. If match found, check if p_keep_override = Y.
-- 4. If true, return override values p_fee_af_contr_ovr, etc.
-- 5. Otherwise, just return the corresponding item id if needed.
--
-- HISTORY:
-- 19-MAR-03 ftanudja o created
-- 15-JUL-05 SatyaDeepo Replaced base views with their _ALL tables
------------------------------------------------------------------------------+

PROCEDURE find_expense_ovr_values(
            p_master_ovr           exp_cls_line_mst_tbl,
            p_detail_ovr           exp_cls_line_dtl_tbl,
            p_exp_type             pn_rec_expcl_dtlacc.expense_type_code%TYPE,
            p_exp_acct             pn_rec_expcl_dtlacc.expense_account_id%TYPE,
            p_loc_id               pn_rec_expcl_dtlln.location_id%TYPE,
            p_cust_id              pn_rec_expcl_dtlln.cust_account_id%TYPE,
            p_rec_spc_std          pn_rec_expcl_dtlln.recovery_space_std_code%TYPE,
            p_rec_type             pn_rec_expcl_dtlln.recovery_type_code%TYPE,
            p_exp_cls_line_dtl_id  OUT NOCOPY pn_rec_expcl_dtlacc.expense_class_line_dtl_id%TYPE,
            p_exp_cls_line_id      OUT NOCOPY pn_rec_expcl_dtlacc.expense_class_line_dtl_id%TYPE,
            p_fee_af_contr_ovr     OUT NOCOPY pn_rec_expcl_dtlln.cls_line_fee_after_contr_ovr%TYPE,
            p_mst_share_pct_ovr    OUT NOCOPY pn_rec_expcl_dtlln.cls_line_share_pct%TYPE,
            p_dtl_share_pct_ovr    OUT NOCOPY pn_rec_expcl_dtlacc.cls_line_dtl_share_pct%TYPE,
            p_mst_fee_bf_contr_ovr OUT NOCOPY pn_rec_expcl_dtlln.cls_line_fee_before_contr_ovr%TYPE,
            p_dtl_fee_bf_contr_ovr OUT NOCOPY pn_rec_expcl_dtlacc.cls_line_dtl_fee_bf_contr%TYPE,
            p_found                IN OUT NOCOPY BOOLEAN,
            p_keep_override        VARCHAR2
          )
IS
   l_desc VARCHAR2(100) := 'pn_recovery_extract_pkg.find_expense_ovr_values' ;
   l_info VARCHAR2(300);
BEGIN

   pnp_debug_pkg.log(l_desc ||' (+)');

   l_info := ' resetting ovr values variables ';
   pnp_debug_pkg.log(l_info);

   p_exp_cls_line_dtl_id  := null;
   p_exp_cls_line_id      := null;
   p_fee_af_contr_ovr     := null;
   p_mst_share_pct_ovr    := null;
   p_dtl_share_pct_ovr    := null;
   p_mst_fee_bf_contr_ovr := null;
   p_dtl_fee_bf_contr_ovr := null;

   FOR i IN 0 .. p_master_ovr.COUNT - 1 LOOP
      IF p_detail_ovr(i).expense_account_id = p_exp_acct AND
         p_detail_ovr(i).expense_type_code = p_exp_type AND
         p_master_ovr(i).recovery_space_std_code = p_rec_spc_std AND
         p_master_ovr(i).recovery_type_code = p_rec_type AND
         p_master_ovr(i).location_id = p_loc_id AND
         p_master_ovr(i).cust_account_id = p_cust_id THEN

         l_info := ' found matching data and determining which values to return ';
         pnp_debug_pkg.log(l_info);

         IF p_keep_override = 'Y' THEN
            p_fee_af_contr_ovr     := p_master_ovr(i).cls_line_fee_after_contr_ovr;
            p_mst_share_pct_ovr    := p_master_ovr(i).cls_line_share_pct;
            p_dtl_share_pct_ovr    := p_detail_ovr(i).cls_line_dtl_share_pct_ovr;
            p_mst_fee_bf_contr_ovr := p_master_ovr(i).cls_line_fee_before_contr_ovr;
            p_dtl_fee_bf_contr_ovr := p_detail_ovr(i).cls_line_dtl_fee_bf_contr_ovr;
         END IF;

         IF p_found IS NOT NULL THEN
            p_found               := TRUE;
            p_exp_cls_line_dtl_id := p_detail_ovr(i).expense_class_line_dtl_id;
            p_exp_cls_line_id     := p_master_ovr(i).expense_class_line_id;
         END IF;

      END IF;
   END LOOP;

   pnp_debug_pkg.log(l_desc ||' (-)');

EXCEPTION
  WHEN OTHERS THEN
     pnp_debug_pkg.log(l_desc || ': Error while ' || l_info);
     raise;
END find_expense_ovr_values;

------------------------------------------------------------------------------+
-- PROCEDURE  : expense_class_extract
-- ASSUMES    : validation done at UI level when calling generate details
--              ,in particular, ensuring expense_line_id is correlated to
--              expense_class_id.
-- DESCRIPTION:
-- o given an expense class id, get details of the expense class.
-- o get all expense lines for locations pertaining to that expense class.
-- o get all space assignment for locations pertaining to that expense class
--   for which the start date and financial obligation date is between
--   the start and end date of the expense line extract.
-- o collect data, do necessary calculations and put them in a pl/sql table.
-- o use pl/sql table to do the proper calculation at both the class line and
--   class line detail level.
-- o dump data into database table; if id already exists, update, otherwise
--   insert.
--
-- HISTORY:
-- 19-MAR-03 ftanudja o created
-- 12-MAY-03 ftanudja o use location / property id from exp lines to get
--                      space assignments, as opposed to using the expense
--                      class' location / property id.
-- 11-JUN-03 ftanudja o add filter recoverable_flag='Y' in get_exp_lines_info.
-- 10-JUL-03 ftanudja o made loc id and prop id mutex in getting cust asgnmt.
-- 11-JUL-03 ftanudja o changed query for get_exp_line_info. 3045056.
-- 05-AUG-03 ftanudja o added l_updcondition to fix logic. 3075129.
--                    o added order by to date and from date for ovr values.
--                    o optimized get_ovr_from_prior CURSOR (break in 2).
-- 06-AUG-03 ftanudja o change flow => if found 'PARENT' exp line, do nothing.
-- 18-SEP-03 ftanudja o added currency code check. 3148855.
-- 15-JUL-05 SatyaDeepo Replaced base views with their _ALL tables
------------------------------------------------------------------------------+

PROCEDURE extract_expense(
            errbuf                 OUT NOCOPY VARCHAR2,
            retcode                OUT NOCOPY VARCHAR2,
            p_expense_class_id     IN pn_rec_expcl.expense_class_id%TYPE,
            p_as_of_date           IN VARCHAR2,
            p_from_date            IN VARCHAR2,
            p_to_date              IN VARCHAR2,
            p_expense_line_id      IN pn_rec_exp_line.expense_line_id%TYPE,
            p_keep_override        IN VARCHAR2)
IS

    CURSOR check_currency IS
     SELECT 1
       FROM pn_rec_exp_line_all
      WHERE expense_line_id = p_expense_line_id
        AND currency_code NOT IN
            (SELECT currency_code FROM pn_rec_expcl_all
             WHERE expense_class_id = p_expense_class_id);

    CURSOR get_exp_class_info IS
     SELECT class.expense_class_id,
            class_type.expense_class_type_id,
            class.area_class_id,
            class.location_id,
            class.property_id,
            class.portion_pct,
            class_type.expense_type_code,
            class_inclusion.cls_incl_share_pct,
            class.class_fee_before_contr,
            class.class_fee_after_contr,
            class_inclusion.cls_incl_fee_before_contr,
            class_inclusion.recovery_type_code,
            class_inclusion.recovery_space_std_code
       FROM pn_rec_expcl_all            class,
            pn_rec_expcl_type_all   class_type,
            pn_rec_expcl_inc_all    class_inclusion
      WHERE class.expense_class_id = class_type.expense_class_id
        AND class_type.expense_class_type_id = class_inclusion.expense_class_type_id
        AND class.expense_class_id = p_expense_class_id;

   CURSOR get_exp_lines_info (
            p_expense_type_code pn_rec_exp_line_dtl.expense_type_code%TYPE) IS
    SELECT nvl(lines_dtl.actual_amount_ovr, lines_dtl.actual_amount) actual_amount,
           nvl(lines_dtl.budgeted_amount_ovr, lines_dtl.budgeted_amount) budgeted_amount,
           lines_dtl.expense_type_code,
           lines_dtl.expense_account_id,
           lines_dtl.location_id,
           lines_dtl.property_id,
           lines_dtl.expense_line_dtl_id,
           lines_dtl.expense_line_id,
           lines_dtl.expense_line_indicator
      FROM pn_rec_exp_line_dtl_all lines_dtl
     WHERE (lines_dtl.expense_line_id = p_expense_line_id OR
            lines_dtl.parent_expense_line_id IN
            (SELECT expense_line_dtl_id
             FROM pn_rec_exp_line_dtl_all
             WHERE expense_line_id = p_expense_line_id))
       AND lines_dtl.expense_type_code = p_expense_type_code
       AND lines_dtl.recoverable_flag = 'Y';

   CURSOR get_cust_assignment_info(
            p_location_id pn_locations.location_id%TYPE,
            p_property_id pn_locations.property_id%TYPE,
            p_rec_spc_std_code pn_space_assign_cust.recovery_space_std_code%TYPE,
            p_rec_type_code    pn_space_assign_cust.recovery_type_code%TYPE) IS
    SELECT cust.cust_space_assign_id,
           cust.cust_account_id,
           cust.lease_id,
           cust.location_id,
           cust.recovery_space_std_code,
           cust.recovery_type_code
      FROM pn_space_assign_cust_all cust
     WHERE cust.location_id IN
           (SELECT location_id FROM pn_locations_all locn
             WHERE locn.active_start_date < fnd_date.canonical_to_date(p_to_date)
               AND locn.active_end_date > fnd_date.canonical_to_date(p_from_date))
       AND cust.cust_assign_start_date < fnd_date.canonical_to_date(p_to_date)
       AND cust.fin_oblig_end_date > fnd_date.canonical_to_date(p_from_date)
       AND cust.recovery_space_std_code = p_rec_spc_std_code
       AND cust.recovery_type_code = p_rec_type_code
       AND cust.location_id IN
           (SELECT location_id FROM pn_locations_all
            START WITH (location_id =  p_location_id OR
                        (property_id = p_property_id AND p_location_id IS NULL))
            CONNECT BY PRIOR  location_id =  parent_location_id);

   CURSOR get_ovr_from_current IS
    SELECT class_line.cls_line_share_pct                mst_shr_pc,
           class_line.cls_line_fee_after_contr_ovr      mst_fee_af,
           class_line.cls_line_fee_before_contr_ovr     mst_fee_bf,
           class_line.location_id                       location_id,
           class_line_dtl.cls_line_dtl_fee_bf_contr_ovr dtl_fee_bf,
           class_line_dtl.cls_line_dtl_share_pct_ovr    dtl_shr_pc,
           class_line.cust_account_id                   cust_account_id,
           class_line.recovery_space_std_code           rec_space_std,
           class_line.recovery_type_code                rec_type_code,
           class_line_dtl.expense_type_code             exp_type,
           class_line_dtl.expense_account_id            exp_acct,
           class_line_dtl.expense_class_line_dtl_id     dtl_id,
           class_line_dtl.expense_class_line_id         mst_id
      FROM pn_rec_expcl_dtl_all           summary,
           pn_rec_expcl_dtlln_all     class_line,
           pn_rec_expcl_dtlacc_all    class_line_dtl,
           pn_rec_expcl_all           class,
           pn_rec_exp_line_all        lines
     WHERE class_line.expense_class_line_id = class_line_dtl.expense_class_line_id
       AND class_line.expense_class_dtl_id = summary.expense_class_dtl_id
       AND summary.expense_class_id = class.expense_class_id
       AND class.expense_class_id = p_expense_class_id
       AND summary.expense_line_id = lines.expense_line_id
       AND lines.expense_line_id = p_expense_line_id;

   CURSOR get_prior_cls_dtl_id IS
    SELECT summary.expense_class_dtl_id
      FROM pn_rec_expcl_dtl_all   summary,
           pn_rec_expcl_all       class,
           pn_rec_exp_line_all    line_hdr,
      (SELECT to_date, as_of_date FROM pn_rec_exp_line_all
            WHERE expense_line_id = p_expense_line_id) ref_line_hdr
     WHERE summary.expense_class_id = class.expense_class_id
       AND summary.expense_line_id = line_hdr.expense_line_id
       AND class.expense_class_id = p_expense_class_id
       AND line_hdr.from_date < ref_line_hdr.to_date
       AND line_hdr.to_date <= ref_line_hdr.to_date
       AND line_hdr.as_of_date < ref_line_hdr.as_of_date
  ORDER BY line_hdr.as_of_date DESC, line_hdr.to_date DESC, line_hdr.from_date DESC;

   CURSOR get_ovr_from_prior (p_prior_cls_dtl_id pn_rec_expcl_dtlln.expense_class_dtl_id%TYPE) IS
    SELECT class_line.cls_line_share_pct                mst_shr_pc,
           class_line.cls_line_fee_after_contr_ovr      mst_fee_af,
           class_line.cls_line_fee_before_contr_ovr     mst_fee_bf,
           class_line.location_id                       location_id,
           class_line_dtl.cls_line_dtl_fee_bf_contr_ovr dtl_fee_bf,
           class_line_dtl.cls_line_dtl_share_pct_ovr    dtl_shr_pc,
           class_line.cust_account_id                   cust_account_id,
           class_line.recovery_space_std_code           rec_space_std,
           class_line.recovery_type_code                rec_type_code,
           class_line_dtl.expense_type_code             exp_type,
           class_line_dtl.expense_account_id            exp_acct
      FROM pn_rec_expcl_dtlln_all  class_line,
           pn_rec_expcl_dtlacc_all class_line_dtl
     WHERE class_line.expense_class_line_id = class_line_dtl.expense_class_line_id
       AND class_line.expense_class_dtl_id = p_prior_cls_dtl_id;

   CURSOR is_reextract IS
    SELECT dtl.expense_class_dtl_id,
           setup.expense_class_name,
           dtl.status,
           dtl.default_area_class_id,
           dtl.cls_line_portion_pct,
           dtl.cls_line_fee_before_contr,
           dtl.cls_line_fee_after_contr
      FROM pn_rec_expcl_dtl_all dtl,
           pn_rec_expcl_all setup
     WHERE dtl.expense_line_id = p_expense_line_id
       AND setup.expense_class_id = p_expense_class_id
       AND setup.expense_class_id = dtl.expense_class_id;

   l_regenerate              VARCHAR2(1);
   l_info                    VARCHAR2(300);
   l_dummy                   VARCHAR2(300);
   l_desc                    VARCHAR2(100) := 'pn_recovery_extract_pkg.extract_expense' ;
   l_token                   VARCHAR2(100);

   l_master_data_id          NUMBER;
   l_count                   NUMBER;
   l_found                   BOOLEAN;
   l_updcondition            BOOLEAN;
   l_dummy_id                pn_rec_expcl_dtl.expense_class_dtl_id%TYPE;

   l_recov_amount            pn_rec_expcl_dtlln.recoverable_amt%TYPE;
   l_cpt_recov_amount        pn_rec_expcl_dtlln.computed_recoverable_amt%TYPE;
   l_mst_share_pct_ovr       pn_rec_expcl_dtlln.cls_line_share_pct%TYPE;
   l_dtl_share_pct_ovr       pn_rec_expcl_dtlacc.cls_line_dtl_share_pct%TYPE;
   l_fee_af_contr_ovr        pn_rec_expcl_dtlln.cls_line_fee_after_contr_ovr%TYPE;
   l_dtl_fee_bf_contr_ovr    pn_rec_expcl_dtlacc.cls_line_dtl_fee_bf_contr%TYPE;
   l_mst_fee_bf_contr_ovr    pn_rec_expcl_dtlln.cls_line_fee_before_contr_ovr%TYPE;

   l_mst_fee_bf_contr        pn_rec_expcl_dtl.cls_line_fee_before_contr%TYPE;
   l_fee_af_contr            pn_rec_expcl_dtl.cls_line_fee_after_contr%TYPE;
   l_portion_pct             pn_rec_expcl_dtl.cls_line_portion_pct%TYPE;

   l_expense_cls_line_id     pn_rec_expcl_dtlln.expense_class_line_id%TYPE;
   l_expense_cls_line_dtl_id pn_rec_expcl_dtlacc.expense_class_line_dtl_id%TYPE;
   l_area_class_id           pn_rec_expcl.area_class_id%TYPE;
   l_expense_class_dtl_id    pn_rec_expcl_dtl.expense_class_dtl_id%TYPE;

   l_fee_use_table           exp_cls_line_use_tbl;
   l_share_use_table         exp_cls_line_use_tbl;
   l_ovr_use_table           exp_cls_line_use_tbl;

   exp_cls_line_master_data  exp_cls_line_mst_tbl;
   exp_cls_line_detail_data  exp_cls_line_dtl_tbl;
   exp_cls_curnt_master_ovr  exp_cls_line_mst_tbl;
   exp_cls_curnt_detail_ovr  exp_cls_line_dtl_tbl;
   exp_cls_prior_master_ovr  exp_cls_line_mst_tbl;
   exp_cls_prior_detail_ovr  exp_cls_line_dtl_tbl;

BEGIN
   pnp_debug_pkg.log(l_desc ||' (+)');

   fnd_message.set_name('PN','PN_REC_EXPCL_DTL_CP_INFO');
   fnd_message.set_token('EXPCL', to_char(p_expense_class_id));
   fnd_message.set_token('EXPLN', to_char(p_expense_line_id));
   fnd_message.set_token('STR'  , p_from_date);
   fnd_message.set_token('END'  , p_to_date);
   fnd_message.set_token('AOD'  , p_as_of_date);
   fnd_message.set_token('OVR'  , p_keep_override);
   pnp_debug_pkg.put_log_msg('');
   pnp_debug_pkg.put_log_msg(fnd_message.get);
   pnp_debug_pkg.put_log_msg('');

   l_info := ' validating currency';
   pnp_debug_pkg.log(l_info);

   FOR check_cur IN check_currency LOOP
      fnd_message.set_name('PN', 'PN_REC_EXP_CUR_MISMATCH');
      RAISE currency_exception;
   END LOOP;

   l_info := ' initializing values ';
   pnp_debug_pkg.log(l_info);

   l_fee_use_table.delete;
   l_share_use_table.delete;
   l_ovr_use_table.delete;

   exp_cls_line_master_data.delete;
   exp_cls_line_detail_data.delete;
   exp_cls_curnt_master_ovr.delete;
   exp_cls_curnt_detail_ovr.delete;
   exp_cls_prior_master_ovr.delete;
   exp_cls_prior_detail_ovr.delete;

   l_info := ' caching default and override values';
   pnp_debug_pkg.log(l_info);

   l_regenerate := 'N';

   FOR check_exists IN is_reextract LOOP

      IF check_exists.status = 'LOCKED' THEN
         fnd_message.set_name('PN','PN_REC_EXPCL_DTL');
         l_token := fnd_message.get;
         fnd_message.set_name('PN','PN_REC_NO_REGEN_LOCKED');
         fnd_message.set_token('MODULE',l_token);
         fnd_message.set_token('FDATE', p_from_date);
         fnd_message.set_token('TDATE', p_to_date);
         fnd_message.set_token('AODATE', p_as_of_date);
         fnd_message.set_token('NAME', check_exists.expense_class_name);
         pnp_debug_pkg.log(fnd_message.get);
         RETURN;
      END IF;

      l_regenerate               := 'Y';
      l_area_class_id            := check_exists.default_area_class_id;
      l_mst_fee_bf_contr         := check_exists.cls_line_fee_before_contr;
      l_fee_af_contr             := check_exists.cls_line_fee_after_contr;
      l_portion_pct              := check_exists.cls_line_portion_pct;
      l_expense_class_dtl_id     := check_exists.expense_class_dtl_id;

   END LOOP;

   IF l_regenerate = 'Y' THEN
      FOR get_ovr_rec IN get_ovr_from_current LOOP
         l_count := exp_cls_curnt_master_ovr.COUNT;

         exp_cls_curnt_master_ovr(l_count).cls_line_share_pct            := get_ovr_rec.mst_shr_pc;
         exp_cls_curnt_master_ovr(l_count).cls_line_fee_after_contr_ovr  := get_ovr_rec.mst_fee_af;
         exp_cls_curnt_master_ovr(l_count).cls_line_fee_before_contr_ovr := get_ovr_rec.mst_fee_bf;
         exp_cls_curnt_master_ovr(l_count).expense_class_line_id         := get_ovr_rec.mst_id;
         exp_cls_curnt_master_ovr(l_count).location_id                   := get_ovr_rec.location_id;
         exp_cls_curnt_master_ovr(l_count).cust_account_id               := get_ovr_rec.cust_account_id;
         exp_cls_curnt_master_ovr(l_count).recovery_space_std_code       := get_ovr_rec.rec_space_std;
         exp_cls_curnt_master_ovr(l_count).recovery_type_code            := get_ovr_rec.rec_type_code;

         exp_cls_curnt_detail_ovr(l_count).cls_line_dtl_fee_bf_contr_ovr := get_ovr_rec.dtl_fee_bf;
         exp_cls_curnt_detail_ovr(l_count).cls_line_dtl_share_pct_ovr    := get_ovr_rec.dtl_shr_pc;
         exp_cls_curnt_detail_ovr(l_count).expense_class_line_dtl_id     := get_ovr_rec.dtl_id;
         exp_cls_curnt_detail_ovr(l_count).expense_type_code             := get_ovr_rec.exp_type;
         exp_cls_curnt_detail_ovr(l_count).expense_account_id            := get_ovr_rec.exp_acct;

      END LOOP;
   END IF;

   l_dummy_id := null;
   l_info     := ' getting prior cls dtl id for overrides ';
   pnp_debug_pkg.log(l_info);

   FOR get_first_id IN get_prior_cls_dtl_id LOOP
      l_dummy_id := get_first_id.expense_class_dtl_id;
      exit;
   END LOOP;

   FOR get_ovr_rec IN get_ovr_from_prior(l_dummy_id) LOOP

      l_count := exp_cls_prior_detail_ovr.COUNT;

      exp_cls_prior_master_ovr(l_count).cls_line_share_pct            := get_ovr_rec.mst_shr_pc;
      exp_cls_prior_master_ovr(l_count).cls_line_fee_after_contr_ovr  := get_ovr_rec.mst_fee_af;
      exp_cls_prior_master_ovr(l_count).cls_line_fee_before_contr_ovr := get_ovr_rec.mst_fee_bf;
      exp_cls_prior_master_ovr(l_count).location_id                   := get_ovr_rec.location_id;
      exp_cls_prior_master_ovr(l_count).cust_account_id               := get_ovr_rec.cust_account_id;
      exp_cls_prior_master_ovr(l_count).recovery_space_std_code       := get_ovr_rec.rec_space_std;
      exp_cls_prior_master_ovr(l_count).recovery_type_code            := get_ovr_rec.rec_type_code;

      exp_cls_prior_detail_ovr(l_count).cls_line_dtl_fee_bf_contr_ovr := get_ovr_rec.dtl_fee_bf;
      exp_cls_prior_detail_ovr(l_count).cls_line_dtl_share_pct_ovr    := get_ovr_rec.dtl_shr_pc;
      exp_cls_prior_detail_ovr(l_count).expense_type_code             := get_ovr_rec.exp_type;
      exp_cls_prior_detail_ovr(l_count).expense_account_id            := get_ovr_rec.exp_acct;

   END LOOP;

   l_info := ' fetching information to prepare data processing ';
   pnp_debug_pkg.log(l_info);

   FOR expense_class_rec IN get_exp_class_info LOOP

      IF l_expense_class_dtl_id IS NOT NULL THEN
         l_updcondition :=
              (l_area_class_id = expense_class_rec.area_class_id AND
              (l_mst_fee_bf_contr = expense_class_rec.class_fee_before_contr OR
               (l_mst_fee_bf_contr IS NULL AND expense_class_rec.class_fee_before_contr IS NULL)) AND
              (l_fee_af_contr = expense_class_rec.class_fee_after_contr OR
               (l_fee_af_contr IS NULL AND expense_class_rec.class_fee_after_contr IS NULL)) AND
              (l_portion_pct = expense_class_rec.portion_pct OR
               (l_portion_pct IS NULL AND expense_class_rec.portion_pct IS NULL)));

         IF NOT l_updcondition OR l_updcondition IS NULL THEN

            l_area_class_id        := expense_class_rec.area_class_id;
            l_mst_fee_bf_contr     := expense_class_rec.class_fee_before_contr;
            l_fee_af_contr         := expense_class_rec.class_fee_after_contr;
            l_portion_pct          := expense_class_rec.portion_pct;

            pn_rec_expcl_dtl_pkg.update_row(
                x_expense_class_id           => p_expense_class_id,
                x_expense_line_id            => p_expense_line_id,
                x_expense_class_dtl_id       => l_expense_class_dtl_id,
                x_status                     => 'OPEN',
                x_def_area_cls_id            => l_area_class_id,
                x_cls_line_fee_bf_ct         => l_mst_fee_bf_contr,
                x_cls_line_fee_af_ct         => l_fee_af_contr,
                x_cls_line_portion_pct       => l_portion_pct,
                x_last_update_date           => SYSDATE,
                x_last_updated_by            => nvl(fnd_profile.value('USER_ID'),-1),
                x_creation_date              => SYSDATE,
                x_created_by                 => nvl(fnd_profile.value('USER_ID'),-1),
                x_last_update_login          => nvl(fnd_profile.value('USER_ID'),-1)
            );

         END IF;

      ELSIF l_expense_class_dtl_id IS NULL THEN

         l_area_class_id        := expense_class_rec.area_class_id;
         l_mst_fee_bf_contr     := expense_class_rec.class_fee_before_contr;
         l_fee_af_contr         := expense_class_rec.class_fee_after_contr;
         l_portion_pct          := expense_class_rec.portion_pct;

         pn_rec_expcl_dtl_pkg.insert_row(
             x_org_id                     => to_number(pn_mo_cache_utils.get_current_org_id),
             x_expense_class_id           => p_expense_class_id,
             x_expense_line_id            => p_expense_line_id,
             x_expense_class_dtl_id       => l_expense_class_dtl_id,
             x_status                     => 'OPEN',
             x_def_area_cls_id            => l_area_class_id,
             x_cls_line_fee_bf_ct         => l_mst_fee_bf_contr,
             x_cls_line_fee_af_ct         => l_fee_af_contr,
             x_cls_line_portion_pct       => l_portion_pct,
             x_last_update_date           => SYSDATE,
             x_last_updated_by            => nvl(fnd_profile.value('USER_ID'),-1),
             x_creation_date              => SYSDATE,
             x_created_by                 => nvl(fnd_profile.value('USER_ID'),-1),
             x_last_update_login          => nvl(fnd_profile.value('USER_ID'),-1)
         );

      END IF;

      FOR expense_line_rec IN get_exp_lines_info(expense_class_rec.expense_type_code) LOOP

         FOR space_assign_rec IN get_cust_assignment_info(
                                   expense_line_rec.location_id,
                                   expense_line_rec.property_id,
                                   expense_class_rec.recovery_space_std_code,
                                   expense_class_rec.recovery_type_code) LOOP

            IF expense_line_rec.expense_line_indicator <> 'PARENT' THEN

               l_info := ' trying to find override values for a given line ';
               pnp_debug_pkg.log(l_info);

               l_found := FALSE;

               IF l_regenerate = 'Y' THEN

                  l_info := ' trying to find override values from regenerated extract';
                  pnp_debug_pkg.log(l_info);

                  find_expense_ovr_values(
                     p_master_ovr           => exp_cls_curnt_master_ovr,
                     p_detail_ovr           => exp_cls_curnt_detail_ovr,
                     p_exp_cls_line_dtl_id  => l_expense_cls_line_dtl_id,
                     p_exp_cls_line_id      => l_expense_cls_line_id,
                     p_exp_type             => expense_class_rec.expense_type_code,
                     p_exp_acct             => expense_line_rec.expense_account_id,
                     p_loc_id               => space_assign_rec.location_id,
                     p_cust_id              => space_assign_rec.cust_account_id,
                     p_rec_spc_std          => expense_class_rec.recovery_space_std_code,
                     p_rec_type             => expense_class_rec.recovery_type_code,
                     p_fee_af_contr_ovr     => l_fee_af_contr_ovr,
                     p_mst_share_pct_ovr    => l_mst_share_pct_ovr,
                     p_dtl_share_pct_ovr    => l_dtl_share_pct_ovr,
                     p_mst_fee_bf_contr_ovr => l_mst_fee_bf_contr_ovr,
                     p_dtl_fee_bf_contr_ovr => l_dtl_fee_bf_contr_ovr,
                     p_found                => l_found,
                     p_keep_override        => p_keep_override
                  );

               END IF;

               IF NOT l_found THEN

                  l_info := ' trying to find override values from prior extract';
                  pnp_debug_pkg.log(l_info);

                  IF l_regenerate = 'N' THEN l_found := null; END IF;

                  find_expense_ovr_values(
                     p_master_ovr           => exp_cls_prior_master_ovr,
                     p_detail_ovr           => exp_cls_prior_detail_ovr,
                     p_exp_cls_line_dtl_id  => l_expense_cls_line_dtl_id,
                     p_exp_cls_line_id      => l_expense_cls_line_id,
                     p_exp_type             => expense_class_rec.expense_type_code,
                     p_exp_acct             => expense_line_rec.expense_account_id,
                     p_loc_id               => space_assign_rec.location_id,
                     p_cust_id              => space_assign_rec.cust_account_id,
                     p_rec_spc_std          => expense_class_rec.recovery_space_std_code,
                     p_rec_type             => expense_class_rec.recovery_type_code,
                     p_fee_af_contr_ovr     => l_fee_af_contr_ovr,
                     p_mst_share_pct_ovr    => l_mst_share_pct_ovr,
                     p_dtl_share_pct_ovr    => l_dtl_share_pct_ovr,
                     p_mst_fee_bf_contr_ovr => l_mst_fee_bf_contr_ovr,
                     p_dtl_fee_bf_contr_ovr => l_dtl_fee_bf_contr_ovr,
                     p_found                => l_found,
                     p_keep_override        => p_keep_override
                  );

               END IF;

               l_info := ' calculating recovery amount and computed recovery amount ';
               pnp_debug_pkg.log(l_info);

               l_recov_amount := expense_line_rec.actual_amount * nvl(expense_class_rec.portion_pct,100) / 100;
               l_cpt_recov_amount := l_recov_amount * nvl(nvl(l_dtl_share_pct_ovr, expense_class_rec.cls_incl_share_pct),100) / 100 * (1 + nvl(nvl(l_dtl_fee_bf_contr_ovr, expense_class_rec.cls_incl_fee_before_contr), 0) / 100);

               l_info:= ' collecting master class-line data for space assignment '||space_assign_rec.cust_space_assign_id||' ';
               pnp_debug_pkg.log(l_info);

               process_exp_cls_dtl_mst_data(
                  p_master_data               => exp_cls_line_master_data,
                  p_ovr_use_data              => l_ovr_use_table,
                  p_fee_use_table             => l_fee_use_table,
                  p_share_use_table           => l_share_use_table,
                  p_master_data_id            => l_master_data_id,
                  p_expense_class_line_id     => l_expense_cls_line_id,
                  p_expense_class_dtl_id      => l_expense_class_dtl_id,
                  p_location_id               => space_assign_rec.location_id,
                  p_cust_space_assign_id      => space_assign_rec.cust_space_assign_id,
                  p_cust_account_id           => space_assign_rec.cust_account_id,
                  p_lease_id                  => space_assign_rec.lease_id,
                  p_recovery_space_std_code   => expense_class_rec.recovery_space_std_code,
                  p_recovery_type_code        => expense_class_rec.recovery_type_code,
                  p_budget_amount             => expense_line_rec.budgeted_amount,
                  p_expense_amount            => expense_line_rec.actual_amount,
                  p_recoverable_amount        => l_recov_amount,
                  p_cpt_recoverable_amount    => l_cpt_recov_amount,
                  p_cls_line_share_pct        => l_mst_share_pct_ovr,
                  p_cls_line_fee_af_contr_ovr => l_fee_af_contr_ovr,
                  p_cls_line_fee_bf_contr_ovr => l_mst_fee_bf_contr_ovr,
                  p_use_fee_bf_contr          => expense_class_rec.cls_incl_fee_before_contr,
                  p_use_share_pct             => expense_class_rec.cls_incl_share_pct,
                  p_use_prior_ovr             => (NOT l_found AND l_regenerate = 'Y')
               );

               l_info:= ' collecting detail class-line data for space assignment '||space_assign_rec.cust_space_assign_id;
               pnp_debug_pkg.log(l_info);

               process_exp_cls_dtl_dtl_data(
                  p_detail_data                => exp_cls_line_detail_data,
                  p_master_data_id             => l_master_data_id,
                  p_expense_class_line_dtl_id  => l_expense_cls_line_dtl_id,
                  p_expense_line_dtl_id        => expense_line_rec.expense_line_dtl_id,
                  p_expense_account_id         => expense_line_rec.expense_account_id,
                  p_expense_type_code          => expense_line_rec.expense_type_code,
                  p_expense_amount             => expense_line_rec.actual_amount,
                  p_budget_amount              => expense_line_rec.budgeted_amount,
                  p_recoverable_amount         => l_recov_amount,
                  p_cpt_recoverable_amount     => l_cpt_recov_amount,
                  p_cls_line_shr_pct           => expense_class_rec.cls_incl_share_pct,
                  p_cls_line_fee_bf_contr      => expense_class_rec.cls_incl_fee_before_contr,
                  p_cls_line_shr_pct_ovr       => l_dtl_share_pct_ovr,
                  p_cls_line_fee_bf_contr_ovr  => l_dtl_fee_bf_contr_ovr
               );

            END IF;

         END LOOP;
      END LOOP;
   END LOOP;

   l_info := ' dumping data into table ';
   pnp_debug_pkg.log(l_info);

   process_exp_class_line_data(
      p_old_detail_data => exp_cls_curnt_detail_ovr,
      p_old_master_data => exp_cls_curnt_master_ovr,
      p_detail_data     => exp_cls_line_detail_data,
      p_master_data     => exp_cls_line_master_data,
      p_fee_use_table   => l_fee_use_table,
      p_share_use_table => l_share_use_table,
      p_default_fee_bf  => l_mst_fee_bf_contr
   );

   IF l_area_class_id IS NOT NULL THEN
      l_info := ' generating area class detail associated with the expense class ';
      pnp_debug_pkg.log(l_info);

      extract_area(
         errbuf             => l_dummy,
         retcode            => l_dummy,
         p_area_class_id    => l_area_class_id,
         p_as_of_date       => p_as_of_date,
         p_from_date        => p_from_date,
         p_to_date          => p_to_date,
         p_keep_override    => p_keep_override);
   END IF;
   pnp_debug_pkg.log(l_desc ||' (-)');

EXCEPTION
  WHEN currency_exception THEN
     pnp_debug_pkg.put_log_msg(fnd_message.get);
     raise;
  WHEN OTHERS THEN
     fnd_message.set_name('PN','PN_REC_CP_INCOMPLETE');
     pnp_debug_pkg.put_log_msg(fnd_message.get);
     pnp_debug_pkg.log(l_desc || ': Error while ' || l_info);
     raise;
END extract_expense;


-------------------------- MAIN EXTRACTION  ----------------------------------+

------------------------------------------------------------------------------+
-- PROCEDURE  : extract_line_expense_area
-- DESCRIPTION: main extraction program
-- o check / validation of inputs.
-- o go to interface table and fetch 'new' data only.
--   'new' => unique combination of expense type and account id for one extract.
-- o create exp line header if it doesn't exist, and create corresponding exp
--   line detail.
-- o if populate detail set to 'Y' then:
-- oo find exp classes above the specified location, and call the expense
--    extract procedure for each one of them.
-- oo find area classes above the specified location, and call the area extract
--    procedure for each one of them.
--
-- HISTORY:
-- 19-MAR-03  ftanudja  o created
-- 28-APR-03  ftanudja  o split up p_pop_cls_dtl param into area and exp.
-- 13-JUN-03  ftanudja  o incorporated messages for input validation errors.
-- 15-JUL-03  ftanudja  o fixed main extraction program to not throw error
--                        when check_extr_code returns FALSE when called
--                        from rec exp line UI (p_called_from <> 'SRS').
-- 15-JUL-05 SatyaDeepo Replaced base views with their _ALL tables
------------------------------------------------------------------------------+

PROCEDURE extract_line_expense_area(
            errbuf               OUT NOCOPY VARCHAR2,
            retcode              OUT NOCOPY VARCHAR2,
            p_location_code      IN pn_locations.location_code%TYPE,
            p_property_code      IN pn_properties.property_code%TYPE,
            p_as_of_date         IN VARCHAR2,
            p_from_date          IN VARCHAR2,
            p_to_date            IN VARCHAR2,
            p_currency_code      IN pn_rec_exp_line.currency_code%TYPE,
            p_pop_exp_class_dtl  IN VARCHAR2,
            p_pop_area_class_dtl IN VARCHAR2,
            p_keep_override      IN VARCHAR2,
            p_extract_code       IN pn_rec_exp_line.expense_extract_code%TYPE,
            p_called_from        IN VARCHAR2)
IS
   l_as_of_date   DATE;
   l_from_date    DATE;
   l_to_date      DATE;
   l_currency     pn_rec_exp_line.currency_code%TYPE;
   l_info         VARCHAR2(300);
   l_desc         VARCHAR2(100) := 'pn_recovery_extract_pkg.extract_line_expense_area' ;
   l_err          VARCHAR2(100);
   l_location_id  pn_locations.location_id%TYPE;
   l_property_id  pn_locations.property_id%TYPE;
   l_extract_code pn_rec_exp_line.expense_extract_code%TYPE;

   CURSOR derive_loc_id_from_loc_code IS
    SELECT location_id, property_id
    FROM   pn_locations
    WHERE  location_code = p_location_code
      AND  rownum = 1;

   CURSOR derive_prop_id_from_prop_code IS
    SELECT property_id
    FROM   pn_properties
    WHERE  property_code = p_property_code;

   CURSOR get_functional_currency_code IS
    SELECT currency_code
      FROM gl_sets_of_books
     WHERE set_of_books_id = TO_NUMBER(pn_mo_cache_utils.get_profile_value('PN_SET_OF_BOOKS_ID',
                                       pn_mo_cache_utils.get_current_org_id));

BEGIN

   pnp_debug_pkg.log(l_desc ||' (+)');

   l_info := ' validating inputs ';
   pnp_debug_pkg.log(l_info);

   l_from_date := fnd_date.canonical_to_date(p_from_date);
   l_to_date   := fnd_date.canonical_to_date(p_to_date);
   l_as_of_date:= fnd_date.canonical_to_date(p_as_of_date);
   l_extract_code := p_extract_code;

   IF p_location_code IS NOT NULL THEN
      FOR loc_rec IN derive_loc_id_from_loc_code LOOP
         l_location_id := loc_rec.location_id;
         l_property_id := loc_rec.property_id;
      END LOOP;
   ELSIF p_property_code IS NOT NULL THEN
      FOR prop_rec IN derive_prop_id_from_prop_code LOOP l_property_id := prop_rec.property_id;
      END LOOP;
   END IF;

   IF p_currency_code IS NULL THEN
      FOR currency_rec IN get_functional_currency_code LOOP l_currency:= currency_rec.currency_code; END LOOP;
   ELSE
      l_currency:= p_currency_code;
   END IF;

   l_info := ' performing input validation ';
   pnp_debug_pkg.log(l_info);

   IF NOT (l_location_id IS NOT NULL OR l_property_id IS NOT NULL) THEN
      fnd_message.set_name('PN','PN_LOC_PROP_REQ');
      raise bad_input_exception;

   ELSIF NOT check_extract_code(p_extract_code, l_location_id, l_property_id,
                                l_as_of_date, l_from_date, l_to_date, l_currency) THEN

      IF p_extract_code IS NOT NULL AND
         p_called_from = 'SRS' THEN

          fnd_message.set_name('PN','PN_REC_NONUNIQUE_NUM');
          fnd_message.set_token('NUMBER', p_extract_code);
          raise bad_input_exception;

      ELSIF p_extract_code IS NULL AND
            pn_mo_cache_utils.get_profile_value('PN_AUTOMATIC_REC_EXPENSE_NUM',
                                                pn_mo_cache_utils.get_current_org_id) = 'N'
         THEN

          fnd_message.set_name('PN','PN_REC_EXP_NUM_REQ');
          raise bad_input_exception;

      END IF;

   ELSIF NOT check_dates(l_as_of_date, l_from_date, l_to_date, l_location_id, l_property_id, p_extract_code) THEN
      fnd_message.set_name('PN','PN_REC_EXT_DT_OVERLAP');
      raise bad_input_exception;

   ELSIF l_currency IS NULL THEN
      app_exception.raise_exception;

   END IF;

   IF p_called_from = 'SRS' THEN
      l_info:= ' performing extraction';
      pnp_debug_pkg.log(l_info);

      extract_expense_lines(
         p_location_id   => l_location_id,
         p_property_id   => l_property_id,
         p_as_of_date    => l_as_of_date,
         p_from_date     => l_from_date,
         p_to_date       => l_to_date,
         p_currency_code => l_currency,
         p_extract_code  => l_extract_code,
         p_keep_override => p_keep_override
      );
   END IF;

   IF p_pop_exp_class_dtl = 'Y' THEN
      populate_expense_class_details(
         p_location_id   => l_location_id,
         p_property_id   => l_property_id,
         p_as_of_date    => p_as_of_date,
         p_from_date     => p_from_date,
         p_to_date       => p_to_date,
         p_extract_code  => l_extract_code,
         p_keep_override => p_keep_override
      );
   END IF;

   IF p_pop_area_class_dtl = 'Y' THEN
      populate_area_class_details(
         p_location_id   => l_location_id,
         p_property_id   => l_property_id,
         p_as_of_date    => p_as_of_date,
         p_from_date     => p_from_date,
         p_to_date       => p_to_date,
         p_keep_override => p_keep_override
      );
   END IF;

   pnp_debug_pkg.log(l_desc ||' (-)');

EXCEPTION
  WHEN bad_input_exception THEN
     pnp_debug_pkg.log(fnd_message.get);
     raise;
  WHEN OTHERS THEN
     pnp_debug_pkg.log(l_desc || ': Error while ' || l_info);
     raise;
END extract_line_expense_area;

------------------------------------------------------------------------------+
-- PROCEDURE  : purge_expense_lines_itf_data
-- ASSUMES    : UI validates location code, property code and expense extr code
-- DESCRIPTION:
-- 1. Purges data from interface table based on the given parameters.
-- 2. Used dbms_SQL to build the query.
--
-- HISTORY:
-- 18-APR-03 ftanudja o created
-- 24-MAY-04 ftanudja o fixed from date / to date logic
--                    o move logic for delete_all_flag = 'Y' to top.
-- 15-JUL-05 sdnahesh o Replaced base views with their _ALL tables
-- 27-OCT-05 sdmahesh o ATG Mandated changes for SQL literals
------------------------------------------------------------------------------+

PROCEDURE purge_expense_lines_itf_data(
            errbuf             OUT NOCOPY VARCHAR2,
            retcode            OUT NOCOPY VARCHAR2,
            p_extract_code     IN pn_rec_exp_line.expense_extract_code%TYPE,
            p_location_code    IN pn_locations.location_code%TYPE,
            p_property_code    IN pn_properties.property_code%TYPE,
            p_from_date        IN VARCHAR2,
            p_to_date          IN VARCHAR2,
            p_transfer_flag    IN pn_rec_exp_itf.transfer_flag%TYPE,
            p_delete_all_flag  IN VARCHAR2)
IS

   CURSOR derive_loc_id_from_loc_code IS
    SELECT location_id
    FROM   pn_locations
    WHERE  location_code = p_location_code;

   CURSOR derive_prop_id_from_prop_code IS
    SELECT property_id
    FROM   pn_properties
    WHERE  property_code = p_property_code;

   l_loc_id        pn_locations.location_id%TYPE;
   l_prop_id       pn_locations.property_id%TYPE;
   l_sqlhead       VARCHAR2(300);
   l_sqltail       VARCHAR2(900) := null;
   l_info          VARCHAR2(300);
   l_desc          VARCHAR2(100) := 'pn_recovery_extract_pkg.purge_expense_lines_itf_data' ;
   l_extract_code  pn_rec_exp_line.expense_extract_code%TYPE;
   l_transfer_flag pn_rec_exp_itf.transfer_flag%TYPE;
   l_from_date     DATE;
   l_to_date       DATE;
   l_statement     VARCHAR2(5000);
   l_cursor        INTEGER;
   l_rows          INTEGER;
   l_count         INTEGER;

BEGIN

   pnp_debug_pkg.log(l_desc ||' (+)');

   IF p_delete_all_flag = 'Y' THEN
      l_info := ' purging everything ';
      pnp_debug_pkg.log(l_info);
      DELETE pn_rec_exp_itf;
      return;
   END IF;
    pnp_debug_pkg.log('p_extract_code='||p_extract_code);
   l_cursor := dbms_sql.open_cursor;
   l_sqlhead := 'DELETE pn_rec_exp_itf WHERE ';

   l_info := ' figuring expense extract code';
   pnp_debug_pkg.log(l_info);
   l_extract_code := p_extract_code;
   l_transfer_flag := p_transfer_flag;
   l_from_date :=  fnd_date.canonical_to_date(p_from_date);
   l_to_date   :=  fnd_date.canonical_to_date(p_to_date);


   IF p_extract_code IS NOT NULL THEN

      l_sqltail := ' expense_line_dtl_id IN ' ||
                   '(SELECT dtl.expense_line_dtl_id ' ||
                   ' FROM pn_rec_exp_line_all hdr, pn_rec_exp_line_dtl_all dtl ' ||
                   ' WHERE hdr.expense_line_id = dtl.expense_line_id ' ||
                   ' AND hdr.expense_extract_code = :l_extract_code)';

   END IF;

   l_info := ' figuring transfer flag';
   pnp_debug_pkg.log(l_info);

   IF p_transfer_flag IS NOT NULL THEN
      IF l_sqltail IS NOT NULL THEN l_sqltail := l_sqltail ||' AND ';   END IF;
      l_sqltail := l_sqltail || ' transfer_flag = :l_transfer_flag';
   END IF;

   l_info := ' figuring from date';
   pnp_debug_pkg.log(l_info);

   IF p_from_date IS NOT NULL THEN
      IF l_sqltail IS NOT NULL THEN l_sqltail := l_sqltail ||' AND '; END IF;
      l_sqltail := l_sqltail ||' from_date >= :l_from_date)';

   END IF;

   l_info := ' figuring to date';
   pnp_debug_pkg.log(l_info);

   IF p_to_date IS NOT NULL THEN
      IF l_sqltail IS NOT NULL THEN l_sqltail := l_sqltail ||' AND '; END IF;
      l_sqltail := l_sqltail ||' to_date <= :l_to_date)';

   END IF;

   l_info := ' figuring location code';
   pnp_debug_pkg.log(l_info);

   IF p_location_code IS NOT NULL THEN
      IF l_sqltail IS NOT NULL THEN l_sqltail := l_sqltail ||' AND '; END IF;
      FOR loc_rec IN derive_loc_id_from_loc_code LOOP l_loc_id := loc_rec.location_id; END LOOP;
      l_sqltail := l_sqltail || ' location_id = :l_loc_id';

   END IF;

   l_info := ' figuring property code';
   pnp_debug_pkg.log(l_info);

   IF p_property_code IS NOT NULL THEN
      IF l_sqltail IS NOT NULL THEN l_sqltail := l_sqltail ||' AND '; END IF;
      FOR prop_rec IN derive_prop_id_from_prop_code LOOP l_prop_id := prop_rec.property_id; END LOOP;
      l_sqltail := l_sqltail || ' property_id = :l_prop_id';

   END IF;



   IF l_sqltail IS NOT NULL THEN

      l_info := ' deleting using dynamic SQL';
      pnp_debug_pkg.log(l_info);
      pnp_debug_pkg.log('');
      pnp_debug_pkg.log(l_sqlhead);
      pnp_debug_pkg.log(l_sqltail);
      pnp_debug_pkg.log('');

      l_statement := l_sqlhead || l_sqltail;
      dbms_sql.parse(l_cursor,l_statement,dbms_sql.native);
      IF p_extract_code IS NOT NULL THEN
        dbms_sql.bind_variable(l_cursor,'l_extract_code',l_extract_code);
      END IF;

      IF p_transfer_flag IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_transfer_flag',l_transfer_flag);
      END IF;

      IF p_from_date IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_from_date',l_from_date);
      END IF;

      IF p_to_date IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_to_date',l_to_date);
      END IF;

      IF p_location_code IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_loc_id',l_loc_id);
      END IF;

      IF p_property_code IS NOT NULL THEN
       dbms_sql.bind_variable(l_cursor,'l_prop_id',l_prop_id);
      END IF;
      l_rows   := dbms_sql.execute(l_cursor);


   END IF;

   IF dbms_sql.is_open (l_cursor) THEN
      dbms_sql.close_cursor (l_cursor);
   END IF;
   pnp_debug_pkg.log(l_desc ||' (-)');

EXCEPTION
  WHEN OTHERS THEN
     pnp_debug_pkg.log(l_desc || ': Error while ' || l_info);
     raise;
END;

END pn_recovery_extract_pkg;

/
