--------------------------------------------------------
--  DDL for Package JTF_RS_DEFAULT_GROUPS_CONC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_DEFAULT_GROUPS_CONC_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfrsbcs.pls 120.0 2005/05/11 08:19:15 appldev noship $ */

 /****************************************************************************
  This is a concurrent program to populate the data in JTF_RS_DEFAULT_GROUPS_INT
  and JTF_RS_DEFAULT_GROUPS. This program will create primary groups for resources
  based on usage and rules (specified by product teams) for date date range from
  01/01/1900 to 12/31/4712. For a specific date there will be only one primary
  group for a resource.

   Currently, it is being used for only Field Service Application.

   CREATED BY    nsinghai      07/20/2004
   MODIFIED BY
   ***************************************************************************/

/*****************************************************************************
  This procedure will populate default groups for Field Service District (usage:
  'FLD_SRV_DISTRICT') through concurrent program "Update Primary Districts for
  Field Service Engineers".

  Created By     nsinghai     07/21/2004
  Modified By
*****************************************************************************/

PROCEDURE  populate_fs_district
  (ERRBUF                    OUT NOCOPY VARCHAR2,
   RETCODE                   OUT NOCOPY VARCHAR2)
 ;

/****************************************************************************
  This Function is used to fetch default group for specific usage given a
  resource_id, date and usage as input parameter. This function will fetch data
  only if data is populated in jtf_rs_default_groups table for that usage.

  Created By     nsinghai     07/21/2004
  Modified By

*****************************************************************************/

 FUNCTION get_default_group
    (p_resource_id    IN NUMBER,
     p_usage          IN VARCHAR2,
     p_date           IN DATE DEFAULT SYSDATE
    )
 RETURN NUMBER;

END jtf_rs_default_groups_conc_pub;

 

/
