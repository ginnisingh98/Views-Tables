--------------------------------------------------------
--  DDL for Package CSM_UOM_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_UOM_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: csmeuoms.pls 120.1 2005/07/25 00:28:25 trajasek noship $ */

--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below

/*PROCEDURE UNIT_OF_MEASURE_ACC_PROCESSOR ( p_itemtype in varchar2,
	    	                            p_itemkey in varchar2,
		                                p_actid in number,
                                        p_funcmode in varchar2,
	                                    x_result out nocopy varchar2);

procedure Refresh_ACC( p_user_id asg_user.user_id%TYPE DEFAULT null,
    p_access_id CSM_UNIT_OF_MEASURE_TL_ACC.ACCESS_ID%TYPE DEFAULT null);

*/

PROCEDURE Refresh_acc(p_status OUT NOCOPY VARCHAR2,
                       p_message OUT NOCOPY VARCHAR2);

END CSM_UOM_EVENT_PKG; -- Package spec

 

/
