--------------------------------------------------------
--  DDL for Package Body CSI_ORGANIZATION_UNIT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_ORGANIZATION_UNIT_PVT" AS
/* $Header: csivoub.pls 120.1 2005/08/16 10:50:01 sguthiva noship $ */

g_pkg_name       VARCHAR2(30) := 'csi_organization_unit_pvt';
g_expire_flag    VARCHAR2(1) := 'N';


/*----------------------------------------------------------*/
/* Procedure name:  Initialize_ou_rec_no_dump               */
/* Description : This gets the first record from history    */
/*                                                          */
/*----------------------------------------------------------*/

PROCEDURE Initialize_ou_rec_no_dump
(
 x_ou_rec               IN OUT NOCOPY  csi_datastructures_pub.org_units_header_rec,
 p_ou_id                IN      NUMBER,
 x_first_no_dump        IN OUT NOCOPY  DATE
) IS

CURSOR Int_no_dump(p_ou_id IN NUMBER ) IS
SELECT      creation_date,
            NEW_operating_unit_id,
            NEW_relationship_type_code,
            NEW_active_start_date,
            NEW_active_end_date,
            NEW_context,
            NEW_attribute1 ,
            NEW_attribute2,
            NEW_attribute3,
            NEW_attribute4,
            NEW_attribute5,
            NEW_attribute6,
            NEW_attribute7,
            NEW_attribute8,
            NEW_attribute9,
            NEW_attribute10,
            NEW_attribute11,
            NEW_attribute12,
            NEW_attribute13,
            NEW_attribute14,
            NEW_attribute15
FROM     csi_i_org_assignments_h
WHERE    instance_ou_id = p_ou_id
ORDER BY creation_date;

BEGIN

  FOR C1 IN Int_no_dump(p_ou_id)
  LOOP
     IF Int_no_dump%ROWCOUNT = 1 THEN
        x_first_no_dump                  := C1.creation_date;
        x_ou_rec.operating_unit_id       := C1.NEW_operating_unit_id;
        x_ou_rec.relationship_type_code  := C1.NEW_relationship_type_code;
        x_ou_rec.active_start_date       := C1.NEW_active_start_date;
        x_ou_rec.active_end_date         := C1.NEW_active_end_date;
        x_ou_rec.context                 := C1.NEW_context;
        x_ou_rec.attribute1              := C1.NEW_attribute1;
        x_ou_rec.attribute2              := C1.NEW_attribute2;
        x_ou_rec.attribute3              := C1.NEW_attribute3;
        x_ou_rec.attribute4              := C1.NEW_attribute4;
        x_ou_rec.attribute5              := C1.NEW_attribute5;
        x_ou_rec.attribute6              := C1.NEW_attribute6;
        x_ou_rec.attribute7              := C1.NEW_attribute7;
        x_ou_rec.attribute8              := C1.NEW_attribute8;
        x_ou_rec.attribute9              := C1.NEW_attribute9;
        x_ou_rec.attribute10             := C1.NEW_attribute10;
        x_ou_rec.attribute11             := C1.NEW_attribute11;
        x_ou_rec.attribute12             := C1.NEW_attribute12;
        x_ou_rec.attribute13             := C1.NEW_attribute13;
        x_ou_rec.attribute14             := C1.NEW_attribute14;
        x_ou_rec.attribute15             := C1.NEW_attribute15;
     ELSE
        EXIT;
     END IF;
  END LOOP;
END Initialize_ou_rec_no_dump;



/*----------------------------------------------------------*/
/* Procedure name:  Initialize_ou_rec                      */
/* Description : This procudure recontructs the record      */
/*                 from the history                         */
/*----------------------------------------------------------*/

PROCEDURE Initialize_ou_rec
(
 x_ou_rec               IN OUT NOCOPY  csi_datastructures_pub.org_units_header_rec,
 p_ou_h_id              IN      NUMBER,
 x_nearest_full_dump    IN OUT NOCOPY  DATE
) IS

CURSOR Int_nearest_full_dump(p_ou_hist_id IN NUMBER ) IS
SELECT      creation_date,
            NEW_operating_unit_id,
            NEW_relationship_type_code,
            NEW_active_start_date,
            NEW_active_end_date,
            NEW_context,
            NEW_attribute1 ,
            NEW_attribute2,
            NEW_attribute3,
            NEW_attribute4,
            NEW_attribute5,
            NEW_attribute6,
            NEW_attribute7,
            NEW_attribute8,
            NEW_attribute9,
            NEW_attribute10,
            NEW_attribute11,
            NEW_attribute12,
            NEW_attribute13,
            NEW_attribute14,
            NEW_attribute15
FROM    csi_i_org_assignments_h
WHERE   instance_ou_history_id = p_ou_hist_id
AND full_dump_flag = 'Y';

BEGIN

  FOR C1 IN Int_nearest_full_dump(p_ou_h_id)
  LOOP
        x_nearest_full_dump              := C1.creation_date;
        x_ou_rec.operating_unit_id       := C1.NEW_operating_unit_id;
        x_ou_rec.relationship_type_code  := C1.NEW_relationship_type_code;
        x_ou_rec.active_start_date       := C1.NEW_active_start_date;
        x_ou_rec.active_end_date         := C1.NEW_active_end_date;
        x_ou_rec.context                 := C1.NEW_context;
        x_ou_rec.attribute1              := C1.NEW_attribute1;
        x_ou_rec.attribute2              := C1.NEW_attribute2;
        x_ou_rec.attribute3              := C1.NEW_attribute3;
        x_ou_rec.attribute4              := C1.NEW_attribute4;
        x_ou_rec.attribute5              := C1.NEW_attribute5;
        x_ou_rec.attribute6              := C1.NEW_attribute6;
        x_ou_rec.attribute7              := C1.NEW_attribute7;
        x_ou_rec.attribute8              := C1.NEW_attribute8;
        x_ou_rec.attribute9              := C1.NEW_attribute9;
        x_ou_rec.attribute10             := C1.NEW_attribute10;
        x_ou_rec.attribute11             := C1.NEW_attribute11;
        x_ou_rec.attribute12             := C1.NEW_attribute12;
        x_ou_rec.attribute13             := C1.NEW_attribute13;
        x_ou_rec.attribute14             := C1.NEW_attribute14;
        x_ou_rec.attribute15             := C1.NEW_attribute15;
  END LOOP;
END Initialize_ou_rec ;



/*----------------------------------------------------------*/
/* Procedure name:  Construct_ou_from_hist                  */
/* Description : This procudure recontructs the record      */
/*                 from the history                         */
/*----------------------------------------------------------*/

PROCEDURE Construct_ou_from_hist
 ( x_ou_tbl           IN OUT NOCOPY      csi_datastructures_pub.org_units_header_tbl,
   p_time_stamp       IN     DATE
 ) IS

 l_nearest_full_dump    DATE := p_time_stamp;
 l_ou_hist_id          NUMBER;
 l_ou_tbl              csi_datastructures_pub.org_units_header_tbl;
 l_ou_count            NUMBER := 0;
 --
 Process_next          EXCEPTION;

 CURSOR get_nearest_full_dump(p_inst_ou_id IN NUMBER ,p_time IN DATE) IS
 SELECT MAX(instance_ou_history_id)
 FROM csi_i_org_assignments_h
 WHERE creation_date <= p_time
 AND  instance_ou_id = p_inst_ou_id
 AND  full_dump_flag = 'Y';


 CURSOR get_ou_hist(p_inst_ou_id IN NUMBER ,
                   p_nearest_full_dump IN DATE,
                   p_time IN DATE ) IS
 SELECT
    OLD_OPERATING_UNIT_ID,
    NEW_OPERATING_UNIT_ID ,
    OLD_RELATIONSHIP_TYPE_CODE ,
    NEW_RELATIONSHIP_TYPE_CODE ,
    OLD_ACTIVE_START_DATE,
    NEW_ACTIVE_START_DATE,
    OLD_ACTIVE_END_DATE  ,
    NEW_ACTIVE_END_DATE  ,
    OLD_CONTEXT      ,
    NEW_CONTEXT      ,
    OLD_ATTRIBUTE1   ,
    NEW_ATTRIBUTE1   ,
    OLD_ATTRIBUTE2   ,
    NEW_ATTRIBUTE2   ,
    OLD_ATTRIBUTE3   ,
    NEW_ATTRIBUTE3   ,
    OLD_ATTRIBUTE4   ,
    NEW_ATTRIBUTE4   ,
    OLD_ATTRIBUTE5   ,
    NEW_ATTRIBUTE5   ,
    OLD_ATTRIBUTE6   ,
    NEW_ATTRIBUTE6   ,
    OLD_ATTRIBUTE7   ,
    NEW_ATTRIBUTE7   ,
    OLD_ATTRIBUTE8   ,
    NEW_ATTRIBUTE8   ,
    OLD_ATTRIBUTE9   ,
    NEW_ATTRIBUTE9   ,
    OLD_ATTRIBUTE10  ,
    NEW_ATTRIBUTE10  ,
    OLD_ATTRIBUTE11  ,
    NEW_ATTRIBUTE11  ,
    OLD_ATTRIBUTE12  ,
    NEW_ATTRIBUTE12  ,
    OLD_ATTRIBUTE13  ,
    NEW_ATTRIBUTE13  ,
    OLD_ATTRIBUTE14  ,
    NEW_ATTRIBUTE14  ,
    OLD_ATTRIBUTE15  ,
    NEW_ATTRIBUTE15
 FROM CSI_I_ORG_ASSIGNMENTS_H
 WHERE creation_date <= p_time
 AND creation_date >= p_nearest_full_dump
 AND instance_ou_id = p_inst_ou_id
 ORDER BY creation_date;

 l_time_stamp   DATE := p_time_stamp;

BEGIN
  l_ou_tbl := x_ou_tbl;
  IF l_ou_tbl.COUNT > 0 THEN
     FOR i IN l_ou_tbl.FIRST..l_ou_tbl.LAST LOOP
     BEGIN
        OPEN get_nearest_full_dump(l_ou_tbl(i).instance_ou_id,p_time_stamp);
        FETCH get_nearest_full_dump INTO l_ou_hist_id;
        CLOSE get_nearest_full_dump;

        IF l_ou_hist_id IS NOT NULL THEN
           Initialize_ou_rec( l_ou_tbl(i), l_ou_hist_id ,l_nearest_full_dump);
        ELSE
           Initialize_ou_rec_no_dump(l_ou_tbl(i), l_ou_tbl(i).instance_ou_id,l_time_stamp);

           l_nearest_full_dump :=  l_time_stamp;
           -- If the user chooses a date before the creation date of the instance
           -- then raise an error
           IF p_time_stamp < l_time_stamp THEN
              -- Messages Commented for bug 2423342. Records that do not qualify should get deleted.
              -- FND_MESSAGE.SET_NAME('CSI','CSI_H_DATE_BEFORE_CRE_DATE');
              -- FND_MESSAGE.SET_TOKEN('CREATION_DATE',to_char(l_time_stamp, 'DD-MON-YYYY HH24:MI:SS'));
              -- FND_MESSAGE.SET_TOKEN('USER_DATE',to_char(p_time_stamp, 'DD-MON-YYYY HH24:MI:SS'));
              -- FND_MSG_PUB.Add;
              l_ou_tbl.DELETE(i);
              RAISE Process_next;
           END IF;
        END IF;

      FOR C2 IN get_ou_hist(l_ou_tbl(i).instance_ou_id ,l_nearest_full_dump,p_time_stamp ) LOOP

       IF (C2.OLD_OPERATING_UNIT_ID IS NULL AND C2.NEW_OPERATING_UNIT_ID IS NOT NULL)
       OR (C2.OLD_OPERATING_UNIT_ID IS NOT NULL AND C2.NEW_OPERATING_UNIT_ID IS NULL)
       OR (C2.OLD_OPERATING_UNIT_ID <> C2.NEW_OPERATING_UNIT_ID) THEN
            l_ou_tbl(i).OPERATING_UNIT_ID := C2.NEW_OPERATING_UNIT_ID;
       END IF;

       IF (C2.OLD_RELATIONSHIP_TYPE_CODE IS NULL AND C2.NEW_RELATIONSHIP_TYPE_CODE IS NOT NULL)
       OR (C2.OLD_RELATIONSHIP_TYPE_CODE IS NOT NULL AND C2.NEW_RELATIONSHIP_TYPE_CODE IS NULL)
       OR (C2.OLD_RELATIONSHIP_TYPE_CODE <> C2.NEW_RELATIONSHIP_TYPE_CODE) THEN
            l_ou_tbl(i).RELATIONSHIP_TYPE_CODE := C2.NEW_RELATIONSHIP_TYPE_CODE;
       END IF;


       IF (C2.OLD_ACTIVE_START_DATE IS NULL AND C2.NEW_ACTIVE_START_DATE IS NOT NULL)
       OR (C2.OLD_ACTIVE_START_DATE IS NOT NULL AND C2.NEW_ACTIVE_START_DATE IS NULL)
       OR (C2.OLD_ACTIVE_START_DATE <> C2.NEW_ACTIVE_START_DATE) THEN
            l_ou_tbl(i).ACTIVE_START_DATE := C2.NEW_ACTIVE_START_DATE;
       END IF;


       IF (C2.OLD_ACTIVE_END_DATE IS NULL AND C2.NEW_ACTIVE_END_DATE IS NOT NULL)
       OR (C2.OLD_ACTIVE_END_DATE IS NOT NULL AND C2.NEW_ACTIVE_END_DATE IS NULL)
       OR (C2.OLD_ACTIVE_END_DATE <> C2.NEW_ACTIVE_END_DATE) THEN
            l_ou_tbl(i).ACTIVE_END_DATE := C2.NEW_ACTIVE_END_DATE;
       END IF;


       IF (C2.OLD_CONTEXT IS NULL AND C2.NEW_CONTEXT IS NOT NULL)
       OR (C2.OLD_CONTEXT IS NOT NULL AND C2.NEW_CONTEXT IS NULL)
       OR (C2.OLD_CONTEXT <> C2.NEW_CONTEXT) THEN
            l_ou_tbl(i).CONTEXT := C2.NEW_CONTEXT;
       END IF;

       IF (C2.OLD_ATTRIBUTE1 IS NULL AND C2.NEW_ATTRIBUTE1 IS NOT NULL)
       OR (C2.OLD_ATTRIBUTE1 IS NOT NULL AND C2.NEW_ATTRIBUTE1 IS NULL)
       OR (C2.OLD_ATTRIBUTE1 <> C2.NEW_ATTRIBUTE1) THEN
            l_ou_tbl(i).ATTRIBUTE1 := C2.NEW_ATTRIBUTE1;
       END IF;

       IF (C2.OLD_ATTRIBUTE2 IS NULL AND C2.NEW_ATTRIBUTE2 IS NOT NULL)
       OR (C2.OLD_ATTRIBUTE2 IS NOT NULL AND C2.NEW_ATTRIBUTE2 IS NULL)
       OR (C2.OLD_ATTRIBUTE2 <> C2.NEW_ATTRIBUTE2) THEN
            l_ou_tbl(i).ATTRIBUTE2 := C2.NEW_ATTRIBUTE2;
       END IF;

       IF (C2.OLD_ATTRIBUTE3 IS NULL AND C2.NEW_ATTRIBUTE3 IS NOT NULL)
       OR (C2.OLD_ATTRIBUTE3 IS NOT NULL AND C2.NEW_ATTRIBUTE3 IS NULL)
       OR (C2.OLD_ATTRIBUTE3 <> C2.NEW_ATTRIBUTE3) THEN
            l_ou_tbl(i).ATTRIBUTE3 := C2.NEW_ATTRIBUTE3;
       END IF;

       IF (C2.OLD_ATTRIBUTE4 IS NULL AND C2.NEW_ATTRIBUTE4 IS NOT NULL)
       OR (C2.OLD_ATTRIBUTE4 IS NOT NULL AND C2.NEW_ATTRIBUTE4 IS NULL)
       OR (C2.OLD_ATTRIBUTE4 <> C2.NEW_ATTRIBUTE4) THEN
            l_ou_tbl(i).ATTRIBUTE4 := C2.NEW_ATTRIBUTE4;
       END IF;


       IF (C2.OLD_ATTRIBUTE5 IS NULL AND C2.NEW_ATTRIBUTE5 IS NOT NULL)
       OR (C2.OLD_ATTRIBUTE5 IS NOT NULL AND C2.NEW_ATTRIBUTE5 IS NULL)
       OR (C2.OLD_ATTRIBUTE5 <> C2.NEW_ATTRIBUTE5) THEN
            l_ou_tbl(i).ATTRIBUTE5 := C2.NEW_ATTRIBUTE5;
       END IF;


       IF (C2.OLD_ATTRIBUTE6 IS NULL AND C2.NEW_ATTRIBUTE6 IS NOT NULL)
       OR (C2.OLD_ATTRIBUTE6 IS NOT NULL AND C2.NEW_ATTRIBUTE6 IS NULL)
       OR (C2.OLD_ATTRIBUTE6 <> C2.NEW_ATTRIBUTE6) THEN
            l_ou_tbl(i).ATTRIBUTE6 := C2.NEW_ATTRIBUTE6;
       END IF;

       IF (C2.OLD_ATTRIBUTE7 IS NULL AND C2.NEW_ATTRIBUTE7 IS NOT NULL)
       OR (C2.OLD_ATTRIBUTE7 IS NOT NULL AND C2.NEW_ATTRIBUTE7 IS NULL)
       OR (C2.OLD_ATTRIBUTE7 <> C2.NEW_ATTRIBUTE7) THEN
            l_ou_tbl(i).ATTRIBUTE7 := C2.NEW_ATTRIBUTE7;
       END IF;

       IF (C2.OLD_ATTRIBUTE8 IS NULL AND C2.NEW_ATTRIBUTE8 IS NOT NULL)
       OR (C2.OLD_ATTRIBUTE8 IS NOT NULL AND C2.NEW_ATTRIBUTE8 IS NULL)
       OR (C2.OLD_ATTRIBUTE8 <> C2.NEW_ATTRIBUTE8) THEN
            l_ou_tbl(i).ATTRIBUTE8 := C2.NEW_ATTRIBUTE8;
       END IF;

       IF (C2.OLD_ATTRIBUTE9 IS NULL AND C2.NEW_ATTRIBUTE9 IS NOT NULL)
       OR (C2.OLD_ATTRIBUTE9 IS NOT NULL AND C2.NEW_ATTRIBUTE9 IS NULL)
       OR (C2.OLD_ATTRIBUTE9 <> C2.NEW_ATTRIBUTE9) THEN
            l_ou_tbl(i).ATTRIBUTE3 := C2.NEW_ATTRIBUTE3;
       END IF;


       IF (C2.OLD_ATTRIBUTE10 IS NULL AND C2.NEW_ATTRIBUTE10 IS NOT NULL)
       OR (C2.OLD_ATTRIBUTE10 IS NOT NULL AND C2.NEW_ATTRIBUTE10 IS NULL)
       OR (C2.OLD_ATTRIBUTE10 <> C2.NEW_ATTRIBUTE10) THEN
            l_ou_tbl(i).ATTRIBUTE10 := C2.NEW_ATTRIBUTE10;
       END IF;



       IF (C2.OLD_ATTRIBUTE11 IS NULL AND C2.NEW_ATTRIBUTE11 IS NOT NULL)
       OR (C2.OLD_ATTRIBUTE11 IS NOT NULL AND C2.NEW_ATTRIBUTE11 IS NULL)
       OR (C2.OLD_ATTRIBUTE11 <> C2.NEW_ATTRIBUTE11) THEN
            l_ou_tbl(i).ATTRIBUTE11 := C2.NEW_ATTRIBUTE11;
       END IF;

       IF (C2.OLD_ATTRIBUTE12 IS NULL AND C2.NEW_ATTRIBUTE12 IS NOT NULL)
       OR (C2.OLD_ATTRIBUTE12 IS NOT NULL AND C2.NEW_ATTRIBUTE12 IS NULL)
       OR (C2.OLD_ATTRIBUTE12 <> C2.NEW_ATTRIBUTE12) THEN
            l_ou_tbl(i).ATTRIBUTE12 := C2.NEW_ATTRIBUTE12;
       END IF;


       IF (C2.OLD_ATTRIBUTE13 IS NULL AND C2.NEW_ATTRIBUTE13 IS NOT NULL)
       OR (C2.OLD_ATTRIBUTE13 IS NOT NULL AND C2.NEW_ATTRIBUTE13 IS NULL)
       OR (C2.OLD_ATTRIBUTE13 <> C2.NEW_ATTRIBUTE13) THEN
            l_ou_tbl(i).ATTRIBUTE13 := C2.NEW_ATTRIBUTE13;
       END IF;


       IF (C2.OLD_ATTRIBUTE14 IS NULL AND C2.NEW_ATTRIBUTE14 IS NOT NULL)
       OR (C2.OLD_ATTRIBUTE14 IS NOT NULL AND C2.NEW_ATTRIBUTE14 IS NULL)
       OR (C2.OLD_ATTRIBUTE14 <> C2.NEW_ATTRIBUTE14) THEN
            l_ou_tbl(i).ATTRIBUTE14 := C2.NEW_ATTRIBUTE14;
       END IF;

       IF (C2.OLD_ATTRIBUTE15 IS NULL AND C2.NEW_ATTRIBUTE15 IS NOT NULL)
       OR (C2.OLD_ATTRIBUTE15 IS NOT NULL AND C2.NEW_ATTRIBUTE15 IS NULL)
       OR (C2.OLD_ATTRIBUTE15 <> C2.NEW_ATTRIBUTE15) THEN
            l_ou_tbl(i).ATTRIBUTE15 := C2.NEW_ATTRIBUTE15;
       END IF;

      END LOOP;
     EXCEPTION
        WHEN Process_next THEN
           NULL;
     END;
    END LOOP;
    --
    x_ou_tbl.DELETE;
    IF l_ou_tbl.count > 0 THEN
       FOR ou_row in l_ou_tbl.FIRST .. l_ou_tbl.LAST
       LOOP
          IF l_ou_tbl.EXISTS(ou_row) THEN
             l_ou_count := l_ou_count + 1;
             x_ou_tbl(l_ou_count) := l_ou_tbl(ou_row);
          END IF;
       END LOOP;
    END IF;
  END IF;
END Construct_ou_from_hist;

/*----------------------------------------------------------*/
/* Procedure name:  Resolve_id_columns                      */
/* Description : This procudure gets the descriptions for   */
/*               id columns                                 */
/*----------------------------------------------------------*/

PROCEDURE  Resolve_id_columns
            (p_org_units_header_tbl  IN OUT NOCOPY   csi_datastructures_pub.org_units_header_tbl)

IS

  l_rltn_lookup_type VARCHAR2(30) := 'CSI_IO_RELATIONSHIP_TYPE_CODE';

   BEGIN

        FOR tab_row in p_org_units_header_tbl.FIRST..p_org_units_header_tbl.LAST
           LOOP

           BEGIN
             SELECT name
             INTO   p_org_units_header_tbl(tab_row).operating_unit_name
             FROM   hr_operating_units
             WHERE  organization_id = p_org_units_header_tbl(tab_row).operating_unit_id;
           EXCEPTION
             WHEN OTHERS THEN
               NULL;
           END;

--type_name

           BEGIN
             SELECT   meaning
             INTO     p_org_units_header_tbl(tab_row).relationship_type_name
             FROM     csi_lookups
             WHERE    lookup_code = p_org_units_header_tbl(tab_row).relationship_type_code
             AND      lookup_type = l_rltn_lookup_type;
           EXCEPTION
             WHEN OTHERS THEN
               NULL;
           END;
        END LOOP;
END Resolve_id_columns;

/*----------------------------------------------------------*/
/* Procedure name:  Define_ou_Columns                       */
/* Description : This procudure defines the columns         */
/*                        for the Dynamic SQL               */
/*----------------------------------------------------------*/

PROCEDURE Define_ou_Columns
(  p_get_ou_cursor_id      IN   NUMBER
  ) IS
  l_ou_rec            csi_datastructures_pub.org_units_header_rec;
BEGIN
     dbms_sql.define_column(p_get_ou_cursor_id, 1, l_ou_rec.instance_ou_id);
     dbms_sql.define_column(p_get_ou_cursor_id, 2, l_ou_rec.instance_id);
     dbms_sql.define_column(p_get_ou_cursor_id, 3, l_ou_rec.operating_unit_id);
     dbms_sql.define_column(p_get_ou_cursor_id, 4, l_ou_rec.relationship_type_code,30);
     dbms_sql.define_column(p_get_ou_cursor_id, 5, l_ou_rec.active_start_date);
     dbms_sql.define_column(p_get_ou_cursor_id, 6, l_ou_rec.active_end_date);
     dbms_sql.define_column(p_get_ou_cursor_id, 7, l_ou_rec.context,30);
     dbms_sql.define_column(p_get_ou_cursor_id, 8, l_ou_rec.attribute1,150);
     dbms_sql.define_column(p_get_ou_cursor_id, 9, l_ou_rec.attribute2,150);
     dbms_sql.define_column(p_get_ou_cursor_id, 10, l_ou_rec.attribute3,150);
     dbms_sql.define_column(p_get_ou_cursor_id, 11, l_ou_rec.attribute4,150);
     dbms_sql.define_column(p_get_ou_cursor_id, 12, l_ou_rec.attribute5,150);
     dbms_sql.define_column(p_get_ou_cursor_id, 13, l_ou_rec.attribute6,150);
     dbms_sql.define_column(p_get_ou_cursor_id, 14, l_ou_rec.attribute7,150);
     dbms_sql.define_column(p_get_ou_cursor_id, 15, l_ou_rec.attribute8,150);
     dbms_sql.define_column(p_get_ou_cursor_id, 16, l_ou_rec.attribute9,150);
     dbms_sql.define_column(p_get_ou_cursor_id, 17, l_ou_rec.attribute10,150);
     dbms_sql.define_column(p_get_ou_cursor_id, 18, l_ou_rec.attribute11,150);
     dbms_sql.define_column(p_get_ou_cursor_id, 19, l_ou_rec.attribute12,150);
     dbms_sql.define_column(p_get_ou_cursor_id, 20, l_ou_rec.attribute13,150);
     dbms_sql.define_column(p_get_ou_cursor_id, 21, l_ou_rec.attribute14,150);
     dbms_sql.define_column(p_get_ou_cursor_id, 22, l_ou_rec.attribute15,150);
     dbms_sql.define_column(p_get_ou_cursor_id, 28, l_ou_rec.object_version_number);
END Define_ou_Columns;


/*----------------------------------------------------------*/
/* Procedure name:  Get_ou_Column_Values                    */
/* Description : This procudure gets the column values      */
/*                        for the Dynamic SQL               */
/*----------------------------------------------------------*/

PROCEDURE Get_ou_Column_Values
   ( p_get_ou_cursor_id      IN       NUMBER,
     x_ou_rec                    OUT NOCOPY  csi_datastructures_pub.org_units_header_rec
    ) IS

BEGIN
     dbms_sql.column_value(p_get_ou_cursor_id, 1, x_ou_rec.instance_ou_id);
     dbms_sql.column_value(p_get_ou_cursor_id, 2, x_ou_rec.instance_id);
     dbms_sql.column_value(p_get_ou_cursor_id, 3, x_ou_rec.operating_unit_id);
     dbms_sql.column_value(p_get_ou_cursor_id, 4, x_ou_rec.relationship_type_code);
     dbms_sql.column_value(p_get_ou_cursor_id, 5, x_ou_rec.active_start_date);
     dbms_sql.column_value(p_get_ou_cursor_id, 6, x_ou_rec.active_end_date);
     dbms_sql.column_value(p_get_ou_cursor_id, 7, x_ou_rec.context);
     dbms_sql.column_value(p_get_ou_cursor_id, 8, x_ou_rec.attribute1);
     dbms_sql.column_value(p_get_ou_cursor_id, 9, x_ou_rec.attribute2);
     dbms_sql.column_value(p_get_ou_cursor_id, 10, x_ou_rec.attribute3);
     dbms_sql.column_value(p_get_ou_cursor_id, 11, x_ou_rec.attribute4);
     dbms_sql.column_value(p_get_ou_cursor_id, 12, x_ou_rec.attribute5);
     dbms_sql.column_value(p_get_ou_cursor_id, 13, x_ou_rec.attribute6);
     dbms_sql.column_value(p_get_ou_cursor_id, 14, x_ou_rec.attribute7);
     dbms_sql.column_value(p_get_ou_cursor_id, 15, x_ou_rec.attribute8);
     dbms_sql.column_value(p_get_ou_cursor_id, 16, x_ou_rec.attribute9);
     dbms_sql.column_value(p_get_ou_cursor_id, 17, x_ou_rec.attribute10);
     dbms_sql.column_value(p_get_ou_cursor_id, 18, x_ou_rec.attribute11);
     dbms_sql.column_value(p_get_ou_cursor_id, 19, x_ou_rec.attribute12);
     dbms_sql.column_value(p_get_ou_cursor_id, 20, x_ou_rec.attribute13);
     dbms_sql.column_value(p_get_ou_cursor_id, 21, x_ou_rec.attribute14);
     dbms_sql.column_value(p_get_ou_cursor_id, 22, x_ou_rec.attribute15);
     dbms_sql.column_value(p_get_ou_cursor_id, 28, x_ou_rec.object_version_number);

END Get_ou_Column_Values;


PROCEDURE Bind_ou_variable
   (p_ou_query_rec    IN    csi_datastructures_pub.organization_unit_query_rec,
    p_cur_get_ou      IN    NUMBER
   )
 IS
BEGIN
    IF( (p_ou_query_rec.instance_ou_id IS NOT NULL)
                     AND (p_ou_query_rec.instance_ou_id <> FND_API.G_MISS_NUM))  THEN
       DBMS_SQL.BIND_VARIABLE(p_cur_get_ou, ':instance_ou_id', p_ou_query_rec.instance_ou_id);
    END IF;

    IF( (p_ou_query_rec.instance_id IS NOT NULL)
                     AND (p_ou_query_rec.instance_id <> FND_API.G_MISS_NUM))  THEN
       DBMS_SQL.BIND_VARIABLE(p_cur_get_ou, ':instance_id', p_ou_query_rec.instance_id);
    END IF;

    IF( (p_ou_query_rec.operating_unit_id IS NOT NULL)
                     AND (p_ou_query_rec.operating_unit_id<> FND_API.G_MISS_NUM))  THEN
       DBMS_SQL.BIND_VARIABLE(p_cur_get_ou, ':operating_unit_id', p_ou_query_rec.operating_unit_id);
    END IF;

    IF( (p_ou_query_rec.relationship_type_code IS NOT NULL)
                     AND (p_ou_query_rec.relationship_type_code <> FND_API.G_MISS_CHAR))  THEN
       DBMS_SQL.BIND_VARIABLE(p_cur_get_ou, ':relationship_type_code', p_ou_query_rec.relationship_type_code);
    END IF;

END Bind_ou_variable;




/*----------------------------------------------------------*/
/* Procedure name:  Gen_ou_Where_Clause                     */
/* Description : Procedure used to  generate the where      */
/*                clause  for Organization units            */
/*----------------------------------------------------------*/

PROCEDURE Gen_ou_Where_Clause
  ( p_ou_query_rec       IN    csi_datastructures_pub.organization_unit_query_rec
   ,x_where_clause       OUT NOCOPY   VARCHAR2
   ) IS

BEGIN

    -- Assign null at the start
    x_where_clause := '';

    IF (( p_ou_query_rec.instance_ou_id  IS NOT NULL)  AND
       (p_ou_query_rec.instance_ou_id  <> FND_API.G_MISS_NUM)) THEN
        x_where_clause := ' instance_ou_id = :instance_ou_id ';
    ELSIF ( p_ou_query_rec.instance_ou_id  IS NULL) THEN
        x_where_clause := ' instance_ou_id IS NULL ';
    END IF;

    IF ((p_ou_query_rec.instance_id IS NOT NULL)       AND
       (p_ou_query_rec.instance_id <> FND_API.G_MISS_NUM))   THEN
        IF x_where_clause IS NULL THEN
            x_where_clause := ' instance_id = :instance_id ';
        ELSE
            x_where_clause := x_where_clause||' AND '||' instance_id = :instance_id ';
        END IF;
    ELSIF (p_ou_query_rec.instance_id IS NULL) THEN
        IF x_where_clause IS NULL THEN
            x_where_clause := ' instance_id IS NULL ';
        ELSE
            x_where_clause := x_where_clause||' AND '||' instance_id IS NULL ';
        END IF;
    END IF;

    IF ((p_ou_query_rec.operating_unit_id  IS NOT NULL)   AND
       (p_ou_query_rec.operating_unit_id  <> FND_API.G_MISS_NUM)) THEN
        IF x_where_clause IS NULL THEN
            x_where_clause := ' operating_unit_id = :operating_unit_id ';
        ELSE
            x_where_clause := x_where_clause||' AND '||' operating_unit_id = :operating_unit_id ';
        END IF;
    ELSIF (p_ou_query_rec.operating_unit_id  IS NULL) THEN
        IF x_where_clause IS NULL THEN
           x_where_clause := ' operating_unit_id IS NULL ';
        ELSE
           x_where_clause := x_where_clause||' AND '||' operating_unit_id IS NULL ';
        END IF;
    END IF ;

    IF  ((p_ou_query_rec.relationship_type_code IS NOT NULL) AND
        (p_ou_query_rec.relationship_type_code <> FND_API.G_MISS_CHAR)) THEN

        IF x_where_clause IS NULL THEN
            x_where_clause := '  relationship_type_code = :relationship_type_code ';
        ELSE
            x_where_clause := x_where_clause||' AND '||
               '  relationship_type_code = :relationship_type_code ';
        END IF;
    ELSIF  (p_ou_query_rec.relationship_type_code IS NULL) THEN

        IF x_where_clause IS NULL THEN
            x_where_clause := '  relationship_type_code IS NULL ';
        ELSE
            x_where_clause := x_where_clause||' AND '||' relationship_type_code IS NULL ';
        END IF;
    END IF;

END Gen_ou_Where_Clause;



/*-------------------------------------------------------*/
/* procedure name: create_organization_unit              */
/* description :  Creates new association between an     */
/*                organization unit and an item instance */
/*                                                       */
/*-------------------------------------------------------*/

PROCEDURE create_organization_unit
 (
      p_api_version         IN      NUMBER
     ,p_commit              IN      VARCHAR2
     ,p_init_msg_list       IN      VARCHAR2
     ,p_validation_level    IN      NUMBER
     ,p_org_unit_rec        IN  OUT NOCOPY  csi_datastructures_pub.organization_units_rec
     ,p_txn_rec             IN  OUT NOCOPY  csi_datastructures_pub.transaction_rec
     ,x_return_status           OUT NOCOPY VARCHAR2
     ,x_msg_count               OUT NOCOPY NUMBER
     ,x_msg_data                OUT NOCOPY VARCHAR2
     ,p_lookup_tbl          IN  OUT NOCOPY  csi_organization_unit_pvt.lookup_tbl
     ,p_ou_count_rec        IN  OUT NOCOPY  csi_organization_unit_pvt.ou_count_rec
     ,p_ou_id_tbl           IN  OUT NOCOPY  csi_organization_unit_pvt.ou_id_tbl
     ,p_called_from_grp     IN  VARCHAR2
 )
 IS

    l_api_name                     CONSTANT VARCHAR2(30)   := 'create_organization_unit';
    l_api_version                  CONSTANT NUMBER         := 1.0;
    l_debug_level                           NUMBER;
    l_instance_ou_id                        NUMBER         := p_org_unit_rec.instance_ou_id;
    l_csi_i_org_assign_h_id                 NUMBER;
    l_dump_frequency_flag                   VARCHAR2(30);
    l_msg_index                             NUMBER;
    l_msg_count                             NUMBER;
    l_record_found                  BOOLEAN := FALSE;
    l_exists_flag                           VARCHAR2(1);
    l_valid_flag                            VARCHAR2(1);
    l_ou_lookup_tbl                         csi_organization_unit_pvt.lookup_tbl;
    l_ou_count_rec                          csi_organization_unit_pvt.ou_count_rec;
    l_ou_id_tbl                             csi_organization_unit_pvt.ou_id_tbl;

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT    create_organization_unit;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name ,
                                        g_pkg_name)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


   -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;


    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Check the profile option debug_level for debug message reporting
    l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

    -- If debug_level = 1 then dump the procedure name
    IF (l_debug_level > 0) THEN
        csi_gen_utility_pvt.put_line( 'create_organization_unit');
    END IF;


    -- If the debug level = 2 then dump all the parameters values.
    IF (l_debug_level > 1) THEN
          csi_gen_utility_pvt.put_line( p_api_version ||'-'
                         || p_commit                     ||'-'
                         || p_init_msg_list              ||'-'
                         || p_validation_level);
     -- Dump txn_rec
         csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);
     -- Dump org_unit_tbl
         csi_gen_utility_pvt.dump_organization_unit_rec(p_org_unit_rec);

    END IF;

    -- Start API body
    --
    -- Initialize the Instance count
    --
    IF p_ou_count_rec.ou_count IS NULL OR
       p_ou_count_rec.ou_count = FND_API.G_MISS_NUM THEN
       p_ou_count_rec.ou_count := 0;
    END IF;
    --
    IF p_ou_count_rec.lookup_count IS NULL OR
       p_ou_count_rec.lookup_count = FND_API.G_MISS_NUM THEN
       p_ou_count_rec.lookup_count := 0;
    END IF;
    --
    -- Verify if instance id is ok
    IF p_called_from_grp <> FND_API.G_TRUE THEN
       IF NOT(csi_org_unit_vld_pvt.Is_valid_instance_id
                 (p_org_unit_rec.instance_id,
                  'INSERT')) THEN
         RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    --
    --validation for the operating unit id
         l_valid_flag := 'Y';
         l_exists_flag := 'N';
         IF p_org_unit_rec.operating_unit_id IS NOT NULL AND
            p_org_unit_rec.operating_unit_id <> FND_API.G_MISS_NUM THEN
            IF p_ou_id_tbl.count > 0 then
               FOR ou_count IN p_ou_id_tbl.FIRST .. p_ou_id_tbl.LAST
               LOOP
                  IF p_ou_id_tbl(ou_count).ou_id = p_org_unit_rec.operating_unit_id
                  THEN
                     l_valid_flag := p_ou_id_tbl(ou_count).valid_flag;
                     l_exists_flag := 'Y';
                     EXIT;
                  END IF;
               END LOOP;
               --
               IF l_valid_flag <> 'Y' THEN
                   FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_OPERATING_UNIT');
                   FND_MESSAGE.SET_TOKEN('OPERATING_UNIT',p_org_unit_rec.operating_unit_id);
                   FND_MSG_PUB.Add;
                  RAISE fnd_api.g_exc_error;
               END IF;
            END IF;
            --
            IF l_exists_flag <> 'Y' THEN
               p_ou_count_rec.ou_count := p_ou_count_rec.ou_count + 1;
               p_ou_id_tbl(p_ou_count_rec.ou_count).ou_id := p_org_unit_rec.operating_unit_id;
               IF NOT(csi_org_unit_vld_pvt.Is_valid_operating_unit_id
                     (p_org_unit_rec.operating_unit_id)) THEN
                  p_ou_id_tbl(p_ou_count_rec.ou_count).valid_flag := 'N';
                    RAISE fnd_api.g_exc_error;
               ELSE
                  p_ou_id_tbl(p_ou_count_rec.ou_count).valid_flag := 'Y';
               END IF;
            END IF;
         ELSE
            FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_OPERATING_UNIT');
            FND_MESSAGE.SET_TOKEN('OPERATING_UNIT',p_org_unit_rec.operating_unit_id);
            FND_MSG_PUB.Add;
            RAISE fnd_api.g_exc_error;
         END IF;
    --
    -- Check start effective date
    IF p_called_from_grp <> FND_API.G_TRUE THEN
       IF NOT(csi_org_unit_vld_pvt.Is_StartDate_Valid
                               (p_org_unit_rec.ACTIVE_START_DATE,
                                p_org_unit_rec.ACTIVE_END_DATE ,
                                p_org_unit_rec.INSTANCE_ID )) THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    -- Check end effective date
    IF p_called_from_grp <> FND_API.G_TRUE THEN
       IF p_org_unit_rec.ACTIVE_END_DATE is NOT NULL THEN
          IF NOT(csi_org_unit_vld_pvt.Is_EndDate_Valid
                             (p_org_unit_rec.ACTIVE_START_DATE,
                              p_org_unit_rec.ACTIVE_END_DATE ,
                              p_org_unit_rec.INSTANCE_ID ,
                              p_org_unit_rec.INSTANCE_OU_ID,
                              p_txn_rec.TRANSACTION_ID))  THEN
             RAISE FND_API.G_EXC_ERROR;
          END IF;
       END IF;
    END IF;
    --
    --validation for the relationship type code
         l_valid_flag := 'Y';
         l_exists_flag := 'N';
         IF ((p_org_unit_rec.relationship_type_code IS NOT NULL) AND
             (p_org_unit_rec.relationship_type_code <> FND_API.G_MISS_CHAR)) THEN
            IF p_lookup_tbl.count > 0 THEN
               FOR lookup_count IN p_lookup_tbl.FIRST .. p_lookup_tbl.LAST
               LOOP
                  IF p_lookup_tbl(lookup_count).lookup_code = p_org_unit_rec.relationship_type_code THEN
                     l_valid_flag := p_lookup_tbl(lookup_count).valid_flag;
                     l_exists_flag := 'Y';
                     EXIT;
                  END IF;
               END LOOP;
               --
               if l_valid_flag <> 'Y' then
                  FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_REL_TYPE_CODE');
                  FND_MESSAGE.SET_TOKEN('RELATIONSHIP_TYPE_CODE',p_org_unit_rec.relationship_type_code);
                  FND_MSG_PUB.Add;
                  RAISE fnd_api.g_exc_error;
               end if;
            End if;
            --
            IF l_exists_flag <> 'Y' THEN
               p_ou_count_rec.lookup_count := p_ou_count_rec.lookup_count  + 1;
               p_lookup_tbl(p_ou_count_rec.lookup_count).lookup_code := p_org_unit_rec.relationship_type_code;
               IF NOT(csi_org_unit_vld_pvt.Is_valid_rel_type_code
                      (p_org_unit_rec.relationship_type_code)) THEN
                    p_lookup_tbl(p_ou_count_rec.lookup_count).valid_flag := 'N';
                      RAISE FND_API.G_EXC_ERROR;
               ELSE
                    p_lookup_tbl(p_ou_count_rec.lookup_count).valid_flag := 'Y';
               END IF;
            END IF;
         END IF;
    --
    -- Added by sk for bug 2232880.
    l_record_found := FALSE;
    IF ( (p_called_from_grp <> FND_API.G_TRUE) AND
         (p_org_unit_rec.instance_ou_id IS NULL OR
          p_org_unit_rec.instance_ou_id = fnd_api.g_miss_num) )
    THEN
      BEGIN
        SELECT  instance_ou_id,
                object_version_number
        INTO    p_org_unit_rec.instance_ou_id,
                p_org_unit_rec.object_version_number
        FROM    csi_i_org_assignments
        WHERE   instance_id            = p_org_unit_rec.instance_id
      --  AND     operating_unit_id      = p_org_unit_rec.operating_unit_id -- Fix for Bug 3918188
        AND     relationship_type_code = p_org_unit_rec.relationship_type_code
        AND     active_end_date        < SYSDATE
        AND     ROWNUM                 = 1 ;
        l_record_found := TRUE;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;

    IF l_record_found
    THEN
           IF   p_org_unit_rec.active_end_date = fnd_api.g_miss_date
           THEN
                p_org_unit_rec.active_end_date := NULL;
           END IF;
         csi_organization_unit_pvt.update_organization_unit
            ( p_api_version         => p_api_version
             ,p_commit              => fnd_api.g_false
             ,p_init_msg_list       => p_init_msg_list
             ,p_validation_level    => p_validation_level
             ,p_org_unit_rec        => p_org_unit_rec
             ,p_txn_rec             => p_txn_rec
             ,x_return_status       => x_return_status
             ,x_msg_count           => x_msg_count
             ,x_msg_data            => x_msg_data
             ,p_lookup_tbl          => l_ou_lookup_tbl
             ,p_ou_count_rec        => l_ou_count_rec
             ,p_ou_id_tbl           => l_ou_id_tbl
            );

             IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                l_msg_index := 1;
                 l_msg_count := x_msg_count;
                WHILE l_msg_count > 0 LOOP
                    x_msg_data := FND_MSG_PUB.GET
                          (  l_msg_index,
                          FND_API.G_FALSE     );

                    csi_gen_utility_pvt.put_line( ' Failed Pvt:update_organization_unit..');
                    csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
                    l_msg_index := l_msg_index + 1;
                    l_msg_count := l_msg_count - 1;
                END LOOP;
                RAISE FND_API.G_EXC_ERROR;
              END IF;
    ELSE
    -- If the instance_ou_id passed is null then generate from sequence
    -- and check if the value exists . If exists then generate again from the sequence
    -- till we get a value that does not exist
    IF l_instance_ou_id IS NULL OR
       l_instance_ou_id = FND_API.G_MISS_NUM THEN
       l_instance_ou_id := csi_org_unit_vld_pvt.get_instance_ou_id;
       p_org_unit_rec.instance_ou_id := l_instance_ou_id;
       WHILE NOT(csi_org_unit_vld_pvt.Is_valid_instance_ou_id
           (l_instance_ou_id))
       LOOP
        l_instance_ou_id := csi_org_unit_vld_pvt.get_instance_ou_id;
            p_org_unit_rec.instance_ou_id := l_instance_ou_id;
       END LOOP;
    ELSE
      -- Validate instance_ou_id
      IF NOT(csi_org_unit_vld_pvt.Is_valid_instance_ou_id
             (p_org_unit_rec.instance_ou_id)) THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    --
    -- Validate alternate_pk_exists
    IF p_called_from_grp <> FND_API.G_TRUE THEN
       IF NOT (csi_org_unit_vld_pvt.Alternate_PK_exists
            (p_org_unit_rec.instance_id
            ,p_org_unit_rec.operating_unit_id
            ,p_org_unit_rec.relationship_type_code
            )) THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    --
    -- End addition by sk for bug 2232880.
    -- Create a row in csi_i_org_assignments table
    IF p_called_from_grp <> FND_API.G_TRUE THEN
       CSI_I_ORG_ASSIGNMENTS_PKG.Insert_Row(
                l_instance_ou_id
               ,p_org_unit_rec.instance_id
               ,p_org_unit_rec.operating_unit_id
               ,p_org_unit_rec.relationship_type_code
               ,p_org_unit_rec.active_start_date
               ,p_org_unit_rec.active_end_date
               ,p_org_unit_rec.context
               ,p_org_unit_rec.attribute1
               ,p_org_unit_rec.attribute2
               ,p_org_unit_rec.attribute3
               ,p_org_unit_rec.attribute4
               ,p_org_unit_rec.attribute5
               ,p_org_unit_rec.attribute6
               ,p_org_unit_rec.attribute7
               ,p_org_unit_rec.attribute8
               ,p_org_unit_rec.attribute9
               ,p_org_unit_rec.attribute10
               ,p_org_unit_rec.attribute11
               ,p_org_unit_rec.attribute12
               ,p_org_unit_rec.attribute13
               ,p_org_unit_rec.attribute14
               ,p_org_unit_rec.attribute15
               ,fnd_global.user_id
               ,sysdate
               ,fnd_global.user_id
               ,sysdate
               ,fnd_global.user_id
               ,1
               );

        --  IF CSI_Instance_parties_vld_pvt.Is_Instance_creation_complete( p_org_unit_rec.INSTANCE_ID ) THEN

        -- Call create_transaction to create txn log
        CSI_TRANSACTIONS_PVT.Create_transaction
          (
             p_api_version            => p_api_version
            ,p_commit                 => fnd_api.g_false
            ,p_init_msg_list          => p_init_msg_list
            ,p_validation_level       => p_validation_level
            ,p_Success_If_Exists_Flag => 'Y'
            ,p_transaction_rec        => p_txn_rec
            ,x_return_status          => x_return_status
            ,x_msg_count              => x_msg_count
            ,x_msg_data               => x_msg_data
          );

                IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  l_msg_index := 1;
                  l_msg_count := x_msg_count;
                  WHILE l_msg_count > 0 LOOP
                       x_msg_data := FND_MSG_PUB.GET
                                      (l_msg_index,
                                     FND_API.G_FALSE      );

                       csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
                       l_msg_index := l_msg_index + 1;
                       l_msg_count := l_msg_count - 1;
                  END LOOP;
                  RAISE FND_API.G_EXC_ERROR;
                END IF;


          -- Get a unique org_assignment history number from the sequence
          l_csi_i_org_assign_h_id := csi_org_unit_vld_pvt.get_cis_i_org_assign_h_id;
          l_dump_frequency_flag := 'N';
         -- Create a row in csi_i_org_assignment history table
          CSI_I_ORG_ASSIGNMENTS_H_PKG.Insert_Row(
               l_csi_i_org_assign_h_id
              ,l_instance_ou_id
              ,p_txn_rec.TRANSACTION_ID
              ,NULL
              ,p_org_unit_rec.OPERATING_UNIT_ID
              ,NULL
              ,p_org_unit_rec.RELATIONSHIP_TYPE_CODE
              ,NULL
              ,NVL(p_org_unit_rec.ACTIVE_START_DATE, SYSDATE)
              ,NULL
              ,p_org_unit_rec.ACTIVE_END_DATE
              ,NULL
              ,p_org_unit_rec.context
              ,NULL
              ,p_org_unit_rec.ATTRIBUTE1
              ,NULL
              ,p_org_unit_rec.ATTRIBUTE2
              ,NULL
              ,p_org_unit_rec.ATTRIBUTE3
              ,NULL
              ,p_org_unit_rec.ATTRIBUTE4
              ,NULL
              ,p_org_unit_rec.ATTRIBUTE5
              ,NULL
              ,p_org_unit_rec.ATTRIBUTE6
              ,NULL
              ,p_org_unit_rec.ATTRIBUTE7
              ,NULL
              ,p_org_unit_rec.ATTRIBUTE8
              ,NULL
              ,p_org_unit_rec.ATTRIBUTE9
              ,NULL
              ,p_org_unit_rec.ATTRIBUTE10
              ,NULL
              ,p_org_unit_rec.ATTRIBUTE11
              ,NULL
              ,p_org_unit_rec.ATTRIBUTE12
              ,NULL
              ,p_org_unit_rec.ATTRIBUTE13
              ,NULL
              ,p_org_unit_rec.ATTRIBUTE14
              ,NULL
              ,p_org_unit_rec.ATTRIBUTE15
              ,l_dump_frequency_flag
              ,fnd_global.user_id
              ,sysdate
              ,fnd_global.user_id
              ,sysdate
              ,fnd_global.user_id
              ,1);

        -- END IF;
      END IF; -- called from grp check

    END IF; -- Added by sk for bug 2232880.
    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;
    -- End of API body
    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get
        (p_count     =>     x_msg_count ,
         p_data     =>     x_msg_data
         );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_organization_unit;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (   p_count             =>      x_msg_count,
                p_data              =>      x_msg_data
             );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_organization_unit;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (   p_count             =>      x_msg_count,
                p_data              =>      x_msg_data
             );

    WHEN OTHERS THEN
        ROLLBACK TO  create_organization_unit;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF     FND_MSG_PUB.Check_Msg_Level
            (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg
                (   g_pkg_name          ,
                    l_api_name
                 );
        END IF;

        FND_MSG_PUB.Count_And_Get
            (  p_count             =>      x_msg_count,
               p_data              =>      x_msg_data
            );

END create_organization_unit;



/*-------------------------------------------------------*/
/* procedure name: update_organization_unit              */
/* description :  Updates an existing instance-org       */
/*                association                            */
/*                                                       */
/*-------------------------------------------------------*/

PROCEDURE update_organization_unit
 (
      p_api_version         IN     NUMBER
     ,p_commit              IN     VARCHAR2
     ,p_init_msg_list       IN     VARCHAR2
     ,p_validation_level    IN     NUMBER
     ,p_org_unit_rec        IN     csi_datastructures_pub.organization_units_rec
     ,p_txn_rec             IN OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status          OUT NOCOPY VARCHAR2
     ,x_msg_count              OUT NOCOPY NUMBER
     ,x_msg_data               OUT NOCOPY VARCHAR2
     ,p_lookup_tbl          IN OUT NOCOPY csi_organization_unit_pvt.lookup_tbl
     ,p_ou_count_rec        IN OUT NOCOPY csi_organization_unit_pvt.ou_count_rec
     ,p_ou_id_tbl           IN OUT NOCOPY csi_organization_unit_pvt.ou_id_tbl
 )


IS
    l_api_name                   CONSTANT VARCHAR2(30)   := 'update_organization_unit';
    l_api_version                CONSTANT NUMBER         := 1.0;
    l_debug_level                         NUMBER;
    l_instance_ou_id                      NUMBER         := p_org_unit_rec.instance_ou_id;
    l_start_date                          DATE;
    l_dump_frequency                      NUMBER;
    l_csi_i_org_assign_h_id               NUMBER;
    l_org_unit_rec                        csi_datastructures_pub.organization_units_rec;
    l_temp_org_unit_rec                   csi_datastructures_pub.organization_units_rec;
    l_dump_frequency_flag                 VARCHAR2(30);
    l_msg_index                           NUMBER;
    l_msg_count                           NUMBER;
    l_exists_flag                         VARCHAR2(1);
    l_valid_flag                          VARCHAR2(1);
    l_org_units_hist_rec                  csi_datastructures_pub.org_units_history_rec;
    l_operating_unit_id                   NUMBER;
    l_rel_type_code                       VARCHAR2(30);

CURSOR org_hist_csr (p_org_hist_id NUMBER) IS
      SELECT  instance_ou_history_id
             ,instance_ou_id
             ,transaction_id
             ,old_operating_unit_id
             ,new_operating_unit_id
             ,old_relationship_type_code
             ,new_relationship_type_code
             ,old_active_start_date
             ,new_active_start_date
             ,old_active_end_date
             ,new_active_end_date
             ,old_context
             ,new_context
             ,old_attribute1
             ,new_attribute1
             ,old_attribute2
             ,new_attribute2
             ,old_attribute3
             ,new_attribute3
             ,old_attribute4
             ,new_attribute4
             ,old_attribute5
             ,new_attribute5
             ,old_attribute6
             ,new_attribute6
             ,old_attribute7
             ,new_attribute7
             ,old_attribute8
             ,new_attribute8
             ,old_attribute9
             ,new_attribute9
             ,old_attribute10
             ,new_attribute10
             ,old_attribute11
             ,new_attribute11
             ,old_attribute12
             ,new_attribute12
             ,old_attribute13
             ,new_attribute13
             ,old_attribute14
             ,new_attribute14
             ,old_attribute15
             ,new_attribute15
             ,full_dump_flag
             ,object_version_number
      FROM   csi_i_org_assignments_h
      WHERE  csi_i_org_assignments_h.instance_ou_history_id = p_org_hist_id
      FOR UPDATE OF object_version_number ;
      l_org_hist_csr     org_hist_csr%ROWTYPE;
      l_org_hist_id      NUMBER;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT    update_organization_unit;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name ,
                                        g_pkg_name)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check the profile option debug_level for debug message reporting
    l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

    -- If debug_level = 1 then dump the procedure name
    IF (l_debug_level > 0) THEN
        csi_gen_utility_pvt.put_line( 'update_organization_unit');
    END IF;

    -- If the debug level = 2 then dump all the parameters values.
    IF (l_debug_level > 1) THEN
        csi_gen_utility_pvt.put_line(
                            p_api_version       ||'-'
                         || p_commit            ||'-'
                         || p_init_msg_list     ||'-'
                         || p_validation_level);
     -- Dump org_unit_rec
        csi_gen_utility_pvt.dump_organization_unit_rec(p_org_unit_rec);
     -- Dump txn_rec
    csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);
    END IF;

    -- Start API body
    --
    -- Initialize the Instance count
    --
    IF p_ou_count_rec.ou_count IS NULL OR
       p_ou_count_rec.ou_count = FND_API.G_MISS_NUM THEN
       p_ou_count_rec.ou_count := 0;
    END IF;
    --
    IF p_ou_count_rec.lookup_count IS NULL OR
       p_ou_count_rec.lookup_count = FND_API.G_MISS_NUM THEN
       p_ou_count_rec.lookup_count := 0;
    END IF;
    --
    -- Validate instance_ou_id
    IF NOT(csi_org_unit_vld_pvt.Val_and_get_inst_ou_id
             (p_org_unit_rec.instance_ou_id,
              l_org_unit_rec)) THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Validate object_version_number
    IF NOT(csi_org_unit_vld_pvt.Is_valid_obj_ver_num
          (p_org_unit_rec.object_version_number
          ,l_org_unit_rec.object_version_number
          )) THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Validate if the instance is updatable
    IF NOT(csi_org_unit_vld_pvt.Is_Updatable(
        l_org_unit_rec.active_end_date,
        p_org_unit_rec.active_end_date)) THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Validate instance id for which the update is related to
    IF NOT(csi_org_unit_vld_pvt.Is_Valid_instance_id
          (l_org_unit_rec.instance_id,
           'UPDATE'
          )) THEN
        -- Check if it is an expire operation
           IF NOT(csi_org_unit_vld_pvt.Is_Expire_Op
                     (p_org_unit_rec)) THEN
             RAISE FND_API.G_EXC_ERROR;
           END IF;
    END IF;

    -- Validate instance id
    IF ( p_org_unit_rec.instance_id <> FND_API.G_MISS_NUM ) THEN
      IF NOT(csi_org_unit_vld_pvt.Val_inst_id_for_update
          (p_org_unit_rec.instance_id
           ,l_org_unit_rec.instance_id
          )) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    --
    --validation for the operating unit id
         l_valid_flag := 'Y';
         l_exists_flag := 'N';
         IF p_org_unit_rec.operating_unit_id IS NOT NULL AND
            p_org_unit_rec.operating_unit_id <> FND_API.G_MISS_NUM THEN
            IF p_ou_id_tbl.count > 0 THEN
               FOR ou_count in p_ou_id_tbl.FIRST .. p_ou_id_tbl.LAST
               LOOP
                  IF p_ou_id_tbl(ou_count).ou_id = p_org_unit_rec.operating_unit_id
                  THEN
                     l_valid_flag := p_ou_id_tbl(ou_count).valid_flag;
                     l_exists_flag := 'Y';
                     EXIT;
                  END IF;
               END LOOP;
               --
               IF l_valid_flag <> 'Y' THEN
                   FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_OPERATING_UNIT');
                   FND_MESSAGE.SET_TOKEN('OPERATING_UNIT',p_org_unit_rec.operating_unit_id);
                   FND_MSG_PUB.Add;
                  RAISE fnd_api.g_exc_error;
               END IF;
            END IF;
            --
            IF l_exists_flag <> 'Y' THEN
               p_ou_count_rec.ou_count := p_ou_count_rec.ou_count + 1;
               p_ou_id_tbl(p_ou_count_rec.ou_count).ou_id := p_org_unit_rec.operating_unit_id;
               IF NOT(csi_org_unit_vld_pvt.Is_valid_operating_unit_id
                     (p_org_unit_rec.operating_unit_id)) THEN
                  p_ou_id_tbl(p_ou_count_rec.ou_count).valid_flag := 'N';
                    RAISE fnd_api.g_exc_error;
               ELSE
                  p_ou_id_tbl(p_ou_count_rec.ou_count).valid_flag := 'Y';
               END IF;
            END IF;
         END IF;
    --

    --
    --validation for the relationship type code
         l_valid_flag := 'Y';
         l_exists_flag := 'N';
         IF ((p_org_unit_rec.relationship_type_code IS NOT NULL) AND
             (p_org_unit_rec.relationship_type_code <> FND_API.G_MISS_CHAR)) THEN
            IF p_lookup_tbl.count > 0 THEN
               FOR lookup_count in p_lookup_tbl.FIRST .. p_lookup_tbl.LAST
               LOOP
                  IF p_lookup_tbl(lookup_count).lookup_code = p_org_unit_rec.relationship_type_code THEN
                     l_valid_flag := p_lookup_tbl(lookup_count).valid_flag;
                     l_exists_flag := 'Y';
                     EXIT;
                  END IF;
               END LOOP;
               --
               IF l_valid_flag <> 'Y' THEN
                  FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_REL_TYPE_CODE');
                  FND_MESSAGE.SET_TOKEN('RELATIONSHIP_TYPE_CODE',p_org_unit_rec.relationship_type_code);
                  FND_MSG_PUB.Add;
                  RAISE fnd_api.g_exc_error;
               END IF;
            END IF;
            --
            IF l_exists_flag <> 'Y' THEN
               p_ou_count_rec.lookup_count := p_ou_count_rec.lookup_count  + 1;
               p_lookup_tbl(p_ou_count_rec.lookup_count).lookup_code := p_org_unit_rec.relationship_type_code;
               IF NOT(csi_org_unit_vld_pvt.Is_valid_rel_type_code
                      (p_org_unit_rec.relationship_type_code)) THEN
                    p_lookup_tbl(p_ou_count_rec.lookup_count).valid_flag := 'N';
                      RAISE FND_API.G_EXC_ERROR;
               ELSE
                    p_lookup_tbl(p_ou_count_rec.lookup_count).valid_flag := 'Y';
               END IF;
            END IF;
         END IF;
    --
    -- Verify start effective date
    IF ( p_org_unit_rec.active_start_date <> FND_API.G_MISS_DATE) THEN
       IF (p_org_unit_rec.active_start_date <> l_org_unit_rec.active_start_date) THEN
         l_start_date := p_org_unit_rec.ACTIVE_START_DATE;
         IF NOT(csi_org_unit_vld_pvt.Is_StartDate_Valid
                               (l_start_date,
                              p_org_unit_rec.ACTIVE_END_DATE ,
                              p_org_unit_rec.INSTANCE_ID )) THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;

       END IF;
    END IF;

    -- Verify end effective date
    IF ( p_org_unit_rec.active_end_date <> FND_API.G_MISS_DATE) THEN
       IF p_org_unit_rec.active_end_date is NOT NULL THEN
        IF g_expire_flag  <> 'Y' THEN
           IF NOT(csi_org_unit_vld_pvt.Is_EndDate_Valid
               (p_org_unit_rec.ACTIVE_START_DATE,
                p_org_unit_rec.ACTIVE_END_DATE,
                p_org_unit_rec.INSTANCE_ID ,
                p_org_unit_rec.INSTANCE_OU_ID,
			 p_txn_rec.TRANSACTION_ID))  THEN
             RAISE FND_API.G_EXC_ERROR;
           END IF;
         END IF;
       END IF;
    END IF;
    -- srramakr Bug 3918188
    -- Validate alternate_pk_exists
    IF p_org_unit_rec.operating_unit_id IS  NULL OR
       p_org_unit_rec.operating_unit_id = FND_API.G_MISS_NUM THEN
       l_operating_unit_id := l_org_unit_rec.operating_unit_id;
    ELSE
       l_operating_unit_id := p_org_unit_rec.operating_unit_id;
    END IF;
    --
    IF p_org_unit_rec.relationship_type_code IS  NULL OR
       p_org_unit_rec.relationship_type_code = FND_API.G_MISS_CHAR THEN
       l_rel_type_code := l_org_unit_rec.relationship_type_code;
    ELSE
       l_rel_type_code := p_org_unit_rec.relationship_type_code;
    END IF;
    --
    IF NOT (csi_org_unit_vld_pvt.Alternate_PK_exists
      (p_instance_id            => l_org_unit_rec.instance_id
      ,p_operating_unit_id      => l_operating_unit_id
      ,p_relationship_type_code => l_rel_type_code
      ,p_instance_ou_id         => p_org_unit_rec.INSTANCE_OU_ID
      )) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- End of 3918188
    -- Validate alternate_pk_exists
/****    IF (p_org_unit_rec.operating_unit_id IS  NULL) AND
        (p_org_unit_rec.relationship_type_code IS  NULL) THEN
       IF NOT (csi_org_unit_vld_pvt.Alternate_PK_exists
         (l_org_unit_rec.instance_id
         ,l_org_unit_rec.operating_unit_id
         ,l_org_unit_rec.relationship_type_code
         )) THEN
         RAISE FND_API.G_EXC_ERROR;
       END IF;
    ELSIF (p_org_unit_rec.operating_unit_id IS  NULL) AND
        (p_org_unit_rec.relationship_type_code IS NOT NULL) THEN
       IF NOT (csi_org_unit_vld_pvt.Alternate_PK_exists
         (l_org_unit_rec.instance_id
         ,l_org_unit_rec.operating_unit_id
         ,p_org_unit_rec.relationship_type_code
         )) THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;
     ELSIF (p_org_unit_rec.operating_unit_id IS  NOT NULL) AND
        (p_org_unit_rec.relationship_type_code IS NULL) THEN
       IF NOT (csi_org_unit_vld_pvt.Alternate_PK_exists
         (l_org_unit_rec.instance_id
         ,p_org_unit_rec.operating_unit_id
         ,l_org_unit_rec.relationship_type_code
          )) THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;
     END IF;
*****/
     -- Get the new object version number
     l_org_unit_rec.object_version_number :=
     csi_org_unit_vld_pvt.get_object_version_number(l_org_unit_rec.object_version_number);

     CSI_I_ORG_ASSIGNMENTS_PKG.Update_Row(
                l_instance_ou_id
               ,p_org_unit_rec.instance_id
               ,p_org_unit_rec.operating_unit_id
               ,p_org_unit_rec.relationship_type_code
               ,p_org_unit_rec.active_start_date
               ,p_org_unit_rec.active_end_date
               ,p_org_unit_rec.context
               ,p_org_unit_rec.attribute1
               ,p_org_unit_rec.attribute2
               ,p_org_unit_rec.attribute3
               ,p_org_unit_rec.attribute4
               ,p_org_unit_rec.attribute5
               ,p_org_unit_rec.attribute6
               ,p_org_unit_rec.attribute7
               ,p_org_unit_rec.attribute8
               ,p_org_unit_rec.attribute9
               ,p_org_unit_rec.attribute10
               ,p_org_unit_rec.attribute11
               ,p_org_unit_rec.attribute12
               ,p_org_unit_rec.attribute13
               ,p_org_unit_rec.attribute14
               ,p_org_unit_rec.attribute15
               ,fnd_api.g_miss_num -- fnd_global.user_id
               ,fnd_api.g_miss_date
               ,fnd_global.user_id
               ,sysdate
               ,fnd_global.user_id
               ,l_org_unit_rec.object_version_number
               );

          -- Call create_transaction to create txn log
            CSI_TRANSACTIONS_PVT.Create_transaction
             (
               p_api_version            => p_api_version
              ,p_commit                 => fnd_api.g_false
              ,p_init_msg_list          => p_init_msg_list
              ,p_validation_level       => p_validation_level
              ,p_Success_If_Exists_Flag => 'Y'
              ,P_transaction_rec        => p_txn_rec
              ,x_return_status          => x_return_status
              ,x_msg_count              => x_msg_count
              ,x_msg_data               => x_msg_data
             );

                IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  l_msg_index := 1;
                  l_msg_count := x_msg_count;
                  WHILE l_msg_count > 0 LOOP
                       x_msg_data := FND_MSG_PUB.GET
                                      (l_msg_index,
                                     FND_API.G_FALSE      );

                       csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
                       l_msg_index := l_msg_index + 1;
                       l_msg_count := l_msg_count - 1;
                  END LOOP;
                  RAISE FND_API.G_EXC_ERROR;
                END IF;

      -- Get a unique org_assignment history number from the sequence
            l_csi_i_org_assign_h_id := csi_org_unit_vld_pvt.get_cis_i_org_assign_h_id;

      -- Get full dump frequency from CSI_INSTALL_PARAMETERS
        l_dump_frequency := csi_org_unit_vld_pvt.get_full_dump_frequency;
        IF l_dump_frequency IS NULL THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      -- Grab the input record in a temporary record
            l_temp_org_unit_rec := p_org_unit_rec;

      -- Start of modifications for Bug#2547034 on 09/20/02 - rtalluri
      BEGIN
       SELECT  instance_ou_history_id
       INTO    l_org_hist_id
       FROM    csi_i_org_assignments_h h
       WHERE   h.transaction_id = p_txn_rec.transaction_id
       AND     h.instance_ou_id = p_org_unit_rec.instance_ou_id;

       OPEN   org_hist_csr(l_org_hist_id);
       FETCH  org_hist_csr INTO l_org_hist_csr ;
       CLOSE  org_hist_csr;
       IF l_org_hist_csr.full_dump_flag = 'Y'
       THEN
         csi_i_org_assignments_h_pkg.update_row(
                    p_instance_ou_history_id      => l_org_hist_id                             ,
                    p_instance_ou_id              => fnd_api.g_miss_num                        ,
                    p_transaction_id              => fnd_api.g_miss_num                        ,
                    p_old_operating_unit_id       => fnd_api.g_miss_num                        ,
                    p_new_operating_unit_id       => l_temp_org_unit_rec.operating_unit_id     ,
                    p_old_relationship_type_code  => fnd_api.g_miss_char                       ,
                    p_new_relationship_type_code  => l_temp_org_unit_rec.relationship_type_code,
                    p_old_active_start_date       => fnd_api.g_miss_date                       ,
                    p_new_active_start_date       => l_temp_org_unit_rec.active_start_date     ,
                    p_old_active_end_date         => fnd_api.g_miss_date                       ,
                    p_new_active_end_date         => l_temp_org_unit_rec.active_end_date       ,
                    p_old_context                 => fnd_api.g_miss_char                       ,
                    p_new_context                 => l_temp_org_unit_rec.context               ,
                    p_old_attribute1              => fnd_api.g_miss_char                       ,
                    p_new_attribute1              => l_temp_org_unit_rec.attribute1            ,
                    p_old_attribute2              => fnd_api.g_miss_char                       ,
                    p_new_attribute2              => l_temp_org_unit_rec.attribute2            ,
                    p_old_attribute3              => fnd_api.g_miss_char                       ,
                    p_new_attribute3              => l_temp_org_unit_rec.attribute3            ,
                    p_old_attribute4              => fnd_api.g_miss_char                       ,
                    p_new_attribute4              => l_temp_org_unit_rec.attribute4            ,
                    p_old_attribute5              => fnd_api.g_miss_char                       ,
                    p_new_attribute5              => l_temp_org_unit_rec.attribute5            ,
                    p_old_attribute6              => fnd_api.g_miss_char                       ,
                    p_new_attribute6              => l_temp_org_unit_rec.attribute6            ,
                    p_old_attribute7              => fnd_api.g_miss_char                       ,
                    p_new_attribute7              => l_temp_org_unit_rec.attribute7            ,
                    p_old_attribute8              => fnd_api.g_miss_char                       ,
                    p_new_attribute8              => l_temp_org_unit_rec.attribute8            ,
                    p_old_attribute9              => fnd_api.g_miss_char                       ,
                    p_new_attribute9              => l_temp_org_unit_rec.attribute9            ,
                    p_old_attribute10             => fnd_api.g_miss_char                       ,
                    p_new_attribute10             => l_temp_org_unit_rec.attribute10           ,
                    p_old_attribute11             => fnd_api.g_miss_char                       ,
                    p_new_attribute11             => l_temp_org_unit_rec.attribute11           ,
                    p_old_attribute12             => fnd_api.g_miss_char                       ,
                    p_new_attribute12             => l_temp_org_unit_rec.attribute12           ,
                    p_old_attribute13             => fnd_api.g_miss_char                       ,
                    p_new_attribute13             => l_temp_org_unit_rec.attribute13           ,
                    p_old_attribute14             => fnd_api.g_miss_char                       ,
                    p_new_attribute14             => l_temp_org_unit_rec.attribute14           ,
                    p_old_attribute15             => fnd_api.g_miss_char                       ,
                    p_new_attribute15             => l_temp_org_unit_rec.attribute15           ,
                    p_full_dump_flag              => fnd_api.g_miss_char                       ,
                    p_created_by                  => fnd_api.g_miss_num, -- fnd_global.user_id ,
                    p_creation_date               => fnd_api.g_miss_date                       ,
                    p_last_updated_by             => fnd_global.user_id                        ,
                    p_last_update_date            => sysdate                                   ,
                    p_last_update_login           => fnd_global.user_id                        ,
                    p_object_version_number       => fnd_api.g_miss_num                        );

       ELSE

             IF    ( l_org_hist_csr.old_operating_unit_id IS NULL
                AND  l_org_hist_csr.new_operating_unit_id IS NULL ) THEN
                     IF  ( l_temp_org_unit_rec.operating_unit_id = l_org_unit_rec.operating_unit_id )
                      OR ( l_temp_org_unit_rec.operating_unit_id = fnd_api.g_miss_num ) THEN
                           l_org_hist_csr.old_operating_unit_id := NULL;
                           l_org_hist_csr.new_operating_unit_id := NULL;
                     ELSE
                           l_org_hist_csr.old_operating_unit_id := fnd_api.g_miss_num;
                           l_org_hist_csr.new_operating_unit_id := l_temp_org_unit_rec.operating_unit_id;
                     END IF;
             ELSE
                     l_org_hist_csr.old_operating_unit_id := fnd_api.g_miss_num;
                     l_org_hist_csr.new_operating_unit_id := l_temp_org_unit_rec.operating_unit_id;
             END IF;
             --
             IF    ( l_org_hist_csr.old_relationship_type_code IS NULL
                AND  l_org_hist_csr.new_relationship_type_code IS NULL ) THEN
                     IF  ( l_temp_org_unit_rec.relationship_type_code = l_org_unit_rec.relationship_type_code )
                      OR ( l_temp_org_unit_rec.relationship_type_code = fnd_api.g_miss_char ) THEN
                           l_org_hist_csr.old_relationship_type_code := NULL;
                           l_org_hist_csr.new_relationship_type_code := NULL;
                     ELSE
                           l_org_hist_csr.old_relationship_type_code := fnd_api.g_miss_char;
                           l_org_hist_csr.new_relationship_type_code := l_temp_org_unit_rec.relationship_type_code;
                     END IF;
             ELSE
                     l_org_hist_csr.old_relationship_type_code := fnd_api.g_miss_char;
                     l_org_hist_csr.new_relationship_type_code := l_temp_org_unit_rec.relationship_type_code;
             END IF;
             --
             IF    ( l_org_hist_csr.old_active_start_date IS NULL
                AND  l_org_hist_csr.new_active_start_date IS NULL ) THEN
                     IF  ( l_temp_org_unit_rec.active_start_date = l_org_unit_rec.active_start_date )
                      OR ( l_temp_org_unit_rec.active_start_date = fnd_api.g_miss_date ) THEN
                           l_org_hist_csr.old_active_start_date := NULL;
                           l_org_hist_csr.new_active_start_date := NULL;
                     ELSE
                           l_org_hist_csr.old_active_start_date := fnd_api.g_miss_date;
                           l_org_hist_csr.new_active_start_date := l_temp_org_unit_rec.active_start_date;
                     END IF;
             ELSE
                     l_org_hist_csr.old_active_start_date := fnd_api.g_miss_date;
                     l_org_hist_csr.new_active_start_date := l_temp_org_unit_rec.active_start_date;
             END IF;
             --
             IF    ( l_org_hist_csr.old_active_end_date IS NULL
                AND  l_org_hist_csr.new_active_end_date IS NULL ) THEN
                     IF  ( l_temp_org_unit_rec.active_end_date = l_org_unit_rec.active_end_date )
                      OR ( l_temp_org_unit_rec.active_end_date = fnd_api.g_miss_date ) THEN
                           l_org_hist_csr.old_active_end_date := NULL;
                           l_org_hist_csr.new_active_end_date := NULL;
                     ELSE
                           l_org_hist_csr.old_active_end_date := fnd_api.g_miss_date;
                           l_org_hist_csr.new_active_end_date := l_temp_org_unit_rec.active_end_date;
                     END IF;
             ELSE
                     l_org_hist_csr.old_active_end_date := fnd_api.g_miss_date;
                     l_org_hist_csr.new_active_end_date := l_temp_org_unit_rec.active_end_date;
             END IF;
             --
             IF    ( l_org_hist_csr.old_context IS NULL
                AND  l_org_hist_csr.new_context IS NULL ) THEN
                     IF  ( l_temp_org_unit_rec.context = l_org_unit_rec.context )
                      OR ( l_temp_org_unit_rec.context = fnd_api.g_miss_char ) THEN
                           l_org_hist_csr.old_context := NULL;
                           l_org_hist_csr.new_context := NULL;
                     ELSE
                           l_org_hist_csr.old_context := fnd_api.g_miss_char;
                           l_org_hist_csr.new_context := l_temp_org_unit_rec.context;
                     END IF;
             ELSE
                     l_org_hist_csr.old_context := fnd_api.g_miss_char;
                     l_org_hist_csr.new_context := l_temp_org_unit_rec.context;
             END IF;
             --
             IF    ( l_org_hist_csr.old_attribute1 IS NULL
                AND  l_org_hist_csr.new_attribute1 IS NULL ) THEN
                     IF  ( l_temp_org_unit_rec.attribute1 = l_org_unit_rec.attribute1 )
                      OR ( l_temp_org_unit_rec.attribute1 = fnd_api.g_miss_char ) THEN
                           l_org_hist_csr.old_attribute1 := NULL;
                           l_org_hist_csr.new_attribute1 := NULL;
                     ELSE
                           l_org_hist_csr.old_attribute1 := fnd_api.g_miss_char;
                           l_org_hist_csr.new_attribute1 := l_temp_org_unit_rec.attribute1;
                     END IF;
             ELSE
                     l_org_hist_csr.old_attribute1 := fnd_api.g_miss_char;
                     l_org_hist_csr.new_attribute1 := l_temp_org_unit_rec.attribute1;
             END IF;
             --
             IF    ( l_org_hist_csr.old_attribute2 IS NULL
                AND  l_org_hist_csr.new_attribute2 IS NULL ) THEN
                     IF  ( l_temp_org_unit_rec.attribute2 = l_org_unit_rec.attribute2 )
                      OR ( l_temp_org_unit_rec.attribute2 = fnd_api.g_miss_char ) THEN
                           l_org_hist_csr.old_attribute2 := NULL;
                           l_org_hist_csr.new_attribute2 := NULL;
                     ELSE
                           l_org_hist_csr.old_attribute2 := fnd_api.g_miss_char;
                           l_org_hist_csr.new_attribute2 := l_temp_org_unit_rec.attribute2;
                     END IF;
             ELSE
                     l_org_hist_csr.old_attribute2 := fnd_api.g_miss_char;
                     l_org_hist_csr.new_attribute2 := l_temp_org_unit_rec.attribute2;
             END IF;
             --
             IF    ( l_org_hist_csr.old_attribute3 IS NULL
                AND  l_org_hist_csr.new_attribute3 IS NULL ) THEN
                     IF  ( l_temp_org_unit_rec.attribute3 = l_org_unit_rec.attribute3 )
                      OR ( l_temp_org_unit_rec.attribute3 = fnd_api.g_miss_char ) THEN
                           l_org_hist_csr.old_attribute3 := NULL;
                           l_org_hist_csr.new_attribute3 := NULL;
                     ELSE
                           l_org_hist_csr.old_attribute3 := fnd_api.g_miss_char;
                           l_org_hist_csr.new_attribute3 := l_temp_org_unit_rec.attribute3;
                     END IF;
             ELSE
                     l_org_hist_csr.old_attribute3 := fnd_api.g_miss_char;
                     l_org_hist_csr.new_attribute3 := l_temp_org_unit_rec.attribute3;
             END IF;
             --
             IF    ( l_org_hist_csr.old_attribute4 IS NULL
                AND  l_org_hist_csr.new_attribute4 IS NULL ) THEN
                     IF  ( l_temp_org_unit_rec.attribute4 = l_org_unit_rec.attribute4 )
                      OR ( l_temp_org_unit_rec.attribute4 = fnd_api.g_miss_char ) THEN
                           l_org_hist_csr.old_attribute4 := NULL;
                           l_org_hist_csr.new_attribute4 := NULL;
                     ELSE
                           l_org_hist_csr.old_attribute4 := fnd_api.g_miss_char;
                           l_org_hist_csr.new_attribute4 := l_temp_org_unit_rec.attribute4;
                     END IF;
             ELSE
                     l_org_hist_csr.old_attribute4 := fnd_api.g_miss_char;
                     l_org_hist_csr.new_attribute4 := l_temp_org_unit_rec.attribute4;
             END IF;
             --
             IF    ( l_org_hist_csr.old_attribute5 IS NULL
                AND  l_org_hist_csr.new_attribute5 IS NULL ) THEN
                     IF  ( l_temp_org_unit_rec.attribute5 = l_org_unit_rec.attribute5 )
                      OR ( l_temp_org_unit_rec.attribute5 = fnd_api.g_miss_char ) THEN
                           l_org_hist_csr.old_attribute5 := NULL;
                           l_org_hist_csr.new_attribute5 := NULL;
                     ELSE
                           l_org_hist_csr.old_attribute5 := fnd_api.g_miss_char;
                           l_org_hist_csr.new_attribute5 := l_temp_org_unit_rec.attribute5;
                     END IF;
             ELSE
                     l_org_hist_csr.old_attribute5 := fnd_api.g_miss_char;
                     l_org_hist_csr.new_attribute5 := l_temp_org_unit_rec.attribute5;
             END IF;
             --
             IF    ( l_org_hist_csr.old_attribute6 IS NULL
                AND  l_org_hist_csr.new_attribute6 IS NULL ) THEN
                     IF  ( l_temp_org_unit_rec.attribute6 = l_org_unit_rec.attribute6 )
                      OR ( l_temp_org_unit_rec.attribute6 = fnd_api.g_miss_char ) THEN
                           l_org_hist_csr.old_attribute6 := NULL;
                           l_org_hist_csr.new_attribute6 := NULL;
                     ELSE
                           l_org_hist_csr.old_attribute6 := fnd_api.g_miss_char;
                           l_org_hist_csr.new_attribute6 := l_temp_org_unit_rec.attribute6;
                     END IF;
             ELSE
                     l_org_hist_csr.old_attribute6 := fnd_api.g_miss_char;
                     l_org_hist_csr.new_attribute6 := l_temp_org_unit_rec.attribute6;
             END IF;
             --
             IF    ( l_org_hist_csr.old_attribute7 IS NULL
                AND  l_org_hist_csr.new_attribute7 IS NULL ) THEN
                     IF  ( l_temp_org_unit_rec.attribute7 = l_org_unit_rec.attribute7 )
                      OR ( l_temp_org_unit_rec.attribute7 = fnd_api.g_miss_char ) THEN
                           l_org_hist_csr.old_attribute7 := NULL;
                           l_org_hist_csr.new_attribute7 := NULL;
                     ELSE
                           l_org_hist_csr.old_attribute7 := fnd_api.g_miss_char;
                           l_org_hist_csr.new_attribute7 := l_temp_org_unit_rec.attribute7;
                     END IF;
             ELSE
                     l_org_hist_csr.old_attribute7 := fnd_api.g_miss_char;
                     l_org_hist_csr.new_attribute7 := l_temp_org_unit_rec.attribute7;
             END IF;
             --
             IF    ( l_org_hist_csr.old_attribute8 IS NULL
                AND  l_org_hist_csr.new_attribute8 IS NULL ) THEN
                     IF  ( l_temp_org_unit_rec.attribute8 = l_org_unit_rec.attribute8 )
                      OR ( l_temp_org_unit_rec.attribute8 = fnd_api.g_miss_char ) THEN
                           l_org_hist_csr.old_attribute8 := NULL;
                           l_org_hist_csr.new_attribute8 := NULL;
                     ELSE
                           l_org_hist_csr.old_attribute8 := fnd_api.g_miss_char;
                           l_org_hist_csr.new_attribute8 := l_temp_org_unit_rec.attribute8;
                     END IF;
             ELSE
                     l_org_hist_csr.old_attribute8 := fnd_api.g_miss_char;
                     l_org_hist_csr.new_attribute8 := l_temp_org_unit_rec.attribute8;
             END IF;
             --
             IF    ( l_org_hist_csr.old_attribute9 IS NULL
                AND  l_org_hist_csr.new_attribute9 IS NULL ) THEN
                     IF  ( l_temp_org_unit_rec.attribute9 = l_org_unit_rec.attribute9 )
                      OR ( l_temp_org_unit_rec.attribute9 = fnd_api.g_miss_char ) THEN
                           l_org_hist_csr.old_attribute9 := NULL;
                           l_org_hist_csr.new_attribute9 := NULL;
                     ELSE
                           l_org_hist_csr.old_attribute9 := fnd_api.g_miss_char;
                           l_org_hist_csr.new_attribute9 := l_temp_org_unit_rec.attribute9;
                     END IF;
             ELSE
                     l_org_hist_csr.old_attribute9 := fnd_api.g_miss_char;
                     l_org_hist_csr.new_attribute9 := l_temp_org_unit_rec.attribute9;
             END IF;
             --
             IF    ( l_org_hist_csr.old_attribute10 IS NULL
                AND  l_org_hist_csr.new_attribute10 IS NULL ) THEN
                     IF  ( l_temp_org_unit_rec.attribute10 = l_org_unit_rec.attribute10 )
                      OR ( l_temp_org_unit_rec.attribute10 = fnd_api.g_miss_char ) THEN
                           l_org_hist_csr.old_attribute10 := NULL;
                           l_org_hist_csr.new_attribute10 := NULL;
                     ELSE
                           l_org_hist_csr.old_attribute10 := fnd_api.g_miss_char;
                           l_org_hist_csr.new_attribute10 := l_temp_org_unit_rec.attribute10;
                     END IF;
             ELSE
                     l_org_hist_csr.old_attribute10 := fnd_api.g_miss_char;
                     l_org_hist_csr.new_attribute10 := l_temp_org_unit_rec.attribute10;
             END IF;
             --
             IF    ( l_org_hist_csr.old_attribute11 IS NULL
                AND  l_org_hist_csr.new_attribute11 IS NULL ) THEN
                     IF  ( l_temp_org_unit_rec.attribute11 = l_org_unit_rec.attribute11 )
                      OR ( l_temp_org_unit_rec.attribute11 = fnd_api.g_miss_char ) THEN
                           l_org_hist_csr.old_attribute11 := NULL;
                           l_org_hist_csr.new_attribute11 := NULL;
                     ELSE
                           l_org_hist_csr.old_attribute11 := fnd_api.g_miss_char;
                           l_org_hist_csr.new_attribute11 := l_temp_org_unit_rec.attribute11;
                     END IF;
             ELSE
                     l_org_hist_csr.old_attribute11 := fnd_api.g_miss_char;
                     l_org_hist_csr.new_attribute11 := l_temp_org_unit_rec.attribute11;
             END IF;
             --
             IF    ( l_org_hist_csr.old_attribute12 IS NULL
                AND  l_org_hist_csr.new_attribute12 IS NULL ) THEN
                     IF  ( l_temp_org_unit_rec.attribute12 = l_org_unit_rec.attribute12 )
                      OR ( l_temp_org_unit_rec.attribute12 = fnd_api.g_miss_char ) THEN
                           l_org_hist_csr.old_attribute12 := NULL;
                           l_org_hist_csr.new_attribute12 := NULL;
                     ELSE
                           l_org_hist_csr.old_attribute12 := fnd_api.g_miss_char;
                           l_org_hist_csr.new_attribute12 := l_temp_org_unit_rec.attribute12;
                     END IF;
             ELSE
                     l_org_hist_csr.old_attribute12 := fnd_api.g_miss_char;
                     l_org_hist_csr.new_attribute12 := l_temp_org_unit_rec.attribute12;
             END IF;
             --
             IF    ( l_org_hist_csr.old_attribute13 IS NULL
                AND  l_org_hist_csr.new_attribute13 IS NULL ) THEN
                     IF  ( l_temp_org_unit_rec.attribute13 = l_org_unit_rec.attribute13 )
                      OR ( l_temp_org_unit_rec.attribute13 = fnd_api.g_miss_char ) THEN
                           l_org_hist_csr.old_attribute13 := NULL;
                           l_org_hist_csr.new_attribute13 := NULL;
                     ELSE
                           l_org_hist_csr.old_attribute13 := fnd_api.g_miss_char;
                           l_org_hist_csr.new_attribute13 := l_temp_org_unit_rec.attribute13;
                     END IF;
             ELSE
                     l_org_hist_csr.old_attribute13 := fnd_api.g_miss_char;
                     l_org_hist_csr.new_attribute13 := l_temp_org_unit_rec.attribute13;
             END IF;
             --
             IF    ( l_org_hist_csr.old_attribute14 IS NULL
                AND  l_org_hist_csr.new_attribute14 IS NULL ) THEN
                     IF  ( l_temp_org_unit_rec.attribute14 = l_org_unit_rec.attribute14 )
                      OR ( l_temp_org_unit_rec.attribute14 = fnd_api.g_miss_char ) THEN
                           l_org_hist_csr.old_attribute14 := NULL;
                           l_org_hist_csr.new_attribute14 := NULL;
                     ELSE
                           l_org_hist_csr.old_attribute14 := fnd_api.g_miss_char;
                           l_org_hist_csr.new_attribute14 := l_temp_org_unit_rec.attribute14;
                     END IF;
             ELSE
                     l_org_hist_csr.old_attribute14 := fnd_api.g_miss_char;
                     l_org_hist_csr.new_attribute14 := l_temp_org_unit_rec.attribute14;
             END IF;
             --
             IF    ( l_org_hist_csr.old_attribute15 IS NULL
                AND  l_org_hist_csr.new_attribute15 IS NULL ) THEN
                     IF  ( l_temp_org_unit_rec.attribute15 = l_org_unit_rec.attribute15 )
                      OR ( l_temp_org_unit_rec.attribute15 = fnd_api.g_miss_char ) THEN
                           l_org_hist_csr.old_attribute15 := NULL;
                           l_org_hist_csr.new_attribute15 := NULL;
                     ELSE
                           l_org_hist_csr.old_attribute15 := fnd_api.g_miss_char;
                           l_org_hist_csr.new_attribute15 := l_temp_org_unit_rec.attribute15;
                     END IF;
             ELSE
                     l_org_hist_csr.old_attribute15 := fnd_api.g_miss_char;
                     l_org_hist_csr.new_attribute15 := l_temp_org_unit_rec.attribute15;
             END IF;
             --

            csi_i_org_assignments_h_pkg.update_row(
                    p_instance_ou_history_id      => l_org_hist_id                             ,
                    p_instance_ou_id              => fnd_api.g_miss_num                        ,
                    p_transaction_id              => fnd_api.g_miss_num                        ,
                    p_old_operating_unit_id       => l_org_hist_csr.old_operating_unit_id      ,
                    p_new_operating_unit_id       => l_org_hist_csr.new_operating_unit_id     ,
                    p_old_relationship_type_code  => l_org_hist_csr.old_relationship_type_code ,
                    p_new_relationship_type_code  => l_org_hist_csr.new_relationship_type_code,
                    p_old_active_start_date       => l_org_hist_csr.old_active_start_date      ,
                    p_new_active_start_date       => l_org_hist_csr.new_active_start_date     ,
                    p_old_active_end_date         => l_org_hist_csr.old_active_end_date        ,
                    p_new_active_end_date         => l_org_hist_csr.new_active_end_date       ,
                    p_old_context                 => l_org_hist_csr.old_context                ,
                    p_new_context                 => l_org_hist_csr.new_context               ,
                    p_old_attribute1              => l_org_hist_csr.old_attribute1             ,
                    p_new_attribute1              => l_org_hist_csr.new_attribute1            ,
                    p_old_attribute2              => l_org_hist_csr.old_attribute2             ,
                    p_new_attribute2              => l_org_hist_csr.new_attribute2            ,
                    p_old_attribute3              => l_org_hist_csr.old_attribute3             ,
                    p_new_attribute3              => l_org_hist_csr.new_attribute3            ,
                    p_old_attribute4              => l_org_hist_csr.old_attribute4             ,
                    p_new_attribute4              => l_org_hist_csr.new_attribute4            ,
                    p_old_attribute5              => l_org_hist_csr.old_attribute5             ,
                    p_new_attribute5              => l_org_hist_csr.new_attribute5            ,
                    p_old_attribute6              => l_org_hist_csr.old_attribute6             ,
                    p_new_attribute6              => l_org_hist_csr.new_attribute6            ,
                    p_old_attribute7              => l_org_hist_csr.old_attribute7             ,
                    p_new_attribute7              => l_org_hist_csr.new_attribute7            ,
                    p_old_attribute8              => l_org_hist_csr.old_attribute8             ,
                    p_new_attribute8              => l_org_hist_csr.new_attribute8            ,
                    p_old_attribute9              => l_org_hist_csr.old_attribute9             ,
                    p_new_attribute9              => l_org_hist_csr.new_attribute9            ,
                    p_old_attribute10             => l_org_hist_csr.old_attribute10            ,
                    p_new_attribute10             => l_org_hist_csr.new_attribute10           ,
                    p_old_attribute11             => l_org_hist_csr.old_attribute11            ,
                    p_new_attribute11             => l_org_hist_csr.new_attribute11           ,
                    p_old_attribute12             => l_org_hist_csr.old_attribute12            ,
                    p_new_attribute12             => l_org_hist_csr.new_attribute12           ,
                    p_old_attribute13             => l_org_hist_csr.old_attribute13            ,
                    p_new_attribute13             => l_org_hist_csr.new_attribute13           ,
                    p_old_attribute14             => l_org_hist_csr.old_attribute14            ,
                    p_new_attribute14             => l_org_hist_csr.new_attribute14           ,
                    p_old_attribute15             => l_org_hist_csr.old_attribute15            ,
                    p_new_attribute15             => l_org_hist_csr.new_attribute15           ,
                    p_full_dump_flag              => fnd_api.g_miss_char                       ,
                    p_created_by                  => fnd_api.g_miss_num                        ,
                    p_creation_date               => fnd_api.g_miss_date                       ,
                    p_last_updated_by             => fnd_global.user_id                        ,
                    p_last_update_date            => sysdate                                   ,
                    p_last_update_login           => fnd_global.user_id                        ,
                    p_object_version_number       => fnd_api.g_miss_num                        );
       END IF;
      EXCEPTION
          WHEN NO_DATA_FOUND THEN

          IF (mod(l_org_unit_rec.object_version_number, l_dump_frequency) = 0) THEN

               l_dump_frequency_flag := 'Y';
                 -- Grab the input record in a temporary record
               l_temp_org_unit_rec := p_org_unit_rec;
               IF (p_org_unit_rec.OPERATING_UNIT_ID  = FND_API.G_MISS_NUM) THEN
                   l_temp_org_unit_rec.OPERATING_UNIT_ID := l_org_unit_rec.OPERATING_UNIT_ID;
               END IF;

               IF (p_org_unit_rec.RELATIONSHIP_TYPE_CODE  = FND_API.G_MISS_CHAR) THEN
                   l_temp_org_unit_rec.RELATIONSHIP_TYPE_CODE := l_org_unit_rec.RELATIONSHIP_TYPE_CODE;
               END IF;

               IF (p_org_unit_rec.ACTIVE_START_DATE  = FND_API.G_MISS_DATE) THEN
                   l_temp_org_unit_rec.ACTIVE_START_DATE := l_org_unit_rec.ACTIVE_START_DATE;
               END IF;

               IF (p_org_unit_rec.ACTIVE_END_DATE  = FND_API.G_MISS_DATE) THEN
                   l_temp_org_unit_rec.ACTIVE_END_DATE := l_org_unit_rec.ACTIVE_END_DATE;
               END IF;

               IF (p_org_unit_rec.CONTEXT  = FND_API.G_MISS_CHAR) THEN
                   l_temp_org_unit_rec.CONTEXT := l_org_unit_rec.CONTEXT;
               END IF;

               IF (p_org_unit_rec.ATTRIBUTE1  = FND_API.G_MISS_CHAR) THEN
                   l_temp_org_unit_rec.ATTRIBUTE1 := l_org_unit_rec.ATTRIBUTE1;
               END IF;

               IF (p_org_unit_rec.ATTRIBUTE2  = FND_API.G_MISS_CHAR) THEN
                   l_temp_org_unit_rec.ATTRIBUTE2 := l_org_unit_rec.ATTRIBUTE2;
               END IF;

               IF (p_org_unit_rec.ATTRIBUTE3  = FND_API.G_MISS_CHAR) THEN
                   l_temp_org_unit_rec.ATTRIBUTE3 := l_org_unit_rec.ATTRIBUTE3;
               END IF;

               IF (p_org_unit_rec.ATTRIBUTE4  = FND_API.G_MISS_CHAR) THEN
                   l_temp_org_unit_rec.ATTRIBUTE4 := l_org_unit_rec.ATTRIBUTE4;
               END IF;

               IF (p_org_unit_rec.ATTRIBUTE5  = FND_API.G_MISS_CHAR) THEN
                   l_temp_org_unit_rec.ATTRIBUTE5 := l_org_unit_rec.ATTRIBUTE5;
               END IF;

               IF (p_org_unit_rec.ATTRIBUTE6  = FND_API.G_MISS_CHAR) THEN
                   l_temp_org_unit_rec.ATTRIBUTE6 := l_org_unit_rec.ATTRIBUTE6;
               END IF;

               IF (p_org_unit_rec.ATTRIBUTE7  = FND_API.G_MISS_CHAR) THEN
                   l_temp_org_unit_rec.ATTRIBUTE7 := l_org_unit_rec.ATTRIBUTE7;
               END IF;

               IF (p_org_unit_rec.ATTRIBUTE8  = FND_API.G_MISS_CHAR) THEN
                   l_temp_org_unit_rec.ATTRIBUTE8 := l_org_unit_rec.ATTRIBUTE8;
               END IF;

               IF (p_org_unit_rec.ATTRIBUTE9  = FND_API.G_MISS_CHAR) THEN
                   l_temp_org_unit_rec.ATTRIBUTE9 := l_org_unit_rec.ATTRIBUTE9;
               END IF;

               IF (p_org_unit_rec.ATTRIBUTE10  = FND_API.G_MISS_CHAR) THEN
                   l_temp_org_unit_rec.ATTRIBUTE10 := l_org_unit_rec.ATTRIBUTE10;
               END IF;

               IF (p_org_unit_rec.ATTRIBUTE11  = FND_API.G_MISS_CHAR) THEN
                   l_temp_org_unit_rec.ATTRIBUTE11 := l_org_unit_rec.ATTRIBUTE11;
               END IF;

               IF (p_org_unit_rec.ATTRIBUTE12  = FND_API.G_MISS_CHAR) THEN
                   l_temp_org_unit_rec.ATTRIBUTE12 := l_org_unit_rec.ATTRIBUTE12;
               END IF;

               IF (p_org_unit_rec.ATTRIBUTE13  = FND_API.G_MISS_CHAR) THEN
                   l_temp_org_unit_rec.ATTRIBUTE13 := l_org_unit_rec.ATTRIBUTE13;
               END IF;

               IF (p_org_unit_rec.ATTRIBUTE14  = FND_API.G_MISS_CHAR) THEN
                   l_temp_org_unit_rec.ATTRIBUTE14 := l_org_unit_rec.ATTRIBUTE14;
               END IF;

               IF (p_org_unit_rec.ATTRIBUTE15  = FND_API.G_MISS_CHAR) THEN
                   l_temp_org_unit_rec.ATTRIBUTE15 := l_org_unit_rec.ATTRIBUTE15;
               END IF;

                -- Create a row in csi_i_org_assignment history table
               CSI_I_ORG_ASSIGNMENTS_H_PKG.Insert_Row(
                     l_csi_i_org_assign_h_id
                    ,l_instance_ou_id
                    ,p_txn_rec.TRANSACTION_ID
                    ,l_org_unit_rec.OPERATING_UNIT_ID
                    ,l_temp_org_unit_rec.OPERATING_UNIT_ID
                    ,l_org_unit_rec.RELATIONSHIP_TYPE_CODE
                    ,l_temp_org_unit_rec.RELATIONSHIP_TYPE_CODE
                    ,l_org_unit_rec.ACTIVE_START_DATE
                    ,l_temp_org_unit_rec.ACTIVE_START_DATE
                    ,l_org_unit_rec.ACTIVE_END_DATE
                    ,l_temp_org_unit_rec.ACTIVE_END_DATE
                    ,l_org_unit_rec.context
                    ,l_temp_org_unit_rec.context
                    ,l_org_unit_rec.ATTRIBUTE1
                    ,l_temp_org_unit_rec.ATTRIBUTE1
                    ,l_org_unit_rec.ATTRIBUTE2
                    ,l_temp_org_unit_rec.ATTRIBUTE2
                    ,l_org_unit_rec.ATTRIBUTE3
                    ,l_temp_org_unit_rec.ATTRIBUTE3
                    ,l_org_unit_rec.ATTRIBUTE4
                    ,l_temp_org_unit_rec.ATTRIBUTE4
                    ,l_org_unit_rec.ATTRIBUTE5
                    ,l_temp_org_unit_rec.ATTRIBUTE5
                    ,l_org_unit_rec.ATTRIBUTE6
                    ,l_temp_org_unit_rec.ATTRIBUTE6
                    ,l_org_unit_rec.ATTRIBUTE7
                    ,l_temp_org_unit_rec.ATTRIBUTE7
                    ,l_org_unit_rec.ATTRIBUTE8
                    ,l_temp_org_unit_rec.ATTRIBUTE8
                    ,l_org_unit_rec.ATTRIBUTE9
                    ,l_temp_org_unit_rec.ATTRIBUTE9
                    ,l_org_unit_rec.ATTRIBUTE10
                    ,l_temp_org_unit_rec.ATTRIBUTE10
                    ,l_org_unit_rec.ATTRIBUTE11
                    ,l_temp_org_unit_rec.ATTRIBUTE11
                    ,l_org_unit_rec.ATTRIBUTE12
                    ,l_temp_org_unit_rec.ATTRIBUTE12
                    ,l_org_unit_rec.ATTRIBUTE13
                    ,l_temp_org_unit_rec.ATTRIBUTE13
                    ,l_org_unit_rec.ATTRIBUTE14
                    ,l_temp_org_unit_rec.ATTRIBUTE14
                    ,l_org_unit_rec.ATTRIBUTE15
                    ,l_temp_org_unit_rec.ATTRIBUTE15
                    ,l_dump_frequency_flag
                    ,fnd_global.user_id
                    ,sysdate
                    ,fnd_global.user_id
                    ,sysdate
                    ,fnd_global.user_id
                    ,1
                    );

        ELSE

           l_dump_frequency_flag := 'N';

           IF (p_org_unit_rec.operating_unit_id = fnd_api.g_miss_num) OR
               NVL(p_org_unit_rec.operating_unit_id, fnd_api.g_miss_num) = NVL(l_org_unit_rec.operating_unit_id, fnd_api.g_miss_num) THEN
                l_org_units_hist_rec.old_operating_unit_id := NULL;
                l_org_units_hist_rec.new_operating_unit_id := NULL;
           ELSIF
              NVL(l_org_unit_rec.operating_unit_id,fnd_api.g_miss_num) <> NVL(p_org_unit_rec.operating_unit_id,fnd_api.g_miss_num) THEN
                l_org_units_hist_rec.old_operating_unit_id := l_org_unit_rec.operating_unit_id ;
                l_org_units_hist_rec.new_operating_unit_id := p_org_unit_rec.operating_unit_id ;
           END IF;
           --
           IF (p_org_unit_rec.relationship_type_code = fnd_api.g_miss_char) OR
               NVL(p_org_unit_rec.relationship_type_code, fnd_api.g_miss_char) = NVL(l_org_unit_rec.relationship_type_code, fnd_api.g_miss_char) THEN
                l_org_units_hist_rec.old_relationship_type_code := NULL;
                l_org_units_hist_rec.new_relationship_type_code := NULL;
           ELSIF
              NVL(l_org_unit_rec.relationship_type_code,fnd_api.g_miss_char) <> NVL(p_org_unit_rec.relationship_type_code,fnd_api.g_miss_char) THEN
                l_org_units_hist_rec.old_relationship_type_code := l_org_unit_rec.relationship_type_code ;
                l_org_units_hist_rec.new_relationship_type_code := p_org_unit_rec.relationship_type_code ;
           END IF;
           --
           IF (p_org_unit_rec.active_start_date = fnd_api.g_miss_date) OR
               NVL(p_org_unit_rec.active_start_date, fnd_api.g_miss_date) = NVL(l_org_unit_rec.active_start_date, fnd_api.g_miss_date) THEN
                l_org_units_hist_rec.old_active_start_date := NULL;
                l_org_units_hist_rec.new_active_start_date := NULL;
           ELSIF
              NVL(l_org_unit_rec.active_start_date,fnd_api.g_miss_date) <> NVL(p_org_unit_rec.active_start_date,fnd_api.g_miss_date) THEN
                l_org_units_hist_rec.old_active_start_date := l_org_unit_rec.active_start_date ;
                l_org_units_hist_rec.new_active_start_date := p_org_unit_rec.active_start_date ;
           END IF;
           --
           IF (p_org_unit_rec.active_end_date = fnd_api.g_miss_date) OR
               NVL(p_org_unit_rec.active_end_date, fnd_api.g_miss_date) = NVL(l_org_unit_rec.active_end_date, fnd_api.g_miss_date) THEN
                l_org_units_hist_rec.old_active_end_date := NULL;
                l_org_units_hist_rec.new_active_end_date := NULL;
           ELSIF
              NVL(l_org_unit_rec.active_end_date,fnd_api.g_miss_date) <> NVL(p_org_unit_rec.active_end_date,fnd_api.g_miss_date) THEN
                l_org_units_hist_rec.old_active_end_date := l_org_unit_rec.active_end_date ;
                l_org_units_hist_rec.new_active_end_date := p_org_unit_rec.active_end_date ;
           END IF;
           --
           IF (p_org_unit_rec.context = fnd_api.g_miss_char) OR
               NVL(p_org_unit_rec.context, fnd_api.g_miss_char) = NVL(l_org_unit_rec.context, fnd_api.g_miss_char) THEN
                l_org_units_hist_rec.old_context := NULL;
                l_org_units_hist_rec.new_context := NULL;
           ELSIF
              NVL(l_org_unit_rec.context,fnd_api.g_miss_char) <> NVL(p_org_unit_rec.context,fnd_api.g_miss_char) THEN
                l_org_units_hist_rec.old_context := l_org_unit_rec.context ;
                l_org_units_hist_rec.new_context := p_org_unit_rec.context ;
           END IF;
           --
           IF (p_org_unit_rec.attribute1 = fnd_api.g_miss_char) OR
               NVL(p_org_unit_rec.attribute1, fnd_api.g_miss_char) = NVL(l_org_unit_rec.attribute1, fnd_api.g_miss_char) THEN
                l_org_units_hist_rec.old_attribute1 := NULL;
                l_org_units_hist_rec.new_attribute1 := NULL;
           ELSIF
              NVL(l_org_unit_rec.attribute1,fnd_api.g_miss_char) <> NVL(p_org_unit_rec.attribute1,fnd_api.g_miss_char) THEN
                l_org_units_hist_rec.old_attribute1 := l_org_unit_rec.attribute1 ;
                l_org_units_hist_rec.new_attribute1 := p_org_unit_rec.attribute1 ;
           END IF;
           --
           IF (p_org_unit_rec.attribute2 = fnd_api.g_miss_char) OR
               NVL(p_org_unit_rec.attribute2, fnd_api.g_miss_char) = NVL(l_org_unit_rec.attribute2, fnd_api.g_miss_char) THEN
                l_org_units_hist_rec.old_attribute2 := NULL;
                l_org_units_hist_rec.new_attribute2 := NULL;
           ELSIF
              NVL(l_org_unit_rec.attribute2,fnd_api.g_miss_char) <> NVL(p_org_unit_rec.attribute2,fnd_api.g_miss_char) THEN
                l_org_units_hist_rec.old_attribute2 := l_org_unit_rec.attribute2 ;
                l_org_units_hist_rec.new_attribute2 := p_org_unit_rec.attribute2 ;
           END IF;
           --
           IF (p_org_unit_rec.attribute3 = fnd_api.g_miss_char) OR
               NVL(p_org_unit_rec.attribute3, fnd_api.g_miss_char) = NVL(l_org_unit_rec.attribute3, fnd_api.g_miss_char) THEN
                l_org_units_hist_rec.old_attribute3 := NULL;
                l_org_units_hist_rec.new_attribute3 := NULL;
           ELSIF
              NVL(l_org_unit_rec.attribute3,fnd_api.g_miss_char) <> NVL(p_org_unit_rec.attribute3,fnd_api.g_miss_char) THEN
                l_org_units_hist_rec.old_attribute3 := l_org_unit_rec.attribute3 ;
                l_org_units_hist_rec.new_attribute3 := p_org_unit_rec.attribute3 ;
           END IF;
           --
           IF (p_org_unit_rec.attribute4 = fnd_api.g_miss_char) OR
               NVL(p_org_unit_rec.attribute4, fnd_api.g_miss_char) = NVL(l_org_unit_rec.attribute4, fnd_api.g_miss_char) THEN
                l_org_units_hist_rec.old_attribute4 := NULL;
                l_org_units_hist_rec.new_attribute4 := NULL;
           ELSIF
              NVL(l_org_unit_rec.attribute4,fnd_api.g_miss_char) <> NVL(p_org_unit_rec.attribute4,fnd_api.g_miss_char) THEN
                l_org_units_hist_rec.old_attribute4 := l_org_unit_rec.attribute4 ;
                l_org_units_hist_rec.new_attribute4 := p_org_unit_rec.attribute4 ;
           END IF;
           --
           IF (p_org_unit_rec.attribute5 = fnd_api.g_miss_char) OR
               NVL(p_org_unit_rec.attribute5, fnd_api.g_miss_char) = NVL(l_org_unit_rec.attribute5, fnd_api.g_miss_char) THEN
                l_org_units_hist_rec.old_attribute5 := NULL;
                l_org_units_hist_rec.new_attribute5 := NULL;
           ELSIF
              NVL(l_org_unit_rec.attribute5,fnd_api.g_miss_char) <> NVL(p_org_unit_rec.attribute5,fnd_api.g_miss_char) THEN
                l_org_units_hist_rec.old_attribute5 := l_org_unit_rec.attribute5 ;
                l_org_units_hist_rec.new_attribute5 := p_org_unit_rec.attribute5 ;
           END IF;
           --
           IF (p_org_unit_rec.attribute6 = fnd_api.g_miss_char) OR
               NVL(p_org_unit_rec.attribute6, fnd_api.g_miss_char) = NVL(l_org_unit_rec.attribute6, fnd_api.g_miss_char) THEN
                l_org_units_hist_rec.old_attribute6 := NULL;
                l_org_units_hist_rec.new_attribute6 := NULL;
           ELSIF
              NVL(l_org_unit_rec.attribute6,fnd_api.g_miss_char) <> NVL(p_org_unit_rec.attribute6,fnd_api.g_miss_char) THEN
                l_org_units_hist_rec.old_attribute6 := l_org_unit_rec.attribute6 ;
                l_org_units_hist_rec.new_attribute6 := p_org_unit_rec.attribute6 ;
           END IF;
           --
           IF (p_org_unit_rec.attribute7 = fnd_api.g_miss_char) OR
               NVL(p_org_unit_rec.attribute7, fnd_api.g_miss_char) = NVL(l_org_unit_rec.attribute7, fnd_api.g_miss_char) THEN
                l_org_units_hist_rec.old_attribute7 := NULL;
                l_org_units_hist_rec.new_attribute7 := NULL;
           ELSIF
              NVL(l_org_unit_rec.attribute7,fnd_api.g_miss_char) <> NVL(p_org_unit_rec.attribute7,fnd_api.g_miss_char) THEN
                l_org_units_hist_rec.old_attribute7 := l_org_unit_rec.attribute7 ;
                l_org_units_hist_rec.new_attribute7 := p_org_unit_rec.attribute7 ;
           END IF;
           --
           IF (p_org_unit_rec.attribute8 = fnd_api.g_miss_char) OR
               NVL(p_org_unit_rec.attribute8, fnd_api.g_miss_char) = NVL(l_org_unit_rec.attribute8, fnd_api.g_miss_char) THEN
                l_org_units_hist_rec.old_attribute8 := NULL;
                l_org_units_hist_rec.new_attribute8 := NULL;
           ELSIF
              NVL(l_org_unit_rec.attribute8,fnd_api.g_miss_char) <> NVL(p_org_unit_rec.attribute8,fnd_api.g_miss_char) THEN
                l_org_units_hist_rec.old_attribute8 := l_org_unit_rec.attribute8 ;
                l_org_units_hist_rec.new_attribute8 := p_org_unit_rec.attribute8 ;
           END IF;
           --
           IF (p_org_unit_rec.attribute9 = fnd_api.g_miss_char) OR
               NVL(p_org_unit_rec.attribute9, fnd_api.g_miss_char) = NVL(l_org_unit_rec.attribute9, fnd_api.g_miss_char) THEN
                l_org_units_hist_rec.old_attribute9 := NULL;
                l_org_units_hist_rec.new_attribute9 := NULL;
           ELSIF
              NVL(l_org_unit_rec.attribute9,fnd_api.g_miss_char) <> NVL(p_org_unit_rec.attribute9,fnd_api.g_miss_char) THEN
                l_org_units_hist_rec.old_attribute9 := l_org_unit_rec.attribute9 ;
                l_org_units_hist_rec.new_attribute9 := p_org_unit_rec.attribute9 ;
           END IF;
           --
           IF (p_org_unit_rec.attribute10 = fnd_api.g_miss_char) OR
               NVL(p_org_unit_rec.attribute10, fnd_api.g_miss_char) = NVL(l_org_unit_rec.attribute10, fnd_api.g_miss_char) THEN
                l_org_units_hist_rec.old_attribute10 := NULL;
                l_org_units_hist_rec.new_attribute10 := NULL;
           ELSIF
              NVL(l_org_unit_rec.attribute10,fnd_api.g_miss_char) <> NVL(p_org_unit_rec.attribute10,fnd_api.g_miss_char) THEN
                l_org_units_hist_rec.old_attribute10 := l_org_unit_rec.attribute10 ;
                l_org_units_hist_rec.new_attribute10 := p_org_unit_rec.attribute10 ;
           END IF;
           --
           IF (p_org_unit_rec.attribute11 = fnd_api.g_miss_char) OR
               NVL(p_org_unit_rec.attribute11, fnd_api.g_miss_char) = NVL(l_org_unit_rec.attribute11, fnd_api.g_miss_char) THEN
                l_org_units_hist_rec.old_attribute11 := NULL;
                l_org_units_hist_rec.new_attribute11 := NULL;
           ELSIF
              NVL(l_org_unit_rec.attribute11,fnd_api.g_miss_char) <> NVL(p_org_unit_rec.attribute11,fnd_api.g_miss_char) THEN
                l_org_units_hist_rec.old_attribute11 := l_org_unit_rec.attribute11 ;
                l_org_units_hist_rec.new_attribute11 := p_org_unit_rec.attribute11 ;
           END IF;
           --
           IF (p_org_unit_rec.attribute12 = fnd_api.g_miss_char) OR
               NVL(p_org_unit_rec.attribute12, fnd_api.g_miss_char) = NVL(l_org_unit_rec.attribute12, fnd_api.g_miss_char) THEN
                l_org_units_hist_rec.old_attribute12 := NULL;
                l_org_units_hist_rec.new_attribute12 := NULL;
           ELSIF
              NVL(l_org_unit_rec.attribute12,fnd_api.g_miss_char) <> NVL(p_org_unit_rec.attribute12,fnd_api.g_miss_char) THEN
                l_org_units_hist_rec.old_attribute12 := l_org_unit_rec.attribute12 ;
                l_org_units_hist_rec.new_attribute12 := p_org_unit_rec.attribute12 ;
           END IF;
           --
           IF (p_org_unit_rec.attribute13 = fnd_api.g_miss_char) OR
               NVL(p_org_unit_rec.attribute13, fnd_api.g_miss_char) = NVL(l_org_unit_rec.attribute13, fnd_api.g_miss_char) THEN
                l_org_units_hist_rec.old_attribute13 := NULL;
                l_org_units_hist_rec.new_attribute13 := NULL;
           ELSIF
              NVL(l_org_unit_rec.attribute13,fnd_api.g_miss_char) <> NVL(p_org_unit_rec.attribute13,fnd_api.g_miss_char) THEN
                l_org_units_hist_rec.old_attribute13 := l_org_unit_rec.attribute13 ;
                l_org_units_hist_rec.new_attribute13 := p_org_unit_rec.attribute13 ;
           END IF;
           --
           IF (p_org_unit_rec.attribute14 = fnd_api.g_miss_char) OR
               NVL(p_org_unit_rec.attribute14, fnd_api.g_miss_char) = NVL(l_org_unit_rec.attribute14, fnd_api.g_miss_char) THEN
                l_org_units_hist_rec.old_attribute14 := NULL;
                l_org_units_hist_rec.new_attribute14 := NULL;
           ELSIF
              NVL(l_org_unit_rec.attribute14,fnd_api.g_miss_char) <> NVL(p_org_unit_rec.attribute14,fnd_api.g_miss_char) THEN
                l_org_units_hist_rec.old_attribute14 := l_org_unit_rec.attribute14 ;
                l_org_units_hist_rec.new_attribute14 := p_org_unit_rec.attribute14 ;
           END IF;
           --
           IF (p_org_unit_rec.attribute15 = fnd_api.g_miss_char) OR
               NVL(p_org_unit_rec.attribute15, fnd_api.g_miss_char) = NVL(l_org_unit_rec.attribute15, fnd_api.g_miss_char) THEN
                l_org_units_hist_rec.old_attribute15 := NULL;
                l_org_units_hist_rec.new_attribute15 := NULL;
           ELSIF
              NVL(l_org_unit_rec.attribute15,fnd_api.g_miss_char) <> NVL(p_org_unit_rec.attribute15,fnd_api.g_miss_char) THEN
                l_org_units_hist_rec.old_attribute15 := l_org_unit_rec.attribute15 ;
                l_org_units_hist_rec.new_attribute15 := p_org_unit_rec.attribute15 ;
           END IF;
           --

               -- Create a row in csi_i_org_assignment history table
               CSI_I_ORG_ASSIGNMENTS_H_PKG.Insert_Row(
                   l_csi_i_org_assign_h_id
                  ,l_instance_ou_id
                  ,p_txn_rec.transaction_id
                  ,l_org_units_hist_rec.old_operating_unit_id
                  ,l_org_units_hist_rec.new_operating_unit_id
                  ,l_org_units_hist_rec.old_relationship_type_code
                  ,l_org_units_hist_rec.new_relationship_type_code
                  ,l_org_units_hist_rec.old_active_start_date
                  ,l_org_units_hist_rec.new_active_start_date
                  ,l_org_units_hist_rec.old_active_end_date
                  ,l_org_units_hist_rec.new_active_end_date
                  ,l_org_units_hist_rec.old_context
                  ,l_org_units_hist_rec.new_context
                  ,l_org_units_hist_rec.old_attribute1
                  ,l_org_units_hist_rec.new_attribute1
                  ,l_org_units_hist_rec.old_attribute2
                  ,l_org_units_hist_rec.new_attribute2
                  ,l_org_units_hist_rec.old_attribute3
                  ,l_org_units_hist_rec.new_attribute3
                  ,l_org_units_hist_rec.old_attribute4
                  ,l_org_units_hist_rec.new_attribute4
                  ,l_org_units_hist_rec.old_attribute5
                  ,l_org_units_hist_rec.new_attribute5
                  ,l_org_units_hist_rec.old_attribute6
                  ,l_org_units_hist_rec.new_attribute6
                  ,l_org_units_hist_rec.old_attribute7
                  ,l_org_units_hist_rec.new_attribute7
                  ,l_org_units_hist_rec.old_attribute8
                  ,l_org_units_hist_rec.new_attribute8
                  ,l_org_units_hist_rec.old_attribute9
                  ,l_org_units_hist_rec.new_attribute9
                  ,l_org_units_hist_rec.old_attribute10
                  ,l_org_units_hist_rec.new_attribute10
                  ,l_org_units_hist_rec.old_attribute11
                  ,l_org_units_hist_rec.new_attribute11
                  ,l_org_units_hist_rec.old_attribute12
                  ,l_org_units_hist_rec.new_attribute12
                  ,l_org_units_hist_rec.old_attribute13
                  ,l_org_units_hist_rec.new_attribute13
                  ,l_org_units_hist_rec.old_attribute14
                  ,l_org_units_hist_rec.new_attribute14
                  ,l_org_units_hist_rec.old_attribute15
                  ,l_org_units_hist_rec.new_attribute15
                  ,l_dump_frequency_flag
                  ,fnd_global.user_id
                  ,sysdate
                  ,fnd_global.user_id
                  ,sysdate
                  ,fnd_global.user_id
                  ,1
                  );
          END IF;
      END;
    -- End of modification for Bug#2547034 on 09/20/02 - rtalluri
    -- End of API body

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get
        (p_count     =>     x_msg_count ,
         p_data      =>     x_msg_data
        );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_organization_unit;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (  p_count             =>      x_msg_count,
               p_data              =>      x_msg_data
             );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_organization_unit;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (  p_count             =>      x_msg_count,
               p_data              =>      x_msg_data
            );

    WHEN OTHERS THEN
        ROLLBACK TO  update_organization_unit;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF  FND_MSG_PUB.Check_Msg_Level
            (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                    FND_MSG_PUB.Add_Exc_Msg
                    (    g_pkg_name   ,
                        l_api_name
                     );
        END IF;

        FND_MSG_PUB.Count_And_Get
            (  p_count             =>      x_msg_count,
               p_data              =>      x_msg_data
             );

END update_organization_unit;

/*--------------------------------------------------*/
/* procedure name: expire_organization_unit         */
/* description :  Expires an existing instance-org  */
/*                association                       */
/*--------------------------------------------------*/

PROCEDURE expire_organization_unit
 (
      p_api_version                 IN  NUMBER
     ,p_commit                      IN  VARCHAR2
     ,p_init_msg_list               IN  VARCHAR2
     ,p_validation_level            IN  NUMBER
     ,p_org_unit_rec                IN  csi_datastructures_pub.organization_units_rec
     ,p_txn_rec                     IN  OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status               OUT NOCOPY VARCHAR2
     ,x_msg_count                   OUT NOCOPY NUMBER
     ,x_msg_data                    OUT NOCOPY VARCHAR2
 )

IS
    l_api_name                CONSTANT VARCHAR2(30)   := 'expire_organization_unit';
    l_api_version             CONSTANT NUMBER        := 1.0;
    l_debug_level                      NUMBER;
    l_org_unit_rec                     csi_datastructures_pub.organization_units_rec;
    l_object_version_number            NUMBER;
    l_msg_count                        NUMBER;
    l_msg_index                        NUMBER;
    l_exists_flag                      VARCHAR2(1);
    l_valid_flag                       VARCHAR2(1);
    l_ou_lookup_tbl                    csi_organization_unit_pvt.lookup_tbl;
    l_ou_count_rec                     csi_organization_unit_pvt.ou_count_rec;
    l_ou_id_tbl                        csi_organization_unit_pvt.ou_id_tbl;

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT    expire_organization_unit;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name ,
                                        g_pkg_name)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;


    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Check the profile option debug_level for debug message reporting
    l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

    -- If debug_level = 1 then dump the procedure name
    IF (l_debug_level > 0) THEN
        csi_gen_utility_pvt.put_line( 'expire_organization_unit');
    END IF;


    -- If the debug level = 2 then dump all the parameters values.
    IF (l_debug_level > 1) THEN
        csi_gen_utility_pvt.put_line(
                                        p_api_version      ||'-'
                                     || p_commit           ||'-'
                                     || p_init_msg_list    ||'-'
                                     || p_validation_level);
      -- Dump org_unit_rec
      csi_gen_utility_pvt.dump_organization_unit_rec(p_org_unit_rec);
      -- Dump txn_rec
      csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);
    END IF;


    -- Start API body

   -- Validate instance_ou_id
      IF NOT(csi_org_unit_vld_pvt.Val_and_get_inst_ou_id
             (p_org_unit_rec.instance_ou_id,
              l_org_unit_rec)) THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

       l_org_unit_rec.instance_ou_id         := p_org_unit_rec.instance_ou_id;
       l_org_unit_rec.instance_id            := FND_API.G_MISS_NUM ;
       l_org_unit_rec.operating_unit_id      := FND_API.G_MISS_NUM ;
       l_org_unit_rec.relationship_type_code := FND_API.G_MISS_CHAR;
       l_org_unit_rec.active_start_date      := FND_API.G_MISS_DATE;
       l_org_unit_rec.active_end_date        := SYSDATE;
       l_org_unit_rec.context                := FND_API.G_MISS_CHAR;
       l_org_unit_rec.attribute1             := FND_API.G_MISS_CHAR ;
       l_org_unit_rec.attribute2             := FND_API.G_MISS_CHAR;
       l_org_unit_rec.attribute3             := FND_API.G_MISS_CHAR;
       l_org_unit_rec.attribute4             := FND_API.G_MISS_CHAR;
       l_org_unit_rec.attribute5             := FND_API.G_MISS_CHAR;
       l_org_unit_rec.attribute6             := FND_API.G_MISS_CHAR;
       l_org_unit_rec.attribute7             := FND_API.G_MISS_CHAR;
       l_org_unit_rec.attribute8             := FND_API.G_MISS_CHAR;
       l_org_unit_rec.attribute9             := FND_API.G_MISS_CHAR;
       l_org_unit_rec.attribute10            := FND_API.G_MISS_CHAR;
       l_org_unit_rec.attribute11            := FND_API.G_MISS_CHAR;
       l_org_unit_rec.attribute12            := FND_API.G_MISS_CHAR;
       l_org_unit_rec.attribute13            := FND_API.G_MISS_CHAR;
       l_org_unit_rec.attribute14            := FND_API.G_MISS_CHAR;
       l_org_unit_rec.attribute15            := FND_API.G_MISS_CHAR;
       l_org_unit_rec.object_version_number  := p_org_unit_rec.object_version_number;

    -- Call update org unit
        g_expire_flag  := 'Y';
            csi_organization_unit_pvt.update_organization_unit
            ( p_api_version         => p_api_version
             ,p_commit              => fnd_api.g_false
             ,p_init_msg_list       => p_init_msg_list
             ,p_validation_level    => p_validation_level
             ,p_org_unit_rec        => l_org_unit_rec
             ,p_txn_rec             => p_txn_rec
             ,x_return_status       => x_return_status
             ,x_msg_count           => x_msg_count
             ,x_msg_data            => x_msg_data
             ,p_lookup_tbl          => l_ou_lookup_tbl
             ,p_ou_count_rec        => l_ou_count_rec
             ,p_ou_id_tbl           => l_ou_id_tbl
            );

        g_expire_flag  := 'N';

                IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  l_msg_index := 1;
                  l_msg_count := x_msg_count;
                  WHILE l_msg_count > 0 LOOP
                       x_msg_data := FND_MSG_PUB.GET
                                      (l_msg_index,
                                     FND_API.G_FALSE      );

                       csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
                       l_msg_index := l_msg_index + 1;
                       l_msg_count := l_msg_count - 1;
                  END LOOP;
                  RAISE FND_API.G_EXC_ERROR;
                END IF;

    -- End of API body


    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;


    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get
        (p_count     =>     x_msg_count ,
          p_data     =>     x_msg_data
        );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        ROLLBACK TO expire_organization_unit;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
            (   p_count             =>      x_msg_count,
                p_data              =>      x_msg_data
            );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        ROLLBACK TO expire_organization_unit;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get
            (   p_count             =>      x_msg_count,
                p_data              =>      x_msg_data
            );

    WHEN OTHERS THEN

        ROLLBACK TO  expire_organization_unit;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level
            (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg
                (    g_pkg_name,
                    l_api_name
                 );
        END IF;

        FND_MSG_PUB.Count_And_Get
            (  p_count             =>      x_msg_count,
               p_data              =>      x_msg_data
            );

END expire_organization_unit;

/*--------------------------------------------------*/
/* procedure name: get_org_unit_history             */
/* description :  Gets organization history         */
/*                                                  */
/*--------------------------------------------------*/

PROCEDURE get_org_unit_history
 (    p_api_version                 IN      NUMBER
     ,p_commit                      IN      VARCHAR2
     ,p_init_msg_list               IN      VARCHAR2
     ,p_validation_level            IN      NUMBER
     ,p_transaction_id              IN      NUMBER
     ,x_org_unit_history_tbl            OUT NOCOPY csi_datastructures_pub.org_units_history_tbl
     ,x_return_status                   OUT NOCOPY VARCHAR2
     ,x_msg_count                       OUT NOCOPY NUMBER
     ,x_msg_data                        OUT NOCOPY VARCHAR2
 ) IS
     l_api_name      CONSTANT VARCHAR2(30)   := 'get_org_unit_history' ;
     l_api_version   CONSTANT NUMBER         := 1.0                       ;
     l_csi_debug_level        NUMBER                                      ;
     l_count                  NUMBER         := 0                         ;
     l_flag                   VARCHAR2(1)  :='N'                          ;
     l_org_unit_tbl           csi_datastructures_pub.org_units_header_tbl;
     i                        NUMBER :=1;

     CURSOR get_org_unit_hist(i_transaction_id   NUMBER)
     IS
     SELECT      oah.INSTANCE_OU_HISTORY_ID,
                 oah.INSTANCE_OU_ID        ,
                 oah.TRANSACTION_ID        ,
                 oah.OLD_OPERATING_UNIT_ID ,
                 oah.NEW_OPERATING_UNIT_ID ,
                 oah.OLD_RELATIONSHIP_TYPE_CODE,
                 oah.NEW_RELATIONSHIP_TYPE_CODE,
                 oah.OLD_ACTIVE_START_DATE,
                 oah.NEW_ACTIVE_START_DATE,
                 oah.OLD_ACTIVE_END_DATE,
                 oah.NEW_ACTIVE_END_DATE,
                 oah.OLD_CONTEXT       ,
                 oah.NEW_CONTEXT       ,
                 oah.OLD_ATTRIBUTE1    ,
                 oah.NEW_ATTRIBUTE1    ,
                 oah.OLD_ATTRIBUTE2    ,
                 oah.NEW_ATTRIBUTE2    ,
                 oah.OLD_ATTRIBUTE3    ,
                 oah.NEW_ATTRIBUTE3    ,
                 oah.OLD_ATTRIBUTE4    ,
                 oah.NEW_ATTRIBUTE4    ,
                 oah.OLD_ATTRIBUTE5    ,
                 oah.NEW_ATTRIBUTE5    ,
                 oah.OLD_ATTRIBUTE6    ,
                 oah.NEW_ATTRIBUTE6    ,
                 oah.OLD_ATTRIBUTE7    ,
                 oah.NEW_ATTRIBUTE7    ,
                 oah.OLD_ATTRIBUTE8    ,
                 oah.NEW_ATTRIBUTE8    ,
                 oah.OLD_ATTRIBUTE9    ,
                 oah.NEW_ATTRIBUTE9    ,
                 oah.OLD_ATTRIBUTE10   ,
                 oah.NEW_ATTRIBUTE10   ,
                 oah.OLD_ATTRIBUTE11   ,
                 oah.NEW_ATTRIBUTE11   ,
                 oah.OLD_ATTRIBUTE12   ,
                 oah.NEW_ATTRIBUTE12   ,
                 oah.OLD_ATTRIBUTE13   ,
                 oah.NEW_ATTRIBUTE13   ,
                 oah.OLD_ATTRIBUTE14   ,
                 oah.NEW_ATTRIBUTE14   ,
                 oah.OLD_ATTRIBUTE15   ,
                 oah.NEW_ATTRIBUTE15   ,
                 oah.FULL_DUMP_FLAG    ,
                 oah.OBJECT_VERSION_NUMBER,
                 oa.INSTANCE_ID
     FROM     csi_i_org_assignments_h oah,
              csi_i_org_assignments oa
     WHERE    oah.transaction_id = i_transaction_id
     AND      oah.instance_ou_id = oa.instance_ou_id;

BEGIN
        -- Standard Start of API savepoint
       -- SAVEPOINT   get_org_unit_history;


        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (    l_api_version           ,
                                                p_api_version           ,
                                                l_api_name              ,
                                                g_pkg_name              )
        THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- Check the profile option CSI_DEBUG_LEVEL for debug message reporting
        l_csi_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

        -- If CSI_DEBUG_LEVEL = 1 then dump the procedure name
        IF (l_csi_debug_level > 0) THEN
            csi_gen_utility_pvt.put_line( 'get_org_unit_history');
        END IF;

        -- If the debug level = 2 then dump all the parameters values.
        IF (l_csi_debug_level > 1) THEN
            csi_gen_utility_pvt.put_line(  'get_org_unit_history'   ||
                                                 p_api_version           ||'-'||
                                                 p_commit                ||'-'||
                                                 p_init_msg_list         ||'-'||
                                                 p_validation_level      ||'-'||
                                                 p_transaction_id               );
             -- dump the in parameter in the log file

        END IF;

        /***** srramakr commented for bug # 3304439
        -- Check for the profile option and enable trace
        l_flag:=csi_gen_utility_pvt.enable_trace(l_trace_flag => l_flag);
        -- End enable trace
        ****/

        -- Start API body

        FOR C1 IN  get_org_unit_hist(p_transaction_id)
        LOOP
                 x_org_unit_history_tbl(i).INSTANCE_OU_HISTORY_ID     :=  C1.INSTANCE_OU_HISTORY_ID;
                 x_org_unit_history_tbl(i).INSTANCE_OU_ID             :=  C1.INSTANCE_OU_ID;
                 x_org_unit_history_tbl(i).TRANSACTION_ID             :=  C1.TRANSACTION_ID;
                 x_org_unit_history_tbl(i).OLD_OPERATING_UNIT_ID      :=  C1.OLD_OPERATING_UNIT_ID;
                 x_org_unit_history_tbl(i).NEW_OPERATING_UNIT_ID      :=  C1.NEW_OPERATING_UNIT_ID;
                 x_org_unit_history_tbl(i).OLD_RELATIONSHIP_TYPE_CODE :=  C1.OLD_RELATIONSHIP_TYPE_CODE;
                 x_org_unit_history_tbl(i).NEW_RELATIONSHIP_TYPE_CODE :=  C1.NEW_RELATIONSHIP_TYPE_CODE;
                 x_org_unit_history_tbl(i).OLD_ACTIVE_START_DATE      :=  C1.OLD_ACTIVE_START_DATE;
                 x_org_unit_history_tbl(i).NEW_ACTIVE_START_DATE      :=  C1.NEW_ACTIVE_START_DATE;
                 x_org_unit_history_tbl(i).OLD_ACTIVE_END_DATE        :=  C1.OLD_ACTIVE_END_DATE;
                 x_org_unit_history_tbl(i).NEW_ACTIVE_END_DATE        :=  C1.NEW_ACTIVE_END_DATE;
                 x_org_unit_history_tbl(i).OLD_CONTEXT                :=  C1.OLD_CONTEXT;
                 x_org_unit_history_tbl(i).NEW_CONTEXT                :=  C1.NEW_CONTEXT;
                 x_org_unit_history_tbl(i).OLD_ATTRIBUTE1             :=  C1.OLD_ATTRIBUTE1;
                 x_org_unit_history_tbl(i).NEW_ATTRIBUTE1             :=  C1.NEW_ATTRIBUTE1;
                 x_org_unit_history_tbl(i).OLD_ATTRIBUTE2             :=  C1.OLD_ATTRIBUTE2;
                 x_org_unit_history_tbl(i).NEW_ATTRIBUTE2             :=  C1.NEW_ATTRIBUTE2;
                 x_org_unit_history_tbl(i).OLD_ATTRIBUTE3             :=  C1.OLD_ATTRIBUTE3;
                 x_org_unit_history_tbl(i).NEW_ATTRIBUTE3             :=  C1.NEW_ATTRIBUTE3;
                 x_org_unit_history_tbl(i).OLD_ATTRIBUTE4             :=  C1.OLD_ATTRIBUTE4;
                 x_org_unit_history_tbl(i).NEW_ATTRIBUTE4             :=  C1.NEW_ATTRIBUTE4;
                 x_org_unit_history_tbl(i).OLD_ATTRIBUTE5             :=  C1.OLD_ATTRIBUTE5;
                 x_org_unit_history_tbl(i).NEW_ATTRIBUTE5             :=  C1.NEW_ATTRIBUTE5;
                 x_org_unit_history_tbl(i).OLD_ATTRIBUTE6             :=  C1.OLD_ATTRIBUTE6;
                 x_org_unit_history_tbl(i).NEW_ATTRIBUTE6             :=  C1.NEW_ATTRIBUTE6;
                 x_org_unit_history_tbl(i).OLD_ATTRIBUTE7             :=  C1.OLD_ATTRIBUTE7;
                 x_org_unit_history_tbl(i).NEW_ATTRIBUTE7             :=  C1.NEW_ATTRIBUTE7;
                 x_org_unit_history_tbl(i).OLD_ATTRIBUTE8             :=  C1.OLD_ATTRIBUTE8;
                 x_org_unit_history_tbl(i).NEW_ATTRIBUTE8             :=  C1.NEW_ATTRIBUTE8;
                 x_org_unit_history_tbl(i).OLD_ATTRIBUTE9             :=  C1.OLD_ATTRIBUTE9;
                 x_org_unit_history_tbl(i).NEW_ATTRIBUTE9             :=  C1.NEW_ATTRIBUTE9;
                 x_org_unit_history_tbl(i).OLD_ATTRIBUTE10            :=  C1.OLD_ATTRIBUTE10;
                 x_org_unit_history_tbl(i).NEW_ATTRIBUTE10            :=  C1.NEW_ATTRIBUTE10;
                 x_org_unit_history_tbl(i).OLD_ATTRIBUTE11            :=  C1.OLD_ATTRIBUTE11;
                 x_org_unit_history_tbl(i).NEW_ATTRIBUTE11            :=  C1.NEW_ATTRIBUTE11;
                 x_org_unit_history_tbl(i).OLD_ATTRIBUTE12            :=  C1.OLD_ATTRIBUTE12;
                 x_org_unit_history_tbl(i).NEW_ATTRIBUTE12            :=  C1.NEW_ATTRIBUTE12;
                 x_org_unit_history_tbl(i).OLD_ATTRIBUTE13            :=  C1.OLD_ATTRIBUTE13;
                 x_org_unit_history_tbl(i).NEW_ATTRIBUTE13            :=  C1.NEW_ATTRIBUTE13;
                 x_org_unit_history_tbl(i).OLD_ATTRIBUTE14            :=  C1.OLD_ATTRIBUTE14;
                 x_org_unit_history_tbl(i).NEW_ATTRIBUTE14            :=  C1.NEW_ATTRIBUTE14;
                 x_org_unit_history_tbl(i).OLD_ATTRIBUTE15            :=  C1.OLD_ATTRIBUTE15;
                 x_org_unit_history_tbl(i).NEW_ATTRIBUTE15            :=  C1.NEW_ATTRIBUTE15;
                 x_org_unit_history_tbl(i).FULL_DUMP_FLAG             :=  C1.FULL_DUMP_FLAG;
                 x_org_unit_history_tbl(i).OBJECT_VERSION_NUMBER      :=  C1.OBJECT_VERSION_NUMBER;
                 x_org_unit_history_tbl(i).INSTANCE_ID                :=  C1.INSTANCE_ID;

                 IF x_org_unit_history_tbl(i).old_operating_unit_id IS NOT NULL
                 THEN
                    l_org_unit_tbl(1).operating_unit_id := x_org_unit_history_tbl(i).old_operating_unit_id;
                    csi_organization_unit_pvt.Resolve_id_columns(l_org_unit_tbl);
                    x_org_unit_history_tbl(i).old_operating_unit_name := l_org_unit_tbl(1).operating_unit_name;
                 END IF;
                 IF x_org_unit_history_tbl(i).new_operating_unit_id IS NOT NULL
                 THEN
                    l_org_unit_tbl(1).operating_unit_id := x_org_unit_history_tbl(i).new_operating_unit_id;
                    csi_organization_unit_pvt.Resolve_id_columns(l_org_unit_tbl);
                    x_org_unit_history_tbl(i).new_operating_unit_name := l_org_unit_tbl(1).operating_unit_name;
                 END IF;

                 i := i + 1;

        END LOOP;



        -- End of API body

        -- Standard check of p_commit.
        /*
        IF FND_API.To_Boolean( p_commit ) THEN
          COMMIT WORK;
        END IF;
        */


        -- Standard call to get message count and if count is  get message info.
        FND_MSG_PUB.Count_And_Get
            (p_count     =>     x_msg_count,
              p_data     =>     x_msg_data
            );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

      --  ROLLBACK TO get_org_unit_history;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
            (   p_count             =>      x_msg_count,
                p_data              =>      x_msg_data
            );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

       -- ROLLBACK TO get_org_unit_history;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get
            (   p_count             =>      x_msg_count,
                p_data              =>      x_msg_data
            );

    WHEN OTHERS THEN

       -- ROLLBACK TO  get_org_unit_history;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level
            (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg
                (    g_pkg_name,
                    l_api_name
                 );
        END IF;

        FND_MSG_PUB.Count_And_Get
            (  p_count             =>      x_msg_count,
               p_data              =>      x_msg_data
            );

END get_org_unit_history;




END csi_organization_unit_pvt;

/
