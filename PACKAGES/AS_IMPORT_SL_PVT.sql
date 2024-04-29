--------------------------------------------------------
--  DDL for Package AS_IMPORT_SL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_IMPORT_SL_PVT" AUTHID CURRENT_USER as
/* $Header: asxslims.pls 120.1 2006/01/18 11:29:22 solin noship $ */

log_fpt constant number := 1; -- log file pointer
output_fpt constant number := 2; -- output file pointer
G_LOAD_STATUS_SUCC      CONSTANT VARCHAR2(20)  := 'SUCCESS';
G_LOAD_STATUS_ERR       CONSTANT VARCHAR2(20)  := 'ERROR';
G_LOAD_STATUS_UNEXP_ERR CONSTANT VARCHAR2(20)  := 'UNEXP_ERROR';
G_api_version     CONSTANT  NUMBER       := 1.0;
G_as_api_version  CONSTANT  NUMBER       := 2.0; -- crm apis are of version 2
G_return_status   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS; -- default is success
G_mesg_count NUMBER := 0;
G_msg_data VARCHAR2(2000) := Null;
G_DEBUGFLAG  VARCHAR2(1)  := 'N'; -- Y - Yes, N - No

l_status boolean:=false;
l_ignore boolean:=false;

procedure main(
    errbuf varchar2,
    errcode varchar2,
    p_source_system in varchar2,
    --p_creation_date in date, -- bugfix : 2044447
    p_debug_msg_flag in varchar2 := 'N',--bugfix : 2047689
    p_batch_id in number,
    p_purge_error_flag in varchar2 := 'N',
    p_parent_request_id in number := NULL,
    p_child_request_id in number := NULL,
    p_resource_id in number := NULL, -- SOLIN, bug 4702335
    p_group_id in number := NULL -- SOLIN, bug 4702335

);

procedure do_lead_import(
--    errbuf varchar2,
--    errcode varchar2,
    p_source_system in varchar2,
    p_debug_msg_flag in varchar2 := 'N',--bugfix : 2047689
    p_parent_request_id in number,
    p_child_request_id in number,
    p_resource_id in number, -- SOLIN, bug 4702335
    p_group_id in number -- SOLIN, bug 4702335

    );

end as_import_sl_pvt;

 

/
