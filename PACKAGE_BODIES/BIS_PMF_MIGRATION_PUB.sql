--------------------------------------------------------
--  DDL for Package Body BIS_PMF_MIGRATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_PMF_MIGRATION_PUB" AS
/* $Header: BISPMIGB.pls 120.1 2005/10/21 07:08:36 ppandey noship $ */
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
REM |                                                                       |
REM | 21-MAR-05   ankagarw   bug#4235732 - changing count(*) to count(1)    |
REM | 19-OCT-2005 ppandey  Enh 4618419- SQL Literal Fix                   |
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
PROCEDURE RESEQUENCE_DIMENSION_LEVELS(
 p_target_level_rec       IN    BIS_PMF_MIGRATION_PUB.target_level_rec
,x_resequenced_dimensions OUT NOCOPY   BIS_PMF_MIGRATION_PUB.resequenced_dimensions_array
,x_dim_count		  OUT NOCOPY	NUMBER
,x_return_status          OUT NOCOPY   NUMBER
)
IS
  CURSOR c_dimcount(p_measure_id IN NUMBER) IS
  SELECT count(1) FROM
  bis_indicator_dimensions
  WHERE indicator_id = p_measure_id;
  l_reseuenced_dimensions_array         BIS_PMF_MIGRATION_PUB.resequenced_dimensions_array;
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
         x_resequenced_dimensions(1).dim_id            := bis_pmf_migration_pub.get_dimension_id (
							  p_target_level_rec.dimension1_levelid);
         x_Resequenced_dimensions(1).seq_no            := l_count;
      END IF;
      IF (l_count=2) THEN
         x_resequenced_dimensions(2).dim_level_col_val := p_target_level_rec.dimension2_levelid;
         x_resequenced_dimensions(2).dim_id            := bis_pmf_migration_pub.get_dimension_id (
							  p_target_level_rec.dimension2_levelid);
         x_Resequenced_dimensions(2).seq_no            := l_count;
      END IF;
      IF (l_count=3) THEN
         x_resequenced_dimensions(3).dim_level_col_val := p_target_level_rec.dimension3_levelid;
         x_resequenced_dimensions(3).dim_id            := bis_pmf_migration_pub.get_dimension_id (
							  p_target_level_rec.dimension3_levelid);
         x_Resequenced_dimensions(3).seq_no            := l_count;
      END IF;
      IF (l_count=4) THEN
         x_resequenced_dimensions(4).dim_level_col_val := p_target_level_rec.dimension4_levelid;
         x_resequenced_dimensions(4).dim_id            := bis_pmf_migration_pub.get_dimension_id (
							  p_target_level_rec.dimension4_levelid);
         x_Resequenced_dimensions(4).seq_no            := l_count;
      END IF;
      IF (l_count=5) THEN
         x_resequenced_dimensions(5).dim_level_col_val := p_target_level_rec.dimension5_levelid;
         x_resequenced_dimensions(5).dim_id            := bis_pmf_migration_pub.get_dimension_id (
							  p_target_level_rec.dimension5_levelid);
         x_Resequenced_dimensions(5).seq_no            := l_count;
      END IF;
  END LOOP;
  END IF;
  l_dimcount := l_dimcount + 1;
  IF (l_dimcount <= 7) THEN
     x_resequenced_dimensions(l_dimcount).dim_level_col := 'dimension'||l_dimcount||'_level_id';
     x_resequenced_dimensions(l_dimcount).dim_level_col_val := p_target_level_rec.org_levelid;
     x_resequenced_dimensions(l_dimcount).dim_id            := bis_pmf_migration_pub.get_dimension_id (
							       p_target_level_rec.org_levelid);
     x_Resequenced_dimensions(l_dimcount).seq_no            := l_dimcount;
     l_dimcount := l_dimcount + 1;
     x_resequenced_dimensions(l_dimcount).dim_level_col     := 'dimension'||l_dimcount||'_level_id';
     x_resequenced_dimensions(l_dimcount).dim_level_col_val := p_target_level_rec.time_levelid;
     x_resequenced_dimensions(l_dimcount).dim_id            := bis_pmf_migration_pub.get_dimension_id (
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
PROCEDURE RESEQUENCE_TARGET_LEVEL_VALUES(
 p_target_rec             IN    BIS_PMF_MIGRATION_PUB.target_rec
,p_dim_count              IN    NUMBER
,x_reseq_target_values    OUT NOCOPY   BIS_PMF_MIGRATION_PUB.reseq_target_values_arr
,x_return_Status	  OUT NOCOPY   NUMBER
)
IS
  l_dim_levelcount 	  NUMBER ;
BEGIN
  l_dim_levelcount := p_dim_count;
  IF(p_target_rec.org_level_value IS NOT NULL AND p_target_Rec.time_level_value IS NOT NULL) THEN
    l_dim_levelcount := l_dim_levelcount - 2;
  END IF;
  IF (l_dim_levelcount > 0) THEN
  FOR l_count IN 1..l_dim_levelcount LOOP
      x_reseq_target_values(l_count).target_level := 'dimension'||l_count||'_level_value';
      IF (l_count = 1) THEN
	 IF (p_target_rec.dimension1_level_value IS NOT NULL) THEN
            x_reseq_target_values(1).target_level_value :=
				''''||p_target_rec.dimension1_level_value||'''';
	 ELSE
	    x_reseq_target_values(1).target_level_value := p_target_rec.dimension1_level_Value;
	 END IF;
      END IF;
      IF (l_count = 2) THEN
	 IF (p_target_rec.dimension2_level_value IS NOT NULL) THEN
            x_reseq_target_values(2).target_level_value :=
				''''||p_target_rec.dimension2_level_value||'''';
	 ELSE
	    x_reseq_target_values(2).target_level_value := p_target_rec.dimension2_level_Value;
	 END IF;
      END IF;
      IF (l_count = 3) THEN
	 IF (p_target_rec.dimension3_level_value IS NOT NULL) THEN
            x_reseq_target_values(3).target_level_value :=
				''''||p_target_rec.dimension3_level_value||'''';
	 ELSE
	    x_reseq_target_values(3).target_level_value := p_target_rec.dimension3_level_Value;
	 END IF;
      END IF;
      IF (l_count = 4) THEN
	 IF (p_target_rec.dimension4_level_value IS NOT NULL) THEN
            x_reseq_target_values(4).target_level_value :=
				''''||p_target_rec.dimension4_level_value||'''';
	 ELSE
	    x_reseq_target_values(4).target_level_value := p_target_rec.dimension4_level_Value;
	 END IF;
      END IF;
      IF (l_count = 5) THEN
	 IF (p_target_rec.dimension5_level_value IS NOT NULL) THEN
            x_reseq_target_values(5).target_level_value :=
				''''||p_target_rec.dimension5_level_value||'''';
	 ELSE
	    x_reseq_target_values(5).target_level_value := p_target_rec.dimension5_level_Value;
	 END IF;
      END IF;
  END LOOP;
  END IF;
  l_dim_levelcount := l_dim_levelcount + 1;
  IF (l_dim_levelcount <= 7) THEN
     x_reseq_target_values(l_dim_levelcount).target_level :=
                          'dimension'||l_dim_levelcount||'_level_value';
     IF (p_target_rec.org_level_value IS NOT NULL) THEN
     x_reseq_target_values(l_dim_levelcount).target_level_value :=
		''''||p_target_rec.org_level_value||'''';
     ELSE
     x_reseq_target_values(l_dim_levelcount).target_level_value := p_target_rec.org_level_value;
     END IF;
     l_dim_levelcount := l_dim_levelcount + 1;
     x_reseq_target_values(l_dim_levelcount).target_level :=
			 'dimension'||l_dim_levelcount||'_level_value';
     IF (p_target_rec.time_level_value IS NOT NULL) THEN
     x_reseq_target_values(l_dim_levelcount).target_level_value :=
		''''||p_target_rec.time_level_value||'''';
     ELSE
     x_reseq_target_values(l_dim_levelcount).target_level_value := p_target_rec.time_level_value;
     END IF;
     l_dim_levelcount := l_dim_levelcount +1;
     FOR l_count IN l_dim_levelcount..7 LOOP
     x_reseq_target_values(l_dim_levelcount).target_level :=
			 'dimension'||l_dim_levelcount||'_level_value';
     x_reseq_target_values(l_Dim_levelcount).target_level_value := NULL;
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
p_measure_short_name IN    VARCHAR2 default NULL,
x_return_status      OUT NOCOPY   VARCHAR2
)
IS
  CURSOR c_targetlvls  IS
  SELECT target_level_id, indicator_id, short_name
        ,time_level_id, org_level_id, dimension1_level_id
        ,dimension2_level_id, dimension3_level_id, dimension4_level_id
        ,dimension5_level_id
  FROM bis_target_levels;
  CURSOR c_targetlvl_values(p_target_level_id IN NUMBER) IS
  SELECT target_id, org_level_value, time_level_value
        ,dimension1_level_value, dimension2_level_value, dimension3_level_value
	,dimension4_level_value, dimension5_level_value
  FROM bis_target_values
  WHERE target_level_id = p_target_level_id;
  l_target_level_rec		BIS_PMF_MIGRATION_PUB.target_level_rec;
  l_reseq_dims                  BIS_PMF_MIGRATION_PUB.resequenced_dimensions_Array;
  l_target_rec			BIS_PMF_MIGRATION_PUB.target_rec;
  l_reseq_target_values		BIS_PMF_MIGRATION_PUB.reseq_target_values_arr;
  l_return_status               NUMBER;
  l_sqlstmt 			VARCHAR2(32000);
  l_sqlstmt1			VARCHAR2(32000);
  l_count			NUMBER := 1;
  l_dummy_value 		NUMBER := 990;
  l_dimlevel_count		NUMBER;
  l_dim_count			NUMBER;
  l_dim_levelvalue_count	NUMBER;
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
       BIS_PMF_MIGRATION_PUB.resequence_dimension_levels
         		     (p_target_level_rec => l_target_level_rec
			     ,x_resequenced_dimensions => l_reseq_dims
			     ,x_dim_count     => l_dim_count
                             ,x_return_status => l_return_status
        		     );
       l_dummy_value  := 990;
       IF (l_return_status = 0 AND l_reseq_dims.COUNT>0) THEN
         --First update the dimension sequences
         FOR l_count IN 1..l_reseq_dims.COUNT LOOP
             IF (l_reseq_dims(l_count).dim_id IS NULL) THEN
                EXIT;
	     ELSE
                UPDATE bis_indicator_dimensions
                SET sequence_no = l_dummy_value
  	        WHERE dimension_id=l_Reseq_dims(l_count).dim_id AND
                      indicator_id=c_rec.indicator_id;
	     END IF;
	     l_dummy_value := l_dummy_value + 1;
         END LOOP;
         FOR l_count IN 1..l_reseq_dims.COUNT LOOP
             IF (l_reseq_dims(l_count).dim_id IS NULL) THEN
                EXIT;
	     ELSE
                UPDATE bis_indicator_dimensions
                SET    sequence_no= l_reseq_dims(l_count).seq_no
                WHERE  dimension_id = l_reseq_dims(l_count).dim_id AND
                       indicator_id = c_Rec.indicator_id;
	        END IF;
         END LOOP;
	 IF (l_dim_count = l_dimlevel_count) THEN
            l_sqlstmt := 'UPDATE bis_target_levels SET ' ||
                        l_reseq_dims(1).dim_level_col ||' = :1' ||
                     ' , '||l_reseq_dims(2).dim_level_col ||' = :2'||
                     ' , '||l_reseq_dims(3).dim_level_col ||' = :3'||
                     ' , '||l_reseq_dims(4).dim_level_col ||' = :4'||
              	     ' , '||l_reseq_dims(5).dim_level_col ||' = :5'||
                     ' , '||l_reseq_dims(6).dim_level_col ||' = :6'||
                     ' , '||l_reseq_dims(7).dim_level_col ||' = :7'||
		     '  WHERE target_level_id =:8';
       EXECUTE IMMEDIATE l_sqlstmt USING to_char(l_reseq_dims(1).dim_level_col_val), to_char(l_reseq_dims(2).dim_level_col_val),
       to_char(l_reseq_dims(3).dim_level_col_val), to_char(l_reseq_dims(4).dim_level_col_val), to_char(l_reseq_dims(5).dim_level_col_val),
       to_char(l_reseq_dims(6).dim_level_col_val), to_char(l_reseq_dims(7).dim_level_col_val),
       c_rec.target_level_id;
	  l_count := 0;
          FOR c_targetrec IN c_targetlvl_values(c_rec.target_level_id) LOOP
               l_count := l_count+1;
               l_target_rec.org_level_value := c_targetrec.org_level_value;
	       l_target_rec.time_level_value := c_targetrec.time_level_value;
	       l_target_rec.dimension1_level_value := c_targetrec.dimension1_level_value;
               l_target_rec.dimension2_level_value := c_targetrec.dimension2_level_value;
               l_target_rec.dimension3_level_value := c_targetrec.dimension3_level_value;
               l_target_rec.dimension4_level_value := c_targetrec.dimension4_level_value;
               l_Target_rec.dimension5_level_value := c_targetrec.dimension5_level_value;
               BIS_PMF_MIGRATION_PUB.resequence_target_level_values(
               		p_target_rec => l_target_rec
		       ,p_dim_count  => l_dim_count
		       ,x_reseq_target_values => l_reseq_target_values
		       ,x_return_Status       => l_return_status
	       );
              IF ((l_return_status = 0) AND (l_reseq_target_values.COUNT > 0)) THEN
                 l_sqlstmt1 := 'UPDATE bis_target_values SET '||
                            l_reseq_target_values(1).target_level ||' = :1'||
                      ' ,'|| l_Reseq_target_values(2).target_level ||' = :2' ||
                      ' ,' || l_Reseq_target_values(3).target_level||' = :3'||
                      ' ,' || l_Reseq_target_values(4).target_level||' = :4' ||
                      ' ,' || l_Reseq_target_values(5).target_level||' = :5' ||
                      ' ,' || l_Reseq_target_values(6).target_level||' = :6' ||
                      ' ,' || l_Reseq_target_values(7).target_level||' = :7' ||
			' WHERE target_level_id = :8  AND target_id = :9';
                  EXECUTE IMMEDIATE l_sqlstmt1 USING l_reseq_target_values(1).target_level_value, l_reseq_target_values(2).target_level_value,
                  l_reseq_target_values(3).target_level_value, l_reseq_target_values(4).target_level_value, l_reseq_target_values(5).target_level_value,
                  l_reseq_target_values(6).target_level_value, l_reseq_target_values(7).target_level_value, c_rec.target_level_id, c_targetrec.target_id;
 	      END IF;
            END LOOP;
          END IF;
          l_count := l_count+1;
     END IF;
  END LOOP;
  COMMIT;
  x_return_Status := 0;
EXCEPTION
  WHEN OTHERS THEN
       ROLLBACK;
       x_return_Status := SQLCODE;
END MIGRATE_PERFORMANCE_MEASURES;

END BIS_PMF_MIGRATION_PUB;
-- SHOW ERRORS

/
