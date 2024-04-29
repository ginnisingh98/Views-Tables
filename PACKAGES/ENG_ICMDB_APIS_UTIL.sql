--------------------------------------------------------
--  DDL for Package ENG_ICMDB_APIS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_ICMDB_APIS_UTIL" AUTHID CURRENT_USER AS
/* $Header: ENGUICMS.pls 120.1 2005/06/13 14:30:51 appldev  $ */

PROCEDURE create_lines(
                     p_change_id in number,
                     x_return_status out nocopy varchar2,
                     x_msg_count out nocopy number,
                     x_msg_data out nocopy varchar2);

PROCEDURE update_approval_status(
                     p_change_id IN NUMBER,
                     p_base_change_mgmt_type_code  IN VARCHAR2 ,
                     p_new_approval_status_cde IN NUMBER ,
                     p_workflow_status_code IN VARCHAR2,
                     x_return_status OUT NOCOPY VARCHAR2,
                     x_msg_count OUT NOCOPY NUMBER,
                     x_msg_data OUT NOCOPY VARCHAR2);


END ENG_ICMDB_APIS_UTIL;

 

/
