--------------------------------------------------------
--  DDL for Package EAM_PERMIT_DEFAULT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_PERMIT_DEFAULT_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVWPDS.pls 120.0.12010000.1 2010/03/19 00:45:19 mashah noship $ */

/******************************************************************
* Procedure     : Populate_Null_Columns
* Purpose       : This procedure will look at the columns that the user
                  has not filled in and will assign those columns a
                  value from the old record.This procedure is not called for CREATE
********************************************************************/


PROCEDURE Populate_Null_Columns
     		  (p_eam_wp_rec         IN  EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type
          , p_old_eam_wp_rec     IN  EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type
          , x_eam_wp_rec         OUT NOCOPY EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type
     );

END EAM_PERMIT_DEFAULT_PVT ;


/
