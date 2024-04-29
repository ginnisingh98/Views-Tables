--------------------------------------------------------
--  DDL for Package EAM_PM_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_PM_ENGINE" AUTHID CURRENT_USER AS
/* $Header: EAMPMEGS.pls 120.3 2006/03/16 02:36:48 kmurthy ship $ */

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
			     p_set_name_id   in number );

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
			combine_default in varchar2) return number;

   /**
   * This is a wrapper on top of the Java stored procedure to invoke the pm scheduler to
   * do the forecast for a given set of asset numbers only.
   */
   procedure do_forecast2(nonSched   in varchar2,
                       startDate  in date,
                       endDate    in date,
                       orgID      in number,
                       userID     in number,
                       selectStmt in varchar2,
               	       setname_id	in number,
		       combine_default in varchar2,
                       group_id in number,
		       source_button in varchar2 );

   procedure do_forecast3(nonSched   in varchar2,
                       startDate  in date,
                       endDate    in date,
                       orgID      in number,
                       userID     in number,
                       objectID in number,
                       objectType in number,
          	       setname_id	in number,
		       combine_default in varchar2,
                       group_id in number);
END eam_pm_engine;


 

/
