--------------------------------------------------------
--  DDL for Package WSH_OTM_SYNC_REF_DATA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_OTM_SYNC_REF_DATA_PKG" AUTHID CURRENT_USER AS
/* $Header: WSHTMTHS.pls 120.0.12000000.1 2007/01/25 16:15:17 amohamme noship $ */

PROCEDURE is_ref_data_send_reqd(p_entity_id IN NUMBER,
				p_parent_entity_id IN VARCHAR2,
				p_entity_type IN VARCHAR2,
				p_entity_updated_date IN DATE,
				x_substitute_entity OUT NOCOPY VARCHAR2,
				p_transmission_id IN NUMBER,
				x_send_allowed OUT NOCOPY BOOLEAN,
				x_return_status OUT NOCOPY VARCHAR2
				);

PROCEDURE update_ref_data(	p_transmission_id IN NUMBER,
				p_transmission_status IN VARCHAR2,
				x_return_status OUT NOCOPY VARCHAR2
				);

PROCEDURE insert_row_sync_ref_data(	p_entity_id IN NUMBER,
					p_parent_entity_id IN NUMBER,
					p_entity_type IN VARCHAR2,
					p_transmission_id IN NUMBER,
                                        x_sync_ref_id     OUT NOCOPY NUMBER,
					x_substitute_entity OUT NOCOPY VARCHAR2,
					x_return_status OUT NOCOPY VARCHAR2
				  );

PROCEDURE insert_row_sync_ref_data_log(	p_sync_ref_id IN NUMBER,
					p_transmission_id IN NUMBER,
                                        p_entity_type IN VARCHAR2,
					x_return_status OUT NOCOPY VARCHAR2
				       );


END WSH_OTM_SYNC_REF_DATA_PKG;

 

/
