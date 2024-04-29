--------------------------------------------------------
--  DDL for Package WMS_OTM_DOCK_SYNC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_OTM_DOCK_SYNC" AUTHID CURRENT_USER AS
/* $Header: WMSOTDDS.pls 120.0 2007/12/22 04:08:46 dramamoo noship $ */

PROCEDURE SEND_DOCK_DOORS(
          p_entity_in_rec     IN WSH_OTM_ENTITY_REC_TYPE,
          x_username          OUT NOCOPY VARCHAR2,
          x_password          OUT NOCOPY VARCHAR2,
          x_org_dock_tbl      OUT NOCOPY WMS_ORG_DOCK_TBL_TYPE,
          x_return_status     OUT NOCOPY VARCHAR2,
          x_msg_data          OUT NOCOPY VARCHAR2 );

PROCEDURE get_secure_ticket_details(
          p_op_code          IN         VARCHAR2,
          p_argument         IN         VARCHAR2,
          x_ticket           OUT NOCOPY RAW,
          x_return_status    OUT NOCOPY VARCHAR2 );

END;

/
