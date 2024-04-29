--------------------------------------------------------
--  DDL for Package Body HZ_SEED_CLASS_CAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_SEED_CLASS_CAT_PKG" AS
/*$Header: ARHSECLB.pls 120.6 2005/12/22 00:03:49 kttang noship $*/
  PROCEDURE SEED_CLASS_CATEGORY
  (p_class   IN VARCHAR2,
   p_amaf    IN VARCHAR2,
   p_ampf    IN VARCHAR2,
   p_alnof   IN VARCHAR2,
   p_user_id IN NUMBER DEFAULT 0)
  IS
      CURSOR c1(l_schema IN VARCHAR2) IS
      SELECT 'Y'
        FROM sys.all_tab_columns
       WHERE table_name = 'HZ_CLASS_CATEGORIES'
         AND column_name = 'ALLOW_LEAF_NODE_ONLY_FLAG'
         AND owner = l_schema;

      lyn  VARCHAR2(1);
      no_data_found1  exception;
      no_data_found2  exception;

      CURSOR c2 (l_cat IN VARCHAR2) IS
      SELECT 'Y'
        FROM hz_class_categories
       WHERE class_category = l_cat;
      lyn2 VARCHAR2(1);

      l_str   VARCHAR2(2000);
      ph   INTEGER;
      rt   INTEGER;
      l_allow_maf   VARCHAR2(1);
      l_allow_mpf   VARCHAR2(1);
      l_allow_lnof  VARCHAR2(1);
      l_class_cat   VARCHAR2(30);
      l_bool BOOLEAN;
      l_status VARCHAR2(255);
      l_schema VARCHAR2(255);
      l_tmp    VARCHAR2(2000);

   BEGIN

        l_allow_maf  := p_amaf;
        l_allow_mpf  := p_ampf;
        l_allow_lnof := p_alnof;
        l_class_cat  := REPLACE(p_class,'''','''''');
        l_bool       := fnd_installation.GET_APP_INFO('AR',l_status,l_tmp,l_schema);

        OPEN c1(l_schema);
          fetch c1 INTO lyn;
          IF c1%NOTFOUND THEN
            lyn := 'N';
          END IF;
        CLOSE c1;

        OPEN c2(l_class_cat);
        FETCH c2 INTO lyn2;
        IF c2%NOTFOUND THEN
           lyn2 := 'N';
        END IF;
        CLOSE c2;


        IF lyn = 'Y' THEN
           IF lyn2 = 'Y' THEN

             l_str :=' update HZ_CLASS_CATEGORIES  set '||
                     ' ALLOW_MULTI_ASSIGN_FLAG = '''||l_allow_maf||''', '||
                     ' ALLOW_MULTI_PARENT_FLAG = '''||l_allow_mpf||''', '||
                     ' ALLOW_LEAF_NODE_ONLY_FLAG = '''||l_allow_lnof||''', '||
                     ' LAST_UPDATED_BY = '''||TO_CHAR(p_user_id)||''', '||
                     ' LAST_UPDATE_DATE = '''|| TO_CHAR(SYSDATE)||''', '||
                     ' LAST_UPDATE_LOGIN = 0 '||
                     ' where  CLASS_CATEGORY = '''||l_class_cat||'''';
           ELSE

             l_str :=' insert into HZ_CLASS_CATEGORIES( '||
                     ' CLASS_CATEGORY,  '||
                     ' ALLOW_MULTI_ASSIGN_FLAG, '||
                     ' ALLOW_MULTI_PARENT_FLAG, '||
                     ' ALLOW_LEAF_NODE_ONLY_FLAG, '||
                     ' DELIMITER, ' ||
                     ' FROZEN_FLAG, ' ||
                     ' LAST_UPDATED_BY, '||
                     ' LAST_UPDATE_DATE, '||
                     ' CREATED_BY, '||
                     ' CREATION_DATE, '||
                     ' LAST_UPDATE_LOGIN)  values ( '||
                     ' '''||l_class_cat||''', '||
                     ' '''||l_allow_maf||''', '||
                     ' '''||l_allow_mpf||''', '||
                     ' '''||l_allow_lnof||''', '||
                     ' ''/'','||
                     ' ''N'','||
                     ' '''||TO_CHAR(p_user_id)||''', '||
                     ' '''||TO_CHAR(sysdate)||''', '||
                     ' '''||TO_CHAR(p_user_id)||''', '||
                     ' '''||TO_CHAR(sysdate)||''', '||
                     ' 0) ';
           END IF;

         ELSE

           IF lyn2 = 'Y' THEN

            l_str := ' update HZ_CLASS_CATEGORIES  set '||
                     ' ALLOW_MULTI_ASSIGN_FLAG = '''||l_allow_maf||''', '||
                     ' ALLOW_MULTI_PARENT_FLAG = '''||l_allow_mpf||''', '||
                     ' LAST_UPDATED_BY = '''||TO_CHAR(p_user_id)||''', '||
                     ' LAST_UPDATE_DATE = '''|| TO_CHAR(SYSDATE)||''', '||
                     ' LAST_UPDATE_LOGIN = 0 '||
                     ' where  CLASS_CATEGORY = '''||l_class_cat||'''';
            ELSE

             l_str :=' insert into HZ_CLASS_CATEGORIES( '||
                     ' CLASS_CATEGORY,  '||
                     ' ALLOW_MULTI_ASSIGN_FLAG, '||
                     ' ALLOW_MULTI_PARENT_FLAG, '||
                     ' DELIMITER, ' ||
                     ' FROZEN_FLAG, ' ||
                     ' LAST_UPDATED_BY, '||
                     ' LAST_UPDATE_DATE, '||
                     ' CREATED_BY, '||
                     ' CREATION_DATE, '||
                     ' LAST_UPDATE_LOGIN)  values ( '||
                     ' '''||l_class_cat||''', '||
                     ' '''||l_allow_maf||''', '||
                     ' '''||l_allow_mpf||''', '||
                     ' ''/'','||
                     ' ''N'','||
                     ' '''||TO_CHAR(p_user_id)||''', '||
                     ' '''||TO_CHAR(sysdate)||''', '||
                     ' '''||TO_CHAR(p_user_id)||''', '||
                     ' '''||TO_CHAR(sysdate)||''', '||
                     ' 0) ';
            END IF;
          END IF;

          ph := dbms_sql.open_cursor;
          dbms_sql.parse(ph,l_str,dbms_sql.native);
          rt := dbms_sql.execute(ph);
          dbms_sql.close_cursor(ph);
  END;

  PROCEDURE SEED_CLASS_CATEGORY_USE
  (p_class       IN VARCHAR2,
   p_col_name    IN VARCHAR2,
   p_awc         IN VARCHAR2,
   p_owner_tab   IN VARCHAR2,
   p_user_id     IN NUMBER DEFAULT 0)
  IS
    CURSOR c1(l_schema IN VARCHAR2) IS
    SELECT 'Y'
      FROM sys.all_tab_columns
     WHERE table_name = 'HZ_CLASS_CATEGORY_USES'
       AND column_name = 'ADDITIONAL_WHERE_CLAUSE'
       AND owner = l_schema;

    TYPE refcur IS REF CURSOR;
    exist_cv  refcur;
    lyn2      VARCHAR2(1);
    lyn       VARCHAR2(1);
    l_str     VARCHAR2(4000);
    ph        INTEGER;
    rt        INTEGER;
    l_awc     VARCHAR2(2000);
    l_class   VARCHAR2(40);
    l_owner_tab VARCHAR2(30);
    l_col_name  VARCHAR2(30);
    l_bool BOOLEAN;
    l_status VARCHAR2(255);
    l_schema VARCHAR2(255);
    l_tmp    VARCHAR2(2000);

  BEGIN
     l_bool := fnd_installation.GET_APP_INFO('AR',l_status,l_tmp,l_schema);

     OPEN c1(l_schema);
     FETCH c1 INTO lyn;
     IF c1%NOTFOUND THEN
        lyn := 'N';
     END IF;
     CLOSE c1;

     IF lyn = 'Y' THEN

      l_awc := REPLACE(p_awc,'''','''''');
      l_owner_tab := REPLACE(p_owner_tab,'''','''''');
      l_col_name  := REPLACE(p_col_name,'''','''''');
      l_class     := REPLACE(p_class,'''','''''');

      OPEN exist_cv FOR
       'SELECT ''Y''  FROM HZ_CLASS_CATEGORY_USES
       WHERE owner_table = '''||l_owner_tab||''' AND '||
         ' class_category = '''||l_class||'''';
      FETCH exist_cv INTO lyn2;
      IF exist_cv%NOTFOUND THEN
        lyn2 := 'N';
      END IF;
      CLOSE exist_cv;

      IF lyn2 = 'Y' THEN
        l_str := ' UPDATE HZ_CLASS_CATEGORY_USES  SET COLUMN_NAME  = '''|| l_col_name ||''', '||
                 ' ADDITIONAL_WHERE_CLAUSE = '''||l_awc||''', '||
                 ' LAST_UPDATED_BY   =  '''||to_char(p_user_id)||''', '||
                 ' LAST_UPDATE_DATE  =  '''||to_char(SYSDATE)||''', '||
                 ' LAST_UPDATE_LOGIN = 0 '||
                 ' WHERE CLASS_CATEGORY = '''||l_class||''''||
                 ' AND OWNER_TABLE    = '''||l_owner_tab||'''';
      ELSE
        l_str := ' insert into HZ_CLASS_CATEGORY_USES( CLASS_CATEGORY, OWNER_TABLE, COLUMN_NAME, '||
                 ' ADDITIONAL_WHERE_CLAUSE, LAST_UPDATED_BY, LAST_UPDATE_DATE, CREATED_BY, '||
                 ' CREATION_DATE, LAST_UPDATE_LOGIN ) values ( '||
                 ''''||l_class||''','''||l_owner_tab||''','''||l_col_name||''','''||l_awc||''','||
                 ''''||TO_CHAR(p_user_id)||''','''||TO_CHAR(sysdate)||''','''||TO_CHAR(p_user_id)||''','||
                 ''''||TO_CHAR(sysdate)||''', 0)';
      END IF;

--      dbms_output.put_line(substr(l_str,1,255));
--      dbms_output.put_line(substr(l_str,256,255));

      ph := dbms_sql.open_cursor;
      dbms_sql.parse(ph,l_str,dbms_sql.native);
      rt := dbms_sql.execute(ph);
      dbms_sql.close_cursor(ph);

     END IF;
  END;
END;

/
