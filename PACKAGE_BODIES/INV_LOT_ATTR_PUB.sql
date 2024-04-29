--------------------------------------------------------
--  DDL for Package Body INV_LOT_ATTR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_LOT_ATTR_PUB" AS
/* $Header: INVVLOTB.pls 120.0 2005/05/25 06:48:51 appldev noship $ */

  -----------------------------------------------------------------------
   -- Name : validate_grade_code
   -- Desc :
   --          Generic routine to validates a grade code , item
   --          must be grade controlled and grade must exist in
   --          mtl_grades table
   --          This function assumes that validation for itemid and orgin
   --          have already taken place
   -- I/P params :
   --      p_grade_code, p_org_id and p_inventory_item_id  (Mandatory)
   --      p_grade_control_flag  (optional, Derived if not given )
   -----------------------------------------------------------------------

FUNCTION validate_grade_code(
  p_grade_code  				IN		VARCHAR
, p_org_id                      IN      NUMBER
, p_inventory_item_id           IN      NUMBER
, p_grade_control_flag          IN      VARCHAR2
, x_return_status 			    OUT NOCOPY VARCHAR2
, x_msg_count 				    OUT NOCOPY NUMBER
, x_msg_data 				    OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS
l_grade_code VARCHAR2(150);
l_grade_control_flag VARCHAR2(1);

CURSOR c_get_grade_code IS
SELECT  grade_code
FROM  mtl_grades
WHERE  Grade_code = p_grade_code;

CURSOR c_get_grade_flag IS
SELECT  grade_control_flag
FROM  mtl_system_items
WHERE inventory_item_id = p_inventory_item_id
AND  organization_id   = p_org_id;


BEGIN
x_return_status := fnd_api.g_ret_sts_success;
    l_grade_control_flag := p_grade_control_flag;
    /* get grade controlled flag */
    IF p_grade_control_flag IS NULL
    THEN
    	OPEN c_get_grade_flag;
    	FETCH c_get_grade_flag INTO l_grade_control_flag;
    	close c_get_grade_flag;
    END IF;

    IF l_grade_control_flag = 'Y'  AND p_grade_code IS NULL
	THEN
       	  fnd_message.set_name('INV', 'INV_MISSING_GRADE');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
    	  RETURN FALSE;
    END IF;
	/* Do validation only if item is grade controlled */
    IF l_grade_control_flag = 'Y'
    THEN
		OPEN c_get_grade_code;
		FETCH c_get_grade_code INTO l_grade_code;

		IF c_get_grade_code%NOTFOUND THEN
		 CLOSE c_get_grade_code;
       	  fnd_message.set_name('INV', 'INV_INVALID_GRADE_CODE_EXP');
          fnd_message.set_token('GRADE_CODE', p_grade_code);
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
    	  RETURN FALSE;
		END IF;
		CLOSE c_get_grade_code;
	END IF;

RETURN TRUE;
 EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status  := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
	                            p_count => x_msg_count,
								p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      RETURN FALSE;

    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
	                            p_count => x_msg_count,
								p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
     RETURN FALSE;
END validate_grade_code;


  -----------------------------------------------------------------------
   -- Name : validate_maturity_date
   -- Desc :
   --          Generic routine to validates maturity date.
   --             Maturity Date must be greater than the Origination Date
   --
   --          This function assumes that validation for origination date
   --          have already taken place
   -- I/P params :
   --      p_maturity_date, p_origination_date (Mandatory)

   --   Modified the procedure to replace condition '<=' to  '<'
   --   in order to allow these dates to be eqaual to origination date.

   -----------------------------------------------------------------------

FUNCTION validate_maturity_date(
  p_maturity_date				IN		DATE
, p_origination_date            IN      DATE
, x_return_status 			    OUT NOCOPY VARCHAR2
, x_msg_count 				    OUT NOCOPY NUMBER
, x_msg_data 				    OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS
BEGIN
x_return_status := fnd_api.g_ret_sts_success;
   IF (p_maturity_date IS NOT NULL AND p_origination_date IS NOT NULL)
   THEN
       IF (p_maturity_date < p_origination_date) THEN
         fnd_message.set_name ('INV','INV_LOT_MATURITY_DATE_INVALID');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
         RETURN TRUE;
       END IF;
   END IF;
RETURN TRUE;
 EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
	                            p_count => x_msg_count,
								p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
     RETURN FALSE;
END validate_maturity_date;


  -----------------------------------------------------------------------
   -- Name : validate_hold_date
   -- Desc :
   --          Generic routine to validates maturity date.
   --             Maturity Date must be greater than the Origination Date
   --
   --          This function assumes that validation for origination date
   --          have already taken place
   -- I/P params :
   --      p_maturity_date, p_origination_date (Mandatory)

      --   Modified the procedure to replace condition '<=' to  '<'
   --   in order to allow these dates to be eqaual to origination date.

   -----------------------------------------------------------------------

FUNCTION validate_hold_date(
  p_hold_date					IN		DATE
, p_origination_date            IN      DATE
, x_return_status 			    OUT NOCOPY VARCHAR2
, x_msg_count 				    OUT NOCOPY NUMBER
, x_msg_data 				    OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS
BEGIN
x_return_status := fnd_api.g_ret_sts_success;
   IF (p_hold_date IS NOT NULL AND p_origination_date IS NOT NULL)
   THEN
       IF (p_hold_date <  p_origination_date) THEN
         fnd_message.set_name ('INV','INV_LOT_HOLD_DATE_INVALID');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
         RETURN TRUE;
       END IF;
   END IF;
RETURN TRUE;
 EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
	                            p_count => x_msg_count,
								p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
     RETURN FALSE;
END validate_hold_date;

  -----------------------------------------------------------------------
   -- Name : validate_expiration_action_date
   -- Desc :
   --          Generic routine to validate expiration_action_date
   --
   --
   --          This function assumes that validation for expiration date
   --          have already taken place
   -- I/P params :
   --      p_expiration_action_date,  p_expiration_date (Mandatory)
   -----------------------------------------------------------------------
FUNCTION validate_exp_action_date(
  p_expiration_action_date		IN		DATE
, p_expiration_date             IN      DATE
, x_return_status 			    OUT NOCOPY VARCHAR2
, x_msg_count 				    OUT NOCOPY NUMBER
, x_msg_data 				    OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS
BEGIN
x_return_status := fnd_api.g_ret_sts_success;
    IF (p_expiration_action_date IS NOT NULL) THEN
      IF (p_expiration_date IS NOT NULL) THEN
	  -- fabdi bug 4168662, removed validations
/*
        IF (p_expiration_action_date <= p_expiration_date) THEN
          fnd_message.set_name ('INV','INV_LOT_EXP_ACT_DATE_INVALID');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
          RETURN FALSE;
        END IF;

*/
      RETURN TRUE;
      ELSE
        fnd_message.set_name ('INV', 'INV_LOT_EXPIRE_DATE_REQ_EXP');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
        RETURN FALSE;
      END IF;
    END IF;
RETURN TRUE;
 EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
	                            p_count => x_msg_count,
								p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
     RETURN FALSE;
END validate_exp_action_date;

-----------------------------------------------------------------------
   -- Name : validate_retest_date
   -- Desc :
   --          Generic routine to validates retest date.
   --             Retest Date must be greater than the Origination Date
   --
   --          This function assumes that validation for origination date
   --          have already taken place
   -- I/P params :
   --      p_maturity_date, p_origination_date (Mandatory)

   --   Modified the procedure to replace condition '<=' to  '<'
   --   in order to allow these dates to be eqaual to origination date.
   -----------------------------------------------------------------------

FUNCTION validate_retest_date(
  p_retest_date  				IN		DATE
, p_origination_date            IN      DATE
, x_return_status 			    OUT NOCOPY VARCHAR2
, x_msg_count 				    OUT NOCOPY NUMBER
, x_msg_data 				    OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS
BEGIN
x_return_status := fnd_api.g_ret_sts_success;
   IF (p_retest_date IS NOT NULL AND p_origination_date IS NOT NULL)
   THEN
       IF (p_retest_date < p_origination_date) THEN
         fnd_message.set_name ('INV','INV_LOT_RETEST_DATE_INVALID');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
         RETURN TRUE;
       END IF;
   END IF;
RETURN TRUE;
 EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
	                            p_count => x_msg_count,
								p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
     RETURN FALSE;
END validate_retest_date;

 -----------------------------------------------------------------------
   -- Name : validate_exp_action_code
   -- Desc :
   --          Generic routine to validates Expiration Action Code , item
   --          must be shlef life controlled, and Action Code must exist in
   --          mtl_actions table
   -- I/P params :
   --      p_expiration_action_code , item ID and Org ID (Mandatory)
   --      p_shelf_life_code  (optional..)
   -----------------------------------------------------------------------
FUNCTION validate_exp_action_code(
  p_expiration_action_code  				IN		VARCHAR
, p_org_id                      			IN      NUMBER
, p_inventory_item_id           			IN      NUMBER
, p_shelf_life_code          				IN      VARCHAR2
, x_return_status 			    OUT NOCOPY VARCHAR2
, x_msg_count 				    OUT NOCOPY NUMBER
, x_msg_data 				    OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS
l_expiration_action_code VARCHAR2(32);
l_shelf_life_code  NUMBER;

/* get expiration action code */
CURSOR  c_get_exp_action_code IS
   SELECT  action_code
   FROM  mtl_actions
   WHERE  action_code = p_expiration_action_code
   AND  NVL(disable_flag,'N') = 'N';

/* get shelf life code */
CURSOR c_get_shelf_life_code IS
SELECT  shelf_life_code
FROM  mtl_system_items
WHERE inventory_item_id = p_inventory_item_id
AND  organization_id   = p_org_id;


BEGIN
x_return_status := fnd_api.g_ret_sts_success;
    l_shelf_life_code := p_shelf_life_code;
    /* get shelf life code flag */
    IF p_shelf_life_code IS NULL
    THEN
    	OPEN c_get_shelf_life_code;
    	FETCH c_get_shelf_life_code INTO l_shelf_life_code;
    	close c_get_shelf_life_code;
    END IF;

	/* Do validation only if item is shelf life ctl*/
    IF ((l_shelf_life_code <> 1) AND (p_expiration_action_code IS NOT NULL))
    THEN
		OPEN c_get_exp_action_code;
		FETCH c_get_exp_action_code INTO l_expiration_action_code;

		IF c_get_exp_action_code%NOTFOUND THEN
		 CLOSE c_get_exp_action_code;
       	  fnd_message.set_name('INV', 'INV_EXP_ACTION_CD_EXP');
          fnd_message.set_token('EXP_ACTION_CD', p_expiration_action_code);
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
    	  RETURN FALSE;
		END IF;
		CLOSE c_get_exp_action_code;
	END IF;

RETURN TRUE;
 EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status  := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
	                            p_count => x_msg_count,
								p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      RETURN FALSE;

    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
	                            p_count => x_msg_count,
								p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
     RETURN FALSE;
END validate_exp_action_code;

 -----------------------------------------------------------------------
   -- Name : validate_reason_code
   -- Desc :
   --          Generic routine to validate reason code/ reason id
   --             Must exist in MTL_TRANSACTION_REASONS
   --
   -- I/P params :
   --      p_reason_code OR  p_resson_id  (Mandatory)
   -----------------------------------------------------------------------
FUNCTION validate_reason_code(
  p_reason_code  							IN		VARCHAR2
, p_reason_id		               			IN      NUMBER
, x_return_status 			    OUT NOCOPY VARCHAR2
, x_msg_count 				    OUT NOCOPY NUMBER
, x_msg_data 				    OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS
l_reason_code VARCHAR2(32);
l_reason_id  NUMBER;

   /* Get reason code info */
   CURSOR c_get_reason_id  IS
    SELECT MTR.REASON_ID
    FROM MTL_TRANSACTION_REASONS MTR
    WHERE MTR.REASON_ID = p_reason_id
    AND NVL(MTR.DISABLE_DATE, SYSDATE + 1) > SYSDATE;

      /* Get reason code info */
   CURSOR c_get_reason_code  IS
    SELECT MTR.REASON_ID
    FROM MTL_TRANSACTION_REASONS MTR
    WHERE MTR.REASON_NAME = p_reason_code
    AND NVL(MTR.DISABLE_DATE, SYSDATE + 1) > SYSDATE;

BEGIN
x_return_status := fnd_api.g_ret_sts_success;
    l_reason_code := p_reason_code;
    l_reason_id := p_reason_id;

    IF p_reason_code IS NOT NULL
    THEN
        OPEN c_get_reason_code;
		FETCH c_get_reason_code INTO l_reason_code;
		IF c_get_reason_code%NOTFOUND THEN
		 CLOSE c_get_reason_code;
       	  fnd_message.set_name('INV', 'INV_INT_REAEXP');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
    	  RETURN FALSE;
		END IF;
		CLOSE c_get_reason_code;
	Else

     IF p_reason_id IS NOT NULL
     THEN
        OPEN c_get_reason_id;
		FETCH c_get_reason_id INTO l_reason_code;
		IF c_get_reason_id%NOTFOUND THEN
		 CLOSE c_get_reason_id;
       	  fnd_message.set_name('INV', 'INV_INT_REAEXP');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
    	  RETURN FALSE;
		END IF;
		CLOSE c_get_reason_id;
     END IF;
	END IF;

RETURN TRUE;
 EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status  := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
	                            p_count => x_msg_count,
								p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      RETURN FALSE;

    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
	                            p_count => x_msg_count,
								p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
     RETURN FALSE;
END validate_reason_code;

 -----------------------------------------------------------------------
   -- Name : validate_origination_type
   -- Desc :
   --          Generic routine to validate origination type
   --             Must exist in mfg_lookups (lookup_type = 'ORIGINATION_TYPE')
   --
   -- I/P params :
   --      p_origination_id  (Mandatory)
   -----------------------------------------------------------------------
FUNCTION validate_origination_type(
  p_origination_type 			IN		NUMBER
, x_return_status 			    OUT NOCOPY VARCHAR2
, x_msg_count 				    OUT NOCOPY NUMBER
, x_msg_data 				    OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS
l_origination_type  NUMBER;

 /* Origination Type validation logic */
   CURSOR  c_get_origination_type IS
   SELECT  lookup_code
     FROM  mfg_lookups
    WHERE  lookup_type = 'MTL_LOT_ORIGINATION_TYPE'
      AND  lookup_code = p_origination_type;

BEGIN
x_return_status := fnd_api.g_ret_sts_success;
    IF p_origination_type IS NOT NULL
    THEN
     OPEN c_get_origination_type;
     FETCH c_get_origination_type into l_origination_type;
     IF c_get_origination_type%NOTFOUND THEN
      CLOSE c_get_origination_type;
      fnd_message.set_name('INV', 'INV_ORIGINATION_TYPE_EXP');
      fnd_message.set_token('ORIGINATION_TYPE', p_origination_type);
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
      RETURN FALSE;
     END IF;
     CLOSE c_get_origination_type;
    END IF;

RETURN TRUE;
 EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status  := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
	                            p_count => x_msg_count,
								p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      RETURN FALSE;

    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
	                            p_count => x_msg_count,
								p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
     RETURN FALSE;
END validate_origination_type;
 -----------------------------------------------------------------------
   -- Name : validate_child_lot
   -- Desc :
   --          Generic routine to validate lot number
   --          Validation conditions
   --            # child lot is new
   --            # Item must be child lot enable
   --            # Validate naming conventions if child Lot has an associated parent lot
   --            # relations ship between parent/child lot is valid
   --
   -- I/P params :
   --      p_parent_lot_number, p_lot_number , itemid, orgid (Mandatory)
   --      p_child_lot_flag (optional)
   -----------------------------------------------------------------------

FUNCTION validate_child_lot (
  p_parent_lot_number			IN		   VARCHAR2
, p_lot_number					IN		   VARCHAR2
, p_org_id                      IN      NUMBER
, p_inventory_item_id           IN      NUMBER
, p_child_lot_flag              IN      VARCHAR2
, x_return_status 			    OUT NOCOPY VARCHAR2
, x_msg_count 				    OUT NOCOPY NUMBER
, x_msg_data 				    OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS
l_parent_lot_number  VARCHAR2(80);
l_lot_number  VARCHAR2(80);
l_child_lot_flag VARCHAR2(1);

  /* Get Lot record  */
   CURSOR  c_get_lot_record IS
   SELECT  *
     FROM  mtl_lot_numbers
    WHERE  lot_number        = p_lot_number
      AND  inventory_item_id = p_inventory_item_id
      AND  organization_id   = p_org_id;

 /* get child lot enabled flag */
   CURSOR c_child_lot_flag IS
    SELECT  p_child_lot_flag
    FROM  mtl_system_items
	WHERE inventory_item_id = p_inventory_item_id
	AND  organization_id   = p_org_id;

    l_api_version          NUMBER;
    l_init_msg_list        VARCHAR2(100);
    l_commit               VARCHAR2(100);

    l_return_status        VARCHAR2(1);
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(3000);

	l_lot_record    c_get_lot_record%ROWTYPE;
BEGIN
x_return_status := fnd_api.g_ret_sts_success;
    l_api_version              := 1.0;
    l_init_msg_list            := fnd_api.g_false;
    l_commit                   := fnd_api.g_false;

   IF l_child_lot_flag IS NULL
   THEN
    OPEN c_child_lot_flag;
    FETCH c_child_lot_flag into l_child_lot_flag;
    CLOSE c_child_lot_flag;
   END IF;

   IF (l_child_lot_flag = 'Y' and p_parent_lot_number IS NOT NULL)
   THEN
    OPEN c_get_lot_record;
    FETCH c_get_lot_record INTO l_lot_record;
    IF c_get_lot_record%NOTFOUND THEN
    CLOSE c_get_lot_record;
      INV_LOT_API_PUB.validate_child_lot (
             x_return_status          =>    l_return_status
           , x_msg_count              =>    l_msg_count
           , x_msg_data               =>    l_msg_data
           , p_api_version            =>    l_api_version
           , p_init_msg_list          =>    l_init_msg_list
           , p_commit                 =>    l_commit
           , p_organization_id        =>    p_org_id
           , p_inventory_item_id      =>    p_inventory_item_id
           , p_parent_lot_number      =>    p_parent_lot_number
           , p_child_lot_number       =>    p_lot_number
          )  ;
      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
              FND_MESSAGE.SET_TOKEN('PGM_NAME','INV_CHILD_LOT_GRP.VALIDATE_CHILD_LOT');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_unexpected_error;
              RETURN FALSE;
      END IF;
      IF l_return_status = fnd_api.g_ret_sts_error THEN
             fnd_message.set_name('INV', 'INV_INVALID_CHILD_LOT_EXP') ;
             fnd_msg_pub.ADD;
             RAISE fnd_api.g_exc_error;
             RETURN FALSE;
      END IF;
	 ELSE
	  /* existing lot */
	  CLOSE c_get_lot_record;
      /* Check Parent Lot is correct */
      IF l_lot_record.parent_lot_number IS NOT NULL THEN
         IF l_lot_record.parent_lot_number <> p_parent_lot_number THEN
            fnd_message.set_name('INV', 'INV_INVALID_PARENT_LOT_EXP') ;
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
            RETURN FALSE;
         END IF;
      END IF;

	 END IF; -- end cursor check
   END IF; -- main if


RETURN TRUE;
 EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status  := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
	                            p_count => x_msg_count,
								p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      RETURN FALSE;

    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
	                            p_count => x_msg_count,
								p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
     RETURN FALSE;
END validate_child_lot;

PROCEDURE create_lot_uom_conv_wrapper
( p_commit                IN              VARCHAR2
, p_action_type           IN              VARCHAR2
, p_reason_id             IN              NUMBER
, p_lot_number      	  IN              VARCHAR2
, p_organization_id       IN              NUMBER
, p_inventory_item_id     IN              NUMBER
, p_from_unit_of_measure  IN              VARCHAR2
, p_from_uom_code         IN              VARCHAR2
, p_from_uom_class        IN              VARCHAR2
, p_to_unit_of_measure    IN              VARCHAR2
, p_to_uom_code           IN              VARCHAR2
, p_to_uom_class          IN              VARCHAR2
, p_conversion_rate       IN              NUMBER
, p_disable_date          IN              DATE
, p_event_spec_disp_id    IN              NUMBER
, p_created_by            IN              NUMBER
, p_creation_date         IN              DATE
, p_last_updated_by       IN              NUMBER
, p_last_update_date      IN              DATE
, p_last_update_login     IN              NUMBER
, p_request_id            IN              NUMBER
, p_program_application_id IN             NUMBER
, p_program_id            IN              NUMBER
, p_program_update_date   IN              DATE
, x_return_status         OUT NOCOPY      VARCHAR2
, x_msg_count             OUT NOCOPY      NUMBER
, x_msg_data              OUT NOCOPY      VARCHAR2
 ) IS

l_return_status        VARCHAR2(2);
l_msg_count            NUMBER;
l_msg_data             VARCHAR2(2000);

l_qty_tbl              MTL_LOT_UOM_CONV_PUB.quantity_update_rec_type;
l_conv_rec             MTL_LOT_UOM_CLASS_CONVERSIONS%ROWTYPE;
l_action_type          VARCHAR2(1);
l_rtn    			   NUMBER;
l_sequence				NUMBER := 1;
BEGIN

  /*  Call Business rule level validation */
  l_rtn := MTL_LOT_UOM_CONV_PVT.validate_lot_conversion_rules
   ( p_organization_id 		=> p_organization_id
   , p_inventory_item_id 	=> p_inventory_item_id
   , p_lot_number 			=> p_lot_number
   , p_from_uom_code  		=> p_from_uom_code
   , p_to_uom_code  		=> p_to_uom_code
   , p_quantity_updates 	=> 'F'
   , p_update_type 			=> p_action_type
   );

   IF ( l_rtn  = 0) THEN
      -- dbms_output.put_line('Error: validate_lot_conversion_rules ' || l_msg_data);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --dbms_output.put_line('Ok: validate_lot_conversion_rules ');

  l_conv_rec.lot_number 			:= p_lot_number;
  l_conv_rec.organization_id 		:= p_organization_id ;
  l_conv_rec.inventory_item_id 		:= p_inventory_item_id;
  -- FROM
  l_conv_rec.from_unit_of_measure 	:= p_from_unit_of_measure;
  l_conv_rec.from_uom_code 			:= p_from_uom_code;
  l_conv_rec.from_uom_class 		:= p_from_uom_class;

  -- TO
  l_conv_rec.to_unit_of_measure 	:= p_to_unit_of_measure;
  l_conv_rec.to_uom_code 			:= p_to_uom_code;
  l_conv_rec.to_uom_class 			:= p_to_uom_class;
  l_conv_rec.conversion_rate 		:= p_conversion_rate;

  l_conv_rec.disable_date 			:= p_disable_date;
  l_conv_rec.event_spec_disp_id 	:= p_event_spec_disp_id ;
  l_conv_rec.created_by 			:= p_created_by ;
  l_conv_rec.creation_date 			:= p_creation_date;

  l_conv_rec.last_updated_by 		:= p_last_updated_by ;
  l_conv_rec.last_update_date 		:= p_last_update_date;

  l_conv_rec.last_update_login 		:= p_last_update_login;
  l_conv_rec.request_id 			:= p_request_id;
  l_conv_rec.program_application_id := p_program_application_id ;
  l_conv_rec.program_id 			:= p_program_id;
  l_conv_rec.program_update_date 	:= p_program_update_date;

  l_action_type := p_action_type;-- 'I'

 /*===================================
     Insert/update conversion record.
   ==================================*/


  MTL_LOT_UOM_CONV_PUB.create_lot_uom_conversion
  ( p_api_version           => 1.0
  , p_init_msg_list         => FND_API.G_TRUE
  , p_commit                => FND_API.G_FALSE
  , p_validation_level      => FND_API.G_VALID_LEVEL_NONE
  , p_action_type           => l_action_type
  , p_update_type_indicator => '5'
  , p_reason_id             => NULL
  , p_batch_id              => NULL
  , p_process_data          => FND_API.G_TRUE
  , p_lot_uom_conv_rec      => l_conv_rec
  , p_qty_update_tbl        => l_qty_tbl
  , x_return_status         => l_return_status
  , x_msg_count            => l_msg_count
  , x_msg_data              => l_msg_data
  , x_sequence              =>  l_sequence);

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  -- dbms_output.put_line('Every thing is OK  : create_lot_uom_conv_wrapper ');


EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);
    -- dbms_output.put_line('Error  : '|| l_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);
    -- dbms_output.put_line('Error  : '|| l_msg_data );

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);
    -- dbms_output.put_line('Error  : '|| l_msg_data );

END create_lot_uom_conv_wrapper;

END INV_LOT_ATTR_PUB;

/
