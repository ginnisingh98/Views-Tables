--------------------------------------------------------
--  DDL for Package Body FTP_PAYMENT_SCHEDULE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTP_PAYMENT_SCHEDULE_PKG" AS
/* $Header: ftppayib.pls 120.6 2006/03/06 03:53:38 appldev noship $ */

/**********************
-- Package Constants
************************/

C_LOG_LEVEL_2		CONSTANT  NUMBER  := fnd_log.level_procedure;
G_RET_STS_ERROR		CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
G_RET_STS_UNEXP_ERROR   CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
G_LOG_LEVEL_ERROR       CONSTANT NUMBER := FND_LOG.level_error;
G_RET_STS_SUCCESS       CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
c_false        CONSTANT  VARCHAR2(1)  := FND_API.G_FALSE;
c_true         CONSTANT  VARCHAR2(1)  := FND_API.G_TRUE;


PROCEDURE TransferData(errbuf   OUT NOCOPY VARCHAR2,
retcode  OUT NOCOPY VARCHAR2,
isTruncate IN  VARCHAR2
)
IS

TYPE t_id_number_tbl			IS TABLE OF FTP_PAYMENT_SCHEDULE_T.ID_NUMBER%TYPE;
TYPE t_source_system_disp_cd_tbl	IS TABLE OF FTP_PAYMENT_SCHEDULE_T.SOURCE_SYSTEM_DISPLAY_CODE%TYPE;
TYPE t_instrument_type_code_tbl		IS TABLE OF FTP_PAYMENT_SCHEDULE_T.INSTRUMENT_TYPE_CODE%TYPE;
TYPE t_payment_date_tbl			IS TABLE OF FTP_PAYMENT_SCHEDULE_T.PAYMENT_DATE%TYPE;
TYPE t_amount_tbl			IS TABLE OF FTP_PAYMENT_SCHEDULE_T.AMOUNT%TYPE;

l_id_number			t_id_number_tbl;
l_source_system_display_code	t_source_system_disp_cd_tbl;
l_instrument_type_code		t_instrument_type_code_tbl;
l_payment_date			t_payment_date_tbl;
l_amount			t_amount_tbl;
l_retun_status			Varchar2(80);
inst_retun_status			Varchar2(80);
l_block  CONSTANT  VARCHAR2(80) := 'FTP_PAYMENT_SCHEDULE.TransferData';
l_source_system_code		FTP_PAYMENT_SCHEDULE.SOURCE_SYSTEM_CODE%TYPE;
l_rowcount	Number		:=0;
BEGIN

FEM_ENGINES_PKG.TECH_MESSAGE(
  p_severity => C_LOG_LEVEL_2,
  p_module => l_block ||'Transfer Data',
  p_msg_text => 'Transfer Begins in Bulk'
 );

IF nvl(isTruncate, 'N') = 'Y' THEN
	EXECUTE IMMEDIATE  'TRUNCATE TABLE FTP.FTP_PAYMENT_SCHEDULE';
END IF;

SELECT ID_NUMBER, SOURCE_SYSTEM_DISPLAY_CODE, INSTRUMENT_TYPE_CODE, PAYMENT_DATE, AMOUNT
BULK COLLECT INTO  l_id_number, l_source_system_display_code,l_instrument_type_code, l_payment_date,l_amount
FROM FTP_PAYMENT_SCHEDULE_T ;

l_rowcount :=0;
FOR i in 1..l_id_number.COUNT LOOP
    BEGIN
	inst_retun_status := G_RET_STS_ERROR;
-- Validate Instrument Type. If succes proceed further else log error;
	Validate_Inst_Type_Code(l_instrument_type_code(i),inst_retun_status);
	IF inst_retun_status = G_RET_STS_SUCCESS THEN
	    l_retun_status := G_RET_STS_ERROR;
	    Validate_Source_System ( l_source_system_display_code(i),l_source_system_code, l_retun_status );
	    IF l_retun_status = G_RET_STS_SUCCESS THEN
		   BEGIN
		      INSERT INTO FTP_PAYMENT_SCHEDULE
		       (ID_NUMBER, SOURCE_SYSTEM_CODE, INSTRUMENT_TYPE_CODE, PAYMENT_DATE, AMOUNT,
		       CREATED_BY_OBJECT_ID,CREATED_BY_REQUEST_ID,LAST_UPDATED_BY_OBJECT_ID,LAST_UPDATED_BY_REQUEST_ID)
		       VALUES (l_id_number(i), l_source_system_code,l_instrument_type_code(i), l_payment_date(i),l_amount(i),
		       1,1,1,1);

		       UPDATE FTP_PAYMENT_SCHEDULE_T SET STATUS ='INSERT'
		       WHERE
		       ID_NUMBER = l_id_number(i) AND
		       SOURCE_SYSTEM_DISPLAY_CODE = l_source_system_display_code(i) AND
		       INSTRUMENT_TYPE_CODE = l_instrument_type_code(i) AND
		       PAYMENT_DATE = l_payment_date(i) ;
		       l_rowcount := l_rowcount + 1;
		    EXCEPTION
			WHEN OTHERS THEN
			UPDATE FTP_PAYMENT_SCHEDULE_T SET STATUS ='Error Inserting the Data : Unique Constraint Violated'
			WHERE
			ID_NUMBER = l_id_number(i) AND
			SOURCE_SYSTEM_DISPLAY_CODE = l_source_system_display_code(i) AND
			INSTRUMENT_TYPE_CODE = l_instrument_type_code(i) AND
			PAYMENT_DATE = l_payment_date(i);

			FEM_ENGINES_PKG.TECH_MESSAGE(
			p_severity => C_LOG_LEVEL_2,
			p_module => l_block ||'Transfer Data',
			p_msg_text => 'Error Inseting the Data'
			);
		   END;
	    ELSE
		UPDATE FTP_PAYMENT_SCHEDULE_T SET STATUS ='INVALID SYSTEM DISPLAY CODE ERROR'
		WHERE
		ID_NUMBER = l_id_number(i) AND
		SOURCE_SYSTEM_DISPLAY_CODE = l_source_system_display_code(i) AND
		INSTRUMENT_TYPE_CODE = l_instrument_type_code(i) AND
		PAYMENT_DATE = l_payment_date(i);
	    END IF;
	ELSE
	    UPDATE FTP_PAYMENT_SCHEDULE_T SET STATUS ='INVALID INSTRUMENT TYPE CODE ERROR'
	    WHERE
	    ID_NUMBER = l_id_number(i) AND
	    SOURCE_SYSTEM_DISPLAY_CODE = l_source_system_display_code(i) AND
	    INSTRUMENT_TYPE_CODE = l_instrument_type_code(i) AND
	    PAYMENT_DATE = l_payment_date(i);
	END IF;
    EXCEPTION
	WHEN OTHERS THEN
        UPDATE FTP_PAYMENT_SCHEDULE_T SET STATUS ='FTP TRANSFER DATA ERROR : OTHERS'
        WHERE
        ID_NUMBER = l_id_number(i) AND
        SOURCE_SYSTEM_DISPLAY_CODE = l_source_system_display_code(i) AND
        INSTRUMENT_TYPE_CODE = l_instrument_type_code(i) AND
        PAYMENT_DATE = l_payment_date(i);

	FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => C_LOG_LEVEL_2,
	p_module => l_block ||'Transfer Data',
	p_msg_text => 'Error Inserting : OTHERS '
        );
    END;

 END LOOP;

 FEM_ENGINES_PKG.TECH_MESSAGE(
  p_severity => C_LOG_LEVEL_2,
  p_module => l_block,
  p_msg_text => 'Successfully inserted rows: '||l_id_number.COUNT
 );

 COMMIT;
 DeleteData ;
 COMMIT;
 retcode := c_true;
 FEM_ENGINES_PKG.User_Message(
         p_app_name => 'FTP',
         p_msg_name => 'FTP_PAY_SCHEDULE_RUN',
         p_token1   => 'INSCOUNT',
         p_value1   => l_rowcount,
	 p_token2   => 'RCOUNT',
         p_value2   => l_id_number.COUNT
        );
EXCEPTION
    when others then
	 FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FTP',
         p_msg_name => 'FTP_UNEXP_ERR',
         p_token1   => 'SQLERRM',
         p_value1   => sqlerrm
        );
    retcode := c_false;
END TransferData;  /* Procedure TransferData */


PROCEDURE DeleteData
IS
l_block  CONSTANT  VARCHAR2(80) := 'FTP_PAYMENT_SCHEDULE_migrate.DeleteData';
BEGIN

DELETE FROM FTP_PAYMENT_SCHEDULE_T WHERE STATUS IN ('INSERT','UPDATE');

FEM_ENGINES_PKG.TECH_MESSAGE(
  p_severity => C_LOG_LEVEL_2,
  p_module => l_block,
  p_msg_text => 'Successfully deleted rows: '||SQL%ROWCOUNT
 );

--commit the data
COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => C_LOG_LEVEL_2,
	p_module => l_block ||'Delete Data',
	p_msg_text => 'Error Deleteing Data'
        );
END DeleteData;


PROCEDURE  Validate_Source_System (
  p_source_system_code     IN  VARCHAR2,
  x_source_system_code     OUT NOCOPY NUMBER,
  x_return_status          OUT NOCOPY VARCHAR2
)
IS
C_MODULE        CONSTANT FND_LOG_MESSAGES.module%TYPE := 'FTP_PAYMENT_SCHDULDE.validate_source_system';

BEGIN
  FEM_ENGINES_PKG.TECH_MESSAGE(
     p_severity => C_LOG_LEVEL_2,
     p_module => C_MODULE,
     p_msg_text => 'Begin Validating Source System Code for'
	 );
   x_return_status := G_RET_STS_SUCCESS;

   BEGIN
     SELECT  source_system_code
     INTO   x_source_system_code
     FROM   fem_source_systems_b
     WHERE  source_system_display_code = p_source_system_code
     AND enabled_flag  = 'Y'
     AND personal_flag = 'N';
   EXCEPTION
      WHEN no_data_found THEN
       x_return_status := G_RET_STS_ERROR;
       FEM_ENGINES_PKG.Tech_Message(
        p_severity => C_LOG_LEVEL_2,
	p_module => 'Transfer Data',
	p_msg_text => 'No Data for Source System Display Code'
	 );
    END;
EXCEPTION
  WHEN others THEN
    x_return_status := G_RET_STS_UNEXP_ERROR;

END Validate_Source_System;


PROCEDURE  Validate_Inst_Type_Code(
  p_inst_type_code	   IN  NUMBER,
  x_return_status          OUT NOCOPY VARCHAR2
) IS
  C_MODULE        CONSTANT FND_LOG_MESSAGES.module%TYPE := 'FTP_PAYMENT_SCHDULDE.validate_Inst_Type_code';
  x_inst_type_code Varchar2(100);
  l_inst_type_code Varchar2(100);
BEGIN
   l_inst_type_code := to_char(p_inst_type_code);
   x_return_status := G_RET_STS_SUCCESS;
   BEGIN
     SELECT LOOKUP_CODE
     INTO   x_inst_type_code
     FROM   FTP_LOOKUPS
     WHERE  LOOKUP_TYPE = 'FTP_INST_TYPES_CODE' AND
     LOOKUP_CODE = trim(l_inst_type_code);
   EXCEPTION
      WHEN no_data_found THEN
       x_return_status := G_RET_STS_ERROR;
       FEM_ENGINES_PKG.Tech_Message(
        p_severity => C_LOG_LEVEL_2,
	p_module => 'Validate_Inst_Type_Code',
	p_msg_text => 'Error In Instrument Type Code'
	);
   END;
EXCEPTION
  WHEN others THEN
    x_return_status := G_RET_STS_UNEXP_ERROR;
END Validate_Inst_Type_Code;

END ftp_payment_schedule_pkg;


/
