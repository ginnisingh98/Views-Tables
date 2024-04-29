--------------------------------------------------------
--  DDL for Package WIP_BOMROUTINGUTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_BOMROUTINGUTIL_PVT" AUTHID CURRENT_USER as
 /* $Header: wipbmrus.pls 120.1.12010000.1 2008/07/24 05:21:44 appldev ship $ */

  procedure explodeRouting(p_orgID       in number,
                           p_wipEntityID in number,
                           p_repSchedID  in number,
                           p_itemID      in number,
                           p_altRouting  in varchar2,
                           p_routingRevDate in date,
                           p_qty         in number,
                           p_startDate   in date,
                           p_endDate     in date,
                           x_serStartOp   out nocopy number,
                           x_returnStatus out nocopy varchar2,
                           x_errorMsg     out nocopy varchar2);

  procedure explodeBOM(p_orgID       in number,
                       p_wipEntityID in number,
                       p_jobType     in number,
                       p_repSchedID  in number,
                       p_itemID      in number,
                       p_altBOM      in varchar2,
                       p_bomRevDate  in date,
                       p_altRouting  in varchar2,
                       p_routingRevDate in date,
                       p_qty         in number,
                       p_jobStartDate in date,
                       p_projectID   in number,
                       p_taskID      in number,
		       p_unitNumber  in varchar2 DEFAULT '', /* added for bug 5332615 */
                       x_returnStatus out nocopy varchar2,
                       x_errorMsg     out nocopy varchar2);

  procedure adjustQtyChange(p_orgID       in number,
                            p_wipEntityID in number,
                            p_qty         in number,
                            x_returnStatus out nocopy varchar2,
                            x_errorMsg     out nocopy varchar2);

end wip_bomRoutingUtil_pvt;

/
