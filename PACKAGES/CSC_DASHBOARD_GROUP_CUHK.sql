--------------------------------------------------------
--  DDL for Package CSC_DASHBOARD_GROUP_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_DASHBOARD_GROUP_CUHK" AUTHID CURRENT_USER AS
/* $Header: cscdguhks.pls 120.3 2005/08/24 05:15 tpalaniv noship $ */

  procedure Get_DashBoard_Group_Pre( P_PARTY_REC IN OUT NOCOPY csc_utils.dashboard_Rec_Type);

  END CSC_DASHBOARD_GROUP_CUHK;

 

/
