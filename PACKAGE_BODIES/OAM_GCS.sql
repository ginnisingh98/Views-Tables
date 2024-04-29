--------------------------------------------------------
--  DDL for Package Body OAM_GCS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OAM_GCS" AS
/* $Header: afamgcsb.pls 120.1 2005/07/02 03:56:19 appldev noship $ */
/*
PROCEDURE REGISTER_OAMGCS_FCQ

		Procedure to register a service instance

PARAMETERS

node		Node name to use as service instance
rti_dir         the  custom directory location  for RTI
Oracle_home	Value of ORACLE_HOME for the node specified
Interval	Interval of periodical uploading
*/


PROCEDURE register_oamgcs_fcq(node IN varchar2,Oracle_home IN varchar2 DEFAULT null,rti_dir IN varchar2 DEFAULT null, interval IN number DEFAULT 300000)
is
	mgr_name varchar2(36);
	name  varchar2(256);
	svcparams varchar2(1024);
	error_message VARCHAR2(1024);
	rti_dir_path VARCHAR2(512);
	qcount	 number;
	ncount   number;
	dummy    number;
BEGIN
	mgr_name := 'OAMGCS_' || UPPER(node);
	IF (rti_dir=null) THEN
		rti_dir_path:=Oracle_home;
	ELSE
		rti_dir_path:=rti_dir;
	END IF;
	svcparams := 'NODE=' || UPPER(node) ||';LOADINTERVAL=' ||TO_CHAR(interval) ||';RTI_KEEP_DAYS=1;FRD_KEEP_DAYS=7';

	IF (Oracle_home is not null) THEN
		svcparams := svcparams||';ORACLE_HOME='|| Oracle_home;
	END IF;
	IF (rti_dir_path is not null) THEN
		svcparams := svcparams||';FORMS60_RTI_DIR='|| rti_dir_path;
	END IF;

	IF lengthb(mgr_name) > 30 THEN
		mgr_name := substrb(mgr_name,1,30);
	END IF;

    SELECT count(*)
	INTO qcount
	FROM fnd_concurrent_queues
	WHERE UPPER(node_name) =UPPER(node)
	 AND TO_NUMBER(manager_type) = (select service_id
		FROM fnd_cp_services where service_handle='OAMGCS');

        IF (qcount = 0) THEN
	        SELECT count(*)
		INTO ncount
		FROM fnd_concurrent_queues
		WHERE concurrent_queue_name = mgr_name;

		IF (ncount <> 0) THEN
			SELECT fnd_concurrent_queues_s.nextval
			INTO dummy
			FROM dual;

			mgr_name := substrb('OAMGCS_'||dummy||'_'||UPPER(node),
						1, 30);
		END IF;

  	        name := fnd_message.get_string('FND', 'CONC-OAMGCS NAME');

		IF(name = 'CONC-OAMGCS NAME') THEN
			name := 'OAM Generic Collection Service';
		END IF;

		DELETE FROM fnd_concurrent_queues_tl
		WHERE concurrent_queue_name = mgr_name;

		BEGIN
  			IF NOT fnd_manager.Manager_exists(mgr_name,'FND') THEN
			  fnd_manager.register_si(manager=>name || ':' ||UPPER(node),
					application=>'FND',
					short_name=>mgr_name,
					service_handle=>'OAMGCS',
					PRIMARY_NODE=>UPPER(node));
			END IF;
                /* Bug 2557014: use work_shift_id parameter insted of
                   workshift_name parameter to ensure Standard workshift
                   is found in NLS instances */
  			IF NOT fnd_manager.manager_work_shift_exists(mgr_name,'FND','Standard') THEN
     			       fnd_manager.assign_work_shift(manager_short_name=>mgr_name,
                	       manager_application=>'FND',
                	       work_shift_id => 0,
                	       processes=>1,
			       sleep_seconds=>30,
	                       svc_params=>svcparams);
			END IF;
	    	END;
	END IF;
	EXCEPTION when others THEN
		IF (SQLCODE=100) THEN
			error_message:='Concurrent Manager not found to update OAM GCS';
		END IF;
		IF (SQLCODE=-6502) THEN
			error_message:='The Service Parameter length is more than 1024';
		END IF;
		IF( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
			FND_MESSAGE.SET_NAME('FND','FND_OAMGCS_REGISTER_ERR');
			FND_MESSAGE.SET_TOKEN('MSG', error_message);
			FND_LOG.MESSAGE (FND_LOG.LEVEL_ERROR,'FND.PLSQL.AFAMGCSB.OAM_GCS.REGISTER_OAMGCS_FCQ',TRUE);
		END IF;
END register_oamgcs_fcq;

/*

PROCEDURE UPDATE_GCS

		Procedure to update a service instance

PARAMETERS

node		node name to use as service instance

Oracle_home	Value of ORACLE_HOME for the node specified

Interval

*/

PROCEDURE update_gcs(node IN varchar2,Oracle_home IN varchar2 DEFAULT null, rti_dir IN varchar2 DEFAULT null,interval IN number DEFAULT 300000)
IS
	mgr_name VARCHAR2(36);
	svcparams VARCHAR2(1024);
	queue_id NUMBER(15);
	error_message VARCHAR2(10);
	rti_dir_path VARCHAR2(1024);
BEGIN
	IF (rti_dir=null) THEN
		rti_dir_path:=Oracle_home;
	ELSE
		rti_dir_path:=rti_dir;
	END IF;

	svcparams := 'NODE=' || UPPER(node) ||';LOADINTERVAL=' ||TO_CHAR(interval) ||';RTI_KEEP_DAYS=1;FRD_KEEP_DAYS=7';

	IF (Oracle_home is not null) THEN
		svcparams := svcparams||';ORACLE_HOME='|| Oracle_home;
	END IF;
	IF (rti_dir_path is not null) THEN
		svcparams := svcparams||';FORMS60_RTI_DIR='|| rti_dir_path;
	END IF;

	/* Getting the specific service instance queue_id*/
	mgr_name := 'OAMGCS_%' || UPPER(node);

	IF lengthb(mgr_name) > 30 THEN
		mgr_name := substrb(mgr_name,1,30);
	END IF;

	SELECT concurrent_queue_id INTO queue_id
		FROM  fnd_concurrent_queues
			WHERE application_id=0 AND concurrent_queue_name LIKE mgr_name;

	/* Update the workshift for this queue_id with new svc_params */

	UPDATE fnd_concurrent_queue_size
		SET   service_parameters = svcparams
			WHERE concurrent_queue_id = queue_id AND queue_application_id = 0;

	EXCEPTION when others THEN
		error_message:='Some unexpected error occured';
		IF (SQLCODE=100) THEN
			error_message:='Concurrent Manager not found to update OAM GCS';
		END IF;
		IF (SQLCODE=-6502) THEN
		  	error_message:='The Service Parameter lenght is more than 1024';
		END IF;
		IF( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
			FND_MESSAGE.SET_NAME('FND','FND_OAMGCS_UPDATE_ERR');
			FND_MESSAGE.SET_TOKEN('MSG', error_message);
			FND_LOG.MESSAGE (FND_LOG.LEVEL_ERROR,'FND.PLSQL.AFAMGCSB.OAM_GCS.UPDATE_OAMGCS',TRUE);
		END IF;
END update_gcs;


/*

PROCEDURE DELETE_GCS

		Procedure to delete a service instance

PARAMETERS

node		node name to use as service instance


*/

PROCEDURE delete_gcs(node IN varchar2)
IS
	mgr_name VARCHAR2(36);
BEGIN

	mgr_name := 'OAMGCS_%' ||UPPER(node);
	IF lengthb(mgr_name) > 30 THEN
		mgr_name := substrb(mgr_name,1,30);
	END IF;

	/* Deleting the specific service instance for specific node*/

	DELETE FROM  fnd_concurrent_queues
			WHERE application_id=0 AND concurrent_queue_name LIKE mgr_name and UPPER(node_name)=upper(node);

END delete_gcs;



/*

FUNCTION SERVICE_EXISTS

		Function to verify existance of a service instance

PARAMETERS

node		ndoe name to verify if it is a service instance.

*/


FUNCTION Service_exists(node IN VARCHAR2)
RETURN VARCHAR2 IS
  instance_count number;
  mgr_name varchar(36);

BEGIN

	   mgr_name:='OAMGCS%'||upper(node);
	   IF lengthb(mgr_name) > 30 THEN
		mgr_name := substrb(mgr_name,1,30);
	   END IF;


		   SELECT count(concurrent_queue_id) into instance_count
		   FROM
		   fnd_concurrent_queues where concurrent_queue_name like mgr_name AND
		   upper(node_name) = upper(node);

	   IF (instance_count>0) THEN
	   	return 'TRUE';
	   ELSE
	   	return 'FALSE';
	   END IF;

	EXCEPTION when others THEN return 'FALSE';

END Service_exists;

FUNCTION service_status(node IN VARCHAR2)
RETURN NUMBER IS
 target         number;
  actual                number;
  description           varchar2(1024);
  error_code            number;
  error_message         varchar2(1024);
  svc_status            number(1);
  mgr_name              varchar(36);
  conc_queue_id         number(15);
  appl_id               number(15);

BEGIN
           mgr_name:='OAMGCS%'||upper(node);
           IF lengthb(mgr_name) > 30 THEN
                mgr_name := substrb(mgr_name,1,30);
           END IF;




            SELECT application_id,concurrent_queue_id INTO appl_id,conc_queue_id                 FROM fnd_concurrent_queues
                  where  concurrent_queue_name like mgr_name
                        AND     upper(node_name) = upper(node);

           FND_OAM.get_svc_inst_status(appl_id,conc_queue_id,target,actual,svc_status,description,error_code,error_message);

           return svc_status;

        EXCEPTION when others THEN return 2;

END service_status;

END oam_gcs;

/
