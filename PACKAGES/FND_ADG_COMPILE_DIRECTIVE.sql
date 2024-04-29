--------------------------------------------------------
--  DDL for Package FND_ADG_COMPILE_DIRECTIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_ADG_COMPILE_DIRECTIVE" AUTHID CURRENT_USER as
/* $Header: AFDGCPDS.pls 120.0.12010000.2 2010/09/17 09:54:04 rsanders noship $ */

/*	fnd_adg_compile_directive
	=========================

	This package is part of Active Data Guard [ADG ] support.

	ADG support requires RPC calls from within standard FND
	packages. These RPC calls are handled by dynamically
	generated packages which in turn depend on database links.

	To avoid both RPC and link dependencies in the shipped code, all
	RPC references are controlled by the following PL/SQL
	compile directive.

          $if fnd_adg_compile_directive.enable_rpc
          $then
                <RPC>
          $else
                 null;
          $end

	The default setting for enable_rpc is false. It is changed to true
	automatically when RPC support is enabled. This source file
	never changes - this ensures ADPATCH never tries to update the spec.
	and turn off RPC support!

	The directive is checked against the current internal RPC state.
	If they get out of sync - e.g. by manually compiling
	this package after RPC support has been enabled - RPC support will
	no longer be enabled.

	You can call fnd_adg_utility.resync_compile_directive to bring the
	compile directive into line with the internal RPC state. The procedure
	is a no-op unless the directive is out of sync.

*/

enable_rpc 		constant 	boolean	:= false;

end fnd_adg_compile_directive;

/
