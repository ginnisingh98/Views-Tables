--------------------------------------------------------
--  DDL for Package FND_ADG_OBJECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_ADG_OBJECT" AUTHID CURRENT_USER as
/* $Header: AFDGOBJS.pls 120.0.12010000.2 2010/09/17 16:31:18 rsanders noship $ */

/*      fnd_adg_object
        ==============

        This package is part of Active Data Guard [ADG ] support.

        It is for INTERNAL use only and is NEVER referenced outside of
        FND_ADG packages. It should never be called by product developers.

        Documentation is intended only for developers maintaining this package.
*/

/*	Constants

	Used to avoid direct dependencies during compilation.
*/

   C_ADG_MANAGE_PACKAGE     constant  varchar2(30) := 'FND_ADG_MANAGE';
   C_ADG_MANAGE_NAME_REMOTE constant  varchar2(30) := 'FND_ADG_MANAGE_REMOTE';

/*	build_all_packages
	==================

	Build all RPC packages.
*/

   procedure build_all_packages;

/*	build_package
	=============

	Build specified package.
*/

   procedure build_package  (p_owner varchar2 default user,
                             p_package_name varchar2,
                             p_build_spec boolean default true,
                             p_build_body boolean default true);

/*	init_package_list
	=================

	Used by clone cleanup to initialise the RPC package list.
*/

   procedure init_package_list;

/*	compile_all_packages
	====================

	Compile all packages.
*/

   procedure compile_all_packages;

/*	compile_package
	===============

	Compile specified package.
*/

   procedure compile_package(p_owner varchar2 default user,
                             p_package_name varchar2,
                             p_compile_spec boolean default true,
                             p_compile_body boolean default true);

/*	compile_directive
	=================

	Enable or disable compile directive.
*/

   procedure compile_directive(p_enable boolean default null);

/*	build_all_synonyms
	==================

	Build all RPC synonyms.
*/

   procedure build_all_synonyms;

/*	build_synonym
	=============

	Build specified synonym.
*/

   procedure build_synonym(p_owner varchar2 default user,
                           p_package_name varchar2);


/*	compile_rpc_dependents
	======================
*/

   procedure compile_rpc_dependents;

/*	validate_package_usage
	======================

	Validates that the RPC packages are defined and set up.
	If p_use_rpc_dependency is true then the RPC packages
	must be in the dependency list, otherwise use compile
	directive.
*/

   procedure validate_package_usage(p_use_rpc_dependency boolean);

end fnd_adg_object;

/
