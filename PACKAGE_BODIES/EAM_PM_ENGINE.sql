--------------------------------------------------------
--  DDL for Package Body EAM_PM_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_PM_ENGINE" AS
/* $Header: EAMPMEGB.pls 120.3 2006/03/16 02:33:28 kmurthy ship $ */

  /**
   * This is a wrapper on top of the Java stored procedure to invoke the pm scheduler.
   */
  procedure run_pm_scheduler(runMode         in number,
                             nonSched        in varchar2,
                             startDate       in date,
                             endDate         in date,
                             groupID         in number,
                             orgID           in number,
                             userID          in number,
                             locationID      in number,
                             categoryID      in number,
                             deptID          in number,
                             itemType        in number,
                             theAssetGroupID in number,
                             assetNumber     in varchar2,
			     p_set_name_id   in number ) as
    language java name 'oracle.apps.eam.pm.scheduling.PMEngine.execute(
                             java.lang.Integer,
                             java.lang.String,
                             java.sql.Timestamp,
                             java.sql.Timestamp,
                             java.lang.Long,
                             java.lang.Long,
                             java.lang.Long,
                             java.lang.Long,
                             java.lang.Long,
                             java.lang.Long,
                             java.lang.Long,
                             java.lang.Long,
                             java.lang.String,
    		             java.lang.Long )';


  /**
   * This is a wrapper on top of the Java stored procedure to invoke the pm scheduler to
   * do the forecast for a given set of asset numbers only.
   */
  function do_forecast(nonSched   in varchar2,
                       startDate  in date,
                       endDate    in date,
                       orgID      in number,
                       userID     in number,
                       selectStmt in varchar2,
			setname_id	in number,
			combine_default in varchar2) return number as
    language java name 'oracle.apps.eam.pm.scheduling.PMEngine.forecastWorkOrders(
                             java.lang.String,
                             java.sql.Timestamp,
                             java.sql.Timestamp,
                             long,
                             long,
                             java.lang.String,
				long,
				java.lang.String) return long';

   procedure do_forecast2(nonSched   in varchar2,
                       startDate  in date,
                       endDate    in date,
                       orgID      in number,
                       userID     in number,
                       selectStmt in varchar2,
               		   setname_id	in number,
			           combine_default in varchar2,
                       group_id in number,
		       source_button in varchar2
		       ) as
    language java name 'oracle.apps.eam.pm.scheduling.PMEngine.forecastWorkOrders2(
                             java.lang.String,
                             java.sql.Timestamp,
                             java.sql.Timestamp,
                             long,
                             long,
                             java.lang.String,
				java.lang.Long,
				java.lang.String,
                           long,
                 	   java.lang.String)';

   procedure do_forecast3(nonSched   in varchar2,
                       startDate  in date,
                       endDate    in date,
                       orgID      in number,
                       userID     in number,
                       objectID in number,
                       objectType in number,
               		   setname_id	in number,
			           combine_default in varchar2,
                       group_id in number) as
    language java name 'oracle.apps.eam.pm.scheduling.PMEngine.forecastWorkOrders3(
                             java.lang.String,
                             java.sql.Timestamp,
                             java.sql.Timestamp,
                             long,
                             long,
                             long,
			     int,
				long,
				java.lang.String,
                long)';

END eam_pm_engine;

/
