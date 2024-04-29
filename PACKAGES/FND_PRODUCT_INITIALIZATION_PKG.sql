--------------------------------------------------------
--  DDL for Package FND_PRODUCT_INITIALIZATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_PRODUCT_INITIALIZATION_PKG" AUTHID CURRENT_USER as
/* $Header: AFPINITS.pls 120.8 2006/09/28 19:09:06 rsheh ship $ */
/*#
* Table Handler to insert or update data in FND_PRODUCT_INITIALIZATION table.
* @rep:scope public
* @rep:product FND
* @rep:displayname Product Initialization
* @rep:lifecycle active
* @rep:compatibility S
* @rep:category BUSINESS_ENTITY FND_PRODUCT_INITIALIZATION
* @rep:ihelp FND/@o_funcsec#o_funcsec See the related online help
*/



init_conditions varchar2(80) := '';
type TextArrayTyp is table of varchar2(80) index by binary_integer;
ExecInitSuccess number := 1;
ExecInitFailure number := 0;

--
-- Register (PUBLIC)
--   Called by product team to register their re-initialization function
--   and invoking sequence
-- Input
--   x_apps_name: application short name
--   x_invoke_seq: invoking sequence
--   x_init_function: re-initialization function
procedure Register(x_apps_name 	        in varchar2,
                   x_init_function      in varchar2 default null,
                   x_owner              in varchar2 default 'SEED');
--
-- Remove (PUBLIC)
--   Called by product team to delete their re-initialization function
-- Input
--   x_apps_name: application short name
--   x_init_function: re-initialization function
procedure Remove(x_apps_name 	 in varchar2);

-- AddInitCondition (PUBLIC)
--   Called by anybody who wants to register their product's re-initialization
--   conditions.
--
-- Input
--   x_apps_name:  the application short name
--   x_condition:  one of the following conditions:
--                 'APPL', 'RESP', 'USER', 'NLS', 'ORG'
--
procedure AddInitCondition(x_apps_name in varchar2,
                           x_condition in varchar2,
                           x_owner     in varchar2);

-- RemoveInitCondition (PUBLIC)
--   Called by anybody who wants to remove their product's re-initialization
--   conditions.
--
-- Input
--   x_apps_name:  the application short name
--   x_condition:  one of the following conditions:
--                 'APPL', 'RESP', 'USER', 'NLS', 'ORG'
--
procedure RemoveInitCondition(x_apps_name in varchar2,
                              x_condition in varchar2);

--
-- AddDependency (PUBLIC)
--   Called by anybody who wants to register their product dependency
--
-- Input
--   x_apps_name:  the application short name
--   x_dependency: the dependency application short name
--
procedure AddDependency(x_apps_name   in varchar2,
                        x_dependency  in varchar2,
                        x_owner       in varchar2);

--
-- RemoveDependency (PUBLIC)
--   Called by anybody who wants to remove their product dependency
--
-- Input
--   x_apps_name:  the application short name
--   x_dependency: the dependency application short name
--
procedure RemoveDependency(x_apps_name   in varchar2,
                           x_dependency  in varchar2);

--
-- ExecInitFunction (PUBLIC)
--   Called by fnd_global.initialize() which decides the current application
--   short name and the conditions occurred.
--
-- Input
--   x_apps_name:  the application short name
--   x_conditions: it is assumed in the format of ('APPL', 'USER')
--
-- Note:
--   WE HAVE TO HAVE GOOD ERROR HANDLING HERE BECAUSE IT IS CALLED BY
--   BY GLOBAL.INITIALIZE()
procedure ExecInitFunction(x_apps_name in varchar2,
                           x_conditions in varchar2);


procedure Test(x_apps_name in varchar2);

--
-- Register (PUBLIC) - Overloaded
--   Called by product team to register their re-initialization function
--   and invoking sequence
-- Input
--   x_apps_name: application short name
--   x_invoke_seq: invoking sequence
--   x_init_function: re-initialization function
procedure Register(x_apps_name          in varchar2,
                   x_init_function      in varchar2 default null,
                   x_owner              in varchar2 default 'SEED',
		   x_last_update_date   in varchar2,
                   x_custom_mode        in varchar2);
--
--
--
-- AddDependency (PUBLIC) - Overloaded
--   Called by anybody who wants to register their product dependency
--
-- Input
--   x_apps_name:  the application short name
--   x_dependency: the dependency application short name
--
procedure AddDependency(x_apps_name   in varchar2,
                        x_dependency  in varchar2,
                        x_owner       in varchar2,
                        x_last_update_date   in varchar2,
                        x_custom_mode        in varchar2);

-- AddInitCondition (PUBLIC) - Overloaded
--   Called by anybody who wants to register their product's re-initialization
--   conditions.
--
-- Input
--   x_apps_name:  the application short name
--   x_condition:  one of the following conditions:
--                 'APPL', 'RESP', 'USER', 'NLS', 'ORG'
--
procedure AddInitCondition(x_apps_name in varchar2,
                           x_condition in varchar2,
                           x_owner     in varchar2,
                           x_last_update_date   in varchar2,
                           x_custom_mode        in varchar2);

-- DiscoInit (PUBLIC)
--   Called by Disco trigger to run all product initialization code inside
--   fnd_product_initialization table with all true conditions.
--
-- Input
--   no input argument
--
-- Output
--  ExecInitSuccess or ExecInitFailure
/*#
 * This is called by Discoverer to run all left over product initialization
 * inside fnd_product_initialization table with all true conditions.
 * Please note that even this is public procedure, it does not mean for
 * other public usage. This is mainly for Discoverer to use.
 * @return success(1) or failure(0)
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Discoverer Initialization
 * @rep:compatibility S
 * @rep:ihelp FND/@mesgdict#mesgdict See the related online help
 */

function DiscoInit return number;

-- RemoveAll (PUBLIC)
--   Called by anybody who wants to remove all their product initialization
--   data.
--
-- Input
--   x_apps_short_name:  the application short name
--
procedure RemoveAll(apps_short_name in varchar2);


end Fnd_Product_Initialization_Pkg;

/
