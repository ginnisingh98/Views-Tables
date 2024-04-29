--------------------------------------------------------
--  DDL for Package WSH_DELIVERY_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_DELIVERY_UTIL" 
-- $Header: WSHDLUTS.pls 115.4 2002/11/16 00:29:13 bsadri ship $
AUTHID CURRENT_USER AS


C_SDEBUG              CONSTANT   NUMBER := wsh_debug_sv.C_LEVEL1;
C_DEBUG               CONSTANT   NUMBER := wsh_debug_sv.C_LEVEL2;

G_INBOUND_FLAG		BOOLEAN := FALSE;


PROCEDURE Update_Dlvy_Status( p_delivery_id	IN NUMBER,
			      p_action_code   IN VARCHAR2 ,
			      p_document_type IN VARCHAR2 ,
			      x_return_status OUT NOCOPY  VARCHAR2
			 );
FUNCTION Is_SendDoc_Allowed( p_delivery_id	IN NUMBER,
			    p_action_code IN VARCHAR2 DEFAULT 'A',
			    x_return_status OUT NOCOPY  VARCHAR2)
RETURN BOOLEAN;

PROCEDURE Check_Updates_Allowed( p_changed_attributes IN WSH_INTERFACE.ChangedAttributeTabType,
				 p_source_code IN VARCHAR2,
				 x_update_allowed OUT NOCOPY  VARCHAR2,
				 x_return_status OUT NOCOPY  VARCHAR2
				);
PROCEDURE Check_Actions_Allowed(x_entity_ids IN OUT NOCOPY  WSH_UTIL_CORE.Id_Tab_Type,
				p_entity_name IN VARCHAR2,
				p_action IN VARCHAR2,
				p_delivery_id IN NUMBER,
				x_err_entity_ids OUT NOCOPY  WSH_UTIL_CORE.Id_Tab_Type,
				x_return_status	OUT NOCOPY    VARCHAR2
				);


END WSH_DELIVERY_UTIL;

 

/
