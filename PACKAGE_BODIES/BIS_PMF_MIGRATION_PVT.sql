--------------------------------------------------------
--  DDL for Package Body BIS_PMF_MIGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_PMF_MIGRATION_PVT" AS
/* $Header: BISVMIGB.pls 120.2 2005/12/15 03:23:41 ankgoel noship $ */
--
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPMIGS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Package Body for Migration of PMF data .
REM |     Please refer to the datamodel for the changes.
REM |                                                                       |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 21-July-2000 amkulkar Creation                                        |
REM |  19-apr-01 rmohanty added fix for 1743506
REM | 21-Jun-2001 meastmon fix migration for bis_user_ind_selections        |
REM | 11-FEB-2003 rchandra added a check to see if the target level going   |
REM |                       to be migrated already exists in which case it  |
REM |                       will not be migrated , in NEEDS_MIGRATION api   |
REM |                       for bug 2790164                                 |
REM |                       Also the migration script will only process rows|
REM |                       from old data model. Cursor definition          |
REM |                       c_targetlvls in MIGRATE_PERFORMANCE_MEASURES API|
REM |                       accordingly changed                             |
REM | 03-JUN-2004 ankgoel  Modified for bug#3583357. Added procedures for   |
REM |                      re-sequencing dimensions in                      |
REM |                      bis_indicator_dimensions using the dim level     |
REM |                      order in bis_target_levels.                      |
REM | 21-MAR-2005 ankagarw bug#4235732 - changing count(*) to count(1)      |
REM | 19-OCT-2005 ppandey  Enh 4618419- SQL Literal Fix                     |
REM | 15-DEC-2005 ankgoel  Bug 4879417- Execute dynamic SQL with a NULL check                   |
REM +=======================================================================+
*/
--
--
FUNCTION GET_DIMENSION_ID
(p_dimension_level_id     IN    NUMBER
)
RETURN NUMBER
IS
   CURSOR c_dim IS
   SELECT dimension_id
   FROM   bis_levels
   WHERE  level_id = p_dimension_level_id;
   l_dim_id		NUMBER;
BEGIN
   OPEN c_dim;
   FETCH c_dim INTO l_dim_id;
   CLOSE c_dim;
   RETURN l_dim_id;
EXCEPTION
  WHEN OTHERS THEN
       null;
END GET_DIMENSION_ID;
--

FUNCTION need_resequence (
 p_indicator_id  IN  NUMBER
,p_dim_level_id  IN  NUMBER
,p_sequence_no   IN  NUMBER
)
RETURN BOOLEAN
IS
  CURSOR c_dim_dim_levels(p_dim_level_id NUMBER, p_indicator_id NUMBER) IS
  SELECT sequence_no
  FROM bis_indicator_dimensions BIS_IND,
       bis_levels BIS_LVL
  WHERE BIS_IND.dimension_id = BIS_LVL.dimension_id
  AND	BIS_IND.indicator_id = p_indicator_id
  AND	BIS_LVL.level_id = p_dim_level_id;

  l_reseq_flag          BOOLEAN := FALSE;
  l_dim_level_sequence  NUMBER;
  l_ind_dim_sequence    NUMBER;
BEGIN
  IF c_dim_dim_levels%ISOPEN THEN
    CLOSE c_dim_dim_levels;
  END IF;
  l_dim_level_sequence := p_sequence_no;
  OPEN c_dim_dim_levels(p_dim_level_id, p_indicator_id);
  FETCH c_dim_dim_levels INTO l_ind_dim_sequence;
  IF ((c_dim_dim_levels%FOUND) AND (l_dim_level_sequence <> l_ind_dim_sequence)) THEN
    l_reseq_flag := TRUE;
  END IF;
  CLOSE c_dim_dim_levels;

  RETURN l_reseq_flag;

EXCEPTION
WHEN OTHERS THEN
  IF c_dim_dim_levels%ISOPEN THEN
    CLOSE c_dim_dim_levels;
  END IF;
  RETURN TRUE;
END need_resequence;
--

PROCEDURE update_bis_indicators (
 p_indicator_id  IN  NUMBER
,p_dim_level_id  IN  NUMBER
,p_sequence_no   IN  NUMBER
)
IS
BEGIN
  IF(p_dim_level_id IS NOT NULL) THEN
    UPDATE bis_indicator_dimensions
    SET sequence_no = p_sequence_no
       ,last_update_date = SYSDATE
    WHERE indicator_id = p_indicator_id
    AND	dimension_id = get_dimension_id(p_dim_level_id);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END update_bis_indicators;

PROCEDURE resequence_ind_dimensions (
  p_indicator_id  IN  NUMBER
)
IS
  /* It is assumed that all target levels for a measure are consistent with each other.
     Only the first set of target level data is taken up.
  */
  CURSOR c_target_level(p_ind_id NUMBER) IS
  SELECT dimension1_level_id, dimension2_level_id,
         dimension3_level_id, dimension4_level_id,
         dimension5_level_id, dimension6_level_id,
         dimension7_level_id
  FROM bis_target_levels
  WHERE indicator_id = p_ind_id
  AND org_level_id IS NOT NULL
  AND time_level_id IS NOT NULL
  AND rownum < 2;

  l_flag_resequence     BOOLEAN := FALSE;
  l_target_level_rec    BIS_PMF_MIGRATION_PVT.target_level_rec;
  c_tl_rec              c_target_level%ROWTYPE;

BEGIN

  IF c_target_level%ISOPEN THEN
    CLOSE c_target_level;
  END IF;

  OPEN c_target_level(p_indicator_id);
  FETCH c_target_level INTO c_tl_rec;
  IF c_target_level%FOUND THEN

    IF (c_tl_rec.dimension1_level_id IS NOT NULL) THEN
      l_flag_resequence := need_resequence(p_indicator_id, c_tl_rec.dimension1_level_id, 1);
    END IF;
    IF ((c_tl_rec.dimension2_level_id IS NOT NULL) AND (l_flag_resequence = FALSE)) THEN
	  l_flag_resequence := need_resequence(p_indicator_id, c_tl_rec.dimension2_level_id, 2);
    END IF;
    IF ((c_tl_rec.dimension3_level_id IS NOT NULL) AND (l_flag_resequence = FALSE)) THEN
	  l_flag_resequence := need_resequence(p_indicator_id, c_tl_rec.dimension3_level_id, 3);
    END IF;
    IF ((c_tl_rec.dimension4_level_id IS NOT NULL) AND (l_flag_resequence = FALSE)) THEN
	  l_flag_resequence := need_resequence(p_indicator_id, c_tl_rec.dimension4_level_id, 4);
    END IF;
    IF ((c_tl_rec.dimension5_level_id IS NOT NULL) AND (l_flag_resequence = FALSE)) THEN
	  l_flag_resequence := need_resequence(p_indicator_id, c_tl_rec.dimension5_level_id, 5);
    END IF;
    IF ((c_tl_rec.dimension6_level_id IS NOT NULL) AND (l_flag_resequence = FALSE)) THEN
	  l_flag_resequence := need_resequence(p_indicator_id, c_tl_rec.dimension6_level_id, 6);
    END IF;
    IF ((c_tl_rec.dimension7_level_id IS NOT NULL) AND (l_flag_resequence = FALSE)) THEN
	  l_flag_resequence := need_resequence(p_indicator_id, c_tl_rec.dimension7_level_id, 7);
    END IF;

    IF (l_flag_resequence = TRUE) THEN

      update_bis_indicators(p_indicator_id, c_tl_rec.dimension1_level_id, 1);
      update_bis_indicators(p_indicator_id, c_tl_rec.dimension2_level_id, 2);
      update_bis_indicators(p_indicator_id, c_tl_rec.dimension3_level_id, 3);
      update_bis_indicators(p_indicator_id, c_tl_rec.dimension4_level_id, 4);
      update_bis_indicators(p_indicator_id, c_tl_rec.dimension5_level_id, 5);
      update_bis_indicators(p_indicator_id, c_tl_rec.dimension6_level_id, 6);
      update_bis_indicators(p_indicator_id, c_tl_rec.dimension7_level_id, 7);

    END IF;
  END IF;
  CLOSE c_target_level;

EXCEPTION
WHEN OTHERS THEN
  IF c_target_level%ISOPEN THEN
    CLOSE c_target_level;
  END IF;
  ROLLBACK;
END resequence_ind_dimensions;
--


PROCEDURE migrate_indicator_dimensions(
 x_return_status  OUT NOCOPY   VARCHAR2
,x_return_code    OUT NOCOPY   NUMBER
)
IS
  /* Cursor picks up only the indicator_id which have ORG and TIME level id as NOT NULL.
     This is assumed for old measures.
  */
    CURSOR c_ind_id IS
    SELECT indicator_id
    FROM bis_target_levels
    WHERE org_level_id IS NOT NULL
    AND time_level_id IS NOT NULL
    GROUP BY indicator_id;

BEGIN
  FOR c_ind_rec IN c_ind_id LOOP
    resequence_ind_dimensions(c_ind_rec.indicator_id);
  END LOOP;

  x_return_Status := 'Success';
  x_return_code   := 0;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    x_return_Status := SQLERRM;
    x_return_code   := SQLCODE;
END migrate_indicator_dimensions;
--

PROCEDURE RESEQUENCE_DIMENSION_LEVELS(
 p_target_level_rec       IN    BIS_PMF_MIGRATION_PVT.target_level_rec
,x_resequenced_dimensions OUT NOCOPY   BIS_PMF_MIGRATION_PVT.resequenced_dimensions_array
,x_dim_count		  OUT NOCOPY	NUMBER
,x_return_status          OUT NOCOPY   NUMBER
)
IS
  CURSOR c_dimcount(p_measure_id IN NUMBER) IS
  SELECT count(1) FROM
  bis_indicator_dimensions
  WHERE indicator_id = p_measure_id;
  l_reseuenced_dimensions_array         BIS_PMF_MIGRATION_PVT.resequenced_dimensions_array;
  l_dimcount				NUMBER;
BEGIN
  OPEN c_dimcount(p_target_level_rec.measure_id);
  FETCH c_dimcount INTO l_dimcount;
  IF (c_dimcount%NOTFOUND) THEN
     x_return_status := -1;
  END IF;
  CLOSE c_dimcount;
  x_dim_count := l_dimcount;
  -- Since the org/time are always the first two subtract two from the count
  --If somebody for some reason runs the migration script again , do not subtract two
  IF (p_target_level_rec.org_levelid IS NOT NULL and p_target_level_rec.time_levelid IS NOT NULL) THEN
     l_dimcount := l_dimcount-2;
  END IF;
  IF (l_dimcount > 0) THEN
  FOR l_count IN 1..l_dimcount LOOP
      x_resequenced_dimensions(l_count).dim_level_col := 'dimension'||l_count||'_level_id';
      IF (l_count = 1) THEN
         x_resequenced_dimensions(1).dim_level_col_val := p_target_level_rec.dimension1_levelid;
         x_resequenced_dimensions(1).dim_id            := bis_pmf_migration_pvt.get_dimension_id (
							  p_target_level_rec.dimension1_levelid);
         x_Resequenced_dimensions(1).seq_no            := l_count;
      END IF;
      IF (l_count=2) THEN
         x_resequenced_dimensions(2).dim_level_col_val := p_target_level_rec.dimension2_levelid;
         x_resequenced_dimensions(2).dim_id            := bis_pmf_migration_pvt.get_dimension_id (
							  p_target_level_rec.dimension2_levelid);
         x_Resequenced_dimensions(2).seq_no            := l_count;
      END IF;
      IF (l_count=3) THEN
         x_resequenced_dimensions(3).dim_level_col_val := p_target_level_rec.dimension3_levelid;
         x_resequenced_dimensions(3).dim_id            := bis_pmf_migration_pvt.get_dimension_id (
							  p_target_level_rec.dimension3_levelid);
         x_Resequenced_dimensions(3).seq_no            := l_count;
      END IF;
      IF (l_count=4) THEN
         x_resequenced_dimensions(4).dim_level_col_val := p_target_level_rec.dimension4_levelid;
         x_resequenced_dimensions(4).dim_id            := bis_pmf_migration_pvt.get_dimension_id (
							  p_target_level_rec.dimension4_levelid);
         x_Resequenced_dimensions(4).seq_no            := l_count;
      END IF;
      IF (l_count=5) THEN
         x_resequenced_dimensions(5).dim_level_col_val := p_target_level_rec.dimension5_levelid;
         x_resequenced_dimensions(5).dim_id            := bis_pmf_migration_pvt.get_dimension_id (
							  p_target_level_rec.dimension5_levelid);
         x_Resequenced_dimensions(5).seq_no            := l_count;
      END IF;
  END LOOP;
  END IF;
  l_dimcount := l_dimcount + 1;
  IF (l_dimcount <= 7) THEN
     x_resequenced_dimensions(l_dimcount).dim_level_col := 'dimension'||l_dimcount||'_level_id';
     x_resequenced_dimensions(l_dimcount).dim_level_col_val := p_target_level_rec.org_levelid;
     x_resequenced_dimensions(l_dimcount).dim_id            := bis_pmf_migration_pvt.get_dimension_id (
							       p_target_level_rec.org_levelid);
     x_Resequenced_dimensions(l_dimcount).seq_no            := l_dimcount;
     l_dimcount := l_dimcount + 1;
     x_resequenced_dimensions(l_dimcount).dim_level_col     := 'dimension'||l_dimcount||'_level_id';
     x_resequenced_dimensions(l_dimcount).dim_level_col_val := p_target_level_rec.time_levelid;
     x_resequenced_dimensions(l_dimcount).dim_id            := bis_pmf_migration_pvt.get_dimension_id (
							       p_target_level_rec.time_levelid);
     x_Resequenced_dimensions(l_dimcount).seq_no            := l_dimcount;
     l_dimcount := l_dimcount +1;
     FOR l_count IN l_dimcount..7 LOOP
     x_resequenced_dimensions(l_dimcount).dim_level_col     := 'dimension'||l_dimcount||'_level_id';
     x_resequenced_dimensions(l_dimcount).dim_level_col_val := NULL;
     l_dimcount := l_dimcount+1;
     END LOOP;
  END IF;
  x_return_status := 0;
EXCEPTION
  WHEN OTHERS THEN
       x_return_status := -1;
END RESEQUENCE_DIMENSION_LEVELS;
--
PROCEDURE RESEQUENCE_DIM_LEVEL_VALUES(
 p_dimvalues_rec          IN    BIS_PMF_MIGRATION_PVT.dim_values_rec
,p_dim_count              IN    NUMBER
,x_reseq_dim_values       OUT NOCOPY   BIS_PMF_MIGRATION_PVT.reseq_dim_values_arr
,x_return_Status	  OUT NOCOPY   NUMBER
)
IS
  l_dim_levelcount 	  NUMBER ;
BEGIN
  l_dim_levelcount := p_dim_count;
  IF(p_dimvalues_rec.org_level_value IS NOT NULL AND p_dimvalues_rec.time_level_value IS NOT NULL) THEN
    l_dim_levelcount := l_dim_levelcount - 2;
  END IF;
  IF (l_dim_levelcount > 0) THEN
  FOR l_count IN 1..l_dim_levelcount LOOP
      x_reseq_dim_values(l_count).dim_level_name := 'dimension'||l_count||'_level_value';
      IF (l_count = 1) THEN
	 IF (p_dimvalues_rec.dimension1_level_value IS NOT NULL) THEN
            x_reseq_dim_values(1).dim_level_value :=
				''''||p_dimvalues_rec.dimension1_level_value||'''';
	 ELSE
	    x_reseq_dim_values(1).dim_level_value := p_dimvalues_rec.dimension1_level_Value;
	 END IF;
      END IF;
      IF (l_count = 2) THEN
	 IF (p_dimvalues_rec.dimension2_level_value IS NOT NULL) THEN
            x_reseq_dim_values(2).dim_level_value :=
				''''||p_dimvalues_rec.dimension2_level_value||'''';
	 ELSE
	    x_reseq_dim_values(2).dim_level_value:= p_dimvalues_rec.dimension2_level_Value;
	 END IF;
      END IF;
      IF (l_count = 3) THEN
	 IF (p_dimvalues_rec.dimension3_level_value IS NOT NULL) THEN
            x_reseq_dim_values(3).dim_level_value:=
				''''||p_dimvalues_rec.dimension3_level_value||'''';
	 ELSE
	    x_reseq_dim_values(3).dim_level_value := p_dimvalues_rec.dimension3_level_Value;
	 END IF;
      END IF;
      IF (l_count = 4) THEN
	 IF (p_dimvalues_rec.dimension4_level_value IS NOT NULL) THEN
            x_reseq_dim_values(4).dim_level_value :=
				''''||p_dimvalues_rec.dimension4_level_value||'''';
	 ELSE
	    x_reseq_dim_values(4).dim_level_value := p_dimvalues_rec.dimension4_level_Value;
	 END IF;
      END IF;
      IF (l_count = 5) THEN
	 IF (p_dimvalues_rec.dimension5_level_value IS NOT NULL) THEN
            x_reseq_dim_values(5).dim_level_value :=
				''''||p_dimvalues_rec.dimension5_level_value||'''';
	 ELSE
	    x_reseq_dim_values(5).dim_level_value := p_dimvalues_rec.dimension5_level_Value;
	 END IF;
      END IF;
  END LOOP;
  END IF;
  l_dim_levelcount := l_dim_levelcount + 1;
  IF (l_dim_levelcount <= 7) THEN
     x_reseq_dim_values(l_dim_levelcount).dim_level_name :=
                          'dimension'||l_dim_levelcount||'_level_value';
     IF (p_dimvalues_rec.org_level_value IS NOT NULL) THEN
     x_reseq_dim_values(l_dim_levelcount).dim_level_value :=
		''''||p_dimvalues_rec.org_level_value||'''';
     ELSE
     x_reseq_dim_values(l_dim_levelcount).dim_level_value := p_dimvalues_rec.org_level_value;
     END IF;
     l_dim_levelcount := l_dim_levelcount + 1;
     x_reseq_dim_values(l_dim_levelcount).dim_level_name :=
			 'dimension'||l_dim_levelcount||'_level_value';
     IF (p_dimvalues_rec.time_level_value IS NOT NULL) THEN
     x_reseq_dim_values(l_dim_levelcount).dim_level_value :=
		''''||p_dimvalues_rec.time_level_value||'''';
     ELSE
     x_reseq_dim_values(l_dim_levelcount).dim_level_value := p_dimvalues_rec.time_level_value;
     END IF;
     l_dim_levelcount := l_dim_levelcount +1;
     FOR l_count IN l_dim_levelcount..7 LOOP
     x_reseq_dim_values(l_dim_levelcount).dim_level_name :=
			 'dimension'||l_dim_levelcount||'_level_value';
     x_reseq_dim_values(l_Dim_levelcount).dim_level_value := NULL;
     l_dim_levelcount := l_dim_levelcount+1;
     END LOOP;
  END IF;
  x_return_status := 0;
EXCEPTION
  WHEN OTHERS THEN
       x_return_status := -1;
END;
--
PROCEDURE RESEQUENCE_IND_LEVEL_VALUES(
 p_dimvalues_rec          IN BIS_PMF_MIGRATION_PVT.dim_values_Rec
,p_dim_count              IN NUMBER
,x_reseq_dim_values       OUT NOCOPY BIS_PMF_MIGRATION_PVT.reseq_dim_values_arr
,x_return_status          OUT NOCOPY NUMBER
)
IS
  l_dim_levelcount 	  NUMBER ;
BEGIN
  l_dim_levelcount := p_dim_count;
  IF(p_dimvalues_rec.org_level_value IS NOT NULL ) THEN
    l_dim_levelcount := l_dim_levelcount - 1;
  END IF;
  IF (l_dim_levelcount > 0) THEN
  FOR l_count IN 1..l_dim_levelcount LOOP
      x_reseq_dim_values(l_count).dim_level_name := 'dimension'||l_count||'_level_value';
      IF (l_count = 1) THEN
	 IF (p_dimvalues_rec.dimension1_level_value IS NOT NULL) THEN
            x_reseq_dim_values(1).dim_level_value :=
				''''||p_dimvalues_rec.dimension1_level_value||'''';
	 ELSE
	    x_reseq_dim_values(1).dim_level_value := p_dimvalues_rec.dimension1_level_Value;
	 END IF;
      END IF;
      IF (l_count = 2) THEN
	 IF (p_dimvalues_rec.dimension2_level_value IS NOT NULL) THEN
            x_reseq_dim_values(2).dim_level_value :=
				''''||p_dimvalues_rec.dimension2_level_value||'''';
	 ELSE
	    x_reseq_dim_values(2).dim_level_value:= p_dimvalues_rec.dimension2_level_Value;
	 END IF;
      END IF;
      IF (l_count = 3) THEN
	 IF (p_dimvalues_rec.dimension3_level_value IS NOT NULL) THEN
            x_reseq_dim_values(3).dim_level_value:=
				''''||p_dimvalues_rec.dimension3_level_value||'''';
	 ELSE
	    x_reseq_dim_values(3).dim_level_value := p_dimvalues_rec.dimension3_level_Value;
	 END IF;
      END IF;
      IF (l_count = 4) THEN
	 IF (p_dimvalues_rec.dimension4_level_value IS NOT NULL) THEN
            x_reseq_dim_values(4).dim_level_value :=
				''''||p_dimvalues_rec.dimension4_level_value||'''';
	 ELSE
	    x_reseq_dim_values(4).dim_level_value := p_dimvalues_rec.dimension4_level_Value;
	 END IF;
      END IF;
      IF (l_count = 5) THEN
	 IF (p_dimvalues_rec.dimension5_level_value IS NOT NULL) THEN
            x_reseq_dim_values(5).dim_level_value :=
				''''||p_dimvalues_rec.dimension5_level_value||'''';
	 ELSE
	    x_reseq_dim_values(5).dim_level_value := p_dimvalues_rec.dimension5_level_Value;
	 END IF;
      END IF;
  END LOOP;
  END IF;
  l_dim_levelcount := l_dim_levelcount + 1;
  IF (l_dim_levelcount <= 6) THEN
     x_reseq_dim_values(l_dim_levelcount).dim_level_name :=
                          'dimension'||l_dim_levelcount||'_level_value';
     IF (p_dimvalues_rec.org_level_value IS NOT NULL) THEN
     x_reseq_dim_values(l_dim_levelcount).dim_level_value :=
		''''||p_dimvalues_rec.org_level_value||'''';
     ELSE
     x_reseq_dim_values(l_dim_levelcount).dim_level_value := p_dimvalues_rec.org_level_value;
     END IF;
     l_dim_levelcount := l_dim_levelcount + 1;
     FOR l_count IN l_dim_levelcount..7 LOOP
     x_reseq_dim_values(l_dim_levelcount).dim_level_name :=
			 'dimension'||l_dim_levelcount||'_level_value';
     x_reseq_dim_values(l_Dim_levelcount).dim_level_value := NULL;
     l_dim_levelcount := l_dim_levelcount+1;
     END LOOP;
  END IF;
  x_return_status := 0;
EXCEPTION
  WHEN OTHERS THEN
       x_return_status := -1;
END;


PROCEDURE MIGRATE_PERFORMANCE_MEASURES
(
 x_return_status      OUT NOCOPY   VARCHAR2
,x_return_code       OUT NOCOPY   NUMBER
)
IS
  CURSOR c_targetlvls  IS
  SELECT target_level_id, indicator_id, short_name
        ,time_level_id, org_level_id, dimension1_level_id
        ,dimension2_level_id, dimension3_level_id, dimension4_level_id
        ,dimension5_level_id, dimension6_level_id, dimension7_level_id
  FROM bis_target_levels
  WHERE (NVL(dimension1_level_id,-9999) <> time_level_id AND NVL(dimension1_level_id,-9999)  <> org_level_id)
    AND (NVL(dimension2_level_id,-9999) <> time_level_id AND NVL(dimension2_level_id,-9999)  <> org_level_id)
    AND (NVL(dimension3_level_id,-9999) <> time_level_id AND NVL(dimension3_level_id,-9999)  <> org_level_id)
    AND (NVL(dimension4_level_id,-9999) <> time_level_id AND NVL(dimension4_level_id,-9999)  <> org_level_id)
    AND (NVL(dimension5_level_id,-9999) <> time_level_id AND NVL(dimension5_level_id,-9999)  <> org_level_id)
    AND (NVL(dimension6_level_id,-9999) <> time_level_id AND NVL(dimension6_level_id,-9999)  <> org_level_id)
    AND (NVL(dimension7_level_id,-9999) <> time_level_id AND NVL(dimension7_level_id,-9999)  <> org_level_id)
  ;  -- only get those rows from the old datamodel
  CURSOR c_targetlvl_values(p_target_level_id IN NUMBER) IS
  SELECT target_id, org_level_value, time_level_value
        ,dimension1_level_value, dimension2_level_value, dimension3_level_value
	,dimension4_level_value, dimension5_level_value
  FROM bis_target_values
  WHERE target_level_id = p_target_level_id;
  CURSOR c_actual_values(p_target_level_id IN NUMBER) IS
  SELECT actual_id, target_level_id, org_level_value, time_level_value,
         dimension1_level_value, dimension2_level_value
        ,dimension3_level_value, dimension4_level_value
        ,dimension5_level_value
  FROM bis_Actual_values
  WHERE target_level_id = p_target_level_id;
  CURSOR c_usrind_values(p_target_level_id IN NUMBER) IS
  SELECT ind_selection_id, target_level_id, org_level_value
        ,dimension1_level_value, dimension2_level_value
        ,dimension3_level_value, dimension4_level_value
        ,dimension5_level_value
  FROM bis_user_ind_selections
  WHERE target_level_id = p_target_level_id;
  l_target_level_rec		BIS_PMF_MIGRATION_PVT.target_level_rec;
  l_reseq_dims                  BIS_PMF_MIGRATION_PVT.resequenced_dimensions_Array;
  l_target_rec			BIS_PMF_MIGRATION_PVT.dim_Values_rec;
  l_reseq_target_values		BIS_PMF_MIGRATION_PVT.reseq_dim_values_arr;
  l_Actual_rec			BIS_PMF_MIGRATION_PVT.dim_values_rec;
  l_reseq_actual_values	        BIS_PMF_MIGRATION_PVT.reseq_dim_values_arr;
  l_userind_rec    		BIS_PMF_MIGRATION_PVT.dim_values_rec;
  l_reseq_userind_Values        BIS_PMF_MIGRATION_PVT.reseq_dim_values_arr;
  l_return_status               NUMBER;
  l_sqlstmt 			VARCHAR2(32000);
  l_sqlstmt1			VARCHAR2(32000);
  l_sqlstmt2                    VARCHAR2(32000);
  l_sqlstmt3			VARCHAR2(32000);
  l_count			NUMBER := 1;
  l_dummy_value 		NUMBER := 990;
  l_dimlevel_count		NUMBER;
  l_dim_count			NUMBER;
  l_dim_levelvalue_count	NUMBER;
  l_indicator_id                BIS_INDICATORS.INDICATOR_ID%TYPE;
  l_error_tbl			BIS_UTILITIES_PUB.ERROR_TBL_TYPE;
  l_sequence_no			NUMBER;
  l_dim_level_id		NUMBER;
  l_dim_level_short_name        VARCHAR2(32000);
  l_dim_level_name              VARCHAR2(32000);
  l_ret_status                  VARCHAR2(32000);
  l_userind_org_name            VARCHAR2(32000);
  l_userind_org_value           VARCHAR2(32000);
  l_target_level_rec_new        BIS_TARget_LEVEL_PUB.TARGET_LEVEL_REC_TYPE;
  -- meastmon 06/21/2001
  l_userind_current_org_value   VARCHAR2(32000);
BEGIN
--Loop thru the cursor and resequence the dimension levels
    FOR c_rec IN c_targetlvls LOOP
        l_target_level_rec.measure_id         := c_rec.indicator_id;
        l_target_level_rec.target_level_id    := c_rec.target_level_id;
        l_target_level_rec.org_levelid        := c_rec.org_level_id;
        l_target_level_rec.time_levelid       := c_Rec.time_level_id;
        l_target_level_rec.dimension1_levelid := c_rec.dimension1_level_id;
        l_target_level_rec.dimension2_levelid := c_rec.dimension2_level_id;
        l_Target_level_Rec.dimension3_levelid := c_rec.dimension3_level_id;
        l_target_level_rec.dimension4_levelid := c_rec.dimension4_level_id;
        l_target_level_rec.dimension5_levelid := c_rec.dimension5_level_id;
        l_dimlevel_count := 0;
        IF (c_rec.org_level_id IS NOT NULL) THEN
            l_dimlevel_count := l_dimlevel_count+1;
        END IF;
        IF (c_rec.time_level_id IS NOT NULL) THEN
            l_dimlevel_count := l_dimlevel_count+1;
        END IF;
        IF (c_rec.dimension1_level_id IS NOT NULL) THEN
            l_dimlevel_count := l_dimlevel_count+1;
        END IF;
        IF (c_rec.dimension2_level_id IS NOT NULL) THEN
            l_dimlevel_count := l_dimlevel_count+1;
        END IF;
        IF (c_rec.dimension3_level_id IS NOT NULL) THEN
            l_dimlevel_count := l_dimlevel_count+1;
        END IF;
        IF (c_rec.dimension4_level_id IS NOT NULL) THEN
            l_dimlevel_count := l_dimlevel_count+1;
        END IF;
        IF (c_rec.dimension5_level_id IS NOT NULL) THEN
            l_dimlevel_count := l_dimlevel_count+1;
        END IF;
        --Check if the org and time levels are null. If they are then there is no
        --need to resequence anything.  This means the records are not really from an
        -- older version of BIS. Also ignore any targets, actuals , user indicator dimensions
        -- for this record since if they have org and time level values the whole thing is
        --messed up anyway.
        IF ((c_rec.org_level_id IS NOT NULL) OR (c_rec.time_level_id IS NOT NULL)) THEN
            l_target_level_rec_new.dimension1_level_id := c_rec.dimension1_level_id;
            l_target_level_rec_new.dimension2_level_id := c_rec.dimension2_level_id;
            l_target_level_rec_new.dimension3_level_id := c_rec.dimension3_level_id;
            l_target_level_rec_new.dimension4_level_id := c_rec.dimension4_level_id;
            l_target_level_rec_new.dimension5_level_id := c_rec.dimension5_level_id;
            l_target_level_rec_new.dimension6_level_id := c_rec.dimension6_level_id;
            l_target_level_rec_new.dimension7_level_id := c_rec.dimension7_level_id;
            l_target_level_rec_new.org_level_id        := c_rec.org_level_id;
            l_target_level_rec_new.time_level_id       := c_rec.time_level_id;
            l_target_level_rec_new.measure_id          := c_rec.indicator_id;

            IF (BIS_PMF_MIGRATION_PVT.NEEDS_MIGRATION(l_target_level_rec_new)) THEN
                BIS_PMF_MIGRATION_PVT.resequence_dimension_levels
         		         (p_target_level_rec => l_target_level_rec
			             ,x_resequenced_dimensions => l_reseq_dims
			             ,x_dim_count     => l_dim_count
                         ,x_return_status => l_return_status
        		          );
                -- Check if the org_level_id and time_level_id are already part of one of
                -- the seven dimension levels. We really need to go back to the dimensions
                -- for these levels in order to verify that. This is to allow the re-re-running
                -- of this particular procedure
                IF (l_return_status = 0 AND l_reseq_dims.COUNT>0) THEN
                    IF (l_dim_count = l_dimlevel_count) THEN
                        --First update the dimension sequences
                        l_Dummy_value := 990;
	                    FOR l_count IN 1..l_reseq_dims.COUNT LOOP
                            IF c_rec.indicator_id = 1001 THEN
		                      NULL;--
	                        END If;
	                    END LOOP;
                        FOR l_count IN 1..l_dim_count LOOP
                            IF (l_reseq_dims(l_count).dim_id IS NULL) THEN
                                --EXIT;
		                        GOTO skip_record;
	                        ELSE
		                        --if (c_rec.indicator_id < 995) THEN
                                UPDATE bis_indicator_dimensions
                                SET sequence_no = l_dummy_value
  	                            WHERE dimension_id=l_Reseq_dims(l_count).dim_id AND
                                      indicator_id=c_rec.indicator_id;
		                        --END IF;
	                        END IF;
	                        l_dummy_value := l_dummy_value + 1;
                        END LOOP;
                        FOR l_count IN 1..l_dim_count LOOP
                            IF (l_reseq_dims(l_count).dim_id IS NULL) THEN
                                EXIT;
	                        ELSE
		                        --if (c_rec.indicator_id > 995) THEN
                                l_indicator_id := c_rec.indicator_id;
                                UPDATE bis_indicator_dimensions
                                SET    sequence_no= l_reseq_dims(l_count).seq_no
                                WHERE  dimension_id = l_reseq_dims(l_count).dim_id AND
                                       indicator_id = c_Rec.indicator_id;
		                        --END IF;
	                        END IF;
                        END LOOP;
                    END IF;
	                IF (l_dim_count = l_dimlevel_count) THEN
                        l_sqlstmt := 'UPDATE bis_target_levels SET ' ||
                                     l_reseq_dims(1).dim_level_col ||' = :1 ' ||
                                     ' , '||l_reseq_dims(2).dim_level_col ||' = :2 '||
                                     ' , '||l_reseq_dims(3).dim_level_col ||' = :3 '||
                                     ' , '||l_reseq_dims(4).dim_level_col ||' = :4 '||
                                     ' , '||l_reseq_dims(5).dim_level_col ||' = :5 '||
                                     ' , '||l_reseq_dims(6).dim_level_col ||' = :6 '||
                                     ' , '||l_reseq_dims(7).dim_level_col ||' = :7 '||
		                             '  WHERE target_level_id =:8';
                      EXECUTE IMMEDIATE l_sqlstmt USING to_char(l_reseq_dims(1).dim_level_col_val),
                           to_char(l_reseq_dims(2).dim_level_col_val), to_char(l_reseq_dims(3).dim_level_col_val),
                           to_char(l_reseq_dims(4).dim_level_col_val), to_char(l_reseq_dims(5).dim_level_col_val),
                           to_char(l_reseq_dims(6).dim_level_col_val), to_char(l_reseq_dims(7).dim_level_col_val),
                           c_rec.target_level_id;
	                    l_count := 0;
	                    /*Migrate the targets*/
                        FOR c_targetrec IN c_targetlvl_values(c_rec.target_level_id) LOOP
                            l_count := l_count+1;
                            l_target_rec.org_level_value := c_targetrec.org_level_value;
	                        l_target_rec.time_level_value := c_targetrec.time_level_value;
	                        l_target_rec.dimension1_level_value := c_targetrec.dimension1_level_value;
                            l_target_rec.dimension2_level_value := c_targetrec.dimension2_level_value;
                            l_target_rec.dimension3_level_value := c_targetrec.dimension3_level_value;
                            l_target_rec.dimension4_level_value := c_targetrec.dimension4_level_value;
                            l_Target_rec.dimension5_level_value := c_targetrec.dimension5_level_value;
                            BIS_PMF_MIGRATION_PVT.resequence_dim_level_values(
               		                   p_dimvalues_rec => l_target_rec
		                              ,p_dim_count  => l_dim_count
		                              ,x_reseq_dim_values => l_reseq_target_values
		                              ,x_return_Status       => l_return_status
	                                  );
                            IF ((l_return_status = 0) AND (l_reseq_target_values.COUNT > 0)) THEN
                                l_sqlstmt1 := 'UPDATE bis_target_values SET '||
                                              l_reseq_target_values(1).dim_level_name ||' = :1 '||
                                              ' ,'|| l_Reseq_target_values(2).dim_level_name ||' = :2 ' ||
	                                          ' ,' || l_Reseq_target_values(3).dim_level_name ||' = :3 '||
	                                          ' ,' || l_Reseq_target_values(4).dim_level_name||' = :4 ' ||
	                                          ' ,' || l_Reseq_target_values(5).dim_level_name||' = :5 ' ||
	                                          ' ,' || l_Reseq_target_values(6).dim_level_name||' = :6 ' ||
	                                          ' ,' || l_Reseq_target_values(7).dim_level_name||' = :7 ' ||
			                                  ' WHERE target_level_id = :8  AND target_id = :9';
                                EXECUTE IMMEDIATE l_sqlstmt1 USING l_reseq_target_values(1).dim_level_value,
                                     l_reseq_target_values(2).dim_level_value, l_reseq_target_values(3).dim_level_value,
                                     l_reseq_target_values(4).dim_level_value, l_reseq_target_values(5).dim_level_value,
                                     l_reseq_target_values(6).dim_level_value, l_reseq_target_values(7).dim_level_value,
                                     c_rec.target_level_id, c_targetrec.target_id;
 	                        END IF;
                        END LOOP;
                        --Migrate the Actual Values
                        FOR c_actual_rec IN c_actual_values(c_rec.target_level_id)  LOOP
                            l_actual_rec.target_level_id := c_actual_rec.target_level_id;
	                        l_actual_rec.org_level_value := c_actual_rec.org_level_value;
                            l_actual_rec.time_level_value := c_actual_rec.time_level_value;
                            l_actual_rec.dimension1_level_value := c_actual_rec.dimension1_level_value;
                            l_actual_rec.dimension2_level_Value := c_actual_rec.dimension2_level_value;
                            l_actual_rec.dimension3_level_value := c_actual_rec.dimension3_level_value;
                            l_actual_rec.dimension4_level_value := c_actual_rec.dimension4_level_value;
                            l_actual_rec.dimension5_level_value := c_actual_rec.dimension5_level_value;
                            BIS_PMF_MIGRATION_PVT.resequence_dim_level_values(
               		               p_dimvalues_rec => l_actual_rec
		                           ,p_dim_count  => l_dim_count
		                           ,x_reseq_dim_values => l_reseq_actual_values
		                           ,x_return_Status       => l_return_status
	                               );
                            IF ((l_return_status = 0) AND (l_reseq_actual_values.COUNT > 0)) THEN
                                l_sqlstmt2 := 'UPDATE bis_actual_values SET '||
                                              l_reseq_actual_values(1).dim_level_name ||' = :1 '||
                                              ' ,'|| l_Reseq_actual_values(2).dim_level_name ||' = :2 ' ||
	                                          ' ,' || l_Reseq_actual_values(3).dim_level_name ||' = :3 '||
	                                          ' ,' || l_Reseq_actual_values(4).dim_level_name||' = :4 ' ||
	                                          ' ,' || l_Reseq_actual_values(5).dim_level_name||' = :5 ' ||
	                                          ' ,' || l_Reseq_actual_values(6).dim_level_name||' = :6 ' ||
	                                          ' ,' || l_Reseq_actual_values(7).dim_level_name||' = :7 ' ||
			                                  ' WHERE target_level_id = :8 AND actual_id = :9 ';
                                EXECUTE IMMEDIATE l_sqlstmt2 USING l_reseq_actual_values(1).dim_level_value,
                                    l_reseq_actual_values(2).dim_level_value, l_reseq_actual_values(3).dim_level_value,
                                    l_reseq_actual_values(4).dim_level_value, l_reseq_actual_values(5).dim_level_value,
                                    l_reseq_actual_values(6).dim_level_value, l_reseq_actual_values(7).dim_level_value,
                                    c_rec.target_level_id, c_actual_Rec.actual_id;
 	                        END IF;
	                    END LOOP;
                    END IF;

                    FOR c_userind_rec IN c_usrind_values(c_rec.target_level_id)  LOOP
                        l_userind_rec.target_level_id := c_userind_rec.target_level_id;
	                    l_userind_rec.org_level_value := c_userind_rec.org_level_value;
                        l_userind_rec.time_level_value := NULL;
                        l_userind_rec.dimension1_level_value := c_userind_rec.dimension1_level_value;
                        l_userind_rec.dimension2_level_Value := c_userind_rec.dimension2_level_value;
                        l_userind_rec.dimension3_level_value := c_userind_rec.dimension3_level_value;
                        l_userind_rec.dimension4_level_value := c_userind_rec.dimension4_level_value;
                        l_userind_rec.dimension5_level_value := c_userind_rec.dimension5_level_value;
                        /*BIS_PMF_MIGRATION_PVT.resequence_ind_level_values(
               		           p_dimvalues_rec => l_userind_rec
		                      ,p_dim_count  => l_dim_count
		                      ,x_reseq_dim_values => l_reseq_userind_values
		                      ,x_return_Status       => l_return_status
	                          ); */
                        -- For user indicator selections find out NOCOPY what is the org level and just update
                        -- that particular dimension. The above logic tries to move the org level value to
                        -- the end which is wrong
	                    BIS_PMF_DEFINER_WRAPPER_PVT.GET_ORG_LEVEL_ID
                            (p_performance_measure_id         => c_rec.indicator_id
                            ,p_target_level_id                => c_rec.target_level_id
	                    ,p_perf_measure_short_name        => null
                            ,p_target_level_short_name        => null
                            ,x_sequence_no                    => l_sequence_no
                            ,x_dim_level_id                   => l_dim_level_id
                            ,x_dim_level_short_name           => l_dim_level_short_name
                            ,x_dim_level_name                 => l_dim_level_name
                            ,x_return_status                  => l_ret_status
                            ,x_error_tbl                      =>l_error_tbl
                            );
                        l_userind_org_name := '';
                        l_userind_org_value := '';

                        --meastmon 06/21/20001
                        --save the current value for organization level
                        --It will be used to decide whether we have to update the record or not.
                        l_userind_current_org_value := NULL;

                        IF (l_sequence_no = 1) THEN
                            l_userind_org_name := 'dimension1_level_value';
                            l_userind_org_value := ''''||c_userind_rec.org_level_value||'''';
                            l_userind_current_org_value := c_userind_rec.dimension1_level_value;
	                    END IF;
                        IF (l_sequence_no = 2) THEN
                            l_userind_org_name := 'dimension2_level_value';
                            l_userind_org_value := ''''||c_userind_rec.org_level_Value||'''';
                            l_userind_current_org_value := c_userind_rec.dimension2_level_value;
	                    END IF;
                        IF (l_sequence_no = 3) THEN
                            l_userind_org_name := 'dimension3_level_value';
                            l_userind_org_value := ''''||c_userind_rec.org_level_value||'''';
                            l_userind_current_org_value := c_userind_rec.dimension3_level_value;
	                    END IF;
                        IF (l_sequence_no = 4) THEN
                            l_userind_org_name := 'dimension4_level_value';
                            l_userind_org_value := ''''||c_userind_rec.org_level_value||'''';
                            l_userind_current_org_value := c_userind_rec.dimension4_level_value;
                        END IF;
                        IF (l_sequence_no = 5) THEN
                            l_userind_org_name := 'dimension5_level_value';
                            l_userind_org_value := ''''||c_userind_rec.org_level_value||'''';
                            l_userind_current_org_value := c_userind_rec.dimension5_level_value;
	                    END IF;
                        IF (l_sequence_no = 6) THEN
                            l_userind_org_name := 'dimension6_level_value';
                            l_userind_org_value := ''''||c_userind_rec.org_level_value||'''';
	                    END IF;
                        IF (l_sequence_no = 7) THEN
                            l_userind_org_name := 'dimension7_level_value';
                            l_userind_org_value := ''''||c_userind_rec.org_level_value||'''';
	                    END IF;
                        --IF ((l_return_status = 0) AND (l_reseq_userind_values.COUNT > 0)) THEN
                            /*l_sqlstmt3 := 'UPDATE bis_user_ind_selections SET '||
                                            l_reseq_userind_values(1).dim_level_name ||' = '||
 			                                NVL(l_reseq_userind_values(1).dim_level_value, 'NULL') ||
                                            ' ,'|| l_reseq_userind_values(2).dim_level_name ||' = ' ||
			                                NVL(l_reseq_userind_values(2).dim_level_value, 'NULL') ||
	                                        ' ,' || l_reseq_userind_values(3).dim_level_name ||' = '||
			                                NVL(l_reseq_userind_values(3).dim_level_value,'NULL') ||
	                                        ' ,' || l_reseq_userind_values(4).dim_level_name||' = ' ||
			                                NVL(l_reseq_userind_values(4).dim_level_value,'NULL') ||
	                                        ' ,' || l_reseq_userind_values(5).dim_level_name||' = ' ||
			                                NVL(l_reseq_userind_values(5).dim_level_value,'NULL') ||
	                                        ' ,' || l_reseq_userind_values(6).dim_level_name||' = ' ||
			                                NVL(l_reseq_userind_values(6).dim_level_value,'NULL') ||
	                                        ' ,' || l_reseq_userind_values(7).dim_level_name||' = ' ||
			                                NVL(l_reseq_userind_values(7).dim_level_value,'NULL') ||
			                                ' WHERE target_level_id = :1  ';*/
                        --meastmon 06/21/2001
                        --If it is null --> Update the record
                        --Else --> dont touch it (It could be a new user selection or the migration was done before)
                        IF (l_userind_current_org_value IS NULL AND l_userind_org_name IS NOT NULL) THEN
                            l_sqlstmt3 := 'UPDATE bis_user_ind_selections SET '||
                                          l_userind_org_name ||'= :1 ' ||
		    	                          ' WHERE ind_selection_id = :2 AND target_level_id = :3';
                            EXECUTE IMMEDIATE l_sqlstmt3 USING l_userind_org_value, c_userind_rec.ind_selection_id, c_rec.target_level_id;
 	                    END IF;
	               END LOOP;
                   --END IF;
                END IF;
            END IF;
        END IF;
        <<skip_record>>
        null;
    END LOOP;
    COMMIT;
    --rollback;

    x_return_Status := 'Success';
    x_return_code   := 0;
EXCEPTION
  WHEN OTHERS THEN
       ROLLBACK;
       x_return_Status := SQLERRM;
       x_return_code   := SQLCODE;
END MIGRATE_PERFORMANCE_MEASURES;



FUNCTION NEEDS_MIGRATION
(p_target_level_rec    IN BIS_TARGET_LEvel_PUB.TARGET_LEVEL_REC_TYPE
)
RETURN BOOLEAN
IS
  l_org_time_exists       BOOLEAN;
  l_org_id                NUMBER;
  l_time_id               NUMBER;
  l_dim1_id               NUMBER;
  l_dim2_id               NUMBER;
  l_dim3_id               NUMBER;
  l_dim4_id               NUMBER;
  l_dim5_id               NUMBER;
  l_dim6_id               NUMBER;
  l_dim7_id               NUMBER;

  CURSOR c_target_lvl_exists(cp_tl_rec    IN BIS_TARGET_LEvel_PUB.TARGET_LEVEL_REC_TYPE) IS
  SELECT COUNT(1) FROM bis_target_levels
  WHERE indicator_id = cp_tl_rec.measure_id
    AND ( cp_tl_rec.dimension1_level_id IS NULL OR
          dimension1_level_id = cp_tl_rec.dimension1_level_id
        )
    AND ( cp_tl_rec.dimension2_level_id IS NULL OR
          dimension2_level_id = cp_tl_rec.dimension2_level_id
        )
    AND ( cp_tl_rec.dimension3_level_id IS NULL OR
          dimension3_level_id = cp_tl_rec.dimension3_level_id
        )
    AND ( cp_tl_rec.dimension4_level_id IS NULL OR
          dimension4_level_id = cp_tl_rec.dimension4_level_id
        )
    AND ( cp_tl_rec.dimension5_level_id IS NULL OR
          dimension5_level_id = cp_tl_rec.dimension5_level_id
        )
    AND ( cp_tl_rec.dimension6_level_id IS NULL OR
          dimension6_level_id = cp_tl_rec.dimension6_level_id
        )
    AND ( cp_tl_rec.dimension7_level_id IS NULL OR
          dimension7_level_id = cp_tl_rec.dimension7_level_id
        );

  l_tl_count             NUMBER := 0;
  l_mig_target_level_rec BIS_PMF_MIGRATION_PVT.target_level_rec;
  l_target_level_rec     BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_REC_TYPE;
  l_reseq_dims           BIS_PMF_MIGRATION_PVT.resequenced_dimensions_Array;
  l_return_status        NUMBER;
  l_dim_count            NUMBER;

BEGIN

  -- Get the resequenced dimension levels which will be used to update
  -- the record to be migrated

  l_mig_target_level_rec.measure_id         := p_target_level_rec.measure_id;
  l_mig_target_level_rec.target_level_id    := p_target_level_rec.target_level_id;
  l_mig_target_level_rec.org_levelid        := p_target_level_rec.org_level_id;
  l_mig_target_level_rec.time_levelid       := p_target_level_rec.time_level_id;
  l_mig_target_level_rec.dimension1_levelid := p_target_level_rec.dimension1_level_id;
  l_mig_target_level_rec.dimension2_levelid := p_target_level_rec.dimension2_level_id;
  l_mig_target_level_Rec.dimension3_levelid := p_target_level_rec.dimension3_level_id;
  l_mig_target_level_rec.dimension4_levelid := p_target_level_rec.dimension4_level_id;
  l_mig_target_level_rec.dimension5_levelid := p_target_level_rec.dimension5_level_id;

  BIS_PMF_MIGRATION_PVT.resequence_dimension_levels
  (p_target_level_rec       => l_mig_target_level_rec
  ,x_resequenced_dimensions => l_reseq_dims
  ,x_dim_count              => l_dim_count
  ,x_return_status          => l_return_status
  );

  -- Create a target level record using the dimension 1 to 7 level ids

  l_target_level_rec.measure_id          := p_target_level_rec.measure_id;
  l_target_level_rec.dimension1_level_id := l_reseq_dims(1).dim_level_col_val;
  l_target_level_rec.dimension2_level_id := l_reseq_dims(2).dim_level_col_val;
  l_target_level_rec.dimension3_level_id := l_reseq_dims(3).dim_level_col_val;
  l_target_level_rec.dimension4_level_id := l_reseq_dims(4).dim_level_col_val;
  l_target_level_rec.dimension5_level_id := l_reseq_dims(5).dim_level_col_val;
  l_target_level_rec.dimension6_level_id := l_reseq_dims(6).dim_level_col_val;
  l_target_level_rec.dimension7_level_id := l_reseq_dims(7).dim_level_col_val;

  -- If the target level combination already exists then the target level should
  -- not be migrated

  IF (c_target_lvl_exists%ISOPEN) THEN
    CLOSE c_target_lvl_exists;
  END IF;

  OPEN c_target_lvl_exists(cp_tl_rec => l_target_level_rec);
  FETCH c_target_lvl_exists INTO l_tl_count;
  CLOSE c_target_lvl_exists;

  IF (l_tl_count <> 0) THEN
    RETURN FALSE;
  END IF;

  -- IF either org or time exists then return true here. As it should never
  -- happen that, only org got migrated and not time
  l_org_id := BIS_PMF_MIGRATION_PVT.GET_DIMENSION_ID(p_target_level_rec.org_level_id);
  l_time_id := BIS_PMF_MIGRATION_PVT.GET_DIMENSION_ID(p_target_level_rec.time_level_id);
  l_dim1_id := BIS_PMF_MIGRATION_PVT.GET_DIMENSION_ID(p_target_level_rec.dimension1_level_id);
  l_dim2_id := BIS_PMF_MIGRATION_PVT.GET_DIMENSION_ID(p_target_level_rec.dimension2_level_id);
  l_dim3_id := BIS_PMF_MIGRATION_PVT.GET_DIMENSION_ID(p_target_level_rec.dimension3_level_id);
  l_dim4_id := BIS_PMF_MIGRATION_PVT.GET_DIMENSION_ID(p_target_level_rec.dimension4_level_id);
  l_dim5_id := BIS_PMF_MIGRATION_PVT.GET_DIMENSION_ID(p_target_level_rec.dimension5_level_id);
  l_dim6_id := BIS_PMF_MIGRATION_PVT.GET_DIMENSION_ID(p_target_level_rec.dimension6_level_id);
  l_dim7_id := BIS_PMF_MIGRATION_PVT.GET_DIMENSION_ID(p_target_level_rec.dimension7_level_id);

  l_org_time_exists := TRUE;
  IF (l_org_id = l_dim1_id)
  THEN
      l_org_time_exists := FALSE;
      GOTO    returnfromproc;
  END IF;
  IF (l_org_id = l_dim2_id)
  THEN
      l_org_time_exists := FALSE;
      GOTO    returnfromproc;
  END IF;
  IF (l_org_id = l_dim3_id)
  THEN
      l_org_time_exists := FALSE;
      GOTO    returnfromproc;
  END IF;
  IF (l_org_id = l_dim4_id)
  THEN
      l_org_time_exists := FALSE;
      GOTO    returnfromproc;
  END IF;
  IF (l_org_id = l_dim5_id)
  THEN
      l_org_time_exists := FALSE;
      GOTO    returnfromproc;
  END IF;
  IF (l_org_id = l_dim6_id)
  THEN
      l_org_time_exists := FALSE;
      GOTO    returnfromproc;
  END IF;
  IF (l_org_id = l_dim7_id)
  THEN
      l_org_time_exists := FALSE;
      GOTO    returnfromproc;
  END IF;
  IF (l_time_id = l_dim1_id)
  THEN
      l_org_time_exists := FALSE;
      GOTO    returnfromproc;
  END IF;
  IF (l_time_id = l_dim2_id)
  THEN
      l_org_time_exists := FALSE;
      GOTO    returnfromproc;
  END IF;
  IF (l_time_id = l_dim3_id)
  THEN
      l_org_time_exists := FALSE;
      GOTO    returnfromproc;
  END IF;
  IF (l_time_id = l_dim4_id)
  THEN
      l_org_time_exists := FALSE;
      GOTO    returnfromproc;
  END IF;
  IF (l_time_id = l_dim5_id)
  THEN
      l_org_time_exists := FALSE;
      GOTO    returnfromproc;
  END IF;
  IF (l_time_id = l_dim6_id)
  THEN
      l_org_time_exists := FALSE;
      GOTO    returnfromproc;
  END IF;
  IF (l_time_id = l_dim7_id)
  THEN
      l_org_time_exists := FALSE;
      GOTO    returnfromproc;
  END IF;
  <<returnfromproc>>
  RETURN l_org_time_exists;
EXCEPTION
  WHEN OTHERS THEN
  IF (c_target_lvl_exists%ISOPEN) THEN
    CLOSE c_target_lvl_exists;
  END IF;
  RETURN FALSE;
END;
END BIS_PMF_MIGRATION_PVT;
 --SHOW ERRORS

/
