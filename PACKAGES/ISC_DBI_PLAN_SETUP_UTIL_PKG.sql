--------------------------------------------------------
--  DDL for Package ISC_DBI_PLAN_SETUP_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DBI_PLAN_SETUP_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: ISCPSFUS.pls 115.1 2003/07/02 01:54:00 scheung ship $ */

function  is_plan_name_exists		(p_plan_name		in	varchar2) return varchar2;

function  get_next_collection_date	(p_frequency		in	varchar2,
					 p_days_offset		in	number,
					 p_reference_date	in	date) return date;

function  get_next_collection_date	(p_frequency		in	varchar2,
					 p_days_offset		in	number) return date;

function  get_next_collection_date	(p_plan_name		in	varchar2) return date;


END ISC_DBI_PLAN_SETUP_UTIL_PKG;

 

/
