--------------------------------------------------------
--  DDL for Package WMS_ARCHIVE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_ARCHIVE_PVT" AUTHID CURRENT_USER as
 /* $Header: WMSTARCS.pls 115.0 2004/04/01 02:55:08 joabraha noship $ */
--
--
Procedure trace(
   p_message  in varchar2
,  p_level    in number default 4
);
--
--
Procedure archive_tasks(
   x_errbuf           out nocopy varchar2
,  x_retcode          out nocopy number
,  p_org_id           in         number
,  p_purge_days       in         number
,  p_archive_batches  in         number
);
--
--
Procedure archive_tasks_worker(
   x_errbuf           out nocopy varchar2
,  x_retcode          out nocopy number
,  p_from_date        in         varchar2
,  p_to_date          in         varchar2
,  p_org_id           in         number
);
--
--
Procedure unarchive_tasks(
   x_errbuf           out nocopy varchar2
,  x_retcode          out nocopy number
,  p_from_date        in         varchar2
,  p_to_date          in         varchar2
,  p_org_id           in         number
,  p_unarch_batches   in         number
);
--
--
Procedure unarchive_tasks_worker(
   x_errbuf           out nocopy varchar2
,  x_retcode          out nocopy number
,  p_from_date        in         varchar2
,  p_to_date          in         varchar2
,  p_org_id           in         number
);
--
--
end wms_archive_pvt;

 

/
