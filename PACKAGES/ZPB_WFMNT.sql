--------------------------------------------------------
--  DDL for Package ZPB_WFMNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_WFMNT" AUTHID CURRENT_USER AS
/* $Header: zpbwkfmnt.pls 120.0.12010.2 2006/08/03 18:49:12 appldev noship $ */


Procedure PURGEWF_BUSINESSAREA (p_business_area_id in number);

procedure purge_Workflows (errbuf out nocopy varchar2,
                          retcode out nocopy varchar2,
                          p_inACID in Number,
                          ACIDType in varchar2);


end ZPB_WFMNT;

 

/
