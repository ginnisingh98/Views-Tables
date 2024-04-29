--------------------------------------------------------
--  DDL for Package Body AST_INVOICES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_INVOICES_PVT" AS
/* $Header: astvinvb.pls 115.3 2002/02/06 11:43:53 pkm ship   $ */

	G_PKG_NAME	CONSTANT VARCHAR2(30) := 'AST_Invoices_PVT';
	G_FILE_NAME CONSTANT VARCHAR2(12) :='astvinvb.pls';
	G_APPL_ID NUMBER := FND_GLOBAL.Prog_Appl_Id;
	G_LOGIN_ID NUMBER := FND_GLOBAL.Conc_Login_Id;
	G_PROGRAM_ID NUMBER := FND_GLOBAL.Conc_Program_Id;
	G_USER_ID NUMBER := FND_GLOBAL.User_Id;
	G_REQUEST_ID NUMBER := FND_GLOBAL.Conc_Request_Id;

PROCEDURE Get_Invoices(
	P_API_VERSION		        IN  NUMBER,
	P_INIT_MSG_LIST		   IN  VARCHAR2 := FND_API.G_FALSE,
	P_COMMIT		             IN  VARCHAR2 := FND_API.G_FALSE,
	P_VALIDATION_LEVEL	        IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
	X_RETURN_STATUS		   OUT VARCHAR2,
	X_MSG_COUNT		        OUT NUMBER,
	X_MSG_DATA		        OUT VARCHAR2,
	P_TRANSACTION_IDS	        IN  VARCHAR2,
	X_INVOICE_ID_T              OUT INVOICE_ID_TBL_TYPE,
	X_INVOICE_NUMBER_T          OUT INVOICE_NUMBER_TBL_TYPE,
	X_INVOICE_STATUS_T          OUT INVOICE_STATUS_TBL_TYPE,
	X_INVOICE_CLASS_T           OUT INVOICE_CLASS_TBL_TYPE,
	X_INV_STATUS_CODE_T         OUT INV_STATUS_CODE_TBL_TYPE,
	X_INV_CLASS_CODE_T          OUT INV_CLASS_CODE_TBL_TYPE,
	X_INVOICE_DATE_T            OUT INVOICE_DATE_TBL_TYPE,
	X_ORIGINAL_AMOUNT_T         OUT ORIGINAL_AMOUNT_TBL_TYPE,
	X_REMAINING_AMOUNT_T        OUT REMAINING_AMOUNT_TBL_TYPE,
	X_INVOICE_CURRENCY_T        OUT INVOICE_CURRENCY_TBL_TYPE,
	X_FUN_REMAINING_AMOUNT_T    OUT FUN_REMAINING_AMOUNT_TBL_TYPE)
AS
    l_api_name	CONSTANT VARCHAR2(30) := 'Get_Invoices';
    l_api_version	CONSTANT NUMBER := 1.0;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(32767);
    l_trx_id_cond VARCHAR2(100) := p_transaction_ids;


    l_cur_get_inv             NUMBER;
    l_select_cl               VARCHAR2(2000) := '';
    l_order_by_cl             VARCHAR2(2000);
    l_where_cl                VARCHAR2(2000) := '';

    TYPE trx_id_tbl_type      IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    l_trx_id_tbl              trx_id_tbl_type;
    l_idx                     BINARY_INTEGER;
    i                         NUMBER;
    j                         NUMBER;

    l_inv_id_tbl              AST_Invoices_PVT.invoice_id_tbl_type;
    l_inv_num_tbl             AST_Invoices_PVT.invoice_number_tbl_type;
    l_inv_status_tbl          AST_Invoices_PVT.invoice_status_tbl_type;
    l_inv_class_tbl           AST_Invoices_PVT.invoice_class_tbl_type;
    l_inv_status_code_tbl     AST_Invoices_PVT.inv_status_code_tbl_type;
    l_inv_class_code_tbl      AST_Invoices_PVT.inv_class_code_tbl_type;
    l_inv_date_tbl            AST_Invoices_PVT.invoice_date_tbl_type;
    l_original_amt_tbl        AST_Invoices_PVT.original_amount_tbl_type;
    l_remaining_amt_tbl       AST_Invoices_PVT.remaining_amount_tbl_type;
    l_inv_currency_tbl        AST_Invoices_PVT.invoice_currency_tbl_type;
    l_fun_remaining_amt_tbl   AST_Invoices_PVT.fun_remaining_amount_tbl_type;

    l_rows_processed           NUMBER;

BEGIN
	-- Standard start of API savepoint
	SAVEPOINT	Get_Invoices_PVT;

	-- Standard call to check for call compatibility
	IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE
	IF FND_API.To_Boolean(p_init_msg_list) THEN
		FND_MSG_PUB.initialize;
	END IF;

   -- Implementation of User Hooks
    /*   Copy all parameters to local variables to be passed to Pre, Post and Business APIs  */
    /*  l_rec      -  will be used as In Out parameter  in pre/post/Business  API calls */
    /*  l_return_status  -  will be a out variable to get return code from called APIs  */

    /*  	Customer pre -processing  section - Mandatory 	*/
    IF  (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, l_api_name, 'B', 'C' )  )  THEN
	     ast_INVOICES_CUHK.GET_INVOICES_PRE(p_api_version => l_api_version,
						x_return_status => l_return_status,
						x_msg_count => l_msg_count,
						x_msg_data => l_msg_data,
						p_transaction_ids => l_trx_id_cond);
             IF (l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
             ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	     END IF;
    END IF;


    /*  	Verticle industry pre- processing section  -  mandatory     */
    IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, l_api_name, 'B', 'V' )  )  THEN
		ast_INVOICES_VUHK.GET_INVOICES_PRE(p_api_version => l_api_version,
						x_return_status => l_return_status,
						x_msg_count => l_msg_count,
						x_msg_data => l_msg_data,
						p_transaction_ids => l_trx_id_cond);
		IF (l_return_status = FND_API.G_RET_STS_ERROR )  THEN
			RAISE FND_API.G_EXC_ERROR;
           	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
    END IF;

	-- Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- API body begin

    l_select_cl := 'SELECT customer_trx_id, '
      || 'trx_number, '
      || 'al_status_meaning, '
      || 'al_class_meaning, '
      || 'status, '
      || 'class, '
      || 'amount_due_remaining, '
      || 'amount_due_original, '
      || 'trx_date, '
      || 'invoice_currency_code, '
      || 'acctd_amount_due_remaining '
      || 'FROM   ar_payment_schedules_v ';

    l_where_cl := 'WHERE customer_trx_id IN ( ';
    l_order_by_cl := ' ORDER BY trx_number ';

    i := 1;
    l_idx := 1;
    LOOP
      j := instr(l_trx_id_cond, ',', i);

      EXIT WHEN j = 0;
      --dbms_output.put_line(substr(l_trx_id_cond, i, j - i));
      l_trx_id_tbl(l_idx) := to_number(substr(l_trx_id_cond, i, j - i));

      IF l_idx > 1 THEN
        l_where_cl := l_where_cl || ' , ';
      END IF;

      l_where_cl := l_where_cl || ':x' || l_idx;
      i := j + 1;
      l_idx := l_idx + 1;

    END LOOP;

    l_where_cl := l_where_cl || ')';

    --dbms_output.put_line('Where Clause > ' || l_where_cl);
    --dbms_output.put_line('Trx ID Count > ' || l_trx_id_tbl.count);

    l_select_cl := l_select_cl || l_where_cl || l_order_by_cl;
    --dbms_output.put_line('Select Clause > ' || l_select_cl);

    l_cur_get_inv := dbms_sql.open_cursor;

    dbms_sql.parse(l_cur_get_inv, l_select_cl, dbms_sql.native);

    FOR i IN 1..l_trx_id_tbl.count LOOP
      --dbms_output.put_line('i > ' || i);
      dbms_sql.bind_variable(l_cur_get_inv, ':x' || i, l_trx_id_tbl(i));
    END LOOP;

    l_inv_id_tbl(1) := null;
    l_inv_num_tbl(1) := null;
    l_inv_status_tbl(1) := null;
    l_inv_class_tbl(1) := null;
    l_inv_status_code_tbl(1) := null;
    l_inv_class_code_tbl(1) := null;
    l_remaining_amt_tbl(1) := null;
    l_original_amt_tbl(1) := null;
    l_inv_date_tbl(1) := null;
    l_inv_currency_tbl(1) := null;
    l_fun_remaining_amt_tbl(1) := null;

    dbms_sql.define_column(l_cur_get_inv, 1, l_inv_id_tbl(1));
    dbms_sql.define_column(l_cur_get_inv, 2, l_inv_num_tbl(1), 30);
    dbms_sql.define_column(l_cur_get_inv, 3, l_inv_status_tbl(1), 80);
    dbms_sql.define_column(l_cur_get_inv, 4, l_inv_class_tbl(1), 80);
    dbms_sql.define_column(l_cur_get_inv, 5, l_inv_status_code_tbl(1), 30);
    dbms_sql.define_column(l_cur_get_inv, 6, l_inv_class_code_tbl(1), 20);
    dbms_sql.define_column(l_cur_get_inv, 7, l_remaining_amt_tbl(1));
    dbms_sql.define_column(l_cur_get_inv, 8, l_original_amt_tbl(1));
    dbms_sql.define_column(l_cur_get_inv, 9, l_inv_date_tbl(1));
    dbms_sql.define_column(l_cur_get_inv, 10, l_inv_currency_tbl(1), 15);
    dbms_sql.define_column(l_cur_get_inv, 11, l_fun_remaining_amt_tbl(1));

    l_rows_processed := dbms_sql.execute(l_cur_get_inv);

    --dbms_output.put_line ('l_rows_processed > ' || l_rows_processed);
    l_idx := 0;
    LOOP
      l_idx := l_idx + 1;

      l_rows_processed := dbms_sql.fetch_rows(l_cur_get_inv);
      --dbms_output.put_line ('l_rows_processed > ' || l_rows_processed);
      IF l_rows_processed <= 0 THEN
        EXIT;
      END IF;

      dbms_sql.column_value(l_cur_get_inv, 1, l_inv_id_tbl(l_idx));
      dbms_sql.column_value(l_cur_get_inv, 2, l_inv_num_tbl(l_idx));
      dbms_sql.column_value(l_cur_get_inv, 3, l_inv_status_tbl(l_idx));
      dbms_sql.column_value(l_cur_get_inv, 4, l_inv_class_tbl(l_idx));
      dbms_sql.column_value(l_cur_get_inv, 5, l_inv_status_code_tbl(l_idx));
      dbms_sql.column_value(l_cur_get_inv, 6, l_inv_class_code_tbl(l_idx));
      dbms_sql.column_value(l_cur_get_inv, 7, l_remaining_amt_tbl(l_idx));
      dbms_sql.column_value(l_cur_get_inv, 8, l_original_amt_tbl(l_idx));
      dbms_sql.column_value(l_cur_get_inv, 9, l_inv_date_tbl(l_idx));
      dbms_sql.column_value(l_cur_get_inv, 10, l_inv_currency_tbl(l_idx));
      dbms_sql.column_value(l_cur_get_inv, 11, l_fun_remaining_amt_tbl(l_idx));

      --dbms_output.put_line(l_inv_num_tbl(l_idx));
    END LOOP;

    dbms_sql.close_cursor(l_cur_get_inv);


    x_invoice_id_t := l_inv_id_tbl;
    x_invoice_number_t := l_inv_num_tbl;
    x_invoice_status_t := l_inv_status_tbl;
    x_invoice_class_t := l_inv_class_tbl;
    x_inv_status_code_t := l_inv_status_code_tbl;
    x_inv_class_code_t := l_inv_class_code_tbl;
    x_remaining_amount_t := l_remaining_amt_tbl;
    x_original_amount_t := l_original_amt_tbl;
    x_invoice_date_t := l_inv_date_tbl;
    x_invoice_currency_t := l_inv_currency_tbl;
    x_fun_remaining_amount_t := l_fun_remaining_amt_tbl;

	-- API body end

	/*  Customer  Post Processing section      -  mandatory              	*/
	IF  (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'C' )  )  THEN
		ast_INVOICES_CUHK.GET_INVOICES_Post (p_api_version => l_api_version,
								x_return_status => l_return_status,
								x_msg_count => l_msg_count,
								x_msg_data => l_msg_data,
								p_transaction_ids => l_trx_id_cond);
		IF (l_return_status = FND_API.G_RET_STS_ERROR )  THEN
				RAISE FND_API.G_EXC_ERROR;
           	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
	END IF;

	-- Standard check of p_commit
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

	-- Standard call to get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Get_Invoices_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Get_Invoices_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN OTHERS THEN
		ROLLBACK TO Get_Invoices_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END Get_Invoices;

END ast_Invoices_PVT;

/
