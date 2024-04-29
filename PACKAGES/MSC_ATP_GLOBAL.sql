--------------------------------------------------------
--  DDL for Package MSC_ATP_GLOBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_ATP_GLOBAL" AUTHID CURRENT_USER AS
/* $Header: MSCGLBLS.pls 120.1 2007/12/12 10:29:06 sbnaik ship $  */

G_APS_VERSION       NUMBER := 10;

PROCEDURE Extend_Atp (
  p_atp_tab             IN OUT NOCOPY  MRP_ATP_PUB.ATP_Rec_Typ,
  x_return_status       OUT      NoCopy VARCHAR2,
  p_index               IN       NUMBER  DEFAULT 1
);


FUNCTION Get_APS_Version
RETURN Number;

Procedure Get_ATP_Session_Id (
              x_session_id       OUT NOCOPY NUMBER,
              x_return_status    OUT NOCOPY VARCHAR2);


END MSC_ATP_GLOBAL;

/
