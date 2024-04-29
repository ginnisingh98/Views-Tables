--------------------------------------------------------
--  DDL for Package Body EC_DOCUMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EC_DOCUMENT" AS
-- $Header: ECTRIGB.pls 120.2 2005/09/30 05:48:32 arsriniv ship $
G_PKG_NAME CONSTANT VARCHAR2(30) := 'EC_DOCUMENT';

PROCEDURE send(
	p_api_version_number  	IN      NUMBER,
   	p_init_msg_list       	IN      VARCHAR2 := FND_API.G_FALSE,
   	p_commit              	IN      VARCHAR2 := FND_API.G_FALSE,
   	p_validation_level    	IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   	x_return_status       	OUT  NOCOPY    VARCHAR2,
   	x_msg_count           	OUT  NOCOPY   NUMBER,
   	x_msg_data            	OUT  NOCOPY   VARCHAR2,
	call_status		OUT  NOCOPY	BOOLEAN,
     	request_id		OUT  NOCOPY	PLS_INTEGER,
	i_Output_Path		IN	VARCHAR2,
	i_Output_Filename       IN      VARCHAR2 DEFAULT NULL,
	i_Transaction_Type    	IN 	VARCHAR2,
	i_debug_mode            IN      NUMBER DEFAULT NULL,
	p_parameter1		IN	VARCHAR2,
	p_parameter2		IN 	VARCHAR2,
 	p_parameter3		IN 	VARCHAR2,
	p_parameter4		IN 	VARCHAR2,
	p_parameter5		IN	VARCHAR2,
	p_parameter6		IN 	VARCHAR2,
	p_parameter7		IN	VARCHAR2,
	p_parameter8		IN	VARCHAR2,
	p_parameter9		IN	VARCHAR2,
	p_parameter10		IN	VARCHAR2,
	p_parameter11		IN	VARCHAR2,
	p_parameter12		IN	VARCHAR2,
	p_parameter13		IN	VARCHAR2,
	p_parameter14		IN	VARCHAR2,
	p_parameter15		IN	VARCHAR2,
	p_parameter16		IN	VARCHAR2,
	p_parameter17		IN	VARCHAR2,
	p_parameter18		IN	VARCHAR2,
	p_parameter19		IN	VARCHAR2,
	p_parameter20		IN	VARCHAR2) IS


	l_api_version	CONSTANT	NUMBER	:=1.0;
	l_api_name	CONSTANT	VARCHAR2(30) := 'ECSEND API';
 	rphase		VARCHAR2(30);
	rstatus		VARCHAR2(30);
	dphase		VARCHAR2(30);
	dstatus		VARCHAR2(30);
	message		VARCHAR2(30);
	p_Output_Path	VARCHAR2(250);
	p_Debug_Mode	NUMBER;
BEGIN
	SAVEPOINT ECSEND_PUB;
	IF NOT fnd_api.Compatible_API_Call(l_api_version,
					p_api_version_number,
					l_api_name,
					G_PKG_NAME)
 	THEN
		RAISE fnd_api.g_exc_unexpected_error;
	END IF;

	IF fnd_api.to_Boolean(p_init_msg_list) THEN
		fnd_msg_pub.initialize;
	END IF;

	x_return_status := fnd_api.g_ret_sts_success;

	p_Output_Path := i_Output_Path;
	IF p_Output_Path IS NULL THEN
	-- Retrieve the system profile option ECE_OUT_FILE_PATH.  This will
    	-- be the directory where the output file will be written.
    	-- NOTE: this directory must be specified in the parameter UTL_FILE_DIR in
    	-- the INIT.ORA file.
    		fnd_profile.get ( 'ECE_OUT_FILE_PATH', p_Output_Path);
	END IF;

	IF i_debug_mode IS NULL THEN
		fnd_profile.get('ECE_' || i_Transaction_Type || '_DEBUG_MODE', p_Debug_Mode);
		IF p_Debug_mode IS NULL THEN
			p_Debug_Mode := 0;
		END IF;
	ELSE
		p_Debug_Mode := i_debug_mode;
	END IF;


	request_id := fnd_request.submit_request(
		Application 	=> 'EC',
		Program		=> 'ECTRIGO',
		Description 	=> 'Outbound Triggering Process',
		argument1	=> p_Output_Path,
		argument2	=> i_Output_Filename,
	 	argument3       => i_Transaction_Type,
		argument4 	=> p_Debug_Mode,
		argument5 	=> p_parameter1,
		argument6	=> p_parameter2,
		argument7	=> p_parameter3,
		argument8	=> p_parameter4,
		argument9	=> p_parameter5,
		argument10	=> p_parameter6,
		argument11	=> p_parameter7,
		argument12	=> p_parameter8,
		argument13	=> p_parameter9,
		argument14	=> p_parameter10,
		argument15	=> p_parameter11,
		argument16	=> p_parameter12,
		argument17	=> p_parameter13,
		argument18	=> p_parameter14,
		argument19	=> p_parameter15,
		argument20	=> p_parameter16,
		argument21	=> p_parameter17,
		argument22	=> p_parameter18,
		argument23	=> p_parameter19,
		argument24	=> p_parameter20);

    	call_status := FND_CONCURRENT.GET_REQUEST_STATUS(request_id,
			' ',' ', rphase, rstatus, dphase, dstatus, message);

   	-- Standard check of p_commit
   	if fnd_api.to_Boolean(p_commit) then
		COMMIT WORK;
   	end if;

	-- Standard call to get message count and if count is 1, get message info.
    	fnd_msg_pub.count_and_get(
		p_count	=> x_msg_count,
		p_data	=> x_msg_data);

EXCEPTION
	WHEN fnd_api.g_exc_error THEN
		ROLLBACK TO ECSEND_PUB;
		x_return_status := fnd_api.g_ret_sts_error;
		fnd_msg_pub.count_and_get(p_count => x_msg_count,
					  p_data  => x_msg_data);
	WHEN fnd_api.g_exc_unexpected_error THEN
		ROLLBACK TO ECSEND_PUB;
		x_return_status := fnd_api.g_ret_sts_unexp_error;
		fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                          p_data  => x_msg_data);
	WHEN OTHERS THEN
		ROLLBACK TO ECSEND_PUB;
		x_return_status := fnd_api.g_ret_sts_unexp_error;
                IF fnd_msg_pub.Check_Msg_Level
			(fnd_msg_pub.G_MSG_LVL_UNEXP_ERROR) THEN
			fnd_msg_pub.add_exc_msg(G_PKG_NAME, l_api_name);
		END IF;
		fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                          p_data  => x_msg_data);
END send;


PROCEDURE process_outbound(
	errbuf			OUT NOCOPY	VARCHAR2,
	retcode			OUT NOCOPY	VARCHAR2,
	i_Output_Path		IN	VARCHAR2,
	i_Output_Filename       IN      VARCHAR2 DEFAULT NULL,
	i_Transaction_Type	IN	VARCHAR2,
	i_debug_mode            IN      NUMBER DEFAULT 0,
	parameter1             	IN      VARCHAR2 DEFAULT NULL,
        parameter2             	IN      VARCHAR2 DEFAULT NULL,
        parameter3             	IN      VARCHAR2 DEFAULT NULL,
        parameter4             	IN      VARCHAR2 DEFAULT NULL,
        parameter5             	IN      VARCHAR2 DEFAULT NULL,
        parameter6             	IN      VARCHAR2 DEFAULT NULL,
        parameter7             	IN      VARCHAR2 DEFAULT NULL,
        parameter8             	IN      VARCHAR2 DEFAULT NULL,
        parameter9             	IN      VARCHAR2 DEFAULT NULL,
        parameter10            	IN      VARCHAR2 DEFAULT NULL,
        parameter11            	IN      VARCHAR2 DEFAULT NULL,
        parameter12            	IN      VARCHAR2 DEFAULT NULL,
        parameter13            	IN      VARCHAR2 DEFAULT NULL,
        parameter14            	IN      VARCHAR2 DEFAULT NULL,
        parameter15            	IN      VARCHAR2 DEFAULT NULL,
        parameter16            	IN      VARCHAR2 DEFAULT NULL,
        parameter17            	IN      VARCHAR2 DEFAULT NULL,
        parameter18            	IN      VARCHAR2 DEFAULT NULL,
        parameter19            	IN      VARCHAR2 DEFAULT NULL,
        parameter20            	IN      VARCHAR2 DEFAULT NULL) IS

i_file_id	PLS_INTEGER := 0;
i_Filename      VARCHAR2(30);

i_run_id        PLS_INTEGER  := 0;
i_count         PLS_INTEGER  := 0;
cEnabled	VARCHAR2(1)  := 'N';
ece_transaction_disabled	EXCEPTION;
hash_value              pls_integer;            -- Bug 2905834
hash_string             varchar2(3200);

cursor c_parameter_map
(p_transaction_type VARCHAR2) is
select  parameter_id        parm_id,
	name                parm_name,
        datatype    	parm_datatype,
        default_value
  from    ece_tran_parameters
 where   transaction_type = p_transaction_type
order by parameter_id, sequence_number;

cursor c_map_id(p_transaction_type VARCHAR2) is
select map_id, map_type from ece_mappings
where ece_mappings.transaction_type = p_transaction_type;

BEGIN
ec_debug.enable_debug(i_debug_mode);
ec_debug.pl(0,'EC','ECE_START_OUTBOUND_TRIG','TRANSACTION_TYPE',i_Transaction_Type);
 if ec_debug.G_debug_level >= 2 then
ec_debug.push('EC_DOCUMENT.PROCESS_OUTBOUND');
ec_debug.pl(3, 'i_Output_Path', i_Output_Path);
ec_debug.pl(3, 'i_Output_Filename', i_Output_Filename);
ec_debug.pl(3, 'i_Transaction_Type',i_Transaction_Type);
ec_debug.pl(3, 'parameter1', parameter1);
ec_debug.pl(3, 'parameter2', parameter2);
ec_debug.pl(3, 'parameter3', parameter3);
ec_debug.pl(3, 'parameter4', parameter4);
ec_debug.pl(3, 'parameter5', parameter5);
ec_debug.pl(3, 'parameter6', parameter6);
ec_debug.pl(3, 'parameter7', parameter7);
ec_debug.pl(3, 'parameter8', parameter8);
ec_debug.pl(3, 'parameter9', parameter9);
ec_debug.pl(3, 'parameter10', parameter11);
ec_debug.pl(3, 'parameter11', parameter11);
ec_debug.pl(3, 'parameter12', parameter12);
ec_debug.pl(3, 'parameter13', parameter13);
ec_debug.pl(3, 'parameter14', parameter14);
ec_debug.pl(3, 'parameter15', parameter15);
ec_debug.pl(3, 'parameter16', parameter16);
ec_debug.pl(3, 'parameter17', parameter17);
ec_debug.pl(3, 'parameter18', parameter18);
ec_debug.pl(3, 'parameter19', parameter19);
ec_debug.pl(3, 'parameter20', parameter20);
ec_debug.pl(3, 'Debug Mode', i_debug_mode);
END if;

-- Transaction Enabled Check
        fnd_profile.get('ECE_' || i_Transaction_Type || '_ENABLED', cEnabled);

	IF cEnabled IS NULL THEN
		ec_debug.pl(0,'EC','ECE_NO_TRANSACTION_PROFILE','TRANSACTION_TYPE',i_Transaction_Type);
              	retcode := 2;
              	raise EC_UTILS.PROGRAM_EXIT;
	ELSIF cEnabled = 'N' THEN
                RAISE ece_transaction_disabled;
        END IF;

-- m_parm_tmp_tbl defined in specs as table of VARCHAR2(150)
-- Populate temporary stack with passed in parameters

	ec_document.populate_tmp_parm_stack(
	parameter1,parameter2,parameter3,parameter4, parameter5,
	parameter6, parameter7,parameter8, parameter9, parameter10,
	parameter11, parameter12, parameter13, parameter14, parameter15,
	parameter16, parameter17, parameter18, parameter19, parameter20);

--Initialize PL/SQL table from ec_util
	ec_utils.g_stack.DELETE;

-- Put parameter name, datatype and default values on stack
-- The order of parameters must be predefined both on the input side and the table

-- EC_UTILS.G_STACK
-- level,
-- variable_name
-- variable_value
-- variable_position
-- variable_data_type
BEGIN
     FOR c_parm_map_rec IN c_parameter_map (p_transaction_type => i_Transaction_Type)
   	LOOP
	        if ec_debug.G_debug_level = 3 then
		ec_debug.pl(3, 'parameter_id', c_parm_map_rec.parm_id);
		ec_debug.pl(3, 'parameter_name', c_parm_map_rec.parm_name);
		ec_debug.pl(3, 'paremeter datatype', c_parm_map_rec.parm_datatype);
		ec_debug.pl(3, 'parameter default value', c_parm_map_rec.default_value);
		end if;

		i_count := i_count + 1;
		ec_utils.g_stack(i_count).level 		:= 0;
		ec_utils.g_stack(i_count).variable_name		:= c_parm_map_rec.parm_name;
		ec_utils.g_stack(i_count).data_type	 	:= c_parm_map_rec.parm_datatype;
		ec_utils.g_stack(i_count).variable_value 	:= c_parm_map_rec.default_value;

		-- Bug 2905834
                hash_string := to_char(0)||'-'||UPPER(c_parm_map_rec.parm_name) ;
                hash_value  := dbms_utility.get_hash_value(hash_string,1,100000);
                ec_utils.g_stack_pos_tbl(hash_value):=i_count;

    	END LOOP;
     COMMIT;
END;

-- Put parameter values on stack
-- m_parm_tmp_tbl is temporary stack that gets the input parameters.
-- ec_utils.g_stack is the final stack that is used by the outbound execution engine.

      FOR i in 1..ec_utils.g_stack.COUNT
	LOOP
		IF m_parm_tmp_tbl.EXISTS(i) THEN

			ec_utils.g_stack(i).variable_value := m_parm_tmp_tbl(i);
                        if ec_debug.G_debug_level = 3 then
			ec_debug.pl(3, 'Parameter temp table value', m_parm_tmp_tbl(i));
			ec_debug.pl(3,'g_stack_count',i);
			ec_debug.pl(3,'g_stack.value',ec_utils.g_stack(i).variable_value);
			end if;
		END IF;
	END LOOP;

 ec_debug.pl(0,'EC','ECE_PARAMETER_STACK_LOADED','TRANSACTION_TYPE',i_Transaction_Type);

-- Derive output filename
	IF fnd_global.conc_request_id IS NOT NULL THEN
		i_file_id := fnd_global.conc_request_id;
	ELSE
		select ece_output_runs_s.NEXTVAL INTO i_file_id
		FROM DUAL;
	END IF;

	IF i_Output_Filename IS NULL THEN
		i_Filename := i_Transaction_Type || i_file_id || '.dat';
        ELSE
		i_Filename := i_Output_Filename;
       	END IF;

BEGIN
     FOR map_id_rec IN c_map_id(p_transaction_type => i_Transaction_Type)
       LOOP
	ec_outbound.process_outbound_documents(i_Transaction_Type, map_id_rec.map_id, i_run_id);

	ec_debug.pl(0,'EC','ECE_EXECUTE_OUTBOUND','TRANSACTION_TYPE',i_Transaction_Type,'MAP_ID',map_id_rec.map_id);

	IF map_id_rec.map_type = 'FF' THEN

	  ec_outbound_stage.get_data(i_Transaction_Type, i_Filename, i_Output_Path, map_id_rec.map_id, i_run_id);

	  ec_debug.pl(0,'EC','ECE_EXECUTE_FLATFILE','TRANSACTION_TYPE',i_Transaction_Type,'MAP_ID',map_id_rec.map_id);

	ELSE

	  ec_xml_utils.ec_xml_processor_out_generic(map_id_rec.map_id,i_run_id,i_Output_Path,i_Filename);

	  ec_debug.pl(0,'EC','ECE_EXECUTE_XML','TRANSACTION_TYPE',i_Transaction_Type,'MAP_ID',map_id_rec.map_id);
	END IF;

      END LOOP;
   COMMIT;
END;
if ec_debug.G_debug_level >= 2 then
ec_debug.pl(3, 'retcode', retcode);
ec_debug.pl(3, 'errbuf', errbuf);
ec_debug.pop('EC_DOCUMENT.PROCESS_OUTBOUND');
end if;
ec_debug.pl(0,'EC','ECE_END_OUTBOUND_TRIG','TRANSACTION_TYPE',i_Transaction_Type);
ec_debug.disable_debug;

EXCEPTION
	WHEN ece_transaction_disabled THEN
                ec_debug.pl(0,'EC','ECE_TRANSACTION_DISABLED','TRANSACTION_TYPE', i_Transaction_Type);
                retcode := 1;
                ec_debug.disable_debug;
                ROLLBACK WORK;
	WHEN EC_UTILS.PROGRAM_EXIT THEN
		ROLLBACK WORK;
		raise;
	WHEN OTHERS THEN
                ROLLBACK WORK;
                ec_debug.pl(0,'EC', 'ECE_PROGRAM_ERROR', 'PROGRESS_LEVEL', 'EC_DOCUMENT.PROCESS_OUTBOUND');
                ec_debug.pl(0,'EC', 'ECE_ERROR_MESSAGE', 'ERROR_MESSAGE', SQLERRM);
                retcode :=2;
                ec_debug.disable_debug;

END process_outbound;


-- m_parm_tmp_tbl defined in specs

procedure populate_tmp_parm_stack(
	parameter1             IN      VARCHAR2 DEFAULT NULL,
        parameter2             IN      VARCHAR2 DEFAULT NULL,
        parameter3             IN      VARCHAR2 DEFAULT NULL,
        parameter4             IN      VARCHAR2 DEFAULT NULL,
        parameter5             IN      VARCHAR2 DEFAULT NULL,
        parameter6             IN      VARCHAR2 DEFAULT NULL,
        parameter7             IN      VARCHAR2 DEFAULT NULL,
        parameter8             IN      VARCHAR2 DEFAULT NULL,
        parameter9             IN      VARCHAR2 DEFAULT NULL,
        parameter10            IN      VARCHAR2 DEFAULT NULL,
        parameter11            IN      VARCHAR2 DEFAULT NULL,
        parameter12            IN      VARCHAR2 DEFAULT NULL,
        parameter13            IN      VARCHAR2 DEFAULT NULL,
        parameter14            IN      VARCHAR2 DEFAULT NULL,
        parameter15            IN      VARCHAR2 DEFAULT NULL,
        parameter16            IN      VARCHAR2 DEFAULT NULL,
        parameter17            IN      VARCHAR2 DEFAULT NULL,
        parameter18            IN      VARCHAR2 DEFAULT NULL,
        parameter19            IN      VARCHAR2 DEFAULT NULL,
        parameter20            IN      VARCHAR2 DEFAULT NULL) IS


	BEGIN
-- Initialize temp stack
	m_parm_tmp_tbl.DELETE;

-- Load temp stack
	IF parameter1 is NOT NULL THEN
        	m_parm_tmp_tbl(1) := parameter1;
	END IF;
	IF parameter2 is NOT NULL THEN
        	m_parm_tmp_tbl(2) := parameter2;
	END IF;
	IF parameter3 is NOT NULL THEN
        	m_parm_tmp_tbl(3) := parameter3;
	END IF;
	IF parameter4 is NOT NULL THEN
        	m_parm_tmp_tbl(4) := parameter4;
	END IF;
	IF parameter5 is NOT NULL THEN
        	m_parm_tmp_tbl(5) := parameter5;
	END IF;
	IF parameter6 is NOT NULL THEN
        	m_parm_tmp_tbl(6) := parameter6;
	END IF;
	IF parameter7 is NOT NULL THEN
        	m_parm_tmp_tbl(7) := parameter7;
	END IF;
	IF parameter8 is NOT NULL THEN
        	m_parm_tmp_tbl(8) := parameter8;
	END IF;
	IF parameter9 is NOT NULL THEN
        	m_parm_tmp_tbl(9) := parameter9;
	END IF;
	IF parameter10 is NOT NULL THEN
        	m_parm_tmp_tbl(10) := parameter10;
	END IF;
	IF parameter11 is NOT NULL THEN
        	m_parm_tmp_tbl(11) := parameter11;
	END IF;
	IF parameter12 is NOT NULL THEN
        	m_parm_tmp_tbl(12) := parameter12;
	END IF;
	IF parameter13 is NOT NULL THEN
        	m_parm_tmp_tbl(13) := parameter13;
	END IF;
	IF parameter14 is NOT NULL THEN
        	m_parm_tmp_tbl(14) := parameter14;
	END IF;
	IF parameter15 is NOT NULL THEN
        	m_parm_tmp_tbl(15) := parameter15;
	END IF;
	IF parameter16 is NOT NULL THEN
        	m_parm_tmp_tbl(16) := parameter16;
	END IF;
	IF parameter17 is NOT NULL THEN
        	m_parm_tmp_tbl(17) := parameter17;
	END IF;
	IF parameter18 is NOT NULL THEN
        	m_parm_tmp_tbl(18) := parameter18;
	END IF;
	IF parameter19 is NOT NULL THEN
        	m_parm_tmp_tbl(19) := parameter19;
	END IF;
	IF parameter20 is NOT NULL THEN
        	m_parm_tmp_tbl(20) := parameter20;
	END IF;
        if ec_debug.G_debug_level =3 then
	IF parameter1 is NOT NULL THEN
	ec_debug.pl(3,'m_parm_tmp_tbl Parameter 1',m_parm_tmp_tbl(1));
	end if;
	IF parameter2 is NOT NULL THEN
        ec_debug.pl(3,'m_parm_tmp_tbl Parameter 2',m_parm_tmp_tbl(2));
	end if;
        IF parameter3 is NOT NULL THEN
	ec_debug.pl(3,'m_parm_tmp_tbl Parameter 3',m_parm_tmp_tbl(3));
	end if;
	IF parameter4 is NOT NULL THEN
	ec_debug.pl(3,'m_parm_tmp_tbl Parameter 4',m_parm_tmp_tbl(4));
	end if;
	IF parameter5 is NOT NULL THEN
	ec_debug.pl(3,'m_parm_tmp_tbl Parameter 5',m_parm_tmp_tbl(5));
	end if;
	IF parameter6 is NOT NULL THEN
	ec_debug.pl(3,'m_parm_tmp_tbl Parameter 6',m_parm_tmp_tbl(6));
	end if;
	IF parameter7 is NOT NULL THEN
	ec_debug.pl(3,'m_parm_tmp_tbl Parameter 7',m_parm_tmp_tbl(7));
	end if;
	IF parameter8 is NOT NULL THEN
	ec_debug.pl(3,'m_parm_tmp_tbl Parameter 8',m_parm_tmp_tbl(8));
	end if;
	IF parameter9 is NOT NULL THEN
	ec_debug.pl(3,'m_parm_tmp_tbl Parameter 9',m_parm_tmp_tbl(9));
	end if;
	IF parameter10 is NOT NULL THEN
	ec_debug.pl(3,'m_parm_tmp_tbl Parameter 10',m_parm_tmp_tbl(10));
	end if;
	IF parameter11 is NOT NULL THEN
	ec_debug.pl(3,'m_parm_tmp_tbl Parameter 11',m_parm_tmp_tbl(11));
	end if;
	IF parameter12 is NOT NULL THEN
	ec_debug.pl(3,'m_parm_tmp_tbl Parameter 12',m_parm_tmp_tbl(12));
	end if;
	IF parameter13 is NOT NULL THEN
	ec_debug.pl(3,'m_parm_tmp_tbl Parameter 13',m_parm_tmp_tbl(13));
	end if;
	IF parameter14 is NOT NULL THEN
        ec_debug.pl(3,'m_parm_tmp_tbl Parameter 14',m_parm_tmp_tbl(14));
	end if;
	IF parameter15 is NOT NULL THEN
	ec_debug.pl(3,'m_parm_tmp_tbl Parameter 15',m_parm_tmp_tbl(15));
	end if;
	IF parameter16 is NOT NULL THEN
	ec_debug.pl(3,'m_parm_tmp_tbl Parameter 16',m_parm_tmp_tbl(16));
	end if;
	IF parameter17 is NOT NULL THEN
	ec_debug.pl(3,'m_parm_tmp_tbl Parameter 17',m_parm_tmp_tbl(17));
	end if;
	IF parameter18 is NOT NULL THEN
	ec_debug.pl(3,'m_parm_tmp_tbl Parameter 18',m_parm_tmp_tbl(18));
	end if;
	IF parameter19 is NOT NULL THEN
	ec_debug.pl(3,'m_parm_tmp_tbl Parameter 19',m_parm_tmp_tbl(19));
	end if;
	IF parameter20 is NOT NULL THEN
	ec_debug.pl(3,'m_parm_tmp_tbl Parameter 20',m_parm_tmp_tbl(20));
	end if;
	end if;

END populate_tmp_parm_stack;


END ec_document;



/
