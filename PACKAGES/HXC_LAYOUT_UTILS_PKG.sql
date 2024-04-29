--------------------------------------------------------
--  DDL for Package HXC_LAYOUT_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_LAYOUT_UTILS_PKG" AUTHID CURRENT_USER as
/* $Header: hxclayoututl.pkh 120.0 2005/05/29 06:19:07 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= ' hxc_layout_utils_pkg.';  -- Global package name

TYPE components_rec IS RECORD (  bld_blk_info_type hxc_bld_blk_info_types.bld_blk_info_type%TYPE,
                                 segment           hxc_mapping_components.segment%type );

TYPE components_tab IS TABLE OF components_rec INDEX BY BINARY_INTEGER;

FUNCTION get_updatable_components RETURN components_tab;

PROCEDURE reset_non_updatable_comps ( p_attributes IN OUT NOCOPY hxc_self_service_time_deposit.app_attributes_info );

end hxc_layout_utils_pkg;

 

/
