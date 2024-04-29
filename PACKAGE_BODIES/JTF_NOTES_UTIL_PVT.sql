--------------------------------------------------------
--  DDL for Package Body JTF_NOTES_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_NOTES_UTIL_PVT" AS
/* $Header: jtfvnub.pls 115.10 2002/11/16 00:30:13 hbouten ship $ */

PROCEDURE GetContexts
( p_api_version           IN            NUMBER
, p_init_msg_list         IN            VARCHAR2
, p_validation_level      IN            NUMBER
, p_note_id               IN            NUMBER
, x_context_count            OUT NOCOPY NUMBER
, x_context_id               OUT NOCOPY JTF_NUMBER_TABLE
, x_context_type_code        OUT NOCOPY JTF_VARCHAR2_TABLE_100
, x_context_type_name        OUT NOCOPY JTF_VARCHAR2_TABLE_100
, x_context_select_id        OUT NOCOPY JTF_NUMBER_TABLE
, x_context_select_name      OUT NOCOPY JTF_VARCHAR2_TABLE_2000
, x_context_select_details   OUT NOCOPY JTF_VARCHAR2_TABLE_2000
, x_return_status            OUT NOCOPY VARCHAR2
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
) AS

  CURSOR c_get_note_contexts
  (
    p_note_id  NUMBER
  ) IS
  SELECT JNS.note_context_id note_context_id,
         JNS.jtf_note_id jtf_note_id,
         --Bug # 1978242, change everything to Party
         DECODE(JNS.note_context_type,'PARTY_ORGANIZATION','PARTY','PARTY_PERSON',
               'PARTY','PARTY_RELATIONSHIP','PARTY',JNS.note_context_type) note_context_type,
         JNS.note_context_type_id note_context_type_id,
         JOB.select_id select_id,
         JOB.select_name select_name,
         JOB.select_details select_details,
         JOB.from_table from_table,
         JOB.where_clause where_clause,
         JOB.order_by_clause order_by_clause,
         JOL.NAME note_context_type_name
  FROM   JTF_OBJECTS_TL JOL,
         JTF_OBJECTS_B JOB,
         JTF_NOTE_CONTEXTS JNS
  WHERE  JNS.JTF_NOTE_ID = p_note_id
  AND    JOB.OBJECT_CODE = DECODE(JNS.note_context_type,'PARTY_ORGANIZATION','PARTY',
            'PARTY_PERSON','PARTY','PARTY_RELATIONSHIP','PARTY',JNS.note_context_type)
  AND    JOL.OBJECT_CODE = JOB.OBJECT_CODE
  AND    JOL.LANGUAGE = USERENV('LANG');

  l_jtf_objects_sql  VARCHAR2(2000);
  l_context_select_name VARCHAR2(2000);
  l_context_select_details VARCHAR2(2000);

BEGIN
  x_return_status := 'S';
  x_msg_count := 0;
  x_msg_data := '';
  x_context_count := 0;
  --First instantiate the collection
  x_context_id := JTF_NUMBER_TABLE();
  x_context_type_code := JTF_VARCHAR2_TABLE_100();
  x_context_type_name := JTF_VARCHAR2_TABLE_100();
  x_context_select_id := JTF_NUMBER_TABLE();
  x_context_select_name := JTF_VARCHAR2_TABLE_2000();
  x_context_select_details := JTF_VARCHAR2_TABLE_2000();

  FOR ref_note_contexts IN c_get_note_contexts(p_note_id)
  LOOP
    x_context_count := x_context_count + 1;
    --First instantiate the collection
    x_context_id.extend(x_context_count);
    x_context_type_code.extend(x_context_count);
    x_context_type_name.extend(x_context_count);
    x_context_select_id.extend(x_context_count);
    x_context_select_name.extend(x_context_count);
    x_context_select_details.extend(x_context_count);
    --Copy the data
    x_context_id(x_context_count) := ref_note_contexts.note_context_id;
    x_context_type_code(x_context_count) := ref_note_contexts.note_context_type;
    x_context_type_name(x_context_count) := ref_note_contexts.note_context_type_name;
    x_context_select_id(x_context_count) := ref_note_contexts.note_context_type_id;
    --Initialize remaining items.
    x_context_select_name(x_context_count) := NULL;
    x_context_select_details(x_context_count) := NULL;
    --Build the query
    IF ((ref_note_contexts.select_id IS NOT NULL) AND
       (ref_note_contexts.select_name IS NOT NULL) AND
       (ref_note_contexts.from_table IS NOT NULL))
    THEN
       l_jtf_objects_sql := 'SELECT ' || ref_note_contexts.select_name;
       IF (ref_note_contexts.select_details IS NOT NULL)
       THEN
          l_jtf_objects_sql := l_jtf_objects_sql || ',' ||
                                               ref_note_contexts.select_details;
       ELSE
          l_jtf_objects_sql := l_jtf_objects_sql || ',NULL';
       END IF;
       l_jtf_objects_sql := l_jtf_objects_sql || ' FROM ' ||
                                                   ref_note_contexts.from_table;
       IF (ref_note_contexts.where_clause IS NOT NULL)
       THEN
          l_jtf_objects_sql := l_jtf_objects_sql || ' WHERE ' ||
                                      ref_note_contexts.where_clause || ' AND ';
       ELSE
          l_jtf_objects_sql := l_jtf_objects_sql || ' WHERE ';
       END IF;
       l_jtf_objects_sql := l_jtf_objects_sql || ref_note_contexts.select_id ||
                            ' = :note_context_type_id';
       BEGIN
         EXECUTE IMMEDIATE l_jtf_objects_sql
             INTO x_context_select_name(x_context_count),
                  x_context_select_details(x_context_count)
             USING ref_note_contexts.note_context_type_id;
       EXCEPTION
          WHEN OTHERS THEN
               x_context_select_name(x_context_count) := NULL;
               x_context_select_details(x_context_count) := NULL;
               x_msg_count := x_msg_count + 1;
               x_msg_data := x_msg_data ||'Error executing query for notes Context ' ||
                             ref_note_contexts.note_context_type_name || ' and ID ' ||
                             ref_note_contexts.note_context_type_id || '. ';
       END;
    ELSE
       x_msg_count := x_msg_count + 1;
       x_msg_data := x_msg_data ||'Error building query for notes Context ' ||
                     ref_note_contexts.note_context_type_name || '. ';
    END IF;
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'U';
    x_msg_count := x_msg_count + 1;
    x_msg_data := x_msg_data ||'Error fetching note context information : ' || sqlerrm;

END GetContexts;

FUNCTION GetNotesDetail
(
   p_note_id IN NUMBER
) RETURN VARCHAR2
AS

  CURSOR c_get_notes_detail
  (
      p_note_id NUMBER
   ) IS
   SELECT NOTES_DETAIL
   FROM JTF_NOTES_TL
   WHERE JTF_NOTE_ID = p_note_id
   AND LANGUAGE = USERENV('LANG');

  l_notes_detail    JTF_NOTES_TL.NOTES_DETAIL%TYPE;

Amount BINARY_INTEGER := 32767;
 Position INTEGER := 1;
 Buffer varchar2(32767);
 CHUNKSIZE INTEGER;

BEGIN
   OPEN c_get_notes_detail(p_note_id);
   FETCH c_get_notes_detail
       INTO l_notes_detail;
   CLOSE c_get_notes_detail;

    chunksize := DBMS_LOB.getchunksize(l_notes_detail);

If chunksize is not null then

 if chunksize < 32767 then
    amount := (32767/chunksize) * chunksize;
 end if;

  dbms_lob.read(l_notes_detail,amount,position,buffer);

 end if;

   RETURN buffer;

END GetNotesDetail;

FUNCTION CheckAttachments
(
   p_note_id    IN NUMBER
) RETURN NUMBER
IS

  CURSOR GetAttachments
  (
     p_note_id   VARCHAR2
  ) IS
  SELECT attached_document_id
  FROM FND_ATTACHED_DOCS_FORM_VL
  WHERE function_name = 'JTF_CAL_ATTACHMENTS'
  AND function_type = 'F'
  AND (security_type = 4 OR publish_flag = 'Y')
  AND entity_name = 'JTF_NOTES_B'
  AND pk1_value = p_note_id;

  l_dummy   NUMBER := 0;
  l_return  NUMBER := 0;

BEGIN
  OPEN GetAttachments(TO_CHAR(p_note_id));
  FETCH GetAttachments
     INTO l_dummy;
  IF GetAttachments%FOUND
  THEN
    l_return := 1;
  END IF;
  CLOSE GetAttachments;

  RETURN l_return;

END CheckAttachments;


FUNCTION HasCLOB
( p_note_id    IN NUMBER
) RETURN VARCHAR2
IS

  CURSOR c_note
  (
     p_note_id   VARCHAR2
  ) IS
  SELECT DECODE(DBMS_LOB.SUBSTR(notes_detail,1,1),NULL,'N','Y') hasCLOB
  FROM jtf_notes_tl
  WHERE jtf_note_id = p_note_id
  AND   language = userenv('LANG');

  l_HasCLOB VARCHAR2(1):='N';

BEGIN
  OPEN c_note(p_note_id);
  FETCH c_note INTO l_hasCLOB;
  CLOSE c_note;
  RETURN l_hasCLOB;
END HasCLOB;

FUNCTION JTFObjectValid
/*
function to verify whether the JTF_OBJECT definition for an object is enough to
create a SQL statement, if not we don't even want to expose the object.
*/
(  p_object_code IN VARCHAR2
) RETURN VARCHAR2
IS
  CURSOR c_object
  (b_object_code IN VARCHAR2
  )IS SELECT job.select_id
      ,      job.select_name
      ,      job.from_table
      FROM  jtf_objects_b job
      WHERE job.object_code = b_object_code;

  r_object c_object%ROWTYPE;

  l_return VARCHAR2(1):= 'N';

BEGIN
  IF (c_object%ISOPEN)
  THEN
    CLOSE c_object;
  END IF;

  OPEN c_object(p_object_code);

  FETCH c_object INTO r_object;

  IF (c_object%FOUND)
  THEN
    IF (   (r_object.select_id   IS NULL)
       OR  (r_object.select_name IS NULL)
       OR  (r_object.from_table  IS NULL)
       )
    THEN
      l_return := 'N';
    ELSE
      l_return := 'Y';
    END IF;
  ELSE
    l_return := 'N';
  END IF;

  IF (c_object%ISOPEN)
  THEN
    CLOSE c_object;
  END IF;

  RETURN l_return;
EXCEPTION
  WHEN OTHERS
  THEN
    IF (c_object%ISOPEN)
    THEN
      CLOSE c_object;
    END IF;
    RETURN 'N';

END JTFObjectValid;

FUNCTION SelectNameVARCHAR2
(  p_select_name IN VARCHAR2
) RETURN VARCHAR2
IS
BEGIN
  RETURN p_select_name;
END SelectNameVARCHAR2;

FUNCTION SelectNameVARCHAR2
(  p_select_name IN NUMBER
) RETURN VARCHAR2
IS
BEGIN
  RETURN TO_CHAR(p_select_name);
END SelectNameVARCHAR2;



END JTF_NOTES_UTIL_PVT;

/
