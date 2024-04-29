--------------------------------------------------------
--  DDL for Package WSH_SAVED_QUERIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_SAVED_QUERIES_PKG" AUTHID CURRENT_USER as
/* $Header: WSHQACTS.pls 115.4 2002/11/13 20:47:19 nparikh ship $ */


procedure insert_row(
  X_rowid				  out NOCOPY  varchar2,
  X_query_id			          out NOCOPY  number,
  X_name				  varchar2,
  X_description				  varchar2,
  X_entity_type			          varchar2,
  X_shared_flag			          varchar2,
  X_pseudo_query			  long,
  X_attribute_category			  varchar2,
  X_attribute1				  varchar2,
  X_attribute2				  varchar2,
  X_attribute3				  varchar2,
  X_attribute4				  varchar2,
  X_attribute5				  varchar2,
  X_attribute6				  varchar2,
  X_attribute7				  varchar2,
  X_attribute8				  varchar2,
  X_attribute9				  varchar2,
  X_attribute10				  varchar2,
  X_attribute11				  varchar2,
  X_attribute12				  varchar2,
  X_attribute13				  varchar2,
  X_attribute14				  varchar2,
  X_attribute15				  varchar2,
  X_creation_date			  date,
  X_created_by			          number,
  X_last_update_date		          date,
  X_last_updated_by		          number,
  X_last_update_login			  number,
  X_program_application_id 		  number,
  X_program_id				  number,
  X_program_update_date			  date,
  X_request_id				  number
);

procedure lock_row(
  X_query_id			          number,
  X_name				  varchar2,
  X_description				  varchar2,
  X_entity_type			          varchar2,
  X_shared_flag			          varchar2,
  X_pseudo_query			  long,
  X_attribute_category			  varchar2,
  X_attribute1				  varchar2,
  X_attribute2				  varchar2,
  X_attribute3				  varchar2,
  X_attribute4				  varchar2,
  X_attribute5				  varchar2,
  X_attribute6				  varchar2,
  X_attribute7				  varchar2,
  X_attribute8				  varchar2,
  X_attribute9				  varchar2,
  X_attribute10				  varchar2,
  X_attribute11				  varchar2,
  X_attribute12				  varchar2,
  X_attribute13				  varchar2,
  X_attribute14				  varchar2,
  X_attribute15				  varchar2,
  X_creation_date			  date,
  X_created_by			          number,
  X_last_update_date		          date,
  X_last_updated_by		          number,
  X_last_update_login			  number,
  X_program_application_id 		  number,
  X_program_id				  number,
  X_program_update_date			  date,
  X_request_id				  number
);

procedure update_row(
  X_query_id			          number,
  X_name				  varchar2,
  X_description				  varchar2,
  X_entity_type			          varchar2,
  X_shared_flag			          varchar2,
  X_pseudo_query			  long,
  X_attribute_category			  varchar2,
  X_attribute1				  varchar2,
  X_attribute2				  varchar2,
  X_attribute3				  varchar2,
  X_attribute4				  varchar2,
  X_attribute5				  varchar2,
  X_attribute6				  varchar2,
  X_attribute7				  varchar2,
  X_attribute8				  varchar2,
  X_attribute9				  varchar2,
  X_attribute10				  varchar2,
  X_attribute11				  varchar2,
  X_attribute12				  varchar2,
  X_attribute13				  varchar2,
  X_attribute14				  varchar2,
  X_attribute15				  varchar2,
  X_last_update_date		          date,
  X_last_updated_by		          number,
  X_last_update_login			  number,
  X_program_application_id 		  number,
  X_program_id				  number,
  X_program_update_date			  date,
  X_request_id				  number
);

procedure delete_row(X_query_id wsh_saved_queries_b.query_id%type);

procedure add_language;

end wsh_saved_queries_pkg;

 

/
