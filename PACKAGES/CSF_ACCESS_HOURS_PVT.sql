--------------------------------------------------------
--  DDL for Package CSF_ACCESS_HOURS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_ACCESS_HOURS_PVT" AUTHID CURRENT_USER as
/* $Header: CSFVACHS.pls 120.0.12010000.2 2009/09/12 13:15:39 vakulkar ship $ */
-- Start of Comments
-- PLEASE NOTE THIS IS A PRIVATE FILE
-- Package name     : CSF_ACCESS_HOURS_PVT
-- Purpose          :
-- History          :
-- 17-AUG-2004      : Changed the name of the package from CSF_ACCESS_HOURS_PKG to CSF_ACCESS_HOURS_PVT
--	            :
-- NOTE             :
-- End of Comments
/*TYPE Access_Hours_Rec_Type IS RECORD
(
ACCESS_HOUR_ID                NUMBER		:=  	FND_API.G_MISS_NUM,
TASK_ID                       NUMBER		:=  	FND_API.G_MISS_NUM,
CREATED_BY                    NUMBER		:=  	FND_API.G_MISS_NUM,
CREATION_DATE                 DATE		    := 	    FND_API.G_MISS_DATE,
LAST_UPDATED_BY               NUMBER		:=  	FND_API.G_MISS_NUM,
LAST_UPDATE_DATE              DATE 		    := 	    FND_API.G_MISS_DATE,
LAST_UPDATE_LOGIN             NUMBER		:=  	FND_API.G_MISS_NUM,
ACCESS_HOUR_REQD              VARCHAR2(2)   :=      FND_API.G_MISS_CHAR,
AFTER_HOURS_FLAG              VARCHAR2(2)   :=      FND_API.G_MISS_CHAR,
MONDAY_FIRST_START                  DATE          :=      FND_API.G_MISS_DATE,
MONDAY_FIRST_END                    DATE          :=      FND_API.G_MISS_DATE,
TUESDAY_FIRST_START                 DATE          :=      FND_API.G_MISS_DATE,
TUESDAY_FIRST_END                   DATE          :=      FND_API.G_MISS_DATE,
WEDNESDAY_FIRST_START               DATE          :=      FND_API.G_MISS_DATE,
WEDNESDAY_FIRST_END                 DATE          :=      FND_API.G_MISS_DATE,
THURSDAY_FIRST_START                DATE          :=      FND_API.G_MISS_DATE,
THURSDAY_FIRST_END                  DATE          :=      FND_API.G_MISS_DATE,
FRIDAY_FIRST_START                  DATE          :=      FND_API.G_MISS_DATE,
FRIDAY_FIRST_END                    DATE          :=      FND_API.G_MISS_DATE,
SATURDAY_FIRST_START                DATE          :=      FND_API.G_MISS_DATE,
SATURDAY_FIRST_END                  DATE          :=      FND_API.G_MISS_DATE,
SUNDAY_FIRST_START                  DATE          :=      FND_API.G_MISS_DATE,
SUNDAY_FIRST_END                    DATE          :=      FND_API.G_MISS_DATE,
MONDAY_SECOND_START                  DATE          :=      FND_API.G_MISS_DATE,
MONDAY_SECOND_END                    DATE          :=      FND_API.G_MISS_DATE,
TUESDAY_SECOND_START                 DATE          :=      FND_API.G_MISS_DATE,
TUESDAY_SECOND_END                   DATE          :=      FND_API.G_MISS_DATE,
WEDNESDAY_SECOND_START               DATE          :=      FND_API.G_MISS_DATE,
WEDNESDAY_SECOND_END                 DATE          :=      FND_API.G_MISS_DATE,
THURSDAY_SECOND_START                DATE          :=      FND_API.G_MISS_DATE,
THURSDAY_SECOND_END                  DATE          :=      FND_API.G_MISS_DATE,
FRIDAY_SECOND_START                  DATE          :=      FND_API.G_MISS_DATE,
FRIDAY_SECOND_END                    DATE          :=      FND_API.G_MISS_DATE,
SATURDAY_SECOND_START                DATE          :=      FND_API.G_MISS_DATE,
SATURDAY_SECOND_END                  DATE          :=      FND_API.G_MISS_DATE,
SUNDAY_SECOND_START                  DATE          :=      FND_API.G_MISS_DATE,
SUNDAY_SECOND_END                    DATE          :=      FND_API.G_MISS_DATE
);

*/

PROCEDURE CREATE_ACCESS_HOURS(
	      p_API_VERSION              IN          NUMBER,
		  p_INIT_MSG_LIST            IN          VARCHAR2,
          x_ACCESS_HOUR_ID           OUT NOCOPY  NUMBER,
          p_TASK_ID    				 NUMBER,
          p_ACCESS_HOUR_REQD 		 VARCHAR2 DEFAULT NULL,
          p_AFTER_HOURS_FLAG 		 VARCHAR2 DEFAULT NULL,
          p_MONDAY_FIRST_START 		 DATE DEFAULT TO_DATE(NULL) ,--null,
          p_MONDAY_FIRST_END 		 DATE DEFAULT  TO_DATE(NULL), --null,
          p_TUESDAY_FIRST_START      DATE DEFAULT TO_DATE(NULL),
          p_TUESDAY_FIRST_END 		 DATE DEFAULT TO_DATE(NULL) ,
          p_WEDNESDAY_FIRST_START 	 DATE DEFAULT TO_DATE(NULL),
          p_WEDNESDAY_FIRST_END 	 DATE DEFAULT TO_DATE(NULL),
          p_THURSDAY_FIRST_START     DATE DEFAULT TO_DATE(NULL),
          p_THURSDAY_FIRST_END 		 DATE DEFAULT TO_DATE(NULL),
          p_FRIDAY_FIRST_START 		 DATE DEFAULT TO_DATE(NULL),
          p_FRIDAY_FIRST_END 		 DATE DEFAULT TO_DATE(NULL),
          p_SATURDAY_FIRST_START 	 DATE DEFAULT TO_DATE(NULL),
          p_SATURDAY_FIRST_END 		 DATE DEFAULT TO_DATE(NULL),
          p_SUNDAY_FIRST_START 		 DATE DEFAULT TO_DATE(NULL),
          p_SUNDAY_FIRST_END 		 DATE DEFAULT TO_DATE(NULL),
          p_MONDAY_SECOND_START 	 DATE DEFAULT TO_DATE(NULL) ,--null,
          p_MONDAY_SECOND_END 		 DATE DEFAULT TO_DATE(NULL), --null,
          p_TUESDAY_SECOND_START 	 DATE DEFAULT TO_DATE(NULL),
          p_TUESDAY_SECOND_END 		 DATE DEFAULT TO_DATE(NULL) ,
          p_WEDNESDAY_SECOND_START   DATE DEFAULT TO_DATE(NULL),
          p_WEDNESDAY_SECOND_END 	 DATE DEFAULT TO_DATE(NULL),
          p_THURSDAY_SECOND_START 	 DATE DEFAULT TO_DATE(NULL),
          p_THURSDAY_SECOND_END 	 DATE DEFAULT TO_DATE(NULL),
          p_FRIDAY_SECOND_START 	 DATE DEFAULT TO_DATE(NULL),
          p_FRIDAY_SECOND_END 		 DATE DEFAULT TO_DATE(NULL),
          p_SATURDAY_SECOND_START 	 DATE DEFAULT TO_DATE(NULL),
          p_SATURDAY_SECOND_END 	 DATE DEFAULT TO_DATE(NULL),
          p_SUNDAY_SECOND_START 	 DATE DEFAULT TO_DATE(NULL),
          p_SUNDAY_SECOND_END 		 DATE DEFAULT TO_DATE(NULL),
          p_DESCRIPTION 			 VARCHAR2 DEFAULT null,
          px_object_version_number   in out nocopy NUMBER,
          p_CREATED_BY    			 NUMBER   DEFAULT null,
          p_CREATION_DATE    		 DATE     DEFAULT null,
          p_LAST_UPDATED_BY    		 NUMBER   DEFAULT null,
          p_LAST_UPDATE_DATE    	 DATE     DEFAULT null,
          p_LAST_UPDATE_LOGIN    	 NUMBER   DEFAULT null,
          p_commit in     			 VARCHAR2 DEFAULT null,
          x_return_status            OUT NOCOPY    VARCHAR2,
	      x_msg_data                 OUT NOCOPY    VARCHAR2,
	      x_msg_count                OUT NOCOPY    NUMBER,
		  p_data_chg_frm_ui			 IN  VARCHAR2  DEFAULT null);


PROCEDURE Update_Access_Hours(
		  p_API_VERSION              IN  NUMBER,
	      p_INIT_MSG_LIST            IN  VARCHAR2 DEFAULT NULL,
          p_ACCESS_HOUR_ID   		 IN  NUMBER,
          p_TASK_ID  			         NUMBER,
          p_ACCESS_HOUR_REQD 			 VARCHAR2 DEFAULT null,
          p_AFTER_HOURS_FLAG 			 VARCHAR2 DEFAULT null,
          p_MONDAY_FIRST_START 			 DATE DEFAULT TO_DATE(NULL), --null,
          p_MONDAY_FIRST_END 			 DATE DEFAULT TO_DATE(NULL), --null,
          p_TUESDAY_FIRST_START 		 DATE DEFAULT TO_DATE(NULL),
          p_TUESDAY_FIRST_END 			 DATE DEFAULT TO_DATE(NULL) ,
          p_WEDNESDAY_FIRST_START 		 DATE DEFAULT TO_DATE(NULL),
          p_WEDNESDAY_FIRST_END 		 DATE DEFAULT TO_DATE(NULL),
          p_THURSDAY_FIRST_START 		 DATE DEFAULT TO_DATE(NULL),
          p_THURSDAY_FIRST_END 			 DATE DEFAULT TO_DATE(NULL),
          p_FRIDAY_FIRST_START 			 DATE DEFAULT TO_DATE(NULL),
          p_FRIDAY_FIRST_END 			 DATE DEFAULT TO_DATE(NULL),
          p_SATURDAY_FIRST_START 		 DATE DEFAULT TO_DATE(NULL),
          p_SATURDAY_FIRST_END 			 DATE DEFAULT TO_DATE(NULL),
          p_SUNDAY_FIRST_START 			 DATE DEFAULT TO_DATE(NULL),
          p_SUNDAY_FIRST_END 			 DATE DEFAULT TO_DATE(NULL),
          p_MONDAY_SECOND_START 		 DATE DEFAULT TO_DATE(NULL), --null,
          p_MONDAY_SECOND_END 			 DATE DEFAULT TO_DATE(NULL), --null,
          p_TUESDAY_SECOND_START 		 DATE DEFAULT TO_DATE(NULL),
          p_TUESDAY_SECOND_END 			 DATE DEFAULT TO_DATE(NULL) ,
          p_WEDNESDAY_SECOND_START 		 DATE DEFAULT TO_DATE(NULL),
          p_WEDNESDAY_SECOND_END 		 DATE DEFAULT TO_DATE(NULL),
          p_THURSDAY_SECOND_START 		 DATE DEFAULT TO_DATE(NULL),
          p_THURSDAY_SECOND_END 		 DATE DEFAULT TO_DATE(NULL),
          p_FRIDAY_SECOND_START 		 DATE DEFAULT TO_DATE(NULL),
          p_FRIDAY_SECOND_END 			 DATE DEFAULT TO_DATE(NULL),
          p_SATURDAY_SECOND_START 		 DATE DEFAULT TO_DATE(NULL),
          p_SATURDAY_SECOND_END 		 DATE DEFAULT TO_DATE(NULL),
          p_SUNDAY_SECOND_START 		 DATE DEFAULT TO_DATE(NULL),
          p_SUNDAY_SECOND_END 			 DATE DEFAULT TO_DATE(NULL),
           p_DESCRIPTION 				 VARCHAR2 DEFAULT null,
          px_object_version_number 		 in out nocopy NUMBER,
          p_CREATED_BY    				 NUMBER   DEFAULT null,
          p_CREATION_DATE    			 DATE     DEFAULT null,
          p_LAST_UPDATED_BY    			 NUMBER   DEFAULT null,
          p_LAST_UPDATE_DATE    		 DATE     DEFAULT null,
          p_LAST_UPDATE_LOGIN    		 NUMBER   DEFAULT null,
          p_commit in     				 VARCHAR2 DEFAULT null,
          x_return_status            	 OUT NOCOPY    VARCHAR2,
	      x_msg_data                 	 OUT NOCOPY    VARCHAR2,
	      x_msg_count                    OUT NOCOPY    NUMBER,
		  p_data_chg_frm_ui			     IN  VARCHAR2  DEFAULT null);


PROCEDURE lock_Access_Hours(
		  p_API_VERSION              IN                     NUMBER,
	      p_INIT_MSG_LIST            IN                     VARCHAR2 default NULL,
          p_access_hour_id                                  NUMBER,
          p_object_version_number                           NUMBER,
          x_return_status            OUT NOCOPY             VARCHAR2,
	      x_msg_data                 OUT NOCOPY             VARCHAR2,
	      x_msg_count                OUT NOCOPY             NUMBER
);
PROCEDURE Delete_Access_Hours(
	      p_API_VERSION              IN                     NUMBER,
	      p_INIT_MSG_LIST            IN                     VARCHAR2 default NULL,
          p_ACCESS_HOUR_ID                                  NUMBER,
          p_commit                   in                     VARCHAR2 default null,
          x_return_status            OUT NOCOPY             VARCHAR2,
	      x_msg_data                 OUT NOCOPY             VARCHAR2,
	      x_msg_count                OUT NOCOPY             NUMBER
);

END CSF_ACCESS_HOURS_PVT;

/
