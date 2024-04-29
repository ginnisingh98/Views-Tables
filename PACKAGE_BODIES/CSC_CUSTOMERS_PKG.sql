--------------------------------------------------------
--  DDL for Package Body CSC_CUSTOMERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_CUSTOMERS_PKG" as
/*$Header: csctcccb.pls 115.7 2004/04/27 10:26:23 vshastry ship $*/

procedure process_audit_table (
	x_party_id				NUMBER,
	x_cust_account_id		     NUMBER,
	x_last_update_date			DATE,
	x_last_updated_by			NUMBER,
	x_last_update_login			NUMBER,
	x_creation_date			DATE,
	x_created_by				NUMBER,
	x_sys_det_critical_flag		VARCHAR2,
	x_override_flag			VARCHAR2,
	x_overridden_critical_flag	VARCHAR2,
	x_override_reason_code		VARCHAR2,
	p_party_status                VARCHAR2  DEFAULT NULL,
	p_request_id                  NUMBER    DEFAULT NULL,
	p_program_application_id      NUMBER    DEFAULT NULL,
	p_program_id                  NUMBER    DEFAULT NULL,
	p_program_update_date         DATE      DEFAULT NULL);

procedure insert_row(
	x_rowid					IN OUT NOCOPY VARCHAR2,
	x_party_id	 			NUMBER,
	x_cust_account_id		        NUMBER,
	x_last_update_date       	        DATE,
	x_last_updated_by			NUMBER,
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
	p_party_status                VARCHAR2   DEFAULT NULL,
	p_request_id                  NUMBER     DEFAULT NULL,
	p_program_application_id      NUMBER     DEFAULT NULL,
	p_program_id                  NUMBER     DEFAULT NULL,
	p_program_update_date         DATE       DEFAULT NULL)
IS
CURSOR C is select rowid from csc_customers
			where party_id = x_party_id;
/*

CURSOR C1 is select pc.value from cs_prof_check_results pc
             where pc.check_id (+) =
               fnd_profile.value_wnps ('CS_CRITICAL_CUSTOMER_CHECK')
             and pc.customer_id = x_customer_id;
*/

BEGIN
	INSERT INTO csc_customers
	(
			party_id,
			cust_account_id,
			last_update_date,
			last_updated_by,
			last_update_login,
			creation_date,
			created_by,
			override_flag,
			overridden_critical_flag,
			override_reason_code,
                        party_status,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date,
                        attribute1,
                        attribute2,
                        attribute3,
                        attribute4,
                        attribute5,
                        attribute6,
                        attribute7,
                        attribute8,
                        attribute9,
                        attribute10,
                        attribute11,
                        attribute12,
                        attribute13,
                        attribute14,
                        attribute15
        )
        VALUES
	(
			DECODE(x_party_id,FND_API.G_MISS_NUM,NULL,x_party_id),
			DECODE(x_cust_account_id,FND_API.G_MISS_NUM,NULL,x_cust_account_id),
			DECODE(x_last_update_date,FND_API.G_MISS_DATE,NULL,x_last_update_date),
			DECODE(x_last_updated_by,FND_API.G_MISS_NUM,NULL,x_last_updated_by),
			DECODE(x_last_update_login,FND_API.G_MISS_NUM,NULL,x_last_update_login),
			DECODE(x_creation_date,FND_API.G_MISS_DATE,NULL,x_creation_date),
			DECODE(x_created_by,FND_API.G_MISS_NUM,NULL,x_created_by),
			DECODE(x_override_flag,FND_API.G_MISS_CHAR,NULL,x_override_flag),
			DECODE(x_overridden_critical_flag,FND_API.G_MISS_CHAR,NULL,x_overridden_critical_flag),
			DECODE(x_override_reason_code,FND_API.G_MISS_CHAR,NULL,x_override_reason_code),
	                DECODE(p_party_status,FND_API.G_MISS_CHAR,NULL,p_party_status),
                        DECODE(p_request_id,FND_API.G_MISS_NUM,NULL,p_request_id),
                        DECODE(p_program_application_id,FND_API.G_MISS_NUM,NULL,p_program_application_id),
                        DECODE(p_program_id,FND_API.G_MISS_NUM,NULL,p_program_id),
                        DECODE(p_program_update_date,FND_API.G_MISS_DATE,NULL,p_program_update_date),
                        x_attribute1,
                        x_attribute2,
                        x_attribute3,
                        x_attribute4,
                        x_attribute5,
                        x_attribute6,
                        x_attribute7,
                        x_attribute8,
                        x_attribute9,
                        x_attribute10,
                        x_attribute11,
                        x_attribute12,
                        x_attribute13,
                        x_attribute14,
                        x_attribute15
        );
	OPEN C;
	FETCH C into x_rowid;
	if (C%NOTFOUND) then
		CLOSE C;
		RAISE NO_DATA_FOUND;
	end if;
	CLOSE C;

	process_audit_table (
		x_party_id,
		x_cust_account_id,
		x_last_update_date,
		x_last_updated_by,
		x_last_update_login,
		x_creation_date,
		x_created_by,
		x_sys_det_critical_flag,
		x_override_flag,
		x_overridden_critical_flag,
		x_override_reason_code,
		p_party_status,
		p_request_id,
		p_program_application_id,
		p_program_id,
		p_program_update_date );

END insert_row;

procedure process_audit_table(
	x_party_id		          NUMBER,
	x_cust_account_id             NUMBER,
	x_last_update_date	          DATE,
	x_last_updated_by	          NUMBER,
	x_last_update_login	          NUMBER,
	x_creation_date	          DATE,
	x_created_by		          NUMBER,
	x_sys_det_critical_flag	     VARCHAR2,
	x_override_flag		     VARCHAR2,
	x_overridden_critical_flag	VARCHAR2,
	x_override_reason_code		VARCHAR2,
	p_party_status                VARCHAR2  DEFAULT NULL,
	p_request_id                  NUMBER    DEFAULT NULL,
	p_program_application_id      NUMBER    DEFAULT NULL,
	p_program_id                  NUMBER    DEFAULT NULL,
	p_program_update_date         DATE      DEFAULT NULL)
IS
x_cust_hist_id number;
cursor C2 is select csc_customers_audit_hist_s.nextval from sys.dual;

/*
x_sys_det_critical_flag varchar2(1);
cursor C1 is select pc.value
	from cs_prof_check_results pc
	where pc.check_id (+) =
					fnd_profile.value_wnps ('CS_CRITICAL_CUSTOMER_CHECK')
	and pc.customer_id = x_customer_id;
*/

begin

if x_cust_hist_id is null then
open C2;
fetch C2 into x_cust_hist_id;
close C2;
end if;

/*
if x_sys_det_critical_flag is null then
open C1;
fetch C1 into x_sys_det_critical_flag;
close C1;
end if;
*/

-- Bug 1352203 - while inserting, the changed by field should be
-- populated with last_updated_by instead of created_by
insert into csc_customers_audit_hist (
	cust_hist_id,
	party_id,
	cust_account_id,
	last_update_date,
	last_updated_by,
	last_update_login,
	creation_date,
	created_by,
	changed_date,
	changed_by,
	sys_det_critical_flag,
	override_flag,
	overridden_critical_flag,
	override_reason_code,
	party_status,
	request_id,
	program_application_id,
	program_id,
	program_update_date )
values (
	x_cust_hist_id,
	x_party_id,
	x_cust_account_id,
	sysdate,
	x_last_updated_by,
	x_last_update_login,
	sysdate,
	x_created_by,
	sysdate,
	x_last_updated_by,
	x_sys_det_critical_flag,
	x_override_flag,
        x_overridden_critical_flag,
	x_override_reason_code,
	p_party_status,
	p_request_id,
	p_program_application_id,
	p_program_id,
	p_program_update_date );
/*
open C2;
fetch C2 into x_rowid;
if (C2%NOTFOUND) then
close C2;
RAISE NO_DATA_FOUND;
end if;
close C2;
*/
end process_audit_table;


Procedure lock_row(
			x_rowid					VARCHAR2,
			x_party_id				NUMBER,
			x_cust_account_id			NUMBER,
			x_last_update_date			DATE,
			x_last_updated_by			NUMBER,
			x_last_update_login			NUMBER,
			x_creation_date			DATE,
			x_created_by				NUMBER,
			x_override_flag			VARCHAR2,
			x_overridden_critical_flag	VARCHAR2,
			x_override_reason_code		VARCHAR2
			) IS
			CURSOR C is
			select *
			from csc_customers
			where rowid = x_rowid
			for update of party_id NOWAIT;
			Recinfo C%ROWTYPE;
			BEGIN
			OPEN C;
			FETCH C INTO recinfo;
			if (C%NOTFOUND) then
			CLOSE C;
			FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
			APP_EXCEPTION.Raise_Exception;
			end if;
			CLOSE C;
			if(
					(Recinfo.party_id = x_party_id)
				AND  (	(Recinfo.last_update_date = x_last_update_date)
					OR (	(Recinfo.last_update_date is null)
						AND (x_last_update_date IS NULL)))
				AND	(	(Recinfo.last_updated_by = x_last_updated_by)
					OR (	(Recinfo.last_updated_by is null)
						AND (x_last_updated_by IS NULL)))
				AND	(	(Recinfo.last_update_login = x_last_update_login)
					OR (	(Recinfo.last_update_login is null)
						AND (x_last_update_login IS NULL)))
				AND	(	(Recinfo.creation_date = x_creation_date)
					OR (	(Recinfo.creation_date is null)
						AND (x_creation_date IS NULL)))
				AND	(	(Recinfo.created_by = x_created_by)
					OR (	(Recinfo.created_by is null)
						AND (x_created_by IS NULL)))
				AND	(	(Recinfo.override_flag = x_override_flag)
					OR (	(Recinfo.override_flag is null)
						AND (x_override_flag IS NULL)))
				AND	(	(Recinfo.overridden_critical_flag = x_overridden_critical_flag)
					OR (	(Recinfo.overridden_critical_flag is null)
						AND (x_overridden_critical_flag IS NULL)))
				AND (	(Recinfo.override_reason_code = x_override_reason_code)
					OR (	(Recinfo.override_reason_code is null)
						AND (x_override_reason_code IS NULL)))
				 ) then
				return;
			else
				fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
				APP_EXCEPTION.Raise_Exception;
			end if;
end lock_row;

procedure update_row(
	x_rowid					VARCHAR2,
	x_party_id				NUMBER,
	x_cust_account_id		        NUMBER,
	x_last_update_date			DATE,
	x_last_updated_by			NUMBER,
	x_last_update_login			NUMBER,
	x_creation_date			        DATE,
	x_created_by				NUMBER,
	x_sys_det_critical_flag	                VARCHAR2,
	x_override_flag		                VARCHAR2,
	x_overridden_critical_flag              VARCHAR2,
	x_override_reason_code	                VARCHAR2,
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
	p_party_status                VARCHAR2   DEFAULT NULL,
	p_request_id                  NUMBER     DEFAULT NULL,
	p_program_application_id      NUMBER     DEFAULT NULL,
	p_program_id                  NUMBER     DEFAULT NULL,
	p_program_update_date         DATE       DEFAULT NULL)
IS
begin
	update csc_customers
	set
	        party_id                        =  DECODE(x_party_id,FND_API.G_MISS_NUM,NULL,NVL(x_party_id,party_id)),
		cust_account_id 		=  DECODE(x_cust_account_id,FND_API.G_MISS_NUM,NULL,NVL(x_cust_account_id,cust_account_id)),
                last_update_date		=  DECODE(x_last_update_date,FND_API.G_MISS_DATE,NULL,NVL(x_last_update_date,last_update_date)),
		last_updated_by	   =	DECODE(x_last_updated_by,FND_API.G_MISS_CHAR,NULL,NVL(x_last_updated_by,last_updated_by)),
		last_update_login		=	DECODE(x_last_update_login,FND_API.G_MISS_NUM,NULL,NVL(x_last_update_login,last_update_login)),
		--creation_date	   =	x_creation_date,
		--created_by			=	x_created_by,
		override_flag			=	DECODE(x_override_flag,FND_API.G_MISS_CHAR,NULL,NVL(x_override_flag,override_flag)),
		overridden_critical_flag	=	DECODE(x_overridden_critical_flag,FND_API.G_MISS_CHAR,NULL,NVL(x_overridden_critical_flag,overridden_critical_flag)),
		override_reason_code	=	DECODE(x_override_reason_code,FND_API.G_MISS_CHAR,NULL,NVL(x_override_reason_code,override_reason_code)),
		party_status			=	DECODE(p_party_status,FND_API.G_MISS_CHAR,NULL,NVL(p_party_status,party_status)),
		request_id			   =	DECODE(p_request_id,FND_API.G_MISS_NUM,NULL,NVL(p_request_id,request_id)),
		program_application_id   =	DECODE(p_program_application_id,FND_API.G_MISS_NUM,NULL,NVL(p_program_application_id,program_application_id)),
		program_id			    =	DECODE(p_program_id,FND_API.G_MISS_NUM,NULL,NVL(p_program_id,program_id)),
		program_update_date   = DECODE(p_program_update_date,FND_API.G_MISS_DATE,NULL,NVL(p_program_update_date,program_update_date)),
                attribute1  =  x_attribute1,
                attribute2  =  x_attribute2,
                attribute3  =  x_attribute3,
                attribute4  =  x_attribute4,
                attribute5  =  x_attribute5,
                attribute6  =  x_attribute6,
                attribute7  =  x_attribute7,
                attribute8  =  x_attribute8,
                attribute9  =  x_attribute9,
                attribute10 =  x_attribute10,
                attribute11 =  x_attribute11,
                attribute12 =  x_attribute12,
                attribute13 =  x_attribute13,
                attribute14 =  x_attribute14,
                attribute15 =  x_attribute15
	where rowid = x_rowid;

	if (SQL%NOTFOUND) then
		raise NO_DATA_FOUND;
	end if;

	process_audit_table (
		x_party_id,
		x_cust_account_id,
		x_last_update_date,
		x_last_updated_by,
		x_last_update_login,
		x_creation_date,
		x_created_by,
		--x_changed_date,
		--x_changed_by,
		x_sys_det_critical_flag,
		x_override_flag,
		x_overridden_critical_flag,
		x_override_reason_code,
		p_party_status,
		p_request_id,
		p_program_application_id,
		p_program_id,
		p_program_update_date );
end update_row;
/*
procedure delete_row(x_rowid varchar2) is
begin
	delete from cs_contacts
	where rowid = x_rowid;
	if (SQL%NOTFOUND) then
		raise NO_DATA_FOUND;
	end if;
end delete_row;
*/

end csc_customers_pkg;

/
