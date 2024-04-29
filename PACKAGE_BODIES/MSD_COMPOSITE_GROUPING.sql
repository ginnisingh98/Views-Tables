--------------------------------------------------------
--  DDL for Package Body MSD_COMPOSITE_GROUPING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_COMPOSITE_GROUPING" AS -- body
/* $Header: MSDCMGRB.pls 120.1 2006/01/19 23:12:42 sjagathe noship $ */

TYPE stream_rec_type IS RECORD
 ( p_stream_id                   NUMBER,
   l_stream_count                NUMBER,
   l_distinct_distributions      NUMBER,
   l_base_stream_id              NUMBER,
   l_group                       NUMBER,
   l_reading_level_string        VARCHAR2(300),
   l_dimension_clause            VARCHAR2(300),
   l_groupable                   NUMBER );

TYPE stream_tbl_type IS TABLE OF stream_rec_type
                           INDEX BY BINARY_INTEGER;

TYPE CharTblTyp IS TABLE OF VARCHAR2(255);
TYPE NumTblTyp  IS TABLE OF NUMBER;

  lb_stream_id          NumTblTyp;
  lb_geo_dim            CharTblTyp;
  lb_org_dim            CharTblTyp;
  lb_prd_dim            CharTblTyp;
  lb_rep_dim            CharTblTyp;
  lb_chn_dim            CharTblTyp;
  lb_dcs_dim            CharTblTyp;
  lb_ud1_dim            CharTblTyp;
  lb_ud2_dim            CharTblTyp;
  lb_base_stream_id     NumTblTyp;

  lb_cs_definition_id   NumTblTyp;
  lb_dimension_code     CharTblTyp;
  lb_level_id           NumTblTyp;

v_group_number   PLS_INTEGER;
v_counter        PLS_INTEGER;
v_final_tbl      stream_tbl_type;
v_index          PLS_INTEGER;

v_threshold_overlap   NUMBER;


PROCEDURE LOG_DEBUG( pBUFF           IN  VARCHAR2)
IS
 BEGIN

         IF G_MSC_DEBUG = 'Y' THEN

            FND_FILE.PUT_LINE( FND_FILE.LOG, pBUFF);

         ELSE
            NULL;
            --DBMS_OUTPUT.PUT_LINE( pBUFF);

         END IF;

 END LOG_DEBUG;

 PROCEDURE LOG_MESSAGE( pBUFF           IN  VARCHAR2)
 IS
 BEGIN

            FND_FILE.PUT_LINE( FND_FILE.LOG, pBUFF);

 END LOG_MESSAGE;

FUNCTION GET_DIM_CODE (p_level_id IN NUMBER)
RETURN VARCHAR2 AS

lv_dimension_code VARCHAR2(10);
BEGIN

 select dimension_code
 into lv_dimension_code
 from msd_levels
 where level_id=p_level_id
 and plan_type is NULL;           -- Bug# 4928951

/* The above fix requires plan_type column (with value as NULL) to be
   present in msd_levels even if liability code is removed. If the
   column is removed, the condition on plan_type must be removed */

 return lv_dimension_code||'_DIM';

END GET_DIM_CODE;

FUNCTION number_of_designators (p_cs_definition_id IN NUMBER)
RETURN NUMBER AS

lv_desig_count NUMBER;

BEGIN

 select count(*) into lv_desig_count
 from (select distinct cs_name from msd_cs_data where cs_definition_id=p_cs_definition_id);


 return lv_desig_count;

END number_of_designators;

FUNCTION GET_STREAM_COUNT (p_cs_definition_id IN NUMBER)
RETURN NUMBER AS

lv_count NUMBER;
BEGIN

 select count(*)
 into lv_count
 from MSD_DISTINCT_DIM_VAL_TEMP
 where stream_id=p_cs_definition_id;

 return lv_count;

END GET_STREAM_COUNT;


PROCEDURE GET_LEVEL_ID (  p_cs_definition_id IN NUMBER,
                          p_dimension_code   IN VARCHAR2)
IS

 CURSOR a(p_cs_definition_id NUMBER,p_dimension_code VARCHAR2) IS
 select to_number(decode(p_dimension_code,'PRD',attribute_2,'GEO',attribute_6,'ORG',attribute_10,'REP',attribute_18,'CHN',attribute_22,'UD1',attribute_26,'UD2',attribute_30,'DCS',attribute_45))
 from msd_cs_data
 where cs_definition_id= p_cs_definition_id
 and cs_data_id = (select min(cs_data_id) from msd_cs_data where cs_definition_id=p_cs_definition_id);

 lv_collect_level_id NUMBER;
 lv_error_text VARCHAR2(2000);

 BEGIN

 LOG_DEBUG('Entered in GET_LEVEL_ID with p_cs_definition_id='||p_cs_definition_id||' and p_dimension_code ='||p_dimension_code);

 OPEN a(p_cs_definition_id,p_dimension_code);

    FETCH a INTO lv_collect_level_id;
      LOG_DEBUG('The value of lv_collect_level_id is '||lv_collect_level_id);
    UPDATE MSD_CS_DTLS_TEMP
    SET COLLECT_LEVEL_ID  = lv_collect_level_id
    WHERE DIMENSION_CODE  = p_dimension_code
    AND  CS_DEFINITION_ID = p_cs_definition_id;

 CLOSE a;


 EXCEPTION
 WHEN OTHERS THEN

   lv_error_text :=SQLERRM;
   LOG_DEBUG(lv_error_text);

END GET_LEVEL_ID;

PROCEDURE get_boundaries(p_index IN NUMBER,
                         p_lower OUT NOCOPY NUMBER,
                         p_upper OUT NOCOPY NUMBER,
                         p_stream_tbl IN stream_tbl_type)
IS

l_counter  PLS_INTEGER;


BEGIN

LOG_DEBUG('started get_boundaries');
l_counter :=1;

FOR i IN 1..p_stream_tbl.COUNT LOOP

  IF p_stream_tbl(i).l_groupable = p_index THEN
    p_lower := l_counter;
    EXIT;
  ELSE
    l_counter := l_counter+1;
  END IF;

END LOOP;


FOR i IN l_counter..p_stream_tbl.COUNT LOOP

  IF p_stream_tbl(i).l_groupable = p_index+1  THEN
    p_upper := l_counter-1;
    EXIT;
  ELSE
   IF i <>  p_stream_tbl.COUNT THEN
      l_counter := l_counter +1;
   ELSE
      p_upper := i;
   END IF;
  END IF;

END LOOP;

EXCEPTION
 WHEN OTHERS THEN
   LOG_DEBUG('inside when others error-  get_boundaries');
   LOG_DEBUG(SQLERRM);

END get_boundaries;

PROCEDURE LOAD_SHIPMENT_STREAM
IS

CURSOR shipment IS
  SELECT  DISTINCT x.ship_to_loc,
                   x.inv_org,
                   x.item,
                   x.sales_rep,
                   x.sales_channel,
                   x.user_defined1,
                   x.user_defined2,
                   null    -- dcs level value
  FROM msd_shipment_data_v x;

  lv_stream_id NUMBER;

BEGIN

 -- MSD_SHIPMENT_HISTORY

 select cs_definition_id into lv_stream_id
 from msd_cs_definitions
 where name='MSD_SHIPMENT_HISTORY';

OPEN shipment;
   FETCH shipment BULK COLLECT INTO
              lb_geo_dim,
              lb_org_dim,
              lb_prd_dim,
              lb_rep_dim,
              lb_chn_dim,
              lb_ud1_dim,
              lb_ud2_dim,
              lb_dcs_dim;


   IF shipment%ROWCOUNT > 0 THEN

      FORALL j IN lb_geo_dim.FIRST..lb_geo_dim.LAST
        INSERT INTO MSD_DISTINCT_DIM_VAL_TEMP
                   ( STREAM_ID,
                     GEO_DIM,
                     ORG_DIM,
                     PRD_DIM,
                     REP_DIM,
                     CHN_DIM,
                     UD1_DIM,
                     UD2_DIM,
                     DCS_DIM,
                     BASE_STREAM_ID )
              VALUES
                  ( lv_stream_id,
                    lb_geo_dim(j),
                    lb_org_dim(j),
                    lb_prd_dim(j),
                    lb_rep_dim(j),
                    lb_chn_dim(j),
                    lb_ud1_dim(j),
                    lb_ud2_dim(j),
                    lb_dcs_dim(j),
                    lv_stream_id);

     END IF;
 CLOSE shipment;

   INSERT INTO MSD_CS_DTLS_TEMP
                   ( CS_DEFINITION_ID,
                     DIMENSION_CODE,
                     COLLECT_LEVEL_ID )
   SELECT a.cs_definition_id,
          a.dimension_code,
          a.collect_level_id
   FROM msd_cs_defn_dim_dtls a, msd_cs_definitions b
   WHERE a.cs_definition_id = b.cs_definition_id
   AND b.cs_definition_id = lv_stream_id
   AND a.dimension_code <> 'TIM'
   AND a.collect_flag='Y'
   AND b.strict_flag='Y'
   AND b.valid_flag='Y'
   AND b.enable_flag='Y'
   AND EXISTS (select 1 from msd_shipment_data where rownum=1);

  --MSD_SHIPMENT_ORIG_HISTORY ??


EXCEPTION
 WHEN OTHERS THEN
    LOG_DEBUG ('when others error -LOAD_SHIPMENT_STREAM');

END LOAD_SHIPMENT_STREAM;

PROCEDURE LOAD_BOOKING_STREAM
IS

CURSOR booking IS
  SELECT  DISTINCT x.ship_to_loc,
                   x.inv_org,
                   x.item,
                   x.sales_rep,
                   x.sales_channel,
                   x.user_defined1,
                   x.user_defined2,
                   null    -- dcs level value
  FROM msd_booking_data_v x;

  lv_stream_id NUMBER;

BEGIN

  -- MSD_BOOKING_HISTORY

 select cs_definition_id into lv_stream_id
 from msd_cs_definitions
 where name='MSD_BOOKING_HISTORY';

OPEN booking;
   FETCH booking BULK COLLECT INTO
              lb_geo_dim,
              lb_org_dim,
              lb_prd_dim,
              lb_rep_dim,
              lb_chn_dim,
              lb_ud1_dim,
              lb_ud2_dim,
              lb_dcs_dim;


   IF booking%ROWCOUNT > 0 THEN

      FORALL j IN lb_geo_dim.FIRST..lb_geo_dim.LAST
        INSERT INTO MSD_DISTINCT_DIM_VAL_TEMP
                   ( STREAM_ID,
                     GEO_DIM,
                     ORG_DIM,
                     PRD_DIM,
                     REP_DIM,
                     CHN_DIM,
                     UD1_DIM,
                     UD2_DIM,
                     DCS_DIM,
                     BASE_STREAM_ID )
              VALUES
                  ( lv_stream_id,
                    lb_geo_dim(j),
                    lb_org_dim(j),
                    lb_prd_dim(j),
                    lb_rep_dim(j),
                    lb_chn_dim(j),
                    lb_ud1_dim(j),
                    lb_ud2_dim(j),
                    lb_dcs_dim(j),
                    lv_stream_id);

     END IF;
 CLOSE booking;

   INSERT INTO MSD_CS_DTLS_TEMP
                   ( CS_DEFINITION_ID,
                     DIMENSION_CODE,
                     COLLECT_LEVEL_ID )
   SELECT a.cs_definition_id,
          a.dimension_code,
          a.collect_level_id
   FROM msd_cs_defn_dim_dtls a, msd_cs_definitions b
   WHERE a.cs_definition_id = b.cs_definition_id
   AND b.cs_definition_id = lv_stream_id
   AND a.dimension_code <> 'TIM'
   AND a.collect_flag='Y'
   AND b.strict_flag='Y'
   AND b.valid_flag='Y'
   AND b.enable_flag='Y'
   AND EXISTS (select 1 from msd_booking_data where rownum=1);

  --MSD_BOOKING_ORIG_HISTORY ??

EXCEPTION
 WHEN OTHERS THEN
    LOG_DEBUG ('when others error -LOAD_BOOKING_STREAM');

END LOAD_BOOKING_STREAM;

PROCEDURE LOAD_MFG_FORECAST
IS

CURSOR mfg_forecast IS
select distinct ship_to_loc_pk.level_value,
                org_pk.level_value,
                item_pk.level_value,
                null,
                sales_channel_pk.level_value,
                null,
                null,
                dcs_pk.level_value
from
    msd_mfg_forecast mbd,
    msd_level_values org_pk,
    msd_level_values dcs_pk,
    msd_level_values item_pk,
    msd_level_values sales_channel_pk,
    msd_level_values ship_to_loc_pk
WHERE (org_pk.instance = mbd.instance and org_pk.sr_level_pk = mbd.sr_inv_org_pk and org_pk.level_id = 7)
AND (dcs_pk.instance = mbd.instance and dcs_pk.sr_level_pk = mbd.sr_demand_class_pk and dcs_pk.level_id = 34)
AND (item_pk.instance = mbd.instance and item_pk.sr_level_pk = mbd.sr_item_pk and item_pk.level_id = 1)
AND (sales_channel_pk.instance(+) = mbd.instance and sales_channel_pk.sr_level_pk(+) = mbd.sr_sales_channel_pk and sales_channel_pk.level_id(+) = 27)
AND (ship_to_loc_pk.instance(+) = mbd.instance and ship_to_loc_pk.sr_level_pk(+) = mbd.sr_ship_to_loc_pk and ship_to_loc_pk.level_id(+) = 11);

lv_stream_id NUMBER;
lv_forecast_designator NUMBER;

BEGIN

 select cs_definition_id into lv_stream_id
 from msd_cs_definitions
 where name='MSD_MANUFACTURING_FORECAST';

 select count(*) into lv_forecast_designator
 from ( select distinct forecast_designator from msd_mfg_forecast);

 IF ( lv_forecast_designator = 1 ) THEN

   OPEN mfg_forecast;
   FETCH mfg_forecast BULK COLLECT INTO
              lb_geo_dim,
              lb_org_dim,
              lb_prd_dim,
              lb_rep_dim,
              lb_chn_dim,
              lb_ud1_dim,
              lb_ud2_dim,
              lb_dcs_dim;


   IF mfg_forecast%ROWCOUNT > 0 THEN

      FORALL j IN lb_geo_dim.FIRST..lb_geo_dim.LAST
        INSERT INTO MSD_DISTINCT_DIM_VAL_TEMP
                   ( STREAM_ID,
                     GEO_DIM,
                     ORG_DIM,
                     PRD_DIM,
                     REP_DIM,
                     CHN_DIM,
                     UD1_DIM,
                     UD2_DIM,
                     DCS_DIM,
                     BASE_STREAM_ID )
              VALUES
                  ( lv_stream_id,
                    lb_geo_dim(j),
                    lb_org_dim(j),
                    lb_prd_dim(j),
                    lb_rep_dim(j),
                    lb_chn_dim(j),
                    lb_ud1_dim(j),
                    lb_ud2_dim(j),
                    lb_dcs_dim(j),
                    lv_stream_id);

     END IF;
 CLOSE mfg_forecast;

   INSERT INTO MSD_CS_DTLS_TEMP
                   ( CS_DEFINITION_ID,
                     DIMENSION_CODE,
                     COLLECT_LEVEL_ID )
   SELECT a.cs_definition_id,
          a.dimension_code,
          a.collect_level_id
   FROM msd_cs_defn_dim_dtls a, msd_cs_definitions b
   WHERE a.cs_definition_id = b.cs_definition_id
   AND b.cs_definition_id = lv_stream_id
   AND a.dimension_code <> 'TIM'
   AND a.collect_flag='Y'
   AND b.strict_flag='Y'
   AND b.valid_flag='Y'
   AND b.enable_flag='Y'
   AND EXISTS (select 1 from MSD_MFG_FCST_CS_V where rownum=1);

 ELSE
   NULL;
 END IF;

EXCEPTION
 WHEN OTHERS THEN
    LOG_DEBUG ('when others error -LOAD_MFG_FORECAST');

END LOAD_MFG_FORECAST;


PROCEDURE get_in_order ( p_stream_tbl IN OUT NOCOPY stream_tbl_type )
IS

temp_rec            stream_rec_type;
l_max_index         NUMBER;

BEGIN

  FOR i in 1..p_stream_tbl.COUNT
   LOOP

     l_max_index := i ;

      FOR j in i+1..p_stream_tbl.COUNT
        LOOP

         IF p_stream_tbl(j).l_distinct_distributions > p_stream_tbl(l_max_index).l_distinct_distributions
           THEN

            l_max_index := j;

         END IF;

      END LOOP;


      temp_rec                  := p_stream_tbl(l_max_index);
      p_stream_tbl(l_max_index) := p_stream_tbl(i);
      p_stream_tbl(i)           := temp_rec ;

  END LOOP;

EXCEPTION
 WHEN OTHERS THEN
    LOG_DEBUG ('when others error -get_in_order');

END get_in_order;




PROCEDURE MSD_ASSIGN_GROUPS (p_stream_tbl IN OUT NOCOPY stream_tbl_type)


IS

l_grouped            BOOLEAN;
l_base_stream_index  NUMBER;
lv_sql_stmt          VARCHAR2(2000);
l_temp_rec           stream_rec_type;

l_overlap            NUMBER;
l_current_group      NUMBER;


BEGIN

  LOG_MESSAGE('Entered in MSD_ASSIGN_GROUPS');

  LOG_MESSAGE ('Number of streams in this particular stream set :'||p_stream_tbl.COUNT);

/*  For Logging purpose  */
   FOR j in 1..p_stream_tbl.COUNT
   LOOP
    LOG_MESSAGE ( 'Element '||j||': '||p_stream_tbl(j).p_stream_id||', '||p_stream_tbl(j).l_reading_level_string||', '||p_stream_tbl(j).l_groupable );
   END LOOP;




   IF p_stream_tbl.COUNT = 1 THEN

     v_group_number := v_group_number + 1;
     p_stream_tbl(1).l_group := v_group_number;

     LOG_DEBUG('Value of v_group_number '||v_group_number);

     v_counter := v_counter + 1;
     v_final_tbl(v_counter) := p_stream_tbl(1);

     LOG_DEBUG('Value of v_counter '||v_counter);

 /*    LOG_DEBUG('*********SHOW v_final_tbl when count is one-starts********');


       For Logging purpose
      FOR j in 1..v_final_tbl.COUNT
        LOOP
           LOG_DEBUG ( 'Element '||j||': '||v_final_tbl(j).p_stream_id||', '||v_final_tbl(j).l_reading_level_string||', '||v_final_tbl(j).l_groupable||', '||v_final_tbl(j).l_group );
      END LOOP;



     LOG_DEBUG('*********SHOW v_final_tbl when count is one-ends********'); */

   ELSE

    LOG_DEBUG ('***********SORTING STARTS***************** ');

       get_in_order(p_stream_tbl);


       FOR j in 1..p_stream_tbl.COUNT
         LOOP
           LOG_DEBUG ( 'Element '||j||': '||p_stream_tbl(j).p_stream_id||', '||p_stream_tbl(j).l_distinct_distributions||', '||p_stream_tbl(j).l_dimension_clause );
       END LOOP;

    LOG_DEBUG ('***********SORTING ENDS***************** ');


     v_group_number := v_group_number + 1;
     p_stream_tbl(1).l_group := v_group_number;

     LOG_DEBUG('Value of v_group_number '||v_group_number);

     l_current_group :=v_group_number;


     FOR i IN 2..p_stream_tbl.COUNT
       LOOP

       l_grouped             := FALSE;
       l_base_stream_index   := 0;

       LOG_DEBUG('-------Value of i is:'||i||'--------');

         FOR j IN REVERSE 1..(i-1)
           LOOP

           LOG_DEBUG('-------Value of j is:'||j||'--------');

           IF ( (not l_grouped)  AND (p_stream_tbl(j).l_base_stream_id = p_stream_tbl(j).p_stream_id) ) THEN

                lv_sql_stmt := '   select sum(count(*))/2  '
                             ||' from MSD_DISTINCT_DIM_VAL_TEMP  '
                             ||' where base_stream_id in ( :l_id1, :l_id2 )  '
                             ||' group by  '||p_stream_tbl(i).l_dimension_clause
                             ||' having count(*) > 1 ';

                     LOG_DEBUG('------SQL statement1 to be executed is : '||lv_sql_stmt);
                     LOG_DEBUG('------Parameters are l_id1'||p_stream_tbl(i).l_base_stream_id);
                     LOG_DEBUG('------Parameters are l_id2'||p_stream_tbl(j).l_base_stream_id);


                     EXECUTE IMMEDIATE lv_sql_stmt INTO l_overlap USING p_stream_tbl(i).l_base_stream_id,
                                                                        p_stream_tbl(j).l_base_stream_id;

                      LOG_DEBUG('---- Value of l_overlap is : '||l_overlap||'--------');

                   IF (( l_overlap/(p_stream_tbl(i).l_stream_count + p_stream_tbl(j).l_distinct_distributions - l_overlap)) > v_threshold_overlap )
                    THEN

                        LOG_DEBUG('----Passes the threshold value----------');

                         l_grouped                                  := TRUE;
                         p_stream_tbl(i).l_group                    := p_stream_tbl(j).l_group;
                         l_base_stream_index                        := j;
                         p_stream_tbl(i).l_base_stream_id           := p_stream_tbl(j).p_stream_id;
                         p_stream_tbl(j).l_distinct_distributions   := p_stream_tbl(j).l_distinct_distributions + p_stream_tbl(i).l_stream_count - l_overlap;

                      /*
                       lv_sql_stmt :=  '  UPDATE MSD_DISTINCT_DIM_VAL_TEMP   '
                                     ||'  SET base_stream_id = 0             '
                                     || ' WHERE rowid in ( select min(rowid) '
                                                          ||' from MSD_DISTINCT_DIM_VAL_TEMP '
                                                          ||' where base_stream_id in (:l_id1, :l_id2) '
                                                          ||' group by '||p_stream_tbl(i).l_dimension_clause
                                                          ||' having count(*) > 1)';  */

                        lv_sql_stmt :=   '  UPDATE MSD_DISTINCT_DIM_VAL_TEMP '
                                       ||'  SET BASE_STREAM_ID = 0 '
                                       ||'  WHERE ROWID IN ( select x.rowid from '
                                       ||'                     (select geo_dim,org_dim,prd_dim,rep_dim,chn_dim,dcs_dim,ud1_dim,ud2_dim from MSD_DISTINCT_DIM_VAL_TEMP where base_stream_id=:l_id1) x, '
                                       ||'                     (select geo_dim,org_dim,prd_dim,rep_dim,chn_dim,dcs_dim,ud1_dim,ud2_dim from MSD_DISTINCT_DIM_VAL_TEMP where base_stream_id=:l_id2) y  '
                                       ||'                   where nvl(x.geo_dim,-1) = nvl(y.geo_dim,-1) '
                                       ||'                   and   nvl(x.org_dim,-1) = nvl(y.org_dim,-1) '
                                       ||'                   and   nvl(x.prd_dim,-1) = nvl(y.prd_dim,-1) '
                                       ||'                   and   nvl(x.rep_dim,-1) = nvl(y.rep_dim,-1) '
                                       ||'                   and   nvl(x.chn_dim,-1) = nvl(y.chn_dim,-1) '
                                       ||'                   and   nvl(x.dcs_dim,-1) = nvl(y.dcs_dim,-1) '
                                       ||'                   and   nvl(x.ud1_dim,-1) = nvl(y.ud1_dim,-1) '
				       ||'                   and   nvl(x.ud2_dim,-1) = nvl(y.ud2_dim,-1)  )';


                        LOG_DEBUG('------SQL statement2 to be executed is : '||lv_sql_stmt);
                        LOG_DEBUG('------Parameters are l_id1'||p_stream_tbl(i).p_stream_id);
                        LOG_DEBUG('------Parameters are l_id2'||p_stream_tbl(j).p_stream_id);

                               EXECUTE IMMEDIATE lv_sql_stmt  USING  p_stream_tbl(i).p_stream_id,
                                                                     p_stream_tbl(j).p_stream_id;



                        UPDATE MSD_DISTINCT_DIM_VAL_TEMP
                        SET    base_stream_id  = p_stream_tbl(j).p_stream_id
                        WHERE  stream_id       = p_stream_tbl(i).p_stream_id
                        AND    base_stream_id  = p_stream_tbl(i).p_stream_id;

                END IF; /* check for p_threshold */


           ELSIF l_grouped AND ( p_stream_tbl(j).l_base_stream_id =  p_stream_tbl(j).p_stream_id ) THEN

             LOG_DEBUG('-------Entered in the conditioned where l_grouped is TRUE-----');

               IF p_stream_tbl(j).l_distinct_distributions < p_stream_tbl(l_base_stream_index).l_distinct_distributions
                 THEN

                 LOG_DEBUG('---------Entered in the swapping-----');

                   l_temp_rec                           := p_stream_tbl(j);
                   p_stream_tbl(j)                      := p_stream_tbl(l_base_stream_index);
                   p_stream_tbl(l_base_stream_index)    := l_temp_rec;

                   l_base_stream_index := j;

               END IF;

           END IF;



          END LOOP; /* for j */


       IF p_stream_tbl(i).l_group IS NULL THEN

           LOG_DEBUG('------Entered in the condition -> where l_group is still NULL--------');

           l_current_group :=l_current_group + 1;
           v_group_number := v_group_number + 1;
           p_stream_tbl(i).l_group := l_current_group;

           LOG_DEBUG('Value of v_group_number '||v_group_number);

       END IF;

     END LOOP; /* for i */


        LOG_DEBUG('----- OUT of i LOOP , incrementing the value of v_counter-------');

        FOR i IN 1..p_stream_tbl.COUNT LOOP

           v_counter := v_counter + 1;
           v_final_tbl(v_counter) := p_stream_tbl(i);

           LOG_DEBUG('Value of v_counter '||v_counter);

        END LOOP;

   END IF;


   IF v_counter = v_index - 1  THEN

     LOG_MESSAGE ('Procedure MSD_ASSIGN_GROUPS is sucessfully completed for all the groupable set of streams');

     --LOG_DEBUG ('value of v_final_tbl.COUNT    '||v_final_tbl.COUNT);

   /*  -- For Logging purpose
      FOR j in 1..v_final_tbl.COUNT
        LOOP
           LOG_DEBUG ( 'Element '||j||': '||v_final_tbl(j).p_stream_id||', '||v_final_tbl(j).l_reading_level_string||', '||v_final_tbl(j).l_groupable||', '||v_final_tbl(j).l_group );
      END LOOP;
    */

   END IF;


EXCEPTION
 WHEN OTHERS THEN
    LOG_DEBUG ('when others error -MSD_ASSIGN_GROUPS');
    ROLLBACK;
    LOG_DEBUG(SQLERRM);

END MSD_ASSIGN_GROUPS;


PROCEDURE MSD_GROUP_STREAMS (  ERRBUF   OUT NOCOPY VARCHAR2,
			       RETCODE  OUT NOCOPY NUMBER,
			       p_mode IN NUMBER DEFAULT SYS_NO,
			       p_threshold_overlap IN NUMBER DEFAULT NULL)
IS

 stream_tbl1     stream_tbl_type;
 stream_tbl2     stream_tbl_type;
 stream_tbl3     stream_tbl_type;

lv_cs_definition_id  NUMBER;
lv_dimension_code    VARCHAR2(10);
lv_cur_stmt          VARCHAR2(2000);

lv_reading_level_string  VARCHAR2(255);
lv_dimension_clause      VARCHAR2(255);
lv_stream_count          NUMBER;


lv_groupable   PLS_INTEGER;
x_var         PLS_INTEGER;
l_lower       PLS_INTEGER;
l_upper       PLS_INTEGER;


CURSOR c IS
  SELECT  DISTINCT x.cs_definition_id,
      x.attribute_8,
      x.attribute_12,
      x.attribute_4,
      x.attribute_20,
      x.attribute_24,
      x.attribute_28,
      x.attribute_32,
      x.attribute_47,
      x.cs_definition_id
  FROM msd_cs_data x;

CURSOR c1 IS
  SELECT a.cs_definition_id,a.dimension_code,a.collect_level_id
  FROM msd_cs_defn_dim_dtls a, msd_cs_definitions b
  WHERE a.cs_definition_id = b.cs_definition_id
  AND a.dimension_code <> 'TIM'
  AND a.collect_flag='Y'
  AND b.strict_flag='Y'
  AND b.valid_flag='Y'
  AND b.enable_flag='Y'
  AND ( ( b.multiple_stream_flag='N') OR ( b.multiple_stream_flag='Y' and MSD_COMPOSITE_GROUPING.number_of_designators(b.cs_definition_id)=1 ))
  AND EXISTS (select 1 from msd_cs_data where cs_definition_id=a.cs_definition_id) ;
    --need to elimintate custom streams having multiple streams with more than one designator.

CURSOR c2 IS
 SELECT cs_definition_id,dimension_code
 FROM   MSD_CS_DTLS_TEMP
 WHERE COLLECT_LEVEL_ID IS NULL;

 TYPE mastcurtyp IS REF CURSOR;
 c3 mastcurtyp;

 --Made c3 Cursor dynamic for Bug 3476620.
/*
CURSOR c3 IS
SELECT cs_definition_id stream_id,
MSD_COMPOSITE_GROUPING.GET_STREAM_COUNT(cs_definition_id) stream_count,
MSD_COMPOSITE_GROUPING.GET_STREAM_COUNT(cs_definition_id) distinct_stream_count,
cs_definition_id base_stream_id,
dim1||decode(dim2,NULL,'',','||dim2)||decode(dim3,NULL,'',','||dim3)||decode(dim4,NULL,'',','||dim4)||decode(dim5,NULL,'',','||dim5)||decode(dim6,NULL,'',','||dim6)||decode(dim7,NULL,'',','||dim7)||decode(dim8,NULL,'',','||dim8)
reading_level_string,
MSD_COMPOSITE_GROUPING.GET_DIM_CODE(dim1)||decode(dim2,NULL,'',','||MSD_COMPOSITE_GROUPING.GET_DIM_CODE(dim2))||decode(dim3,NULL,'',','||MSD_COMPOSITE_GROUPING.GET_DIM_CODE(dim3))||decode(dim4,NULL,'',','||MSD_COMPOSITE_GROUPING.GET_DIM_CODE(dim4))||
decode(dim5,NULL,'',','||MSD_COMPOSITE_GROUPING.GET_DIM_CODE(dim5))||decode(dim6,NULL,'',','||MSD_COMPOSITE_GROUPING.GET_DIM_CODE(dim6))||decode(dim7,NULL,'',','||MSD_COMPOSITE_GROUPING.GET_DIM_CODE(dim7))||
decode(dim8,NULL,'',','||MSD_COMPOSITE_GROUPING.GET_DIM_CODE(dim8)) dimension_clause
FROM
(select cs_definition_id,collect_level_id as dim1,
LEAD(collect_level_id,1) over (partition by cs_definition_id order by collect_level_id) as dim2,
LEAD(collect_level_id,2) over (partition by cs_definition_id order by collect_level_id) as dim3,
LEAD(collect_level_id,3) over (partition by cs_definition_id order by collect_level_id) as dim4,
LEAD(collect_level_id,4) over (partition by cs_definition_id order by collect_level_id) as dim5,
LEAD(collect_level_id,5) over (partition by cs_definition_id order by collect_level_id) as dim6,
LEAD(collect_level_id,6) over (partition by cs_definition_id order by collect_level_id) as dim7,
LEAD(collect_level_id,7) over (partition by cs_definition_id order by collect_level_id) as dim8,
row_number() over (partition by cs_definition_id order by collect_level_id) as rno
from MSD_CS_DTLS_TEMP )
WHERE rno=1
ORDER BY dim1,dim2,dim3,dim4,dim5,dim6,dim7,dim8;
*/

 BEGIN

   v_threshold_overlap  := p_threshold_overlap;
   v_threshold_overlap  :=0.85;                  -- Hardcoded Threshold percentage

  ----- populating the temporary tables MSD_DISTINCT_DIM_VAL_TEMP and MSD_CS_DTLS_TEMP -------

  --TRUNCATE TABLE MSD_DISTINCT_DIM_VAL_TEMP;

 OPEN c;
   FETCH c BULK COLLECT INTO
              lb_stream_id,
              lb_geo_dim,
              lb_org_dim,
              lb_prd_dim,
              lb_rep_dim,
              lb_chn_dim,
              lb_ud1_dim,
              lb_ud2_dim,
              lb_dcs_dim,
              lb_base_stream_id;

   IF c%ROWCOUNT > 0 THEN

      FORALL j IN lb_stream_id.FIRST..lb_stream_id.LAST
        INSERT INTO MSD_DISTINCT_DIM_VAL_TEMP
                   ( STREAM_ID,
                     GEO_DIM,
                     ORG_DIM,
                     PRD_DIM,
                     REP_DIM,
                     CHN_DIM,
                     UD1_DIM,
                     UD2_DIM,
                     DCS_DIM,
                     BASE_STREAM_ID )
              VALUES
                  ( lb_stream_id(j),
                    lb_geo_dim(j),
                    lb_org_dim(j),
                    lb_prd_dim(j),
                    lb_rep_dim(j),
                    lb_chn_dim(j),
                    lb_ud1_dim(j),
                    lb_ud2_dim(j),
                    lb_dcs_dim(j),
                    lb_base_stream_id(j));

     END IF;
 CLOSE c;

  --TRUNCATE TABLE MSD_CS_DTLS_TEMP;

 OPEN c1;
   FETCH c1 BULK COLLECT INTO
              lb_cs_definition_id,
              lb_dimension_code,
              lb_level_id;

   IF c1%ROWCOUNT > 0 THEN

      FORALL j IN lb_cs_definition_id.FIRST..lb_cs_definition_id.LAST
        INSERT INTO MSD_CS_DTLS_TEMP
                   ( CS_DEFINITION_ID,
                     DIMENSION_CODE,
                     COLLECT_LEVEL_ID )
              VALUES
                  ( lb_cs_definition_id(j),
                    lb_dimension_code(j),
                    lb_level_id(j)          );

     END IF;
 CLOSE c1;

  LOAD_SHIPMENT_STREAM;

  LOAD_BOOKING_STREAM;

  LOAD_MFG_FORECAST;

 OPEN c2;
   LOOP
    FETCH c2 INTO lv_cs_definition_id,lv_dimension_code;
      EXIT WHEN c2%NOTFOUND;
      GET_LEVEL_ID (lv_cs_definition_id,lv_dimension_code);
   END LOOP;
 CLOSE c2;

 COMMIT;

 ---- Both Temporary tables are populated by here -------------

 --Made c3 Cursor dynamic for Bug 3476620.
 lv_cur_stmt :=    ' SELECT cs_definition_id stream_id, '
 ||' MSD_COMPOSITE_GROUPING.GET_STREAM_COUNT(cs_definition_id) stream_count, '
 ||' MSD_COMPOSITE_GROUPING.GET_STREAM_COUNT(cs_definition_id) distinct_stream_count, '
 ||' cs_definition_id base_stream_id, '
 ||' dim1||decode(dim2,NULL,'''','',''||dim2)||decode(dim3,NULL,'''','',''||dim3)||decode(dim4,NULL,'''','',''||dim4)||decode(dim5,NULL,'''','',''||dim5)||decode(dim6,NULL,'''','',''||dim6)|| '
 ||' decode(dim7,NULL,'''','',''||dim7)||decode(dim8,NULL,'''','',''||dim8) reading_level_string, '
 ||' MSD_COMPOSITE_GROUPING.GET_DIM_CODE(dim1)||decode(dim2,NULL,'''','',''||MSD_COMPOSITE_GROUPING.GET_DIM_CODE(dim2))||decode(dim3,NULL,'''','',''||MSD_COMPOSITE_GROUPING.GET_DIM_CODE(dim3))|| '
 ||' decode(dim4,NULL,'''','',''||MSD_COMPOSITE_GROUPING.GET_DIM_CODE(dim4))|| '
 ||' decode(dim5,NULL,'''','',''||MSD_COMPOSITE_GROUPING.GET_DIM_CODE(dim5))||decode(dim6,NULL,'''','',''||MSD_COMPOSITE_GROUPING.GET_DIM_CODE(dim6))||decode(dim7,NULL,'''','',''||MSD_COMPOSITE_GROUPING.GET_DIM_CODE(dim7))|| '
 ||' decode(dim8,NULL,'''','',''||MSD_COMPOSITE_GROUPING.GET_DIM_CODE(dim8)) dimension_clause '
 ||' FROM '
 ||' (select cs_definition_id,collect_level_id as dim1, '
 ||' LEAD(collect_level_id,1) over (partition by cs_definition_id order by collect_level_id) as dim2, '
 ||' LEAD(collect_level_id,2) over (partition by cs_definition_id order by collect_level_id) as dim3, '
 ||' LEAD(collect_level_id,3) over (partition by cs_definition_id order by collect_level_id) as dim4, '
 ||' LEAD(collect_level_id,4) over (partition by cs_definition_id order by collect_level_id) as dim5, '
 ||' LEAD(collect_level_id,5) over (partition by cs_definition_id order by collect_level_id) as dim6, '
 ||' LEAD(collect_level_id,6) over (partition by cs_definition_id order by collect_level_id) as dim7, '
 ||' LEAD(collect_level_id,7) over (partition by cs_definition_id order by collect_level_id) as dim8, '
 ||' row_number() over (partition by cs_definition_id order by collect_level_id) as rno '
 ||' from MSD_CS_DTLS_TEMP ) '
 ||' WHERE rno=1 '
 ||' ORDER BY dim1,dim2,dim3,dim4,dim5,dim6,dim7,dim8 ';

 /* Populating the pl/sql table for all the possible streams to be grouped */

 OPEN c3 FOR lv_cur_stmt;  --Made c3 Cursor dynamic for Bug 3476620.
   v_index :=1;

   LOOP

     LOG_DEBUG (' Value of v_index '||v_index);
     FETCH c3 INTO stream_tbl1(v_index).p_stream_id,
                   stream_tbl1(v_index).l_stream_count,
                   stream_tbl1(v_index).l_distinct_distributions,
                   stream_tbl1(v_index).l_base_stream_id,
                   stream_tbl1(v_index).l_reading_level_string,
                   stream_tbl1(v_index).l_dimension_clause;

       EXIT WHEN c3%NOTFOUND;
       v_index := v_index + 1;

   END LOOP;

 CLOSE c3;




 /*  Forming the set of streams that can be grouped */
  lv_groupable :=1;
  stream_tbl1(1).l_groupable := lv_groupable;

  FOR i IN 2..stream_tbl1.COUNT
   LOOP
      LOG_DEBUG (' Value of lv_groupable '||lv_groupable);
      IF stream_tbl1(i).l_reading_level_string = stream_tbl1(i-1).l_reading_level_string THEN
         stream_tbl1(i).l_groupable := lv_groupable;
      ELSE
         lv_groupable := lv_groupable + 1;
         stream_tbl1(i).l_groupable := lv_groupable;
      END IF;

    END LOOP;

   /*  For Logging purpose  */
   FOR j in 1..stream_tbl1.COUNT
   LOOP
    LOG_MESSAGE ( 'Element '||j||': '||stream_tbl1(j).p_stream_id||', '||stream_tbl1(j).l_reading_level_string||', '||stream_tbl1(j).l_groupable );
   END LOOP;




 ----  Calling function  MSD_ASSIGN_GROUPS for each set of groupable streams----------

   v_group_number := 0;
   v_counter      := 0;

   FOR i IN 1..lv_groupable
   LOOP

     get_boundaries(i,l_lower,l_upper,stream_tbl1);

     LOG_DEBUG (' i ='||i);
     LOG_DEBUG('l_lower '||l_lower);
     LOG_DEBUG('l_upper '||l_upper);


     x_var := 1;
     FOR j IN l_lower..l_upper
     LOOP
       LOG_DEBUG ('x_var is'||x_var);
       stream_tbl2(x_var) :=stream_tbl1(j);
       x_var := x_var + 1;
     END LOOP;

     MSD_ASSIGN_GROUPS ( stream_tbl2 );

     stream_tbl2 := stream_tbl3;

   END LOOP;





 ----  Based on the application mode updating/displaying or displaying the Composite grouping

 IF p_mode = SYS_YES THEN

  LOG_MESSAGE('-------APPLICATION MODE is YES---------');

   LOG_MESSAGE('*************FINAL OUTPUT - STARTS**************');

   UPDATE MSD_CS_DEFINITIONS
   SET COMPOSITE_GROUP_CODE = to_number(NULL);


   FOR j in 1..v_final_tbl.COUNT
   LOOP
    LOG_MESSAGE ( 'Element '||j||': '||v_final_tbl(j).p_stream_id||', '||v_final_tbl(j).l_dimension_clause||', '||v_final_tbl(j).l_group);

   UPDATE MSD_CS_DEFINITIONS
   SET COMPOSITE_GROUP_CODE =  v_final_tbl(j).l_group
   WHERE CS_DEFINITION_ID   =  v_final_tbl(j).p_stream_id;

   END LOOP;

   LOG_MESSAGE('*************FINAL OUTPUT - ENDS**************');

   COMMIT;

 ELSE

   LOG_MESSAGE('-----APPLICATION MODE is NO------');

   LOG_MESSAGE('*************FINAL OUTPUT - STARTS**************');

   /*  For Logging purpose  */
   FOR j in 1..v_final_tbl.COUNT
   LOOP
    LOG_MESSAGE ( 'Element '||j||': '||v_final_tbl(j).p_stream_id||', '||v_final_tbl(j).l_dimension_clause||', '||v_final_tbl(j).l_group);
   END LOOP;

   LOG_MESSAGE('*************FINAL OUTPUT - ENDS**************');

 END IF;

   RETCODE := G_SUCCESS;

EXCEPTION
  WHEN OTHERS THEN
    LOG_DEBUG ('when others error -msd_group_streams');
    ROLLBACK;
    RETCODE := G_ERROR;
    LOG_DEBUG(SQLERRM);


END MSD_GROUP_STREAMS;

END MSD_COMPOSITE_GROUPING;

/
