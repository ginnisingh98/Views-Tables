--------------------------------------------------------
--  DDL for Package Body GR_TECHNICAL_PARAMETERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_TECHNICAL_PARAMETERS" AS
/*$Header: GRPTECHB.pls 120.3 2005/11/16 12:09:10 pbamb noship $*/

PROCEDURE Get_Tech_Parm_Data
				(p_commit IN VARCHAR2,
				 p_api_version IN NUMBER,
				 p_organization_id IN NUMBER,
				 p_property_id IN VARCHAR2,
				 p_inventory_item_id IN NUMBER,
				 p_label_code IN VARCHAR2,
				 x_value OUT NOCOPY VARCHAR2,
				 x_return_status OUT NOCOPY VARCHAR2,
				 x_msg_data OUT  NOCOPY VARCHAR2)
	IS
/* Alpha Variables */
L_API_NAME			CONSTANT VARCHAR2(30) := 'Get Tech Parm Data';
L_TEXT_DATA			VARCHAR2(80);
L_UNIT_CODE			VARCHAR2(4);
L_RETURN_STATUS			VARCHAR2(1) := 'S';
L_MSG_DATA			VARCHAR2(2000);
L_VALUE				VARCHAR2(240);
L_CHECK_FOR_VALUE		VARCHAR2(3);
L_TECH_PARM			VARCHAR2(1);
L_ORGN_CODE			VARCHAR2(4) := FND_PROFILE.Value('GEMMS_DEFAULT_ORGN');

/*   Numeric Variables */
L_API_VERSION	  		CONSTANT NUMBER := 1.0;
L_ORACLE_ERROR	  		NUMBER;
L_BOOLEAN_DATA			NUMBER(5);
L_NUM_DATA			NUMBER;
L_QCASSY_TYP_ID			NUMBER(15);
L_MSG_COUNT			NUMBER;
L_ITEM_ID			NUMBER;

/*   Exceptions */
NO_TECH_PARM_FOUND		EXCEPTION;
INCOMPATIBLE_API_VERSION_ERROR	EXCEPTION;

/* Declare cursors */

CURSOR Cur_get_description IS
	SELECT	label_description
	FROM	gr_labels_tl
	WHERE	label_code = p_label_code
	AND   	language   = userenv('LANG');
X_desc		Cur_get_description%ROWTYPE;

CURSOR c_get_lab_techparm IS
	SELECT	data_type, qcassy_typ_id, lm_unit_code, lowerbound_num,
		upperbound_num, lowerbound_char, upperbound_char, organization_id, tech_parm_id
	FROM 	lm_tech_hdr
	WHERE	organization_id = p_organization_id
	AND	tech_parm_name = X_desc.label_description;
LocalLabRecord		c_get_lab_techparm%ROWTYPE;

        --<Bug 4724991 consider global technical parameters>
CURSOR c_get_lab_techparm_global IS
        SELECT 	data_type, qcassy_typ_id, lm_unit_code, lowerbound_num,
		upperbound_num, lowerbound_char, upperbound_char, organization_id, tech_parm_id
	FROM	lm_tech_hdr
	WHERE	organization_id  IS NULL
	AND	tech_parm_name = X_desc.label_description;

/*  B2564522 Changed the cursor to incorporatethe QM changes*/
CURSOR c_get_specs IS
	SELECT	b.min_value_num, b.max_value_num, b.target_value_num, b.target_value_char, q.test_unit
	FROM 	gmd_spec_tests_b b, gmd_inventory_spec_vrs v, gmd_specifications_b s, gmd_qc_tests_b q
    WHERE	b.test_id = LocalLabRecord.qcassy_typ_id
	AND 	s.inventory_item_id = p_inventory_item_id
    AND  	b.spec_id = v.spec_id
    AND  	s.spec_id = b.spec_id
    AND	    q.test_id = b.test_id
	AND	   (v.organization_id = p_organization_id OR v.organization_id IS NULL)
	AND	   v.lot_number IS NULL
	AND	   v.subinventory IS NULL;
LocalSpecsRecord		c_get_specs%ROWTYPE;


CURSOR Cur_get_num(p_TECH_PARM_ID NUMBER) IS
	SELECT 	num_data
	FROM	lm_item_dat
	WHERE	organization_id = p_organization_id
	AND	tech_parm_name = X_desc.label_description
	AND	inventory_item_id = p_inventory_item_id
        AND tech_parm_id = p_TECH_PARM_ID;
X_num_data		Cur_get_num%ROWTYPE;

CURSOR Cur_get_text(p_TECH_PARM_ID NUMBER) IS
	SELECT	text_data
	FROM 	lm_item_dat
 	WHERE	organization_id = p_organization_id
	AND	tech_parm_name = X_desc.label_description
	AND	inventory_item_id = p_inventory_item_id
        AND tech_parm_id = p_TECH_PARM_ID;
X_text_data		Cur_get_text%ROWTYPE;

CURSOR Cur_get_boolean(p_TECH_PARM_ID NUMBER) IS
	SELECT	boolean_data
	FROM	lm_item_dat
 	WHERE	organization_id = p_organization_id
	AND	tech_parm_name = X_desc.label_description
	AND	inventory_item_id = p_inventory_item_id
        AND tech_parm_id = p_TECH_PARM_ID;
X_boolean_data	Cur_get_boolean%ROWTYPE;

CURSOR Cur_get_techparm IS
	SELECT 	tech_parm
	FROM	gr_labels_b
	WHERE	label_code = p_label_code;
LocalTechParmRecord	Cur_get_techparm%ROWTYPE;

BEGIN

/*     	Initialization Routine */

   SAVEPOINT Get_Tech_Parm_Data;
   x_msg_data := NULL;

/*	Now call the check API versions procedure */

   IF NOT FND_API.Compatible_API_Call
			     		(l_api_version,
			      		 p_api_version,
			      		 l_api_name,
			      		 g_pkg_name) THEN
      RAISE Incompatible_API_version_error;
   END IF;

/*
**		Set return status to successful
*/
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_check_for_value := 'YES';

	OPEN Cur_get_description;
	FETCH Cur_get_description INTO X_desc;

	IF Cur_get_description%NOTFOUND THEN
            	RAISE No_Tech_Parm_Found;
	END IF;

   OPEN c_get_lab_techparm;
   FETCH c_get_lab_techparm INTO LocalLabRecord;
   IF c_get_lab_techparm%FOUND THEN
	  WHILE c_get_lab_techparm%FOUND LOOP

	/* If we are looking at a numeric value */
	    IF (c_get_lab_techparm%FOUND and LocalLabRecord.data_type NOT IN (0,2,3,4)) THEN
	/* If it is not a QC assay */
		IF LocalLabRecord.qcassy_typ_id IS NULL THEN
		 IF p_property_id = 'LOW' THEN
			l_value := TO_CHAR(LocalLabRecord.lowerbound_num);
		   ELSIF p_property_id = 'HIGH' THEN
			l_value := TO_CHAR(LocalLabRecord.upperbound_num);
		   ELSIF p_property_id = 'VALUE' and l_check_for_value = 'YES' THEN
			OPEN Cur_get_num(LocalLabRecord.tech_parm_id);
			FETCH Cur_get_num INTO X_num_data;
			IF Cur_get_num%FOUND THEN
			 	l_value := TO_CHAR(X_num_data.num_data);
			END IF;
			CLOSE Cur_get_num;
		   ELSIF p_property_id = 'UNIT' THEN
			l_value := LocalLabRecord.lm_unit_code;
		   END IF;
 	/* This is a QC assay  B2564522 - changed the values for the correct columns from new table*/
		ELSE
		   OPEN c_get_specs;
		   FETCH c_get_specs INTO LocalSpecsRecord;
		   WHILE c_get_specs%FOUND LOOP
		    IF p_property_id = 'LOW' THEN
		   	l_value := TO_CHAR(LocalSpecsRecord.min_value_num);
		    ELSIF p_property_id = 'HIGH' THEN
			l_value := TO_CHAR(LocalSpecsRecord.max_value_num);
		    ELSIF p_property_id = 'VALUE' THEN
			l_value := TO_CHAR(LocalSpecsRecord.target_value_num);
		    ELSIF p_property_id = 'UNIT' THEN
			l_value := LocalSpecsRecord.test_unit;
		    END IF;
		    FETCH c_get_specs INTO LocalSpecsRecord;
		   END LOOP;
		   CLOSE c_get_specs;
		END IF;

	/* If it is a character value */
	   ELSIF LocalLabRecord.data_type = 0 THEN
	   	IF p_property_id = 'LW_CHR' THEN
		   	l_value := LocalLabRecord.lowerbound_char;
		END IF;
	   	IF p_property_id = 'HI_CHR' THEN
			l_value := LocalLabRecord.upperbound_char;
		END IF;
		IF p_property_id = 'VALUE' THEN
	/* If it is not a QC assay and we have an item id */
			IF LocalLabRecord.qcassy_typ_id IS NULL and l_check_for_value = 'YES' THEN
			   OPEN Cur_get_text(LocalLabRecord.tech_parm_id);
			   FETCH Cur_get_text INTO X_text_data;
			   IF Cur_get_text%FOUND THEN
				l_value := X_text_data.text_data;
			   END IF;
			   CLOSE Cur_get_text;
	/* If it is a QC assay B2564522 - changed the text to target_value_char*/
			ELSIF LocalLabRecord.qcassy_typ_id IS NOT NULL THEN
				OPEN c_get_specs;
				FETCH c_get_specs INTO LocalSpecsRecord;
				IF c_get_specs%FOUND THEN
					l_value := LocalSpecsRecord.target_value_char;
				END IF;
				CLOSE c_get_specs;
			END IF;
		ELSIF p_property_id = 'UNIT' THEN
			l_value := LocalLabRecord.lm_unit_code;

		END IF;
	/* If this is a list and we are looking for the item technical data */
	   ELSIF LocalLabRecord.data_type = 2  and l_check_for_value = 'YES' THEN
		/* Not a qc assay */
	     IF p_property_id = 'VALUE' THEN
		IF LocalLabRecord.qcassy_typ_id IS NULL THEN
		   OPEN Cur_get_text(LocalLabRecord.tech_parm_id);
		   FETCH Cur_get_text INTO X_text_data;
			IF Cur_get_text%FOUND THEN
				l_value := X_text_data.text_data;
			END IF;
		   CLOSE Cur_get_text;
		   /* A qc assay  B2564522 - changed text_spec to target_value_char*/
		ELSIF LocalLabRecord.qcassy_typ_id IS NOT NULL THEN
			OPEN c_get_specs;
			FETCH c_get_specs INTO LocalSpecsRecord;
			IF c_get_specs%FOUND THEN
				l_value := LocalSpecsRecord.target_value_char;
			END IF;
			CLOSE c_get_specs;
		END IF;
		/* QM  B2564522 - changed qcunit_code to test_unit*/
	      ELSIF p_property_id = 'UNIT' THEN
	        OPEN c_get_specs;
		FETCH c_get_specs INTO LocalSpecsRecord;
		IF c_get_specs%FOUND THEN
			l_value := LocalSpecsRecord.test_unit;
		END IF;
		CLOSE c_get_specs;
	      END IF;
	/*If this is a boolean and we are looking for the item technical data */
	   ELSIF LocalLabRecord.data_type = 3 and p_property_id = 'VALUE' and l_check_for_value = 'YES' THEN
		OPEN Cur_get_boolean(LocalLabRecord.tech_parm_id);
		FETCH Cur_get_boolean INTO X_boolean_data;
		IF Cur_get_boolean%FOUND THEN
		   	l_value := TO_CHAR(X_boolean_data.boolean_data);
		END IF;
		CLOSE Cur_get_boolean;
	   END IF;
	   FETCH c_get_lab_techparm INTO LocalLabRecord;
	   END LOOP;
   ELSE

     OPEN c_get_lab_techparm_global;
     FETCH c_get_lab_techparm_global INTO LocalLabRecord;
     WHILE c_get_lab_techparm_global%FOUND LOOP
	/* If we are looking at a numeric value */
	    IF (c_get_lab_techparm_global%FOUND and LocalLabRecord.data_type NOT IN (0,2,3,4)) THEN
	/* If it is not a QC assay */
		IF LocalLabRecord.qcassy_typ_id IS NULL THEN
		 IF p_property_id = 'LOW' THEN
			l_value := TO_CHAR(LocalLabRecord.lowerbound_num);
		   ELSIF p_property_id = 'HIGH' THEN
			l_value := TO_CHAR(LocalLabRecord.upperbound_num);
		   ELSIF p_property_id = 'VALUE' and l_check_for_value = 'YES' THEN
			OPEN Cur_get_num(LocalLabRecord.tech_parm_id);
			FETCH Cur_get_num INTO X_num_data;
			IF Cur_get_num%FOUND THEN
			 	l_value := TO_CHAR(X_num_data.num_data);
			END IF;
			CLOSE Cur_get_num;
		   ELSIF p_property_id = 'UNIT' THEN
			l_value := LocalLabRecord.lm_unit_code;
		   END IF;
 	/* This is a QC assay  B2564522 - changed the values for the correct columns from new table*/
		ELSE
		   OPEN c_get_specs;
		   FETCH c_get_specs INTO LocalSpecsRecord;
		   WHILE c_get_specs%FOUND LOOP
		    IF p_property_id = 'LOW' THEN
		   	l_value := TO_CHAR(LocalSpecsRecord.min_value_num);
		    ELSIF p_property_id = 'HIGH' THEN
			l_value := TO_CHAR(LocalSpecsRecord.max_value_num);
		    ELSIF p_property_id = 'VALUE' THEN
			l_value := TO_CHAR(LocalSpecsRecord.target_value_num);
		    ELSIF p_property_id = 'UNIT' THEN
			l_value := LocalSpecsRecord.test_unit;
		    END IF;
		    FETCH c_get_specs INTO LocalSpecsRecord;
		   END LOOP;
		   CLOSE c_get_specs;
		END IF;

	/* If it is a character value */
	   ELSIF LocalLabRecord.data_type = 0 THEN
	   	IF p_property_id = 'LW_CHR' THEN
		   	l_value := LocalLabRecord.lowerbound_char;
		END IF;
	   	IF p_property_id = 'HI_CHR' THEN
			l_value := LocalLabRecord.upperbound_char;
		END IF;
		IF p_property_id = 'VALUE' THEN
	/* If it is not a QC assay and we have an item id */
			IF LocalLabRecord.qcassy_typ_id IS NULL and l_check_for_value = 'YES' THEN
			   OPEN Cur_get_text(LocalLabRecord.tech_parm_id);
			   FETCH Cur_get_text INTO X_text_data;
			   IF Cur_get_text%FOUND THEN
				l_value := X_text_data.text_data;
			   END IF;
			   CLOSE Cur_get_text;
	/* If it is a QC assay B2564522 - changed the text to target_value_char*/
			ELSIF LocalLabRecord.qcassy_typ_id IS NOT NULL THEN
				OPEN c_get_specs;
				FETCH c_get_specs INTO LocalSpecsRecord;
				IF c_get_specs%FOUND THEN
					l_value := LocalSpecsRecord.target_value_char;
				END IF;
				CLOSE c_get_specs;
			END IF;
		ELSIF p_property_id = 'UNIT' THEN
			l_value := LocalLabRecord.lm_unit_code;

		END IF;
	/* If this is a list and we are looking for the item technical data */
	   ELSIF LocalLabRecord.data_type = 2  and l_check_for_value = 'YES' THEN
		/* Not a qc assay */
	     IF p_property_id = 'VALUE' THEN
		IF LocalLabRecord.qcassy_typ_id IS NULL THEN
		   OPEN Cur_get_text(LocalLabRecord.tech_parm_id);
		   FETCH Cur_get_text INTO X_text_data;
			IF Cur_get_text%FOUND THEN
				l_value := X_text_data.text_data;
			END IF;
		   CLOSE Cur_get_text;
		   /* A qc assay  B2564522 - changed text_spec to target_value_char*/
		ELSIF LocalLabRecord.qcassy_typ_id IS NOT NULL THEN
			OPEN c_get_specs;
			FETCH c_get_specs INTO LocalSpecsRecord;
			IF c_get_specs%FOUND THEN
				l_value := LocalSpecsRecord.target_value_char;
			END IF;
			CLOSE c_get_specs;
		END IF;
		/* QM  B2564522 - changed qcunit_code to test_unit*/
	      ELSIF p_property_id = 'UNIT' THEN
	        OPEN c_get_specs;
		FETCH c_get_specs INTO LocalSpecsRecord;
		IF c_get_specs%FOUND THEN
			l_value := LocalSpecsRecord.test_unit;
		END IF;
		CLOSE c_get_specs;
	      END IF;
	/*If this is a boolean and we are looking for the item technical data */
	   ELSIF LocalLabRecord.data_type = 3 and p_property_id = 'VALUE' and l_check_for_value = 'YES' THEN
		OPEN Cur_get_boolean(LocalLabRecord.tech_parm_id);
		FETCH Cur_get_boolean INTO X_boolean_data;
		IF Cur_get_boolean%FOUND THEN
		   	l_value := TO_CHAR(X_boolean_data.boolean_data);
		END IF;
		CLOSE Cur_get_boolean;
	   END IF;
	   FETCH c_get_lab_techparm_global INTO LocalLabRecord;
	   END LOOP;
   END IF;
   IF c_get_lab_techparm%ISOPEN THEN
      CLOSE c_get_lab_techparm;
   END IF;

   CLOSE Cur_get_description;

   IF c_get_lab_techparm_global%ISOPEN THEN
     CLOSE c_get_lab_techparm_global;
   END IF;


 X_value := l_value;

EXCEPTION
	WHEN No_Tech_Parm_Found THEN
		ROLLBACK TO SAVEPOINT Get_Tech_Parm_Data;
		  FND_MESSAGE.SET_NAME('GR', 'GR_VALID_TECHPARM');
		  APP_EXCEPTION.RAISE_EXCEPTION;

	WHEN Incompatible_API_version_error THEN
      		ROLLBACK TO SAVEPOINT Get_Tech_Parm_Data;
        	  FND_MESSAGE.SET_NAME('GR', 'GR_API_VERSION_ERROR');
        	  FND_MESSAGE.SET_TOKEN('VERSION', p_api_version,FALSE);
		  APP_EXCEPTION.RAISE_EXCEPTION;

	WHEN OTHERS THEN
		ROLLBACK TO SAVEPOINT Get_Tech_Parm_Data;
		  l_oracle_error := SQLCODE;
		  l_msg_data := SUBSTR(SQLERRM, 1, 200);
		  FND_MESSAGE.SET_NAME('GR', 'GR_UNEXPECTED_ERROR');
        	  FND_MESSAGE.SET_TOKEN('TEXT', l_msg_data, FALSE);
		  APP_EXCEPTION.RAISE_EXCEPTION;

END Get_Tech_Parm_Data;

END GR_TECHNICAL_PARAMETERS;

/
