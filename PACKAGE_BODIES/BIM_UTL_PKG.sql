--------------------------------------------------------
--  DDL for Package Body BIM_UTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_UTL_PKG" AS
/* $Header: bimutlpb.pls 115.8 2004/02/19 10:33:14 kpadiyar noship $*/

 g_pkg_name  CONSTANT  VARCHAR2(20) := 'BIM_UTL_PKG';
 g_file_name CONSTANT  VARCHAR2(20) := 'bimutlpb.pls';
 l_to_currency  VARCHAR2(100) := fnd_profile.value('AMS_DEFAULT_CURR_CODE');
 l_conversion_type VARCHAR2(30):= fnd_profile.VALUE('AMS_CURR_CONVERSION_TYPE');
---------------------------------------------------------------------
-- FUNCTION
--    Convert_Currency
-- NOTE: Given from currency, from amount, converts to default currency amount.
--       Default currency can be get from profile value.
-- PARAMETER
--   p_from_currency      IN  VARCHAR2,
--   p_to_currency        IN  VARCHAR2,
--   p_from_amount        IN  NUMBER,
-- RETURN   NUMBER
---------------------------------------------------------------------
FUNCTION  convert_currency(
   p_from_currency          VARCHAR2  ,
   p_from_amount            NUMBER) return NUMBER
IS
   l_user_rate                  CONSTANT NUMBER       := 1;
   l_max_roll_days              CONSTANT NUMBER       := -1;
   l_denominator      NUMBER;   -- Not used in Marketing.
   l_numerator        NUMBER;   -- Not used in Marketing.
   l_to_amount    NUMBER;
   l_rate         NUMBER;
BEGIN

     -- Conversion type cannot be null in profile
     IF l_conversion_type IS NULL THEN
       IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_NO_EXCHANGE_TYPE');
         fnd_msg_pub.add;
       END IF;
       RETURN 0;
     END IF;

-- Call the proper GL API to convert the amount.
 gl_currency_api.convert_closest_amount(
      x_from_currency => p_from_currency
     ,x_to_currency => l_to_currency
     ,x_conversion_date =>sysdate
     ,x_conversion_type => l_conversion_type
     ,x_user_rate => l_user_rate
     ,x_amount => p_from_amount
     ,x_max_roll_days => l_max_roll_days
     ,x_converted_amount => l_to_amount
     ,x_denominator => l_denominator
     ,x_numerator => l_numerator
     ,x_rate => l_rate);
RETURN (l_to_amount);
EXCEPTION
   WHEN gl_currency_api.no_rate THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_NO_RATE');
         fnd_msg_pub.add;
      END IF;
      RETURN 0;
   WHEN gl_currency_api.invalid_currency THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_INVALID_CURR');
         fnd_msg_pub.add;
      END IF;
      RETURN 0;
   WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg('OZF_UTLITY_PVT', 'Convert_curency');
      END IF;
      RETURN 0;
END convert_currency;
-----------------------------------------------------------------------
 -- PROCEDURE
 --    LOG_HISTORY
 --
 -- Note
 --    Insert history data for each load
--------------------------------------------------------------------------
PROCEDURE LOG_HISTORY(
    p_object                      VARCHAR2        ,
    p_start_time                  DATE            ,
    p_end_time                    DATE            ,
    x_msg_count              OUT  NOCOPY NUMBER          ,
    x_msg_data               OUT  NOCOPY VARCHAR2        ,
    x_return_status          OUT  NOCOPY VARCHAR2
 )
IS
    l_user_id            NUMBER := FND_GLOBAL.USER_ID();
    l_table_name         VARCHAR2(100):='bim_rep_history';
BEGIN
    INSERT INTO
    bim_rep_history
       (creation_date,
        last_update_date,
        created_by,
        last_updated_by,
        object_last_updated_date,
        object,
        start_date,
        end_date)
 VALUES
       (sysdate,
        sysdate,
        l_user_id,
        l_user_id,
        sysdate,
        p_object,
        p_start_time,
        p_end_time);
EXCEPTION
WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MESSAGE.Set_Name ('AMS', 'AMS_REP_INSERT_ERROR');
   FND_MESSAGE.Set_token('table_name', l_table_name, FALSE);
   FND_MSG_PUB.Add;
   fnd_file.put_line(fnd_file.log,fnd_message.get);
END LOG_HISTORY;

/* This procedure will drop the indexes of table p_table_name, and put
  the index name and other information into bim_all_indexes. */
PROCEDURE DROP_INDEX
    ( p_table_name             IN  VARCHAR2
    )
    IS
    l_user_id          	   	   NUMBER := FND_GLOBAL.USER_ID();
    l_sysdate          	  	   DATE   := SYSDATE;
    l_api_version_number       	   CONSTANT NUMBER       := 1.0;
    l_api_name                 	   CONSTANT VARCHAR2(30) := 'DROP_INDEX';
    l_success                VARCHAR2(3);
    l_seq_name               VARCHAR(100);
    l_def_tablespace         VARCHAR2(100);
    l_index_tablespace       VARCHAR2(100);
    l_oracle_username        VARCHAR2(100);
    l_table_name	     VARCHAR2(100);
    l_temp_msg		     VARCHAR2(100);

    /* Following tables are declared for storing information about the indexes */
    TYPE  generic_number_table IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE  generic_char_table IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

    l_pct_free	       	     generic_number_table;
    l_ini_trans 	     generic_number_table;
    l_max_trans  	     generic_number_table;
    l_initial_extent   	     generic_number_table;
    l_next_extent  	     generic_number_table;
    l_min_extents 	     generic_number_table;
    l_max_extents 	     generic_number_table;
    l_pct_increase 	     generic_number_table;
    l_column_position        generic_number_table;
    l_owner 		     generic_char_table;
    l_uniqueness 	     generic_char_table;
    l_index_name 	     generic_char_table;
    l_ind_column_name  	     generic_char_table;
    l_index_table_name       generic_char_table;
    l_col_num                VARCHAR2(1000);
    is_unique                VARCHAR2(30);
    i			     NUMBER;
    j                        NUMBER;
    l_count                  NUMBER;

   l_status      VARCHAR2(30);
   l_industry    VARCHAR2(30);
   l_orcl_schema VARCHAR2(30);
   l_bol         BOOLEAN := fnd_installation.get_app_info ('BIM',l_status,l_industry,l_orcl_schema);

    CURSOR    get_ts_name IS
    SELECT    i.tablespace, i.index_tablespace, u.oracle_username
    FROM      fnd_product_installations i, fnd_application a,
	      fnd_oracle_userid u
    WHERE     a.application_short_name = 'BIM'
    AND       a.application_id = i.application_id
    AND       u.oracle_id = i.oracle_id;

    CURSOR    get_index_params(p_name VARCHAR2 ,l_schema VARCHAR2) IS
    SELECT    a.owner,a.index_name,b.table_name,a.uniqueness,b.column_name,
              b.column_position,a.pct_free,a.ini_trans,a.max_trans,
              a.initial_extent,a.next_extent,a.min_extents,a.max_extents,
              a.pct_increase
    FROM      all_ind_columns b, all_indexes a
    WHERE     a.index_name = b.index_name
    AND       a.owner = l_schema
    AND       a.owner = b.index_owner
    AND       b.table_name =upper(p_name)
    ORDER BY  a.index_name,b.column_position;

    CURSOR   index_count(p_name VARCHAR2) IS
    SELECT   count(*)
    FROM     bim_all_indexes
    WHERE    table_name =upper(p_name);

 BEGIN

   /* Get the tablespace name for the purpose of creating the index on that tablespace */
   OPEN  get_ts_name;
   FETCH get_ts_name INTO l_def_tablespace, l_index_tablespace, l_oracle_username;
   CLOSE get_ts_name;

   /* Check whether there is already entried in bim_all_indexes. */
   OPEN index_count(p_table_name);
   FETCH index_count into l_count;
   CLOSE index_count;

   /* Only if there is no entries in table bim_all_indexes, otherwise it means
   that the indexes are already dropped. */
   IF l_count = 0 THEN

   /* Retrieve and store INDEX parameters. Then drop the indexes */
   i := 1;
   FOR x in get_index_params(p_table_name,l_orcl_schema) LOOP
   BEGIN
          l_pct_free(i)                  := x.pct_free;
          l_ini_trans(i)                 := x.ini_trans;
          l_max_trans(i)                 := x.max_trans;
          l_initial_extent(i)            := x.initial_extent;
          l_next_extent(i)               := x.next_extent;
          l_min_extents(i)               := x.min_extents;
          l_max_extents(i)               := x.max_extents;
          l_pct_increase(i)              := x.pct_increase;
          l_owner(i)                     := x.owner;
          l_index_name(i)                := x.index_name;
          l_index_table_name(i)          := x.table_name;
          l_ind_column_name(i)           := x.column_name;
          l_uniqueness(i)                := x.uniqueness;
          l_column_position(i)           := x.column_position;

          IF (l_column_position(i) = 1) THEN
           EXECUTE IMMEDIATE 'DROP INDEX  '|| l_owner(i) || '.'|| l_index_name(i) ;
          --dbms_output.put_line('Drop index '|| l_owner(i) || '.'|| l_index_name(i));
          END IF;
          i := i + 1;
   EXCEPTION
   WHEN OTHERS THEN
   ams_utility_pvt.write_conc_log('error dropping index:'||sqlerrm(sqlcode));
   END;
    END LOOP;
  --dbms_output.put_line('I:'||i);
   /* Insert the indexes parameters into bim_all_indexes. */

   j:=1;
   WHILE(j<i) LOOP
--   dbms_output.put_line('index name:'||l_index_name(j));
   BEGIN
   IF (j<i-1) and (l_index_name(j) =l_index_name(j+1)) THEN
    l_col_num :=l_col_num||l_ind_column_name(j)||',';
   ELSE
    l_col_num :=l_col_num||l_ind_column_name(j);

    IF (l_uniqueness(j) ='UNIQUE' ) THEN
        is_unique := l_uniqueness(j);
    ELSE is_unique:='';
    END IF;
    INSERT into bim_all_indexes (
       owner
      ,index_name
      ,table_name
      ,column_name
      ,index_tablespace
      ,pct_free
      ,ini_trans
      ,max_trans
      ,initial_extent
      ,next_extent
      ,min_extents
      ,max_extents
      ,pct_increase
      ,uniqueness)
      SELECT l_owner(j)
            ,l_index_name(j)
            ,l_index_table_name(j)
            ,l_col_num
            ,l_index_tablespace
            ,l_pct_free(j)
            ,l_ini_trans(j)
            ,l_max_trans(j)
            ,l_initial_extent(j)
            ,l_next_extent(j)
            ,l_min_extents(j)
            ,l_max_extents(j)
            ,l_pct_increase(j)
            ,is_unique
      FROM DUAL;
     l_col_num :='';
   END IF;
   --dbms_output.put_line('J:'||j);
   j := j + 1;
   EXCEPTION
   WHEN OTHERS THEN
   ams_utility_pvt.write_conc_log('error inserting into bim_all_index:'||sqlerrm(sqlcode));
   --dbms_output.put_line('error inserting'||sqlerrm(sqlcode));
   END;
 END LOOP;
 END IF;
EXCEPTION
   WHEN OTHERS THEN
   ams_utility_pvt.write_conc_log('error in procedure drop_index:'||sqlerrm(sqlcode));
END DROP_INDEX;

PROCEDURE CREATE_INDEX
    ( p_table_name             IN  VARCHAR2
    )
    IS
    l_user_id          	   	   NUMBER := FND_GLOBAL.USER_ID();
    l_sysdate          	  	   DATE   := SYSDATE;
    l_api_version_number       	   CONSTANT NUMBER       := 1.0;
    l_api_name                 	   CONSTANT VARCHAR2(30) := 'DROP_INDEX';
    l_count                        NUMBER;
    CURSOR get_all_index (p_name VARCHAR2) IS
    SELECT uniqueness
    ,owner
    ,index_name
    ,table_name
    ,index_tablespace
    ,column_name
    ,pct_free
    ,ini_trans
    ,max_trans
    ,initial_extent
    ,next_extent
    ,min_extents
    ,max_extents
    ,pct_increase
    FROM bim_all_indexes
    WHERE table_name =UPPER(p_name);

    CURSOR   index_count(p_name VARCHAR2) IS
    SELECT   count(*)
    FROM     bim_all_indexes
    WHERE    table_name =upper(p_name);
BEGIN
    OPEN index_count(p_table_name);
    FETCH index_count into l_count;
    CLOSE index_count;

    IF l_count>0 THEN
    FOR x in get_all_index(p_table_name) LOOP
    BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX '
    || x.owner
    || '.'
    || x.index_name
    ||' ON '
    || x.owner
    ||'.'
    || x.table_name
    || ' ('
    || x.column_name
    || ' )'
            || ' tablespace '  || x.index_tablespace
            || ' pctfree     ' || x.pct_free
            || ' initrans '    || x.ini_trans
            || ' maxtrans  '   || x.max_trans
            || ' storage ( '
            || ' initial '     || x.initial_extent
            || ' next '        || x.next_extent
            || ' minextents '  || x.min_extents
            || ' maxextents '  || x.max_extents
            || ' pctincrease ' || x.pct_increase
            || ')'
            || ' compute statistics';
            EXCEPTION
   WHEN OTHERS THEN
   ams_utility_pvt.write_conc_log('error create index'||sqlerrm(sqlcode));
   --dbms_output.put_line('error updateing minimum balance'||sqlerrm(sqlcode));
   END;
     END LOOP;
     DELETE bim_all_indexes where table_name =UPPER(p_table_name);
   END IF;
END CREATE_INDEX;

END BIM_UTL_PKG;

/
