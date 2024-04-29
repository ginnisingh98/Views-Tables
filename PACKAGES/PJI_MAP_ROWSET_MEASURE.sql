--------------------------------------------------------
--  DDL for Package PJI_MAP_ROWSET_MEASURE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_MAP_ROWSET_MEASURE" AUTHID CURRENT_USER as
-- $Header: PJIRWSTS.pls 120.0 2005/06/13 04:54:06 appldev noship $

procedure insert_row
	(p_rowset_code           IN VARCHAR2,
	 p_name                  IN VARCHAR2,
	 p_description           IN VARCHAR2,
	 x_msg_count             IN OUT NOCOPY NUMBER,
	 x_return_status         OUT NOCOPY VARCHAR2,
	 x_err_msg_data          OUT NOCOPY VARCHAR2) ;

procedure create_map
	(p_rowset_code               IN VARCHAR2,
	 p_measure_set_code_add_tb1  IN SYSTEM.pa_varchar2_30_tbl_type,
	 p_measure_set_code_del_tb1  IN SYSTEM.pa_varchar2_30_tbl_type,
	 p_object_version_number     IN NUMBER,
	 x_msg_count                 IN OUT NOCOPY NUMBER,
	 x_return_status             OUT NOCOPY VARCHAR2,
	 x_err_msg_data              OUT NOCOPY VARCHAR2);

procedure update_row
	(p_rowset_code           IN VARCHAR2,
	 p_name                  IN VARCHAR2,
	 p_description           IN VARCHAR2,
	 p_object_version_number IN NUMBER,
	 x_msg_count             IN OUT NOCOPY NUMBER,
	 x_return_status         OUT NOCOPY VARCHAR2,
	 x_err_msg_data          OUT NOCOPY VARCHAR2) ;

procedure delete_row
	(p_rowset_code           IN VARCHAR2,
	 x_msg_count             IN OUT NOCOPY NUMBER,
	 x_return_status         OUT NOCOPY VARCHAR2,
	 x_err_msg_data          OUT NOCOPY VARCHAR2) ;


end PJI_MAP_ROWSET_MEASURE;

 

/
