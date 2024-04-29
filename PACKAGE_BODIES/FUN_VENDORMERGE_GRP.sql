--------------------------------------------------------
--  DDL for Package Body FUN_VENDORMERGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_VENDORMERGE_GRP" AS
/* $Header: funntsmb.pls 120.4 2006/03/30 14:15:05 asrivats noship $ */

	--Declare all required global variables
    g_user_id               NUMBER;
    g_login_id              NUMBER;
    g_today                 DATE;

--===========================FND_LOG.START=====================================

    g_state_level NUMBER;
    g_proc_level  NUMBER;
    g_event_level NUMBER;
    g_excep_level NUMBER;
    g_error_level NUMBER;
    g_unexp_level NUMBER;
    g_path        VARCHAR2(100);

--===========================FND_LOG.END=======================================

    PROCEDURE Merge_Vendor(
            -- ***** Standard API Parameters *****
	p_api_version         IN   NUMBER,
	p_init_msg_list       IN   VARCHAR2 default FND_API.G_FALSE,
	p_commit              IN   VARCHAR2 default FND_API.G_FALSE,
	p_validation_level    IN   NUMBER   default FND_API.G_VALID_LEVEL_FULL,
	p_return_status       OUT  NOCOPY   VARCHAR2,
	p_msg_count           OUT  NOCOPY   NUMBER ,
	p_msg_data            OUT  NOCOPY   VARCHAR2,
           -- ****** Merge Input Parameters ******
	p_vendor_id           IN            NUMBER ,
	p_dup_vendor_id       IN            NUMBER ,
	p_vendor_site_id      IN            NUMBER ,
	p_dup_vendor_site_id  IN            NUMBER
	)
 IS

        -- ***** local variables *****
        l_return_status         VARCHAR2(1);
        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(2000);
        l_path			VARCHAR2(100);
	PROCEDURE Check_Mandatory_Parameters (
		x_return_status OUT NOCOPY VARCHAR2)
	IS
	BEGIN
		x_return_status := FND_API.G_TRUE;
                IF p_vendor_id IS NULL or p_dup_vendor_id IS NULL
                 or p_vendor_site_id IS NULL  or p_dup_vendor_site_id IS NULL
		THEN
			x_return_status := FND_API.G_FALSE;
			RETURN;
		END IF;

	EXCEPTION
		WHEN OTHERS THEN
			x_return_status := FND_API.G_FALSE;

	END Check_Mandatory_Parameters;

    BEGIN
        p_msg_count		:=	NULL;
        p_msg_data		:=	NULL;
        g_user_id               := fnd_global.user_id;
        g_login_id              := fnd_global.login_id;

	l_path  := g_path||'Supplier Merge:';
        fun_net_util.Log_String(g_event_level,l_path,'Supplier Merge(+)');

        -- ****   Standard start of API savepoint  ****

        SAVEPOINT Merge_Vendor_SP;

        -- ****  Initialize message list if p_init_msg_list is set to TRUE. ****

        IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;

        -- ****  Initialize return status to SUCCESS   *****
        p_return_status := FND_API.G_RET_STS_SUCCESS;

        /*-----------------------------------------------+
        |   ========  START OF API BODY  ============   |
        +-----------------------------------------------*/

        -- ****  Check for mandatory parameters ****

/*        fun_net_util.Log_String(g_event_level,
				l_path
				,'Check Mandatory Params(+)');

        Check_Mandatory_Parameters(
	x_return_status => l_return_status);

        fun_net_util.Log_String(g_event_level,
				l_path
				,'Return Status'|| l_return_status);

        fun_net_util.Log_String(g_event_level,
				l_path,
				'Check Mandatory Params(-)');

	IF l_return_status = FND_API.G_FALSE THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;
*/
 	-- Update Vendor Id and Vendor Site id with the Merged Vendor Id
        -- and Vendor Site Id
	-- If the Vendor Id and the Merged Vendor Id and in the same
        -- agreement with the same vendor sites or no vendor sites and
        -- if they have different priorities ,update the vendor ids
        -- with the higher priority of the two

	BEGIN

        fun_net_util.Log_String(g_event_level,
				l_path
				,'Updating Netting Suppliers');

       	 UPDATE fun_net_suppliers_all s
	 	SET supplier_id  = p_vendor_id,
     		supplier_site_id = decode(supplier_site_id,p_dup_vendor_site_id,
	 			   p_vendor_site_id, supplier_site_id)
        WHERE  supplier_id = p_dup_vendor_id
			AND    nvl(supplier_site_id, 0)  =
				decode(supplier_site_id, NULL,
				 0, p_dup_vendor_site_id);

         fun_net_util.Log_String(g_event_level
			        ,l_path
				,'Rows Updated'|| sql%rowcount);

        UPDATE fun_net_suppliers_all s
        SET   supplier_priority = (
			SELECT min(supplier_priority)
		        FROM  fun_net_suppliers_all
			WHERE agreement_id = s.agreement_id
			AND supplier_id = s.supplier_id
		 	AND nvl(supplier_site_id,0) =
					decode(s.supplier_site_id,
	                                NULL,0,s.supplier_site_id))
        WHERE supplier_id = p_vendor_id
       	 AND nvl(supplier_site_id, 0)  =
			decode(supplier_site_id, NULL,
			 0, p_vendor_site_id);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			null;

		WHEN OTHERS THEN

        		fun_net_util.Log_String(g_event_level,
				l_path
				,'sqlcode '||sqlcode||' sqlerrm ' || sqlerrm);
			RAISE FND_API.G_EXC_ERROR;
     	END;

/* Delete the record that has the same agreement id, supplier priority , vendor and vendor site */

     BEGIN

        fun_net_util.Log_String(g_event_level,
				l_path
				,'Deleting Records');

      	DELETE FROM fun_net_suppliers_all s
     	WHERE netting_supplier_id = (SELECT min(netting_supplier_id)
			 FROM fun_net_suppliers_all
			 WHERE
			     s.agreement_id = agreement_id
			 AND s.supplier_id = supplier_id
			 AND nvl(s.supplier_site_id,0) = nvl(supplier_site_id,0)
	 		 AND s.supplier_priority = supplier_priority
			 GROUP BY agreement_id,
				  supplier_id,
			 	  supplier_site_id,
		 	  	  supplier_priority
	                HAVING COUNT(netting_supplier_id) > 1);

        fun_net_util.Log_String(g_event_level,
				l_path
				,'Records Deleted' || sql%rowcount);

        fun_net_util.Log_String(g_event_level,
				l_path
				,'Supplier Merge (-)');
     EXCEPTION
     	WHEN NO_DATA_FOUND THEN
     		null;
	WHEN OTHERS THEN

        	fun_net_util.Log_String
				(g_event_level,
				 l_path
				,'sqlcode' || sqlcode || 'sqlerrm ' || sqlerrm);

     END;

 	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT WORK;
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO Merge_Vendor_SP;
            p_return_status := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.Count_And_Get (
                p_count    =>  p_msg_count,
                p_data     =>  p_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO Merge_Vendor_SP;
            p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            FND_MSG_PUB.Count_And_Get (
                p_count    =>  p_msg_count,
                p_data     =>  p_msg_data );

        WHEN OTHERS THEN
            ROLLBACK TO Merge_Vendor_SP;
            p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level(
			FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            	FND_MSG_PUB.Add_Exc_Msg( 'FUN_VendorMerge_PKG', 'Merge_Vendor');
            END IF;
            FND_MSG_PUB.Count_And_Get (
                p_count    =>  p_msg_count,
                p_data     =>  p_msg_data );
	END Merge_Vendor;

BEGIN
    g_today := TRUNC(sysdate);
END FUN_VendorMerge_GRP;

/
