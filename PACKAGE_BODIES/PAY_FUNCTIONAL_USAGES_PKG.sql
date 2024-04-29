--------------------------------------------------------
--  DDL for Package Body PAY_FUNCTIONAL_USAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FUNCTIONAL_USAGES_PKG" AS
-- $Header: pypfuapi.pkb 115.2 2002/12/11 15:13:43 exjones noship $
--
	PROCEDURE lock_row(
	  p_row_id            IN VARCHAR2,
	  p_usage_id          IN NUMBER,
	  p_area_id           IN NUMBER,
	  p_legislation_code  IN VARCHAR2,
	  p_business_group_id IN NUMBER,
	  p_payroll_id        IN NUMBER
	) IS
	  --
	  CURSOR csr_functional_usage IS
	    SELECT  *
	    FROM    pay_functional_usages
	    WHERE   rowid = p_row_id
	    FOR UPDATE OF
	            usage_id NOWAIT;
	  --
	  usage_record  csr_functional_usage%ROWTYPE;
	  --
	BEGIN
    OPEN csr_functional_usage;
    FETCH csr_functional_usage INTO usage_record;
    IF csr_functional_usage%NOTFOUND THEN
      CLOSE csr_functional_usage;
      Hr_Utility.Set_Message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      Hr_Utility.Set_Message_Token(
        'PROCEDURE',
        'PAY_FUNCTIONAL_USAGES_PKG.LOCK_ROW'
      );
    END IF;
    CLOSE csr_functional_usage;
    --
    IF  ((usage_record.usage_id = p_usage_id) OR
         (usage_record.usage_id IS NULL AND p_usage_id IS NULL))
    AND ((usage_record.area_id = p_area_id) OR
         (usage_record.area_id IS NULL AND p_area_id IS NULL))
    AND ((usage_record.legislation_code = p_legislation_code) OR
         (usage_record.legislation_code IS NULL AND p_legislation_code IS NULL))
    AND ((usage_record.business_group_id = p_business_group_id) OR
         (usage_record.business_group_id IS NULL AND p_business_group_id IS NULL))
    AND ((usage_record.payroll_id = p_payroll_id) OR
         (usage_record.payroll_id IS NULL AND p_payroll_id IS NULL))
    THEN
      RETURN;
    ELSE
      Hr_Utility.Set_Message(0,'FORM_RECORD_CHANGED');
      Hr_Utility.Raise_Error;
    END IF;
	END lock_row;
--
	PROCEDURE insert_row(
	  p_row_id            IN out nocopy VARCHAR2,
	  p_usage_id          IN out nocopy NUMBER,
	  p_area_id           IN NUMBER,
	  p_legislation_code  IN VARCHAR2,
	  p_business_group_id IN NUMBER,
	  p_payroll_id        IN NUMBER
	) IS
 	  --
 	  CURSOR csr_new_id IS
 	    SELECT  pay_functional_usages_s.NEXTVAL
 	    FROM    dual;
 	  --
 	  CURSOR csr_usage_rowid IS
 	    SELECT  rowid
 	    FROM    pay_functional_usages
 	    WHERE   usage_id = p_usage_id;
 	  --
	BEGIN
    --
    OPEN csr_new_id;
    FETCH csr_new_id INTO p_usage_id;
    CLOSE csr_new_id;
    --
    INSERT INTO pay_functional_usages(
      usage_id,
      area_id,
      legislation_code,
      business_group_id,
      payroll_id
    ) VALUES (
      p_usage_id,
      p_area_id,
      p_legislation_code,
      p_business_group_id,
      p_payroll_id
    );
    --
    OPEN csr_usage_rowid;
    FETCH csr_usage_rowid INTO p_row_id;
    IF csr_usage_rowid%NOTFOUND THEN
      CLOSE csr_usage_rowid;
      Hr_Utility.Set_Message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      Hr_Utility.Set_Message_Token(
        'PROCEDURE',
        'PAY_FUNCTIONAL_USAGES_PKG.INSERT_ROW'
      );
    END IF;
    CLOSE csr_usage_rowid;
    --
	END insert_row;
--
	PROCEDURE update_row(
	  p_row_id            IN VARCHAR2,
	  p_usage_id          IN NUMBER,
	  p_area_id           IN NUMBER,
	  p_legislation_code  IN VARCHAR2,
	  p_business_group_id IN NUMBER,
	  p_payroll_id        IN NUMBER
	) IS
  BEGIN
    UPDATE  pay_functional_usages
    SET     usage_id          = p_usage_id,
            area_id           = p_area_id,
            legislation_code  = p_legislation_code,
            business_group_id = p_business_group_id,
            payroll_id        = p_payroll_id
    WHERE   rowid             = p_row_id;
    --
    IF SQL%NOTFOUND THEN
      Hr_Utility.Set_Message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      Hr_Utility.Set_Message_Token(
        'PROCEDURE',
        'PAY_FUNCTIONAL_USAGES_PKG.UPDATE_ROW'
      );
    END IF;
	END update_row;
--
	PROCEDURE delete_row(
	  p_row_id            IN VARCHAR2,
	  p_usage_id          IN NUMBER
	) IS
	BEGIN
    DELETE
    FROM    pay_functional_usages
    WHERE   rowid = p_row_id;
    --
    IF SQL%NOTFOUND THEN
      Hr_Utility.Set_Message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      Hr_Utility.Set_Message_Token(
        'PROCEDURE',
        'PAY_FUNCTIONAL_USAGES_PKG.DELETE_ROW'
      );
    END IF;
	END delete_row;
--
END pay_functional_usages_pkg;

/
