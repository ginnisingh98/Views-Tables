--------------------------------------------------------
--  DDL for Package Body INV_SHORTCHECKPROCESSTRX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_SHORTCHECKPROCESSTRX_PVT" AS
/* $Header: INVSPPVB.pls 120.2 2006/03/15 15:05:21 somanaam ship $*/
  -- Start OF comments
  -- API name  : ProcessTransactions
  -- TYPE      : Private
  -- Pre-reqs  : None
  -- FUNCTION  :
  -- Parameters:
  --     IN    :
  --
  --	 OUT   :
  --
  --  ERRBUF		 OUT VARCHAR2
  --	Error code
  --
  --  RETCODE		 OUT NUMBER
  --	Return completion status
  --
  -- Version: Current Version 1.0
  --              Changed : Nothing
  --          No Previous Version 0.0
  --          Initial version 1.0
  -- Notes  :
  -- END OF comments
PROCEDURE ProcessTransactions (
  ERRBUF 			OUT NOCOPY VARCHAR2,
  RETCODE			OUT NOCOPY NUMBER
  )
IS
  --
  L_return_status	VARCHAR2(1);
  L_msg_count		NUMBER;
  L_msg_data		VARCHAR2(2000);
  L_check_result	VARCHAR2(1);
  L_seq_num		NUMBER;
  L_conc_status		BOOLEAN;
  --
  CURSOR L_SelectTrx_csr (l_days in number )IS
	SELECT /*+ INDEX (mmt mtl_material_transactions_n5) */
               organization_id,
	       inventory_item_id
	  FROM mtl_material_transactions
	 WHERE shortage_process_code = 1
           and transaction_date > (sysdate - l_days )
	GROUP BY organization_id,
                 inventory_item_id;
  --
  L_SelectTrx_rec	L_SelectTrx_csr%ROWTYPE;
  --
  -- This cursor is to select the most recent transaction for an item
  -- If multiple transactions have the same date, the transaction with the
  -- higher quantity is choosen
  CURSOR L_LastTrx_csr ( p_inventory_item_id  IN NUMBER,
			 p_organization_id    IN NUMBER ) IS
  SELECT primary_quantity
  FROM   mtl_material_transactions
  WHERE  inventory_item_id 	= p_inventory_item_id
  AND    organization_id   	= p_organization_id
  AND    shortage_process_code 	= 1
  ORDER BY transaction_date DESC,
	   primary_quantity;
  --
  L_LastTrx_rec		L_LastTrx_csr%ROWTYPE;
  --
  l_days number := 30;
  --
  PROCEDURE UpdateTrx ( p_organization_id	 IN NUMBER,
		        p_inventory_item_id	 IN NUMBER,
			p_shortage_process_code  IN NUMBER )
  IS
  BEGIN
    UPDATE mtl_material_transactions
    SET    shortage_process_code = p_shortage_process_code
    WHERE  organization_id   	 = p_organization_id
    AND    inventory_item_id 	 = p_inventory_item_id
    AND    shortage_process_code = 1;
  END UpdateTrx;
  --
BEGIN
    -- Initialize RETCODE
    RETCODE := 0;
    -- Get the items that have to be checked from material transactions table
    OPEN L_SelectTrx_csr(l_days);
    LOOP
    BEGIN
    FETCH L_SelectTrx_csr INTO L_SelectTrx_rec;
    EXIT WHEN L_SelectTrx_csr%NOTFOUND;
    --
    	-- Since we only want to check the most recent transaction for an
    	-- item/org combination we open another cursor for the last transaction
	-- and fetch just the first record
        OPEN L_LastTrx_csr ( L_SelectTrx_rec.inventory_item_id,
			     L_SelectTrx_rec.organization_id );
	FETCH L_LastTrx_csr INTO L_LastTrx_rec;
        -- Call the shortage check procedure
        INV_ShortCheckExec_PVT.ExecCheck (
  		p_api_version		=> 1.0,
  		p_init_msg_list 	=> FND_API.G_TRUE,
  		p_commit 		=> FND_API.G_TRUE,
  		x_return_status		=> L_return_status,
  		x_msg_count		=> L_msg_count,
  		x_msg_data		=> L_msg_data,
  		p_sum_detail_flag	=> 1,
  		p_organization_id	=> L_SelectTrx_rec.organization_id,
  		p_inventory_item_id	=> L_SelectTrx_rec.inventory_item_id,
  		p_comp_att_qty_flag	=> 1,
		p_primary_quantity	=> L_LastTrx_rec.primary_quantity,
  		x_seq_num		=> L_seq_num,
  		x_check_result		=> L_check_result
  		);
    	--
    	-- If an error has occured set shortage process code to error,
    	-- write error msg data to ERRBUF and to log file and set RETCODE
    	IF L_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       	   UpdateTrx ( L_SelectTrx_rec.organization_id,
            	       L_SelectTrx_rec.inventory_item_id,
                       3 );
       	   ERRBUF := L_msg_data;
       	   FND_FILE.PUT_LINE(FND_FILE.LOG,ERRBUF);
	   RETCODE := 1;
    	   --
    	   -- Else call send notifications proc if shortage has been detected
    	ELSE
    	   IF L_check_result = FND_API.G_TRUE THEN
       	      INV_ShortCheckExec_PVT.SendNotifications (
  	  	p_api_version 	  	=> 1.0,
	  	p_init_msg_list         => FND_API.G_TRUE,
          	p_commit                => FND_API.G_TRUE,
          	x_return_status         => L_return_status,
          	x_msg_count             => L_msg_count,
          	x_msg_data              => L_msg_data,
  	  	p_organization_id	=> L_SelectTrx_rec.organization_id,
	  	p_inventory_item_id	=> L_SelectTrx_rec.inventory_item_id,
  	  	p_seq_num		=> L_seq_num,
		p_notification_type	=> 'R'
          	);
    	      -- If an error has occured set shortage process code to error,
    	      -- write error msg data to ERRBUF and to log file and set RETCODE
    	      IF L_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       		 UpdateTrx ( L_SelectTrx_rec.organization_id,
                   	     L_SelectTrx_rec.inventory_item_id,
                   	     3 );
       		 ERRBUF := L_msg_data;
       		 FND_FILE.PUT_LINE(FND_FILE.LOG,ERRBUF);
		 RETCODE := 1;
    	      --
    	      ELSE
    		 -- Update checked rows in material transactions table
    		 UpdateTrx ( L_SelectTrx_rec.organization_id,
			     L_SelectTrx_rec.inventory_item_id,
			     2 );
    	      END IF;
	   ELSE
    	      -- Update checked rows in material transactions table
    	      UpdateTrx ( L_SelectTrx_rec.organization_id,
		          L_SelectTrx_rec.inventory_item_id,
			  2 );
    	   END IF;
        END IF;
    --
    -- Purge the rows from the temp table (if there are any)
    INV_ShortCheckExec_PVT.PurgeTempTable (
   	  p_api_version 	  => 1.0,
	  p_init_msg_list         => FND_API.G_TRUE,
          p_commit                => FND_API.G_TRUE,
          x_return_status         => L_return_status,
          x_msg_count             => L_msg_count,
          x_msg_data              => L_msg_data,
  	  p_seq_num		  => L_seq_num
          );
    --
    CLOSE L_LastTrx_csr;
    --
    EXCEPTION
    WHEN OTHERS THEN
        -- If an error has occured set shortage process code to error,
       UpdateTrx ( L_SelectTrx_rec.organization_id,
                   L_SelectTrx_rec.inventory_item_id,
                   3 );
       --
       -- write error msg data to ERRBUF and to log file and set RETCODE
       ERRBUF := TO_CHAR(SQLCODE);
       FND_FILE.PUT_LINE(FND_FILE.LOG,ERRBUF);
       RETCODE := 1;
       --
       -- and purge the rows from the temp table (if there are any)
       INV_ShortCheckExec_PVT.PurgeTempTable (
   	  p_api_version 	  => 1.0,
	  p_init_msg_list         => FND_API.G_TRUE,
          p_commit                => FND_API.G_TRUE,
          x_return_status         => L_return_status,
          x_msg_count             => L_msg_count,
          x_msg_data              => L_msg_data,
  	  p_seq_num		  => L_seq_num
          );
    END;
    --
    COMMIT;
    END LOOP;
    CLOSE L_SelectTrx_csr;
    --
    -- Set completion status and retcode
    IF RETCODE = 0 THEN
       L_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS ('NORMAL','');
    ELSIF RETCODE = 1 THEN
       L_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS ('WARNING','');
    END IF;
    --
END ProcessTransactions;
END INV_ShortCheckProcessTrx_PVT;

/
