--------------------------------------------------------
--  DDL for Package ZPB_DVAC_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_DVAC_WF" AUTHID CURRENT_USER AS
/* $Header: ZPBVDVCS.pls 120.0.12010.4 2006/08/03 12:04:54 appldev noship $ */

procedure set_dvac_task (errbuf out nocopy varchar2,
            		retcode out nocopy varchar2,
                        BP_ID in number,
                        instanceId in number,
                        p_business_area_id in number,
                        p_task_id in number);

end ZPB_DVAC_WF;

 

/
