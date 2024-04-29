--------------------------------------------------------
--  DDL for Package ZPB_METADATA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_METADATA_PKG" AUTHID CURRENT_USER as
/* $Header: ZPBMDPKS.pls 120.0.12010.4 2006/08/03 11:59:25 appldev noship $ */

-------------------------------------------------------------------------------
-- BUILD_DIMS - Exposes metadata for dimensions and objects associated with them
-- 				hierarchies, attributes, levels
--
-- IN: p_aw       - The AW to build
--     p_sharedAW - The shared AW (may be the same as p_aw)
--     p_type     - The AW type (PERSONAL or SHARED)
--     p_dims     - Space separated list of dim ID's
-------------------------------------------------------------------------------
procedure BUILD_DIMS(p_aw       in            varchar2,
                     p_sharedAW in            varchar2,
                     p_type     in            varchar2,
                     p_dims     in            varchar2);

-------------------------------------------------------------------------------
-- BUILD_INSTANCE - Expose metadata for all measures of an instance by calling
--				   	BUILD_MEASURE.  If it has not been done yet, call
--					BUILD_CUBE to expose metadat for the containing cube
--
-- IN: p_aw       - The AW
--     p_instance - The ID of the instance
--     p_type     - The type of the instance (PERSONAL, SHARED_VIEW, etc)
--     p_approver - The approvee ID.  Null is not applicable
--
-------------------------------------------------------------------------------
procedure BUILD_INSTANCE(p_aw       in            varchar2,
                         p_instance in            varchar2,
                         p_type     in            varchar2,
                         p_template in            varchar2 default null,
                         p_approvee in            varchar2 default null);

-------------------------------------------------------------------------------
-- BUILD_MEASURE - Builds a metadata map for a measure
--
-- IN: p_aw   - The AW containing the Calc
--     p_meas - The ID of the calc measure
-------------------------------------------------------------------------------
procedure BUILD_MEASURE(p_aw       in            varchar2,
                        p_instance in            varchar2,
                        p_meas     in            varchar2,
                        p_cube     in            varchar2,
                        p_column   in            varchar2,
                        p_template in            varchar2 default null,
                        p_approvee in            varchar2 default null,
					    p_currencyRel in         varchar2 default null);

-------------------------------------------------------------------------------
-- BUILD - Builds the Metadata Map, which is a map used by the
--         Java tier to boostrap OLAPI.
--
-- IN: p_aw     - The AW
--     p_sharedAW - The name of the shared AW.  May be the same as p_aw.
--     p_type   - The type, either PERSONAL or SHARED
--     p_doMeas - Update the measures as well, values are 'Y' or 'N'
-------------------------------------------------------------------------------
procedure BUILD(p_aw       in varchar2,
                p_sharedAW in varchar2,
                p_type     in varchar2,
                p_doMeas   in varchar2,
				p_onlySec  in varchar2 default 'N');

-------------------------------------------------------------------------------
-- BUILD_EXCEPTION_INST - Returns the instance_id for the "fake" excpetion
--                        instance.  The cube and measure information for
--						  this fake instance is never committed to DB but
--						  used only in the session in which its created.
--
-- IN: p_sharedAw - The shared AW
--     p_persAw   - The personal AW
--     p_instance - The ID of the instance
--     p_name     - The name of the measures to be created
-------------------------------------------------------------------------------
procedure BUILD_EXCEPTION_INST(p_sharedAw in            varchar2,
                              p_persAw   in            varchar2,
                              p_instance in            varchar2,
                              p_name     in            varchar2,
							  p_user_id  in            varchar2,
							  p_bus_area_id in         varchar2,
							  p_fake_flag in           boolean default true,
						      p_start_up_flag in       boolean default false);

-------------------------------------------------------------------------------
-- BUILD_OWNERMAP_MEASURE - Exposes MD for containing cube and ownermap measure
--
-- IN: p_aw   - The AW of the ownermap measure
--     p_dims - The dimensions of the ownermap measure
-------------------------------------------------------------------------------
procedure BUILD_OWNERMAP_MEASURE(p_aw       in            varchar2,
                                 p_dims     in            varchar2);

-------------------------------------------------------------------------------
-- BUILD_CUBE -Exposes metadata for a cube (zpb_cubes), its dimensionality
--				(zpb_cube_dims) and its hierarchies (zpb_cube_hier)
--
-- IN: p_aw       - The AW
--     p_cubeView - The name of the cube
--	   p_dims	  - Dimensionality of cube
--
-------------------------------------------------------------------------------
procedure BUILD_CUBE(p_aw       	in      varchar2,
                     p_cubeView 	in      varchar2,
                     p_dims     	in      varchar2,
		     		 p_cube_type 	in		varchar2 default 'STANDARD');


-------------------------------------------------------------------------------
-- REMOVE_INSTANCE - Removes the metadata for a given instance
--
-- IN: p_aw       - The AW to build on
--     p_instance - The ID of the instance
--     p_type     - The type of the instance (PERSONAL, SHARED_VOEW, etc)
--     p_template - The template ID. Null is not applicable
--     p_approvee - The approvee ID. Null is not applicable
-------------------------------------------------------------------------------
procedure REMOVE_INSTANCE(p_aw       in            varchar2,
                          p_instance in            varchar2,
                          p_type     in            varchar2,
                          p_template in            varchar2,
                          p_approvee in            varchar2);

-------------------------------------------------------------------------------
--  delete_user - 	   Procedure deletes all personal "personal" cubes and the
-- 					   contained measures for the specified user
-------------------------------------------------------------------------------
procedure delete_user(p_user varchar2);

-------------------------------------------------------------------------------
-- BUILD_PERSONAL_DIMS - Updates user's personal scoping for hierarchies, levels,
--						 and attributes.  Updates user's personal levels.
--
-- IN: p_aw       - The AW to build
--     p_sharedAW - The shared AW (may be the same as p_aw)
--     p_type     - The AW type (PERSONAL or SHARED)
--     p_dims     - Space separated list of dim ID's
-------------------------------------------------------------------------------
procedure BUILD_PERSONAL_DIMS(p_aw       	 in   varchar2,
                     		  p_sharedAw 	 in   varchar2,
                     		  p_type     	 in   varchar2,
                     		  p_dims     	 in   varchar2);

-------------------------------------------------------------------------------
--  cleanOutBusinessArea - Procedure that deletes all md records for a
--                         particular business area.  Done before a universe
--                                              refresh.
-------------------------------------------------------------------------------
procedure cleanBusArea(p_bus_area_id in number);

-------------------------------------------------------------------------------
--  delete_shared_cubes - 	   Procedure deletes all shared and shared "personal" cubes and the
-- 					           contained measures for the specified business area
-------------------------------------------------------------------------------
procedure delete_shared_cubes(p_sharaw in varchar2);

end ZPB_METADATA_PKG;

 

/
