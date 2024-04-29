--------------------------------------------------------
--  DDL for Package MST_CM_DETAILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MST_CM_DETAILS" AUTHID CURRENT_USER AS
/*$Header: MSTCMDLS.pls 115.1 2003/07/30 18:30:22 jnhuang noship $ */

function get_number_of_loads(
arg_plan_id IN number,
arg_continuous_move_id IN number
) return number;

function get_distance(
arg_plan_id IN number,
arg_continuous_move_id IN number
) return number;

function get_savings(
arg_plan_id IN number,
arg_continuous_move_id IN number,
arg_total_cm_trip_cost IN number
) return number;


function get_number_of_stops(
arg_plan_id IN number,
arg_trip_id IN number
) return number;

function get_total_savings(
arg_plan_id IN number
) return number;

function get_number_of_exceptions(
arg_plan_id IN number
) return number;

function get_percent_of_tl_in_cm(
arg_plan_id IN number
) return number;

function get_trip_loading_status(
arg_plan_id number,
arg_trip_id number
) return varchar2;

END mst_cm_details;



 

/
