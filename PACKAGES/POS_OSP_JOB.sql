--------------------------------------------------------
--  DDL for Package POS_OSP_JOB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_OSP_JOB" AUTHID CURRENT_USER as
/* $Header: POSASNWS.pls 115.0 99/08/20 11:09:02 porting sh $ */

function r_count(po_line_location_id in number) return number;
function get_osp_info(po_line_location_id in number) return varchar2;
function get_po_distribution_id(po_line_location_id in number) return number;
function get_wip_entity_id(po_line_location_id in number) return number;
function get_wip_line_id(po_line_location_id in number) return number;
function get_wip_seq_num(po_line_location_id in number) return number;
function get_wip_info(po_distributions_id in number) return varchar2;

end pos_osp_job;

 

/
