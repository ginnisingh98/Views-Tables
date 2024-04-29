--------------------------------------------------------
--  DDL for Package Body OZF_BASELINESALES_LIFT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_BASELINESALES_LIFT_PVT" AS
/*$Header: ozfvbslb.pls 120.1 2005/09/09 12:17 mkothari noship $*/

 OZF_DEBUG_HIGH_ON   CONSTANT BOOLEAN     := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
 OZF_DEBUG_MEDIUM_ON CONSTANT BOOLEAN     := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);
 OZF_DEBUG_LOW_ON    CONSTANT BOOLEAN     := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);

-- ------------------------
-- Public Procedures
-- ------------------------

-- ------------------------------------------------------------------
-- Name: START_PURGE
-- Desc: Program to Purge Baseline Sales and Promotional Lift Factor Data
-- -----------------------------------------------------------------
PROCEDURE START_PURGE
              (
                ERRBUF            OUT  NOCOPY VARCHAR2,
                RETCODE           OUT  NOCOPY NUMBER,
                p_data_source     IN VARCHAR2,
                p_data_type       IN VARCHAR2,
                p_curr_or_hist    IN VARCHAR2,
                p_record_type     IN VARCHAR2,
                p_as_of_date      IN VARCHAR2
	       )
IS
    l_api_name                CONSTANT VARCHAR2(30) := 'START_PURGE';
    l_full_name               CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
    x_msg_count               NUMBER;
    x_msg_data                VARCHAR2(240);
    x_return_status           VARCHAR2(1);
    l_init_msg_list           VARCHAR2(10)  := FND_API.G_FALSE;
    l_del_tbl_stmt1           VARCHAR2(100) := ' DELETE FROM ';
    l_del_err_tbl_stmt1       VARCHAR2(250) :=
            ' DELETE FROM OZF_INTERFACE_ERRORS ERR '
         || ' WHERE ERR.ENTITY_NAME = :1 '
         || ' AND ERR.ENTITY_ROW_ID IN (SELECT ';
    l_from_clause          VARCHAR2(10) := ' FROM ';
    l_del_err_tbl_stmt3   VARCHAR2(100) := ' WHERE DATA_SOURCE = :2 ';
    l_del_err_tbl_stmt4   VARCHAR2(100) := ' AND STATUS_FLAG = :3) ';
    l_del_int_tbl_stmt3   VARCHAR2(100) := ' WHERE DATA_SOURCE = :1 ';
    l_del_int_tbl_stmt4   VARCHAR2(100) := ' AND STATUS_FLAG = :2 ';
    l_del_his_tbl_stmt3   VARCHAR2(100) := ' WHERE DATA_SOURCE = :1 AND HISTORY_SNAPSHOT_DATE <= :2 ';
    l_sql_stmt      VARCHAR2(1000);
    l_entity_name   VARCHAR2(30);
    l_column_name   VARCHAR2(30);
    l_status_flag   VARCHAR2(1);
    l_as_of_date    DATE;
    l_header_rows   NUMBER;
    l_error_rows   NUMBER;
BEGIN

	ozf_utility_pvt.write_conc_log(' Start: Private API: ' || l_full_name || ' (-)');
	ozf_utility_pvt.write_conc_log(' -- Start Purging Program at : ' ||
	                                 to_char(sysdate,'MM-DD-YYYY HH24:MI:SS'));

	SAVEPOINT START_PURGE;

	-- Initialize API return status to SUCCESS
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	ozf_utility_pvt.write_conc_log('-- p_data_source is      : ' || p_data_source ) ;
	ozf_utility_pvt.write_conc_log('-- p_data_type is        : ' || p_data_type ) ;
	ozf_utility_pvt.write_conc_log('-- p_curr_or_hist is     : ' || p_curr_or_hist ) ;
	ozf_utility_pvt.write_conc_log('-- p_record_type is      : ' || p_record_type ) ;
	ozf_utility_pvt.write_conc_log('-- p_as_of_date is       : ' || p_as_of_date ) ;

	-- check if data_source is null
	IF p_data_source is NULL THEN
	   FND_MESSAGE.set_name('OZF', 'OZF_BASE_DATA_SRC_MISSING');
	   FND_MSG_PUB.add;
	   ozf_utility_pvt.write_conc_log(FND_MESSAGE.Get);
	   RAISE FND_API.g_exc_error;
	END IF;

	-- check if data_type is null
	IF p_data_type is NULL THEN
	   FND_MESSAGE.set_name('OZF', 'OZF_BASE_DATA_TYPE_MISSING');
	   FND_MSG_PUB.add;
	   ozf_utility_pvt.write_conc_log(FND_MESSAGE.Get);
	   RAISE FND_API.g_exc_error;
	END IF;

	-- check if p_curr_or_hist is null
	IF p_curr_or_hist is NULL THEN
	   FND_MESSAGE.set_name('OZF', 'OZF_BASE_CURR_OR_HIST_MISSING');
	   FND_MSG_PUB.add;
	   ozf_utility_pvt.write_conc_log(FND_MESSAGE.Get);
	   RAISE FND_API.g_exc_error;
	END IF;

	-- check if purging current data and p_record_type is null
	IF p_curr_or_hist = 'CURR_DATA' AND p_record_type is NULL THEN
	   FND_MESSAGE.set_name('OZF', 'OZF_BASE_RECORD_TYPE_MISSING');
	   FND_MSG_PUB.add;
	   ozf_utility_pvt.write_conc_log(FND_MESSAGE.Get);
	   RAISE FND_API.g_exc_error;
	END IF;

	-- check if purging historical data and p_as_of_date is null
	IF p_curr_or_hist = 'HIST_DATA' AND p_as_of_date is NULL THEN
	   FND_MESSAGE.set_name('OZF', 'OZF_BASE_AS_OF_DATE_MISSING');
	   FND_MSG_PUB.add;
	   ozf_utility_pvt.write_conc_log(FND_MESSAGE.Get);
	   RAISE FND_API.g_exc_error;
	END IF;


	----------------------------------------------------------
	-- Process Current Data
	----------------------------------------------------------
	IF p_curr_or_hist = 'CURR_DATA' THEN

	  IF p_data_type = 'BASELINE_SALES' THEN
	     l_entity_name := 'OZF_BASELINE_SALES_INTERFACE';
	     l_column_name := 'BASELINE_SALES_INTERFACE_ID';
	  ELSIF p_data_type = 'LIFT_FACTORS' THEN
	     l_entity_name := 'OZF_LIFT_FACTORS_INTERFACE';
	     l_column_name := 'LIFT_FACTORS_INTERFACE_ID';
	  END IF;

	  IF p_record_type = 'ERR_REC' THEN
	     l_status_flag := 'E';
	     l_sql_stmt := l_del_err_tbl_stmt1 || l_column_name || l_from_clause || l_entity_name
	                || l_del_err_tbl_stmt3 || l_del_err_tbl_stmt4;
	     IF OZF_DEBUG_HIGH_ON THEN
		ozf_utility_pvt.write_conc_log ('-- l_sql_stmt = '||l_sql_stmt);
	     END IF;
	     EXECUTE IMMEDIATE l_sql_stmt USING l_entity_name, p_data_source, l_status_flag;
	     l_error_rows := sql%rowcount;
	     ozf_utility_pvt.write_conc_log ('-- Purged '|| to_char(l_error_rows)||' error records in error table for entity = '
						  ||l_entity_name||' for Data Source ='
						  ||p_data_source ||';');

	     l_sql_stmt := null;
	     l_sql_stmt := l_del_tbl_stmt1 || l_entity_name || l_del_int_tbl_stmt3 || l_del_int_tbl_stmt4;
	     IF OZF_DEBUG_HIGH_ON THEN
		ozf_utility_pvt.write_conc_log ('-- l_sql_stmt = '||l_sql_stmt);
	     END IF;
	     EXECUTE IMMEDIATE l_sql_stmt USING p_data_source, l_status_flag;
	     l_header_rows := sql%rowcount;
	     ozf_utility_pvt.write_conc_log ('-- Purged '|| to_char(l_header_rows)||' error records in interface table = '
						  ||l_entity_name||' for Data Source = '
						  ||p_data_source ||';');

	  ELSIF p_record_type = 'S_P_REC' THEN
	     l_status_flag := 'P';
	     l_sql_stmt := l_del_err_tbl_stmt1 || l_column_name || l_from_clause || l_entity_name
	                || l_del_err_tbl_stmt3 || l_del_err_tbl_stmt4;
	     IF OZF_DEBUG_HIGH_ON THEN
		ozf_utility_pvt.write_conc_log ('-- l_sql_stmt = '||l_sql_stmt);
	     END IF;
	     EXECUTE IMMEDIATE l_sql_stmt USING l_entity_name, p_data_source, l_status_flag;
	     l_error_rows := sql%rowcount;
	     ozf_utility_pvt.write_conc_log ('-- Purged '|| to_char(l_error_rows)||' error records in error table for entity = '
						  ||l_entity_name||' for Data Source ='
						  ||p_data_source ||';');
	     l_sql_stmt := null;
	     l_sql_stmt := l_del_tbl_stmt1 || l_entity_name || l_del_int_tbl_stmt3 || l_del_int_tbl_stmt4;
	     IF OZF_DEBUG_HIGH_ON THEN
		ozf_utility_pvt.write_conc_log ('-- l_sql_stmt = '||l_sql_stmt);
	     END IF;
	     EXECUTE IMMEDIATE l_sql_stmt USING p_data_source, l_status_flag;
	     l_header_rows := sql%rowcount;
	     ozf_utility_pvt.write_conc_log ('-- Purged '|| to_char(l_header_rows)||' successfully processed records in interface table = '
						  ||l_entity_name||' for Data Source = '
						  ||p_data_source ||';');

	  ELSIF p_record_type = 'ALL_REC' THEN
	     l_sql_stmt := l_del_err_tbl_stmt1 || l_column_name || l_from_clause || l_entity_name
	                || l_del_err_tbl_stmt3 || ') ';
	     IF OZF_DEBUG_HIGH_ON THEN
		ozf_utility_pvt.write_conc_log ('-- l_sql_stmt = '||l_sql_stmt);
	     END IF;
	     EXECUTE IMMEDIATE l_sql_stmt USING l_entity_name, p_data_source;
	     l_error_rows := sql%rowcount;
	     ozf_utility_pvt.write_conc_log ('-- Purged '|| to_char(l_error_rows)||' error records in error table for entity = '
						  ||l_entity_name||' for Data Source ='
						  ||p_data_source ||';');

	     l_sql_stmt := null;
	     l_sql_stmt := l_del_tbl_stmt1 || l_entity_name || l_del_int_tbl_stmt3;
	     IF OZF_DEBUG_HIGH_ON THEN
		ozf_utility_pvt.write_conc_log ('-- l_sql_stmt = '||l_sql_stmt);
	     END IF;
	     EXECUTE IMMEDIATE l_sql_stmt USING p_data_source;
	     l_header_rows := sql%rowcount;
	     ozf_utility_pvt.write_conc_log ('-- Purged '|| to_char(l_header_rows)||' records in interface table = '
						  ||l_entity_name||' for Data Source = '
						  ||p_data_source ||';');
	  END IF;

	----------------------------------------------------------
	-- Process Historical Data
	----------------------------------------------------------
	ELSIF p_curr_or_hist = 'HIST_DATA' THEN

	  l_as_of_date := trunc(NVL(FND_DATE.CANONICAL_TO_DATE(p_as_of_date), sysdate));

	  IF p_data_type = 'BASELINE_SALES' THEN
	     l_entity_name := 'OZF_BASELINE_SALES_HISTORY';
	  ELSIF p_data_type = 'LIFT_FACTORS' THEN
	     l_entity_name := 'OZF_LIFT_FACTORS_HISTORY';
	  END IF;
          l_sql_stmt := null;
          l_sql_stmt := l_del_tbl_stmt1 || l_entity_name || l_del_his_tbl_stmt3;
	  IF OZF_DEBUG_HIGH_ON THEN
	     ozf_utility_pvt.write_conc_log ('-- l_sql_stmt = '||l_sql_stmt);
	  END IF;
	  EXECUTE IMMEDIATE l_sql_stmt USING p_data_source, l_as_of_date;
          l_header_rows := sql%rowcount;
	  ozf_utility_pvt.write_conc_log ('-- Purged '|| to_char(l_header_rows)||' records of historical data in '
	     				||l_entity_name||' for Data Source = '
	     			        ||p_data_source ||' up to snapshot date '
	     			        ||to_char(l_as_of_date,'DD-MON-YYYY')||' ;');

	END IF;


	----------------------------------------------------------
	-- commit the deleled records
	----------------------------------------------------------
	ozf_utility_pvt.write_conc_log('-- Commiting Purged Records ');

	COMMIT;

	ozf_utility_pvt.write_conc_log('-- Committed ');
	----------------------------------------------------------

	ozf_utility_pvt.write_conc_log(' -- End: Purging Program at : ' || to_char(sysdate,'MM-DD-YYYY HH24:MI:SS'));
	ozf_utility_pvt.write_conc_log('End: Private API: ' || l_full_name || ' (+)');

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO START_PURGE;
	  x_return_status := FND_API.g_ret_sts_error ;
          ERRBUF := x_msg_data;
          RETCODE := 2;
          ozf_utility_pvt.write_conc_log('Private API: ' || l_full_name || ' Expected Error ' );
          ozf_utility_pvt.write_conc_log(sqlerrm(sqlcode) );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO START_PURGE;
	  x_return_status := FND_API.g_ret_sts_unexp_error ;
          ERRBUF := sqlerrm(sqlcode);
          RETCODE := 2;
          ozf_utility_pvt.write_conc_log('Private API: ' || l_full_name || ' Unexpected Error ' );
          ozf_utility_pvt.write_conc_log(sqlerrm(sqlcode) );

     WHEN OTHERS THEN
          ROLLBACK TO START_PURGE;
	  x_return_status := FND_API.g_ret_sts_unexp_error ;
          ERRBUF  := sqlerrm(sqlcode);
          RETCODE := 2;
          ozf_utility_pvt.write_conc_log('Private API: ' || l_full_name || ' Other Error ' );
          ozf_utility_pvt.write_conc_log(sqlerrm(sqlcode) );

END START_PURGE;


END OZF_BASELINESALES_LIFT_PVT;

/
