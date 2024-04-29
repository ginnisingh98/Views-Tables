--------------------------------------------------------
--  DDL for Package Body PAY_FUNCTIONAL_AREAS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FUNCTIONAL_AREAS_PKG" AS
-- $Header: pypfaapi.pkb 115.3 2002/12/11 15:13:18 exjones noship $
--
----------------------------------------------------------------------------------
PROCEDURE lock_row(
		p_row_id	IN VARCHAR2,
 		p_area_id	IN NUMBER,
 		p_short_name	IN VARCHAR2,
 		p_description 	IN VARCHAR2
 	) IS
 	  CURSOR csr_functional_area IS
 	    SELECT  *
 	    FROM    pay_functional_areas
 	    WHERE   rowid = p_row_id
 	    FOR UPDATE OF
 	            area_id NOWAIT;
 	  --
 	  area_record csr_functional_area%ROWTYPE;
 	  --
BEGIN
    OPEN csr_functional_area;
    FETCH csr_functional_area INTO area_record;
    IF csr_functional_area%NOTFOUND THEN
      CLOSE csr_functional_area;
      Hr_Utility.Set_Message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      Hr_Utility.Set_Message_Token(
        'PROCEDURE',
        'PAY_FUNCTIONAL_AREAS_PKG.LOCK_ROW'
      );
    END IF;
    CLOSE csr_functional_area;
    --
    IF  ((area_record.area_id = p_area_id) OR
         (area_record.area_id IS NULL AND p_area_id IS NULL))
    AND ((area_record.short_name = p_short_name) OR
         (area_record.short_name IS NULL AND p_short_name IS NULL))
    AND ((area_record.description = p_description) OR
         (area_record.description IS NULL AND p_description IS NULL))
    THEN
      RETURN;
    ELSE
      Hr_Utility.Set_Message(0,'FORM_RECORD_CHANGED');
      Hr_Utility.Raise_Error;
    END IF;
END lock_row;
--
----------------------------------------------------------------------------------
PROCEDURE insert_row(
		p_row_id        IN out nocopy VARCHAR2,
 		p_area_id	IN out nocopy NUMBER,
 		p_short_name	IN VARCHAR2,
 		p_description 	IN VARCHAR2
 	) IS
 	  --
 	  CURSOR csr_new_id IS
 	    SELECT  pay_functional_areas_s.NEXTVAL
 	    FROM    dual;
 	  --
 	  CURSOR csr_area_rowid IS
 	    SELECT  rowid
 	    FROM    pay_functional_areas
 	    WHERE   area_id = p_area_id;
 	  --
 BEGIN
    --
    OPEN csr_new_id;
    FETCH csr_new_id INTO p_area_id;
    CLOSE csr_new_id;
    --
    INSERT INTO pay_functional_areas(
      area_id,
      short_name,
      description
    ) VALUES (
      p_area_id,
      p_short_name,
      p_description
    );
    --
    OPEN csr_area_rowid;
    FETCH csr_area_rowid INTO p_row_id;
    IF csr_area_rowid%NOTFOUND THEN
      CLOSE csr_area_rowid;
      Hr_Utility.Set_Message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      Hr_Utility.Set_Message_Token(
        'PROCEDURE',
        'PAY_FUNCTIONAL_AREAS_PKG.INSERT_ROW'
      );
    END IF;
    CLOSE csr_area_rowid;
    --
 END insert_row;
--
----------------------------------------------------------------------------------
PROCEDURE update_row(
		p_row_id        IN VARCHAR2,
 		p_area_id	IN NUMBER,
 		p_short_name	IN VARCHAR2,
 		p_description 	IN VARCHAR2
 	) IS
 BEGIN
    UPDATE  pay_functional_areas
    SET     area_id                     = p_area_id,
            short_name                  = p_short_name,
            description                 = p_description
    WHERE   rowid                       = p_row_id;
    --
    IF SQL%NOTFOUND THEN
      Hr_Utility.Set_Message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      Hr_Utility.Set_Message_Token(
        'PROCEDURE',
        'PAY_FUNCTIONAL_AREAS_PKG.UPDATE_ROW'
      );
    END IF;
 END update_row;
----------------------------------------------------------------------------------
PROCEDURE delete_row(
		p_row_id        IN VARCHAR2,
 		p_area_id	IN NUMBER
 	) IS
BEGIN
    DELETE
    FROM    pay_functional_areas
    WHERE   rowid = p_row_id;
    --
    IF SQL%NOTFOUND THEN
      Hr_Utility.Set_Message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      Hr_Utility.Set_Message_Token(
        'PROCEDURE',
        'PAY_FUNCTIONAL_AREAS_PKG.DELETE_ROW'
      );
    END IF;
END delete_row;
-----------------------------------------------------------------------------------
FUNCTION name_is_not_unique (
--
--*********************************************************************************
--* Returns TRUE if the functional area short name has been duplicated            *
--*********************************************************************************
--
-- Parameters are
--
p_short_name      varchar2,
p_area_id         number     default null
--
		) return boolean is
--
v_name_duplicated boolean := FALSE;
l_dummy_number number;
--
cursor csr_duplicate is
	select null
	from pay_functional_areas pfa
	where pfa.short_name = p_short_name
	and (pfa.area_id <> p_area_id
	     or p_area_id is null);
--
begin
--
  hr_utility.set_location('PAY_FUNCTIONAL_AREAS_PKG.NAME_IS_NOT_UNIQUE',1);
--
  open csr_duplicate;
  fetch csr_duplicate into l_dummy_number;
  v_name_duplicated := csr_duplicate%found;
  close csr_duplicate;
--
  return v_name_duplicated;
--
end name_is_not_unique;
--

END pay_functional_areas_pkg;

/
