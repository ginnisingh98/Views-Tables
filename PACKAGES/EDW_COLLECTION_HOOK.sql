--------------------------------------------------------
--  DDL for Package EDW_COLLECTION_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_COLLECTION_HOOK" AUTHID CURRENT_USER AS
/*$Header: EDWPCOLS.pls 115.9 2002/12/05 21:24:18 vsurendr ship $*/

function pre_dimension_coll(p_object_name varchar2) return boolean;
function post_dimension_coll(p_object_name varchar2) return boolean;
function pre_fact_coll(p_object_name varchar2) return boolean;
function post_fact_coll(p_object_name varchar2) return boolean;
function pre_mapping_coll(p_object_name varchar2) return boolean;
function post_mapping_coll(p_object_name varchar2) return boolean;

/***********************************************************
The procedures below are used only for work flow right now...
************************************************************/
function pre_coll(p_object_name varchar2)  return boolean;
function post_coll(p_object_name varchar2)  return boolean;
/**************************************************************/
function pre_derived_fact_coll(p_object_name varchar2) return boolean;
function post_derived_fact_coll(p_object_name varchar2) return boolean;

END EDW_COLLECTION_HOOK;

 

/
