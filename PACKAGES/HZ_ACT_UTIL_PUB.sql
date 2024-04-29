--------------------------------------------------------
--  DDL for Package HZ_ACT_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_ACT_UTIL_PUB" AUTHID CURRENT_USER AS
/* $Header: ARHACUIS.pls 120.0 2003/05/30 21:24:32 jypandey noship $ */

function get_active_act_site_use (
    p_act_site_id                         IN     NUMBER)
RETURN VARCHAR2;

function get_all_act_site_use (
    p_act_site_id                         IN     NUMBER)
RETURN VARCHAR2;

function get_location_id (
    p_act_site_id                         IN     NUMBER)
RETURN NUMBER;

function get_act_contact_roles(
    p_cust_account_role_id                   IN     NUMBER) RETURN VARCHAR2;

END HZ_ACT_UTIL_PUB;

 

/
