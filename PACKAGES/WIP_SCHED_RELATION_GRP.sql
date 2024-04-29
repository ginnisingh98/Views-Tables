--------------------------------------------------------
--  DDL for Package WIP_SCHED_RELATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_SCHED_RELATION_GRP" AUTHID CURRENT_USER AS
/* $Header: wipgwlks.pls 115.0 2003/09/16 11:09:20 amgarg noship $ */
/*==========================================================================+
|   Copyright (c) 1997 Oracle Corporation Redwood Shores, California, USA   |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : wipgwlks.pls                                               |
|                                                                           |
| DESCRIPTION  : This package, is a Group API, which contains functions     |
|              to Create and Delete relationships for Work Order Scheduling.|
|                                                                           |
| Coders       : Amit Garg                                                  |
+===========================================================================*/


--Global Constants
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'wip_sched_relation_grp';


/******************************************************************************
* PROCEDURE INSERTROW                                                         *
*  This procedure is used to validate AND create Relationships to be          *
*  inserted in WIP_SCHED_RELATIONSHIPS Table                                  *
*  The input parameters for this procedure are:                               *
*   p_parentObjectID       :  Parent Object Idetifier                         *
*   p_parentObjectTypeID   :  Parent Object type Idetifier                    *
*   p_childObjectID        :  Child Object Idetifier                          *
*   p_childObjectTypeID    :  Child Object type Idetifier                     *
*   p_relationshipType     :  Type of relationship between parent and child   *
*   p_relationshipStatus   :  Relationship status,                            *
*                                  pending     : 0                            *
*                                  processing  : 1                            *
*                                  valid       : 2                            *
*                                  invalid     : 3                            *
*   x_return_status        :  out parameter to indicate success, failure or   *
*                             error for this procedure                        *
*   x_msg_count            :  out parameter indicating number of messages in  *
*                             msg list                                        *
*   x_msg_data             :  message in encoded form is returned             *
*   p_api_version          :  parameter indicating api version, to check for  *
*                             valid API version                               *
*   p_init_msg_list        :  Parameter to indicate whether public msg list   *
*                             is required to be initialised                   *
*   p_commit               :  Parameter to indicate if commit is required     *
*                             by this proc                                    *
******************************************************************************/
PROCEDURE insertRow(p_parentObjectID    IN NUMBER,
                  p_parentObjectTypeID  IN NUMBER,
                  p_childObjectID       IN NUMBER,
                  p_childObjectTypeID   IN NUMBER,
                  p_relationshipType    IN NUMBER,
                  p_relationshipStatus  IN NUMBER,
                  x_return_status       OUT NOCOPY VARCHAR2,
                  x_msg_count           OUT NOCOPY NUMBER,
                  x_msg_data            OUT NOCOPY VARCHAR2,
                  p_api_version         IN  NUMBER,
                  p_init_msg_list       IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                  p_commit              IN  VARCHAR2 DEFAULT FND_API.G_FALSE);



/************************************************************************
* PROCEDURE DELETEROW                                                   *
*  This procedure is used to validate AND DELETE Relationships FROM     *
*  WIP_SCHED_RELATIONSHIPS Table                                        *
*  The input parameters for this procedure are:                         *
*   p_relationshipID   :  Relationship idetifier to be deleted          *
*   x_return_status    :  To indicate procedure success, failure, error *
*   x_msg_count        :  To indicate number of msgs in msg list        *
*   x_msg_data         :  Return message in encoded form                *
*   p_api_version      :  To validate API version to be used            *
*   p_init_msg_list    :  Whether to intialize public msg list          *
*   p_commit           :  Whether to commit transaction                 *
************************************************************************/
PROCEDURE deleteRow(p_relationshipID in number,
                  x_return_status       OUT NOCOPY VARCHAR2,
                  x_msg_count           OUT NOCOPY NUMBER,
                  x_msg_data            OUT NOCOPY VARCHAR2,
                  p_api_version         IN  NUMBER,
                  p_init_msg_list       IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                  p_commit              IN  VARCHAR2 DEFAULT FND_API.G_FALSE);


END wip_sched_relation_grp;

 

/
