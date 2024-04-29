--------------------------------------------------------
--  DDL for Package Body FTP_IRC_ADI_MIGRATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTP_IRC_ADI_MIGRATE" AS
--$Header: ftpmgrtb.pls 120.4 2006/05/15 05:29:10 appldev noship $

/**********************
-- Package Constants
**********************/
c_log_level_1  CONSTANT  NUMBER  := fnd_log.level_statement;
c_log_level_2  CONSTANT  NUMBER  := fnd_log.level_procedure;
c_log_level_3  CONSTANT  NUMBER  := fnd_log.level_event;
c_log_level_4  CONSTANT  NUMBER  := fnd_log.level_exception;
c_log_level_5  CONSTANT  NUMBER  := fnd_log.level_error;
c_log_level_6  CONSTANT  NUMBER  := fnd_log.level_unexpected;

c_false        CONSTANT  VARCHAR2(1)  := FND_API.G_FALSE;
c_true         CONSTANT  VARCHAR2(1)  := FND_API.G_TRUE;

/***************************************************************************
 Desc  : Migrates Parameter Rates type of Interest Rate Codes.
 Pgmr  : Raghuram K Nanda
 Date  : 8-Mar-2005
 History: 28-Mar-2005
 Pgmr  : Karen added: update interfece table status with 'F' when migration failed
 **************************************************************************/
PROCEDURE migrateparameters (
 errbuf   OUT NOCOPY VARCHAR2,
 retcode  OUT NOCOPY VARCHAR2,
 p_int_rate_code IN NUMBER
)
IS

TYPE t_eff_date_tbl IS TABLE OF FTP_IRC_ADI_PARAM_T.EFFECTIVE_DATE%TYPE;
TYPE t_mean_rev_tbl IS TABLE OF FTP_IRC_ADI_PARAM_T.MEAN_REVERSION_SPEED%TYPE;
TYPE t_long_rr_tbl IS TABLE OF FTP_IRC_ADI_PARAM_T.LONG_RUN_RATE%TYPE;
TYPE t_vol_merton_tbl IS TABLE OF FTP_IRC_ADI_PARAM_T.VOLATILITY_MERTON%TYPE;
TYPE t_vol_vasicek_tbl IS TABLE OF FTP_IRC_ADI_PARAM_T.VOLATILITY_VASICEK%TYPE;

l_eff_date_tbl      t_eff_date_tbl;
l_mean_rev_tbl      t_mean_rev_tbl;
l_long_rr_tbl       t_long_rr_tbl;
l_vol_merton_tbl    t_vol_merton_tbl;
l_vol_vasicek_tbl   t_vol_vasicek_tbl;

l_block  CONSTANT  VARCHAR2(80) := 'ftp.plsql.ftp_irc_adi_migrate.migrateparameters';
BEGIN

FEM_ENGINES_PKG.TECH_MESSAGE(
  p_severity => c_log_level_2,
  p_module => l_block||'.interest_rate_code',
  p_msg_text => p_int_rate_code
 );

--Read the values
select EFFECTIVE_DATE,MEAN_REVERSION_SPEED,
LONG_RUN_RATE,VOLATILITY_MERTON,VOLATILITY_VASICEK
bulk collect into l_eff_date_tbl,l_mean_rev_tbl,l_long_rr_tbl,
l_vol_merton_tbl,l_vol_vasicek_tbl
from FTP_IRC_ADI_PARAM_T where
INTEREST_RATE_CODE = p_int_rate_code;

FOR i in 1..l_mean_rev_tbl.COUNT LOOP
    BEGIN
    -- if present, update it
    UPDATE FTP_IRC_TS_PARAM_HIST SET
    MEAN_REVERSION_SPEED = l_mean_rev_tbl(i),
    LONG_RUN_RATE = l_long_rr_tbl(i),
    VOLATILITY_MERTON = l_vol_merton_tbl(i),
    VOLATILITY_VASICEK = l_vol_vasicek_tbl(i)
    WHERE EFFECTIVE_DATE = l_eff_date_tbl(i) AND
    INTEREST_RATE_CODE = p_int_rate_code;

    IF (SQL%ROWCOUNT = 0)
    THEN
        INSERT INTO FTP_IRC_TS_PARAM_HIST(EFFECTIVE_DATE,INTEREST_RATE_CODE,
        MEAN_REVERSION_SPEED,LONG_RUN_RATE,VOLATILITY_MERTON,VOLATILITY_VASICEK,
        RATE_DATA_SOURCE_CODE,IS_VALID_FLG,LAST_MODIFIED_DATE,CREATION_DATE,
        CREATED_BY,LAST_UPDATED_BY,LAST_UPDATE_DATE)
        VALUES(l_eff_date_tbl(i),p_int_rate_code,l_mean_rev_tbl(i),l_long_rr_tbl(i),
        l_vol_merton_tbl(i),l_vol_vasicek_tbl(i),1,1,sysdate,sysdate,1,1,sysdate);

       --Karen added for testing
       update FTP_IRC_ADI_PARAM_T set STATUS ='INSERT'
       where EFFECTIVE_DATE = l_eff_date_tbl(i)
       AND INTEREST_RATE_CODE = p_int_rate_code;
    ELSE
       -- it has updated. so set the status to UPDATE
       --Karen added for testing
       update FTP_IRC_ADI_PARAM_T set STATUS ='UPDATE'
       where EFFECTIVE_DATE = l_eff_date_tbl(i)
       AND INTEREST_RATE_CODE = p_int_rate_code;

    END IF;
    EXCEPTION
        when others then
            --Karen added
            --set status to 'F'
            update FTP_IRC_ADI_PARAM_T set STATUS ='FTP_PARAM_MIGRATE_ERR' where EFFECTIVE_DATE = l_eff_date_tbl(i)
            AND INTEREST_RATE_CODE = p_int_rate_code;

            --put message on the message stack for calling program to handle
            FEM_ENGINES_PKG.Put_Message(
             p_app_name => 'FTP',
             p_msg_name => 'FTP_PARAM_MIGRATE_ERR',
             p_token1   => 'EFF_DATE',
             p_value1   => l_eff_date_tbl(i)
            );
    END;
END LOOP;


FEM_ENGINES_PKG.TECH_MESSAGE(
  p_severity => c_log_level_2,
  p_module => l_block,
  p_msg_text => 'Successfully inserted/updated rows: '||l_mean_rev_tbl.COUNT
 );

--commit the data
COMMIT;

retcode := c_true;

--remove the successful insert/update entries from the interface table
deleteparameters (
 errbuf   => errbuf,
 retcode  => retcode,
 p_int_rate_code => p_int_rate_code
);

EXCEPTION
    when others then

        --put message on the message stack for calling program to handle
        FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FTP',
         p_msg_name => 'FTP_UNEXP_ERR',
         p_token1   => 'SQLERRM',
         p_value1   => sqlerrm
        );
        retcode := c_false;
END migrateparameters;

/***************************************************************************
 Desc  : Deletes Parameter Rates type of Interest Rate Codes.
 Pgmr  : Raghuram K Nanda
 Date  : 8-Mar-2005
 **************************************************************************/
PROCEDURE deleteparameters (
 errbuf   OUT NOCOPY VARCHAR2,
 retcode  OUT NOCOPY VARCHAR2,
 p_int_rate_code IN NUMBER
)
IS
l_block  CONSTANT  VARCHAR2(80) := 'ftp.plsql.ftp_irc_adi_migrate.deleteparameters';
BEGIN

FEM_ENGINES_PKG.TECH_MESSAGE(
  p_severity => c_log_level_2,
  p_module => l_block||'.interest_rate_code',
  p_msg_text => p_int_rate_code
 );

DELETE FROM FTP_IRC_ADI_PARAM_T WHERE
INTEREST_RATE_CODE = p_int_rate_code and STATUS IN ('INSERT','UPDATE');

FEM_ENGINES_PKG.TECH_MESSAGE(
  p_severity => c_log_level_2,
  p_module => l_block,
  p_msg_text => 'Successfully deleted rows: '||SQL%ROWCOUNT
 );

--commit the data
COMMIT;
retcode := c_true;
EXCEPTION
    when others then

        --put message on the message stack for calling program to handle
        FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FTP',
         p_msg_name => 'FTP_UNEXP_ERR',
         p_token1   => 'SQLERRM',
         p_value1   => sqlerrm
        );
        retcode := c_false;
END deleteparameters;

/***************************************************************************
 Desc  : PL/SQL Table to be used in migrate hist rates procedure.
 Pgmr  : Bobby Mathew, Thanks to Shintaro Okuda
 Date  : 20060223
 Bug	 : 5048839
 **************************************************************************/

FUNCTION FTP_MULTI_TABLE_F RETURN FTP_MULTI_TABLE PIPELINED IS
BEGIN
	FOR i IN 1..100 LOOP
      	PIPE ROW(i);
	END LOOP;
	RETURN;
END;


/***************************************************************************
 Desc  : Migrates Historical Rates type of Interest Rate Code.
 Pgmr  : Raghuram K Nanda
 Date  : 8-Mar-2005
 **************************************************************************/
PROCEDURE migratehistrates (
 errbuf   OUT NOCOPY VARCHAR2,
 retcode  OUT NOCOPY VARCHAR2,
 p_int_rate_code IN NUMBER
)
IS
l_select_stmt varchar2(1000);
l_curr_date	DATE := NULL;
l_int_term  FTP_IRC_RATE_TERMS.INTEREST_RATE_TERM%TYPE;
l_int_mult  FTP_IRC_RATE_TERMS.INTEREST_RATE_TERM_MULT%TYPE;
l_indx		NUMBER;

TYPE t_int_rates_tbl IS TABLE OF FTP_IRC_ADI_RATE_T.INTEREST_RATE1%TYPE;
TYPE t_int_terms_tbl IS TABLE OF FTP_IRC_RATE_TERMS.INTEREST_RATE_TERM%TYPE;
TYPE t_int_mults_tbl IS TABLE OF FTP_IRC_RATE_TERMS.INTEREST_RATE_TERM_MULT%TYPE;
TYPE t_eff_date_tbl IS TABLE OF FTP_IRC_ADI_RATE_T.EFFECTIVE_DATE%TYPE;

l_int_rates_tbl     t_int_rates_tbl;
l_int_terms_tbl     t_int_terms_tbl;
l_int_mults_tbl     t_int_mults_tbl;
l_eff_date_tbl      t_eff_date_tbl;

l_block  CONSTANT  VARCHAR2(80) := 'ftp.plsql.ftp_irc_adi_migrate.migratehistrates';

BEGIN
FEM_ENGINES_PKG.TECH_MESSAGE(
  p_severity => c_log_level_2,
  p_module => l_block||'.interest_rate_code',
  p_msg_text => p_int_rate_code
 );

--Get the term and its multipliers
select INTEREST_RATE_TERM_MULT,INTEREST_RATE_TERM
bulk collect into l_int_mults_tbl,l_int_terms_tbl
from FTP_IRC_RATE_TERMS
where INTEREST_RATE_CODE = p_int_rate_code
--Bobby20050719 - UI sorts terms points based on actual length of the term - - Bug 4494361
order by INTEREST_RATE_TERM * decode(INTEREST_RATE_TERM_MULT,'D',1, 'M',30.5, 'Y',365);

--Get the interest rates in row fashion
--Bobby20050719 - modified to include 100 Interest Rate columns
--Bobby20050831 - Bug 4582713 modified to include 100 Interest Rate columns
select EFFECTIVE_DATE,INT_RATE
bulk collect into l_eff_date_tbl,l_int_rates_tbl
from (
 select INTEREST_RATE_CODE,EFFECTIVE_DATE,decode( COLUMN_VALUE,
       1,INTEREST_RATE1, 2,INTEREST_RATE2,
       3,INTEREST_RATE3, 4,INTEREST_RATE4,
       5,INTEREST_RATE5, 6,INTEREST_RATE6, 7,INTEREST_RATE7,
       8,INTEREST_RATE8, 9,INTEREST_RATE9, 10,INTEREST_RATE10,
       11,INTEREST_RATE11, 12,INTEREST_RATE12,
       13,INTEREST_RATE13, 14,INTEREST_RATE14,
       15,INTEREST_RATE15, 16,INTEREST_RATE16, 17,INTEREST_RATE17,
       18,INTEREST_RATE18, 19,INTEREST_RATE19, 20,INTEREST_RATE20,
       21,INTEREST_RATE21, 22,INTEREST_RATE22,
       23,INTEREST_RATE23, 24,INTEREST_RATE24,
       25,INTEREST_RATE25, 26,INTEREST_RATE26, 27,INTEREST_RATE27,
       28,INTEREST_RATE28, 29,INTEREST_RATE29, 30,INTEREST_RATE30,
       31,INTEREST_RATE31, 32,INTEREST_RATE32,
       33,INTEREST_RATE33, 34,INTEREST_RATE34,
       35,INTEREST_RATE35, 36,INTEREST_RATE36, 37,INTEREST_RATE37,
       38,INTEREST_RATE38, 39,INTEREST_RATE39, 40,INTEREST_RATE40,
       41,INTEREST_RATE41, 42,INTEREST_RATE42,
       43,INTEREST_RATE43, 44,INTEREST_RATE44,
       45,INTEREST_RATE45, 46,INTEREST_RATE46, 47,INTEREST_RATE47,
       48,INTEREST_RATE48, 49,INTEREST_RATE49, 50,INTEREST_RATE50,
       51,INTEREST_RATE51, 52,INTEREST_RATE52,
       53,INTEREST_RATE53, 54,INTEREST_RATE54,
       55,INTEREST_RATE55, 56,INTEREST_RATE56, 57,INTEREST_RATE57,
       58,INTEREST_RATE58, 59,INTEREST_RATE59, 60,INTEREST_RATE60,
       61,INTEREST_RATE61, 62,INTEREST_RATE62,
       63,INTEREST_RATE63, 64,INTEREST_RATE64,
       65,INTEREST_RATE65, 66,INTEREST_RATE66, 67,INTEREST_RATE67,
       68,INTEREST_RATE68, 69,INTEREST_RATE69, 70,INTEREST_RATE70,
       71,INTEREST_RATE71, 72,INTEREST_RATE72,
       73,INTEREST_RATE73, 74,INTEREST_RATE74,
       75,INTEREST_RATE75, 76,INTEREST_RATE76, 77,INTEREST_RATE77,
       78,INTEREST_RATE78, 79,INTEREST_RATE79, 80,INTEREST_RATE80,
       81,INTEREST_RATE81, 82,INTEREST_RATE82,
       83,INTEREST_RATE83, 84,INTEREST_RATE84,
       85,INTEREST_RATE85, 86,INTEREST_RATE86, 87,INTEREST_RATE87,
       88,INTEREST_RATE88, 89,INTEREST_RATE89, 90,INTEREST_RATE90,
       91,INTEREST_RATE91, 92,INTEREST_RATE92,
       93,INTEREST_RATE93, 94,INTEREST_RATE94,
       95,INTEREST_RATE95, 96,INTEREST_RATE96, 97,INTEREST_RATE97,
       98,INTEREST_RATE98, 99,INTEREST_RATE99, 100,INTEREST_RATE100
      ) int_rate
 from FTP_IRC_ADI_RATE_T, TABLE(FTP_MULTI_TABLE_F())
 --Bobby20050719 - Interest rate should be in the same order as it interface table - Bug 4494361
 where INTEREST_RATE_CODE = p_int_rate_code order by EFFECTIVE_DATE,COLUMN_VALUE )
 where INT_RATE is not null;


l_indx := 0;

FOR i in 1..l_int_rates_tbl.COUNT LOOP
    BEGIN

    IF (l_eff_date_tbl(i) <> l_curr_date OR l_curr_date IS NULL) THEN
    	l_curr_date := l_eff_date_tbl(i);
    	l_indx := 1;
    ELSE
	 	l_indx := l_indx + 1;
    END IF;

    l_int_term  := l_int_terms_tbl(l_indx);
	 l_int_mult  := l_int_mults_tbl(l_indx);
    -- if present, update it
    UPDATE FTP_IRC_RATE_HIST SET
    INTEREST_RATE = l_int_rates_tbl(i)
    where INTEREST_RATE_TERM = l_int_term and
    INTEREST_RATE_TERM_MULT = l_int_mult and
    EFFECTIVE_DATE = l_eff_date_tbl(i) and
    INTEREST_RATE_CODE = p_int_rate_code;

    IF (SQL%ROWCOUNT = 0)
    THEN
        insert into FTP_IRC_RATE_HIST(EFFECTIVE_DATE,INTEREST_RATE_CODE,
        INTEREST_RATE_TERM,INTEREST_RATE_TERM_MULT,INTEREST_RATE,
        RATE_DATA_SOURCE_CODE,LAST_MODIFIED_DATE,CREATION_DATE,CREATED_BY,
        LAST_UPDATED_BY,LAST_UPDATE_DATE )
        values(l_eff_date_tbl(i),p_int_rate_code,l_int_term,
        l_int_mult,l_int_rates_tbl(i),1,sysdate,sysdate,1,1,sysdate );

       --Karen added for testing
       update FTP_IRC_ADI_RATE_T set STATUS ='INSERT'
       where EFFECTIVE_DATE = l_eff_date_tbl(i)
       AND INTEREST_RATE_CODE = p_int_rate_code;
    ELSE
       -- it has updated. so set the status to UPDATE
       --Karen added for testing
       update FTP_IRC_ADI_RATE_T set STATUS ='UPDATE'
       where EFFECTIVE_DATE = l_eff_date_tbl(i)
       AND INTEREST_RATE_CODE = p_int_rate_code;
    END IF;
    EXCEPTION
        when others then

            --put message on the message stack for calling program to handle
            FEM_ENGINES_PKG.Put_Message(
             p_app_name => 'FTP',
             p_msg_name => 'FTP_HIST_MIGRATE_ERR',
             p_token1   => 'EFF_DATE',
             p_value1   => l_eff_date_tbl(i)
            );
    END;
END LOOP;


FEM_ENGINES_PKG.TECH_MESSAGE(
  p_severity => c_log_level_2,
  p_module => l_block,
  p_msg_text => 'Successfully inserted/updated rows: '||l_int_terms_tbl.COUNT
 );

--commit the data
COMMIT;
retcode := c_true;

--remove the successful insert/update entries from the interface table
deletehistrates (
 errbuf   => errbuf,
 retcode  => retcode,
 p_int_rate_code => p_int_rate_code
);

EXCEPTION
    when others then

        --put message on the message stack for calling program to handle
        FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FTP',
         p_msg_name => 'FTP_UNEXP_ERR',
         p_token1   => 'SQLERRM',
         p_value1   => sqlerrm
        );
        retcode := c_false;

END migratehistrates;

/***************************************************************************
 Desc  : Deletes Historical Rates type of Interest Rate Code.
 Pgmr  : Raghuram K Nanda
 Date  : 8-Mar-2005
 **************************************************************************/
PROCEDURE deletehistrates (
 errbuf   OUT NOCOPY VARCHAR2,
 retcode  OUT NOCOPY VARCHAR2,
 p_int_rate_code IN NUMBER
)
IS
l_block  CONSTANT  VARCHAR2(80) := 'ftp.plsql.ftp_irc_adi_migrate.deletehistrates';
BEGIN

FEM_ENGINES_PKG.TECH_MESSAGE(
  p_severity => c_log_level_2,
  p_module => l_block||'.interest_rate_code',
  p_msg_text => p_int_rate_code
 );

DELETE FROM FTP_IRC_ADI_RATE_T WHERE INTEREST_RATE_CODE = p_int_rate_code and
STATUS IN ('INSERT','UPDATE');

FEM_ENGINES_PKG.TECH_MESSAGE(
  p_severity => c_log_level_2,
  p_module => l_block,
  p_msg_text => 'Successfully deleted rows: '||SQL%ROWCOUNT
 );

--commit the data
COMMIT;
retcode := c_true;
EXCEPTION
    when others then

        --put message on the message stack for calling program to handle
        FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FTP',
         p_msg_name => 'FTP_UNEXP_ERR',
         p_token1   => 'SQLERRM',
         p_value1   => sqlerrm
        );
        retcode := c_false;

END deletehistrates;

END FTP_IRC_ADI_MIGRATE;

/
