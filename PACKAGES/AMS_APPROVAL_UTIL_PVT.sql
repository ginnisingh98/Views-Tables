--------------------------------------------------------
--  DDL for Package AMS_APPROVAL_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_APPROVAL_UTIL_PVT" AUTHID CURRENT_USER as
/* $Header: amsvuaps.pls 115.2 2002/12/20 10:27:04 vmodur noship $ */
 PROCEDURE Get_Object_Owner(itemtype          IN       VARCHAR2,
                            itemkey           IN       VARCHAR2,
                            x_approver_id     OUT NOCOPY      NUMBER,
                            x_return_status   OUT NOCOPY      VARCHAR2);

 PROCEDURE Get_Parent_Object_Owner(itemtype          IN       VARCHAR2,
                                   itemkey           IN       VARCHAR2,
                                   x_approver_id     OUT NOCOPY      NUMBER,
                                   x_return_status   OUT NOCOPY      VARCHAR2);

 PROCEDURE Get_Budget_Owner(itemtype          IN       VARCHAR2,
                            itemkey           IN       VARCHAR2,
                            x_approver_id     OUT NOCOPY      NUMBER,
                            x_return_status   OUT NOCOPY      VARCHAR2);

 PROCEDURE Get_Parent_Budget_Owner(itemtype   IN       VARCHAR2,
                            itemkey           IN       VARCHAR2,
                            x_approver_id     OUT NOCOPY      NUMBER,
                            x_return_status   OUT NOCOPY      VARCHAR2);
END ams_approval_util_pvt;

 

/
