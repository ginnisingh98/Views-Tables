--------------------------------------------------------
--  DDL for Package BISM_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BISM_UTILS" AUTHID CURRENT_USER AS
/* $Header: bibutils.pls 120.2 2006/04/03 05:24:36 akbansal noship $ */
function get_guid return raw;
function get_database_user return varchar2;
function get_current_user_id return raw;
function init_user(user varchar2) return raw;
function get_object_ids_and_time(num number,current_time out nocopy date) return bism_object_ids;
function get_object_ids_and_time_30(num number,current_time out nocopy date) return RAW;
function get_time_in_hundredth_sec return varchar2;
END bism_utils ;

 

/
