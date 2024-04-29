--------------------------------------------------------
--  DDL for Package Body RRS_IMPORT_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RRS_IMPORT_INTERFACE_PKG" as
/* $Header: RRSIMINB.pls 120.0.12010000.32 2010/02/05 22:14:44 sunarang noship $ */



  ----------------------------------------------------------------------------
  -- Global constants
  ----------------------------------------------------------------------------
  G_PKG_NAME                          CONSTANT VARCHAR2(30) := 'RRS_IMPORT_INTERFACE_PKG';
  G_REQUEST_ID                        NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
  G_PROGAM_APPLICATION_ID             NUMBER := FND_GLOBAL.PROG_APPL_ID;
  G_PROGAM_ID                         NUMBER := FND_GLOBAL.CONC_PROGRAM_ID;
  G_USER_NAME                         FND_USER.USER_NAME%TYPE := FND_GLOBAL.USER_NAME;
  G_USER_ID                           NUMBER := FND_GLOBAL.USER_ID;
  G_LOGIN_ID                          NUMBER := FND_GLOBAL.LOGIN_ID;
  G_CURRENT_USER_ID                   NUMBER;
  G_CURRENT_LOGIN_ID                  NUMBER;
  G_HZ_PARTY_ID                       VARCHAR2(30);
  G_ADD_ERRORS_TO_FND_STACK           VARCHAR2(1);
  G_APPLICATION_CONTEXT               VARCHAR2(30);
  G_DATE_FORMAT                       CONSTANT VARCHAR2(30) := 'SYYYY-MM-DD HH24:MI:SS';

  G_APPLICATION_ID                    NUMBER(3) := 718;
  G_DATA_ROWS_UPLOADED_NEW            CONSTANT NUMBER := 0;
  G_PS_TO_BE_PROCESSED                CONSTANT VARCHAR2(1) := 1;
  G_PS_IN_PROCESS                     CONSTANT VARCHAR2(1) := 2;
  G_PS_GENERIC_ERROR                  CONSTANT VARCHAR2(1) := 3;
  G_PS_SUCCESS                        CONSTANT VARCHAR2(1) := 4;
  G_RETCODE_SUCCESS_WITH_WARNING      CONSTANT VARCHAR(1) := 'W';

  G_TX_TYPE_CREATE		      CONSTANT VARCHAR2(6) := 'CREATE';
  G_TX_TYPE_UPDATE		      CONSTANT VARCHAR2(6) := 'UPDATE';




local_processing_errors  rrs_processing_errors_tab;


Procedure main(
ERRBUF 				OUT NOCOPY 	VARCHAR2
,RETCODE 			OUT NOCOPY 	VARCHAR2
,p_batch_id                     IN              NUMBER
,p_purge_rows                	IN 		VARCHAR2
,p_gather_stats                	IN 		VARCHAR2
) is
l_batch_id					NUMBER;
l_data_set_id					NUMBER;
x_return_status					VARCHAR2(1);
x_verify_sites_data				VARCHAR2(1);
x_return_flag					VARCHAR2(1);
l_site_exist					VARCHAR2(1) := 'N';
l_loc_exist					VARCHAR2(1) := 'N';
l_ta_exist					VARCHAR2(1) := 'N';
conc_status					Boolean;

begin

FND_FILE.put_line(FND_FILE.LOG, 'Batch ID : '||p_batch_id);
FND_FILE.put_line(FND_FILE.LOG, 'Purge Processed Rows : '||p_purge_rows);
FND_FILE.put_line(FND_FILE.LOG, 'Gather Statistics on Interface Tables : '||p_gather_stats);

x_return_status := 'S';
x_verify_sites_data := 'S';

begin
select 	'S'
into	x_verify_sites_data
from 	RRS_SITES_INTERFACE
WHERE 	batch_id = p_batch_id
and 	Process_status = G_PS_TO_BE_PROCESSED
and	rownum < 2;
exception
	When no_data_found then
		x_verify_sites_data := 'E';

end;
	check_prereqs( p_batch_id => p_batch_id
			,x_return_status => x_return_status
			);

if x_return_status = 'S'  AND x_verify_sites_data = 'S' then
/*
	check_prereqs( p_batch_id => p_batch_id
			,x_return_status => x_return_status
			);
*/

/********************************************************************
 * 	This Update is for defaulting the Address1 in case of Site
 * 	creation/updation using no value for address1 field. We are populating
 * 	the Site Name in Address1 field.
 * 	************************************************************/

	Update	RRS_SITES_INTERFACE
	Set	Address1 = Site_name
	where	batch_id = p_batch_id
	and 	process_status = G_PS_TO_BE_PROCESSED
	and	Address1 is NULL
	and	country is NOT NULL
	and 	rowid in (select 	rowid
			from 	RRS_SITES_INTERFACE
			where	batch_id = p_batch_id
			and     process_status = G_PS_TO_BE_PROCESSED
			and     Address1 is NULL);


	If p_gather_stats = 'Y' then

		fnd_stats.gather_table_stats('RRS','RRS_SITES_INTERFACE',cascade=>true,percent=>30);

	end if;


	Validate_new_rows( p_batch_id => p_batch_id
			, p_purge_rows => p_purge_rows
			,x_return_flag=>x_return_flag
			);


	Validate_update_rows( p_batch_id => p_batch_id
			,p_purge_rows => p_purge_rows
			,x_return_flag => x_return_flag
			);


end if ;

Begin
	select 	'Y'
	into 	l_site_exist
	from 	RRS_SITE_UA_INTF A
	where	a.batch_id = p_batch_id
	and	(A.SITE_ID is NOT NULL )
	and	(A.Process_status = G_PS_TO_BE_PROCESSED )
	and	rownum < 2;

Exception
	When NO_DATA_FOUND THEN
		l_site_exist := 'N';

End;

Begin
	select 	'Y'
	into 	l_loc_exist
	from 	RRS_LOCATION_UA_INTF A
	where	a.batch_id = p_batch_id
	and	(A.LOCATION_ID is NOT NULL )
	and	(A.Process_status = G_PS_TO_BE_PROCESSED )
	and	rownum < 2;

Exception
	When NO_DATA_FOUND THEN
		l_loc_exist := 'N';

End;

Begin
	select 	'Y'
	into 	l_ta_exist
	from 	RRS_TRADEAREA_UA_INTF A
	where	a.batch_id = p_batch_id
	and	(A.TRADE_AREA_ID is NOT NULL )
	and	(A.Process_status = G_PS_TO_BE_PROCESSED )
	and	rownum < 2;

Exception
	When NO_DATA_FOUND THEN
		l_ta_exist := 'N';

End;

	If ( l_site_exist = 'Y' OR l_loc_exist = 'Y' OR l_ta_exist = 'Y' )  then

		-- l_transaction_id := MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL;
		-- l_data_set_id := RRS_SITE_INTF_SETS_S.NEXTVAL;

		SELECT 	RRS_SITE_INTF_SETS_S.NEXTVAL
		INTO	l_data_set_id
		FROM 	DUAL;

		If l_site_exist = 'Y' then
		UPDATE 	RRS_SITE_UA_INTF
		SET 	DATA_SET_ID = l_data_set_id,
			Transaction_id = l_data_set_id,
			ATTR_GROUP_TYPE = 'RRS_SITEMGMT_GROUP',
			DATA_LEVEL_ID = 71802,
			DATA_LEVEL_NAME = 'SITE_LEVEL'
		where 	batch_id = p_batch_id
		and	SITE_ID is NOT NULL
		and	Process_status = G_PS_TO_BE_PROCESSED;

		If p_gather_stats = 'Y' then

			fnd_stats.gather_table_stats('RRS','RRS_SITE_UA_INTF',cascade=>true,percent=>30);

		end if;

		end if;

		If l_loc_exist = 'Y' then
		UPDATE 	RRS_LOCATION_UA_INTF
		SET 	DATA_SET_ID = l_data_set_id,
			Transaction_id = l_data_set_id,
			ATTR_GROUP_TYPE = 'RRS_LOCATION_GROUP',
			DATA_LEVEL_ID = 71801,
			DATA_LEVEL_NAME = 'LOCATION_LEVEL'
		where 	batch_id = p_batch_id
		and	LOCATION_ID is NOT NULL
		and	Process_status = G_PS_TO_BE_PROCESSED;

                If p_gather_stats = 'Y' then

                        fnd_stats.gather_table_stats('RRS','RRS_LOCATION_UA_INTF',cascade=>true,percent=>30);

                end if;


		end if;


		If l_ta_exist = 'Y' then
		UPDATE 	RRS_TRADEAREA_UA_INTF
		SET 	DATA_SET_ID = l_data_set_id,
			Transaction_id = l_data_set_id,
			ATTR_GROUP_TYPE = 'RRS_TRADE_AREA_GROUP',
			DATA_LEVEL_ID = 71803,
			DATA_LEVEL_NAME = 'TRADE_AREA_LEVEL'
		where 	batch_id = p_batch_id
		and	trade_area_id is not null
		and	Process_status = G_PS_TO_BE_PROCESSED;

                If p_gather_stats = 'Y' then

                        fnd_stats.gather_table_stats('RRS','RRS_TRADEAREA_UA_INTF',cascade=>true,percent=>30);

                end if;


		end if;


	RRS_SITE_UDA_BULKLOAD_INTF.LOAD_USERATTR_DATA( ERRBUF => errbuf
							,RETCODE => retcode
							,p_batch_id => p_batch_id
							,p_data_set_id => l_data_set_id
							,p_purge_successful_lines => p_purge_rows
							);

    IF (  RETCODE = FND_API.G_RET_STS_SUCCESS ) THEN
	conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('SUCCESS', 'Success: All the rows processed successfully.');
    ELSIF (  RETCODE = G_RETCODE_SUCCESS_WITH_WARNING ) THEN
	conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING', 'Warning: One or more rows errored due to validation checks. ');
    ELSIF (  RETCODE = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', 'Error: Unexpected Error happened while processing the Interface rows in this Batch.');

    END IF;

	end if;


end;

/************************************************************************************
 * 		This procedure check_prereqs will do the pre-req checks before starting the
 * 		validations. If pre-req checks fails than no other validation will happen
 * 		and process will stop immediately.
 * 		*********************************************************************/

Procedure check_prereqs(
p_batch_id			IN 		number
,x_return_status		OUT NOCOPY	varchar2
) is

l_count				number;

Type rrs_site_counts_rec is RECORD (
site_identification_number 	rrs_sites_interface.site_identification_number%Type
,site_count			number
);
Type rrs_site_counts_tab is Table of rrs_site_counts_rec;
l_site_counts 		rrs_site_counts_tab;

local_processing_errors         rrs_processing_errors_tab;
p_processing_errors             rrs_processing_errors_tab;

begin

p_processing_errors := rrs_processing_errors_tab();
local_processing_errors := rrs_processing_errors_tab();


SELECT	SITE_IDENTIFICATION_NUMBER , count(*)
BULK COLLECT
INTO 	l_site_counts
FROM	RRS_SITES_INTERFACE
WHERE	BATCH_ID = p_batch_id
AND	TRANSACTION_TYPE = G_TX_TYPE_CREATE
AND	PROCESS_STATUS = G_PS_TO_BE_PROCESSED
GROUP BY SITE_IDENTIFICATION_NUMBER
HAVING 	count(*) > 1;

IF l_site_counts.count > 0 Then

		x_return_status := 'E';
		prepare_error_mesg(
				p_site_id => NULL
				,p_site_id_num => l_site_counts(1).site_identification_number
				,p_column_name => 'SITE_IDENTIFICATION_NUMBER'
				,p_message_name => 'MESSAGE NAME'
				,p_message_text => 'This Batch has multiple rows with same Site Identification Number : '||l_site_counts(1).site_identification_number|| ' , Modify the batch.'
				,p_source_table_name => 'RRS_SITES_INTERFACE'
				,p_destination_table_name => 'RRS_SITES_B'
				,p_process_status => '3'
				,p_transaction_type => G_TX_TYPE_CREATE
				,p_batch_id => p_batch_id
				,p_processing_errors => local_processing_errors
				);

else

        Delete from RRS_INTERFACE_ERRORS
        Where   batch_id = p_batch_id
        and     Process_status = '3';

	x_return_status := 'S';

end if;


/********************************************************************
 * 	This Update is for defaulting the Address1 in case of Site
 * 	creation/updation using no value for address1 field. We are populating
 * 	the Site Name in Address1 field.
 * 	************************************************************/

/*
 * Moved this SQL just before calling Validat_new_rows and Validate_update_rows.
 *
 *
	Update	RRS_SITES_INTERFACE
	Set	Address1 = Site_name
	where	batch_id = p_batch_id
	and 	process_status = G_PS_TO_BE_PROCESSED
	and	Address1 is NULL
	and	country is NOT NULL
	and 	rowid in (select 	rowid
			from 	RRS_SITES_INTERFACE
			where	batch_id = p_batch_id
			and     process_status = G_PS_TO_BE_PROCESSED
			and     Address1 is NULL);



select count(distinct(site_status_code))
into  l_count
from rrs_sites_interface
where batch_id = p_batch_id
and process_status = G_PS_TO_BE_PROCESSED;

If l_count > 1 then

	x_return_status := 'E';
elsif l_count = 1 then

	x_return_status := 'S';

end if;
*/


end;



Procedure Validate_new_rows(
p_batch_id			IN 		number
,p_purge_rows                	IN              varchar2
,x_return_flag			OUT NOCOPY	varchar2
) is
p_site_id			varchar2(30);
p_site_id_num			varchar2(30);
l_found				varchar2(1);
l_batch_id			number;
l_row_status			varchar2(1);
p_transaction_type		varchar2(6);

Cursor c_default_site_id_num(l_batch_id number) is
Select 	site_identification_number,
	ROWID
from 	RRS_SITES_INTERFACE
where   batch_id = p_batch_id
and     process_status = G_PS_IN_PROCESS
and     transaction_type = G_TX_TYPE_CREATE
and	site_identification_number is NULL;


Cursor c_new_interface_row(l_batch_id number) is
select
SITE_ID,
SITE_IDENTIFICATION_NUMBER,
SITE_NAME,
SITE_TYPE_CODE,
SITE_STATUS_CODE,
SITE_USE_TYPE_CODE,
BRANDNAME_CODE,
CALENDAR_CODE,
LOCATION_STATUS,
LOCATION_ID,
SITE_PARTY_ID,
PARTY_SITE_ID,
LE_PARTY_ID,
CREATED_BY,
CREATION_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATE_LOGIN,
ADDRESS1,
ADDRESS2,
ADDRESS3,
ADDRESS4,
ADDRESS_LINES_PHONETIC,
CITY,
POSTAL_CODE,
STATE,
PROVINCE,
COUNTY,
COUNTRY,
GEOMETRY_SOURCE,
LONGITUDE,
LATITUDE,
REQUEST_ID,
PROGRAM_APPLICATION_ID,
PROGRAM_ID,
PROGRAM_UPDATE_DATE,
TRANSACTION_TYPE,
BATCH_PROCESSING,
BATCH_ID
FROM RRS_SITES_INTERFACE
WHERE TRANSACTION_TYPE = G_TX_TYPE_CREATE
and  BATCH_ID = l_batch_id
and Process_status = G_PS_IN_PROCESS;


local_processing_errors 	rrs_processing_errors_tab;
p_processing_errors 		rrs_processing_errors_tab;

p_init_msg_list			varchar2(1) := 'T';
l_location_rec                  HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
p_location_rec                  HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;

p_organization_rec		HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE;
l_organization_rec		HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE;

p_party_site_rec		HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE;
l_party_site_rec		HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE;

p_party_usage_code		varchar2(30);

p_do_addr_val 			varchar2(1) :=  'Y';
x_location_id 			number;
x_addr_val_status 		varchar2(3);
x_addr_warn_msg 		varchar2(240);
x_return_status 		varchar2(1);
x_msg_count 			number;
x_msg_data 			varchar2(1000);

x_party_id			number;
x_party_number			number;
x_profile_id			number;


x_party_site_id			number;
x_party_site_number 		number;

l_create_location		varchar2(1);
l_create_party			varchar2(1);

l_geo_source			varchar2(30);
l_db_geo_source			varchar2(30);
l_upd_geo_data			varchar2(1);

Type rrs_site_id_rec is RECORD (site_id		RRS_SITES_B.SITE_ID%TYPE);
Type rrs_site_id_tab is TABLE OF NUMBER;
s_site_ids 			rrs_site_id_tab;

x_num_rows			number;

l_site_id_num			number;
l_site_id_num_exist		varchar2(30);

Begin

l_batch_id := p_batch_id;

/*
	Delete from RRS_INTERFACE_ERRORS
	Where	batch_id = p_batch_id
	and 	Transaction_type = G_TX_TYPE_CREATE
	and	Process_status = '3';
*/



	/**************************************************************
 * 	Before Starting all the validatios , let's mark all the rows in
 * 	Interface table with status Validation started ( 2 ). After
 * 	completion of this processing , all the rows in this batch should have
 * 	status as either Validation failed ( 3 ) or Validation succeeded ( 4 )
 * 	**************************************************************/

	UPDATE 	RRS_SITES_INTERFACE
	SET 	PROCESS_STATUS = G_PS_IN_PROCESS,
		REQUEST_ID = G_REQUEST_ID,
		PROGRAM_APPLICATION_ID = G_PROGAM_APPLICATION_ID,
		PROGRAM_ID = G_PROGAM_ID,
		PROGRAM_UPDATE_DATE = SYSDATE,
		LAST_UPDATED_BY = G_USER_ID,
		LAST_UPDATE_DATE = SYSDATE,
		LAST_UPDATE_LOGIN = G_LOGIN_ID
	WHERE	BATCH_ID = p_batch_id
	AND 	PROCESS_STATUS = G_PS_TO_BE_PROCESSED
	AND 	TRANSACTION_TYPE = G_TX_TYPE_CREATE;



/*******************************************************************
 * 	Based on profile check of Automatic generation of Site
 * 	Identification number , let's generate the
 * 	Site_identification_number using a sequence and assign
 * 	it to every row of this batch with Transaction_type = 'CREATE'.
 * 	***********************************************************/


IF (FND_PROFILE.VALUE('RRS_AUTO_DEFAULT_SITE_NUM') = '1' )  then


FOR site_id_num IN  c_default_site_id_num(l_batch_id) LOOP


	-- l_site_id_num := rrs_default_site_number_s.nextval;
	SELECT 	RRS_DEFAULT_SITE_NUMBER_S.NEXTVAL
	INTO	l_site_id_num
	FROM 	DUAL;

	Begin
		Select 	site_identification_number
		into	l_site_id_num_exist
		from 	RRS_SITES_INTERFACE
        	where   site_identification_number = to_char(l_site_id_num)
        	and     batch_id = p_batch_id
        	and     process_status = G_PS_IN_PROCESS
        	and     transaction_type = G_TX_TYPE_CREATE;
	Exception
		When TOO_MANY_ROWS then null;
		When NO_DATA_FOUND then

			Update 	RRS_SITES_INTERFACE
			Set	site_identification_number = l_site_id_num
			where	site_identification_number is NULL
			and 	batch_id = p_batch_id
			and 	process_status = G_PS_IN_PROCESS
			and 	transaction_type = G_TX_TYPE_CREATE
			and 	ROWID = site_id_num.ROWID;

	End;


END LOOP;

End if;


FOR site_data IN  c_new_interface_row(l_batch_id) LOOP

p_processing_errors := rrs_processing_errors_tab();
local_processing_errors := rrs_processing_errors_tab();

l_row_status := 'S';
l_create_party := 'N';
l_create_location := 'N';
l_upd_geo_data := 'Y';

begin
	Check_site_id_num(
			p_site_id_num=>site_data.site_identification_number
			,p_site_id=>site_data.site_id
			,p_transaction_type=>site_data.transaction_type
			,x_return_flag=>x_return_flag
			);
	if x_return_flag = 'S' AND l_row_status = 'S'  then
		null;
 		-- dbms_output.put_line('Site Identification Number validation succeeded ');
	elsif x_return_flag = 'E' then
		l_row_status := 'E';
		prepare_error_mesg(
				p_site_id => NULL
				,p_site_id_num => site_data.site_identification_number
				,p_column_name => 'SITE_IDENTIFICATION_NUMBER'
				,p_message_name => 'MESSAGE NAME'
				,p_message_text => 'This Site Identification Number already exists, Enter a new number.'
				,p_source_table_name => 'RRS_SITES_INTERFACE'
				,p_destination_table_name => 'RRS_SITES_B'
				,p_process_status => '3'
				,p_transaction_type => site_data.transaction_type
				,p_batch_id => site_data.batch_id
				,p_processing_errors => local_processing_errors
				);
	end if;

If site_data.site_name is NULL Then
		l_row_status := 'E';
		prepare_error_mesg(
				p_site_id => NULL
				,p_site_id_num => site_data.site_identification_number
				,p_column_name => 'SITE_NAME'
				,p_message_name => 'MESSAGE NAME'
				,p_message_text => 'Site Name cannot be Null  for : '||site_data.site_identification_number
				,p_source_table_name => 'RRS_SITES_INTERFACE'
				,p_destination_table_name => 'RRS_SITES_TL'
				,p_process_status => '3'
				,p_transaction_type => site_data.transaction_type
				,p_batch_id => site_data.batch_id
				,p_processing_errors => local_processing_errors
				);
end if;


If site_data.site_status_code is NOT NULL then
	Check_site_status_code( p_site_id_num => site_data.site_identification_number
			      ,p_site_status_code => site_data.site_status_code
			      ,x_return_flag => x_return_flag
				);
		if x_return_flag = 'S' AND l_row_status = 'S' then
			null;
 			-- dbms_output.put_line('Site status code validation succeeded ');
		elsif x_return_flag = 'E' then
			l_row_status := 'E';
			prepare_error_mesg(
				p_site_id => NULL
				,p_site_id_num => site_data.site_identification_number
				,p_column_name => 'SITE_STATUS_CODE'
				,p_message_name => 'MESSAGE NAME'
				,p_message_text => 'Site Status code is not valid  for site_id : '||site_data.site_identification_number
				,p_source_table_name => 'RRS_SITES_INTERFACE'
				,p_destination_table_name => 'RRS_SITES_B'
				,p_process_status => '3'
				,p_transaction_type => site_data.transaction_type
				,p_batch_id => site_data.batch_id
				,p_processing_errors => local_processing_errors
				);
		end if;

else
			l_row_status := 'E';
		prepare_error_mesg(
				p_site_id => NULL
				,p_site_id_num => site_data.site_identification_number
				,p_column_name => 'SITE_STATUS_CODE'
				,p_message_name => 'MESSAGE NAME'
				,p_message_text => 'Site Status code cannot be null for site_id : '||site_data.site_identification_number
				,p_source_table_name => 'RRS_SITES_INTERFACE'
				,p_destination_table_name => 'RRS_SITES_B'
				,p_process_status => '3'
				,p_transaction_type => site_data.transaction_type
				,p_batch_id => site_data.batch_id
				,p_processing_errors => local_processing_errors
				);

end if;




If site_data.brandname_code is NOT NULL then
	Check_site_brand_code( p_site_id_num => site_data.site_identification_number
			      ,p_site_brand_code => site_data.brandname_code
			      ,x_return_flag => x_return_flag
				);
	if x_return_flag = 'S' AND l_row_status = 'S' then
		null;
 		-- dbms_output.put_line('Brandname code code validation succeeded ');
	elsif x_return_flag = 'E' then
		l_row_status := 'E';
		prepare_error_mesg(
				p_site_id => NULL
				,p_site_id_num => site_data.site_identification_number
				,p_column_name => 'BRANDNAME_CODE'
				,p_message_name => 'MESSAGE NAME'
				,p_message_text => 'Brandname Code validation fails for : '||site_data.site_identification_number
				,p_source_table_name => 'RRS_SITES_INTERFACE'
				,p_destination_table_name => 'RRS_SITES_B'
				,p_process_status => '3'
				,p_transaction_type => site_data.transaction_type
				,p_batch_id => site_data.batch_id
				,p_processing_errors => local_processing_errors
				);
	end if;

end if;


if site_data.calendar_code is NOT NULL then
	Check_site_calendar_code( p_site_id_num => site_data.site_identification_number
			      ,p_site_calendar_code => site_data.calendar_code
			      ,x_return_flag => x_return_flag
				);
	if x_return_flag = 'S' AND l_row_status = 'S' then
		null;
 		-- dbms_output.put_line('Calendar code validation succeeded ');
	elsif x_return_flag = 'E' then
		l_row_status := 'E';
		prepare_error_mesg(
				p_site_id => NULL
				,p_site_id_num => site_data.site_identification_number
				,p_column_name => 'CALENDAR_CODE'
				,p_message_name => 'MESSAGE NAME'
				,p_message_text => 'Calendar Code validation fails for : '||site_data.site_identification_number
				,p_source_table_name => 'RRS_SITES_INTERFACE'
				,p_destination_table_name => 'RRS_SITES_B'
				,p_process_status => '3'
				,p_transaction_type => site_data.transaction_type
				,p_batch_id => site_data.batch_id
				,p_processing_errors => local_processing_errors
				);
	end if;
end if;

if site_data.site_use_type_code is NOT NULL then
	Check_site_use_type_code( p_site_id_num => site_data.site_identification_number
			      ,p_site_use_type_code => site_data.site_use_type_code
			      ,x_return_flag => x_return_flag
				);
	if x_return_flag = 'S' AND l_row_status = 'S' then
		null;
 		-- dbms_output.put_line('Site use type code validation succeeded ');
	elsif x_return_flag = 'E' then
		l_row_status := 'E';
		prepare_error_mesg(
				p_site_id => NULL
				,p_site_id_num => site_data.site_identification_number
				,p_column_name => 'SITE_USE_TYPE_CODE'
				,p_message_name => 'MESSAGE NAME'
				,p_message_text => 'Site Use Type Code validation fails for : '||site_data.site_identification_number
				,p_source_table_name => 'RRS_SITES_INTERFACE'
				,p_destination_table_name => 'RRS_SITE_USES'
				,p_process_status => '3'
				,p_transaction_type => site_data.transaction_type
				,p_batch_id => site_data.batch_id
				,p_processing_errors => local_processing_errors
				);
	end if;
end if;



If site_data.country is NOT NULL then

		Check_location_country( p_site_id_num => site_data.site_identification_number
				   	,p_location_id => site_data.location_id
				      	,p_country_code => site_data.country
				      	,x_return_flag => x_return_flag
					);
	if x_return_flag = 'S' AND l_row_status = 'S' then
		null;
 		-- dbms_output.put_line('Country code validation succeeded ');
	elsif x_return_flag = 'E' then
		l_row_status := 'E';
		prepare_error_mesg(
				p_site_id => NULL
				,p_site_id_num => site_data.site_identification_number
				,p_column_name => 'COUNTRY_CODE'
				,p_message_name => 'MESSAGE NAME'
				,p_message_text => 'Country Code validation fails for : '||site_data.site_identification_number
				,p_source_table_name => 'RRS_SITES_INTERFACE'
				,p_destination_table_name => 'HZ_LOCATIONS'
				,p_process_status => '3'
				,p_transaction_type => site_data.transaction_type
				,p_batch_id => site_data.batch_id
				,p_processing_errors => local_processing_errors
				);
	end if;
else
	l_row_status := 'E';
		prepare_error_mesg(
				p_site_id => NULL
				,p_site_id_num => site_data.site_identification_number
				,p_column_name => 'COUNTRY_CODE'
				,p_message_name => 'MESSAGE NAME'
				,p_message_text => 'Invalid Country Code. country Code is required for : '||site_data.site_identification_number
				,p_source_table_name => 'RRS_SITES_INTERFACE'
				,p_destination_table_name => 'HZ_LOCATIONS'
				,p_process_status => '3'
				,p_transaction_type => site_data.transaction_type
				,p_batch_id => site_data.batch_id
				,p_processing_errors => local_processing_errors
				);

end if;

If site_data.location_status = 'E' and site_data.location_id is NOT NULL  Then

		Check_location_id(p_site_id_num => site_data.site_identification_number
				,p_location_id => site_data.location_id
				,p_country_code => site_data.country
				,x_return_flag => x_return_flag
				);
	if x_return_flag = 'S' AND l_row_status = 'S' then
		null;
 		-- dbms_output.put_line('Location ID validation succeeded 1');
	elsif x_return_flag = 'E' then
		l_row_status := 'E';
		prepare_error_mesg(
				p_site_id => NULL
				,p_site_id_num => site_data.site_identification_number
				,p_column_name => 'LOCATION_ID'
				,p_message_name => 'MESSAGE NAME'
				,p_message_text => 'Location Status and Location ID combination is not  valid for : '||site_data.site_identification_number
				,p_source_table_name => 'RRS_SITES_INTERFACE'
				,p_destination_table_name => 'HZ_LOCATIONS'
				,p_process_status => '3'
				,p_transaction_type => site_data.transaction_type
				,p_batch_id => site_data.batch_id
				,p_processing_errors => local_processing_errors
				);
	end if;
/*
elsif site_data.location_status = 'E' and site_data.address1 is NOT NULL and site_data.country is NOT NULL Then

		Check_address1( p_site_id_num => site_data.site_identification_number
			      ,p_location_id => site_data.location_id
			      ,p_location_status => site_data.location_status
			      ,p_country_code => site_data.country
			      ,p_address1 => site_data.address1
			      ,x_return_flag => x_return_flag
				);
        if x_return_flag = 'S' AND l_row_status = 'S' then
		null;
                -- dbms_output.put_line('Location ID validation succeeded 2');
        elsif x_return_flag = 'E' then
                l_row_status := 'E';
		prepare_error_mesg(
				p_site_id => NULL
				,p_site_id_num => site_data.site_identification_number
				,p_column_name => 'ADDRESS1'
				,p_message_name => 'MESSAGE NAME'
				,p_message_text => 'Location Status and Address combination is not  valid for : '||site_data.site_identification_number
				,p_source_table_name => 'RRS_SITES_INTERFACE'
				,p_destination_table_name => 'HZ_LOCATIONS'
				,p_process_status => '3'
				,p_transaction_type => site_data.transaction_type
				,p_batch_id => site_data.batch_id
				,p_processing_errors => local_processing_errors
				);
        end if;
*/

elsif site_data.location_status = 'N' and site_data.address1 is NOT NULL and site_data.country is NOT NULL Then

		Check_address1( p_site_id_num => site_data.site_identification_number
			      ,p_location_id => site_data.location_id
			      ,p_location_status => site_data.location_status
			      ,p_country_code => site_data.country
			      ,p_address1 => site_data.address1
			      ,x_return_flag => x_return_flag
				);
		 -- dbms_output.put_line('How about now... : '||x_return_flag);
		 -- dbms_output.put_line('Row Status now... : '||l_row_status);
        if x_return_flag = 'S' AND l_row_status = 'S' then
		l_create_location := 'Y';


        elsif x_return_flag = 'E' then
                l_row_status := 'E';
		prepare_error_mesg(
				p_site_id => NULL
				,p_site_id_num => site_data.site_identification_number
				,p_column_name => 'ADDRESS1'
				,p_message_name => 'MESSAGE NAME'
				,p_message_text => 'Location status , Address1 and Country validations fails for : '||site_data.site_identification_number
				,p_source_table_name => 'RRS_SITES_INTERFACE'
				,p_destination_table_name => 'HZ_LOCATIONS'
				,p_process_status => '3'
				,p_transaction_type => site_data.transaction_type
				,p_batch_id => site_data.batch_id
				,p_processing_errors => local_processing_errors
				);
        end if;

elsIf site_data.location_status = 'N' and site_data.location_id is NOT NULL  Then
		 l_row_status := 'E';
		prepare_error_mesg(
				p_site_id => NULL
				,p_site_id_num => site_data.site_identification_number
				,p_column_name => 'LOCATION_ID'
				,p_message_name => 'MESSAGE NAME'
				,p_message_text => 'Location Status and Location ID combination is not  valid for : '||site_data.site_identification_number
				,p_source_table_name => 'RRS_SITES_INTERFACE'
				,p_destination_table_name => 'HZ_LOCATIONS'
				,p_process_status => '3'
				,p_transaction_type => site_data.transaction_type
				,p_batch_id => site_data.batch_id
				,p_processing_errors => local_processing_errors
				);

elsif site_data.location_status = 'N' and (site_data.address1 is NULL OR site_data.country is NULL) Then
		 l_row_status := 'E';
		prepare_error_mesg(
				p_site_id => NULL
				,p_site_id_num => site_data.site_identification_number
				,p_column_name => 'ADDRESS1'
				,p_message_name => 'MESSAGE NAME'
				,p_message_text => 'Location Status and Address combination is not  valid for : '||site_data.site_identification_number
				,p_source_table_name => 'RRS_SITES_INTERFACE'
				,p_destination_table_name => 'HZ_LOCATIONS'
				,p_process_status => '3'
				,p_transaction_type => site_data.transaction_type
				,p_batch_id => site_data.batch_id
				,p_processing_errors => local_processing_errors
				);
else
		 l_row_status := 'E';
		prepare_error_mesg(
				p_site_id => NULL
				,p_site_id_num => site_data.site_identification_number
				,p_column_name => 'LOCATION_STATUS'
				,p_message_name => 'MESSAGE NAME'
				,p_message_text => 'Location Data is invalid for : '||site_data.site_identification_number
				,p_source_table_name => 'RRS_SITES_INTERFACE'
				,p_destination_table_name => 'RRS_SITES_INTERFACE'
				,p_process_status => '3'
				,p_transaction_type => site_data.transaction_type
				,p_batch_id => site_data.batch_id
				,p_processing_errors => local_processing_errors
				);

End if;

If ( ( site_data.LONGITUDE is NOT NULL AND site_data.LATITUDE is NULL ) OR
	( site_data.LONGITUDE is NULL and site_data.LATITUDE is NOT NULL )) Then

		l_row_status := 'E';
		prepare_error_mesg(
				p_site_id => NULL
				,p_site_id_num => site_data.site_identification_number
				,p_column_name => 'LONGITUDE LATITUDE'
				,p_message_name => 'MESSAGE NAME'
				,p_message_text => 'Both langitude and latitude should be either Null or Not Null for : '||site_data.site_identification_number
				,p_source_table_name => 'RRS_SITES_INTERFACE'
				,p_destination_table_name => 'HZ_LOCATIONS'
				,p_process_status => '3'
				,p_transaction_type => site_data.transaction_type
				,p_batch_id => site_data.batch_id
				,p_processing_errors => local_processing_errors
				);

elsif (  site_data.LONGITUDE is NOT NULL AND site_data.LATITUDE is NOT NULL  ) then
	if (site_data.Longitude < -180 OR site_data.Longitude > 180 )  then
		l_row_status := 'E';
		prepare_error_mesg(
				p_site_id => NULL
				,p_site_id_num => site_data.site_identification_number
				,p_column_name => 'LONGITUDE '
				,p_message_name => 'MESSAGE NAME'
				,p_message_text => 'Longitude should be between -180 and 180 for : '||site_data.site_identification_number
				,p_source_table_name => 'RRS_SITES_INTERFACE'
				,p_destination_table_name => 'HZ_LOCATIONS'
				,p_process_status => '3'
				,p_transaction_type => site_data.transaction_type
				,p_batch_id => site_data.batch_id
				,p_processing_errors => local_processing_errors
				);

	elsif ( site_data.latitude < -90 OR site_data.latitude > 90 ) then
		l_row_status := 'E';
		prepare_error_mesg(
				p_site_id => NULL
				,p_site_id_num => site_data.site_identification_number
				,p_column_name => 'LATITUDE'
				,p_message_name => 'MESSAGE NAME'
				,p_message_text => 'Latitude should be between -90 and 90 for : '||site_data.site_identification_number
				,p_source_table_name => 'RRS_SITES_INTERFACE'
				,p_destination_table_name => 'HZ_LOCATIONS'
				,p_process_status => '3'
				,p_transaction_type => site_data.transaction_type
				,p_batch_id => site_data.batch_id
				,p_processing_errors => local_processing_errors
				);

	end if;

end if;


If ( site_data.GEOMETRY_SOURCE is NOT NULL ) then

        Check_geo_source_code( p_site_id_num => site_data.site_identification_number
                              ,p_geo_source_code => site_data.geometry_source
                              ,x_return_flag => x_return_flag
                                );
        if x_return_flag = 'S' AND l_row_status = 'S' then
                null;
                -- dbms_output.put_line('Site use type code validation succeeded ');
        elsif x_return_flag = 'E' then
                l_row_status := 'E';
		prepare_error_mesg(
				p_site_id => NULL
				,p_site_id_num => site_data.site_identification_number
				,p_column_name => 'GEOMETRY_SOURCE'
				,p_message_name => 'MESSAGE NAME'
				,p_message_text => 'Geometry Source Code validation fails for : '||site_data.site_identification_number
				,p_source_table_name => 'RRS_SITES_INTERFACE'
				,p_destination_table_name => 'HZ_LOCATIONS'
				,p_process_status => '3'
				,p_transaction_type => site_data.transaction_type
				,p_batch_id => site_data.batch_id
				,p_processing_errors => local_processing_errors
				);
	end if;

end if ;


If site_data.GEOMETRY_SOURCE is NULL and site_data.LONGITUDE is NOT NULL and site_data.LATITUDE is NOT NULL then
	l_geo_source := 'RRS_USER_ENTERED';


elsif site_data.GEOMETRY_SOURCE is NULL and site_data.LONGITUDE is NULL and site_data.LATITUDE is NULL then
	If site_data.location_status = 'N' then

	 	IF  (FND_PROFILE.VALUE('RRS_GEOCODE_SRC_PREFERENCE') = 'RRS_USER_ENTERED')  then
			l_geo_source := 'RRS_USER_ENTERED';
		else
			l_geo_source := 'RRS_GOOGLE';
		end if;

	elsif site_data.location_status = 'E'  and  l_row_status = 'S'  then

		l_upd_geo_data := 'N';

		select 	geometry_source
		into 	l_db_geo_source
		from 	hz_locations
		where	location_id = site_data.location_id;

		If l_db_geo_source is NULL then
	 		IF  (FND_PROFILE.VALUE('RRS_GEOCODE_SRC_PREFERENCE') = 'RRS_USER_ENTERED')  then
				l_geo_source := 'RRS_USER_ENTERED';
			else
				l_geo_source := 'RRS_GOOGLE';
			end if;
				UPDATE	HZ_LOCATIONS
				SET	GEOMETRY_SOURCE = l_geo_source
				WHERE	LOCATION_ID = site_data.location_id;
		end if;


	end if;


elsif site_data.GEOMETRY_SOURCE = 'RRS_GOOGLE' and site_data.LONGITUDE is NOT NULL and site_data.LATITUDE is NOT NULL then
		l_row_status := 'E';
		prepare_error_mesg(
				p_site_id => NULL
				,p_site_id_num => site_data.site_identification_number
				,p_column_name => 'GEOMETRY_SOURCE'
				,p_message_name => 'MESSAGE NAME'
				,p_message_text => 'Longitude-Latitude should be Null for Geometry Source as System Generated for : '||site_data.site_identification_number
				,p_source_table_name => 'RRS_SITES_INTERFACE'
				,p_destination_table_name => 'HZ_LOCATIONS'
				,p_process_status => '3'
				,p_transaction_type => site_data.transaction_type
				,p_batch_id => site_data.batch_id
				,p_processing_errors => local_processing_errors
				);

end if;

If site_data.site_type_code is NULL then
		l_row_status := 'E';
		prepare_error_mesg(
				p_site_id => NULL
				,p_site_id_num => site_data.site_identification_number
				,p_column_name => 'SITE_TYPE_CODE'
				,p_message_name => 'MESSAGE NAME'
				,p_message_text => 'Site type code cannot be null for site_id : '||site_data.site_identification_number
				,p_source_table_name => 'RRS_SITES_INTERFACE'
				,p_destination_table_name => 'RRS_SITES_B'
				,p_process_status => '3'
				,p_transaction_type => site_data.transaction_type
				,p_batch_id => site_data.batch_id
				,p_processing_errors => local_processing_errors
				);

else

	Check_site_type_code( p_site_id_num => site_data.site_identification_number
			      ,p_site_type_code => site_data.site_type_code
			      ,x_return_flag => x_return_flag
				);
	if x_return_flag = 'S' AND l_row_status = 'S' then
		null;
 		-- dbms_output.put_line('Site type code validation succeeded ');
	elsif x_return_flag = 'E' then
		l_row_status := 'E';
		prepare_error_mesg(
				p_site_id => NULL
				,p_site_id_num => site_data.site_identification_number
				,p_column_name => 'SITE_TYPE_CODE'
				,p_message_name => 'MESSAGE NAME'
				,p_message_text => 'Site type code validation fails for : '||site_data.site_identification_number
				,p_source_table_name => 'RRS_SITES_INTERFACE'
				,p_destination_table_name => 'RRS_SITES_B'
				,p_process_status => '3'
				,p_transaction_type => site_data.transaction_type
				,p_batch_id => site_data.batch_id
				,p_processing_errors => local_processing_errors
				);
	end if;
end if;

If (site_data.site_type_code = 'E' )
AND ( site_data.le_party_id is NOT NULL OR site_data.party_site_id is NOT NULL ) then

		l_row_status := 'E';
		prepare_error_mesg(
				p_site_id => NULL
				,p_site_id_num => site_data.site_identification_number
				,p_column_name => 'SITE_PARTY_ID'
				,p_message_name => 'MESSAGE NAME'
				,p_message_text => 'Site type code and External party validation fails for : '||site_data.site_identification_number
				,p_source_table_name => 'RRS_SITES_INTERFACE'
				,p_destination_table_name => 'RRS_SITES_B'
				,p_process_status => '3'
				,p_transaction_type => site_data.transaction_type
				,p_batch_id => site_data.batch_id
				,p_processing_errors => local_processing_errors
				);

elsIf site_data.site_type_code = 'E' AND site_data.site_party_id is  NOT NULL then


	Check_site_party_id( p_site_id_num => site_data.site_identification_number
			      ,p_site_party_id => site_data.site_party_id
			      ,x_return_flag => x_return_flag
				);
	if x_return_flag = 'S' AND l_row_status = 'S' then
		null;
 		-- dbms_output.put_line('Site type code and External Party validation succeeded ');
	elsif x_return_flag = 'E' then
		l_row_status := 'E';
		prepare_error_mesg(
				p_site_id => NULL
				,p_site_id_num => site_data.site_identification_number
				,p_column_name => 'SITE_PARTY_ID'
				,p_message_name => 'MESSAGE NAME'
				,p_message_text => 'Site type code and External party validation fails for : '||site_data.site_identification_number
				,p_source_table_name => 'RRS_SITES_INTERFACE'
				,p_destination_table_name => 'RRS_SITES_B'
				,p_process_status => '3'
				,p_transaction_type => site_data.transaction_type
				,p_batch_id => site_data.batch_id
				,p_processing_errors => local_processing_errors
				);
	end if;
/*
else
		l_row_status := 'E';
		prepare_error_mesg(
				p_site_id => NULL
				,p_site_id_num => site_data.site_identification_number
				,p_column_name => 'SITE_PARTY_ID'
				,p_message_name => 'MESSAGE NAME'
				,p_message_text => 'Site type code and External party validation fails for : '||site_data.site_identification_number
				,p_source_table_name => 'RRS_SITES_INTERFACE'
				,p_destination_table_name => 'RRS_SITES_B'
				,p_process_status => '3'
				,p_transaction_type => site_data.transaction_type
				,p_batch_id => site_data.batch_id
				,p_processing_errors => local_processing_errors
				);
	dbms_output.put_line(' Invalid combination of Site Type Code and Site Party ID for site_id : '||site_data.site_identification_number);
*/

end if;

If site_data.site_type_code = 'I' AND site_data.le_party_id is  NOT NULL then


	Check_le_party_id( p_site_id_num => site_data.site_identification_number
			      ,p_le_party_id => site_data.le_party_id
			      ,x_return_flag => x_return_flag
				);
	if x_return_flag = 'S' AND l_row_status = 'S' then

		l_create_party := 'Y';
	elsif x_return_flag = 'E' then
		l_row_status := 'E';
		prepare_error_mesg(
				p_site_id => NULL
				,p_site_id_num => site_data.site_identification_number
				,p_column_name => 'LE_PARTY_ID'
				,p_message_name => 'MESSAGE NAME'
				,p_message_text => 'Site type code and LE party validation fails for : '||site_data.site_identification_number
				,p_source_table_name => 'RRS_SITES_INTERFACE'
				,p_destination_table_name => 'RRS_SITES_B'
				,p_process_status => '3'
				,p_transaction_type => site_data.transaction_type
				,p_batch_id => site_data.batch_id
				,p_processing_errors => local_processing_errors
				);
	end if;
elsIf (site_data.site_type_code = 'I' AND site_data.le_party_id is  NULL ) AND (
site_data.site_party_id is NOT NULL OR site_data.party_site_id is NOT NULL ) then
		l_row_status := 'E';
		prepare_error_mesg(
				p_site_id => NULL
				,p_site_id_num => site_data.site_identification_number
				,p_column_name => 'LE_PARTY_ID'
				,p_message_name => 'MESSAGE NAME'
				,p_message_text => 'Site type code and LE party validation fails for : '||site_data.site_identification_number
				,p_source_table_name => 'RRS_SITES_INTERFACE'
				,p_destination_table_name => 'RRS_SITES_B'
				,p_process_status => '3'
				,p_transaction_type => site_data.transaction_type
				,p_batch_id => site_data.batch_id
				,p_processing_errors => local_processing_errors
				);
/*
else
	dbms_output.put_line(' Invalid combination of Site Type Code and Site Party ID for site_id : '||site_data.site_identification_number);
*/

end if;



-- lot of processing needs to be done here.. for party , location and party_site also.

-- Location Creation.

If l_create_location = 'Y' and l_row_status = 'S'  then

		l_location_rec.country := site_data.country;
		l_location_rec.address1 := site_data.address1;
		l_location_rec.address2 := site_data.address2;
		l_location_rec.address3 := site_data.address3;
		l_location_rec.address4 := site_data.address4;
		l_location_rec.city := site_data.city;
		l_location_rec.postal_code := site_data.postal_code;
		l_location_rec.state := site_data.state;
		l_location_rec.province := site_data.province;
		l_location_rec.county := site_data.county;
		l_location_rec.address_lines_phonetic := site_data.address_lines_phonetic;
		l_location_rec.created_by_module := 'RRS';
		l_location_rec.application_id := 718;


		hz_location_v2pub.create_location(p_init_msg_list => 'T'
						,p_location_rec => l_location_rec
						,p_do_addr_val => 'Y'
						,x_location_id => x_location_id
						,x_addr_val_status => x_addr_val_status
						,x_addr_warn_msg => x_addr_warn_msg
						,x_return_status => x_return_status
						,x_msg_count => x_msg_count
						,x_msg_data => x_msg_data
						);

		If x_return_status = 'S'  AND  l_row_status = 'S' then
			null;
			-- dbms_output.put_line('New location ID for Site : '||site_data.site_identification_number||' is => '||x_location_id);

		elsif x_return_status = 'E'  then
			l_row_status := 'E';
			prepare_error_mesg(
				p_site_id => NULL
				,p_site_id_num => site_data.site_identification_number
				,p_column_name => 'LOCATION_ID'
				,p_message_name => 'MESSAGE NAME'
				,p_message_text => 'Error Creating the location for : '||site_data.site_identification_number||' '||x_msg_data
				,p_source_table_name => 'RRS_SITES_INTERFACE'
				,p_destination_table_name => 'HZ_LOCATIONS'
				,p_process_status => '3'
				,p_transaction_type => site_data.transaction_type
				,p_batch_id => site_data.batch_id
				,p_processing_errors => local_processing_errors
				);

		end if;
End if;

-- Party Creation

If l_create_party = 'Y'  and  l_row_status = 'S'  then

-- Party Creation

		l_organization_rec.organization_name := site_data.site_identification_number;
		l_organization_rec.created_by_module := 'RRS';

		hz_party_v2pub.create_organization(p_organization_rec => l_organization_rec
						  ,p_party_usage_code => 'REAL_ESTATE'
 						  ,x_return_status => x_return_status
 						  ,x_msg_count => x_msg_count
 						  ,x_msg_data => x_msg_data
 						  ,x_party_id => x_party_id
 						  ,x_party_number => x_party_number
 						  ,x_profile_id => x_profile_id
						);
                If x_return_status = 'S' AND l_row_status = 'S' then

			null;
                        -- dbms_output.put_line('New Party  ID for Site : '||site_data.site_identification_number||' is => '||x_party_id);

                elsif x_return_status = 'E' then
                        l_row_status := 'E';
			prepare_error_mesg(
				p_site_id => NULL
				,p_site_id_num => site_data.site_identification_number
				,p_column_name => 'SITE_PARTY_ID'
				,p_message_name => 'MESSAGE NAME'
				,p_message_text => 'Error Creating the Party for : '||site_data.site_identification_number
				,p_source_table_name => 'RRS_SITES_INTERFACE'
				,p_destination_table_name => 'RRS_SITES_B'
				,p_process_status => '3'
				,p_transaction_type => site_data.transaction_type
				,p_batch_id => site_data.batch_id
				,p_processing_errors => local_processing_errors
				);

                end if;



-- Party Site Creation


If l_create_location = 'Y'  and l_row_status = 'S'  then


		l_party_site_rec.location_id := x_location_id;

else

		l_party_site_rec.location_id := site_data.location_id;

end if;

		l_party_site_rec.party_id := x_party_id;
		l_party_site_rec.identifying_address_flag := 'Y';
		l_party_site_rec.created_by_module := 'RRS';

		hz_party_site_v2pub.create_party_site( p_init_msg_list => 'T'
							,p_party_site_rec => l_party_site_rec
						 	,x_party_site_id => x_party_site_id
 							,x_party_site_number => x_party_site_number
 							,x_return_status => x_return_status
 							,x_msg_count => x_msg_count
 							,x_msg_data => x_msg_data
							);
                If x_return_status = 'S' AND l_row_status = 'S' then

			null;
                        -- dbms_output.put_line('New Party Site ID for Site : '||site_data.site_identification_number||' is => '||x_party_site_id);

                elsif x_return_status = 'E' then
                        l_row_status := 'E';
			prepare_error_mesg(
				p_site_id => NULL
				,p_site_id_num => site_data.site_identification_number
				,p_column_name => 'PARTY_SITE_ID'
				,p_message_name => 'MESSAGE NAME'
				,p_message_text => 'Error Creating the Party Site for : '||site_data.site_identification_number
				,p_source_table_name => 'RRS_SITES_INTERFACE'
				,p_destination_table_name => 'RRS_SITES_B'
				,p_process_status => '3'
				,p_transaction_type => site_data.transaction_type
				,p_batch_id => site_data.batch_id
				,p_processing_errors => local_processing_errors
				);

                end if;


end if;


-- call for updating HZ_Locations for Geometry coordinates.

	if l_upd_geo_data = 'Y'  and  l_row_status = 'S'  then
	RRS_SITE_UTILS.Update_geometry_for_locations ( p_loc_id => nvl(site_data.location_id , x_location_id)
							,p_lat => site_data.latitude
							,p_long => site_data.longitude
							,p_status => 'GOOD'
							,p_geo_source => nvl(site_data.geometry_source , l_geo_source )
							,x_return_status => x_return_status
							,x_msg_count => x_msg_count
							,x_msg_data => x_msg_data
							);

                If x_return_status = 'S' AND l_row_status = 'S' then
                        null;

                elsif x_return_status = 'E'  then
                        l_row_status := 'E';
                        prepare_error_mesg( p_site_id => NULL
                                ,p_site_id_num => site_data.site_identification_number
                                ,p_column_name => 'GEOMETRY_SOURCE'
                                ,p_message_name => 'MESSAGE NAME'
                                ,p_message_text => 'Error Updating the Geometry Information for : '||site_data.site_identification_number
                                ,p_source_table_name => 'RRS_SITES_INTERFACE'
                                ,p_destination_table_name => 'HZ_LOCATIONS'
                                ,p_process_status => '3'
                                ,p_transaction_type => site_data.transaction_type
                                ,p_batch_id => site_data.batch_id
                                ,p_processing_errors => local_processing_errors
                                );

                end if;

	end if;



	/********************************************
  	Here we will check if all the validations are successful so far,
 	we will update the process_status of this row to be Validation_succeeded
	( 4 )
	*********************************************/

If l_row_status = 'S' then
-- dbms_output.put_line (' Create Loaction Flag is : '||l_create_location);

	If l_create_party = 'Y' and l_create_location = 'Y'  then
        	update rrs_sites_interface
        	set     location_id = x_location_id,
                	site_party_id = x_party_id ,
			party_site_id = x_party_site_id
        	where   site_identification_number = site_data.site_identification_number
		and 	batch_id = p_batch_id
		and 	Transaction_type = G_TX_TYPE_CREATE
		and 	process_status = G_PS_IN_PROCESS
        	and     location_status = 'N';

	elsif l_create_party = 'Y' then

        	update rrs_sites_interface
        	set     site_party_id = x_party_id ,
			party_site_id = x_party_site_id
        	where   site_identification_number = site_data.site_identification_number
		and 	process_status = G_PS_IN_PROCESS
		and 	batch_id = p_batch_id;

	elsif l_create_location = 'Y' then
-- dbms_output.put_line (' updating  Loaction ID  : '||x_location_id);

        	update rrs_sites_interface
        	set     location_id = x_location_id
        	where   site_identification_number = site_data.site_identification_number
		and 	batch_id = p_batch_id
		and 	process_status = G_PS_IN_PROCESS
		and 	Transaction_type = G_TX_TYPE_CREATE;

	end if;



/*
	Update RRS_SITES_INTERFACE
	Set 	Process_status = G_PS_SUCCESS
	Where	Batch_id = p_batch_id
	and 	process_status = G_PS_IN_PROCESS
	and 	site_identification_number = site_data.site_identification_number
	and 	transaction_type = G_TX_TYPE_CREATE;
*/

elsif l_row_status = 'E' then

	Update RRS_SITES_INTERFACE
	Set 	Process_status = '3'
	Where	Batch_id = p_batch_id
	and 	process_status = G_PS_IN_PROCESS
	and 	site_identification_number = site_data.site_identification_number
	and 	transaction_type = G_TX_TYPE_CREATE;

	Write_interface_errors(p_processing_errors => local_processing_errors);
else

	/*********************
 * 	This behaviour should never happen but I am documenting for exceptional
 * 	case. Update all the rows with process_status = '2' to '1' after
 * 	completion of the processing logic. It should always return 0 rows.
 	* *********************/

        Update RRS_SITES_INTERFACE
        Set     Process_status = G_PS_TO_BE_PROCESSED
        Where   Batch_id = p_batch_id
        and     process_status = G_PS_IN_PROCESS
        and     transaction_type in ( G_TX_TYPE_CREATE );


end if;

end;

End Loop;


 	Create_sites(
			p_batch_id => p_batch_id
			,p_transaction_type => G_TX_TYPE_CREATE
			,p_purge_rows => p_purge_rows
			,x_num_rows => x_num_rows
			,x_return_status => x_return_status
			);







end;



Procedure Check_site_id_num(
 p_site_id_num 			IN		varchar2
,p_site_id 			IN		varchar2
,p_transaction_type		IN		varchar2
,x_return_flag  		OUT NOCOPY 	varchar2
) is

begin
If p_site_id_num is NOT NULL and p_transaction_type = G_TX_TYPE_CREATE then

	Begin
	select  'E'
	into 	x_return_flag
	from 	rrs_sites_b
	where site_identification_number = p_site_id_num;
	exception
		when no_data_found then
			x_return_flag := 'S';
	end;

elsIf p_site_id_num is NOT NULL and p_transaction_type = G_TX_TYPE_UPDATE then

	Begin
	select  'S'
	into 	x_return_flag
	from 	rrs_sites_b
	where site_identification_number = p_site_id_num;
	exception
		when no_data_found then
	 	x_return_flag := 'E';
	end;

elsif p_site_id is NOT NULL and p_site_id_num is NULL then

	Begin
	select  'S'
	into 	x_return_flag
	from 	rrs_sites_b
	where site_id = p_site_id;
	exception
		when no_data_found then
		null;
   		-- dbms_output.put_line('Returning Success 2 for p_site_id : '||p_site_id);
	end;

End if;

end;



Procedure Check_site_type_code(
 p_site_id_num 			IN		varchar2
,p_site_type_code  		IN 		varchar2
,x_return_flag  		OUT NOCOPY 	varchar2
) is
l_lookup_code		varchar2(30);
begin

begin
select 	LOOKUP_CODE
into 	l_lookup_code
from 	rrs_lookups_v
where 	LOOKUP_TYPE = 'RRS_SITE_TYPE'
and 	LOOKUP_CODE = p_site_type_code;
exception
	When no_data_found then
	x_return_flag := 'E';
end;
If l_lookup_code is NOT NULL Then
	x_return_flag := 'S';
end if;
end;



Procedure Check_site_status_code(
 p_site_id_num 			IN		varchar2
,p_site_status_code  		IN 		varchar2
,x_return_flag  		OUT NOCOPY 	varchar2
) is
l_lookup_code		varchar2(30);
begin

begin
select 	LOOKUP_CODE
into 	l_lookup_code
from 	rrs_lookups_v
where 	LOOKUP_TYPE = 'RRS_SITE_STATUS'
and 	LOOKUP_CODE = p_site_status_code;
exception
	When no_data_found then
	x_return_flag := 'E';
end;
If l_lookup_code is NOT NULL Then
	x_return_flag := 'S';
end if;
end;


Procedure Check_site_brand_code(
 p_site_id_num 			IN		varchar2
,p_site_brand_code  		IN 		varchar2
,x_return_flag  		OUT NOCOPY 	varchar2
) is
l_lookup_code 		varchar2(30);
begin

begin
select 	Lookup_code
into 	l_lookup_code
from 	rrs_lookups_v
where 	lookup_type = 'RRS_BRAND_NAME'
and 	lookup_code = p_site_brand_code;
exception
	when no_data_found then
		x_return_flag := 'E';

end;
If l_lookup_code is NOT NULL then
	x_return_flag := 'S';
end if;
end;


Procedure Check_site_use_type_code(
p_site_id_num 			IN		varchar2
,p_site_use_type_code 		IN		varchar2
,x_return_flag 			OUT NOCOPY	varchar2
) is

l_site_use_type_code		varchar2(30);

begin


begin
Select  LOOKUP_CODE
into	l_site_use_type_code
From    Fnd_Lookup_Values
Where   Lookup_Type In ('PARTY_SITE_USE_CODE' )
AND     View_Application_Id In ( 222 )
AND	Language = userenv('Lang')
And     Security_Group_Id = 0
AND	LOOKUP_CODE = p_site_use_type_code;
exception
        When no_data_found then
                x_return_flag := 'E';

end;
If l_site_use_type_code is NOT NULL then
        x_return_flag := 'S';
end if;


end;



Procedure Check_site_calendar_code(
 p_site_id_num 			IN		varchar2
,p_site_calendar_code  		IN 		varchar2
,x_return_flag  		OUT NOCOPY 	varchar2
) is
l_calendar_code			varchar2(30);
begin


begin
select calendar_code
into 	l_calendar_code
from 	BOM_CALENDARS
where 	calendar_code = p_site_calendar_code;
exception
	When no_data_found then
		x_return_flag := 'E';

end;
If l_calendar_code is NOT NULL then
	x_return_flag := 'S';
end if;
end;


Procedure Check_location_id(
p_site_id_num 			IN		varchar2
,p_location_id                  IN              number
,p_country_code			IN		varchar2
,x_return_flag                  OUT NOCOPY      varchar2
)is
l_location_id			number;
begin

begin

select 	location_id
into 	l_location_id
from 	hz_locations
where 	location_id = p_location_id;
/*
and	country = p_country_code
*/
exception
	When no_data_found then
		x_return_flag := 'E';

end;
If l_location_id is NOT NULL then
	x_return_flag := 'S';
end if;

end;



Procedure Check_address1(
p_site_id_num 			IN 		varchar2
,p_location_status 		IN		varchar2
,p_location_id 			IN		number
,p_country_code 		IN		varchar2
,p_address1 			IN		varchar2
,x_return_flag 			OUT NOCOPY	varchar2
) is

l_address1		varchar2(240);
begin

begin
select address1
/*
	,address2
	,address3
	,address4
	,address_lines_phonetic
	,city
	,postal_code
	,state
	,province
	,county
*/
Into 	l_address1
From 	HZ_locations
where   address1 = p_address1
and 	country = p_country_code;
exception
        When no_data_found then
		IF p_location_status = 'E' Then
                	x_return_flag := 'E';
		elsif p_location_status = 'N' then
			x_return_flag := 'S';
		end if;

        When too_many_rows then
		IF p_location_status = 'E' Then
                	x_return_flag := 'E';
		elsif p_location_status = 'N' then
			x_return_flag := 'S';
		end if;
        When others then
                x_return_flag := 'E';


end;
If l_address1 is NOT NULL Then
	x_return_flag := 'S';
end if;

end;





Procedure Check_site_party_id(
p_site_id_num                   IN              varchar2
,p_site_party_id                IN              number
,x_return_flag                  OUT NOCOPY      varchar2
)is
l_site_party_id		number;

Begin

Begin
SELECT 	HP.PARTY_ID
into 	l_site_party_id
FROM 	HZ_PARTIES HP, HZ_ORGANIZATION_PROFILES HOP
WHERE 	HP.PARTY_ID = HOP.PARTY_ID
AND 	HP.PARTY_ID = p_site_party_id
AND 	NVL(HOP.INTERNAL_FLAG,'N') = 'N'
AND 	HP.PARTY_TYPE = 'ORGANIZATION'
AND 	SYSDATE BETWEEN NVL(TRUNC(EFFECTIVE_START_DATE),TRUNC(SYSDATE)) AND NVL(EFFECTIVE_END_DATE,TRUNC(SYSDATE)+1);
exception
	When no_data_found then
		x_return_flag := 'E';

end;
If l_site_party_id is NOT NULL then
	x_return_flag := 'S';
end if;

end;


Procedure Check_le_party_id(
p_site_id_num                   IN              varchar2
,p_le_party_id                	IN              number
,x_return_flag                  OUT NOCOPY      varchar2
)is
l_le_party_id 		number;
Begin

Begin

SELECT xep.legal_entity_id
into	l_le_party_id
FROM xle_entity_profiles xep,
     xle_registrations xr,
     xle_jurisdictions_vl jur,
     hr_locations hl,
     hz_geographies b,
     hz_parties hp,
     xle_lookups l,
     xle_lookups l1
WHERE l.lookup_type = 'XLE_YES_NO'
AND l.lookup_code = xep.transacting_entity_flag
AND xep.geography_id = b.geography_id
AND xr.location_id = hl.location_id
AND xr.source_id = xep.legal_entity_id
AND xr.identifying_flag='Y'
AND xr.source_table = 'XLE_ENTITY_PROFILES'
AND jur.jurisdiction_id=xr.jurisdiction_id
AND l1.lookup_type = 'XLE_REG_CODE'
AND jur.registration_code_le = l1.lookup_code
AND hp.party_id = xep.party_id
AND SYSDATE < NVL(xep.effective_to, SYSDATE + 1)
AND xep.party_id = p_le_party_id;
exception
	When no_data_found then
		x_return_flag := 'E';

end;
If l_le_party_id is NOT NULL then
	x_return_flag := 'S';
end if;

end;


Procedure Check_location_country(
p_site_id_num                   IN              varchar2
,p_location_id 			IN		number
,p_country_code  		IN		varchar2
,x_return_flag 			OUT NOCOPY	varchar2
) is

l_country_code 			varchar2(3);
begin

begin
Select 	Territory_code
into 	l_country_code
From 	Fnd_Territories_Vl
where 	Territory_code = p_country_code
and 	obsolete_flag = 'N';
exception
	When no_data_found then
		x_return_flag := 'E';

end;
if l_country_code is NOT NULL then
	x_return_flag := 'S';
end if;

end;

Procedure Check_geo_source_code(
 p_site_id_num 			IN		varchar2
,p_geo_source_code  		IN 		varchar2
,x_return_flag  		OUT NOCOPY 	varchar2
) is
l_lookup_code		varchar2(30);
begin

begin
select 	LOOKUP_CODE
into 	l_lookup_code
from 	rrs_lookups_v
where 	LOOKUP_TYPE = 'RRS_GEO_SOURCE'
and 	LOOKUP_CODE = p_geo_source_code;
exception
	When no_data_found then
	x_return_flag := 'E';
end;


If l_lookup_code is NOT NULL Then
	x_return_flag := 'S';
end if;

end;



Procedure Write_interface_errors(
p_processing_errors 	IN 		RRS_PROCESSING_ERRORS_TAB
)is
conc_status	Boolean;
begin

INSERT into RRS_INTERFACE_ERRORS(
SITE_ID,
SITE_IDENTIFICATION_NUMBER,
COLUMN_NAME,
MESSAGE_NAME,
MESSAGE_TYPE,
MESSAGE_TEXT,
SOURCE_TABLE_NAME,
DESTINATION_TABLE_NAME,
CREATED_BY,
CREATION_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATE_LOGIN,
REQUEST_ID,
PROGRAM_APPLICATION_ID,
PROGRAM_ID,
PROGRAM_UPDATE_DATE,
PROCESS_STATUS,
TRANSACTION_TYPE,
BATCH_ID
)
(select
*
from table( p_processing_errors)
);

If ( sql%rowcount ) > 0 then
        FND_FILE.put_line(FND_FILE.LOG, 'Few records failed the validations. Please check  the interface errors table for details. ');
	conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING', 'Warning: One or more rows errored due to validation checks. ');
end if;


end;


Procedure prepare_error_mesg(
 p_site_id			IN		varchar2
,p_site_id_num 			IN		varchar2
,p_column_name 			IN		varchar2
,p_message_name 		IN		varchar2
,p_message_text 		IN		varchar2
,p_source_table_name 		IN		varchar2
,p_destination_table_name 	IN		varchar2
,p_process_status 		IN		varchar2
,p_transaction_type 		IN		varchar2
,p_batch_id 			IN		number
,p_processing_errors		IN OUT NOCOPY   RRS_PROCESSING_ERRORS_TAB
)is
begin


p_processing_errors.Extend();
p_processing_errors(p_processing_errors.Last) := rrs_processing_errors_rec(
                                                                        p_site_id
                                                                        ,p_site_id_num
                                                                        ,p_column_name
                                                                        ,p_message_name
                                                                        ,'C'
                                                                        ,p_message_text
                                                                        ,p_source_table_name
                                                                        ,p_destination_table_name
                                                                        ,G_USER_ID
                                                                        ,sysdate
                                                                        ,G_USER_ID
                                                                        ,sysdate
                                                                        ,G_LOGIN_ID
                                                                        ,G_REQUEST_ID
                                                                        ,G_APPLICATION_ID
                                                                        ,G_PROGAM_ID
                                                                        ,sysdate
                                                                        ,p_process_status
                                                                        ,p_transaction_type
                                                                        ,p_batch_id
                                                                        );


end;


Procedure Create_sites(
p_batch_id			IN			number
,p_transaction_type		IN			varchar2
,p_purge_rows			IN			varchar2
,x_num_rows			OUT NOCOPY 		number
,x_return_status		OUT NOCOPY 		varchar2
)is

conc_status 		Boolean;
begin

	/***********************************************
 * 	Here the code starts for copying the validation succeeded data from Interface
 * 	tables into base tables.
 * 	************************************************/

Begin

insert into rrs_sites_b
(
SITE_ID
,SITE_IDENTIFICATION_NUMBER
,SITE_TYPE_CODE
,SITE_STATUS_CODE
,BRANDNAME_CODE
,CALENDAR_CODE
,LOCATION_ID
,SITE_PARTY_ID
,PARTY_SITE_ID
,LE_PARTY_ID
,IS_TEMPLATE_FLAG
,CREATED_BY
,CREATION_DATE
,LAST_UPDATED_BY
,LAST_UPDATE_DATE
,LAST_UPDATE_LOGIN
)
(select
rrs_sites_s.nextval
,SITE_IDENTIFICATION_NUMBER
,SITE_TYPE_CODE
,SITE_STATUS_CODE
,BRANDNAME_CODE
,CALENDAR_CODE
,LOCATION_ID
,SITE_PARTY_ID
,PARTY_SITE_ID
,LE_PARTY_ID
,'N'
,G_USER_ID
,SYSDATE
,LAST_UPDATED_BY
,SYSDATE
,LAST_UPDATE_LOGIN
From 	RRS_SITES_INTERFACE
where 	batch_id = p_batch_id
and 	transaction_type = G_TX_TYPE_CREATE
and 	process_status = G_PS_IN_PROCESS
) ;
Exception
	When Others Then
	Rollback;
        conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', 'Error: Unexpected Error occured during processing of Sites data.  ');

End;

If ( sql%rowcount ) > 0 then
	FND_FILE.put_line(FND_FILE.LOG, 'Total No. of Sites Created : '||to_char(sql%rowcount));
end if;

Begin

insert into RRS_SITES_TL(
SITE_ID
,NAME
,LANGUAGE
,SOURCE_LANG
,CREATED_BY
,CREATION_DATE
,LAST_UPDATED_BY
,LAST_UPDATE_DATE
,LAST_UPDATE_LOGIN
,DESCRIPTION
)
(select
B.site_id
,a.SITE_NAME
,L.LANGUAGE_CODE
,userenv('LANG')
,G_USER_ID
,SYSDATE
,a.LAST_UPDATED_BY
,SYSDATE
,a.LAST_UPDATE_LOGIN
,NULL
From    RRS_SITES_INTERFACE A ,RRS_SITES_B B, FND_LANGUAGES L
where   batch_id = p_batch_id
and     transaction_type = G_TX_TYPE_CREATE
and     process_status = G_PS_IN_PROCESS
and 	A.site_identification_number = b.site_identification_number
and 	L.INSTALLED_FLAG in ('I', 'B')
and 	not exists
    	(select NULL
    	from RRS_SITES_TL T
    	where T.SITE_ID = B.site_id
    	and T.LANGUAGE = L.LANGUAGE_CODE)
);

Exception
	When Others Then
	Rollback;
        conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', 'Error: Unexpected Error occured during processing of Sites data.  ');

end;

If ( sql%rowcount ) > 0 then
        FND_FILE.put_line(FND_FILE.LOG, 'Few records failed the validations. Please check  the interface errors table for details. ');
        conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING', 'Warning: One or more rows errored due to validation checks. ');
end if;



Begin

insert into RRS_SITE_USES(
 SITE_USE_ID
,SITE_ID
,SITE_USE_TYPE_CODE
,STATUS_CODE
,IS_PRIMARY_FLAG
,OBJECT_VERSION_NUMBER
,CREATED_BY
,CREATION_DATE
,LAST_UPDATED_BY
,LAST_UPDATE_DATE
,LAST_UPDATE_LOGIN
)
(
Select
rrs_site_uses_s.nextval
,B.SITE_ID
,A.SITE_USE_TYPE_CODE
,'A'
,'Y'
,1
,G_USER_ID
,SYSDATE
,G_USER_ID
,SYSDATE
,G_LOGIN_ID
From    RRS_SITES_INTERFACE A ,RRS_SITES_B B
where   batch_id = p_batch_id
and     transaction_type = G_TX_TYPE_CREATE
and     process_status = G_PS_IN_PROCESS
and	A.SITE_USE_TYPE_CODE is NOT NULL
and     A.site_identification_number = B.site_identification_number
);

Exception
	When Others Then
	Rollback;
        conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', 'Error: Unexpected Error occured during processing of Sites data.  ');

end;


If (  p_purge_rows = 'Y' ) THEN
	DELETE from RRS_SITES_INTERFACE
	where   batch_id = p_batch_id
	and     transaction_type = G_TX_TYPE_CREATE
	and     process_status = G_PS_IN_PROCESS;
else

	UPDATE	RRS_SITES_INTERFACE
	SET	PROCESS_STATUS = G_PS_SUCCESS
	WHERE 	PROCESS_STATUS= G_PS_IN_PROCESS
	AND	BATCH_ID = p_batch_id
	AND	TRANSACTION_TYPE= G_TX_TYPE_CREATE;

end if;


end;


Procedure Validate_update_rows(
p_batch_id                      IN              number
,p_purge_rows                	IN              varchar2
,x_return_flag                  OUT NOCOPY      varchar2
) is

p_site_id                       varchar2(30);
p_site_id_num                   varchar2(30);
l_found                         varchar2(1);
l_batch_id                      number;
l_row_status                    varchar2(1);
p_transaction_type              varchar2(6);

l_geo_source			varchar2(30);

cursor c_update_interface_row (l_batch_id number )is
select
a.SITE_ID site_id_intf
,a.SITE_IDENTIFICATION_NUMBER site_id_num_intf
,a.SITE_NAME site_name_intf
,a.SITE_TYPE_CODE site_type_code_intf
,a.SITE_STATUS_CODE site_status_code_intf
,a.SITE_USE_TYPE_CODE site_use_type_code_intf
,a.BRANDNAME_CODE brandname_code_intf
,a.CALENDAR_CODE calendar_code_intf
,a.LOCATION_STATUS location_status_intf
,a.LOCATION_ID  location_id_intf
,a.SITE_PARTY_ID site_party_id_intf
,a.PARTY_SITE_ID party_site_id_intf
,a.LE_PARTY_ID le_party_id_intf
,a.ADDRESS1 address1_intf
,a.ADDRESS2 address2_intf
,a.ADDRESS3 address3_intf
,a.ADDRESS4 address4_intf
,a.ADDRESS_LINES_PHONETIC address_lines_phonetic_intf
,a.CITY city_intf
,a.POSTAL_CODE postal_code_intf
,a.STATE state_intf
,a.PROVINCE province_intf
,a.COUNTY county_intf
,a.COUNTRY country_intf
,a.GEOMETRY_SOURCE geometry_source_intf
,a.Longitude Longitude_intf
,a.Latitude Latitude_intf
,a.TRANSACTION_TYPE transaction_type_intf
,BATCH_PROCESSING
,BATCH_ID
,b.SITE_ID site_id
,b.SITE_IDENTIFICATION_NUMBER site_identification_number
,c.NAME site_name
,b.SITE_TYPE_CODE site_type_code
,b.SITE_STATUS_CODE site_status_code
,d.SITE_USE_TYPE_CODE site_use_type_code
,b.BRANDNAME_CODE brandname_code
,b.CALENDAR_CODE calendar_code
,b.LOCATION_ID  location_id
,b.SITE_PARTY_ID site_party_id
,b.PARTY_SITE_ID party_site_id
,b.LE_PARTY_ID le_party_id
,h.ADDRESS1 address1
,h.ADDRESS2 address2
,h.ADDRESS3 address3
,h.ADDRESS4 address4
,h.ADDRESS_LINES_PHONETIC address_lines_phonetic
,h.CITY city
,h.POSTAL_CODE postal_code
,h.STATE state
,h.PROVINCE province
,h.COUNTY county
,h.COUNTRY country
,h.GEOMETRY_SOURCE geometry_source
,h.object_version_number
FROM RRS_SITES_INTERFACE a, RRS_SITES_B B , RRS_SITES_TL C, RRS_SITE_USES D,
HZ_LOCATIONS H
WHERE TRANSACTION_TYPE = G_TX_TYPE_UPDATE
and  BATCH_ID = l_batch_id
and Process_status = G_PS_IN_PROCESS
and b.site_id = c.site_id
and c.language = userenv('Lang')
and a.site_id = d.site_id(+)
and d.is_primary_flag(+)  = 'Y'
and h.location_id = b.location_id
and a.site_identification_number = b.site_identification_number;


local_processing_errors         rrs_processing_errors_tab;
p_processing_errors     	rrs_processing_errors_tab;

p_init_msg_list         	varchar2(1) := 'T';
l_location_rec                  HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
p_location_rec                  HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;

p_organization_rec              HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE;
l_organization_rec              HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE;

p_party_site_rec                HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE;
l_party_site_rec                HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE;

p_party_usage_code              varchar2(30);

p_do_addr_val           	varchar2(1) :=  'Y';
x_location_id           	number;
x_addr_val_status       	varchar2(3);
x_addr_warn_msg         	varchar2(240);
x_return_status         	varchar2(1);
x_msg_count             	number;
x_msg_data              	varchar2(1000);

x_party_id              	number;
x_party_number          	number;
x_profile_id            	number;


x_party_site_id         	number;
x_party_site_number     	number;

l_update_location       	varchar2(1);
l_create_party          	varchar2(1);

Type rrs_site_id_rec is RECORD (site_id         RRS_SITES_B.SITE_ID%TYPE);
Type rrs_site_id_tab is TABLE OF NUMBER;
s_site_ids rrs_site_id_tab;

x_num_rows              	number;
p_object_version_number		number;



begin


/*
	Delete from RRS_INTERFACE_ERRORS
	Where	batch_id = p_batch_id
	and 	Transaction_type = G_TX_TYPE_UPDATE
	and	Process_status = '3';

*/

        /**************************************************************
 *     Before Starting all the validatios , let's mark all the rows in
 *     Interface table with status Validation started ( 2 ). After
 *     completion of this processing , all the rows in this batch should
 *     have status as either Validation failed ( 3 ) or Validation succeeded
 *     ( 4 )
 *       **************************************************************/

        Update RRS_SITES_INTERFACE
        Set     Process_status = G_PS_IN_PROCESS,
                REQUEST_ID = G_REQUEST_ID,
                PROGRAM_APPLICATION_ID = G_PROGAM_APPLICATION_ID,
                PROGRAM_ID = G_PROGAM_ID,
                PROGRAM_UPDATE_DATE = SYSDATE,
                CREATED_BY = G_USER_ID,
                CREATION_DATE = SYSDATE,
                LAST_UPDATED_BY = G_USER_ID,
                LAST_UPDATE_DATE = SYSDATE,
                LAST_UPDATE_LOGIN = G_LOGIN_ID

        Where   Batch_id = p_batch_id
        and     process_status = G_PS_TO_BE_PROCESSED
        and     transaction_type = G_TX_TYPE_UPDATE;

l_batch_id := p_batch_id;

FOR site_data IN  c_update_interface_row(l_batch_id) LOOP


p_processing_errors := rrs_processing_errors_tab();
local_processing_errors := rrs_processing_errors_tab();

l_row_status := 'S';
l_create_party := 'N';
l_update_location := 'N';

begin

        Check_site_id_num(
                        p_site_id_num=>site_data.site_id_num_intf
                        ,p_site_id=>site_data.site_id
                        ,p_transaction_type=>site_data.transaction_type_intf
                        ,x_return_flag=>x_return_flag
                        );
        if x_return_flag = 'S' AND l_row_status = 'S'  then
		null;
                -- dbms_output.put_line('Site Identification Number validation succeeded ');
        elsif x_return_flag = 'E' then
                l_row_status := 'E';
                prepare_error_mesg(
                                p_site_id => NULL
                                ,p_site_id_num => site_data.site_id_num_intf
                                ,p_column_name => 'SITE_IDENTIFICATION_NUMBER'
                                ,p_message_name => 'MESSAGE NAME'
                                ,p_message_text => 'Site Identification Number '||site_data.site_id_num_intf||' does not  exist, Enter an existing number.'
                                ,p_source_table_name => 'RRS_SITES_INTERFACE'
                                ,p_destination_table_name => 'RRS_SITES_B'
                                ,p_process_status => '3'
                                ,p_transaction_type => site_data.transaction_type_intf
                                ,p_batch_id => site_data.batch_id
                                ,p_processing_errors => local_processing_errors
                                );
        end if;

If site_data.site_name_intf is NULL Then
                l_row_status := 'E';
                prepare_error_mesg( p_site_id => NULL
                                ,p_site_id_num => site_data.site_id_num_intf
                                ,p_column_name => 'SITE_NAME'
                                ,p_message_name => 'MESSAGE NAME'
                                ,p_message_text => 'Site Name cannot be Null for : '||site_data.site_identification_number
                                ,p_source_table_name => 'RRS_SITES_INTERFACE'
                                ,p_destination_table_name => 'RRS_SITES_TL'
                                ,p_process_status => '3'
                                ,p_transaction_type => site_data.transaction_type_intf
                                ,p_batch_id => site_data.batch_id
                                ,p_processing_errors => local_processing_errors
                                );
end if;



If site_data.site_status_code_intf is NOT NULL then
	Check_site_status_code( p_site_id_num => site_data.site_id_num_intf
			      ,p_site_status_code => site_data.site_status_code_intf
			      ,x_return_flag => x_return_flag
				);
		if x_return_flag = 'S' AND l_row_status = 'S' then
			null;
 			-- dbms_output.put_line('Site status code validation succeeded ');
		elsif x_return_flag = 'E' then
			l_row_status := 'E';
			prepare_error_mesg(
				p_site_id => NULL
				,p_site_id_num => site_data.site_id_num_intf
				,p_column_name => 'SITE_STATUS_CODE'
				,p_message_name => 'MESSAGE NAME'
				,p_message_text => 'Site Status code is not valid  for site_id : '||site_data.site_identification_number
				,p_source_table_name => 'RRS_SITES_INTERFACE'
				,p_destination_table_name => 'RRS_SITES_B'
				,p_process_status => '3'
				,p_transaction_type => site_data.transaction_type_intf
				,p_batch_id => site_data.batch_id
				,p_processing_errors => local_processing_errors
				);
		end if;

else
			l_row_status := 'E';
		prepare_error_mesg(
				p_site_id => NULL
				,p_site_id_num => site_data.site_id_num_intf
				,p_column_name => 'SITE_STATUS_CODE'
				,p_message_name => 'MESSAGE NAME'
				,p_message_text => 'Site Status code cannot be null for site_id : '||site_data.site_id_num_intf
				,p_source_table_name => 'RRS_SITES_INTERFACE'
				,p_destination_table_name => 'RRS_SITES_B'
				,p_process_status => '3'
				,p_transaction_type => site_data.transaction_type_intf
				,p_batch_id => site_data.batch_id
				,p_processing_errors => local_processing_errors
				);

end if;


If site_data.brandname_code_intf is NOT NULL then
	Check_site_brand_code( p_site_id_num => site_data.site_id_num_intf
			      ,p_site_brand_code => site_data.brandname_code_intf
			      ,x_return_flag => x_return_flag
				);
	if x_return_flag = 'S' AND l_row_status = 'S' then
		null;
 		-- dbms_output.put_line('Brandname code code validation succeeded ');
	elsif x_return_flag = 'E' then
		l_row_status := 'E';
		prepare_error_mesg(
				p_site_id => NULL
				,p_site_id_num => site_data.site_id_num_intf
				,p_column_name => 'BRANDNAME_CODE'
				,p_message_name => 'MESSAGE NAME'
				,p_message_text => 'Brandname Code validation fails for : '||site_data.site_id_num_intf
				,p_source_table_name => 'RRS_SITES_INTERFACE'
				,p_destination_table_name => 'RRS_SITES_B'
				,p_process_status => '3'
				,p_transaction_type => site_data.transaction_type_intf
				,p_batch_id => site_data.batch_id
				,p_processing_errors => local_processing_errors
				);
	end if;

end if;


if site_data.calendar_code_intf is NOT NULL then
	Check_site_calendar_code( p_site_id_num => site_data.site_id_num_intf
			      ,p_site_calendar_code => site_data.calendar_code_intf
			      ,x_return_flag => x_return_flag
				);
	if x_return_flag = 'S' AND l_row_status = 'S' then
		null;
 		-- dbms_output.put_line('Calendar code validation succeeded ');
	elsif x_return_flag = 'E' then
		l_row_status := 'E';
		prepare_error_mesg(
				p_site_id => NULL
				,p_site_id_num => site_data.site_id_num_intf
				,p_column_name => 'CALENDAR_CODE'
				,p_message_name => 'MESSAGE NAME'
				,p_message_text => 'Calendar Code validation fails for : '||site_data.site_id_num_intf
				,p_source_table_name => 'RRS_SITES_INTERFACE'
				,p_destination_table_name => 'RRS_SITES_B'
				,p_process_status => '3'
				,p_transaction_type => site_data.transaction_type_intf
				,p_batch_id => site_data.batch_id
				,p_processing_errors => local_processing_errors
				);
	end if;

end if;

If site_data.site_use_type_code IS NULL Then
	x_return_flag := 'S';

elsif  site_data.site_use_type_code is NOT NULL and ( site_data.site_use_type_code <> site_data.site_use_type_code_intf ) then
	l_row_status := 'E';
		prepare_error_mesg(
				p_site_id => NULL
				,p_site_id_num => site_data.site_id_num_intf
				,p_column_name => 'SITE_USE_TYPE_CODE'
				,p_message_name => 'MESSAGE NAME'
				,p_message_text => 'Site Use Type Code ( Purpose ) Code cannot be changed for : '||site_data.site_id_num_intf
				,p_source_table_name => 'RRS_SITES_INTERFACE'
				,p_destination_table_name => 'RRS_SITE_USES'
				,p_process_status => '3'
				,p_transaction_type => site_data.transaction_type_intf
				,p_batch_id => site_data.batch_id
				,p_processing_errors => local_processing_errors
				);

end if;


if site_data.location_status_intf = 'E' and site_data.Location_id IS NOT NULL and site_data.address1_intf is NOT NULL then


	If (  	site_data.address1_intf <> site_data.address1 OR
	 	site_data.address2_intf <> site_data.address2 OR
	 	site_data.address3_intf <> site_data.address3 OR
	 	site_data.address4_intf <> site_data.address4 OR
	 	site_data.address_lines_phonetic_intf <> site_data.address_lines_phonetic OR
	 	site_data.city_intf <> site_data.city OR
	 	site_data.postal_code_intf <> site_data.postal_code OR
	 	site_data.state_intf <> site_data.state OR
	 	site_data.province_intf <> site_data.province OR
	 	site_data.county_intf <> site_data.county
		) Then


		l_update_location := 'Y';

/*
                update_address( p_site_id_num => site_data.site_id_num_intf
                              ,p_location_id => site_data.location_id_intf
                              ,p_location_status => site_data.location_status_intf
                              ,p_country_code => site_data.country_intf
                              ,p_address1 => site_data.address1_intf
                              ,x_return_flag => x_return_flag
                                );
        	if x_return_flag = 'S' AND l_row_status = 'S' then
                	dbms_output.put_line('Location ID validation succeeded 2');
        	elsif x_return_flag = 'E' then
                	l_row_status := 'E';
                	prepare_error_mesg(
                                p_site_id => NULL
                                ,p_site_id_num => site_data.site_id_num_intf
                                ,p_column_name => 'ADDRESS1'
                                ,p_message_name => 'MESSAGE NAME'
                                ,p_message_text => 'Location Status and Address combination is not  valid for : '||site_data.site_id_num_intf
                                ,p_source_table_name => 'RRS_SITES_INTERFACE'
                                ,p_destination_table_name => 'HZ_LOCATIONS'
                                ,p_process_status => '3'
                                ,p_transaction_type => site_data.transaction_type_intf
                                ,p_batch_id => site_data.batch_id
                                ,p_processing_errors => local_processing_errors
                                );
        	end if;
*/
	end if;
else
                 l_row_status := 'E';
                prepare_error_mesg(
                                p_site_id => NULL
                                ,p_site_id_num => site_data.site_id_num_intf
                                ,p_column_name => 'LOCATION_STATUS'
                                ,p_message_name => 'MESSAGE NAME'
                                ,p_message_text => 'Location Status cannot be null or New  for : '||site_data.site_id_num_intf
                                ,p_source_table_name => 'RRS_SITES_INTERFACE'
                                ,p_destination_table_name => 'HZ_LOCATIONS'
                                ,p_process_status => '3'
                                ,p_transaction_type => site_data.transaction_type_intf
                                ,p_batch_id => site_data.batch_id
                                ,p_processing_errors => local_processing_errors
                                );

End if;



If ( ( site_data.LONGITUDE_intf is NOT NULL AND site_data.LATITUDE_intf is NULL ) OR
	( site_data.LONGITUDE_intf is NULL and site_data.LATITUDE_intf is NOT NULL )) Then

		l_row_status := 'E';
		prepare_error_mesg(
				p_site_id => NULL
				,p_site_id_num => site_data.site_id_num_intf
				,p_column_name => 'LONGITUDE LATITUDE'
				,p_message_name => 'MESSAGE NAME'
				,p_message_text => 'Both longitude and latitude should be either Null or Not Null for : '||site_data.site_id_num_intf
				,p_source_table_name => 'RRS_SITES_INTERFACE'
				,p_destination_table_name => 'HZ_LOCATIONS'
				,p_process_status => '3'
				,p_transaction_type => site_data.transaction_type_intf
				,p_batch_id => site_data.batch_id
				,p_processing_errors => local_processing_errors
				);
elsif (  site_data.LONGITUDE_intf is NOT NULL AND site_data.LATITUDE_intf is NOT NULL  ) then
	if (site_data.Longitude_intf < -180 OR site_data.Longitude_intf > 180 )  then
		l_row_status := 'E';
		prepare_error_mesg(
				p_site_id => NULL
				,p_site_id_num => site_data.site_id_num_intf
				,p_column_name => 'LONGITUDE '
				,p_message_name => 'MESSAGE NAME'
				,p_message_text => 'Longitude should be between -180 and 180 for : '||site_data.site_id_num_intf
				,p_source_table_name => 'RRS_SITES_INTERFACE'
				,p_destination_table_name => 'HZ_LOCATIONS'
				,p_process_status => '3'
				,p_transaction_type => site_data.transaction_type_intf
				,p_batch_id => site_data.batch_id
				,p_processing_errors => local_processing_errors
				);

	elsif ( site_data.latitude_intf < -90 OR site_data.latitude_intf > 90 ) then
		l_row_status := 'E';
		prepare_error_mesg(
				p_site_id => NULL
				,p_site_id_num => site_data.site_id_num_intf
				,p_column_name => 'LATITUDE'
				,p_message_name => 'MESSAGE NAME'
				,p_message_text => 'Latitude should be between -90 and 90 for : '||site_data.site_id_num_intf
				,p_source_table_name => 'RRS_SITES_INTERFACE'
				,p_destination_table_name => 'HZ_LOCATIONS'
				,p_process_status => '3'
				,p_transaction_type => site_data.transaction_type_intf
				,p_batch_id => site_data.batch_id
				,p_processing_errors => local_processing_errors
				);

	end if;


end if;


If ( site_data.GEOMETRY_SOURCE_intf is NOT NULL ) then

        Check_geo_source_code( p_site_id_num => site_data.site_id_num_intf
                              ,p_geo_source_code => site_data.geometry_source_intf
                              ,x_return_flag => x_return_flag
                                );
        if x_return_flag = 'S' AND l_row_status = 'S' then
                null;
        elsif x_return_flag = 'E' then
                l_row_status := 'E';
		prepare_error_mesg(
				p_site_id => NULL
				,p_site_id_num => site_data.site_id_num_intf
				,p_column_name => 'GEOMETRY_SOURCE'
				,p_message_name => 'MESSAGE NAME'
				,p_message_text => 'Geometry Source Code validation fails for : '||site_data.site_id_num_intf
				,p_source_table_name => 'RRS_SITES_INTERFACE'
				,p_destination_table_name => 'HZ_LOCATIONS'
				,p_process_status => '3'
				,p_transaction_type => site_data.transaction_type_intf
				,p_batch_id => site_data.batch_id
				,p_processing_errors => local_processing_errors
				);
	end if;

end if ;


If site_data.GEOMETRY_SOURCE_intf is NULL and site_data.LONGITUDE_intf is NOT NULL and site_data.LATITUDE_intf is NOT NULL then
		l_geo_source := 'RRS_USER_ENTERED';


elsif site_data.GEOMETRY_SOURCE_intf is NULL and site_data.LONGITUDE_intf is NULL and site_data.LATITUDE_intf is NULL then

		l_geo_source := 'RRS_GOOGLE';


elsif site_data.GEOMETRY_SOURCE_intf = 'RRS_GOOGLE' and site_data.LONGITUDE_intf is NOT NULL and site_data.LATITUDE_intf is NOT NULL then
		l_row_status := 'E';
		prepare_error_mesg(
				p_site_id => NULL
				,p_site_id_num => site_data.site_id_num_intf
				,p_column_name => 'GEOMETRY_SOURCE'
				,p_message_name => 'MESSAGE NAME'
				,p_message_text => 'Longitude-Latitude should be Null for Geometry Source as System Generated for : '||site_data.site_id_num_intf
				,p_source_table_name => 'RRS_SITES_INTERFACE'
				,p_destination_table_name => 'HZ_LOCATIONS'
				,p_process_status => '3'
				,p_transaction_type => site_data.transaction_type_intf
				,p_batch_id => site_data.batch_id
				,p_processing_errors => local_processing_errors
				);

end if;




If site_data.site_type_code_intf is NULL then
        l_row_status := 'E';
                prepare_error_mesg(
                                p_site_id => NULL
                                ,p_site_id_num => site_data.site_id_num_intf
                                ,p_column_name => 'SITE_TYPE_CODE'
                                ,p_message_name => 'MESSAGE NAME'
                                ,p_message_text => 'Site type code cannot be null for site_id : '||site_data.site_id_num_intf
                                ,p_source_table_name => 'RRS_SITES_INTERFACE'
                                ,p_destination_table_name => 'RRS_SITES_B'
                                ,p_process_status => '3'
                                ,p_transaction_type => site_data.transaction_type_intf
                                ,p_batch_id => site_data.batch_id
                                ,p_processing_errors => local_processing_errors
                                );

elsif  site_data.site_type_code is NOT NULL and site_data.site_party_id is NOT NULL and site_data.site_type_code <> site_data.site_type_code_intf then
        l_row_status := 'E';
                prepare_error_mesg(
                                p_site_id => NULL
                                ,p_site_id_num => site_data.site_id_num_intf
                                ,p_column_name => 'SITE_TYPE_CODE'
                                ,p_message_name => 'MESSAGE NAME'
                                ,p_message_text => 'Site type code cannot be changed for site_id : '||site_data.site_id_num_intf
                                ,p_source_table_name => 'RRS_SITES_INTERFACE'
                                ,p_destination_table_name => 'RRS_SITES_B'
                                ,p_process_status => '3'
                                ,p_transaction_type => site_data.transaction_type_intf
                                ,p_batch_id => site_data.batch_id
                                ,p_processing_errors => local_processing_errors
                                );


elsif  site_data.site_type_code = 'E' AND (site_data.party_site_id_intf IS NOT NULL OR site_data.le_party_id_intf is NOT NULL )  then
        l_row_status := 'E';
                prepare_error_mesg(
                                p_site_id => NULL
                                ,p_site_id_num => site_data.site_id_num_intf
                                ,p_column_name => 'SITE_TYPE_CODE'
                                ,p_message_name => 'MESSAGE NAME'
                                ,p_message_text => 'Site type code cannot be changed for site_id : '||site_data.site_id_num_intf
                                ,p_source_table_name => 'RRS_SITES_INTERFACE'
                                ,p_destination_table_name => 'RRS_SITES_B'
                                ,p_process_status => '3'
                                ,p_transaction_type => site_data.transaction_type_intf
                                ,p_batch_id => site_data.batch_id
                                ,p_processing_errors => local_processing_errors
                                );


elsif  ( site_data.site_type_code = 'E' and site_data.site_party_id is NOT NULL AND site_data.site_party_id_intf <> site_data.site_party_id  ) then
                l_row_status := 'E';
                prepare_error_mesg(
                                p_site_id => NULL
                                ,p_site_id_num => site_data.site_id_num_intf
                                ,p_column_name => 'SITE_PARTY_ID'
                                ,p_message_name => 'MESSAGE NAME'
                                ,p_message_text => 'Site Party ID cannot be changed for : '||site_data.site_id_num_intf
                                ,p_source_table_name => 'RRS_SITES_INTERFACE'
                                ,p_destination_table_name => 'RRS_SITES_B'
                                ,p_process_status => '3'
                                ,p_transaction_type => site_data.transaction_type_intf
                                ,p_batch_id => site_data.batch_id
                                ,p_processing_errors => local_processing_errors
                                );


elsif  site_data.site_type_code = 'E' and site_data.site_party_id is NULL AND site_data.site_party_id_intf IS NOT NULL then

        Check_site_party_id( p_site_id_num => site_data.site_id_num_intf
                              ,p_site_party_id => site_data.site_party_id_intf
                              ,x_return_flag => x_return_flag
                                );
        if x_return_flag = 'S' AND l_row_status = 'S' then
		null;
                -- dbms_output.put_line('Site type code and External Party validation succeeded ');
        elsif x_return_flag = 'E' then
                l_row_status := 'E';
                prepare_error_mesg(
                                p_site_id => NULL
                                ,p_site_id_num => site_data.site_id_num_intf
                                ,p_column_name => 'SITE_PARTY_ID'
                                ,p_message_name => 'MESSAGE NAME'
                                ,p_message_text => 'Site type code and External party validation fails for : '||site_data.site_id_num_intf
                                ,p_source_table_name => 'RRS_SITES_INTERFACE'
                                ,p_destination_table_name => 'RRS_SITES_B'
                                ,p_process_status => '3'
                                ,p_transaction_type => site_data.transaction_type_intf
                                ,p_batch_id => site_data.batch_id
                                ,p_processing_errors => local_processing_errors
                                );
        end if;

elsif  ( site_data.site_type_code = 'I' and site_data.site_party_id is NOT NULL AND site_data.le_party_id_intf <> site_data.le_party_id  ) then
                l_row_status := 'E';
                prepare_error_mesg(
                                p_site_id => NULL
                                ,p_site_id_num => site_data.site_id_num_intf
                                ,p_column_name => 'LE_PARTY_ID'
                                ,p_message_name => 'MESSAGE NAME'
                                ,p_message_text => 'LE Party ID cannot be changed for : '||site_data.site_id_num_intf
                                ,p_source_table_name => 'RRS_SITES_INTERFACE'
                                ,p_destination_table_name => 'RRS_SITES_B'
                                ,p_process_status => '3'
                                ,p_transaction_type => site_data.transaction_type_intf
                                ,p_batch_id => site_data.batch_id
                                ,p_processing_errors => local_processing_errors
                                );


elsif  site_data.site_type_code = 'I' and site_data.le_party_id is NULL AND site_data.le_party_id_intf  IS NOT NULL then

        Check_le_party_id( p_site_id_num => site_data.site_id_num_intf
                              ,p_le_party_id => site_data.le_party_id_intf
                              ,x_return_flag => x_return_flag
                                );
        if x_return_flag = 'S' AND l_row_status = 'S' then

                l_create_party := 'Y';
        elsif x_return_flag = 'E' then
                l_row_status := 'E';
                prepare_error_mesg(
                                p_site_id => NULL
                                ,p_site_id_num => site_data.site_id_num_intf
                                ,p_column_name => 'LE_PARTY_ID'
                                ,p_message_name => 'MESSAGE NAME'
                                ,p_message_text => 'Site type code and LE party validation fails for : '||site_data.site_id_num_intf
                                ,p_source_table_name => 'RRS_SITES_INTERFACE'
                                ,p_destination_table_name => 'RRS_SITES_B'
                                ,p_process_status => '3'
                                ,p_transaction_type => site_data.transaction_type_intf
                                ,p_batch_id => site_data.batch_id
                                ,p_processing_errors => local_processing_errors
                                );
        end if;
/*
 * else
 *         dbms_output.put_line(' Invalid combination of Site Type Code and Site
 *         Party ID for site_id : '||site_data.site_identification_number);
 *         */

elsif  site_data.site_type_code = 'I' and site_data.le_party_id is NULL AND site_data.le_party_id_intf IS NULL
	AND ( site_data.site_party_id_intf is NOT NULL OR site_data.party_site_id_intf is NOT NULL ) then
                l_row_status := 'E';
                prepare_error_mesg(
                                p_site_id => NULL
                                ,p_site_id_num => site_data.site_id_num_intf
                                ,p_column_name => 'LE_PARTY_ID'
                                ,p_message_name => 'MESSAGE NAME'
                                ,p_message_text => 'Site type code and Party validation fails for : '||site_data.site_id_num_intf
                                ,p_source_table_name => 'RRS_SITES_INTERFACE'
                                ,p_destination_table_name => 'RRS_SITES_B'
                                ,p_process_status => '3'
                                ,p_transaction_type => site_data.transaction_type_intf
                                ,p_batch_id => site_data.batch_id
                                ,p_processing_errors => local_processing_errors
                                );

else

        Check_site_type_code( p_site_id_num => site_data.site_id_num_intf
                              ,p_site_type_code => site_data.site_type_code_intf
                              ,x_return_flag => x_return_flag
                                );
        if x_return_flag = 'S' AND l_row_status = 'S' then
		null;
                -- dbms_output.put_line('Site type code validation succeeded ');
        elsif x_return_flag = 'E' then
                l_row_status := 'E';
                prepare_error_mesg(
                                p_site_id => NULL
                                ,p_site_id_num => site_data.site_id_num_intf
                                ,p_column_name => 'SITE_TYPE_CODE'
                                ,p_message_name => 'MESSAGE NAME'
                                ,p_message_text => 'Site type code validation fails for : '||site_data.site_id_num_intf
                                ,p_source_table_name => 'RRS_SITES_INTERFACE'
                                ,p_destination_table_name => 'RRS_SITES_B'
                                ,p_process_status => '3'
                                ,p_transaction_type => site_data.transaction_type_intf
                                ,p_batch_id => site_data.batch_id
                                ,p_processing_errors => local_processing_errors
                                );
        end if;
end if;




If l_update_location = 'Y'  and l_row_status = 'S' then


		l_location_rec.location_id := site_data.location_id;
		l_location_rec.country := site_data.country;
		l_location_rec.address1 := site_data.address1_intf;
		l_location_rec.address2 := site_data.address2_intf;
		l_location_rec.address3 := site_data.address3_intf;
		l_location_rec.address4 := site_data.address4_intf;
		l_location_rec.city := site_data.city_intf;
		l_location_rec.postal_code := site_data.postal_code_intf;
		l_location_rec.state := site_data.state_intf;
		l_location_rec.province := site_data.province_intf;
		l_location_rec.county := site_data.county_intf;
		l_location_rec.address_lines_phonetic := site_data.address_lines_phonetic_intf;


		hz_location_v2pub.update_location(p_init_msg_list => 'T'
						,p_location_rec => l_location_rec
						,p_do_addr_val => 'Y'
						,p_object_version_number => site_data.object_version_number
						,x_addr_val_status => x_addr_val_status
						,x_addr_warn_msg => x_addr_warn_msg
						,x_return_status => x_return_status
						,x_msg_count => x_msg_count
						,x_msg_data => x_msg_data
						);

		If x_return_status = 'S'  AND  l_row_status = 'S' then
			null;
			-- dbms_output.put_line('location updated  for Site : '||site_data.site_identification_number);

		else
			l_row_status := 'E';

		end if;


end if;


-- Party Creation

If l_create_party = 'Y'  and  l_row_status = 'S'  then

-- Party Creation

		l_organization_rec.organization_name := site_data.site_identification_number;
		l_organization_rec.created_by_module := 'RRS';

		hz_party_v2pub.create_organization(p_organization_rec => l_organization_rec
						  ,p_party_usage_code => 'REAL_ESTATE'
 						  ,x_return_status => x_return_status
 						  ,x_msg_count => x_msg_count
 						  ,x_msg_data => x_msg_data
 						  ,x_party_id => x_party_id
 						  ,x_party_number => x_party_number
 						  ,x_profile_id => x_profile_id
						);
                If x_return_status = 'S' AND l_row_status = 'S' then

			null;
                        -- dbms_output.put_line('New Party  ID for Site : '||site_data.site_identification_number||' is => '||x_party_id);

                else
                        l_row_status := 'E';

                end if;



-- Party Site Creation


		l_party_site_rec.location_id := site_data.location_id;

		l_party_site_rec.party_id := x_party_id;
		l_party_site_rec.identifying_address_flag := 'Y';
		l_party_site_rec.created_by_module := 'RRS';

		hz_party_site_v2pub.create_party_site( p_init_msg_list => 'T'
							,p_party_site_rec => l_party_site_rec
						 	,x_party_site_id => x_party_site_id
 							,x_party_site_number => x_party_site_number
 							,x_return_status => x_return_status
 							,x_msg_count => x_msg_count
 							,x_msg_data => x_msg_data
							);
                If x_return_status = 'S' AND l_row_status = 'S' then

			null;
                        -- dbms_output.put_line('New Party Site ID for Site : '||site_data.site_identification_number||' is => '||x_party_site_id);

                else
                        l_row_status := 'E';

                end if;


end if;

 If l_row_status = 'S' then
-- call for updating HZ_Locations for Geometry coordinates.
	RRS_SITE_UTILS.Update_geometry_for_locations ( p_loc_id => site_data.location_id
							,p_lat => site_data.latitude_intf
							,p_long => site_data.longitude_intf
							,p_status => 'GOOD'
							,p_geo_source => nvl(site_data.geometry_source_intf , l_geo_source )
							,x_return_status => x_return_status
							,x_msg_count => x_msg_count
							,x_msg_data => x_msg_data
							);

                If x_return_status = 'S' AND l_row_status = 'S' then
                        null;

                elsif x_return_status = 'E'  then
                        l_row_status := 'E';
                        prepare_error_mesg( p_site_id => NULL
                                ,p_site_id_num => site_data.site_id_num_intf
                                ,p_column_name => 'GEOMETRY_SOURCE'
                                ,p_message_name => 'MESSAGE NAME'
                                ,p_message_text => 'Error Updating the Geometry Information for : '||site_data.site_id_num_intf
                                ,p_source_table_name => 'RRS_SITES_INTERFACE'
                                ,p_destination_table_name => 'HZ_LOCATIONS'
                                ,p_process_status => '3'
                                ,p_transaction_type => site_data.transaction_type_intf
                                ,p_batch_id => site_data.batch_id
                                ,p_processing_errors => local_processing_errors
                                );

                end if;
end if;



	/********************************************
  	Here we will check if all the validations are successful so far,
 	we will update the process_status of this row to be Validation_succeeded
	( 4 )
	*********************************************/

If l_row_status = 'S' then

	if l_create_party = 'Y' then

        	update rrs_sites_interface
        	set     site_party_id = x_party_id ,
			party_site_id = x_party_site_id
        	where   site_identification_number = site_data.site_id_num_intf;
	end if;

/*
	Update RRS_SITES_INTERFACE
	Set 	Process_status = G_PS_SUCCESS
	Where	Batch_id = p_batch_id
	and 	process_status = G_PS_IN_PROCESS
	and 	site_identification_number = site_data.site_id_num_intf
	and 	transaction_type = G_TX_TYPE_UPDATE;
*/

elsif l_row_status = 'E' then

	Update RRS_SITES_INTERFACE
	Set 	Process_status = '3'
	Where	Batch_id = p_batch_id
	and 	process_status = G_PS_IN_PROCESS
	and 	site_identification_number = site_data.site_id_num_intf
	and 	transaction_type = G_TX_TYPE_UPDATE;

	Write_interface_errors(p_processing_errors => local_processing_errors);
else

	/*********************
 * 	This behaviour should never happen but I am documenting for exceptional
 * 	case. Update all the rows with process_status = '2' to '1' after
 * 	completion of the processing logic. It should always return 0 rows.
 	* *********************/

        Update RRS_SITES_INTERFACE
        Set     Process_status = G_PS_TO_BE_PROCESSED
        Where   Batch_id = p_batch_id
        and     process_status = G_PS_IN_PROCESS
        and     transaction_type in ( G_TX_TYPE_UPDATE );

end if;

end;


End Loop;

        Update_sites(
                        p_batch_id => p_batch_id
                        ,p_transaction_type => G_TX_TYPE_UPDATE
                        ,p_purge_rows => p_purge_rows
                        ,x_num_rows => x_num_rows
                        ,x_return_status => x_return_status
                        );



end;

Procedure Update_sites(
p_batch_id                      IN                      number
,p_transaction_type             IN                      varchar2
,p_purge_rows                	IN                      varchar2
,x_num_rows                     OUT NOCOPY              number
,x_return_status                OUT NOCOPY              varchar2
)is


begin

        /***********************************************
 *      Here the code starts for copying the validation succeeded data from
 *    Interface tables into base tables.
 *      ************************************************/


Update 	RRS_SITES_B A
Set 	(
	A.SITE_TYPE_CODE, A.SITE_STATUS_CODE , A.BRANDNAME_CODE , A.CALENDAR_CODE , A.SITE_PARTY_ID , A.PARTY_SITE_ID ,
	A.LE_PARTY_ID , A.OBJECT_VERSION_NUMBER , A.LAST_UPDATED_BY , A.LAST_UPDATE_DATE
	) =
(SELECT
 	B.SITE_TYPE_CODE , B.SITE_STATUS_CODE, B.BRANDNAME_CODE, B.CALENDAR_CODE, B.SITE_PARTY_ID, B.PARTY_SITE_ID,
 	B.LE_PARTY_ID, A.OBJECT_VERSION_NUMBER + 1, B.LAST_UPDATED_BY, sysdate
From 	RRS_SITES_INTERFACE B
where	A.site_identification_number = B.site_identification_number
and	B.Batch_id = p_batch_id
and	B.PROCESS_STATUS = G_PS_IN_PROCESS
and 	B.Transaction_type = G_TX_TYPE_UPDATE )
Where	A.site_identification_number in  (select C.site_identification_number
					from 	RRS_SITES_INTERFACE C
					Where	C.Batch_id = p_batch_id
					and	C.Process_status = G_PS_IN_PROCESS
					and 	C.Transaction_type = G_TX_TYPE_UPDATE );

If ( sql%rowcount ) > 0 then
	FND_FILE.put_line(FND_FILE.LOG, 'Total No. of Sites Updated : '||to_char(sql%rowcount));
end if;


Update 	RRS_SITES_TL A
Set	Name = (select site_name from RRS_SITES_INTERFACE B, RRS_SITES_B  RSB
		where   RSB.site_identification_number = B.site_identification_number
		and	RSB.Site_id = A.Site_id
		and     B.Batch_id = p_batch_id
		and     B.PROCESS_STATUS = G_PS_IN_PROCESS
		and     B.Transaction_type = G_TX_TYPE_UPDATE ),
	SOURCE_LANG = userenv('LANG')
Where   A.site_id in  (select RSB1.site_id
                                        from    RRS_SITES_INTERFACE C, RRS_SITES_B RSB1
                                        Where   C.Batch_id = p_batch_id
					and   	RSB1.site_identification_number = C.site_identification_number
                                        and     C.Process_status = G_PS_IN_PROCESS
                                        and     C.Transaction_type = G_TX_TYPE_UPDATE )
AND 	userenv('LANG') in (LANGUAGE, SOURCE_LANG);


insert into RRS_SITE_USES(
 SITE_USE_ID
,SITE_ID
,SITE_USE_TYPE_CODE
,STATUS_CODE
,IS_PRIMARY_FLAG
,OBJECT_VERSION_NUMBER
,CREATED_BY
,CREATION_DATE
,LAST_UPDATED_BY
,LAST_UPDATE_DATE
,LAST_UPDATE_LOGIN
)
(
Select
rrs_site_uses_s.nextval
,B.SITE_ID
,SITE_USE_TYPE_CODE
,'A'
,'Y'
,1
,G_USER_ID
,SYSDATE
,A.LAST_UPDATED_BY
,SYSDATE
,A.LAST_UPDATE_LOGIN
From    RRS_SITES_INTERFACE A ,RRS_SITES_B B
where   batch_id = p_batch_id
and     transaction_type = G_TX_TYPE_UPDATE
and     process_status = G_PS_IN_PROCESS
and	A.SITE_USE_TYPE_CODE is NOT NULL
and     A.site_identification_number = B.site_identification_number
and 	NOT EXISTS ( select 	C.site_id
		     from	RRS_SITE_USES C
		     where	B.Site_id = C.Site_id )
);


If (  p_purge_rows = 'Y' ) THEN
	DELETE from RRS_SITES_INTERFACE
	where   batch_id = p_batch_id
	and     transaction_type = G_TX_TYPE_UPDATE
	and     process_status = G_PS_IN_PROCESS;
else
        UPDATE  RRS_SITES_INTERFACE
        SET     PROCESS_STATUS = G_PS_SUCCESS
        WHERE   PROCESS_STATUS=G_PS_IN_PROCESS
        AND     BATCH_ID = p_batch_id
        AND     TRANSACTION_TYPE=G_TX_TYPE_UPDATE;

end if;

end;

End rrs_import_interface_pkg;

/
