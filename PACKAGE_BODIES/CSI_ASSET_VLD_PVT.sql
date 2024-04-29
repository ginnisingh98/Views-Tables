--------------------------------------------------------
--  DDL for Package Body CSI_ASSET_VLD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_ASSET_VLD_PVT" AS
/* $Header: csivavb.pls 115.21 2003/09/04 00:39:31 sguthiva ship $ */

/*-----------------------------------------------------------*/
/* Procedure name: Check_Reqd_Param                          */
/* Description : To Check if the reqd parameter is passed    */
/*-----------------------------------------------------------*/

PROCEDURE Check_Reqd_Param
(
	p_number                IN      NUMBER,
	p_param_name            IN      VARCHAR2,
	p_api_name              IN      VARCHAR2
) IS
BEGIN
	IF (NVL(p_number,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM) THEN
		FND_MESSAGE.SET_NAME('CSI','CSI_API_REQD_PARAM_MISSING');
		FND_MESSAGE.SET_TOKEN('API_NAME',p_api_name);
		FND_MESSAGE.SET_TOKEN('MISSING_PARAM',p_param_name);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
END Check_Reqd_Param;

/*-----------------------------------------------------------*/
/* Procedure name: Check_Reqd_Param                          */
/* Description : To Check if the reqd parameter is passed    */
/*-----------------------------------------------------------*/

PROCEDURE Check_Reqd_Param
(
	p_variable      IN      VARCHAR2,
	p_param_name    IN      VARCHAR2,
	p_api_name      IN      VARCHAR2
) IS
BEGIN
	IF (NVL(p_variable,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR) THEN
	    FND_MESSAGE.SET_NAME('CSI','CSI_API_REQD_PARAM_MISSING');
    	FND_MESSAGE.SET_TOKEN('API_NAME',p_api_name);
		FND_MESSAGE.SET_TOKEN('MISSING_PARAM',p_param_name);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
END Check_Reqd_Param;

/*-----------------------------------------------------------*/
/* Procedure name: Check_Reqd_Param                          */
/* Description : To Check if the reqd parameter is passed    */
/*-----------------------------------------------------------*/

PROCEDURE Check_Reqd_Param
(
	p_date          IN      DATE,
	p_param_name    IN      VARCHAR2,
	p_api_name      IN      VARCHAR2
) IS
BEGIN
	IF (NVL(p_date,FND_API.G_MISS_DATE) = FND_API.G_MISS_DATE) THEN
	    FND_MESSAGE.SET_NAME('CSI','CSI_API_REQD_PARAM_MISSING');
    	FND_MESSAGE.SET_TOKEN('API_NAME',p_api_name);
		FND_MESSAGE.SET_TOKEN('MISSING_PARAM',p_param_name);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
END Check_Reqd_Param;

/*-----------------------------------------------------------*/
/* Procedure name: Is_InstanceID_Valid                       */
/* Description : Check if the Instance Id exists             */
/*-----------------------------------------------------------*/

FUNCTION Is_InstanceID_Valid
(   p_instance_id               IN    NUMBER,
    p_check_for_instance_expiry IN    VARCHAR2,
    p_stack_err_msg             IN    BOOLEAN
 ) RETURN BOOLEAN IS

	l_dummy         VARCHAR2(1);
	l_return_value  BOOLEAN := TRUE;

   CURSOR c1 IS
	SELECT 'x'
	FROM csi_item_instances
	WHERE instance_id = p_instance_id
     and  ((active_end_date is null) OR (active_end_date >= sysdate));

   CURSOR c2 IS
	SELECT 'x'
	FROM csi_item_instances
	WHERE instance_id = p_instance_id;
BEGIN
  IF p_check_for_instance_expiry = fnd_api.g_true THEN
    OPEN c1;
    FETCH c1 INTO l_dummy;
       IF c1%NOTFOUND THEN
          l_return_value  := FALSE;
         IF ( p_stack_err_msg = TRUE ) THEN
           FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_INSTANCE_ID');
           FND_MESSAGE.SET_TOKEN('INSTANCE_ID',p_instance_id);
           FND_MSG_PUB.Add;
         END IF;
       END IF;
    CLOSE c1;
  ELSE
    OPEN c2;
    FETCH c2 INTO l_dummy;
       IF c2%NOTFOUND THEN
          l_return_value  := FALSE;
         IF ( p_stack_err_msg = TRUE ) THEN
           FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_INSTANCE_ID');
           FND_MESSAGE.SET_TOKEN('INSTANCE_ID',p_instance_id);
           FND_MSG_PUB.Add;
         END IF;
       END IF;
    CLOSE c2;
  END IF;

  RETURN l_return_value;

END Is_InstanceID_Valid;


/*-----------------------------------------------------------*/
/* Procedure name:   gen_inst_asset_id                       */
/* Description : Generate instance asset id   from           */
/*                           the sequence                    */
/*-----------------------------------------------------------*/

FUNCTION  gen_inst_asset_id
  RETURN NUMBER IS

  l_inst_asset_id       NUMBER;

BEGIN
 SELECT CSI_I_ASSETS_S.nextval
  INTO  l_inst_asset_id
  FROM sys.dual;

RETURN l_inst_asset_id;

END  gen_inst_asset_id;

/*-----------------------------------------------------------*/
/* Procedure name:  Is_Inst_assetID_exists                   */
/* Description : Check if the instance asset id              */
/*               exists in csi_i_assets                      */
/*-----------------------------------------------------------*/

FUNCTION  Is_Inst_assetID_exists

(	p_instance_asset_id     IN      NUMBER,
	p_stack_err_msg         IN      BOOLEAN
  ) RETURN BOOLEAN IS

	l_dummy         VARCHAR2(1);
	l_return_value  BOOLEAN := TRUE;
BEGIN
   	SELECT 'x'
     INTO l_dummy
     FROM csi_i_assets
	WHERE instance_asset_id = p_instance_asset_id ;

	IF ( p_stack_err_msg = TRUE ) THEN
		   FND_MESSAGE.SET_NAME('CSI','CSI_API_INV_INST_ASSET_ID');
		   FND_MESSAGE.SET_TOKEN('INSTANCE_ASSET_ID',p_instance_asset_id);
		   FND_MSG_PUB.Add;
	END IF;
	RETURN l_return_value;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    l_return_value  := FALSE;
	RETURN l_return_value;
END  Is_Inst_assetID_exists;

/*-----------------------------------------------------------*/
/* Procedure name:  Is_Inst_asset_id_valid                   */
/* Description : Check if the instance asset id              */
/*               exists in csi_i_assets                      */
/*-----------------------------------------------------------*/

FUNCTION  Is_Inst_asset_id_valid

(	p_instance_asset_id     IN      NUMBER,
	p_stack_err_msg         IN      BOOLEAN
  ) RETURN BOOLEAN IS

	l_dummy         VARCHAR2(1);
	l_return_value  BOOLEAN := TRUE;
BEGIN
   	SELECT 'x'
     INTO l_dummy
     FROM csi_i_assets
	WHERE instance_asset_id = p_instance_asset_id ;
	RETURN l_return_value;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    l_return_value  := FALSE;
    IF ( p_stack_err_msg = TRUE ) THEN
		   FND_MESSAGE.SET_NAME('CSI','CSI_API_INV_INST_ASSET_ID');
		   FND_MESSAGE.SET_TOKEN('INSTANCE_ASSET_ID',p_instance_asset_id);
		   FND_MSG_PUB.Add;
	END IF;
	RETURN l_return_value;
END  Is_Inst_asset_id_valid;


/*-----------------------------------------------------------*/
/* Procedure name: Is_Update_Status_Exists                   */
/* Description : Check if the update status  is              */
/*              defined in CSI_LOOKUPS                       */
/*-----------------------------------------------------------*/

FUNCTION Is_Update_Status_Exists
(
    p_update_status         IN      VARCHAR2,
	p_stack_err_msg         IN      BOOLEAN
) RETURN BOOLEAN IS

	l_dummy                 VARCHAR2(1);
	l_return_value          BOOLEAN := TRUE;
        l_asset_lookup_type     VARCHAR2(30) := 'CSI_ASSET_UPDATE_STATUS_CODE';

	CURSOR c1 IS
	SELECT 'x'
	FROM CSI_LOOKUPS
	WHERE  UPPER(lookup_code) = UPPER(p_update_status)
        AND  lookup_type      = l_asset_lookup_type;
BEGIN
	OPEN c1;
	FETCH c1 INTO l_dummy;
	IF c1%NOTFOUND THEN
		l_return_value  := FALSE;
		IF ( p_stack_err_msg = TRUE ) THEN
		   FND_MESSAGE.SET_NAME('CSI','CSI_API_INV_UPDATE_STATUS');
		   FND_MESSAGE.SET_TOKEN('UPDATE_STATUS',p_update_status);
		   FND_MSG_PUB.Add;
		END IF;
	END IF;
	CLOSE c1;
	RETURN l_return_value;

END Is_Update_Status_Exists;

/*-----------------------------------------------------------*/
/* Procedure name: Is_Quantity_Valid                         */
/* Description : Check if the asset quantity > 0             */
/*-----------------------------------------------------------*/

FUNCTION Is_Quantity_Valid
(
    p_asset_quantity        IN      NUMBER,
	p_stack_err_msg         IN      BOOLEAN
  ) RETURN BOOLEAN IS

   l_return_status    BOOLEAN := TRUE;
BEGIN
	IF (NVL(p_asset_quantity,-1) <= 0 ) THEN
        l_return_status := FALSE;
      	FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_ASSET_QTY');
		FND_MESSAGE.SET_TOKEN('QUANTITY',p_asset_quantity);
		FND_MSG_PUB.Add;
	END IF;

 RETURN l_return_status;

END Is_Quantity_Valid;


/*-----------------------------------------------------------*/
/* Procedure name:   gen_inst_asset_hist_id                  */
/* Description : Generate instance asset id   from           */
/*                           the sequence                    */
/*-----------------------------------------------------------*/

FUNCTION  gen_inst_asset_hist_id
  RETURN NUMBER IS

 l_inst_asset_hist_id       NUMBER;

BEGIN
  SELECT CSI_I_ASSETS_H_S.nextval
  INTO  l_inst_asset_hist_id
  FROM sys.dual;
 RETURN l_inst_asset_hist_id;
END gen_inst_asset_hist_id;

/*-----------------------------------------------------------*/
/* Procedure name:  Is_Asset_Comb_Valid                      */
/* Description : Check if the instance asset id and location */
/*               id exists in fa_books                       */
/*-----------------------------------------------------------*/

FUNCTION  Is_Asset_Comb_Valid
(	p_asset_id        IN      NUMBER,
    p_book_type_code  IN      VARCHAR2,
    p_stack_err_msg   IN      BOOLEAN
  ) RETURN BOOLEAN IS
	l_dummy         VARCHAR2(1);
	l_return_value  BOOLEAN := TRUE;

CURSOR C1 IS
 SELECT 'x'
  FROM fa_books
 WHERE asset_id       = p_asset_id
  and  book_type_code = p_book_type_code
  and  rownum = 1 ;

BEGIN
	OPEN C1;
	FETCH C1 INTO l_dummy;
	IF C1%NOTFOUND THEN
        l_return_value  := FALSE;
        IF ( p_stack_err_msg = TRUE ) THEN
		   FND_MESSAGE.SET_NAME('CSI','CSI_API_INV_ASSET_COMB');
		   FND_MESSAGE.SET_TOKEN('ASSET_COMBINATION',p_asset_id||'-'||p_book_type_code);
		   FND_MSG_PUB.Add;
	    END IF;
     END IF;
    CLOSE C1;
 RETURN l_return_value;
END Is_Asset_Comb_Valid;


/*-----------------------------------------------------------*/
/* Procedure name:  Is_Asset_Location_Valid                  */
/* Description : Check if the instance location id           */
/*                exists in csi_a_locations                  */
/*-----------------------------------------------------------*/

FUNCTION  Is_Asset_Location_Valid
(   p_location_id     IN      NUMBER,
    p_stack_err_msg   IN      BOOLEAN
   ) RETURN BOOLEAN IS
	l_dummy         VARCHAR2(1);
	l_return_value  BOOLEAN := TRUE;
BEGIN
   	SELECT 'x'
     INTO l_dummy
     FROM csi_a_locations
	WHERE fa_location_id   = p_location_id
      and  ((active_end_date is null) OR (active_end_date >= sysdate))
      and  ROWNUM = 1;

	RETURN l_return_value;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    l_return_value  := FALSE;
    IF ( p_stack_err_msg = TRUE ) THEN
		   FND_MESSAGE.SET_NAME('CSI','CSI_API_INV_ASSET_LOCATION');
		   FND_MESSAGE.SET_TOKEN('ASSET_LOCATION_ID',p_location_id);
		   FND_MSG_PUB.Add;
	END IF;
 RETURN l_return_value;
END Is_Asset_Location_Valid;

/*-----------------------------------------------------------*/
/* Procedure name: Is_StartDate_Valid                        */
/* Description : Check if instance assets active start       */
/*    date is valid                                          */
/*-----------------------------------------------------------*/

FUNCTION Is_StartDate_Valid
(   p_start_date                IN   DATE,
    p_end_date                  IN   DATE,
    p_instance_id               IN   NUMBER,
    p_check_for_instance_expiry IN   VARCHAR2, -- Added for cse on 14-feb-03
    p_stack_err_msg             IN   BOOLEAN
) RETURN BOOLEAN IS

	l_instance_start_date         DATE;
	l_instance_end_date           DATE;
	l_return_value                BOOLEAN := TRUE;

    CURSOR c1 IS
	SELECT active_start_date,
           active_end_date
	FROM   csi_item_instances
	WHERE  instance_id = p_instance_id
      AND  ((active_end_date IS NULL) OR (active_end_date >= SYSDATE));
BEGIN
   IF ((p_end_date IS NOT NULL) AND (p_end_date <> FND_API.G_MISS_DATE))THEN
      IF p_start_date > p_end_date THEN
           l_return_value  := FALSE;
     	   FND_MESSAGE.SET_NAME('CSI','CSI_API_INVAL_AST_START_DATE');
	       FND_MESSAGE.SET_TOKEN('START_DATE',p_start_date);
	       FND_MSG_PUB.Add;
           RETURN l_return_value;
      END IF;
   END IF;

    OPEN c1;
    FETCH c1 INTO l_instance_start_date,l_instance_end_date;
     IF p_check_for_instance_expiry = fnd_api.g_true  -- Added for cse on 14-feb-03
     THEN
       IF c1%NOTFOUND THEN
          l_return_value  := FALSE;
         IF ( p_stack_err_msg = TRUE ) THEN
           FND_MESSAGE.SET_NAME('CSI','CSI_API_INVAL_INST_START_DATE');
           FND_MESSAGE.SET_TOKEN('ENTITY','ASSET');
           FND_MSG_PUB.Add;
         END IF;
        RETURN l_return_value;
       END IF;
     END IF;
    CLOSE c1;

    IF (p_start_date < l_instance_start_date) AND (l_instance_start_date IS NOT NULL)  THEN
            l_return_value  := FALSE;
            IF ( p_stack_err_msg = TRUE ) THEN
              FND_MESSAGE.SET_NAME('CSI','CSI_API_INVAL_AST_START_DATE');
              FND_MESSAGE.SET_TOKEN('START_DATE',p_start_date);
	          FND_MSG_PUB.Add;
	        END IF;
    END IF;

    IF  ((l_instance_end_date IS NOT NULL) AND (p_start_date > l_instance_end_date)) THEN
      IF p_check_for_instance_expiry = fnd_api.g_true  -- Added for cse on 14-feb-03
      THEN
            l_return_value  := FALSE;
            IF ( p_stack_err_msg = TRUE ) THEN
              FND_MESSAGE.SET_NAME('CSI','CSI_API_INVAL_AST_START_DATE');
              FND_MESSAGE.SET_TOKEN('START_DATE',p_start_date);
	          FND_MSG_PUB.Add;
            END IF;
      END IF;
    END IF;
  RETURN l_return_value;
END Is_StartDate_Valid;

/*----------------------------------------------------------*/
/* Function Name :  Is_EndDate_Valid                        */
/*                                                          */
/* Description  :  This function checks if end date         */
/*                 is valid                                 */
/*----------------------------------------------------------*/

FUNCTION Is_EndDate_Valid
(
    p_start_date                IN   DATE,
    p_end_date                  IN   DATE,
    p_instance_id               IN   NUMBER,
    p_inst_asset_id             IN   NUMBER,
    p_txn_id                    IN   NUMBER,
    p_check_for_instance_expiry IN   VARCHAR2, -- Added for cse on 14-feb-03
    p_stack_err_msg             IN   BOOLEAN
) RETURN BOOLEAN IS

    l_return_value  BOOLEAN := TRUE;
    l_transaction_date   date;

    CURSOR c1 IS
       SELECT active_start_date,
              active_end_date
       FROM   csi_item_instances
       WHERE  instance_id = p_instance_id;

       l_date_rec   c1%ROWTYPE;

BEGIN

     IF  ((p_inst_asset_id IS NULL) OR  (p_inst_asset_id = FND_API.G_MISS_NUM)) THEN
         IF ((p_end_date IS NOT NULL) AND (p_end_date <> FND_API.G_MISS_DATE)) THEN

            IF p_end_date < SYSDATE THEN
               l_return_value  := FALSE;
               FND_MESSAGE.SET_NAME('CSI','CSI_API_INVAL_AST_END_DATE');
	           FND_MESSAGE.SET_TOKEN('END_DATE',p_end_date);
	           FND_MSG_PUB.Add;
               l_return_value := FALSE;
               RETURN l_return_value;
            END IF;
          END IF;
           RETURN l_return_value;
     ELSE
          IF p_end_date < SYSDATE THEN
             SELECT MAX(t.transaction_date)
             INTO   l_transaction_date
             FROM   csi_i_assets_h s,
                    csi_transactions t
             WHERE  s.instance_asset_id=p_inst_asset_id
             AND    s.transaction_id=t.transaction_id
	         AND    t.transaction_id <> nvl(p_txn_id, -999999);

             IF l_transaction_date > p_end_date
             THEN
                fnd_message.set_name('CSI','CSI_HAS_TXNS');
                fnd_message.set_token('END_DATE_ACTIVE',p_end_date);
                fnd_msg_pub.add;
                l_return_value := FALSE;
                RETURN l_return_value;
             END IF;
          END IF;
          IF ((p_end_date IS NOT NULL) AND (p_end_date <> FND_API.G_MISS_DATE)) then
           OPEN c1;
            FETCH c1 INTO l_date_rec;

             IF (p_end_date > NVL(l_date_rec.active_end_date, p_end_date))
             THEN
               IF p_check_for_instance_expiry = fnd_api.g_true  -- Added for cse on 14-feb-03
               THEN
                 l_return_value  := FALSE;
                 IF ( p_stack_err_msg = TRUE ) THEN
                      FND_MESSAGE.SET_NAME('CSI','CSI_API_INVAL_AST_END_DATE');
                      FND_MESSAGE.SET_TOKEN('END_DATE',p_end_date);
                      FND_MSG_PUB.Add;
                 END IF;
                 RETURN l_return_value;
               END IF;
             END IF;

             IF (p_end_date < NVL(l_date_rec.active_start_date,p_end_date))
             THEN
                 l_return_value  := FALSE;
                 IF ( p_stack_err_msg = TRUE ) THEN
                      FND_MESSAGE.SET_NAME('CSI','CSI_API_INVAL_AST_END_DATE');
                      FND_MESSAGE.SET_TOKEN('END_DATE',p_end_date);
                      FND_MSG_PUB.Add;
                 END IF;
                 RETURN l_return_value;
             END IF;
          CLOSE c1;
         END IF;
     END IF;
    RETURN l_return_value;
END Is_EndDate_Valid;

END CSI_Asset_vld_pvt ;


/
