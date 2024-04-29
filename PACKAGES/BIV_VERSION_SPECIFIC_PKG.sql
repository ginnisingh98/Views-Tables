--------------------------------------------------------
--  DDL for Package BIV_VERSION_SPECIFIC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIV_VERSION_SPECIFIC_PKG" AUTHID CURRENT_USER AS
	-- $Header: bivvrsns.pls 115.0 2003/02/05 21:26:37 smisra noship $ */
function get_sr_table return varchar2;
procedure set_update_program( p_sr_rec in out nocopy
                                CS_ServiceRequest_PVT.service_request_rec_type);
procedure status_lov(p_sr_id number,
                     p_lov_sttmnt out nocopy varchar2);
end;

 

/
