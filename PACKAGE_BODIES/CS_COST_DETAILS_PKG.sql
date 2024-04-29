--------------------------------------------------------
--  DDL for Package Body CS_COST_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_COST_DETAILS_PKG" AS
/* $Header: csxcstb.pls 120.2 2008/01/18 07:01:10 bkanimoz noship $ */

L_API_NAME_FULL CONSTANT VARCHAR2(255):='CS_COST_DETAILS_PKG';
L_LOG_MODULE CONSTANT VARCHAR2(255):='csxcstb.pls'|| L_API_NAME_FULL ||'.';


/*====================================
Procedure Insert Row
======================================
*/
PROCEDURE Insert_Row
	(

	p_incident_id NUMBER,
	p_estimate_detail_id NUMBER,
	p_transaction_type_id NUMBER,
	p_txn_billing_type_id NUMBER,
	p_inventory_item_id NUMBER,
	p_quantity NUMBER,
	p_unit_cost NUMBER,
	p_extended_cost NUMBER,
	p_override_ext_cost_flag VARCHAR2,
	p_transaction_date DATE,
	p_source_id NUMBER,
	p_source_code VARCHAR2,
	p_unit_of_measure_code VARCHAR2,
	p_currency_code VARCHAR2,
	p_org_id NUMBER,
	p_inventory_org_id NUMBER,
	p_attribute1 VARCHAR2,
	p_attribute2 VARCHAR2,
	p_attribute3 VARCHAR2,
	p_attribute4 VARCHAR2,
	p_attribute5 VARCHAR2,
	p_attribute6 VARCHAR2,
	p_attribute7 VARCHAR2,
	p_attribute8 VARCHAR2,
	p_attribute9 VARCHAR2,
	p_attribute10 VARCHAR2,
	p_attribute11 VARCHAR2,
	p_attribute12 VARCHAR2,
	p_attribute13 VARCHAR2,
	p_attribute14 VARCHAR2,
	p_attribute15 VARCHAR2,
	p_last_update_date DATE,
	p_last_updated_by NUMBER,
	p_last_update_login NUMBER,
	p_created_by NUMBER,
	p_creation_date DATE,
	x_object_version_number OUT NOCOPY NUMBER,
	x_cost_id OUT NOCOPY NUMBER
	) IS

	l_cost_id NUMBER;

BEGIN



	--get the cost_id from the sequence
	SELECT cs_cost_details_s.nextval
	INTO l_cost_id
	FROM DUAL;


	IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level THEN
	FND_LOG.String
	(FND_LOG.level_procedure ,
	L_LOG_MODULE ||'',
	'Before Inserting into the cost table. l_cost_id: '||l_cost_id
	);
	END IF;


	--insert the data into cost table
INSERT
INTO    cs_cost_details
        (
                cost_id ,
                incident_id ,
                estimate_detail_id ,
                transaction_type_id ,
                txn_billing_type_id ,
                inventory_item_id ,
                quantity ,
                unit_cost ,
                extended_cost ,
                override_ext_cost_flag ,
                transaction_date ,
                source_id ,
                source_code ,
                unit_of_measure_code ,
                currency_code ,
                org_id ,
                inventory_org_id ,
                attribute1 ,
                attribute2 ,
                attribute3 ,
                attribute4 ,
                attribute5 ,
                attribute6 ,
                attribute7 ,
                attribute8 ,
                attribute9 ,
                attribute10 ,
                attribute11 ,
                attribute12 ,
                attribute13 ,
                attribute14 ,
                attribute15 ,
                last_update_date ,
                last_updated_by ,
                last_update_login ,
                created_by ,
                creation_date ,
                object_version_number
        )
        VALUES
        (
                l_cost_id ,
                p_incident_id ,
                p_estimate_detail_id ,
                p_transaction_type_id ,
                p_txn_billing_type_id ,
                p_inventory_item_id ,
                p_quantity ,
                p_unit_cost ,
                p_extended_cost ,
                p_override_ext_cost_flag ,
                p_transaction_date ,
                p_source_id ,
                p_source_code ,
                p_unit_of_measure_code ,
                p_currency_code ,
                p_org_id ,
                p_inventory_org_id ,
                p_attribute1 ,
                p_attribute2 ,
                p_attribute3 ,
                p_attribute4 ,
                p_attribute5 ,
                p_attribute6 ,
                p_attribute7 ,
                p_attribute8 ,
                p_attribute9 ,
                p_attribute10 ,
                p_attribute11 ,
                p_attribute12 ,
                p_attribute13 ,
                p_attribute14 ,
                p_attribute15 ,
                p_last_update_date ,
                p_last_updated_by ,
                p_last_update_login ,
                p_created_by ,
                p_creation_date ,
                1
        )
        ;

	--assign the values to the out variables
	X_OBJECT_VERSION_NUMBER :=1;

	x_cost_id := l_Cost_id;

	--commit the work
	COMMIT;


	IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level THEN
	FND_LOG.String
	(FND_LOG.level_procedure ,
	L_LOG_MODULE ||'',
	'After Inserting into the cost table. l_cost_id: '||l_cost_id
	);
	END IF;


END Insert_Row;



/*=========================================
Procedure Update Row
===========================================
*/

PROCEDURE Update_Row
	(

	p_cost_id NUMBER,
	p_incident_id NUMBER,
	p_estimate_detail_id NUMBER,
	p_transaction_type_id NUMBER,
	p_txn_billing_type_id NUMBER,
	p_inventory_item_id NUMBER,
	p_quantity NUMBER,
	p_unit_cost NUMBER,
	p_extended_cost NUMBER,
	p_override_ext_cost_flag VARCHAR2,
	p_transaction_date DATE,
	p_source_id NUMBER,
	p_source_code VARCHAR2,
	p_unit_of_measure_code VARCHAR2,
	p_currency_code VARCHAR2,
	p_org_id NUMBER,
	p_inventory_org_id NUMBER,
	p_attribute1 VARCHAR2,
	p_attribute2 VARCHAR2,
	p_attribute3 VARCHAR2,
	p_attribute4 VARCHAR2,
	p_attribute5 VARCHAR2,
	p_attribute6 VARCHAR2,
	p_attribute7 VARCHAR2,
	p_attribute8 VARCHAR2,
	p_attribute9 VARCHAR2,
	p_attribute10 VARCHAR2,
	p_attribute11 VARCHAR2,
	p_attribute12 VARCHAR2,
	p_attribute13 VARCHAR2,
	p_attribute14 VARCHAR2,
	p_attribute15 VARCHAR2,
	p_last_update_date DATE,
	p_last_updated_by NUMBER,
	p_last_update_login NUMBER,
	p_created_by NUMBER,
	p_creation_date DATE,
	x_object_version_number IN OUT NOCOPY NUMBER

	) IS

	CURSOR C2 IS
	SELECT OBJECT_VERSION_NUMBER
	FROM CS_cost_details
	WHERE cost_id = p_cost_id;

	l_cost_id NUMBER;

	CURSOR get_cost_id IS
	SELECT cost_id
	FROM cs_cost_details
	WHERE estimate_detail_id =p_estimate_detail_id;


BEGIN
	IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level THEN
	FND_LOG.String
	(FND_LOG.level_procedure ,
	L_LOG_MODULE ||'',
	'Before Updating the cost table.p_cost_id: '||p_cost_id
	);
	END IF;

	OPEN C2;
	FETCH C2
	INTO X_OBJECT_VERSION_NUMBER;
	CLOSE C2;

	l_cost_id := p_cost_id;

	IF p_estimate_detail_id IS NOT NULL THEN

	OPEN get_cost_id;
	FETCH get_cost_id
	INTO l_cost_id;
	CLOSE get_cost_id;

	END IF;



	UPDATE cs_cost_details
        SET cost_id = decode(l_cost_id,FND_API.G_MISS_NUM,cost_id,l_cost_id),
        incident_id = decode(p_incident_id,FND_API.G_MISS_NUM,incident_id,p_incident_id),
        estimate_detail_id = decode(p_estimate_detail_id,FND_API.G_MISS_NUM,estimate_detail_id,p_estimate_detail_id),
        transaction_type_id = decode(p_transaction_type_id,FND_API.G_MISS_NUM ,transaction_type_id,p_transaction_type_id),
        txn_billing_type_id = decode(p_txn_billing_type_id,FND_API.G_MISS_NUM ,txn_billing_type_id ,p_txn_billing_type_id),
        inventory_item_id = decode(p_inventory_item_id,FND_API.G_MISS_NUM ,inventory_item_id,p_inventory_item_id),
        quantity = decode(p_quantity,FND_API.G_MISS_NUM,quantity,p_quantity),
        unit_cost = decode(p_unit_cost,FND_API.G_MISS_NUM ,unit_cost,p_unit_cost),
        extended_cost = decode(p_extended_cost ,FND_API.G_MISS_NUM ,extended_cost,p_extended_cost),
        override_ext_cost_flag = decode(p_override_ext_cost_flag,FND_API.G_MISS_CHAR,override_ext_cost_flag,p_override_ext_cost_flag),
        transaction_date = decode(p_transaction_date, FND_API.G_MISS_DATE,transaction_date,p_transaction_date),
        source_id = decode(p_source_id,FND_API.G_MISS_NUM,source_id,p_source_id),
        source_code = decode(p_source_code,FND_API.G_MISS_CHAR,source_code,p_source_code),
        unit_of_measure_code= decode(p_unit_of_measure_code ,FND_API.G_MISS_CHAR,unit_of_measure_code,p_unit_of_measure_code),
        currency_code = decode(p_currency_code,FND_API.G_MISS_CHAR,currency_code,p_currency_code),
        org_id = decode(p_org_id,FND_API.G_MISS_NUM,org_id,p_org_id),
        inventory_org_id = decode(p_inventory_org_id,FND_API.G_MISS_NUM,inventory_org_id,p_inventory_org_id),
        attribute1 = decode(p_attribute1 , FND_API.G_MISS_CHAR ,attribute1,p_attribute1),
        attribute2 = decode(p_attribute2 , FND_API.G_MISS_CHAR ,attribute2,p_attribute2),
        attribute3 = decode(p_attribute3 , FND_API.G_MISS_CHAR ,attribute3,p_attribute3),
        attribute4 = decode(p_attribute4 , FND_API.G_MISS_CHAR ,attribute4,p_attribute4),
        attribute5 = decode(p_attribute5 , FND_API.G_MISS_CHAR ,attribute5,p_attribute5),
        attribute6 = decode(p_attribute6 , FND_API.G_MISS_CHAR ,attribute6,p_attribute6),
        attribute7 = decode(p_attribute7 , FND_API.G_MISS_CHAR ,attribute7,p_attribute7),
        attribute8 = decode(p_attribute8 , FND_API.G_MISS_CHAR ,attribute8,p_attribute8),
        attribute9 = decode(p_attribute9 , FND_API.G_MISS_CHAR ,attribute9,p_attribute9),
        attribute10 = decode(p_attribute10 , FND_API.G_MISS_CHAR ,attribute10,p_attribute10),
        attribute11 = decode(p_attribute11 , FND_API.G_MISS_CHAR ,attribute11,p_attribute11),
        attribute12 = decode(p_attribute12 , FND_API.G_MISS_CHAR ,attribute12,p_attribute12),
        attribute13 = decode(p_attribute13 , FND_API.G_MISS_CHAR ,attribute13,p_attribute13),
        attribute14 = decode(p_attribute14 , FND_API.G_MISS_CHAR ,attribute14,p_attribute14),
        attribute15 = decode(p_attribute15 , FND_API.G_MISS_CHAR ,attribute15,p_attribute15),
        last_update_date = decode(p_last_update_date, FND_API.G_MISS_CHAR ,last_update_date,p_last_update_date),
        last_updated_by = decode(p_last_updated_by , FND_API.G_MISS_CHAR,last_updated_by,p_last_updated_by),
        last_update_login = decode(p_last_update_login, FND_API.G_MISS_CHAR,last_update_login,p_last_update_login),
        --created_by		=	decode(p_created_by	, FND_API.G_MISS_CHAR,created_by,p_created_by),
        --creation_date	=	decode(p_creation_date	 ,   FND_API.G_MISS_DATE  ,creation_date,p_creation_date),
        object_version_number = X_OBJECT_VERSION_NUMBER+1
WHERE   cost_id =l_cost_id;

	IF (SQL%NOTFOUND) THEN
	RAISE NO_DATA_FOUND;
	END IF;

	X_OBJECT_VERSION_NUMBER := X_OBJECT_VERSION_NUMBER+1;

	IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level THEN
	FND_LOG.String
	(FND_LOG.level_procedure ,
	L_LOG_MODULE ||'',
	'After  Updating the cost table. x_object_version_number: '||x_object_version_number
	) ;
	END IF;


END Update_Row;


/*=========================================
Procedure Delete Row
===========================================
*/

PROCEDURE Delete_Row
	(
	p_cost_id NUMBER
	) IS

BEGIN

	IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level THEN
	FND_LOG.String
	(FND_LOG.level_procedure ,
	L_LOG_MODULE ||'',
	'Before  Deleting the cost record . p_cost_id '||p_cost_id
	);
	END IF;

	DELETE FROM cs_cost_details
	WHERE cost_id=p_cost_id;

	IF (SQL%NOTFOUND) THEN
	RAISE NO_DATA_FOUND;
	END IF;

	IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level THEN
	FND_LOG.String
	(FND_LOG.level_procedure ,
	L_LOG_MODULE ||'',
	'After  Deleting the cost record . p_cost_id : '||p_cost_id
	);
	END IF;

END Delete_Row;


END CS_COST_DETAILS_PKG;


/
