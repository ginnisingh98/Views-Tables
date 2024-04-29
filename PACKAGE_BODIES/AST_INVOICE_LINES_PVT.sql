--------------------------------------------------------
--  DDL for Package Body AST_INVOICE_LINES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_INVOICE_LINES_PVT" AS
/* $Header: astvinlb.pls 115.3 2002/02/06 11:21:05 pkm ship      $ */

	G_PKG_NAME	CONSTANT VARCHAR2(30) := 'AST_Invoice_Lines_PVT';
	G_FILE_NAME	CONSTANT VARCHAR2(12) :='astvinlb.pls';
	G_APPL_ID		NUMBER := FND_GLOBAL.Prog_Appl_Id;
	G_LOGIN_ID	NUMBER := FND_GLOBAL.Conc_Login_Id;
	G_PROGRAM_ID	NUMBER := FND_GLOBAL.Conc_Program_Id;
	G_USER_ID		NUMBER := FND_GLOBAL.User_Id;
	G_REQUEST_ID	NUMBER := FND_GLOBAL.Conc_Request_Id;

PROCEDURE Get_Invoice_Lines(
          p_api_version           IN  NUMBER,
          p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
          p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
          p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
          x_return_status         OUT VARCHAR2,
          x_msg_count             OUT NUMBER,
          x_msg_data              OUT VARCHAR2,
          p_invoice_id            IN  NUMBER,
          x_line_id_t             OUT line_id_tbl_type,
          x_line_number_t         OUT line_number_tbl_type,
          x_item_t                OUT item_tbl_type,
          x_units_t               OUT units_tbl_type,
          x_quantity_t            OUT quantity_tbl_type,
          x_price_per_unit_t      OUT price_per_unit_tbl_type,
          x_original_amount_t     OUT original_amount_tbl_type
      )
AS
     l_api_name     CONSTANT VARCHAR2(30) := 'Get_Invoice_Lines';
     l_api_version  CONSTANT NUMBER := 1.0;
     i              BINARY_INTEGER := 0;
     l_return_status VARCHAR2(1);
     l_msg_count NUMBER;
     l_msg_data VARCHAR2(32767);
     l_invoice_id  NUMBER := p_invoice_id;

     l_line_id_t             AST_Invoice_Lines_PVT.line_id_tbl_type;
     l_line_number_t         AST_Invoice_Lines_PVT.line_number_tbl_type;
     l_item_t                AST_Invoice_Lines_PVT.item_tbl_type;
     l_units_t               AST_Invoice_Lines_PVT.units_tbl_type;
     l_quantity_t            AST_Invoice_Lines_PVT.quantity_tbl_type;
     l_price_per_unit_t      AST_Invoice_Lines_PVT.price_per_unit_tbl_type;
     l_original_amount_t     AST_Invoice_Lines_PVT.original_amount_tbl_type;

     CURSOR c_inv_line IS
	  SELECT customer_trx_line_id,
         customer_trx_id,
         line_number,
         inventory_item_id,
         uom_code,
         quantity,
         unit_selling_price,
         extended_amount
       FROM ra_customer_trx_lines_v
       WHERE customer_trx_id = l_invoice_id;

BEGIN
     -- Standard start of API savepoint
     SAVEPOINT     Get_Invoice_Lines_PVT;

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
	     ast_INVOICE_LINES_CUHK.Get_Invoice_Lines_PRE(p_api_version => l_api_version,
						x_return_status => l_return_status,
						x_msg_count => l_msg_count,
						x_msg_data => l_msg_data,
						p_invoice_id => l_invoice_id);
             IF (l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		     RAISE FND_API.G_EXC_ERROR;
             ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	     END IF;
    END IF;


    /*  	Verticle industry pre- processing section  -  mandatory     */
    IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, l_api_name, 'B', 'V' )  )  THEN
		ast_INVOICE_LINES_VUHK.Get_Invoice_Lines_PRE(p_api_version => l_api_version,
						x_return_status => l_return_status,
						x_msg_count => l_msg_count,
						x_msg_data => l_msg_data,
						p_invoice_id => l_invoice_id);
		IF (l_return_status = FND_API.G_RET_STS_ERROR )  THEN
			RAISE FND_API.G_EXC_ERROR;
          ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
    END IF;

	 -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- API body

     FOR inv_line_rec IN c_inv_line LOOP
	  i := i + 1;
       l_line_id_t(i) := inv_line_rec.customer_trx_line_id;
       l_line_number_t(i) := inv_line_rec.line_number;
       l_item_t(i) := inv_line_rec.inventory_item_id;
       l_units_t(i) := inv_line_rec.uom_code;
       l_quantity_t(i) := inv_line_rec.quantity;
       l_price_per_unit_t(i) := inv_line_rec.unit_selling_price;
       l_original_amount_t(i) := inv_line_rec.extended_amount;
	  --dbms_output.put_line('Line Numer : ' || l_line_number_t(i));
	END LOOP;

     x_line_id_t := l_line_id_t;
     x_line_number_t := l_line_number_t;
     x_item_t := l_item_t;
     x_units_t := l_units_t;
     x_quantity_t := l_quantity_t;
     x_price_per_unit_t := l_price_per_unit_t;
     x_original_amount_t := l_original_amount_t;


     -- End of API body

	/*  Vertical Post Processing section      -  mandatory              	*/
	IF  (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'V' )  )  THEN
		ast_INVOICE_LINES_VUHK.Get_Invoice_Lines_POST(p_api_version => l_api_version,
							x_return_status => l_return_status,
							x_msg_count => l_msg_count,
							x_msg_data => l_msg_data,
						p_invoice_id => l_invoice_id);
		if (l_return_status = FND_API.G_RET_STS_ERROR )  THEN
					RAISE FND_API.G_EXC_ERROR;
	        ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

	END IF;

	/*  Customer  Post Processing section      -  mandatory              	*/
	IF  (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'C' )  )  THEN
		ast_INVOICE_LINES_CUHK.Get_Invoice_Lines_POST (p_api_version => l_api_version,
								x_return_status => l_return_status,
								x_msg_count => l_msg_count,
								x_msg_data => l_msg_data,
						          p_invoice_id => l_invoice_id);
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
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
						 p_data => x_msg_data,
						 p_encoded => FND_API.G_FALSE);
EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Get_Invoice_Lines_PVT;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Get_Invoice_Lines_PVT;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

     WHEN OTHERS THEN
          ROLLBACK TO Get_Invoice_Lines_PVT;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
               FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
END Get_Invoice_Lines;
END ast_Invoice_Lines_PVT;

/
