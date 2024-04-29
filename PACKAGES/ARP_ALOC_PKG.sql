--------------------------------------------------------
--  DDL for Package ARP_ALOC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_ALOC_PKG" AUTHID CURRENT_USER as
/* $Header: AROALOCS.pls 115.0 99/07/17 00:00:43 porting ship $ */

function user_value ( 	p_segment_qualifier 	in varchar2,
			p_segment_value 	in varchar2) return varchar2;

function user_value_matches_id ( p_segment_user_value 	in varchar2,
				 p_segment_id	 	in number  ) return boolean;

function unique_postal_code ( p_segment_id	 	in number ) return varchar2;

procedure parent_value_and_id ( p_child_segment_id 	 	in number,
				p_parent_segment_id		out number,
				p_parent_segment_user_val 	out varchar2 );
--
end arp_aloc_pkg;


 

/
