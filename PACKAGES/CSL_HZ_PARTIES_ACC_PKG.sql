--------------------------------------------------------
--  DDL for Package CSL_HZ_PARTIES_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_HZ_PARTIES_ACC_PKG" AUTHID CURRENT_USER AS
/* $Header: cslpaacs.pls 115.6 2003/07/23 23:51:15 yliao ship $ */

PROCEDURE INSERT_PARTY( p_party_id    IN NUMBER
                      , p_resource_id IN NUMBER
		      , p_flow_type   IN NUMBER DEFAULT CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_NORMAL);

PROCEDURE UPDATE_PARTY( p_party_id IN NUMBER );

PROCEDURE DELETE_PARTY( p_party_id    IN NUMBER
                      , p_resource_id IN NUMBER
		      , p_flow_type   IN NUMBER DEFAULT CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_NORMAL);

PROCEDURE CHANGE_PARTY( p_old_party_id IN NUMBER
                      , p_new_party_id IN NUMBER
		      , p_resource_id IN NUMBER );

FUNCTION Replicate_Record( p_party_id IN NUMBER) RETURN BOOLEAN;

PROCEDURE PRE_INSERT_PARTY ( x_return_status OUT NOCOPY VARCHAR2);
/* Called before party Insert */

PROCEDURE POST_INSERT_PARTY ( x_return_status OUT NOCOPY VARCHAR2);
/* Called after party Insert */

PROCEDURE PRE_UPDATE_PARTY ( x_return_status OUT NOCOPY VARCHAR2);
/* Called before party Update */

PROCEDURE POST_UPDATE_PARTY ( x_return_status OUT NOCOPY VARCHAR2);
/* Called after party Update */

PROCEDURE PRE_DELETE_PARTY ( x_return_status OUT NOCOPY VARCHAR2);
/* Called before party Delete */

PROCEDURE POST_DELETE_PARTY ( x_return_status OUT NOCOPY VARCHAR2);
/* Called after party Delete */

FUNCTION UPDATE_PARTY_WFSUB( p_subscription_guid   in     raw
               , p_event               in out NOCOPY wf_event_t)
return varchar2;

END CSL_HZ_PARTIES_ACC_PKG;

 

/
