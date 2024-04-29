--------------------------------------------------------
--  DDL for Package WIP_BOMROUTING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_BOMROUTING_PVT" AUTHID CURRENT_USER as
 /* $Header: wipbmrts.pls 120.2 2006/07/20 11:01:25 panagara noship $ */

  -- This procedure is used to explode the bom and routing and schedule the job if needed.
  -- p_schedulingMethod: if the value is routing based, then you must provide one of the p_startDate
  --                     and p_endDate, you can not provide both, however.
  --                     if it is not routing based, then you must provide both.
  -- p_startDate: forward schedule the job if it is not null
  -- p_endDate: backward schedule the job it it is not null
  -- p_rtgRefID: only useful when p_jobType is nonstandard
  -- p_bomRefID: only useful when p_jobType is nonstandard
  -- p_unitNumber: To explode components properly based on unit number for unit effective assemblies.
  procedure createJob(p_orgID       in number,
                      p_wipEntityID in number,
                      p_jobType     in number,
                      p_itemID      in number,
                      p_schedulingMethod in number,
                      p_altRouting  in varchar2,
                      p_routingRevDate in date,
                      p_altBOM      in varchar2,
                      p_bomRevDate  in date,
                      p_qty         in number,
                      p_startDate   in date,
                      p_endDate     in date,
                      p_projectID   in number,
                      p_taskID      in number,
                      p_rtgRefID    in number,
                      p_bomRefID    in number,
      		      p_unitNumber  in varchar2 DEFAULT '', /* added for bug 5332615 */
                      x_serStartOp   out nocopy number,
                      x_returnStatus out nocopy varchar2,
                      x_errorMsg     out nocopy varchar2);


  -- This procedure is used to reexplode the bom/routing if applicable and reschedule the job.
  -- It will also handle qty change and scheduled date changes. It will decide whether we need to
  -- to explode from BOM or just adjust the currrent wip copy.
  -- p_schedulingMethod: if the value is routing based, then you must provide one of the p_startDate
  --                     and p_endDate, you can not provide both, however.
  --                     if it is not routing based, then you must provide both.
  -- p_startDate: forward schedule the job if it is not null
  -- p_endDate: backward schedule the job it it is not null
  -- p_rtgRefID: only useful when p_jobType is nonstandard
  -- p_bomRefID: only useful when p_jobType is nonstandard
  -- p_unitNumber: To explode components properly based on unit number for unit effective assemblies.

  -- for anything related to bom/rtg you do not want to change, for instance, bom_reference_id, you must pass the original
  -- value queried up from the job. If you pass null, this API will consider that you want to change the
  -- value to null instead of not touching it at all.
  procedure reexplodeJob(p_orgID       in number,
                         p_wipEntityID in number,
                         p_schedulingMethod in number,
                         p_altRouting  in varchar2,
                         p_routingRevDate in date,
                         p_altBOM      in varchar2,
                         p_bomRevDate  in date,
                         p_qty         in number,
                         p_startDate   in date,
                         p_endDate     in date,
			 p_projectID   in number,
			 p_taskID      in number,
                         p_rtgRefID    in number,
                         p_bomRefID    in number,
                         p_allowExplosion in boolean,
			 p_unitNumber  in varchar2 DEFAULT '', /* added for bug 5332615 */
                         x_returnStatus out nocopy varchar2,
                         x_errorMsg     out nocopy varchar2);

end wip_bomRouting_pvt;

 

/
