--------------------------------------------------------
--  DDL for Package FLM_KANBAN_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FLM_KANBAN_SUMMARY_PKG" AUTHID CURRENT_USER AS
/* $Header: FLMKBNSS.pls 115.2 2002/11/27 11:02:35 nrajpal noship $ */


PROCEDURE Insert_Row(X_rowid                  IN OUT NOCOPY VARCHAR2,
		     X_summary_id	      IN OUT NOCOPY NUMBER,
                     X_organization_id      	     	    NUMBER,
                     X_summary_type                         NUMBER,
                     X_summary_code                         VARCHAR2,
                     X_kanban_plan_id			    NUMBER,
                     X_node_type			    NUMBER,
                     X_source_organization_id               NUMBER,
                     X_supplier_id                          NUMBER,
                     X_supplier_site_id                     NUMBER,
                     X_subinventory_name                    VARCHAR2,
                     X_locator_id                           NUMBER,
                     X_wip_line_id                          NUMBER,
                     X_x		                    NUMBER,
                     X_y                                    NUMBER);


PROCEDURE Lock_Row(  X_rowid                                VARCHAR2,
		     X_summary_id		            NUMBER,
                     X_organization_id      	     	    NUMBER,
                     X_summary_type                         NUMBER,
                     X_summary_code                         VARCHAR2,
                     X_kanban_plan_id			    NUMBER,
                     X_node_type			    NUMBER,
                     X_source_organization_id               NUMBER,
                     X_supplier_id                          NUMBER,
                     X_supplier_site_id                     NUMBER,
                     X_subinventory_name                    VARCHAR2,
                     X_locator_id                           NUMBER,
                     X_wip_line_id                          NUMBER,
                     X_x		                    NUMBER,
                     X_y                                    NUMBER);


PROCEDURE Update_Row(X_rowid                                VARCHAR2,
		     X_summary_id		            NUMBER,
                     X_organization_id      	     	    NUMBER,
                     X_summary_type                         NUMBER,
                     X_summary_code                         VARCHAR2,
                     X_kanban_plan_id			    NUMBER,
                     X_node_type			    NUMBER,
                     X_source_organization_id               NUMBER,
                     X_supplier_id                          NUMBER,
                     X_supplier_site_id                     NUMBER,
                     X_subinventory_name                    VARCHAR2,
                     X_locator_id                           NUMBER,
                     X_wip_line_id                          NUMBER,
                     X_x		                    NUMBER,
                     X_y                                    NUMBER);


PROCEDURE Delete_Row(X_rowid VARCHAR2);


END FLM_KANBAN_SUMMARY_PKG;

 

/
