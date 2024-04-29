--------------------------------------------------------
--  DDL for Package HZ_MO_GLOBAL_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_MO_GLOBAL_CACHE" AUTHID CURRENT_USER as
/*$Header: ARHMOGCS.pls 120.6 2006/04/17 22:54:24 dmmehta noship $ */

----------------------------------------
-- declaration of tables.
----------------------------------------

TYPE OrgIDTable IS TABLE OF hr_organization_information.organization_id%TYPE;
TYPE AutoSiteNumberingTable IS TABLE OF
	ar_system_parameters_all.auto_site_numbering%TYPE;
TYPE DefaultCountryTable IS TABLE OF
	ar_system_parameters_all.default_country%TYPE;
TYPE SetOfBooksIDTable is TABLE OF gl_sets_of_books.set_of_books_id%TYPE;
TYPE ChartOfAccountsIDTable IS TABLE OF
	gl_sets_of_books.chart_of_accounts_id%TYPE;
TYPE LocationStructureIDTable is TABLE OF ar_system_parameters_all.location_structure_id%TYPE;
TYPE TaxMethodTable is TABLE OF ar_system_parameters_all.tax_method%TYPE;
TYPE AddressValTable is TABLE OF ar_system_parameters_all.address_validation%TYPE;
--  Bug 5002547 : Added for Reciprocal Flag field
TYPE ReciprocalFlagTable is TABLE OF
ar_system_parameters_all.create_reciprocal_flag%TYPE;
----------------------------------------
-- declaration of global record types.
----------------------------------------

TYPE GlobalsRecord IS RECORD (
	Auto_site_numbering   AR_SYSTEM_PARAMETERS_ALL.AUTO_SITE_NUMBERING%TYPE,
	Default_country	      AR_SYSTEM_PARAMETERS_ALL.DEFAULT_COUNTRY%TYPE,
	Chart_of_accounts_ID  GL_SETS_OF_BOOKS.CHART_OF_ACCOUNTS_ID%TYPE,
	Set_of_books_ID	      GL_SETS_OF_BOOKS.SET_OF_BOOKS_ID%TYPE,
	Location_structure_ID AR_SYSTEM_PARAMETERS_ALL.LOCATION_STRUCTURE_ID%TYPE,
	Tax_method            AR_SYSTEM_PARAMETERS_ALL.TAX_METHOD%TYPE,
	Address_val           AR_SYSTEM_PARAMETERS_ALL.ADDRESS_VALIDATION%TYPE,
        Reciprocal_flag       AR_SYSTEM_PARAMETERS_ALL.CREATE_RECIPROCAL_FLAG%TYPE
			     );

TYPE GlobalsTable is RECORD  (
	org_id_t		OrgIDTable,
	auto_site_numbering_t	AutoSiteNumberingTable,
	default_country_t	DefaultCountryTable,
	chart_of_accounts_id_t	ChartOfAccountsIDTable,
	set_of_books_id_t	SetOfBooksIDTable,
	location_structure_id_t LocationStructureIDTable,
	tax_method_t            TaxMethodTable,
	address_val_t           AddressValTable,
        reciprocal_flag_t       ReciprocalFlagTable
			     );

TYPE cust_num_gen_rec IS RECORD (
	Default_Org AR_SYSTEM_PARAMETERS_ALL.ORG_ID%TYPE,
	Generate_customer_number
		AR_SYSTEM_PARAMETERS_ALL.generate_customer_number%TYPE,
--  Bug 5002547 : Added for Grouping Rule, Autocash Rule Set field
        Default_grouping_rule_ID
                AR_SYSTEM_PARAMETERS_ALL.default_grouping_rule_id%TYPE,
        Autocash_hierarchy_ID AR_SYSTEM_PARAMETERS_ALL.autocash_hierarchy_id%TYPE
				);

--------------------------------------
-- declaration of public procedures and functions
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
 *   12-MAY-2005    Rajib Ranjan Borah   o TCA SSA Uptake (Bug 3456489). Created.
 *
 */

PROCEDURE retrieve_globals(
        p_globals	OUT	NOCOPY	GlobalsTable
);
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
 *   12-MAY-2005    Rajib Ranjan Borah   o TCA SSA Uptake (Bug 3456489). Created.
 */

FUNCTION get_org_attributes	(
        p_org_id		IN	NUMBER
				)
RETURN	hz_mo_global_cache.GlobalsRecord;

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
 *   12-MAY-2005    Rajib Ranjan Borah   o TCA SSA Uptake (Bug 3456489). Created.
 */

FUNCTION get_auto_site_numbering(
        p_org_id		IN	NUMBER
				)
RETURN	varchar2;

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
 *   12-MAY-2005    Rajib Ranjan Borah   o TCA SSA Uptake (Bug 3456489). Created.
 */

FUNCTION get_default_country	(
        p_org_id		IN	NUMBER
				)
RETURN	varchar2;

/**
 * FUNCTION get_location_structure_id
 *
 * DESCRIPTION
 *     	Returns the location structure for the org.
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
 *	Location_structure_id		Location structure for the org.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   14-JUN-2005    Ramesh Ch     o Customer Merge SSA Uptake   Created.
 */

FUNCTION get_location_structure_id(
        p_org_id		IN	NUMBER
				)
RETURN	number;

/**
 * FUNCTION get_tax_method
 *
 * DESCRIPTION
 *     	Returns the tax method for the org.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_org_id_in		Organization ID
 *
 *   IN/OUT:
 *   OUT:
 *
 * RETURNS:
 *	Tax_method		Tax method for the org.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   14-JUN-2005    Ramesh Ch     o Customer Merge SSA Uptake   Created.
 */

FUNCTION get_tax_method(
        p_org_id		IN	NUMBER
				)
RETURN	varchar2;

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
 *   12-MAY-2005    Rajib Ranjan Borah   o TCA SSA Uptake (Bug 3456489). Created.
 */

FUNCTION get_chart_of_accounts_id(
        p_org_id		IN	NUMBER
				)
RETURN	number;

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
 *   12-MAY-2005    Rajib Ranjan Borah   o TCA SSA Uptake (Bug 3456489). Created.
 */

FUNCTION get_set_of_books_id	(
        p_org_id		IN	NUMBER
				)
RETURN	number;

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
 *   12-MAY-2005    Rajib Ranjan Borah   o TCA SSA Uptake (Bug 3456489). Created.
 */

FUNCTION get_generate_customer_number
RETURN	varchar2;


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
RETURN	varchar2;


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
 */
PROCEDURE validate_orgid_pub_api(
  ORG_ID             IN OUT NOCOPY NUMBER,
  ERROR_MESG_SUPPR   IN            VARCHAR2  DEFAULT 'N',
  STATUS             OUT    NOCOPY VARCHAR2);

/**
 * FUNCTION get_create_reciprocal_flag
 *
 * DESCRIPTION
 *      Returns the Reciprocal Flag setting for the org
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *   IN/OUT:
 *   OUT:
 *
 * RETURNS:
 *      Create Reciprocal Flag setting for the org
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   03-APR-2006    Dhaval Mehta    Bug 5002547 : Added
 *
 **/

FUNCTION get_create_reciprocal_flag(
         p_org_id IN NUMBER)
RETURN varchar2;


/**
 * FUNCTION get_autocash_hierarchy_id
 *
 * DESCRIPTION
 *      Returns the Autocash Rule setting for the org
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *   IN/OUT:
 *   OUT:
 *
 * RETURNS:
 *      Autocash Hierarchy ID setting for the org
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   03-APR-2006    Dhaval Mehta    Bug 5002547 : Added
 *
 **/

FUNCTION get_autocash_hierarchy_id
RETURN NUMBER;


/**
 * FUNCTION get_default_grouping_rule_id
 *
 * DESCRIPTION
 *      Returns the Default Group Rule setting for the org
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *   IN/OUT:
 *   OUT:
 *
 * RETURNS:
 *      Default Grouping Rule ID setting for the org
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   03-APR-2006    Dhaval Mehta    Bug 5002547 : Added
 *
 **/

FUNCTION get_default_grouping_rule_id
RETURN NUMBER;

END HZ_MO_GLOBAL_CACHE;


 

/
