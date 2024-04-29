--------------------------------------------------------
--  DDL for Package Body ITG_SYNCUOMINBOUND_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ITG_SYNCUOMINBOUND_PVT" AS
/* ARCS: $Header: itgvsuib.pls 120.3 2005/12/22 04:07:35 bsaratna noship $
 * CVS:  itgvsuib.pls,v 1.14 2002/12/23 21:20:30 ecoe Exp
 */

  g_action VARCHAR2(200):= '';

  G_PKG_NAME CONSTANT VARCHAR2(30) := 'ITG_SyncUOMInbound_PVT';

  FUNCTION check_size(
   p_value            IN  VARCHAR2,
    p_min              IN  NUMBER,
    p_max              IN  NUMBER,
    p_desc             IN  VARCHAR2
  ) RETURN VARCHAR2 IS
  BEGIN
    IF LENGTHB(p_value) NOT BETWEEN p_min AND p_max THEN /* bug 4002567*/
      ITG_Debug.msg('cs', 'Length check failed for field '||p_desc);
      ITG_MSG.data_value_error(p_value, p_min, p_max);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    RETURN p_value;
  END check_size;

  PROCEDURE insert_uom(
    p_uom_rec          IN  mtl_units_of_measure%ROWTYPE
  ) IS
    l_count               NUMBER := 0;
  BEGIN
    g_action := 'UOM parameters validation';
    IF NVL(p_uom_rec.base_uom_flag, 'z') NOT IN ('Y', 'N') THEN
      ITG_MSG.missing_element_value('BASEUOMFL', p_uom_rec.base_uom_flag);
      RAISE FND_API.G_EXC_ERROR;
    END IF;


	-- this condition is not accounted in the NOT EXISTS clause of the insert
	select count(*)
	into	 l_count
	from   mtl_units_of_measure
	where  (uom_code =  p_uom_rec.uom_code and  unit_of_measure <> p_uom_rec.unit_of_measure)
	  or   (uom_code <> p_uom_rec.uom_code and  unit_of_measure = p_uom_rec.unit_of_measure);

    	if l_count > 0 then
		itg_msg.dup_uom(p_uom_rec.uom_code,p_uom_rec.unit_of_measure);
		raise FND_API.G_EXC_ERROR;
	end if;

    IF p_uom_rec.base_uom_flag = 'Y' THEN
      SELECT COUNT(*)
      INTO   l_count
      FROM   mtl_units_of_measure
      WHERE  base_uom_flag = 'Y'
      AND    uom_class     = p_uom_rec.uom_class;
      IF l_count > 0 THEN
        ITG_MSG.toomany_base_uom_flag;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    g_action := 'UOM  insert';
    INSERT INTO mtl_units_of_measure_tl (
      unit_of_measure,
      unit_of_measure_tl,
      uom_code,
      uom_class,
      base_uom_flag,
      disable_date,
      description,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      language,
      source_lang
    ) SELECT p_uom_rec.unit_of_measure,
             p_uom_rec.unit_of_measure,
	       p_uom_rec.uom_code,
	       p_uom_rec.uom_class,
	       p_uom_rec.base_uom_flag,
	       p_uom_rec.disable_date,
	       p_uom_rec.description,
	       p_uom_rec.last_update_date,
	       p_uom_rec.last_updated_by,
	       p_uom_rec.creation_date,
	       p_uom_rec.created_by,
	       l.language_code,
	       USERENV('LANG')
        FROM   FND_LANGUAGES l
        WHERE  l.installed_flag IN ('I', 'B')
        AND    NOT EXISTS (
          SELECT NULL
          FROM   mtl_units_of_measure_tl t
          WHERE  (t.unit_of_measure = p_uom_rec.unit_of_measure
			OR t.uom_code	     = p_uom_rec.uom_code)
          AND    t.language        = l.language_code);
  END insert_uom;

  PROCEDURE delete_uom(
    p_uom_rec          IN  mtl_units_of_measure%ROWTYPE
  ) IS
  BEGIN
    g_action := 'UOM disable';
    IF p_uom_rec.disable_date IS NULL THEN
      ITG_MSG.null_disable_date;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    UPDATE mtl_units_of_measure_tl
    SET    disable_date       = p_uom_rec.disable_date,
           last_update_date   = p_uom_rec.last_update_date,
           last_updated_by    = p_uom_rec.last_updated_by,
	   --unit_of_measure_tl = p_uom_rec.unit_of_measure_tl, /*null update fails?*/
	   source_lang        = USERENV('LANG')
    WHERE  unit_of_measure 	= p_uom_rec.unit_of_measure
	AND uom_code  		= p_uom_rec.uom_code
	AND uom_class 		= p_uom_rec.uom_class
	AND USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);

    IF SQL%ROWCOUNT = 0 THEN
	ITG_MSG.no_uom(p_uom_rec.unit_of_measure||'-'||p_uom_rec.uom_code||'-'||p_uom_rec.uom_class);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END delete_uom;

  PROCEDURE update_uom(
    p_uom_rec          IN  mtl_units_of_measure%ROWTYPE
  ) IS
  BEGIN
    g_action := 'UOM update';
    UPDATE mtl_units_of_measure_tl
    SET    description        = p_uom_rec.description,
           disable_date       = p_uom_rec.disable_date,
	     --unit_of_measure_tl = p_uom_rec.unit_of_measure_tl, /*null update?*/
	     source_lang        = USERENV('LANG'),
           last_update_date   = p_uom_rec.last_update_date,
           last_updated_by    = p_uom_rec.last_updated_by
    WHERE  unit_of_measure 	= p_uom_rec.unit_of_measure
	AND  uom_code  		= p_uom_rec.uom_code
	AND  uom_class 		= p_uom_rec.uom_class
	AND  USERENV('LANG') IN (language, source_lang);

    IF SQL%ROWCOUNT = 0 THEN
	ITG_MSG.no_uom(p_uom_rec.unit_of_measure||'-'||p_uom_rec.uom_code||'-'||p_uom_rec.uom_class);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END update_uom;

  PROCEDURE valid_uom_class(
    p_uom_class        IN  VARCHAR2,
    p_xns_date         IN  DATE
  ) IS
    l_dummy                DATE;
    l_found                BOOLEAN := FALSE;

    CURSOR uom_class_csr IS
      SELECT disable_date
      FROM   mtl_uom_classes
      WHERE  uom_class = p_uom_class;
  BEGIN
    g_action := 'UOMClass validation';
    IF p_uom_class IS NOT NULL THEN
      OPEN  uom_class_csr;
      FETCH uom_class_csr INTO l_dummy;
      l_found := uom_class_csr%FOUND;
      CLOSE uom_class_csr;
      IF l_found AND NVL(p_xns_date, l_dummy) <= l_dummy THEN
        RETURN;
      END IF;
    END IF;

    ITG_MSG.missing_element_value('UOMCLASS', p_uom_class);
    RAISE FND_API.G_EXC_ERROR;
  END valid_uom_class;

  FUNCTION valid_number(
    p_value            IN  VARCHAR2,
    p_name             IN  VARCHAR2
  ) RETURN NUMBER IS
  BEGIN
    RETURN TO_NUMBER(p_value);
  EXCEPTION
    WHEN INVALID_NUMBER OR VALUE_ERROR THEN
      ITG_MSG.missing_element_value(p_name, p_value);
      RAISE FND_API.G_EXC_ERROR;
  END valid_number;

  FUNCTION reduce_conv_rate (
    p_numerator        IN  VARCHAR2,
    p_denominator      IN  VARCHAR2,
    p_fr_conv_fact     IN  NUMBER   := 1,
    p_to_conv_fact     IN  NUMBER   := 1
  ) RETURN VARCHAR2 IS
    l_fr_rate              NUMBER := 0;
    l_to_rate              NUMBER := 1;
    l_result               NUMBER;
  BEGIN
    /* Validate and convert each factor, calculate fraction */
    l_result  := (valid_number(p_numerator,   'FROMFACTOR') * p_fr_conv_fact) /
                 (valid_number(p_denominator, 'TOFACTOR'  ) * p_to_conv_fact);

    /* Reduce the fraction to a decimal value */
    RETURN SUBSTRB(TO_CHAR(l_result), 1, 40);/* bug 4002567*/
  EXCEPTION
	WHEN OTHERS THEN
		itg_msg.uomconvrate_err;
		RAISE FND_API.G_EXC_ERROR;
  END reduce_conv_rate;

  FUNCTION cross_validate(
    p_uom              IN  VARCHAR2,
    p_uom_code         IN  VARCHAR2,
    p_uom_class        IN  VARCHAR2
  ) RETURN VARCHAR2 IS
    l_base                 mtl_units_of_measure.base_uom_flag%TYPE;
  BEGIN
    SELECT base_uom_flag
    INTO   l_base
    FROM   mtl_units_of_measure
    WHERE  unit_of_measure = p_uom
    AND    uom_code        = p_uom_code
    AND    uom_class       = p_uom_class;

    RETURN l_base;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ITG_MSG.bad_uom_crossval;
      RAISE FND_API.G_EXC_ERROR;
  END cross_validate;

  FUNCTION get_default_conv_flag(
    p_uom_code         IN  VARCHAR2,
    p_uom_class        IN  VARCHAR2,
    p_conv_rate        IN  VARCHAR2
  ) RETURN VARCHAR2 IS
    l_dummy                NUMBER;
  BEGIN
    SELECT 1
    INTO   l_dummy
    FROM   mtl_uom_conversions
    WHERE  uom_code          = p_uom_code
    AND    uom_class         = p_uom_class
    AND    inventory_item_id = 0
    AND    conversion_rate   = TO_NUMBER(p_conv_rate);
    RETURN 'Y';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 'N';
  END get_default_conv_flag;

  FUNCTION get_in_base(
    p_uom_code         IN  VARCHAR2,
    p_itemid           IN  VARCHAR2
  ) RETURN NUMBER IS
    l_conv_rate            NUMBER;
  BEGIN
    SELECT conversion_rate
    INTO   l_conv_rate
    FROM   mtl_uom_conversions
    WHERE  uom_code = p_uom_code AND inventory_item_id = p_itemid;
    RETURN l_conv_rate;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ITG_MSG.conv_not_found(p_uom_code);
      RAISE FND_API.G_EXC_ERROR;
  END get_in_base;

  FUNCTION get_base_uom(
    p_uom_code         IN  VARCHAR2
  ) RETURN VARCHAR2 IS
    l_base_uom_code        mtl_units_of_measure.uom_code%TYPE;
  BEGIN
    SELECT m2.uom_code
    INTO   l_base_uom_code
    FROM   mtl_units_of_measure m1,
           mtl_units_of_measure m2
    WHERE  m1.uom_code      = p_uom_code
    AND    m1.uom_class     = m2.uom_class
    AND    m2.base_uom_flag = 'Y';
    RETURN l_base_uom_code;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ITG_MSG.base_uom_not_found(p_uom_code);
      RAISE FND_API.G_EXC_ERROR;
  END get_base_uom;

  PROCEDURE delete_uom_class(
    p_cls_rec          IN  mtl_uom_classes%ROWTYPE
  ) IS
  BEGIN
    g_action := 'UOMClass parameter validation';
    IF p_cls_rec.disable_date IS NULL THEN
      ITG_MSG.null_disable_date;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    g_action := 'UOMClass disable';
    UPDATE mtl_uom_classes_tl
    SET    disable_date     = p_cls_rec.disable_date,
           last_update_date = p_cls_rec.last_update_date,
           last_updated_by  = p_cls_rec.last_updated_by,
	     --uom_class_tl     = p_cls_rec.uom_class_tl, /*null update fails*/
	     source_lang      = USERENV('LANG')
    WHERE  uom_class       =  p_cls_rec.uom_class
    AND    USERENV('LANG') IN (language, source_lang);

    IF SQL%ROWCOUNT = 0 THEN
      ITG_MSG.no_uom_class(p_cls_rec.uom_class);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END delete_uom_class;

  PROCEDURE update_uom_class(
    p_cls_rec          IN  mtl_uom_classes%ROWTYPE
  ) IS
  BEGIN
    g_action := 'UOMClass update';
    UPDATE mtl_uom_classes_tl
    SET    description      = p_cls_rec.description,
           disable_date     = p_cls_rec.disable_date,
           last_update_date = p_cls_rec.last_update_date,
           last_updated_by  = p_cls_rec.last_updated_by,
	     --uom_class_tl     = p_cls_rec.uom_class_tl, /*null update fails*/
	   source_lang      = USERENV('LANG')
    WHERE  uom_class       =  p_cls_rec.uom_class
    AND    USERENV('LANG') IN (language, source_lang);

    IF SQL%ROWCOUNT = 0 THEN
      ITG_MSG.no_uom_class(p_cls_rec.uom_class);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END update_uom_class;

  PROCEDURE insert_uom_class(
    p_cls_rec          IN  mtl_uom_classes%ROWTYPE
  ) IS
  BEGIN
    g_action := 'UOMClass insert';
    INSERT INTO mtl_uom_classes_tl (
      uom_class,
      uom_class_tl,
      disable_date,
      description,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      language,
      source_lang
    ) SELECT p_cls_rec.uom_class,
             p_cls_rec.uom_class,
	     p_cls_rec.disable_date,
	     p_cls_rec.description,
	     p_cls_rec.last_update_date,
	     p_cls_rec.last_updated_by,
	     p_cls_rec.creation_date,
	     p_cls_rec.created_by,
	     l.language_code,
	     USERENV('LANG')
      FROM   fnd_languages l
      WHERE  l.installed_flag IN ('I', 'B')
      AND    NOT EXISTS
        (SELECT NULL
         FROM   mtl_uom_classes_tl t
         WHERE  t.uom_class = p_cls_rec.uom_class
         AND    t.language  = l.language_code);
  END insert_uom_class;

  PROCEDURE delete_uom_class_conv(
    p_ccv_rec          IN  mtl_uom_class_conversions%ROWTYPE
  ) IS
  BEGIN
    g_action := 'UOMClass-conversion parameter validation';
    IF p_ccv_rec.disable_date IS NULL THEN
      ITG_MSG.null_disable_date;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    g_action := 'UOMClassConversion delete';
    UPDATE mtl_uom_class_conversions
    SET    disable_date     = p_ccv_rec.disable_date,
           last_update_date = p_ccv_rec.last_update_date,
           last_updated_by  = p_ccv_rec.last_updated_by
    WHERE  from_unit_of_measure = p_ccv_rec.from_unit_of_measure
    AND    from_uom_code        = p_ccv_rec.from_uom_code
    AND    from_uom_class       = p_ccv_rec.from_uom_class
    AND    to_unit_of_measure   = p_ccv_rec.to_unit_of_measure
    AND    to_uom_code          = p_ccv_rec.to_uom_code
    AND    to_uom_class         = p_ccv_rec.to_uom_class;

    IF SQL%ROWCOUNT = 0 THEN
      ITG_MSG.no_uomclass_conv;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END delete_uom_class_conv;

  PROCEDURE update_uom_class_conv(
    p_ccv_rec          IN  mtl_uom_class_conversions%ROWTYPE
  ) IS
  BEGIN
    g_action := 'UOMClassConversion update';
    UPDATE mtl_uom_class_conversions
    SET    conversion_rate  = p_ccv_rec.conversion_rate,
           disable_date     = p_ccv_rec.disable_date,
           last_update_date = p_ccv_rec.last_update_date,
           last_updated_by  = p_ccv_rec.last_updated_by
    WHERE  from_unit_of_measure = p_ccv_rec.from_unit_of_measure
    AND    from_uom_code        = p_ccv_rec.from_uom_code
    AND    from_uom_class       = p_ccv_rec.from_uom_class
    AND    to_unit_of_measure   = p_ccv_rec.to_unit_of_measure
    AND    to_uom_code          = p_ccv_rec.to_uom_code
    AND    to_uom_class         = p_ccv_rec.to_uom_class;

    IF SQL%ROWCOUNT = 0 THEN
      ITG_MSG.no_uomclass_conv;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END update_uom_class_conv;


  PROCEDURE insert_uom_class_conv(
    p_ccv_rec          IN  mtl_uom_class_conversions%ROWTYPE
  ) IS
	l_count NUMBER;
  BEGIN
	g_action := 'UOMClass-conv insert';
	l_count := 0;

	SELECT	count(*)
	INTO		l_count
	FROM		mtl_uom_class_conversions
	WHERE 	inventory_item_id = p_ccv_rec.inventory_item_id AND
			( to_uom_code = p_ccv_rec.to_uom_code OR
			  to_uom_class = p_ccv_rec.to_uom_class OR
			  to_unit_of_measure = p_ccv_rec.to_unit_of_measure );

	IF l_count > 0 THEN
		itg_msg.dup_uomclass_conv;
		RAISE FND_API.G_EXC_ERROR;
	END IF;

    INSERT INTO mtl_uom_class_conversions (
      from_unit_of_measure,
      from_uom_code,
      from_uom_class,
      to_unit_of_measure,
      to_uom_code,
      to_uom_class,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      disable_date,
      inventory_item_id,
      conversion_rate
    ) VALUES (
      p_ccv_rec.from_unit_of_measure,
      p_ccv_rec.from_uom_code,
      p_ccv_rec.from_uom_class,
      p_ccv_rec.to_unit_of_measure,
      p_ccv_rec.to_uom_code,
      p_ccv_rec.to_uom_class,
      p_ccv_rec.last_update_date,
      p_ccv_rec.last_updated_by,
      p_ccv_rec.creation_date,
      p_ccv_rec.created_by,
      p_ccv_rec.disable_date,
      p_ccv_rec.inventory_item_id,
      p_ccv_rec.conversion_rate
    );
  END insert_uom_class_conv;

  PROCEDURE delete_uom_conv(
    p_con_rec          IN  mtl_uom_conversions%ROWTYPE
  ) IS
  BEGIN
    g_action := 'UOM-conversion parameter validation';
    IF p_con_rec.disable_date IS NULL THEN
      ITG_MSG.null_disable_date;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    g_action := 'UOM-conversion update';
    UPDATE mtl_uom_conversions
    SET    disable_date     = p_con_rec.disable_date,
           last_update_date = p_con_rec.last_update_date,
           last_updated_by  = p_con_rec.last_updated_by
    WHERE  unit_of_measure = p_con_rec.unit_of_measure
    AND    uom_code        = p_con_rec.uom_code
    AND    uom_class       = p_con_rec.uom_class;

    IF SQL%ROWCOUNT = 0 THEN
      ITG_MSG.no_uom_conv;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END delete_uom_conv;

  PROCEDURE update_uom_conv(
    p_con_rec          IN  mtl_uom_conversions%ROWTYPE
  ) IS
  BEGIN
    g_action := 'UOM-conversion update';
    UPDATE mtl_uom_conversions
    SET    conversion_rate  = p_con_rec.conversion_rate,
           disable_date     = p_con_rec.disable_date,
           last_update_date = p_con_rec.last_update_date,
           last_updated_by  = p_con_rec.last_updated_by
    WHERE  unit_of_measure = p_con_rec.unit_of_measure
    AND    uom_code        = p_con_rec.uom_code
    AND    uom_class       = p_con_rec.uom_class;

    IF SQL%ROWCOUNT = 0 THEN
      ITG_MSG.no_uom_conv;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END update_uom_conv;

  PROCEDURE insert_uom_conv(
    p_con_rec          IN  mtl_uom_conversions%ROWTYPE
  ) IS
    l_flag_count           NUMBER;
    l_count NUMBER;
  BEGIN
    g_action := 'UOM-conversion parameter validation';
    IF NVL(p_con_rec.default_conversion_flag, 'z') NOT IN ('Y', 'N') THEN
      ITG_MSG.missing_element_value(
        'CONVFLAG', p_con_rec.default_conversion_flag);
      RAISE FND_API.G_EXC_ERROR;
    END IF;


	select	count(*)
	into		l_count
	from		mtl_uom_conversions
	where		inventory_item_id = p_con_rec.inventory_item_id
		and	( unit_of_measure = p_con_rec.unit_of_measure
			OR uom_code = p_con_rec.uom_code );

	IF l_count > 0 then
		itg_msg.dup_uom_conv(p_con_rec.inventory_item_id,
			p_con_rec.uom_code||'-'||p_con_rec.unit_of_measure);
		RAISE FND_API.G_EXC_ERROR;
	end if;


    /* Check for multiple flags */
    IF p_con_rec.default_conversion_flag = 'Y' THEN
      SELECT COUNT(*)
      INTO   l_flag_count
      FROM   mtl_uom_conversions
      WHERE  default_conversion_flag = 'Y'
      AND    uom_class               = p_con_rec.uom_class;
      IF l_flag_count > 1 THEN
        ITG_MSG.toomany_default_conv_flag;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

      g_action := 'UOM-conversion insert';

    INSERT INTO mtl_uom_conversions (
      unit_of_measure,
      uom_code,
      uom_class,
      inventory_item_id,
      conversion_rate,
      default_conversion_flag,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      disable_date
    ) VALUES (
      p_con_rec.unit_of_measure,
      p_con_rec.uom_code,
      p_con_rec.uom_class,
      p_con_rec.inventory_item_id,
      p_con_rec.conversion_rate,
      p_con_rec.default_conversion_flag,
      p_con_rec.last_update_date,
      p_con_rec.last_updated_by,
      p_con_rec.creation_date,
      p_con_rec.created_by,
      p_con_rec.disable_date
    );

  END insert_uom_conv;

  /* Handle a task=UOMCLASS request
   * This procedure is referenced in processUOM, below, and must be
   * placed ahead of that procedure to avoid a forward reference error.
   */
  PROCEDURE process_uom_class (
    p_syncind          IN  VARCHAR2,
    p_uom              IN  VARCHAR2,
    p_uomcode          IN  VARCHAR2,
    p_uomclass         IN  VARCHAR2,
    p_defconflg        IN  VARCHAR2,
    p_description      IN  VARCHAR2,
    p_dt_creation      IN  DATE,
    p_dt_expiration    IN  DATE
  ) IS
    /* Working storage */
    l_cls_rec              mtl_uom_classes%ROWTYPE;
    l_uom_rec              mtl_units_of_measure%ROWTYPE;
    l_con_rec              mtl_uom_conversions%ROWTYPE;
    l_ccv_rec              mtl_uom_class_conversions%ROWTYPE;
    l_param VARCHAR2(200);
    l_value VARCHAR2(200);
  BEGIN

	g_action := 'UOMClass parameter validation';
 	l_param := null;

	IF p_uom IS NULL THEN
		l_param := 'UOM';
		l_value := null;
	ELSIF p_uomcode IS NULL THEN
		l_param := 'NOTES';
		l_value := null;
	ELSIF p_uomclass IS NULL THEN
		l_param := 'UOMGROUPID';
		l_value := null;
	ELSIF nvl(p_defconflg,'x') not in ('Y','N') THEN
		l_param := 'ORACLEITG.DEFCONFLAG';
		l_value := p_defconflg;
	ELSIF nvl(p_syncind,'x') not in ('A','C','D') THEN
		l_param := 'SYNCIND';
		l_value := p_syncind;
	END IF;

	IF l_param IS NOT NULL THEN
		itg_msg.missing_element_value(l_param,nvl(l_value,'NULL'));
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	g_action := 'UOMClass sync';

    /* Get the records together */
    IF p_syncind NOT IN ('A','C','D') THEN
	itg_msg.missing_element_value('SYNCIND',p_syncind);
	RAISE FND_API.G_EXC_ERROR;
    END IF;
    l_cls_rec.last_update_date := NVL(p_dt_creation, SYSDATE);
    l_cls_rec.last_updated_by  := FND_GLOBAL.user_id;
    l_cls_rec.creation_date    := l_cls_rec.last_update_date;
    l_cls_rec.created_by       := l_cls_rec.last_updated_by;

    l_cls_rec.disable_date     := p_dt_expiration;
    l_cls_rec.description      := check_size(p_description, 0, 50, 'Description');
    l_cls_rec.uom_class        := check_size(p_uomclass,    1, 10, 'UOM Class');
    l_uom_rec.unit_of_measure  := check_size(p_uom,         1, 25, 'Unit of Measure');
    l_uom_rec.uom_code         := check_size(p_uomcode,     1,  3, 'UOM Code');
    l_uom_rec.base_uom_flag    := 'Y';

    l_con_rec.default_conversion_flag := check_size(p_defconflg,   1,  1, 'Default Conversion Flag');
    l_con_rec.conversion_rate         := 1;
    l_con_rec.inventory_item_id       := 0;

    l_uom_rec.last_update_date  := l_cls_rec.last_update_date;
    l_uom_rec.last_updated_by   := l_cls_rec.last_updated_by;
    l_uom_rec.creation_date     := l_cls_rec.creation_date;
    l_uom_rec.created_by        := l_cls_rec.created_by;
    l_uom_rec.uom_class         := l_cls_rec.uom_class;
    l_uom_rec.Description       := l_uom_rec.unit_of_measure;

    l_con_rec.last_update_date  := l_cls_rec.last_update_date;
    l_con_rec.last_updated_by   := l_cls_rec.last_updated_by;
    l_con_rec.creation_date     := l_cls_rec.creation_date;
    l_con_rec.created_by        := l_cls_rec.created_by;
    l_con_rec.unit_of_measure   := l_uom_rec.unit_of_measure;
    l_con_rec.uom_class         := l_cls_rec.uom_class;
    l_con_rec.uom_code          := l_uom_rec.uom_code;

    l_ccv_rec.last_update_date     := l_cls_rec.last_update_date;
    l_ccv_rec.last_updated_by      := l_cls_rec.last_updated_by;
    l_ccv_rec.creation_date        := l_cls_rec.creation_date;
    l_ccv_rec.created_by           := l_cls_rec.created_by;
    l_ccv_rec.from_unit_of_measure := l_uom_rec.unit_of_measure;
    l_ccv_rec.to_unit_of_measure   := l_uom_rec.unit_of_measure;
    l_ccv_rec.from_uom_class       := l_cls_rec.uom_class;
    l_ccv_rec.to_uom_class         := l_cls_rec.uom_class;
    l_ccv_rec.from_uom_code        := l_uom_rec.uom_code;
    l_ccv_rec.to_uom_code          := l_uom_rec.uom_code;
    l_ccv_rec.conversion_rate      := l_con_rec.conversion_rate;
    l_ccv_rec.inventory_item_id    := l_con_rec.inventory_item_id;
    g_action := 'UOMCLASS sync';

	-- since date field are not coming from the XML
	-- set disabledate to current date for delete_uom
	IF p_syncind = 'D' then
		l_cls_rec.disable_date     := sysdate;
		l_con_rec.disable_date     := sysdate;
		l_ccv_rec.disable_date     := sysdate;
		l_uom_rec.disable_date     := sysdate;
	END IF;

    /* What are we doing? */
    IF    p_syncind = 'A' THEN
      insert_uom_class     (l_cls_rec);
      insert_uom_conv      (l_con_rec);
      insert_uom_class_conv(l_ccv_rec);
      insert_uom           (l_uom_rec);
    ELSIF p_syncind = 'C' THEN
      update_uom_class     (l_cls_rec);
      update_uom_conv      (l_con_rec);
      update_uom_class_conv(l_ccv_rec);
      update_uom           (l_uom_rec);
    ELSIF p_syncind = 'D' THEN
      delete_uom_class     (l_cls_rec);
      delete_uom_conv      (l_con_rec);
      delete_uom_class_conv(l_ccv_rec);
      delete_uom           (l_uom_rec);
    END IF;
  END process_uom_class;

  PROCEDURE process_uom(
    p_syncind          IN  VARCHAR2,
    p_uom              IN  VARCHAR2,
    p_uomcode          IN  VARCHAR2,
    p_uomclass         IN  VARCHAR2,
    p_buomflag         IN  VARCHAR2,
    p_description      IN  VARCHAR2,
    p_dt_creation      IN  DATE,
    p_dt_expiration    IN  DATE
  ) IS
    l_uom_rec     mtl_units_of_measure%ROWTYPE;

    CURSOR l_def_cls_csr IS
      SELECT uom_class
      FROM   mtl_units_of_measure
      WHERE  unit_of_measure = l_uom_rec.unit_of_measure;
	l_param VARCHAR2(200);
	l_value VARCHAR2(200);
  BEGIN

	g_action := 'UOM parameter validation';
 	l_param := null;

	IF p_uom IS NULL THEN
		l_param := 'UOM';
		l_value := null;
	ELSIF p_uomcode IS NULL THEN
		l_param := 'NOTES';
		l_value := null;
	ELSIF nvl(p_buomflag,'x') NOT IN ('Y','N') THEN
		l_param := 'ORACLEITG.BASEUOMFLAG';
		l_value := p_buomflag;
	ELSIF nvl(p_syncind,'x') not in ('A','C','D') THEN
		l_param := 'SYNCIND';
		l_value := p_syncind;
	END IF;

	IF l_param IS NOT NULL THEN
		itg_msg.missing_element_value(l_param,nvl(l_value,'NULL'));
		RAISE FND_API.G_EXC_ERROR;
	END IF;

    /* Get the record together */
    l_uom_rec.last_update_date := NVL(p_dt_creation, SYSDATE);
    l_uom_rec.last_updated_by  := FND_GLOBAL.user_id;
    l_uom_rec.creation_date    := l_uom_rec.last_update_date;
    l_uom_rec.created_by       := l_uom_rec.last_updated_by;

    l_uom_rec.disable_date     := p_dt_expiration;
    l_uom_rec.description      := check_size(p_description,  0, 50, 'Description');
    l_uom_rec.unit_of_measure  := check_size(p_uom,          1, 25, 'Unit of Measure');
    l_uom_rec.uom_code         := check_size(p_uomcode,      1,  3, 'UOM Code');
    l_uom_rec.uom_class        := check_size(p_uomclass,     1, 10, 'UOM Class');
    l_uom_rec.base_uom_flag    := check_size(p_buomflag,     1,  1, 'Base UOM Flag');

    IF p_syncind = 'A' AND l_uom_rec.uom_class IS NULL THEN
      /* This signals that what we are really doing is a processUomClass.
       * Fill a field segment nested table accordingly, then call the
       * UOM Class procedure.
       */
	g_action := 'UOMClass sync';
      process_uom_class(
        p_syncind       => p_syncind,
        p_uom           => p_uom,
        p_uomcode       => p_uomcode,
        p_uomclass      => 'SAP'||p_uomcode,
        p_defconflg     => 'Y',
        p_description   => p_description,
        p_dt_creation   => p_dt_creation,
        p_dt_expiration => p_dt_expiration
      );
    ELSE
      IF l_uom_rec.uom_class IS NULL THEN
        /* Not inserting a new UOM but no UOM Class passed in.
         * Have only to look up the class that goes with the UOM,
         * since the UOM exists in Oracle already.
	 *
	 * MUST set l_uom_rec.unit_of_measure first!
	 */
        OPEN  l_def_cls_csr;
        FETCH l_def_cls_csr INTO l_uom_rec.uom_class;
        CLOSE l_def_cls_csr;
      END IF;
      /* Make sure the UOM Class is valid */
      valid_uom_class(l_uom_rec.uom_class, l_uom_rec.creation_date);
      /* What are we doing? */
	g_action := 'UOM sync';
	-- since date field are not coming from the XML
	-- set disabledate to current date for delete_uom
	IF p_syncind = 'D' then
		l_uom_rec.disable_date     := sysdate;
	END IF;

      IF    p_syncind = 'A' THEN insert_uom(l_uom_rec);
      ELSIF p_syncind = 'C' THEN update_uom(l_uom_rec);
      ELSIF p_syncind = 'D' THEN delete_uom(l_uom_rec);
      END IF;
    END IF;
  END process_uom;

  PROCEDURE process_uom_inter (
    p_syncind          IN  VARCHAR2,
    p_fruomcode        IN  VARCHAR2,
    p_touomcode        IN  VARCHAR2,
    p_itemid           IN  VARCHAR2,
    p_conv_rate        IN  VARCHAR2,
    p_dt_creation      IN  DATE,
    p_dt_expiration    IN  DATE
  ) IS
    l_ccv_rec              mtl_uom_class_conversions%ROWTYPE;
    l_dummy                mtl_units_of_measure.base_uom_flag%TYPE;

    /* Get uom and default the value of uom_class. */
    CURSOR l_uom_csr(l_uom_code VARCHAR2) IS
      SELECT uom_class, unit_of_measure
      FROM   mtl_units_of_measure
      WHERE  uom_code = l_uom_code;

  BEGIN
    g_action := 'UOM conversion parameter validation';

    IF p_syncind NOT IN ('A','C','D') THEN
	itg_msg.missing_element_value('SYNCIND',p_syncind);
	RAISE FND_API.G_EXC_ERROR;
    END IF;

    /* Get the record together */
    l_ccv_rec.last_update_date := NVL(p_dt_creation, SYSDATE);
    l_ccv_rec.last_updated_by  := FND_GLOBAL.user_id;
    l_ccv_rec.creation_date    := l_ccv_rec.last_update_date;
    l_ccv_rec.created_by       := l_ccv_rec.last_updated_by;
    l_ccv_rec.disable_date     := p_dt_expiration;

    /* Deal with the from_uom_class */
    l_ccv_rec.from_uom_code    :=
      check_size(p_fruomcode, 1, 3,'From UOM Code');
    OPEN  l_uom_csr(l_ccv_rec.from_uom_code);
    FETCH l_uom_csr INTO l_ccv_rec.from_uom_class,
                         l_ccv_rec.from_unit_of_measure;
    CLOSE l_uom_csr;
    valid_uom_class(l_ccv_rec.from_uom_class, l_ccv_rec.creation_date);

    /* Deal with the to_uom_class */
    l_ccv_rec.to_uom_code      :=
      check_size(p_touomcode, 1, 3, 'To UOM Code');
    OPEN  l_uom_csr(l_ccv_rec.to_uom_code);
    FETCH l_uom_csr INTO l_ccv_rec.to_uom_class,
                         l_ccv_rec.to_unit_of_measure;
    CLOSE l_uom_csr;
    valid_uom_class(l_ccv_rec.to_uom_class, l_ccv_rec.creation_date);

    l_ccv_rec.conversion_rate  := valid_number(p_conv_rate, 'CONVRATE');
    IF NVL(l_ccv_rec.conversion_rate, 0) <= 0 THEN
      ITG_MSG.missing_element_value('CONVRATE', p_conv_rate);
      RAISE FND_API.G_EXC_ERROR;
    ELSIF p_itemid IS NULL THEN
      ITG_MSG.missing_element_value('ITEMID', p_itemid);
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      /* l_ccv_rec.inventory_item_id :=
           po_ip_oagxml_pkg.getItemId(p_itemid, NULL); */
      NULL;
    END IF;
    l_ccv_rec.inventory_item_id := p_itemid;
    l_dummy := cross_validate(
      l_ccv_rec.from_unit_of_measure,
      l_ccv_rec.from_uom_code,
      l_ccv_rec.from_uom_class);

    l_dummy := cross_validate(
      l_ccv_rec.to_unit_of_measure,
      l_ccv_rec.to_uom_code,
      l_ccv_rec.to_uom_class);

    IF p_syncind = 'D' THEN
	    l_ccv_rec.disable_date     := sysdate;
    END IF;

    g_action := 'UOM conversion sync';

    /* What are we doing? */
    IF    p_syncind = 'A'  THEN insert_uom_class_conv(l_ccv_rec);
    ELSIF p_syncind = 'C'  THEN update_uom_class_conv(l_ccv_rec);
    ELSIF p_syncind = 'D'  THEN delete_uom_class_conv(l_ccv_rec);
    END IF;
  END process_uom_inter;

  PROCEDURE process_uom_intra (
    p_syncind          IN  VARCHAR2,
    p_uom              IN  VARCHAR2,
    p_uomcode          IN  VARCHAR2,
    p_uomclass         IN  VARCHAR2,
    p_itemid           IN  VARCHAR2,
    p_conv_rate        IN  VARCHAR2,
    p_def_conv         IN  VARCHAR2,
    p_dt_creation      IN  DATE,
    p_dt_expiration    IN  DATE
  ) IS
    /* Working storage */
    l_con_rec              mtl_uom_conversions%ROWTYPE;
    l_base_flag            mtl_units_of_measure.base_uom_flag%TYPE;

    /* Default the value of uom_class */
    CURSOR l_def_cls_csr IS
      SELECT uom_class
      FROM   mtl_units_of_measure
      WHERE  unit_of_measure = l_con_rec.unit_of_measure;
  BEGIN

    g_action := 'UOM-conversion parameter validation';

    IF p_syncind NOT IN ('A','C','D') THEN
	itg_msg.missing_element_value('SYNCIND',p_syncind);
	RAISE FND_API.G_EXC_ERROR;
    END IF;


    /* Get the record together */
    l_con_rec.last_update_date := NVL(p_dt_creation, SYSDATE);
    l_con_rec.last_updated_by  := FND_GLOBAL.user_id;
    l_con_rec.creation_date    := l_con_rec.last_update_date;
    l_con_rec.created_by       := l_con_rec.last_updated_by;
    l_con_rec.disable_date     := p_dt_expiration;
    l_con_rec.unit_of_measure  :=
      check_size(p_uom,     1, 25, 'Unit of Measure');
    l_con_rec.uom_code         :=
      check_size(p_uomcode, 1,  3,  'UOM Code');

    /* UOM_CLASS lives in field segment 3 */
    IF p_uomclass IS NULL THEN
      /* MUST set l_con_rec.unit_of_measure first! */
      OPEN  l_def_cls_csr;
      FETCH l_def_cls_csr INTO l_con_rec.uom_class;
      CLOSE l_def_cls_csr;
    ELSE
      l_con_rec.uom_class := check_size(p_uomclass, 1, 10, 'UOM Class');
    END IF;

    valid_uom_class(l_con_rec.uom_class, l_con_rec.creation_date);

    /* Validate uom with class and code, get the base flag in the process */
    l_base_flag := cross_validate(
      l_con_rec.unit_of_measure,
      l_con_rec.uom_code,
      l_con_rec.uom_class);

    /* Validate the conversion factor
     * (needs the uom, code, class and l_base_flag)
     */
    l_con_rec.conversion_rate := valid_number(p_conv_rate, 'CONVRATE');
    IF NVL(l_con_rec.conversion_rate, 0) <= 0 THEN
      ITG_MSG.neg_conv;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF p_itemid IS NULL THEN
      l_con_rec.inventory_item_id := 0;
      IF l_base_flag = 'Y' THEN
        IF NVL(l_con_rec.conversion_rate, 0) <> 1 THEN
	  ITG_MSG.missing_element_value('CONVRATE', p_conv_rate);
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
    ELSE
	--TODO!. Need to enhance the XGM to allow item_seg + org
	l_con_rec.inventory_item_id := p_itemid;
      /* l_con_rec.inventory_item_id :=
           po_ip_oagxml_pkg.getItemId(p_itemid, NULL); */
      NULL;
    END IF;

    IF p_syncind = 'D' then
    	l_con_rec.disable_date     := sysdate;
    END IF;
    g_action := 'UOM conversion sync';
    /* set the value for default converstion flag */
    l_con_rec.default_conversion_flag := p_def_conv;
    /* What are we doing? */
    IF    p_syncind = 'A' THEN insert_uom_conv(l_con_rec);
    ELSIF p_syncind = 'C' THEN update_uom_conv(l_con_rec);
    ELSIF p_syncind = 'D' THEN delete_uom_conv(l_con_rec);
    END IF;

  END process_uom_intra;

  /* Handle a task=UOMCONV request by differentiating the type of conversion,
   * either a standard, interclass or intraclass, and filling a field nested
   * table object accordingly, then pass that object to the private procedure
   * that processes that conversion
   */
  PROCEDURE process_uom_conv (
    p_syncind          IN  VARCHAR2 ,
    p_fromcode         IN  VARCHAR2,
    p_touomcode        IN  VARCHAR2,
    p_itemid           IN  NUMBER,
    p_fromfactor       IN  VARCHAR2,
    p_tofactor         IN  VARCHAR2,
    p_dt_creation      IN  DATE,
    p_dt_expiration    IN  DATE
  ) IS
    l_fr_base_uom          mtl_units_of_measure.uom_code%TYPE;
    l_to_base_uom          mtl_units_of_measure.uom_code%TYPE;

    /* Default the value of uom_class */
    CURSOR l_uom_csr(
      p_uom_code  VARCHAR2
    ) IS
      SELECT uom_class, unit_of_measure, uom_code, base_uom_flag
      FROM   mtl_units_of_measure
      WHERE  uom_code      =    p_uom_code
      AND    base_uom_flag LIKE '%';

    l_fr_uom_csr_rec       l_uom_csr%ROWTYPE;
    l_to_uom_csr_rec       l_uom_csr%ROWTYPE;
    l_conv_rate            VARCHAR2(40);
    l_fr_conv              NUMBER;
    l_to_conv              NUMBER;
    l_def_conv_flag        VARCHAR2(4);
    l_tmp 			   NUMBER;
    l_param			   VARCHAR2(20);
    l_value			   VARCHAR2(20);
  BEGIN

    /* Look up/massage the necessary UOM data...
     * The touomcode ALWAYS gets passed in
     */
    OPEN  l_uom_csr(p_touomcode);
    FETCH l_uom_csr INTO l_to_uom_csr_rec;
    CLOSE l_uom_csr;

    IF l_to_uom_csr_rec.uom_code IS NULL THEN
      ITG_MSG.missing_element_value('UOMGRPDTL/UOM', p_touomcode);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    /* Build an outField using the "in" field (the field parameter coming in,
     * that is) which we will pass along to the appropriate procedure,
     * processIntraConv or processInterConv.
     * item id is null, it is a standered conversion
     *
     * Reduce the conversion rates to a decimal value
     * this value is needed for all 3 types of conversions
     * There is no conversion factors when the units are same
     * for different UOM another call to this procede will be made.
     */
    BEGIN
	l_param := 'UOMGRPHDR/QUANTITY';
      l_value := p_fromfactor;
	l_tmp := to_number(p_fromfactor);

	l_param := 'UOMGRPDTL/QUANTITY';
      l_value := p_tofactor;
	l_tmp := to_number(p_tofactor);

	IF l_tmp = 0 THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

    EXCEPTION
	WHEN OTHERS THEN
		ITG_MSG.missing_element_value(l_param,l_value);
		RAISE FND_API.G_EXC_ERROR;
    END;
    l_conv_rate := reduce_conv_rate(p_fromfactor, p_tofactor);


    IF p_itemid IS NULL THEN
      /* Case 1 standard */
      /* No ITEM_ID passed to us - Build a Standard conversion field table */
      process_uom_intra(
        p_syncind       => p_syncind,
        p_uom           => l_to_uom_csr_rec.unit_of_measure,
        p_uomcode       => l_to_uom_csr_rec.uom_code,
        p_uomclass      => l_to_uom_csr_rec.uom_class,
        p_itemid        => p_itemid,
        p_conv_rate     => l_conv_rate,
        p_def_conv      => 'N',
        p_dt_creation   => p_dt_creation,
        p_dt_expiration => p_dt_expiration
      );

    ELSE
      /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
       * For Intra conversion, when fruomcode is null
       * +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
       */

      IF p_fromcode IS NULL THEN
        /* case 2 Intra-class
         * need to make sure the item's uom class is the same as
         * what we are
         * Build an Intra-Class conversion field table
	 */
        l_def_conv_flag := get_default_conv_flag(
	  l_to_uom_csr_rec.uom_code, l_to_uom_csr_rec.uom_class, l_conv_rate);

        /* Call the intra conversion procedure. */
        process_uom_intra(
	  p_syncind       => p_syncind,
	  p_uom           => l_to_uom_csr_rec.unit_of_measure,
	  p_uomcode       => l_to_uom_csr_rec.uom_code,
	  p_uomclass      => l_to_uom_csr_rec.uom_class,
	  p_itemid        => p_itemid,
	  p_conv_rate     => l_conv_rate,
	  p_def_conv      => l_def_conv_flag,
	  p_dt_creation   => p_dt_creation,
        p_dt_expiration => p_dt_expiration
        );

      ELSE

      OPEN  l_uom_csr(p_fromcode);
      FETCH l_uom_csr INTO l_fr_uom_csr_rec;
      CLOSE l_uom_csr;

	IF l_fr_uom_csr_rec.uom_code IS NULL THEN
		ITG_MSG.missing_element_value('UOMGRPHDR/UOM', p_fromcode);
		RAISE FND_API.G_EXC_ERROR;
	END IF;

        /* Build an Inter-Class conversion field table
         * need to find the conversion rate based on the base UOM's.
         * Look up the fruomcode data...
         * convert to base uom
	 */
	l_fr_conv := get_in_base(l_fr_uom_csr_rec.uom_code,nvl(p_itemid,0)) ;
	l_to_conv := get_in_base(l_to_uom_csr_rec.uom_code,nvl(p_itemid,0)) ;

	/* get the base UOM for these codes */
	l_fr_base_uom := get_base_uom(l_fr_uom_csr_rec.uom_code);
	l_to_base_uom := get_base_uom(l_to_uom_csr_rec.uom_code);

        l_conv_rate := reduce_conv_rate(
          p_fromfactor, p_tofactor, l_fr_conv, l_to_conv);

        process_uom_inter(
          p_syncind       => p_syncind,
          p_fruomcode     => l_fr_base_uom,
          p_touomcode     => l_to_base_uom,
          p_itemid        => p_itemid,
          p_conv_rate     => l_conv_rate,
          p_dt_creation   => p_dt_creation,
          p_dt_expiration => p_dt_expiration
	);

      END IF;
    END IF;
  END process_uom_conv;

  /* Public functions */

  /* Only one public function, depend in the value of the p_task, will call
     different APIs */
  PROCEDURE Sync_UOM_All(
    x_return_status    OUT NOCOPY VARCHAR2,         /* VARCHAR2(1) */
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2,         /* VARCHAR2(2000) */

    p_task             IN         VARCHAR2,
    p_syncind          IN         VARCHAR2,
    p_uom              IN         VARCHAR2 := NULL,
    p_uomcode          IN         VARCHAR2 := NULL,
    p_uomclass         IN         VARCHAR2 := NULL,
    p_buomflag         IN         VARCHAR2 := NULL,
    p_description      IN         VARCHAR2 := NULL,
    p_defconflg        IN         VARCHAR2 := NULL,
    p_fromcode         IN         VARCHAR2 := NULL,
    p_touomcode        IN         VARCHAR2 := NULL,
    p_itemid           IN         NUMBER   := NULL,
    p_fromfactor       IN         VARCHAR2 := NULL,
    p_tofactor         IN         VARCHAR2 := NULL,
    p_dt_creation      IN         DATE     := NULL,
    p_dt_expiration    IN         DATE     := NULL
  ) IS
    l_api_name    CONSTANT VARCHAR2(30) := 'Sync_UOM_ALL';
    l_api_version CONSTANT NUMBER       := 1.0;

    l_dt_creation 	DATE;
    l_dt_expiration 	DATE;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    g_action := 'UOM sync';

    SAVEPOINT Sync_UOM_ALL;
    ITG_Debug.setup(
    	p_reset     => TRUE,
	p_pkg_name  => G_PKG_NAME,
	p_proc_name => l_api_name);


      -- Now in wrapper FND_MSG_PUB.Initialize;

      /* NOTE: Add more tracing, esp. called procedures */
      ITG_Debug.msg('SUA', 'Top of procedure.');
      ITG_Debug.msg('SUA', 'p_task',          p_task);
      ITG_Debug.msg('SUA', 'p_syncind',       p_syncind);
      ITG_Debug.msg('SUA', 'p_uom',           p_uom);
      ITG_Debug.msg('SUA', 'p_uomcode',       p_uomcode);
      ITG_Debug.msg('SUA', 'p_uomclass',      p_uomclass);
      ITG_Debug.msg('SUA', 'p_buomflag',      p_buomflag);
      ITG_Debug.msg('SUA', 'p_description',   p_description);
      ITG_Debug.msg('SUA', 'p_defconflg',     p_defconflg);
      ITG_Debug.msg('SUA', 'p_fromcode',      p_fromcode,      TRUE);
      ITG_Debug.msg('SUA', 'p_touomcode',     p_touomcode,     TRUE);
      ITG_Debug.msg('SUA', 'p_itemid',        p_itemid);
      ITG_Debug.msg('SUA', 'p_fromfactor',    p_fromfactor,    TRUE);
      ITG_Debug.msg('SUA', 'p_tofactor',      p_tofactor,      TRUE);
      ITG_Debug.msg('SUA', 'p_dt_creation',   p_dt_creation);
      ITG_Debug.msg('SUA', 'p_dt_expiration', p_dt_expiration);

      l_dt_creation := NVL(p_dt_creation, SYSDATE);
	l_dt_expiration := NVL(p_dt_expiration,l_dt_creation+3650);

      /* Here goes the switch */
      IF upper(p_task) = 'UOM' THEN
      g_action := 'synchronzing UOM';
	process_uom(
	  p_syncind       => upper(p_syncind),
	  p_uom           => p_uom,
	  p_uomcode       => p_uomcode,
	  p_uomclass      => p_uomclass,
	  p_buomflag      => p_buomflag,
	  p_description   => p_description,
	  p_dt_creation   => l_dt_creation,
	  p_dt_expiration => l_dt_expiration
	);

      ELSIF upper(p_task) = 'UOMCLASS' THEN
      g_action := 'UOMCLASS sync';
	process_uom_class(
	  p_syncind       => upper(p_syncind),
	  p_uom           => p_uom,
	  p_uomcode       => p_uomcode,
	  p_uomclass      => p_uomclass,
	  p_defconflg     => p_defconflg,
	  p_description   => p_description,
	  p_dt_creation   => l_dt_creation,
	  p_dt_expiration => l_dt_expiration
	);
      ELSIF upper(p_task) = 'UOMCONV' THEN
      g_action := 'UOM conversion sync';
	process_uom_conv(
	  p_syncind       => upper(p_syncind),
	  p_fromcode      => p_fromcode,
	  p_touomcode     => p_touomcode,
	  p_itemid        => p_itemid,
	  p_fromfactor    => p_fromfactor,
	  p_tofactor      => p_tofactor,
	  p_dt_creation   => l_dt_creation,
	  p_dt_expiration => l_dt_expiration
	);
      ELSE
	ITG_MSG.missing_element_value('P_TASK', p_task);
      END IF;

	COMMIT WORK;

      ITG_Debug.msg('SUA', 'Done.');

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
      	ROLLBACK TO Sync_UOM_ALL;
      	x_return_status := FND_API.G_RET_STS_ERROR;
            ITG_msg.checked_error(g_action);

      WHEN OTHERS THEN
      	ROLLBACK TO Sync_UOM_ALL;
      	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            ITG_msg.unexpected_error(g_action);
		itg_debug.msg('Unexpected error (UOMSync) - ' || substr(SQLERRM,1,255),true);

    -- Removed FND_MSG_PUB.Count_And_Get

  END Sync_UOM_ALL;

END ITG_SyncUOMInbound_PVT;

/
