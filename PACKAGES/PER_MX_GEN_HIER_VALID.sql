--------------------------------------------------------
--  DDL for Package PER_MX_GEN_HIER_VALID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_MX_GEN_HIER_VALID" AUTHID CURRENT_USER as
/* $Header: permxgenhiervald.pkh 115.1 2004/05/07 13:46:31 vpandya noship $ */
--
/*
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1992 Oracle Corporation UK Ltd.,                *
   *                   Chertsey, England.                           *
   *                                                                *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation UK Ltd,  *
   *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
   *  England.                                                      *
   *                                                                *
   ******************************************************************

   Description: This package is used to validate generic hierarchy
                'Mexican HRMS Statutory Reporting' for Mexico.

   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   05-MAY-2004  vpandya     115.0            Created.
*/
--

  PROCEDURE validate_nodes( P_BUSINESS_GROUP_ID        in NUMBER
                           ,P_ENTITY_ID                in VARCHAR2
                           ,P_HIERARCHY_VERSION_ID     in NUMBER
                           ,P_NODE_TYPE                in VARCHAR2
                           ,P_SEQ                      in NUMBER
                           ,P_PARENT_HIERARCHY_NODE_ID in NUMBER
                           ,P_REQUEST_ID               in NUMBER
                           ,P_PROGRAM_APPLICATION_ID   in NUMBER
                           ,P_PROGRAM_ID               in NUMBER
                           ,P_PROGRAM_UPDATE_DATE      in DATE
                           ,P_EFFECTIVE_DATE           in DATE );

  PROCEDURE create_default_location( P_HIERARCHY_NODE_ID        in NUMBER
                                    ,P_BUSINESS_GROUP_ID        in NUMBER
                                    ,P_ENTITY_ID                in VARCHAR2
                                    ,P_HIERARCHY_VERSION_ID     in NUMBER
                                    ,P_NODE_TYPE                in VARCHAR2
                                    ,P_SEQ                      in NUMBER
                                    ,P_PARENT_HIERARCHY_NODE_ID in NUMBER
                                    ,P_REQUEST_ID               in NUMBER
                                    ,P_PROGRAM_APPLICATION_ID   in NUMBER
                                    ,P_PROGRAM_ID               in NUMBER
                                    ,P_PROGRAM_UPDATE_DATE      in DATE
                                    ,P_EFFECTIVE_DATE           in DATE );

--  PROCEDURE delete_nodes( P_HIERARCHY_NODE_ID     in NUMBER
--                         ,P_OBJECT_VERSION_NUMBER in NUMBER);

  PROCEDURE update_nodes( P_HIERARCHY_NODE_ID        in NUMBER
                         ,P_ENTITY_ID                in VARCHAR2
                         ,P_NODE_TYPE                in VARCHAR2
                         ,P_SEQ                      in NUMBER
                         ,P_PARENT_HIERARCHY_NODE_ID in NUMBER
                         ,P_REQUEST_ID               in NUMBER
                         ,P_PROGRAM_APPLICATION_ID   in NUMBER
                         ,P_PROGRAM_ID               in NUMBER
                         ,P_PROGRAM_UPDATE_DATE      in DATE
                         ,P_OBJECT_VERSION_NUMBER    in NUMBER
                         ,P_EFFECTIVE_DATE           in DATE );

  PROCEDURE update_hier_versions( P_HIERARCHY_VERSION_ID   in NUMBER
                                 ,P_VERSION_NUMBER         in NUMBER
                                 ,P_DATE_FROM              in DATE
                                 ,P_DATE_TO                in DATE
                                 ,P_STATUS                 in VARCHAR2
                                 ,P_VALIDATE_FLAG          in VARCHAR2
                                 ,P_REQUEST_ID             in NUMBER
                                 ,P_PROGRAM_APPLICATION_ID in NUMBER
                                 ,P_PROGRAM_ID             in NUMBER
                                 ,P_PROGRAM_UPDATE_DATE    in DATE
                                 ,P_OBJECT_VERSION_NUMBER  in NUMBER
                                 ,P_EFFECTIVE_DATE         in DATE );

END per_mx_gen_hier_valid;

 

/
