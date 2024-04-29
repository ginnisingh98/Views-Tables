--------------------------------------------------------
--  DDL for Package CSL_HZ_PARTY_SITES_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_HZ_PARTY_SITES_ACC_PKG" AUTHID CURRENT_USER AS
/* $Header: cslpsacs.pls 115.3 2002/08/21 08:27:30 rrademak ship $ */

PROCEDURE INSERT_PARTY_SITE( p_party_site_id IN NUMBER
                           , p_resource_id IN NUMBER );

PROCEDURE UPDATE_PARTY_SITE( p_party_site_id IN NUMBER );

PROCEDURE DELETE_PARTY_SITE( p_party_site_id IN NUMBER
                           , p_resource_id IN NUMBER );

PROCEDURE CHANGE_PARTY_SITE( p_old_party_site_id IN NUMBER
                           , p_new_party_site_id IN NUMBER
		           , p_resource_id IN NUMBER );

END CSL_HZ_PARTY_SITES_ACC_PKG;

 

/
