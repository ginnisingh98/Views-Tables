--------------------------------------------------------
--  DDL for Package BIV_SR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIV_SR_PKG" AUTHID CURRENT_USER AS
	-- $Header: bivupdts.pls 115.0 2003/02/05 21:17:40 smisra noship $ */
 procedure  update_service_request(
                 p_sr_id            number,
                 p_status_id        number,
                 p_severity_id      number,
                 p_owner_id         number,
                 p_owner_group_id   number,
                 p_note_type        varchar2,
                 p_note_status      varchar2,
                 p_note             varchar2,
                 p_vrsn_no          number,
                 p_error out nocopy varchar2) ;
end;

 

/
