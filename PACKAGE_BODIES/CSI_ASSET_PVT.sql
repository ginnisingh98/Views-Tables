--------------------------------------------------------
--  DDL for Package Body CSI_ASSET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_ASSET_PVT" AS
/* $Header: csivaab.pls 120.18 2006/11/17 06:38:37 sumathur noship $ */

  g_pkg_name  varchar2(30) := 'CSI_ASSET_PVT';

  PROCEDURE debug( p_message IN varchar2) IS
  BEGIN
    csi_gen_utility_pvt.put_line(p_message);
  EXCEPTION
    WHEN others THEN null;
  END debug;

  /*----------------------------------------------------------*/
  /* Procedure name:  Initialize_asset_rec                    */
  /* Description : This procudure recontructs the record      */
  /*                 from the history                         */
  /*----------------------------------------------------------*/
  PROCEDURE Initialize_asset_rec_no_dump (
    x_instance_asset_rec          IN OUT NOCOPY csi_datastructures_pub.instance_asset_header_rec,
    p_inst_asset_id               IN NUMBER ,
    x_no_dump           IN OUT NOCOPY DATE)
  IS

    CURSOR Int_no_dump(p_inst_ass_id IN NUMBER ) IS
      SELECT creation_date,
             INSTANCE_ASSET_ID,
             NEW_INSTANCE_ID,
             NEW_FA_ASSET_ID,
             NEW_ASSET_QUANTITY,
             NEW_FA_BOOK_TYPE_CODE,
             NEW_FA_LOCATION_ID,
             NEW_UPDATE_STATUS,
             NEW_ACTIVE_START_DATE,
             NEW_ACTIVE_END_DATE,
             FULL_DUMP_FLAG,
             OBJECT_VERSION_NUMBER
      FROM   CSI_I_ASSETS_H
      WHERE  instance_asset_id = p_inst_ass_id
      ORDER  by creation_date;

  BEGIN
    FOR C1 IN Int_no_dump(p_inst_asset_id  ) LOOP
      IF Int_no_dump%ROWCOUNT = 1 THEN
        x_no_dump                               := C1.creation_date;
        x_instance_asset_rec.FA_ASSET_ID        := C1.NEW_FA_ASSET_ID;
        x_instance_asset_rec.ASSET_QUANTITY     := C1.NEW_ASSET_QUANTITY;
        x_instance_asset_rec.FA_BOOK_TYPE_CODE  := C1.NEW_FA_BOOK_TYPE_CODE;
        x_instance_asset_rec.FA_LOCATION_ID     := C1.NEW_FA_LOCATION_ID;
        x_instance_asset_rec.UPDATE_STATUS      := C1.NEW_UPDATE_STATUS;
        x_instance_asset_rec.ACTIVE_START_DATE  := C1.NEW_ACTIVE_START_DATE;
        x_instance_asset_rec.ACTIVE_END_DATE    := C1.NEW_ACTIVE_END_DATE;
      ELSE
        EXIT;
      END IF;
    END LOOP;
  END Initialize_asset_rec_no_dump ;

/*----------------------------------------------------------*/
/* Procedure name:  Initialize_asset_rec                    */
/* Description : This procudure recontructs the record      */
/*                 from the history                         */
/*----------------------------------------------------------*/

PROCEDURE Initialize_asset_rec
(
  x_instance_asset_rec          IN OUT NOCOPY csi_datastructures_pub.instance_asset_header_rec,
  p_inst_asset_hist_id          IN NUMBER ,
  x_nearest_full_dump           IN OUT NOCOPY DATE
  ) IS

CURSOR Int_nearest_full_dump(p_inst_ass_hist_id IN NUMBER ) IS
SELECT
 CREATION_DATE                ,
 INSTANCE_ASSET_ID            ,
 NEW_INSTANCE_ID              ,
 NEW_FA_ASSET_ID              ,
 NEW_ASSET_QUANTITY           ,
 NEW_FA_BOOK_TYPE_CODE        ,
 NEW_FA_LOCATION_ID           ,
 NEW_UPDATE_STATUS            ,
 NEW_ACTIVE_START_DATE        ,
 NEW_ACTIVE_END_DATE          ,
 FULL_DUMP_FLAG               ,
 OBJECT_VERSION_NUMBER
FROM CSI_I_ASSETS_H
WHERE instance_asset_history_id = p_inst_ass_hist_id
  and  full_dump_flag = 'Y' ;

BEGIN
  FOR C1 IN Int_nearest_full_dump(p_inst_asset_hist_id  ) LOOP
     x_nearest_full_dump                     := C1.creation_date;
     x_instance_asset_rec.FA_ASSET_ID        := C1.NEW_FA_ASSET_ID;
     x_instance_asset_rec.ASSET_QUANTITY     := C1.NEW_ASSET_QUANTITY;
     x_instance_asset_rec.FA_BOOK_TYPE_CODE  := C1.NEW_FA_BOOK_TYPE_CODE;
     x_instance_asset_rec.FA_LOCATION_ID     := C1.NEW_FA_LOCATION_ID;
     x_instance_asset_rec.UPDATE_STATUS      := C1.NEW_UPDATE_STATUS;
     x_instance_asset_rec.ACTIVE_START_DATE  := C1.NEW_ACTIVE_START_DATE;
     x_instance_asset_rec.ACTIVE_END_DATE    := C1.NEW_ACTIVE_END_DATE;

  END LOOP;
END Initialize_asset_rec ;


  PROCEDURE set_fa_sync_flag (
    px_instance_asset_rec IN OUT NOCOPY csi_datastructures_pub.instance_asset_rec,
    p_location_id         IN NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_error_msg           OUT NOCOPY VARCHAR2)
  IS
    l_mapped_fa_location_id NUMBER ;
    l_cii_location_id       NUMBER;
    l_tot_fa_loc_units      NUMBER ;
    l_synced_fa_loc_units   NUMBER ;
    l_cii_location          VARCHAR2(2000);
    l_fa_location           VARCHAR2(240);
    l_sync_up_flag          VARCHAR2(1);
    --
    -- Modified the query to look at the Mapping of Item Instance Location with FA Location.
    -- Since Asset linking will be done only with the Item Instances that are at HZ or HR Locations
    -- and these ID's are derived from the same Database sequence, the query has been simplified.
    --
    -- Following cursor will be used if p_location_id is not passed.
    CURSOR csi_location_cur IS
      SELECT decode(cii.location_type_code,'HZ_PARTY_SITES',
                      (select hzp.location_id
                       from hz_party_sites hzp
                       where hzp.party_site_id = cii.location_id),cii.location_id) cii_location_id
      FROM csi_item_instances cii
      WHERE  cii.instance_id = px_instance_asset_rec.instance_id;
    --
    CURSOR csi_a_location_cur IS
      SELECT fa_location_id
      FROM   csi_a_locations
      WHERE  location_id = l_cii_location_id;

    CURSOR fa_location_units_cur IS
      SELECT SUM(fdh.units_assigned)
      FROM   fa_distribution_history fdh
      WHERE  fdh.asset_id = px_instance_asset_rec.fa_asset_id
      AND    fdh.date_ineffective is null
      AND    fdh.location_id = px_instance_asset_rec.fa_location_id  ;

    CURSOR synced_fa_loc_units_cur IS
      SELECT SUM(cia.asset_quantity)
      FROM   csi_i_assets cia
      WHERE  cia.fa_asset_id    = px_instance_asset_rec.fa_asset_id
      AND    cia.fa_location_id = px_instance_asset_rec.fa_location_id
      AND    cia.asset_quantity > 0
      AND    sysdate between nvl(cia.active_start_date, sysdate-1) and nvl(cia.active_end_date, sysdate+1)
      AND    cia.update_status  = 'IN_SERVICE'
      AND    cia.fa_sync_flag   = 'Y' ;

      CURSOR inst_sync_over_cur IS
      SELECT cia.fa_sync_flag
      FROM   csi_i_assets cia
      WHERE  cia.fa_asset_id    = px_instance_asset_rec.fa_asset_id
      AND    cia.fa_location_id = px_instance_asset_rec.fa_location_id
      AND    cia.instance_id = px_instance_asset_rec.instance_id
      AND    cia.asset_quantity > 0
      AND    sysdate between nvl(cia.active_start_date, sysdate-1) and nvl(cia.active_end_date, sysdate+1)
      AND    cia.update_status  = 'IN_SERVICE';



  BEGIN
    x_return_status := fnd_api.G_RET_STS_SUCCESS ;

    debug('set_fa_sync_flag');

     OPEN inst_sync_over_cur;
     FETCH inst_sync_over_cur
     INTO l_sync_up_flag ;
     CLOSE  inst_sync_over_cur;

   IF  (NVL(l_sync_up_flag,'N') = 'Y') THEN
         px_instance_asset_rec.fa_sync_flag := 'Y';
   ELSE
    IF nvl(p_location_id,-9999) = -9999 THEN -- Gets passed only from GRP API (Create)
       OPEN csi_location_cur;
       FETCH csi_location_cur
       INTO l_cii_location_id;
       CLOSE csi_location_cur;
    ELSE
       l_cii_location_id := p_location_id;
    END IF;
    --
    OPEN  csi_a_location_cur ;
    FETCH  csi_a_location_cur
    INTO l_mapped_fa_location_id;
    CLOSE  csi_a_location_cur ;
    --



    csi_gen_utility_pvt.put_line('Mapp FA Loc ID : '|| l_mapped_fa_location_id);
    IF px_instance_asset_rec.fa_location_id <> NVL(l_mapped_fa_location_id ,0) THEN
      px_instance_asset_rec.fa_sync_flag := 'N' ;
      -- Resolve FA Location
      Begin
        select concatenated_segments
        into l_fa_location
        from FA_LOCATIONS_KFV
        where location_id = px_instance_asset_rec.fa_location_id;
     Exception
       when no_data_found then
         null;
     End;

     --
     -- Resolve CII Location
     Begin
       select location_code
       into l_cii_location
       from HR_LOCATIONS_ALL
       where location_id = l_cii_location_id;
       --
       FND_MESSAGE.SET_NAME('CSI','CSI_FA_HR_LOCATION_MAP');
       FND_MESSAGE.SET_TOKEN('FA_LOCATION',l_fa_location);
       FND_MESSAGE.SET_TOKEN('HR_LOCATION',l_cii_location);
       FND_MSG_PUB.Add;
     Exception
       when no_data_found then
         Begin
           select address1||','||address2||','||address3||','||address4||','||city||','||state||','||postal_code||','||country
         into l_cii_location
         from HZ_LOCATIONS
         where location_id = l_cii_location_id;
                --
         FND_MESSAGE.SET_NAME('CSI','CSI_FA_HZ_LOCATION_MAP');
         FND_MESSAGE.SET_TOKEN('FA_LOCATION',l_fa_location);
         FND_MESSAGE.SET_TOKEN('HZ_LOCATION',l_cii_location);
         FND_MSG_PUB.Add;
       Exception
         when no_data_found then
           null;
       End;
     End;
   ELSE

     OPEN  fa_location_units_cur ;
     FETCH fa_location_units_cur INTO l_tot_fa_loc_units ;
     CLOSE fa_location_units_cur ;

     OPEN  synced_fa_loc_units_cur ;
     FETCH synced_fa_loc_units_cur INTO l_synced_fa_loc_units ;
     CLOSE synced_fa_loc_units_cur ;

     IF NVL(l_tot_fa_loc_units,0) >= NVL(l_synced_fa_loc_units,0) +
       NVL(px_instance_asset_rec.asset_quantity,0)
     THEN
       px_instance_asset_rec.fa_sync_flag := 'Y' ;
     ELSE
       px_instance_asset_rec.fa_sync_flag := 'N' ;
       FND_MESSAGE.SET_NAME('CSI','CSI_FA_CIA_UNITS_MISMATCH');
       FND_MSG_PUB.Add;
     END IF ;
   END IF ; --px_instance_asset_rec.fa_location_id <> l_mapped_fa_location_id ;
END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.G_RET_STS_ERROR ;
  END set_fa_sync_flag;

/*----------------------------------------------------------*/
/* Procedure name:  Construct_asset_from_hist               */
/* Description : This procudure recontructs the record      */
/*                 from the history                         */
/*----------------------------------------------------------*/

PROCEDURE Construct_asset_from_hist
(
  x_instance_asset_tbl      IN OUT NOCOPY csi_datastructures_pub.instance_asset_header_tbl,
  p_time_stamp              IN DATE
   ) IS

l_nearest_full_dump      DATE := p_time_stamp;
l_inst_asset_history_id   NUMBER;
l_instance_asset_tbl     csi_datastructures_pub.instance_asset_header_tbl;
l_asset_count            NUMBER := 0;
--
Process_next             EXCEPTION;


CURSOR get_nearest_full_dump(p_asset_id IN NUMBER ,p_time IN DATE) IS
SELECT
   MAX(instance_asset_history_id)
 FROM CSI_I_ASSETS_H
WHERE  creation_date <= p_time
  and  instance_asset_id = p_asset_id
  and  full_dump_flag = 'Y';

CURSOR get_asset_label_hist(p_asset_id IN NUMBER ,
                            p_nearest_full_dump IN DATE,
                            p_time IN DATE ) IS
SELECT
 INSTANCE_ASSET_ID            ,
 TRANSACTION_ID               ,
 OLD_INSTANCE_ID              ,
 NEW_INSTANCE_ID              ,
 OLD_FA_ASSET_ID              ,
 NEW_FA_ASSET_ID              ,
 OLD_ASSET_QUANTITY           ,
 NEW_ASSET_QUANTITY           ,
 OLD_FA_BOOK_TYPE_CODE        ,
 NEW_FA_BOOK_TYPE_CODE        ,
 OLD_FA_LOCATION_ID           ,
 NEW_FA_LOCATION_ID           ,
 OLD_UPDATE_STATUS            ,
 NEW_UPDATE_STATUS            ,
 FULL_DUMP_FLAG               ,
 OLD_ACTIVE_START_DATE        ,
 NEW_ACTIVE_START_DATE        ,
 OLD_ACTIVE_END_DATE          ,
 NEW_ACTIVE_END_DATE          ,
 OBJECT_VERSION_NUMBER
FROM CSI_I_ASSETS_H
WHERE  creation_date <= p_time
 and   creation_date >= p_nearest_full_dump
 and   instance_asset_id = p_asset_id
 ORDER BY creation_date;

 l_time_stamp   DATE := p_time_stamp;

BEGIN
l_instance_asset_tbl := x_instance_asset_tbl;
IF l_instance_asset_tbl.COUNT > 0 THEN

FOR i IN l_instance_asset_tbl.FIRST..l_instance_asset_tbl.LAST LOOP
BEGIN
  OPEN get_nearest_full_dump(l_instance_asset_tbl(i).instance_asset_id, p_time_stamp);
  FETCH get_nearest_full_dump INTO l_inst_asset_history_id;
  CLOSE get_nearest_full_dump;

  IF l_inst_asset_history_id IS NOT NULL THEN
     Initialize_asset_rec( l_instance_asset_tbl(i), l_inst_asset_history_id ,l_nearest_full_dump);
  ELSE
     Initialize_asset_rec_no_dump(l_instance_asset_tbl(i), l_instance_asset_tbl(i).instance_asset_id, l_time_stamp);

           l_nearest_full_dump :=  l_time_stamp;
           -- If the user chooses a date before the creation date of the instance
           -- then raise an error
           IF p_time_stamp < l_time_stamp THEN
              -- Messages Commented for bug 2423342. Records that do not qualify should get deleted.
              -- FND_MESSAGE.SET_NAME('CSI','CSI_H_DATE_BEFORE_CRE_DATE');
              -- FND_MESSAGE.SET_TOKEN('CREATION_DATE',to_char(l_time_stamp, 'DD-MON-YYYY HH24:MI:SS'));
              -- FND_MESSAGE.SET_TOKEN('USER_DATE',to_char(p_time_stamp, 'DD-MON-YYYY HH24:MI:SS'));
              -- FND_MSG_PUB.Add;
              l_instance_asset_tbl.DELETE(i);
              RAISE Process_next;
           END IF;

  END IF;

  FOR C2 IN get_asset_label_hist(l_instance_asset_tbl(i).instance_asset_id, l_nearest_full_dump, p_time_stamp ) LOOP


   IF (C2.OLD_FA_ASSET_ID IS NULL AND C2.NEW_FA_ASSET_ID IS NOT NULL)
   OR (C2.OLD_FA_ASSET_ID IS NOT NULL AND C2.NEW_FA_ASSET_ID IS NULL)
   OR (C2.OLD_FA_ASSET_ID <> C2.NEW_FA_ASSET_ID) THEN
        l_instance_asset_tbl(i).FA_ASSET_ID := C2.NEW_FA_ASSET_ID;
   END IF;

   IF (C2.OLD_ASSET_QUANTITY IS NULL AND C2.NEW_ASSET_QUANTITY IS NOT NULL)
   OR (C2.OLD_ASSET_QUANTITY IS NOT NULL AND C2.NEW_ASSET_QUANTITY IS NULL)
   OR (C2.OLD_ASSET_QUANTITY <> C2.NEW_ASSET_QUANTITY) THEN
        l_instance_asset_tbl(i).ASSET_QUANTITY := C2.NEW_ASSET_QUANTITY;
   END IF;

   IF (C2.OLD_FA_BOOK_TYPE_CODE IS NULL AND C2.NEW_FA_BOOK_TYPE_CODE IS NOT NULL)
   OR (C2.OLD_FA_BOOK_TYPE_CODE IS NOT NULL AND C2.NEW_FA_BOOK_TYPE_CODE IS NULL)
   OR (C2.OLD_FA_BOOK_TYPE_CODE <> C2.NEW_FA_BOOK_TYPE_CODE) THEN
        l_instance_asset_tbl(i).FA_BOOK_TYPE_CODE := C2.NEW_FA_BOOK_TYPE_CODE;
   END IF;

   IF (C2.OLD_FA_LOCATION_ID IS NULL AND C2.NEW_FA_LOCATION_ID IS NOT NULL)
   OR (C2.OLD_FA_LOCATION_ID IS NOT NULL AND C2.NEW_FA_LOCATION_ID IS NULL)
   OR (C2.OLD_FA_LOCATION_ID <> C2.NEW_FA_LOCATION_ID) THEN
        l_instance_asset_tbl(i).FA_LOCATION_ID := C2.NEW_FA_LOCATION_ID;
   END IF;

   IF (C2.OLD_UPDATE_STATUS IS NULL AND C2.NEW_UPDATE_STATUS IS NOT NULL)
   OR (C2.OLD_UPDATE_STATUS IS NOT NULL AND C2.NEW_UPDATE_STATUS IS NULL)
   OR (C2.OLD_UPDATE_STATUS <> C2.NEW_UPDATE_STATUS) THEN
        l_instance_asset_tbl(i).UPDATE_STATUS := C2.NEW_UPDATE_STATUS;
   END IF;

   IF (C2.OLD_ACTIVE_START_DATE IS NULL AND C2.NEW_ACTIVE_START_DATE IS NOT NULL)
   OR (C2.OLD_ACTIVE_START_DATE IS NOT NULL AND C2.NEW_ACTIVE_START_DATE IS NULL)
   OR (C2.OLD_ACTIVE_START_DATE <> C2.NEW_ACTIVE_START_DATE) THEN
         l_instance_asset_tbl(i).ACTIVE_START_DATE := C2.NEW_ACTIVE_START_DATE;
   END IF;


   IF (C2.OLD_ACTIVE_END_DATE IS NULL AND C2.NEW_ACTIVE_END_DATE IS NOT NULL)
   OR (C2.OLD_ACTIVE_END_DATE IS NOT NULL AND C2.NEW_ACTIVE_END_DATE IS NULL)
   OR (C2.OLD_ACTIVE_END_DATE <> C2.NEW_ACTIVE_END_DATE) THEN
         l_instance_asset_tbl(i).ACTIVE_END_DATE := C2.NEW_ACTIVE_END_DATE;
   END IF;


  END LOOP;
 EXCEPTION
   WHEN Process_next THEN
      NULL;
 END;
 END LOOP;
 x_instance_asset_tbl.DELETE;
 IF l_instance_asset_tbl.count > 0 THEN
    FOR asset_row in l_instance_asset_tbl.FIRST .. l_instance_asset_tbl.LAST
    LOOP
       IF l_instance_asset_tbl.EXISTS(asset_row) THEN
          l_asset_count := l_asset_count + 1;
          x_instance_asset_tbl(l_asset_count) := l_instance_asset_tbl(asset_row);
       END IF;
    END LOOP;
 END IF;
END IF;

END Construct_asset_from_hist;

/*----------------------------------------------------------*/
/* Procedure name:  Resolve_id_columns                      */
/* Description : This procudure gets the descriptions for   */
/*               id columns                                 */
/*----------------------------------------------------------*/

PROCEDURE  Resolve_id_columns
            (p_asset_header_tbl  IN OUT NOCOPY   csi_datastructures_pub.instance_asset_header_tbl)

IS
l_code_combination_id NUMBER;
l_assigned_to         NUMBER;
   BEGIN
       l_code_combination_id := NULL;
       l_assigned_to         := NULL;
       FOR tab_row in p_asset_header_tbl.FIRST..p_asset_header_tbl.LAST
         LOOP

         /* The following code has been commented for sql performance repository bug 4896250 */
         /*
          BEGIN
             SELECT b.asset_number
                   ,b.serial_number
                   ,b.tag_number
                   ,d.concatenated_segments category
                   ,e.date_placed_in_service
                   ,b.description
                   ,f.name
                   ,g.concatenated_segments
             INTO   p_asset_header_tbl(tab_row).asset_number
                   ,p_asset_header_tbl(tab_row).serial_number
                   ,p_asset_header_tbl(tab_row).tag_number
                   ,p_asset_header_tbl(tab_row).category
                   ,p_asset_header_tbl(tab_row).date_placed_in_service
                   ,p_asset_header_tbl(tab_row).description
                   ,p_asset_header_tbl(tab_row).employee_name
                   ,p_asset_header_tbl(tab_row).expense_account_number
             FROM   fa_additions_vl b
                   ,fa_distribution_history c
                   ,fa_categories_b_kfv d
                   ,fa_books e
                   ,fa_employees f
                   ,gl_code_combinations_kfv g
             WHERE  b.asset_id = c.asset_id
             AND    b.asset_category_id = d.category_id
             AND    b.asset_id = e.asset_id
             AND    c.book_type_code = e.book_type_code
             AND    c.assigned_to = f.employee_id(+)
             AND    c.code_combination_id = g.code_combination_id
             --AND    c.date_ineffective IS NULL -- Commented for bug 4206038
             -- Added for Bug: 3903805
             --AND    e.date_ineffective IS NULL -- Commented for bug 4206038
             AND    e.book_type_code = p_asset_header_tbl(tab_row).fa_book_type_code
             AND    c.location_id = p_asset_header_tbl(tab_row).fa_location_id
             -- End of addition for Bug: 3903805
             AND    b.asset_id = p_asset_header_tbl(tab_row).fa_asset_id
             AND    rownum < 2; -- Added for Bug: 3903805
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;
          */

           BEGIN
             SELECT b.asset_number
                   ,b.serial_number
                   ,b.tag_number
                   ,d.concatenated_segments category
                   ,e.date_placed_in_service
                   ,b.description
                   ,c.code_combination_id
                   ,c.assigned_to
             INTO   p_asset_header_tbl(tab_row).asset_number
                   ,p_asset_header_tbl(tab_row).serial_number
                   ,p_asset_header_tbl(tab_row).tag_number
                   ,p_asset_header_tbl(tab_row).category
                   ,p_asset_header_tbl(tab_row).date_placed_in_service
                   ,p_asset_header_tbl(tab_row).description
                   ,l_code_combination_id
                   ,l_assigned_to
             FROM   fa_additions_vl b
                   ,fa_distribution_history c
                   ,fa_categories_b_kfv d
                   ,fa_books e
             WHERE  b.asset_id = c.asset_id
             AND    b.asset_category_id = d.category_id
             AND    b.asset_id = e.asset_id
             AND    c.book_type_code = e.book_type_code
             AND    e.book_type_code = p_asset_header_tbl(tab_row).fa_book_type_code
             AND    c.location_id = p_asset_header_tbl(tab_row).fa_location_id
             AND    b.asset_id = p_asset_header_tbl(tab_row).fa_asset_id
             AND    rownum < 2;
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;


         BEGIN
             SELECT concatenated_segments
               INTO p_asset_header_tbl(tab_row).expense_account_number
               FROM gl_code_combinations_kfv
              WHERE code_combination_id = l_code_combination_id;
              l_code_combination_id:=NULL;
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;

          BEGIN
             SELECT name
               INTO p_asset_header_tbl(tab_row).employee_name
               FROM fa_employees
              WHERE employee_id=l_assigned_to
                AND rownum<2;
                l_assigned_to:=NULL;
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;

        -- asset location validation
          BEGIN
            SELECT segment1,
                   segment2,
                   segment3,
                   segment4,
                   segment5,
                   segment6,
                   segment7
            INTO   p_asset_header_tbl(tab_row).fa_location_segment1,
                   p_asset_header_tbl(tab_row).fa_location_segment2,
                   p_asset_header_tbl(tab_row).fa_location_segment3,
                   p_asset_header_tbl(tab_row).fa_location_segment4,
                   p_asset_header_tbl(tab_row).fa_location_segment5,
                   p_asset_header_tbl(tab_row).fa_location_segment6,
                   p_asset_header_tbl(tab_row).fa_location_segment7
            FROM   fa_locations
            WHERE  location_id = p_asset_header_tbl(tab_row).fa_location_id;
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;
        END LOOP;
END Resolve_id_columns;

/*----------------------------------------------------------*/
/* Procedure name:  Get_Asset_Column_Values                 */
/* Description : This procudure gets the column values      */
/*                        for the Dynamic SQL               */
/*----------------------------------------------------------*/

PROCEDURE Get_Asset_Column_Values
(
    p_get_asset_cursor_id    IN   NUMBER      ,
    x_inst_asset_rec         OUT NOCOPY  csi_datastructures_pub.instance_asset_header_rec
    )IS
BEGIN

 dbms_sql.column_value(p_get_asset_cursor_id, 1, x_inst_asset_rec.instance_asset_id);
 dbms_sql.column_value(p_get_asset_cursor_id, 2, x_inst_asset_rec.instance_id);
 dbms_sql.column_value(p_get_asset_cursor_id, 3, x_inst_asset_rec.fa_asset_id);
 dbms_sql.column_value(p_get_asset_cursor_id, 4, x_inst_asset_rec.fa_book_type_code );
 dbms_sql.column_value(p_get_asset_cursor_id, 5, x_inst_asset_rec.fa_location_id);
 dbms_sql.column_value(p_get_asset_cursor_id, 6, x_inst_asset_rec.asset_quantity);
 dbms_sql.column_value(p_get_asset_cursor_id, 7, x_inst_asset_rec.update_status);
 dbms_sql.column_value(p_get_asset_cursor_id, 8, x_inst_asset_rec.active_start_date);
 dbms_sql.column_value(p_get_asset_cursor_id, 9, x_inst_asset_rec.active_end_date);
 dbms_sql.column_value(p_get_asset_cursor_id, 10, x_inst_asset_rec.object_version_number);

 END Get_Asset_Column_Values;


/*----------------------------------------------------------*/
/* Procedure name:  Define_Asset_Columns                    */
/* Description : This procudure defines the columns         */
/*                        for the Dynamic SQL               */
/*----------------------------------------------------------*/

PROCEDURE Define_Asset_Columns
(
    p_get_asset_cursor_id      IN   NUMBER
    ) IS

  l_inst_asset_rec  csi_datastructures_pub.instance_asset_header_rec;

BEGIN

 dbms_sql.define_column(p_get_asset_cursor_id, 1, l_inst_asset_rec.instance_asset_id);
 dbms_sql.define_column(p_get_asset_cursor_id, 2, l_inst_asset_rec.instance_id);
 dbms_sql.define_column(p_get_asset_cursor_id, 3, l_inst_asset_rec.fa_asset_id);
 dbms_sql.define_column(p_get_asset_cursor_id, 4, l_inst_asset_rec.fa_book_type_code,30 );
 dbms_sql.define_column(p_get_asset_cursor_id, 5, l_inst_asset_rec.fa_location_id);
 dbms_sql.define_column(p_get_asset_cursor_id, 6, l_inst_asset_rec.asset_quantity);
 dbms_sql.define_column(p_get_asset_cursor_id, 7, l_inst_asset_rec.update_status,30);
 dbms_sql.define_column(p_get_asset_cursor_id, 8, l_inst_asset_rec.active_start_date);
 dbms_sql.define_column(p_get_asset_cursor_id, 9, l_inst_asset_rec.active_end_date);
 dbms_sql.define_column(p_get_asset_cursor_id, 10, l_inst_asset_rec.object_version_number);

END Define_Asset_Columns;

/*----------------------------------------------------------*/
/* Procedure name:  Bind_asset_variable                     */
/* Description : Procedure used to  generate the where      */
/*                cluase  for Party relationship            */
/*----------------------------------------------------------*/

PROCEDURE Bind_asset_variable
(
    p_inst_asset_query_rec   IN    csi_datastructures_pub.instance_asset_query_rec,
    p_get_asset_cursor_id    IN    NUMBER
    )IS

BEGIN
 IF( (p_inst_asset_query_rec.instance_asset_id IS NOT NULL)
                  AND (p_inst_asset_query_rec.instance_asset_id <> FND_API.G_MISS_NUM))  THEN
    DBMS_SQL.BIND_VARIABLE(p_get_asset_cursor_id, ':instance_asset_id', p_inst_asset_query_rec.instance_asset_id);
 END IF;

 IF( (p_inst_asset_query_rec.instance_id IS NOT NULL)
                  AND (p_inst_asset_query_rec.instance_id <> FND_API.G_MISS_NUM))  THEN
    DBMS_SQL.BIND_VARIABLE(p_get_asset_cursor_id, ':instance_id', p_inst_asset_query_rec.instance_id);
 END IF;

 IF( (p_inst_asset_query_rec.fa_asset_id IS NOT NULL)
                  AND (p_inst_asset_query_rec.fa_asset_id <> FND_API.G_MISS_NUM))  THEN
    DBMS_SQL.BIND_VARIABLE(p_get_asset_cursor_id, ':fa_asset_id', p_inst_asset_query_rec.fa_asset_id);
 END IF;

 IF( (p_inst_asset_query_rec.fa_book_type_code IS NOT NULL)
                  AND (p_inst_asset_query_rec.fa_book_type_code <> FND_API.G_MISS_CHAR))  THEN
    DBMS_SQL.BIND_VARIABLE(p_get_asset_cursor_id, ':fa_book_type_code', p_inst_asset_query_rec.fa_book_type_code);
 END IF;

 IF( (p_inst_asset_query_rec.fa_location_id IS NOT NULL)
                  AND (p_inst_asset_query_rec.fa_location_id <> FND_API.G_MISS_NUM))  THEN
    DBMS_SQL.BIND_VARIABLE(p_get_asset_cursor_id, ':fa_location_id', p_inst_asset_query_rec.fa_location_id);
 END IF;
 IF( (p_inst_asset_query_rec.update_status IS NOT NULL)
                  AND (p_inst_asset_query_rec.update_status <> FND_API.G_MISS_CHAR))  THEN
    DBMS_SQL.BIND_VARIABLE(p_get_asset_cursor_id, ':update_status', p_inst_asset_query_rec.update_status);
 END IF;

END Bind_asset_variable;


/*----------------------------------------------------------*/
/* Procedure name:  Gen_Asset_Where_Clause                  */
/* Description : Procedure used to  generate the where      */
/*                cluase  for Party relationship            */
/*----------------------------------------------------------*/

PROCEDURE Gen_Asset_Where_Clause
(   p_inst_asset_query_rec     IN    csi_datastructures_pub.instance_asset_query_rec
   ,x_where_clause             OUT NOCOPY   VARCHAR2
  ) IS

BEGIN
 -- Assign null at the start
 x_where_clause := '';

IF (( p_inst_asset_query_rec.instance_asset_id  IS NOT NULL)  AND
        ( p_inst_asset_query_rec.instance_asset_id  <> FND_API.G_MISS_NUM)) THEN
        x_where_clause := ' instance_asset_id = :instance_asset_id ';
ELSIF ( p_inst_asset_query_rec.instance_asset_id  IS  NULL) THEN
        x_where_clause := ' instance_asset_id IS NULL ';
END IF;

IF ((p_inst_asset_query_rec.instance_id IS NOT NULL)  AND
      (p_inst_asset_query_rec.instance_id <> FND_API.G_MISS_NUM))   THEN
        IF x_where_clause IS NULL THEN
            x_where_clause := ' instance_id = :instance_id ';
        ELSE
            x_where_clause := x_where_clause||' AND '||' instance_id = :instance_id ';
        END IF;
ELSIF (p_inst_asset_query_rec.instance_id IS  NULL) THEN
        IF x_where_clause IS NULL THEN
            x_where_clause := ' instance_id IS NULL ';
        ELSE
            x_where_clause := x_where_clause||' AND '||' instance_id IS NULL ';
        END IF;
END IF;

IF ((p_inst_asset_query_rec.fa_asset_id   IS NOT NULL)  AND
          (p_inst_asset_query_rec.fa_asset_id  <> FND_API.G_MISS_NUM)) THEN
        IF x_where_clause IS NULL THEN
            x_where_clause := ' fa_asset_id = :fa_asset_id ';
        ELSE
            x_where_clause := x_where_clause||' AND '||' fa_asset_id = :fa_asset_id ';
        END IF;
ELSIF (p_inst_asset_query_rec.fa_asset_id   IS  NULL) THEN
        IF x_where_clause IS NULL THEN
            x_where_clause := ' fa_asset_id IS NULL ';
        ELSE
            x_where_clause := x_where_clause||' AND '||' fa_asset_id IS NULL ';
        END IF;
END IF ;
IF  ((p_inst_asset_query_rec.fa_book_type_code  IS NOT NULL) AND
          (p_inst_asset_query_rec.fa_book_type_code  <> FND_API.G_MISS_CHAR)) THEN
        IF x_where_clause IS NULL THEN
            x_where_clause := '  fa_book_type_code = :fa_book_type_code ';
        ELSE
            x_where_clause := x_where_clause||' AND '||
                   '  fa_book_type_code = :fa_book_type_code ';
        END IF;
ELSIF (p_inst_asset_query_rec.fa_book_type_code  IS NULL) THEN
        IF x_where_clause IS NULL THEN
            x_where_clause := '  fa_book_type_code IS NULL ';
        ELSE
            x_where_clause := x_where_clause||' AND '||
                   '  fa_book_type_code IS NULL ';
        END IF;
END IF;

IF  ((p_inst_asset_query_rec.fa_location_id  IS NOT NULL) AND
           (p_inst_asset_query_rec.fa_location_id  <> FND_API.G_MISS_NUM)) THEN
        IF x_where_clause IS NULL THEN
            x_where_clause := '  fa_location_id = :fa_location_id ';
        ELSE
            x_where_clause := x_where_clause||' AND '||
                   '  fa_location_id = :fa_location_id ';
        END IF;
ELSIF (p_inst_asset_query_rec.fa_location_id  IS NULL) THEN
        IF x_where_clause IS NULL THEN
            x_where_clause := '  fa_location_id IS NULL ';
        ELSE
            x_where_clause := x_where_clause||' AND '||
                   '  fa_location_id IS NULL ';
        END IF;
END IF;

IF  ((p_inst_asset_query_rec.update_status  IS NOT NULL) AND
         (p_inst_asset_query_rec.update_status  <> FND_API.G_MISS_CHAR)) THEN
        IF x_where_clause IS NULL THEN
            x_where_clause := '  update_status = :update_status ';
        ELSE
            x_where_clause := x_where_clause||' AND '||
                   '  update_status = :update_status ';
        END IF;
ELSIF (p_inst_asset_query_rec.update_status  IS  NULL) THEN
        IF x_where_clause IS NULL THEN
            x_where_clause := '  update_status IS NULL ';
        ELSE
            x_where_clause := x_where_clause||' AND '||
                   '  update_status IS NULL ';
        END IF;
END IF;

END Gen_Asset_Where_Clause;


  /*-------------------------------------------------------*/
  /* procedure name: get_instance_assets                   */
  /* description :   Get information about the assets      */
  /*                 associated with an item instance.     */
  /*-------------------------------------------------------*/
  PROCEDURE get_instance_assets (
      p_api_version               IN  NUMBER
     ,p_commit                    IN  VARCHAR2
     ,p_init_msg_list             IN  VARCHAR2
     ,p_validation_level          IN  NUMBER
     ,p_instance_asset_query_rec  IN  csi_datastructures_pub.instance_asset_query_rec
     ,p_resolve_id_columns        IN  VARCHAR2
     ,p_time_stamp                IN  DATE
     ,x_instance_asset_tbl        OUT NOCOPY csi_datastructures_pub.instance_asset_header_tbl
     ,x_return_status             OUT NOCOPY VARCHAR2
     ,x_msg_count                 OUT NOCOPY NUMBER
     ,x_msg_data                  OUT NOCOPY VARCHAR2
   ) IS

    l_api_name      CONSTANT VARCHAR2(30)   := 'get_instance_asset';
    l_api_version       CONSTANT NUMBER         := 1.0;
    l_CSI_DEBUG_LEVEL            NUMBER;
    l_instance_asset_rec     csi_datastructures_pub.instance_asset_rec;
    l_msg_index              NUMBER;
    l_msg_count              NUMBER;
    l_VERSION_LABEL_ID       NUMBER := NULL;
    l_count                  NUMBER := 0;
    l_instance_asset_id      NUMBER;
    l_where_clause           VARCHAR2(2000) := ''                            ;
    l_get_inst_asset_cursor_id  NUMBER                                       ;
    l_inst_asset_rec         csi_datastructures_pub.instance_asset_header_rec       ;
    l_rows_processed         NUMBER                                          ;
    l_select_stmt            VARCHAR2(20000):= ' SELECT INSTANCE_ASSET_ID,INSTANCE_ID,FA_ASSET_ID,FA_BOOK_TYPE_CODE '||
                               ' ,FA_LOCATION_ID,ASSET_QUANTITY,UPDATE_STATUS,ACTIVE_START_DATE,ACTIVE_END_DATE , '||
                               ' OBJECT_VERSION_NUMBER  FROM CSI_I_ASSETS ';
    l_instance_asset_tbl     csi_datastructures_pub.instance_asset_header_tbl;

BEGIN
        -- Standard Start of API savepoint
        /*
        IF fnd_api.to_boolean(p_commit)
        THEN
          SAVEPOINT     get_instance_asset_pvt;
        END IF;
        */
        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (l_api_version       ,
                                                p_api_version           ,
                                                l_api_name              ,
                                                G_PKG_NAME              )
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
    l_CSI_DEBUG_LEVEL:=fnd_profile.value('CSI_DEBUG_LEVEL');

    IF (l_CSI_DEBUG_LEVEL > 0) THEN
          debug( 'get_instance_asset');
    END IF;

    -- If the debug level = 2 then dump all the parameters values.
    IF (l_CSI_DEBUG_LEVEL > 1) THEN
      debug(p_api_version ||'-'|| p_commit||'-'||p_init_msg_list||'-'||p_validation_level);
      csi_gen_utility_pvt.dump_asset_query_rec(p_instance_asset_query_rec);
    END IF;

    -- check if atleast one query parameters are passed
    IF   (p_instance_asset_query_rec.instance_asset_id  = FND_API.G_MISS_NUM)
     AND (p_instance_asset_query_rec.instance_id  = FND_API.G_MISS_NUM)
     AND (p_instance_asset_query_rec.fa_asset_id   = FND_API.G_MISS_NUM)
     AND (p_instance_asset_query_rec.fa_book_type_code = FND_API.G_MISS_CHAR)
     AND (p_instance_asset_query_rec.fa_location_id = FND_API.G_MISS_NUM)
     AND (p_instance_asset_query_rec.update_status = FND_API.G_MISS_CHAR)  THEN

          FND_MESSAGE.Set_Name('CSI', 'CSI_API_INVALID_PARAMETERS');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Generate the where clause
    Gen_Asset_Where_Clause
       (   p_inst_asset_query_rec =>  p_instance_asset_query_rec,
           x_where_clause         =>  l_where_clause    );

    -- Build the select statement
    l_select_stmt := l_select_stmt || ' where '||l_where_clause;

    -- Open the cursor
    l_get_inst_asset_cursor_id := dbms_sql.open_cursor;

    --Parse the select statement
    dbms_sql.parse(l_get_inst_asset_cursor_id, l_select_stmt , dbms_sql.native);

    -- Bind the variables
    Bind_asset_variable(p_instance_asset_query_rec, l_get_inst_asset_cursor_id);

    -- Define output variables
    Define_Asset_Columns(l_get_inst_asset_cursor_id);

    -- execute the select statement
    l_rows_processed := dbms_sql.execute(l_get_inst_asset_cursor_id);

    LOOP
    EXIT WHEN DBMS_SQL.FETCH_ROWS(l_get_inst_asset_cursor_id) = 0;
             Get_asset_Column_Values(l_get_inst_asset_cursor_id, l_inst_asset_rec);
             l_count := l_count + 1;
             x_instance_asset_tbl(l_count) := l_inst_asset_rec;
    END LOOP;

    -- Close the cursor
    DBMS_SQL.CLOSE_CURSOR(l_get_inst_asset_cursor_id);

    IF (p_time_stamp IS NOT NULL) AND (p_time_stamp <> FND_API.G_MISS_DATE) THEN
      IF p_time_stamp <= sysdate THEN
          Construct_asset_from_hist(x_instance_asset_tbl, p_time_stamp);
      ELSE
          FND_MESSAGE.Set_Name('CSI', 'CSI_API_INVALID_HIST_PARAMS');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

   -- Resolve the foreign key columns if p_resolve_id_columns is true
    IF p_resolve_id_columns = fnd_api.g_true THEN
       IF x_instance_asset_tbl.count > 0 THEN
           l_instance_asset_tbl := x_instance_asset_tbl;
           Resolve_id_columns(l_instance_asset_tbl);

           x_instance_asset_tbl := l_instance_asset_tbl;
       END IF;
    END IF;

        --  End of API body

        -- Standard check of p_commit.
        /*
        IF FND_API.To_Boolean( p_commit ) THEN
           COMMIT WORK;
        END IF;
        */

    /***** srramakr commented for bug # 3304439
    -- Check for the profile option and disable the trace
        IF (fnd_profile.value('CSI_ENABLE_SQL_TRACE') = 'Y') THEN
           dbms_session.set_sql_trace(false);
    END IF;
        -- End disable trace
    ****/

        -- Standard call to get message count and if count is  get message info.
        FND_MSG_PUB.Count_And_Get
                (p_count        =>      x_msg_count ,
               p_data   =>      x_msg_data      );

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
        /*
        IF fnd_api.to_boolean(p_commit)
        THEN
           ROLLBACK TO get_instance_asset_pvt;
        END IF;
        */
                x_return_status := FND_API.G_RET_STS_ERROR ;
                                FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count,
                        p_data                  =>      x_msg_data);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        /*
        IF fnd_api.to_boolean(p_commit)
        THEN
           ROLLBACK TO get_instance_asset_pvt;
        END IF;
        */
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count,
                        p_data                  =>      x_msg_data);
        WHEN OTHERS THEN
        /*
        IF fnd_api.to_boolean(p_commit)
        THEN
           ROLLBACK TO get_instance_asset_pvt;
       END IF;
       */
        IF DBMS_SQL.IS_OPEN(l_get_inst_asset_cursor_id) THEN
          DBMS_SQL.CLOSE_CURSOR(l_get_inst_asset_cursor_id);
        END IF;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       G_PKG_NAME      ,
                        l_api_name      );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (       p_count         =>      x_msg_count,
                        p_data          =>      x_msg_data      );
  END get_instance_assets;

  /*-------------------------------------------------------*/
  /* Procedure name: create_instance_asset                 */
  /* Description :   procedure used to update an Item      */
  /*                 Instance                              */
  /*-------------------------------------------------------*/
  PROCEDURE create_instance_asset (
    p_api_version         IN            NUMBER,
    p_commit              IN            VARCHAR2,
    p_init_msg_list       IN            VARCHAR2,
    p_validation_level    IN            NUMBER,
    p_instance_asset_rec  IN OUT NOCOPY csi_datastructures_pub.instance_asset_rec,
    p_txn_rec             IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2,
    p_lookup_tbl          IN OUT NOCOPY csi_asset_pvt.lookup_tbl,
    p_asset_count_rec     IN OUT NOCOPY csi_asset_pvt.asset_count_rec,
    p_asset_id_tbl        IN OUT NOCOPY csi_asset_pvt.asset_id_tbl,
    p_asset_loc_tbl       IN OUT NOCOPY csi_asset_pvt.asset_loc_tbl,
    p_called_from_grp     IN            VARCHAR2)
  IS

    l_api_name        CONSTANT VARCHAR2(30) := 'CREATE_INSTANCE_ASSET';
    l_api_version     CONSTANT NUMBER := 1.0;
    l_CSI_DEBUG_LEVEL          NUMBER;
    l_process_flag             BOOLEAN :=  TRUE;
    l_msg_index                NUMBER;
    l_msg_count                NUMBER;
    x_msg_index_out            NUMBER;
    l_instance_asset_hist_id   NUMBER;
    l_acct_class_code          VARCHAR2(10);
    l_record_found             BOOLEAN := FALSE;
    l_exists_flag              VARCHAR2(1);
    l_valid_flag               VARCHAR2(1);
    l_asset_lookup_tbl         csi_asset_pvt.lookup_tbl;
    l_asset_count_rec          csi_asset_pvt.asset_count_rec;
    l_asset_id_tbl             csi_asset_pvt.asset_id_tbl;
    l_asset_loc_tbl            csi_asset_pvt.asset_loc_tbl;

    l_return_status            varchar2(1) := fnd_api.g_ret_sts_success;
    l_error_message            varchar2(2000);

  BEGIN
    -- Standard Start of API savepoint
    IF fnd_api.to_boolean(p_commit) THEN
      SAVEPOINT    create_instance_asset_pvt;
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check the profile option CSI_DEBUG_LEVEL for debug message reporting
    l_CSI_DEBUG_LEVEL:=fnd_profile.value('CSI_DEBUG_LEVEL');

    IF (l_CSI_DEBUG_LEVEL >= 1) THEN
      debug('create_instance_asset:'||
                                    p_api_version||'-'|| p_commit||'-'|| p_init_msg_list);
      csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);
      csi_gen_utility_pvt.dump_instance_asset_rec(p_instance_asset_rec);
    END IF;

    -- Start API body
    --
    -- Initialize the Asset count
    --
    IF p_asset_count_rec.asset_count IS NULL OR p_asset_count_rec.asset_count = FND_API.G_MISS_NUM
    THEN
       p_asset_count_rec.asset_count := 0;
    END IF;
    --
    IF p_asset_count_rec.lookup_count IS NULL OR p_asset_count_rec.lookup_count = FND_API.G_MISS_NUM
    THEN
      p_asset_count_rec.lookup_count := 0;
    END IF;
    --
    IF p_asset_count_rec.loc_count IS NULL OR p_asset_count_rec.loc_count = FND_API.G_MISS_NUM THEN
      p_asset_count_rec.loc_count := 0;
    END IF;
    --
    -- Check if all the required parameters are passed
    CSI_Asset_vld_pvt.Check_Reqd_Param
           (   p_instance_asset_rec.INSTANCE_ID  ,
            '  p_instance_asset_rec.INSTANCE_ID ',
               l_api_name               );

    IF nvl(p_instance_asset_rec.fa_mass_addition_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
      CSI_Asset_vld_pvt.Check_Reqd_Param(
        p_instance_asset_rec.FA_ASSET_ID,
       'p_instance_asset_rec.FA_ASSET_ID ',
       l_api_name);
    END IF;

    CSI_Asset_vld_pvt.Check_Reqd_Param
             (    p_instance_asset_rec.FA_BOOK_TYPE_CODE ,
                   '  p_instance_asset_rec.FA_BOOK_TYPE_CODE ',
                      l_api_name            );

    CSI_Asset_vld_pvt.Check_Reqd_Param
             (    p_instance_asset_rec.FA_LOCATION_ID,
                   '  p_instance_asset_rec.FA_LOCATION_ID',
                      l_api_name                        );
    -- Added by sk for bug 2232880.
    l_record_found := FALSE;
    IF ( (p_called_from_grp <> FND_API.G_TRUE) AND
          (p_instance_asset_rec.instance_asset_id IS NULL OR
           p_instance_asset_rec.instance_asset_id = fnd_api.g_miss_num) )
    THEN
      BEGIN
        SELECT  instance_asset_id,
                object_version_number
        INTO    p_instance_asset_rec.instance_asset_id,
                p_instance_asset_rec.object_version_number
       FROM    csi_i_assets
        WHERE   instance_id       = p_instance_asset_rec.instance_id
        and     fa_asset_id       = p_instance_asset_rec.fa_asset_id
        and     fa_book_type_code = p_instance_asset_rec.fa_book_type_code
        AND     fa_location_id    = p_instance_asset_rec.fa_location_id
        AND     active_end_date   < SYSDATE
        AND     ROWNUM            = 1 ;
        l_record_found := TRUE;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;

    IF l_record_found THEN
      IF p_instance_asset_rec.active_end_date = fnd_api.g_miss_date THEN
        p_instance_asset_rec.active_end_date := NULL;
      END IF;

      update_instance_asset(
         p_api_version         => p_api_version
           ,p_commit              => fnd_api.g_false
           ,p_init_msg_list       => p_init_msg_list
           ,p_validation_level    => p_validation_level
           ,p_instance_asset_rec  => p_instance_asset_rec
           ,p_txn_rec             => p_txn_rec
           ,x_return_status       => x_return_status
           ,x_msg_count           => x_msg_count
           ,x_msg_data            => x_msg_data
           ,p_lookup_tbl          => l_asset_lookup_tbl
           ,p_asset_count_rec     => l_asset_count_rec
           ,p_asset_id_tbl        => l_asset_id_tbl
           ,p_asset_loc_tbl       => l_asset_loc_tbl);


      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        l_msg_index := 1;
        l_msg_count := x_msg_count;
        WHILE l_msg_count > 0 LOOP
          x_msg_data := FND_MSG_PUB.GET (  l_msg_index, FND_API.G_FALSE     );
          debug( ' Failed Pvt:update_instance_asset..');
          debug('message data = '||x_msg_data);
          l_msg_index := l_msg_index + 1;
          l_msg_count := l_msg_count - 1;
        END LOOP;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    ELSE
      -- End addition by sk for bug 2232880.


      CSI_Asset_vld_pvt.Check_Reqd_Param
              (    p_instance_asset_rec.ASSET_QUANTITY,
                    '  p_instance_asset_rec.ASSET_QUANTITY',
                       l_api_name                        );
      CSI_Asset_vld_pvt.Check_Reqd_Param
              (    p_instance_asset_rec.UPDATE_STATUS,
                    '  p_instance_asset_rec.UPDATE_STATUS',
                       l_api_name                        );

      -- Validate the Instance id exists in csi_item_instances
      IF p_called_from_grp <> FND_API.G_TRUE THEN
        IF NOT( CSI_Asset_vld_pvt.Is_InstanceID_Valid
                                (p_instance_asset_rec.INSTANCE_ID
                                ,p_instance_asset_rec.check_for_instance_expiry
                              )) THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;

      IF  p_instance_asset_rec.INSTANCE_ASSET_ID is  NULL OR
          p_instance_asset_rec.INSTANCE_ASSET_ID = FND_API.G_MISS_NUM THEN

        -- If the instance_asset id passed is null then generate from sequence
        -- and check if the value exists . If exists then generate
        -- again from the sequence till we get a value that does not exist
        WHILE l_process_flag
        LOOP
          p_instance_asset_rec.INSTANCE_ASSET_ID := CSI_Asset_vld_pvt.gen_inst_asset_id;
          IF NOT(CSI_Asset_vld_pvt.Is_Inst_assetID_exists
                                       (p_instance_asset_rec.INSTANCE_ASSET_ID,
                                           FALSE                   )) THEN
            l_process_flag := FALSE;
          END IF;
        END LOOP;
      ELSE
        -- Validate the instance asset id if exist then raise CSI_API_INVALID_PRIMARY_KEY error
        IF CSI_Asset_vld_pvt.Is_Inst_assetID_exists
                                       (p_instance_asset_rec.INSTANCE_ASSET_ID,
                                        TRUE                        ) THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;

      --validation for the asset update status
      l_valid_flag := 'Y';
      l_exists_flag := 'N';
      IF ((p_instance_asset_rec.update_status IS NOT NULL) AND
        (p_instance_asset_rec.update_status <> FND_API.G_MISS_CHAR)) THEN
        IF p_lookup_tbl.count > 0 THEN
          For lookup_count in p_lookup_tbl.FIRST .. p_lookup_tbl.LAST
          LOOP
            IF p_lookup_tbl(lookup_count).lookup_code = p_instance_asset_rec.update_status THEN
              l_valid_flag := p_lookup_tbl(lookup_count).valid_flag;
              l_exists_flag := 'Y';
              exit;
            END IF;
          END LOOP;
               --
          IF l_valid_flag <> 'Y' then
            FND_MESSAGE.SET_NAME('CSI','CSI_API_INV_UPDATE_STATUS');
            FND_MESSAGE.SET_TOKEN('UPDATE_STATUS',p_instance_asset_rec.update_status);
            FND_MSG_PUB.Add;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;
        --
        IF l_exists_flag <> 'Y' THEN
          p_asset_count_rec.lookup_count := p_asset_count_rec.lookup_count  + 1;
          p_lookup_tbl(p_asset_count_rec.lookup_count).lookup_code :=
            p_instance_asset_rec.update_status;
          IF NOT( CSI_Asset_vld_pvt.Is_Update_Status_Exists
                              (p_instance_asset_rec.UPDATE_STATUS)) THEN
            p_lookup_tbl(p_asset_count_rec.lookup_count).valid_flag := 'N';
            RAISE FND_API.G_EXC_ERROR;
          ELSE
            p_lookup_tbl(p_asset_count_rec.lookup_count).valid_flag := 'Y';
          END IF;
        END IF;
      END IF;
      --

      -- Validate the quantity > 0
      IF NOT( CSI_Asset_vld_pvt.Is_Quantity_Valid
                             (p_instance_asset_rec.ASSET_QUANTITY)) THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      --check for the exists of asset_id and asset book_type_code combination in the fa_books table
      l_valid_flag := 'Y';
      l_exists_flag := 'N';
      IF ((p_instance_asset_rec.fa_asset_id is not null AND
              p_instance_asset_rec.fa_asset_id <> FND_API.G_MISS_NUM) AND
             (p_instance_asset_rec.fa_book_type_code is not null AND
              p_instance_asset_rec.fa_book_type_code <> FND_API.G_MISS_CHAR)) THEN
        IF p_asset_id_tbl.count > 0 then
          For asset_count in p_asset_id_tbl.FIRST .. p_asset_id_tbl.LAST
          LOOP
            IF p_asset_id_tbl(asset_count).asset_id = p_instance_asset_rec.fa_asset_id AND
               p_asset_id_tbl(asset_count).asset_book_type = p_instance_asset_rec.fa_book_type_code
            THEN
              l_valid_flag := p_asset_id_tbl(asset_count).valid_flag;
              l_exists_flag := 'Y';
              exit;
            END IF;
          END LOOP;
          --
          IF l_valid_flag <> 'Y' THEN
            FND_MESSAGE.SET_NAME('CSI','CSI_API_INV_ASSET_COMB');
            FND_MESSAGE.SET_TOKEN('ASSET_COMBINATION',
              p_instance_asset_rec.fa_asset_id||'-'||p_instance_asset_rec.fa_book_type_code);
            FND_MSG_PUB.Add;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;
        --
        IF l_exists_flag <> 'Y' THEN
          p_asset_count_rec.asset_count := p_asset_count_rec.asset_count + 1;
          p_asset_id_tbl(p_asset_count_rec.asset_count).asset_id := p_instance_asset_rec.fa_asset_id;
          p_asset_id_tbl(p_asset_count_rec.asset_count).asset_book_type :=
          p_instance_asset_rec.fa_book_type_code;
          IF NOT( CSI_Asset_vld_pvt.Is_Asset_Comb_Valid
            (p_instance_asset_rec.FA_ASSET_ID   ,
            p_instance_asset_rec.FA_BOOK_TYPE_CODE )) THEN
            p_asset_id_tbl(p_asset_count_rec.asset_count).valid_flag := 'N';
            RAISE fnd_api.g_exc_error;
          ELSE
            p_asset_id_tbl(p_asset_count_rec.asset_count).valid_flag := 'Y';
          END IF;
        END IF;
      END IF;
      --
      IF ((p_instance_asset_rec.active_start_date = FND_API.G_MISS_DATE) OR
        (p_instance_asset_rec.active_start_date IS NULL))
      THEN
        p_instance_asset_rec.active_start_date := SYSDATE;
      END IF;

      IF (p_instance_asset_rec.active_end_date = FND_API.G_MISS_DATE) THEN
        p_instance_asset_rec.active_end_date := NULL;
      END IF;
      --
      IF p_called_from_grp <> FND_API.G_TRUE THEN
        -- Validation for the active start date passed
        IF NOT(CSI_Asset_vld_pvt.Is_StartDate_Valid(
               p_instance_asset_rec.ACTIVE_START_DATE,
               p_instance_asset_rec.ACTIVE_END_DATE ,
               p_instance_asset_rec.INSTANCE_ID,
               p_instance_asset_rec.check_for_instance_expiry  ))
        THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
      --
      IF p_called_from_grp <> FND_API.G_TRUE THEN
        -- Verify if the active_end_date is valid
        IF ((p_instance_asset_rec.ACTIVE_END_DATE is NOT NULL) AND
          ( p_instance_asset_rec.ACTIVE_END_DATE <> FND_API.G_MISS_DATE)) THEN
          IF NOT(CSI_Asset_vld_pvt.Is_EndDate_Valid(
                 p_instance_asset_rec.ACTIVE_START_DATE,
                 p_instance_asset_rec.ACTIVE_END_DATE ,
                 p_instance_asset_rec.INSTANCE_ID,
                 p_instance_asset_rec.INSTANCE_ASSET_ID,
                 p_txn_rec.TRANSACTION_ID,
                 p_instance_asset_rec.check_for_instance_expiry))
          THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        END IF;
      END IF;

      IF nvl(p_instance_asset_rec.fa_asset_id, fnd_api.g_miss_num) = fnd_api.g_miss_num
         OR
         nvl(p_instance_asset_rec.fa_book_type_code, fnd_api.g_miss_char) = fnd_api.g_miss_char
         OR
         nvl(p_instance_asset_rec.fa_location_id, fnd_api.g_miss_num) = fnd_api.g_miss_num
         OR
         nvl(p_instance_asset_rec.asset_quantity, fnd_api.g_miss_num) = fnd_api.g_miss_num
      THEN
        p_instance_asset_rec.creation_complete_flag := 'N';
      ELSE
        p_instance_asset_rec.creation_complete_flag := 'Y';
      END IF;
      --
      -- Since Group API already makes a call to this routine, by-passing it.
      IF p_called_from_grp <> FND_API.G_TRUE THEN
	 IF p_instance_asset_rec.fa_sync_validation_reqd = fnd_api.g_true THEN
	    set_fa_sync_flag (
	      px_instance_asset_rec => p_instance_asset_rec,
	      x_return_status       => l_return_status,
	      x_error_msg           => l_error_message);
	    IF l_return_status <> fnd_api.g_ret_sts_success THEN
	       RAISE fnd_api.g_exc_error;
	    END IF;
         END IF;
      END IF; -- Called from grp check as GRP API already does the validation
      --
      IF p_instance_asset_rec.fa_sync_validation_reqd = fnd_api.g_false AND
         nvl(p_instance_asset_rec.fa_sync_flag,'N') = 'Y' THEN
        --check for the existance of location_id in fa_locations table
        l_valid_flag := 'Y';
        l_exists_flag := 'N';
        IF p_instance_asset_rec.fa_location_id is not null AND
           p_instance_asset_rec.fa_location_id <> FND_API.G_MISS_NUM THEN
          IF p_asset_loc_tbl.count > 0 then
            For loc_count in p_asset_loc_tbl.FIRST .. p_asset_loc_tbl.LAST
            LOOP
              IF p_asset_loc_tbl(loc_count).asset_loc_id = p_instance_asset_rec.fa_location_id THEN
                l_valid_flag := p_asset_loc_tbl(loc_count).valid_flag;
                l_exists_flag := 'Y';
                exit;
              END IF;
            END LOOP;
            --
            IF l_valid_flag <> 'Y' THEN
              FND_MESSAGE.SET_NAME('CSI','CSI_API_INV_ASSET_LOCATION');
              FND_MESSAGE.SET_TOKEN('ASSET_LOCATION_ID',p_instance_asset_rec.fa_location_id);
              FND_MSG_PUB.Add;
              RAISE fnd_api.g_exc_error;
            END IF;
          END IF;
          --
          IF l_exists_flag <> 'Y' THEN
            p_asset_count_rec.loc_count := p_asset_count_rec.loc_count + 1;
            p_asset_loc_tbl(p_asset_count_rec.loc_count).asset_loc_id :=
              p_instance_asset_rec.fa_location_id;
            IF NOT( CSI_Asset_vld_pvt.Is_Asset_Location_Valid (p_instance_asset_rec.FA_LOCATION_ID ))
            THEN
              p_asset_loc_tbl(p_asset_count_rec.loc_count).valid_flag := 'N';
              RAISE fnd_api.g_exc_error;
            ELSE
              p_asset_loc_tbl(p_asset_count_rec.loc_count).valid_flag := 'Y';
            END IF;
          END IF;
        END IF;
      END IF;

      -- Call table handler to insert into csi_i_assets table
      IF p_called_from_grp <> FND_API.G_TRUE THEN
        CSI_I_ASSETS_PKG.Insert_Row (
          px_INSTANCE_ASSET_ID    => p_instance_asset_rec.INSTANCE_ASSET_ID,
          p_INSTANCE_ID           => p_instance_asset_rec.INSTANCE_ID,
          p_FA_ASSET_ID           => p_instance_asset_rec.FA_ASSET_ID,
          p_FA_BOOK_TYPE_CODE     => p_instance_asset_rec.FA_BOOK_TYPE_CODE,
          p_FA_LOCATION_ID        => p_instance_asset_rec.FA_LOCATION_ID,
          p_ASSET_QUANTITY        => p_instance_asset_rec.ASSET_QUANTITY,
          p_UPDATE_STATUS         => p_instance_asset_rec.UPDATE_STATUS,
          p_FA_SYNC_FLAG          => p_instance_asset_rec.FA_SYNC_FLAG,
          p_FA_MASS_ADDITION_ID   => p_instance_asset_rec.FA_MASS_ADDITION_ID,
          p_CREATION_COMPLETE_FLAG=> p_instance_asset_rec.CREATION_COMPLETE_FLAG,
          p_CREATED_BY            => FND_GLOBAL.USER_ID,
          p_CREATION_DATE         => SYSDATE,
          p_LAST_UPDATED_BY       => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_DATE      => SYSDATE,
          p_LAST_UPDATE_LOGIN     => FND_GLOBAL.LOGIN_ID,
          p_OBJECT_VERSION_NUMBER => 1,
          p_ACTIVE_START_DATE     => p_instance_asset_rec.ACTIVE_START_DATE,
          p_ACTIVE_END_DATE       => p_instance_asset_rec.ACTIVE_END_DATE);

        IF nvl(p_txn_rec.transaction_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
          -- Call create_transaction to create txn log
          CSI_TRANSACTIONS_PVT.Create_transaction (
            p_api_version            => p_api_version,
            p_commit                 => p_commit,
            p_init_msg_list          => p_init_msg_list,
            p_validation_level       => p_validation_level,
            p_Success_If_Exists_Flag => 'Y',
            P_transaction_rec        => p_txn_rec,
            x_return_status          => x_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data);

          IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            FND_MESSAGE.SET_NAME('CSI','CSI_FAILED_TO_VALIDATE_TXN');
            FND_MESSAGE.SET_TOKEN('API_NAME',l_api_name);
            FND_MESSAGE.SET_TOKEN('TRANSACTION_ID',p_txn_rec.transaction_id );
            FND_MSG_PUB.Add;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;

        -- Generate the instance asset history id from the sequence
        l_instance_asset_hist_id := CSI_Asset_vld_pvt.gen_inst_asset_hist_id;
        -- Call table handlers to insert into history table
        CSI_I_ASSETS_H_PKG.Insert_Row (
          px_INSTANCE_ASSET_HISTORY_ID => l_instance_asset_hist_id,
          p_INSTANCE_ASSET_ID          => p_instance_asset_rec.INSTANCE_ASSET_ID,
          p_TRANSACTION_ID             => p_txn_rec.transaction_id,
          p_OLD_INSTANCE_ID            => NULL,
          p_NEW_INSTANCE_ID            => p_instance_asset_rec.INSTANCE_ID,
          p_OLD_FA_ASSET_ID            => NULL,
          p_NEW_FA_ASSET_ID            => p_instance_asset_rec.FA_ASSET_ID,
          p_OLD_ASSET_QUANTITY         => NULL,
          p_NEW_ASSET_QUANTITY         => p_instance_asset_rec.ASSET_QUANTITY,
          p_OLD_FA_BOOK_TYPE_CODE      => NULL,
          p_NEW_FA_BOOK_TYPE_CODE      => p_instance_asset_rec.FA_BOOK_TYPE_CODE,
          p_OLD_FA_LOCATION_ID         => NULL,
          p_NEW_FA_LOCATION_ID         => p_instance_asset_rec.FA_LOCATION_ID,
          p_OLD_UPDATE_STATUS          => NULL,
          p_NEW_UPDATE_STATUS          => p_instance_asset_rec.UPDATE_STATUS,
          p_OLD_FA_SYNC_FLAG           => NULL,
          p_NEW_FA_SYNC_FLAG           => p_instance_asset_rec.FA_SYNC_FLAG,
          p_OLD_FA_MASS_ADDITION_ID    => NULL,
          p_NEW_FA_MASS_ADDITION_ID    => p_instance_asset_rec.FA_MASS_ADDITION_ID,
          p_OLD_CREATION_COMPLETE_FLAG => NULL,
          p_NEW_CREATION_COMPLETE_FLAG => p_instance_asset_rec.CREATION_COMPLETE_FLAG,
          p_FULL_DUMP_FLAG             => 'N',
          p_CREATED_BY                 => FND_GLOBAL.USER_ID,
          p_CREATION_DATE              => SYSDATE,
          p_LAST_UPDATED_BY            => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_DATE           => SYSDATE,
          p_LAST_UPDATE_LOGIN          => FND_GLOBAL.LOGIN_ID,
          p_OBJECT_VERSION_NUMBER      => 1,
          p_OLD_ACTIVE_START_DATE      => NULL,
          p_NEW_ACTIVE_START_DATE      => p_instance_asset_rec.ACTIVE_START_DATE,
          p_OLD_ACTIVE_END_DATE        => NULL,
          p_NEW_ACTIVE_END_DATE        => p_instance_asset_rec.ACTIVE_END_DATE);

        csi_item_instance_pvt.get_and_update_acct_class(
          p_api_version         =>     p_api_version,
          p_commit              =>     p_commit,
          p_init_msg_list       =>     p_init_msg_list,
          p_validation_level    =>     p_validation_level,
          p_instance_id         =>     p_instance_asset_rec.instance_id,
          p_instance_expiry_flag =>    p_instance_asset_rec.check_for_instance_expiry,
          p_txn_rec             =>     p_txn_rec,
          x_acct_class_code     =>     l_acct_class_code,
          x_return_status       =>     x_return_status,
          x_msg_count           =>     x_msg_count,
          x_msg_data            =>     x_msg_data);

        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          RAISE fnd_api.g_exc_error;
        END IF;

      END IF; -- called from grp check
    END IF; -- Added by sk for bug 2232880
    --
    -- End of API body

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);

    debug(' end of create_instance_asset.'||x_return_status);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      IF fnd_api.to_boolean(p_commit) THEN
        ROLLBACK TO create_instance_asset_pvt;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
      l_error_message := csi_gen_utility_pvt.dump_error_stack;
      debug('error(E): '||l_error_message);
    WHEN fnd_api.g_exc_unexpected_error THEN
      IF fnd_api.to_boolean(p_commit) THEN
        ROLLBACK TO create_instance_asset_pvt;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
      l_error_message := csi_gen_utility_pvt.dump_error_stack;
      debug('error(U): '||l_error_message);
    WHEN OTHERS THEN
      IF fnd_api.to_boolean(p_commit) THEN
        ROLLBACK TO create_instance_asset_pvt;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
      FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
      l_error_message := csi_gen_utility_pvt.dump_error_stack;
      debug('error(0): '||l_error_message);
  END create_instance_asset;


  PROCEDURE update_instance_asset(
    p_api_version         IN     NUMBER,
    p_commit              IN     VARCHAR2,
    p_init_msg_list       IN     VARCHAR2,
    p_validation_level    IN     NUMBER,
    p_instance_asset_rec  IN OUT NOCOPY csi_datastructures_pub.instance_asset_rec,
    p_txn_rec             IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2,
    p_lookup_tbl          IN OUT NOCOPY csi_asset_pvt.lookup_tbl,
    p_asset_count_rec     IN OUT NOCOPY csi_asset_pvt.asset_count_rec,
    p_asset_id_tbl        IN OUT NOCOPY csi_asset_pvt.asset_id_tbl,
    p_asset_loc_tbl       IN OUT NOCOPY csi_asset_pvt.asset_loc_tbl )
  IS
    l_api_name               CONSTANT   VARCHAR2(30)   := 'update_instance_asset';
    l_api_version            CONSTANT   NUMBER         := 1.0;
    l_CSI_DEBUG_LEVEL                   NUMBER;
    l_object_version_number             NUMBER;
    l_inst_asset_his_id                 NUMBER;
    l_full_dump_frequency               NUMBER;
    l_mod_value                         NUMBER;
    x_msg_index_out                     NUMBER;
    l_instance_asset_hist_id            NUMBER;
    l_acct_class_code                   VARCHAR2(10);
    l_exists_flag                       VARCHAR2(1);
    l_valid_flag                        VARCHAR2(1);
    l_ins_asset_hist_rec                csi_datastructures_pub.ins_asset_history_rec;
    l_creation_complete_flag            varchar2(1);
    l_return_status                     varchar2(1) := fnd_api.g_ret_sts_success;
    l_error_message                     varchar2(2000);

    CURSOR get_curr_asset_rec (p_inst_asset_id   IN  NUMBER) IS
      SELECT instance_asset_id,
             instance_id,
             fa_asset_id,
             fa_book_type_code,
             fa_location_id,
             asset_quantity,
             update_status,
             fa_sync_flag,
             fa_mass_addition_id,
             creation_complete_flag,
             active_start_date,
             active_end_date,
             object_version_number
      FROM   csi_i_assets
      WHERE INSTANCE_ASSET_ID = p_inst_asset_id
      FOR UPDATE OF object_version_number ;

    l_curr_asset_rec       get_curr_asset_rec%ROWTYPE;
    l_temp_inst_asset_rec  get_curr_asset_rec%ROWTYPE;

    CURSOR asset_hist_csr (p_asset_hist_id NUMBER) IS
      SELECT  *
      FROM    csi_i_assets_h
      WHERE   csi_i_assets_h.instance_asset_history_id = p_asset_hist_id
      FOR UPDATE NOWAIT;

    l_asset_hist_csr    asset_hist_csr%ROWTYPE;
    l_asset_hist_id     NUMBER;

  BEGIN

    -- Standard Start of API savepoint
    IF fnd_api.to_boolean(p_commit) THEN
      SAVEPOINT    update_instance_asset_pvt;
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version , p_api_version  , l_api_name , G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check the profile option CSI_DEBUG_LEVEL for debug message reporting
    l_CSI_DEBUG_LEVEL:=fnd_profile.value('CSI_DEBUG_LEVEL');

    -- If CSI_DEBUG_LEVEL = 1 then dump the procedure name
    IF (l_CSI_DEBUG_LEVEL > 0) THEN
         debug( 'update_instance_asset');
    END IF;


    -- If the debug level = 2 then dump all the parameters values.
    IF (l_CSI_DEBUG_LEVEL > 1) THEN
      debug( 'update_instance_asset:'||p_api_version||'-'||p_commit||'-'||p_init_msg_list||'-'||p_validation_level);
      -- Dump the records in the log file
      csi_gen_utility_pvt.dump_instance_asset_rec(p_instance_asset_rec);
      IF nvl(p_txn_rec.transaction_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
        csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);
      END IF;
    END IF;

    -- Initialize the Asset count
    IF p_asset_count_rec.asset_count IS NULL OR
       p_asset_count_rec.asset_count = FND_API.G_MISS_NUM THEN
       p_asset_count_rec.asset_count := 0;
    END IF;
    --
    IF p_asset_count_rec.lookup_count IS NULL OR
      p_asset_count_rec.lookup_count = FND_API.G_MISS_NUM THEN
      p_asset_count_rec.lookup_count := 0;
    END IF;
    --
    IF p_asset_count_rec.loc_count IS NULL OR
       p_asset_count_rec.loc_count = FND_API.G_MISS_NUM THEN
       p_asset_count_rec.loc_count := 0;
    END IF;

    -- Check if all the required parameters are passed
    CSI_Asset_vld_pvt.Check_Reqd_Param (p_instance_asset_rec.INSTANCE_ASSET_ID,
            'p_instance_asset_rec.INSTANCE_ASSET_ID ',
            l_api_name);

    -- check if the object_version_number passed matches with the one
    -- in the database else raise error
    OPEN get_curr_asset_rec(p_instance_asset_rec.INSTANCE_ASSET_ID);
    FETCH get_curr_asset_rec INTO l_curr_asset_rec;
    IF  (l_curr_asset_rec.object_version_number <> p_instance_asset_rec.OBJECT_VERSION_NUMBER) THEN
       FND_MESSAGE.Set_Name('CSI', 'CSI_API_OBJ_VER_MISMATCH');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF get_curr_asset_rec%NOTFOUND THEN
      FND_MESSAGE.Set_Name('CSI', 'CSI_API_RECORD_LOCKED');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE get_curr_asset_rec;
    --
    p_instance_asset_rec.instance_id := l_curr_asset_rec.instance_id;
    --
    -- Validate the Instance asset id exists in csi_i_assets
    IF NOT( CSI_Asset_vld_pvt.Is_Inst_asset_id_valid (p_instance_asset_rec.INSTANCE_ASSET_ID)) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Validate the Instance id exists in csi_item_instances
    IF ((p_instance_asset_rec.INSTANCE_ID IS NOT NULL)
       AND (p_instance_asset_rec.INSTANCE_ID <> FND_API.G_MISS_NUM)) THEN
      IF NOT( CSI_Asset_vld_pvt.Is_InstanceID_Valid
                              (p_instance_asset_rec.INSTANCE_ID
                              ,p_instance_asset_rec.check_for_instance_expiry
                              )) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    --validation for the asset update status
    l_valid_flag := 'Y';
    l_exists_flag := 'N';
    IF ((p_instance_asset_rec.update_status IS NOT NULL) AND
       (p_instance_asset_rec.update_status <> FND_API.G_MISS_CHAR)) THEN
      IF p_lookup_tbl.count > 0 THEN
        For lookup_count in p_lookup_tbl.FIRST .. p_lookup_tbl.LAST
        LOOP
          IF p_lookup_tbl(lookup_count).lookup_code = p_instance_asset_rec.update_status THEN
            l_valid_flag := p_lookup_tbl(lookup_count).valid_flag;
            l_exists_flag := 'Y';
            exit;
          END IF;
        End Loop;
               --
        if l_valid_flag <> 'Y' then
          FND_MESSAGE.SET_NAME('CSI','CSI_API_INV_UPDATE_STATUS');
          FND_MESSAGE.SET_TOKEN('UPDATE_STATUS',p_instance_asset_rec.update_status);
          FND_MSG_PUB.Add;
          RAISE fnd_api.g_exc_error;
        end if;
      End if;
      --
      IF l_exists_flag <> 'Y' THEN
        p_asset_count_rec.lookup_count := p_asset_count_rec.lookup_count  + 1;
        p_lookup_tbl(p_asset_count_rec.lookup_count).lookup_code := p_instance_asset_rec.update_status;
        IF NOT( CSI_Asset_vld_pvt.Is_Update_Status_Exists
              (p_instance_asset_rec.UPDATE_STATUS)) THEN
          p_lookup_tbl(p_asset_count_rec.lookup_count).valid_flag := 'N';
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          p_lookup_tbl(p_asset_count_rec.lookup_count).valid_flag := 'Y';
        END IF;
      END IF;
    END IF;
    --

    --check for the exists of asset_id and asset book_type_code combination in the fa_books table
    l_valid_flag := 'Y';
    l_exists_flag := 'N';
    IF ((p_instance_asset_rec.fa_asset_id is not null AND
         p_instance_asset_rec.fa_asset_id <> FND_API.G_MISS_NUM) AND
        (p_instance_asset_rec.fa_book_type_code is not null AND
         p_instance_asset_rec.fa_book_type_code <> FND_API.G_MISS_CHAR))
    THEN
      IF p_asset_id_tbl.count > 0 then
        For asset_count in p_asset_id_tbl.FIRST .. p_asset_id_tbl.LAST
        LOOP
          IF p_asset_id_tbl(asset_count).asset_id = p_instance_asset_rec.fa_asset_id AND
              p_asset_id_tbl(asset_count).asset_book_type = p_instance_asset_rec.fa_book_type_code
          THEN
            l_valid_flag := p_asset_id_tbl(asset_count).valid_flag;
            l_exists_flag := 'Y';
            exit;
          END IF;
        END LOOP;
        --
        IF l_valid_flag <> 'Y' THEN
          FND_MESSAGE.SET_NAME('CSI','CSI_API_INV_ASSET_COMB');
          FND_MESSAGE.SET_TOKEN('ASSET_COMBINATION',p_instance_asset_rec.fa_asset_id||'-'||p_instance_asset_rec.fa_book_type_code);
          FND_MSG_PUB.Add;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;
      --
      IF l_exists_flag <> 'Y' THEN
        p_asset_count_rec.asset_count := p_asset_count_rec.asset_count + 1;
        p_asset_id_tbl(p_asset_count_rec.asset_count).asset_id := p_instance_asset_rec.fa_asset_id;
        p_asset_id_tbl(p_asset_count_rec.asset_count).asset_book_type := p_instance_asset_rec.fa_book_type_code;
        IF NOT( CSI_Asset_vld_pvt.Is_Asset_Comb_Valid
                               (p_instance_asset_rec.FA_ASSET_ID   ,
                                p_instance_asset_rec.FA_BOOK_TYPE_CODE )) THEN
           p_asset_id_tbl(p_asset_count_rec.asset_count).valid_flag := 'N';
           RAISE fnd_api.g_exc_error;
        ELSE
           p_asset_id_tbl(p_asset_count_rec.asset_count).valid_flag := 'Y';
        END IF;
      END IF;
    END IF;
    --

    IF p_instance_asset_rec.fa_sync_validation_reqd = fnd_api.g_false AND
       nvl(p_instance_asset_rec.fa_sync_flag,'N') = 'Y'
    THEN
      l_valid_flag := 'Y';
      l_exists_flag := 'N';
      IF p_instance_asset_rec.fa_location_id is not null AND
         p_instance_asset_rec.fa_location_id <> FND_API.G_MISS_NUM THEN
        IF p_asset_loc_tbl.count > 0 then
          For loc_count in p_asset_loc_tbl.FIRST .. p_asset_loc_tbl.LAST
          LOOP
            IF p_asset_loc_tbl(loc_count).asset_loc_id = p_instance_asset_rec.fa_location_id THEN
              l_valid_flag := p_asset_loc_tbl(loc_count).valid_flag;
              l_exists_flag := 'Y';
              exit;
            END IF;
          END LOOP;
          --
          IF l_valid_flag <> 'Y' THEN
            FND_MESSAGE.SET_NAME('CSI','CSI_API_INV_ASSET_LOCATION');
            FND_MESSAGE.SET_TOKEN('ASSET_LOCATION_ID',p_instance_asset_rec.fa_location_id);
            FND_MSG_PUB.Add;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;
        --
        IF l_exists_flag <> 'Y' THEN
          p_asset_count_rec.loc_count := p_asset_count_rec.loc_count + 1;
          p_asset_loc_tbl(p_asset_count_rec.loc_count).asset_loc_id := p_instance_asset_rec.fa_location_id;
          IF NOT( CSI_Asset_vld_pvt.Is_Asset_Location_Valid (p_instance_asset_rec.FA_LOCATION_ID   )) THEN
            p_asset_loc_tbl(p_asset_count_rec.loc_count).valid_flag := 'N';
            RAISE fnd_api.g_exc_error;
          ELSE
            p_asset_loc_tbl(p_asset_count_rec.loc_count).valid_flag := 'Y';
          END IF;
        END IF;
      END IF;
    END IF;
    --

    -- Validation for the Active start date
    IF p_instance_asset_rec.active_start_date <> FND_API.G_MISS_DATE THEN
      IF p_instance_asset_rec.active_start_date <> l_curr_asset_rec.active_start_date THEN
        FND_MESSAGE.Set_Name('CSI', 'CSI_API_UPD_NOT_ALLOWED');
        FND_MESSAGE.Set_Token('COLUMN', 'ACTIVE_START_DATE');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -- Verify end effective end date
    IF ( p_instance_asset_rec.active_end_date <> FND_API.G_MISS_DATE) THEN
      IF p_instance_asset_rec.active_end_date IS NOT NULL THEN
        IF NOT(CSI_Asset_vld_pvt.Is_EndDate_Valid
               (p_instance_asset_rec.ACTIVE_START_DATE,
                p_instance_asset_rec.ACTIVE_END_DATE,
                p_instance_asset_rec.INSTANCE_ID ,
                p_instance_asset_rec.INSTANCE_ASSET_ID,
                p_txn_rec.TRANSACTION_ID,
                p_instance_asset_rec.check_for_instance_expiry))  THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
    END IF;

    IF ((p_instance_asset_rec.fa_asset_id is not null AND p_instance_asset_rec.fa_asset_id <> fnd_api.g_miss_num)
         OR
        (l_curr_asset_rec.fa_asset_id is not null AND p_instance_asset_rec.fa_asset_id = fnd_api.g_miss_num))
       AND
       ((p_instance_asset_rec.fa_book_type_code is not null AND
         p_instance_asset_rec.fa_book_type_code <> fnd_api.g_miss_char)
         OR
        (l_curr_asset_rec.fa_book_type_code is not null AND
          p_instance_asset_rec.fa_book_type_code = fnd_api.g_miss_char))
       AND
       ((p_instance_asset_rec.fa_location_id is not null AND
         p_instance_asset_rec.fa_location_id <> fnd_api.g_miss_num)
         OR
        (l_curr_asset_rec.fa_location_id is not null AND
         p_instance_asset_rec.fa_location_id = fnd_api.g_miss_num))
       AND
       ((p_instance_asset_rec.asset_quantity is not null AND
         p_instance_asset_rec.asset_quantity <> fnd_api.g_miss_num)
         OR
        (l_curr_asset_rec.asset_quantity is not null AND
         p_instance_asset_rec.asset_quantity = fnd_api.g_miss_num))
    THEN
      l_creation_complete_flag := 'Y';
    ELSE
      l_creation_complete_flag := 'N';
    END IF;

    IF p_instance_asset_rec.fa_sync_validation_reqd = fnd_api.g_true THEN

      IF nvl(p_instance_asset_rec.fa_book_type_code, fnd_api.g_miss_char) = fnd_api.g_miss_char THEN
        p_instance_asset_rec.fa_book_type_code := l_curr_asset_rec.fa_book_type_code;
      END IF;

      IF nvl(p_instance_asset_rec.instance_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
        p_instance_asset_rec.instance_id := l_curr_asset_rec.instance_id;
      END IF;

      IF nvl(p_instance_asset_rec.fa_location_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
        p_instance_asset_rec.fa_location_id := l_curr_asset_rec.fa_location_id;
      END IF;

      IF nvl(p_instance_asset_rec.fa_ASSET_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
        p_instance_asset_rec.fa_ASSET_id := l_curr_asset_rec.fa_ASSET_id;
      END IF;

      IF nvl(p_instance_asset_rec.asset_quantity, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
        p_instance_asset_rec.asset_quantity := l_curr_asset_rec.asset_quantity;
      END IF;

      set_fa_sync_flag (
        px_instance_asset_rec => p_instance_asset_rec,
        x_return_status       => l_return_status,
        x_error_msg           => l_error_message);
      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- Increment the object_version_number before updating
    l_OBJECT_VERSION_NUMBER := l_curr_asset_rec.OBJECT_VERSION_NUMBER + 1 ;

    CSI_I_ASSETS_PKG.Update_Row (
      p_INSTANCE_ASSET_ID     => p_instance_asset_rec.instance_asset_id,
      p_INSTANCE_ID           => p_instance_asset_rec.INSTANCE_ID,
      p_FA_ASSET_ID           => p_instance_asset_rec.FA_ASSET_ID,
      p_FA_BOOK_TYPE_CODE     => p_instance_asset_rec.FA_BOOK_TYPE_CODE,
      p_FA_LOCATION_ID        => p_instance_asset_rec.FA_LOCATION_ID,
      p_ASSET_QUANTITY        => p_instance_asset_rec.ASSET_QUANTITY,
      p_UPDATE_STATUS         => p_instance_asset_rec.UPDATE_STATUS,
      p_FA_SYNC_FLAG          => p_instance_asset_rec.FA_SYNC_FLAG,
      p_FA_MASS_ADDITION_ID   => p_instance_asset_rec.FA_MASS_ADDITION_ID,
      p_CREATION_COMPLETE_FLAG=> l_creation_complete_flag,
      p_CREATED_BY            => FND_API.G_MISS_NUM,
      p_CREATION_DATE         => fnd_api.g_miss_date,
      p_LAST_UPDATED_BY       => FND_GLOBAL.USER_ID,
      p_LAST_UPDATE_DATE      => SYSDATE,
      p_LAST_UPDATE_LOGIN     => FND_GLOBAL.LOGIN_ID,
      p_OBJECT_VERSION_NUMBER => l_OBJECT_VERSION_NUMBER,
      p_ACTIVE_START_DATE     => p_instance_asset_rec.ACTIVE_START_DATE,
      p_ACTIVE_END_DATE       => p_instance_asset_rec.ACTIVE_END_DATE);

    IF nvl(p_txn_rec.transaction_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN -- changed <> to = bug 5207557
      -- Call create_transaction to create txn log
      CSI_TRANSACTIONS_PVT.Create_transaction (
        p_api_version            => p_api_version,
        p_commit                 => p_commit,
        p_init_msg_list          => p_init_msg_list,
        p_validation_level       => p_validation_level,
        p_Success_If_Exists_Flag => 'Y',
        P_transaction_rec        => p_txn_rec,
        x_return_status          => x_return_status,
        x_msg_count              => x_msg_count,
        x_msg_data               => x_msg_data);

      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        FND_MESSAGE.SET_NAME('CSI','CSI_FAILED_TO_VALIDATE_TXN');
        FND_MESSAGE.SET_TOKEN('API_NAME',l_api_name);
        FND_MESSAGE.SET_TOKEN('TRANSACTION_ID',p_txn_rec.transaction_id );
        FND_MSG_PUB.Add;
        FOR i in 1..x_msg_Count LOOP
          FND_MSG_PUB.Get(p_msg_index     => i,
                          p_encoded       => 'F',
                          p_data          => x_msg_data,
                          p_msg_index_out => x_msg_index_out );
          debug( 'message data = '||x_msg_data);
        End LOOP;
        IF fnd_api.to_boolean(p_commit) THEN
          ROLLBACK TO update_instance_asset_pvt;
        END IF;
        RETURN;
      END IF;
    END IF;

    -- Generate the instance asset history id from the sequence
    l_instance_asset_hist_id := CSI_Asset_vld_pvt.gen_inst_asset_hist_id;

    -- Get the full_dump_frequency from csi_install_parameter
    IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
      csi_gen_utility_pvt.populate_install_param_rec;
    END IF;
    --
    l_full_dump_frequency := csi_datastructures_pub.g_install_param_rec.history_full_dump_frequency;
    --
    IF l_full_dump_frequency IS NULL THEN
      FND_MESSAGE.SET_NAME('CSI','CSI_API_GET_FULL_DUMP_FAILED');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    --
    SELECT mod(l_object_version_number,l_full_dump_frequency)
    INTO   l_mod_value
    FROM   dual;

    l_temp_inst_asset_rec.instance_asset_id     := p_instance_asset_rec.instance_asset_id ;
    l_temp_inst_asset_rec.instance_id           := p_instance_asset_rec.instance_id ;
    l_temp_inst_asset_rec.fa_asset_id           := p_instance_asset_rec.fa_asset_id ;
    l_temp_inst_asset_rec.fa_book_type_code     := p_instance_asset_rec.fa_book_type_code ;
    l_temp_inst_asset_rec.fa_location_id        := p_instance_asset_rec.fa_location_id ;
    l_temp_inst_asset_rec.asset_quantity        := p_instance_asset_rec.asset_quantity ;
    l_temp_inst_asset_rec.update_status         := p_instance_asset_rec.update_status ;
    l_temp_inst_asset_rec.active_start_date     := p_instance_asset_rec.active_start_date ;
    l_temp_inst_asset_rec.active_end_date       := p_instance_asset_rec.active_end_date ;
    l_temp_inst_asset_rec.object_version_number := p_instance_asset_rec.object_version_number ;

    -- Start of modification for Bug#2547034 on 09/20/02 - rtalluri
    BEGIN
      SELECT  instance_asset_history_id
      INTO    l_asset_hist_id
      FROM    csi_i_assets_h h
      WHERE   h.transaction_id = p_txn_rec.transaction_id
      AND     h.instance_asset_id = p_instance_asset_rec.instance_asset_id;

      OPEN   asset_hist_csr(l_asset_hist_id);
      FETCH  asset_hist_csr INTO l_asset_hist_csr ;
      CLOSE  asset_hist_csr;

      IF l_asset_hist_csr.full_dump_flag = 'Y' THEN
        CSI_I_ASSETS_H_PKG.Update_Row (
          p_INSTANCE_ASSET_HISTORY_ID    => l_asset_hist_id,
          p_INSTANCE_ASSET_ID            => fnd_api.g_miss_num,
          p_TRANSACTION_ID               => fnd_api.g_miss_num,
          p_OLD_INSTANCE_ID              => fnd_api.g_miss_num,
          p_NEW_INSTANCE_ID              => l_temp_inst_asset_rec.INSTANCE_ID,
          p_OLD_FA_ASSET_ID              => fnd_api.g_miss_num,
          p_NEW_FA_ASSET_ID              => l_temp_inst_asset_rec.FA_ASSET_ID,
          p_OLD_ASSET_QUANTITY           => fnd_api.g_miss_num,
          p_NEW_ASSET_QUANTITY           => l_temp_inst_asset_rec.ASSET_QUANTITY,
          p_OLD_FA_BOOK_TYPE_CODE        => fnd_api.g_miss_char,
          p_NEW_FA_BOOK_TYPE_CODE        => l_temp_inst_asset_rec.FA_BOOK_TYPE_CODE,
          p_OLD_FA_LOCATION_ID           => fnd_api.g_miss_num,
          p_NEW_FA_LOCATION_ID           => l_temp_inst_asset_rec.FA_LOCATION_ID,
          p_OLD_UPDATE_STATUS            => fnd_api.g_miss_char,
          p_NEW_UPDATE_STATUS            => l_temp_inst_asset_rec.UPDATE_STATUS,
          p_OLD_FA_SYNC_FLAG             => fnd_api.g_miss_char,
          p_NEW_FA_SYNC_FLAG             => l_temp_inst_asset_rec.FA_SYNC_FLAG,
          p_OLD_FA_MASS_ADDITION_ID      => fnd_api.g_miss_num,
          p_NEW_FA_MASS_ADDITION_ID      => l_temp_inst_asset_rec.FA_MASS_ADDITION_ID,
          p_OLD_CREATION_COMPLETE_FLAG   => fnd_api.g_miss_char,
          p_NEW_CREATION_COMPLETE_FLAG   => l_temp_inst_asset_rec.CREATION_COMPLETE_FLAG,
          p_FULL_DUMP_FLAG               => fnd_api.g_miss_char,
          p_CREATED_BY                   => fnd_api.g_miss_num,
          p_CREATION_DATE                => fnd_api.g_miss_date,
          p_LAST_UPDATED_BY              => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_DATE             => SYSDATE,
          p_LAST_UPDATE_LOGIN            => FND_GLOBAL.LOGIN_ID,
          p_OBJECT_VERSION_NUMBER        => fnd_api.g_miss_num,
          p_OLD_ACTIVE_START_DATE        => fnd_api.g_miss_date,
          p_NEW_ACTIVE_START_DATE        => l_temp_inst_asset_rec.ACTIVE_START_DATE,
          p_OLD_ACTIVE_END_DATE          => fnd_api.g_miss_date,
          p_NEW_ACTIVE_END_DATE          => l_temp_inst_asset_rec.ACTIVE_END_DATE);

      ELSE

        IF ( l_asset_hist_csr.old_instance_id IS NULL AND  l_asset_hist_csr.new_instance_id IS NULL ) THEN
          IF ( l_temp_inst_asset_rec.instance_id = l_curr_asset_rec.instance_id )
              OR ( l_temp_inst_asset_rec.instance_id = fnd_api.g_miss_num )
          THEN
            l_asset_hist_csr.old_instance_id := NULL;
            l_asset_hist_csr.new_instance_id := NULL;
          ELSE
            l_asset_hist_csr.old_instance_id := fnd_api.g_miss_num;
            l_asset_hist_csr.new_instance_id := l_temp_inst_asset_rec.instance_id;
          END IF;
        ELSE
          l_asset_hist_csr.old_instance_id := fnd_api.g_miss_num;
          l_asset_hist_csr.new_instance_id := l_temp_inst_asset_rec.instance_id;
        END IF;
        --
        IF ( l_asset_hist_csr.old_fa_asset_id IS NULL AND  l_asset_hist_csr.new_fa_asset_id IS NULL ) THEN
          IF  ( l_temp_inst_asset_rec.fa_asset_id = l_curr_asset_rec.fa_asset_id )
                OR
              ( l_temp_inst_asset_rec.fa_asset_id = fnd_api.g_miss_num )
          THEN
            l_asset_hist_csr.old_fa_asset_id := NULL;
            l_asset_hist_csr.new_fa_asset_id := NULL;
          ELSE
            l_asset_hist_csr.old_fa_asset_id := fnd_api.g_miss_num;
            l_asset_hist_csr.new_fa_asset_id := l_temp_inst_asset_rec.fa_asset_id;
          END IF;
        ELSE
          l_asset_hist_csr.old_fa_asset_id := fnd_api.g_miss_num;
          l_asset_hist_csr.new_fa_asset_id := l_temp_inst_asset_rec.fa_asset_id;
        END IF;
        --
        IF ( l_asset_hist_csr.old_fa_book_type_code IS NULL AND  l_asset_hist_csr.new_fa_book_type_code IS NULL) THEN
          IF  ( l_temp_inst_asset_rec.fa_book_type_code = l_curr_asset_rec.fa_book_type_code )
                      OR ( l_temp_inst_asset_rec.fa_book_type_code = fnd_api.g_miss_char ) THEN
                           l_asset_hist_csr.old_fa_book_type_code := NULL;
                           l_asset_hist_csr.new_fa_book_type_code := NULL;
                     ELSE
                           l_asset_hist_csr.old_fa_book_type_code := fnd_api.g_miss_char;
                           l_asset_hist_csr.new_fa_book_type_code := l_temp_inst_asset_rec.fa_book_type_code;
                     END IF;
             ELSE
                     l_asset_hist_csr.old_fa_book_type_code := fnd_api.g_miss_char;
                     l_asset_hist_csr.new_fa_book_type_code := l_temp_inst_asset_rec.fa_book_type_code;
             END IF;
             --
             IF    ( l_asset_hist_csr.old_fa_location_id IS NULL
                AND  l_asset_hist_csr.new_fa_location_id IS NULL ) THEN
                     IF  ( l_temp_inst_asset_rec.fa_location_id = l_curr_asset_rec.fa_location_id )
                      OR ( l_temp_inst_asset_rec.fa_location_id = fnd_api.g_miss_num ) THEN
                           l_asset_hist_csr.old_fa_location_id := NULL;
                           l_asset_hist_csr.new_fa_location_id := NULL;
                     ELSE
                           l_asset_hist_csr.old_fa_location_id := fnd_api.g_miss_num;
                           l_asset_hist_csr.new_fa_location_id := l_temp_inst_asset_rec.fa_location_id;
                     END IF;
             ELSE
                     l_asset_hist_csr.old_fa_location_id := fnd_api.g_miss_num;
                     l_asset_hist_csr.new_fa_location_id := l_temp_inst_asset_rec.fa_location_id;
             END IF;
             --
             IF    ( l_asset_hist_csr.old_asset_quantity IS NULL
                AND  l_asset_hist_csr.new_asset_quantity IS NULL ) THEN
                     IF  ( l_temp_inst_asset_rec.asset_quantity = l_curr_asset_rec.asset_quantity )
                      OR ( l_temp_inst_asset_rec.asset_quantity = fnd_api.g_miss_num ) THEN
                           l_asset_hist_csr.old_asset_quantity := NULL;
                           l_asset_hist_csr.new_asset_quantity := NULL;
                     ELSE
                           l_asset_hist_csr.old_asset_quantity := fnd_api.g_miss_num;
                           l_asset_hist_csr.new_asset_quantity := l_temp_inst_asset_rec.asset_quantity;
                     END IF;
             ELSE
                     l_asset_hist_csr.old_asset_quantity := fnd_api.g_miss_num;
                     l_asset_hist_csr.new_asset_quantity := l_temp_inst_asset_rec.asset_quantity;
             END IF;
             --
             IF    ( l_asset_hist_csr.old_update_status IS NULL
                AND  l_asset_hist_csr.new_update_status IS NULL ) THEN
                     IF  ( l_temp_inst_asset_rec.update_status = l_curr_asset_rec.update_status )
                      OR ( l_temp_inst_asset_rec.update_status = fnd_api.g_miss_char ) THEN
                           l_asset_hist_csr.old_update_status := NULL;
                           l_asset_hist_csr.new_update_status := NULL;
                     ELSE
                           l_asset_hist_csr.old_update_status := fnd_api.g_miss_char;
                           l_asset_hist_csr.new_update_status := l_temp_inst_asset_rec.update_status;
                     END IF;
             ELSE
                     l_asset_hist_csr.old_update_status := fnd_api.g_miss_char;
                     l_asset_hist_csr.new_update_status := l_temp_inst_asset_rec.update_status;
             END IF;
             --
             IF    ( l_asset_hist_csr.old_active_start_date IS NULL
                AND  l_asset_hist_csr.new_active_start_date IS NULL ) THEN
                     IF  ( l_temp_inst_asset_rec.active_start_date = l_curr_asset_rec.active_start_date )
                      OR ( l_temp_inst_asset_rec.active_start_date = fnd_api.g_miss_date ) THEN
                           l_asset_hist_csr.old_active_start_date := NULL;
                           l_asset_hist_csr.new_active_start_date := NULL;
                     ELSE
                           l_asset_hist_csr.old_active_start_date := fnd_api.g_miss_date;
                           l_asset_hist_csr.new_active_start_date := l_temp_inst_asset_rec.active_start_date;
                     END IF;
             ELSE
                     l_asset_hist_csr.old_active_start_date := fnd_api.g_miss_date;
                     l_asset_hist_csr.new_active_start_date := l_temp_inst_asset_rec.active_start_date;
             END IF;
             --
             IF    ( l_asset_hist_csr.old_active_end_date IS NULL
                AND  l_asset_hist_csr.new_active_end_date IS NULL ) THEN
                     IF  ( l_temp_inst_asset_rec.active_end_date = l_curr_asset_rec.active_end_date )
                      OR ( l_temp_inst_asset_rec.active_end_date = fnd_api.g_miss_date ) THEN
                           l_asset_hist_csr.old_active_end_date := NULL;
                           l_asset_hist_csr.new_active_end_date := NULL;
                     ELSE
                           l_asset_hist_csr.old_active_end_date := fnd_api.g_miss_date;
                           l_asset_hist_csr.new_active_end_date := l_temp_inst_asset_rec.active_end_date;
                     END IF;
             ELSE
                     l_asset_hist_csr.old_active_end_date := fnd_api.g_miss_date;
                     l_asset_hist_csr.new_active_end_date := l_temp_inst_asset_rec.active_end_date;
             END IF;


        csi_i_assets_h_pkg.update_row (
          p_instance_asset_history_id    => l_asset_hist_id                         ,
          p_instance_asset_id            => fnd_api.g_miss_num                      ,
          p_transaction_id               => fnd_api.g_miss_num                      ,
          p_old_instance_id              => l_asset_hist_csr.old_instance_id        ,
          p_new_instance_id              => l_asset_hist_csr.new_instance_id        ,
          p_old_fa_asset_id              => l_asset_hist_csr.old_fa_asset_id        ,
          p_new_fa_asset_id              => l_asset_hist_csr.new_fa_asset_id        ,
          p_old_asset_quantity           => l_asset_hist_csr.old_asset_quantity     ,
          p_new_asset_quantity           => l_asset_hist_csr.new_asset_quantity     ,
          p_old_fa_book_type_code        => l_asset_hist_csr.old_fa_book_type_code  ,
          p_new_fa_book_type_code        => l_asset_hist_csr.new_fa_book_type_code  ,
          p_old_fa_location_id           => l_asset_hist_csr.old_fa_location_id     ,
          p_new_fa_location_id           => l_asset_hist_csr.new_fa_location_id     ,
          p_old_update_status            => l_asset_hist_csr.old_update_status      ,
          p_new_update_status            => l_asset_hist_csr.new_update_status      ,
          p_OLD_FA_SYNC_FLAG             => l_asset_hist_csr.old_fa_sync_flag,
          p_NEW_FA_SYNC_FLAG             => l_asset_hist_csr.new_fa_sync_flag,
          p_OLD_FA_MASS_ADDITION_ID      => l_asset_hist_csr.old_fa_mass_addition_id,
          p_NEW_FA_MASS_ADDITION_ID      => l_asset_hist_csr.new_fa_mass_addition_id,
          p_OLD_CREATION_COMPLETE_FLAG   => l_asset_hist_csr.old_creation_complete_flag,
          p_NEW_CREATION_COMPLETE_FLAG   => l_asset_hist_csr.new_creation_complete_flag,
          p_full_dump_flag               => fnd_api.g_miss_char                     ,
          p_created_by                   => fnd_api.g_miss_num                      ,
          p_creation_date                => fnd_api.g_miss_date                     ,
          p_last_updated_by              => fnd_global.user_id                      ,
          p_last_update_date             => SYSDATE                                 ,
          p_last_update_login            => fnd_global.login_id                     ,
          p_object_version_number        => fnd_api.g_miss_num                      ,
          p_old_active_start_date        => l_asset_hist_csr.old_active_start_date  ,
          p_new_active_start_date        => l_asset_hist_csr.new_active_start_date  ,
          p_old_active_end_date          => l_asset_hist_csr.old_active_end_date    ,
          p_new_active_end_date          => l_asset_hist_csr.new_active_end_date    );
        END IF;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN

        IF (l_mod_value = 0) THEN
          -- If the mod value is 0 then dump all the columns both changed and unchanged
          -- changed columns have old and new values while the unchanged values have old and new values
          -- exactly same
          -- assign the party rec
             l_temp_inst_asset_rec.instance_asset_id     := p_instance_asset_rec.instance_asset_id ;
             l_temp_inst_asset_rec.instance_id           := p_instance_asset_rec.instance_id ;
             l_temp_inst_asset_rec.fa_asset_id           := p_instance_asset_rec.fa_asset_id ;
             l_temp_inst_asset_rec.fa_book_type_code     := p_instance_asset_rec.fa_book_type_code ;
             l_temp_inst_asset_rec.fa_location_id        := p_instance_asset_rec.fa_location_id ;
             l_temp_inst_asset_rec.asset_quantity        := p_instance_asset_rec.asset_quantity ;
             l_temp_inst_asset_rec.update_status         := p_instance_asset_rec.update_status ;
             l_temp_inst_asset_rec.active_start_date     := p_instance_asset_rec.active_start_date ;
             l_temp_inst_asset_rec.active_end_date       := p_instance_asset_rec.active_end_date ;
             l_temp_inst_asset_rec.object_version_number := p_instance_asset_rec.object_version_number ;

          IF (p_instance_asset_rec.FA_ASSET_ID = FND_API.G_MISS_NUM) THEN
              l_temp_inst_asset_rec.FA_ASSET_ID := l_curr_asset_rec.FA_ASSET_ID ;
          END IF;
          IF (p_instance_asset_rec.ASSET_QUANTITY = FND_API.G_MISS_NUM) THEN
              l_temp_inst_asset_rec.ASSET_QUANTITY := l_curr_asset_rec.ASSET_QUANTITY ;
          END IF;
          IF (p_instance_asset_rec.FA_BOOK_TYPE_CODE = FND_API.G_MISS_CHAR) THEN
              l_temp_inst_asset_rec.FA_BOOK_TYPE_CODE := l_curr_asset_rec.FA_BOOK_TYPE_CODE ;
          END IF;
          IF (p_instance_asset_rec.FA_LOCATION_ID = FND_API.G_MISS_NUM) THEN
              l_temp_inst_asset_rec.FA_LOCATION_ID := l_curr_asset_rec.FA_LOCATION_ID ;
          END IF;
          IF  (p_instance_asset_rec.UPDATE_STATUS = FND_API.G_MISS_CHAR) THEN
              l_temp_inst_asset_rec.UPDATE_STATUS := l_curr_asset_rec.UPDATE_STATUS ;
          END IF;

       -- Call table handlers to insert into history table
       CSI_I_ASSETS_H_PKG.Insert_Row
       (
          px_INSTANCE_ASSET_HISTORY_ID   => l_instance_asset_hist_id               ,
          p_INSTANCE_ASSET_ID            => p_instance_asset_rec.INSTANCE_ASSET_ID ,
          p_TRANSACTION_ID               => p_txn_rec.transaction_id               ,
          p_OLD_INSTANCE_ID              => l_curr_asset_rec.INSTANCE_ID           ,
          p_NEW_INSTANCE_ID              => l_temp_inst_asset_rec.INSTANCE_ID       ,
          p_OLD_FA_ASSET_ID              => l_curr_asset_rec.FA_ASSET_ID           ,
          p_NEW_FA_ASSET_ID              => l_temp_inst_asset_rec.FA_ASSET_ID       ,
          p_OLD_ASSET_QUANTITY           => l_curr_asset_rec.ASSET_QUANTITY        ,
          p_NEW_ASSET_QUANTITY           => l_temp_inst_asset_rec.ASSET_QUANTITY    ,
          p_OLD_FA_BOOK_TYPE_CODE        => l_curr_asset_rec.FA_BOOK_TYPE_CODE     ,
          p_NEW_FA_BOOK_TYPE_CODE        => l_temp_inst_asset_rec.FA_BOOK_TYPE_CODE ,
          p_OLD_FA_LOCATION_ID           => l_curr_asset_rec.FA_LOCATION_ID        ,
          p_NEW_FA_LOCATION_ID           => l_temp_inst_asset_rec.FA_LOCATION_ID    ,
          p_OLD_UPDATE_STATUS            => l_curr_asset_rec.UPDATE_STATUS         ,
          p_NEW_UPDATE_STATUS            => l_temp_inst_asset_rec.UPDATE_STATUS     ,
          p_OLD_FA_SYNC_FLAG             => l_curr_asset_rec.FA_SYNC_FLAG,
          p_NEW_FA_SYNC_FLAG             => l_temp_inst_asset_rec.FA_SYNC_FLAG,
          p_OLD_FA_MASS_ADDITION_ID      => l_curr_asset_rec.FA_MASS_ADDITION_ID,
          p_NEW_FA_MASS_ADDITION_ID      => l_temp_inst_asset_rec.FA_MASS_ADDITION_ID,
          p_OLD_CREATION_COMPLETE_FLAG   => l_curr_asset_rec.CREATION_COMPLETE_FLAG,
          p_NEW_CREATION_COMPLETE_FLAG   => l_temp_inst_asset_rec.creation_complete_flag,
          p_FULL_DUMP_FLAG               => 'Y'                                    ,
          p_CREATED_BY                   => FND_GLOBAL.USER_ID                     ,
          p_CREATION_DATE                => SYSDATE                                ,
          p_LAST_UPDATED_BY              => FND_GLOBAL.USER_ID                     ,
          p_LAST_UPDATE_DATE             => SYSDATE                                ,
          p_LAST_UPDATE_LOGIN            => FND_GLOBAL.LOGIN_ID                    ,
          p_OBJECT_VERSION_NUMBER        => 1                                      ,
          p_OLD_ACTIVE_START_DATE        => l_curr_asset_rec.ACTIVE_START_DATE     ,
          p_NEW_ACTIVE_START_DATE        => l_temp_inst_asset_rec.ACTIVE_START_DATE,
          p_OLD_ACTIVE_END_DATE          => l_curr_asset_rec.ACTIVE_END_DATE       ,
          p_NEW_ACTIVE_END_DATE          => l_temp_inst_asset_rec.ACTIVE_END_DATE  );


       ELSE
           -- assign the party rec
          l_temp_inst_asset_rec := l_curr_asset_rec;

          -- If the mod value is not equal to zero then dump only the changed columns
          -- while the unchanged values have old and new values as null
           IF (p_instance_asset_rec.fa_asset_id = fnd_api.g_miss_num) OR
               NVL(p_instance_asset_rec.fa_asset_id, fnd_api.g_miss_num) = NVL(l_temp_inst_asset_rec.fa_asset_id, fnd_api.g_miss_num) THEN
                l_ins_asset_hist_rec.old_fa_asset_id := NULL;
                l_ins_asset_hist_rec.new_fa_asset_id := NULL;
           ELSIF
              NVL(l_temp_inst_asset_rec.fa_asset_id,fnd_api.g_miss_num) <> NVL(p_instance_asset_rec.fa_asset_id,fnd_api.g_miss_num) THEN
                l_ins_asset_hist_rec.old_fa_asset_id := l_temp_inst_asset_rec.fa_asset_id ;
                l_ins_asset_hist_rec.new_fa_asset_id := p_instance_asset_rec.fa_asset_id ;
           END IF;
           --
           IF (p_instance_asset_rec.asset_quantity = fnd_api.g_miss_num) OR
               NVL(p_instance_asset_rec.asset_quantity, fnd_api.g_miss_num) = NVL(l_temp_inst_asset_rec.asset_quantity, fnd_api.g_miss_num) THEN
                l_ins_asset_hist_rec.old_asset_quantity := NULL;
                l_ins_asset_hist_rec.new_asset_quantity := NULL;
           ELSIF
              NVL(l_temp_inst_asset_rec.asset_quantity,fnd_api.g_miss_num) <> NVL(p_instance_asset_rec.asset_quantity,fnd_api.g_miss_num) THEN
                l_ins_asset_hist_rec.old_asset_quantity := l_temp_inst_asset_rec.asset_quantity ;
                l_ins_asset_hist_rec.new_asset_quantity := p_instance_asset_rec.asset_quantity ;
           END IF;
           --
           IF (p_instance_asset_rec.fa_book_type_code = fnd_api.g_miss_char) OR
               NVL(p_instance_asset_rec.fa_book_type_code, fnd_api.g_miss_char) = NVL(l_temp_inst_asset_rec.fa_book_type_code, fnd_api.g_miss_char) THEN
                l_ins_asset_hist_rec.old_fa_book_type_code := NULL;
                l_ins_asset_hist_rec.new_fa_book_type_code := NULL;
           ELSIF
              NVL(l_temp_inst_asset_rec.fa_book_type_code,fnd_api.g_miss_char) <> NVL(p_instance_asset_rec.fa_book_type_code,fnd_api.g_miss_char) THEN
                l_ins_asset_hist_rec.old_fa_book_type_code := l_temp_inst_asset_rec.fa_book_type_code ;
                l_ins_asset_hist_rec.new_fa_book_type_code := p_instance_asset_rec.fa_book_type_code ;
           END IF;
           --
           IF (p_instance_asset_rec.fa_location_id = fnd_api.g_miss_num) OR
               NVL(p_instance_asset_rec.fa_location_id, fnd_api.g_miss_num) = NVL(l_temp_inst_asset_rec.fa_location_id, fnd_api.g_miss_num) THEN
                l_ins_asset_hist_rec.old_fa_location_id := NULL;
                l_ins_asset_hist_rec.new_fa_location_id := NULL;
           ELSIF
              NVL(l_temp_inst_asset_rec.fa_location_id,fnd_api.g_miss_num) <> NVL(p_instance_asset_rec.fa_location_id,fnd_api.g_miss_num) THEN
                l_ins_asset_hist_rec.old_fa_location_id := l_temp_inst_asset_rec.fa_location_id ;
                l_ins_asset_hist_rec.new_fa_location_id := p_instance_asset_rec.fa_location_id ;
           END IF;
           --
           IF (p_instance_asset_rec.update_status = fnd_api.g_miss_char) OR
               NVL(p_instance_asset_rec.update_status, fnd_api.g_miss_char) = NVL(l_temp_inst_asset_rec.update_status, fnd_api.g_miss_char) THEN
                l_ins_asset_hist_rec.old_fa_book_type_code := NULL;
                l_ins_asset_hist_rec.new_fa_book_type_code := NULL;
           ELSIF
              NVL(l_temp_inst_asset_rec.update_status,fnd_api.g_miss_char) <> NVL(p_instance_asset_rec.update_status,fnd_api.g_miss_char) THEN
                l_ins_asset_hist_rec.old_fa_book_type_code := l_temp_inst_asset_rec.update_status ;
                l_ins_asset_hist_rec.new_fa_book_type_code := p_instance_asset_rec.update_status ;
           END IF;
           --
           IF (p_instance_asset_rec.active_start_date = fnd_api.g_miss_date) OR
               NVL(p_instance_asset_rec.active_start_date, fnd_api.g_miss_date) = NVL(l_temp_inst_asset_rec.active_start_date, fnd_api.g_miss_date) THEN
                l_ins_asset_hist_rec.old_active_start_date := NULL;
                l_ins_asset_hist_rec.new_active_start_date := NULL;
           ELSIF
              NVL(l_temp_inst_asset_rec.active_start_date,fnd_api.g_miss_date) <> NVL(p_instance_asset_rec.active_start_date,fnd_api.g_miss_date) THEN
                l_ins_asset_hist_rec.old_active_start_date := l_temp_inst_asset_rec.active_start_date ;
                l_ins_asset_hist_rec.new_active_start_date := p_instance_asset_rec.active_start_date ;
           END IF;
           --
           IF (p_instance_asset_rec.active_end_date = fnd_api.g_miss_date) OR
               NVL(p_instance_asset_rec.active_end_date, fnd_api.g_miss_date) = NVL(l_temp_inst_asset_rec.active_end_date, fnd_api.g_miss_date) THEN
                l_ins_asset_hist_rec.old_active_end_date := NULL;
                l_ins_asset_hist_rec.new_active_end_date := NULL;
           ELSIF
              NVL(l_temp_inst_asset_rec.active_end_date,fnd_api.g_miss_date) <> NVL(p_instance_asset_rec.active_end_date,fnd_api.g_miss_date) THEN
                l_ins_asset_hist_rec.old_active_end_date := l_temp_inst_asset_rec.active_end_date ;
                l_ins_asset_hist_rec.new_active_end_date := p_instance_asset_rec.active_end_date ;
           END IF;
           --

       -- Call table handlers to insert into history table
       CSI_I_ASSETS_H_PKG.Insert_Row (
          px_INSTANCE_ASSET_HISTORY_ID   => l_instance_asset_hist_id ,
          p_INSTANCE_ASSET_ID            => p_instance_asset_rec.INSTANCE_ASSET_ID ,
          p_TRANSACTION_ID               => p_txn_rec.transaction_id ,
          p_OLD_INSTANCE_ID              => l_ins_asset_hist_rec.old_INSTANCE_ID ,
          p_NEW_INSTANCE_ID              => l_ins_asset_hist_rec.new_INSTANCE_ID ,
          p_OLD_FA_ASSET_ID              => l_ins_asset_hist_rec.old_FA_ASSET_ID ,
          p_NEW_FA_ASSET_ID              => l_ins_asset_hist_rec.new_FA_ASSET_ID ,
          p_OLD_ASSET_QUANTITY           => l_ins_asset_hist_rec.old_ASSET_QUANTITY ,
          p_NEW_ASSET_QUANTITY           => l_ins_asset_hist_rec.new_ASSET_QUANTITY ,
          p_OLD_FA_BOOK_TYPE_CODE        => l_ins_asset_hist_rec.old_FA_BOOK_TYPE_CODE ,
          p_NEW_FA_BOOK_TYPE_CODE        => l_ins_asset_hist_rec.new_FA_BOOK_TYPE_CODE ,
          p_OLD_FA_LOCATION_ID           => l_ins_asset_hist_rec.old_FA_LOCATION_ID ,
          p_NEW_FA_LOCATION_ID           => l_ins_asset_hist_rec.new_FA_LOCATION_ID ,
          p_OLD_UPDATE_STATUS            => l_ins_asset_hist_rec.old_UPDATE_STATUS ,
          p_NEW_UPDATE_STATUS            => l_ins_asset_hist_rec.new_UPDATE_STATUS ,
          p_OLD_FA_SYNC_FLAG             => l_ins_asset_hist_rec.old_fa_sync_flag,
          p_NEW_FA_SYNC_FLAG             => l_ins_asset_hist_rec.new_fa_sync_flag,
          p_OLD_FA_MASS_ADDITION_ID      => l_ins_asset_hist_rec.old_fa_mass_addition_id,
          p_NEW_FA_MASS_ADDITION_ID      => l_ins_asset_hist_rec.new_fa_mass_addition_id,
          p_OLD_CREATION_COMPLETE_FLAG   => l_ins_asset_hist_rec.old_creation_complete_flag,
          p_NEW_CREATION_COMPLETE_FLAG   => l_ins_asset_hist_rec.new_creation_complete_flag,
          p_FULL_DUMP_FLAG               => 'N' ,
          p_CREATED_BY                   => FND_GLOBAL.USER_ID ,
          p_CREATION_DATE                => SYSDATE ,
          p_LAST_UPDATED_BY              => FND_GLOBAL.USER_ID ,
          p_LAST_UPDATE_DATE             => SYSDATE ,
          p_LAST_UPDATE_LOGIN            => FND_GLOBAL.LOGIN_ID ,
          p_OBJECT_VERSION_NUMBER        => 1 ,
          p_OLD_ACTIVE_START_DATE        => l_ins_asset_hist_rec.old_ACTIVE_START_DATE ,
          p_NEW_ACTIVE_START_DATE        => l_ins_asset_hist_rec.new_ACTIVE_START_DATE ,
          p_OLD_ACTIVE_END_DATE          => l_ins_asset_hist_rec.old_ACTIVE_END_DATE ,
          p_NEW_ACTIVE_END_DATE          => l_ins_asset_hist_rec.new_ACTIVE_END_DATE  );

    END IF;

   END;
   -- End of modification for Bug#2547034 on 09/20/02 - rtalluri

--update the accounting class code in the csi_item_instances
      csi_item_instance_pvt.get_and_update_acct_class
         ( p_api_version         =>     p_api_version
          ,p_commit              =>     p_commit
          ,p_init_msg_list       =>     p_init_msg_list
          ,p_validation_level    =>     p_validation_level
          ,p_instance_id         =>     l_curr_asset_rec.instance_id
          ,p_instance_expiry_flag =>    p_instance_asset_rec.check_for_instance_expiry
          ,p_txn_rec             =>     p_txn_rec
          ,x_acct_class_code     =>     l_acct_class_code
          ,x_return_status       =>     x_return_status
          ,x_msg_count           =>     x_msg_count
          ,x_msg_data            =>     x_msg_data
         );

      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         FOR i in 1..x_msg_Count LOOP
            FND_MSG_PUB.Get(p_msg_index     => i,
                            p_encoded       => 'F',
                            p_data          => x_msg_data,
                            p_msg_index_out => x_msg_index_out );
         End LOOP;
         RAISE fnd_api.g_exc_error;
      END IF;

    --
    -- End of API body

    -- Standard check of p_commit.
        IF FND_API.To_Boolean( p_commit ) THEN
                COMMIT WORK;
        END IF;

    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count ,
      p_data  => x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      X_return_status := FND_API.G_RET_STS_ERROR ;
      IF fnd_api.to_boolean(p_commit) THEN
        ROLLBACK TO update_instance_asset_pvt;
      END IF;
      FND_MSG_PUB.Count_And_Get (
        p_count => x_msg_count,
        p_data  => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF fnd_api.to_boolean(p_commit) THEN
        ROLLBACK TO update_instance_asset_pvt;
      END IF;
      FND_MSG_PUB.Count_And_Get(
        p_count => x_msg_count,
        p_data  => x_msg_data);
    WHEN OTHERS THEN
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF fnd_api.to_boolean(p_commit) THEN
        ROLLBACK TO update_instance_asset_pvt;
      END IF;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(
        p_count => x_msg_count,
        p_data  => x_msg_data);
  END update_instance_asset;

/*-------------------------------------------------------*/
/* procedure name: get_instance_asset_hist               */
/* description :  Retreives asset history for            */
/*                a given transaction                    */
/*-------------------------------------------------------*/


PROCEDURE get_instance_asset_hist
( p_api_version         IN  NUMBER
 ,p_commit              IN  VARCHAR2
 ,p_init_msg_list       IN  VARCHAR2
 ,p_validation_level    IN  NUMBER
 ,p_transaction_id      IN  NUMBER
 ,x_ins_asset_hist_tbl  OUT NOCOPY csi_datastructures_pub.ins_asset_history_tbl
 ,x_return_status       OUT NOCOPY VARCHAR2
 ,x_msg_count           OUT NOCOPY NUMBER
 ,x_msg_data            OUT NOCOPY VARCHAR2
 ) IS

CURSOR txn_asset_hist_csr (p_txn_id IN NUMBER) IS
   SELECT      ah.INSTANCE_ASSET_HISTORY_ID   ,
               ah.INSTANCE_ASSET_ID              ,
               ah.TRANSACTION_ID                 ,
               ah.OLD_INSTANCE_ID                ,
               ah.NEW_INSTANCE_ID                ,
               ah.OLD_FA_ASSET_ID                ,
               ah.NEW_FA_ASSET_ID                ,
               ah.OLD_ASSET_QUANTITY             ,
               ah.NEW_ASSET_QUANTITY             ,
               ah.OLD_FA_BOOK_TYPE_CODE          ,
               ah.NEW_FA_BOOK_TYPE_CODE          ,
               ah.OLD_FA_LOCATION_ID             ,
               ah.NEW_FA_LOCATION_ID             ,
               ah.OLD_UPDATE_STATUS              ,
               ah.NEW_UPDATE_STATUS              ,
               ah.FULL_DUMP_FLAG                 ,
               ah.OBJECT_VERSION_NUMBER          ,
               ah.SECURITY_GROUP_ID              ,
               ah.OLD_ACTIVE_START_DATE          ,
               ah.NEW_ACTIVE_START_DATE          ,
               ah.OLD_ACTIVE_END_DATE            ,
               ah.NEW_ACTIVE_END_DATE            ,
               a.INSTANCE_ID
   FROM        csi_i_assets_h ah,
               csi_i_assets   a
   WHERE       ah.transaction_id = p_txn_id
   AND         ah.instance_asset_id = a.instance_asset_id;

l_api_name            CONSTANT   VARCHAR2(30) := 'get_instance_asset_hist';
l_api_version         CONSTANT   NUMBER               := 1.0;
l_old_ins_asset_rec   csi_datastructures_pub.instance_asset_header_rec;
l_new_ins_asset_rec   csi_datastructures_pub.instance_asset_header_rec;
l_old_ins_asset_tbl   csi_datastructures_pub.instance_asset_header_tbl;
l_new_ins_asset_tbl   csi_datastructures_pub.instance_asset_header_tbl;
l_ins_asset_rec       csi_datastructures_pub.ins_asset_history_rec;
l_temp_asset_rec      csi_datastructures_pub.ins_asset_history_rec;
i                     NUMBER :=0 ;
BEGIN
        /*
        IF fnd_api.to_boolean(p_commit)
        THEN
           SAVEPOINT    get_instance_asset_hist;
        END IF;
        */

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (l_api_version       ,
                                            p_api_version       ,
                                            l_api_name          ,
                                            G_PKG_NAME              )
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

   /***** srramakr commented for bug # 3304439
   -- Check for the profile option and enable trace
   IF (fnd_profile.value('CSI_ENABLE_SQL_TRACE') = 'Y') THEN
                   dbms_session.set_sql_trace(TRUE);
   END IF;

   -- End enable trace
   ****/

   -- Start API body
   --

FOR l_asset_hist_csr IN txn_asset_hist_csr (p_transaction_id)
LOOP
          l_ins_asset_rec:=l_temp_asset_rec;


          --
          IF NVL(l_asset_hist_csr.old_instance_id,fnd_api.g_miss_num) = NVL(l_asset_hist_csr.new_instance_id,fnd_api.g_miss_num)
          THEN
            l_old_ins_asset_rec.instance_id := NULL;
            l_new_ins_asset_rec.instance_id := NULL;
          ELSE
            l_old_ins_asset_rec.instance_id := l_asset_hist_csr.old_instance_id;
            l_new_ins_asset_rec.instance_id := l_asset_hist_csr.new_instance_id;
          END IF;
          --
          IF NVL(l_asset_hist_csr.old_fa_asset_id,fnd_api.g_miss_num) = NVL(l_asset_hist_csr.new_fa_asset_id,fnd_api.g_miss_num)
          THEN
            l_old_ins_asset_rec.fa_asset_id := NULL;
            l_new_ins_asset_rec.fa_asset_id := NULL;
          ELSE
            l_old_ins_asset_rec.fa_asset_id := l_asset_hist_csr.old_fa_asset_id;
            l_new_ins_asset_rec.fa_asset_id := l_asset_hist_csr.new_fa_asset_id;
          END IF;
          --
          IF NVL(l_asset_hist_csr.old_fa_book_type_code,fnd_api.g_miss_char) = NVL(l_asset_hist_csr.new_fa_book_type_code,fnd_api.g_miss_char)
          THEN
            l_old_ins_asset_rec.fa_book_type_code := NULL;
            l_new_ins_asset_rec.fa_book_type_code := NULL;
          ELSE
            l_old_ins_asset_rec.fa_book_type_code := l_asset_hist_csr.old_fa_book_type_code;
            l_new_ins_asset_rec.fa_book_type_code := l_asset_hist_csr.new_fa_book_type_code;
          END IF;
          --
          IF NVL(l_asset_hist_csr.old_fa_location_id,fnd_api.g_miss_num) = NVL(l_asset_hist_csr.new_fa_location_id,fnd_api.g_miss_num)
          THEN
            l_old_ins_asset_rec.fa_location_id := NULL;
            l_new_ins_asset_rec.fa_location_id := NULL;
          ELSE
            l_old_ins_asset_rec.fa_location_id := l_asset_hist_csr.old_fa_location_id;
            l_new_ins_asset_rec.fa_location_id := l_asset_hist_csr.new_fa_location_id;
          END IF;
          --
          IF NVL(l_asset_hist_csr.old_asset_quantity,fnd_api.g_miss_num) = NVL(l_asset_hist_csr.new_asset_quantity,fnd_api.g_miss_num)
          THEN
            l_old_ins_asset_rec.asset_quantity := NULL;
            l_new_ins_asset_rec.asset_quantity := NULL;
          ELSE
            l_old_ins_asset_rec.asset_quantity := l_asset_hist_csr.old_asset_quantity;
            l_new_ins_asset_rec.asset_quantity := l_asset_hist_csr.new_asset_quantity;
          END IF;
          --
          IF NVL(l_asset_hist_csr.old_update_status,fnd_api.g_miss_char) = NVL(l_asset_hist_csr.new_update_status,fnd_api.g_miss_char)
          THEN
            l_old_ins_asset_rec.update_status := NULL;
            l_new_ins_asset_rec.update_status := NULL;
          ELSE
            l_old_ins_asset_rec.update_status := l_asset_hist_csr.old_update_status;
            l_new_ins_asset_rec.update_status := l_asset_hist_csr.new_update_status;
          END IF;
          --
          IF NVL(l_asset_hist_csr.old_active_start_date,fnd_api.g_miss_date) = NVL(l_asset_hist_csr.new_active_start_date,fnd_api.g_miss_date)
          THEN
            l_old_ins_asset_rec.active_start_date := NULL;
            l_new_ins_asset_rec.active_start_date := NULL;
          ELSE
            l_old_ins_asset_rec.active_start_date := l_asset_hist_csr.old_active_start_date;
            l_new_ins_asset_rec.active_start_date := l_asset_hist_csr.new_active_start_date;
          END IF;
          --
          IF NVL(l_asset_hist_csr.old_active_end_date,fnd_api.g_miss_date) = NVL(l_asset_hist_csr.new_active_end_date,fnd_api.g_miss_date)
          THEN
            l_old_ins_asset_rec.active_end_date := NULL;
            l_new_ins_asset_rec.active_end_date := NULL;
          ELSE
            l_old_ins_asset_rec.active_end_date := l_asset_hist_csr.old_active_end_date;
            l_new_ins_asset_rec.active_end_date := l_asset_hist_csr.new_active_end_date;
          END IF;
          --

          l_old_ins_asset_tbl(1):=l_old_ins_asset_rec;
          csi_asset_pvt.resolve_id_columns
            (p_asset_header_tbl  => l_old_ins_asset_tbl);
          l_old_ins_asset_rec:=l_old_ins_asset_tbl(1);


          l_new_ins_asset_tbl(1):=l_new_ins_asset_rec;
          csi_asset_pvt.resolve_id_columns
            (p_asset_header_tbl  => l_new_ins_asset_tbl);
          l_new_ins_asset_rec:=l_new_ins_asset_tbl(1);

          --
          IF NVL(l_old_ins_asset_rec.asset_number,fnd_api.g_miss_char) = NVL(l_new_ins_asset_rec.asset_number,fnd_api.g_miss_char)
          THEN
            l_old_ins_asset_rec.asset_number := NULL;
            l_new_ins_asset_rec.asset_number := NULL;
          END IF;
          --
          IF NVL(l_old_ins_asset_rec.serial_number,fnd_api.g_miss_char) = NVL(l_new_ins_asset_rec.serial_number,fnd_api.g_miss_char)
          THEN
            l_old_ins_asset_rec.serial_number := NULL;
            l_new_ins_asset_rec.serial_number := NULL;
          END IF;
          --
          IF NVL(l_old_ins_asset_rec.tag_number,fnd_api.g_miss_char) = NVL(l_new_ins_asset_rec.tag_number,fnd_api.g_miss_char)
          THEN
            l_old_ins_asset_rec.tag_number := NULL;
            l_new_ins_asset_rec.tag_number := NULL;
          END IF;
          --
          IF NVL(l_old_ins_asset_rec.category,fnd_api.g_miss_char) = NVL(l_new_ins_asset_rec.category,fnd_api.g_miss_char)
          THEN
            l_old_ins_asset_rec.category := NULL;
            l_new_ins_asset_rec.category := NULL;
          END IF;
          --
          IF NVL(l_old_ins_asset_rec.fa_location_segment1,fnd_api.g_miss_char) = NVL(l_new_ins_asset_rec.fa_location_segment1,fnd_api.g_miss_char)
          THEN
            l_old_ins_asset_rec.fa_location_segment1 := NULL;
            l_new_ins_asset_rec.fa_location_segment1 := NULL;
          END IF;
          --
          IF NVL(l_old_ins_asset_rec.fa_location_segment2,fnd_api.g_miss_char) = NVL(l_new_ins_asset_rec.fa_location_segment2,fnd_api.g_miss_char)
          THEN
            l_old_ins_asset_rec.fa_location_segment2 := NULL;
            l_new_ins_asset_rec.fa_location_segment2 := NULL;
          END IF;
          --
          IF NVL(l_old_ins_asset_rec.fa_location_segment3,fnd_api.g_miss_char) = NVL(l_new_ins_asset_rec.fa_location_segment3,fnd_api.g_miss_char)
          THEN
            l_old_ins_asset_rec.fa_location_segment3 := NULL;
            l_new_ins_asset_rec.fa_location_segment3 := NULL;
          END IF;
          --
          IF NVL(l_old_ins_asset_rec.fa_location_segment4,fnd_api.g_miss_char) = NVL(l_new_ins_asset_rec.fa_location_segment4,fnd_api.g_miss_char)
          THEN
            l_old_ins_asset_rec.fa_location_segment4 := NULL;
            l_new_ins_asset_rec.fa_location_segment4 := NULL;
          END IF;
          --
          IF NVL(l_old_ins_asset_rec.fa_location_segment5,fnd_api.g_miss_char) = NVL(l_new_ins_asset_rec.fa_location_segment5,fnd_api.g_miss_char)
          THEN
            l_old_ins_asset_rec.fa_location_segment5 := NULL;
            l_new_ins_asset_rec.fa_location_segment5 := NULL;
          END IF;
          --
          IF NVL(l_old_ins_asset_rec.fa_location_segment6,fnd_api.g_miss_char) = NVL(l_new_ins_asset_rec.fa_location_segment6,fnd_api.g_miss_char)
          THEN
            l_old_ins_asset_rec.fa_location_segment6 := NULL;
            l_new_ins_asset_rec.fa_location_segment6 := NULL;
          END IF;
          --
          IF NVL(l_old_ins_asset_rec.fa_location_segment7,fnd_api.g_miss_char) = NVL(l_new_ins_asset_rec.fa_location_segment7,fnd_api.g_miss_char)
          THEN
            l_old_ins_asset_rec.fa_location_segment7 := NULL;
            l_new_ins_asset_rec.fa_location_segment7 := NULL;
          END IF;
          --
          IF NVL(l_old_ins_asset_rec.date_placed_in_service,fnd_api.g_miss_date) = NVL(l_new_ins_asset_rec.date_placed_in_service,fnd_api.g_miss_date)
          THEN
            l_old_ins_asset_rec.date_placed_in_service := NULL;
            l_new_ins_asset_rec.date_placed_in_service := NULL;
          END IF;
          --
          IF NVL(l_old_ins_asset_rec.description,fnd_api.g_miss_char) = NVL(l_new_ins_asset_rec.description,fnd_api.g_miss_char)
          THEN
            l_old_ins_asset_rec.description := NULL;
            l_new_ins_asset_rec.description := NULL;
          END IF;
          --
          IF NVL(l_old_ins_asset_rec.employee_name,fnd_api.g_miss_char) = NVL(l_new_ins_asset_rec.employee_name,fnd_api.g_miss_char)
          THEN
            l_old_ins_asset_rec.employee_name := NULL;
            l_new_ins_asset_rec.employee_name := NULL;
          END IF;
          --
          IF NVL(l_old_ins_asset_rec.expense_account_number,fnd_api.g_miss_char) = NVL(l_new_ins_asset_rec.expense_account_number,fnd_api.g_miss_char)
          THEN
            l_old_ins_asset_rec.expense_account_number := NULL;
            l_new_ins_asset_rec.expense_account_number := NULL;
          END IF;
          --
          l_ins_asset_rec.instance_asset_id           := l_asset_hist_csr.instance_asset_id;
          l_ins_asset_rec.old_instance_id             := l_old_ins_asset_rec.instance_id ;
          l_ins_asset_rec.new_instance_id             := l_new_ins_asset_rec.instance_id ;
          l_ins_asset_rec.old_fa_asset_id             := l_old_ins_asset_rec.fa_asset_id ;
          l_ins_asset_rec.new_fa_asset_id             := l_new_ins_asset_rec.fa_asset_id ;
          l_ins_asset_rec.old_fa_book_type_code       := l_old_ins_asset_rec.fa_book_type_code ;
          l_ins_asset_rec.new_fa_book_type_code       := l_new_ins_asset_rec.fa_book_type_code ;
          l_ins_asset_rec.old_fa_location_id          := l_old_ins_asset_rec.fa_location_id ;
          l_ins_asset_rec.new_fa_location_id          := l_new_ins_asset_rec.fa_location_id ;
          l_ins_asset_rec.old_asset_quantity          := l_old_ins_asset_rec.asset_quantity ;
          l_ins_asset_rec.new_asset_quantity          := l_new_ins_asset_rec.asset_quantity ;
          l_ins_asset_rec.old_update_status           := l_old_ins_asset_rec.update_status ;
          l_ins_asset_rec.new_update_status           := l_new_ins_asset_rec.update_status ;
          l_ins_asset_rec.old_active_start_date       := l_old_ins_asset_rec.active_start_date ;
          l_ins_asset_rec.new_active_start_date       := l_new_ins_asset_rec.active_start_date ;
          l_ins_asset_rec.old_active_end_date         := l_old_ins_asset_rec.active_end_date ;
          l_ins_asset_rec.new_active_end_date         := l_new_ins_asset_rec.active_end_date ;
          l_ins_asset_rec.old_asset_number            := l_old_ins_asset_rec.asset_number ;
          l_ins_asset_rec.new_asset_number            := l_new_ins_asset_rec.asset_number ;
          l_ins_asset_rec.old_serial_number           := l_old_ins_asset_rec.serial_number ;
          l_ins_asset_rec.new_serial_number           := l_new_ins_asset_rec.serial_number ;
          l_ins_asset_rec.old_tag_number              := l_old_ins_asset_rec.tag_number ;
          l_ins_asset_rec.new_tag_number              := l_new_ins_asset_rec.tag_number ;
          l_ins_asset_rec.old_category                := l_old_ins_asset_rec.category ;
          l_ins_asset_rec.new_category                := l_new_ins_asset_rec.category ;
          l_ins_asset_rec.old_fa_location_segment1    := l_old_ins_asset_rec.fa_location_segment1 ;
          l_ins_asset_rec.new_fa_location_segment1    := l_new_ins_asset_rec.fa_location_segment1 ;
          l_ins_asset_rec.old_fa_location_segment2    := l_old_ins_asset_rec.fa_location_segment2 ;
          l_ins_asset_rec.new_fa_location_segment2    := l_new_ins_asset_rec.fa_location_segment2 ;
          l_ins_asset_rec.old_fa_location_segment3    := l_old_ins_asset_rec.fa_location_segment3 ;
          l_ins_asset_rec.new_fa_location_segment3    := l_new_ins_asset_rec.fa_location_segment3 ;
          l_ins_asset_rec.old_fa_location_segment4    := l_old_ins_asset_rec.fa_location_segment4 ;
          l_ins_asset_rec.new_fa_location_segment4    := l_new_ins_asset_rec.fa_location_segment4 ;
          l_ins_asset_rec.old_fa_location_segment5    := l_old_ins_asset_rec.fa_location_segment5 ;
          l_ins_asset_rec.new_fa_location_segment5    := l_new_ins_asset_rec.fa_location_segment5 ;
          l_ins_asset_rec.old_fa_location_segment6    := l_old_ins_asset_rec.fa_location_segment6 ;
          l_ins_asset_rec.new_fa_location_segment6    := l_new_ins_asset_rec.fa_location_segment6 ;
          l_ins_asset_rec.old_fa_location_segment7    := l_old_ins_asset_rec.fa_location_segment7 ;
          l_ins_asset_rec.new_fa_location_segment7    := l_new_ins_asset_rec.fa_location_segment7 ;
          l_ins_asset_rec.old_date_placed_in_service  := l_old_ins_asset_rec.date_placed_in_service ;
          l_ins_asset_rec.new_date_placed_in_service  := l_new_ins_asset_rec.date_placed_in_service ;
          l_ins_asset_rec.old_description             := l_old_ins_asset_rec.description ;
          l_ins_asset_rec.new_description             := l_new_ins_asset_rec.description ;
          l_ins_asset_rec.old_employee_name           := l_old_ins_asset_rec.employee_name ;
          l_ins_asset_rec.new_employee_name           := l_new_ins_asset_rec.employee_name ;
          l_ins_asset_rec.old_expense_account_number  := l_old_ins_asset_rec.expense_account_number ;
          l_ins_asset_rec.new_expense_account_number  := l_new_ins_asset_rec.expense_account_number ;
          l_ins_asset_rec.old_fa_mass_addition_id     := l_old_ins_asset_rec.fa_mass_addition_id;
          l_ins_asset_rec.new_fa_mass_addition_id     := l_new_ins_asset_rec.fa_mass_addition_id;

         -- x_ins_asset_hist_rec := l_ins_asset_rec ;
          i:=i+1;
          x_ins_asset_hist_tbl(i)    := l_ins_asset_rec ;
          x_ins_asset_hist_tbl(i).instance_id := l_asset_hist_csr.instance_id;
END LOOP;

--
        -- End of API body

        -- Standard check of p_commit.
        /*
        IF FND_API.To_Boolean( p_commit ) THEN
                COMMIT WORK;
        END IF;
        */

    /***** srramakr commented for bug # 3304439
    -- Check for the profile option and disable the trace
        IF (fnd_profile.value('CSI_ENABLE_SQL_TRACE') = 'Y') THEN
                   dbms_session.set_sql_trace(false);
        END IF;
        -- End disable trace
    ****/

        -- Standard call to get message count and if count is  get message info.
        FND_MSG_PUB.Count_And_Get
                (p_count        =>      x_msg_count ,
             p_data     =>      x_msg_data      );
EXCEPTION
        WHEN OTHERS THEN
                X_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                /*
                IF fnd_api.to_boolean(p_commit)
                THEN
                ROLLBACK TO get_instance_asset_hist;
                END IF;
                */
                IF FND_MSG_PUB.Check_Msg_Level
                     (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                   FND_MSG_PUB.Add_Exc_Msg
                    ( G_PKG_NAME, l_api_name );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (       p_count         =>      x_msg_count,
                        p_data      =>      x_msg_data);

END get_instance_asset_hist ;

PROCEDURE asset_syncup_validation
     (     px_instance_sync_tbl       IN OUT NOCOPY CSI_ASSET_PVT.instance_sync_tbl,
           px_instance_asset_sync_tbl IN OUT NOCOPY CSI_ASSET_PVT.instance_asset_sync_tbl,
           px_fa_asset_sync_tbl       IN OUT NOCOPY CSI_ASSET_PVT.fa_asset_sync_tbl,
           x_error_msg                OUT NOCOPY VARCHAR2,
           x_return_status            OUT NOCOPY VARCHAR2
      ) IS
    l_fa_asset_sync_tbl          csi_asset_pvt.fa_asset_sync_tbl;
    l_Sync_Flag                  VARCHAR2(1) := FND_API.G_TRUE;
    l_location_id                NUMBER := 0;
    l_fa_location_id             NUMBER := 0;

    CURSOR csi_a_location_cur( l_inst_location_id NUMBER) IS
    SELECT fa_location_id
    FROM   csi_a_locations
    WHERE  location_id = l_inst_location_id;

BEGIN
     x_return_status := FND_API.G_RET_STS_SUCCESS ;
     IF px_instance_sync_tbl.count = 0 OR px_instance_asset_sync_tbl.count = 0 OR
        px_fa_asset_sync_tbl.count = 0 THEN
        x_error_msg     := 'Invalid Parameters';
        RAISE fnd_api.g_exc_error;
     END IF;
     /*-- Cursor on instance-asset pl/sql table --*/

   IF px_instance_asset_sync_tbl.count > 0 THEN
     FOR c_inst_asset_rec IN px_instance_asset_sync_tbl.FIRST..px_instance_asset_sync_tbl.LAST
     LOOP
        IF px_fa_asset_sync_tbl.count > 0 THEN
     /*-- Cursor on Fixed asset pl/sql table --*/

           FOR c_fa_asset_rec IN px_fa_asset_sync_tbl.FIRST..px_fa_asset_sync_tbl.LAST
           LOOP
               /*-- Searching for matching Fixed asset and location --*/
               IF px_fa_asset_sync_tbl(c_fa_asset_rec).fa_asset_id =
                  px_instance_asset_sync_tbl(c_inst_asset_rec).fa_asset_id AND
                  px_fa_asset_sync_tbl(c_fa_asset_rec).fa_location_id =
                  px_instance_asset_sync_tbl(c_inst_asset_rec).fa_location_id THEN
               /*-- Accumulating matching asset quantity in sync up qty --*/
                  IF px_fa_asset_sync_tbl(c_fa_asset_rec).sync_up_quantity = FND_API.G_MISS_NUM THEN
                     px_fa_asset_sync_tbl(c_fa_asset_rec).sync_up_quantity :=
                     nvl(px_instance_asset_sync_tbl(c_inst_asset_rec).inst_asset_quantity,0);
                  ELSE
                     px_fa_asset_sync_tbl(c_fa_asset_rec).sync_up_quantity :=
                     nvl( px_fa_asset_sync_tbl(c_fa_asset_rec).sync_up_quantity,0)
                    +nvl(px_instance_asset_sync_tbl(c_inst_asset_rec).inst_asset_quantity,0);
                  END IF;
               /*-- Validating Accumulated sync qty should not be more than Fa asset qty --*/
                  IF px_fa_asset_sync_tbl(c_fa_asset_rec).sync_up_quantity >
                     px_fa_asset_sync_tbl(c_fa_asset_rec).fa_asset_quantity THEN
                     l_Sync_Flag := FND_API.G_FALSE;
                  END IF;
               END IF;
          END LOOP;
         END IF;
         IF px_instance_sync_tbl.count > 0  THEN
         /*-- Cursor on Item Instance pl/sql table --*/
            FOR c_inst_rec IN px_instance_sync_tbl.FIRST .. px_instance_sync_tbl.LAST
            LOOP
               /*-- Searching for matching Item Instances or Interface id's --*/
            IF (px_instance_sync_tbl(c_inst_rec).instance_id =
                px_instance_asset_sync_tbl(c_inst_asset_rec).instance_id ) OR
               (px_instance_sync_tbl(c_inst_rec).inst_interface_id =
                px_instance_asset_sync_tbl(c_inst_asset_rec).inst_interface_id ) THEN
               /*-- Accumulating matching instance quantity in sync up qty --*/
              IF px_instance_sync_tbl(c_inst_rec).sync_up_quantity = FND_API.G_MISS_NUM THEN
                px_instance_sync_tbl(c_inst_rec).sync_up_quantity :=
                px_instance_asset_sync_tbl(c_inst_asset_rec).inst_asset_quantity;
              ELSE
                px_instance_sync_tbl(c_inst_rec).sync_up_quantity :=
                px_instance_sync_tbl(c_inst_rec).sync_up_quantity
               +px_instance_asset_sync_tbl(c_inst_asset_rec).inst_asset_quantity;
              END IF;

               /*-- Getting instance location setup with Asset location --*/
              IF l_location_id <> px_instance_sync_tbl( c_inst_rec ).location_id THEN
                 l_location_id    := px_instance_sync_tbl( c_inst_rec ).location_id;
                 l_fa_location_id := NULL;

                 OPEN  csi_a_location_cur( l_location_id );
                 FETCH csi_a_location_cur INTO l_fa_location_id ;
                 CLOSE csi_a_location_cur;
              END IF;

               /*-- Validating Accumulated sync qty should not be more than Instance qty --*/
               /*-- Also Validating instance location setup with Asset location --*/
              IF (px_instance_sync_tbl(c_inst_rec).sync_up_quantity >
                  px_instance_sync_tbl(c_inst_rec).instance_quantity ) OR
                 (px_instance_asset_sync_tbl(c_inst_asset_rec).fa_location_id
                  <> NVL(l_fa_location_id,0) ) THEN
                 l_Sync_Flag := FND_API.G_FALSE;
              END IF;
            END IF;
          END LOOP;
        END IF;
      END LOOP;
   END IF;
     /*-- Cursor on Fixed asset pl/sql table --*/

/*      FOR c_fa_asset_rec IN px_fa_asset_sync_tbl.FIRST..px_fa_asset_sync_tbl.LAST
      LOOP
*/        /*-- Validating all Fa asset qty is matched/sync --*/
/*        IF px_fa_asset_sync_tbl(c_fa_asset_rec).sync_up_quantity <>
           px_fa_asset_sync_tbl(c_fa_asset_rec).fa_asset_quantity THEN
           l_Sync_Flag := FND_API.G_FALSE;
        END IF;
      END LOOP;
*/
     /*-- Cursor on Item Instance pl/sql table --*/
     FOR c_inst_rec IN px_instance_sync_tbl.FIRST .. px_instance_sync_tbl.LAST
     LOOP
       /*-- Validating All Instance qty is matched/sync --*/
       IF px_instance_sync_tbl(c_inst_rec).sync_up_quantity <>
          px_instance_sync_tbl(c_inst_rec).instance_quantity THEN
          l_Sync_Flag := FND_API.G_FALSE;
       END IF;
     END LOOP;
     /*-- Cursor on Item Instance pl/sql table --*/
     FOR c_inst_rec IN px_instance_sync_tbl.FIRST .. px_instance_sync_tbl.LAST
     LOOP
     /*-- If All Assets/Item Instances are in sync then set vld flag as S else E --*/
      IF l_Sync_Flag = FND_API.G_FALSE THEN
         px_instance_sync_tbl(c_inst_rec).vld_status := 'E';
      ELSE
         px_instance_sync_tbl(c_inst_rec).vld_status := 'S';
      END IF;
     END LOOP;
 EXCEPTION
  WHEN fnd_api.g_exc_error THEN
       x_return_status := FND_API.G_RET_STS_ERROR ;
 END asset_syncup_validation;

 PROCEDURE get_attached_item_instances
     (     p_api_version                IN  NUMBER,
           p_init_msg_list              IN  VARCHAR2,
           p_instance_asset_sync_tbl    IN  CSI_ASSET_PVT.instance_asset_sync_tbl,
           x_instance_sync_tbl          OUT NOCOPY CSI_ASSET_PVT.instance_sync_tbl,
           x_return_status              OUT NOCOPY    VARCHAR2,
           x_msg_count                  OUT NOCOPY    NUMBER,
           x_msg_data                   OUT NOCOPY    VARCHAR2,
           p_source_system_name         IN  VARCHAR2 DEFAULT NULL,
           p_called_from_grp            IN  VARCHAR2 DEFAULT fnd_api.g_false
     ) IS
      TYPE num_tbl  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
      TYPE char_tbl IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
      l_instance_tbl            num_tbl;
      l_interface_tbl           num_tbl;
      l_instance_qty_tbl        num_tbl;
      l_location_id_tbl         num_tbl;
      l_location_type_code_tbl  char_tbl;

      l_api_name        CONSTANT VARCHAR2(30)   := 'GET_ATTACHED_ITEM_INSTANCES';
      l_api_version     CONSTANT NUMBER         := 1.0                    ;
      l_csi_debug_level          NUMBER                                   ;
      l_msg_index                NUMBER                                   ;
      l_msg_count                NUMBER                                   ;
      l_sql_stmt                 VARCHAR2(32767)                          ;
      l_inst_cnt                 NUMBER;
      l_dup_flag                 BOOLEAN;

    CURSOR c_item_instances ( p_fa_asset_id NUMBER, p_fa_location_id NUMBER) IS
      SELECT a.instance_id,null inst_interface_id, a.quantity, a.location_id ,a.location_type_code
      FROM   csi_item_instances a, csi_i_assets b
      WHERE a.instance_id  = b.instance_id
      AND b.fa_asset_id    = p_fa_asset_id
      AND b.fa_location_id = p_fa_location_id ;

   CURSOR c_interf_instance ( p_fa_asset_id NUMBER,
                              p_fa_location_id NUMBER,
                              p_source_system_name VARCHAR2 ) IS
      SELECT a.instance_id,a.inst_interface_id,a.quantity, a.location_id ,a.location_type_code
      FROM csi_instance_interface a ,csi_i_asset_interface b
      WHERE a.inst_interface_id=b.inst_interface_id
      AND b.fa_asset_id        = p_fa_asset_id
      AND b.fa_location_id     = p_fa_location_id
      AND a.process_status IN ('R','X')
      AND a.source_system_name = nvl(p_source_system_name ,a.source_system_name)
      UNION ALL
      SELECT a.instance_id,null inst_interface_id, a.quantity, a.location_id ,a.location_type_code
      FROM   csi_item_instances a, csi_i_assets b
      WHERE a.instance_id  = b.instance_id
      AND b.fa_asset_id    = p_fa_asset_id
      AND b.fa_location_id = p_fa_location_id
      AND NOT EXISTS ( SELECT 1 FROM csi_instance_interface c
                       WHERE c.instance_id   = a.instance_id
                       AND   c.process_status IN ('R','X')
                       AND   c.source_system_name = nvl(p_source_system_name ,c.source_system_name)) ;

 BEGIN
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (l_api_version       ,
                                          p_api_version       ,
                                          l_api_name          ,
                                          G_PKG_NAME          )
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
    -- If csi_debug_level = 1 then dump the procedure name
      IF (l_csi_debug_level > 0) THEN
          debug( 'get_attached_item_instances');
      END IF;
    -- If the debug level = 2 then dump all the parameters values.
      IF (l_csi_debug_level > 1) THEN
            debug( 'get_attached_item_instances:'||
                                          p_api_version           ||'-'||
                                          p_init_msg_list               );
      END IF;
     -- Validate asset pl/sql table of records is not null
      IF p_instance_asset_sync_tbl.count = 0 THEN
        IF (l_csi_debug_level > 0) THEN
            debug( 'Asset table of records not provided as input parameter');
            RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;

      FOR inst_asst_rec IN p_instance_asset_sync_tbl.FIRST..p_instance_asset_sync_tbl.LAST
      LOOP
        IF p_instance_asset_sync_tbl.exists( inst_asst_rec ) THEN

        IF p_called_from_grp = fnd_api.g_true THEN

          OPEN c_interf_instance(
                p_instance_asset_sync_tbl(inst_asst_rec).fa_asset_id ,  -- :1
                p_instance_asset_sync_tbl(inst_asst_rec).fa_location_id,-- :2
                p_source_system_name );

          FETCH c_interf_instance BULK COLLECT INTO
          l_instance_tbl,l_interface_tbl,l_instance_qty_tbl, l_location_id_tbl, l_location_type_code_tbl;
          CLOSE c_interf_instance;
        ELSE

          OPEN c_item_instances
          (     p_instance_asset_sync_tbl(inst_asst_rec).fa_asset_id ,
                p_instance_asset_sync_tbl(inst_asst_rec).fa_location_id
          );
          FETCH c_item_instances BULK COLLECT INTO
                l_instance_tbl,l_interface_tbl,l_instance_qty_tbl ,l_location_id_tbl,l_location_type_code_tbl;
          CLOSE c_item_instances;
        END IF;


        l_inst_cnt := x_instance_sync_tbl.count;
        IF l_instance_tbl.count > 0 THEN
           FOR c_op IN 1..l_instance_tbl.COUNT
           LOOP
             IF l_instance_tbl.exists( c_op ) THEN
             l_dup_flag := FALSE;
             FOR c_dup IN 1..x_instance_sync_tbl.count
             LOOP
               IF x_instance_sync_tbl.exists( c_dup ) THEN
               IF x_instance_sync_tbl( c_dup).instance_id = l_instance_tbl(c_op) OR
                  x_instance_sync_tbl( c_dup).inst_interface_id = l_interface_tbl(c_op)
               THEN
                  l_dup_flag := TRUE ;

               END IF;
               END IF;
             END LOOP;
             IF l_dup_flag = FALSE THEN

                l_inst_cnt := l_inst_cnt +1 ;
                x_instance_sync_tbl( l_inst_cnt ).instance_id       := l_instance_tbl(c_op);
                x_instance_sync_tbl( l_inst_cnt ).inst_interface_id := l_interface_tbl(c_op);
                x_instance_sync_tbl( l_inst_cnt ).instance_quantity := l_instance_qty_tbl(c_op);
                x_instance_sync_tbl( l_inst_cnt ).location_id       := l_location_id_tbl(c_op);
                x_instance_sync_tbl( l_inst_cnt ).location_type_code:= l_location_type_code_tbl(c_op);
             END IF;
            END IF;
           END LOOP;
         END IF;

        END IF;
      END LOOP;

 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count     =>      x_msg_count,
                        p_data          =>      x_msg_data      );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count         =>      x_msg_count,
                        p_data          =>      x_msg_data      );
        WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       G_PKG_NAME          ,
                        l_api_name      );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (       p_count         =>      x_msg_count,
                        p_data          =>      x_msg_data      );
 END get_attached_item_instances;


 PROCEDURE get_attached_asset_links
     (     p_api_version              IN  NUMBER,
           p_init_msg_list            IN  VARCHAR2,
           p_instance_sync_tbl        IN  CSI_ASSET_PVT.instance_sync_tbl,
           x_instance_asset_sync_tbl  OUT NOCOPY CSI_ASSET_PVT.instance_asset_sync_tbl,
           x_return_status            OUT NOCOPY    VARCHAR2,
           x_msg_count                OUT NOCOPY    NUMBER,
           x_msg_data                 OUT NOCOPY    VARCHAR2,
           p_source_system_name       IN  VARCHAR2 DEFAULT NULL,
           p_called_from_grp          IN  VARCHAR2 DEFAULT fnd_api.g_false
     ) IS
      TYPE num_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
      l_fa_asset_id_tbl       num_tbl;
      l_fa_asset_loc_id_tbl   num_tbl;
      l_asset_qty_tbl         num_tbl;
      l_api_name        CONSTANT VARCHAR2(30)   := 'GET_ATTACHED_ASSET_LINKS';
      l_api_version     CONSTANT NUMBER         := 1.0                    ;
      l_csi_debug_level          NUMBER                                   ;
      l_msg_index                NUMBER                                   ;
      l_msg_count                NUMBER                                   ;
      l_sql_stmt                 VARCHAR2(32767)                          ;
      l_asset_cnt                NUMBER;
    CURSOR c_instance_assets( p_instance_id NUMBER ) IS
      SELECT b.fa_asset_id,b.fa_location_id, b.asset_quantity
      FROM   csi_item_instances a, csi_i_assets b
      WHERE a.instance_id  = b.instance_id
      AND   a.instance_id  = p_instance_id ;

    CURSOR c_interface_assets( p_instance_id          NUMBER
                              ,p_interface_id         NUMBER
                              ,p_source_system_name   VARCHAR2
                               ) IS
      SELECT b.fa_asset_id,b.fa_location_id,b.asset_quantity
      FROM csi_instance_interface a ,csi_i_asset_interface b
      WHERE a.inst_interface_id = b.inst_interface_id
      AND a.process_status IN ('R','X')
      AND (a.instance_id        = p_instance_id
        OR a.inst_interface_id  = p_interface_id )
      AND a.source_system_name  = nvl(p_source_system_name,a.source_system_name)
      UNION ALL
      SELECT b.fa_asset_id,b.fa_location_id, b.asset_quantity
      FROM   csi_item_instances a, csi_i_assets b
      WHERE a.instance_id = b.instance_id
      AND   a.instance_id = p_instance_id
      AND NOT EXISTS ( SELECT 1
                       FROM csi_i_asset_interface c,
                            csi_instance_interface d
                       WHERE d.instance_id      = a.instance_id
                       AND c.inst_interface_id  = d.inst_interface_id
                       AND d.source_system_name = nvl(p_source_system_name,d.source_system_name)
                       AND c.fa_asset_id        = b.fa_asset_id
                       AND d.process_status     IN ('R','X')
                       AND c.fa_location_id     = b.fa_location_id );

 BEGIN
        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (l_api_version       ,
                                            p_api_version       ,
                                            l_api_name          ,
                                            G_PKG_NAME          )
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
    -- If csi_debug_level = 1 then dump the procedure name
    IF (l_csi_debug_level > 0) THEN
            debug( 'get_attached_asset_links');
    END IF;
    -- If the debug level = 2 then dump all the parameters values.
    IF (l_csi_debug_level > 1) THEN
            debug( 'get_attached_asset_links:'||
                                          p_api_version           ||'-'||
                                          p_init_msg_list               );
    END IF;
     -- Validate asset pl/sql table of records is not null
      IF p_instance_sync_tbl.count = 0 THEN
        IF (l_csi_debug_level > 0) THEN
            debug( 'Item instance not provided as input parameter');
            RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
      FOR inst_rec IN p_instance_sync_tbl.FIRST..p_instance_sync_tbl.LAST
      LOOP
        IF p_instance_sync_tbl.exists( inst_rec ) THEN
        l_fa_asset_id_tbl.delete;
        l_fa_asset_loc_id_tbl.delete;
        l_asset_qty_tbl.delete;

        IF p_called_from_grp = fnd_api.g_true THEN
           OPEN c_interface_assets( p_instance_sync_tbl(inst_rec).instance_id ,
                               p_instance_sync_tbl(inst_rec).inst_interface_id,
                               p_source_system_name);
            FETCH c_interface_assets BULK COLLECT INTO
            l_fa_asset_id_tbl,l_fa_asset_loc_id_tbl,l_asset_qty_tbl;
            CLOSE c_interface_assets;
        ELSE
            OPEN c_instance_assets( p_instance_sync_tbl(inst_rec).instance_id );
            FETCH c_instance_assets BULK COLLECT INTO
                 l_fa_asset_id_tbl,l_fa_asset_loc_id_tbl,l_asset_qty_tbl;
            CLOSE c_instance_assets;
        END IF;
        l_asset_cnt := x_instance_asset_sync_tbl.count;
        IF l_fa_asset_id_tbl.COUNT > 0 THEN
           FOR c_op IN 1..l_fa_asset_id_tbl.COUNT
           LOOP
             IF l_fa_asset_id_tbl.exists(c_op) THEN
             l_asset_cnt := l_asset_cnt +1 ;
             x_instance_asset_sync_tbl( l_asset_cnt ).instance_id    := p_instance_sync_tbl(inst_rec).instance_id ;
             x_instance_asset_sync_tbl( l_asset_cnt ).inst_interface_id := p_instance_sync_tbl(inst_rec).inst_interface_id;
             x_instance_asset_sync_tbl( l_asset_cnt ).fa_asset_id    := l_fa_asset_id_tbl(c_op);
             x_instance_asset_sync_tbl( l_asset_cnt ).fa_location_id := l_fa_asset_loc_id_tbl(c_op);
             x_instance_asset_sync_tbl( l_asset_cnt ).inst_asset_quantity := l_asset_qty_tbl(c_op);
             END IF;
           END LOOP;
        END IF;
       END IF;
      END LOOP;
      debug(' After  get_attached_asset_links');
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count     =>      x_msg_count,
                        p_data          =>      x_msg_data      );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count         =>      x_msg_count,
                        p_data          =>      x_msg_data      );
        WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       G_PKG_NAME          ,
                        l_api_name      );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (       p_count         =>      x_msg_count,
                        p_data          =>      x_msg_data      );
END get_attached_asset_links;

PROCEDURE get_fa_asset_details
     (     p_api_version                IN  NUMBER,
           p_init_msg_list              IN  VARCHAR2,
           p_instance_asset_sync_tbl    IN  CSI_ASSET_PVT.instance_asset_sync_tbl,
           x_fa_asset_sync_tab          OUT NOCOPY CSI_ASSET_PVT.fa_asset_sync_tbl,
           x_return_status              OUT NOCOPY    VARCHAR2,
           x_msg_count                  OUT NOCOPY    NUMBER,
           x_msg_data                   OUT NOCOPY    VARCHAR2,
           p_source_system_name         IN  VARCHAR2 DEFAULT NULL,
           p_called_from_grp            IN  VARCHAR2 DEFAULT fnd_api.g_false
     ) IS
      TYPE num_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
      l_fa_asset_id_tbl       num_tbl;
      l_fa_asset_loc_id_tbl   num_tbl;
      l_fa_asset_qty_tbl      num_tbl;
      l_api_name        CONSTANT VARCHAR2(30)   := 'GET_FA_ASSET_DETAILS';
      l_api_version     CONSTANT NUMBER         := 1.0                    ;
      l_csi_debug_level          NUMBER                                   ;
      l_msg_index                NUMBER                                   ;
      l_msg_count                NUMBER                                   ;
      l_fa_asset_cnt             NUMBER  := 0;
      l_fetch                    BOOLEAN := TRUE;

      CURSOR c_fa_assets ( p_fa_asset_id NUMBER
                          ,p_location_id NUMBER )IS
      SELECT SUM(units_assigned)
      FROM   fa_distribution_history fadh
      WHERE  fadh.asset_id     = p_fa_asset_id
      AND    fadh.location_id  = p_location_id
      AND    units_assigned    > 0
      AND    fadh.date_ineffective IS NULL;
BEGIN
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (l_api_version       ,
                                          p_api_version       ,
                                          l_api_name          ,
                                          G_PKG_NAME          )
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
    -- If csi_debug_level = 1 then dump the procedure name
    IF (l_csi_debug_level > 0) THEN
            debug( 'get_fa_asset_details');
    END IF;
    -- If the debug level = 2 then dump all the parameters values.
    IF (l_csi_debug_level > 1) THEN
            debug( 'get_fa_asset_details:'||
                                          p_api_version           ||'-'||
                                          p_init_msg_list               );
    END IF;
    -- Validate asset pl/sql table of records is not null
    IF p_instance_asset_sync_tbl.count = 0 THEN
      IF (l_csi_debug_level > 0) THEN
          debug( 'Fixed Asset details not provided as input parameter');
          RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    FOR c_fa_asset IN p_instance_asset_sync_tbl.FIRST..p_instance_asset_sync_tbl.LAST
    LOOP
       l_fetch := TRUE;
       l_fa_asset_cnt := x_fa_asset_sync_tab.count;
       IF l_fa_asset_cnt > 0 THEN
         FOR c_out IN x_fa_asset_sync_tab.FIRST..x_fa_asset_sync_tab.LAST
         LOOP
           IF x_fa_asset_sync_tab(c_out).fa_asset_id =  p_instance_asset_sync_tbl(c_fa_asset).fa_asset_id
            AND x_fa_asset_sync_tab(c_out).fa_location_id =  p_instance_asset_sync_tbl(c_fa_asset).fa_location_id THEN
              l_fetch := FALSE;
           END IF;
         END LOOP;
       END IF;
       IF l_fetch = TRUE THEN
         l_fa_asset_cnt := l_fa_asset_cnt + 1 ;
         x_fa_asset_sync_tab(l_fa_asset_cnt).fa_asset_id    :=p_instance_asset_sync_tbl(c_fa_asset).fa_asset_id ;
         x_fa_asset_sync_tab(l_fa_asset_cnt).fa_location_id :=p_instance_asset_sync_tbl(c_fa_asset).fa_location_id ;

         OPEN c_fa_assets( p_instance_asset_sync_tbl(c_fa_asset).fa_asset_id
                         , p_instance_asset_sync_tbl(c_fa_asset).fa_location_id );
         FETCH c_fa_assets INTO x_fa_asset_sync_tab(l_fa_asset_cnt).fa_asset_quantity;
         CLOSE c_fa_assets;
       END IF;
    END LOOP;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count     =>      x_msg_count,
                        p_data          =>      x_msg_data      );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count         =>      x_msg_count,
                        p_data          =>      x_msg_data      );
        WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       G_PKG_NAME          ,
                        l_api_name      );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (       p_count         =>      x_msg_count,
                        p_data          =>      x_msg_data      );
 END get_fa_asset_details ;

 PROCEDURE Get_syncup_tree
     (     px_instance_sync_tbl          IN OUT NOCOPY CSI_ASSET_PVT.instance_sync_tbl,
           px_instance_asset_sync_tbl    IN OUT NOCOPY CSI_ASSET_PVT.instance_asset_sync_tbl,
           x_fa_asset_sync_tbl           IN OUT NOCOPY CSI_ASSET_PVT.fa_asset_sync_tbl,
           x_return_status               OUT NOCOPY    VARCHAR2,
           x_error_msg                   OUT NOCOPY    VARCHAR2,
           p_source_system_name          IN  VARCHAR2 DEFAULT NULL,
           p_called_from_grp             IN  VARCHAR2 DEFAULT fnd_api.g_false
     ) IS
       l_csi_debug_level           NUMBER := 0;
       l_instance_sync_tbl         CSI_ASSET_PVT.instance_sync_tbl;
       l_tmp_instance_sync_tbl     CSI_ASSET_PVT.instance_sync_tbl;
       l_instance_asset_sync_tbl   CSI_ASSET_PVT.instance_asset_sync_tbl;
       l_tmp_instance_asset_sync_tbl   CSI_ASSET_PVT.instance_asset_sync_tbl;
       l_fa_asset_sync_tbl         CSI_ASSET_PVT.fa_asset_sync_tbl;
       l_Search_Flag               VARCHAR2(1);
       l_return_status             VARCHAR2(1);
       l_msg_data                  VARCHAR2(500);
       l_msg_count                 NUMBER;
       l_init_msg_list             VARCHAR2(500);
       l_match_cnt                 BINARY_INTEGER := 0;
       l_tbl_cnt                   BINARY_INTEGER := 0;
       l_process_loop              BOOLEAN := TRUE;

 BEGIN
    -- Check the profile option CSI_DEBUG_LEVEL for debug message reporting
    l_csi_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');
    IF (l_csi_debug_level > 0) THEN
       debug( 'Get_syncup_tree');
    END IF;

    IF nvl(px_instance_sync_tbl.count,0) > 0 THEN
      l_tbl_cnt := px_instance_sync_tbl.count;
      l_instance_sync_tbl       := px_instance_sync_tbl ;
      l_Search_Flag             := 'I';
    ELSIF nvl(px_instance_asset_sync_tbl.count,0) >0 THEN
      l_tbl_cnt := px_instance_asset_sync_tbl.count;
      l_instance_asset_sync_tbl  := px_instance_asset_sync_tbl;
      l_Search_Flag             := 'A';
    ELSE
      IF (l_csi_debug_level > 0) THEN
         debug( 'Get_syncup_tree');
      END IF;
      FND_MESSAGE.Set_Name('CSI', 'CSI_API_INVALID_PARAMETERS');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    /*-- Loop untill all item instances or assets are explored --*/
    WHILE l_process_loop
    LOOP
      IF l_Search_Flag = 'I' THEN
         l_instance_asset_sync_tbl.DELETE;
        csi_asset_pvt.get_attached_asset_links
        (  p_api_version              => 1.0,
           p_init_msg_list            => l_init_msg_list,
           p_instance_sync_tbl        => l_instance_sync_tbl,
           x_instance_asset_sync_tbl  => l_instance_asset_sync_tbl,
           x_return_status            => l_return_status,
           x_msg_count                => l_msg_count,
           x_msg_data                 => l_msg_data,
           p_source_system_name       => p_source_system_name,
           p_called_from_grp          => p_called_from_grp
        );
        l_instance_sync_tbl.delete;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           debug( 'Get_attached_asset_links returned with error');
           RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF nvl(l_instance_asset_sync_tbl.count,0) > 0 THEN
           /*-- Verify revisited Nodes --*/
         IF px_instance_asset_sync_tbl.count > 0 THEN
           l_tmp_instance_asset_sync_tbl := l_instance_asset_sync_tbl;
--           l_instance_asset_sync_tbl.DELETE;

          FOR c_fin_asst IN px_instance_asset_sync_tbl.first .. px_instance_asset_sync_tbl.last
          LOOP
            IF px_instance_asset_sync_tbl.exists( c_fin_asst ) THEN

              l_tbl_cnt := l_tmp_instance_asset_sync_tbl.FIRST;

              LOOP
             /*-- look for instance/interface-id,asset n location match --*/
              IF ((l_tmp_instance_asset_sync_tbl(l_tbl_cnt).instance_id =
                   px_instance_asset_sync_tbl(c_fin_asst).instance_id) OR
                  (l_tmp_instance_asset_sync_tbl(l_tbl_cnt).inst_interface_id =
                   px_instance_asset_sync_tbl(c_fin_asst).inst_interface_id))
                                AND
                  l_tmp_instance_asset_sync_tbl(l_tbl_cnt).fa_asset_id =
                  px_instance_asset_sync_tbl(c_fin_asst).fa_asset_id
                                AND
                  l_tmp_instance_asset_sync_tbl(l_tbl_cnt).fa_location_id =
                  px_instance_asset_sync_tbl(c_fin_asst).fa_location_id THEN

                  l_tmp_instance_asset_sync_tbl.DELETE(l_tbl_cnt);

              END IF;
              EXIT WHEN l_tmp_instance_asset_sync_tbl.next(l_tbl_cnt ) IS NULL ;
               l_tbl_cnt := l_tmp_instance_asset_sync_tbl.next(l_tbl_cnt );
            END LOOP; -- c_asst
           END IF;
          END LOOP; -- c_fin_asst

	  l_tbl_cnt := 0;
          l_process_loop := FALSE;
          l_instance_asset_sync_tbl.DELETE;

          IF l_tmp_instance_asset_sync_tbl.count > 0 THEN
            FOR c_temp In l_tmp_instance_asset_sync_tbl.first..l_tmp_instance_asset_sync_tbl.last LOOP
             IF l_tmp_instance_asset_sync_tbl.exists( c_temp ) THEN
                l_tbl_cnt := l_tbl_cnt + 1;
                l_instance_asset_sync_tbl(l_tbl_cnt) := l_tmp_instance_asset_sync_tbl(c_temp);
                l_process_loop := TRUE;
             END IF;
            END LOOP;
           END IF;
	   l_tmp_instance_asset_sync_tbl.DELETE;
          END IF;
          IF nvl(l_instance_asset_sync_tbl.count,0) > 0 THEN
             l_match_cnt := px_instance_asset_sync_tbl.count;
             FOR c_asst IN 1..l_instance_asset_sync_tbl.count
             LOOP
               IF l_instance_asset_sync_tbl.exists( c_asst ) THEN
                  l_match_cnt := l_match_cnt + 1;
                  px_instance_asset_sync_tbl( l_match_cnt ).instance_id
                  :=l_instance_asset_sync_tbl( c_asst ).instance_id;
                  px_instance_asset_sync_tbl( l_match_cnt ).inst_interface_id
                  :=l_instance_asset_sync_tbl( c_asst ).inst_interface_id;
                  px_instance_asset_sync_tbl( l_match_cnt ).fa_asset_id
                  :=l_instance_asset_sync_tbl( c_asst ).fa_asset_id;
                  px_instance_asset_sync_tbl( l_match_cnt ).fa_location_id
                  :=l_instance_asset_sync_tbl( c_asst ).fa_location_id;
                  px_instance_asset_sync_tbl( l_match_cnt ).inst_asset_quantity
                 :=l_instance_asset_sync_tbl( c_asst ).inst_asset_quantity;
               END IF;
             END LOOP;
             l_Search_Flag := 'A';-- Setting Flag to find instances based on asset
             l_match_cnt   := 0;
             l_tbl_cnt     := 0;
          END IF;
        END IF;

      ELSIF l_Search_Flag = 'A' THEN
        l_instance_sync_tbl.DELETE;
        csi_asset_pvt.get_attached_item_instances
        (  p_api_version              => 1.0,
           p_init_msg_list            => l_init_msg_list,
           p_instance_asset_sync_tbl  => l_instance_asset_sync_tbl,
           x_instance_sync_tbl        => l_instance_sync_tbl,
           x_return_status            => l_return_status,
           x_msg_count                => l_msg_count,
           x_msg_data                 => l_msg_data,
           p_source_system_name       => p_source_system_name,
           p_called_from_grp          => p_called_from_grp
        );
        l_instance_asset_sync_tbl.delete;
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           debug( 'Get_attached_item_instances returned with error');
           RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF nvl(l_instance_sync_tbl.count,0) > 0 THEN
           /*-- Verify revisited Nodes --*/
           l_tmp_instance_sync_tbl := l_instance_sync_tbl;
           l_instance_sync_tbl.DELETE;

         IF px_instance_sync_tbl.count > 0 THEN
          FOR c_fin_inst IN px_instance_sync_tbl.first..px_instance_sync_tbl.last
          LOOP
            IF px_instance_sync_tbl.exists( c_fin_inst ) THEN
            l_tbl_cnt := l_tmp_instance_sync_tbl.FIRST;
            LOOP
             /*-- look for instance match --*/
              IF (l_tmp_instance_sync_tbl( l_tbl_cnt ).instance_id =
                   px_instance_sync_tbl( c_fin_inst ).instance_id) OR
                  (l_tmp_instance_sync_tbl( l_tbl_cnt ).inst_interface_id =
                   px_instance_sync_tbl(c_fin_inst ).inst_interface_id)THEN

                l_tmp_instance_sync_tbl.DELETE( l_tbl_cnt );
              END IF;
              EXIT WHEN l_tmp_instance_sync_tbl.next(l_tbl_cnt) IS NULL ;
               l_tbl_cnt := l_tmp_instance_sync_tbl.next(l_tbl_cnt);
            END LOOP; -- c_inst
           END IF;
          END LOOP; -- c_fin_inst

	  l_tbl_cnt := 0;
          l_instance_sync_tbl.delete;
          l_process_loop := FALSE;
	  IF l_tmp_instance_sync_tbl.count > 0 THEN
             FOR c_temp in l_tmp_instance_sync_tbl.FIRST..l_tmp_instance_sync_tbl.LAST LOOP
               IF l_tmp_instance_sync_tbl.exists(c_temp) THEN
                  l_tbl_cnt := l_tbl_cnt +1 ;
                  l_instance_sync_tbl(l_tbl_cnt) := l_tmp_instance_sync_tbl(c_temp);
                  l_process_loop := TRUE;
               END IF;
             END LOOP;
          END IF;
          l_tmp_instance_sync_tbl.delete;

          END IF;

          IF nvl(l_instance_sync_tbl.count,0) > 0 THEN
             l_match_cnt := nvl(px_instance_sync_tbl.count ,0);
             FOR c_inst IN l_instance_sync_tbl.first..l_instance_sync_tbl.last
             LOOP
                IF l_instance_sync_tbl.exists( c_inst ) THEN

                   l_match_cnt := l_match_cnt + 1;
                   px_instance_sync_tbl( l_match_cnt ).instance_id
                   :=l_instance_sync_tbl( c_inst ).instance_id;
                   px_instance_sync_tbl( l_match_cnt ).inst_interface_id
                   :=l_instance_sync_tbl( c_inst ).inst_interface_id;
                   px_instance_sync_tbl( l_match_cnt ).instance_quantity
                   :=l_instance_sync_tbl( c_inst ).instance_quantity;
                   px_instance_sync_tbl( l_match_cnt ).location_id
                   :=l_instance_sync_tbl( c_inst ).location_id;
                   px_instance_sync_tbl( l_match_cnt ).location_type_code
                   :=l_instance_sync_tbl( c_inst ).location_type_code;

                END IF;
             END LOOP;
             l_Search_Flag := 'I';-- Setting Flag to find assets based on instanace
          END IF;
        END IF;
      ELSE  -- l_Search_Flag <> 'A' OR 'I' THEN
       EXIT;
      END IF;
    END LOOP;
    get_fa_asset_details
    (
           p_api_version                => 1.0,
           p_init_msg_list              => l_init_msg_list,
           p_instance_asset_sync_tbl    => px_instance_asset_sync_tbl,
           x_fa_asset_sync_tab          => x_fa_asset_sync_tbl,
           x_return_status              => l_return_status,
           x_msg_count                  => l_msg_count,
           x_msg_data                   => l_msg_data,
           p_source_system_name         => p_source_system_name,
           p_called_from_grp            => p_called_from_grp);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           debug( 'Get_fa_asset_details returned with error');
           RAISE FND_API.G_EXC_ERROR;
        END IF;

 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR ;
 END Get_syncup_tree ;

  PROCEDURE create_instance_assets (
    p_api_version         IN     number,
    p_commit              IN     varchar2,
    p_init_msg_list       IN     varchar2,
    p_validation_level    IN     number,
    p_instance_asset_tbl  IN OUT nocopy csi_datastructures_pub.instance_asset_tbl,
    p_txn_rec             IN OUT nocopy csi_datastructures_pub.transaction_rec,
    p_lookup_tbl          IN OUT nocopy csi_asset_pvt.lookup_tbl,
    p_asset_count_rec     IN OUT nocopy csi_asset_pvt.asset_count_rec,
    p_asset_id_tbl        IN OUT nocopy csi_asset_pvt.asset_id_tbl,
    p_asset_loc_tbl       IN OUT nocopy csi_asset_pvt.asset_loc_tbl,
    x_return_status          OUT nocopy varchar2,
    x_msg_count              OUT nocopy number,
    x_msg_data               OUT nocopy varchar2)
  IS
    l_api_name            varchar2(30) := 'create_instance_assets';
    l_return_status       varchar2(1)  := fnd_api.g_ret_sts_success;
    l_msg_count           number;
    l_msg_data            varchar2(2000);
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    SAVEPOINT create_instance_assets;

    IF p_instance_asset_tbl.COUNT > 0 THEN

      FOR ia_ind IN p_instance_asset_tbl.FIRST .. p_instance_asset_tbl.LAST
      LOOP

        create_instance_asset(
          p_api_version         => 1.0,
          p_commit              => fnd_api.g_false,
          p_init_msg_list       => fnd_api.g_true,
          p_validation_level    => fnd_api.g_valid_level_full,
          p_instance_asset_rec  => p_instance_asset_tbl(ia_ind),
          p_txn_rec             => p_txn_rec,
          p_lookup_tbl          => p_lookup_tbl,
          p_asset_count_rec     => p_asset_count_rec,
          p_asset_id_tbl        => p_asset_id_tbl,
          p_asset_loc_tbl       => p_asset_loc_tbl,
          x_return_status       => l_return_status,
          x_msg_count           => l_msg_count,
          x_msg_data            => l_msg_data);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

      END LOOP;

    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_instance_assets;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data );
    WHEN others THEN
      ROLLBACK TO create_instance_assets;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      fnd_msg_pub.add_exc_msg(g_pkg_name , l_api_name);
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data );
  END create_instance_assets;

END csi_asset_pvt;


/
