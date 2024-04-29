--------------------------------------------------------
--  DDL for Package Body HZ_MO_GLOBAL_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_MO_GLOBAL_CACHE" as
/*$Header: ARHMOGCB.pls 120.8 2006/04/17 22:54:56 dmmehta noship $ */

---------------------------------------------
-- declaration of private global variables.
---------------------------------------------

TYPE G_Cache_Type IS TABLE OF HZ_MO_GLOBAL_CACHE.GlobalsRecord
					INDEX BY BINARY_INTEGER;

G_Cache	G_Cache_Type;

G_Cust_Gen_Cache HZ_MO_GLOBAL_CACHE.cust_num_gen_rec;

--logging related
MOD_PKG                    VARCHAR2(30)  := 'hz.plsql.HZ_MO_GLOBAL_CACHE';
MOD_validate_orgid_pub_api VARCHAR2(50)  := MOD_PKG || '.validate_orgid_pub_api';


--------------------------------------
-- declaration of private procedures and functions
--------------------------------------

PROCEDURE populate;

--------------------------------------
-- private procedures and functions
--------------------------------------
/**==========================================================================+
 | PROCEDURE populate
 |
 | DESCRIPTION
 |     	This procedure retrieves operating unit attributes from the database
 |	and stores them in the cache.
 |
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS
 |   IN:
 |   IN/OUT:
 |   OUT:
 |
 | RETURNS	: NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |  12-MAY-2005    Rajib Ranjan Borah   o TCA SSA Uptake (Bug 3456489) Created.
 |
 +==========================================================================**/

PROCEDURE populate
IS
	i	PLS_INTEGER;
	l_gt	HZ_MO_GLOBAL_CACHE.GlobalsTable;
BEGIN
	G_Cache.DELETE;
	retrieve_globals(l_gt);

	IF (l_gt.org_id_t.COUNT > 0) THEN
		FOR i IN 1..l_gt.org_id_t.LAST LOOP
			G_Cache(l_gt.org_id_t(i)).auto_site_numbering :=
				l_gt.auto_site_numbering_t(i);
			G_Cache(l_gt.org_id_t(i)).default_country :=
				l_gt.default_country_t(i);
			G_Cache(l_gt.org_id_t(i)).chart_of_accounts_id :=
				l_gt.chart_of_accounts_id_t(i);
			G_Cache(l_gt.org_id_t(i)).set_of_books_id :=
				l_gt.set_of_books_id_t(i);
			G_Cache(l_gt.org_id_t(i)).location_structure_id :=
				l_gt.location_structure_id_t(i);
			G_Cache(l_gt.org_id_t(i)).tax_method :=
				l_gt.tax_method_t(i);
			G_Cache(l_gt.org_id_t(i)).Address_val:=
				l_gt.address_val_t(i);
                        --  Bug 5002547 : Added create_reciprocal_flag
                        G_Cache(l_gt.org_id_t(i)).reciprocal_flag:=
                                l_gt.reciprocal_flag_t(i);
		END LOOP;
	END IF;
END populate;


--------------------------------------
-- public procedures and functions
--------------------------------------

/**
 * PROCEDURE retrieve_globals
 *
 * DESCRIPTION
 *     	This procedure retrieves operating unit attributes from the database
 *	and stores them into the specified data structure.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *   IN/OUT:
 *   OUT:
 *	p_globals			The global variables from AR System
 *					parameters used in TCA.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *  12-MAY-2005    Rajib Ranjan Borah   o TCA SSA Uptake (Bug 3456489) Created.
 *
 */

PROCEDURE retrieve_globals(
        p_globals	OUT	NOCOPY	GlobalsTable
) IS

BEGIN
	SELECT 	asp.org_id,
		asp.auto_site_numbering,
	        asp.default_country,
	        gl.chart_of_accounts_id,
	        gl.set_of_books_id,
		asp.location_structure_id,
		asp.tax_method,
                asp.address_validation,
                --  Bug 5002547 : Added create_reciprocal_flag
                nvl(asp.create_reciprocal_flag, 'N')
	BULK COLLECT
	INTO   	p_globals.org_id_t,
	        p_globals.auto_site_numbering_t,
		p_globals.default_country_t,
	        p_globals.chart_of_accounts_id_t,
	        p_globals.set_of_books_id_t,
		p_globals.location_structure_id_t,
		p_globals.tax_method_t,
                p_globals.address_val_t,
                --  Bug 5002547 : Added create_reciprocal_flag
                p_globals.reciprocal_flag_t
	FROM   	gl_sets_of_books gl,
	        ar_system_parameters asp
	WHERE 	gl.set_of_books_id = asp.set_of_books_id;

END retrieve_globals;


/**
 * FUNCTION get_org_attributes
 *
 * DESCRIPTION
 *     	Checks whether the specified org exists in the cache and returns the
 *	attributes if the org exists.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_org_id_in			Organization ID
 *
 *   IN/OUT:
 *   OUT:
 *
 * RETURNS:
 *	GlobalsRecord			Attributes corresponding to the Org.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 * 12-MAY-2005    Rajib Ranjan Borah   o TCA SSA Uptake (Bug 3456489) Created.
 */

FUNCTION get_org_attributes	(
        p_org_id		IN	NUMBER
				)
RETURN	hz_mo_global_cache.GlobalsRecord
IS
BEGIN
	IF G_Cache.exists(p_org_id) THEN
		Return(G_Cache(p_org_id));
	ELSE
		Populate();
		IF G_Cache.exists(p_org_id) THEN
			Return(G_Cache(p_org_id));
		ELSE
			RAISE NO_DATA_FOUND;
		END IF;
	END IF;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			FND_MESSAGE.SET_NAME('AR',
					'AR_NO_ROW_IN_SYSTEM_PARAMETERS');
			FND_MSG_PUB.ADD;
			RAISE;
END get_org_attributes;

/**
 * FUNCTION get_auto_site_numbering
 *
 * DESCRIPTION
 *     	Returns the Site Number Generation Setting for the org.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_org_id_in			Organization ID
 *
 *   IN/OUT:
 *   OUT:
 *
 * RETURNS:
 *	Auto_Site_Numbering		Auto_site_numbering setting for the Org.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *     12-MAY-2005    Rajib Ranjan Borah   o TCA SSA Uptake (Bug 3456489) Created.
 */

FUNCTION get_auto_site_numbering(
        p_org_id		IN	NUMBER
				)
RETURN	varchar2
IS
	L_Param_Rec	HZ_MO_GLOBAL_CACHE.GlobalsRecord;

BEGIN
	L_Param_Rec := Get_Org_Attributes(p_org_id);
	RETURN	L_Param_Rec.auto_site_numbering;
END get_auto_site_numbering;

/**
 * FUNCTION get_default_country
 *
 * DESCRIPTION
 *     	Returns the default country for the org.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_org_id_in			Organization ID
 *
 *   IN/OUT:
 *   OUT:
 *
 * RETURNS:
 *	Country_code			Default Country for the Org.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *  12-MAY-2005    Rajib Ranjan Borah   o TCA SSA Uptake (Bug 3456489) Created.
 */

FUNCTION get_default_country	(
        p_org_id		IN	NUMBER
				)
RETURN	varchar2
IS
	L_Param_Rec	HZ_MO_GLOBAL_CACHE.GlobalsRecord;

BEGIN
	L_Param_Rec := get_Org_Attributes(p_org_id);
	RETURN L_Param_Rec.Default_country;
END get_default_country;

FUNCTION get_location_structure_id(
        p_org_id		IN	NUMBER
				)
RETURN	number
IS
  L_Param_Rec	HZ_MO_GLOBAL_CACHE.GlobalsRecord;
BEGIN
 L_Param_Rec := get_Org_Attributes(p_org_id);
 RETURN L_Param_Rec.Location_structure_ID;
END;
FUNCTION get_tax_method(
        p_org_id		IN	NUMBER
				)
RETURN	varchar2
IS
  L_Param_Rec	HZ_MO_GLOBAL_CACHE.GlobalsRecord;
BEGIN
 L_Param_Rec := get_Org_Attributes(p_org_id);
 RETURN L_Param_Rec.Tax_method;
END;

/**
 * FUNCTION get_chart_of_accounts_id
 *
 * DESCRIPTION
 *     	Returns the chart of accounts ID for the org.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_org_id_in			Organization ID
 *
 *   IN/OUT:
 *   OUT:
 *
 * RETURNS:
 *	Chart_of_Accounts_ID		Chart of Accounts ID for the Org.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *  12-MAY-2005    Rajib Ranjan Borah   o TCA SSA Uptake (Bug 3456489) Created.
 */

FUNCTION get_chart_of_accounts_id(
        p_org_id		IN	NUMBER
				)
RETURN	number
IS
	L_Param_Rec	HZ_MO_GLOBAL_CACHE.GlobalsRecord;

BEGIN
	L_Param_Rec := get_Org_Attributes(p_org_id);
	RETURN L_Param_Rec.chart_of_accounts_id;
END get_chart_of_accounts_id;

/**
 * FUNCTION get_set_of_books_id
 *
 * DESCRIPTION
 *     	Returns the Set of Books ID for the org.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_org_id_in			Organization ID
 *
 *   IN/OUT:
 *   OUT:
 *
 * RETURNS:
 *	Set_of_Books_ID			Set of Books ID for the Org.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *  12-MAY-2005    Rajib Ranjan Borah   o TCA SSA Uptake (Bug 3456489) Created.
 */

FUNCTION get_set_of_books_id	(
        p_org_id		IN	NUMBER
				)
RETURN	number
IS
	L_Param_Rec	HZ_MO_GLOBAL_CACHE.GlobalsRecord;

BEGIN
	L_Param_Rec := get_Org_Attributes(p_org_id);
	RETURN L_Param_Rec.set_of_books_id;
END get_set_of_books_id;

/**
 * PROCEDURE populate_non_org
 *
 * DESCRIPTION
 *     	Populates cache from AR System Parameters for non org
 *      entity related columns
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_org_id_in			Organization ID
 *
 *   IN/OUT:
 *   OUT:
 *
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *    17-APR-2006    Dhaval Mehta         o Bug 5107334 : Created
 */

 PROCEDURE populate_non_org (
     p_org_id  IN  NUMBER ) IS

     l_autocash NUMBER;
     l_grouping NUMBER;
     l_cust VARCHAR2(1);

 BEGIN
   IF p_org_id = G_Cust_Gen_Cache.default_org THEN
      RETURN;
   ELSE
      SELECT generate_customer_number,
             autocash_hierarchy_id,
	     default_grouping_rule_id
      INTO   l_cust, l_autocash, l_grouping
      FROM   AR_SYSTEM_PARAMETERS_ALL
      WHERE  org_id = p_org_id;

      G_Cust_Gen_Cache.default_org := p_org_id;
      G_Cust_Gen_Cache.generate_customer_number := l_cust;
      G_Cust_Gen_Cache.autocash_hierarchy_id := l_autocash;
      G_Cust_Gen_Cache.default_grouping_rule_id := l_grouping;
   END IF;

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR',
	'AR_NO_ROW_IN_SYSTEM_PARAMETERS');
	FND_MSG_PUB.ADD;
	RAISE;

 END populate_non_org;

/**
 * FUNCTION get_generate_customer_number
 *
 * DESCRIPTION
 *     	Returns the Customer Number Generation Setting for the org.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_org_id_in			Organization ID
 *
 *   IN/OUT:
 *   OUT:
 *
 * RETURNS:
 *	Customer_Number_Generate	Customer Number generate setting for
 *					the Org.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *    12-MAY-2005    Rajib Ranjan Borah   o TCA SSA Uptake (Bug 3456489) Created.
 *    24-MAR-2006    Dhaval Mehta         o Bug 5107334 : generate_customer_number
 *                                          is non org strip parameter. So, get
 *                                          the current org_id, if its null get
 *                                          default org_id. Query the AR
 *                                          parameter table and return the
 *                                          value. If org_id is NULL, return a
 *                                          new value 'D'. This means that we do
 *                                          not validate account_number column.
 *                                          User can enter any value if wish to.
 *                                          If no value is entered, it will be
 *                                          auto generated.
 */

FUNCTION get_generate_customer_number
RETURN	varchar2
IS
	L_org_id	Number;
	L_Value		Varchar2(1);
--
BEGIN
    BEGIN
--  Bug 5107334 : get current org_id, if NULL, get default org_id
      L_org_id := nvl(mo_global.get_current_org_id, mo_utils.get_default_org_id);
    EXCEPTION
    WHEN OTHERS
    THEN
     RAISE FND_API.G_EXC_ERROR;
    END;

	IF L_org_id IS NULL THEN
--  Bug 5107334 : Return new status 'D' if no org_id is derived
--  Don't put any warning message that can cause confustion
		RETURN 'D';
	ELSE
		IF (L_org_id = G_Cust_Gen_Cache.default_org) THEN
			RETURN G_Cust_Gen_Cache.generate_customer_number;
		ELSE
		        populate_non_org(L_org_id);
			RETURN G_Cust_Gen_Cache.generate_customer_number;
		END IF;
	END IF;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			FND_MESSAGE.SET_NAME('AR',
					'AR_NO_ROW_IN_SYSTEM_PARAMETERS');
			FND_MSG_PUB.ADD;
			RAISE;

END get_generate_customer_number;
/**
 * FUNCTION get_address_validation
 *
 * DESCRIPTION
 *     	Returns the error or warning to be issued during the failure of
 *      address validation.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *   IN/OUT:
 *   OUT:
 *
 * RETURNS:
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   24-JUN-2005    Kalyan   o TCA SSA Uptake (Bug 4454799). Created.
 */

FUNCTION get_address_validation( p_org_id IN NUMBER )
RETURN	varchar2
IS
    L_Param_Rec   HZ_MO_GLOBAL_CACHE.GlobalsRecord;
BEGIN
    L_Param_Rec := get_org_Attributes(p_org_id);
    RETURN L_Param_Rec.Address_Val;

END get_address_validation ;


/**
 * PROCEDURE validate_orgid_pub_api
 *
 * DESCRIPTION
 *     	Wrapper around MO_GLOBAL.validate_orgid_pub_api
 *      Extra functionality -
 *       IF passed ORG_ID is null
 *        + no default org_id based on profile was found by MO_GLOBAL
 *       {
 *          IF security settings allow user access to set of OUs
 *             RETURN one OU from that set and set STATUS = 'R' (random)
 *          ELSE
 *             Allow default behavior. Bubble up MO_GLOBAL raised exception
 *       }
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *              ERROR_MESG_SUPPR   IN            VARCHAR2  DEFAULT 'N'
 *   IN/OUT:
 *              ORG_ID             IN OUT NOCOPY NUMBER
 *   OUT:
 *              STATUS             OUT    NOCOPY VARCHAR2
 *
 * RETURNS:
 *
 * NOTES !!DONT USE WITHOUT DISCUSSING WITH TCA DEVELOPMENT!!
 *
 * MODIFICATION HISTORY
 *
 *   24-MAR-2006    Vivek Nama     Bug 5107334 Created
 *   30-MAR-2006    Vivek Nama     Bug 5124700 Modified query to use ar_system_parameters
 */
PROCEDURE validate_orgid_pub_api(
  ORG_ID             IN OUT NOCOPY NUMBER,
  ERROR_MESG_SUPPR   IN            VARCHAR2  DEFAULT 'N',
  STATUS             OUT    NOCOPY VARCHAR2)
IS

 l_org_id            Number;
 l_org_name          hr_operating_units.name%TYPE;

BEGIN

IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,MOD_validate_orgid_pub_api,'ENTER');
END IF;

IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FND_LOG.string(FND_LOG.LEVEL_STATEMENT,MOD_validate_orgid_pub_api,'ORG_ID='||ORG_ID);
 FND_LOG.string(FND_LOG.LEVEL_STATEMENT,MOD_validate_orgid_pub_api,'ERROR_MESG_SUPPR='||ERROR_MESG_SUPPR);
END IF;

  --call mo_global api
  MO_GLOBAL.validate_orgid_pub_api(
    ORG_ID,
    ERROR_MESG_SUPPR,
    STATUS);

IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FND_LOG.string(FND_LOG.LEVEL_STATEMENT,MOD_validate_orgid_pub_api,'successfully executed MO_GLOBAL.validate_orgid_pub_api()');
END IF;


  --process output
  --note there is similar handling in exception block of this api to handle case ERROR_MESG_SUPPR <> "N'
  IF  STATUS = 'F'
  AND ORG_ID is null THEN

    BEGIN

IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FND_LOG.string(FND_LOG.LEVEL_STATEMENT,MOD_validate_orgid_pub_api,'case: ORG_ID is null');
END IF;

      --try to pick first org that user has access to
      SELECT
       hr.organization_id,
       hr.name
      INTO
       l_org_id,
       l_org_name
      FROM
       hr_operating_units hr,
       ar_system_parameters s
      WHERE
          mo_global.check_access(hr.organization_id) = 'Y'
      AND hr.organization_id = s.org_id
      AND s.set_of_books_id > 0
      AND rownum < 2;

IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FND_LOG.string(FND_LOG.LEVEL_STATEMENT,MOD_validate_orgid_pub_api,'l_org_id='||l_org_id);
 FND_LOG.string(FND_LOG.LEVEL_STATEMENT,MOD_validate_orgid_pub_api,'l_org_name='||l_org_name);
END IF;

      IF l_org_id is not null THEN
        ORG_ID := l_org_id;
        STATUS := 'R';
      END IF;

    EXCEPTION
    WHEN no_data_found THEN

IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FND_LOG.string(FND_LOG.LEVEL_STATEMENT,MOD_validate_orgid_pub_api,'caught exception no_data_found in sql=SELECT hr.organization_id,hr.name FROM hr_operating_units hr WHERE mo_global.check_access(hr.organization_id) = "Y" AND rownum < 2');
END IF;

      --if an org is still not available let default behavior persist

    END;

  END IF;



IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FND_LOG.string(FND_LOG.LEVEL_STATEMENT,MOD_validate_orgid_pub_api,'ORG_ID='||ORG_ID);
 FND_LOG.string(FND_LOG.LEVEL_STATEMENT,MOD_validate_orgid_pub_api,'STATUS='||STATUS);
END IF;

IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,MOD_validate_orgid_pub_api,'EXIT');
END IF;

  RETURN;


EXCEPTION

WHEN others THEN

IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FND_LOG.string(FND_LOG.LEVEL_STATEMENT,MOD_validate_orgid_pub_api,'caught exception in MO_GLOBAL.validate_orgid_pub_api()');
END IF;

  --note there is similar handling in main block of this api to handle case ERROR_MESG_SUPPR = "N'
  IF ORG_ID is null THEN
    BEGIN

IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FND_LOG.string(FND_LOG.LEVEL_STATEMENT,MOD_validate_orgid_pub_api,'case: ORG_ID is null');
END IF;

     --try to pick first org that user has access to
      SELECT
       hr.organization_id,
       hr.name
      INTO
       l_org_id,
       l_org_name
      FROM
       hr_operating_units hr,
       ar_system_parameters s
      WHERE
          mo_global.check_access(hr.organization_id) = 'Y'
      AND hr.organization_id = s.org_id
      AND s.set_of_books_id > 0
      AND rownum < 2;

IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FND_LOG.string(FND_LOG.LEVEL_STATEMENT,MOD_validate_orgid_pub_api,'l_org_id='||l_org_id);
 FND_LOG.string(FND_LOG.LEVEL_STATEMENT,MOD_validate_orgid_pub_api,'l_org_name='||l_org_name);
END IF;

      IF l_org_id is null THEN

IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,MOD_validate_orgid_pub_api,'ERROR: raising APP_EXCEPTION.RAISE_EXCEPTION');
END IF;

        APP_EXCEPTION.RAISE_EXCEPTION;

      ELSE

        ORG_ID := l_org_id;
        STATUS := 'R';

IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FND_LOG.string(FND_LOG.LEVEL_STATEMENT,MOD_validate_orgid_pub_api,'ORG_ID='||ORG_ID);
 FND_LOG.string(FND_LOG.LEVEL_STATEMENT,MOD_validate_orgid_pub_api,'STATUS='||STATUS);
END IF;

IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,MOD_validate_orgid_pub_api,'EXIT');
END IF;

        RETURN;

      END IF;

    EXCEPTION
    WHEN no_data_found THEN

IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FND_LOG.string(FND_LOG.LEVEL_STATEMENT,MOD_validate_orgid_pub_api,'caught exception no_data_found in sql=SELECT hr.organization_id,hr.name FROM hr_operating_units hr WHERE mo_global.check_access(hr.organization_id) = "Y" AND rownum < 2');
END IF;

IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,MOD_validate_orgid_pub_api,'ERROR: raising APP_EXCEPTION.RAISE_EXCEPTION');
END IF;

      --if an org is still not available let default behavior persist
      APP_EXCEPTION.RAISE_EXCEPTION;
    END;

  ELSE
  --IF ORG_ID is not null
  --let default behavior persist


IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FND_LOG.string(FND_LOG.LEVEL_STATEMENT,MOD_validate_orgid_pub_api,'case: ORG_ID is not null');
END IF;

IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,MOD_validate_orgid_pub_api,'ERROR: raising APP_EXCEPTION.RAISE_EXCEPTION');
END IF;

    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;

END validate_orgid_pub_api;


/**
 * FUNCTION get_create_reciprocal_flag
 *
 * DESCRIPTION
 *     	Returns the Reciprocal Flag setting for the org
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_org_id_in			Organization ID
 *
 *   IN/OUT:
 *   OUT:
 *
 * RETURNS:
 *	Create Reciprocal Flag setting for the org
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *  13-MAR-2006    Dhaval Mehta    Bug 5002547 : Added
 */

FUNCTION get_create_reciprocal_flag (
        p_org_id		IN	NUMBER
				)
RETURN varchar2
IS
	L_Param_Rec	HZ_MO_GLOBAL_CACHE.GlobalsRecord;

BEGIN
	L_Param_Rec := get_Org_Attributes(p_org_id);
	RETURN L_Param_Rec.reciprocal_flag;
END get_create_reciprocal_flag;


/**
 * FUNCTION get_autocash_hierarchy_id
 *
 * DESCRIPTION
 *     	Returns the the Autocash Rule setting for the org
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *   IN/OUT:
 *   OUT:
 *
 * RETURNS:
 *	autocash_hierarchy_id	Autocash Hierarchy ID setting
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *    13-MAR-2006    Dhaval Mehta    Bug 5002547 : Added
 */

FUNCTION get_autocash_hierarchy_id
RETURN Number
IS
	L_org_id	Number;
	L_Value		Number;
        l_return_status VARCHAR2(2000);
--
BEGIN
    BEGIN
      L_org_id := nvl(mo_global.get_current_org_id, mo_utils.get_default_org_id);
    EXCEPTION
    WHEN OTHERS
    THEN
      NULL;
    END;

	IF L_org_id IS NULL THEN
		RETURN NULL;
	ELSE
		IF (L_org_id = G_Cust_Gen_Cache.default_org) THEN
			RETURN G_Cust_Gen_Cache.autocash_hierarchy_id;
		ELSE
		        populate_non_org(L_org_id);
			RETURN G_Cust_Gen_Cache.autocash_hierarchy_id;
		END IF;
	END IF;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			FND_MESSAGE.SET_NAME('AR',
					'AR_NO_ROW_IN_SYSTEM_PARAMETERS');
			FND_MSG_PUB.ADD;
			RAISE;

END get_autocash_hierarchy_id;
/**
 * FUNCTION get_default_grouping_rule_id
 *
 * DESCRIPTION
 *     	Returns the Default Group Rule setting for the org
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *   IN/OUT:
 *   OUT:
 *
 * RETURNS:
 *	default_grouping_rule_id	Default Grouping Rule ID setting
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *    13-MAR-2006    Dhaval Mehta    Bug 5002547 : Added
 */

FUNCTION get_default_grouping_rule_id
RETURN NUMBER
IS
	L_org_id	Number;
	L_Value		Number;
        l_return_status VARCHAR2(2000);
--
BEGIN
    BEGIN
      L_org_id := nvl(mo_global.get_current_org_id, mo_utils.get_default_org_id);
    EXCEPTION
    WHEN OTHERS
    THEN
     NULL;
    END;

	IF L_org_id IS NULL THEN
		RETURN NULL;
	ELSE
		IF (L_org_id = G_Cust_Gen_Cache.default_org) THEN
			RETURN G_Cust_Gen_Cache.default_grouping_rule_id;
		ELSE
		        populate_non_org(L_org_id);
			RETURN G_Cust_Gen_Cache.default_grouping_rule_id;
		END IF;
	END IF;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			FND_MESSAGE.SET_NAME('AR',
					'AR_NO_ROW_IN_SYSTEM_PARAMETERS');
			FND_MSG_PUB.ADD;
			RAISE;

END get_default_grouping_rule_id;

END HZ_MO_GLOBAL_CACHE;


/
