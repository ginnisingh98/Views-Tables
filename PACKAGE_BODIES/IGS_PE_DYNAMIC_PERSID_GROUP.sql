--------------------------------------------------------
--  DDL for Package Body IGS_PE_DYNAMIC_PERSID_GROUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_DYNAMIC_PERSID_GROUP" AS
/* $Header: IGSPEDGB.pls 120.1 2006/02/02 06:49:07 skpandey noship $ */

  -- Global Variables


  g_api_version 	CONSTANT NUMBER       := 1.0;
  g_api_name    	CONSTANT VARCHAR2(30) := 'igs_get_dynamic_sql';
  g_pkg_name		CONSTANT VARCHAR2(30) := 'igs_dynamic_perid_group';
  g_full_name   	CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| g_api_name;
  --g_msg_list		VARCHAR2     	      := FND_API.g_false;


/*==========================================================================+
 | Name: IGS_GET_DYNAMIC_SQL().                                             |
 |       Returns the SQL extracted from Discoverer.                         |
 |    04-DEC-2003  ssaleem     Dynamic Person id group Bug 3198795          |
 |                             handled order by clause in dynamic person    |
 |                             id group                                     |
 +==========================================================================*/

  FUNCTION IGS_GET_DYNAMIC_SQL(
     p_GroupID	IN     		igs_pe_persid_group_all.group_id%TYPE,
     p_Status	OUT NOCOPY 	VARCHAR2) RETURN VARCHAR2
  IS

     --local variables

    l_SQL 		VARCHAR2(32767);
    l_SQL_exp 		VARCHAR2(67);
    l_id		NUMBER(6);
    lv_parser           VARCHAR2(32767);
    lv_found            VARCHAR2(1);
    x_Count		NUMBER;
    x_Data		VARCHAR2(2000);

    CURSOR c_group_type IS
    SELECT group_type
    FROM IGS_PE_PERSID_GROUP_V
    WHERE group_id = p_GroupID;
    lv_group_type IGS_PE_PERSID_GROUP_V.group_type%TYPE;

    CURSOR c_Rec IS
    SELECT S.sql_segment
    FROM IGS_PE_PERSID_GROUP_ALL G, IGS_PE_DYN_SQLSEGS S
    WHERE G.group_id = p_GroupID
    AND G.file_name = S.file_name
    ORDER BY S.seg_sequence_num;


  BEGIN
    l_SQL := '';
    l_SQL_exp := 'SELECT 1 FROM DUAL';
    OPEN c_group_type;
    FETCH c_group_type INTO lv_group_type;
    CLOSE c_group_type;

    IF lv_group_type = 'STATIC' THEN
       l_SQL := 'SELECT person_id FROM igs_pe_prsid_grp_mem_all where TRUNC(SYSDATE) BETWEEN NVL(start_date,TRUNC(SYSDATE)) AND NVL(end_date,TRUNC(SYSDATE)) AND group_id = '||p_GroupID ;

    ELSIF lv_group_type = 'DYNAMIC' THEN
       FOR c_Disc IN c_REC LOOP
          l_SQL  := l_SQL || c_Disc.sql_segment;
       END LOOP;

       -- l_SQL := UPPER(rtrim(l_SQL)); Bug:3405360, asbala --commented this code
       lv_parser  := substr(l_SQL,(instr(l_SQL,'SELECT') + 6));
       lv_parser  := substr(lv_parser,1,(instr(lv_parser,'FROM') - 1));
       lv_parser  := trim(lv_parser);
       lv_parser  := lv_parser||',';

       WHILE lv_parser IS NOT NULL LOOP
         DECLARE
             lv_check VARCHAR2(100);
         BEGIN
             lv_check  := substr(lv_parser,1,(instr(lv_parser,',')-1));
             lv_parser := trim(substr(lv_parser,(instr(lv_parser,',')+1)));

             IF ((UPPER(lv_check) like '%PERSON_ID%') OR
                 (UPPER(lv_check) like '%PARTY_ID%')) THEN
                  l_SQL := 'SELECT '||lv_check||' PERSON_ID '||
                       substr(l_SQL,(instr(l_SQL,'FROM')));
                  lv_found := 'Y';
                  lv_parser := NULL;
              END IF;
         END;
       END LOOP;

       IF INSTR(l_SQL,' ORDER BY ') > 0 THEN
         l_SQL := SUBSTR(l_SQL,0,(INSTR(l_SQL,' ORDER BY ')));
       END IF;

       IF NVL(lv_found,'N') = 'N' THEN
              RAISE NO_DATA_FOUND;
       END IF;
    END IF;
    p_Status := FND_API.g_ret_sts_success;

    RETURN l_SQL;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      p_Status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, g_api_name);
      END IF;
      FND_MSG_PUB.count_and_get(
        p_encoded => FND_API.g_false,
        p_count   => x_Count,
        p_data    => x_Data
      );
      RETURN l_SQL_exp;
    WHEN FND_API.g_exc_error THEN
      p_Status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
        p_encoded => FND_API.g_false,
        p_count   => x_Count,
        p_data    => x_Data
      );
      RETURN l_SQL_exp;
    WHEN FND_API.g_exc_unexpected_error THEN
      p_Status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
        p_encoded => FND_API.g_false,
        p_count   => x_count,
        p_data    => x_data
      );
      RETURN l_SQL_exp;
  END IGS_GET_DYNAMIC_SQL;


FUNCTION GET_DYNAMIC_SQL(
     p_GroupID	IN     		igs_pe_persid_group_all.group_id%TYPE,
     p_Status	OUT NOCOPY 	VARCHAR2,
     p_group_type OUT NOCOPY    IGS_PE_PERSID_GROUP_V.group_type%TYPE) RETURN VARCHAR2
  IS

     --local variables

    l_SQL 		VARCHAR2(32767);
    l_SQL_exp 		VARCHAR2(67);
    l_id		NUMBER(6);
    lv_parser           VARCHAR2(32767);
    lv_found            VARCHAR2(1);
    x_Count		NUMBER;
    x_Data		VARCHAR2(2000);


    CURSOR c_group_type IS
    SELECT group_type
    FROM IGS_PE_PERSID_GROUP_V
    WHERE group_id = p_GroupID;
    lv_group_type IGS_PE_PERSID_GROUP_V.group_type%TYPE;

    CURSOR c_Rec IS
    SELECT S.sql_segment
    FROM IGS_PE_PERSID_GROUP_ALL G, IGS_PE_DYN_SQLSEGS S
    WHERE G.group_id = p_GroupID
    AND G.file_name = S.file_name
    ORDER BY S.seg_sequence_num;

  BEGIN
    l_SQL := '';
    l_SQL_exp := 'SELECT 1 FROM DUAL';

    OPEN c_group_type;
    FETCH c_group_type INTO lv_group_type;
    CLOSE c_group_type;

    IF lv_group_type = 'STATIC' THEN
       l_SQL := 'SELECT person_id FROM igs_pe_prsid_grp_mem_all where TRUNC(SYSDATE) BETWEEN NVL(start_date,TRUNC(SYSDATE)) AND NVL(end_date,TRUNC(SYSDATE)) AND group_id = :p_GroupID';

    ELSIF lv_group_type = 'DYNAMIC' THEN
       FOR c_Disc IN c_REC LOOP
          l_SQL  := l_SQL || c_Disc.sql_segment;
       END LOOP;

       lv_parser  := substr(l_SQL,(instr(l_SQL,'SELECT') + 6));
       lv_parser  := substr(lv_parser,1,(instr(lv_parser,'FROM') - 1));
       lv_parser  := trim(lv_parser);
       lv_parser  := lv_parser||',';

       WHILE lv_parser IS NOT NULL LOOP
         DECLARE
             lv_check VARCHAR2(100);
         BEGIN
             lv_check  := substr(lv_parser,1,(instr(lv_parser,',')-1));
             lv_parser := trim(substr(lv_parser,(instr(lv_parser,',')+1)));

             IF ((UPPER(lv_check) like '%PERSON_ID%') OR
                 (UPPER(lv_check) like '%PARTY_ID%')) THEN
                  l_SQL := 'SELECT '||lv_check||' PERSON_ID '||
                       substr(l_SQL,(instr(l_SQL,'FROM')));
                  lv_found := 'Y';
                  lv_parser := NULL;
              END IF;
         END;
       END LOOP;

       IF INSTR(l_SQL,' ORDER BY ') > 0 THEN
         l_SQL := SUBSTR(l_SQL,0,(INSTR(l_SQL,' ORDER BY ')));
       END IF;

       IF NVL(lv_found,'N') = 'N' THEN
              RAISE NO_DATA_FOUND;
       END IF;
    END IF;
    p_Status := FND_API.g_ret_sts_success;
    p_group_type := lv_group_type;
    RETURN l_SQL;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      p_Status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, g_api_name);
      END IF;
      FND_MSG_PUB.count_and_get(
        p_encoded => FND_API.g_false,
        p_count   => x_Count,
        p_data    => x_Data
      );
      RETURN l_SQL_exp;
    WHEN FND_API.g_exc_error THEN
      p_Status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
        p_encoded => FND_API.g_false,
        p_count   => x_Count,
        p_data    => x_Data
      );
      RETURN l_SQL_exp;
    WHEN FND_API.g_exc_unexpected_error THEN
      p_Status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
        p_encoded => FND_API.g_false,
        p_count   => x_count,
        p_data    => x_data
      );
      RETURN l_SQL_exp;
  END GET_DYNAMIC_SQL;


  FUNCTION DYN_PIG_MEMBER(p_GroupID  IN   NUMBER,
                       p_PersonID IN   NUMBER)
  RETURN NUMBER AS

     --local variables

    l_SQL               VARCHAR2(32767);
    l_length            NUMBER;
    l_id                NUMBER(6);
    lv_parser           VARCHAR2(32767);
    lv_found            VARCHAR2(1);

    TYPE c_person_id_grpCurTyp IS REF CURSOR ;
    c_person_id_grp c_person_id_grpCurTyp ;
    TYPE c_person_id_grp_recTyp IS RECORD
    (  person_id igs_pe_person_base_v.person_id%TYPE);
     c_person_id_grp_rec c_person_id_grp_recTyp ;

    CURSOR c_Rec IS
    SELECT S.sql_segment
    FROM IGS_PE_PERSID_GROUP_ALL G, IGS_PE_DYN_SQLSEGS S
    WHERE G.group_id = p_GroupID
    AND G.file_name = S.file_name
    ORDER BY S.seg_sequence_num;


  BEGIN
    l_SQL               := '';
    FOR c_Disc IN c_Rec LOOP
        l_SQL  := l_SQL || c_Disc.sql_segment;
    END LOOP;

    l_SQL :=  rtrim(l_SQL);
    lv_parser  := substr(l_SQL,(instr(l_SQL,'SELECT') + 6));
    lv_parser  := substr(lv_parser,1,(instr(lv_parser,'FROM') - 1));
    lv_parser  := trim(lv_parser);
    lv_parser  := lv_parser||',';

    WHILE lv_parser IS NOT NULL LOOP
      DECLARE
          lv_check VARCHAR2(100);
      BEGIN
          lv_check  := substr(lv_parser,1,(instr(lv_parser,',')-1));
          lv_parser := trim(substr(lv_parser,(instr(lv_parser,',')+1)));

          IF ((lv_check like '%PERSON_ID%') OR
              (lv_check like '%PARTY_ID%')) THEN
               l_SQL := 'SELECT '||lv_check||' PERSON_ID '||
                    substr(l_SQL,(instr(l_SQL,'FROM')));
               lv_found := 'Y';
               lv_parser := NULL;
           END IF;
      END;
    END LOOP;
    IF NVL(lv_found,'N') = 'N' THEN
           RAISE NO_DATA_FOUND;
    END IF;

--  skpandey, 02-FEB-2006, Bug#4937960: Changed cursor as a part of LITERAL fix
    OPEN c_person_id_grp  FOR 'SELECT person_id FROM ('||l_SQL||') WHERE person_id = :p_PersonID' USING p_PersonID;

    FETCH c_person_id_grp INTO c_person_id_grp_rec;
    IF  c_person_id_grp%NOTFOUND THEN
       CLOSE c_person_id_grp;
       RETURN  NULL;
    ELSE
       CLOSE c_person_id_grp;
       RETURN p_PersonID;
    END IF;


  EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS' , 'DYN_PIG_MEMBER');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception ;

  END DYN_PIG_MEMBER;

/*==========================================================================+
 | Name:  IGS_Post_Save_Document().                                         |
 |        To enable automatic extraction of SQL, Oracle Discoverer has      |
 |        enabled a trigger that gets fired whenever a Workbook is          |
 |        saved.  The "trigger" looks for a PL/SQL function which is        |
 |        mapped to this function and then does the necessary data          |
 |        insertion.                                                        |
 +==========================================================================*/

  FUNCTION IGS_POST_SAVE_DOCUMENT(p_WorkBookOwner IN VARCHAR2,
                                  p_WorkBookName  IN VARCHAR2,
                                  p_WorkSheetName IN VARCHAR2,
                                  p_Sequence      IN NUMBER,
                                  p_SQLSegment    IN VARCHAR2)
  RETURN NUMBER IS

    -- local variables
    l_sqlerrm 	       VARCHAR2(600);
    l_sqlcode          VARCHAR2(100);
    l_sequence_id      NUMBER(6);
    l_creator_id       NUMBER(15);
    l_temp_str	       VARCHAR2(200);
    l_num              NUMBER;

    l_insert	       BOOLEAN;
    l_sqltxt	       VARCHAR2(32767);

    CURSOR c_dyn_sql IS
    SELECT 1
    FROM IGS_PE_DYN_SQLSEGS
    WHERE file_name = UPPER(p_WorkBookName)||':'||UPPER(p_WorkSheetName);

    CURSOR c_prev_seg IS
    SELECT 1
    FROM IGS_PE_DYN_SQLSEGS
    WHERE file_name = UPPER(p_WorkBookName)||':'||UPPER(p_WorkSheetName)
    AND seg_sequence_num=1;


  BEGIN
    l_sqltxt	       := '';
    l_temp_str := substr(p_WorkBookOwner, 2);
    l_creator_id := to_number(l_temp_str);


    IF (AMS_DISCOVERER_PVT.EUL_TRIGGER$POST_SAVE_DOCUMENT(p_WorkBookOwner,
      p_WorkBookName, p_WorkSheetName, p_Sequence, p_SQLSegment) = 0) THEN

      l_insert := FALSE;
      --check for an existing set of workbook entries
      if (p_Sequence < 2) then
         OPEN c_dyn_sql;
         FETCH c_dyn_sql INTO l_num;
         IF(c_dyn_sql%FOUND) THEN
             DELETE from IGS_PE_DYN_SQLSEGS
             WHERE file_name = UPPER(p_WorkBookName)||':'
                               ||UPPER(p_WorkSheetName);
         END IF;
         CLOSE c_dyn_sql;

         l_sqltxt := UPPER(p_SQLSegment);
         IF INSTR(l_sqltxt, '.PARTY_ID') > 0 OR
            INSTR(l_sqltxt, '.PERSON_ID') > 0
         THEN
            l_insert := TRUE;
         END IF;
      else  /* Continuing segments */
         OPEN c_prev_seg;
         FETCH c_prev_seg INTO l_num;
         IF (c_prev_seg%FOUND) THEN
            l_insert := TRUE;
         ELSE
            l_insert := FALSE;
         END IF;
         CLOSE c_prev_seg;
      end if;

      IF l_insert = TRUE THEN
         l_sqltxt := replace(p_SQLSegment,fnd_global.local_chr(10),' ');
         INSERT INTO IGS_PE_DYN_SQLSEGS (
            SQLSEGS_ID,
            FILE_NAME,
            SEG_SEQUENCE_NUM,
            SQL_SEGMENT,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE
          )
	  VALUES (
  	    IGS_PE_DYN_SQLSEGS_S.nextval,
            UPPER(p_WorkBookName)||':'||UPPER(p_WorkSheetName),
  	    p_Sequence,
  	    l_sqltxt,
  	    l_creator_id,
  	    SYSDATE,
  	    l_creator_id,
  	    SYSDATE
          );
       END IF;

    ELSE
      RETURN(1);
    END IF;


  RETURN(0);


  EXCEPTION
    WHEN OTHERS THEN
      l_sqlerrm := SQLERRM;
      l_sqlcode := SQLCODE;
      RETURN (1) ;

  END IGS_POST_SAVE_DOCUMENT;

/*==========================================================================+
 | Name: GET_DYNAMIC_SQL_FROM_FILE().                                             |
 |       Returns the SQL extracted from Discoverer.                         |
 +==========================================================================*/

  FUNCTION GET_DYNAMIC_SQL_FROM_FILE(
     p_FileName	IN     		IGS_PE_DYN_SQLSEGS.file_name%TYPE,
     p_Status	OUT NOCOPY 	VARCHAR2) RETURN VARCHAR2
  IS

     --local variables

    l_SQL 		VARCHAR2(32767);
    l_SQL_exp 		VARCHAR2(67);
    l_id		NUMBER(6);
    lv_parser           VARCHAR2(32767);
    lv_found            VARCHAR2(1);
    x_Count		NUMBER;
    x_Data		VARCHAR2(2000);

    CURSOR c_Rec (cp_FileName IGS_PE_DYN_SQLSEGS.file_name%TYPE) IS
    SELECT S.sql_segment
    FROM IGS_PE_DYN_SQLSEGS S
    WHERE S.file_name = cp_FileName
    ORDER BY S.seg_sequence_num;

  BEGIN
       l_SQL 		         := '';
       l_SQL_exp 		 := 'SELECT 1 FROM DUAL';
       FOR c_Disc IN c_REC(p_FileName) LOOP
          l_SQL  := l_SQL || c_Disc.sql_segment;
       END LOOP;

       lv_parser  := substr(l_SQL,(instr(l_SQL,'SELECT') + 6));
       lv_parser  := substr(lv_parser,1,(instr(lv_parser,'FROM') - 1));
       lv_parser  := trim(lv_parser);
       lv_parser  := lv_parser||',';

       WHILE lv_parser IS NOT NULL LOOP
         DECLARE
             lv_check VARCHAR2(100);
         BEGIN
             lv_check  := substr(lv_parser,1,(instr(lv_parser,',')-1));
             lv_parser := trim(substr(lv_parser,(instr(lv_parser,',')+1)));

             IF ((UPPER(lv_check) like '%PERSON_ID%') OR
                 (UPPER(lv_check) like '%PARTY_ID%')) THEN
                  l_SQL := 'SELECT '||lv_check||' PERSON_ID '||
                       substr(l_SQL,(instr(l_SQL,'FROM')));
                  lv_found := 'Y';
                  lv_parser := NULL;
              END IF;
         END;
       END LOOP;

       IF INSTR(l_SQL,' ORDER BY ') > 0 THEN
         l_SQL := SUBSTR(l_SQL,0,(INSTR(l_SQL,' ORDER BY ')));
       END IF;

       IF NVL(lv_found,'N') = 'N' THEN
              RAISE NO_DATA_FOUND;
       END IF;

    p_Status := FND_API.g_ret_sts_success;

    RETURN l_SQL;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      p_Status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, g_api_name);
      END IF;
      FND_MSG_PUB.count_and_get(
        p_encoded => FND_API.g_false,
        p_count   => x_Count,
        p_data    => x_Data
      );
      RETURN l_SQL_exp;
    WHEN FND_API.g_exc_error THEN
      p_Status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
        p_encoded => FND_API.g_false,
        p_count   => x_Count,
        p_data    => x_Data
      );
      RETURN l_SQL_exp;
    WHEN FND_API.g_exc_unexpected_error THEN
      p_Status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
        p_encoded => FND_API.g_false,
        p_count   => x_count,
        p_data    => x_data
      );
      RETURN l_SQL_exp;
  END GET_DYNAMIC_SQL_FROM_FILE;

END IGS_PE_DYNAMIC_PERSID_GROUP;

/
