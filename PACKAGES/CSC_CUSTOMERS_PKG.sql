--------------------------------------------------------
--  DDL for Package CSC_CUSTOMERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_CUSTOMERS_PKG" AUTHID CURRENT_USER as
/*$Header: csctcccs.pls 115.4 2004/04/27 10:24:51 vshastry ship $*/
procedure insert_row(
	x_rowid					IN OUT NOCOPY VARCHAR2,
	x_party_id				NUMBER,
	x_cust_account_id		        NUMBER,
	x_last_update_date			DATE,
        x_last_updated_by		        NUMBER,
	x_last_update_login			NUMBER,
	x_creation_date			        DATE,
	x_created_by				NUMBER,
	x_sys_det_critical_flag		        VARCHAR2,
	x_override_flag			        VARCHAR2,
	x_overridden_critical_flag	        VARCHAR2,
	x_override_reason_code		        VARCHAR2,
        x_attribute1                            VARCHAR2 DEFAULT NULL,
        x_attribute2                            VARCHAR2 DEFAULT NULL,
        x_attribute3                            VARCHAR2 DEFAULT NULL,
        x_attribute4                            VARCHAR2 DEFAULT NULL,
        x_attribute5                            VARCHAR2 DEFAULT NULL,
        x_attribute6                            VARCHAR2 DEFAULT NULL,
        x_attribute7                            VARCHAR2 DEFAULT NULL,
        x_attribute8                            VARCHAR2 DEFAULT NULL,
        x_attribute9                            VARCHAR2 DEFAULT NULL,
        x_attribute10                           VARCHAR2 DEFAULT NULL,
        x_attribute11                           VARCHAR2 DEFAULT NULL,
        x_attribute12                           VARCHAR2 DEFAULT NULL,
        x_attribute13                           VARCHAR2 DEFAULT NULL,
        x_attribute14                           VARCHAR2 DEFAULT NULL,
        x_attribute15                           VARCHAR2 DEFAULT NULL,
	p_party_status                VARCHAR2  DEFAULT NULL,
	p_request_id                  NUMBER    DEFAULT NULL,
	p_program_application_id      NUMBER    DEFAULT NULL,
	p_program_id                  NUMBER    DEFAULT NULL,
	p_program_update_date         DATE      DEFAULT NULL );

procedure lock_row(
	x_rowid					VARCHAR2,
	x_party_id				NUMBER,
	x_cust_account_id		     NUMBER,
     x_last_update_date			DATE,
	x_last_updated_by			NUMBER,
	x_last_update_login			NUMBER,
	x_creation_date			DATE,
	x_created_by				NUMBER,
	x_override_flag			VARCHAR2,
	x_overridden_critical_flag	VARCHAR2,
	x_override_reason_code		VARCHAR2);


procedure update_row(
	x_rowid					VARCHAR2,
	x_party_id				NUMBER,
	x_cust_account_id		        NUMBER,
	x_last_update_date			DATE,
	x_last_updated_by			NUMBER,
	x_last_update_login			NUMBER,
	x_creation_date	         		DATE,
	x_created_by				NUMBER,
	x_sys_det_critical_flag	        	VARCHAR2,
	x_override_flag			        VARCHAR2,
	x_overridden_critical_flag       	VARCHAR2,
	x_override_reason_code		        VARCHAR2,
        x_attribute1                            VARCHAR2 DEFAULT NULL,
        x_attribute2                            VARCHAR2 DEFAULT NULL,
        x_attribute3                            VARCHAR2 DEFAULT NULL,
        x_attribute4                            VARCHAR2 DEFAULT NULL,
        x_attribute5                            VARCHAR2 DEFAULT NULL,
        x_attribute6                            VARCHAR2 DEFAULT NULL,
        x_attribute7                            VARCHAR2 DEFAULT NULL,
        x_attribute8                            VARCHAR2 DEFAULT NULL,
        x_attribute9                            VARCHAR2 DEFAULT NULL,
        x_attribute10                           VARCHAR2 DEFAULT NULL,
        x_attribute11                           VARCHAR2 DEFAULT NULL,
        x_attribute12                           VARCHAR2 DEFAULT NULL,
        x_attribute13                           VARCHAR2 DEFAULT NULL,
        x_attribute14                           VARCHAR2 DEFAULT NULL,
        x_attribute15                           VARCHAR2 DEFAULT NULL,
	p_party_status                VARCHAR2 DEFAULT NULL,
	p_request_id                  NUMBER   DEFAULT NULL,
	p_program_application_id      NUMBER   DEFAULT NULL,
	p_program_id                  NUMBER   DEFAULT NULL,
	p_program_update_date         DATE     DEFAULT NULL);

end csc_customers_pkg;

 

/
