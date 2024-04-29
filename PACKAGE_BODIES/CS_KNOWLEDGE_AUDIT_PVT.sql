--------------------------------------------------------
--  DDL for Package Body CS_KNOWLEDGE_AUDIT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_KNOWLEDGE_AUDIT_PVT" AS
/* $Header: cskbapb.pls 120.4.12010000.3 2009/10/21 12:47:50 amganapa ship $ */

-- An element is updatable if
-- 1) no set is linking to it, OR
-- 2) only set with p_set_number is linking to it.
-- return 'Y' if updatable
-- return 'N' if not-updatable
FUNCTION Is_Element_Updatable
(
  p_element_number IN  VARCHAR2,
  p_set_number     IN  VARCHAR2
)
RETURN VARCHAR2
IS
  l_count NUMBER;

  CURSOR cur_ele IS
    SELECT element_id
      FROM CS_KB_ELEMENTS_B
     WHERE element_number = p_element_number;

  CURSOR cur_set(c_element_id IN NUMBER) IS
    SELECT DISTINCT s.set_number
      FROM CS_KB_SET_ELES se,
           CS_KB_SETS_B s
     WHERE se.element_id = c_element_id
       AND se.set_id = s.set_id;

BEGIN

  -- if p_set_number is null, any existing
  IF p_set_number IS NULL THEN

    SELECT COUNT(se.set_id)
      INTO l_count
      FROM CS_KB_SET_ELES se,
           CS_KB_ELEMENTS_B e
     WHERE e.element_number = p_element_number
       AND se.element_id = e.element_id;

    IF l_count < 1 THEN
      RETURN 'Y';
    ELSE
      RETURN 'N';
    END IF;

  END IF;

  FOR rec IN cur_ele LOOP

    FOR rec_inner IN cur_set(rec.element_id) LOOP
      IF ( rec_inner.set_number <> p_set_number ) THEN
        RETURN 'N';
      END IF;
    END LOOP;

  END LOOP;

  RETURN 'Y';

END Is_Element_Updatable;


-- check IF at least one statement FOR each mandatory element-type
-- (which IS defined IN cs_kb_set_ele_types) exists
-- FOR this particular version of solution
-- RETURN 'N' IF complete, 'Y' IF there IS any missing ele-types
FUNCTION Get_Missing_Ele_Type
( p_set_id                 IN  NUMBER--,
)
RETURN VARCHAR2 IS

  -- Create the table variables to hold returnable info.
  t_ele_type_id   JTF_NUMBER_TABLE       := JTF_NUMBER_TABLE();
  t_ele_type_name JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();

  -- count of matching element type
  l_count NUMBER;
  l_set_type_id NUMBER;
  l_element_type_name CS_KB_ELEMENT_TYPES_TL.name%TYPE;

  -- Counter variable.
  counter NUMBER := 0;

  -- list of required element types
  CURSOR cur_ele_type(p_set_type_id IN NUMBER) IS
    SELECT B.element_type_id
      FROM CS_KB_SET_ELE_TYPES A, CS_KB_ELEMENT_TYPES_VL B
     WHERE A.set_type_id = p_set_type_id
       AND A.optional_flag = 'N'
       AND A.element_type_id = B.element_type_id
       AND trunc(sysdate) between trunc(nvl(B.start_date_active, sysdate)) and trunc(nvl(B.end_date_active, sysdate))
  ORDER BY A.element_type_order ASC;

BEGIN

  SELECT set_type_id
    INTO l_set_type_id
    FROM CS_KB_SETS_B
   WHERE set_id = p_set_id;

  FOR rec IN cur_ele_type(l_set_type_id) LOOP

    SELECT count(*)
      INTO l_count
      FROM CS_KB_ELEMENTS_B e,
           CS_KB_SET_ELES   se
     WHERE se.set_id = p_set_id
       AND se.element_id = e.element_id
       AND e.element_type_id = rec.element_type_id;

     IF l_count < 1 THEN

       SELECT name
         INTO l_element_type_name
         FROM CS_KB_ELEMENT_TYPES_TL
        WHERE element_type_id = rec.element_type_id
          AND language = USERENV('LANG');

       -- Extending tables one.
       t_ele_type_id.EXTEND;
       t_ele_type_name.EXTEND;
       counter := counter + 1;

       t_ele_type_id(counter) := rec.element_type_id;
       t_ele_type_name(counter) := l_element_type_name;

     END IF;
  END LOOP;

  IF counter = 0 THEN
    RETURN 'N';
  ELSE
    RETURN 'Y';
  END IF;

END Get_Missing_Ele_Type;


FUNCTION Decrypt
(
   KEY    IN VARCHAR2,
   VALUE  IN VARCHAR2
)
RETURN VARCHAR2 AS LANGUAGE java name
'oracle.apps.fnd.security.WebSessionManagerProc.decrypt(java.lang.String,java.lang.String) return java.lang.String';


--
-- Get sysdate, fnd user AND login
--
PROCEDURE Get_Who(
  x_sysdate  OUT NOCOPY DATE,
  x_user_id  OUT NOCOPY NUMBER,
  x_login_id OUT NOCOPY NUMBER
) IS
BEGIN
  x_sysdate := SYSDATE;
  x_user_id := FND_GLOBAL.user_id;
  x_login_id := FND_GLOBAL.login_id;
END Get_Who;

--
-- Check set_type - element_type IS valid
-- Valid params:
--   (set id, NULL, ele id, NULL)
--   (set id, NULL, NULL, ele type)
--   (NULL, set type, ele id, NULL)
--   (NULL, set type, NULL, ele type)
--
FUNCTION Is_Set_Ele_Type_Valid(
  p_set_number IN VARCHAR2 := NULL,
  p_set_type_id IN NUMBER :=NULL,
  p_element_number IN VARCHAR2 :=NULL,
  p_ele_type_id IN NUMBER :=NULL
) RETURN VARCHAR2 IS
  l_count PLS_INTEGER;
BEGIN

  IF p_set_number IS NOT NULL THEN
    IF  p_element_number IS NOT NULL THEN
      SELECT count(*) INTO l_count
        FROM cs_kb_set_ele_types se,
             cs_kb_sets_b s,
             cs_kb_elements_b e
        WHERE se.set_type_id = s.set_type_id
        AND se.element_type_id = e.element_type_id
        AND s.set_number = p_set_number
        AND e.element_number = p_element_number;

    ELSIF(p_ele_type_id > 0) THEN
      SELECT count(*) INTO l_count
        FROM CS_KB_SET_ELE_TYPES se,
             CS_KB_SETS_B s
        WHERE se.set_type_id = s.set_type_id
        AND s.set_number = p_set_number
        AND se.element_type_id = p_ele_type_id;
    END IF;

  ELSIF(p_set_type_id >0) THEN
    IF p_element_number IS NOT NULL THEN
      SELECT count(*) INTO l_count
        FROM CS_KB_SET_ELE_TYPES se,
             CS_KB_ELEMENTS_B e
        WHERE se.set_type_id = p_set_type_id
        AND e.element_number = p_element_number
        AND se.element_type_id = e.element_type_id;

    ELSIF(p_ele_type_id >0) THEN
      SELECT count(*) INTO l_count
        FROM CS_KB_SET_ELE_TYPES se
        WHERE se.set_type_id = p_set_type_id
        AND se.element_type_id = p_ele_type_id;
    END IF;
  END IF;

  IF(l_count >0) THEN RETURN G_TRUE;
  ELSE                RETURN G_FALSE;
  END IF;
END Is_Set_Ele_Type_Valid;


FUNCTION Del_Element_From_Set(
  p_element_id IN NUMBER,
  p_set_id IN NUMBER
) RETURN NUMBER IS--RETURN OKAY_STATUS / ERROR_STATUS
  l_date DATE;
  l_user NUMBER;
  l_login NUMBER;

  CURSOR cur_eles( c_sid IN NUMBER) IS
    SELECT element_id
    FROM CS_KB_SET_ELES
    WHERE set_id = c_sid;

  CURSOR cur_set IS
    SELECT set_type_id
    FROM CS_KB_SETS_B
    WHERE set_id = p_set_id;

  l_set_rec cur_set%ROWTYPE;

BEGIN
  -- Check params
  IF( not p_set_id > 0 ) or (not p_element_id > 0) THEN
    FND_MESSAGE.set_name('CS', 'CS_KB_C_MISS_PARAM');
    GOTO ERROR_FOUND;
  END IF;

  --delete a row IN set_eles_audit
  DELETE FROM CS_KB_SET_ELES
    WHERE element_id = p_element_id
    AND set_id = p_set_id;

  -- change UPDATE DATE of set_audit
  -- -- AND UPDATE change_history of set

  Get_Who(l_date, l_user, l_login);
  UPDATE CS_KB_SETS_B SET
    last_update_date = l_date,
    last_updated_by = l_user,
    last_update_login = l_login
    WHERE set_id = p_set_id;

  -- touch related sets to UPDATE interMedia index
  UPDATE CS_KB_SETS_TL SET
    last_update_date = l_date,
    last_updated_by = l_user,
    last_update_login = l_login
    WHERE set_id = p_set_id;


  RETURN OKAY_STATUS;
  <<ERROR_FOUND>>
  RETURN ERROR_STATUS;

END Del_Element_From_Set;


FUNCTION Add_Element_To_Set(
  p_element_number IN VARCHAR2,
  p_set_id IN NUMBER,
  p_assoc_degree IN NUMBER := CS_KNOWLEDGE_PUB.G_POSITIVE_ASSOC
) RETURN NUMBER IS --RETURN OKAY_STATUS / ERROR_STATUS
  l_dummy NUMBER;
  l_element_id NUMBER;--new
  l_count  PLS_INTEGER;
  l_date  DATE;
  l_created_by NUMBER;
  l_login NUMBER;
  l_order NUMBER(15);
  l_set_type_id NUMBER;
  l_ele_type_id NUMBER;

  l_set_number VARCHAR2(30);

BEGIN

  -- Check params
  IF( NOT p_set_id > 0 ) OR (p_element_number IS NULL) THEN
    FND_MESSAGE.set_name('CS', 'CS_KB_C_MISS_PARAM');
    GOTO ERROR_FOUND;
  END IF;

  -- check IF element exists
  SELECT COUNT(*) INTO l_count
      FROM CS_KB_ELEMENTS_B
      WHERE element_number = p_element_number;
  IF(l_count=0) THEN
    FND_MESSAGE.set_name('CS', 'CS_KB_C_INVALID_ELE_ID');
    GOTO ERROR_FOUND;
  END IF;

  l_element_id := CS_KB_ELEMENTS_AUDIT_PKG.Get_Latest_Version_Id(p_element_number);

  -- check IF element already exists
  SELECT count(se.element_id) INTO l_count
    FROM CS_KB_SET_ELES se, CS_KB_ELEMENTS_B eb
   WHERE se.set_id = p_set_id
     AND se.element_id = eb.element_id
     AND eb.element_number = p_element_number;
  IF(l_count>0) THEN
    FND_MESSAGE.set_name('CS', 'CS_KB_C_ELE_EXIST_ERR');
    GOTO ERROR_FOUND;
  END IF;

  --check set ele type match

  SELECT set_type_id INTO l_set_type_id
  FROM CS_KB_SETS_B
  WHERE set_id = p_set_id;

  SELECT element_type_id INTO l_ele_type_id
  FROM CS_KB_ELEMENTS_B
  WHERE element_id = l_element_id;

  IF( Is_Set_Ele_Type_Valid(
        p_set_type_id => l_set_type_id,
        p_ele_type_id => l_ele_type_id)
        = G_FALSE) THEN
      FND_MESSAGE.set_name('CS', 'CS_KB_C_INCOMPATIBLE_TYPES');
      GOTO ERROR_FOUND;
   END IF;

  -- prepare data to insert
  Get_Who(l_date, l_created_by, l_login);

  SELECT MAX(element_order) INTO l_order
    FROM CS_KB_SET_ELES
    WHERE set_id = p_set_id;

  -- order IS important, need to consider l_order may be NULL
  IF( l_order > 0) THEN
    l_order := l_order + 1;
  ELSE
    l_order :=1;
  END IF;

  -- insert INTO set_ele
  INSERT INTO CS_KB_SET_ELES (
        set_id, element_id, element_order, assoc_degree,
        creation_date, created_by,
        last_update_date, last_updated_by, last_update_login)
        VALUES(
        p_set_id, l_element_id, l_order, p_assoc_degree,
        l_date, l_created_by, l_date, l_created_by, l_login);

  -- change UPDATE DATE of set
  -- AND UPDATE history
  UPDATE CS_KB_SETS_B SET
    last_update_date = l_date,
    last_updated_by = l_created_by,
    last_update_login = l_login
    WHERE set_id = p_set_id;

  SELECT set_number
    INTO l_set_number
    FROM CS_KB_SETS_B
   WHERE set_id = p_set_id;

  -- touch related sets to UPDATE interMedia index
  UPDATE CS_KB_SETS_TL SET
    last_update_date = l_date,
    last_updated_by = l_created_by,
    last_update_login = l_login
    WHERE set_id = p_set_id;


  RETURN OKAY_STATUS;

  <<ERROR_FOUND>>
  RETURN ERROR_STATUS;
END Add_Element_To_Set;


FUNCTION Create_Element_And_Link_To_Set(
  p_element_type_id  IN NUMBER,
  p_desc IN VARCHAR2,
  p_name IN VARCHAR2,
  p_status IN VARCHAR2,
  p_access_level IN NUMBER,
  p_attribute_category IN VARCHAR2,
  p_attribute1 IN VARCHAR2,
  p_attribute2 IN VARCHAR2,
  p_attribute3 IN VARCHAR2,
  p_attribute4 IN VARCHAR2,
  p_attribute5 IN VARCHAR2,
  p_attribute6 IN VARCHAR2,
  p_attribute7 IN VARCHAR2,
  p_attribute8 IN VARCHAR2,
  p_attribute9 IN VARCHAR2,
  p_attribute10 IN VARCHAR2,
  p_attribute11 IN VARCHAR2,
  p_attribute12 IN VARCHAR2,
  p_attribute13 IN VARCHAR2,
  p_attribute14 IN VARCHAR2,
  p_attribute15 IN VARCHAR2,
  p_set_id IN NUMBER,
  p_assoc_degree IN NUMBER := CS_KNOWLEDGE_PUB.G_POSITIVE_ASSOC,
  p_locked_by IN NUMBER,
  p_start_active_date IN DATE,
  p_end_active_date IN DATE,
  p_content_type IN VARCHAR2
) RETURN NUMBER IS--RETURN element_audit_id IF success, or ERROR_STATUS IF fail
 l_element_id NUMBER;
 l_element_number VARCHAR2(30);
 l_ret NUMBER;
BEGIN
  l_element_id := CS_KB_ELEMENTS_AUDIT_PKG.Create_Element(
  p_element_type_id => p_element_type_id,
  p_desc => p_desc,
  p_name => p_name,
  p_status => p_status,
  p_access_level => p_access_level,
  p_attribute_category => p_attribute_category,
  p_attribute1 => p_attribute1,
  p_attribute2 => p_attribute2,
  p_attribute3 => p_attribute3,
  p_attribute4 => p_attribute4,
  p_attribute5 => p_attribute5,
  p_attribute6 => p_attribute6,
  p_attribute7 => p_attribute7,
  p_attribute8 => p_attribute8,
  p_attribute9 => p_attribute9,
  p_attribute10 => p_attribute10,
  p_attribute11 => p_attribute11,
  p_attribute12 => p_attribute12,
  p_attribute13 => p_attribute13,
  p_attribute14 => p_attribute14,
  p_attribute15 => p_attribute15,
  p_start_active_date => p_start_active_date,
  p_end_active_date => p_end_active_date,
  p_content_type => p_content_type
);

  IF l_element_id < 0 THEN
     RETURN l_element_id;
  END IF;

  SELECT element_number INTO l_element_number
  FROM CS_KB_ELEMENTS_B
  WHERE element_id = l_element_id;

  l_ret := Add_Element_To_Set(
  p_element_number => l_element_number,
  p_set_id => p_set_id,
  p_assoc_degree => p_assoc_degree);

  IF l_ret = ERROR_STATUS THEN
    RETURN ERROR_STATUS;
  END IF;

  RETURN l_element_id;
END Create_Element_And_Link_To_Set;


FUNCTION Sort_Element_Order(p_set_number IN VARCHAR2)
RETURN NUMBER IS--RETURN OKAY_STATUS IF success, or ERROR_STATUS IF fail

  CURSOR cur_ele_types IS
    SELECT t.element_type_id
      FROM CS_KB_SET_ELE_TYPES t, CS_KB_SETS_B s
     WHERE t.set_type_id = s.set_type_id
       AND s.set_id = CS_KB_SOLUTION_PVT.Get_Latest_Version_Id(p_set_number)
  ORDER BY t.element_type_order;

  CURSOR cur_eles(ele_type_id IN NUMBER) IS
    SELECT se.set_id, se.element_id
      FROM CS_KB_SET_ELES se, CS_KB_ELEMENTS_B el
     WHERE se.set_id = CS_KB_SOLUTION_PVT.Get_Latest_Version_Id(p_set_number)
       AND se.element_id = el.element_id
       AND el.element_type_id = ele_type_id
  ORDER BY se.element_order;

  l_counter PLS_INTEGER := 0;

BEGIN

  FOR rec_o IN cur_ele_types LOOP

    FOR rec_i IN cur_eles(rec_o.element_type_id) LOOP

      l_counter := l_counter + 1;

      UPDATE CS_KB_SET_ELES
         SET element_order = l_counter
       WHERE element_id = rec_i.element_id
         AND set_id = rec_i.set_id;

      IF (SQL%NOTFOUND) THEN
         RETURN ERROR_STATUS; -- Show error message: no permission to link this element
      END IF;
    END LOOP;

  END LOOP;

  RETURN OKAY_STATUS;

EXCEPTION
  WHEN OTHERS THEN
    RETURN ERROR_STATUS;
END Sort_Element_Order;


PROCEDURE Auto_Obsolete_Draft_Stmts(p_set_number  IN VARCHAR2,
                                    p_max_set_id  IN NUMBER) IS

l_count NUMBER(15);
l_prior_set_id NUMBER(15);
l_exists BOOLEAN;

Type element_id_tab_type     is TABLE OF CS_KB_ELEMENTS_B.ELEMENT_ID%TYPE INDEX BY BINARY_INTEGER;
Type element_status_tab_type is TABLE OF CS_KB_ELEMENTS_B.STATUS%TYPE INDEX BY BINARY_INTEGER;

l_prev_ver_elem_ids    element_id_tab_type;

l_max_ver_elem_ids     element_id_tab_type;

l_orphan_elem_ids      element_id_tab_type;

CURSOR get_elem_info(c_set_id IN NUMBER)
IS

   SELECT B.element_id from cs_kb_set_eles A, cs_kb_elements_b B, cs_kb_elements_tl C
   WHERE  A.set_id = c_set_id
   AND    B.element_id = A.element_id
   AND    B.element_id = C.element_id
   AND    B.status     = 'DRAFT'
   AND    C.language   = userenv('LANG');


CURSOR get_prev_set_id IS
select set_id
from cs_kb_sets_b
where set_id <> p_max_set_id
and set_number = p_set_number
order by creation_date desc;

BEGIN

Open get_elem_info(p_max_set_id);
l_count := 0;
Loop

   Fetch get_elem_info INTO l_max_ver_elem_ids(l_count);
   EXIT WHEN get_elem_info%NOTFOUND;
   l_count := l_count + 1;

End Loop;

Close get_elem_info;

-- Get the prior set id for this soultion

--BugFix 3993200 - sequence id fix
OPEN  get_prev_set_id;
FETCH get_prev_set_id INTO l_prior_set_id;
CLOSE get_prev_set_id;

IF (l_prior_set_id is NOT NULL)
THEN
  Open get_elem_info(l_prior_set_id);
  l_count := 0;
   Loop

     Fetch get_elem_info INTO l_prev_ver_elem_ids(l_count);
     EXIT WHEN get_elem_info%NOTFOUND;
     l_count := l_count + 1;

   End Loop;

   Close get_elem_info;

 -- Compute the difference at this point;
 -- First Get rid of the Unwanted Statments
    for j in 0..l_prev_ver_elem_ids.count-1
    loop
      l_exists := FALSE;
      for k in 0..l_max_ver_elem_ids.count-1
      loop
          IF (l_max_ver_elem_ids(k) = l_prev_ver_elem_ids(j))
         THEN
             l_exists := TRUE;
             EXIT;
         END IF;

      end loop;
      IF (l_exists = FALSE)
      THEN
          UPDATE CS_KB_ELEMENTS_B
          SET status = 'OBS'
          WHERE element_id = l_prev_ver_elem_ids(j);

      END IF;

    end loop;

END IF;

END Auto_Obsolete_Draft_Stmts;



PROCEDURE Auto_Obsolete_For_Solution_Pub(p_set_number  IN VARCHAR2,
                                         p_max_set_id  IN NUMBER) IS

Type element_id_tab_type     is TABLE OF CS_KB_ELEMENTS_B.ELEMENT_ID%TYPE INDEX BY BINARY_INTEGER;
Type element_status_tab_type is TABLE OF CS_KB_ELEMENTS_B.STATUS%TYPE INDEX BY BINARY_INTEGER;

l_max_set_id   NUMBER(15);
l_temp_set_id  NUMBER(15);
l_exists BOOLEAN;

l_prev_ver_elem_ids     element_id_tab_type;
l_prev_ver_elem_stats   element_status_tab_type;

l_max_ver_elem_ids     element_id_tab_type;
l_max_ver_elem_stats   element_status_tab_type;

l_orphan_elem_ids      element_id_tab_type;
l_orphan_elem_stats    element_status_tab_type;


l_count NUMBER(15);



CURSOR get_elem_info(c_set_id IN NUMBER)
IS

SELECT element_id from cs_kb_set_eles

WHERE set_id = c_set_id;



CURSOR get_elem_details(c_set_number IN VARCHAR2, c_set_id IN NUMBER)
IS

SELECT DISTINCT element_id from cs_kb_set_eles

WHERE set_id in
      (select set_id from cs_kb_sets_b where set_number = c_set_number
       and set_id < c_set_id);

BEGIN

Open get_elem_info(p_max_set_id);
l_count := 0;
Loop

   Fetch get_elem_info INTO l_max_ver_elem_ids(l_count);
   EXIT WHEN get_elem_info%NOTFOUND;
   l_count := l_count + 1;

End Loop;

Close get_elem_info;


Open  get_elem_details(p_set_number, p_max_set_id);
l_count := 0;
Loop

   Fetch get_elem_details INTO l_prev_ver_elem_ids(l_count);
   EXIT WHEN get_elem_details%NOTFOUND;
   l_count := l_count + 1;

End Loop;

CLOSE get_elem_details;


 -- Compute the difference at this point;

 -- First Get rid of the Unwanted Statments


    for j in 0..l_prev_ver_elem_ids.count-1
    loop
    l_exists := FALSE;
      for k in 0..l_max_ver_elem_ids.count-1
      loop

         IF (l_max_ver_elem_ids(k) = l_prev_ver_elem_ids(j))
         THEN
             l_exists := TRUE;
             EXIT;
         END IF;

      end loop;
      IF (l_exists = FALSE)
      THEN

        -- Call to Obsolete the Statement  l_prev_ver_elem_ids(j)
        Obs_Elmt_Status_With_Check(l_prev_ver_elem_ids(j));

      END IF;

    end loop;

END Auto_Obsolete_For_Solution_Pub;


-- BugFix 3993200 - Sequence id fix
-- Replace above Function with new code below:
FUNCTION Is_Pub_Element_Obsoletable(p_element_id IN NUMBER)
RETURN NUMBER IS

CURSOR Get_solns IS
SELECT count(se.Set_id)
FROM CS_KB_SET_ELES se
WHERE se.ELEMENT_ID = p_element_id
AND EXISTS (Select 'x'
            From CS_KB_SETS_B s
            WHERE s.Set_id = se.set_id
            AND (s.latest_version_flag = 'Y'
                 OR s.viewable_version_flag = 'Y')
            );
l_count NUMBER;

BEGIN

 -- Check if any Solutions contain Statement p_element_id
 -- This includes all Latest Draft and Viewable Solution Versions
 OPEN  Get_solns;
 FETCH Get_solns INTO l_count;
 CLOSE Get_solns;

 IF l_count = 0 THEN
   -- No Solutions exist. 1 = Statement can be Obsoleted
   RETURN 1;
 ELSE
   -- At leate One Solution exists. 0 = Statement should NOT be Obsoleted
   RETURN 0;
 END IF;

END;


Procedure Auto_Obsolete_For_Solution_Obs(p_set_number  IN VARCHAR2,
                                         p_max_set_id  IN NUMBER) IS



l_element_id NUMBER(15);

CURSOR get_elem_info(c_set_id IN NUMBER)
IS

SELECT element_id from cs_kb_set_eles

WHERE set_id = c_set_id;


BEGIN


  -- Possibly Obsolete statements in prev versions

     Auto_Obsolete_For_Solution_Pub(p_set_number => p_set_number,
                                    p_max_set_id => p_max_set_id);

  -- Possibly obsolete the statements linked to this version;

     Open get_elem_info(p_max_set_id);

     Loop

       Fetch get_elem_info INTO l_element_id;
       EXIT WHEN get_elem_info%NOTFOUND;

       Obs_Elmt_Status_With_Check(l_element_id);


     End Loop;

     Close get_elem_info;




END Auto_Obsolete_For_Solution_Obs;


PROCEDURE Obs_Elmt_Status_With_Check(p_element_id IN NUMBER) IS

l_status VARCHAR2(30);

BEGIN

  select status INTO l_status
  from cs_kb_elements_b
  where element_id = p_element_id;

  IF (l_status = 'DRAFT')
  THEN
    UPDATE CS_KB_ELEMENTS_B
    SET status = 'OBS'
    WHERE element_id = p_element_id;
  ELSIF (l_status = 'PUBLISHED')
  THEN
    IF (Is_Pub_Element_Obsoletable(p_element_id) = 1)
    THEN
      UPDATE CS_KB_ELEMENTS_B
      SET status = 'OBS'
      WHERE element_id = p_element_id;

    END IF;
  END IF;


END Obs_Elmt_Status_With_Check;

PROCEDURE Transfer_Note_To_Element(p_note_id IN NUMBER, p_element_id IN NUMBER)
IS
l_clob1 clob;
l_clob2 clob;
BEGIN
  select notes_detail
    into l_clob1
    from jtf_notes_tl
    where jtf_note_id = p_note_id
      and language = USERENV('LANG');

  select description
    into l_clob2
    from cs_kb_elements_tl
    where element_id = p_element_id
      and language = USERENV('LANG')
      for update;

  DBMS_LOB.TRIM(l_clob2, 0);
  DBMS_LOB.COPY(l_clob2, l_clob1, DBMS_LOB.GETLENGTH(l_clob1));

  JTF_NOTES_PKG.DELETE_ROW(p_note_id);

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    NULL;

END Transfer_Note_To_Element;

FUNCTION Get_Concatenated_Elmt_Details(p_set_id IN NUMBER) RETURN CLOB IS
l_clob_loc CLOB;
l_temp_clob_loc CLOB;

CURSOR C1(c_set_id IN NUMBER) IS
SELECT description from cs_kb_elements_tl, cs_kb_set_eles
where  cs_kb_set_eles.set_id = c_set_id
AND    cs_kb_set_eles.element_id = cs_kb_elements_tl.element_id
and    cs_kb_elements_tl.language = USERENV('LANG');

BEGIN
dbms_lob.CREATETEMPORARY(l_clob_loc, TRUE, DBMS_LOB.session);
DBMS_LOB.TRIM(l_clob_loc, 0);

open c1(p_set_id);
loop
  fetch c1 INTO l_temp_CLOB_LOC;
  exit when c1%NOTFOUND;
  dbms_lob.append(l_clob_loc, l_temp_clob_loc);
  dbms_lob.writeappend(l_clob_loc, 1, ' ');
end loop;
close c1;
return l_clob_loc;
END Get_Concatenated_Elmt_Details;

/*
 * forwards to Create_Set_With_Validation_2
 */
FUNCTION Create_Set_With_Validation
(
  p_api_version          in  number,
  p_init_msg_list        in  varchar2 := FND_API.G_FALSE,
  p_commit               in  varchar2 := FND_API.G_FALSE,
  p_validation_level     in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT NOCOPY varchar2,
  x_msg_count            OUT NOCOPY number,
  x_msg_data             OUT NOCOPY varchar2,
  p_set_type_name        in  varchar2,
  p_set_visibility       in  varchar2,
  p_set_title            in  varchar2,
  p_set_flow_name        in VARCHAR2,
  p_set_flow_stepcode    in VARCHAR2,
  p_set_products         in  JTF_VARCHAR2_TABLE_2000,
  p_set_platforms        in  JTF_VARCHAR2_TABLE_2000,
  p_set_categories       in  JTF_VARCHAR2_TABLE_2000,
  p_ele_type_name_tbl    in  JTF_VARCHAR2_TABLE_2000,
  p_ele_dist_tbl         in  JTF_VARCHAR2_TABLE_2000,
  p_ele_content_type_tbl in  JTF_VARCHAR2_TABLE_2000,
  p_ele_summary_tbl      in  JTF_VARCHAR2_TABLE_2000,
  p_ele_nos_tbl              in  JTF_VARCHAR2_TABLE_2000,
  p_ele_nos_upd_tbl	 in  JTF_VARCHAR2_TABLE_2000,
  p_ele_dist_upd_tbl         in  JTF_VARCHAR2_TABLE_2000,
  p_ele_content_type_upd_tbl in  JTF_VARCHAR2_TABLE_2000,
  p_ele_summary_upd_tbl      in  JTF_VARCHAR2_TABLE_2000,
  p_set_category_last_names in JTF_VARCHAR2_TABLE_2000,
  x_created_ele_ids_tbl  OUT NOCOPY JTF_NUMBER_TABLE,
  x_ele_ids_upd_tbl      OUT NOCOPY JTF_NUMBER_TABLE,
  x_set_number           OUT NOCOPY VARCHAR2) RETURN NUMBER IS

BEGIN

  RETURN Create_Set_With_Validation_2(
          p_api_version,
          p_init_msg_list,
          p_commit,
          p_validation_level,
          x_return_status,
          x_msg_count,
          x_msg_data,
          p_set_type_name,
          p_set_visibility,
          p_set_title,
          p_set_flow_name,
          p_set_flow_stepcode,
          p_set_products,
          p_set_platforms,
          p_set_categories,
          p_ele_type_name_tbl,
          p_ele_dist_tbl,
          p_ele_content_type_tbl,
          p_ele_summary_tbl,
          p_ele_nos_tbl,
          p_ele_nos_upd_tbl,
          p_ele_dist_upd_tbl,
          p_ele_content_type_upd_tbl,
          p_ele_summary_upd_tbl,
          p_set_category_last_names,
          x_created_ele_ids_tbl,
          x_ele_ids_upd_tbl,
          x_set_number,
          '>');

END Create_Set_With_Validation;

FUNCTION Create_Set_With_Validation_2
(
  p_api_version          in  number,
  p_init_msg_list        in  varchar2 := FND_API.G_FALSE,
  p_commit               in  varchar2 := FND_API.G_FALSE,
  p_validation_level     in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT NOCOPY varchar2,
  x_msg_count            OUT NOCOPY number,
  x_msg_data             OUT NOCOPY varchar2,
  p_set_type_name        in  varchar2,
  p_set_visibility       in  varchar2,
  p_set_title            in  varchar2,
  p_set_flow_name        in VARCHAR2,
  p_set_flow_stepcode    in VARCHAR2,
  p_set_products         in  JTF_VARCHAR2_TABLE_2000,
  p_set_platforms        in  JTF_VARCHAR2_TABLE_2000,
  p_set_categories       in  JTF_VARCHAR2_TABLE_2000,
  p_ele_type_name_tbl    in  JTF_VARCHAR2_TABLE_2000,
  p_ele_dist_tbl         in  JTF_VARCHAR2_TABLE_2000,
  p_ele_content_type_tbl in  JTF_VARCHAR2_TABLE_2000,
  p_ele_summary_tbl      in  JTF_VARCHAR2_TABLE_2000,
  p_ele_nos_tbl              in  JTF_VARCHAR2_TABLE_2000,
  p_ele_nos_upd_tbl	 in  JTF_VARCHAR2_TABLE_2000,
  p_ele_dist_upd_tbl         in  JTF_VARCHAR2_TABLE_2000,
  p_ele_content_type_upd_tbl in  JTF_VARCHAR2_TABLE_2000,
  p_ele_summary_upd_tbl      in  JTF_VARCHAR2_TABLE_2000,
  p_set_category_last_names in JTF_VARCHAR2_TABLE_2000,
  x_created_ele_ids_tbl  OUT NOCOPY JTF_NUMBER_TABLE,
  x_ele_ids_upd_tbl      OUT NOCOPY JTF_NUMBER_TABLE,
  x_set_number           OUT NOCOPY VARCHAR2,
  p_delim                  IN VARCHAR2
  ) RETURN NUMBER IS
  l_set_product_segments JTF_VARCHAR2_TABLE_2000;
  l_set_platform_segments JTF_VARCHAR2_TABLE_2000;
BEGIN
  l_set_product_segments := JTF_VARCHAR2_TABLE_2000();
  l_set_platform_segments := JTF_VARCHAR2_TABLE_2000();
  --If p_set_products is not empty, set l_set_product_segments to the same
  --size and filled with ''. The same for platforms.
  if(p_set_products.count>0) then
    l_set_product_segments.extend(p_set_products.count);
    for i in 1..p_set_products.count loop
      l_set_product_segments(i) := '';
    end loop;
  end if;

  if (p_set_platforms.count>0) then
    l_set_platform_segments.extend(p_set_platforms.count);
    for i in 1..p_set_platforms.count loop
      l_set_platform_segments(i) := '';
    end loop;
  end if;

  RETURN Create_Set_With_Validation_3(
          p_api_version,
          p_init_msg_list,
          p_commit,
          p_validation_level,
          x_return_status,
          x_msg_count,
          x_msg_data,
          p_set_type_name,
          p_set_visibility,
          p_set_title,
          p_set_flow_name,
          p_set_flow_stepcode,
          p_set_products,
          l_set_product_segments,
          p_set_platforms,
          l_set_platform_segments,
          p_set_categories,
          p_ele_type_name_tbl,
          p_ele_dist_tbl,
          p_ele_content_type_tbl,
          p_ele_summary_tbl,
          p_ele_nos_tbl,
          p_ele_nos_upd_tbl,
          p_ele_dist_upd_tbl,
          p_ele_content_type_upd_tbl,
          p_ele_summary_upd_tbl,
          p_set_category_last_names,
          x_created_ele_ids_tbl,
          x_ele_ids_upd_tbl,
          x_set_number,
          '>');

END Create_Set_With_Validation_2;

/*
 * forwards to Update_Set_With_Validation_2
 */
FUNCTION Update_Set_With_Validation
(
  p_api_version          in  number,
  p_init_msg_list        in  varchar2 := FND_API.G_FALSE,
  p_commit               in  varchar2 := FND_API.G_FALSE,
  p_validation_level     in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT NOCOPY varchar2,
  x_msg_count            OUT NOCOPY number,
  x_msg_data             OUT NOCOPY varchar2,
  p_set_number           in  varchar2,
  p_set_type_name        in  varchar2,
  p_set_visibility       in  varchar2,
  p_set_title            in  varchar2,
  p_set_products         in  JTF_VARCHAR2_TABLE_2000,
  p_set_platforms        in  JTF_VARCHAR2_TABLE_2000,
  p_set_categories       in  JTF_VARCHAR2_TABLE_2000,
  p_ele_type_name_tbl    in  JTF_VARCHAR2_TABLE_2000,
  p_ele_dist_tbl         in  JTF_VARCHAR2_TABLE_2000,
  p_ele_content_type_tbl in  JTF_VARCHAR2_TABLE_2000,
  p_ele_summary_tbl      in  JTF_VARCHAR2_TABLE_2000,
  p_ele_nos_tbl          in  JTF_VARCHAR2_TABLE_2000,
  p_ele_nos_upd_tbl      in  JTF_VARCHAR2_TABLE_2000,
  p_ele_dist_upd_tbl         in  JTF_VARCHAR2_TABLE_2000,
  p_ele_content_type_upd_tbl in  JTF_VARCHAR2_TABLE_2000,
  p_ele_summary_upd_tbl      in  JTF_VARCHAR2_TABLE_2000,
  p_set_category_last_names in JTF_VARCHAR2_TABLE_2000,
  x_created_ele_ids_tbl  OUT NOCOPY JTF_NUMBER_TABLE,
  x_ele_ids_upd_tbl      OUT NOCOPY JTF_NUMBER_TABLE,
  x_set_id               OUT NOCOPY number) RETURN NUMBER IS

BEGIN
  RETURN Update_Set_With_Validation_2(
          p_api_version,
          p_init_msg_list,
          p_commit,
          p_validation_level,
          x_return_status,
          x_msg_count,
          x_msg_data,
          p_set_number,
          p_set_type_name,
          p_set_visibility,
          p_set_title,
          p_set_products,
          p_set_platforms,
          p_set_categories,
          p_ele_type_name_tbl,
          p_ele_dist_tbl,
          p_ele_content_type_tbl,
          p_ele_summary_tbl,
          p_ele_nos_tbl,
          p_ele_nos_upd_tbl,
          p_ele_dist_upd_tbl,
          p_ele_content_type_upd_tbl,
          p_ele_summary_upd_tbl,
          p_set_category_last_names,
          x_created_ele_ids_tbl,
          x_ele_ids_upd_tbl,
          x_set_id,
          '>');

END Update_Set_With_validation;

/*
* This one takes delimeter
*/
FUNCTION Update_Set_With_Validation_2
(
  p_api_version          in  number,
  p_init_msg_list        in  varchar2 := FND_API.G_FALSE,
  p_commit               in  varchar2 := FND_API.G_FALSE,
  p_validation_level     in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT NOCOPY varchar2,
  x_msg_count            OUT NOCOPY number,
  x_msg_data             OUT NOCOPY varchar2,
  p_set_number           in  varchar2,
  p_set_type_name        in  varchar2,
  p_set_visibility       in  varchar2,
  p_set_title            in  varchar2,
  p_set_products         in  JTF_VARCHAR2_TABLE_2000,
  p_set_platforms        in  JTF_VARCHAR2_TABLE_2000,
  p_set_categories       in  JTF_VARCHAR2_TABLE_2000,
  p_ele_type_name_tbl    in  JTF_VARCHAR2_TABLE_2000,
  p_ele_dist_tbl         in  JTF_VARCHAR2_TABLE_2000,
  p_ele_content_type_tbl in  JTF_VARCHAR2_TABLE_2000,
  p_ele_summary_tbl      in  JTF_VARCHAR2_TABLE_2000,
  p_ele_nos_tbl          in  JTF_VARCHAR2_TABLE_2000,
  p_ele_nos_upd_tbl      in  JTF_VARCHAR2_TABLE_2000,
  p_ele_dist_upd_tbl         in  JTF_VARCHAR2_TABLE_2000,
  p_ele_content_type_upd_tbl in  JTF_VARCHAR2_TABLE_2000,
  p_ele_summary_upd_tbl      in  JTF_VARCHAR2_TABLE_2000,
  p_set_category_last_names in JTF_VARCHAR2_TABLE_2000,
  x_created_ele_ids_tbl  OUT NOCOPY JTF_NUMBER_TABLE,
  x_ele_ids_upd_tbl      OUT NOCOPY JTF_NUMBER_TABLE,
  x_set_id               OUT NOCOPY number,
  p_delim                  IN VARCHAR2
) RETURN NUMBER IS
  l_set_product_segments JTF_VARCHAR2_TABLE_2000;
  l_set_platform_segments JTF_VARCHAR2_TABLE_2000;
BEGIN
  l_set_product_segments := JTF_VARCHAR2_TABLE_2000();
  l_set_platform_segments := JTF_VARCHAR2_TABLE_2000();
  --If p_set_products is not empty, set l_set_product_segments to the same
  --size and filled with ''. The same for platforms.
  if(p_set_products.count>0) then
    l_set_product_segments.extend(p_set_products.count);
    for i in 1..p_set_products.count loop
      l_set_product_segments(i) := '';
    end loop;
  end if;

  if (p_set_platforms.count>0) then
    l_set_platform_segments.extend(p_set_platforms.count);
    for i in 1..p_set_platforms.count loop
      l_set_platform_segments(i) := '';
    end loop;
  end if;

  RETURN Update_Set_With_Validation_3(
          p_api_version,
          p_init_msg_list,
          p_commit,
          p_validation_level,
          x_return_status,
          x_msg_count,
          x_msg_data,
          p_set_number,
          p_set_type_name,
          p_set_visibility,
          p_set_title,
          p_set_products,
          l_set_product_segments,
          p_set_platforms,
          l_set_platform_segments,
          p_set_categories,
          p_ele_type_name_tbl,
          p_ele_dist_tbl,
          p_ele_content_type_tbl,
          p_ele_summary_tbl,
          p_ele_nos_tbl,
          p_ele_nos_upd_tbl,
          p_ele_dist_upd_tbl,
          p_ele_content_type_upd_tbl,
          p_ele_summary_upd_tbl,
          p_set_category_last_names,
          x_created_ele_ids_tbl,
          x_ele_ids_upd_tbl,
          x_set_id,
          '>');

END Update_Set_With_validation_2;

/*
 * forwards to VALIDATE_SOLN_ATTRIBUTES_2
 */
FUNCTION VALIDATE_SOLN_ATTRIBUTES
(
  p_set_type_id       IN  NUMBER,
  p_visibility_name IN  VARCHAR2,
  p_product_names   IN  JTF_VARCHAR2_TABLE_2000,
  p_platform_names   IN  JTF_VARCHAR2_TABLE_2000,
  p_category_names   IN  JTF_VARCHAR2_TABLE_2000,
  p_category_last_names IN  JTF_VARCHAR2_TABLE_2000,
  p_ele_nums          IN  JTF_VARCHAR2_TABLE_2000,
  p_ele_upd_nums        IN  JTF_VARCHAR2_TABLE_2000,
  p_ele_upd_content_types    IN  JTF_VARCHAR2_TABLE_2000,
  p_ele_upd_dist_names     IN JTF_VARCHAR2_TABLE_2000,
  p_element_type_names IN  JTF_VARCHAR2_TABLE_2000,
  p_ele_content_types    IN  JTF_VARCHAR2_TABLE_2000,
  p_ele_dist_names  IN JTF_VARCHAR2_TABLE_2000,
  x_visibility_id      OUT NOCOPY NUMBER,
  x_product_numbers OUT NOCOPY JTF_NUMBER_TABLE,
  x_platform_numbers OUT NOCOPY JTF_NUMBER_TABLE,
  x_category_numbers OUT NOCOPY JTF_NUMBER_TABLE,
  x_ele_ids           OUT NOCOPY JTF_NUMBER_TABLE,
  x_ele_upd_ids         OUT NOCOPY JTF_NUMBER_TABLE,
  x_element_type_ids  OUT NOCOPY JTF_NUMBER_TABLE,
  x_ele_dist_ids    OUT NOCOPY JTF_VARCHAR2_TABLE_2000,
  x_ele_content_type_codes OUT NOCOPY JTF_VARCHAR2_TABLE_2000,
  x_ele_upd_type_ids  OUT NOCOPY JTF_NUMBER_TABLE,
  x_ele_upd_dist_ids    OUT NOCOPY JTF_VARCHAR2_TABLE_2000,
  x_ele_upd_content_type_codes OUT NOCOPY JTF_VARCHAR2_TABLE_2000,
  x_return_status       OUT NOCOPY  varchar2,
  x_msg_count           OUT NOCOPY  number,
  x_msg_data            OUT NOCOPY  varchar2

) RETURN NUMBER IS

BEGIN
  RETURN VALIDATE_SOLN_ATTRIBUTES_2(
          p_set_type_id,
          p_visibility_name,
          p_product_names,
          p_platform_names,
          p_category_names,
          p_category_last_names,
          p_ele_nums,
          p_ele_upd_nums,
          p_ele_upd_content_types,
          p_ele_upd_dist_names,
          p_element_type_names,
          p_ele_content_types,
          p_ele_dist_names,
          x_visibility_id,
          x_product_numbers,
          x_platform_numbers,
          x_category_numbers,
          x_ele_ids,
          x_ele_upd_ids,
          x_element_type_ids,
          x_ele_dist_ids,
          x_ele_content_type_codes,
          x_ele_upd_type_ids,
          x_ele_upd_dist_ids,
          x_ele_upd_content_type_codes,
          x_return_status,
          x_msg_count,
          x_msg_data,
          '>');

END VALIDATE_SOLN_ATTRIBUTES;

FUNCTION VALIDATE_SOLN_ATTRIBUTES_2
(
  p_set_type_id       IN  NUMBER,
  p_visibility_name IN  VARCHAR2,
  p_product_names   IN  JTF_VARCHAR2_TABLE_2000,
  p_platform_names   IN  JTF_VARCHAR2_TABLE_2000,
  p_category_names   IN  JTF_VARCHAR2_TABLE_2000,
  p_category_last_names IN  JTF_VARCHAR2_TABLE_2000,
  p_ele_nums          IN  JTF_VARCHAR2_TABLE_2000,
  p_ele_upd_nums        IN  JTF_VARCHAR2_TABLE_2000,
  p_ele_upd_content_types    IN  JTF_VARCHAR2_TABLE_2000,
  p_ele_upd_dist_names     IN JTF_VARCHAR2_TABLE_2000,
  p_element_type_names IN  JTF_VARCHAR2_TABLE_2000,
  p_ele_content_types    IN  JTF_VARCHAR2_TABLE_2000,
  p_ele_dist_names  IN JTF_VARCHAR2_TABLE_2000,
  x_visibility_id      OUT NOCOPY NUMBER,
  x_product_numbers OUT NOCOPY JTF_NUMBER_TABLE,
  x_platform_numbers OUT NOCOPY JTF_NUMBER_TABLE,
  x_category_numbers OUT NOCOPY JTF_NUMBER_TABLE,
  x_ele_ids           OUT NOCOPY JTF_NUMBER_TABLE,
  x_ele_upd_ids         OUT NOCOPY JTF_NUMBER_TABLE,
  x_element_type_ids  OUT NOCOPY JTF_NUMBER_TABLE,
  x_ele_dist_ids    OUT NOCOPY JTF_VARCHAR2_TABLE_2000,
  x_ele_content_type_codes OUT NOCOPY JTF_VARCHAR2_TABLE_2000,
  x_ele_upd_type_ids  OUT NOCOPY JTF_NUMBER_TABLE,
  x_ele_upd_dist_ids    OUT NOCOPY JTF_VARCHAR2_TABLE_2000,
  x_ele_upd_content_type_codes OUT NOCOPY JTF_VARCHAR2_TABLE_2000,
  x_return_status       OUT NOCOPY  varchar2,
  x_msg_count           OUT NOCOPY  number,
  x_msg_data            OUT NOCOPY  varchar2,
  p_delim                  IN VARCHAR2

) RETURN NUMBER IS
l_product_segments JTF_VARCHAR2_TABLE_2000;
l_platform_segments JTF_VARCHAR2_TABLE_2000;
BEGIN
    l_product_segments := JTF_VARCHAR2_TABLE_2000();
    l_platform_segments := JTF_VARCHAR2_TABLE_2000();
  RETURN VALIDATE_SOLN_ATTRIBUTES_3(
          p_set_type_id,
          p_visibility_name,
          p_product_names,
          l_product_segments,
          p_platform_names,
          l_platform_segments,
          p_category_names,
          p_category_last_names,
          p_ele_nums,
          p_ele_upd_nums,
          p_ele_upd_content_types,
          p_ele_upd_dist_names,
          p_element_type_names,
          p_ele_content_types,
          p_ele_dist_names,
          x_visibility_id,
          x_product_numbers,
          x_platform_numbers,
          x_category_numbers,
          x_ele_ids,
          x_ele_upd_ids,
          x_element_type_ids,
          x_ele_dist_ids,
          x_ele_content_type_codes,
          x_ele_upd_type_ids,
          x_ele_upd_dist_ids,
          x_ele_upd_content_type_codes,
          x_return_status,
          x_msg_count,
          x_msg_data,
          '>');

END VALIDATE_SOLN_ATTRIBUTES_2;
/*
This is the same as the original create_set_with_validation, except it takes a delimiter param
*/
FUNCTION Create_Set_With_Validation_3
(
  p_api_version          in  number,
  p_init_msg_list        in  varchar2 := FND_API.G_FALSE,
  p_commit               in  varchar2 := FND_API.G_FALSE,
  p_validation_level     in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT NOCOPY varchar2,
  x_msg_count            OUT NOCOPY number,
  x_msg_data             OUT NOCOPY varchar2,
  p_set_type_name        in  varchar2,
  p_set_visibility       in  varchar2,
  p_set_title            in  varchar2,
  p_set_flow_name        in VARCHAR2,
  p_set_flow_stepcode    in VARCHAR2,
  p_set_products         in  JTF_VARCHAR2_TABLE_2000,
  p_set_product_segments    in  JTF_VARCHAR2_TABLE_2000,
  p_set_platforms        in  JTF_VARCHAR2_TABLE_2000,
  p_set_platform_segments   in  JTF_VARCHAR2_TABLE_2000,
  p_set_categories       in  JTF_VARCHAR2_TABLE_2000,
  p_ele_type_name_tbl    in  JTF_VARCHAR2_TABLE_2000,
  p_ele_dist_tbl         in  JTF_VARCHAR2_TABLE_2000,
  p_ele_content_type_tbl in  JTF_VARCHAR2_TABLE_2000,
  p_ele_summary_tbl      in  JTF_VARCHAR2_TABLE_2000,
  p_ele_nos_tbl              in  JTF_VARCHAR2_TABLE_2000,
  p_ele_nos_upd_tbl	 in  JTF_VARCHAR2_TABLE_2000,
  p_ele_dist_upd_tbl         in  JTF_VARCHAR2_TABLE_2000,
  p_ele_content_type_upd_tbl in  JTF_VARCHAR2_TABLE_2000,
  p_ele_summary_upd_tbl      in  JTF_VARCHAR2_TABLE_2000,
  p_set_category_last_names in JTF_VARCHAR2_TABLE_2000,
  x_created_ele_ids_tbl  OUT NOCOPY JTF_NUMBER_TABLE,
  x_ele_ids_upd_tbl      OUT NOCOPY JTF_NUMBER_TABLE,
  x_set_number           OUT NOCOPY VARCHAR2,
  p_delim                  IN VARCHAR2
  ) RETURN NUMBER IS

l_set_id            number;
l_set_type_id       NUMBER;
l_set_access_level  VARCHAR2(2000);
l_set_visibility_id NUMBER;
l_element_ids  JTF_NUMBER_TABLE;
l_element_type_ids  JTF_NUMBER_TABLE;
l_element_dist_ids  JTF_VARCHAR2_TABLE_2000;
l_element_content_type_codes JTF_VARCHAR2_TABLE_2000;
l_ele_type_id_upd_tbl JTF_NUMBER_TABLE;
l_ele_dist_id_upd_tbl JTF_VARCHAR2_TABLE_2000;
l_ele_conttype_codes_upd_tbl JTF_VARCHAR2_TABLE_2000;
l_set_product_ids   JTF_NUMBER_TABLE;
l_set_platform_ids  JTF_NUMBER_TABLE;
l_set_category_ids  JTF_NUMBER_TABLE;
l_set_product_org_ids  JTF_NUMBER_TABLE;
l_set_platform_org_ids JTF_NUMBER_TABLE;
l_temp_clob         CLOB;
l_flow_details_id	number := null;
l_validate_buf      VARCHAR2(1000);
l_return_val NUMBER;
l_return_status VARCHAR2(1);
l_msg_data      VARCHAR2(2000);
l_msg_count     NUMBER;

BEGIN

   SAVEPOINT Create_Set;

   x_created_ele_ids_tbl := JTF_NUMBER_TABLE();
   x_ele_ids_upd_tbl	 := JTF_NUMBER_TABLE();
   l_element_ids	 := JTF_NUMBER_TABLE();
   l_element_type_ids    := JTF_NUMBER_TABLE();
   l_element_dist_ids    := JTF_VARCHAR2_TABLE_2000();
   l_element_content_type_codes := JTF_VARCHAR2_TABLE_2000();
   l_ele_type_id_upd_tbl := JTF_NUMBER_TABLE();
   l_ele_dist_id_upd_tbl := JTF_VARCHAR2_TABLE_2000();
   l_ele_conttype_codes_upd_tbl := JTF_VARCHAR2_TABLE_2000();
   l_set_product_ids     := JTF_NUMBER_TABLE();
   l_set_platform_ids    := JTF_NUMBER_TABLE();
   l_set_category_ids    := JTF_NUMBER_TABLE();
   l_set_product_org_ids :=  JTF_NUMBER_TABLE();
   l_set_platform_org_ids := JTF_NUMBER_TABLE();

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Validate Set Type Name, get Set Type ID
   l_validate_buf := p_set_type_name;
   l_return_val := Validate_Set_Type_Name_Create(p_set_type_name,
                                          l_set_type_id);
   IF (l_return_val = ERROR_STATUS)
     THEN RAISE INVALID_SET_TYPE_NAME;
   END IF;

   -- validate flow info if provided
   IF (p_set_flow_name IS NOT NULL) AND (p_set_flow_stepcode IS NOT NULL) THEN
       l_return_val := Validate_Flow (
  		p_flow_name   => p_set_flow_name,
  		p_flow_step   => p_set_flow_stepcode,
  		x_flow_details_id => l_flow_details_id);

       IF (l_return_val = ERROR_STATUS)
     		THEN RAISE INVALID_FLOW;
       END IF;
   END IF;

   -- validate all other attributes
   l_return_val := VALIDATE_SOLN_ATTRIBUTES_3 (
  	p_set_type_id       	=> l_set_type_id,
  	p_visibility_name 	=> p_set_visibility,
    p_product_names         => p_set_products,
    p_product_segments         => p_set_product_segments,
    p_platform_names        => p_set_platforms,
    p_platform_segments        => p_set_platform_segments,
  	p_category_names   	=> p_set_categories,
  	p_category_last_names 	=> p_set_category_last_names,
  	p_ele_nums          	=> p_ele_nos_tbl,
        p_ele_upd_nums          => p_ele_nos_upd_tbl,
  	p_ele_upd_content_types => p_ele_content_type_upd_tbl,
  	p_ele_upd_dist_names    => p_ele_dist_upd_tbl,
  	p_element_type_names 	=> p_ele_type_name_tbl,
  	p_ele_content_types    	=> p_ele_content_type_tbl,
  	p_ele_dist_names  	=> p_ele_dist_tbl,
        x_visibility_id         => l_set_visibility_id,
  	x_product_numbers 	=> l_set_product_ids,
  	x_platform_numbers 	=> l_set_platform_ids,
  	x_category_numbers 	=> l_set_category_ids,
  	x_ele_ids           	=> l_element_ids,
        x_ele_upd_ids           => x_ele_ids_upd_tbl,
  	x_element_type_ids  	=> l_element_type_ids,
  	x_ele_dist_ids    	=> l_element_dist_ids,
	x_ele_content_type_codes =>l_element_content_type_codes,
  	x_ele_upd_type_ids  	=> l_ele_type_id_upd_tbl,
  	x_ele_upd_dist_ids    	=> l_ele_dist_id_upd_tbl,
        x_ele_upd_content_type_codes => l_ele_conttype_codes_upd_tbl,
  	x_return_status       	=> x_return_status,
  	x_msg_count           	=> x_msg_count,
  	x_msg_data            	=> x_msg_data,
    p_delim                   => p_delim
   );

   -- dbms_output.put_line('return from VALIDATE='||l_return_val);
   IF (x_msg_count = 1) THEN
      RAISE VALIDATION_ERROR;
   END IF;

   -- Start Creation at this point
   CS_KB_SOLUTION_PVT.Create_Solution
               ( p_set_type_id   => l_set_type_id,
                 p_name          => p_set_title,
                 p_visibility_id => l_set_visibility_id,
                 x_set_id        => l_set_id,
                 x_set_number    => x_set_number,
                 x_return_status => l_return_status,
                 x_msg_data      => l_msg_data,
                 x_msg_count     => l_msg_count );

   -- dbms_output.put_line('created x_set_id='||l_set_id);
   if( (l_return_status = FND_API.G_RET_STS_ERROR) or
       (l_set_id <= 0) ) then
     raise FND_API.G_EXC_ERROR;
   elsif ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) then
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- link set with statements, products, categories, platforms, etc.
   -- also create new statements if info provided
   l_return_val := Link_Soln_Attributes(
        p_validate_type	      => 'CREATE',
  	p_set_id              => l_set_id,
  	p_given_element_ids   => x_ele_ids_upd_tbl,
  	p_given_ele_nums      => p_ele_nos_upd_tbl,
  	p_given_ele_type_ids  => l_ele_type_id_upd_tbl,
  	p_given_ele_dist_ids  => l_ele_dist_id_upd_tbl,
  	p_given_ele_content_types => l_ele_conttype_codes_upd_tbl,
  	p_given_ele_summaryies => p_ele_summary_upd_tbl,
	p_element_ids   	=> l_element_ids,
  	p_element_type_ids    => l_element_type_ids,
  	p_element_dist_ids    => l_element_dist_ids,
  	p_element_content_types => l_element_content_type_codes,
  	p_element_summaries   => p_ele_summary_tbl,
  	p_element_dummy_detail => l_temp_clob,
  	p_set_product_ids     => l_set_product_ids,
  	p_set_platform_ids    => l_set_platform_ids,
  	p_set_category_ids    => l_set_category_ids,
  	x_created_element_ids => x_created_ele_ids_tbl,
  	x_return_status       => x_return_status,
  	x_msg_count           => x_msg_count,
  	x_msg_data            => x_msg_data);

   -- update set with flow info and status.
   IF (l_flow_details_id IS NOT NULL) THEN
     if( Get_Missing_Ele_Type( l_set_id ) = 'N' ) then
       --l_set_id := CS_KB_SOLUTION_PVT.clone_solution(x_set_number,
         --                               'PUB', l_flow_details_id, null);
	    null ;
	    --bug fix 6034639 commented the above code.
     else
       raise MANDATORY_STATEMENT_MISSING;
     end if;
   END IF;

   -- dbms_output.put_line('return from LINK='||l_return_val);

   x_return_status := fnd_api.g_ret_sts_success;
   x_msg_count := 0;
   x_msg_data := null;
   RETURN OKAY_STATUS;

EXCEPTION

  WHEN VALIDATION_ERROR THEN
     /*
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count     := 1;
     x_msg_data      := 'Invalid Set Type Name : ' || p_set_type_name;
     */

     RETURN ERROR_STATUS;

  WHEN MANDATORY_STATEMENT_MISSING  THEN
     ROLLBACK TO Create_Set;
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count     := 1;
     x_msg_data      := 'Mandatory Statements Missing.';

     RETURN ERROR_STATUS;

  WHEN INVALID_SET_TYPE_NAME  THEN
     ROLLBACK TO Create_Set;
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count     := 1;
     x_msg_data      := 'Invalid Set Type Name : ' || p_set_type_name;

     RETURN ERROR_STATUS;

  WHEN INVALID_FLOW THEN
     ROLLBACK TO Create_Set;
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count     := 1;
     x_msg_data      := 'Invalid flow: ' || p_set_flow_name ||
		' or step: ' || p_set_flow_stepcode;

     RETURN ERROR_STATUS;

  WHEN DUPLICATE_SET_NAME  THEN
     ROLLBACK TO Create_Set;
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count     := 1;
     x_msg_data      := 'Duplicate Solution Name:' || l_validate_buf;

     RETURN ERROR_STATUS;

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Create_Set;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);
      RETURN ERROR_STATUS;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Create_Set;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE ,
      p_count => x_msg_count,
      p_data  => x_msg_data);
      RETURN ERROR_STATUS;

   WHEN OTHERS THEN
      ROLLBACK TO Create_Set;
      x_msg_data      := 'Creating solution: ' || SQLERRM ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_msg_count := 1;
      RETURN ERROR_STATUS;

END Create_Set_With_Validation_3;

/*
Add support for product/platform segments
*/
FUNCTION Update_Set_With_Validation_3
(
  p_api_version          in  number,
  p_init_msg_list        in  varchar2 := FND_API.G_FALSE,
  p_commit               in  varchar2 := FND_API.G_FALSE,
  p_validation_level     in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT NOCOPY varchar2,
  x_msg_count            OUT NOCOPY number,
  x_msg_data             OUT NOCOPY varchar2,
  p_set_number           in  varchar2,
  p_set_type_name        in  varchar2,
  p_set_visibility       in  varchar2,
  p_set_title            in  varchar2,
  p_set_products         in  JTF_VARCHAR2_TABLE_2000,
  p_set_product_segments    in  JTF_VARCHAR2_TABLE_2000,
  p_set_platforms        in  JTF_VARCHAR2_TABLE_2000,
  p_set_platform_segments   in  JTF_VARCHAR2_TABLE_2000,
  p_set_categories       in  JTF_VARCHAR2_TABLE_2000,
  p_ele_type_name_tbl    in  JTF_VARCHAR2_TABLE_2000,
  p_ele_dist_tbl         in  JTF_VARCHAR2_TABLE_2000,
  p_ele_content_type_tbl in  JTF_VARCHAR2_TABLE_2000,
  p_ele_summary_tbl      in  JTF_VARCHAR2_TABLE_2000,
  p_ele_nos_tbl          in  JTF_VARCHAR2_TABLE_2000,
  p_ele_nos_upd_tbl      in  JTF_VARCHAR2_TABLE_2000,
  p_ele_dist_upd_tbl         in  JTF_VARCHAR2_TABLE_2000,
  p_ele_content_type_upd_tbl in  JTF_VARCHAR2_TABLE_2000,
  p_ele_summary_upd_tbl      in  JTF_VARCHAR2_TABLE_2000,
  p_set_category_last_names in JTF_VARCHAR2_TABLE_2000,
  x_created_ele_ids_tbl  OUT NOCOPY JTF_NUMBER_TABLE,
  x_ele_ids_upd_tbl      OUT NOCOPY JTF_NUMBER_TABLE,
  x_set_id               OUT NOCOPY number,
  p_delim                  IN VARCHAR2
) RETURN NUMBER IS

l_set_type_id       NUMBER;
l_set_access_level  VARCHAR2(2000);
l_set_visibility_id NUMBER;
l_element_ids  JTF_NUMBER_TABLE;
l_element_type_ids  JTF_NUMBER_TABLE;
l_element_dist_ids  JTF_VARCHAR2_TABLE_2000;
l_element_content_type_codes JTF_VARCHAR2_TABLE_2000;
l_ele_type_id_upd_tbl JTF_NUMBER_TABLE;
l_ele_dist_id_upd_tbl JTF_VARCHAR2_TABLE_2000;
l_ele_conttype_codes_upd_tbl JTF_VARCHAR2_TABLE_2000;
l_set_product_ids   JTF_NUMBER_TABLE;
l_set_platform_ids  JTF_NUMBER_TABLE;
l_set_category_ids  JTF_NUMBER_TABLE;
l_set_product_org_ids  JTF_NUMBER_TABLE;
l_set_platform_org_ids JTF_NUMBER_TABLE;
l_temp_clob         CLOB;
l_validate_buf      VARCHAR2(1000);
l_return_val NUMBER;
l_return_status VARCHAR2(1);
l_msg_data      VARCHAR2(2000);
l_msg_count     NUMBER;

-- old IDs to delete
l_old_set_product_ids   JTF_NUMBER_TABLE;
l_old_set_platform_ids  JTF_NUMBER_TABLE;
l_old_set_product_org_ids  JTF_NUMBER_TABLE;
l_old_set_platform_org_ids JTF_NUMBER_TABLE;
counter number := 1;

cursor element_ids_cur (p_set_id IN NUMBER) IS
select element_id
from cs_kb_set_eles
where set_id = p_set_id;

cursor product_ids_cur (p_set_id IN NUMBER) IS
select product_id, product_org_id
from cs_kb_set_products
where set_id = p_set_id;

cursor platform_ids_cur (p_set_id IN NUMBER) IS
select platform_id, platform_org_id
from cs_kb_set_platforms
where set_id = p_set_id;

cursor category_ids_cur (p_set_id IN NUMBER) IS
select category_id
from cs_kb_set_categories
where set_id = p_set_id;


BEGIN
   -- dbms_output.put_line('Update Set with Validation - BEGIN');
   SAVEPOINT Update_Set;

   x_created_ele_ids_tbl := JTF_NUMBER_TABLE();
   l_element_ids	 := JTF_NUMBER_TABLE();
   l_element_type_ids    := JTF_NUMBER_TABLE();
   l_element_dist_ids    := JTF_VARCHAR2_TABLE_2000();
   l_element_content_type_codes := JTF_VARCHAR2_TABLE_2000();
   l_ele_type_id_upd_tbl := JTF_NUMBER_TABLE();
   l_ele_dist_id_upd_tbl := JTF_VARCHAR2_TABLE_2000();
   x_ele_ids_upd_tbl     := JTF_NUMBER_TABLE();
   l_ele_conttype_codes_upd_tbl := JTF_VARCHAR2_TABLE_2000();
   l_set_product_ids     := JTF_NUMBER_TABLE();
   l_set_platform_ids    := JTF_NUMBER_TABLE();
   l_set_category_ids    := JTF_NUMBER_TABLE();
   l_set_product_org_ids :=  JTF_NUMBER_TABLE();
   l_set_platform_org_ids := JTF_NUMBER_TABLE();

   l_old_set_product_ids  := JTF_NUMBER_TABLE();
   l_old_set_platform_ids := JTF_NUMBER_TABLE();
   l_old_set_product_org_ids := JTF_NUMBER_TABLE();
   l_old_set_platform_org_ids := JTF_NUMBER_TABLE();

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- dbms_output.put_line('Validate Set number');
   -- Validate Set number, get Set ID
   l_validate_buf := p_set_number;
   l_return_val := Validate_Set_Number(p_set_number,
                                       x_set_id);
   IF (l_return_val = ERROR_STATUS)
     THEN RAISE INVALID_SET_NUMBER;
   END IF;

   -- dbms_output.put_line('Validate Set type name');
   -- Validate Set Type Name, get Set Type ID
   l_validate_buf := p_set_type_name;
   l_return_val := Validate_Set_Type_Name_Update(
					  x_set_id,
					  p_set_type_name,
                                          l_set_type_id);
   IF (l_return_val = ERROR_STATUS)
     THEN RAISE INVALID_SET_TYPE_NAME;
   END IF;

   -- dbms_output.put_line('Validate soln attributes');
   -- validate all other attributes
   l_return_val := VALIDATE_SOLN_ATTRIBUTES_3 (
        p_set_type_id           => l_set_type_id,
        p_visibility_name       => p_set_visibility,
        p_product_names         => p_set_products,
        p_product_segments         => p_set_product_segments,
        p_platform_names        => p_set_platforms,
        p_platform_segments        => p_set_platform_segments,
        p_category_names        => p_set_categories,
        p_category_last_names   => p_set_category_last_names,
        p_ele_nums              => p_ele_nos_tbl,
	p_ele_upd_nums          => p_ele_nos_upd_tbl,
        p_ele_upd_content_types => p_ele_content_type_upd_tbl,
        p_ele_upd_dist_names    => p_ele_dist_upd_tbl,
        p_element_type_names    => p_ele_type_name_tbl,
        p_ele_content_types     => p_ele_content_type_tbl,
        p_ele_dist_names        => p_ele_dist_tbl,
        x_visibility_id         => l_set_visibility_id,
        x_product_numbers       => l_set_product_ids,
        x_platform_numbers      => l_set_platform_ids,
        x_category_numbers      => l_set_category_ids,
	x_ele_ids               => l_element_ids,
        x_ele_upd_ids           => x_ele_ids_upd_tbl,
        x_element_type_ids      => l_element_type_ids,
        x_ele_dist_ids          => l_element_dist_ids,
	x_ele_content_type_codes => l_element_content_type_codes,
        x_ele_upd_type_ids      => l_ele_type_id_upd_tbl,
        x_ele_upd_dist_ids      => l_ele_dist_id_upd_tbl,
	x_ele_upd_content_type_codes => l_ele_conttype_codes_upd_tbl,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data,
        p_delim                   => p_delim
   );

   --dbms_output.put_line('return from CVALIDATE='||l_return_val);

   IF (x_msg_count = 1) THEN
      RAISE VALIDATION_ERROR;
   END IF;

   -- dbms_output.put_line('done all validations.');

   -- update set
   CS_KB_SOLUTION_PVT.Update_Solution
               ( p_set_id        => x_set_id,
                 p_set_number    => p_set_number,
                 p_set_type_id   => l_set_type_id,
                 p_name          => p_set_title,
                 p_visibility_id => l_set_visibility_id,
                 p_status        => 'PUB',
                 x_return_status => l_return_status,
                 x_msg_count     => l_msg_count,
                 x_msg_data      => l_msg_data,
                 p_attribute_category => null,
                 p_attribute1 => null,
                 p_attribute2 => null,
                 p_attribute3 => null,
                 p_attribute4 => null,
                 p_attribute5 => null,
                 p_attribute6 => null,
                 p_attribute7 => null,
                 p_attribute8 => null,
                 p_attribute9 => null,
                 p_attribute10 => null,
                 p_attribute11 => null,
                 p_attribute12 => null,
                 p_attribute13 => null,
                 p_attribute14 => null,
                 p_attribute15 => null
               );

   -- dbms_output.put_line('return from UPDATE_SET='||l_return_val);
   if( (l_return_status = FND_API.G_RET_STS_ERROR) or
       (x_set_id <= 0) ) then
     raise FND_API.G_EXC_ERROR;
   elsif ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) then
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- dbms_output.put_line('updated soln.');

   -- Unlink all element ids for this set_id
   FOR cur_row IN element_ids_cur(x_set_id) LOOP
       l_return_val := Del_Element_From_Set(
        	p_element_id => cur_row.element_id,
        	p_set_id     => x_set_id
        	);
       if (l_return_val < 0) then
      		raise FND_API.G_EXC_UNEXPECTED_ERROR;
       end if;
   END LOOP;
   -- dbms_output.put_line('unlinked element ids. ');

   -- unlink all products
   FOR cur_row IN product_ids_cur(x_set_id) LOOP
       l_old_set_product_ids.extend;
       l_old_set_product_ids(counter) := cur_row.product_id;
       l_old_set_product_org_ids.extend;
       l_old_set_product_org_ids(counter) := cur_row.product_org_id;
       counter := counter + 1;
   END LOOP;

   cs_kb_assoc_pkg.add_link(p_item_id => l_old_set_product_ids,
                               p_org_id  => l_old_set_product_org_ids,
                               p_set_id  => x_set_id,
                               p_link_type => 1,
                               p_task => 0,
                               p_result => l_return_val);

   if (l_return_val < 0) then
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;
   -- dbms_output.put_line('unlinked products. ');

   -- unlink all platforms
   counter := 1;
   FOR cur_row IN platform_ids_cur(x_set_id) LOOP
       l_old_set_platform_ids.extend;
       l_old_set_platform_ids(counter) := cur_row.platform_id;
       l_old_set_platform_org_ids.extend;
       l_old_set_platform_org_ids(counter) := cur_row.platform_org_id;
       counter := counter + 1;
   END LOOP;

   cs_kb_assoc_pkg.add_link(p_item_id => l_old_set_platform_ids,
                               p_org_id  => l_old_set_platform_org_ids,
                               p_set_id  => x_set_id,
                               p_link_type => 0,
                               p_task => 0,
                               p_result => l_return_val);

   if (l_return_val < 0) then
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;
   -- dbms_output.put_line('unlinked platforms. ');

   -- unlink categories
   FOR cur_row IN category_ids_cur(x_set_id) LOOP
       CS_KB_SOLN_CATEGORIES_PVT.removeSolutionFromCategory(
    	p_api_version        => 1.0,
    	x_return_status      => x_return_status,
    	x_msg_count          => x_msg_count,
    	x_msg_data           => x_msg_data,
    	p_solution_id        => x_set_id,
    	p_category_id        => cur_row.category_id
       );
   END LOOP;
   -- dbms_output.put_line('unlinked categories. ');

   -- link set with statements, products, categories, platforms, etc.
   -- also create new statements if info provided
   l_return_val := Link_Soln_Attributes(
        p_validate_type       => 'UPDATE',
        p_set_id              => x_set_id,
        p_given_element_ids   => x_ele_ids_upd_tbl,
        p_given_ele_nums      => p_ele_nos_upd_tbl,
        p_given_ele_type_ids  => l_ele_type_id_upd_tbl,
        p_given_ele_dist_ids  => l_ele_dist_id_upd_tbl,
        p_given_ele_content_types => l_ele_conttype_codes_upd_tbl,
        p_given_ele_summaryies => p_ele_summary_upd_tbl,
	p_element_ids		=> l_element_ids,
        p_element_type_ids    => l_element_type_ids,
        p_element_dist_ids    => l_element_dist_ids,
        p_element_content_types => l_element_content_type_codes,
        p_element_summaries   => p_ele_summary_tbl,
        p_element_dummy_detail => l_temp_clob,
        p_set_product_ids     => l_set_product_ids,
        p_set_platform_ids    => l_set_platform_ids,
        p_set_category_ids    => l_set_category_ids,
        x_created_element_ids => x_created_ele_ids_tbl,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data);
  -- dbms_output.put_line('linked everything. ');
  -- dbms_output.put_line('return from LINK='||l_return_val);

   if( Get_Missing_Ele_Type( x_set_id ) = 'Y' ) then
     raise MANDATORY_STATEMENT_MISSING;
   end if;

   -- Repopulate the Solution Content cache for this solution
   CS_KB_SYNC_INDEX_PKG.Populate_Soln_Content_Cache (x_set_id);
   CS_KB_SYNC_INDEX_PKG.Pop_Soln_Attach_Content_Cache (x_set_id);  --12.1.3

   -- Mark the Solution Version for indexing
   CS_KB_SYNC_INDEX_PKG.Mark_Idxs_on_Pub_Soln( p_set_number );

   -- dbms_output.put_line('Update Set with Validation - END');
   RETURN OKAY_STATUS;

EXCEPTION
  WHEN VALIDATION_ERROR THEN
     RETURN ERROR_STATUS;

  WHEN MANDATORY_STATEMENT_MISSING  THEN
     ROLLBACK TO Update_Set;
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count     := 1;
     x_msg_data      := 'Mandatory Statements Missing.';

     RETURN ERROR_STATUS;

  WHEN INVALID_SET_NUMBER THEN
     ROLLBACK TO Update_Set;
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count     := 1;
     x_msg_data      := 'Invalid Solution Number: ' || p_set_number || '. Solutions to be updated should be valid and PUBLISHED.' ;

     RETURN ERROR_STATUS;

  WHEN INVALID_SET_TYPE_NAME  THEN
     ROLLBACK TO Update_Set;
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count     := 1;
     x_msg_data      := 'Invalid Set Type Name : ' || p_set_type_name;

     RETURN ERROR_STATUS;

  WHEN DUPLICATE_SET_NAME  THEN
     ROLLBACK TO Update_Set;
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count     := 1;
     x_msg_data      := 'Duplicate Solution Name:' || l_validate_buf;

     RETURN ERROR_STATUS;

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Create_Set;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);
      RETURN ERROR_STATUS;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Update_Set;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);
      RETURN ERROR_STATUS;

   WHEN OTHERS THEN
      ROLLBACK TO Update_Set;
      x_msg_data      := 'Update Solution: ' || SQLERRM ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_msg_count := 0;
      RETURN ERROR_STATUS;

END Update_Set_With_validation_3;

/*
This is the same as the original validate_soln_attributes, except it takes a delimiter param
*/
FUNCTION VALIDATE_SOLN_ATTRIBUTES_3
(
  p_set_type_id       IN  NUMBER,
  p_visibility_name IN  VARCHAR2,
  p_product_names   IN  JTF_VARCHAR2_TABLE_2000,
  p_product_segments   IN  JTF_VARCHAR2_TABLE_2000,
  p_platform_names   IN  JTF_VARCHAR2_TABLE_2000,
  p_platform_segments   IN  JTF_VARCHAR2_TABLE_2000,
  p_category_names   IN  JTF_VARCHAR2_TABLE_2000,
  p_category_last_names IN  JTF_VARCHAR2_TABLE_2000,
  p_ele_nums          IN  JTF_VARCHAR2_TABLE_2000,
  p_ele_upd_nums        IN  JTF_VARCHAR2_TABLE_2000,
  p_ele_upd_content_types    IN  JTF_VARCHAR2_TABLE_2000,
  p_ele_upd_dist_names     IN JTF_VARCHAR2_TABLE_2000,
  p_element_type_names IN  JTF_VARCHAR2_TABLE_2000,
  p_ele_content_types    IN  JTF_VARCHAR2_TABLE_2000,
  p_ele_dist_names  IN JTF_VARCHAR2_TABLE_2000,
  x_visibility_id      OUT NOCOPY NUMBER,
  x_product_numbers OUT NOCOPY JTF_NUMBER_TABLE,
  x_platform_numbers OUT NOCOPY JTF_NUMBER_TABLE,
  x_category_numbers OUT NOCOPY JTF_NUMBER_TABLE,
  x_ele_ids           OUT NOCOPY JTF_NUMBER_TABLE,
  x_ele_upd_ids         OUT NOCOPY JTF_NUMBER_TABLE,
  x_element_type_ids  OUT NOCOPY JTF_NUMBER_TABLE,
  x_ele_dist_ids    OUT NOCOPY JTF_VARCHAR2_TABLE_2000,
  x_ele_content_type_codes OUT NOCOPY JTF_VARCHAR2_TABLE_2000,
  x_ele_upd_type_ids  OUT NOCOPY JTF_NUMBER_TABLE,
  x_ele_upd_dist_ids    OUT NOCOPY JTF_VARCHAR2_TABLE_2000,
  x_ele_upd_content_type_codes OUT NOCOPY JTF_VARCHAR2_TABLE_2000,
  x_return_status       OUT NOCOPY  varchar2,
  x_msg_count           OUT NOCOPY  number,
  x_msg_data            OUT NOCOPY  varchar2,
  p_delim                  IN VARCHAR2

) RETURN NUMBER IS
l_validate_buf      VARCHAR2(1000);
l_return_val	NUMBER;
  l_return_status VARCHAR2(1);
  l_dup_found VARCHAR2(1);
  l_product_numbers JTF_NUMBER_TABLE;
  l_platform_numbers JTF_NUMBER_TABLE;
BEGIN

   x_element_type_ids := JTF_NUMBER_TABLE();
   x_product_numbers := JTF_NUMBER_TABLE();
   l_product_numbers := JTF_NUMBER_TABLE();
   x_platform_numbers := JTF_NUMBER_TABLE();
   l_platform_numbers := JTF_NUMBER_TABLE();
   x_category_numbers := JTF_NUMBER_TABLE();
   x_ele_ids := JTF_NUMBER_TABLE();
   x_ele_upd_ids := JTF_NUMBER_TABLE();
   x_element_type_ids := JTF_NUMBER_TABLE();
   x_ele_dist_ids := JTF_VARCHAR2_TABLE_2000();
   x_ele_content_type_codes := JTF_VARCHAR2_TABLE_2000();
   x_ele_upd_type_ids  := JTF_NUMBER_TABLE();
   x_ele_upd_dist_ids  := JTF_VARCHAR2_TABLE_2000();
   x_ele_upd_content_type_codes := JTF_VARCHAR2_TABLE_2000();

   -- Validate Solution Visibility Level Name, get ID
   l_validate_buf := p_visibility_name;
   l_return_status := Validate_Visibility_Level( p_visibility_name,
                                                 x_visibility_id );
   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE INVALID_VISIBILITY_LEVEL;
   END IF;


   -- Validate Set Product Names

   l_product_numbers.extend(p_product_segments.count);
   for i in 1..p_product_segments.count loop
     if(p_product_segments(i) is not null) then
      l_validate_buf := p_product_segments(i);
      l_return_val := Validate_Product_Segment(p_product_segments(i),
                                            l_product_numbers(i));
      IF (l_return_val = ERROR_STATUS)
       THEN RAISE INVALID_PRODUCT_SEGMENT;
      END IF;
     else
      l_validate_buf := p_product_names(i);
      l_return_val := Validate_Product_Name(p_product_names(i),
                                            l_product_numbers(i));
      IF (l_return_val = ERROR_STATUS)
       THEN RAISE INVALID_PRODUCT_NAME;
      END IF;
     end if;
   end loop;

   -- Filter duplicatoin
   for i in 1..l_product_numbers.count loop
    l_dup_found := 'N';
    for j in 1..x_product_numbers.count loop
        if l_product_numbers(i) = x_product_numbers(j) then
            l_dup_found := 'Y';
            exit;
        end if;
    end loop;
    if l_dup_found = 'N' then
        x_product_numbers.extend;
        x_product_numbers(x_product_numbers.count) := l_product_numbers(i);
    end if;
   end loop;

   -- Validate Set Platform Names
   l_platform_numbers.extend(p_platform_segments.count);
   for i in 1..p_platform_segments.count loop
     if (p_platform_segments(i) is not null) then
      l_validate_buf := p_platform_segments(i);
      l_return_val := Validate_Platform_Segment(p_platform_segments(i),
                                            l_platform_numbers(i));
      IF (l_return_val = ERROR_STATUS)
       THEN RAISE INVALID_PLATFORM_SEGMENT;
      END IF;
     else
      l_validate_buf := p_platform_names(i);
      l_return_val := Validate_Platform_Name(p_platform_names(i),
                                            l_platform_numbers(i));
      IF (l_return_val = ERROR_STATUS)
       THEN RAISE INVALID_PLATFORM_NAME;
      END IF;
     end if;
   end loop;

   -- Filter duplicatoin
   for i in 1..l_platform_numbers.count loop
    l_dup_found := 'N';
    for j in 1..x_platform_numbers.count loop
        if l_platform_numbers(i) = x_platform_numbers(j) then
            l_dup_found := 'Y';
            exit;
        end if;
    end loop;
    if l_dup_found = 'N' then
        x_platform_numbers.extend;
        x_platform_numbers(x_platform_numbers.count) := l_platform_numbers(i);
    end if;
   end loop;

   -- Validate that there is at least one category
   if( p_category_names is null or  p_category_names.count = 0)then
     RAISE MANDATORY_CATEGORY_MISSING;
   end if;

   -- Validate Set Category Names
   x_category_numbers.extend(p_category_names.count);
   for i in 1..p_category_names.count loop
      l_validate_buf := p_category_names(i);
      l_return_val := Validate_Category_name_2(p_category_names(i),
                                             p_category_last_names(i),
                                             x_category_numbers(i),
                                             p_delim);
      IF (l_return_val = ERROR_STATUS)
       THEN RAISE INVALID_CATEGORY_NAME;
      END IF;
   end loop;

   -- Validate Element no.
   x_ele_ids.extend(p_ele_nums.count);
   for i in 1..p_ele_nums.count loop
       l_validate_buf := p_ele_nums(i);
       l_return_val := Validate_Element_No(p_ele_nums(i),
                                           x_ele_ids(i));
       IF (l_return_val = ERROR_STATUS) THEN
          RAISE INVALID_ELEMENT_NUMBER;
       END IF;
   end loop;

   -- Validate Element no. for global update
   x_ele_upd_ids.extend(p_ele_upd_nums.count);
   for i in 1..p_ele_upd_nums.count loop

       l_validate_buf := p_ele_upd_nums(i);
       l_return_val := Validate_Element_No(p_ele_upd_nums(i),
                                           x_ele_upd_ids(i));
       IF (l_return_val = ERROR_STATUS)
          THEN RAISE INVALID_ELEMENT_NUMBER;
       END IF;
   end loop;

   -- Validate each Element Type Name
   x_element_type_ids.extend(p_element_type_names.count);
   for i in 1..p_element_type_names.count loop
       l_validate_buf := p_element_type_names(i);
       l_return_val := Validate_Element_Type_Name(p_element_type_names(i),
                                                  x_element_type_ids(i));
       IF (l_return_val = ERROR_STATUS)
        THEN RAISE INVALID_ELEMENT_TYPE_NAME;
       END IF;
   end loop;

   -- Resolve each Element Type Name/ID for global update
   x_ele_upd_type_ids.extend(p_ele_upd_nums.count);
   for i in 1..p_ele_upd_nums.count loop
       l_validate_buf := p_ele_upd_nums(i);
       l_return_val := Resolve_Element_Type_ID(p_ele_upd_nums(i),
                                                  x_ele_upd_type_ids(i));
       IF (l_return_val = ERROR_STATUS)
        THEN RAISE INVALID_ELEMENT_TYPE;
       END IF;
   end loop;

   -- Validate Set Element Type Mapping
   l_return_val := Validate_Set_Element_Type_Ids(p_set_type_id,
                                                 x_element_type_ids);
   IF (l_return_val = ERROR_STATUS)
      THEN RAISE INVALID_SET_ELEMENT_TYPE_MAP;
   END IF;

   -- Validate Set Element Type Mapping for global update
   l_return_val := Validate_Set_Element_Type_Ids(p_set_type_id,
                                                 x_ele_upd_type_ids);
   IF (l_return_val = ERROR_STATUS)
      THEN RAISE INVALID_SET_ELEMENT_TYPE_MAP;
   END IF;

   -- Valdiate Each Element Content Type Name
   x_ele_content_type_codes.extend(p_ele_content_types.count);
   for i in 1..p_ele_content_types.count loop
       l_validate_buf := p_ele_content_types(i);
       l_return_val :=
	   Validate_Element_Content_Type(p_ele_content_types(i),
				         x_ele_content_type_codes(i));
       IF (l_return_val = ERROR_STATUS)
        THEN RAISE INVALID_ELEMENT_CONTENT_TYPE;
       END IF;
   end loop;

   -- Valdiate Each Element Content Type Name for global update
   x_ele_upd_content_type_codes.extend(p_ele_upd_content_types.count);
   for i in 1..p_ele_upd_content_types.count loop
       l_validate_buf := p_ele_upd_content_types(i);
       l_return_val :=
	    Validate_Element_Content_Type(p_ele_upd_content_types(i),
					  x_ele_upd_content_type_codes(i));
       IF (l_return_val = ERROR_STATUS)
        THEN RAISE INVALID_ELEMENT_CONTENT_TYPE;
       END IF;
   end loop;

   -- Validate Each Element distribution Name
   x_ele_dist_ids.extend(p_ele_dist_names.count);
   for i in 1..p_ele_dist_names.count loop
       l_validate_buf := p_ele_dist_names(i);
       l_return_val := Validate_Access_Level(p_ele_dist_names(i),
                                             x_ele_dist_ids(i));

       IF (l_return_val = ERROR_STATUS) THEN
         RAISE INVALID_ACCESS_LEVEL;
       END IF;

   end loop;

   -- Validate Each Element distribution Name for global update
   x_ele_upd_dist_ids.extend(p_ele_upd_dist_names.count);
   for i in 1..p_ele_upd_dist_names.count loop
       l_validate_buf := p_ele_upd_dist_names(i);
       l_return_val := Validate_Access_Level(p_ele_upd_dist_names(i),
                                             x_ele_upd_dist_ids(i));
       IF (l_return_val = ERROR_STATUS) THEN
         RAISE INVALID_ACCESS_LEVEL;
       END IF;

   end loop;

   X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
   return OKAY_STATUS;
EXCEPTION
  WHEN INVALID_VISIBILITY_LEVEL  THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count     := 1;
     x_msg_data      := ' Invalid Visibility Name: ' || l_validate_buf;

     RETURN ERROR_STATUS;

  WHEN INVALID_ACCESS_LEVEL  THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count     := 1;
     x_msg_data      := ' Invalid Distribution Name: ' || l_validate_buf;

     RETURN ERROR_STATUS;

  WHEN INVALID_ELEMENT_TYPE_NAME  THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count     := 1;
     x_msg_data      := 'Invalid Element Type Name: ' || l_validate_buf;

     RETURN ERROR_STATUS;

  WHEN INVALID_ELEMENT_TYPE THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count     := 1;
     x_msg_data      := 'Invalid Element Type ID for Element Number: ' || l_validate_buf;

     RETURN ERROR_STATUS;

  WHEN INVALID_SET_ELEMENT_TYPE_MAP  THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count     := 1;
     x_msg_data      := 'Invalid Set Element Type Mapping: ' || l_validate_buf;

     RETURN ERROR_STATUS;

  WHEN INVALID_ELEMENT_CONTENT_TYPE  THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count     := 1;
     x_msg_data      := 'Invalid Element Content Type: ' || l_validate_buf;

     RETURN ERROR_STATUS;

  WHEN INVALID_ELEMENT_NUMBER  THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count     := 1;
     x_msg_data      := 'This Statement No is invalid or in DRAFT status: ' || l_validate_buf;

     RETURN ERROR_STATUS;

  WHEN INVALID_PRODUCT_NAME  THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count     := 1;
     x_msg_data      := 'Product Name is invalid: ' || l_validate_buf;

     RETURN ERROR_STATUS;

  WHEN INVALID_PRODUCT_SEGMENT  THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count     := 1;
     x_msg_data      := 'Product Segment is invalid: ' || l_validate_buf;

     RETURN ERROR_STATUS;

  WHEN INVALID_PLATFORM_NAME  THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count     := 1;
     x_msg_data      := 'Platform Name is Invalid: ' || l_validate_buf;

     RETURN ERROR_STATUS;

  WHEN INVALID_PLATFORM_SEGMENT  THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count     := 1;
     x_msg_data      := 'Platform Segment is Invalid: ' || l_validate_buf;

     RETURN ERROR_STATUS;

    WHEN MANDATORY_CATEGORY_MISSING  THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := 1;
      x_msg_data      := 'Mandatory category missing. Solution must belong to at least one category.';

     RETURN ERROR_STATUS;

  WHEN INVALID_CATEGORY_NAME  THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count     := 1;
     x_msg_data      := 'Category Name is Invalid:' || l_validate_buf;

     RETURN ERROR_STATUS;

   WHEN OTHERS THEN
      x_msg_data      := 'ERROR in validating solution attributes: ' || SQLERRM ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_msg_count := 0;
      RETURN ERROR_STATUS;

END VALIDATE_SOLN_ATTRIBUTES_3;


FUNCTION Link_Soln_Attributes
(
  p_validate_type     IN VARCHAR2,
  p_set_id              IN NUMBER,
  p_given_element_ids   IN JTF_NUMBER_TABLE,
  p_given_ele_nums      in  JTF_VARCHAR2_TABLE_2000,
  p_given_ele_type_ids  in  JTF_NUMBER_TABLE,
  p_given_ele_dist_ids  in  JTF_VARCHAR2_TABLE_2000,
  p_given_ele_content_types in  JTF_VARCHAR2_TABLE_2000,
  p_given_ele_summaryies in  JTF_VARCHAR2_TABLE_2000,
  p_element_ids   IN JTF_NUMBER_TABLE,
  p_element_type_ids    IN JTF_NUMBER_TABLE,
  p_element_dist_ids    IN JTF_VARCHAR2_TABLE_2000,
  p_element_content_types IN JTF_VARCHAR2_TABLE_2000,
  p_element_summaries   IN JTF_VARCHAR2_TABLE_2000,
  p_element_dummy_detail IN CLOB,
  p_set_product_ids     IN JTF_NUMBER_TABLE,
  p_set_platform_ids    IN JTF_NUMBER_TABLE,
  p_set_category_ids    IN JTF_NUMBER_TABLE,
  x_created_element_ids OUT NOCOPY JTF_NUMBER_TABLE,
  x_return_status       OUT NOCOPY  varchar2,
  x_msg_count           OUT NOCOPY  number,
  x_msg_data            OUT NOCOPY  varchar2
) RETURN NUMBER IS
l_temp_element_no   VARCHAR2(30);
l_set_product_org_ids  JTF_NUMBER_TABLE;
l_set_platform_org_ids JTF_NUMBER_TABLE;
l_temp_category_link_id number;
l_temp_update_return number;
l_elmt_status VARCHAR2(30);

l_validate_buf      VARCHAR2(1000);
l_return_val    NUMBER;
BEGIN

  l_set_product_org_ids :=  JTF_NUMBER_TABLE();
  l_set_platform_org_ids := JTF_NUMBER_TABLE();

  IF (p_validate_type = 'UPDATE') THEN
   l_elmt_status := 'PUBLISHED';
  ELSE
   l_elmt_status := null;
  END IF;


  -- Creating new elements
  x_created_element_ids := JTF_NUMBER_TABLE();
  x_created_element_ids.extend(p_element_type_ids.count);
  for i in 1..p_element_type_ids.count loop
     x_created_element_ids(i) := CS_KB_ELEMENTS_AUDIT_PKG.Create_Element_CLOB(
           p_element_type_id => p_element_type_ids(i),
           p_name => p_element_summaries(i),
           p_desc => p_element_dummy_detail,
           p_status => l_elmt_status,
           p_access_level => p_element_dist_ids(i),
           p_content_type => p_element_content_types(i));

     IF (x_created_element_ids(i) = -3) then
        l_validate_buf := p_element_summaries(i);
        raise DUPLICATE_ELEMENT_NAME;
	-- should should get existing ID and link
     ELSIF (not x_created_element_ids(i) > 0) then
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
     end if;
   end loop;

   -- link The Created element ids to set id;
   for i in 1..x_created_element_ids.count loop
     l_temp_element_no := cs_kb_elements_audit_pkg.Get_Element_Number(
       x_created_element_ids(i));

     l_return_val := cs_knowledge_audit_pvt.Add_Element_To_Set(
       p_element_number => l_temp_element_no,
       p_set_id => p_set_id);

     if (l_return_val = ERROR_STATUS) THEN
       raise FND_API.G_EXC_UNEXPECTED_ERROR;
     end if;
   end loop;

   -- link The provided element ids to set id;
   for i in 1..p_element_ids.count loop
     l_temp_element_no := cs_kb_elements_audit_pkg.Get_Element_Number(
       p_element_ids(i));
     l_return_val := cs_knowledge_audit_pvt.Add_Element_To_Set(
       p_element_number => l_temp_element_no,
       p_set_id => p_set_id);

     if (l_return_val = ERROR_STATUS) THEN
       raise FND_API.G_EXC_UNEXPECTED_ERROR;
     end if;
   end loop;

   -- global updating given elements
   for i in 1..p_given_ele_type_ids.count loop
     l_temp_update_return := CS_KB_ELEMENTS_AUDIT_PKG.Update_Element_CLOB(
	   p_element_id 	=> p_given_element_ids(i),
  	   p_element_number 	=> p_given_ele_nums(i),
           p_element_type_id 	=> p_given_ele_type_ids(i),
           p_name 		=> p_given_ele_summaryies(i),
           p_desc 		=> p_element_dummy_detail,
           p_access_level 	=> p_given_ele_dist_ids(i),
           p_content_type 	=> p_given_ele_content_types(i),
	   p_status		=> 'PUBLISHED');

     IF (l_temp_update_return < 0) then
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
     end if;

     -- Mark the text indexes for the updated statement
     cs_kb_sync_index_pkg.MARK_IDXS_ON_GLOBAL_STMT_UPD(p_given_element_ids(i));
   end loop;

   -- link the updated given element nos to set id

   for i in 1..p_given_ele_nums.count loop
     l_validate_buf := p_given_ele_nums(i);
     l_return_val := cs_knowledge_audit_pvt.Add_Element_To_Set(
       p_element_number => p_given_ele_nums(i),
       p_set_id => p_set_id);
     if (l_return_val = ERROR_STATUS) THEN
       raise SET_ELEMENT_LINK_ERROR;
     end if;
   end loop;

   -- Populate org id table
   l_set_product_org_ids.extend(p_set_product_ids.count);
   for i in 1..l_set_product_org_ids.count loop
        l_set_product_org_ids(i) := cs_std.get_item_valdn_orgzn_id;
   end loop;

   -- link the set to products
   cs_kb_assoc_pkg.add_link(p_item_id => p_set_product_ids,
                               p_org_id  => l_set_product_org_ids,
                               p_set_id  => p_set_id,
                               p_link_type => 1,
                               p_task => 1,
                               p_result => l_return_val);

   if (l_return_val = 0) THEN
         raise PRODUCT_LINK_ERROR;
   end if;

   -- Populate org id table
   l_set_platform_org_ids.extend(p_set_platform_ids.count);

   for i in 1..l_set_platform_org_ids.count loop
        l_set_platform_org_ids(i) := cs_std.get_item_valdn_orgzn_id;
   end loop;

   -- link the set to platforms
   cs_kb_assoc_pkg.add_link(p_item_id => p_set_platform_ids,
                               p_org_id  => l_set_platform_org_ids,
                               p_set_id  => p_set_id,
                               p_link_type => 0,
                               p_task => 1,
                               p_result => l_return_val);

   if (l_return_val = 0) THEN
         raise PLATFORM_LINK_ERROR;
   end if;

   -- link the set to categories
   for i in 1..p_set_category_ids.count loop
     CS_KB_SOLN_CATEGORIES_PVT.addSolutionToCategory(
        p_api_version           => 1.0,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data,
        p_solution_id           => p_set_id,
        p_category_id           => p_set_category_ids(i),
        x_soln_category_link_id => l_temp_category_link_id
     );

     if (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        raise CATEGORY_LINK_ERROR;
     end if;
   end loop;

   return OKAY_STATUS;

EXCEPTION
  WHEN PRODUCT_LINK_ERROR  THEN
     IF (p_validate_type = 'CREATE') THEN
         ROLLBACK TO Create_Set;
     ELSIF (p_validate_type = 'UPDATE') THEN
	 ROLLBACK TO Update_Set;
     END IF;
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count     := 1;
     x_msg_data      := 'Unable to link to Product' ;

     RETURN ERROR_STATUS;

  WHEN PLATFORM_LINK_ERROR  THEN
     IF (p_validate_type = 'CREATE') THEN
         ROLLBACK TO Create_Set;
     ELSIF (p_validate_type = 'UPDATE') THEN
         ROLLBACK TO Update_Set;
     END IF;

     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count     := 1;
     x_msg_data      := 'Unable to link to Platform' ;

     RETURN ERROR_STATUS;

  WHEN CATEGORY_LINK_ERROR  THEN
     IF (p_validate_type = 'CREATE') THEN
         ROLLBACK TO Create_Set;
     ELSIF (p_validate_type = 'UPDATE') THEN
         ROLLBACK TO Update_Set;
     END IF;

     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count     := 1;
     x_msg_data      := 'Unable to link to Category' ;
     RETURN ERROR_STATUS;

 WHEN SET_ELEMENT_LINK_ERROR  THEN
     IF (p_validate_type = 'CREATE') THEN
         ROLLBACK TO Create_Set;
     ELSIF (p_validate_type = 'UPDATE') THEN
         ROLLBACK TO Update_Set;
     END IF;

     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count     := 1;
     x_msg_data      := 'Error while linking to statement:' || l_validate_buf ;
     RETURN ERROR_STATUS;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF (p_validate_type = 'CREATE') THEN
         ROLLBACK TO Create_Set;
     ELSIF (p_validate_type = 'UPDATE') THEN
         ROLLBACK TO Update_Set;
     END IF;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data);
      RETURN ERROR_STATUS;

   WHEN OTHERS THEN
     IF (p_validate_type = 'CREATE') THEN
         ROLLBACK TO Create_Set;
     ELSIF (p_validate_type = 'UPDATE') THEN
         ROLLBACK TO Update_Set;
     END IF;

      x_msg_data      := 'Error at Create Links: ' || SQLERRM ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_msg_count := 1;
      RETURN ERROR_STATUS;

END Link_Soln_Attributes;


FUNCTION Validate_Set_Type_Name_Create
(
  p_set_type_name IN  VARCHAR2,
  x_set_type_id   OUT NOCOPY NUMBER
) RETURN NUMBER IS
BEGIN
  select set_type_id
  into x_set_type_id from cs_kb_set_types_tl
  where language = userenv('LANG')
  and upper(name) = upper(p_set_type_name);
  RETURN OKAY_STATUS;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN ERROR_STATUS;
  WHEN OTHERS THEN
       RETURN ERROR_STATUS;

END Validate_Set_Type_Name_Create;

FUNCTION Validate_Set_Type_Name_Update
(
  p_set_id 	  IN  NUMBER,
  p_set_type_name IN  VARCHAR2,
  x_set_type_id   OUT NOCOPY NUMBER
) RETURN NUMBER IS

BEGIN
  select sets.set_type_id
  into x_set_type_id
  from cs_kb_set_types_tl type,
       cs_kb_sets_b sets
  where type.language = userenv('LANG')
  and upper(type.name) = upper(p_set_type_name)
  and sets.set_type_id = type.set_type_id
  and sets.set_id = p_set_id;

  RETURN OKAY_STATUS;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN ERROR_STATUS;
  WHEN OTHERS THEN
       RETURN ERROR_STATUS;

END Validate_Set_Type_Name_Update;

-- BugFix 3993200 - Sequence id fix
-- Moved Query to Check_Flow Cursor
-- removed max
FUNCTION Validate_Flow
(
  p_flow_name   IN  VARCHAR2,
  p_flow_step   IN  VARCHAR2,
  x_flow_details_id OUT NOCOPY NUMBER
) RETURN NUMBER IS

 Cursor Check_Flow IS
  select flow_details_id
  from cs_kb_wf_flows_tl flow,
       cs_kb_wf_flow_details detail,
	   cs_lookups lookup
  where flow.name = p_flow_name
  and   flow.language = userenv('LANG')
  and   flow.flow_id = detail.flow_id
  and   detail.action = 'PUB'
  and   detail.step = lookup.lookup_code
  and   NVL(detail.END_DATE, sysdate) >= sysdate
  and   lookup.lookup_type = 'CS_KB_STATUS'
  and   lookup.meaning = p_flow_step;

BEGIN
  OPEN  Check_Flow;
  FETCH Check_Flow INTO x_flow_details_id;
  CLOSE Check_Flow;

  IF (x_flow_details_id IS NULL) THEN
	RETURN ERROR_STATUS;
  ELSE
    RETURN OKAY_STATUS;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RETURN ERROR_STATUS;
END Validate_Flow;

-- BugFix 3993200 - Sequence id fix
-- removed select max subquery and replaced with lvf
-- exist and in PUB status
FUNCTION Validate_Set_Number
(
  p_set_number IN varchar2,
  x_set_id      OUT NOCOPY NUMBER
) RETURN NUMBER IS
BEGIN
  select set_id
  into x_set_id
  from cs_kb_sets_b a
  where a.set_number = p_set_number
  and a.status = 'PUB'
  and a.latest_version_flag = 'Y';

  RETURN OKAY_STATUS;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN ERROR_STATUS;
  WHEN OTHERS THEN
    RETURN ERROR_STATUS;
END Validate_Set_Number;

FUNCTION Validate_Element_Type_Name
(
  p_Element_type_name IN  VARCHAR2,
  x_element_type_id   OUT NOCOPY NUMBER
) RETURN NUMBER IS

BEGIN

  select element_type_id
  into x_element_type_id from cs_kb_element_types_tl
  where language = userenv('LANG')
  and upper(name) = upper(p_element_type_name);

  RETURN OKAY_STATUS;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    RETURN ERROR_STATUS;
  WHEN OTHERS THEN
       RETURN ERROR_STATUS;

END Validate_Element_Type_Name;

FUNCTION Resolve_Element_Type_ID
(
  p_Element_number    IN  VARCHAR2,
  x_element_type_id   OUT NOCOPY NUMBER
) RETURN NUMBER IS

BEGIN

  select element_type_id
  into x_element_type_id
  from cs_kb_elements_b
  where element_number = p_element_number;

  RETURN OKAY_STATUS;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    RETURN ERROR_STATUS;
  WHEN OTHERS THEN
       RETURN ERROR_STATUS;

END Resolve_Element_Type_ID;

FUNCTION Validate_Set_Element_Type_Ids
(
  p_set_type_id       IN  NUMBER,
  p_element_type_ids  IN JTF_NUMBER_TABLE

) RETURN NUMBER IS

Type element_type_id_tab_type     is
TABLE OF CS_KB_ELEMENT_TYPES_B.ELEMENT_TYPE_ID%TYPE INDEX BY BINARY_INTEGER;

l_element_type_ids element_type_id_tab_type;

l_count NUMBER(15);
l_exists boolean;

cursor get_elem_type_ids(c_set_type_id IN NUMBER) IS
select element_type_id from cs_kb_set_ele_types
where set_type_id = c_set_type_id;

BEGIN

   Open get_elem_type_ids(p_set_type_id);
   l_count := 1;
   Loop

   Fetch get_elem_type_ids INTO l_element_type_ids(l_count);
   EXIT WHEN get_elem_type_ids%NOTFOUND;
   l_count := l_count + 1;

   End Loop;

   close get_elem_type_ids;

    for j in 1..p_element_type_ids.count
    loop
    l_exists := FALSE;
      for k in 1..l_element_type_ids.count
      loop

         IF (l_element_type_ids(k) = p_element_type_ids(j))
         THEN
             l_exists := TRUE;
             EXIT;
         END IF;

      end loop;
      IF (l_exists = FALSE)
      THEN
           RETURN ERROR_STATUS;

      END IF;

    end loop;

    RETURN OKAY_STATUS;
EXCEPTION
  WHEN OTHERS THEN
       RETURN ERROR_STATUS;

END Validate_Set_Element_Type_Ids;


  /*
   * Validate_visibility_level
   *   Given the textual name of a visibility level,
   *   validate that such a visibility level exists
   *   and fetch the id. It returns either success or
   *   error.
   * Parameters:
   *  p_visibility_name - textual name of the visibility level to validate.
   *  x_visibility_id - out the validated visibility level id. The value
   *                    is undefined if the function returns an error.
   * Return Value:
   *  If there is a validation error, returns FND_API.G_RET_STS_ERROR.
   *  If the validation succeeds, returns FND_API.G_RET_STS_SUCCESSFUL.
   */
  FUNCTION VALIDATE_VISIBILITY_LEVEL
  (
    p_visibility_name           IN VARCHAR2,
    x_visibility_id             OUT NOCOPY NUMBER
  ) RETURN VARCHAR2 IS
    cursor get_matching_visibility( c_visibility_name VARCHAR2 ) is
      select visibility_id
      from cs_kb_visibilities_vl v
      where upper(v.name) like upper(c_visibility_name);
    l_return_status VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
  BEGIN

    -- Check input parameters
    if( p_visibility_name is null) then
      return FND_API.G_RET_STS_ERROR;
    end if;

    -- Fetch the id of the visibility level
    open get_matching_visibility(p_visibility_name);
    fetch get_matching_visibility into x_visibility_id;
    if ( get_matching_visibility%NOTFOUND ) then
      l_return_status := FND_API.G_RET_STS_ERROR;
    else
      l_return_status := FND_API.G_RET_STS_SUCCESS;
    end if;
    close get_matching_visibility;
    return l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FND_API.G_RET_STS_ERROR;
  END Validate_Visibility_Level;


FUNCTION VALIDATE_ACCESS_LEVEL
(
  p_access_level_name   IN  VARCHAR2,
  x_access_level_value  OUT NOCOPY VARCHAR2
) RETURN NUMBER IS
BEGIN

select lookup_code into x_access_level_value
from cs_lookups where lookup_type = 'CS_KB_ACCESS_LEVEL'
and upper(meaning) like upper(p_access_level_name);

if (x_access_level_value IS NULL)
then
   return ERROR_STATUS;
end if;
 return OKAY_STATUS;
EXCEPTION
 WHEN NO_DATA_FOUND THEN
  RETURN ERROR_STATUS;
 WHEN OTHERS THEN
       RETURN ERROR_STATUS;
END Validate_Access_Level;

FUNCTION VALIDATE_ELEMENT_CONTENT_TYPE
(
  p_ele_content_type    IN  VARCHAR2,
  p_ele_content_type_code OUT NOCOPY VARCHAR2
) RETURN NUMBER IS
BEGIN

 select lookup_code
 INTO p_ele_content_type_code
 from cs_lookups
 where lookup_type = 'CS_KB_CONTENT_TYPE'
 and meaning = p_ele_content_type;

 IF ( (p_ele_content_type_code <> 'TEXT/HTML')  AND
      (p_ele_content_type_code <> 'TEXT/PLAIN')  AND
      (p_ele_content_type_code <> 'TEXT/X-PLAIN')  AND
      (p_ele_content_type_code <> 'TEXT/X-HTML') ) THEN
    RETURN ERROR_STATUS;
 ELSE
    return OKAY_STATUS;
 END IF;
EXCEPTION
 WHEN OTHERS THEN
       RETURN ERROR_STATUS;
END Validate_Element_Content_Type;


FUNCTION VALIDATE_ELEMENT_NO
(
  p_ele_no    IN  VARCHAR2,
  x_latest_id OUT NOCOPY NUMBER
) RETURN NUMBER IS

BEGIN

select element_id INTO x_latest_id
from cs_kb_elements_b
where element_number = p_ele_no
and status = 'PUBLISHED';

RETURN OKAY_STATUS;

EXCEPTION
 WHEN NO_DATA_FOUND THEN
   RETURN ERROR_STATUS;
 WHEN OTHERS THEN
       RETURN ERROR_STATUS;
END Validate_Element_No;


FUNCTION VALIDATE_PRODUCT_NAME
(
  p_name   IN  VARCHAR2,
  x_number OUT NOCOPY NUMBER
) RETURN NUMBER IS

 l_query VARCHAR2(1000);
 l_org_id NUMBER;
 l_prof_val NUMBER;

 l_cursor INTEGER;
 ignore INTEGER;

BEGIN
 l_query :=
  'SELECT it.inventory_item_id '||
  'FROM mtl_system_items_vl it, mtl_item_categories ic '||
  'where it.inventory_item_id = ic.inventory_item_id '||
  'and   it.organization_id = ic.organization_id '||
  'and   it.organization_id = :l_org_id '||
  'and   ic.category_set_id = :l_prof_val '||
  'and   upper(it.description) = upper(:l_name) ';

  l_cursor := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(l_cursor, l_query, DBMS_SQL.NATIVE);
  DBMS_SQL.BIND_VARIABLE(l_cursor, ':l_org_id',   cs_std.get_item_valdn_orgzn_id);
  DBMS_SQL.BIND_VARIABLE(l_cursor, ':l_prof_val', fnd_profile.value('CS_KB_PRODUCT_CATEGORY_SET'));
  DBMS_SQL.BIND_VARIABLE(l_cursor, ':l_name',     p_name);
  DBMS_SQL.DEFINE_COLUMN(l_cursor, 1, x_number);
  ignore := DBMS_SQL.EXECUTE(l_cursor);

  IF DBMS_SQL.FETCH_ROWS(l_cursor)>0 THEN
    DBMS_SQL.COLUMN_VALUE(l_cursor, 1, x_number);
    DBMS_SQL.CLOSE_CURSOR(l_cursor);
    RETURN OKAY_STATUS;
  ELSE
    DBMS_SQL.CLOSE_CURSOR(l_cursor);
    RETURN ERROR_STATUS;
  END IF;

EXCEPTION

   WHEN NO_DATA_FOUND THEN
       RETURN ERROR_STATUS;
   WHEN OTHERS THEN
       RETURN ERROR_STATUS;

END Validate_Product_Name;

FUNCTION VALIDATE_PRODUCT_SEGMENT
(
  p_segment   IN  VARCHAR2,
  x_number OUT NOCOPY NUMBER
) RETURN NUMBER IS
 CURSOR cur_segments(cp_org_id NUMBER, cp_prof_val VARCHAR2, cp_segments VARCHAR2) IS
   SELECT it.inventory_item_id
   FROM mtl_system_items_vl it, mtl_item_categories ic
   where it.inventory_item_id = ic.inventory_item_id
   and   it.organization_id = ic.organization_id
   and   it.organization_id = cp_org_id
   and   ic.category_set_id = cp_prof_val
   and   upper(it.concatenated_segments) = upper(cp_segments) ;
BEGIN
  open  cur_segments(cs_std.get_item_valdn_orgzn_id,
                     fnd_profile.value('CS_KB_PRODUCT_CATEGORY_SET'),
                     p_segment);
      fetch cur_segments into x_number;
      if cur_segments%NOTFOUND then
        close cur_segments;
        RETURN ERROR_STATUS;
      end if;
  close cur_segments;

  return OKAY_STATUS;

EXCEPTION
   WHEN OTHERS THEN
       RETURN ERROR_STATUS;
END Validate_Product_Segment;


FUNCTION VALIDATE_PLATFORM_NAME
(
  p_name   IN  VARCHAR2,
  x_number OUT NOCOPY NUMBER
) RETURN NUMBER IS

 l_query VARCHAR2(1000);
 l_org_id NUMBER;
 l_prof_val NUMBER;

 l_cursor INTEGER;
 ignore INTEGER;

BEGIN

 l_query :=
  'SELECT it.inventory_item_id '||
  'FROM mtl_system_items_vl it, mtl_item_categories ic '||
  'where it.inventory_item_id = ic.inventory_item_id '||
  'and   it.organization_id = ic.organization_id '||
  'and   it.organization_id = :l_org_id '||
  'and   ic.category_set_id = :l_prof_val '||
  'and   upper(it.description) = upper(:l_name) ';

  l_cursor := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(l_cursor, l_query, DBMS_SQL.NATIVE);
  DBMS_SQL.BIND_VARIABLE(l_cursor, ':l_org_id',   cs_std.get_item_valdn_orgzn_id);
  DBMS_SQL.BIND_VARIABLE(l_cursor, ':l_prof_val', fnd_profile.value('CS_SR_PLATFORM_CATEGORY_SET'));
  DBMS_SQL.BIND_VARIABLE(l_cursor, ':l_name',     p_name);
  DBMS_SQL.DEFINE_COLUMN(l_cursor, 1, x_number);
  ignore := DBMS_SQL.EXECUTE(l_cursor);

  IF DBMS_SQL.FETCH_ROWS(l_cursor)>0 THEN
    DBMS_SQL.COLUMN_VALUE(l_cursor, 1, x_number);
    DBMS_SQL.CLOSE_CURSOR(l_cursor);
    RETURN OKAY_STATUS;
  ELSE
    DBMS_SQL.CLOSE_CURSOR(l_cursor);
    RETURN ERROR_STATUS;
  END IF;

EXCEPTION

   WHEN NO_DATA_FOUND THEN
       RETURN ERROR_STATUS;
   WHEN OTHERS THEN
       RETURN ERROR_STATUS;

END Validate_Platform_Name;

FUNCTION VALIDATE_PLATFORM_SEGMENT
(
  p_segment   IN  VARCHAR2,
  x_number OUT NOCOPY NUMBER
) RETURN NUMBER IS
 CURSOR cur_segments(cp_org_id NUMBER, cp_prof_val VARCHAR2, cp_segments VARCHAR2) IS
   SELECT it.inventory_item_id
   FROM mtl_system_items_vl it, mtl_item_categories ic
   where it.inventory_item_id = ic.inventory_item_id
   and   it.organization_id = ic.organization_id
   and   it.organization_id = cp_org_id
   and   ic.category_set_id = cp_prof_val
   and   upper(it.concatenated_segments) = upper(cp_segments) ;

BEGIN
  open  cur_segments(cs_std.get_item_valdn_orgzn_id,
                     fnd_profile.value('CS_SR_PLATFORM_CATEGORY_SET'),
                     p_segment);
      fetch cur_segments into x_number;
      if cur_segments%NOTFOUND then
        close cur_segments;
        RETURN ERROR_STATUS;
      end if;
  close cur_segments;

  return OKAY_STATUS;

EXCEPTION
   WHEN OTHERS THEN
       RETURN ERROR_STATUS;
END Validate_Platform_Segment;
/*
 * forwards to VALIDATE_CATEGORY_NAME_2
 */
FUNCTION VALIDATE_CATEGORY_NAME
(
  p_name      IN  VARCHAR2,
  p_last_name IN  VARCHAR2,
  x_number OUT NOCOPY NUMBER
) RETURN NUMBER IS

BEGIN

 RETURN VALIDATE_CATEGORY_NAME_2(p_name, p_last_name, x_number, '>');

END Validate_Category_Name;

/*
 * forwards to Get_Category_Name_2
 */
-- Given the Category name in a bread crumb form
-- Determine the last category name
-- For example given A>B>C>D, return D
FUNCTION Get_Category_Name
(
  p_category_name  IN  varchar2
) RETURN VARCHAR2 IS

begin
  RETURN Get_Category_Name_2(p_category_name,'>');
End Get_Category_Name;

FUNCTION Encode_Text(p_text IN VARCHAR2) RETURN VARCHAR2 IS

l_text VARCHAR2(32767);
l_gt VARCHAR2(15);
l_lt VARCHAR2(15);
l_amp VARCHAR2(15);
l_apos VARCHAR2(15);
l_quot VARCHAR2(15);



BEGIN

  l_gt   := '&' || 'gt;';
  l_lt   := '&' || 'lt;';
  l_amp  := '&' || 'amp;';
  l_apos  := '&' || 'apos;';
  l_quot := '&' || 'quot;';

  l_text := replace(p_text, '&', l_amp);
  l_text := replace(l_text, '>', l_gt);
  l_text := replace(l_text, '<', l_lt);
  l_text := replace(l_text, '''', l_apos);
  l_text := replace(l_text, '"', l_quot);

 return l_text;

End Encode_Text;

-- Break a CLOB into chunks of VARCHARs
-- and write it to a file

PROCEDURE Write_CLOB_TO_File(p_clob IN  CLOB,
                             p_file IN  NUMBER) IS

chunkSize      INTEGER;
chunkPos       INTEGER;
amt	           INTEGER;

x_Buf varchar2(32767);
x_sourceLength number;

BEGIN

     IF (p_clob IS NULL)
     THEN
       RETURN;
     END IF;

     x_sourceLength := DBMS_LOB.getlength(p_clob);

     IF (x_sourceLength = 0)
     THEN
       RETURN;
     END IF;

     chunkSize := DBMS_LOB.GETCHUNKSIZE(p_clob);
     -- BugFix 3995241 21-Apr-2005 MK
     -- chunksize reduced to allow for expansion after Encode_Text api call
     IF (chunkSize > 6553)
     THEN
   	   chunkSize := 6553;
     END IF;

     chunkPos :=1;

     -- read in chunks
     WHILE (chunkPos<= x_sourceLength) AND
                ((x_sourceLength-chunkPos) >= chunkSize)
     LOOP
        DBMS_LOB.READ(p_clob, chunkSize, chunkPos, x_Buf);
        FND_FILE.PUT(p_file, Encode_Text(x_Buf));
        chunkPos := chunkPos + chunkSize;
     END LOOP;

     -- read the rest of CLOB
     IF ((x_sourceLength-chunkPos) < chunkSize) THEN
        amt := x_sourceLength-chunkPos+1;
        DBMS_LOB.READ(p_clob, amt, chunkPos, x_Buf);
        FND_FILE.PUT(p_file, Encode_Text(x_Buf));
     END IF;

END Write_Clob_To_File;


/*
 * Export_Solutions
 *  This procedure is used by the XML Solution Import / Export
 *  concurrent program. Depending on the export mode selected,
 *  It can export either all published solutions or the
 *  latest version of all solutions in a particular category.
 *  Parameters:
 *    p_category_name - This should be the full textual path
 *      of the category for which solutions will be exported.
 *      The individual category names should be separated by
 *      a '>'. Example: 'Home>Desktop>Monitor'
 *    p_sol_status - One of 2 mode values: ALL or PUB. This
 *      determines whether only published solutions are exported
 *      or the latest version of all non-obsoleted solutions
 *      are exported.
 */
/*
 * forwards to EXPORT_SOLUTIONS_2
 */
PROCEDURE EXPORT_SOLUTIONS
(
  errbuf   OUT NOCOPY VARCHAR2,
  retcode  OUT NOCOPY NUMBER,
  p_category_name  IN  VARCHAR2,
  p_sol_status     IN  VARCHAR2
) IS

BEGIN
 EXPORT_SOLUTIONS_2(errbuf, retcode, p_category_name, p_sol_status, '>');

END EXPORT_SOLUTIONS;


PROCEDURE GET_USER_ACCESS_LEVEL(
                                p_user_name      IN VARCHAR2,
                                x_access_level   OUT NOCOPY NUMBER) IS

l_permission_name VARCHAR2(30);
l_flag            NUMBER(15);
l_return_status   VARCHAR2(30);
BEGIN

    --Default Access Level is only for external
    x_access_level := 3000;

    l_permission_name := 'CS_Solution_View_Restricted';

    JTF_AUTH_SECURITY_PKG.check_permission(
    x_flag => l_flag,
    x_return_status => l_return_status,
    p_user_name => p_user_name,
    p_permission_name => l_permission_name);

    IF (l_flag = 1)
    THEN
      x_access_level := 900;
      RETURN;
    END IF;

    l_permission_name := 'CS_Solution_View_Internal';

    JTF_AUTH_SECURITY_PKG.check_permission(
    x_flag => l_flag,
    x_return_status => l_return_status,
    p_user_name => p_user_name,
    p_permission_name => l_permission_name);

    IF (l_flag = 1)
    THEN
      x_access_level := 1000;
      RETURN;
    END IF;

    l_permission_name := 'CS_Solution_View';

    JTF_AUTH_SECURITY_PKG.check_permission(
    x_flag => l_flag,
    x_return_status => l_return_status,
    p_user_name => p_user_name,
    p_permission_name => l_permission_name);

    IF (l_flag = 1)
    THEN
      x_access_level := 3000;
      RETURN;
    END IF;

EXCEPTION

WHEN OTHERS THEN
    x_access_level := 3000;


END GET_USER_ACCESS_LEVEL;


FUNCTION GET_USER_NAME (V_USER_ID NUMBER)
RETURN VARCHAR2
AS

 Cursor Get_Emp_User IS
  SELECT  P.FULL_NAME
  FROM FND_USER fu
      ,PER_ALL_PEOPLE_F P
  WHERE sysdate BETWEEN nvl(fu.start_date, sysdate-1)
                    AND nvl(fu.end_date, sysdate+1)
  AND fu.employee_id = P.person_id
  AND TRUNC(SYSDATE) BETWEEN P.EFFECTIVE_START_DATE
                         AND P.EFFECTIVE_END_DATE
  AND fu.User_id = V_USER_ID;

 Cursor Get_B2C_User IS
   SELECT hp.party_name
   FROM hz_parties hp
       ,fnd_user fu
   WHERE hp.party_type = 'PERSON'
   AND sysdate BETWEEN nvl(fu.start_date, sysdate-1)
                   AND nvl(fu.end_date, sysdate+1)
   AND fu.customer_id = hp.party_id
   AND fu.customer_id is not null
   AND fu.employee_id is null
   AND fu.User_id = V_USER_ID;

 Cursor Get_B2B_User IS
  SELECT hp.party_name
   from hz_parties hp
       ,hz_relationships hr
       ,fnd_user fu
   WHERE hr.party_id = fu.customer_id
   AND hr.subject_id = hp.party_id
   AND hr.relationship_code in ('EMPLOYEE_OF', 'CONTACT_OF')
   AND hp.party_type = 'PERSON'
   AND hr.subject_table_name = 'HZ_PARTIES'
   AND hr.object_table_name = 'HZ_PARTIES'
   AND sysdate BETWEEN nvl(fu.start_date, sysdate-1)
                   AND nvl(fu.end_date, sysdate+1)
   AND fu.customer_id is not null
   AND fu.employee_id is null
   AND fu.User_id = V_USER_ID;

  CURSOR GET_FND_USER IS
   SELECT fu.user_name
   FROM FND_USER fu
   WHERE fu.User_id = V_USER_ID;

 l_full_name VARCHAR2(200) := null;
BEGIN
  OPEN  GET_EMP_USER;
  FETCH GET_EMP_USER INTO l_full_name;
  CLOSE GET_EMP_USER;

  IF l_full_name IS NULL THEN
    OPEN  GET_B2C_USER;
    FETCH GET_B2C_USER INTO l_full_name;
    CLOSE GET_B2C_USER;

    IF l_full_name IS NULL THEN
      OPEN  GET_B2B_USER;
      FETCH GET_B2B_USER INTO l_full_name;
      CLOSE GET_B2B_USER;

      IF l_full_name IS NULL THEN
        OPEN  GET_FND_USER;
        FETCH GET_FND_USER INTO l_full_name;
        CLOSE GET_FND_USER;
      END IF;
    END IF;

  END IF;

 RETURN l_full_name;
END;

-- (SRCHEFF)
  /*
    This program updates the usage score based on the usage. It consists of two
    sections: 1. update usage scores of those solutions that were published AFTER
    the (sysdate - time_span) date, 2. update usage scores of those solutions that
    were publishec  BEFORE the (sysdate - time_span) date.
    In the first section, we compensate the score with an aging factor. The aging
    actor is calculated as:
    1 - (sysdate - last_update_date)/time_span. The agian factor should only
    range from 0 - 1, that is it is 1 if the last update date is the sysdate, and
    0 if it is (sysdate - time_span).

    In both cases, we only look at those solutions of which the feedback or
    linkage were create AFTERthe cut-off date (sysdate - time_span).
    */
PROCEDURE Update_Solution_Usage_Score (
      p_commit    IN   VARCHAR2 := FND_API.G_FALSE)
  IS
    -- Default time usage to 1 year if the profile is not set.
    CURSOR Get_Time_Usage_Csr IS
        Select nvl(fnd_profile.value('CS_KB_USAGE_TIME_SPAN'), 365)  from dual;

    -- Bug 32170161, replace sum with avg.
    CURSOR Get_Avg_Score_Csr(p_time_usge_span NUMBER)  IS
        select avg(usage_score)/p_time_usge_span
        from cs_kb_sets_b
        where status = 'PUB';

    CURSOR Get_Lower_Limit_Csr(p_coefficient  NUMBER, p_time_usage_span NUMBER) IS
      select avg(usage_score) - (p_coefficient*stddev(usage_score)/sqrt(count(set_id)))
      from cs_kb_sets_b
      where status = 'PUB'
      and last_update_date > (sysdate - p_time_usage_span);

    CURSOR Get_Upper_Limit_Csr(p_coefficient  NUMBER, p_time_usage_span NUMBER) IS
      select avg(usage_score) + (p_coefficient*stddev(usage_score)/sqrt(count(set_id)))
      from cs_kb_sets_b
      where status = 'PUB'
      and last_update_date > (sysdate - p_time_usage_span);

    CURSOR Get_Coefficient_Csr IS
      select fnd_profile.value('CS_KB_USAGE_LIMIT_FACTOR') from dual;

    -- (4740480)
    CURSOR Get_Set_Count(p_time_usage_span NUMBER) IS
      SELECT count(set_id)
      FROM cs_kb_sets_b
      WHERE status = 'PUB'
      AND last_update_date > (SYSDATE - p_time_usage_span);

    l_set_count               NUMBER;
    -- 4740480_eof

    l_time_usage              NUMBER := 0;
    l_usage_limit_factor      NUMBER := 0;
    l_avg_score               NUMBER := 0;
    l_coefficient             NUMBER := 0;
    l_lower                   NUMBER := 0;
    l_higher                  NUMBER := 0;

BEGIN
    Savepoint l_upd_usage_score_sav;

    -- get profile values
    OPEN Get_Time_Usage_Csr;
    FETCH Get_Time_Usage_Csr INTO l_time_usage;
    CLOSE Get_Time_Usage_Csr;

    If l_time_usage <= 0  Then
      RAISE INVALID_USAGE_TIME_SPAN_ERROR;
    End If;

    -- 4740480
    OPEN get_set_count(l_time_usage);
    FETCH Get_Set_Count INTO l_set_count;
    CLOSE Get_Set_Count;

    IF l_set_count > 0 THEN
    -- 4740480_eof

	    OPEN Get_Avg_Score_Csr(l_time_usage);
	    FETCH Get_Avg_Score_Csr INTO l_avg_score;
	    CLOSE Get_Avg_Score_Csr;

	    -- 1.  Update usage scores of solutions that were published AFTER
	    --     (sysadate - l_time_usage) based on the used history.
	    -- 1.1 Get score from used history
	    update cs_kb_sets_b c set usage_score =
	    (
	     select
	      round(
	       sum(to_number(cl.meaning)*(1-(sysdate-a.creation_date)/l_time_usage))
	          +
		  (l_avg_score * ( 1 - (sysdate - c.last_update_date)/l_time_usage) )
	        )
	    from cs_kb_set_used_hists a, cs_lookups cl
	    where a.set_id = c.set_id
	    and a.used_type = cl.lookup_code
	    and cl.lookup_type = 'CS_KB_USAGE_TYPE_WEIGHT'
	    and a.creation_date >= (sysdate - l_time_usage)
	    and c.last_update_date > (sysdate - l_time_usage)
	    and c.status = 'PUB'
	    group by c.set_id, c.last_update_date
	    )
	    where c.status = 'PUB'
	    and c.last_update_date > (sysdate-l_time_usage)
	    and exists (
	      select null
	      from cs_kb_set_used_hists a, cs_lookups cl
	      where a.set_id = c.set_id
	      and a.used_type = cl.lookup_code
	      and cl.lookup_type = 'CS_KB_USAGE_TYPE_WEIGHT'
	      and a.creation_date >= (sysdate - l_time_usage)
	      and c.last_update_date > (sysdate - l_time_usage)
	      and c.status = 'PUB'
	   );

	   --1.2  Update usage scores of solutions that were published AFTER
	   -- sysdate - l_time_usage based on the solution linkage.
	    update cs_kb_sets_b c set usage_score =
	    (
	       select
	      round(
	        sum(to_number(cl.meaning)*(1-(sysdate-a.creation_date)/l_time_usage))
	         +
	        (l_avg_score * ( 1 - (sysdate - c.last_update_date)/l_time_usage) )
	           )  + c.usage_score
	    from cs_kb_set_links a, cs_lookups cl
	    where a.set_id = c.set_id
	    and a.link_type = cl.lookup_code
	    and cl.lookup_type = 'CS_KB_USAGE_TYPE_WEIGHT'
	    and a.creation_date >= (sysdate - l_time_usage)
	    and c.last_update_date > (sysdate - l_time_usage)
		and c.status = 'PUB'
	    group by c.set_id, c.last_update_date
	    )
	    where c.status = 'PUB'
	    and c.last_update_date > (sysdate-l_time_usage)
	    and exists (
	      select null
	      from cs_kb_set_links a, cs_lookups cl
	      where a.set_id = c.set_id
	      and a.link_type = cl.lookup_code
	      and cl.lookup_type = 'CS_KB_USAGE_TYPE_WEIGHT'
	      and a.creation_date >= (sysdate - l_time_usage)
	      and c.last_update_date > (sysdate - l_time_usage)
	      and c.status = 'PUB'
	    );

	   -- 2. Update usage scores of solutions that were published BEFORE
	   --  sysdate - l_time_usage based on the used history. Aging factor
	   --  compensation will not be added in this update.
	   update cs_kb_sets_b c set usage_score =
	    (
	    select round(sum(to_number(cl.meaning)*(1-(sysdate-a.creation_date)/l_time_usage))
	               )
	    from cs_kb_set_used_hists a, cs_lookups cl
	    where a.set_id = c.set_id
	    and a.used_type = cl.lookup_code
	    and cl.lookup_type = 'CS_KB_USAGE_TYPE_WEIGHT'
	    and a.creation_date >= (sysdate - l_time_usage)
	    and c.last_update_date <= (sysdate - l_time_usage)
		and c.status = 'PUB'
	    group by c.set_id, c.last_update_date
	    )
	    where c.status = 'PUB'
	    and c.last_update_date <= (sysdate-l_time_usage)
	    and exists (
	      select null
	      from cs_kb_set_used_hists a, cs_lookups cl
	      where a.set_id = c.set_id
	      and a.used_type = cl.lookup_code
	      and cl.lookup_type = 'CS_KB_USAGE_TYPE_WEIGHT'
	      and a.creation_date >= (sysdate - l_time_usage)
	      and c.last_update_date <= (sysdate - l_time_usage)
	      and c.status = 'PUB'
	   );

	    -- 2.1  Update usage scores of solutions that were published BEFORE
	    -- sysdate - l_time_usage based on the solution linkage.
	    update cs_kb_sets_b c set usage_score =
	    (
	    select round(sum(to_number(cl.meaning)*(1-(sysdate-a.creation_date)/l_time_usage))
		           ) + c.usage_score
	    from cs_kb_set_links a, cs_lookups cl
	    where a.set_id = c.set_id
	    and a.link_type = cl.lookup_code
	    and cl.lookup_type = 'CS_KB_USAGE_TYPE_WEIGHT'
	    and a.creation_date >= (sysdate - l_time_usage)
	    and c.last_update_date <= (sysdate - l_time_usage)
	    and c.status = 'PUB'
	    group by c.set_id, c.last_update_date
	    )
	    where c.status = 'PUB'
	    and c.last_update_date <= (sysdate-l_time_usage)
	    and exists (
	      select null
	      from cs_kb_set_links a, cs_lookups cl
	      where a.set_id = c.set_id
	      and a.link_type = cl.lookup_code
	      and cl.lookup_type = 'CS_KB_USAGE_TYPE_WEIGHT'
	      and a.creation_date >= (sysdate - l_time_usage)
	      and c.last_update_date <= (sysdate - l_time_usage)
	      and c.status = 'PUB'
	    );


	    -- Update the normalized usage score column.
	    Open Get_Coefficient_Csr;
	    Fetch Get_Coefficient_Csr Into l_coefficient;
	    Close Get_Coefficient_Csr;

	    If l_coefficient = 0  Then
	      Raise INVALID_COEFFICIENT_FACTOR;
	    End If;

	    Open Get_Lower_Limit_Csr(l_coefficient, l_time_usage);
	    Fetch Get_Lower_Limit_Csr Into l_lower;
	    Close Get_Lower_Limit_Csr;

	    Open Get_Upper_Limit_Csr(l_coefficient, l_time_usage);
	    Fetch Get_Upper_Limit_Csr Into l_higher;
	    Close Get_Upper_Limit_Csr;

	    -- update norm_usage_score
	    If (l_higher  - l_lower) <> 0 Then --5705547
	       update cs_kb_sets_b set norm_usage_score = (
                 ( decode(sign(decode(sign(usage_score - l_lower),
	                    -1,   l_lower,
	                    usage_score) - l_higher),
	                     -1,   decode(sign(usage_score - l_lower),
	                     -1,   l_lower,
	                    usage_score),
	          l_higher) - l_lower)/(l_higher  - l_lower)*100 )
	      where status = 'PUB';
	   End If; --5705547

	    -- commit changes
	    IF FND_API.to_Boolean( p_commit )
	      THEN
	          COMMIT WORK;
	    END IF;
    END IF;  -- end l_set_count > 0, 4740480
EXCEPTION
    WHEN INVALID_USAGE_TIME_SPAN_ERROR THEN
        Rollback To l_upd_usage_score_sav;
        Raise;
    WHEN INVALID_COEFFICIENT_FACTOR THEN
        Rollback To l_upd_usage_score_sav;
        Raise;
    WHEN OTHERS THEN
        Rollback To l_upd_usage_score_sav;
        Raise;
END Update_Solution_Usage_Score;

/*
 * Form the category's full path name based on category id
 *  The path is delimited by the specified parameter.
 *  - if p_verify is true,
 *    then it will LOG a warning when category contains a '>'
 */
FUNCTION Get_Category_Full_Name
(
  p_catid  IN  NUMBER,
  p_delim IN VARCHAR2,
  p_verify IN BOOLEAN DEFAULT FALSE
--  full_cat_name OUT VARCHAR2
) RETURN VARCHAR2 IS
  cursor c1 is
    select category_id
      from cs_kb_soln_categories_b
      start with category_id  = p_catid
      connect by prior parent_category_id = category_id;

Type category_id_tab_type  is TABLE OF NUMBER(15)     INDEX BY BINARY_INTEGER;
category_id_tbl   category_id_tab_type;

l_cat_name VARCHAR(2000);

j NUMBER(15);
composite_cat_name VARCHAR2(2000);

contains_gt BOOLEAN;

BEGIN
      open c1;

      j := 1;
      composite_cat_name := '';

      contains_gt := FALSE;

      loop
       fetch c1 INTO category_id_tbl(j);
       exit when c1%NOTFOUND;

       select name into l_cat_name
       from cs_kb_soln_categories_tl
       where language = userenv('LANG') and category_id = category_id_tbl(j);

       if(p_verify and 0 < instr(l_cat_name, '>')) then
         contains_gt := true;
       end if;

       if (j = 1) then
         composite_cat_name := l_cat_name || composite_cat_name;
       else
         composite_cat_name := l_cat_name || p_delim || composite_cat_name;
       end if;

      j := j+1;
      end loop;

      close c1;

      if(contains_gt) then
         FND_FILE.PUT_LINE(FND_FILE.LOG, fnd_message.GET_STRING('CS','CS_KB_EXPORT_INVCAT') || composite_cat_name);
      end if;

      return composite_cat_name;


END Get_Category_Full_Name;

/*
This is the same as the original validate_category_name, except it takes a delimiter param
*/
FUNCTION VALIDATE_CATEGORY_NAME_2
(
  p_name      IN  VARCHAR2,
  p_last_name IN  VARCHAR2,
  x_number OUT NOCOPY NUMBER,
  p_delim IN VARCHAR2
) RETURN NUMBER IS

Cursor c1 is
  select category_id from
  cs_kb_soln_categories_tl
  where upper(name) = upper(p_last_name)
  and language = userenv('LANG');

cursor c2(c_id IN NUMBER) is
    select tl.name
    from (    SELECT category_id, level lev
          FROM cs_kb_soln_categories_b
          START WITH category_id = c_id
          CONNECT BY prior parent_category_id = category_id
    ) b, cs_kb_soln_categories_tl tl
    where
    b.category_id = tl.category_id
    and tl.language = userenv( 'LANG' )
    order by b.lev;

l_count NUMBER(15);
j NUMBER(15);

Type category_id_tab_type  is TABLE OF NUMBER(15)     INDEX BY BINARY_INTEGER;
Type categ_name_tab_type   is TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;

category_id_tbl   category_id_tab_type;
category_name_tbl categ_name_tab_type;
tree_ids_tbl      category_id_tab_type;
tree_names_tbl    categ_name_tab_type;
composite_cat_name VARCHAR2(2000);
valid_flag boolean;

BEGIN

    -- Compare this path with p_name
    -- If there is a match then this is the one

l_count := 1;

open c1;
Loop

   Fetch c1 INTO category_id_tbl(l_count);
   EXIT WHEN c1%NOTFOUND;
   l_count := l_count + 1;

End Loop;
close c1;

--   dbms_output.put_line('Number='||category_id_tbl.count);

   -- loop thru the base level categories
   for i in 1..category_id_tbl.count loop

      valid_flag := false;
      open c2(category_id_tbl(i));

      j := 1;
      composite_cat_name := '';
      loop
       fetch c2 INTO tree_names_tbl(j);

       exit when c2%NOTFOUND;

       if (j = 1) then
         composite_cat_name := tree_names_tbl(j) || composite_cat_name;
       else
         composite_cat_name := tree_names_tbl(j) || p_delim || composite_cat_name;
       end if;

      j := j+1;
      end loop;

      close c2;

      if (upper(composite_cat_name) = upper(p_name))
      THEN
        x_number := category_id_tbl(i);
        valid_flag := true;
        exit;
      end IF;


   end loop;

   if (valid_flag = true)
   then

      RETURN OKAY_STATUS;

   else

      return ERROR_STATUS;
   end if;

EXCEPTION

   WHEN NO_DATA_FOUND THEN
       RETURN ERROR_STATUS;
   WHEN OTHERS THEN
       RETURN ERROR_STATUS;

END Validate_Category_Name_2;

/*
This is the same as the original Get_Category_Name, except it takes a delimiter param
*/
-- Given the Category name in a bread crumb form
-- Determine the last category name
-- For example given A>B>C>D, return D
--  (where '>' is whatever char specified by p_delim)

FUNCTION Get_Category_Name_2
(
  p_category_name  IN  varchar2,
  p_delim IN VARCHAR2
) RETURN VARCHAR2 IS

  l_temp         CS_KB_SOLN_CATEGORIES_TL.NAME%TYPE;
  l_start_loc    number := 1;
  l_temp_loc     number := 1;
  l_temp_loc_buf number := 1;
  l_length       number;
  l_out          CS_KB_SOLN_CATEGORIES_TL.NAME%TYPE;

  begin
  --remove spaces

  l_length := length(p_category_name);

  WHILE (l_temp_loc < l_length) AND (l_temp_loc >0)
  LOOP
        l_temp_loc := INSTR(p_category_name, p_delim, l_start_loc, 1);
        IF (l_temp_loc > 0) THEN
            l_temp_loc_buf := l_temp_loc + 1;
        END IF;
        l_start_loc := l_temp_loc + 1;
  END LOOP;

  l_out := SUBSTR(p_category_name, l_temp_loc_buf);
  l_out := RTRIM(l_out);
  l_out := LTRIM(l_out);

  RETURN l_out;

End Get_Category_Name_2;

/*
 * Export_Solutions_2
 *
 *  This procedure is used by the XML Solution Export
 *  concurrent program. Depending on the export mode selected,
 *  It can export either all published solutions or the
 *  latest version of all solutions in a particular category.
 *  The third parameter is the delimiter, which the concurrent
 *  program defaults to '>'.  However, the user may need to
 *  specify a different delimiter, if any category has '>' its name
 *
 *  Parameters:
 *    p_category_name - This should be the full textual path
 *      of the category for which solutions will be exported.
 *      The individual category names should be separated by
 *      the delimiter. Example: 'Home <delim> Desktop <delim>Monitor'
 *    p_sol_status - One of 2 mode values: ALL or PUB. This
 *      determines whether only published solutions are exported
 *      or the latest version of all non-obsoleted solutions
 *      are exported.
 *    delim - The delimiter used
 */
PROCEDURE EXPORT_SOLUTIONS_2
(
  errbuf   OUT NOCOPY VARCHAR2,
  retcode  OUT NOCOPY NUMBER,
  p_category_name  IN  VARCHAR2,
  p_sol_status     IN  VARCHAR2,
  p_delim IN VARCHAR2
) IS


-- Fetch info for the published version of all published solutions
-- in a category
CURSOR get_solution_info_pub(c_category_id IN NUMBER)
IS
select  /*+ index(sc) */a.set_id, a.set_number, c.name, v.name, b.name, a.status
from cs_kb_sets_b a, cs_kb_sets_tl b, cs_kb_set_types_vl c,
     cs_kb_visibilities_vl v, cs_kb_set_categories sc
where  a.set_type_id = c.set_type_id
and a.set_id = sc.set_id and sc.category_id = c_category_id
and a.set_id = b.set_id and b.language = userenv('LANG')
and a.visibility_id = v.visibility_id
and a.status = 'PUB';

-- Fetch info for the latest version of all non-obsolete solutions
-- in a category
CURSOR get_solution_info_all(c_category_id IN NUMBER)
IS
select /*+ index(sc) */ a.set_id, a.set_number, c.name, v.name, b.name, a.status
from cs_kb_sets_b a, cs_kb_sets_tl b, cs_kb_set_types_vl c,
     cs_kb_visibilities_vl v, cs_kb_set_categories sc
where a.set_type_id = c.set_type_id
and a.set_id = sc.set_id and sc.category_id = c_category_id
and a.set_id = b.set_id and b.language = userenv('LANG')
and a.visibility_id = v.visibility_id
and a.status <> 'OBS'
and a.latest_version_flag = 'Y';


-- Fetch info for all statements for a solution
CURSOR get_element_info(c_set_id IN NUMBER) IS
select  a.element_number, d.name, e.meaning,
        NVL(a.content_type, 'TEXT/HTML'), b.name, b.description, a.status
from    cs_kb_elements_b a , cs_kb_elements_tl b, cs_kb_set_eles c,
        cs_kb_element_types_vl d, cs_lookups e
where   a.element_id = c.element_id and c.set_id = c_set_id
and     a.element_id = b.element_id and b.language = userenv('LANG')
and     a.element_type_id = d.element_type_id
and     a.access_level = e.lookup_code and e.lookup_type = 'CS_KB_ACCESS_LEVEL';

-- Fetch info for all products the solution links to
CURSOR get_product_info(c_set_id IN NUMBER) IS
SELECT  it.description,it.concatenated_segments
FROM mtl_system_items_vl it, mtl_item_categories ic, cs_kb_set_products a
where it.inventory_item_id = ic.inventory_item_id
and   it.organization_id = ic.organization_id
and   it.organization_id = cs_std.get_item_valdn_orgzn_id
and   ic.category_set_id = fnd_profile.value('CS_KB_PRODUCT_CATEGORY_SET')
and   it.inventory_item_id = a.product_id
and   a.set_id = c_set_id;

-- Fetch info for all platforms the solution links to
CURSOR get_platform_info(c_set_id IN NUMBER) IS
SELECT it.description,it.concatenated_segments
FROM   mtl_system_items_vl it, mtl_item_categories ic, cs_kb_set_platforms a
where  it.inventory_item_id = ic.inventory_item_id
and    it.organization_id = ic.organization_id
and    it.organization_id = cs_std.get_item_valdn_orgzn_id
and    ic.category_set_id = fnd_profile.value('CS_SR_PLATFORM_CATEGORY_SET')
and    it.inventory_item_id = a.platform_id
and    a.set_id = c_set_id;

-- Fetch all category ids associated with this solution
CURSOR get_category_ids(c_set_id IN NUMBER) IS
Select a.category_id
from cs_kb_set_categories a
where a.set_id = c_set_id;

-- Declare some local temporary variables
l_category_name     CS_KB_SOLN_CATEGORIES_TL.NAME%TYPE;
l_category_id       NUMBER(15);
l_ret_val           NUMBER(15);
l_gt                VARCHAR2(15);
l_elmt_content_type VARCHAR2(30);

l_soln_count       NUMBER(15);
l_elmt_count       NUMBER(15);
l_prod_count       NUMBER(15);
l_plat_count       NUMBER(15);

l_soln_index       NUMBER(15);
l_elmt_index       NUMBER(15);
l_prod_index       NUMBER(15);
l_plat_index       NUMBER(15);

l_cat_index       NUMBER(15);

Type set_id_tab_type
  is TABLE OF CS_KB_SETS_B.SET_ID%TYPE INDEX BY BINARY_INTEGER;
Type set_number_tab_type
  is TABLE OF CS_KB_SETS_B.SET_NUMBER%TYPE INDEX BY BINARY_INTEGER;
Type set_type_name_tab_type
  is TABLE OF CS_KB_SET_TYPES_TL.NAME%TYPE INDEX BY BINARY_INTEGER;
Type set_name_tab_type
  is TABLE OF CS_KB_SETS_TL.NAME%TYPE INDEX BY BINARY_INTEGER;
Type set_vis_tab_type
  is TABLE OF CS_LOOKUPS.MEANING%TYPE INDEX BY BINARY_INTEGER;
Type set_status_tab_type
  is TABLE OF CS_KB_SETS_B.STATUS%TYPE INDEX BY BINARY_INTEGER;
Type cat_id_tab_type
  is TABLE OF CS_KB_SOLN_CATEGORIES_VL.CATEGORY_ID%TYPE INDEX BY BINARY_INTEGER;

l_set_ids        set_id_tab_type;
l_set_nos        set_number_tab_type;
l_set_type_names set_type_name_tab_type;
l_set_names      set_name_tab_type;
l_set_vis        set_vis_tab_type;
l_set_status     set_status_tab_type;
l_cat_ids        cat_id_tab_type;

Type elmt_number_tab_type
  is TABLE OF CS_KB_ELEMENTS_B.ELEMENT_NUMBER%TYPE INDEX BY BINARY_INTEGER;
Type elmt_type_name_tab_type
  is TABLE OF CS_KB_ELEMENT_TYPES_TL.NAME%TYPE INDEX BY BINARY_INTEGER;
Type elmt_name_tab_type
  is TABLE OF CS_KB_ELEMENTS_TL.NAME%TYPE INDEX BY BINARY_INTEGER;
Type elmt_desc_tab_type
  is TABLE OF CS_KB_ELEMENTS_TL.DESCRIPTION%TYPE INDEX BY BINARY_INTEGER;
Type elmt_dist_tab_type
  is TABLE OF CS_LOOKUPS.MEANING%TYPE INDEX BY BINARY_INTEGER;
Type elmt_status_tab_type
  is TABLE OF CS_KB_ELEMENTS_B.STATUS%TYPE INDEX BY BINARY_INTEGER;
Type elmt_ct_tab_type
  is TABLE OF CS_KB_ELEMENTS_B.CONTENT_TYPE%TYPE INDEX BY BINARY_INTEGER;

l_elmt_nos         elmt_number_tab_type;
l_elmt_type_names  elmt_type_name_tab_type;
l_elmt_names       elmt_name_tab_type;
l_elmt_descs       elmt_desc_tab_type;
l_elmt_dists       elmt_dist_tab_type;
l_elmt_stats       elmt_status_tab_type;
l_elmt_cts         elmt_ct_tab_type;

Type prod_name_tab_type
  is TABLE OF MTL_SYSTEM_ITEMS_VL.description%TYPE INDEX BY BINARY_INTEGER;
Type plat_name_tab_type
  is TABLE OF MTL_SYSTEM_ITEMS_VL.description%TYPE INDEX BY BINARY_INTEGER;

l_prod_names prod_name_tab_type;
l_prod_segments MTL_SYSTEM_ITEMS_VL.concatenated_segments%TYPE;
l_plat_names plat_name_tab_type;
l_plat_segments MTL_SYSTEM_ITEMS_VL.concatenated_segments%TYPE;

--local delimiter
l_delim             VARCHAR2(10);

-- Cursor + Vars to Validate Stmt Content
 CURSOR Get_Stmts (v_set_id NUMBER) is
  SELECT
    eb.Element_Number,
    replace(
      replace(
        replace(
          replace(
            replace(et.description, '&','&'||'amp;' )
                                 , '>','&'||'gt;')
                                 , '<','&'||'lt;')
                                 , '''','&'||'apos;')
                                 , '"' ,'&'||'quot;') stmt
  FROM CS_KB_ELEMENTS_TL et,
       CS_KB_ELEMENTS_B eb,
       CS_KB_SET_ELES se
  WHERE et.language = userenv('LANG')
  AND   eb.Element_Id = et.Element_Id
  AND   eb.element_id = se.element_id
  AND   se.set_id = v_set_id;

 l_Num   NUMBER;
 l_Start NUMBER;
 l_Limit NUMBER := 32000;
 l_Error VARCHAR2(1);
 l_success_solns NUMBER;
 l_Stmts VARCHAR2(2000);


BEGIN
-- trim and use only first character of the delimiter
l_delim := p_delim;
l_delim := RTRIM(l_delim);
l_delim := LTRIM(l_delim);
l_delim := substr(l_delim,1,1);

-- dbms_output.put_line('l_delim='|| l_delim);

 -- Extract the Category Name from the Bread Crumb
 l_category_name := get_category_name_2(p_category_name, l_delim);

 -- Determine the category id for the category name
 l_ret_val := Validate_category_Name_2(p_category_name,
                                     l_category_name,
                                     l_category_id, l_delim);

 IF ( l_ret_val = ERROR_STATUS)
 THEN
  raise INVALID_CATEGORY_NAME;
 END IF;

 --remove this, use encode_text instead
 l_gt := '&' || 'gt;';

/*******************************************************
 *
 * Query OUT All the set_ids matching the criteria
 *
 *******************************************************/

FND_FILE.PUT_LINE(FND_FILE.LOG, fnd_message.GET_STRING('CS','CS_KB_EXPORT_CAT')|| p_category_name);
FND_FILE.PUT_LINE(FND_FILE.LOG, fnd_message.GET_STRING('CS','CS_KB_EXPORT_STATUS')|| p_sol_status);

FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<?xml version="1.0"?>');
FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<!DOCTYPE solution_list SYSTEM "cskb_solution.dtd">');

IF (p_sol_status = 'ALL')
THEN
   SELECT /*+ index(sc) */ count(a.set_number) INTO l_soln_count
   from cs_kb_sets_b a, cs_kb_sets_tl b, cs_kb_set_types_vl c,
        cs_kb_visibilities_vl v, cs_kb_set_categories sc
   where a.set_type_id = c.set_type_id
   and a.set_id = sc.set_id and sc.category_id = l_category_id
   and a.set_id = b.set_id and b.language = userenv('LANG')
   and a.visibility_id = v.visibility_id
   and a.status <> 'OBS'
   and a.latest_version_flag = 'Y';
ELSE
   SELECT  count(a.set_number) INTO l_soln_count
   from cs_kb_sets_b a, cs_kb_sets_tl b, cs_kb_set_types_vl c,
        cs_kb_visibilities_vl v, cs_kb_set_categories sc
   where a.set_type_id = c.set_type_id
   and a.set_id = sc.set_id and sc.category_id = l_category_id
   and a.set_id = b.set_id and b.language = userenv('LANG')
   and a.visibility_id = v.visibility_id
   and a.status = 'PUB';
END IF;

IF (l_soln_count > 0) THEN
  FND_FILE.PUT_LINE(FND_FILE.LOG, fnd_message.GET_STRING('CS','CS_KB_EXPORT_ATTEMPT') || l_soln_count);
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<solution_list>');
END IF;

l_soln_index := 1;
l_success_solns := 0;


IF (p_sol_status = 'ALL')
THEN
   open get_solution_info_all(l_category_id);
ELSE
   open get_solution_info_pub(l_category_id);
END IF;

loop

IF (p_sol_status = 'ALL')
THEN
  fetch get_solution_info_all INTO l_set_ids(l_soln_index), l_set_nos(l_soln_index),
                                   l_set_type_names(l_soln_index),
                                   l_set_vis(l_soln_index),
                                   l_set_names(l_soln_index),
                                   l_set_status(l_soln_index);

  exit when get_solution_info_all%NOTFOUND;
ELSE
  fetch get_solution_info_pub INTO l_set_ids(l_soln_index), l_set_nos(l_soln_index),
                               l_set_type_names(l_soln_index),
                               l_set_vis(l_soln_index),
                               l_set_names(l_soln_index),
                               l_set_status(l_soln_index);

  exit when get_solution_info_pub%NOTFOUND;

END IF;

-- Need to Validate Solution Content prior to dumping output
-- Check Content of Clob to check if is valid
-- Check content does not exceed 32K without a linebreak
l_Error := 'N';
l_Stmts := null;
FOR StmtCheck IN Get_Stmts (l_set_ids(l_soln_index))LOOP

  -- If the Stmt Summary is > 32K then we need to check it for Line Breaks
  IF length(StmtCheck.stmt) > l_limit THEN
    -- Set the Start Position
    l_Start := 1;
    -- Use a Loop to validate each 32K chunk of the Statement
    LOOP
      -- Find the position of the new Line (line break) character working
      -- backwards from the end of the stmt 32K chunk
      l_Num := instr(substr(StmtCheck.stmt,l_Start, l_Limit) , FND_GLOBAL.newline, -1, 1);
      -- Reset the start position to be the previous line break identified in the chunk
      l_Start := l_Start + l_Num;

      -- If l_Num = 0 Then NO new line characters were found in the chunk
      IF l_Num = 0 THEN
        -- Validate if this is the last chunk (and that the size < 32K)
        -- If this is NOT the last chunk then this will cause an error
        -- when using FND_FILE, so through exception and do not process
        -- this Solution.
        IF l_Start < (length(StmtCheck.stmt) - l_Limit ) THEN
          l_Error := 'Y';
          IF l_Stmts is null THEN
            l_Stmts := StmtCheck.Element_Number;
          ELSE
            l_Stmts := l_Stmts||', '||StmtCheck.Element_Number;
          END IF;

        END IF;

      END IF;

    EXIT WHEN l_Num = 0;  -- 0 Signifies the end
    END LOOP;

  END IF;

END LOOP;

IF l_error = 'Y' THEN
  -- If any of the statements failed validation add a message to the Log
  FND_MESSAGE.set_name('CS', 'CS_KB_EXPORT_STMT_32K');
  FND_MESSAGE.SET_TOKEN(TOKEN => 'SOLN_NUMBER',
                        VALUE => l_set_nos(l_soln_index) );
  FND_MESSAGE.SET_TOKEN(TOKEN => 'STMT_NUMBER',
                        VALUE => l_stmts );
  FND_FILE.PUT_LINE(FND_FILE.LOG, fnd_message.GET);

ELSIF l_error = 'N' THEN

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ' || '<solution>');

    FND_FILE.PUT(FND_FILE.OUTPUT, '  ' || '<solution_number>');
    FND_FILE.PUT(FND_FILE.OUTPUT, l_set_nos(l_soln_index));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</solution_number>');

    FND_FILE.PUT(FND_FILE.OUTPUT, '  ' || '<solution_type>');
    FND_FILE.PUT(FND_FILE.OUTPUT, l_set_type_names(l_soln_index));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</solution_type>');

    FND_FILE.PUT(FND_FILE.OUTPUT, '  ' || '<solution_visibility>');
    FND_FILE.PUT(FND_FILE.OUTPUT, l_set_vis(l_soln_index));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</solution_visibility>');

    FND_FILE.PUT(FND_FILE.OUTPUT, '  ' || '<title>');
    FND_FILE.PUT(FND_FILE.OUTPUT, Encode_Text(l_set_names(l_soln_index)));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</title>');

  -- output all categories instead of just the one specified by parameter
  l_cat_index := 1;
  open get_category_ids(l_set_ids(l_soln_index));

  loop

    fetch get_category_ids INTO l_cat_ids(l_cat_index);
    exit when get_category_ids%NOTFOUND;

    FND_FILE.PUT(FND_FILE.OUTPUT, '  ' || '<category>');
    FND_FILE.PUT(FND_FILE.OUTPUT, encode_text(get_category_full_name(l_cat_ids(l_cat_index), l_delim, true)));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</category>');

    l_cat_index := l_cat_index + 1;

  end loop;

  close get_category_ids;

  -- Start Querying out Products

  l_prod_index := 1;
  open get_product_info(l_set_ids(l_soln_index));

  loop

    fetch get_product_info INTO l_prod_names(l_prod_index),l_prod_segments;
    exit when get_product_info%NOTFOUND;

    FND_FILE.PUT(FND_FILE.OUTPUT, '  ' || '<product segments="'|| Encode_Text(l_prod_segments) ||'">');
    FND_FILE.PUT(FND_FILE.OUTPUT, Encode_Text(l_prod_names(l_prod_index)));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</product>');

    l_prod_index := l_prod_index + 1;

  end loop;

  close get_product_info;

  -- End Querying Products

  -- Start Querying out Platforms


  l_plat_index := 1;
  open get_platform_info(l_set_ids(l_soln_index));

  loop

    fetch get_platform_info INTO l_plat_names(l_plat_index),l_plat_segments;
    exit when get_platform_info%NOTFOUND;

    FND_FILE.PUT(FND_FILE.OUTPUT, '  ' || '<platform segments="'|| Encode_Text(l_plat_segments) ||'">');
    FND_FILE.PUT(FND_FILE.OUTPUT, Encode_Text(l_plat_names(l_plat_index)));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</platform>');

    l_plat_index := l_plat_index + 1;

  end loop;

  close get_platform_info;


  -- End Querying Platforms


  -- Start Querying out Statements for this Solution

  l_elmt_index := 1;
  open get_element_info(l_set_ids(l_soln_index));

  loop
    fetch get_element_info INTO l_elmt_nos(l_elmt_index), l_elmt_type_names(l_elmt_index),
                                l_elmt_dists(l_elmt_index),
                                l_elmt_cts(l_elmt_index),
                                l_elmt_names(l_elmt_index), l_elmt_descs(l_elmt_index),
                                l_elmt_stats(l_elmt_index);

    exit when get_element_info%NOTFOUND;
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '  ' || '<statement_link_update>');

    FND_FILE.PUT(FND_FILE.OUTPUT, '   ' || '<statement_no_upd>');
    FND_FILE.PUT(FND_FILE.OUTPUT, l_elmt_nos(l_elmt_index));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</statement_no_upd>');

    FND_FILE.PUT(FND_FILE.OUTPUT, '   ' || '<statement_distribution_upd>');
    FND_FILE.PUT(FND_FILE.OUTPUT, l_elmt_dists(l_elmt_index));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</statement_distribution_upd>');

    -- Determine the Value for the content type from lookups

    select meaning
    INTO   l_elmt_content_type
    from cs_lookups
    where lookup_type = 'CS_KB_CONTENT_TYPE'
    and lookup_code = l_elmt_cts(l_elmt_index);

    FND_FILE.PUT(FND_FILE.OUTPUT, '   ' || '<content_type_upd>');
    FND_FILE.PUT(FND_FILE.OUTPUT, l_elmt_content_type);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</content_type_upd>');

    FND_FILE.PUT(FND_FILE.OUTPUT, '   ' || '<summary_upd>');
    FND_FILE.PUT(FND_FILE.OUTPUT, Encode_Text(l_elmt_names(l_elmt_index)));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</summary_upd>');

    FND_FILE.PUT(FND_FILE.OUTPUT, '   ' || '<detail_upd>');
    Write_Clob_To_File(l_elmt_descs(l_elmt_index), FND_FILE.OUTPUT);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</detail_upd>');

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '  ' || '</statement_link_update>');

    l_elmt_index :=  l_elmt_index + 1;

  end loop;

  close get_element_info;

  -- End Querying out Statements for this Solution

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ' || '</solution>');

   l_success_solns := l_success_solns + 1;

 --ELSE -- Solution Contains invalid content for export

END IF; -- Validate Soln Content

 l_soln_index := l_soln_index + 1;

end loop; -- For Solutions Loop

IF (p_sol_status = 'ALL')
THEN
  close get_solution_info_all;
ELSE
  close get_solution_info_pub;
END IF;

IF (l_soln_count > 0) THEN
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</solution_list>');
END IF;

l_soln_index := l_soln_index - 1;

FND_FILE.PUT_LINE(FND_FILE.LOG, fnd_message.GET_STRING('CS','CS_KB_EXPORT_COUNT') || l_success_solns); --l_soln_index);

EXCEPTION

WHEN INVALID_CATEGORY_NAME

THEN

   FND_FILE.PUT_LINE(FND_FILE.LOG, fnd_message.GET_STRING('CS','CS_KB_EXPORT_INVCAT') || p_category_name);
   FND_FILE.PUT_LINE(FND_FILE.LOG, fnd_message.GET_STRING('CS','CS_KB_EXPORT_RETST')|| ERROR_STATUS);
   RETCODE := ERROR_STATUS;

WHEN OTHERS

THEN

   FND_FILE.PUT_LINE(FND_FILE.LOG, fnd_message.GET_STRING('CS','CS_KB_EXPORT_UNEXP')||'-'||substrb(sqlerrm,1,100));
   FND_FILE.PUT_LINE(FND_FILE.LOG, fnd_message.GET_STRING('CS','CS_KB_EXPORT_RETST')|| ERROR_STATUS);
   RETCODE := ERROR_STATUS;

END EXPORT_SOLUTIONS_2;

PROCEDURE Clone_Soln_After_Import
    (
    x_return_status        OUT NOCOPY varchar2,
    x_msg_count            OUT NOCOPY number,
    x_msg_data             OUT NOCOPY varchar2,
    p_set_flow_name        IN  VARCHAR2,
    p_set_flow_stepcode    IN  VARCHAR2,
    p_set_number           IN  VARCHAR2
    ) IS

    l_set_id            NUMBER;
    l_flow_details_id   number := null;
    l_return_val        NUMBER;

  BEGIN
    SAVEPOINT Clone_Soln;
    -- validate flow info if provided
    IF (p_set_flow_name IS NOT NULL) AND (p_set_flow_stepcode IS NOT NULL) THEN
      l_return_val := Validate_Flow (
  	                 p_flow_name   => p_set_flow_name,
  	                 p_flow_step   => p_set_flow_stepcode,
  	                 x_flow_details_id => l_flow_details_id);

      IF (l_return_val = ERROR_STATUS)
        THEN RAISE INVALID_FLOW;
      END IF;
    END IF;
    IF (l_flow_details_id IS NOT NULL) THEN
       l_set_id := CS_KB_SOLUTION_PVT.clone_solution(p_set_number,
                                                     'PUB',
                                                     l_flow_details_id,
                                                     null);
   END IF;
   x_return_status := fnd_api.g_ret_sts_success;
   x_msg_count := 0;
   x_msg_data := null;
  EXCEPTION
    WHEN INVALID_FLOW THEN
       ROLLBACK TO Clone_Soln;
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_msg_count     := 1;
       x_msg_data      := 'Invalid flow: ' || p_set_flow_name ||
		  ' or step: ' || p_set_flow_stepcode;
     WHEN OTHERS THEN
        ROLLBACK TO Clone_Soln;
        x_msg_data      := 'Creating solution: ' || SQLERRM ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        x_msg_count := 1;
  END Clone_Soln_After_Import;
END CS_KNOWLEDGE_AUDIT_PVT;

/
