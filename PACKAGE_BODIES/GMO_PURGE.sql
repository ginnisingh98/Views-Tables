--------------------------------------------------------
--  DDL for Package Body GMO_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMO_PURGE" AS
/* $Header: GMOVPRGB.pls 120.0 2005/09/21 06:09 bchopra noship $ */

/* Procedure to clean GMO Device Read tables */
PROCEDURE PURGE_DEVICE_DATA(P_END_DATE  IN DATE,
                            P_TRUNCATE_TABLE IN VARCHAR2,
                            P_COMMIT IN VARCHAR2)
IS
 INVALID_DATE_EXCEPTION EXCEPTION;
 INVALID_PARAM_EXCEPTION EXCEPTION;
BEGIN

   IF (P_END_DATE > sysdate) THEN
	fnd_message.set_name('GMO', 'GMO_PURGE_FUTURE_END_DATE');
        FND_MSG_PUB.ADD;
        RAISE INVALID_DATE_EXCEPTION;
   END IF;

   /* Validate if end data is null and request is not for truncate */
   IF(P_END_DATE IS NULL AND P_TRUNCATE_TABLE= GMO_CONSTANTS_GRP.NO) THEN
      fnd_message.set_name('GMO', 'GMO_INVALID_INPUT_PARAM');
      FND_MSG_PUB.ADD;
      RAISE INVALID_PARAM_EXCEPTION;
   END IF ;

   IF(P_TRUNCATE_TABLE =  GMO_CONSTANTS_GRP.YES) THEN
        execute immediate 'truncate table GMO_DEVICE_RESPONSES_T';
        execute immediate 'truncate table GMO_DEVICE_REQUESTS_T';
    RETURN;
   END IF;


     DELETE GMO_DEVICE_RESPONSES_T
     WHERE REQUEST_ID IN
         (SELECT REQUEST_ID
            FROM GMO_DEVICE_REQUESTS_T
           WHERE CREATION_DATE <= P_END_DATE );

        DELETE FROM GMO_DEVICE_REQUESTS_T WHERE CREATION_DATE <= P_END_DATE;

    IF(P_COMMIT = GMO_CONSTANTS_GRP.YES) THEN
          COMMIT;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('GMO','GMO_PURGE_DEVICE_DB_ERR');
                FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
                FND_MESSAGE.SET_TOKEN('ERROR_CODE',SQLCODE);
                FND_MSG_PUB.ADD;
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_purge.purge_device_data', FALSE);
                end if;
      RAISE;

END PURGE_DEVICE_DATA;


/* Procedure to clean GMO Instruction tables */
PROCEDURE PURGE_INSTRUCTION_DATA(P_END_DATE IN DATE,
                            P_TRUNCATE_TABLE IN VARCHAR2,
                            P_COMMIT IN VARCHAR2)
IS
 INVALID_DATE_EXCEPTION EXCEPTION;
 INVALID_PARAM_EXCEPTION EXCEPTION;
BEGIN

   IF (P_END_DATE > sysdate) THEN
	fnd_message.set_name('GMO', 'GMO_PURGE_FUTURE_END_DATE');
        FND_MSG_PUB.ADD;
        RAISE INVALID_DATE_EXCEPTION;
   END IF;

   /* Validate if end data is null and request is not for truncate */
   IF(P_END_DATE IS NULL AND P_TRUNCATE_TABLE = GMO_CONSTANTS_GRP.NO) THEN
      fnd_message.set_name('GMO', 'GMO_INVALID_INPUT_PARAM');
      FND_MSG_PUB.ADD;
      RAISE INVALID_PARAM_EXCEPTION;
   END IF ;

   IF(P_TRUNCATE_TABLE =  GMO_CONSTANTS_GRP.YES) THEN
      /* Truncate Definition temporary tables */
       execute immediate 'truncate table GMO_INSTR_APPR_DEFN_T';
       execute immediate 'truncate table GMO_INSTR_DEFN_T';
       execute immediate 'truncate table GMO_INSTR_SET_DEFN_T';
      /* Truncate Instance temporary tables */
       execute immediate 'truncate table GMO_INSTR_TASK_INSTANCE_T';
       execute immediate 'truncate table GMO_INSTR_EREC_INSTANCE_T';
       execute immediate 'truncate table GMO_INSTR_INSTANCE_T';
       execute immediate 'truncate table GMO_INSTR_SET_INSTANCE_T';
      /* Truncate Attributes table in the end */
       execute immediate 'truncate table GMO_INSTR_ATTRIBUTES_T';
    RETURN;
   END IF;

      /* Delete Definition temporary tables */
    delete GMO_INSTR_APPR_DEFN_T where LAST_UPDATE_DATE <= P_END_DATE;
    delete GMO_INSTR_DEFN_T where LAST_UPDATE_DATE <= P_END_DATE;
    delete GMO_INSTR_SET_DEFN_T where LAST_UPDATE_DATE <= P_END_DATE;

      /* Truncate Instance temporary tables */
    delete GMO_INSTR_TASK_INSTANCE_T where LAST_UPDATE_DATE <= P_END_DATE;
    delete GMO_INSTR_EREC_INSTANCE_T where LAST_UPDATE_DATE <= P_END_DATE;
    delete GMO_INSTR_INSTANCE_T where LAST_UPDATE_DATE <= P_END_DATE;
    delete GMO_INSTR_SET_INSTANCE_T where LAST_UPDATE_DATE <= P_END_DATE;

      /* Truncate Attributes table in the end */
    delete GMO_INSTR_ATTRIBUTES_T where LAST_UPDATE_DATE <= P_END_DATE;

    IF(P_COMMIT = GMO_CONSTANTS_GRP.YES) THEN
          COMMIT;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('GMO','GMO_PURGE_INSTR_DB_ERR');
                FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
                FND_MESSAGE.SET_TOKEN('ERROR_CODE',SQLCODE);
                FND_MSG_PUB.ADD;
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_purge.purge_instruction_data', FALSE);
                end if;
      RAISE;
END PURGE_INSTRUCTION_DATA;

/* Procedure to clean GMO temporary tables */
PROCEDURE PURGE_ALL(P_END_DATE  IN DATE,
                            P_TRUNCATE_TABLE IN VARCHAR2,
                            P_COMMIT IN VARCHAR2)
IS
 INVALID_DATE_EXCEPTION EXCEPTION;
 INVALID_PARAM_EXCEPTION EXCEPTION;
BEGIN

   IF (P_END_DATE > sysdate) THEN
	fnd_message.set_name('GMO', 'GMO_PURGE_FUTURE_END_DATE');
        FND_MSG_PUB.ADD;
        RAISE INVALID_DATE_EXCEPTION;
   END IF;

   /* Validate if end data is null and request is not for truncate */
   IF(P_END_DATE IS NULL AND P_TRUNCATE_TABLE = GMO_CONSTANTS_GRP.NO) THEN
      fnd_message.set_name('GMO', 'GMO_INVALID_INPUT_PARAM');
      FND_MSG_PUB.ADD;
      RAISE INVALID_PARAM_EXCEPTION;
   END IF ;


   PURGE_DEVICE_DATA(P_END_DATE => P_END_DATE,
                     P_TRUNCATE_TABLE => P_TRUNCATE_TABLE,
                     P_COMMIT => GMO_CONSTANTS_GRP.NO);


   PURGE_INSTRUCTION_DATA(P_END_DATE => P_END_DATE,
                          P_TRUNCATE_TABLE => P_TRUNCATE_TABLE,
                          P_COMMIT => GMO_CONSTANTS_GRP.NO);

    IF(P_COMMIT = GMO_CONSTANTS_GRP.YES) THEN
          COMMIT;
    END IF;

EXCEPTION
     WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('GMO','GMO_PURGE_ALL_DB_ERR');
                FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
                FND_MESSAGE.SET_TOKEN('ERROR_CODE',SQLCODE);
                FND_MSG_PUB.ADD;
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_purge.purge_all', FALSE);
                end if;
      RAISE;
END PURGE_ALL;

--this procedure is used to clean up temp data from Concurrent Program
PROCEDURE PURGE_ALL(ERRBUF       OUT NOCOPY VARCHAR2,
                    RETCODE      OUT NOCOPY VARCHAR2,
                    P_MODULE_NAME IN VARCHAR2 DEFAULT NULL,
                    P_AGE         IN VARCHAR2 ,
                    P_TRUNCATE_TABLE IN VARCHAR2 DEFAULT GMO_CONSTANTS_GRP.NO)
IS
l_end_date date;
l_err_msg VARCHAR2(4000);
BEGIN

	fnd_file.put_line(fnd_file.output, fnd_message.get_string('GMO', 'GMO_PURGE_TOTAL_START') );

	fnd_message.set_name('GMO', 'GMO_PURGE_PARAMETERS');
	fnd_message.set_token( 'MODULE', P_MODULE_NAME);
	fnd_message.set_token( 'AGE', P_AGE);
	fnd_message.set_token( 'TRUNCATE_TABLE', P_TRUNCATE_TABLE);
	fnd_file.put_line(fnd_file.output, fnd_message.get);

        l_end_date := sysdate - to_number(p_age);

        IF(P_MODULE_NAME is null) THEN
            PURGE_ALL(P_END_DATE => l_end_date,
                      P_TRUNCATE_TABLE => P_TRUNCATE_TABLE,
                      P_COMMIT => GMO_CONSTANTS_GRP.YES);
        ELSIF (P_MODULE_NAME = 'DEVICE') THEN
             PURGE_DEVICE_DATA(P_END_DATE => l_end_date,
                               P_TRUNCATE_TABLE => P_TRUNCATE_TABLE,
                               P_COMMIT => GMO_CONSTANTS_GRP.YES);
        ELSIF (P_MODULE_NAME='INSTRUCTION') THEN
             PURGE_INSTRUCTION_DATA(P_END_DATE => l_end_date,
                                    P_TRUNCATE_TABLE => P_TRUNCATE_TABLE,
                                     P_COMMIT => GMO_CONSTANTS_GRP.YES);
        END IF;

	fnd_message.set_name('GMO', 'GMO_PURGE_TOTAL_END');
	fnd_file.put_line(fnd_file.output, fnd_message.get);

	RETCODE := '0';
        ERRBUF := '';
exception
  when others then
    -- Retrieve error message into errbuf
     l_err_msg := fnd_message.get;
    if (l_err_msg is not null) then
      errbuf := l_err_msg;
    else
      errbuf := sqlerrm;
    end if;

    -- Return 2 for error.
    retcode := '2';

END PURGE_ALL;

END GMO_PURGE;

/
