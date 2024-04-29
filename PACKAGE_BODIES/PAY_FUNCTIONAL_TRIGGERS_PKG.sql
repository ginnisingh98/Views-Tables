--------------------------------------------------------
--  DDL for Package Body PAY_FUNCTIONAL_TRIGGERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FUNCTIONAL_TRIGGERS_PKG" AS
-- $Header: pypftapi.pkb 115.2 2002/12/11 15:13:31 exjones noship $
--
	PROCEDURE lock_row(
	  p_row_id      IN VARCHAR2,
	  p_trigger_id  IN NUMBER,
	  p_area_id     IN NUMBER,
	  p_event_id    IN NUMBER
	) IS
	  --
	  CURSOR csr_functional_trigger IS
	    SELECT  *
	    FROM    pay_functional_triggers
	    WHERE   rowid = p_row_id
	    FOR UPDATE OF
	            trigger_id NOWAIT;
	  --
	  trigger_record  csr_functional_trigger%ROWTYPE;
	  --
	BEGIN
    OPEN csr_functional_trigger;
    FETCH csr_functional_trigger INTO trigger_record;
    IF csr_functional_trigger%NOTFOUND THEN
      CLOSE csr_functional_trigger;
      Hr_Utility.Set_Message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      Hr_Utility.Set_Message_Token(
        'PROCEDURE',
        'PAY_FUNCTIONAL_TRIGGERS_PKG.LOCK_ROW'
      );
    END IF;
    CLOSE csr_functional_trigger;
    --
    IF  ((trigger_record.trigger_id = p_trigger_id) OR
         (trigger_record.trigger_id IS NULL AND p_trigger_id IS NULL))
    AND ((trigger_record.event_id = p_event_id) OR
         (trigger_record.event_id IS NULL AND p_event_id IS NULL))
    AND ((trigger_record.area_id = p_area_id) OR
         (trigger_record.area_id IS NULL AND p_area_id IS NULL))
    THEN
      RETURN;
    ELSE
      Hr_Utility.Set_Message(0,'FORM_RECORD_CHANGED');
      Hr_Utility.Raise_Error;
    END IF;
	END lock_row;
--
	PROCEDURE insert_row(
	  p_row_id      IN out nocopy VARCHAR2,
	  p_trigger_id  IN out nocopy NUMBER,
	  p_area_id     IN NUMBER,
	  p_event_id    IN NUMBER
	) IS
 	  --
 	  CURSOR csr_new_id IS
 	    SELECT  pay_functional_triggers_s.NEXTVAL
 	    FROM    dual;
 	  --
 	  CURSOR csr_trigger_rowid IS
 	    SELECT  rowid
 	    FROM    pay_functional_triggers
 	    WHERE   trigger_id = p_trigger_id;
 	  --
	BEGIN
    --
    OPEN csr_new_id;
    FETCH csr_new_id INTO p_trigger_id;
    CLOSE csr_new_id;
    --
    INSERT INTO pay_functional_triggers(
      trigger_id,
      area_id,
      event_id
    ) VALUES (
      p_trigger_id,
      p_area_id,
      p_event_id
    );
    --
    OPEN csr_trigger_rowid;
    FETCH csr_trigger_rowid INTO p_row_id;
    IF csr_trigger_rowid%NOTFOUND THEN
      CLOSE csr_trigger_rowid;
      Hr_Utility.Set_Message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      Hr_Utility.Set_Message_Token(
        'PROCEDURE',
        'PAY_FUNCTIONAL_TRIGGERS_PKG.INSERT_ROW'
      );
    END IF;
    CLOSE csr_trigger_rowid;
    --
	END insert_row;
--
	PROCEDURE update_row(
	  p_row_id      IN VARCHAR2,
	  p_trigger_id  IN NUMBER,
	  p_area_id     IN NUMBER,
	  p_event_id    IN NUMBER
	) IS
	BEGIN
    UPDATE  pay_functional_triggers
    SET     trigger_id  = p_trigger_id,
            area_id     = p_area_id,
            event_id    = p_event_id
    WHERE   rowid       = p_row_id;
    --
    IF SQL%NOTFOUND THEN
      Hr_Utility.Set_Message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      Hr_Utility.Set_Message_Token(
        'PROCEDURE',
        'PAY_FUNCTIONAL_TRIGGERS_PKG.UPDATE_ROW'
      );
    END IF;
	END update_row;
--
	PROCEDURE delete_row(
	  p_row_id      IN VARCHAR2,
	  p_trigger_id  IN NUMBER
	) IS
	BEGIN
    DELETE
    FROM    pay_functional_triggers
    WHERE   rowid = p_row_id;
    --
    IF SQL%NOTFOUND THEN
      Hr_Utility.Set_Message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      Hr_Utility.Set_Message_Token(
        'PROCEDURE',
        'PAY_FUNCTIONAL_TRIGGERS_PKG.DELETE_ROW'
      );
    END IF;
	END delete_row;
--
END pay_functional_triggers_pkg;

/
