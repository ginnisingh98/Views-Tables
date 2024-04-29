--------------------------------------------------------
--  DDL for Package CSF_AUTO_COMMIT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_AUTO_COMMIT_PVT" AUTHID CURRENT_USER as
/* $Header: CSFVCMTS.pls 120.0 2005/05/24 17:49:24 appldev noship $ */

  procedure update_planned_task_status
    ( x_errbuf       out nocopy varchar2
    , x_retcode      out nocopy varchar2
    , p_query_id     varchar2 default null
    );

end csf_auto_commit_pvt;

 

/
