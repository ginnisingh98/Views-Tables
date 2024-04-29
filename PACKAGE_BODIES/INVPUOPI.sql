--------------------------------------------------------
--  DDL for Package Body INVPUOPI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVPUOPI" AS
/* $Header: INVPUP1B.pls 120.7.12010000.3 2009/10/08 05:09:37 vggarg ship $ */

l_application_id number(10) :=   401;
l_id_flex_code varchar2(4) := 'MSTK';
l_enabled_flag varchar2(1) := 'Y';
l_id_flex_num  number(15)  := 101;

/*
** Parse the input item number,  assign segment values
** into  SEGMENT  columns  in MTL_SYSTEM_ITEMS_INTERFACE
*/
---Start: Bug Fix 3051653
G_SEGMENT_DELIMITER VARCHAR2(10)  := NULL;
G_SEGMENTS_INUSE    NUMBER(10)     := NULL;
G_SEGMENT_STRING    VARCHAR2(500) := NULL;
G_DYNAMIC_UPDATE    VARCHAR2(1000):= NULL;
--Start  Bug: 4654433
G_NUM_OF_SEGMENTS   NUMBER   := NULL;
TYPE G_SEGMENTS_USED_TYPE IS TABLE OF NUMBER
INDEX BY PLS_INTEGER;
G_SEGMENTS_USED       G_SEGMENTS_USED_TYPE;
G_SEGMENT_NUMS_USED G_SEGMENTS_USED_TYPE;
G_MIN_SEGMENT       FND_ID_FLEX_SEGMENTS.application_column_name%TYPE;
G_MIN_SEG_NUM       NUMBER;
G_CHECK_SEG_NUM     NUMBER;
--End Bug: 4654433

FUNCTION mtl_pr_parse_item_segments
(p_row_id      in      rowid
,item_number   out    NOCOPY VARCHAR2
,item_id       out    NOCOPY NUMBER
,err_text      out    NOCOPY varchar2
) RETURN INTEGER IS

   l_segment_name VARCHAR2(500);

BEGIN


   IF G_SEGMENT_STRING IS NULL THEN
      FOR i in G_SEGMENT_NUMS_USED.FIRST..G_SEGMENT_NUMS_USED.LAST LOOP
    BEGIN
       SELECT FS.application_column_name
       INTO   l_segment_name
       FROM   FND_ID_FLEX_SEGMENTS  FS
       WHERE  FS.SEGMENT_NUM    = G_SEGMENT_NUMS_USED(i)
       AND     FS.ID_FLEX_CODE   = l_id_flex_code
       AND     FS.ID_FLEX_NUM    = l_id_flex_num
       AND     FS.ENABLED_FLAG   = l_enabled_flag
       AND     FS.APPLICATION_ID = l_application_id;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
          l_segment_name := NULL;
       WHEN OTHERS   THEN
          raise_application_error(-20001, SQLERRM);
    END;

    IF l_segment_name IS NOT NULL THEN
       IF G_SEGMENT_STRING IS NULL  THEN
          G_SEGMENT_STRING := l_segment_name;
       ELSE
          G_SEGMENT_STRING := G_SEGMENT_STRING||'||'''||G_SEGMENT_DELIMITER||'''||'||l_segment_name;
       END  IF;
    END IF;
      END LOOP;
   END IF;


   IF G_DYNAMIC_UPDATE IS NULL THEN

      G_DYNAMIC_UPDATE := ' UPDATE mtl_system_items_interface'||
           ' SET     item_number = '||G_SEGMENT_STRING||
           ' WHERE ROWID   = :p_row_id '||
           ' RETURNING inventory_item_id, item_number INTO :item_id, :item_number';
   END IF;

   EXECUTE IMMEDIATE G_DYNAMIC_UPDATE
   USING p_row_id, OUT item_id,  OUT item_number;


   RETURN 0;

EXCEPTION
   WHEN  OTHERS THEN
      err_text := substr('INVPUOPI.parse_item:' || SQLERRM ,1, 240);
      return(SQLCODE);
END mtl_pr_parse_item_segments;
---End:  Bug Fix  3051653

--Start  :New overloaded   procedure mtl_pr_parse_item_number
PROCEDURE mtl_pr_parse_item_number(
   p_item_number     IN    VARCHAR2
  ,p_segment1       OUT NOCOPY   VARCHAR2
  ,p_segment2       OUT NOCOPY   VARCHAR2
  ,p_segment3       OUT NOCOPY   VARCHAR2
  ,p_segment4       OUT NOCOPY   VARCHAR2
  ,p_segment5       OUT NOCOPY   VARCHAR2
  ,p_segment6       OUT NOCOPY   VARCHAR2
  ,p_segment7       OUT NOCOPY   VARCHAR2
  ,p_segment8       OUT NOCOPY   VARCHAR2
  ,p_segment9       OUT NOCOPY   VARCHAR2
  ,p_segment10      OUT NOCOPY   VARCHAR2
  ,p_segment11      OUT NOCOPY   VARCHAR2
  ,p_segment12      OUT NOCOPY   VARCHAR2
  ,p_segment13      OUT NOCOPY   VARCHAR2
  ,p_segment14      OUT NOCOPY   VARCHAR2
  ,p_segment15      OUT NOCOPY   VARCHAR2
  ,p_segment16      OUT NOCOPY   VARCHAR2
  ,p_segment17      OUT NOCOPY   VARCHAR2
  ,p_segment18      OUT NOCOPY   VARCHAR2
  ,p_segment19      OUT NOCOPY   VARCHAR2
  ,p_segment20      OUT NOCOPY   VARCHAR2
  ,x_err_text       OUT NOCOPY   VARCHAR2) IS

      type segvalueType is table of varchar2(40)   index by binary_integer;
      type tmpvalueType is table of varchar2(40)   index by binary_integer;
      seg_value         segvalueType;
      tmp_value         tmpvalueType;
      segment_name    varchar2(30);
      segment_num     varchar2(30);
      return_status   number;
      pos         number;
      ind         number;
      l_count_slash   number;

   BEGIN



      x_err_text := NULL;

      for n in 1..20 loop
    seg_value(n) := NULL;
    tmp_value(n) := NULL;
      end loop;

      return_status := 1;
      pos := 1;
      ind := 1;
      while (return_status > 0 AND ind < G_SEGMENTS_INUSE) loop
    return_status := INSTR(p_item_number,G_SEGMENT_DELIMITER,pos);

    if (return_status > 0) then
       tmp_value(ind) := substr(p_item_number,pos,return_status - pos);
       pos        := return_status + length(G_SEGMENT_DELIMITER);
       ind        := ind +1;
    end if;
      end loop;
      tmp_value(ind) := substr(p_item_number,pos);

      --Start :3632767 Code to suport \. in item number
      --tmp_value contains values from item number seperated at   deliminator
      --Ex: Item Number : A.B then tmp_value(1)=A and tmp_value(2)=B this seperation is   done by  above code.
      --We need   to check if each string in tmp_value ends with odd number of \'s then
      --append this with value with next row and move all the remaining rows by  one up.
      --Ex :tmp_value(1) = A\\\  tmp_value(2) = B tmp_value(3) =  C
      --Then tmp_value(1) = A\\\.B tmp_value(2) = C tmp_value(3) = tmp_value(4)..and so   on.

      FOR i IN 1..(tmp_value.COUNT-1) LOOP
    pos :=  i+1;
    WHILE   tmp_value(i) IS   NOT NULL
       AND  tmp_value(pos) IS NOT NULL
       AND  (INSTR(tmp_value(i),'\',-1) = LENGTH(tmp_value(i)))
    LOOP

       l_count_slash := 0;
       FOR  j IN REVERSE 1..LENGTH(tmp_value(i)) LOOP
          IF SUBSTR(tmp_value(i),J,1) = '\' THEN
        l_count_slash   := l_count_slash + 1;
          ELSE
        EXIT;
          END IF;
       END  LOOP;

       IF MOD(l_count_slash,2) <>0  THEN
          IF G_SEGMENTS_INUSE = 1 THEN
        tmp_value(i) := tmp_value(i) ||G_SEGMENT_DELIMITER|| tmp_value(pos);
          ELSE
        tmp_value(i) := SUBSTR(tmp_value(i),1,LENGTH(tmp_value(i))-1)   ||G_SEGMENT_DELIMITER|| tmp_value(pos);
          END IF;
          FOR j in   (i+1)..tmp_value.COUNT-1 LOOP
        tmp_value(j) := tmp_value(j+1);
          END LOOP;
       ELSE
          EXIT;
       END  IF; --MOD(l_count_slash,2) <>0

    END LOOP;
      END LOOP;

      --Remove the escape character \
      FOR i IN 1..tmp_value.COUNT LOOP
    tmp_value(i) := REPLACE(tmp_value(i),'\\','\');
      END LOOP;
      --End :3632767 Code to suport \. in item number
      --Bug: 4654433
      pos :=   1 ;
      FOR n in G_SEGMENTS_USED.FIRST..G_SEGMENTS_USED.LAST LOOP
    seg_value(G_SEGMENTS_USED(n)) := tmp_value(pos);
    pos :=  pos + 1  ;
     END LOOP;

     --Start :3632767 Code to suport \.   in item  number
    -- Bug: 5160315 Changing value of ind so that remaining segments are
    --                         stored in last enabled segment
     ind := G_SEGMENTS_USED(G_SEGMENTS_USED.LAST);
     FOR i IN pos ..tmp_value.count LOOP
        IF tmp_value(i)   IS NOT NULL THEN
           seg_value(ind) := seg_value(ind) ||G_SEGMENT_DELIMITER||tmp_value(i);
        END IF;
     END LOOP;
     --End :3632767 Code to suport \. in item number

     p_segment1    := seg_value(1);
     p_segment2    := seg_value(2);
     p_segment3    := seg_value(3);
     p_segment4    := seg_value(4);
     p_segment5    := seg_value(5);
     p_segment6    := seg_value(6);
     p_segment7    := seg_value(7);
     p_segment8    := seg_value(8);
     p_segment9    := seg_value(9);
     p_segment10 := seg_value(10);
     p_segment11 := seg_value(11);
     p_segment12 := seg_value(12);
     p_segment13 := seg_value(13);
     p_segment14 := seg_value(14);
     p_segment15 := seg_value(15);
     p_segment16 := seg_value(16);
     p_segment17 := seg_value(17);
     p_segment18 := seg_value(18);
     p_segment19 := seg_value(19);
     p_segment20 := seg_value(20);
     x_err_text   := NULL;
   EXCEPTION
      WHEN OTHERS THEN
   x_err_text := substr('INVPUOPI.parse_item:' || SQLERRM ,1, 240);
   END mtl_pr_parse_item_number;
--End :New overloaded procedure  mtl_pr_parse_item_number

FUNCTION mtl_pr_parse_item_number
(
item_number varchar2,
item_id     number,
trans_id number,
org_id      number,
err_text out   NOCOPY varchar2,
p_rowid     rowid
)
RETURN INTEGER
IS
   type segvalueType is table of varchar2(40)
      index by binary_integer;
   type tmpvalueType is table of varchar2(40)
      index by binary_integer;
   seg_value   segvalueType;
   tmp_value   tmpvalueType;
   delimiter   varchar2(10);
   segvalue_tmp   varchar2(40);
   segment_name   varchar2(30);
   segment_num varchar2(30);
   max_segment number;
   return_status  number;
   pos      number;
   ind      number;
   l_count_slash  number;
BEGIN
   err_text := NULL;

/*
** initialize table values
*/
   for n in 1..20 loop
      seg_value(n) :=   NULL;
      tmp_value(n) :=   NULL;
   end loop;

/*
** get the delimeter and max_segment
*/
       --Bug: 4654433
       delimiter := G_SEGMENT_DELIMITER;
       max_segment := G_SEGMENTS_INUSE;
/*
** seperate input name into segments
*/
   return_status := 1;
   pos := 1;
   ind := 1;
   while (return_status > 0 AND ind < max_segment) loop
      return_status := INSTR(item_number,delimiter,pos);
      if (return_status > 0) then
         tmp_value(ind) := substr(item_number,pos,
            return_status -   pos);
         pos := return_status + length(delimiter);
         ind := ind +1;
      end if;

   end loop;
   tmp_value(ind) := substr(item_number,pos);

   --Start  :3632767 Code to suport \. in item number
   --tmp_value contains values from item number seperated at deliminator
   --Ex: Item Number : A.B then tmp_value(1)=A and tmp_value(2)=B this seperation is done by above code.
   --We need to check if each string in tmp_value ends with odd number of \'s then
   --append this with value with next row and move all the  remaining rows by one up.
   --Ex :tmp_value(1) = A\\\ tmp_value(2) = B tmp_value(3)  = C
   --Then tmp_value(1) = A\\\.B tmp_value(2) = C tmp_value(3) = tmp_value(4)..and so on.

   FOR i IN 1..(tmp_value.COUNT-1)  LOOP
      pos := i+1;

      WHILE tmp_value(i) IS NOT NULL
         AND tmp_value(pos) IS NOT  NULL
         AND (INSTR(tmp_value(i),'\',-1) =   LENGTH(tmp_value(i)))
      LOOP

         l_count_slash := 0;
         FOR j IN REVERSE 1..LENGTH(tmp_value(i)) LOOP
       IF SUBSTR(tmp_value(i),J,1) = '\' THEN
          l_count_slash := l_count_slash + 1;
       ELSE
          EXIT;
       END IF;
         END LOOP;

         IF MOD(l_count_slash,2) <>0 THEN
       IF G_SEGMENTS_INUSE = 1 THEN
          tmp_value(i) := tmp_value(i) ||G_SEGMENT_DELIMITER|| tmp_value(pos);
       ELSE
          tmp_value(i) := SUBSTR(tmp_value(i),1,LENGTH(tmp_value(i))-1) ||G_SEGMENT_DELIMITER|| tmp_value(pos);
       END IF;
       FOR j in (i+1)..tmp_value.COUNT-1 LOOP
          tmp_value(j) := tmp_value(j+1);
       END LOOP;
         ELSE
      EXIT;
         END IF;
      END LOOP;
   END LOOP;

   FOR i IN 1..tmp_value.COUNT LOOP
      tmp_value(i)   := REPLACE(tmp_value(i),'\\','\');
   END LOOP;
   --End :3632767 Code to suport \. in item number

/*
** assign the seperated segments into proper SEGMENT columns
** commented below  seg_value(ind) := tmp_value(n);
** If 1st enabled segment is say SEGMENT10 with SEGMENT  NUM 15
** and item number like '06231'
** Below logic would fail , as the while loop above will store
** '06231' in tmp_value(1) and above commented st. would look for
** a value in tmp_value(15).
*/
   --Bug: 4654433
   pos :=    1 ;
   for n in G_SEGMENTS_USED.FIRST..G_SEGMENTS_USED.LAST loop
        seg_value(G_SEGMENTS_USED(n)) := tmp_value(pos);
        pos := pos   + 1 ;
   end loop;

   --Start  :3632767 Code to suport \. in item number
   -- Bug: 5160315 Changing value of ind so that remaining segments are
   --                         stored in last enabled segment
   ind := G_SEGMENTS_USED(G_SEGMENTS_USED.LAST);
   FOR i IN pos ..tmp_value.count LOOP
      IF tmp_value(i) IS NOT NULL THEN
         seg_value(ind) := seg_value(ind) ||delimiter||tmp_value(i);
      END IF;
   END LOOP;
   --End :3632767 Code to suport \. in item number

/*
** update segment values in MTL_SYSTEM_ITEMS_INTERFACE
*/
   update MTL_SYSTEM_ITEMS_INTERFACE
   set segment1 = DECODE(seg_value(1),NULL,segment1,seg_value(1)),
   segment2 = DECODE(seg_value(2),NULL,segment2,seg_value(2)),
   segment3 = DECODE(seg_value(3),NULL,segment3,seg_value(3)),
   segment4 = DECODE(seg_value(4),NULL,segment4,seg_value(4)),
   segment5 = DECODE(seg_value(5),NULL,segment5,seg_value(5)),
   segment6 = DECODE(seg_value(6),NULL,segment6,seg_value(6)),
   segment7 = DECODE(seg_value(7),NULL,segment7,seg_value(7)),
   segment8 = DECODE(seg_value(8),NULL,segment8,seg_value(8)),
   segment9 = DECODE(seg_value(9),NULL,segment9,seg_value(9)),
   segment10 = DECODE(seg_value(10),NULL,segment10,seg_value(10)),
   segment11 = DECODE(seg_value(11),NULL,segment11,seg_value(11)),
   segment12 = DECODE(seg_value(12),NULL,segment12,seg_value(12)),
   segment13 = DECODE(seg_value(13),NULL,segment13,seg_value(13)),
   segment14 = DECODE(seg_value(14),NULL,segment14,seg_value(14)),
   segment15 = DECODE(seg_value(15),NULL,segment15,seg_value(15)),
   segment16 = DECODE(seg_value(16),NULL,segment16,seg_value(16)),
   segment17 = DECODE(seg_value(17),NULL,segment17,seg_value(17)),
   segment18 = DECODE(seg_value(18),NULL,segment18,seg_value(18)),
   segment19 = DECODE(seg_value(19),NULL,segment19,seg_value(19)),
   segment20 = DECODE(seg_value(20),NULL,segment20,seg_value(20))
   Where     rowid   = p_rowid ;
/*08/18/97 where transaction_id  = trans_id; */
      /*  and  organization_id   = org_id;   */

      /*SETID logic probably not needed   here*/

    RETURN (0);

EXCEPTION

   WHEN OTHERS THEN
       err_text :=   substr('INVPUOPI.parse_item:' || SQLERRM ,1, 240);
       return(SQLCODE);

END mtl_pr_parse_item_number;

/*
** Parse flex name with the flex code, return the flex id
*/

FUNCTION mtl_pr_parse_flex_name
(
org_id      number,
flex_code   varchar2,
flex_name   varchar2,
flex_id  in out   NOCOPY number,
set_id      number,
err_text out   NOCOPY varchar2,
structure_id number default -1 /*Fix for bug 8288281*/
)
RETURN INTEGER
IS
   type segvalueType is table of varchar2(40)
      index by binary_integer;
   type tmpvalueType is table of varchar2(40)
      index by binary_integer;
   seg_value   segvalueType;
   tmp_value   tmpvalueType;
   delimiter   varchar2(10);
   segvalue_tmp   varchar2(40);
   segment_name   varchar2(30);
   segment_num varchar2(30);
   max_segment number;
   return_status  number;
   ret_code number;
   statement_num  number;
   struct_id   number;
   pos      number;
   ind      number;
   l_count_slash  number;

   l_inv_debug_level NUMBER := INVPUTLI.get_debug_level;  --Bug: 4667452
BEGIN

   err_text := NULL;
   statement_num := 1;

   /* get the structure first */
   if flex_code = 'MCAT' then
      select structure_id
      into struct_id
      from mtl_category_sets_b
      where category_set_id = set_id;
   else
      struct_id := 101;
   end if;

   /* Search for the item id at production   item table */
   if flex_code = 'MSTK' then
      statement_num := 2;
      ret_code := INVPUOPI.mtl_pr_trans_prod_item (
         flex_name,
         org_id,
         flex_id,
         err_text);
      if (ret_code <=   0 ) then
--11/05/97  if (ret_code < 0 ) then
          return(ret_code);
      end if;
   end if;

   /* We are going   to search the interface table now */
   /* init  table values */
   for n in 1..20 loop
      seg_value(n) :=   NULL;
      tmp_value(n) :=   NULL;
   end loop;

   /* get the delimeter and max_segment */
   --Bug: 4654433
   /*Changes done for bug 8288281. Here the delimiter and the num of segments of the flexflield should be retrieved for the
   flex code being passed and shouldnt be hard coded from System Items flexfield*/
   IF structure_id = -1 THEN
	   statement_num := 3;
	   delimiter := G_SEGMENT_DELIMITER;

	   statement_num := 4;
	   max_segment := G_SEGMENTS_INUSE;
   ELSE

	 statement_num := 3.1;

	 SELECT FT.concatenated_segment_delimiter
	   INTO delimiter
	   FROM  fnd_id_flex_structures FT
	   WHERE FT.id_flex_code = flex_code
	     AND FT.APPLICATION_ID = l_application_id
	     AND FT.ID_FLEX_NUM = structure_id;

	     statement_num := 4.1;

	   SELECT  max(FS.segment_num)
	   INTO max_segment
	   FROM  FND_ID_FLEX_SEGMENTS FS
	   WHERE FS.APPLICATION_ID = l_application_id
	     AND FS.id_flex_code = flex_code
	     AND FS.ENABLED_FLAG = 'Y'
	     AND FS.id_flex_num = structure_id;

   END IF;
   /*End of changes*/

   /* seperate input name into segments */
   pos := 1;
   ind := 1;
   return_status := 1;
   statement_num := 5;
   while (return_status > 0 AND ind < max_segment) loop
      return_status := INSTR(flex_name,delimiter,pos);
      if (return_status > 0) then
         tmp_value(ind) := substr(flex_name,pos,
            return_status -   pos);
         pos := return_status + length(delimiter);
         ind := ind +1;
      end if;
   end loop;
   tmp_value(ind) := substr(flex_name,pos);

   --Start  :3632767 Code to suport \. in item number
   --tmp_value contains values from item number seperated at deliminator
   --Ex: Item Number : A.B then tmp_value(1)=A and tmp_value(2)=B this seperation is done by above code.
   --We need to check if each string in tmp_value ends with odd number of \'s then
   --append this with value with next row and move all the  remaining rows by one up.
   --Ex :tmp_value(1) = A\\\ tmp_value(2) = B tmp_value(3)  = C
   --Then tmp_value(1) = A\\\.B tmp_value(2) = C tmp_value(3) = tmp_value(4)..and so on.

   IF flex_code = 'MSTK' THEN
      FOR i IN 1..(tmp_value.COUNT-1) LOOP
         pos := i+1;

         WHILE tmp_value(i) IS NOT  NULL
         AND tmp_value(pos) IS NOT  NULL
         AND (INSTR(tmp_value(i),'\',-1) =   LENGTH(tmp_value(i)))
         LOOP

       l_count_slash := 0;
       FOR j IN  REVERSE 1..LENGTH(tmp_value(i)) LOOP
          IF SUBSTR(tmp_value(i),J,1)  = '\' THEN
             l_count_slash := l_count_slash +   1;
          ELSE
             EXIT;
          END  IF;
       END LOOP;

       IF MOD(l_count_slash,2) <>0 THEN
          IF G_SEGMENTS_INUSE = 1 THEN
             tmp_value(i) := tmp_value(i) ||G_SEGMENT_DELIMITER|| tmp_value(pos);
          ELSE
             tmp_value(i) := SUBSTR(tmp_value(i),1,LENGTH(tmp_value(i))-1) ||G_SEGMENT_DELIMITER|| tmp_value(pos);
          END  IF;
          FOR  j in (i+1)..tmp_value.COUNT-1 LOOP
             tmp_value(j) := tmp_value(j+1);
          END  LOOP;
       ELSE
         EXIT;
       END IF;
         END LOOP;
      END LOOP;

      FOR i IN 1..tmp_value.COUNT LOOP
         tmp_value(i) := REPLACE(tmp_value(i),'\\','\');
      END LOOP;
   END IF;
   --End :3632767 Code to suport \. in item number

   /* assign the seperated segments into proper SEGMENT columns */
   --Bug: 4654433
   statement_num := 6;
   /* Bug 8613428 added If condition to reinitialize G_SEGMENTS_USED with category KFF values.
     Earlier it had system Items KFF values. */
 IF structure_id = -1 THEN
   pos := 1  ;
   for n in G_SEGMENTS_USED.FIRST..G_SEGMENTS_USED.LAST loop
        seg_value(G_SEGMENTS_USED(n)) := tmp_value(pos);
        pos := pos   + 1;
   end loop;
 ELSE
	SELECT to_number(substr(application_column_name,8)), segment_num BULK COLLECT INTO
	G_SEGMENTS_USED, G_SEGMENT_NUMS_USED
	FROM  FND_ID_FLEX_SEGMENTS
	WHERE APPLICATION_ID = l_application_id
	AND id_flex_code = flex_code
	AND ENABLED_FLAG = 'Y'
	AND id_flex_num = structure_id
	ORDER BY segment_num;

     pos := 1  ;
   for n in G_SEGMENTS_USED.FIRST..G_SEGMENTS_USED.LAST loop
        seg_value(G_SEGMENTS_USED(n)) := tmp_value(pos);
        pos := pos   + 1;
   end loop;
 END IF;

   --Start  :3632767 Code to suport \. in item number
   IF flex_code = 'MSTK' THEN
      FOR i IN pos   ..tmp_value.count LOOP
         IF tmp_value(i) IS NOT NULL THEN
       seg_value(ind)   := seg_value(ind) ||delimiter||tmp_value(i);
         END IF;
      END LOOP;
   END IF;
   --End :3632767 Code to suport \. in item number

   /* search for the matched segment values record */

   /*
   ** since we do not support dynamic SQL at this moment, so
   ** we search for different table, based   on the flex code
   */

   statement_num := 7;

   if flex_code = 'MSTK' then
      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('INVPUP1.mtl_pr_parse_flex_name :verifying in MSII table' ||flex_name);
      END IF;

      select INVENTORY_ITEM_ID
      into flex_id
      from MTL_SYSTEM_ITEMS_INTERFACE
      where ORGANIZATION_ID = org_id
      and NVL(segment1,' ') = DECODE(seg_value(1),NULL,' ',seg_value(1))
      and NVL(segment2,' ') = DECODE(seg_value(2),NULL,' ',seg_value(2))
      and NVL(segment3,' ') = DECODE(seg_value(3),NULL,' ',seg_value(3))
      and NVL(segment4,' ') = DECODE(seg_value(4),NULL,' ',seg_value(4))
      and NVL(segment5,' ') = DECODE(seg_value(5),NULL,' ',seg_value(5))
      and NVL(segment6,' ') = DECODE(seg_value(6),NULL,' ',seg_value(6))
      and NVL(segment7,' ') = DECODE(seg_value(7),NULL,' ',seg_value(7))
      and NVL(segment8,' ') = DECODE(seg_value(8),NULL,' ',seg_value(8))
      and NVL(segment9,' ') = DECODE(seg_value(9),NULL,' ',seg_value(9))
      and NVL(segment10,' ') = DECODE(seg_value(10),NULL,' ',seg_value(10))
      and NVL(segment11,' ') = DECODE(seg_value(11),NULL,' ',seg_value(11))
      and NVL(segment12,' ') = DECODE(seg_value(12),NULL,' ',seg_value(12))
      and NVL(segment13,' ') = DECODE(seg_value(13),NULL,' ',seg_value(13))
      and NVL(segment14,' ') = DECODE(seg_value(14),NULL,' ',seg_value(14))
      and NVL(segment15,' ') = DECODE(seg_value(15),NULL,' ',seg_value(15))
      and NVL(segment16,' ') = DECODE(seg_value(16),NULL,' ',seg_value(16))
      and NVL(segment17,' ') = DECODE(seg_value(17),NULL,' ',seg_value(17))
      and NVL(segment18,' ') = DECODE(seg_value(18),NULL,' ',seg_value(18))
      and NVL(segment19,' ') = DECODE(seg_value(19),NULL,' ',seg_value(19))
      and NVL(segment20,' ') = DECODE(seg_value(20),NULL,' ',seg_value(20))
      --Bug: 6192567 process_flag = 1
      and process_flag IN (1,2) and inventory_item_id is NOT NULL
      and rownum = 1;   --Bug:3340808,3531430

   else if  flex_code = 'MTLL' then
      select INVENTORY_LOCATION_ID
      into flex_id
      from MTL_ITEM_LOCATIONS
      where ORGANIZATION_ID = org_id
      and NVL(segment1,' ') = DECODE(seg_value(1),NULL,' ',seg_value(1))
      and NVL(segment2,' ') = DECODE(seg_value(2),NULL,' ',seg_value(2))
      and NVL(segment3,' ') = DECODE(seg_value(3),NULL,' ',seg_value(3))
      and NVL(segment4,' ') = DECODE(seg_value(4),NULL,' ',seg_value(4))
      and NVL(segment5,' ') = DECODE(seg_value(5),NULL,' ',seg_value(5))
      and NVL(segment6,' ') = DECODE(seg_value(6),NULL,' ',seg_value(6))
      and NVL(segment7,' ') = DECODE(seg_value(7),NULL,' ',seg_value(7))
      and NVL(segment8,' ') = DECODE(seg_value(8),NULL,' ',seg_value(8))
      and NVL(segment9,' ') = DECODE(seg_value(9),NULL,' ',seg_value(9))
      and NVL(segment10,' ') = DECODE(seg_value(10),NULL,' ',seg_value(10))
      and NVL(segment11,' ') = DECODE(seg_value(11),NULL,' ',seg_value(11))
      and NVL(segment12,' ') = DECODE(seg_value(12),NULL,' ',seg_value(12))
      and NVL(segment13,' ') = DECODE(seg_value(13),NULL,' ',seg_value(13))
      and NVL(segment14,' ') = DECODE(seg_value(14),NULL,' ',seg_value(14))
      and NVL(segment15,' ') = DECODE(seg_value(15),NULL,' ',seg_value(15))
      and NVL(segment16,' ') = DECODE(seg_value(16),NULL,' ',seg_value(16))
      and NVL(segment17,' ') = DECODE(seg_value(17),NULL,' ',seg_value(17))
      and NVL(segment18,' ') = DECODE(seg_value(18),NULL,' ',seg_value(18))
      and NVL(segment19,' ') = DECODE(seg_value(19),NULL,' ',seg_value(19))
      and NVL(segment20,' ') = DECODE(seg_value(20),NULL,' ',seg_value(20));

   else if  flex_code = 'MCAT' then
      select CATEGORY_ID
      into flex_id
      from mtl_categories_b
      where structure_id = struct_id
      and NVL(segment1,' ') = DECODE(seg_value(1),NULL,' ',seg_value(1))
      and NVL(segment2,' ') = DECODE(seg_value(2),NULL,' ',seg_value(2))
      and NVL(segment3,' ') = DECODE(seg_value(3),NULL,' ',seg_value(3))
      and NVL(segment4,' ') = DECODE(seg_value(4),NULL,' ',seg_value(4))
      and NVL(segment5,' ') = DECODE(seg_value(5),NULL,' ',seg_value(5))
      and NVL(segment6,' ') = DECODE(seg_value(6),NULL,' ',seg_value(6))
      and NVL(segment7,' ') = DECODE(seg_value(7),NULL,' ',seg_value(7))
      and NVL(segment8,' ') = DECODE(seg_value(8),NULL,' ',seg_value(8))
      and NVL(segment9,' ') = DECODE(seg_value(9),NULL,' ',seg_value(9))
      and NVL(segment10,' ') = DECODE(seg_value(10),NULL,' ',seg_value(10))
      and NVL(segment11,' ') = DECODE(seg_value(11),NULL,' ',seg_value(11))
      and NVL(segment12,' ') = DECODE(seg_value(12),NULL,' ',seg_value(12))
      and NVL(segment13,' ') = DECODE(seg_value(13),NULL,' ',seg_value(13))
      and NVL(segment14,' ') = DECODE(seg_value(14),NULL,' ',seg_value(14))
      and NVL(segment15,' ') = DECODE(seg_value(15),NULL,' ',seg_value(15))
      and NVL(segment16,' ') = DECODE(seg_value(16),NULL,' ',seg_value(16))
      and NVL(segment17,' ') = DECODE(seg_value(17),NULL,' ',seg_value(17))
      and NVL(segment18,' ') = DECODE(seg_value(18),NULL,' ',seg_value(18))
      and NVL(segment19,' ') = DECODE(seg_value(19),NULL,' ',seg_value(19))
      and NVL(segment20,' ') = DECODE(seg_value(20),NULL,' ',seg_value(20));

   end if;  /* MCAT  */
   end if;  /* MTLL  */
   end if;  /* MSTK  */

    RETURN (0);

EXCEPTION

   WHEN  others THEN
      flex_id := NULL;
      err_text := SUBSTRB('INVPUOPI.flex_name' || statement_num   || SQLERRM, 1,240);
      IF l_inv_debug_level IN(101, 102)   THEN
    INVPUTLI.info(   err_text);
      END IF;

      RETURN (SQLCODE);

END mtl_pr_parse_flex_name;

/*
** Search for the matched item number in the MSTK key flexfield   view
** and return the item id, if found.
*/

FUNCTION mtl_pr_trans_prod_item
(
item_number_in    varchar2,
org_id         number,
item_id_out  out  NOCOPY number,
err_text     out  NOCOPY varchar2
)
RETURN INTEGER
IS
   delimiter   varchar2(10);
   min_segment varchar2(32);
   seg1     varchar2(40);
   dummy    number;
   num_of_segments    number;
   min_seg_num  number;
   check_seg_num   number;
BEGIN
   --Bug: 4654433
   delimiter := G_SEGMENT_DELIMITER;
   num_of_segments   := G_NUM_OF_SEGMENTS;

   select min(FS.application_column_name),min(FS.segment_num)
     into min_segment,min_seg_num
   from FND_ID_FLEX_SEGMENTS FS
   where FS.APPLICATION_ID = l_application_id
     and FS.id_flex_code = l_id_flex_code
     and FS.ENABLED_FLAG = l_enabled_flag
     and FS.id_flex_num = l_id_flex_num;

      /* Start of Bugfix 4082723  Anmurali */
   BEGIN
      select FS.segment_num into check_seg_num
      from FND_ID_FLEX_SEGMENTS FS
      where FS.APPLICATION_ID = l_application_id
        and FS.id_flex_code = l_id_flex_code
        and FS.ENABLED_FLAG = l_enabled_flag
        and FS.id_flex_num =  l_id_flex_num
        and FS.application_column_name = 'SEGMENT1';
   EXCEPTION

      WHEN NO_DATA_FOUND THEN
            check_seg_num := null;
   END;



    if (min_segment = 'SEGMENT1' and check_seg_num = min_seg_num) then
/*
** this  is being done because we assume  most customers will define
** flex  combination using atleast segment1.  Atleast they will benefit
** from  the index on org_id+segment1.  Else the   statemnt does a   range
** scan  based on org id   (since the index on segment1 is  suppressed as
** item_number is a concatenation of columns) and is not selective enough
**
** 31-MAY-95: Added new if clause to not look at delimiter if
** num_of_segments = 1; Fix for  bug 285002
** This  is to avoid tripping over in the case where there is only one
** segment and that segment value contains the delimiter character
*/
       if (num_of_segments > 1) then
          dummy :=   instr(item_number_in, delimiter);
          if (dummy = 0) then
        seg1 := item_number_in;
          else
        seg1 := substr(item_number_in, 1, dummy - 1);
          end if;
       elsif (num_of_segments = 1)  then
          seg1 := item_number_in;
       end  if;
/* If condition   added for bug 2935221
   For customers who have segment1 as null, the use of segment1   doesn't
   return the inventroy_item_id. This is taken care of in the if-else condition
*/
       if (seg1 is   null) then
          select inventory_item_id
      into item_id_out
          from mtl_system_items_b_kfv
          where organization_id = org_id
          and concatenated_segments = item_number_in;
       else
      select inventory_item_id
      into item_id_out
      from mtl_system_items_b_kfv
      where segment1 = seg1
        and organization_id = org_id
        and concatenated_segments = item_number_in;
       end  if;
   else

       select inventory_item_id
         into item_id_out
       from mtl_system_items_b_kfv
       where organization_id = org_id
         and concatenated_segments  = item_number_in;

   end if;

   RETURN (0);

EXCEPTION

   WHEN  OTHERS THEN
      item_id_out := NULL;
      err_text := substr('INVPUOPI.trans_item: ' || SQLERRM, 1,240);
      RETURN (SQLCODE);

END mtl_pr_trans_prod_item;


FUNCTION mtl_pr_trans_org_id
(
org_code varchar2,
org_id out  NOCOPY number,
err_text out   NOCOPY varchar2
)
RETURN INTEGER
is
begin

   --4932347: Using MTL_PARAMETERS instead of org_org
   select organization_id
   into org_id
   from mtl_parameters
   where organization_code = org_code;

    return(0);

exception

   WHEN OTHERS THEN
       org_id := NULL;
       err_text :=   substr('INVPUOPI.trans_org: ' || SQLERRM , 1, 240);
       return(SQLCODE);

end mtl_pr_trans_org_id;


FUNCTION mtl_pr_trans_template_id
(
templ_name   varchar2,
templ_id out NOCOPY number,
err_text out NOCOPY varchar2
)
RETURN INTEGER
IS
BEGIN
   select template_id
   into templ_id
   from mtl_item_templates
   where template_name = templ_name;

    return(0);

exception

   WHEN OTHERS THEN
       templ_id :=   NULL;
       err_text :=   substr('INVPUOPI.parse_template: ' || SQLERRM, 1, 240);
       return(SQLCODE);

END mtl_pr_trans_template_id;


FUNCTION mtl_log_interface_err
(
org_id      number,
user_id     number,
login_id number,
prog_appid  number,
prog_id     number,
req_id      number,
trans_id number,
error_text  varchar2,
  p_column_name      VARCHAR2 := NULL,
tbl_name varchar2,
msg_name varchar2,
err_text       OUT  NOCOPY VARCHAR2
)
RETURN INTEGER
IS
   dumm_status     number;
   translated_text  fnd_new_messages.message_text%TYPE;  --3699144
   l_sysdate       DATE  :=  SYSDATE;
   l_inv_debug_level NUMBER := INVPUTLI.get_debug_level;  --Bug: 4667452
BEGIN

   IF (msg_name   = 'INV_IOI_ERR') OR (msg_name =  'INV_ICOI_ERROR')
       OR (msg_name like 'BOM%') OR (msg_name like 'CST%')
       OR (msg_name like 'INV_CAT_SET_NO_DEFAULT_CAT')THEN
      translated_text := error_text;
   ELSE
      dumm_status := INVUPD2B.get_message(msg_name, translated_text);
   END IF;

   IF l_inv_debug_level IN(101,  102) THEN
      INVPUTLI.info('INVPUOPI.mtl_log_interface_err: msg_name =   '||msg_name);
   END IF;

 -- Bug  4052362  To display the entire error message - Anmurali

   INSERT INTO mtl_interface_errors
   (
   TRANSACTION_ID,
   UNIQUE_ID,
   ORGANIZATION_ID,
   LAST_UPDATE_DATE,
   LAST_UPDATED_BY,
   CREATION_DATE,
   CREATED_BY,
   LAST_UPDATE_LOGIN,
   COLUMN_NAME,
   TABLE_NAME,
   MESSAGE_NAME,
   ERROR_MESSAGE,
   REQUEST_ID,
   PROGRAM_APPLICATION_ID,
   PROGRAM_ID,
   PROGRAM_UPDATE_DATE
   )
   VALUES
   (
   trans_id,
   mtl_system_items_interface_s.NEXTVAL,
   org_id,
   l_sysdate,
   user_id,
   l_sysdate,
   user_id,
   login_id,
   p_column_name,
   tbl_name,
   msg_name,
   SUBSTRB(translated_text, 1,2000),
   req_id,
   prog_appid,
   prog_id,
   l_sysdate
   );

   -- Output error information into the   log file
  if (to_number(nvl(fnd_profile.value('CONC_REQUEST_ID'),0)) <>   0) then
   FND_FILE.PUT_LINE(FND_FILE.LOG,'************************************') ;
   FND_FILE.PUT_LINE(FND_FILE.LOG,'TRANSACTION ID : '  || trans_id);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'ORGANIZATION ID : ' || org_id);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'TABLE NAME : '  || tbl_name);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'COLUMN NAME : ' || p_column_name);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'MESSAGE NAME : '  ||  msg_name);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'ERROR MESSAGE : ' ||  substrb(translated_text,1,2000));
 end if  ;

  IF l_inv_debug_level IN(101, 102) THEN
     INVPUTLI.info('INVPUOPI.mtl_log_interface_err: TRANSACTION   ID : '   || trans_id);
     INVPUTLI.info('INVPUOPI.mtl_log_interface_err: ORGANIZATION ID : ' || org_id);
     INVPUTLI.info('INVPUOPI.mtl_log_interface_err: TABLE NAME : '  || tbl_name);
     INVPUTLI.info('INVPUOPI.mtl_log_interface_err: COLUMN NAME   : ' || p_column_name);
     INVPUTLI.info('INVPUOPI.mtl_log_interface_err: MESSAGE NAME : '  || msg_name);
     INVPUTLI.info('INVPUOPI.mtl_log_interface_err: ERROR MESSAGE : ' || substrb(translated_text,1,2000));
  END IF;

   RETURN (0);

EXCEPTION

   WHEN  others THEN
      err_text := SUBSTRB('INVPUOPI.mtl_log_interface_err: ' ||   SQLERRM, 1,240);
      RETURN (SQLCODE);

END mtl_log_interface_err;

--------------------------------------------------------------------
-- To convert item_number to Item_id
-----------------------------------------------------------------
FUNCTION mtl_pr_parse_item_name
(
item_number_in    varchar2,
item_id_out  out  NOCOPY number,
err_text     out  NOCOPY varchar2
)
RETURN INTEGER
IS
   delimiter   varchar2(10);
   min_segment varchar2(32);
   seg1     varchar2(40);
   dummy    number;
   num_of_segments   number;
   min_seg_num number;
   check_seg_num  number;

l_application_id number(10) :=   401;
l_id_flex_code varchar2(4) := 'MSTK';
l_enabled_flag varchar2(1) := 'Y';
l_id_flex_num  number(15)  := 101 ;
BEGIN

        --Bug: 4654433
   delimiter       := G_SEGMENT_DELIMITER;
   num_of_segments   := G_NUM_OF_SEGMENTS;
        min_segment     := G_MIN_SEGMENT;
   min_seg_num     := G_MIN_SEG_NUM;
   check_seg_num   := G_CHECK_SEG_NUM;

       /* Start   of Bugfix 4082723  Anmurali */

   if (min_segment   = 'SEGMENT1' and check_seg_num = min_seg_num) then

      if (num_of_segments > 1) then
          dummy :=   instr(item_number_in, delimiter);
          if (dummy = 0) then
        seg1 := item_number_in;
          else
        seg1 := substr(item_number_in, 1, dummy - 1);
          end if;
       elsif (num_of_segments = 1)  then
          seg1 := item_number_in;
       end  if;

      if (seg1 is null) then
          select inventory_item_id
       into item_id_out
       from mtl_system_items_b_kfv
      where concatenated_segments = item_number_in
      group by inventory_item_id; -- Bug: 3447718 - added group by to   get distinct inventory_item_id
      else
          select inventory_item_id
       into item_id_out
       from mtl_system_items_b_kfv
      where segment1 = seg1
        and concatenated_segments = item_number_in
      group by inventory_item_id; -- Bug: 3447718 - added group by to   get distinct inventory_item_id
      end if;

   else
       select inventory_item_id
         into item_id_out
       from mtl_system_items_b_kfv
       where concatenated_segments  = item_number_in
       group by inventory_item_id;  -- Bug:  3447718  - added  group by to get   distinct inventory_item_id

   end if;

   RETURN (0);

EXCEPTION

   WHEN  OTHERS THEN
      item_id_out := NULL;
      err_text := substr('INVPUOPI.trans_item: ' || SQLERRM, 1,240);
      RETURN (SQLCODE);

END mtl_pr_parse_item_name;

/*------------------------------*/
/* Package initialization block  */
/*------------------------------*/

BEGIN

   SELECT FT.concatenated_segment_delimiter
   INTO  G_SEGMENT_DELIMITER
   FROM  fnd_id_flex_structures FT
   WHERE FT.id_flex_code = l_id_flex_code
     AND FT.APPLICATION_ID = l_application_id
     AND FT.ID_FLEX_NUM = l_id_flex_num;

   SELECT max(FS.segment_num)
   INTO  G_SEGMENTS_INUSE
   FROM  FND_ID_FLEX_SEGMENTS FS
   WHERE FS.APPLICATION_ID = l_application_id
     AND FS.id_flex_code = l_id_flex_code
     AND FS.ENABLED_FLAG = l_enabled_flag
     AND FS.id_flex_num = l_id_flex_num;

   SELECT to_number(substr(application_column_name,8)), segment_num BULK COLLECT INTO G_SEGMENTS_USED, G_SEGMENT_NUMS_USED
   FROM  FND_ID_FLEX_SEGMENTS
   WHERE APPLICATION_ID = l_application_id
      AND id_flex_code = l_id_flex_code
      AND ENABLED_FLAG = l_enabled_flag
      AND id_flex_num = l_id_flex_num
   ORDER BY segment_num;

   SELECT COUNT(*) INTO G_NUM_OF_SEGMENTS
   FROM  FND_ID_FLEX_SEGMENTS FS
   WHERE FS.APPLICATION_ID = l_application_id
     AND FS.id_flex_code = l_id_flex_code
     AND FS.ENABLED_FLAG = l_enabled_flag
     AND FS.id_flex_num =  l_id_flex_num;

   SELECT min(FS.application_column_name),min(FS.segment_num)
   INTO G_MIN_SEGMENT,G_MIN_SEG_NUM
   FROM FND_ID_FLEX_SEGMENTS FS
   WHERE FS.APPLICATION_ID = l_application_id
     AND FS.id_flex_code = l_id_flex_code
     AND FS.ENABLED_FLAG = l_enabled_flag
     AND FS.id_flex_num = l_id_flex_num;

   BEGIN
      select FS.segment_num into G_CHECK_SEG_NUM
      from FND_ID_FLEX_SEGMENTS FS
      where FS.APPLICATION_ID = l_application_id
        and FS.id_flex_code = l_id_flex_code
   and FS.ENABLED_FLAG = l_enabled_flag
   and FS.id_flex_num = l_id_flex_num
   and FS.application_column_name = 'SEGMENT1';
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         G_CHECK_SEG_NUM := null;
   END;

END INVPUOPI;

/
