--------------------------------------------------------
--  DDL for Package Body CSF_DEBRIEF_TASK_ASSIGNMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_DEBRIEF_TASK_ASSIGNMENTS" AS
/* $Header: csfptkab.pls 120.0 2005/05/24 18:02:26 appldev noship $ */


Procedure update_task_assignment
   (    l_API_VERSION		        IN	    NUMBER       ,
        l_OBJECT_VERSION_NUMBER         IN OUT NOCOPY NUMBER      ,
	l_TASK_ASSIGNMENT_ID	        IN	    NUMBER      ,
	l_ACTUAL_START_DATE             IN     DATE		,
	l_ACTUAL_END_DATE               IN     DATE		,
        l_ASSIGNMENT_STATUS_ID          IN     NUMBER      ,
	l_RETURN_STATUS		        OUT  NOCOPY  VARCHAR2	 ,
	l_MSG_COUNT		        OUT  NOCOPY   NUMBER 	 ,
	l_MSG_DATA		        OUT  NOCOPY  VARCHAR2   ) IS
begin
  null;
END update_task_assignment;


function CtAcctInfo(x_party_id in number,x_acct_id in number)
  return varchar2 is

begin
  null;
end CtAcctInfo;


end   CSF_DEBRIEF_TASK_ASSIGNMENTS;

/
