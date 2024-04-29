--------------------------------------------------------
--  DDL for Package PA_ASSET_ALLOCATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ASSET_ALLOCATION_PVT" AUTHID CURRENT_USER AS
/* $Header: PACASALS.pls 120.1.12010000.2 2008/08/06 11:35:25 atshukla ship $ */


    --Do not alter the structure of this record or table type, as it
    --must match the structure sent to the PA_CLIENT_EXTN_ASSET_ALLOC.
    --ASSET_ALLOC_BASIS procedure
    TYPE asset_basis_type IS RECORD (
         project_asset_id       NUMBER NOT NULL := 0,
         asset_basis_amount     NUMBER,
         total_basis_amount     NUMBER);

    TYPE asset_basis_table_type IS TABLE OF asset_basis_type
       INDEX BY BINARY_INTEGER;


    --These Globals are used for cache purposes, so that the basis
    --table is not needlessly reconstructed for identical lines processed
    --consecutively.
    G_project_id                NUMBER := -99;  /*bug4991824*/
    G_task_id                   NUMBER := -99;
    G_capital_event_id          NUMBER := -99;
    G_asset_category_id         NUMBER := -99;  -- Added for bug 7175027
    G_line_type                 VARCHAR2(30) := 'ZZZ';
    G_asset_allocation_method   VARCHAR2(30) := 'ZZZ';
    G_asset_basis_table         asset_basis_table_type;


PROCEDURE ALLOCATE_UNASSIGNED
	                       (p_project_asset_line_id     IN      NUMBER,
                           p_line_type                  IN      VARCHAR2,
                           p_capital_event_id           IN      NUMBER,
                           p_project_id                 IN      NUMBER,
                           p_task_id 	                IN	    NUMBER,
                           p_asset_allocation_method    IN      VARCHAR2,
                           p_asset_category_id          IN      NUMBER, /* Added for bug#3211946  */
                           x_asset_or_project_err          OUT NOCOPY VARCHAR2,
                           x_error_code                    OUT NOCOPY VARCHAR2,
                           x_err_asset_id                  OUT NOCOPY NUMBER,
                           x_return_status                 OUT NOCOPY VARCHAR2,
                           x_msg_count                     OUT NOCOPY NUMBER,
                           x_msg_data                      OUT NOCOPY VARCHAR2);


END PA_ASSET_ALLOCATION_PVT;

/
